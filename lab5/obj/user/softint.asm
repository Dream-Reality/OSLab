
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	5d                   	pop    %ebp
  80003a:	c3                   	ret    
	...

0080003c <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	56                   	push   %esi
  800040:	53                   	push   %ebx
  800041:	83 ec 20             	sub    $0x20,%esp
  800044:	8b 75 08             	mov    0x8(%ebp),%esi
  800047:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80004a:	e8 f0 00 00 00       	call   80013f <sys_getenvid>
  80004f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800054:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005b:	c1 e0 07             	shl    $0x7,%eax
  80005e:	29 d0                	sub    %edx,%eax
  800060:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800065:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800068:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 f6                	test   %esi,%esi
  800072:	7e 07                	jle    80007b <libmain+0x3f>
		binaryname = argv[0];
  800074:	8b 03                	mov    (%ebx),%eax
  800076:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007f:	89 34 24             	mov    %esi,(%esp)
  800082:	e8 ad ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800087:	e8 08 00 00 00       	call   800094 <exit>
}
  80008c:	83 c4 20             	add    $0x20,%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80009a:	e8 32 05 00 00       	call   8005d1 <close_all>
	sys_env_destroy(0);
  80009f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a6:	e8 42 00 00 00       	call   8000ed <sys_env_destroy>
}
  8000ab:	c9                   	leave  
  8000ac:	c3                   	ret    
  8000ad:	00 00                	add    %al,(%eax)
	...

008000b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000be:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c1:	89 c3                	mov    %eax,%ebx
  8000c3:	89 c7                	mov    %eax,%edi
  8000c5:	89 c6                	mov    %eax,%esi
  8000c7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000de:	89 d1                	mov    %edx,%ecx
  8000e0:	89 d3                	mov    %edx,%ebx
  8000e2:	89 d7                	mov    %edx,%edi
  8000e4:	89 d6                	mov    %edx,%esi
  8000e6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5f                   	pop    %edi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fb:	b8 03 00 00 00       	mov    $0x3,%eax
  800100:	8b 55 08             	mov    0x8(%ebp),%edx
  800103:	89 cb                	mov    %ecx,%ebx
  800105:	89 cf                	mov    %ecx,%edi
  800107:	89 ce                	mov    %ecx,%esi
  800109:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010b:	85 c0                	test   %eax,%eax
  80010d:	7e 28                	jle    800137 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800113:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011a:	00 
  80011b:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  800132:	e8 c1 10 00 00       	call   8011f8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800137:	83 c4 2c             	add    $0x2c,%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 02 00 00 00       	mov    $0x2,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_yield>:

void
sys_yield(void)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800164:	ba 00 00 00 00       	mov    $0x0,%edx
  800169:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016e:	89 d1                	mov    %edx,%ecx
  800170:	89 d3                	mov    %edx,%ebx
  800172:	89 d7                	mov    %edx,%edi
  800174:	89 d6                	mov    %edx,%esi
  800176:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800178:	5b                   	pop    %ebx
  800179:	5e                   	pop    %esi
  80017a:	5f                   	pop    %edi
  80017b:	5d                   	pop    %ebp
  80017c:	c3                   	ret    

0080017d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	57                   	push   %edi
  800181:	56                   	push   %esi
  800182:	53                   	push   %ebx
  800183:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800186:	be 00 00 00 00       	mov    $0x0,%esi
  80018b:	b8 04 00 00 00       	mov    $0x4,%eax
  800190:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800193:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800196:	8b 55 08             	mov    0x8(%ebp),%edx
  800199:	89 f7                	mov    %esi,%edi
  80019b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80019d:	85 c0                	test   %eax,%eax
  80019f:	7e 28                	jle    8001c9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001bc:	00 
  8001bd:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  8001c4:	e8 2f 10 00 00       	call   8011f8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c9:	83 c4 2c             	add    $0x2c,%esp
  8001cc:	5b                   	pop    %ebx
  8001cd:	5e                   	pop    %esi
  8001ce:	5f                   	pop    %edi
  8001cf:	5d                   	pop    %ebp
  8001d0:	c3                   	ret    

008001d1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	57                   	push   %edi
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001da:	b8 05 00 00 00       	mov    $0x5,%eax
  8001df:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f0:	85 c0                	test   %eax,%eax
  8001f2:	7e 28                	jle    80021c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001ff:	00 
  800200:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  800207:	00 
  800208:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020f:	00 
  800210:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  800217:	e8 dc 0f 00 00       	call   8011f8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80021c:	83 c4 2c             	add    $0x2c,%esp
  80021f:	5b                   	pop    %ebx
  800220:	5e                   	pop    %esi
  800221:	5f                   	pop    %edi
  800222:	5d                   	pop    %ebp
  800223:	c3                   	ret    

00800224 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800232:	b8 06 00 00 00       	mov    $0x6,%eax
  800237:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023a:	8b 55 08             	mov    0x8(%ebp),%edx
  80023d:	89 df                	mov    %ebx,%edi
  80023f:	89 de                	mov    %ebx,%esi
  800241:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800243:	85 c0                	test   %eax,%eax
  800245:	7e 28                	jle    80026f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800247:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800252:	00 
  800253:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  80025a:	00 
  80025b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800262:	00 
  800263:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  80026a:	e8 89 0f 00 00       	call   8011f8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026f:	83 c4 2c             	add    $0x2c,%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	57                   	push   %edi
  80027b:	56                   	push   %esi
  80027c:	53                   	push   %ebx
  80027d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800280:	bb 00 00 00 00       	mov    $0x0,%ebx
  800285:	b8 08 00 00 00       	mov    $0x8,%eax
  80028a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028d:	8b 55 08             	mov    0x8(%ebp),%edx
  800290:	89 df                	mov    %ebx,%edi
  800292:	89 de                	mov    %ebx,%esi
  800294:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800296:	85 c0                	test   %eax,%eax
  800298:	7e 28                	jle    8002c2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a5:	00 
  8002a6:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8002ad:	00 
  8002ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b5:	00 
  8002b6:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  8002bd:	e8 36 0f 00 00       	call   8011f8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c2:	83 c4 2c             	add    $0x2c,%esp
  8002c5:	5b                   	pop    %ebx
  8002c6:	5e                   	pop    %esi
  8002c7:	5f                   	pop    %edi
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d8:	b8 09 00 00 00       	mov    $0x9,%eax
  8002dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e3:	89 df                	mov    %ebx,%edi
  8002e5:	89 de                	mov    %ebx,%esi
  8002e7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e9:	85 c0                	test   %eax,%eax
  8002eb:	7e 28                	jle    800315 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f8:	00 
  8002f9:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  800300:	00 
  800301:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800308:	00 
  800309:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  800310:	e8 e3 0e 00 00       	call   8011f8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800315:	83 c4 2c             	add    $0x2c,%esp
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5f                   	pop    %edi
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800326:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 df                	mov    %ebx,%edi
  800338:	89 de                	mov    %ebx,%esi
  80033a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80033c:	85 c0                	test   %eax,%eax
  80033e:	7e 28                	jle    800368 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800340:	89 44 24 10          	mov    %eax,0x10(%esp)
  800344:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80034b:	00 
  80034c:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  800353:	00 
  800354:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80035b:	00 
  80035c:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  800363:	e8 90 0e 00 00       	call   8011f8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800368:	83 c4 2c             	add    $0x2c,%esp
  80036b:	5b                   	pop    %ebx
  80036c:	5e                   	pop    %esi
  80036d:	5f                   	pop    %edi
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	57                   	push   %edi
  800374:	56                   	push   %esi
  800375:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800376:	be 00 00 00 00       	mov    $0x0,%esi
  80037b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800380:	8b 7d 14             	mov    0x14(%ebp),%edi
  800383:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800386:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800389:	8b 55 08             	mov    0x8(%ebp),%edx
  80038c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80038e:	5b                   	pop    %ebx
  80038f:	5e                   	pop    %esi
  800390:	5f                   	pop    %edi
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	57                   	push   %edi
  800397:	56                   	push   %esi
  800398:	53                   	push   %ebx
  800399:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a9:	89 cb                	mov    %ecx,%ebx
  8003ab:	89 cf                	mov    %ecx,%edi
  8003ad:	89 ce                	mov    %ecx,%esi
  8003af:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003b1:	85 c0                	test   %eax,%eax
  8003b3:	7e 28                	jle    8003dd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003b9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c0:	00 
  8003c1:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8003c8:	00 
  8003c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d0:	00 
  8003d1:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  8003d8:	e8 1b 0e 00 00       	call   8011f8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003dd:	83 c4 2c             	add    $0x2c,%esp
  8003e0:	5b                   	pop    %ebx
  8003e1:	5e                   	pop    %esi
  8003e2:	5f                   	pop    %edi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    
  8003e5:	00 00                	add    %al,(%eax)
	...

008003e8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ee:	05 00 00 00 30       	add    $0x30000000,%eax
  8003f3:	c1 e8 0c             	shr    $0xc,%eax
}
  8003f6:	5d                   	pop    %ebp
  8003f7:	c3                   	ret    

008003f8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
  8003fb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	89 04 24             	mov    %eax,(%esp)
  800404:	e8 df ff ff ff       	call   8003e8 <fd2num>
  800409:	05 20 00 0d 00       	add    $0xd0020,%eax
  80040e:	c1 e0 0c             	shl    $0xc,%eax
}
  800411:	c9                   	leave  
  800412:	c3                   	ret    

00800413 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	53                   	push   %ebx
  800417:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80041a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80041f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800421:	89 c2                	mov    %eax,%edx
  800423:	c1 ea 16             	shr    $0x16,%edx
  800426:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80042d:	f6 c2 01             	test   $0x1,%dl
  800430:	74 11                	je     800443 <fd_alloc+0x30>
  800432:	89 c2                	mov    %eax,%edx
  800434:	c1 ea 0c             	shr    $0xc,%edx
  800437:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80043e:	f6 c2 01             	test   $0x1,%dl
  800441:	75 09                	jne    80044c <fd_alloc+0x39>
			*fd_store = fd;
  800443:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800445:	b8 00 00 00 00       	mov    $0x0,%eax
  80044a:	eb 17                	jmp    800463 <fd_alloc+0x50>
  80044c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800451:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800456:	75 c7                	jne    80041f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800458:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80045e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800463:	5b                   	pop    %ebx
  800464:	5d                   	pop    %ebp
  800465:	c3                   	ret    

00800466 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80046c:	83 f8 1f             	cmp    $0x1f,%eax
  80046f:	77 36                	ja     8004a7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800471:	05 00 00 0d 00       	add    $0xd0000,%eax
  800476:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800479:	89 c2                	mov    %eax,%edx
  80047b:	c1 ea 16             	shr    $0x16,%edx
  80047e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800485:	f6 c2 01             	test   $0x1,%dl
  800488:	74 24                	je     8004ae <fd_lookup+0x48>
  80048a:	89 c2                	mov    %eax,%edx
  80048c:	c1 ea 0c             	shr    $0xc,%edx
  80048f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800496:	f6 c2 01             	test   $0x1,%dl
  800499:	74 1a                	je     8004b5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80049b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049e:	89 02                	mov    %eax,(%edx)
	return 0;
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	eb 13                	jmp    8004ba <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004ac:	eb 0c                	jmp    8004ba <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b3:	eb 05                	jmp    8004ba <fd_lookup+0x54>
  8004b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004ba:	5d                   	pop    %ebp
  8004bb:	c3                   	ret    

008004bc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	53                   	push   %ebx
  8004c0:	83 ec 14             	sub    $0x14,%esp
  8004c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8004c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ce:	eb 0e                	jmp    8004de <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8004d0:	39 08                	cmp    %ecx,(%eax)
  8004d2:	75 09                	jne    8004dd <dev_lookup+0x21>
			*dev = devtab[i];
  8004d4:	89 03                	mov    %eax,(%ebx)
			return 0;
  8004d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004db:	eb 35                	jmp    800512 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004dd:	42                   	inc    %edx
  8004de:	8b 04 95 34 20 80 00 	mov    0x802034(,%edx,4),%eax
  8004e5:	85 c0                	test   %eax,%eax
  8004e7:	75 e7                	jne    8004d0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8004ee:	8b 00                	mov    (%eax),%eax
  8004f0:	8b 40 48             	mov    0x48(%eax),%eax
  8004f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004fb:	c7 04 24 b8 1f 80 00 	movl   $0x801fb8,(%esp)
  800502:	e8 e9 0d 00 00       	call   8012f0 <cprintf>
	*dev = 0;
  800507:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80050d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800512:	83 c4 14             	add    $0x14,%esp
  800515:	5b                   	pop    %ebx
  800516:	5d                   	pop    %ebp
  800517:	c3                   	ret    

