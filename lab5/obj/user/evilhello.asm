
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800049:	e8 76 00 00 00       	call   8000c4 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 20             	sub    $0x20,%esp
  800058:	8b 75 08             	mov    0x8(%ebp),%esi
  80005b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80005e:	e8 f0 00 00 00       	call   800153 <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006f:	c1 e0 07             	shl    $0x7,%eax
  800072:	29 d0                	sub    %edx,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  80007c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80007f:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800084:	85 f6                	test   %esi,%esi
  800086:	7e 07                	jle    80008f <libmain+0x3f>
		binaryname = argv[0];
  800088:	8b 03                	mov    (%ebx),%eax
  80008a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800093:	89 34 24             	mov    %esi,(%esp)
  800096:	e8 99 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009b:	e8 08 00 00 00       	call   8000a8 <exit>
}
  8000a0:	83 c4 20             	add    $0x20,%esp
  8000a3:	5b                   	pop    %ebx
  8000a4:	5e                   	pop    %esi
  8000a5:	5d                   	pop    %ebp
  8000a6:	c3                   	ret    
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ae:	e8 32 05 00 00       	call   8005e5 <close_all>
	sys_env_destroy(0);
  8000b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ba:	e8 42 00 00 00       	call   800101 <sys_env_destroy>
}
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    
  8000c1:	00 00                	add    %al,(%eax)
	...

008000c4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d5:	89 c3                	mov    %eax,%ebx
  8000d7:	89 c7                	mov    %eax,%edi
  8000d9:	89 c6                	mov    %eax,%esi
  8000db:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f2:	89 d1                	mov    %edx,%ecx
  8000f4:	89 d3                	mov    %edx,%ebx
  8000f6:	89 d7                	mov    %edx,%edi
  8000f8:	89 d6                	mov    %edx,%esi
  8000fa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    

00800101 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	57                   	push   %edi
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010f:	b8 03 00 00 00       	mov    $0x3,%eax
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	89 cb                	mov    %ecx,%ebx
  800119:	89 cf                	mov    %ecx,%edi
  80011b:	89 ce                	mov    %ecx,%esi
  80011d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80011f:	85 c0                	test   %eax,%eax
  800121:	7e 28                	jle    80014b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800123:	89 44 24 10          	mov    %eax,0x10(%esp)
  800127:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80012e:	00 
  80012f:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  800136:	00 
  800137:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80013e:	00 
  80013f:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  800146:	e8 c1 10 00 00       	call   80120c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014b:	83 c4 2c             	add    $0x2c,%esp
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	5f                   	pop    %edi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	b8 02 00 00 00       	mov    $0x2,%eax
  800163:	89 d1                	mov    %edx,%ecx
  800165:	89 d3                	mov    %edx,%ebx
  800167:	89 d7                	mov    %edx,%edi
  800169:	89 d6                	mov    %edx,%esi
  80016b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016d:	5b                   	pop    %ebx
  80016e:	5e                   	pop    %esi
  80016f:	5f                   	pop    %edi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <sys_yield>:

void
sys_yield(void)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800178:	ba 00 00 00 00       	mov    $0x0,%edx
  80017d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800182:	89 d1                	mov    %edx,%ecx
  800184:	89 d3                	mov    %edx,%ebx
  800186:	89 d7                	mov    %edx,%edi
  800188:	89 d6                	mov    %edx,%esi
  80018a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019a:	be 00 00 00 00       	mov    $0x0,%esi
  80019f:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	89 f7                	mov    %esi,%edi
  8001af:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b1:	85 c0                	test   %eax,%eax
  8001b3:	7e 28                	jle    8001dd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001c0:	00 
  8001c1:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001d0:	00 
  8001d1:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  8001d8:	e8 2f 10 00 00       	call   80120c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001dd:	83 c4 2c             	add    $0x2c,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5f                   	pop    %edi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800202:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800204:	85 c0                	test   %eax,%eax
  800206:	7e 28                	jle    800230 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800208:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800213:	00 
  800214:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  80021b:	00 
  80021c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800223:	00 
  800224:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  80022b:	e8 dc 0f 00 00       	call   80120c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800230:	83 c4 2c             	add    $0x2c,%esp
  800233:	5b                   	pop    %ebx
  800234:	5e                   	pop    %esi
  800235:	5f                   	pop    %edi
  800236:	5d                   	pop    %ebp
  800237:	c3                   	ret    

00800238 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800241:	bb 00 00 00 00       	mov    $0x0,%ebx
  800246:	b8 06 00 00 00       	mov    $0x6,%eax
  80024b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024e:	8b 55 08             	mov    0x8(%ebp),%edx
  800251:	89 df                	mov    %ebx,%edi
  800253:	89 de                	mov    %ebx,%esi
  800255:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800257:	85 c0                	test   %eax,%eax
  800259:	7e 28                	jle    800283 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80025f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800266:	00 
  800267:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  80026e:	00 
  80026f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800276:	00 
  800277:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  80027e:	e8 89 0f 00 00       	call   80120c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800283:	83 c4 2c             	add    $0x2c,%esp
  800286:	5b                   	pop    %ebx
  800287:	5e                   	pop    %esi
  800288:	5f                   	pop    %edi
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    

0080028b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	57                   	push   %edi
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800294:	bb 00 00 00 00       	mov    $0x0,%ebx
  800299:	b8 08 00 00 00       	mov    $0x8,%eax
  80029e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a4:	89 df                	mov    %ebx,%edi
  8002a6:	89 de                	mov    %ebx,%esi
  8002a8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002aa:	85 c0                	test   %eax,%eax
  8002ac:	7e 28                	jle    8002d6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002b2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c9:	00 
  8002ca:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  8002d1:	e8 36 0f 00 00       	call   80120c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002d6:	83 c4 2c             	add    $0x2c,%esp
  8002d9:	5b                   	pop    %ebx
  8002da:	5e                   	pop    %esi
  8002db:	5f                   	pop    %edi
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	57                   	push   %edi
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ec:	b8 09 00 00 00       	mov    $0x9,%eax
  8002f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f7:	89 df                	mov    %ebx,%edi
  8002f9:	89 de                	mov    %ebx,%esi
  8002fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002fd:	85 c0                	test   %eax,%eax
  8002ff:	7e 28                	jle    800329 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800301:	89 44 24 10          	mov    %eax,0x10(%esp)
  800305:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80030c:	00 
  80030d:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  800314:	00 
  800315:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80031c:	00 
  80031d:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  800324:	e8 e3 0e 00 00       	call   80120c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800329:	83 c4 2c             	add    $0x2c,%esp
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800344:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800347:	8b 55 08             	mov    0x8(%ebp),%edx
  80034a:	89 df                	mov    %ebx,%edi
  80034c:	89 de                	mov    %ebx,%esi
  80034e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800350:	85 c0                	test   %eax,%eax
  800352:	7e 28                	jle    80037c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800354:	89 44 24 10          	mov    %eax,0x10(%esp)
  800358:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80035f:	00 
  800360:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  800367:	00 
  800368:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80036f:	00 
  800370:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  800377:	e8 90 0e 00 00       	call   80120c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80037c:	83 c4 2c             	add    $0x2c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038a:	be 00 00 00 00       	mov    $0x0,%esi
  80038f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800394:	8b 7d 14             	mov    0x14(%ebp),%edi
  800397:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80039a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80039d:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003a2:	5b                   	pop    %ebx
  8003a3:	5e                   	pop    %esi
  8003a4:	5f                   	pop    %edi
  8003a5:	5d                   	pop    %ebp
  8003a6:	c3                   	ret    

008003a7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	57                   	push   %edi
  8003ab:	56                   	push   %esi
  8003ac:	53                   	push   %ebx
  8003ad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bd:	89 cb                	mov    %ecx,%ebx
  8003bf:	89 cf                	mov    %ecx,%edi
  8003c1:	89 ce                	mov    %ecx,%esi
  8003c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003c5:	85 c0                	test   %eax,%eax
  8003c7:	7e 28                	jle    8003f1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003cd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003d4:	00 
  8003d5:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8003dc:	00 
  8003dd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003e4:	00 
  8003e5:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  8003ec:	e8 1b 0e 00 00       	call   80120c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003f1:	83 c4 2c             	add    $0x2c,%esp
  8003f4:	5b                   	pop    %ebx
  8003f5:	5e                   	pop    %esi
  8003f6:	5f                   	pop    %edi
  8003f7:	5d                   	pop    %ebp
  8003f8:	c3                   	ret    
  8003f9:	00 00                	add    %al,(%eax)
	...

008003fc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	05 00 00 00 30       	add    $0x30000000,%eax
  800407:	c1 e8 0c             	shr    $0xc,%eax
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800412:	8b 45 08             	mov    0x8(%ebp),%eax
  800415:	89 04 24             	mov    %eax,(%esp)
  800418:	e8 df ff ff ff       	call   8003fc <fd2num>
  80041d:	05 20 00 0d 00       	add    $0xd0020,%eax
  800422:	c1 e0 0c             	shl    $0xc,%eax
}
  800425:	c9                   	leave  
  800426:	c3                   	ret    

00800427 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	53                   	push   %ebx
  80042b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80042e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800433:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800435:	89 c2                	mov    %eax,%edx
  800437:	c1 ea 16             	shr    $0x16,%edx
  80043a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800441:	f6 c2 01             	test   $0x1,%dl
  800444:	74 11                	je     800457 <fd_alloc+0x30>
  800446:	89 c2                	mov    %eax,%edx
  800448:	c1 ea 0c             	shr    $0xc,%edx
  80044b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800452:	f6 c2 01             	test   $0x1,%dl
  800455:	75 09                	jne    800460 <fd_alloc+0x39>
			*fd_store = fd;
  800457:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800459:	b8 00 00 00 00       	mov    $0x0,%eax
  80045e:	eb 17                	jmp    800477 <fd_alloc+0x50>
  800460:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800465:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80046a:	75 c7                	jne    800433 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80046c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800472:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800477:	5b                   	pop    %ebx
  800478:	5d                   	pop    %ebp
  800479:	c3                   	ret    

0080047a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800480:	83 f8 1f             	cmp    $0x1f,%eax
  800483:	77 36                	ja     8004bb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800485:	05 00 00 0d 00       	add    $0xd0000,%eax
  80048a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80048d:	89 c2                	mov    %eax,%edx
  80048f:	c1 ea 16             	shr    $0x16,%edx
  800492:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800499:	f6 c2 01             	test   $0x1,%dl
  80049c:	74 24                	je     8004c2 <fd_lookup+0x48>
  80049e:	89 c2                	mov    %eax,%edx
  8004a0:	c1 ea 0c             	shr    $0xc,%edx
  8004a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004aa:	f6 c2 01             	test   $0x1,%dl
  8004ad:	74 1a                	je     8004c9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b2:	89 02                	mov    %eax,(%edx)
	return 0;
  8004b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b9:	eb 13                	jmp    8004ce <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004c0:	eb 0c                	jmp    8004ce <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004c7:	eb 05                	jmp    8004ce <fd_lookup+0x54>
  8004c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004ce:	5d                   	pop    %ebp
  8004cf:	c3                   	ret    

008004d0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	53                   	push   %ebx
  8004d4:	83 ec 14             	sub    $0x14,%esp
  8004d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8004dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e2:	eb 0e                	jmp    8004f2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8004e4:	39 08                	cmp    %ecx,(%eax)
  8004e6:	75 09                	jne    8004f1 <dev_lookup+0x21>
			*dev = devtab[i];
  8004e8:	89 03                	mov    %eax,(%ebx)
			return 0;
  8004ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ef:	eb 35                	jmp    800526 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004f1:	42                   	inc    %edx
  8004f2:	8b 04 95 34 20 80 00 	mov    0x802034(,%edx,4),%eax
  8004f9:	85 c0                	test   %eax,%eax
  8004fb:	75 e7                	jne    8004e4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004fd:	a1 04 40 80 00       	mov    0x804004,%eax
  800502:	8b 00                	mov    (%eax),%eax
  800504:	8b 40 48             	mov    0x48(%eax),%eax
  800507:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80050b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050f:	c7 04 24 b8 1f 80 00 	movl   $0x801fb8,(%esp)
  800516:	e8 e9 0d 00 00       	call   801304 <cprintf>
	*dev = 0;
  80051b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800521:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800526:	83 c4 14             	add    $0x14,%esp
  800529:	5b                   	pop    %ebx
  80052a:	5d                   	pop    %ebp
  80052b:	c3                   	ret    

0080052c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	56                   	push   %esi
  800530:	53                   	push   %ebx
  800531:	83 ec 30             	sub    $0x30,%esp
  800534:	8b 75 08             	mov    0x8(%ebp),%esi
  800537:	8a 45 0c             	mov    0xc(%ebp),%al
  80053a:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80053d:	89 34 24             	mov    %esi,(%esp)
  800540:	e8 b7 fe ff ff       	call   8003fc <fd2num>
  800545:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800548:	89 54 24 04          	mov    %edx,0x4(%esp)
  80054c:	89 04 24             	mov    %eax,(%esp)
  80054f:	e8 26 ff ff ff       	call   80047a <fd_lookup>
  800554:	89 c3                	mov    %eax,%ebx
  800556:	85 c0                	test   %eax,%eax
  800558:	78 05                	js     80055f <fd_close+0x33>
	    || fd != fd2)
  80055a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80055d:	74 0d                	je     80056c <fd_close+0x40>
		return (must_exist ? r : 0);
  80055f:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800563:	75 46                	jne    8005ab <fd_close+0x7f>
  800565:	bb 00 00 00 00       	mov    $0x0,%ebx
  80056a:	eb 3f                	jmp    8005ab <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80056c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80056f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800573:	8b 06                	mov    (%esi),%eax
  800575:	89 04 24             	mov    %eax,(%esp)
  800578:	e8 53 ff ff ff       	call   8004d0 <dev_lookup>
  80057d:	89 c3                	mov    %eax,%ebx
  80057f:	85 c0                	test   %eax,%eax
  800581:	78 18                	js     80059b <fd_close+0x6f>
		if (dev->dev_close)
  800583:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800586:	8b 40 10             	mov    0x10(%eax),%eax
  800589:	85 c0                	test   %eax,%eax
  80058b:	74 09                	je     800596 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80058d:	89 34 24             	mov    %esi,(%esp)
  800590:	ff d0                	call   *%eax
  800592:	89 c3                	mov    %eax,%ebx
  800594:	eb 05                	jmp    80059b <fd_close+0x6f>
		else
			r = 0;
  800596:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80059b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80059f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005a6:	e8 8d fc ff ff       	call   800238 <sys_page_unmap>
	return r;
}
  8005ab:	89 d8                	mov    %ebx,%eax
  8005ad:	83 c4 30             	add    $0x30,%esp
  8005b0:	5b                   	pop    %ebx
  8005b1:	5e                   	pop    %esi
  8005b2:	5d                   	pop    %ebp
  8005b3:	c3                   	ret    

008005b4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005b4:	55                   	push   %ebp
  8005b5:	89 e5                	mov    %esp,%ebp
  8005b7:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c4:	89 04 24             	mov    %eax,(%esp)
  8005c7:	e8 ae fe ff ff       	call   80047a <fd_lookup>
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	78 13                	js     8005e3 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005d7:	00 
  8005d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005db:	89 04 24             	mov    %eax,(%esp)
  8005de:	e8 49 ff ff ff       	call   80052c <fd_close>
}
  8005e3:	c9                   	leave  
  8005e4:	c3                   	ret    

008005e5 <close_all>:

void
close_all(void)
{
  8005e5:	55                   	push   %ebp
  8005e6:	89 e5                	mov    %esp,%ebp
  8005e8:	53                   	push   %ebx
  8005e9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005f1:	89 1c 24             	mov    %ebx,(%esp)
  8005f4:	e8 bb ff ff ff       	call   8005b4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005f9:	43                   	inc    %ebx
  8005fa:	83 fb 20             	cmp    $0x20,%ebx
  8005fd:	75 f2                	jne    8005f1 <close_all+0xc>
		close(i);
}
  8005ff:	83 c4 14             	add    $0x14,%esp
  800602:	5b                   	pop    %ebx
  800603:	5d                   	pop    %ebp
  800604:	c3                   	ret    

00800605 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800605:	55                   	push   %ebp
  800606:	89 e5                	mov    %esp,%ebp
  800608:	57                   	push   %edi
  800609:	56                   	push   %esi
  80060a:	53                   	push   %ebx
  80060b:	83 ec 4c             	sub    $0x4c,%esp
  80060e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800611:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800614:	89 44 24 04          	mov    %eax,0x4(%esp)
  800618:	8b 45 08             	mov    0x8(%ebp),%eax
  80061b:	89 04 24             	mov    %eax,(%esp)
  80061e:	e8 57 fe ff ff       	call   80047a <fd_lookup>
  800623:	89 c3                	mov    %eax,%ebx
  800625:	85 c0                	test   %eax,%eax
  800627:	0f 88 e1 00 00 00    	js     80070e <dup+0x109>
		return r;
	close(newfdnum);
  80062d:	89 3c 24             	mov    %edi,(%esp)
  800630:	e8 7f ff ff ff       	call   8005b4 <close>

	newfd = INDEX2FD(newfdnum);
  800635:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80063b:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80063e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800641:	89 04 24             	mov    %eax,(%esp)
  800644:	e8 c3 fd ff ff       	call   80040c <fd2data>
  800649:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80064b:	89 34 24             	mov    %esi,(%esp)
  80064e:	e8 b9 fd ff ff       	call   80040c <fd2data>
  800653:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800656:	89 d8                	mov    %ebx,%eax
  800658:	c1 e8 16             	shr    $0x16,%eax
  80065b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800662:	a8 01                	test   $0x1,%al
  800664:	74 46                	je     8006ac <dup+0xa7>
  800666:	89 d8                	mov    %ebx,%eax
  800668:	c1 e8 0c             	shr    $0xc,%eax
  80066b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800672:	f6 c2 01             	test   $0x1,%dl
  800675:	74 35                	je     8006ac <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800677:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80067e:	25 07 0e 00 00       	and    $0xe07,%eax
  800683:	89 44 24 10          	mov    %eax,0x10(%esp)
  800687:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80068a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800695:	00 
  800696:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006a1:	e8 3f fb ff ff       	call   8001e5 <sys_page_map>
  8006a6:	89 c3                	mov    %eax,%ebx
  8006a8:	85 c0                	test   %eax,%eax
  8006aa:	78 3b                	js     8006e7 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006af:	89 c2                	mov    %eax,%edx
  8006b1:	c1 ea 0c             	shr    $0xc,%edx
  8006b4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006bb:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006c1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006c5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006d0:	00 
  8006d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006dc:	e8 04 fb ff ff       	call   8001e5 <sys_page_map>
  8006e1:	89 c3                	mov    %eax,%ebx
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	79 25                	jns    80070c <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006f2:	e8 41 fb ff ff       	call   800238 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006f7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800705:	e8 2e fb ff ff       	call   800238 <sys_page_unmap>
	return r;
  80070a:	eb 02                	jmp    80070e <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80070c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80070e:	89 d8                	mov    %ebx,%eax
  800710:	83 c4 4c             	add    $0x4c,%esp
  800713:	5b                   	pop    %ebx
  800714:	5e                   	pop    %esi
  800715:	5f                   	pop    %edi
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	53                   	push   %ebx
  80071c:	83 ec 24             	sub    $0x24,%esp
  80071f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800722:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800725:	89 44 24 04          	mov    %eax,0x4(%esp)
  800729:	89 1c 24             	mov    %ebx,(%esp)
  80072c:	e8 49 fd ff ff       	call   80047a <fd_lookup>
  800731:	85 c0                	test   %eax,%eax
  800733:	78 6f                	js     8007a4 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800735:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073f:	8b 00                	mov    (%eax),%eax
  800741:	89 04 24             	mov    %eax,(%esp)
  800744:	e8 87 fd ff ff       	call   8004d0 <dev_lookup>
  800749:	85 c0                	test   %eax,%eax
  80074b:	78 57                	js     8007a4 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80074d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800750:	8b 50 08             	mov    0x8(%eax),%edx
  800753:	83 e2 03             	and    $0x3,%edx
  800756:	83 fa 01             	cmp    $0x1,%edx
  800759:	75 25                	jne    800780 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80075b:	a1 04 40 80 00       	mov    0x804004,%eax
  800760:	8b 00                	mov    (%eax),%eax
  800762:	8b 40 48             	mov    0x48(%eax),%eax
  800765:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800769:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076d:	c7 04 24 f9 1f 80 00 	movl   $0x801ff9,(%esp)
  800774:	e8 8b 0b 00 00       	call   801304 <cprintf>
		return -E_INVAL;
  800779:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077e:	eb 24                	jmp    8007a4 <read+0x8c>
	}
	if (!dev->dev_read)
  800780:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800783:	8b 52 08             	mov    0x8(%edx),%edx
  800786:	85 d2                	test   %edx,%edx
  800788:	74 15                	je     80079f <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80078a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80078d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800791:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800794:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800798:	89 04 24             	mov    %eax,(%esp)
  80079b:	ff d2                	call   *%edx
  80079d:	eb 05                	jmp    8007a4 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80079f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8007a4:	83 c4 24             	add    $0x24,%esp
  8007a7:	5b                   	pop    %ebx
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	57                   	push   %edi
  8007ae:	56                   	push   %esi
  8007af:	53                   	push   %ebx
  8007b0:	83 ec 1c             	sub    $0x1c,%esp
  8007b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007b6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007be:	eb 23                	jmp    8007e3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007c0:	89 f0                	mov    %esi,%eax
  8007c2:	29 d8                	sub    %ebx,%eax
  8007c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cb:	01 d8                	add    %ebx,%eax
  8007cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d1:	89 3c 24             	mov    %edi,(%esp)
  8007d4:	e8 3f ff ff ff       	call   800718 <read>
		if (m < 0)
  8007d9:	85 c0                	test   %eax,%eax
  8007db:	78 10                	js     8007ed <readn+0x43>
			return m;
		if (m == 0)
  8007dd:	85 c0                	test   %eax,%eax
  8007df:	74 0a                	je     8007eb <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007e1:	01 c3                	add    %eax,%ebx
  8007e3:	39 f3                	cmp    %esi,%ebx
  8007e5:	72 d9                	jb     8007c0 <readn+0x16>
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	eb 02                	jmp    8007ed <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8007eb:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007ed:	83 c4 1c             	add    $0x1c,%esp
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5f                   	pop    %edi
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	53                   	push   %ebx
  8007f9:	83 ec 24             	sub    $0x24,%esp
  8007fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800802:	89 44 24 04          	mov    %eax,0x4(%esp)
  800806:	89 1c 24             	mov    %ebx,(%esp)
  800809:	e8 6c fc ff ff       	call   80047a <fd_lookup>
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 6a                	js     80087c <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800812:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800815:	89 44 24 04          	mov    %eax,0x4(%esp)
  800819:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081c:	8b 00                	mov    (%eax),%eax
  80081e:	89 04 24             	mov    %eax,(%esp)
  800821:	e8 aa fc ff ff       	call   8004d0 <dev_lookup>
  800826:	85 c0                	test   %eax,%eax
  800828:	78 52                	js     80087c <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80082a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800831:	75 25                	jne    800858 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800833:	a1 04 40 80 00       	mov    0x804004,%eax
  800838:	8b 00                	mov    (%eax),%eax
  80083a:	8b 40 48             	mov    0x48(%eax),%eax
  80083d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800841:	89 44 24 04          	mov    %eax,0x4(%esp)
  800845:	c7 04 24 15 20 80 00 	movl   $0x802015,(%esp)
  80084c:	e8 b3 0a 00 00       	call   801304 <cprintf>
		return -E_INVAL;
  800851:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800856:	eb 24                	jmp    80087c <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800858:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085b:	8b 52 0c             	mov    0xc(%edx),%edx
  80085e:	85 d2                	test   %edx,%edx
  800860:	74 15                	je     800877 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800862:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800865:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800869:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800870:	89 04 24             	mov    %eax,(%esp)
  800873:	ff d2                	call   *%edx
  800875:	eb 05                	jmp    80087c <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800877:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80087c:	83 c4 24             	add    $0x24,%esp
  80087f:	5b                   	pop    %ebx
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <seek>:

int
seek(int fdnum, off_t offset)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800888:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80088b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	89 04 24             	mov    %eax,(%esp)
  800895:	e8 e0 fb ff ff       	call   80047a <fd_lookup>
  80089a:	85 c0                	test   %eax,%eax
  80089c:	78 0e                	js     8008ac <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80089e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    