00800518 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800518:	55                   	push   %ebp
  800519:	89 e5                	mov    %esp,%ebp
  80051b:	56                   	push   %esi
  80051c:	53                   	push   %ebx
  80051d:	83 ec 30             	sub    $0x30,%esp
  800520:	8b 75 08             	mov    0x8(%ebp),%esi
  800523:	8a 45 0c             	mov    0xc(%ebp),%al
  800526:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800529:	89 34 24             	mov    %esi,(%esp)
  80052c:	e8 b7 fe ff ff       	call   8003e8 <fd2num>
  800531:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800534:	89 54 24 04          	mov    %edx,0x4(%esp)
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	e8 26 ff ff ff       	call   800466 <fd_lookup>
  800540:	89 c3                	mov    %eax,%ebx
  800542:	85 c0                	test   %eax,%eax
  800544:	78 05                	js     80054b <fd_close+0x33>
	    || fd != fd2)
  800546:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800549:	74 0d                	je     800558 <fd_close+0x40>
		return (must_exist ? r : 0);
  80054b:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80054f:	75 46                	jne    800597 <fd_close+0x7f>
  800551:	bb 00 00 00 00       	mov    $0x0,%ebx
  800556:	eb 3f                	jmp    800597 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800558:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80055b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055f:	8b 06                	mov    (%esi),%eax
  800561:	89 04 24             	mov    %eax,(%esp)
  800564:	e8 53 ff ff ff       	call   8004bc <dev_lookup>
  800569:	89 c3                	mov    %eax,%ebx
  80056b:	85 c0                	test   %eax,%eax
  80056d:	78 18                	js     800587 <fd_close+0x6f>
		if (dev->dev_close)
  80056f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800572:	8b 40 10             	mov    0x10(%eax),%eax
  800575:	85 c0                	test   %eax,%eax
  800577:	74 09                	je     800582 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800579:	89 34 24             	mov    %esi,(%esp)
  80057c:	ff d0                	call   *%eax
  80057e:	89 c3                	mov    %eax,%ebx
  800580:	eb 05                	jmp    800587 <fd_close+0x6f>
		else
			r = 0;
  800582:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800587:	89 74 24 04          	mov    %esi,0x4(%esp)
  80058b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800592:	e8 8d fc ff ff       	call   800224 <sys_page_unmap>
	return r;
}
  800597:	89 d8                	mov    %ebx,%eax
  800599:	83 c4 30             	add    $0x30,%esp
  80059c:	5b                   	pop    %ebx
  80059d:	5e                   	pop    %esi
  80059e:	5d                   	pop    %ebp
  80059f:	c3                   	ret    

008005a0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005a0:	55                   	push   %ebp
  8005a1:	89 e5                	mov    %esp,%ebp
  8005a3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	e8 ae fe ff ff       	call   800466 <fd_lookup>
  8005b8:	85 c0                	test   %eax,%eax
  8005ba:	78 13                	js     8005cf <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005bc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005c3:	00 
  8005c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005c7:	89 04 24             	mov    %eax,(%esp)
  8005ca:	e8 49 ff ff ff       	call   800518 <fd_close>
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <close_all>:

void
close_all(void)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	53                   	push   %ebx
  8005d5:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005d8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005dd:	89 1c 24             	mov    %ebx,(%esp)
  8005e0:	e8 bb ff ff ff       	call   8005a0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005e5:	43                   	inc    %ebx
  8005e6:	83 fb 20             	cmp    $0x20,%ebx
  8005e9:	75 f2                	jne    8005dd <close_all+0xc>
		close(i);
}
  8005eb:	83 c4 14             	add    $0x14,%esp
  8005ee:	5b                   	pop    %ebx
  8005ef:	5d                   	pop    %ebp
  8005f0:	c3                   	ret    

008005f1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005f1:	55                   	push   %ebp
  8005f2:	89 e5                	mov    %esp,%ebp
  8005f4:	57                   	push   %edi
  8005f5:	56                   	push   %esi
  8005f6:	53                   	push   %ebx
  8005f7:	83 ec 4c             	sub    $0x4c,%esp
  8005fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005fd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800600:	89 44 24 04          	mov    %eax,0x4(%esp)
  800604:	8b 45 08             	mov    0x8(%ebp),%eax
  800607:	89 04 24             	mov    %eax,(%esp)
  80060a:	e8 57 fe ff ff       	call   800466 <fd_lookup>
  80060f:	89 c3                	mov    %eax,%ebx
  800611:	85 c0                	test   %eax,%eax
  800613:	0f 88 e1 00 00 00    	js     8006fa <dup+0x109>
		return r;
	close(newfdnum);
  800619:	89 3c 24             	mov    %edi,(%esp)
  80061c:	e8 7f ff ff ff       	call   8005a0 <close>

	newfd = INDEX2FD(newfdnum);
  800621:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800627:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80062a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80062d:	89 04 24             	mov    %eax,(%esp)
  800630:	e8 c3 fd ff ff       	call   8003f8 <fd2data>
  800635:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800637:	89 34 24             	mov    %esi,(%esp)
  80063a:	e8 b9 fd ff ff       	call   8003f8 <fd2data>
  80063f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800642:	89 d8                	mov    %ebx,%eax
  800644:	c1 e8 16             	shr    $0x16,%eax
  800647:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80064e:	a8 01                	test   $0x1,%al
  800650:	74 46                	je     800698 <dup+0xa7>
  800652:	89 d8                	mov    %ebx,%eax
  800654:	c1 e8 0c             	shr    $0xc,%eax
  800657:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80065e:	f6 c2 01             	test   $0x1,%dl
  800661:	74 35                	je     800698 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800663:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80066a:	25 07 0e 00 00       	and    $0xe07,%eax
  80066f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800673:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800676:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800681:	00 
  800682:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800686:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80068d:	e8 3f fb ff ff       	call   8001d1 <sys_page_map>
  800692:	89 c3                	mov    %eax,%ebx
  800694:	85 c0                	test   %eax,%eax
  800696:	78 3b                	js     8006d3 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800698:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80069b:	89 c2                	mov    %eax,%edx
  80069d:	c1 ea 0c             	shr    $0xc,%edx
  8006a0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006a7:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006b1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006bc:	00 
  8006bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006c8:	e8 04 fb ff ff       	call   8001d1 <sys_page_map>
  8006cd:	89 c3                	mov    %eax,%ebx
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	79 25                	jns    8006f8 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006de:	e8 41 fb ff ff       	call   800224 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006f1:	e8 2e fb ff ff       	call   800224 <sys_page_unmap>
	return r;
  8006f6:	eb 02                	jmp    8006fa <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8006f8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8006fa:	89 d8                	mov    %ebx,%eax
  8006fc:	83 c4 4c             	add    $0x4c,%esp
  8006ff:	5b                   	pop    %ebx
  800700:	5e                   	pop    %esi
  800701:	5f                   	pop    %edi
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	53                   	push   %ebx
  800708:	83 ec 24             	sub    $0x24,%esp
  80070b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800711:	89 44 24 04          	mov    %eax,0x4(%esp)
  800715:	89 1c 24             	mov    %ebx,(%esp)
  800718:	e8 49 fd ff ff       	call   800466 <fd_lookup>
  80071d:	85 c0                	test   %eax,%eax
  80071f:	78 6f                	js     800790 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800721:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800724:	89 44 24 04          	mov    %eax,0x4(%esp)
  800728:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072b:	8b 00                	mov    (%eax),%eax
  80072d:	89 04 24             	mov    %eax,(%esp)
  800730:	e8 87 fd ff ff       	call   8004bc <dev_lookup>
  800735:	85 c0                	test   %eax,%eax
  800737:	78 57                	js     800790 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800739:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073c:	8b 50 08             	mov    0x8(%eax),%edx
  80073f:	83 e2 03             	and    $0x3,%edx
  800742:	83 fa 01             	cmp    $0x1,%edx
  800745:	75 25                	jne    80076c <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800747:	a1 04 40 80 00       	mov    0x804004,%eax
  80074c:	8b 00                	mov    (%eax),%eax
  80074e:	8b 40 48             	mov    0x48(%eax),%eax
  800751:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800755:	89 44 24 04          	mov    %eax,0x4(%esp)
  800759:	c7 04 24 f9 1f 80 00 	movl   $0x801ff9,(%esp)
  800760:	e8 8b 0b 00 00       	call   8012f0 <cprintf>
		return -E_INVAL;
  800765:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076a:	eb 24                	jmp    800790 <read+0x8c>
	}
	if (!dev->dev_read)
  80076c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076f:	8b 52 08             	mov    0x8(%edx),%edx
  800772:	85 d2                	test   %edx,%edx
  800774:	74 15                	je     80078b <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800776:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800779:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80077d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800780:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800784:	89 04 24             	mov    %eax,(%esp)
  800787:	ff d2                	call   *%edx
  800789:	eb 05                	jmp    800790 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80078b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800790:	83 c4 24             	add    $0x24,%esp
  800793:	5b                   	pop    %ebx
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	57                   	push   %edi
  80079a:	56                   	push   %esi
  80079b:	53                   	push   %ebx
  80079c:	83 ec 1c             	sub    $0x1c,%esp
  80079f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007a2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007aa:	eb 23                	jmp    8007cf <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007ac:	89 f0                	mov    %esi,%eax
  8007ae:	29 d8                	sub    %ebx,%eax
  8007b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b7:	01 d8                	add    %ebx,%eax
  8007b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bd:	89 3c 24             	mov    %edi,(%esp)
  8007c0:	e8 3f ff ff ff       	call   800704 <read>
		if (m < 0)
  8007c5:	85 c0                	test   %eax,%eax
  8007c7:	78 10                	js     8007d9 <readn+0x43>
			return m;
		if (m == 0)
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	74 0a                	je     8007d7 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007cd:	01 c3                	add    %eax,%ebx
  8007cf:	39 f3                	cmp    %esi,%ebx
  8007d1:	72 d9                	jb     8007ac <readn+0x16>
  8007d3:	89 d8                	mov    %ebx,%eax
  8007d5:	eb 02                	jmp    8007d9 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8007d7:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007d9:	83 c4 1c             	add    $0x1c,%esp
  8007dc:	5b                   	pop    %ebx
  8007dd:	5e                   	pop    %esi
  8007de:	5f                   	pop    %edi
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	83 ec 24             	sub    $0x24,%esp
  8007e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f2:	89 1c 24             	mov    %ebx,(%esp)
  8007f5:	e8 6c fc ff ff       	call   800466 <fd_lookup>
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	78 6a                	js     800868 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800801:	89 44 24 04          	mov    %eax,0x4(%esp)
  800805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800808:	8b 00                	mov    (%eax),%eax
  80080a:	89 04 24             	mov    %eax,(%esp)
  80080d:	e8 aa fc ff ff       	call   8004bc <dev_lookup>
  800812:	85 c0                	test   %eax,%eax
  800814:	78 52                	js     800868 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800816:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800819:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80081d:	75 25                	jne    800844 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80081f:	a1 04 40 80 00       	mov    0x804004,%eax
  800824:	8b 00                	mov    (%eax),%eax
  800826:	8b 40 48             	mov    0x48(%eax),%eax
  800829:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80082d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800831:	c7 04 24 15 20 80 00 	movl   $0x802015,(%esp)
  800838:	e8 b3 0a 00 00       	call   8012f0 <cprintf>
		return -E_INVAL;
  80083d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800842:	eb 24                	jmp    800868 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800844:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800847:	8b 52 0c             	mov    0xc(%edx),%edx
  80084a:	85 d2                	test   %edx,%edx
  80084c:	74 15                	je     800863 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80084e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800851:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800855:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800858:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80085c:	89 04 24             	mov    %eax,(%esp)
  80085f:	ff d2                	call   *%edx
  800861:	eb 05                	jmp    800868 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800863:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800868:	83 c4 24             	add    $0x24,%esp
  80086b:	5b                   	pop    %ebx
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <seek>:

int
seek(int fdnum, off_t offset)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800874:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800877:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	89 04 24             	mov    %eax,(%esp)
  800881:	e8 e0 fb ff ff       	call   800466 <fd_lookup>
  800886:	85 c0                	test   %eax,%eax
  800888:	78 0e                	js     800898 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80088a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80088d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800890:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800893:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800898:	c9                   	leave  
  800899:	c3                   	ret    

0080089a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	83 ec 24             	sub    $0x24,%esp
  8008a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ab:	89 1c 24             	mov    %ebx,(%esp)
  8008ae:	e8 b3 fb ff ff       	call   800466 <fd_lookup>
  8008b3:	85 c0                	test   %eax,%eax
  8008b5:	78 63                	js     80091a <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c1:	8b 00                	mov    (%eax),%eax
  8008c3:	89 04 24             	mov    %eax,(%esp)
  8008c6:	e8 f1 fb ff ff       	call   8004bc <dev_lookup>
  8008cb:	85 c0                	test   %eax,%eax
  8008cd:	78 4b                	js     80091a <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008d6:	75 25                	jne    8008fd <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8008dd:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008df:	8b 40 48             	mov    0x48(%eax),%eax
  8008e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ea:	c7 04 24 d8 1f 80 00 	movl   $0x801fd8,(%esp)
  8008f1:	e8 fa 09 00 00       	call   8012f0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008fb:	eb 1d                	jmp    80091a <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  8008fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800900:	8b 52 18             	mov    0x18(%edx),%edx
  800903:	85 d2                	test   %edx,%edx
  800905:	74 0e                	je     800915 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800907:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80090e:	89 04 24             	mov    %eax,(%esp)
  800911:	ff d2                	call   *%edx
  800913:	eb 05                	jmp    80091a <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800915:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80091a:	83 c4 24             	add    $0x24,%esp
  80091d:	5b                   	pop    %ebx
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	53                   	push   %ebx
  800924:	83 ec 24             	sub    $0x24,%esp
  800927:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80092a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80092d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	89 04 24             	mov    %eax,(%esp)
  800937:	e8 2a fb ff ff       	call   800466 <fd_lookup>
  80093c:	85 c0                	test   %eax,%eax
  80093e:	78 52                	js     800992 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800940:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800943:	89 44 24 04          	mov    %eax,0x4(%esp)
  800947:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80094a:	8b 00                	mov    (%eax),%eax
  80094c:	89 04 24             	mov    %eax,(%esp)
  80094f:	e8 68 fb ff ff       	call   8004bc <dev_lookup>
  800954:	85 c0                	test   %eax,%eax
  800956:	78 3a                	js     800992 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800958:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80095f:	74 2c                	je     80098d <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800961:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800964:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80096b:	00 00 00 
	stat->st_isdir = 0;
  80096e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800975:	00 00 00 
	stat->st_dev = dev;
  800978:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80097e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800982:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800985:	89 14 24             	mov    %edx,(%esp)
  800988:	ff 50 14             	call   *0x14(%eax)
  80098b:	eb 05                	jmp    800992 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80098d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800992:	83 c4 24             	add    $0x24,%esp
  800995:	5b                   	pop    %ebx
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009a7:	00 
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	89 04 24             	mov    %eax,(%esp)
  8009ae:	e8 88 02 00 00       	call   800c3b <open>
  8009b3:	89 c3                	mov    %eax,%ebx
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	78 1b                	js     8009d4 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c0:	89 1c 24             	mov    %ebx,(%esp)
  8009c3:	e8 58 ff ff ff       	call   800920 <fstat>
  8009c8:	89 c6                	mov    %eax,%esi
	close(fd);
  8009ca:	89 1c 24             	mov    %ebx,(%esp)
  8009cd:	e8 ce fb ff ff       	call   8005a0 <close>
	return r;
  8009d2:	89 f3                	mov    %esi,%ebx
}
  8009d4:	89 d8                	mov    %ebx,%eax
  8009d6:	83 c4 10             	add    $0x10,%esp
  8009d9:	5b                   	pop    %ebx
  8009da:	5e                   	pop    %esi
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    
  8009dd:	00 00                	add    %al,(%eax)
	...

008009e0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	83 ec 10             	sub    $0x10,%esp
  8009e8:	89 c3                	mov    %eax,%ebx
  8009ea:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8009ec:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009f3:	75 11                	jne    800a06 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009fc:	e8 92 12 00 00       	call   801c93 <ipc_find_env>
  800a01:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a06:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a0d:	00 
  800a0e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a15:	00 
  800a16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1a:	a1 00 40 80 00       	mov    0x804000,%eax
  800a1f:	89 04 24             	mov    %eax,(%esp)
  800a22:	e8 06 12 00 00       	call   801c2d <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  800a27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a2e:	00 
  800a2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a3a:	e8 81 11 00 00       	call   801bc0 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  800a3f:	83 c4 10             	add    $0x10,%esp
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a52:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a64:	b8 02 00 00 00       	mov    $0x2,%eax
  800a69:	e8 72 ff ff ff       	call   8009e0 <fsipc>
}
  800a6e:	c9                   	leave  
  800a6f:	c3                   	ret    

00800a70 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	8b 40 0c             	mov    0xc(%eax),%eax
  800a7c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a81:	ba 00 00 00 00       	mov    $0x0,%edx
  800a86:	b8 06 00 00 00       	mov    $0x6,%eax
  800a8b:	e8 50 ff ff ff       	call   8009e0 <fsipc>
}
  800a90:	c9                   	leave  
  800a91:	c3                   	ret    

00800a92 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	53                   	push   %ebx
  800a96:	83 ec 14             	sub    $0x14,%esp
  800a99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 40 0c             	mov    0xc(%eax),%eax
  800aa2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800aa7:	ba 00 00 00 00       	mov    $0x0,%edx
  800aac:	b8 05 00 00 00       	mov    $0x5,%eax
  800ab1:	e8 2a ff ff ff       	call   8009e0 <fsipc>
  800ab6:	85 c0                	test   %eax,%eax
  800ab8:	78 2b                	js     800ae5 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800aba:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ac1:	00 
  800ac2:	89 1c 24             	mov    %ebx,(%esp)
  800ac5:	e8 d1 0d 00 00       	call   80189b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800aca:	a1 80 50 80 00       	mov    0x805080,%eax
  800acf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ad5:	a1 84 50 80 00       	mov    0x805084,%eax
  800ada:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ae0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae5:	83 c4 14             	add    $0x14,%esp
  800ae8:	5b                   	pop    %ebx
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	53                   	push   %ebx
  800aef:	83 ec 14             	sub    $0x14,%esp
  800af2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800af5:	8b 45 08             	mov    0x8(%ebp),%eax
  800af8:	8b 40 0c             	mov    0xc(%eax),%eax
  800afb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  800b00:	89 d8                	mov    %ebx,%eax
  800b02:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800b08:	76 05                	jbe    800b0f <devfile_write+0x24>
  800b0a:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800b0f:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  800b14:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1f:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b26:	e8 53 0f 00 00       	call   801a7e <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  800b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b30:	b8 04 00 00 00       	mov    $0x4,%eax
  800b35:	e8 a6 fe ff ff       	call   8009e0 <fsipc>
  800b3a:	85 c0                	test   %eax,%eax
  800b3c:	78 53                	js     800b91 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  800b3e:	39 c3                	cmp    %eax,%ebx
  800b40:	73 24                	jae    800b66 <devfile_write+0x7b>
  800b42:	c7 44 24 0c 44 20 80 	movl   $0x802044,0xc(%esp)
  800b49:	00 
  800b4a:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800b51:	00 
  800b52:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  800b59:	00 
  800b5a:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800b61:	e8 92 06 00 00       	call   8011f8 <_panic>
	assert(r <= PGSIZE);
  800b66:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b6b:	7e 24                	jle    800b91 <devfile_write+0xa6>
  800b6d:	c7 44 24 0c 6b 20 80 	movl   $0x80206b,0xc(%esp)
  800b74:	00 
  800b75:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800b7c:	00 
  800b7d:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  800b84:	00 
  800b85:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800b8c:	e8 67 06 00 00       	call   8011f8 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  800b91:	83 c4 14             	add    $0x14,%esp
  800b94:	5b                   	pop    %ebx
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	83 ec 10             	sub    $0x10,%esp
  800b9f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba5:	8b 40 0c             	mov    0xc(%eax),%eax
  800ba8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800bad:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bbd:	e8 1e fe ff ff       	call   8009e0 <fsipc>
  800bc2:	89 c3                	mov    %eax,%ebx
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	78 6a                	js     800c32 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800bc8:	39 c6                	cmp    %eax,%esi
  800bca:	73 24                	jae    800bf0 <devfile_read+0x59>
  800bcc:	c7 44 24 0c 44 20 80 	movl   $0x802044,0xc(%esp)
  800bd3:	00 
  800bd4:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800bdb:	00 
  800bdc:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  800be3:	00 
  800be4:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800beb:	e8 08 06 00 00       	call   8011f8 <_panic>
	assert(r <= PGSIZE);
  800bf0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800bf5:	7e 24                	jle    800c1b <devfile_read+0x84>
  800bf7:	c7 44 24 0c 6b 20 80 	movl   $0x80206b,0xc(%esp)
  800bfe:	00 
  800bff:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800c06:	00 
  800c07:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  800c0e:	00 
  800c0f:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800c16:	e8 dd 05 00 00       	call   8011f8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c1f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c26:	00 
  800c27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2a:	89 04 24             	mov    %eax,(%esp)
  800c2d:	e8 e2 0d 00 00       	call   801a14 <memmove>
	return r;
}
  800c32:	89 d8                	mov    %ebx,%eax
  800c34:	83 c4 10             	add    $0x10,%esp
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
  800c40:	83 ec 20             	sub    $0x20,%esp
  800c43:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c46:	89 34 24             	mov    %esi,(%esp)
  800c49:	e8 1a 0c 00 00       	call   801868 <strlen>
  800c4e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c53:	7f 60                	jg     800cb5 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c58:	89 04 24             	mov    %eax,(%esp)
  800c5b:	e8 b3 f7 ff ff       	call   800413 <fd_alloc>
  800c60:	89 c3                	mov    %eax,%ebx
  800c62:	85 c0                	test   %eax,%eax
  800c64:	78 54                	js     800cba <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c6a:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c71:	e8 25 0c 00 00       	call   80189b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c79:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c81:	b8 01 00 00 00       	mov    $0x1,%eax
  800c86:	e8 55 fd ff ff       	call   8009e0 <fsipc>
  800c8b:	89 c3                	mov    %eax,%ebx
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	79 15                	jns    800ca6 <open+0x6b>
		fd_close(fd, 0);
  800c91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c98:	00 
  800c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9c:	89 04 24             	mov    %eax,(%esp)
  800c9f:	e8 74 f8 ff ff       	call   800518 <fd_close>
		return r;
  800ca4:	eb 14                	jmp    800cba <open+0x7f>
	}

	return fd2num(fd);
  800ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca9:	89 04 24             	mov    %eax,(%esp)
  800cac:	e8 37 f7 ff ff       	call   8003e8 <fd2num>
  800cb1:	89 c3                	mov    %eax,%ebx
  800cb3:	eb 05                	jmp    800cba <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cb5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800cba:	89 d8                	mov    %ebx,%eax
  800cbc:	83 c4 20             	add    $0x20,%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800cc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cce:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd3:	e8 08 fd ff ff       	call   8009e0 <fsipc>
}
  800cd8:	c9                   	leave  
  800cd9:	c3                   	ret    
	...

00800cdc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 10             	sub    $0x10,%esp
  800ce4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cea:	89 04 24             	mov    %eax,(%esp)
  800ced:	e8 06 f7 ff ff       	call   8003f8 <fd2data>
  800cf2:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800cf4:	c7 44 24 04 77 20 80 	movl   $0x802077,0x4(%esp)
  800cfb:	00 
  800cfc:	89 34 24             	mov    %esi,(%esp)
  800cff:	e8 97 0b 00 00       	call   80189b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800d04:	8b 43 04             	mov    0x4(%ebx),%eax
  800d07:	2b 03                	sub    (%ebx),%eax
  800d09:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800d0f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800d16:	00 00 00 
	stat->st_dev = &devpipe;
  800d19:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800d20:	30 80 00 
	return 0;
}
  800d23:	b8 00 00 00 00       	mov    $0x0,%eax
  800d28:	83 c4 10             	add    $0x10,%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	53                   	push   %ebx
  800d33:	83 ec 14             	sub    $0x14,%esp
  800d36:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800d39:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d44:	e8 db f4 ff ff       	call   800224 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800d49:	89 1c 24             	mov    %ebx,(%esp)
  800d4c:	e8 a7 f6 ff ff       	call   8003f8 <fd2data>
  800d51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d5c:	e8 c3 f4 ff ff       	call   800224 <sys_page_unmap>
}
  800d61:	83 c4 14             	add    $0x14,%esp
  800d64:	5b                   	pop    %ebx
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 2c             	sub    $0x2c,%esp
  800d70:	89 c7                	mov    %eax,%edi
  800d72:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800d75:	a1 04 40 80 00       	mov    0x804004,%eax
  800d7a:	8b 00                	mov    (%eax),%eax
  800d7c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800d7f:	89 3c 24             	mov    %edi,(%esp)
  800d82:	e8 51 0f 00 00       	call   801cd8 <pageref>
  800d87:	89 c6                	mov    %eax,%esi
  800d89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d8c:	89 04 24             	mov    %eax,(%esp)
  800d8f:	e8 44 0f 00 00       	call   801cd8 <pageref>
  800d94:	39 c6                	cmp    %eax,%esi
  800d96:	0f 94 c0             	sete   %al
  800d99:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800d9c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800da2:	8b 12                	mov    (%edx),%edx
  800da4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800da7:	39 cb                	cmp    %ecx,%ebx
  800da9:	75 08                	jne    800db3 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800dab:	83 c4 2c             	add    $0x2c,%esp
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800db3:	83 f8 01             	cmp    $0x1,%eax
  800db6:	75 bd                	jne    800d75 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800db8:	8b 42 58             	mov    0x58(%edx),%eax
  800dbb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800dc2:	00 
  800dc3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dc7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dcb:	c7 04 24 7e 20 80 00 	movl   $0x80207e,(%esp)
  800dd2:	e8 19 05 00 00       	call   8012f0 <cprintf>
  800dd7:	eb 9c                	jmp    800d75 <_pipeisclosed+0xe>