008008ae <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	53                   	push   %ebx
  8008b2:	83 ec 24             	sub    $0x24,%esp
  8008b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008bf:	89 1c 24             	mov    %ebx,(%esp)
  8008c2:	e8 b3 fb ff ff       	call   80047a <fd_lookup>
  8008c7:	85 c0                	test   %eax,%eax
  8008c9:	78 63                	js     80092e <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d5:	8b 00                	mov    (%eax),%eax
  8008d7:	89 04 24             	mov    %eax,(%esp)
  8008da:	e8 f1 fb ff ff       	call   8004d0 <dev_lookup>
  8008df:	85 c0                	test   %eax,%eax
  8008e1:	78 4b                	js     80092e <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008ea:	75 25                	jne    800911 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008ec:	a1 04 40 80 00       	mov    0x804004,%eax
  8008f1:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008f3:	8b 40 48             	mov    0x48(%eax),%eax
  8008f6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fe:	c7 04 24 d8 1f 80 00 	movl   $0x801fd8,(%esp)
  800905:	e8 fa 09 00 00       	call   801304 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80090a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80090f:	eb 1d                	jmp    80092e <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  800911:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800914:	8b 52 18             	mov    0x18(%edx),%edx
  800917:	85 d2                	test   %edx,%edx
  800919:	74 0e                	je     800929 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80091b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800922:	89 04 24             	mov    %eax,(%esp)
  800925:	ff d2                	call   *%edx
  800927:	eb 05                	jmp    80092e <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800929:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80092e:	83 c4 24             	add    $0x24,%esp
  800931:	5b                   	pop    %ebx
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	53                   	push   %ebx
  800938:	83 ec 24             	sub    $0x24,%esp
  80093b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80093e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800941:	89 44 24 04          	mov    %eax,0x4(%esp)
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	89 04 24             	mov    %eax,(%esp)
  80094b:	e8 2a fb ff ff       	call   80047a <fd_lookup>
  800950:	85 c0                	test   %eax,%eax
  800952:	78 52                	js     8009a6 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800954:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800957:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80095e:	8b 00                	mov    (%eax),%eax
  800960:	89 04 24             	mov    %eax,(%esp)
  800963:	e8 68 fb ff ff       	call   8004d0 <dev_lookup>
  800968:	85 c0                	test   %eax,%eax
  80096a:	78 3a                	js     8009a6 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80096c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800973:	74 2c                	je     8009a1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800975:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800978:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80097f:	00 00 00 
	stat->st_isdir = 0;
  800982:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800989:	00 00 00 
	stat->st_dev = dev;
  80098c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800992:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800996:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800999:	89 14 24             	mov    %edx,(%esp)
  80099c:	ff 50 14             	call   *0x14(%eax)
  80099f:	eb 05                	jmp    8009a6 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8009a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8009a6:	83 c4 24             	add    $0x24,%esp
  8009a9:	5b                   	pop    %ebx
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009bb:	00 
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	89 04 24             	mov    %eax,(%esp)
  8009c2:	e8 88 02 00 00       	call   800c4f <open>
  8009c7:	89 c3                	mov    %eax,%ebx
  8009c9:	85 c0                	test   %eax,%eax
  8009cb:	78 1b                	js     8009e8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d4:	89 1c 24             	mov    %ebx,(%esp)
  8009d7:	e8 58 ff ff ff       	call   800934 <fstat>
  8009dc:	89 c6                	mov    %eax,%esi
	close(fd);
  8009de:	89 1c 24             	mov    %ebx,(%esp)
  8009e1:	e8 ce fb ff ff       	call   8005b4 <close>
	return r;
  8009e6:	89 f3                	mov    %esi,%ebx
}
  8009e8:	89 d8                	mov    %ebx,%eax
  8009ea:	83 c4 10             	add    $0x10,%esp
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    
  8009f1:	00 00                	add    %al,(%eax)
	...

008009f4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	83 ec 10             	sub    $0x10,%esp
  8009fc:	89 c3                	mov    %eax,%ebx
  8009fe:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a00:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a07:	75 11                	jne    800a1a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a09:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a10:	e8 92 12 00 00       	call   801ca7 <ipc_find_env>
  800a15:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a1a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a21:	00 
  800a22:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a29:	00 
  800a2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2e:	a1 00 40 80 00       	mov    0x804000,%eax
  800a33:	89 04 24             	mov    %eax,(%esp)
  800a36:	e8 06 12 00 00       	call   801c41 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  800a3b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a42:	00 
  800a43:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a4e:	e8 81 11 00 00       	call   801bd4 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  800a53:	83 c4 10             	add    $0x10,%esp
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	8b 40 0c             	mov    0xc(%eax),%eax
  800a66:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a73:	ba 00 00 00 00       	mov    $0x0,%edx
  800a78:	b8 02 00 00 00       	mov    $0x2,%eax
  800a7d:	e8 72 ff ff ff       	call   8009f4 <fsipc>
}
  800a82:	c9                   	leave  
  800a83:	c3                   	ret    

00800a84 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a90:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a95:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9a:	b8 06 00 00 00       	mov    $0x6,%eax
  800a9f:	e8 50 ff ff ff       	call   8009f4 <fsipc>
}
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    

00800aa6 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	53                   	push   %ebx
  800aaa:	83 ec 14             	sub    $0x14,%esp
  800aad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800abb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ac5:	e8 2a ff ff ff       	call   8009f4 <fsipc>
  800aca:	85 c0                	test   %eax,%eax
  800acc:	78 2b                	js     800af9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ace:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ad5:	00 
  800ad6:	89 1c 24             	mov    %ebx,(%esp)
  800ad9:	e8 d1 0d 00 00       	call   8018af <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ade:	a1 80 50 80 00       	mov    0x805080,%eax
  800ae3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ae9:	a1 84 50 80 00       	mov    0x805084,%eax
  800aee:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af9:	83 c4 14             	add    $0x14,%esp
  800afc:	5b                   	pop    %ebx
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	53                   	push   %ebx
  800b03:	83 ec 14             	sub    $0x14,%esp
  800b06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	8b 40 0c             	mov    0xc(%eax),%eax
  800b0f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  800b14:	89 d8                	mov    %ebx,%eax
  800b16:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800b1c:	76 05                	jbe    800b23 <devfile_write+0x24>
  800b1e:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800b23:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  800b28:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b33:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b3a:	e8 53 0f 00 00       	call   801a92 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  800b3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b44:	b8 04 00 00 00       	mov    $0x4,%eax
  800b49:	e8 a6 fe ff ff       	call   8009f4 <fsipc>
  800b4e:	85 c0                	test   %eax,%eax
  800b50:	78 53                	js     800ba5 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  800b52:	39 c3                	cmp    %eax,%ebx
  800b54:	73 24                	jae    800b7a <devfile_write+0x7b>
  800b56:	c7 44 24 0c 44 20 80 	movl   $0x802044,0xc(%esp)
  800b5d:	00 
  800b5e:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800b65:	00 
  800b66:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  800b6d:	00 
  800b6e:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800b75:	e8 92 06 00 00       	call   80120c <_panic>
	assert(r <= PGSIZE);
  800b7a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b7f:	7e 24                	jle    800ba5 <devfile_write+0xa6>
  800b81:	c7 44 24 0c 6b 20 80 	movl   $0x80206b,0xc(%esp)
  800b88:	00 
  800b89:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800b90:	00 
  800b91:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  800b98:	00 
  800b99:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800ba0:	e8 67 06 00 00       	call   80120c <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  800ba5:	83 c4 14             	add    $0x14,%esp
  800ba8:	5b                   	pop    %ebx
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
  800bb0:	83 ec 10             	sub    $0x10,%esp
  800bb3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb9:	8b 40 0c             	mov    0xc(%eax),%eax
  800bbc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800bc1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcc:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd1:	e8 1e fe ff ff       	call   8009f4 <fsipc>
  800bd6:	89 c3                	mov    %eax,%ebx
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	78 6a                	js     800c46 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800bdc:	39 c6                	cmp    %eax,%esi
  800bde:	73 24                	jae    800c04 <devfile_read+0x59>
  800be0:	c7 44 24 0c 44 20 80 	movl   $0x802044,0xc(%esp)
  800be7:	00 
  800be8:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800bef:	00 
  800bf0:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  800bf7:	00 
  800bf8:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800bff:	e8 08 06 00 00       	call   80120c <_panic>
	assert(r <= PGSIZE);
  800c04:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c09:	7e 24                	jle    800c2f <devfile_read+0x84>
  800c0b:	c7 44 24 0c 6b 20 80 	movl   $0x80206b,0xc(%esp)
  800c12:	00 
  800c13:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800c1a:	00 
  800c1b:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  800c22:	00 
  800c23:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800c2a:	e8 dd 05 00 00       	call   80120c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c33:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c3a:	00 
  800c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3e:	89 04 24             	mov    %eax,(%esp)
  800c41:	e8 e2 0d 00 00       	call   801a28 <memmove>
	return r;
}
  800c46:	89 d8                	mov    %ebx,%eax
  800c48:	83 c4 10             	add    $0x10,%esp
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	83 ec 20             	sub    $0x20,%esp
  800c57:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c5a:	89 34 24             	mov    %esi,(%esp)
  800c5d:	e8 1a 0c 00 00       	call   80187c <strlen>
  800c62:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c67:	7f 60                	jg     800cc9 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c6c:	89 04 24             	mov    %eax,(%esp)
  800c6f:	e8 b3 f7 ff ff       	call   800427 <fd_alloc>
  800c74:	89 c3                	mov    %eax,%ebx
  800c76:	85 c0                	test   %eax,%eax
  800c78:	78 54                	js     800cce <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c7a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c7e:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c85:	e8 25 0c 00 00       	call   8018af <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c92:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c95:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9a:	e8 55 fd ff ff       	call   8009f4 <fsipc>
  800c9f:	89 c3                	mov    %eax,%ebx
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	79 15                	jns    800cba <open+0x6b>
		fd_close(fd, 0);
  800ca5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cac:	00 
  800cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb0:	89 04 24             	mov    %eax,(%esp)
  800cb3:	e8 74 f8 ff ff       	call   80052c <fd_close>
		return r;
  800cb8:	eb 14                	jmp    800cce <open+0x7f>
	}

	return fd2num(fd);
  800cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cbd:	89 04 24             	mov    %eax,(%esp)
  800cc0:	e8 37 f7 ff ff       	call   8003fc <fd2num>
  800cc5:	89 c3                	mov    %eax,%ebx
  800cc7:	eb 05                	jmp    800cce <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cc9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800cce:	89 d8                	mov    %ebx,%eax
  800cd0:	83 c4 20             	add    $0x20,%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800cdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce2:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce7:	e8 08 fd ff ff       	call   8009f4 <fsipc>
}
  800cec:	c9                   	leave  
  800ced:	c3                   	ret    
	...

00800cf0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 10             	sub    $0x10,%esp
  800cf8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	89 04 24             	mov    %eax,(%esp)
  800d01:	e8 06 f7 ff ff       	call   80040c <fd2data>
  800d06:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800d08:	c7 44 24 04 77 20 80 	movl   $0x802077,0x4(%esp)
  800d0f:	00 
  800d10:	89 34 24             	mov    %esi,(%esp)
  800d13:	e8 97 0b 00 00       	call   8018af <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800d18:	8b 43 04             	mov    0x4(%ebx),%eax
  800d1b:	2b 03                	sub    (%ebx),%eax
  800d1d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800d23:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800d2a:	00 00 00 
	stat->st_dev = &devpipe;
  800d2d:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800d34:	30 80 00 
	return 0;
}
  800d37:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3c:	83 c4 10             	add    $0x10,%esp
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	53                   	push   %ebx
  800d47:	83 ec 14             	sub    $0x14,%esp
  800d4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800d4d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d58:	e8 db f4 ff ff       	call   800238 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800d5d:	89 1c 24             	mov    %ebx,(%esp)
  800d60:	e8 a7 f6 ff ff       	call   80040c <fd2data>
  800d65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d69:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d70:	e8 c3 f4 ff ff       	call   800238 <sys_page_unmap>
}
  800d75:	83 c4 14             	add    $0x14,%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 2c             	sub    $0x2c,%esp
  800d84:	89 c7                	mov    %eax,%edi
  800d86:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800d89:	a1 04 40 80 00       	mov    0x804004,%eax
  800d8e:	8b 00                	mov    (%eax),%eax
  800d90:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800d93:	89 3c 24             	mov    %edi,(%esp)
  800d96:	e8 51 0f 00 00       	call   801cec <pageref>
  800d9b:	89 c6                	mov    %eax,%esi
  800d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800da0:	89 04 24             	mov    %eax,(%esp)
  800da3:	e8 44 0f 00 00       	call   801cec <pageref>
  800da8:	39 c6                	cmp    %eax,%esi
  800daa:	0f 94 c0             	sete   %al
  800dad:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800db0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800db6:	8b 12                	mov    (%edx),%edx
  800db8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800dbb:	39 cb                	cmp    %ecx,%ebx
  800dbd:	75 08                	jne    800dc7 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800dbf:	83 c4 2c             	add    $0x2c,%esp
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5f                   	pop    %edi
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800dc7:	83 f8 01             	cmp    $0x1,%eax
  800dca:	75 bd                	jne    800d89 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800dcc:	8b 42 58             	mov    0x58(%edx),%eax
  800dcf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800dd6:	00 
  800dd7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ddb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ddf:	c7 04 24 7e 20 80 00 	movl   $0x80207e,(%esp)
  800de6:	e8 19 05 00 00       	call   801304 <cprintf>
  800deb:	eb 9c                	jmp    800d89 <_pipeisclosed+0xe>