00800dd9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	57                   	push   %edi
  800ddd:	56                   	push   %esi
  800dde:	53                   	push   %ebx
  800ddf:	83 ec 1c             	sub    $0x1c,%esp
  800de2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800de5:	89 34 24             	mov    %esi,(%esp)
  800de8:	e8 0b f6 ff ff       	call   8003f8 <fd2data>
  800ded:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800def:	bf 00 00 00 00       	mov    $0x0,%edi
  800df4:	eb 3c                	jmp    800e32 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800df6:	89 da                	mov    %ebx,%edx
  800df8:	89 f0                	mov    %esi,%eax
  800dfa:	e8 68 ff ff ff       	call   800d67 <_pipeisclosed>
  800dff:	85 c0                	test   %eax,%eax
  800e01:	75 38                	jne    800e3b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800e03:	e8 56 f3 ff ff       	call   80015e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800e08:	8b 43 04             	mov    0x4(%ebx),%eax
  800e0b:	8b 13                	mov    (%ebx),%edx
  800e0d:	83 c2 20             	add    $0x20,%edx
  800e10:	39 d0                	cmp    %edx,%eax
  800e12:	73 e2                	jae    800df6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800e14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e17:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800e1a:	89 c2                	mov    %eax,%edx
  800e1c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800e22:	79 05                	jns    800e29 <devpipe_write+0x50>
  800e24:	4a                   	dec    %edx
  800e25:	83 ca e0             	or     $0xffffffe0,%edx
  800e28:	42                   	inc    %edx
  800e29:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800e2d:	40                   	inc    %eax
  800e2e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e31:	47                   	inc    %edi
  800e32:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800e35:	75 d1                	jne    800e08 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800e37:	89 f8                	mov    %edi,%eax
  800e39:	eb 05                	jmp    800e40 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e3b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800e40:	83 c4 1c             	add    $0x1c,%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
  800e4e:	83 ec 1c             	sub    $0x1c,%esp
  800e51:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800e54:	89 3c 24             	mov    %edi,(%esp)
  800e57:	e8 9c f5 ff ff       	call   8003f8 <fd2data>
  800e5c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e5e:	be 00 00 00 00       	mov    $0x0,%esi
  800e63:	eb 3a                	jmp    800e9f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800e65:	85 f6                	test   %esi,%esi
  800e67:	74 04                	je     800e6d <devpipe_read+0x25>
				return i;
  800e69:	89 f0                	mov    %esi,%eax
  800e6b:	eb 40                	jmp    800ead <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800e6d:	89 da                	mov    %ebx,%edx
  800e6f:	89 f8                	mov    %edi,%eax
  800e71:	e8 f1 fe ff ff       	call   800d67 <_pipeisclosed>
  800e76:	85 c0                	test   %eax,%eax
  800e78:	75 2e                	jne    800ea8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800e7a:	e8 df f2 ff ff       	call   80015e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800e7f:	8b 03                	mov    (%ebx),%eax
  800e81:	3b 43 04             	cmp    0x4(%ebx),%eax
  800e84:	74 df                	je     800e65 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800e86:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800e8b:	79 05                	jns    800e92 <devpipe_read+0x4a>
  800e8d:	48                   	dec    %eax
  800e8e:	83 c8 e0             	or     $0xffffffe0,%eax
  800e91:	40                   	inc    %eax
  800e92:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800e96:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e99:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800e9c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e9e:	46                   	inc    %esi
  800e9f:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ea2:	75 db                	jne    800e7f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ea4:	89 f0                	mov    %esi,%eax
  800ea6:	eb 05                	jmp    800ead <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ea8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800ead:	83 c4 1c             	add    $0x1c,%esp
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	57                   	push   %edi
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
  800ebb:	83 ec 3c             	sub    $0x3c,%esp
  800ebe:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800ec1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ec4:	89 04 24             	mov    %eax,(%esp)
  800ec7:	e8 47 f5 ff ff       	call   800413 <fd_alloc>
  800ecc:	89 c3                	mov    %eax,%ebx
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	0f 88 45 01 00 00    	js     80101b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ed6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800edd:	00 
  800ede:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ee1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eec:	e8 8c f2 ff ff       	call   80017d <sys_page_alloc>
  800ef1:	89 c3                	mov    %eax,%ebx
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	0f 88 20 01 00 00    	js     80101b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800efb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800efe:	89 04 24             	mov    %eax,(%esp)
  800f01:	e8 0d f5 ff ff       	call   800413 <fd_alloc>
  800f06:	89 c3                	mov    %eax,%ebx
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	0f 88 f8 00 00 00    	js     801008 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f10:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f17:	00 
  800f18:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f1b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f26:	e8 52 f2 ff ff       	call   80017d <sys_page_alloc>
  800f2b:	89 c3                	mov    %eax,%ebx
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	0f 88 d3 00 00 00    	js     801008 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800f35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f38:	89 04 24             	mov    %eax,(%esp)
  800f3b:	e8 b8 f4 ff ff       	call   8003f8 <fd2data>
  800f40:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f42:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f49:	00 
  800f4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f55:	e8 23 f2 ff ff       	call   80017d <sys_page_alloc>
  800f5a:	89 c3                	mov    %eax,%ebx
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	0f 88 91 00 00 00    	js     800ff5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f64:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f67:	89 04 24             	mov    %eax,(%esp)
  800f6a:	e8 89 f4 ff ff       	call   8003f8 <fd2data>
  800f6f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800f76:	00 
  800f77:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f7b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f82:	00 
  800f83:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f8e:	e8 3e f2 ff ff       	call   8001d1 <sys_page_map>
  800f93:	89 c3                	mov    %eax,%ebx
  800f95:	85 c0                	test   %eax,%eax
  800f97:	78 4c                	js     800fe5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800f99:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fa2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800fa4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fa7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800fae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800fb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fb7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800fb9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fbc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800fc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fc6:	89 04 24             	mov    %eax,(%esp)
  800fc9:	e8 1a f4 ff ff       	call   8003e8 <fd2num>
  800fce:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800fd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fd3:	89 04 24             	mov    %eax,(%esp)
  800fd6:	e8 0d f4 ff ff       	call   8003e8 <fd2num>
  800fdb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800fde:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe3:	eb 36                	jmp    80101b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  800fe5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fe9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ff0:	e8 2f f2 ff ff       	call   800224 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  800ff5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ffc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801003:	e8 1c f2 ff ff       	call   800224 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801008:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80100b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80100f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801016:	e8 09 f2 ff ff       	call   800224 <sys_page_unmap>
    err:
	return r;
}
  80101b:	89 d8                	mov    %ebx,%eax
  80101d:	83 c4 3c             	add    $0x3c,%esp
  801020:	5b                   	pop    %ebx
  801021:	5e                   	pop    %esi
  801022:	5f                   	pop    %edi
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    

00801025 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80102b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801032:	8b 45 08             	mov    0x8(%ebp),%eax
  801035:	89 04 24             	mov    %eax,(%esp)
  801038:	e8 29 f4 ff ff       	call   800466 <fd_lookup>
  80103d:	85 c0                	test   %eax,%eax
  80103f:	78 15                	js     801056 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801041:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801044:	89 04 24             	mov    %eax,(%esp)
  801047:	e8 ac f3 ff ff       	call   8003f8 <fd2data>
	return _pipeisclosed(fd, p);
  80104c:	89 c2                	mov    %eax,%edx
  80104e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801051:	e8 11 fd ff ff       	call   800d67 <_pipeisclosed>
}
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80105b:	b8 00 00 00 00       	mov    $0x0,%eax
  801060:	5d                   	pop    %ebp
  801061:	c3                   	ret    

00801062 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801068:	c7 44 24 04 96 20 80 	movl   $0x802096,0x4(%esp)
  80106f:	00 
  801070:	8b 45 0c             	mov    0xc(%ebp),%eax
  801073:	89 04 24             	mov    %eax,(%esp)
  801076:	e8 20 08 00 00       	call   80189b <strcpy>
	return 0;
}
  80107b:	b8 00 00 00 00       	mov    $0x0,%eax
  801080:	c9                   	leave  
  801081:	c3                   	ret    

00801082 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	57                   	push   %edi
  801086:	56                   	push   %esi
  801087:	53                   	push   %ebx
  801088:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80108e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801093:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801099:	eb 30                	jmp    8010cb <devcons_write+0x49>
		m = n - tot;
  80109b:	8b 75 10             	mov    0x10(%ebp),%esi
  80109e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8010a0:	83 fe 7f             	cmp    $0x7f,%esi
  8010a3:	76 05                	jbe    8010aa <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8010a5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8010aa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010ae:	03 45 0c             	add    0xc(%ebp),%eax
  8010b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b5:	89 3c 24             	mov    %edi,(%esp)
  8010b8:	e8 57 09 00 00       	call   801a14 <memmove>
		sys_cputs(buf, m);
  8010bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c1:	89 3c 24             	mov    %edi,(%esp)
  8010c4:	e8 e7 ef ff ff       	call   8000b0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010c9:	01 f3                	add    %esi,%ebx
  8010cb:	89 d8                	mov    %ebx,%eax
  8010cd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010d0:	72 c9                	jb     80109b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8010d2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8010e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010e7:	75 07                	jne    8010f0 <devcons_read+0x13>
  8010e9:	eb 25                	jmp    801110 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8010eb:	e8 6e f0 ff ff       	call   80015e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8010f0:	e8 d9 ef ff ff       	call   8000ce <sys_cgetc>
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	74 f2                	je     8010eb <devcons_read+0xe>
  8010f9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	78 1d                	js     80111c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8010ff:	83 f8 04             	cmp    $0x4,%eax
  801102:	74 13                	je     801117 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801104:	8b 45 0c             	mov    0xc(%ebp),%eax
  801107:	88 10                	mov    %dl,(%eax)
	return 1;
  801109:	b8 01 00 00 00       	mov    $0x1,%eax
  80110e:	eb 0c                	jmp    80111c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801110:	b8 00 00 00 00       	mov    $0x0,%eax
  801115:	eb 05                	jmp    80111c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801117:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80111c:	c9                   	leave  
  80111d:	c3                   	ret    

0080111e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801124:	8b 45 08             	mov    0x8(%ebp),%eax
  801127:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80112a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801131:	00 
  801132:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801135:	89 04 24             	mov    %eax,(%esp)
  801138:	e8 73 ef ff ff       	call   8000b0 <sys_cputs>
}
  80113d:	c9                   	leave  
  80113e:	c3                   	ret    

0080113f <getchar>:

int
getchar(void)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801145:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80114c:	00 
  80114d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801150:	89 44 24 04          	mov    %eax,0x4(%esp)
  801154:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80115b:	e8 a4 f5 ff ff       	call   800704 <read>
	if (r < 0)
  801160:	85 c0                	test   %eax,%eax
  801162:	78 0f                	js     801173 <getchar+0x34>
		return r;
	if (r < 1)
  801164:	85 c0                	test   %eax,%eax
  801166:	7e 06                	jle    80116e <getchar+0x2f>
		return -E_EOF;
	return c;
  801168:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80116c:	eb 05                	jmp    801173 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80116e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801173:	c9                   	leave  
  801174:	c3                   	ret    

00801175 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80117b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801182:	8b 45 08             	mov    0x8(%ebp),%eax
  801185:	89 04 24             	mov    %eax,(%esp)
  801188:	e8 d9 f2 ff ff       	call   800466 <fd_lookup>
  80118d:	85 c0                	test   %eax,%eax
  80118f:	78 11                	js     8011a2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801191:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801194:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80119a:	39 10                	cmp    %edx,(%eax)
  80119c:	0f 94 c0             	sete   %al
  80119f:	0f b6 c0             	movzbl %al,%eax
}
  8011a2:	c9                   	leave  
  8011a3:	c3                   	ret    

008011a4 <opencons>:

int
opencons(void)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8011aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ad:	89 04 24             	mov    %eax,(%esp)
  8011b0:	e8 5e f2 ff ff       	call   800413 <fd_alloc>
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	78 3c                	js     8011f5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8011b9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8011c0:	00 
  8011c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011cf:	e8 a9 ef ff ff       	call   80017d <sys_page_alloc>
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 1d                	js     8011f5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8011d8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8011de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8011e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8011ed:	89 04 24             	mov    %eax,(%esp)
  8011f0:	e8 f3 f1 ff ff       	call   8003e8 <fd2num>
}
  8011f5:	c9                   	leave  
  8011f6:	c3                   	ret    
	...

008011f8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	56                   	push   %esi
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801200:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801203:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801209:	e8 31 ef ff ff       	call   80013f <sys_getenvid>
  80120e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801211:	89 54 24 10          	mov    %edx,0x10(%esp)
  801215:	8b 55 08             	mov    0x8(%ebp),%edx
  801218:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80121c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801220:	89 44 24 04          	mov    %eax,0x4(%esp)
  801224:	c7 04 24 a4 20 80 00 	movl   $0x8020a4,(%esp)
  80122b:	e8 c0 00 00 00       	call   8012f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801230:	89 74 24 04          	mov    %esi,0x4(%esp)
  801234:	8b 45 10             	mov    0x10(%ebp),%eax
  801237:	89 04 24             	mov    %eax,(%esp)
  80123a:	e8 50 00 00 00       	call   80128f <vcprintf>
	cprintf("\n");
  80123f:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  801246:	e8 a5 00 00 00       	call   8012f0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80124b:	cc                   	int3   
  80124c:	eb fd                	jmp    80124b <_panic+0x53>
	...

00801250 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	53                   	push   %ebx
  801254:	83 ec 14             	sub    $0x14,%esp
  801257:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80125a:	8b 03                	mov    (%ebx),%eax
  80125c:	8b 55 08             	mov    0x8(%ebp),%edx
  80125f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801263:	40                   	inc    %eax
  801264:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801266:	3d ff 00 00 00       	cmp    $0xff,%eax
  80126b:	75 19                	jne    801286 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80126d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801274:	00 
  801275:	8d 43 08             	lea    0x8(%ebx),%eax
  801278:	89 04 24             	mov    %eax,(%esp)
  80127b:	e8 30 ee ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  801280:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801286:	ff 43 04             	incl   0x4(%ebx)
}
  801289:	83 c4 14             	add    $0x14,%esp
  80128c:	5b                   	pop    %ebx
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801298:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80129f:	00 00 00 
	b.cnt = 0;
  8012a2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8012a9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8012ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8012c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c4:	c7 04 24 50 12 80 00 	movl   $0x801250,(%esp)
  8012cb:	e8 82 01 00 00       	call   801452 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8012d0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8012d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8012e0:	89 04 24             	mov    %eax,(%esp)
  8012e3:	e8 c8 ed ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  8012e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8012ee:	c9                   	leave  
  8012ef:	c3                   	ret    

008012f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8012f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8012f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801300:	89 04 24             	mov    %eax,(%esp)
  801303:	e8 87 ff ff ff       	call   80128f <vcprintf>
	va_end(ap);

	return cnt;
}
  801308:	c9                   	leave  
  801309:	c3                   	ret    
	...

0080130c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	57                   	push   %edi
  801310:	56                   	push   %esi
  801311:	53                   	push   %ebx
  801312:	83 ec 3c             	sub    $0x3c,%esp
  801315:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801318:	89 d7                	mov    %edx,%edi
  80131a:	8b 45 08             	mov    0x8(%ebp),%eax
  80131d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801320:	8b 45 0c             	mov    0xc(%ebp),%eax
  801323:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801326:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801329:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80132c:	85 c0                	test   %eax,%eax
  80132e:	75 08                	jne    801338 <printnum+0x2c>
  801330:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801333:	39 45 10             	cmp    %eax,0x10(%ebp)
  801336:	77 57                	ja     80138f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801338:	89 74 24 10          	mov    %esi,0x10(%esp)
  80133c:	4b                   	dec    %ebx
  80133d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801341:	8b 45 10             	mov    0x10(%ebp),%eax
  801344:	89 44 24 08          	mov    %eax,0x8(%esp)
  801348:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80134c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801350:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801357:	00 
  801358:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80135b:	89 04 24             	mov    %eax,(%esp)
  80135e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801361:	89 44 24 04          	mov    %eax,0x4(%esp)
  801365:	e8 b2 09 00 00       	call   801d1c <__udivdi3>
  80136a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80136e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801372:	89 04 24             	mov    %eax,(%esp)
  801375:	89 54 24 04          	mov    %edx,0x4(%esp)
  801379:	89 fa                	mov    %edi,%edx
  80137b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80137e:	e8 89 ff ff ff       	call   80130c <printnum>
  801383:	eb 0f                	jmp    801394 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801385:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801389:	89 34 24             	mov    %esi,(%esp)
  80138c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80138f:	4b                   	dec    %ebx
  801390:	85 db                	test   %ebx,%ebx
  801392:	7f f1                	jg     801385 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801394:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801398:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80139c:	8b 45 10             	mov    0x10(%ebp),%eax
  80139f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013aa:	00 
  8013ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013ae:	89 04 24             	mov    %eax,(%esp)
  8013b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b8:	e8 7f 0a 00 00       	call   801e3c <__umoddi3>
  8013bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013c1:	0f be 80 c7 20 80 00 	movsbl 0x8020c7(%eax),%eax
  8013c8:	89 04 24             	mov    %eax,(%esp)
  8013cb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8013ce:	83 c4 3c             	add    $0x3c,%esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5e                   	pop    %esi
  8013d3:	5f                   	pop    %edi
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    

008013d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8013d9:	83 fa 01             	cmp    $0x1,%edx
  8013dc:	7e 0e                	jle    8013ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8013de:	8b 10                	mov    (%eax),%edx
  8013e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8013e3:	89 08                	mov    %ecx,(%eax)
  8013e5:	8b 02                	mov    (%edx),%eax
  8013e7:	8b 52 04             	mov    0x4(%edx),%edx
  8013ea:	eb 22                	jmp    80140e <getuint+0x38>
	else if (lflag)
  8013ec:	85 d2                	test   %edx,%edx
  8013ee:	74 10                	je     801400 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8013f0:	8b 10                	mov    (%eax),%edx
  8013f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013f5:	89 08                	mov    %ecx,(%eax)
  8013f7:	8b 02                	mov    (%edx),%eax
  8013f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fe:	eb 0e                	jmp    80140e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801400:	8b 10                	mov    (%eax),%edx
  801402:	8d 4a 04             	lea    0x4(%edx),%ecx
  801405:	89 08                	mov    %ecx,(%eax)
  801407:	8b 02                	mov    (%edx),%eax
  801409:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80140e:	5d                   	pop    %ebp
  80140f:	c3                   	ret    

00801410 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801416:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801419:	8b 10                	mov    (%eax),%edx
  80141b:	3b 50 04             	cmp    0x4(%eax),%edx
  80141e:	73 08                	jae    801428 <sprintputch+0x18>
		*b->buf++ = ch;
  801420:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801423:	88 0a                	mov    %cl,(%edx)
  801425:	42                   	inc    %edx
  801426:	89 10                	mov    %edx,(%eax)
}
  801428:	5d                   	pop    %ebp
  801429:	c3                   	ret    

0080142a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801430:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801433:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801437:	8b 45 10             	mov    0x10(%ebp),%eax
  80143a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80143e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801441:	89 44 24 04          	mov    %eax,0x4(%esp)
  801445:	8b 45 08             	mov    0x8(%ebp),%eax
  801448:	89 04 24             	mov    %eax,(%esp)
  80144b:	e8 02 00 00 00       	call   801452 <vprintfmt>
	va_end(ap);
}
  801450:	c9                   	leave  
  801451:	c3                   	ret    