00800ded <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	83 ec 1c             	sub    $0x1c,%esp
  800df6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800df9:	89 34 24             	mov    %esi,(%esp)
  800dfc:	e8 0b f6 ff ff       	call   80040c <fd2data>
  800e01:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e03:	bf 00 00 00 00       	mov    $0x0,%edi
  800e08:	eb 3c                	jmp    800e46 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800e0a:	89 da                	mov    %ebx,%edx
  800e0c:	89 f0                	mov    %esi,%eax
  800e0e:	e8 68 ff ff ff       	call   800d7b <_pipeisclosed>
  800e13:	85 c0                	test   %eax,%eax
  800e15:	75 38                	jne    800e4f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800e17:	e8 56 f3 ff ff       	call   800172 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800e1c:	8b 43 04             	mov    0x4(%ebx),%eax
  800e1f:	8b 13                	mov    (%ebx),%edx
  800e21:	83 c2 20             	add    $0x20,%edx
  800e24:	39 d0                	cmp    %edx,%eax
  800e26:	73 e2                	jae    800e0a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800e28:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e2b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800e2e:	89 c2                	mov    %eax,%edx
  800e30:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800e36:	79 05                	jns    800e3d <devpipe_write+0x50>
  800e38:	4a                   	dec    %edx
  800e39:	83 ca e0             	or     $0xffffffe0,%edx
  800e3c:	42                   	inc    %edx
  800e3d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800e41:	40                   	inc    %eax
  800e42:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e45:	47                   	inc    %edi
  800e46:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800e49:	75 d1                	jne    800e1c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800e4b:	89 f8                	mov    %edi,%eax
  800e4d:	eb 05                	jmp    800e54 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e4f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800e54:	83 c4 1c             	add    $0x1c,%esp
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
  800e62:	83 ec 1c             	sub    $0x1c,%esp
  800e65:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800e68:	89 3c 24             	mov    %edi,(%esp)
  800e6b:	e8 9c f5 ff ff       	call   80040c <fd2data>
  800e70:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e72:	be 00 00 00 00       	mov    $0x0,%esi
  800e77:	eb 3a                	jmp    800eb3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800e79:	85 f6                	test   %esi,%esi
  800e7b:	74 04                	je     800e81 <devpipe_read+0x25>
				return i;
  800e7d:	89 f0                	mov    %esi,%eax
  800e7f:	eb 40                	jmp    800ec1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800e81:	89 da                	mov    %ebx,%edx
  800e83:	89 f8                	mov    %edi,%eax
  800e85:	e8 f1 fe ff ff       	call   800d7b <_pipeisclosed>
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	75 2e                	jne    800ebc <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800e8e:	e8 df f2 ff ff       	call   800172 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800e93:	8b 03                	mov    (%ebx),%eax
  800e95:	3b 43 04             	cmp    0x4(%ebx),%eax
  800e98:	74 df                	je     800e79 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800e9a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800e9f:	79 05                	jns    800ea6 <devpipe_read+0x4a>
  800ea1:	48                   	dec    %eax
  800ea2:	83 c8 e0             	or     $0xffffffe0,%eax
  800ea5:	40                   	inc    %eax
  800ea6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800eaa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ead:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800eb0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800eb2:	46                   	inc    %esi
  800eb3:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eb6:	75 db                	jne    800e93 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800eb8:	89 f0                	mov    %esi,%eax
  800eba:	eb 05                	jmp    800ec1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ebc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800ec1:	83 c4 1c             	add    $0x1c,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	57                   	push   %edi
  800ecd:	56                   	push   %esi
  800ece:	53                   	push   %ebx
  800ecf:	83 ec 3c             	sub    $0x3c,%esp
  800ed2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800ed5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ed8:	89 04 24             	mov    %eax,(%esp)
  800edb:	e8 47 f5 ff ff       	call   800427 <fd_alloc>
  800ee0:	89 c3                	mov    %eax,%ebx
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	0f 88 45 01 00 00    	js     80102f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800eea:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ef1:	00 
  800ef2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ef5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f00:	e8 8c f2 ff ff       	call   800191 <sys_page_alloc>
  800f05:	89 c3                	mov    %eax,%ebx
  800f07:	85 c0                	test   %eax,%eax
  800f09:	0f 88 20 01 00 00    	js     80102f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800f0f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f12:	89 04 24             	mov    %eax,(%esp)
  800f15:	e8 0d f5 ff ff       	call   800427 <fd_alloc>
  800f1a:	89 c3                	mov    %eax,%ebx
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	0f 88 f8 00 00 00    	js     80101c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f24:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f2b:	00 
  800f2c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f3a:	e8 52 f2 ff ff       	call   800191 <sys_page_alloc>
  800f3f:	89 c3                	mov    %eax,%ebx
  800f41:	85 c0                	test   %eax,%eax
  800f43:	0f 88 d3 00 00 00    	js     80101c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800f49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f4c:	89 04 24             	mov    %eax,(%esp)
  800f4f:	e8 b8 f4 ff ff       	call   80040c <fd2data>
  800f54:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f56:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f5d:	00 
  800f5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f69:	e8 23 f2 ff ff       	call   800191 <sys_page_alloc>
  800f6e:	89 c3                	mov    %eax,%ebx
  800f70:	85 c0                	test   %eax,%eax
  800f72:	0f 88 91 00 00 00    	js     801009 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f78:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f7b:	89 04 24             	mov    %eax,(%esp)
  800f7e:	e8 89 f4 ff ff       	call   80040c <fd2data>
  800f83:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800f8a:	00 
  800f8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f96:	00 
  800f97:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa2:	e8 3e f2 ff ff       	call   8001e5 <sys_page_map>
  800fa7:	89 c3                	mov    %eax,%ebx
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 4c                	js     800ff9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800fad:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800fb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fb6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800fb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fbb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800fc2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800fc8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fcb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800fcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fd0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800fd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fda:	89 04 24             	mov    %eax,(%esp)
  800fdd:	e8 1a f4 ff ff       	call   8003fc <fd2num>
  800fe2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800fe4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fe7:	89 04 24             	mov    %eax,(%esp)
  800fea:	e8 0d f4 ff ff       	call   8003fc <fd2num>
  800fef:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800ff2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff7:	eb 36                	jmp    80102f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  800ff9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ffd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801004:	e8 2f f2 ff ff       	call   800238 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801009:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80100c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801010:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801017:	e8 1c f2 ff ff       	call   800238 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80101c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80101f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801023:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80102a:	e8 09 f2 ff ff       	call   800238 <sys_page_unmap>
    err:
	return r;
}
  80102f:	89 d8                	mov    %ebx,%eax
  801031:	83 c4 3c             	add    $0x3c,%esp
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80103f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801042:	89 44 24 04          	mov    %eax,0x4(%esp)
  801046:	8b 45 08             	mov    0x8(%ebp),%eax
  801049:	89 04 24             	mov    %eax,(%esp)
  80104c:	e8 29 f4 ff ff       	call   80047a <fd_lookup>
  801051:	85 c0                	test   %eax,%eax
  801053:	78 15                	js     80106a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801058:	89 04 24             	mov    %eax,(%esp)
  80105b:	e8 ac f3 ff ff       	call   80040c <fd2data>
	return _pipeisclosed(fd, p);
  801060:	89 c2                	mov    %eax,%edx
  801062:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801065:	e8 11 fd ff ff       	call   800d7b <_pipeisclosed>
}
  80106a:	c9                   	leave  
  80106b:	c3                   	ret    

0080106c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80106f:	b8 00 00 00 00       	mov    $0x0,%eax
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80107c:	c7 44 24 04 96 20 80 	movl   $0x802096,0x4(%esp)
  801083:	00 
  801084:	8b 45 0c             	mov    0xc(%ebp),%eax
  801087:	89 04 24             	mov    %eax,(%esp)
  80108a:	e8 20 08 00 00       	call   8018af <strcpy>
	return 0;
}
  80108f:	b8 00 00 00 00       	mov    $0x0,%eax
  801094:	c9                   	leave  
  801095:	c3                   	ret    

00801096 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	57                   	push   %edi
  80109a:	56                   	push   %esi
  80109b:	53                   	push   %ebx
  80109c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8010a7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010ad:	eb 30                	jmp    8010df <devcons_write+0x49>
		m = n - tot;
  8010af:	8b 75 10             	mov    0x10(%ebp),%esi
  8010b2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8010b4:	83 fe 7f             	cmp    $0x7f,%esi
  8010b7:	76 05                	jbe    8010be <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8010b9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8010be:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010c2:	03 45 0c             	add    0xc(%ebp),%eax
  8010c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c9:	89 3c 24             	mov    %edi,(%esp)
  8010cc:	e8 57 09 00 00       	call   801a28 <memmove>
		sys_cputs(buf, m);
  8010d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010d5:	89 3c 24             	mov    %edi,(%esp)
  8010d8:	e8 e7 ef ff ff       	call   8000c4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010dd:	01 f3                	add    %esi,%ebx
  8010df:	89 d8                	mov    %ebx,%eax
  8010e1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010e4:	72 c9                	jb     8010af <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8010e6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8010ec:	5b                   	pop    %ebx
  8010ed:	5e                   	pop    %esi
  8010ee:	5f                   	pop    %edi
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8010f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010fb:	75 07                	jne    801104 <devcons_read+0x13>
  8010fd:	eb 25                	jmp    801124 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8010ff:	e8 6e f0 ff ff       	call   800172 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801104:	e8 d9 ef ff ff       	call   8000e2 <sys_cgetc>
  801109:	85 c0                	test   %eax,%eax
  80110b:	74 f2                	je     8010ff <devcons_read+0xe>
  80110d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80110f:	85 c0                	test   %eax,%eax
  801111:	78 1d                	js     801130 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801113:	83 f8 04             	cmp    $0x4,%eax
  801116:	74 13                	je     80112b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801118:	8b 45 0c             	mov    0xc(%ebp),%eax
  80111b:	88 10                	mov    %dl,(%eax)
	return 1;
  80111d:	b8 01 00 00 00       	mov    $0x1,%eax
  801122:	eb 0c                	jmp    801130 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801124:	b8 00 00 00 00       	mov    $0x0,%eax
  801129:	eb 05                	jmp    801130 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80112b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801130:	c9                   	leave  
  801131:	c3                   	ret    

00801132 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801138:	8b 45 08             	mov    0x8(%ebp),%eax
  80113b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80113e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801145:	00 
  801146:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801149:	89 04 24             	mov    %eax,(%esp)
  80114c:	e8 73 ef ff ff       	call   8000c4 <sys_cputs>
}
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <getchar>:

int
getchar(void)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801159:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801160:	00 
  801161:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801164:	89 44 24 04          	mov    %eax,0x4(%esp)
  801168:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80116f:	e8 a4 f5 ff ff       	call   800718 <read>
	if (r < 0)
  801174:	85 c0                	test   %eax,%eax
  801176:	78 0f                	js     801187 <getchar+0x34>
		return r;
	if (r < 1)
  801178:	85 c0                	test   %eax,%eax
  80117a:	7e 06                	jle    801182 <getchar+0x2f>
		return -E_EOF;
	return c;
  80117c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801180:	eb 05                	jmp    801187 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801182:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801187:	c9                   	leave  
  801188:	c3                   	ret    

00801189 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80118f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801192:	89 44 24 04          	mov    %eax,0x4(%esp)
  801196:	8b 45 08             	mov    0x8(%ebp),%eax
  801199:	89 04 24             	mov    %eax,(%esp)
  80119c:	e8 d9 f2 ff ff       	call   80047a <fd_lookup>
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	78 11                	js     8011b6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8011a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8011ae:	39 10                	cmp    %edx,(%eax)
  8011b0:	0f 94 c0             	sete   %al
  8011b3:	0f b6 c0             	movzbl %al,%eax
}
  8011b6:	c9                   	leave  
  8011b7:	c3                   	ret    

008011b8 <opencons>:

int
opencons(void)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8011be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c1:	89 04 24             	mov    %eax,(%esp)
  8011c4:	e8 5e f2 ff ff       	call   800427 <fd_alloc>
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	78 3c                	js     801209 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8011cd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8011d4:	00 
  8011d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e3:	e8 a9 ef ff ff       	call   800191 <sys_page_alloc>
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	78 1d                	js     801209 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8011ec:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8011f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8011f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011fa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801201:	89 04 24             	mov    %eax,(%esp)
  801204:	e8 f3 f1 ff ff       	call   8003fc <fd2num>
}
  801209:	c9                   	leave  
  80120a:	c3                   	ret    
	...

0080120c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	56                   	push   %esi
  801210:	53                   	push   %ebx
  801211:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801214:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801217:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80121d:	e8 31 ef ff ff       	call   800153 <sys_getenvid>
  801222:	8b 55 0c             	mov    0xc(%ebp),%edx
  801225:	89 54 24 10          	mov    %edx,0x10(%esp)
  801229:	8b 55 08             	mov    0x8(%ebp),%edx
  80122c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801230:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801234:	89 44 24 04          	mov    %eax,0x4(%esp)
  801238:	c7 04 24 a4 20 80 00 	movl   $0x8020a4,(%esp)
  80123f:	e8 c0 00 00 00       	call   801304 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801244:	89 74 24 04          	mov    %esi,0x4(%esp)
  801248:	8b 45 10             	mov    0x10(%ebp),%eax
  80124b:	89 04 24             	mov    %eax,(%esp)
  80124e:	e8 50 00 00 00       	call   8012a3 <vcprintf>
	cprintf("\n");
  801253:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  80125a:	e8 a5 00 00 00       	call   801304 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80125f:	cc                   	int3   
  801260:	eb fd                	jmp    80125f <_panic+0x53>
	...