00801452 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	57                   	push   %edi
  801456:	56                   	push   %esi
  801457:	53                   	push   %ebx
  801458:	83 ec 4c             	sub    $0x4c,%esp
  80145b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80145e:	8b 75 10             	mov    0x10(%ebp),%esi
  801461:	eb 12                	jmp    801475 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801463:	85 c0                	test   %eax,%eax
  801465:	0f 84 6b 03 00 00    	je     8017d6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80146b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80146f:	89 04 24             	mov    %eax,(%esp)
  801472:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801475:	0f b6 06             	movzbl (%esi),%eax
  801478:	46                   	inc    %esi
  801479:	83 f8 25             	cmp    $0x25,%eax
  80147c:	75 e5                	jne    801463 <vprintfmt+0x11>
  80147e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801482:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801489:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80148e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801495:	b9 00 00 00 00       	mov    $0x0,%ecx
  80149a:	eb 26                	jmp    8014c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80149c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80149f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8014a3:	eb 1d                	jmp    8014c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8014a8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8014ac:	eb 14                	jmp    8014c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8014b1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8014b8:	eb 08                	jmp    8014c2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8014ba:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8014bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014c2:	0f b6 06             	movzbl (%esi),%eax
  8014c5:	8d 56 01             	lea    0x1(%esi),%edx
  8014c8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8014cb:	8a 16                	mov    (%esi),%dl
  8014cd:	83 ea 23             	sub    $0x23,%edx
  8014d0:	80 fa 55             	cmp    $0x55,%dl
  8014d3:	0f 87 e1 02 00 00    	ja     8017ba <vprintfmt+0x368>
  8014d9:	0f b6 d2             	movzbl %dl,%edx
  8014dc:	ff 24 95 00 22 80 00 	jmp    *0x802200(,%edx,4)
  8014e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8014e6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8014eb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8014ee:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8014f2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8014f5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8014f8:	83 fa 09             	cmp    $0x9,%edx
  8014fb:	77 2a                	ja     801527 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8014fd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8014fe:	eb eb                	jmp    8014eb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801500:	8b 45 14             	mov    0x14(%ebp),%eax
  801503:	8d 50 04             	lea    0x4(%eax),%edx
  801506:	89 55 14             	mov    %edx,0x14(%ebp)
  801509:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80150b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80150e:	eb 17                	jmp    801527 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801510:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801514:	78 98                	js     8014ae <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801516:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801519:	eb a7                	jmp    8014c2 <vprintfmt+0x70>
  80151b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80151e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801525:	eb 9b                	jmp    8014c2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801527:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80152b:	79 95                	jns    8014c2 <vprintfmt+0x70>
  80152d:	eb 8b                	jmp    8014ba <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80152f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801530:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801533:	eb 8d                	jmp    8014c2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801535:	8b 45 14             	mov    0x14(%ebp),%eax
  801538:	8d 50 04             	lea    0x4(%eax),%edx
  80153b:	89 55 14             	mov    %edx,0x14(%ebp)
  80153e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801542:	8b 00                	mov    (%eax),%eax
  801544:	89 04 24             	mov    %eax,(%esp)
  801547:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80154a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80154d:	e9 23 ff ff ff       	jmp    801475 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801552:	8b 45 14             	mov    0x14(%ebp),%eax
  801555:	8d 50 04             	lea    0x4(%eax),%edx
  801558:	89 55 14             	mov    %edx,0x14(%ebp)
  80155b:	8b 00                	mov    (%eax),%eax
  80155d:	85 c0                	test   %eax,%eax
  80155f:	79 02                	jns    801563 <vprintfmt+0x111>
  801561:	f7 d8                	neg    %eax
  801563:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801565:	83 f8 0f             	cmp    $0xf,%eax
  801568:	7f 0b                	jg     801575 <vprintfmt+0x123>
  80156a:	8b 04 85 60 23 80 00 	mov    0x802360(,%eax,4),%eax
  801571:	85 c0                	test   %eax,%eax
  801573:	75 23                	jne    801598 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801575:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801579:	c7 44 24 08 df 20 80 	movl   $0x8020df,0x8(%esp)
  801580:	00 
  801581:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801585:	8b 45 08             	mov    0x8(%ebp),%eax
  801588:	89 04 24             	mov    %eax,(%esp)
  80158b:	e8 9a fe ff ff       	call   80142a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801590:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801593:	e9 dd fe ff ff       	jmp    801475 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801598:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80159c:	c7 44 24 08 5d 20 80 	movl   $0x80205d,0x8(%esp)
  8015a3:	00 
  8015a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ab:	89 14 24             	mov    %edx,(%esp)
  8015ae:	e8 77 fe ff ff       	call   80142a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8015b6:	e9 ba fe ff ff       	jmp    801475 <vprintfmt+0x23>
  8015bb:	89 f9                	mov    %edi,%ecx
  8015bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8015c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c6:	8d 50 04             	lea    0x4(%eax),%edx
  8015c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8015cc:	8b 30                	mov    (%eax),%esi
  8015ce:	85 f6                	test   %esi,%esi
  8015d0:	75 05                	jne    8015d7 <vprintfmt+0x185>
				p = "(null)";
  8015d2:	be d8 20 80 00       	mov    $0x8020d8,%esi
			if (width > 0 && padc != '-')
  8015d7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8015db:	0f 8e 84 00 00 00    	jle    801665 <vprintfmt+0x213>
  8015e1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8015e5:	74 7e                	je     801665 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8015e7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015eb:	89 34 24             	mov    %esi,(%esp)
  8015ee:	e8 8b 02 00 00       	call   80187e <strnlen>
  8015f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8015f6:	29 c2                	sub    %eax,%edx
  8015f8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8015fb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8015ff:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801602:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801605:	89 de                	mov    %ebx,%esi
  801607:	89 d3                	mov    %edx,%ebx
  801609:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80160b:	eb 0b                	jmp    801618 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80160d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801611:	89 3c 24             	mov    %edi,(%esp)
  801614:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801617:	4b                   	dec    %ebx
  801618:	85 db                	test   %ebx,%ebx
  80161a:	7f f1                	jg     80160d <vprintfmt+0x1bb>
  80161c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80161f:	89 f3                	mov    %esi,%ebx
  801621:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801624:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801627:	85 c0                	test   %eax,%eax
  801629:	79 05                	jns    801630 <vprintfmt+0x1de>
  80162b:	b8 00 00 00 00       	mov    $0x0,%eax
  801630:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801633:	29 c2                	sub    %eax,%edx
  801635:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801638:	eb 2b                	jmp    801665 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80163a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80163e:	74 18                	je     801658 <vprintfmt+0x206>
  801640:	8d 50 e0             	lea    -0x20(%eax),%edx
  801643:	83 fa 5e             	cmp    $0x5e,%edx
  801646:	76 10                	jbe    801658 <vprintfmt+0x206>
					putch('?', putdat);
  801648:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80164c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801653:	ff 55 08             	call   *0x8(%ebp)
  801656:	eb 0a                	jmp    801662 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80165c:	89 04 24             	mov    %eax,(%esp)
  80165f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801662:	ff 4d e4             	decl   -0x1c(%ebp)
  801665:	0f be 06             	movsbl (%esi),%eax
  801668:	46                   	inc    %esi
  801669:	85 c0                	test   %eax,%eax
  80166b:	74 21                	je     80168e <vprintfmt+0x23c>
  80166d:	85 ff                	test   %edi,%edi
  80166f:	78 c9                	js     80163a <vprintfmt+0x1e8>
  801671:	4f                   	dec    %edi
  801672:	79 c6                	jns    80163a <vprintfmt+0x1e8>
  801674:	8b 7d 08             	mov    0x8(%ebp),%edi
  801677:	89 de                	mov    %ebx,%esi
  801679:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80167c:	eb 18                	jmp    801696 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80167e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801682:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801689:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80168b:	4b                   	dec    %ebx
  80168c:	eb 08                	jmp    801696 <vprintfmt+0x244>
  80168e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801691:	89 de                	mov    %ebx,%esi
  801693:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801696:	85 db                	test   %ebx,%ebx
  801698:	7f e4                	jg     80167e <vprintfmt+0x22c>
  80169a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80169d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80169f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8016a2:	e9 ce fd ff ff       	jmp    801475 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8016a7:	83 f9 01             	cmp    $0x1,%ecx
  8016aa:	7e 10                	jle    8016bc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8016ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8016af:	8d 50 08             	lea    0x8(%eax),%edx
  8016b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8016b5:	8b 30                	mov    (%eax),%esi
  8016b7:	8b 78 04             	mov    0x4(%eax),%edi
  8016ba:	eb 26                	jmp    8016e2 <vprintfmt+0x290>
	else if (lflag)
  8016bc:	85 c9                	test   %ecx,%ecx
  8016be:	74 12                	je     8016d2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8016c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c3:	8d 50 04             	lea    0x4(%eax),%edx
  8016c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8016c9:	8b 30                	mov    (%eax),%esi
  8016cb:	89 f7                	mov    %esi,%edi
  8016cd:	c1 ff 1f             	sar    $0x1f,%edi
  8016d0:	eb 10                	jmp    8016e2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8016d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d5:	8d 50 04             	lea    0x4(%eax),%edx
  8016d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8016db:	8b 30                	mov    (%eax),%esi
  8016dd:	89 f7                	mov    %esi,%edi
  8016df:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8016e2:	85 ff                	test   %edi,%edi
  8016e4:	78 0a                	js     8016f0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8016e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016eb:	e9 8c 00 00 00       	jmp    80177c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8016f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016f4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8016fb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8016fe:	f7 de                	neg    %esi
  801700:	83 d7 00             	adc    $0x0,%edi
  801703:	f7 df                	neg    %edi
			}
			base = 10;
  801705:	b8 0a 00 00 00       	mov    $0xa,%eax
  80170a:	eb 70                	jmp    80177c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80170c:	89 ca                	mov    %ecx,%edx
  80170e:	8d 45 14             	lea    0x14(%ebp),%eax
  801711:	e8 c0 fc ff ff       	call   8013d6 <getuint>
  801716:	89 c6                	mov    %eax,%esi
  801718:	89 d7                	mov    %edx,%edi
			base = 10;
  80171a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80171f:	eb 5b                	jmp    80177c <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801721:	89 ca                	mov    %ecx,%edx
  801723:	8d 45 14             	lea    0x14(%ebp),%eax
  801726:	e8 ab fc ff ff       	call   8013d6 <getuint>
  80172b:	89 c6                	mov    %eax,%esi
  80172d:	89 d7                	mov    %edx,%edi
			base = 8;
  80172f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801734:	eb 46                	jmp    80177c <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  801736:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80173a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801741:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801744:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801748:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80174f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801752:	8b 45 14             	mov    0x14(%ebp),%eax
  801755:	8d 50 04             	lea    0x4(%eax),%edx
  801758:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80175b:	8b 30                	mov    (%eax),%esi
  80175d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801762:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801767:	eb 13                	jmp    80177c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801769:	89 ca                	mov    %ecx,%edx
  80176b:	8d 45 14             	lea    0x14(%ebp),%eax
  80176e:	e8 63 fc ff ff       	call   8013d6 <getuint>
  801773:	89 c6                	mov    %eax,%esi
  801775:	89 d7                	mov    %edx,%edi
			base = 16;
  801777:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80177c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801780:	89 54 24 10          	mov    %edx,0x10(%esp)
  801784:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801787:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80178b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80178f:	89 34 24             	mov    %esi,(%esp)
  801792:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801796:	89 da                	mov    %ebx,%edx
  801798:	8b 45 08             	mov    0x8(%ebp),%eax
  80179b:	e8 6c fb ff ff       	call   80130c <printnum>
			break;
  8017a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8017a3:	e9 cd fc ff ff       	jmp    801475 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8017a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017ac:	89 04 24             	mov    %eax,(%esp)
  8017af:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8017b5:	e9 bb fc ff ff       	jmp    801475 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8017ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017be:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017c5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017c8:	eb 01                	jmp    8017cb <vprintfmt+0x379>
  8017ca:	4e                   	dec    %esi
  8017cb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8017cf:	75 f9                	jne    8017ca <vprintfmt+0x378>
  8017d1:	e9 9f fc ff ff       	jmp    801475 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8017d6:	83 c4 4c             	add    $0x4c,%esp
  8017d9:	5b                   	pop    %ebx
  8017da:	5e                   	pop    %esi
  8017db:	5f                   	pop    %edi
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	83 ec 28             	sub    $0x28,%esp
  8017e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8017ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8017ed:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8017f1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8017f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	74 30                	je     80182f <vsnprintf+0x51>
  8017ff:	85 d2                	test   %edx,%edx
  801801:	7e 33                	jle    801836 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801803:	8b 45 14             	mov    0x14(%ebp),%eax
  801806:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80180a:	8b 45 10             	mov    0x10(%ebp),%eax
  80180d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801811:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801814:	89 44 24 04          	mov    %eax,0x4(%esp)
  801818:	c7 04 24 10 14 80 00 	movl   $0x801410,(%esp)
  80181f:	e8 2e fc ff ff       	call   801452 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801824:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801827:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80182a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182d:	eb 0c                	jmp    80183b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80182f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801834:	eb 05                	jmp    80183b <vsnprintf+0x5d>
  801836:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80183b:	c9                   	leave  
  80183c:	c3                   	ret    

0080183d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801843:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801846:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80184a:	8b 45 10             	mov    0x10(%ebp),%eax
  80184d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801851:	8b 45 0c             	mov    0xc(%ebp),%eax
  801854:	89 44 24 04          	mov    %eax,0x4(%esp)
  801858:	8b 45 08             	mov    0x8(%ebp),%eax
  80185b:	89 04 24             	mov    %eax,(%esp)
  80185e:	e8 7b ff ff ff       	call   8017de <vsnprintf>
	va_end(ap);

	return rc;
}
  801863:	c9                   	leave  
  801864:	c3                   	ret    
  801865:	00 00                	add    %al,(%eax)
	...

00801868 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80186e:	b8 00 00 00 00       	mov    $0x0,%eax
  801873:	eb 01                	jmp    801876 <strlen+0xe>
		n++;
  801875:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801876:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80187a:	75 f9                	jne    801875 <strlen+0xd>
		n++;
	return n;
}
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801884:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801887:	b8 00 00 00 00       	mov    $0x0,%eax
  80188c:	eb 01                	jmp    80188f <strnlen+0x11>
		n++;
  80188e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80188f:	39 d0                	cmp    %edx,%eax
  801891:	74 06                	je     801899 <strnlen+0x1b>
  801893:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801897:	75 f5                	jne    80188e <strnlen+0x10>
		n++;
	return n;
}
  801899:	5d                   	pop    %ebp
  80189a:	c3                   	ret    

0080189b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80189b:	55                   	push   %ebp
  80189c:	89 e5                	mov    %esp,%ebp
  80189e:	53                   	push   %ebx
  80189f:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8018a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018aa:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8018ad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8018b0:	42                   	inc    %edx
  8018b1:	84 c9                	test   %cl,%cl
  8018b3:	75 f5                	jne    8018aa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8018b5:	5b                   	pop    %ebx
  8018b6:	5d                   	pop    %ebp
  8018b7:	c3                   	ret    

008018b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	53                   	push   %ebx
  8018bc:	83 ec 08             	sub    $0x8,%esp
  8018bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8018c2:	89 1c 24             	mov    %ebx,(%esp)
  8018c5:	e8 9e ff ff ff       	call   801868 <strlen>
	strcpy(dst + len, src);
  8018ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018d1:	01 d8                	add    %ebx,%eax
  8018d3:	89 04 24             	mov    %eax,(%esp)
  8018d6:	e8 c0 ff ff ff       	call   80189b <strcpy>
	return dst;
}
  8018db:	89 d8                	mov    %ebx,%eax
  8018dd:	83 c4 08             	add    $0x8,%esp
  8018e0:	5b                   	pop    %ebx
  8018e1:	5d                   	pop    %ebp
  8018e2:	c3                   	ret    

008018e3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	56                   	push   %esi
  8018e7:	53                   	push   %ebx
  8018e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ee:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8018f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018f6:	eb 0c                	jmp    801904 <strncpy+0x21>
		*dst++ = *src;
  8018f8:	8a 1a                	mov    (%edx),%bl
  8018fa:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8018fd:	80 3a 01             	cmpb   $0x1,(%edx)
  801900:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801903:	41                   	inc    %ecx
  801904:	39 f1                	cmp    %esi,%ecx
  801906:	75 f0                	jne    8018f8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801908:	5b                   	pop    %ebx
  801909:	5e                   	pop    %esi
  80190a:	5d                   	pop    %ebp
  80190b:	c3                   	ret    

0080190c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	56                   	push   %esi
  801910:	53                   	push   %ebx
  801911:	8b 75 08             	mov    0x8(%ebp),%esi
  801914:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801917:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80191a:	85 d2                	test   %edx,%edx
  80191c:	75 0a                	jne    801928 <strlcpy+0x1c>
  80191e:	89 f0                	mov    %esi,%eax
  801920:	eb 1a                	jmp    80193c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801922:	88 18                	mov    %bl,(%eax)
  801924:	40                   	inc    %eax
  801925:	41                   	inc    %ecx
  801926:	eb 02                	jmp    80192a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801928:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80192a:	4a                   	dec    %edx
  80192b:	74 0a                	je     801937 <strlcpy+0x2b>
  80192d:	8a 19                	mov    (%ecx),%bl
  80192f:	84 db                	test   %bl,%bl
  801931:	75 ef                	jne    801922 <strlcpy+0x16>
  801933:	89 c2                	mov    %eax,%edx
  801935:	eb 02                	jmp    801939 <strlcpy+0x2d>
  801937:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801939:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80193c:	29 f0                	sub    %esi,%eax
}
  80193e:	5b                   	pop    %ebx
  80193f:	5e                   	pop    %esi
  801940:	5d                   	pop    %ebp
  801941:	c3                   	ret    

00801942 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801948:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80194b:	eb 02                	jmp    80194f <strcmp+0xd>
		p++, q++;
  80194d:	41                   	inc    %ecx
  80194e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80194f:	8a 01                	mov    (%ecx),%al
  801951:	84 c0                	test   %al,%al
  801953:	74 04                	je     801959 <strcmp+0x17>
  801955:	3a 02                	cmp    (%edx),%al
  801957:	74 f4                	je     80194d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801959:	0f b6 c0             	movzbl %al,%eax
  80195c:	0f b6 12             	movzbl (%edx),%edx
  80195f:	29 d0                	sub    %edx,%eax
}
  801961:	5d                   	pop    %ebp
  801962:	c3                   	ret    

00801963 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	53                   	push   %ebx
  801967:	8b 45 08             	mov    0x8(%ebp),%eax
  80196a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80196d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801970:	eb 03                	jmp    801975 <strncmp+0x12>
		n--, p++, q++;
  801972:	4a                   	dec    %edx
  801973:	40                   	inc    %eax
  801974:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801975:	85 d2                	test   %edx,%edx
  801977:	74 14                	je     80198d <strncmp+0x2a>
  801979:	8a 18                	mov    (%eax),%bl
  80197b:	84 db                	test   %bl,%bl
  80197d:	74 04                	je     801983 <strncmp+0x20>
  80197f:	3a 19                	cmp    (%ecx),%bl
  801981:	74 ef                	je     801972 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801983:	0f b6 00             	movzbl (%eax),%eax
  801986:	0f b6 11             	movzbl (%ecx),%edx
  801989:	29 d0                	sub    %edx,%eax
  80198b:	eb 05                	jmp    801992 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80198d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801992:	5b                   	pop    %ebx
  801993:	5d                   	pop    %ebp
  801994:	c3                   	ret    

00801995 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	8b 45 08             	mov    0x8(%ebp),%eax
  80199b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80199e:	eb 05                	jmp    8019a5 <strchr+0x10>
		if (*s == c)
  8019a0:	38 ca                	cmp    %cl,%dl
  8019a2:	74 0c                	je     8019b0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8019a4:	40                   	inc    %eax
  8019a5:	8a 10                	mov    (%eax),%dl
  8019a7:	84 d2                	test   %dl,%dl
  8019a9:	75 f5                	jne    8019a0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8019ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b0:	5d                   	pop    %ebp
  8019b1:	c3                   	ret    

008019b2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8019bb:	eb 05                	jmp    8019c2 <strfind+0x10>
		if (*s == c)
  8019bd:	38 ca                	cmp    %cl,%dl
  8019bf:	74 07                	je     8019c8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8019c1:	40                   	inc    %eax
  8019c2:	8a 10                	mov    (%eax),%dl
  8019c4:	84 d2                	test   %dl,%dl
  8019c6:	75 f5                	jne    8019bd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8019c8:	5d                   	pop    %ebp
  8019c9:	c3                   	ret    

008019ca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	57                   	push   %edi
  8019ce:	56                   	push   %esi
  8019cf:	53                   	push   %ebx
  8019d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8019d9:	85 c9                	test   %ecx,%ecx
  8019db:	74 30                	je     801a0d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8019dd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019e3:	75 25                	jne    801a0a <memset+0x40>
  8019e5:	f6 c1 03             	test   $0x3,%cl
  8019e8:	75 20                	jne    801a0a <memset+0x40>
		c &= 0xFF;
  8019ea:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8019ed:	89 d3                	mov    %edx,%ebx
  8019ef:	c1 e3 08             	shl    $0x8,%ebx
  8019f2:	89 d6                	mov    %edx,%esi
  8019f4:	c1 e6 18             	shl    $0x18,%esi
  8019f7:	89 d0                	mov    %edx,%eax
  8019f9:	c1 e0 10             	shl    $0x10,%eax
  8019fc:	09 f0                	or     %esi,%eax
  8019fe:	09 d0                	or     %edx,%eax
  801a00:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801a02:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801a05:	fc                   	cld    
  801a06:	f3 ab                	rep stos %eax,%es:(%edi)
  801a08:	eb 03                	jmp    801a0d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801a0a:	fc                   	cld    
  801a0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801a0d:	89 f8                	mov    %edi,%eax
  801a0f:	5b                   	pop    %ebx
  801a10:	5e                   	pop    %esi
  801a11:	5f                   	pop    %edi
  801a12:	5d                   	pop    %ebp
  801a13:	c3                   	ret    

00801a14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	57                   	push   %edi
  801a18:	56                   	push   %esi
  801a19:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801a22:	39 c6                	cmp    %eax,%esi
  801a24:	73 34                	jae    801a5a <memmove+0x46>
  801a26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a29:	39 d0                	cmp    %edx,%eax
  801a2b:	73 2d                	jae    801a5a <memmove+0x46>
		s += n;
		d += n;
  801a2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a30:	f6 c2 03             	test   $0x3,%dl
  801a33:	75 1b                	jne    801a50 <memmove+0x3c>
  801a35:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801a3b:	75 13                	jne    801a50 <memmove+0x3c>
  801a3d:	f6 c1 03             	test   $0x3,%cl
  801a40:	75 0e                	jne    801a50 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a42:	83 ef 04             	sub    $0x4,%edi
  801a45:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a48:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801a4b:	fd                   	std    
  801a4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a4e:	eb 07                	jmp    801a57 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a50:	4f                   	dec    %edi
  801a51:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801a54:	fd                   	std    
  801a55:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a57:	fc                   	cld    
  801a58:	eb 20                	jmp    801a7a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a5a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a60:	75 13                	jne    801a75 <memmove+0x61>
  801a62:	a8 03                	test   $0x3,%al
  801a64:	75 0f                	jne    801a75 <memmove+0x61>
  801a66:	f6 c1 03             	test   $0x3,%cl
  801a69:	75 0a                	jne    801a75 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a6b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801a6e:	89 c7                	mov    %eax,%edi
  801a70:	fc                   	cld    
  801a71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a73:	eb 05                	jmp    801a7a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801a75:	89 c7                	mov    %eax,%edi
  801a77:	fc                   	cld    
  801a78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a7a:	5e                   	pop    %esi
  801a7b:	5f                   	pop    %edi
  801a7c:	5d                   	pop    %ebp
  801a7d:	c3                   	ret    

00801a7e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a84:	8b 45 10             	mov    0x10(%ebp),%eax
  801a87:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a92:	8b 45 08             	mov    0x8(%ebp),%eax
  801a95:	89 04 24             	mov    %eax,(%esp)
  801a98:	e8 77 ff ff ff       	call   801a14 <memmove>
}
  801a9d:	c9                   	leave  
  801a9e:	c3                   	ret    

00801a9f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	57                   	push   %edi
  801aa3:	56                   	push   %esi
  801aa4:	53                   	push   %ebx
  801aa5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aa8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801aae:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab3:	eb 16                	jmp    801acb <memcmp+0x2c>
		if (*s1 != *s2)
  801ab5:	8a 04 17             	mov    (%edi,%edx,1),%al
  801ab8:	42                   	inc    %edx
  801ab9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801abd:	38 c8                	cmp    %cl,%al
  801abf:	74 0a                	je     801acb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801ac1:	0f b6 c0             	movzbl %al,%eax
  801ac4:	0f b6 c9             	movzbl %cl,%ecx
  801ac7:	29 c8                	sub    %ecx,%eax
  801ac9:	eb 09                	jmp    801ad4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801acb:	39 da                	cmp    %ebx,%edx
  801acd:	75 e6                	jne    801ab5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ad4:	5b                   	pop    %ebx
  801ad5:	5e                   	pop    %esi
  801ad6:	5f                   	pop    %edi
  801ad7:	5d                   	pop    %ebp
  801ad8:	c3                   	ret    

00801ad9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	8b 45 08             	mov    0x8(%ebp),%eax
  801adf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801ae2:	89 c2                	mov    %eax,%edx
  801ae4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801ae7:	eb 05                	jmp    801aee <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ae9:	38 08                	cmp    %cl,(%eax)
  801aeb:	74 05                	je     801af2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801aed:	40                   	inc    %eax
  801aee:	39 d0                	cmp    %edx,%eax
  801af0:	72 f7                	jb     801ae9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801af2:	5d                   	pop    %ebp
  801af3:	c3                   	ret    

00801af4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	57                   	push   %edi
  801af8:	56                   	push   %esi
  801af9:	53                   	push   %ebx
  801afa:	8b 55 08             	mov    0x8(%ebp),%edx
  801afd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b00:	eb 01                	jmp    801b03 <strtol+0xf>
		s++;
  801b02:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b03:	8a 02                	mov    (%edx),%al
  801b05:	3c 20                	cmp    $0x20,%al
  801b07:	74 f9                	je     801b02 <strtol+0xe>
  801b09:	3c 09                	cmp    $0x9,%al
  801b0b:	74 f5                	je     801b02 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801b0d:	3c 2b                	cmp    $0x2b,%al
  801b0f:	75 08                	jne    801b19 <strtol+0x25>
		s++;
  801b11:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b12:	bf 00 00 00 00       	mov    $0x0,%edi
  801b17:	eb 13                	jmp    801b2c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801b19:	3c 2d                	cmp    $0x2d,%al
  801b1b:	75 0a                	jne    801b27 <strtol+0x33>
		s++, neg = 1;
  801b1d:	8d 52 01             	lea    0x1(%edx),%edx
  801b20:	bf 01 00 00 00       	mov    $0x1,%edi
  801b25:	eb 05                	jmp    801b2c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b2c:	85 db                	test   %ebx,%ebx
  801b2e:	74 05                	je     801b35 <strtol+0x41>
  801b30:	83 fb 10             	cmp    $0x10,%ebx
  801b33:	75 28                	jne    801b5d <strtol+0x69>
  801b35:	8a 02                	mov    (%edx),%al
  801b37:	3c 30                	cmp    $0x30,%al
  801b39:	75 10                	jne    801b4b <strtol+0x57>
  801b3b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b3f:	75 0a                	jne    801b4b <strtol+0x57>
		s += 2, base = 16;
  801b41:	83 c2 02             	add    $0x2,%edx
  801b44:	bb 10 00 00 00       	mov    $0x10,%ebx
  801b49:	eb 12                	jmp    801b5d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801b4b:	85 db                	test   %ebx,%ebx
  801b4d:	75 0e                	jne    801b5d <strtol+0x69>
  801b4f:	3c 30                	cmp    $0x30,%al
  801b51:	75 05                	jne    801b58 <strtol+0x64>
		s++, base = 8;
  801b53:	42                   	inc    %edx
  801b54:	b3 08                	mov    $0x8,%bl
  801b56:	eb 05                	jmp    801b5d <strtol+0x69>
	else if (base == 0)
		base = 10;
  801b58:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b62:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801b64:	8a 0a                	mov    (%edx),%cl
  801b66:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801b69:	80 fb 09             	cmp    $0x9,%bl
  801b6c:	77 08                	ja     801b76 <strtol+0x82>
			dig = *s - '0';
  801b6e:	0f be c9             	movsbl %cl,%ecx
  801b71:	83 e9 30             	sub    $0x30,%ecx
  801b74:	eb 1e                	jmp    801b94 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801b76:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801b79:	80 fb 19             	cmp    $0x19,%bl
  801b7c:	77 08                	ja     801b86 <strtol+0x92>
			dig = *s - 'a' + 10;
  801b7e:	0f be c9             	movsbl %cl,%ecx
  801b81:	83 e9 57             	sub    $0x57,%ecx
  801b84:	eb 0e                	jmp    801b94 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801b86:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801b89:	80 fb 19             	cmp    $0x19,%bl
  801b8c:	77 12                	ja     801ba0 <strtol+0xac>
			dig = *s - 'A' + 10;
  801b8e:	0f be c9             	movsbl %cl,%ecx
  801b91:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801b94:	39 f1                	cmp    %esi,%ecx
  801b96:	7d 0c                	jge    801ba4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801b98:	42                   	inc    %edx
  801b99:	0f af c6             	imul   %esi,%eax
  801b9c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801b9e:	eb c4                	jmp    801b64 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801ba0:	89 c1                	mov    %eax,%ecx
  801ba2:	eb 02                	jmp    801ba6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801ba4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801ba6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801baa:	74 05                	je     801bb1 <strtol+0xbd>
		*endptr = (char *) s;
  801bac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801baf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801bb1:	85 ff                	test   %edi,%edi
  801bb3:	74 04                	je     801bb9 <strtol+0xc5>
  801bb5:	89 c8                	mov    %ecx,%eax
  801bb7:	f7 d8                	neg    %eax
}
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5f                   	pop    %edi
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    
	...

00801bc0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	56                   	push   %esi
  801bc4:	53                   	push   %ebx
  801bc5:	83 ec 10             	sub    $0x10,%esp
  801bc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bce:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	75 05                	jne    801bda <ipc_recv+0x1a>
  801bd5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801bda:	89 04 24             	mov    %eax,(%esp)
  801bdd:	e8 b1 e7 ff ff       	call   800393 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801be2:	85 c0                	test   %eax,%eax
  801be4:	79 16                	jns    801bfc <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801be6:	85 db                	test   %ebx,%ebx
  801be8:	74 06                	je     801bf0 <ipc_recv+0x30>
  801bea:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801bf0:	85 f6                	test   %esi,%esi
  801bf2:	74 32                	je     801c26 <ipc_recv+0x66>
  801bf4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801bfa:	eb 2a                	jmp    801c26 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801bfc:	85 db                	test   %ebx,%ebx
  801bfe:	74 0c                	je     801c0c <ipc_recv+0x4c>
  801c00:	a1 04 40 80 00       	mov    0x804004,%eax
  801c05:	8b 00                	mov    (%eax),%eax
  801c07:	8b 40 74             	mov    0x74(%eax),%eax
  801c0a:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c0c:	85 f6                	test   %esi,%esi
  801c0e:	74 0c                	je     801c1c <ipc_recv+0x5c>
  801c10:	a1 04 40 80 00       	mov    0x804004,%eax
  801c15:	8b 00                	mov    (%eax),%eax
  801c17:	8b 40 78             	mov    0x78(%eax),%eax
  801c1a:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801c1c:	a1 04 40 80 00       	mov    0x804004,%eax
  801c21:	8b 00                	mov    (%eax),%eax
  801c23:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	5b                   	pop    %ebx
  801c2a:	5e                   	pop    %esi
  801c2b:	5d                   	pop    %ebp
  801c2c:	c3                   	ret    