00801264 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	53                   	push   %ebx
  801268:	83 ec 14             	sub    $0x14,%esp
  80126b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80126e:	8b 03                	mov    (%ebx),%eax
  801270:	8b 55 08             	mov    0x8(%ebp),%edx
  801273:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801277:	40                   	inc    %eax
  801278:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80127a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80127f:	75 19                	jne    80129a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801281:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801288:	00 
  801289:	8d 43 08             	lea    0x8(%ebx),%eax
  80128c:	89 04 24             	mov    %eax,(%esp)
  80128f:	e8 30 ee ff ff       	call   8000c4 <sys_cputs>
		b->idx = 0;
  801294:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80129a:	ff 43 04             	incl   0x4(%ebx)
}
  80129d:	83 c4 14             	add    $0x14,%esp
  8012a0:	5b                   	pop    %ebx
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    

008012a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8012ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8012b3:	00 00 00 
	b.cnt = 0;
  8012b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8012bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8012c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8012d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d8:	c7 04 24 64 12 80 00 	movl   $0x801264,(%esp)
  8012df:	e8 82 01 00 00       	call   801466 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8012e4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8012ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ee:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8012f4:	89 04 24             	mov    %eax,(%esp)
  8012f7:	e8 c8 ed ff ff       	call   8000c4 <sys_cputs>

	return b.cnt;
}
  8012fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801302:	c9                   	leave  
  801303:	c3                   	ret    

00801304 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80130a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80130d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801311:	8b 45 08             	mov    0x8(%ebp),%eax
  801314:	89 04 24             	mov    %eax,(%esp)
  801317:	e8 87 ff ff ff       	call   8012a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    
	...

00801320 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	57                   	push   %edi
  801324:	56                   	push   %esi
  801325:	53                   	push   %ebx
  801326:	83 ec 3c             	sub    $0x3c,%esp
  801329:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80132c:	89 d7                	mov    %edx,%edi
  80132e:	8b 45 08             	mov    0x8(%ebp),%eax
  801331:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801334:	8b 45 0c             	mov    0xc(%ebp),%eax
  801337:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80133a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80133d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801340:	85 c0                	test   %eax,%eax
  801342:	75 08                	jne    80134c <printnum+0x2c>
  801344:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801347:	39 45 10             	cmp    %eax,0x10(%ebp)
  80134a:	77 57                	ja     8013a3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80134c:	89 74 24 10          	mov    %esi,0x10(%esp)
  801350:	4b                   	dec    %ebx
  801351:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801355:	8b 45 10             	mov    0x10(%ebp),%eax
  801358:	89 44 24 08          	mov    %eax,0x8(%esp)
  80135c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801360:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801364:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80136b:	00 
  80136c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80136f:	89 04 24             	mov    %eax,(%esp)
  801372:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801375:	89 44 24 04          	mov    %eax,0x4(%esp)
  801379:	e8 b2 09 00 00       	call   801d30 <__udivdi3>
  80137e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801382:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801386:	89 04 24             	mov    %eax,(%esp)
  801389:	89 54 24 04          	mov    %edx,0x4(%esp)
  80138d:	89 fa                	mov    %edi,%edx
  80138f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801392:	e8 89 ff ff ff       	call   801320 <printnum>
  801397:	eb 0f                	jmp    8013a8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801399:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80139d:	89 34 24             	mov    %esi,(%esp)
  8013a0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8013a3:	4b                   	dec    %ebx
  8013a4:	85 db                	test   %ebx,%ebx
  8013a6:	7f f1                	jg     801399 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8013a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013ac:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8013b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013be:	00 
  8013bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013c2:	89 04 24             	mov    %eax,(%esp)
  8013c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013cc:	e8 7f 0a 00 00       	call   801e50 <__umoddi3>
  8013d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013d5:	0f be 80 c7 20 80 00 	movsbl 0x8020c7(%eax),%eax
  8013dc:	89 04 24             	mov    %eax,(%esp)
  8013df:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8013e2:	83 c4 3c             	add    $0x3c,%esp
  8013e5:	5b                   	pop    %ebx
  8013e6:	5e                   	pop    %esi
  8013e7:	5f                   	pop    %edi
  8013e8:	5d                   	pop    %ebp
  8013e9:	c3                   	ret    

008013ea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8013ed:	83 fa 01             	cmp    $0x1,%edx
  8013f0:	7e 0e                	jle    801400 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8013f2:	8b 10                	mov    (%eax),%edx
  8013f4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8013f7:	89 08                	mov    %ecx,(%eax)
  8013f9:	8b 02                	mov    (%edx),%eax
  8013fb:	8b 52 04             	mov    0x4(%edx),%edx
  8013fe:	eb 22                	jmp    801422 <getuint+0x38>
	else if (lflag)
  801400:	85 d2                	test   %edx,%edx
  801402:	74 10                	je     801414 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801404:	8b 10                	mov    (%eax),%edx
  801406:	8d 4a 04             	lea    0x4(%edx),%ecx
  801409:	89 08                	mov    %ecx,(%eax)
  80140b:	8b 02                	mov    (%edx),%eax
  80140d:	ba 00 00 00 00       	mov    $0x0,%edx
  801412:	eb 0e                	jmp    801422 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801414:	8b 10                	mov    (%eax),%edx
  801416:	8d 4a 04             	lea    0x4(%edx),%ecx
  801419:	89 08                	mov    %ecx,(%eax)
  80141b:	8b 02                	mov    (%edx),%eax
  80141d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80142a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80142d:	8b 10                	mov    (%eax),%edx
  80142f:	3b 50 04             	cmp    0x4(%eax),%edx
  801432:	73 08                	jae    80143c <sprintputch+0x18>
		*b->buf++ = ch;
  801434:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801437:	88 0a                	mov    %cl,(%edx)
  801439:	42                   	inc    %edx
  80143a:	89 10                	mov    %edx,(%eax)
}
  80143c:	5d                   	pop    %ebp
  80143d:	c3                   	ret    

0080143e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801444:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801447:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80144b:	8b 45 10             	mov    0x10(%ebp),%eax
  80144e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801452:	8b 45 0c             	mov    0xc(%ebp),%eax
  801455:	89 44 24 04          	mov    %eax,0x4(%esp)
  801459:	8b 45 08             	mov    0x8(%ebp),%eax
  80145c:	89 04 24             	mov    %eax,(%esp)
  80145f:	e8 02 00 00 00       	call   801466 <vprintfmt>
	va_end(ap);
}
  801464:	c9                   	leave  
  801465:	c3                   	ret    

00801466 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	57                   	push   %edi
  80146a:	56                   	push   %esi
  80146b:	53                   	push   %ebx
  80146c:	83 ec 4c             	sub    $0x4c,%esp
  80146f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801472:	8b 75 10             	mov    0x10(%ebp),%esi
  801475:	eb 12                	jmp    801489 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801477:	85 c0                	test   %eax,%eax
  801479:	0f 84 6b 03 00 00    	je     8017ea <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80147f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801483:	89 04 24             	mov    %eax,(%esp)
  801486:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801489:	0f b6 06             	movzbl (%esi),%eax
  80148c:	46                   	inc    %esi
  80148d:	83 f8 25             	cmp    $0x25,%eax
  801490:	75 e5                	jne    801477 <vprintfmt+0x11>
  801492:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801496:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80149d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8014a2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8014a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014ae:	eb 26                	jmp    8014d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8014b3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8014b7:	eb 1d                	jmp    8014d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8014bc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8014c0:	eb 14                	jmp    8014d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8014c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8014cc:	eb 08                	jmp    8014d6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8014ce:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8014d1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014d6:	0f b6 06             	movzbl (%esi),%eax
  8014d9:	8d 56 01             	lea    0x1(%esi),%edx
  8014dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8014df:	8a 16                	mov    (%esi),%dl
  8014e1:	83 ea 23             	sub    $0x23,%edx
  8014e4:	80 fa 55             	cmp    $0x55,%dl
  8014e7:	0f 87 e1 02 00 00    	ja     8017ce <vprintfmt+0x368>
  8014ed:	0f b6 d2             	movzbl %dl,%edx
  8014f0:	ff 24 95 00 22 80 00 	jmp    *0x802200(,%edx,4)
  8014f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8014fa:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8014ff:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801502:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  801506:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801509:	8d 50 d0             	lea    -0x30(%eax),%edx
  80150c:	83 fa 09             	cmp    $0x9,%edx
  80150f:	77 2a                	ja     80153b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801511:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801512:	eb eb                	jmp    8014ff <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801514:	8b 45 14             	mov    0x14(%ebp),%eax
  801517:	8d 50 04             	lea    0x4(%eax),%edx
  80151a:	89 55 14             	mov    %edx,0x14(%ebp)
  80151d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80151f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801522:	eb 17                	jmp    80153b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801524:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801528:	78 98                	js     8014c2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80152a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80152d:	eb a7                	jmp    8014d6 <vprintfmt+0x70>
  80152f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801532:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801539:	eb 9b                	jmp    8014d6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80153b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80153f:	79 95                	jns    8014d6 <vprintfmt+0x70>
  801541:	eb 8b                	jmp    8014ce <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801543:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801544:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801547:	eb 8d                	jmp    8014d6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801549:	8b 45 14             	mov    0x14(%ebp),%eax
  80154c:	8d 50 04             	lea    0x4(%eax),%edx
  80154f:	89 55 14             	mov    %edx,0x14(%ebp)
  801552:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801556:	8b 00                	mov    (%eax),%eax
  801558:	89 04 24             	mov    %eax,(%esp)
  80155b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80155e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801561:	e9 23 ff ff ff       	jmp    801489 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801566:	8b 45 14             	mov    0x14(%ebp),%eax
  801569:	8d 50 04             	lea    0x4(%eax),%edx
  80156c:	89 55 14             	mov    %edx,0x14(%ebp)
  80156f:	8b 00                	mov    (%eax),%eax
  801571:	85 c0                	test   %eax,%eax
  801573:	79 02                	jns    801577 <vprintfmt+0x111>
  801575:	f7 d8                	neg    %eax
  801577:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801579:	83 f8 0f             	cmp    $0xf,%eax
  80157c:	7f 0b                	jg     801589 <vprintfmt+0x123>
  80157e:	8b 04 85 60 23 80 00 	mov    0x802360(,%eax,4),%eax
  801585:	85 c0                	test   %eax,%eax
  801587:	75 23                	jne    8015ac <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801589:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80158d:	c7 44 24 08 df 20 80 	movl   $0x8020df,0x8(%esp)
  801594:	00 
  801595:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801599:	8b 45 08             	mov    0x8(%ebp),%eax
  80159c:	89 04 24             	mov    %eax,(%esp)
  80159f:	e8 9a fe ff ff       	call   80143e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8015a7:	e9 dd fe ff ff       	jmp    801489 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8015ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015b0:	c7 44 24 08 5d 20 80 	movl   $0x80205d,0x8(%esp)
  8015b7:	00 
  8015b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8015bf:	89 14 24             	mov    %edx,(%esp)
  8015c2:	e8 77 fe ff ff       	call   80143e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8015ca:	e9 ba fe ff ff       	jmp    801489 <vprintfmt+0x23>
  8015cf:	89 f9                	mov    %edi,%ecx
  8015d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8015d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015da:	8d 50 04             	lea    0x4(%eax),%edx
  8015dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8015e0:	8b 30                	mov    (%eax),%esi
  8015e2:	85 f6                	test   %esi,%esi
  8015e4:	75 05                	jne    8015eb <vprintfmt+0x185>
				p = "(null)";
  8015e6:	be d8 20 80 00       	mov    $0x8020d8,%esi
			if (width > 0 && padc != '-')
  8015eb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8015ef:	0f 8e 84 00 00 00    	jle    801679 <vprintfmt+0x213>
  8015f5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8015f9:	74 7e                	je     801679 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8015fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015ff:	89 34 24             	mov    %esi,(%esp)
  801602:	e8 8b 02 00 00       	call   801892 <strnlen>
  801607:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80160a:	29 c2                	sub    %eax,%edx
  80160c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80160f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801613:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801616:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801619:	89 de                	mov    %ebx,%esi
  80161b:	89 d3                	mov    %edx,%ebx
  80161d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80161f:	eb 0b                	jmp    80162c <vprintfmt+0x1c6>
					putch(padc, putdat);
  801621:	89 74 24 04          	mov    %esi,0x4(%esp)
  801625:	89 3c 24             	mov    %edi,(%esp)
  801628:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80162b:	4b                   	dec    %ebx
  80162c:	85 db                	test   %ebx,%ebx
  80162e:	7f f1                	jg     801621 <vprintfmt+0x1bb>
  801630:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801633:	89 f3                	mov    %esi,%ebx
  801635:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801638:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80163b:	85 c0                	test   %eax,%eax
  80163d:	79 05                	jns    801644 <vprintfmt+0x1de>
  80163f:	b8 00 00 00 00       	mov    $0x0,%eax
  801644:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801647:	29 c2                	sub    %eax,%edx
  801649:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80164c:	eb 2b                	jmp    801679 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80164e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801652:	74 18                	je     80166c <vprintfmt+0x206>
  801654:	8d 50 e0             	lea    -0x20(%eax),%edx
  801657:	83 fa 5e             	cmp    $0x5e,%edx
  80165a:	76 10                	jbe    80166c <vprintfmt+0x206>
					putch('?', putdat);
  80165c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801660:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801667:	ff 55 08             	call   *0x8(%ebp)
  80166a:	eb 0a                	jmp    801676 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80166c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801670:	89 04 24             	mov    %eax,(%esp)
  801673:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801676:	ff 4d e4             	decl   -0x1c(%ebp)
  801679:	0f be 06             	movsbl (%esi),%eax
  80167c:	46                   	inc    %esi
  80167d:	85 c0                	test   %eax,%eax
  80167f:	74 21                	je     8016a2 <vprintfmt+0x23c>
  801681:	85 ff                	test   %edi,%edi
  801683:	78 c9                	js     80164e <vprintfmt+0x1e8>
  801685:	4f                   	dec    %edi
  801686:	79 c6                	jns    80164e <vprintfmt+0x1e8>
  801688:	8b 7d 08             	mov    0x8(%ebp),%edi
  80168b:	89 de                	mov    %ebx,%esi
  80168d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801690:	eb 18                	jmp    8016aa <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801692:	89 74 24 04          	mov    %esi,0x4(%esp)
  801696:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80169d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80169f:	4b                   	dec    %ebx
  8016a0:	eb 08                	jmp    8016aa <vprintfmt+0x244>
  8016a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016a5:	89 de                	mov    %ebx,%esi
  8016a7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8016aa:	85 db                	test   %ebx,%ebx
  8016ac:	7f e4                	jg     801692 <vprintfmt+0x22c>
  8016ae:	89 7d 08             	mov    %edi,0x8(%ebp)
  8016b1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8016b6:	e9 ce fd ff ff       	jmp    801489 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8016bb:	83 f9 01             	cmp    $0x1,%ecx
  8016be:	7e 10                	jle    8016d0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8016c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c3:	8d 50 08             	lea    0x8(%eax),%edx
  8016c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8016c9:	8b 30                	mov    (%eax),%esi
  8016cb:	8b 78 04             	mov    0x4(%eax),%edi
  8016ce:	eb 26                	jmp    8016f6 <vprintfmt+0x290>
	else if (lflag)
  8016d0:	85 c9                	test   %ecx,%ecx
  8016d2:	74 12                	je     8016e6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8016d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d7:	8d 50 04             	lea    0x4(%eax),%edx
  8016da:	89 55 14             	mov    %edx,0x14(%ebp)
  8016dd:	8b 30                	mov    (%eax),%esi
  8016df:	89 f7                	mov    %esi,%edi
  8016e1:	c1 ff 1f             	sar    $0x1f,%edi
  8016e4:	eb 10                	jmp    8016f6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8016e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8016e9:	8d 50 04             	lea    0x4(%eax),%edx
  8016ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8016ef:	8b 30                	mov    (%eax),%esi
  8016f1:	89 f7                	mov    %esi,%edi
  8016f3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8016f6:	85 ff                	test   %edi,%edi
  8016f8:	78 0a                	js     801704 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8016fa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016ff:	e9 8c 00 00 00       	jmp    801790 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801704:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801708:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80170f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801712:	f7 de                	neg    %esi
  801714:	83 d7 00             	adc    $0x0,%edi
  801717:	f7 df                	neg    %edi
			}
			base = 10;
  801719:	b8 0a 00 00 00       	mov    $0xa,%eax
  80171e:	eb 70                	jmp    801790 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801720:	89 ca                	mov    %ecx,%edx
  801722:	8d 45 14             	lea    0x14(%ebp),%eax
  801725:	e8 c0 fc ff ff       	call   8013ea <getuint>
  80172a:	89 c6                	mov    %eax,%esi
  80172c:	89 d7                	mov    %edx,%edi
			base = 10;
  80172e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801733:	eb 5b                	jmp    801790 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801735:	89 ca                	mov    %ecx,%edx
  801737:	8d 45 14             	lea    0x14(%ebp),%eax
  80173a:	e8 ab fc ff ff       	call   8013ea <getuint>
  80173f:	89 c6                	mov    %eax,%esi
  801741:	89 d7                	mov    %edx,%edi
			base = 8;
  801743:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801748:	eb 46                	jmp    801790 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80174a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80174e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801755:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801758:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80175c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801763:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801766:	8b 45 14             	mov    0x14(%ebp),%eax
  801769:	8d 50 04             	lea    0x4(%eax),%edx
  80176c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80176f:	8b 30                	mov    (%eax),%esi
  801771:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801776:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80177b:	eb 13                	jmp    801790 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80177d:	89 ca                	mov    %ecx,%edx
  80177f:	8d 45 14             	lea    0x14(%ebp),%eax
  801782:	e8 63 fc ff ff       	call   8013ea <getuint>
  801787:	89 c6                	mov    %eax,%esi
  801789:	89 d7                	mov    %edx,%edi
			base = 16;
  80178b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801790:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801794:	89 54 24 10          	mov    %edx,0x10(%esp)
  801798:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80179b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80179f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017a3:	89 34 24             	mov    %esi,(%esp)
  8017a6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017aa:	89 da                	mov    %ebx,%edx
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	e8 6c fb ff ff       	call   801320 <printnum>
			break;
  8017b4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8017b7:	e9 cd fc ff ff       	jmp    801489 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8017bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c0:	89 04 24             	mov    %eax,(%esp)
  8017c3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8017c9:	e9 bb fc ff ff       	jmp    801489 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8017ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017d2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017d9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017dc:	eb 01                	jmp    8017df <vprintfmt+0x379>
  8017de:	4e                   	dec    %esi
  8017df:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8017e3:	75 f9                	jne    8017de <vprintfmt+0x378>
  8017e5:	e9 9f fc ff ff       	jmp    801489 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8017ea:	83 c4 4c             	add    $0x4c,%esp
  8017ed:	5b                   	pop    %ebx
  8017ee:	5e                   	pop    %esi
  8017ef:	5f                   	pop    %edi
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    

008017f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	83 ec 28             	sub    $0x28,%esp
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8017fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801801:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801805:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801808:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80180f:	85 c0                	test   %eax,%eax
  801811:	74 30                	je     801843 <vsnprintf+0x51>
  801813:	85 d2                	test   %edx,%edx
  801815:	7e 33                	jle    80184a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801817:	8b 45 14             	mov    0x14(%ebp),%eax
  80181a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80181e:	8b 45 10             	mov    0x10(%ebp),%eax
  801821:	89 44 24 08          	mov    %eax,0x8(%esp)
  801825:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801828:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182c:	c7 04 24 24 14 80 00 	movl   $0x801424,(%esp)
  801833:	e8 2e fc ff ff       	call   801466 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801838:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80183b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80183e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801841:	eb 0c                	jmp    80184f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801843:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801848:	eb 05                	jmp    80184f <vsnprintf+0x5d>
  80184a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80184f:	c9                   	leave  
  801850:	c3                   	ret    

00801851 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801857:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80185a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80185e:	8b 45 10             	mov    0x10(%ebp),%eax
  801861:	89 44 24 08          	mov    %eax,0x8(%esp)
  801865:	8b 45 0c             	mov    0xc(%ebp),%eax
  801868:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186c:	8b 45 08             	mov    0x8(%ebp),%eax
  80186f:	89 04 24             	mov    %eax,(%esp)
  801872:	e8 7b ff ff ff       	call   8017f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801877:	c9                   	leave  
  801878:	c3                   	ret    
  801879:	00 00                	add    %al,(%eax)
	...

0080187c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801882:	b8 00 00 00 00       	mov    $0x0,%eax
  801887:	eb 01                	jmp    80188a <strlen+0xe>
		n++;
  801889:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80188a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80188e:	75 f9                	jne    801889 <strlen+0xd>
		n++;
	return n;
}
  801890:	5d                   	pop    %ebp
  801891:	c3                   	ret    

00801892 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801898:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80189b:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a0:	eb 01                	jmp    8018a3 <strnlen+0x11>
		n++;
  8018a2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8018a3:	39 d0                	cmp    %edx,%eax
  8018a5:	74 06                	je     8018ad <strnlen+0x1b>
  8018a7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8018ab:	75 f5                	jne    8018a2 <strnlen+0x10>
		n++;
	return n;
}
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    

008018af <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	53                   	push   %ebx
  8018b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8018b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018be:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8018c1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8018c4:	42                   	inc    %edx
  8018c5:	84 c9                	test   %cl,%cl
  8018c7:	75 f5                	jne    8018be <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8018c9:	5b                   	pop    %ebx
  8018ca:	5d                   	pop    %ebp
  8018cb:	c3                   	ret    

008018cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	53                   	push   %ebx
  8018d0:	83 ec 08             	sub    $0x8,%esp
  8018d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8018d6:	89 1c 24             	mov    %ebx,(%esp)
  8018d9:	e8 9e ff ff ff       	call   80187c <strlen>
	strcpy(dst + len, src);
  8018de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018e5:	01 d8                	add    %ebx,%eax
  8018e7:	89 04 24             	mov    %eax,(%esp)
  8018ea:	e8 c0 ff ff ff       	call   8018af <strcpy>
	return dst;
}
  8018ef:	89 d8                	mov    %ebx,%eax
  8018f1:	83 c4 08             	add    $0x8,%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	56                   	push   %esi
  8018fb:	53                   	push   %ebx
  8018fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801902:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801905:	b9 00 00 00 00       	mov    $0x0,%ecx
  80190a:	eb 0c                	jmp    801918 <strncpy+0x21>
		*dst++ = *src;
  80190c:	8a 1a                	mov    (%edx),%bl
  80190e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801911:	80 3a 01             	cmpb   $0x1,(%edx)
  801914:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801917:	41                   	inc    %ecx
  801918:	39 f1                	cmp    %esi,%ecx
  80191a:	75 f0                	jne    80190c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80191c:	5b                   	pop    %ebx
  80191d:	5e                   	pop    %esi
  80191e:	5d                   	pop    %ebp
  80191f:	c3                   	ret    

00801920 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	56                   	push   %esi
  801924:	53                   	push   %ebx
  801925:	8b 75 08             	mov    0x8(%ebp),%esi
  801928:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80192b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80192e:	85 d2                	test   %edx,%edx
  801930:	75 0a                	jne    80193c <strlcpy+0x1c>
  801932:	89 f0                	mov    %esi,%eax
  801934:	eb 1a                	jmp    801950 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801936:	88 18                	mov    %bl,(%eax)
  801938:	40                   	inc    %eax
  801939:	41                   	inc    %ecx
  80193a:	eb 02                	jmp    80193e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80193c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80193e:	4a                   	dec    %edx
  80193f:	74 0a                	je     80194b <strlcpy+0x2b>
  801941:	8a 19                	mov    (%ecx),%bl
  801943:	84 db                	test   %bl,%bl
  801945:	75 ef                	jne    801936 <strlcpy+0x16>
  801947:	89 c2                	mov    %eax,%edx
  801949:	eb 02                	jmp    80194d <strlcpy+0x2d>
  80194b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80194d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801950:	29 f0                	sub    %esi,%eax
}
  801952:	5b                   	pop    %ebx
  801953:	5e                   	pop    %esi
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80195f:	eb 02                	jmp    801963 <strcmp+0xd>
		p++, q++;
  801961:	41                   	inc    %ecx
  801962:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801963:	8a 01                	mov    (%ecx),%al
  801965:	84 c0                	test   %al,%al
  801967:	74 04                	je     80196d <strcmp+0x17>
  801969:	3a 02                	cmp    (%edx),%al
  80196b:	74 f4                	je     801961 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80196d:	0f b6 c0             	movzbl %al,%eax
  801970:	0f b6 12             	movzbl (%edx),%edx
  801973:	29 d0                	sub    %edx,%eax
}
  801975:	5d                   	pop    %ebp
  801976:	c3                   	ret    

00801977 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	53                   	push   %ebx
  80197b:	8b 45 08             	mov    0x8(%ebp),%eax
  80197e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801981:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801984:	eb 03                	jmp    801989 <strncmp+0x12>
		n--, p++, q++;
  801986:	4a                   	dec    %edx
  801987:	40                   	inc    %eax
  801988:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801989:	85 d2                	test   %edx,%edx
  80198b:	74 14                	je     8019a1 <strncmp+0x2a>
  80198d:	8a 18                	mov    (%eax),%bl
  80198f:	84 db                	test   %bl,%bl
  801991:	74 04                	je     801997 <strncmp+0x20>
  801993:	3a 19                	cmp    (%ecx),%bl
  801995:	74 ef                	je     801986 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801997:	0f b6 00             	movzbl (%eax),%eax
  80199a:	0f b6 11             	movzbl (%ecx),%edx
  80199d:	29 d0                	sub    %edx,%eax
  80199f:	eb 05                	jmp    8019a6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8019a1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8019a6:	5b                   	pop    %ebx
  8019a7:	5d                   	pop    %ebp
  8019a8:	c3                   	ret    