00801c2d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	57                   	push   %edi
  801c31:	56                   	push   %esi
  801c32:	53                   	push   %ebx
  801c33:	83 ec 1c             	sub    $0x1c,%esp
  801c36:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c3c:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801c3f:	85 db                	test   %ebx,%ebx
  801c41:	75 05                	jne    801c48 <ipc_send+0x1b>
  801c43:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801c48:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c4c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c50:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c54:	8b 45 08             	mov    0x8(%ebp),%eax
  801c57:	89 04 24             	mov    %eax,(%esp)
  801c5a:	e8 11 e7 ff ff       	call   800370 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801c5f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c62:	75 07                	jne    801c6b <ipc_send+0x3e>
  801c64:	e8 f5 e4 ff ff       	call   80015e <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801c69:	eb dd                	jmp    801c48 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801c6b:	85 c0                	test   %eax,%eax
  801c6d:	79 1c                	jns    801c8b <ipc_send+0x5e>
  801c6f:	c7 44 24 08 c0 23 80 	movl   $0x8023c0,0x8(%esp)
  801c76:	00 
  801c77:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801c7e:	00 
  801c7f:	c7 04 24 d2 23 80 00 	movl   $0x8023d2,(%esp)
  801c86:	e8 6d f5 ff ff       	call   8011f8 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801c8b:	83 c4 1c             	add    $0x1c,%esp
  801c8e:	5b                   	pop    %ebx
  801c8f:	5e                   	pop    %esi
  801c90:	5f                   	pop    %edi
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	53                   	push   %ebx
  801c97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c9a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c9f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801ca6:	89 c2                	mov    %eax,%edx
  801ca8:	c1 e2 07             	shl    $0x7,%edx
  801cab:	29 ca                	sub    %ecx,%edx
  801cad:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cb3:	8b 52 50             	mov    0x50(%edx),%edx
  801cb6:	39 da                	cmp    %ebx,%edx
  801cb8:	75 0f                	jne    801cc9 <ipc_find_env+0x36>
			return envs[i].env_id;
  801cba:	c1 e0 07             	shl    $0x7,%eax
  801cbd:	29 c8                	sub    %ecx,%eax
  801cbf:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cc4:	8b 40 40             	mov    0x40(%eax),%eax
  801cc7:	eb 0c                	jmp    801cd5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cc9:	40                   	inc    %eax
  801cca:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ccf:	75 ce                	jne    801c9f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cd1:	66 b8 00 00          	mov    $0x0,%ax
}
  801cd5:	5b                   	pop    %ebx
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    

00801cd8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801cde:	89 c2                	mov    %eax,%edx
  801ce0:	c1 ea 16             	shr    $0x16,%edx
  801ce3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cea:	f6 c2 01             	test   $0x1,%dl
  801ced:	74 1e                	je     801d0d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cef:	c1 e8 0c             	shr    $0xc,%eax
  801cf2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cf9:	a8 01                	test   $0x1,%al
  801cfb:	74 17                	je     801d14 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801cfd:	c1 e8 0c             	shr    $0xc,%eax
  801d00:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d07:	ef 
  801d08:	0f b7 c0             	movzwl %ax,%eax
  801d0b:	eb 0c                	jmp    801d19 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d12:	eb 05                	jmp    801d19 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d14:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    
	...

00801d1c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d1c:	55                   	push   %ebp
  801d1d:	57                   	push   %edi
  801d1e:	56                   	push   %esi
  801d1f:	83 ec 10             	sub    $0x10,%esp
  801d22:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d26:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d2e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801d32:	89 cd                	mov    %ecx,%ebp
  801d34:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	75 2c                	jne    801d68 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801d3c:	39 f9                	cmp    %edi,%ecx
  801d3e:	77 68                	ja     801da8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d40:	85 c9                	test   %ecx,%ecx
  801d42:	75 0b                	jne    801d4f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d44:	b8 01 00 00 00       	mov    $0x1,%eax
  801d49:	31 d2                	xor    %edx,%edx
  801d4b:	f7 f1                	div    %ecx
  801d4d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d4f:	31 d2                	xor    %edx,%edx
  801d51:	89 f8                	mov    %edi,%eax
  801d53:	f7 f1                	div    %ecx
  801d55:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d57:	89 f0                	mov    %esi,%eax
  801d59:	f7 f1                	div    %ecx
  801d5b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d5d:	89 f0                	mov    %esi,%eax
  801d5f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d61:	83 c4 10             	add    $0x10,%esp
  801d64:	5e                   	pop    %esi
  801d65:	5f                   	pop    %edi
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d68:	39 f8                	cmp    %edi,%eax
  801d6a:	77 2c                	ja     801d98 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d6c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801d6f:	83 f6 1f             	xor    $0x1f,%esi
  801d72:	75 4c                	jne    801dc0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d74:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d76:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d7b:	72 0a                	jb     801d87 <__udivdi3+0x6b>
  801d7d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d81:	0f 87 ad 00 00 00    	ja     801e34 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d87:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d8c:	89 f0                	mov    %esi,%eax
  801d8e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d90:	83 c4 10             	add    $0x10,%esp
  801d93:	5e                   	pop    %esi
  801d94:	5f                   	pop    %edi
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    
  801d97:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d98:	31 ff                	xor    %edi,%edi
  801d9a:	31 f6                	xor    %esi,%esi
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
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801da8:	89 fa                	mov    %edi,%edx
  801daa:	89 f0                	mov    %esi,%eax
  801dac:	f7 f1                	div    %ecx
  801dae:	89 c6                	mov    %eax,%esi
  801db0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801db2:	89 f0                	mov    %esi,%eax
  801db4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801db6:	83 c4 10             	add    $0x10,%esp
  801db9:	5e                   	pop    %esi
  801dba:	5f                   	pop    %edi
  801dbb:	5d                   	pop    %ebp
  801dbc:	c3                   	ret    
  801dbd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801dc0:	89 f1                	mov    %esi,%ecx
  801dc2:	d3 e0                	shl    %cl,%eax
  801dc4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801dc8:	b8 20 00 00 00       	mov    $0x20,%eax
  801dcd:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801dcf:	89 ea                	mov    %ebp,%edx
  801dd1:	88 c1                	mov    %al,%cl
  801dd3:	d3 ea                	shr    %cl,%edx
  801dd5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801dd9:	09 ca                	or     %ecx,%edx
  801ddb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801ddf:	89 f1                	mov    %esi,%ecx
  801de1:	d3 e5                	shl    %cl,%ebp
  801de3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801de7:	89 fd                	mov    %edi,%ebp
  801de9:	88 c1                	mov    %al,%cl
  801deb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801ded:	89 fa                	mov    %edi,%edx
  801def:	89 f1                	mov    %esi,%ecx
  801df1:	d3 e2                	shl    %cl,%edx
  801df3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801df7:	88 c1                	mov    %al,%cl
  801df9:	d3 ef                	shr    %cl,%edi
  801dfb:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801dfd:	89 f8                	mov    %edi,%eax
  801dff:	89 ea                	mov    %ebp,%edx
  801e01:	f7 74 24 08          	divl   0x8(%esp)
  801e05:	89 d1                	mov    %edx,%ecx
  801e07:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801e09:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e0d:	39 d1                	cmp    %edx,%ecx
  801e0f:	72 17                	jb     801e28 <__udivdi3+0x10c>
  801e11:	74 09                	je     801e1c <__udivdi3+0x100>
  801e13:	89 fe                	mov    %edi,%esi
  801e15:	31 ff                	xor    %edi,%edi
  801e17:	e9 41 ff ff ff       	jmp    801d5d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e1c:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e20:	89 f1                	mov    %esi,%ecx
  801e22:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e24:	39 c2                	cmp    %eax,%edx
  801e26:	73 eb                	jae    801e13 <__udivdi3+0xf7>
		{
		  q0--;
  801e28:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e2b:	31 ff                	xor    %edi,%edi
  801e2d:	e9 2b ff ff ff       	jmp    801d5d <__udivdi3+0x41>
  801e32:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e34:	31 f6                	xor    %esi,%esi
  801e36:	e9 22 ff ff ff       	jmp    801d5d <__udivdi3+0x41>
	...

00801e3c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e3c:	55                   	push   %ebp
  801e3d:	57                   	push   %edi
  801e3e:	56                   	push   %esi
  801e3f:	83 ec 20             	sub    $0x20,%esp
  801e42:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e46:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e4a:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e4e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801e52:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e56:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801e5a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801e5c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e5e:	85 ed                	test   %ebp,%ebp
  801e60:	75 16                	jne    801e78 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801e62:	39 f1                	cmp    %esi,%ecx
  801e64:	0f 86 a6 00 00 00    	jbe    801f10 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e6a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801e6c:	89 d0                	mov    %edx,%eax
  801e6e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e70:	83 c4 20             	add    $0x20,%esp
  801e73:	5e                   	pop    %esi
  801e74:	5f                   	pop    %edi
  801e75:	5d                   	pop    %ebp
  801e76:	c3                   	ret    
  801e77:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e78:	39 f5                	cmp    %esi,%ebp
  801e7a:	0f 87 ac 00 00 00    	ja     801f2c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e80:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801e83:	83 f0 1f             	xor    $0x1f,%eax
  801e86:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e8a:	0f 84 a8 00 00 00    	je     801f38 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e90:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e94:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e96:	bf 20 00 00 00       	mov    $0x20,%edi
  801e9b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801e9f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ea3:	89 f9                	mov    %edi,%ecx
  801ea5:	d3 e8                	shr    %cl,%eax
  801ea7:	09 e8                	or     %ebp,%eax
  801ea9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801ead:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801eb1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801eb5:	d3 e0                	shl    %cl,%eax
  801eb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ebb:	89 f2                	mov    %esi,%edx
  801ebd:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801ebf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ec3:	d3 e0                	shl    %cl,%eax
  801ec5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ec9:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ecd:	89 f9                	mov    %edi,%ecx
  801ecf:	d3 e8                	shr    %cl,%eax
  801ed1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801ed3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ed5:	89 f2                	mov    %esi,%edx
  801ed7:	f7 74 24 18          	divl   0x18(%esp)
  801edb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801edd:	f7 64 24 0c          	mull   0xc(%esp)
  801ee1:	89 c5                	mov    %eax,%ebp
  801ee3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ee5:	39 d6                	cmp    %edx,%esi
  801ee7:	72 67                	jb     801f50 <__umoddi3+0x114>
  801ee9:	74 75                	je     801f60 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801eeb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801eef:	29 e8                	sub    %ebp,%eax
  801ef1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801ef3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ef7:	d3 e8                	shr    %cl,%eax
  801ef9:	89 f2                	mov    %esi,%edx
  801efb:	89 f9                	mov    %edi,%ecx
  801efd:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801eff:	09 d0                	or     %edx,%eax
  801f01:	89 f2                	mov    %esi,%edx
  801f03:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f07:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f09:	83 c4 20             	add    $0x20,%esp
  801f0c:	5e                   	pop    %esi
  801f0d:	5f                   	pop    %edi
  801f0e:	5d                   	pop    %ebp
  801f0f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f10:	85 c9                	test   %ecx,%ecx
  801f12:	75 0b                	jne    801f1f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f14:	b8 01 00 00 00       	mov    $0x1,%eax
  801f19:	31 d2                	xor    %edx,%edx
  801f1b:	f7 f1                	div    %ecx
  801f1d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f1f:	89 f0                	mov    %esi,%eax
  801f21:	31 d2                	xor    %edx,%edx
  801f23:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f25:	89 f8                	mov    %edi,%eax
  801f27:	e9 3e ff ff ff       	jmp    801e6a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f2c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f2e:	83 c4 20             	add    $0x20,%esp
  801f31:	5e                   	pop    %esi
  801f32:	5f                   	pop    %edi
  801f33:	5d                   	pop    %ebp
  801f34:	c3                   	ret    
  801f35:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f38:	39 f5                	cmp    %esi,%ebp
  801f3a:	72 04                	jb     801f40 <__umoddi3+0x104>
  801f3c:	39 f9                	cmp    %edi,%ecx
  801f3e:	77 06                	ja     801f46 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f40:	89 f2                	mov    %esi,%edx
  801f42:	29 cf                	sub    %ecx,%edi
  801f44:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801f46:	89 f8                	mov    %edi,%eax
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
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f50:	89 d1                	mov    %edx,%ecx
  801f52:	89 c5                	mov    %eax,%ebp
  801f54:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f58:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f5c:	eb 8d                	jmp    801eeb <__umoddi3+0xaf>
  801f5e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f60:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f64:	72 ea                	jb     801f50 <__umoddi3+0x114>
  801f66:	89 f1                	mov    %esi,%ecx
  801f68:	eb 81                	jmp    801eeb <__umoddi3+0xaf>