008019a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8019af:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8019b2:	eb 05                	jmp    8019b9 <strchr+0x10>
		if (*s == c)
  8019b4:	38 ca                	cmp    %cl,%dl
  8019b6:	74 0c                	je     8019c4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8019b8:	40                   	inc    %eax
  8019b9:	8a 10                	mov    (%eax),%dl
  8019bb:	84 d2                	test   %dl,%dl
  8019bd:	75 f5                	jne    8019b4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8019bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c4:	5d                   	pop    %ebp
  8019c5:	c3                   	ret    

008019c6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8019cf:	eb 05                	jmp    8019d6 <strfind+0x10>
		if (*s == c)
  8019d1:	38 ca                	cmp    %cl,%dl
  8019d3:	74 07                	je     8019dc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8019d5:	40                   	inc    %eax
  8019d6:	8a 10                	mov    (%eax),%dl
  8019d8:	84 d2                	test   %dl,%dl
  8019da:	75 f5                	jne    8019d1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	57                   	push   %edi
  8019e2:	56                   	push   %esi
  8019e3:	53                   	push   %ebx
  8019e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8019ed:	85 c9                	test   %ecx,%ecx
  8019ef:	74 30                	je     801a21 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8019f1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019f7:	75 25                	jne    801a1e <memset+0x40>
  8019f9:	f6 c1 03             	test   $0x3,%cl
  8019fc:	75 20                	jne    801a1e <memset+0x40>
		c &= 0xFF;
  8019fe:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801a01:	89 d3                	mov    %edx,%ebx
  801a03:	c1 e3 08             	shl    $0x8,%ebx
  801a06:	89 d6                	mov    %edx,%esi
  801a08:	c1 e6 18             	shl    $0x18,%esi
  801a0b:	89 d0                	mov    %edx,%eax
  801a0d:	c1 e0 10             	shl    $0x10,%eax
  801a10:	09 f0                	or     %esi,%eax
  801a12:	09 d0                	or     %edx,%eax
  801a14:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801a16:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801a19:	fc                   	cld    
  801a1a:	f3 ab                	rep stos %eax,%es:(%edi)
  801a1c:	eb 03                	jmp    801a21 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801a1e:	fc                   	cld    
  801a1f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801a21:	89 f8                	mov    %edi,%eax
  801a23:	5b                   	pop    %ebx
  801a24:	5e                   	pop    %esi
  801a25:	5f                   	pop    %edi
  801a26:	5d                   	pop    %ebp
  801a27:	c3                   	ret    

00801a28 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	57                   	push   %edi
  801a2c:	56                   	push   %esi
  801a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a30:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a33:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801a36:	39 c6                	cmp    %eax,%esi
  801a38:	73 34                	jae    801a6e <memmove+0x46>
  801a3a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a3d:	39 d0                	cmp    %edx,%eax
  801a3f:	73 2d                	jae    801a6e <memmove+0x46>
		s += n;
		d += n;
  801a41:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a44:	f6 c2 03             	test   $0x3,%dl
  801a47:	75 1b                	jne    801a64 <memmove+0x3c>
  801a49:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801a4f:	75 13                	jne    801a64 <memmove+0x3c>
  801a51:	f6 c1 03             	test   $0x3,%cl
  801a54:	75 0e                	jne    801a64 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a56:	83 ef 04             	sub    $0x4,%edi
  801a59:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a5c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801a5f:	fd                   	std    
  801a60:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a62:	eb 07                	jmp    801a6b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a64:	4f                   	dec    %edi
  801a65:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801a68:	fd                   	std    
  801a69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a6b:	fc                   	cld    
  801a6c:	eb 20                	jmp    801a8e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a6e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a74:	75 13                	jne    801a89 <memmove+0x61>
  801a76:	a8 03                	test   $0x3,%al
  801a78:	75 0f                	jne    801a89 <memmove+0x61>
  801a7a:	f6 c1 03             	test   $0x3,%cl
  801a7d:	75 0a                	jne    801a89 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a7f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801a82:	89 c7                	mov    %eax,%edi
  801a84:	fc                   	cld    
  801a85:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a87:	eb 05                	jmp    801a8e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801a89:	89 c7                	mov    %eax,%edi
  801a8b:	fc                   	cld    
  801a8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a8e:	5e                   	pop    %esi
  801a8f:	5f                   	pop    %edi
  801a90:	5d                   	pop    %ebp
  801a91:	c3                   	ret    

00801a92 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a98:	8b 45 10             	mov    0x10(%ebp),%eax
  801a9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa9:	89 04 24             	mov    %eax,(%esp)
  801aac:	e8 77 ff ff ff       	call   801a28 <memmove>
}
  801ab1:	c9                   	leave  
  801ab2:	c3                   	ret    

00801ab3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	57                   	push   %edi
  801ab7:	56                   	push   %esi
  801ab8:	53                   	push   %ebx
  801ab9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801abc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801abf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac7:	eb 16                	jmp    801adf <memcmp+0x2c>
		if (*s1 != *s2)
  801ac9:	8a 04 17             	mov    (%edi,%edx,1),%al
  801acc:	42                   	inc    %edx
  801acd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801ad1:	38 c8                	cmp    %cl,%al
  801ad3:	74 0a                	je     801adf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801ad5:	0f b6 c0             	movzbl %al,%eax
  801ad8:	0f b6 c9             	movzbl %cl,%ecx
  801adb:	29 c8                	sub    %ecx,%eax
  801add:	eb 09                	jmp    801ae8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801adf:	39 da                	cmp    %ebx,%edx
  801ae1:	75 e6                	jne    801ac9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae8:	5b                   	pop    %ebx
  801ae9:	5e                   	pop    %esi
  801aea:	5f                   	pop    %edi
  801aeb:	5d                   	pop    %ebp
  801aec:	c3                   	ret    

00801aed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	8b 45 08             	mov    0x8(%ebp),%eax
  801af3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801af6:	89 c2                	mov    %eax,%edx
  801af8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801afb:	eb 05                	jmp    801b02 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801afd:	38 08                	cmp    %cl,(%eax)
  801aff:	74 05                	je     801b06 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801b01:	40                   	inc    %eax
  801b02:	39 d0                	cmp    %edx,%eax
  801b04:	72 f7                	jb     801afd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801b06:	5d                   	pop    %ebp
  801b07:	c3                   	ret    

00801b08 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	57                   	push   %edi
  801b0c:	56                   	push   %esi
  801b0d:	53                   	push   %ebx
  801b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  801b11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b14:	eb 01                	jmp    801b17 <strtol+0xf>
		s++;
  801b16:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b17:	8a 02                	mov    (%edx),%al
  801b19:	3c 20                	cmp    $0x20,%al
  801b1b:	74 f9                	je     801b16 <strtol+0xe>
  801b1d:	3c 09                	cmp    $0x9,%al
  801b1f:	74 f5                	je     801b16 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801b21:	3c 2b                	cmp    $0x2b,%al
  801b23:	75 08                	jne    801b2d <strtol+0x25>
		s++;
  801b25:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b26:	bf 00 00 00 00       	mov    $0x0,%edi
  801b2b:	eb 13                	jmp    801b40 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801b2d:	3c 2d                	cmp    $0x2d,%al
  801b2f:	75 0a                	jne    801b3b <strtol+0x33>
		s++, neg = 1;
  801b31:	8d 52 01             	lea    0x1(%edx),%edx
  801b34:	bf 01 00 00 00       	mov    $0x1,%edi
  801b39:	eb 05                	jmp    801b40 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b3b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b40:	85 db                	test   %ebx,%ebx
  801b42:	74 05                	je     801b49 <strtol+0x41>
  801b44:	83 fb 10             	cmp    $0x10,%ebx
  801b47:	75 28                	jne    801b71 <strtol+0x69>
  801b49:	8a 02                	mov    (%edx),%al
  801b4b:	3c 30                	cmp    $0x30,%al
  801b4d:	75 10                	jne    801b5f <strtol+0x57>
  801b4f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b53:	75 0a                	jne    801b5f <strtol+0x57>
		s += 2, base = 16;
  801b55:	83 c2 02             	add    $0x2,%edx
  801b58:	bb 10 00 00 00       	mov    $0x10,%ebx
  801b5d:	eb 12                	jmp    801b71 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801b5f:	85 db                	test   %ebx,%ebx
  801b61:	75 0e                	jne    801b71 <strtol+0x69>
  801b63:	3c 30                	cmp    $0x30,%al
  801b65:	75 05                	jne    801b6c <strtol+0x64>
		s++, base = 8;
  801b67:	42                   	inc    %edx
  801b68:	b3 08                	mov    $0x8,%bl
  801b6a:	eb 05                	jmp    801b71 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801b6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801b71:	b8 00 00 00 00       	mov    $0x0,%eax
  801b76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801b78:	8a 0a                	mov    (%edx),%cl
  801b7a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801b7d:	80 fb 09             	cmp    $0x9,%bl
  801b80:	77 08                	ja     801b8a <strtol+0x82>
			dig = *s - '0';
  801b82:	0f be c9             	movsbl %cl,%ecx
  801b85:	83 e9 30             	sub    $0x30,%ecx
  801b88:	eb 1e                	jmp    801ba8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801b8a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801b8d:	80 fb 19             	cmp    $0x19,%bl
  801b90:	77 08                	ja     801b9a <strtol+0x92>
			dig = *s - 'a' + 10;
  801b92:	0f be c9             	movsbl %cl,%ecx
  801b95:	83 e9 57             	sub    $0x57,%ecx
  801b98:	eb 0e                	jmp    801ba8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801b9a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801b9d:	80 fb 19             	cmp    $0x19,%bl
  801ba0:	77 12                	ja     801bb4 <strtol+0xac>
			dig = *s - 'A' + 10;
  801ba2:	0f be c9             	movsbl %cl,%ecx
  801ba5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801ba8:	39 f1                	cmp    %esi,%ecx
  801baa:	7d 0c                	jge    801bb8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801bac:	42                   	inc    %edx
  801bad:	0f af c6             	imul   %esi,%eax
  801bb0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801bb2:	eb c4                	jmp    801b78 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801bb4:	89 c1                	mov    %eax,%ecx
  801bb6:	eb 02                	jmp    801bba <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801bb8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801bba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801bbe:	74 05                	je     801bc5 <strtol+0xbd>
		*endptr = (char *) s;
  801bc0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bc3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801bc5:	85 ff                	test   %edi,%edi
  801bc7:	74 04                	je     801bcd <strtol+0xc5>
  801bc9:	89 c8                	mov    %ecx,%eax
  801bcb:	f7 d8                	neg    %eax
}
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5f                   	pop    %edi
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    
	...

00801bd4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	56                   	push   %esi
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 10             	sub    $0x10,%esp
  801bdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801be5:	85 c0                	test   %eax,%eax
  801be7:	75 05                	jne    801bee <ipc_recv+0x1a>
  801be9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801bee:	89 04 24             	mov    %eax,(%esp)
  801bf1:	e8 b1 e7 ff ff       	call   8003a7 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	79 16                	jns    801c10 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801bfa:	85 db                	test   %ebx,%ebx
  801bfc:	74 06                	je     801c04 <ipc_recv+0x30>
  801bfe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801c04:	85 f6                	test   %esi,%esi
  801c06:	74 32                	je     801c3a <ipc_recv+0x66>
  801c08:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801c0e:	eb 2a                	jmp    801c3a <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c10:	85 db                	test   %ebx,%ebx
  801c12:	74 0c                	je     801c20 <ipc_recv+0x4c>
  801c14:	a1 04 40 80 00       	mov    0x804004,%eax
  801c19:	8b 00                	mov    (%eax),%eax
  801c1b:	8b 40 74             	mov    0x74(%eax),%eax
  801c1e:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c20:	85 f6                	test   %esi,%esi
  801c22:	74 0c                	je     801c30 <ipc_recv+0x5c>
  801c24:	a1 04 40 80 00       	mov    0x804004,%eax
  801c29:	8b 00                	mov    (%eax),%eax
  801c2b:	8b 40 78             	mov    0x78(%eax),%eax
  801c2e:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801c30:	a1 04 40 80 00       	mov    0x804004,%eax
  801c35:	8b 00                	mov    (%eax),%eax
  801c37:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801c3a:	83 c4 10             	add    $0x10,%esp
  801c3d:	5b                   	pop    %ebx
  801c3e:	5e                   	pop    %esi
  801c3f:	5d                   	pop    %ebp
  801c40:	c3                   	ret    

00801c41 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	57                   	push   %edi
  801c45:	56                   	push   %esi
  801c46:	53                   	push   %ebx
  801c47:	83 ec 1c             	sub    $0x1c,%esp
  801c4a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c50:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801c53:	85 db                	test   %ebx,%ebx
  801c55:	75 05                	jne    801c5c <ipc_send+0x1b>
  801c57:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801c5c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c60:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c64:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c68:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6b:	89 04 24             	mov    %eax,(%esp)
  801c6e:	e8 11 e7 ff ff       	call   800384 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801c73:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c76:	75 07                	jne    801c7f <ipc_send+0x3e>
  801c78:	e8 f5 e4 ff ff       	call   800172 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801c7d:	eb dd                	jmp    801c5c <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801c7f:	85 c0                	test   %eax,%eax
  801c81:	79 1c                	jns    801c9f <ipc_send+0x5e>
  801c83:	c7 44 24 08 c0 23 80 	movl   $0x8023c0,0x8(%esp)
  801c8a:	00 
  801c8b:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801c92:	00 
  801c93:	c7 04 24 d2 23 80 00 	movl   $0x8023d2,(%esp)
  801c9a:	e8 6d f5 ff ff       	call   80120c <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801c9f:	83 c4 1c             	add    $0x1c,%esp
  801ca2:	5b                   	pop    %ebx
  801ca3:	5e                   	pop    %esi
  801ca4:	5f                   	pop    %edi
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    

00801ca7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	53                   	push   %ebx
  801cab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801cae:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cb3:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801cba:	89 c2                	mov    %eax,%edx
  801cbc:	c1 e2 07             	shl    $0x7,%edx
  801cbf:	29 ca                	sub    %ecx,%edx
  801cc1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cc7:	8b 52 50             	mov    0x50(%edx),%edx
  801cca:	39 da                	cmp    %ebx,%edx
  801ccc:	75 0f                	jne    801cdd <ipc_find_env+0x36>
			return envs[i].env_id;
  801cce:	c1 e0 07             	shl    $0x7,%eax
  801cd1:	29 c8                	sub    %ecx,%eax
  801cd3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cd8:	8b 40 40             	mov    0x40(%eax),%eax
  801cdb:	eb 0c                	jmp    801ce9 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cdd:	40                   	inc    %eax
  801cde:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ce3:	75 ce                	jne    801cb3 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ce5:	66 b8 00 00          	mov    $0x0,%ax
}
  801ce9:	5b                   	pop    %ebx
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    

00801cec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801cf2:	89 c2                	mov    %eax,%edx
  801cf4:	c1 ea 16             	shr    $0x16,%edx
  801cf7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cfe:	f6 c2 01             	test   $0x1,%dl
  801d01:	74 1e                	je     801d21 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d03:	c1 e8 0c             	shr    $0xc,%eax
  801d06:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d0d:	a8 01                	test   $0x1,%al
  801d0f:	74 17                	je     801d28 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d11:	c1 e8 0c             	shr    $0xc,%eax
  801d14:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d1b:	ef 
  801d1c:	0f b7 c0             	movzwl %ax,%eax
  801d1f:	eb 0c                	jmp    801d2d <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d21:	b8 00 00 00 00       	mov    $0x0,%eax
  801d26:	eb 05                	jmp    801d2d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d28:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d2d:	5d                   	pop    %ebp
  801d2e:	c3                   	ret    
	...

00801d30 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d30:	55                   	push   %ebp
  801d31:	57                   	push   %edi
  801d32:	56                   	push   %esi
  801d33:	83 ec 10             	sub    $0x10,%esp
  801d36:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d3a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d3e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d42:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801d46:	89 cd                	mov    %ecx,%ebp
  801d48:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	75 2c                	jne    801d7c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801d50:	39 f9                	cmp    %edi,%ecx
  801d52:	77 68                	ja     801dbc <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d54:	85 c9                	test   %ecx,%ecx
  801d56:	75 0b                	jne    801d63 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d58:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5d:	31 d2                	xor    %edx,%edx
  801d5f:	f7 f1                	div    %ecx
  801d61:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d63:	31 d2                	xor    %edx,%edx
  801d65:	89 f8                	mov    %edi,%eax
  801d67:	f7 f1                	div    %ecx
  801d69:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d6b:	89 f0                	mov    %esi,%eax
  801d6d:	f7 f1                	div    %ecx
  801d6f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d71:	89 f0                	mov    %esi,%eax
  801d73:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	5e                   	pop    %esi
  801d79:	5f                   	pop    %edi
  801d7a:	5d                   	pop    %ebp
  801d7b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d7c:	39 f8                	cmp    %edi,%eax
  801d7e:	77 2c                	ja     801dac <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d80:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801d83:	83 f6 1f             	xor    $0x1f,%esi
  801d86:	75 4c                	jne    801dd4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d88:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d8a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d8f:	72 0a                	jb     801d9b <__udivdi3+0x6b>
  801d91:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d95:	0f 87 ad 00 00 00    	ja     801e48 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d9b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801da0:	89 f0                	mov    %esi,%eax
  801da2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801da4:	83 c4 10             	add    $0x10,%esp
  801da7:	5e                   	pop    %esi
  801da8:	5f                   	pop    %edi
  801da9:	5d                   	pop    %ebp
  801daa:	c3                   	ret    
  801dab:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801dac:	31 ff                	xor    %edi,%edi
  801dae:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801db0:	89 f0                	mov    %esi,%eax
  801db2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801db4:	83 c4 10             	add    $0x10,%esp
  801db7:	5e                   	pop    %esi
  801db8:	5f                   	pop    %edi
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    
  801dbb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dbc:	89 fa                	mov    %edi,%edx
  801dbe:	89 f0                	mov    %esi,%eax
  801dc0:	f7 f1                	div    %ecx
  801dc2:	89 c6                	mov    %eax,%esi
  801dc4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dc6:	89 f0                	mov    %esi,%eax
  801dc8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dca:	83 c4 10             	add    $0x10,%esp
  801dcd:	5e                   	pop    %esi
  801dce:	5f                   	pop    %edi
  801dcf:	5d                   	pop    %ebp
  801dd0:	c3                   	ret    
  801dd1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801dd4:	89 f1                	mov    %esi,%ecx
  801dd6:	d3 e0                	shl    %cl,%eax
  801dd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801ddc:	b8 20 00 00 00       	mov    $0x20,%eax
  801de1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801de3:	89 ea                	mov    %ebp,%edx
  801de5:	88 c1                	mov    %al,%cl
  801de7:	d3 ea                	shr    %cl,%edx
  801de9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801ded:	09 ca                	or     %ecx,%edx
  801def:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801df3:	89 f1                	mov    %esi,%ecx
  801df5:	d3 e5                	shl    %cl,%ebp
  801df7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801dfb:	89 fd                	mov    %edi,%ebp
  801dfd:	88 c1                	mov    %al,%cl
  801dff:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801e01:	89 fa                	mov    %edi,%edx
  801e03:	89 f1                	mov    %esi,%ecx
  801e05:	d3 e2                	shl    %cl,%edx
  801e07:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e0b:	88 c1                	mov    %al,%cl
  801e0d:	d3 ef                	shr    %cl,%edi
  801e0f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e11:	89 f8                	mov    %edi,%eax
  801e13:	89 ea                	mov    %ebp,%edx
  801e15:	f7 74 24 08          	divl   0x8(%esp)
  801e19:	89 d1                	mov    %edx,%ecx
  801e1b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801e1d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e21:	39 d1                	cmp    %edx,%ecx
  801e23:	72 17                	jb     801e3c <__udivdi3+0x10c>
  801e25:	74 09                	je     801e30 <__udivdi3+0x100>
  801e27:	89 fe                	mov    %edi,%esi
  801e29:	31 ff                	xor    %edi,%edi
  801e2b:	e9 41 ff ff ff       	jmp    801d71 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e30:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e34:	89 f1                	mov    %esi,%ecx
  801e36:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e38:	39 c2                	cmp    %eax,%edx
  801e3a:	73 eb                	jae    801e27 <__udivdi3+0xf7>
		{
		  q0--;
  801e3c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e3f:	31 ff                	xor    %edi,%edi
  801e41:	e9 2b ff ff ff       	jmp    801d71 <__udivdi3+0x41>
  801e46:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e48:	31 f6                	xor    %esi,%esi
  801e4a:	e9 22 ff ff ff       	jmp    801d71 <__udivdi3+0x41>
	...

00801e50 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e50:	55                   	push   %ebp
  801e51:	57                   	push   %edi
  801e52:	56                   	push   %esi
  801e53:	83 ec 20             	sub    $0x20,%esp
  801e56:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e5a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e5e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e62:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801e66:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e6a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801e6e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801e70:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e72:	85 ed                	test   %ebp,%ebp
  801e74:	75 16                	jne    801e8c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801e76:	39 f1                	cmp    %esi,%ecx
  801e78:	0f 86 a6 00 00 00    	jbe    801f24 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e7e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801e80:	89 d0                	mov    %edx,%eax
  801e82:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e84:	83 c4 20             	add    $0x20,%esp
  801e87:	5e                   	pop    %esi
  801e88:	5f                   	pop    %edi
  801e89:	5d                   	pop    %ebp
  801e8a:	c3                   	ret    
  801e8b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e8c:	39 f5                	cmp    %esi,%ebp
  801e8e:	0f 87 ac 00 00 00    	ja     801f40 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e94:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801e97:	83 f0 1f             	xor    $0x1f,%eax
  801e9a:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e9e:	0f 84 a8 00 00 00    	je     801f4c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ea4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ea8:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801eaa:	bf 20 00 00 00       	mov    $0x20,%edi
  801eaf:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801eb3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801eb7:	89 f9                	mov    %edi,%ecx
  801eb9:	d3 e8                	shr    %cl,%eax
  801ebb:	09 e8                	or     %ebp,%eax
  801ebd:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801ec1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ec5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ec9:	d3 e0                	shl    %cl,%eax
  801ecb:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ecf:	89 f2                	mov    %esi,%edx
  801ed1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801ed3:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ed7:	d3 e0                	shl    %cl,%eax
  801ed9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801edd:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ee1:	89 f9                	mov    %edi,%ecx
  801ee3:	d3 e8                	shr    %cl,%eax
  801ee5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801ee7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ee9:	89 f2                	mov    %esi,%edx
  801eeb:	f7 74 24 18          	divl   0x18(%esp)
  801eef:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801ef1:	f7 64 24 0c          	mull   0xc(%esp)
  801ef5:	89 c5                	mov    %eax,%ebp
  801ef7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ef9:	39 d6                	cmp    %edx,%esi
  801efb:	72 67                	jb     801f64 <__umoddi3+0x114>
  801efd:	74 75                	je     801f74 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801eff:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f03:	29 e8                	sub    %ebp,%eax
  801f05:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f07:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f0b:	d3 e8                	shr    %cl,%eax
  801f0d:	89 f2                	mov    %esi,%edx
  801f0f:	89 f9                	mov    %edi,%ecx
  801f11:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f13:	09 d0                	or     %edx,%eax
  801f15:	89 f2                	mov    %esi,%edx
  801f17:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f1b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f1d:	83 c4 20             	add    $0x20,%esp
  801f20:	5e                   	pop    %esi
  801f21:	5f                   	pop    %edi
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f24:	85 c9                	test   %ecx,%ecx
  801f26:	75 0b                	jne    801f33 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f28:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2d:	31 d2                	xor    %edx,%edx
  801f2f:	f7 f1                	div    %ecx
  801f31:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f33:	89 f0                	mov    %esi,%eax
  801f35:	31 d2                	xor    %edx,%edx
  801f37:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f39:	89 f8                	mov    %edi,%eax
  801f3b:	e9 3e ff ff ff       	jmp    801e7e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f40:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f42:	83 c4 20             	add    $0x20,%esp
  801f45:	5e                   	pop    %esi
  801f46:	5f                   	pop    %edi
  801f47:	5d                   	pop    %ebp
  801f48:	c3                   	ret    
  801f49:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f4c:	39 f5                	cmp    %esi,%ebp
  801f4e:	72 04                	jb     801f54 <__umoddi3+0x104>
  801f50:	39 f9                	cmp    %edi,%ecx
  801f52:	77 06                	ja     801f5a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f54:	89 f2                	mov    %esi,%edx
  801f56:	29 cf                	sub    %ecx,%edi
  801f58:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801f5a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f5c:	83 c4 20             	add    $0x20,%esp
  801f5f:	5e                   	pop    %esi
  801f60:	5f                   	pop    %edi
  801f61:	5d                   	pop    %ebp
  801f62:	c3                   	ret    
  801f63:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f64:	89 d1                	mov    %edx,%ecx
  801f66:	89 c5                	mov    %eax,%ebp
  801f68:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f6c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f70:	eb 8d                	jmp    801eff <__umoddi3+0xaf>
  801f72:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f74:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f78:	72 ea                	jb     801f64 <__umoddi3+0x114>
  801f7a:	89 f1                	mov    %esi,%ecx
  801f7c:	eb 81                	jmp    801eff <__umoddi3+0xaf>
