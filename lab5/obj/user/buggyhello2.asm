
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 30 80 00       	mov    0x803000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 79 00 00 00       	call   8000c8 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 20             	sub    $0x20,%esp
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800062:	e8 f0 00 00 00       	call   800157 <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800073:	c1 e0 07             	shl    $0x7,%eax
  800076:	29 d0                	sub    %edx,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800080:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800083:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800088:	85 f6                	test   %esi,%esi
  80008a:	7e 07                	jle    800093 <libmain+0x3f>
		binaryname = argv[0];
  80008c:	8b 03                	mov    (%ebx),%eax
  80008e:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800093:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800097:	89 34 24             	mov    %esi,(%esp)
  80009a:	e8 95 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009f:	e8 08 00 00 00       	call   8000ac <exit>
}
  8000a4:	83 c4 20             	add    $0x20,%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000b2:	e8 32 05 00 00       	call   8005e9 <close_all>
	sys_env_destroy(0);
  8000b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000be:	e8 42 00 00 00       	call   800105 <sys_env_destroy>
}
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    
  8000c5:	00 00                	add    %al,(%eax)
	...

008000c8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d9:	89 c3                	mov    %eax,%ebx
  8000db:	89 c7                	mov    %eax,%edi
  8000dd:	89 c6                	mov    %eax,%esi
  8000df:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5f                   	pop    %edi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f6:	89 d1                	mov    %edx,%ecx
  8000f8:	89 d3                	mov    %edx,%ebx
  8000fa:	89 d7                	mov    %edx,%edi
  8000fc:	89 d6                	mov    %edx,%esi
  8000fe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5f                   	pop    %edi
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    

00800105 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	57                   	push   %edi
  800109:	56                   	push   %esi
  80010a:	53                   	push   %ebx
  80010b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800113:	b8 03 00 00 00       	mov    $0x3,%eax
  800118:	8b 55 08             	mov    0x8(%ebp),%edx
  80011b:	89 cb                	mov    %ecx,%ebx
  80011d:	89 cf                	mov    %ecx,%edi
  80011f:	89 ce                	mov    %ecx,%esi
  800121:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800123:	85 c0                	test   %eax,%eax
  800125:	7e 28                	jle    80014f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800127:	89 44 24 10          	mov    %eax,0x10(%esp)
  80012b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800132:	00 
  800133:	c7 44 24 08 b8 1f 80 	movl   $0x801fb8,0x8(%esp)
  80013a:	00 
  80013b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800142:	00 
  800143:	c7 04 24 d5 1f 80 00 	movl   $0x801fd5,(%esp)
  80014a:	e8 c1 10 00 00       	call   801210 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014f:	83 c4 2c             	add    $0x2c,%esp
  800152:	5b                   	pop    %ebx
  800153:	5e                   	pop    %esi
  800154:	5f                   	pop    %edi
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015d:	ba 00 00 00 00       	mov    $0x0,%edx
  800162:	b8 02 00 00 00       	mov    $0x2,%eax
  800167:	89 d1                	mov    %edx,%ecx
  800169:	89 d3                	mov    %edx,%ebx
  80016b:	89 d7                	mov    %edx,%edi
  80016d:	89 d6                	mov    %edx,%esi
  80016f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800171:	5b                   	pop    %ebx
  800172:	5e                   	pop    %esi
  800173:	5f                   	pop    %edi
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    

00800176 <sys_yield>:

void
sys_yield(void)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	57                   	push   %edi
  80017a:	56                   	push   %esi
  80017b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017c:	ba 00 00 00 00       	mov    $0x0,%edx
  800181:	b8 0b 00 00 00       	mov    $0xb,%eax
  800186:	89 d1                	mov    %edx,%ecx
  800188:	89 d3                	mov    %edx,%ebx
  80018a:	89 d7                	mov    %edx,%edi
  80018c:	89 d6                	mov    %edx,%esi
  80018e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800190:	5b                   	pop    %ebx
  800191:	5e                   	pop    %esi
  800192:	5f                   	pop    %edi
  800193:	5d                   	pop    %ebp
  800194:	c3                   	ret    

00800195 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019e:	be 00 00 00 00       	mov    $0x0,%esi
  8001a3:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	89 f7                	mov    %esi,%edi
  8001b3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b5:	85 c0                	test   %eax,%eax
  8001b7:	7e 28                	jle    8001e1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001bd:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 08 b8 1f 80 	movl   $0x801fb8,0x8(%esp)
  8001cc:	00 
  8001cd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001d4:	00 
  8001d5:	c7 04 24 d5 1f 80 00 	movl   $0x801fd5,(%esp)
  8001dc:	e8 2f 10 00 00       	call   801210 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001e1:	83 c4 2c             	add    $0x2c,%esp
  8001e4:	5b                   	pop    %ebx
  8001e5:	5e                   	pop    %esi
  8001e6:	5f                   	pop    %edi
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    

008001e9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	57                   	push   %edi
  8001ed:	56                   	push   %esi
  8001ee:	53                   	push   %ebx
  8001ef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001fa:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800208:	85 c0                	test   %eax,%eax
  80020a:	7e 28                	jle    800234 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800210:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800217:	00 
  800218:	c7 44 24 08 b8 1f 80 	movl   $0x801fb8,0x8(%esp)
  80021f:	00 
  800220:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800227:	00 
  800228:	c7 04 24 d5 1f 80 00 	movl   $0x801fd5,(%esp)
  80022f:	e8 dc 0f 00 00       	call   801210 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800234:	83 c4 2c             	add    $0x2c,%esp
  800237:	5b                   	pop    %ebx
  800238:	5e                   	pop    %esi
  800239:	5f                   	pop    %edi
  80023a:	5d                   	pop    %ebp
  80023b:	c3                   	ret    

0080023c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	57                   	push   %edi
  800240:	56                   	push   %esi
  800241:	53                   	push   %ebx
  800242:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024a:	b8 06 00 00 00       	mov    $0x6,%eax
  80024f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800252:	8b 55 08             	mov    0x8(%ebp),%edx
  800255:	89 df                	mov    %ebx,%edi
  800257:	89 de                	mov    %ebx,%esi
  800259:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80025b:	85 c0                	test   %eax,%eax
  80025d:	7e 28                	jle    800287 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800263:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80026a:	00 
  80026b:	c7 44 24 08 b8 1f 80 	movl   $0x801fb8,0x8(%esp)
  800272:	00 
  800273:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80027a:	00 
  80027b:	c7 04 24 d5 1f 80 00 	movl   $0x801fd5,(%esp)
  800282:	e8 89 0f 00 00       	call   801210 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800287:	83 c4 2c             	add    $0x2c,%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	57                   	push   %edi
  800293:	56                   	push   %esi
  800294:	53                   	push   %ebx
  800295:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800298:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029d:	b8 08 00 00 00       	mov    $0x8,%eax
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a8:	89 df                	mov    %ebx,%edi
  8002aa:	89 de                	mov    %ebx,%esi
  8002ac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ae:	85 c0                	test   %eax,%eax
  8002b0:	7e 28                	jle    8002da <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002b6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002bd:	00 
  8002be:	c7 44 24 08 b8 1f 80 	movl   $0x801fb8,0x8(%esp)
  8002c5:	00 
  8002c6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002cd:	00 
  8002ce:	c7 04 24 d5 1f 80 00 	movl   $0x801fd5,(%esp)
  8002d5:	e8 36 0f 00 00       	call   801210 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002da:	83 c4 2c             	add    $0x2c,%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
  8002e8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f0:	b8 09 00 00 00       	mov    $0x9,%eax
  8002f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fb:	89 df                	mov    %ebx,%edi
  8002fd:	89 de                	mov    %ebx,%esi
  8002ff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800301:	85 c0                	test   %eax,%eax
  800303:	7e 28                	jle    80032d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800305:	89 44 24 10          	mov    %eax,0x10(%esp)
  800309:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800310:	00 
  800311:	c7 44 24 08 b8 1f 80 	movl   $0x801fb8,0x8(%esp)
  800318:	00 
  800319:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800320:	00 
  800321:	c7 04 24 d5 1f 80 00 	movl   $0x801fd5,(%esp)
  800328:	e8 e3 0e 00 00       	call   801210 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80032d:	83 c4 2c             	add    $0x2c,%esp
  800330:	5b                   	pop    %ebx
  800331:	5e                   	pop    %esi
  800332:	5f                   	pop    %edi
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    

00800335 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	57                   	push   %edi
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
  80033b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800343:	b8 0a 00 00 00       	mov    $0xa,%eax
  800348:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034b:	8b 55 08             	mov    0x8(%ebp),%edx
  80034e:	89 df                	mov    %ebx,%edi
  800350:	89 de                	mov    %ebx,%esi
  800352:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800354:	85 c0                	test   %eax,%eax
  800356:	7e 28                	jle    800380 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800358:	89 44 24 10          	mov    %eax,0x10(%esp)
  80035c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800363:	00 
  800364:	c7 44 24 08 b8 1f 80 	movl   $0x801fb8,0x8(%esp)
  80036b:	00 
  80036c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800373:	00 
  800374:	c7 04 24 d5 1f 80 00 	movl   $0x801fd5,(%esp)
  80037b:	e8 90 0e 00 00       	call   801210 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800380:	83 c4 2c             	add    $0x2c,%esp
  800383:	5b                   	pop    %ebx
  800384:	5e                   	pop    %esi
  800385:	5f                   	pop    %edi
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	57                   	push   %edi
  80038c:	56                   	push   %esi
  80038d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038e:	be 00 00 00 00       	mov    $0x0,%esi
  800393:	b8 0c 00 00 00       	mov    $0xc,%eax
  800398:	8b 7d 14             	mov    0x14(%ebp),%edi
  80039b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80039e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003a6:	5b                   	pop    %ebx
  8003a7:	5e                   	pop    %esi
  8003a8:	5f                   	pop    %edi
  8003a9:	5d                   	pop    %ebp
  8003aa:	c3                   	ret    

008003ab <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	57                   	push   %edi
  8003af:	56                   	push   %esi
  8003b0:	53                   	push   %ebx
  8003b1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003be:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c1:	89 cb                	mov    %ecx,%ebx
  8003c3:	89 cf                	mov    %ecx,%edi
  8003c5:	89 ce                	mov    %ecx,%esi
  8003c7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003c9:	85 c0                	test   %eax,%eax
  8003cb:	7e 28                	jle    8003f5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003cd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003d1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003d8:	00 
  8003d9:	c7 44 24 08 b8 1f 80 	movl   $0x801fb8,0x8(%esp)
  8003e0:	00 
  8003e1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003e8:	00 
  8003e9:	c7 04 24 d5 1f 80 00 	movl   $0x801fd5,(%esp)
  8003f0:	e8 1b 0e 00 00       	call   801210 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003f5:	83 c4 2c             	add    $0x2c,%esp
  8003f8:	5b                   	pop    %ebx
  8003f9:	5e                   	pop    %esi
  8003fa:	5f                   	pop    %edi
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    
  8003fd:	00 00                	add    %al,(%eax)
	...

00800400 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800403:	8b 45 08             	mov    0x8(%ebp),%eax
  800406:	05 00 00 00 30       	add    $0x30000000,%eax
  80040b:	c1 e8 0c             	shr    $0xc,%eax
}
  80040e:	5d                   	pop    %ebp
  80040f:	c3                   	ret    

00800410 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800416:	8b 45 08             	mov    0x8(%ebp),%eax
  800419:	89 04 24             	mov    %eax,(%esp)
  80041c:	e8 df ff ff ff       	call   800400 <fd2num>
  800421:	05 20 00 0d 00       	add    $0xd0020,%eax
  800426:	c1 e0 0c             	shl    $0xc,%eax
}
  800429:	c9                   	leave  
  80042a:	c3                   	ret    

0080042b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
  80042e:	53                   	push   %ebx
  80042f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800432:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800437:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800439:	89 c2                	mov    %eax,%edx
  80043b:	c1 ea 16             	shr    $0x16,%edx
  80043e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800445:	f6 c2 01             	test   $0x1,%dl
  800448:	74 11                	je     80045b <fd_alloc+0x30>
  80044a:	89 c2                	mov    %eax,%edx
  80044c:	c1 ea 0c             	shr    $0xc,%edx
  80044f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800456:	f6 c2 01             	test   $0x1,%dl
  800459:	75 09                	jne    800464 <fd_alloc+0x39>
			*fd_store = fd;
  80045b:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  80045d:	b8 00 00 00 00       	mov    $0x0,%eax
  800462:	eb 17                	jmp    80047b <fd_alloc+0x50>
  800464:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800469:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80046e:	75 c7                	jne    800437 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800470:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800476:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80047b:	5b                   	pop    %ebx
  80047c:	5d                   	pop    %ebp
  80047d:	c3                   	ret    

0080047e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
  800481:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800484:	83 f8 1f             	cmp    $0x1f,%eax
  800487:	77 36                	ja     8004bf <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800489:	05 00 00 0d 00       	add    $0xd0000,%eax
  80048e:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800491:	89 c2                	mov    %eax,%edx
  800493:	c1 ea 16             	shr    $0x16,%edx
  800496:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80049d:	f6 c2 01             	test   $0x1,%dl
  8004a0:	74 24                	je     8004c6 <fd_lookup+0x48>
  8004a2:	89 c2                	mov    %eax,%edx
  8004a4:	c1 ea 0c             	shr    $0xc,%edx
  8004a7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004ae:	f6 c2 01             	test   $0x1,%dl
  8004b1:	74 1a                	je     8004cd <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b6:	89 02                	mov    %eax,(%edx)
	return 0;
  8004b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bd:	eb 13                	jmp    8004d2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004c4:	eb 0c                	jmp    8004d2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004cb:	eb 05                	jmp    8004d2 <fd_lookup+0x54>
  8004cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004d2:	5d                   	pop    %ebp
  8004d3:	c3                   	ret    

008004d4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	53                   	push   %ebx
  8004d8:	83 ec 14             	sub    $0x14,%esp
  8004db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8004e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e6:	eb 0e                	jmp    8004f6 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8004e8:	39 08                	cmp    %ecx,(%eax)
  8004ea:	75 09                	jne    8004f5 <dev_lookup+0x21>
			*dev = devtab[i];
  8004ec:	89 03                	mov    %eax,(%ebx)
			return 0;
  8004ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f3:	eb 35                	jmp    80052a <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004f5:	42                   	inc    %edx
  8004f6:	8b 04 95 60 20 80 00 	mov    0x802060(,%edx,4),%eax
  8004fd:	85 c0                	test   %eax,%eax
  8004ff:	75 e7                	jne    8004e8 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800501:	a1 04 40 80 00       	mov    0x804004,%eax
  800506:	8b 00                	mov    (%eax),%eax
  800508:	8b 40 48             	mov    0x48(%eax),%eax
  80050b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80050f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800513:	c7 04 24 e4 1f 80 00 	movl   $0x801fe4,(%esp)
  80051a:	e8 e9 0d 00 00       	call   801308 <cprintf>
	*dev = 0;
  80051f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800525:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80052a:	83 c4 14             	add    $0x14,%esp
  80052d:	5b                   	pop    %ebx
  80052e:	5d                   	pop    %ebp
  80052f:	c3                   	ret    

00800530 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	56                   	push   %esi
  800534:	53                   	push   %ebx
  800535:	83 ec 30             	sub    $0x30,%esp
  800538:	8b 75 08             	mov    0x8(%ebp),%esi
  80053b:	8a 45 0c             	mov    0xc(%ebp),%al
  80053e:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800541:	89 34 24             	mov    %esi,(%esp)
  800544:	e8 b7 fe ff ff       	call   800400 <fd2num>
  800549:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80054c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800550:	89 04 24             	mov    %eax,(%esp)
  800553:	e8 26 ff ff ff       	call   80047e <fd_lookup>
  800558:	89 c3                	mov    %eax,%ebx
  80055a:	85 c0                	test   %eax,%eax
  80055c:	78 05                	js     800563 <fd_close+0x33>
	    || fd != fd2)
  80055e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800561:	74 0d                	je     800570 <fd_close+0x40>
		return (must_exist ? r : 0);
  800563:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800567:	75 46                	jne    8005af <fd_close+0x7f>
  800569:	bb 00 00 00 00       	mov    $0x0,%ebx
  80056e:	eb 3f                	jmp    8005af <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800570:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800573:	89 44 24 04          	mov    %eax,0x4(%esp)
  800577:	8b 06                	mov    (%esi),%eax
  800579:	89 04 24             	mov    %eax,(%esp)
  80057c:	e8 53 ff ff ff       	call   8004d4 <dev_lookup>
  800581:	89 c3                	mov    %eax,%ebx
  800583:	85 c0                	test   %eax,%eax
  800585:	78 18                	js     80059f <fd_close+0x6f>
		if (dev->dev_close)
  800587:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80058a:	8b 40 10             	mov    0x10(%eax),%eax
  80058d:	85 c0                	test   %eax,%eax
  80058f:	74 09                	je     80059a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800591:	89 34 24             	mov    %esi,(%esp)
  800594:	ff d0                	call   *%eax
  800596:	89 c3                	mov    %eax,%ebx
  800598:	eb 05                	jmp    80059f <fd_close+0x6f>
		else
			r = 0;
  80059a:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80059f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005aa:	e8 8d fc ff ff       	call   80023c <sys_page_unmap>
	return r;
}
  8005af:	89 d8                	mov    %ebx,%eax
  8005b1:	83 c4 30             	add    $0x30,%esp
  8005b4:	5b                   	pop    %ebx
  8005b5:	5e                   	pop    %esi
  8005b6:	5d                   	pop    %ebp
  8005b7:	c3                   	ret    

008005b8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005b8:	55                   	push   %ebp
  8005b9:	89 e5                	mov    %esp,%ebp
  8005bb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c8:	89 04 24             	mov    %eax,(%esp)
  8005cb:	e8 ae fe ff ff       	call   80047e <fd_lookup>
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	78 13                	js     8005e7 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005d4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005db:	00 
  8005dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005df:	89 04 24             	mov    %eax,(%esp)
  8005e2:	e8 49 ff ff ff       	call   800530 <fd_close>
}
  8005e7:	c9                   	leave  
  8005e8:	c3                   	ret    

008005e9 <close_all>:

void
close_all(void)
{
  8005e9:	55                   	push   %ebp
  8005ea:	89 e5                	mov    %esp,%ebp
  8005ec:	53                   	push   %ebx
  8005ed:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005f0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005f5:	89 1c 24             	mov    %ebx,(%esp)
  8005f8:	e8 bb ff ff ff       	call   8005b8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005fd:	43                   	inc    %ebx
  8005fe:	83 fb 20             	cmp    $0x20,%ebx
  800601:	75 f2                	jne    8005f5 <close_all+0xc>
		close(i);
}
  800603:	83 c4 14             	add    $0x14,%esp
  800606:	5b                   	pop    %ebx
  800607:	5d                   	pop    %ebp
  800608:	c3                   	ret    

00800609 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800609:	55                   	push   %ebp
  80060a:	89 e5                	mov    %esp,%ebp
  80060c:	57                   	push   %edi
  80060d:	56                   	push   %esi
  80060e:	53                   	push   %ebx
  80060f:	83 ec 4c             	sub    $0x4c,%esp
  800612:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800615:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800618:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061c:	8b 45 08             	mov    0x8(%ebp),%eax
  80061f:	89 04 24             	mov    %eax,(%esp)
  800622:	e8 57 fe ff ff       	call   80047e <fd_lookup>
  800627:	89 c3                	mov    %eax,%ebx
  800629:	85 c0                	test   %eax,%eax
  80062b:	0f 88 e1 00 00 00    	js     800712 <dup+0x109>
		return r;
	close(newfdnum);
  800631:	89 3c 24             	mov    %edi,(%esp)
  800634:	e8 7f ff ff ff       	call   8005b8 <close>

	newfd = INDEX2FD(newfdnum);
  800639:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80063f:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800642:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800645:	89 04 24             	mov    %eax,(%esp)
  800648:	e8 c3 fd ff ff       	call   800410 <fd2data>
  80064d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80064f:	89 34 24             	mov    %esi,(%esp)
  800652:	e8 b9 fd ff ff       	call   800410 <fd2data>
  800657:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80065a:	89 d8                	mov    %ebx,%eax
  80065c:	c1 e8 16             	shr    $0x16,%eax
  80065f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800666:	a8 01                	test   $0x1,%al
  800668:	74 46                	je     8006b0 <dup+0xa7>
  80066a:	89 d8                	mov    %ebx,%eax
  80066c:	c1 e8 0c             	shr    $0xc,%eax
  80066f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800676:	f6 c2 01             	test   $0x1,%dl
  800679:	74 35                	je     8006b0 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80067b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800682:	25 07 0e 00 00       	and    $0xe07,%eax
  800687:	89 44 24 10          	mov    %eax,0x10(%esp)
  80068b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80068e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800692:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800699:	00 
  80069a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80069e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006a5:	e8 3f fb ff ff       	call   8001e9 <sys_page_map>
  8006aa:	89 c3                	mov    %eax,%ebx
  8006ac:	85 c0                	test   %eax,%eax
  8006ae:	78 3b                	js     8006eb <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006b3:	89 c2                	mov    %eax,%edx
  8006b5:	c1 ea 0c             	shr    $0xc,%edx
  8006b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006bf:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006c5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006c9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006cd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006d4:	00 
  8006d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006e0:	e8 04 fb ff ff       	call   8001e9 <sys_page_map>
  8006e5:	89 c3                	mov    %eax,%ebx
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	79 25                	jns    800710 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006eb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006f6:	e8 41 fb ff ff       	call   80023c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800702:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800709:	e8 2e fb ff ff       	call   80023c <sys_page_unmap>
	return r;
  80070e:	eb 02                	jmp    800712 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800710:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800712:	89 d8                	mov    %ebx,%eax
  800714:	83 c4 4c             	add    $0x4c,%esp
  800717:	5b                   	pop    %ebx
  800718:	5e                   	pop    %esi
  800719:	5f                   	pop    %edi
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	53                   	push   %ebx
  800720:	83 ec 24             	sub    $0x24,%esp
  800723:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800726:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800729:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072d:	89 1c 24             	mov    %ebx,(%esp)
  800730:	e8 49 fd ff ff       	call   80047e <fd_lookup>
  800735:	85 c0                	test   %eax,%eax
  800737:	78 6f                	js     8007a8 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800739:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80073c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800740:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800743:	8b 00                	mov    (%eax),%eax
  800745:	89 04 24             	mov    %eax,(%esp)
  800748:	e8 87 fd ff ff       	call   8004d4 <dev_lookup>
  80074d:	85 c0                	test   %eax,%eax
  80074f:	78 57                	js     8007a8 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800751:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800754:	8b 50 08             	mov    0x8(%eax),%edx
  800757:	83 e2 03             	and    $0x3,%edx
  80075a:	83 fa 01             	cmp    $0x1,%edx
  80075d:	75 25                	jne    800784 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80075f:	a1 04 40 80 00       	mov    0x804004,%eax
  800764:	8b 00                	mov    (%eax),%eax
  800766:	8b 40 48             	mov    0x48(%eax),%eax
  800769:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80076d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800771:	c7 04 24 25 20 80 00 	movl   $0x802025,(%esp)
  800778:	e8 8b 0b 00 00       	call   801308 <cprintf>
		return -E_INVAL;
  80077d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800782:	eb 24                	jmp    8007a8 <read+0x8c>
	}
	if (!dev->dev_read)
  800784:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800787:	8b 52 08             	mov    0x8(%edx),%edx
  80078a:	85 d2                	test   %edx,%edx
  80078c:	74 15                	je     8007a3 <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80078e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800791:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800795:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800798:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80079c:	89 04 24             	mov    %eax,(%esp)
  80079f:	ff d2                	call   *%edx
  8007a1:	eb 05                	jmp    8007a8 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8007a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8007a8:	83 c4 24             	add    $0x24,%esp
  8007ab:	5b                   	pop    %ebx
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	57                   	push   %edi
  8007b2:	56                   	push   %esi
  8007b3:	53                   	push   %ebx
  8007b4:	83 ec 1c             	sub    $0x1c,%esp
  8007b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ba:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007c2:	eb 23                	jmp    8007e7 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007c4:	89 f0                	mov    %esi,%eax
  8007c6:	29 d8                	sub    %ebx,%eax
  8007c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cf:	01 d8                	add    %ebx,%eax
  8007d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d5:	89 3c 24             	mov    %edi,(%esp)
  8007d8:	e8 3f ff ff ff       	call   80071c <read>
		if (m < 0)
  8007dd:	85 c0                	test   %eax,%eax
  8007df:	78 10                	js     8007f1 <readn+0x43>
			return m;
		if (m == 0)
  8007e1:	85 c0                	test   %eax,%eax
  8007e3:	74 0a                	je     8007ef <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007e5:	01 c3                	add    %eax,%ebx
  8007e7:	39 f3                	cmp    %esi,%ebx
  8007e9:	72 d9                	jb     8007c4 <readn+0x16>
  8007eb:	89 d8                	mov    %ebx,%eax
  8007ed:	eb 02                	jmp    8007f1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8007ef:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007f1:	83 c4 1c             	add    $0x1c,%esp
  8007f4:	5b                   	pop    %ebx
  8007f5:	5e                   	pop    %esi
  8007f6:	5f                   	pop    %edi
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	53                   	push   %ebx
  8007fd:	83 ec 24             	sub    $0x24,%esp
  800800:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800803:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800806:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080a:	89 1c 24             	mov    %ebx,(%esp)
  80080d:	e8 6c fc ff ff       	call   80047e <fd_lookup>
  800812:	85 c0                	test   %eax,%eax
  800814:	78 6a                	js     800880 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800816:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800819:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800820:	8b 00                	mov    (%eax),%eax
  800822:	89 04 24             	mov    %eax,(%esp)
  800825:	e8 aa fc ff ff       	call   8004d4 <dev_lookup>
  80082a:	85 c0                	test   %eax,%eax
  80082c:	78 52                	js     800880 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80082e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800831:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800835:	75 25                	jne    80085c <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800837:	a1 04 40 80 00       	mov    0x804004,%eax
  80083c:	8b 00                	mov    (%eax),%eax
  80083e:	8b 40 48             	mov    0x48(%eax),%eax
  800841:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800845:	89 44 24 04          	mov    %eax,0x4(%esp)
  800849:	c7 04 24 41 20 80 00 	movl   $0x802041,(%esp)
  800850:	e8 b3 0a 00 00       	call   801308 <cprintf>
		return -E_INVAL;
  800855:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80085a:	eb 24                	jmp    800880 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80085c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085f:	8b 52 0c             	mov    0xc(%edx),%edx
  800862:	85 d2                	test   %edx,%edx
  800864:	74 15                	je     80087b <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800866:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800869:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80086d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800870:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800874:	89 04 24             	mov    %eax,(%esp)
  800877:	ff d2                	call   *%edx
  800879:	eb 05                	jmp    800880 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80087b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800880:	83 c4 24             	add    $0x24,%esp
  800883:	5b                   	pop    %ebx
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <seek>:

int
seek(int fdnum, off_t offset)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80088c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80088f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	89 04 24             	mov    %eax,(%esp)
  800899:	e8 e0 fb ff ff       	call   80047e <fd_lookup>
  80089e:	85 c0                	test   %eax,%eax
  8008a0:	78 0e                	js     8008b0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    

008008b2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	53                   	push   %ebx
  8008b6:	83 ec 24             	sub    $0x24,%esp
  8008b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c3:	89 1c 24             	mov    %ebx,(%esp)
  8008c6:	e8 b3 fb ff ff       	call   80047e <fd_lookup>
  8008cb:	85 c0                	test   %eax,%eax
  8008cd:	78 63                	js     800932 <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d9:	8b 00                	mov    (%eax),%eax
  8008db:	89 04 24             	mov    %eax,(%esp)
  8008de:	e8 f1 fb ff ff       	call   8004d4 <dev_lookup>
  8008e3:	85 c0                	test   %eax,%eax
  8008e5:	78 4b                	js     800932 <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008ee:	75 25                	jne    800915 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008f0:	a1 04 40 80 00       	mov    0x804004,%eax
  8008f5:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008f7:	8b 40 48             	mov    0x48(%eax),%eax
  8008fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800902:	c7 04 24 04 20 80 00 	movl   $0x802004,(%esp)
  800909:	e8 fa 09 00 00       	call   801308 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80090e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800913:	eb 1d                	jmp    800932 <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  800915:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800918:	8b 52 18             	mov    0x18(%edx),%edx
  80091b:	85 d2                	test   %edx,%edx
  80091d:	74 0e                	je     80092d <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80091f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800922:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800926:	89 04 24             	mov    %eax,(%esp)
  800929:	ff d2                	call   *%edx
  80092b:	eb 05                	jmp    800932 <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80092d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800932:	83 c4 24             	add    $0x24,%esp
  800935:	5b                   	pop    %ebx
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	53                   	push   %ebx
  80093c:	83 ec 24             	sub    $0x24,%esp
  80093f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800942:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800945:	89 44 24 04          	mov    %eax,0x4(%esp)
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	89 04 24             	mov    %eax,(%esp)
  80094f:	e8 2a fb ff ff       	call   80047e <fd_lookup>
  800954:	85 c0                	test   %eax,%eax
  800956:	78 52                	js     8009aa <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800958:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80095b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800962:	8b 00                	mov    (%eax),%eax
  800964:	89 04 24             	mov    %eax,(%esp)
  800967:	e8 68 fb ff ff       	call   8004d4 <dev_lookup>
  80096c:	85 c0                	test   %eax,%eax
  80096e:	78 3a                	js     8009aa <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800970:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800973:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800977:	74 2c                	je     8009a5 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800979:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80097c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800983:	00 00 00 
	stat->st_isdir = 0;
  800986:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80098d:	00 00 00 
	stat->st_dev = dev;
  800990:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800996:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80099a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80099d:	89 14 24             	mov    %edx,(%esp)
  8009a0:	ff 50 14             	call   *0x14(%eax)
  8009a3:	eb 05                	jmp    8009aa <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8009a5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8009aa:	83 c4 24             	add    $0x24,%esp
  8009ad:	5b                   	pop    %ebx
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	56                   	push   %esi
  8009b4:	53                   	push   %ebx
  8009b5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009bf:	00 
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	89 04 24             	mov    %eax,(%esp)
  8009c6:	e8 88 02 00 00       	call   800c53 <open>
  8009cb:	89 c3                	mov    %eax,%ebx
  8009cd:	85 c0                	test   %eax,%eax
  8009cf:	78 1b                	js     8009ec <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d8:	89 1c 24             	mov    %ebx,(%esp)
  8009db:	e8 58 ff ff ff       	call   800938 <fstat>
  8009e0:	89 c6                	mov    %eax,%esi
	close(fd);
  8009e2:	89 1c 24             	mov    %ebx,(%esp)
  8009e5:	e8 ce fb ff ff       	call   8005b8 <close>
	return r;
  8009ea:	89 f3                	mov    %esi,%ebx
}
  8009ec:	89 d8                	mov    %ebx,%eax
  8009ee:	83 c4 10             	add    $0x10,%esp
  8009f1:	5b                   	pop    %ebx
  8009f2:	5e                   	pop    %esi
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    
  8009f5:	00 00                	add    %al,(%eax)
	...

008009f8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	83 ec 10             	sub    $0x10,%esp
  800a00:	89 c3                	mov    %eax,%ebx
  800a02:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a04:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a0b:	75 11                	jne    800a1e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a0d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a14:	e8 92 12 00 00       	call   801cab <ipc_find_env>
  800a19:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a1e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a25:	00 
  800a26:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a2d:	00 
  800a2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a32:	a1 00 40 80 00       	mov    0x804000,%eax
  800a37:	89 04 24             	mov    %eax,(%esp)
  800a3a:	e8 06 12 00 00       	call   801c45 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  800a3f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a46:	00 
  800a47:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a52:	e8 81 11 00 00       	call   801bd8 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  800a57:	83 c4 10             	add    $0x10,%esp
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8b 40 0c             	mov    0xc(%eax),%eax
  800a6a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a72:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a77:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7c:	b8 02 00 00 00       	mov    $0x2,%eax
  800a81:	e8 72 ff ff ff       	call   8009f8 <fsipc>
}
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    

00800a88 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	8b 40 0c             	mov    0xc(%eax),%eax
  800a94:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a99:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9e:	b8 06 00 00 00       	mov    $0x6,%eax
  800aa3:	e8 50 ff ff ff       	call   8009f8 <fsipc>
}
  800aa8:	c9                   	leave  
  800aa9:	c3                   	ret    

00800aaa <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	53                   	push   %ebx
  800aae:	83 ec 14             	sub    $0x14,%esp
  800ab1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 40 0c             	mov    0xc(%eax),%eax
  800aba:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800abf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac4:	b8 05 00 00 00       	mov    $0x5,%eax
  800ac9:	e8 2a ff ff ff       	call   8009f8 <fsipc>
  800ace:	85 c0                	test   %eax,%eax
  800ad0:	78 2b                	js     800afd <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ad2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ad9:	00 
  800ada:	89 1c 24             	mov    %ebx,(%esp)
  800add:	e8 d1 0d 00 00       	call   8018b3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ae2:	a1 80 50 80 00       	mov    0x805080,%eax
  800ae7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800aed:	a1 84 50 80 00       	mov    0x805084,%eax
  800af2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800afd:	83 c4 14             	add    $0x14,%esp
  800b00:	5b                   	pop    %ebx
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	53                   	push   %ebx
  800b07:	83 ec 14             	sub    $0x14,%esp
  800b0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b10:	8b 40 0c             	mov    0xc(%eax),%eax
  800b13:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  800b18:	89 d8                	mov    %ebx,%eax
  800b1a:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800b20:	76 05                	jbe    800b27 <devfile_write+0x24>
  800b22:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800b27:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  800b2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b37:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b3e:	e8 53 0f 00 00       	call   801a96 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4d:	e8 a6 fe ff ff       	call   8009f8 <fsipc>
  800b52:	85 c0                	test   %eax,%eax
  800b54:	78 53                	js     800ba9 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  800b56:	39 c3                	cmp    %eax,%ebx
  800b58:	73 24                	jae    800b7e <devfile_write+0x7b>
  800b5a:	c7 44 24 0c 70 20 80 	movl   $0x802070,0xc(%esp)
  800b61:	00 
  800b62:	c7 44 24 08 77 20 80 	movl   $0x802077,0x8(%esp)
  800b69:	00 
  800b6a:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  800b71:	00 
  800b72:	c7 04 24 8c 20 80 00 	movl   $0x80208c,(%esp)
  800b79:	e8 92 06 00 00       	call   801210 <_panic>
	assert(r <= PGSIZE);
  800b7e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b83:	7e 24                	jle    800ba9 <devfile_write+0xa6>
  800b85:	c7 44 24 0c 97 20 80 	movl   $0x802097,0xc(%esp)
  800b8c:	00 
  800b8d:	c7 44 24 08 77 20 80 	movl   $0x802077,0x8(%esp)
  800b94:	00 
  800b95:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  800b9c:	00 
  800b9d:	c7 04 24 8c 20 80 00 	movl   $0x80208c,(%esp)
  800ba4:	e8 67 06 00 00       	call   801210 <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  800ba9:	83 c4 14             	add    $0x14,%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 10             	sub    $0x10,%esp
  800bb7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbd:	8b 40 0c             	mov    0xc(%eax),%eax
  800bc0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800bc5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd0:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd5:	e8 1e fe ff ff       	call   8009f8 <fsipc>
  800bda:	89 c3                	mov    %eax,%ebx
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	78 6a                	js     800c4a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800be0:	39 c6                	cmp    %eax,%esi
  800be2:	73 24                	jae    800c08 <devfile_read+0x59>
  800be4:	c7 44 24 0c 70 20 80 	movl   $0x802070,0xc(%esp)
  800beb:	00 
  800bec:	c7 44 24 08 77 20 80 	movl   $0x802077,0x8(%esp)
  800bf3:	00 
  800bf4:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  800bfb:	00 
  800bfc:	c7 04 24 8c 20 80 00 	movl   $0x80208c,(%esp)
  800c03:	e8 08 06 00 00       	call   801210 <_panic>
	assert(r <= PGSIZE);
  800c08:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c0d:	7e 24                	jle    800c33 <devfile_read+0x84>
  800c0f:	c7 44 24 0c 97 20 80 	movl   $0x802097,0xc(%esp)
  800c16:	00 
  800c17:	c7 44 24 08 77 20 80 	movl   $0x802077,0x8(%esp)
  800c1e:	00 
  800c1f:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  800c26:	00 
  800c27:	c7 04 24 8c 20 80 00 	movl   $0x80208c,(%esp)
  800c2e:	e8 dd 05 00 00       	call   801210 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c33:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c37:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c3e:	00 
  800c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c42:	89 04 24             	mov    %eax,(%esp)
  800c45:	e8 e2 0d 00 00       	call   801a2c <memmove>
	return r;
}
  800c4a:	89 d8                	mov    %ebx,%eax
  800c4c:	83 c4 10             	add    $0x10,%esp
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 20             	sub    $0x20,%esp
  800c5b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c5e:	89 34 24             	mov    %esi,(%esp)
  800c61:	e8 1a 0c 00 00       	call   801880 <strlen>
  800c66:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c6b:	7f 60                	jg     800ccd <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c70:	89 04 24             	mov    %eax,(%esp)
  800c73:	e8 b3 f7 ff ff       	call   80042b <fd_alloc>
  800c78:	89 c3                	mov    %eax,%ebx
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	78 54                	js     800cd2 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c7e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c82:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c89:	e8 25 0c 00 00       	call   8018b3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c91:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c96:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c99:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9e:	e8 55 fd ff ff       	call   8009f8 <fsipc>
  800ca3:	89 c3                	mov    %eax,%ebx
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	79 15                	jns    800cbe <open+0x6b>
		fd_close(fd, 0);
  800ca9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cb0:	00 
  800cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb4:	89 04 24             	mov    %eax,(%esp)
  800cb7:	e8 74 f8 ff ff       	call   800530 <fd_close>
		return r;
  800cbc:	eb 14                	jmp    800cd2 <open+0x7f>
	}

	return fd2num(fd);
  800cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cc1:	89 04 24             	mov    %eax,(%esp)
  800cc4:	e8 37 f7 ff ff       	call   800400 <fd2num>
  800cc9:	89 c3                	mov    %eax,%ebx
  800ccb:	eb 05                	jmp    800cd2 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ccd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800cd2:	89 d8                	mov    %ebx,%eax
  800cd4:	83 c4 20             	add    $0x20,%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ce1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce6:	b8 08 00 00 00       	mov    $0x8,%eax
  800ceb:	e8 08 fd ff ff       	call   8009f8 <fsipc>
}
  800cf0:	c9                   	leave  
  800cf1:	c3                   	ret    
	...

00800cf4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
  800cf9:	83 ec 10             	sub    $0x10,%esp
  800cfc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800cff:	8b 45 08             	mov    0x8(%ebp),%eax
  800d02:	89 04 24             	mov    %eax,(%esp)
  800d05:	e8 06 f7 ff ff       	call   800410 <fd2data>
  800d0a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800d0c:	c7 44 24 04 a3 20 80 	movl   $0x8020a3,0x4(%esp)
  800d13:	00 
  800d14:	89 34 24             	mov    %esi,(%esp)
  800d17:	e8 97 0b 00 00       	call   8018b3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800d1c:	8b 43 04             	mov    0x4(%ebx),%eax
  800d1f:	2b 03                	sub    (%ebx),%eax
  800d21:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800d27:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800d2e:	00 00 00 
	stat->st_dev = &devpipe;
  800d31:	c7 86 88 00 00 00 24 	movl   $0x803024,0x88(%esi)
  800d38:	30 80 00 
	return 0;
}
  800d3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d40:	83 c4 10             	add    $0x10,%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 14             	sub    $0x14,%esp
  800d4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800d51:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d5c:	e8 db f4 ff ff       	call   80023c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800d61:	89 1c 24             	mov    %ebx,(%esp)
  800d64:	e8 a7 f6 ff ff       	call   800410 <fd2data>
  800d69:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d74:	e8 c3 f4 ff ff       	call   80023c <sys_page_unmap>
}
  800d79:	83 c4 14             	add    $0x14,%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	83 ec 2c             	sub    $0x2c,%esp
  800d88:	89 c7                	mov    %eax,%edi
  800d8a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800d8d:	a1 04 40 80 00       	mov    0x804004,%eax
  800d92:	8b 00                	mov    (%eax),%eax
  800d94:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800d97:	89 3c 24             	mov    %edi,(%esp)
  800d9a:	e8 51 0f 00 00       	call   801cf0 <pageref>
  800d9f:	89 c6                	mov    %eax,%esi
  800da1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800da4:	89 04 24             	mov    %eax,(%esp)
  800da7:	e8 44 0f 00 00       	call   801cf0 <pageref>
  800dac:	39 c6                	cmp    %eax,%esi
  800dae:	0f 94 c0             	sete   %al
  800db1:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800db4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800dba:	8b 12                	mov    (%edx),%edx
  800dbc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800dbf:	39 cb                	cmp    %ecx,%ebx
  800dc1:	75 08                	jne    800dcb <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800dc3:	83 c4 2c             	add    $0x2c,%esp
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800dcb:	83 f8 01             	cmp    $0x1,%eax
  800dce:	75 bd                	jne    800d8d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800dd0:	8b 42 58             	mov    0x58(%edx),%eax
  800dd3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800dda:	00 
  800ddb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ddf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800de3:	c7 04 24 aa 20 80 00 	movl   $0x8020aa,(%esp)
  800dea:	e8 19 05 00 00       	call   801308 <cprintf>
  800def:	eb 9c                	jmp    800d8d <_pipeisclosed+0xe>

00800df1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	57                   	push   %edi
  800df5:	56                   	push   %esi
  800df6:	53                   	push   %ebx
  800df7:	83 ec 1c             	sub    $0x1c,%esp
  800dfa:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800dfd:	89 34 24             	mov    %esi,(%esp)
  800e00:	e8 0b f6 ff ff       	call   800410 <fd2data>
  800e05:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e07:	bf 00 00 00 00       	mov    $0x0,%edi
  800e0c:	eb 3c                	jmp    800e4a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800e0e:	89 da                	mov    %ebx,%edx
  800e10:	89 f0                	mov    %esi,%eax
  800e12:	e8 68 ff ff ff       	call   800d7f <_pipeisclosed>
  800e17:	85 c0                	test   %eax,%eax
  800e19:	75 38                	jne    800e53 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800e1b:	e8 56 f3 ff ff       	call   800176 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800e20:	8b 43 04             	mov    0x4(%ebx),%eax
  800e23:	8b 13                	mov    (%ebx),%edx
  800e25:	83 c2 20             	add    $0x20,%edx
  800e28:	39 d0                	cmp    %edx,%eax
  800e2a:	73 e2                	jae    800e0e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800e2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e2f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800e32:	89 c2                	mov    %eax,%edx
  800e34:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800e3a:	79 05                	jns    800e41 <devpipe_write+0x50>
  800e3c:	4a                   	dec    %edx
  800e3d:	83 ca e0             	or     $0xffffffe0,%edx
  800e40:	42                   	inc    %edx
  800e41:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800e45:	40                   	inc    %eax
  800e46:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e49:	47                   	inc    %edi
  800e4a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800e4d:	75 d1                	jne    800e20 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800e4f:	89 f8                	mov    %edi,%eax
  800e51:	eb 05                	jmp    800e58 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e53:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800e58:	83 c4 1c             	add    $0x1c,%esp
  800e5b:	5b                   	pop    %ebx
  800e5c:	5e                   	pop    %esi
  800e5d:	5f                   	pop    %edi
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	83 ec 1c             	sub    $0x1c,%esp
  800e69:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800e6c:	89 3c 24             	mov    %edi,(%esp)
  800e6f:	e8 9c f5 ff ff       	call   800410 <fd2data>
  800e74:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e76:	be 00 00 00 00       	mov    $0x0,%esi
  800e7b:	eb 3a                	jmp    800eb7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800e7d:	85 f6                	test   %esi,%esi
  800e7f:	74 04                	je     800e85 <devpipe_read+0x25>
				return i;
  800e81:	89 f0                	mov    %esi,%eax
  800e83:	eb 40                	jmp    800ec5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800e85:	89 da                	mov    %ebx,%edx
  800e87:	89 f8                	mov    %edi,%eax
  800e89:	e8 f1 fe ff ff       	call   800d7f <_pipeisclosed>
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	75 2e                	jne    800ec0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800e92:	e8 df f2 ff ff       	call   800176 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800e97:	8b 03                	mov    (%ebx),%eax
  800e99:	3b 43 04             	cmp    0x4(%ebx),%eax
  800e9c:	74 df                	je     800e7d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800e9e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800ea3:	79 05                	jns    800eaa <devpipe_read+0x4a>
  800ea5:	48                   	dec    %eax
  800ea6:	83 c8 e0             	or     $0xffffffe0,%eax
  800ea9:	40                   	inc    %eax
  800eaa:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800eae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800eb4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800eb6:	46                   	inc    %esi
  800eb7:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eba:	75 db                	jne    800e97 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ebc:	89 f0                	mov    %esi,%eax
  800ebe:	eb 05                	jmp    800ec5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ec0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800ec5:	83 c4 1c             	add    $0x1c,%esp
  800ec8:	5b                   	pop    %ebx
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	57                   	push   %edi
  800ed1:	56                   	push   %esi
  800ed2:	53                   	push   %ebx
  800ed3:	83 ec 3c             	sub    $0x3c,%esp
  800ed6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800ed9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800edc:	89 04 24             	mov    %eax,(%esp)
  800edf:	e8 47 f5 ff ff       	call   80042b <fd_alloc>
  800ee4:	89 c3                	mov    %eax,%ebx
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	0f 88 45 01 00 00    	js     801033 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800eee:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ef5:	00 
  800ef6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ef9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800efd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f04:	e8 8c f2 ff ff       	call   800195 <sys_page_alloc>
  800f09:	89 c3                	mov    %eax,%ebx
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	0f 88 20 01 00 00    	js     801033 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800f13:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f16:	89 04 24             	mov    %eax,(%esp)
  800f19:	e8 0d f5 ff ff       	call   80042b <fd_alloc>
  800f1e:	89 c3                	mov    %eax,%ebx
  800f20:	85 c0                	test   %eax,%eax
  800f22:	0f 88 f8 00 00 00    	js     801020 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f28:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f2f:	00 
  800f30:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f3e:	e8 52 f2 ff ff       	call   800195 <sys_page_alloc>
  800f43:	89 c3                	mov    %eax,%ebx
  800f45:	85 c0                	test   %eax,%eax
  800f47:	0f 88 d3 00 00 00    	js     801020 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800f4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f50:	89 04 24             	mov    %eax,(%esp)
  800f53:	e8 b8 f4 ff ff       	call   800410 <fd2data>
  800f58:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f5a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f61:	00 
  800f62:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f6d:	e8 23 f2 ff ff       	call   800195 <sys_page_alloc>
  800f72:	89 c3                	mov    %eax,%ebx
  800f74:	85 c0                	test   %eax,%eax
  800f76:	0f 88 91 00 00 00    	js     80100d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f7f:	89 04 24             	mov    %eax,(%esp)
  800f82:	e8 89 f4 ff ff       	call   800410 <fd2data>
  800f87:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800f8e:	00 
  800f8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f93:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f9a:	00 
  800f9b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa6:	e8 3e f2 ff ff       	call   8001e9 <sys_page_map>
  800fab:	89 c3                	mov    %eax,%ebx
  800fad:	85 c0                	test   %eax,%eax
  800faf:	78 4c                	js     800ffd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800fb1:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800fb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fba:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800fbc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fbf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800fc6:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800fcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fcf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800fd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fd4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800fdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fde:	89 04 24             	mov    %eax,(%esp)
  800fe1:	e8 1a f4 ff ff       	call   800400 <fd2num>
  800fe6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800fe8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800feb:	89 04 24             	mov    %eax,(%esp)
  800fee:	e8 0d f4 ff ff       	call   800400 <fd2num>
  800ff3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800ff6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ffb:	eb 36                	jmp    801033 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  800ffd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801001:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801008:	e8 2f f2 ff ff       	call   80023c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80100d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801010:	89 44 24 04          	mov    %eax,0x4(%esp)
  801014:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80101b:	e8 1c f2 ff ff       	call   80023c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801020:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801023:	89 44 24 04          	mov    %eax,0x4(%esp)
  801027:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80102e:	e8 09 f2 ff ff       	call   80023c <sys_page_unmap>
    err:
	return r;
}
  801033:	89 d8                	mov    %ebx,%eax
  801035:	83 c4 3c             	add    $0x3c,%esp
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801043:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104a:	8b 45 08             	mov    0x8(%ebp),%eax
  80104d:	89 04 24             	mov    %eax,(%esp)
  801050:	e8 29 f4 ff ff       	call   80047e <fd_lookup>
  801055:	85 c0                	test   %eax,%eax
  801057:	78 15                	js     80106e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801059:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105c:	89 04 24             	mov    %eax,(%esp)
  80105f:	e8 ac f3 ff ff       	call   800410 <fd2data>
	return _pipeisclosed(fd, p);
  801064:	89 c2                	mov    %eax,%edx
  801066:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801069:	e8 11 fd ff ff       	call   800d7f <_pipeisclosed>
}
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    

00801070 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801073:	b8 00 00 00 00       	mov    $0x0,%eax
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    

0080107a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801080:	c7 44 24 04 c2 20 80 	movl   $0x8020c2,0x4(%esp)
  801087:	00 
  801088:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108b:	89 04 24             	mov    %eax,(%esp)
  80108e:	e8 20 08 00 00       	call   8018b3 <strcpy>
	return 0;
}
  801093:	b8 00 00 00 00       	mov    $0x0,%eax
  801098:	c9                   	leave  
  801099:	c3                   	ret    

0080109a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	57                   	push   %edi
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
  8010a0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8010ab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010b1:	eb 30                	jmp    8010e3 <devcons_write+0x49>
		m = n - tot;
  8010b3:	8b 75 10             	mov    0x10(%ebp),%esi
  8010b6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8010b8:	83 fe 7f             	cmp    $0x7f,%esi
  8010bb:	76 05                	jbe    8010c2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8010bd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8010c2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010c6:	03 45 0c             	add    0xc(%ebp),%eax
  8010c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010cd:	89 3c 24             	mov    %edi,(%esp)
  8010d0:	e8 57 09 00 00       	call   801a2c <memmove>
		sys_cputs(buf, m);
  8010d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010d9:	89 3c 24             	mov    %edi,(%esp)
  8010dc:	e8 e7 ef ff ff       	call   8000c8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010e1:	01 f3                	add    %esi,%ebx
  8010e3:	89 d8                	mov    %ebx,%eax
  8010e5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010e8:	72 c9                	jb     8010b3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8010ea:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8010fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010ff:	75 07                	jne    801108 <devcons_read+0x13>
  801101:	eb 25                	jmp    801128 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801103:	e8 6e f0 ff ff       	call   800176 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801108:	e8 d9 ef ff ff       	call   8000e6 <sys_cgetc>
  80110d:	85 c0                	test   %eax,%eax
  80110f:	74 f2                	je     801103 <devcons_read+0xe>
  801111:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801113:	85 c0                	test   %eax,%eax
  801115:	78 1d                	js     801134 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801117:	83 f8 04             	cmp    $0x4,%eax
  80111a:	74 13                	je     80112f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80111c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80111f:	88 10                	mov    %dl,(%eax)
	return 1;
  801121:	b8 01 00 00 00       	mov    $0x1,%eax
  801126:	eb 0c                	jmp    801134 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801128:	b8 00 00 00 00       	mov    $0x0,%eax
  80112d:	eb 05                	jmp    801134 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80112f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801134:	c9                   	leave  
  801135:	c3                   	ret    

00801136 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80113c:	8b 45 08             	mov    0x8(%ebp),%eax
  80113f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801142:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801149:	00 
  80114a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80114d:	89 04 24             	mov    %eax,(%esp)
  801150:	e8 73 ef ff ff       	call   8000c8 <sys_cputs>
}
  801155:	c9                   	leave  
  801156:	c3                   	ret    

00801157 <getchar>:

int
getchar(void)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80115d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801164:	00 
  801165:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801168:	89 44 24 04          	mov    %eax,0x4(%esp)
  80116c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801173:	e8 a4 f5 ff ff       	call   80071c <read>
	if (r < 0)
  801178:	85 c0                	test   %eax,%eax
  80117a:	78 0f                	js     80118b <getchar+0x34>
		return r;
	if (r < 1)
  80117c:	85 c0                	test   %eax,%eax
  80117e:	7e 06                	jle    801186 <getchar+0x2f>
		return -E_EOF;
	return c;
  801180:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801184:	eb 05                	jmp    80118b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801186:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80118b:	c9                   	leave  
  80118c:	c3                   	ret    

0080118d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801193:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119a:	8b 45 08             	mov    0x8(%ebp),%eax
  80119d:	89 04 24             	mov    %eax,(%esp)
  8011a0:	e8 d9 f2 ff ff       	call   80047e <fd_lookup>
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	78 11                	js     8011ba <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8011a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ac:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8011b2:	39 10                	cmp    %edx,(%eax)
  8011b4:	0f 94 c0             	sete   %al
  8011b7:	0f b6 c0             	movzbl %al,%eax
}
  8011ba:	c9                   	leave  
  8011bb:	c3                   	ret    

008011bc <opencons>:

int
opencons(void)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8011c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c5:	89 04 24             	mov    %eax,(%esp)
  8011c8:	e8 5e f2 ff ff       	call   80042b <fd_alloc>
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	78 3c                	js     80120d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8011d1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8011d8:	00 
  8011d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e7:	e8 a9 ef ff ff       	call   800195 <sys_page_alloc>
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	78 1d                	js     80120d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8011f0:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8011f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8011fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011fe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801205:	89 04 24             	mov    %eax,(%esp)
  801208:	e8 f3 f1 ff ff       	call   800400 <fd2num>
}
  80120d:	c9                   	leave  
  80120e:	c3                   	ret    
	...

00801210 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	56                   	push   %esi
  801214:	53                   	push   %ebx
  801215:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801218:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80121b:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  801221:	e8 31 ef ff ff       	call   800157 <sys_getenvid>
  801226:	8b 55 0c             	mov    0xc(%ebp),%edx
  801229:	89 54 24 10          	mov    %edx,0x10(%esp)
  80122d:	8b 55 08             	mov    0x8(%ebp),%edx
  801230:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801234:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123c:	c7 04 24 d0 20 80 00 	movl   $0x8020d0,(%esp)
  801243:	e8 c0 00 00 00       	call   801308 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801248:	89 74 24 04          	mov    %esi,0x4(%esp)
  80124c:	8b 45 10             	mov    0x10(%ebp),%eax
  80124f:	89 04 24             	mov    %eax,(%esp)
  801252:	e8 50 00 00 00       	call   8012a7 <vcprintf>
	cprintf("\n");
  801257:	c7 04 24 10 24 80 00 	movl   $0x802410,(%esp)
  80125e:	e8 a5 00 00 00       	call   801308 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801263:	cc                   	int3   
  801264:	eb fd                	jmp    801263 <_panic+0x53>
	...

00801268 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	53                   	push   %ebx
  80126c:	83 ec 14             	sub    $0x14,%esp
  80126f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801272:	8b 03                	mov    (%ebx),%eax
  801274:	8b 55 08             	mov    0x8(%ebp),%edx
  801277:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80127b:	40                   	inc    %eax
  80127c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80127e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801283:	75 19                	jne    80129e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801285:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80128c:	00 
  80128d:	8d 43 08             	lea    0x8(%ebx),%eax
  801290:	89 04 24             	mov    %eax,(%esp)
  801293:	e8 30 ee ff ff       	call   8000c8 <sys_cputs>
		b->idx = 0;
  801298:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80129e:	ff 43 04             	incl   0x4(%ebx)
}
  8012a1:	83 c4 14             	add    $0x14,%esp
  8012a4:	5b                   	pop    %ebx
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    

008012a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8012b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8012b7:	00 00 00 
	b.cnt = 0;
  8012ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8012c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8012c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8012d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012dc:	c7 04 24 68 12 80 00 	movl   $0x801268,(%esp)
  8012e3:	e8 82 01 00 00       	call   80146a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8012e8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8012ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8012f8:	89 04 24             	mov    %eax,(%esp)
  8012fb:	e8 c8 ed ff ff       	call   8000c8 <sys_cputs>

	return b.cnt;
}
  801300:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801306:	c9                   	leave  
  801307:	c3                   	ret    

00801308 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80130e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801311:	89 44 24 04          	mov    %eax,0x4(%esp)
  801315:	8b 45 08             	mov    0x8(%ebp),%eax
  801318:	89 04 24             	mov    %eax,(%esp)
  80131b:	e8 87 ff ff ff       	call   8012a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  801320:	c9                   	leave  
  801321:	c3                   	ret    
	...

00801324 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	57                   	push   %edi
  801328:	56                   	push   %esi
  801329:	53                   	push   %ebx
  80132a:	83 ec 3c             	sub    $0x3c,%esp
  80132d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801330:	89 d7                	mov    %edx,%edi
  801332:	8b 45 08             	mov    0x8(%ebp),%eax
  801335:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801338:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80133e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801341:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801344:	85 c0                	test   %eax,%eax
  801346:	75 08                	jne    801350 <printnum+0x2c>
  801348:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80134b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80134e:	77 57                	ja     8013a7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801350:	89 74 24 10          	mov    %esi,0x10(%esp)
  801354:	4b                   	dec    %ebx
  801355:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801359:	8b 45 10             	mov    0x10(%ebp),%eax
  80135c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801360:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801364:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801368:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80136f:	00 
  801370:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801373:	89 04 24             	mov    %eax,(%esp)
  801376:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801379:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137d:	e8 b2 09 00 00       	call   801d34 <__udivdi3>
  801382:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801386:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80138a:	89 04 24             	mov    %eax,(%esp)
  80138d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801391:	89 fa                	mov    %edi,%edx
  801393:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801396:	e8 89 ff ff ff       	call   801324 <printnum>
  80139b:	eb 0f                	jmp    8013ac <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80139d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013a1:	89 34 24             	mov    %esi,(%esp)
  8013a4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8013a7:	4b                   	dec    %ebx
  8013a8:	85 db                	test   %ebx,%ebx
  8013aa:	7f f1                	jg     80139d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8013ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8013b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013bb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013c2:	00 
  8013c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013c6:	89 04 24             	mov    %eax,(%esp)
  8013c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d0:	e8 7f 0a 00 00       	call   801e54 <__umoddi3>
  8013d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013d9:	0f be 80 f3 20 80 00 	movsbl 0x8020f3(%eax),%eax
  8013e0:	89 04 24             	mov    %eax,(%esp)
  8013e3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8013e6:	83 c4 3c             	add    $0x3c,%esp
  8013e9:	5b                   	pop    %ebx
  8013ea:	5e                   	pop    %esi
  8013eb:	5f                   	pop    %edi
  8013ec:	5d                   	pop    %ebp
  8013ed:	c3                   	ret    

008013ee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8013f1:	83 fa 01             	cmp    $0x1,%edx
  8013f4:	7e 0e                	jle    801404 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8013f6:	8b 10                	mov    (%eax),%edx
  8013f8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8013fb:	89 08                	mov    %ecx,(%eax)
  8013fd:	8b 02                	mov    (%edx),%eax
  8013ff:	8b 52 04             	mov    0x4(%edx),%edx
  801402:	eb 22                	jmp    801426 <getuint+0x38>
	else if (lflag)
  801404:	85 d2                	test   %edx,%edx
  801406:	74 10                	je     801418 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801408:	8b 10                	mov    (%eax),%edx
  80140a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80140d:	89 08                	mov    %ecx,(%eax)
  80140f:	8b 02                	mov    (%edx),%eax
  801411:	ba 00 00 00 00       	mov    $0x0,%edx
  801416:	eb 0e                	jmp    801426 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801418:	8b 10                	mov    (%eax),%edx
  80141a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80141d:	89 08                	mov    %ecx,(%eax)
  80141f:	8b 02                	mov    (%edx),%eax
  801421:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    

00801428 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80142e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801431:	8b 10                	mov    (%eax),%edx
  801433:	3b 50 04             	cmp    0x4(%eax),%edx
  801436:	73 08                	jae    801440 <sprintputch+0x18>
		*b->buf++ = ch;
  801438:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80143b:	88 0a                	mov    %cl,(%edx)
  80143d:	42                   	inc    %edx
  80143e:	89 10                	mov    %edx,(%eax)
}
  801440:	5d                   	pop    %ebp
  801441:	c3                   	ret    

00801442 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801448:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80144b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80144f:	8b 45 10             	mov    0x10(%ebp),%eax
  801452:	89 44 24 08          	mov    %eax,0x8(%esp)
  801456:	8b 45 0c             	mov    0xc(%ebp),%eax
  801459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145d:	8b 45 08             	mov    0x8(%ebp),%eax
  801460:	89 04 24             	mov    %eax,(%esp)
  801463:	e8 02 00 00 00       	call   80146a <vprintfmt>
	va_end(ap);
}
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	57                   	push   %edi
  80146e:	56                   	push   %esi
  80146f:	53                   	push   %ebx
  801470:	83 ec 4c             	sub    $0x4c,%esp
  801473:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801476:	8b 75 10             	mov    0x10(%ebp),%esi
  801479:	eb 12                	jmp    80148d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80147b:	85 c0                	test   %eax,%eax
  80147d:	0f 84 6b 03 00 00    	je     8017ee <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  801483:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801487:	89 04 24             	mov    %eax,(%esp)
  80148a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80148d:	0f b6 06             	movzbl (%esi),%eax
  801490:	46                   	inc    %esi
  801491:	83 f8 25             	cmp    $0x25,%eax
  801494:	75 e5                	jne    80147b <vprintfmt+0x11>
  801496:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80149a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8014a1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8014a6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8014ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014b2:	eb 26                	jmp    8014da <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8014b7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8014bb:	eb 1d                	jmp    8014da <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014bd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8014c0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8014c4:	eb 14                	jmp    8014da <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8014c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8014d0:	eb 08                	jmp    8014da <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8014d2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8014d5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014da:	0f b6 06             	movzbl (%esi),%eax
  8014dd:	8d 56 01             	lea    0x1(%esi),%edx
  8014e0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8014e3:	8a 16                	mov    (%esi),%dl
  8014e5:	83 ea 23             	sub    $0x23,%edx
  8014e8:	80 fa 55             	cmp    $0x55,%dl
  8014eb:	0f 87 e1 02 00 00    	ja     8017d2 <vprintfmt+0x368>
  8014f1:	0f b6 d2             	movzbl %dl,%edx
  8014f4:	ff 24 95 40 22 80 00 	jmp    *0x802240(,%edx,4)
  8014fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8014fe:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801503:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801506:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80150a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80150d:	8d 50 d0             	lea    -0x30(%eax),%edx
  801510:	83 fa 09             	cmp    $0x9,%edx
  801513:	77 2a                	ja     80153f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801515:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801516:	eb eb                	jmp    801503 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801518:	8b 45 14             	mov    0x14(%ebp),%eax
  80151b:	8d 50 04             	lea    0x4(%eax),%edx
  80151e:	89 55 14             	mov    %edx,0x14(%ebp)
  801521:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801523:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801526:	eb 17                	jmp    80153f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801528:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80152c:	78 98                	js     8014c6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80152e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801531:	eb a7                	jmp    8014da <vprintfmt+0x70>
  801533:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801536:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80153d:	eb 9b                	jmp    8014da <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80153f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801543:	79 95                	jns    8014da <vprintfmt+0x70>
  801545:	eb 8b                	jmp    8014d2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801547:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801548:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80154b:	eb 8d                	jmp    8014da <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80154d:	8b 45 14             	mov    0x14(%ebp),%eax
  801550:	8d 50 04             	lea    0x4(%eax),%edx
  801553:	89 55 14             	mov    %edx,0x14(%ebp)
  801556:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80155a:	8b 00                	mov    (%eax),%eax
  80155c:	89 04 24             	mov    %eax,(%esp)
  80155f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801562:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801565:	e9 23 ff ff ff       	jmp    80148d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80156a:	8b 45 14             	mov    0x14(%ebp),%eax
  80156d:	8d 50 04             	lea    0x4(%eax),%edx
  801570:	89 55 14             	mov    %edx,0x14(%ebp)
  801573:	8b 00                	mov    (%eax),%eax
  801575:	85 c0                	test   %eax,%eax
  801577:	79 02                	jns    80157b <vprintfmt+0x111>
  801579:	f7 d8                	neg    %eax
  80157b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80157d:	83 f8 0f             	cmp    $0xf,%eax
  801580:	7f 0b                	jg     80158d <vprintfmt+0x123>
  801582:	8b 04 85 a0 23 80 00 	mov    0x8023a0(,%eax,4),%eax
  801589:	85 c0                	test   %eax,%eax
  80158b:	75 23                	jne    8015b0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80158d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801591:	c7 44 24 08 0b 21 80 	movl   $0x80210b,0x8(%esp)
  801598:	00 
  801599:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80159d:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a0:	89 04 24             	mov    %eax,(%esp)
  8015a3:	e8 9a fe ff ff       	call   801442 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8015ab:	e9 dd fe ff ff       	jmp    80148d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8015b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015b4:	c7 44 24 08 89 20 80 	movl   $0x802089,0x8(%esp)
  8015bb:	00 
  8015bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c3:	89 14 24             	mov    %edx,(%esp)
  8015c6:	e8 77 fe ff ff       	call   801442 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8015ce:	e9 ba fe ff ff       	jmp    80148d <vprintfmt+0x23>
  8015d3:	89 f9                	mov    %edi,%ecx
  8015d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8015db:	8b 45 14             	mov    0x14(%ebp),%eax
  8015de:	8d 50 04             	lea    0x4(%eax),%edx
  8015e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8015e4:	8b 30                	mov    (%eax),%esi
  8015e6:	85 f6                	test   %esi,%esi
  8015e8:	75 05                	jne    8015ef <vprintfmt+0x185>
				p = "(null)";
  8015ea:	be 04 21 80 00       	mov    $0x802104,%esi
			if (width > 0 && padc != '-')
  8015ef:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8015f3:	0f 8e 84 00 00 00    	jle    80167d <vprintfmt+0x213>
  8015f9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8015fd:	74 7e                	je     80167d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8015ff:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801603:	89 34 24             	mov    %esi,(%esp)
  801606:	e8 8b 02 00 00       	call   801896 <strnlen>
  80160b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80160e:	29 c2                	sub    %eax,%edx
  801610:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801613:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801617:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80161a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80161d:	89 de                	mov    %ebx,%esi
  80161f:	89 d3                	mov    %edx,%ebx
  801621:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801623:	eb 0b                	jmp    801630 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801625:	89 74 24 04          	mov    %esi,0x4(%esp)
  801629:	89 3c 24             	mov    %edi,(%esp)
  80162c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80162f:	4b                   	dec    %ebx
  801630:	85 db                	test   %ebx,%ebx
  801632:	7f f1                	jg     801625 <vprintfmt+0x1bb>
  801634:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801637:	89 f3                	mov    %esi,%ebx
  801639:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80163c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80163f:	85 c0                	test   %eax,%eax
  801641:	79 05                	jns    801648 <vprintfmt+0x1de>
  801643:	b8 00 00 00 00       	mov    $0x0,%eax
  801648:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80164b:	29 c2                	sub    %eax,%edx
  80164d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801650:	eb 2b                	jmp    80167d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801652:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801656:	74 18                	je     801670 <vprintfmt+0x206>
  801658:	8d 50 e0             	lea    -0x20(%eax),%edx
  80165b:	83 fa 5e             	cmp    $0x5e,%edx
  80165e:	76 10                	jbe    801670 <vprintfmt+0x206>
					putch('?', putdat);
  801660:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801664:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80166b:	ff 55 08             	call   *0x8(%ebp)
  80166e:	eb 0a                	jmp    80167a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801670:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801674:	89 04 24             	mov    %eax,(%esp)
  801677:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80167a:	ff 4d e4             	decl   -0x1c(%ebp)
  80167d:	0f be 06             	movsbl (%esi),%eax
  801680:	46                   	inc    %esi
  801681:	85 c0                	test   %eax,%eax
  801683:	74 21                	je     8016a6 <vprintfmt+0x23c>
  801685:	85 ff                	test   %edi,%edi
  801687:	78 c9                	js     801652 <vprintfmt+0x1e8>
  801689:	4f                   	dec    %edi
  80168a:	79 c6                	jns    801652 <vprintfmt+0x1e8>
  80168c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80168f:	89 de                	mov    %ebx,%esi
  801691:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801694:	eb 18                	jmp    8016ae <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801696:	89 74 24 04          	mov    %esi,0x4(%esp)
  80169a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8016a1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8016a3:	4b                   	dec    %ebx
  8016a4:	eb 08                	jmp    8016ae <vprintfmt+0x244>
  8016a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016a9:	89 de                	mov    %ebx,%esi
  8016ab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8016ae:	85 db                	test   %ebx,%ebx
  8016b0:	7f e4                	jg     801696 <vprintfmt+0x22c>
  8016b2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8016b5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8016ba:	e9 ce fd ff ff       	jmp    80148d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8016bf:	83 f9 01             	cmp    $0x1,%ecx
  8016c2:	7e 10                	jle    8016d4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8016c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c7:	8d 50 08             	lea    0x8(%eax),%edx
  8016ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8016cd:	8b 30                	mov    (%eax),%esi
  8016cf:	8b 78 04             	mov    0x4(%eax),%edi
  8016d2:	eb 26                	jmp    8016fa <vprintfmt+0x290>
	else if (lflag)
  8016d4:	85 c9                	test   %ecx,%ecx
  8016d6:	74 12                	je     8016ea <vprintfmt+0x280>
		return va_arg(*ap, long);
  8016d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8016db:	8d 50 04             	lea    0x4(%eax),%edx
  8016de:	89 55 14             	mov    %edx,0x14(%ebp)
  8016e1:	8b 30                	mov    (%eax),%esi
  8016e3:	89 f7                	mov    %esi,%edi
  8016e5:	c1 ff 1f             	sar    $0x1f,%edi
  8016e8:	eb 10                	jmp    8016fa <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8016ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ed:	8d 50 04             	lea    0x4(%eax),%edx
  8016f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8016f3:	8b 30                	mov    (%eax),%esi
  8016f5:	89 f7                	mov    %esi,%edi
  8016f7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8016fa:	85 ff                	test   %edi,%edi
  8016fc:	78 0a                	js     801708 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8016fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  801703:	e9 8c 00 00 00       	jmp    801794 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801708:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80170c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801713:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801716:	f7 de                	neg    %esi
  801718:	83 d7 00             	adc    $0x0,%edi
  80171b:	f7 df                	neg    %edi
			}
			base = 10;
  80171d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801722:	eb 70                	jmp    801794 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801724:	89 ca                	mov    %ecx,%edx
  801726:	8d 45 14             	lea    0x14(%ebp),%eax
  801729:	e8 c0 fc ff ff       	call   8013ee <getuint>
  80172e:	89 c6                	mov    %eax,%esi
  801730:	89 d7                	mov    %edx,%edi
			base = 10;
  801732:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801737:	eb 5b                	jmp    801794 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801739:	89 ca                	mov    %ecx,%edx
  80173b:	8d 45 14             	lea    0x14(%ebp),%eax
  80173e:	e8 ab fc ff ff       	call   8013ee <getuint>
  801743:	89 c6                	mov    %eax,%esi
  801745:	89 d7                	mov    %edx,%edi
			base = 8;
  801747:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80174c:	eb 46                	jmp    801794 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80174e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801752:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801759:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80175c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801760:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801767:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80176a:	8b 45 14             	mov    0x14(%ebp),%eax
  80176d:	8d 50 04             	lea    0x4(%eax),%edx
  801770:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801773:	8b 30                	mov    (%eax),%esi
  801775:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80177a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80177f:	eb 13                	jmp    801794 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801781:	89 ca                	mov    %ecx,%edx
  801783:	8d 45 14             	lea    0x14(%ebp),%eax
  801786:	e8 63 fc ff ff       	call   8013ee <getuint>
  80178b:	89 c6                	mov    %eax,%esi
  80178d:	89 d7                	mov    %edx,%edi
			base = 16;
  80178f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801794:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801798:	89 54 24 10          	mov    %edx,0x10(%esp)
  80179c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80179f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017a7:	89 34 24             	mov    %esi,(%esp)
  8017aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017ae:	89 da                	mov    %ebx,%edx
  8017b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b3:	e8 6c fb ff ff       	call   801324 <printnum>
			break;
  8017b8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8017bb:	e9 cd fc ff ff       	jmp    80148d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8017c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c4:	89 04 24             	mov    %eax,(%esp)
  8017c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8017cd:	e9 bb fc ff ff       	jmp    80148d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8017d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017d6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017dd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017e0:	eb 01                	jmp    8017e3 <vprintfmt+0x379>
  8017e2:	4e                   	dec    %esi
  8017e3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8017e7:	75 f9                	jne    8017e2 <vprintfmt+0x378>
  8017e9:	e9 9f fc ff ff       	jmp    80148d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8017ee:	83 c4 4c             	add    $0x4c,%esp
  8017f1:	5b                   	pop    %ebx
  8017f2:	5e                   	pop    %esi
  8017f3:	5f                   	pop    %edi
  8017f4:	5d                   	pop    %ebp
  8017f5:	c3                   	ret    

008017f6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	83 ec 28             	sub    $0x28,%esp
  8017fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801802:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801805:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801809:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80180c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801813:	85 c0                	test   %eax,%eax
  801815:	74 30                	je     801847 <vsnprintf+0x51>
  801817:	85 d2                	test   %edx,%edx
  801819:	7e 33                	jle    80184e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80181b:	8b 45 14             	mov    0x14(%ebp),%eax
  80181e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801822:	8b 45 10             	mov    0x10(%ebp),%eax
  801825:	89 44 24 08          	mov    %eax,0x8(%esp)
  801829:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80182c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801830:	c7 04 24 28 14 80 00 	movl   $0x801428,(%esp)
  801837:	e8 2e fc ff ff       	call   80146a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80183c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80183f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801845:	eb 0c                	jmp    801853 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80184c:	eb 05                	jmp    801853 <vsnprintf+0x5d>
  80184e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801853:	c9                   	leave  
  801854:	c3                   	ret    

00801855 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80185b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80185e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801862:	8b 45 10             	mov    0x10(%ebp),%eax
  801865:	89 44 24 08          	mov    %eax,0x8(%esp)
  801869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801870:	8b 45 08             	mov    0x8(%ebp),%eax
  801873:	89 04 24             	mov    %eax,(%esp)
  801876:	e8 7b ff ff ff       	call   8017f6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80187b:	c9                   	leave  
  80187c:	c3                   	ret    
  80187d:	00 00                	add    %al,(%eax)
	...

00801880 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801886:	b8 00 00 00 00       	mov    $0x0,%eax
  80188b:	eb 01                	jmp    80188e <strlen+0xe>
		n++;
  80188d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80188e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801892:	75 f9                	jne    80188d <strlen+0xd>
		n++;
	return n;
}
  801894:	5d                   	pop    %ebp
  801895:	c3                   	ret    

00801896 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80189c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80189f:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a4:	eb 01                	jmp    8018a7 <strnlen+0x11>
		n++;
  8018a6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8018a7:	39 d0                	cmp    %edx,%eax
  8018a9:	74 06                	je     8018b1 <strnlen+0x1b>
  8018ab:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8018af:	75 f5                	jne    8018a6 <strnlen+0x10>
		n++;
	return n;
}
  8018b1:	5d                   	pop    %ebp
  8018b2:	c3                   	ret    

008018b3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	53                   	push   %ebx
  8018b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8018bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8018c5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8018c8:	42                   	inc    %edx
  8018c9:	84 c9                	test   %cl,%cl
  8018cb:	75 f5                	jne    8018c2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8018cd:	5b                   	pop    %ebx
  8018ce:	5d                   	pop    %ebp
  8018cf:	c3                   	ret    

008018d0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	53                   	push   %ebx
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8018da:	89 1c 24             	mov    %ebx,(%esp)
  8018dd:	e8 9e ff ff ff       	call   801880 <strlen>
	strcpy(dst + len, src);
  8018e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018e9:	01 d8                	add    %ebx,%eax
  8018eb:	89 04 24             	mov    %eax,(%esp)
  8018ee:	e8 c0 ff ff ff       	call   8018b3 <strcpy>
	return dst;
}
  8018f3:	89 d8                	mov    %ebx,%eax
  8018f5:	83 c4 08             	add    $0x8,%esp
  8018f8:	5b                   	pop    %ebx
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    

008018fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	56                   	push   %esi
  8018ff:	53                   	push   %ebx
  801900:	8b 45 08             	mov    0x8(%ebp),%eax
  801903:	8b 55 0c             	mov    0xc(%ebp),%edx
  801906:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801909:	b9 00 00 00 00       	mov    $0x0,%ecx
  80190e:	eb 0c                	jmp    80191c <strncpy+0x21>
		*dst++ = *src;
  801910:	8a 1a                	mov    (%edx),%bl
  801912:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801915:	80 3a 01             	cmpb   $0x1,(%edx)
  801918:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80191b:	41                   	inc    %ecx
  80191c:	39 f1                	cmp    %esi,%ecx
  80191e:	75 f0                	jne    801910 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801920:	5b                   	pop    %ebx
  801921:	5e                   	pop    %esi
  801922:	5d                   	pop    %ebp
  801923:	c3                   	ret    

00801924 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	56                   	push   %esi
  801928:	53                   	push   %ebx
  801929:	8b 75 08             	mov    0x8(%ebp),%esi
  80192c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80192f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801932:	85 d2                	test   %edx,%edx
  801934:	75 0a                	jne    801940 <strlcpy+0x1c>
  801936:	89 f0                	mov    %esi,%eax
  801938:	eb 1a                	jmp    801954 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80193a:	88 18                	mov    %bl,(%eax)
  80193c:	40                   	inc    %eax
  80193d:	41                   	inc    %ecx
  80193e:	eb 02                	jmp    801942 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801940:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801942:	4a                   	dec    %edx
  801943:	74 0a                	je     80194f <strlcpy+0x2b>
  801945:	8a 19                	mov    (%ecx),%bl
  801947:	84 db                	test   %bl,%bl
  801949:	75 ef                	jne    80193a <strlcpy+0x16>
  80194b:	89 c2                	mov    %eax,%edx
  80194d:	eb 02                	jmp    801951 <strlcpy+0x2d>
  80194f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801951:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801954:	29 f0                	sub    %esi,%eax
}
  801956:	5b                   	pop    %ebx
  801957:	5e                   	pop    %esi
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801960:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801963:	eb 02                	jmp    801967 <strcmp+0xd>
		p++, q++;
  801965:	41                   	inc    %ecx
  801966:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801967:	8a 01                	mov    (%ecx),%al
  801969:	84 c0                	test   %al,%al
  80196b:	74 04                	je     801971 <strcmp+0x17>
  80196d:	3a 02                	cmp    (%edx),%al
  80196f:	74 f4                	je     801965 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801971:	0f b6 c0             	movzbl %al,%eax
  801974:	0f b6 12             	movzbl (%edx),%edx
  801977:	29 d0                	sub    %edx,%eax
}
  801979:	5d                   	pop    %ebp
  80197a:	c3                   	ret    

0080197b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	53                   	push   %ebx
  80197f:	8b 45 08             	mov    0x8(%ebp),%eax
  801982:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801985:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801988:	eb 03                	jmp    80198d <strncmp+0x12>
		n--, p++, q++;
  80198a:	4a                   	dec    %edx
  80198b:	40                   	inc    %eax
  80198c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80198d:	85 d2                	test   %edx,%edx
  80198f:	74 14                	je     8019a5 <strncmp+0x2a>
  801991:	8a 18                	mov    (%eax),%bl
  801993:	84 db                	test   %bl,%bl
  801995:	74 04                	je     80199b <strncmp+0x20>
  801997:	3a 19                	cmp    (%ecx),%bl
  801999:	74 ef                	je     80198a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80199b:	0f b6 00             	movzbl (%eax),%eax
  80199e:	0f b6 11             	movzbl (%ecx),%edx
  8019a1:	29 d0                	sub    %edx,%eax
  8019a3:	eb 05                	jmp    8019aa <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8019a5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8019aa:	5b                   	pop    %ebx
  8019ab:	5d                   	pop    %ebp
  8019ac:	c3                   	ret    

008019ad <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8019b6:	eb 05                	jmp    8019bd <strchr+0x10>
		if (*s == c)
  8019b8:	38 ca                	cmp    %cl,%dl
  8019ba:	74 0c                	je     8019c8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8019bc:	40                   	inc    %eax
  8019bd:	8a 10                	mov    (%eax),%dl
  8019bf:	84 d2                	test   %dl,%dl
  8019c1:	75 f5                	jne    8019b8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8019c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019c8:	5d                   	pop    %ebp
  8019c9:	c3                   	ret    

008019ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8019d3:	eb 05                	jmp    8019da <strfind+0x10>
		if (*s == c)
  8019d5:	38 ca                	cmp    %cl,%dl
  8019d7:	74 07                	je     8019e0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8019d9:	40                   	inc    %eax
  8019da:	8a 10                	mov    (%eax),%dl
  8019dc:	84 d2                	test   %dl,%dl
  8019de:	75 f5                	jne    8019d5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8019e0:	5d                   	pop    %ebp
  8019e1:	c3                   	ret    

008019e2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	57                   	push   %edi
  8019e6:	56                   	push   %esi
  8019e7:	53                   	push   %ebx
  8019e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8019f1:	85 c9                	test   %ecx,%ecx
  8019f3:	74 30                	je     801a25 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8019f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019fb:	75 25                	jne    801a22 <memset+0x40>
  8019fd:	f6 c1 03             	test   $0x3,%cl
  801a00:	75 20                	jne    801a22 <memset+0x40>
		c &= 0xFF;
  801a02:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801a05:	89 d3                	mov    %edx,%ebx
  801a07:	c1 e3 08             	shl    $0x8,%ebx
  801a0a:	89 d6                	mov    %edx,%esi
  801a0c:	c1 e6 18             	shl    $0x18,%esi
  801a0f:	89 d0                	mov    %edx,%eax
  801a11:	c1 e0 10             	shl    $0x10,%eax
  801a14:	09 f0                	or     %esi,%eax
  801a16:	09 d0                	or     %edx,%eax
  801a18:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801a1a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801a1d:	fc                   	cld    
  801a1e:	f3 ab                	rep stos %eax,%es:(%edi)
  801a20:	eb 03                	jmp    801a25 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801a22:	fc                   	cld    
  801a23:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801a25:	89 f8                	mov    %edi,%eax
  801a27:	5b                   	pop    %ebx
  801a28:	5e                   	pop    %esi
  801a29:	5f                   	pop    %edi
  801a2a:	5d                   	pop    %ebp
  801a2b:	c3                   	ret    

00801a2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	57                   	push   %edi
  801a30:	56                   	push   %esi
  801a31:	8b 45 08             	mov    0x8(%ebp),%eax
  801a34:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801a3a:	39 c6                	cmp    %eax,%esi
  801a3c:	73 34                	jae    801a72 <memmove+0x46>
  801a3e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a41:	39 d0                	cmp    %edx,%eax
  801a43:	73 2d                	jae    801a72 <memmove+0x46>
		s += n;
		d += n;
  801a45:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a48:	f6 c2 03             	test   $0x3,%dl
  801a4b:	75 1b                	jne    801a68 <memmove+0x3c>
  801a4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801a53:	75 13                	jne    801a68 <memmove+0x3c>
  801a55:	f6 c1 03             	test   $0x3,%cl
  801a58:	75 0e                	jne    801a68 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a5a:	83 ef 04             	sub    $0x4,%edi
  801a5d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a60:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801a63:	fd                   	std    
  801a64:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a66:	eb 07                	jmp    801a6f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a68:	4f                   	dec    %edi
  801a69:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801a6c:	fd                   	std    
  801a6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a6f:	fc                   	cld    
  801a70:	eb 20                	jmp    801a92 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a72:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a78:	75 13                	jne    801a8d <memmove+0x61>
  801a7a:	a8 03                	test   $0x3,%al
  801a7c:	75 0f                	jne    801a8d <memmove+0x61>
  801a7e:	f6 c1 03             	test   $0x3,%cl
  801a81:	75 0a                	jne    801a8d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a83:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801a86:	89 c7                	mov    %eax,%edi
  801a88:	fc                   	cld    
  801a89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a8b:	eb 05                	jmp    801a92 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801a8d:	89 c7                	mov    %eax,%edi
  801a8f:	fc                   	cld    
  801a90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a92:	5e                   	pop    %esi
  801a93:	5f                   	pop    %edi
  801a94:	5d                   	pop    %ebp
  801a95:	c3                   	ret    

00801a96 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  801aad:	89 04 24             	mov    %eax,(%esp)
  801ab0:	e8 77 ff ff ff       	call   801a2c <memmove>
}
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	57                   	push   %edi
  801abb:	56                   	push   %esi
  801abc:	53                   	push   %ebx
  801abd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ac0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ac3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ac6:	ba 00 00 00 00       	mov    $0x0,%edx
  801acb:	eb 16                	jmp    801ae3 <memcmp+0x2c>
		if (*s1 != *s2)
  801acd:	8a 04 17             	mov    (%edi,%edx,1),%al
  801ad0:	42                   	inc    %edx
  801ad1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801ad5:	38 c8                	cmp    %cl,%al
  801ad7:	74 0a                	je     801ae3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801ad9:	0f b6 c0             	movzbl %al,%eax
  801adc:	0f b6 c9             	movzbl %cl,%ecx
  801adf:	29 c8                	sub    %ecx,%eax
  801ae1:	eb 09                	jmp    801aec <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ae3:	39 da                	cmp    %ebx,%edx
  801ae5:	75 e6                	jne    801acd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801ae7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aec:	5b                   	pop    %ebx
  801aed:	5e                   	pop    %esi
  801aee:	5f                   	pop    %edi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	8b 45 08             	mov    0x8(%ebp),%eax
  801af7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801afa:	89 c2                	mov    %eax,%edx
  801afc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801aff:	eb 05                	jmp    801b06 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801b01:	38 08                	cmp    %cl,(%eax)
  801b03:	74 05                	je     801b0a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801b05:	40                   	inc    %eax
  801b06:	39 d0                	cmp    %edx,%eax
  801b08:	72 f7                	jb     801b01 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	57                   	push   %edi
  801b10:	56                   	push   %esi
  801b11:	53                   	push   %ebx
  801b12:	8b 55 08             	mov    0x8(%ebp),%edx
  801b15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b18:	eb 01                	jmp    801b1b <strtol+0xf>
		s++;
  801b1a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b1b:	8a 02                	mov    (%edx),%al
  801b1d:	3c 20                	cmp    $0x20,%al
  801b1f:	74 f9                	je     801b1a <strtol+0xe>
  801b21:	3c 09                	cmp    $0x9,%al
  801b23:	74 f5                	je     801b1a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801b25:	3c 2b                	cmp    $0x2b,%al
  801b27:	75 08                	jne    801b31 <strtol+0x25>
		s++;
  801b29:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b2a:	bf 00 00 00 00       	mov    $0x0,%edi
  801b2f:	eb 13                	jmp    801b44 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801b31:	3c 2d                	cmp    $0x2d,%al
  801b33:	75 0a                	jne    801b3f <strtol+0x33>
		s++, neg = 1;
  801b35:	8d 52 01             	lea    0x1(%edx),%edx
  801b38:	bf 01 00 00 00       	mov    $0x1,%edi
  801b3d:	eb 05                	jmp    801b44 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b3f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b44:	85 db                	test   %ebx,%ebx
  801b46:	74 05                	je     801b4d <strtol+0x41>
  801b48:	83 fb 10             	cmp    $0x10,%ebx
  801b4b:	75 28                	jne    801b75 <strtol+0x69>
  801b4d:	8a 02                	mov    (%edx),%al
  801b4f:	3c 30                	cmp    $0x30,%al
  801b51:	75 10                	jne    801b63 <strtol+0x57>
  801b53:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b57:	75 0a                	jne    801b63 <strtol+0x57>
		s += 2, base = 16;
  801b59:	83 c2 02             	add    $0x2,%edx
  801b5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801b61:	eb 12                	jmp    801b75 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801b63:	85 db                	test   %ebx,%ebx
  801b65:	75 0e                	jne    801b75 <strtol+0x69>
  801b67:	3c 30                	cmp    $0x30,%al
  801b69:	75 05                	jne    801b70 <strtol+0x64>
		s++, base = 8;
  801b6b:	42                   	inc    %edx
  801b6c:	b3 08                	mov    $0x8,%bl
  801b6e:	eb 05                	jmp    801b75 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801b70:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801b7c:	8a 0a                	mov    (%edx),%cl
  801b7e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801b81:	80 fb 09             	cmp    $0x9,%bl
  801b84:	77 08                	ja     801b8e <strtol+0x82>
			dig = *s - '0';
  801b86:	0f be c9             	movsbl %cl,%ecx
  801b89:	83 e9 30             	sub    $0x30,%ecx
  801b8c:	eb 1e                	jmp    801bac <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801b8e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801b91:	80 fb 19             	cmp    $0x19,%bl
  801b94:	77 08                	ja     801b9e <strtol+0x92>
			dig = *s - 'a' + 10;
  801b96:	0f be c9             	movsbl %cl,%ecx
  801b99:	83 e9 57             	sub    $0x57,%ecx
  801b9c:	eb 0e                	jmp    801bac <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801b9e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801ba1:	80 fb 19             	cmp    $0x19,%bl
  801ba4:	77 12                	ja     801bb8 <strtol+0xac>
			dig = *s - 'A' + 10;
  801ba6:	0f be c9             	movsbl %cl,%ecx
  801ba9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801bac:	39 f1                	cmp    %esi,%ecx
  801bae:	7d 0c                	jge    801bbc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801bb0:	42                   	inc    %edx
  801bb1:	0f af c6             	imul   %esi,%eax
  801bb4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801bb6:	eb c4                	jmp    801b7c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801bb8:	89 c1                	mov    %eax,%ecx
  801bba:	eb 02                	jmp    801bbe <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801bbc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801bbe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801bc2:	74 05                	je     801bc9 <strtol+0xbd>
		*endptr = (char *) s;
  801bc4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bc7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801bc9:	85 ff                	test   %edi,%edi
  801bcb:	74 04                	je     801bd1 <strtol+0xc5>
  801bcd:	89 c8                	mov    %ecx,%eax
  801bcf:	f7 d8                	neg    %eax
}
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5f                   	pop    %edi
  801bd4:	5d                   	pop    %ebp
  801bd5:	c3                   	ret    
	...

00801bd8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	56                   	push   %esi
  801bdc:	53                   	push   %ebx
  801bdd:	83 ec 10             	sub    $0x10,%esp
  801be0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801be3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801be9:	85 c0                	test   %eax,%eax
  801beb:	75 05                	jne    801bf2 <ipc_recv+0x1a>
  801bed:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801bf2:	89 04 24             	mov    %eax,(%esp)
  801bf5:	e8 b1 e7 ff ff       	call   8003ab <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801bfa:	85 c0                	test   %eax,%eax
  801bfc:	79 16                	jns    801c14 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801bfe:	85 db                	test   %ebx,%ebx
  801c00:	74 06                	je     801c08 <ipc_recv+0x30>
  801c02:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801c08:	85 f6                	test   %esi,%esi
  801c0a:	74 32                	je     801c3e <ipc_recv+0x66>
  801c0c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801c12:	eb 2a                	jmp    801c3e <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c14:	85 db                	test   %ebx,%ebx
  801c16:	74 0c                	je     801c24 <ipc_recv+0x4c>
  801c18:	a1 04 40 80 00       	mov    0x804004,%eax
  801c1d:	8b 00                	mov    (%eax),%eax
  801c1f:	8b 40 74             	mov    0x74(%eax),%eax
  801c22:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c24:	85 f6                	test   %esi,%esi
  801c26:	74 0c                	je     801c34 <ipc_recv+0x5c>
  801c28:	a1 04 40 80 00       	mov    0x804004,%eax
  801c2d:	8b 00                	mov    (%eax),%eax
  801c2f:	8b 40 78             	mov    0x78(%eax),%eax
  801c32:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801c34:	a1 04 40 80 00       	mov    0x804004,%eax
  801c39:	8b 00                	mov    (%eax),%eax
  801c3b:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801c3e:	83 c4 10             	add    $0x10,%esp
  801c41:	5b                   	pop    %ebx
  801c42:	5e                   	pop    %esi
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	57                   	push   %edi
  801c49:	56                   	push   %esi
  801c4a:	53                   	push   %ebx
  801c4b:	83 ec 1c             	sub    $0x1c,%esp
  801c4e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c54:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801c57:	85 db                	test   %ebx,%ebx
  801c59:	75 05                	jne    801c60 <ipc_send+0x1b>
  801c5b:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801c60:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c64:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6f:	89 04 24             	mov    %eax,(%esp)
  801c72:	e8 11 e7 ff ff       	call   800388 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801c77:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c7a:	75 07                	jne    801c83 <ipc_send+0x3e>
  801c7c:	e8 f5 e4 ff ff       	call   800176 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801c81:	eb dd                	jmp    801c60 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801c83:	85 c0                	test   %eax,%eax
  801c85:	79 1c                	jns    801ca3 <ipc_send+0x5e>
  801c87:	c7 44 24 08 00 24 80 	movl   $0x802400,0x8(%esp)
  801c8e:	00 
  801c8f:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801c96:	00 
  801c97:	c7 04 24 12 24 80 00 	movl   $0x802412,(%esp)
  801c9e:	e8 6d f5 ff ff       	call   801210 <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801ca3:	83 c4 1c             	add    $0x1c,%esp
  801ca6:	5b                   	pop    %ebx
  801ca7:	5e                   	pop    %esi
  801ca8:	5f                   	pop    %edi
  801ca9:	5d                   	pop    %ebp
  801caa:	c3                   	ret    

00801cab <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	53                   	push   %ebx
  801caf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801cb2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cb7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801cbe:	89 c2                	mov    %eax,%edx
  801cc0:	c1 e2 07             	shl    $0x7,%edx
  801cc3:	29 ca                	sub    %ecx,%edx
  801cc5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ccb:	8b 52 50             	mov    0x50(%edx),%edx
  801cce:	39 da                	cmp    %ebx,%edx
  801cd0:	75 0f                	jne    801ce1 <ipc_find_env+0x36>
			return envs[i].env_id;
  801cd2:	c1 e0 07             	shl    $0x7,%eax
  801cd5:	29 c8                	sub    %ecx,%eax
  801cd7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cdc:	8b 40 40             	mov    0x40(%eax),%eax
  801cdf:	eb 0c                	jmp    801ced <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ce1:	40                   	inc    %eax
  801ce2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ce7:	75 ce                	jne    801cb7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ce9:	66 b8 00 00          	mov    $0x0,%ax
}
  801ced:	5b                   	pop    %ebx
  801cee:	5d                   	pop    %ebp
  801cef:	c3                   	ret    

00801cf0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801cf6:	89 c2                	mov    %eax,%edx
  801cf8:	c1 ea 16             	shr    $0x16,%edx
  801cfb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d02:	f6 c2 01             	test   $0x1,%dl
  801d05:	74 1e                	je     801d25 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d07:	c1 e8 0c             	shr    $0xc,%eax
  801d0a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d11:	a8 01                	test   $0x1,%al
  801d13:	74 17                	je     801d2c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d15:	c1 e8 0c             	shr    $0xc,%eax
  801d18:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d1f:	ef 
  801d20:	0f b7 c0             	movzwl %ax,%eax
  801d23:	eb 0c                	jmp    801d31 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d25:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2a:	eb 05                	jmp    801d31 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d2c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    
	...

00801d34 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d34:	55                   	push   %ebp
  801d35:	57                   	push   %edi
  801d36:	56                   	push   %esi
  801d37:	83 ec 10             	sub    $0x10,%esp
  801d3a:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d3e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d42:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d46:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801d4a:	89 cd                	mov    %ecx,%ebp
  801d4c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d50:	85 c0                	test   %eax,%eax
  801d52:	75 2c                	jne    801d80 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801d54:	39 f9                	cmp    %edi,%ecx
  801d56:	77 68                	ja     801dc0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d58:	85 c9                	test   %ecx,%ecx
  801d5a:	75 0b                	jne    801d67 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d5c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d61:	31 d2                	xor    %edx,%edx
  801d63:	f7 f1                	div    %ecx
  801d65:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d67:	31 d2                	xor    %edx,%edx
  801d69:	89 f8                	mov    %edi,%eax
  801d6b:	f7 f1                	div    %ecx
  801d6d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d6f:	89 f0                	mov    %esi,%eax
  801d71:	f7 f1                	div    %ecx
  801d73:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d75:	89 f0                	mov    %esi,%eax
  801d77:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d79:	83 c4 10             	add    $0x10,%esp
  801d7c:	5e                   	pop    %esi
  801d7d:	5f                   	pop    %edi
  801d7e:	5d                   	pop    %ebp
  801d7f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d80:	39 f8                	cmp    %edi,%eax
  801d82:	77 2c                	ja     801db0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d84:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801d87:	83 f6 1f             	xor    $0x1f,%esi
  801d8a:	75 4c                	jne    801dd8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d8c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d8e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d93:	72 0a                	jb     801d9f <__udivdi3+0x6b>
  801d95:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d99:	0f 87 ad 00 00 00    	ja     801e4c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d9f:	be 01 00 00 00       	mov    $0x1,%esi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801db0:	31 ff                	xor    %edi,%edi
  801db2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801db4:	89 f0                	mov    %esi,%eax
  801db6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	5e                   	pop    %esi
  801dbc:	5f                   	pop    %edi
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    
  801dbf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dc0:	89 fa                	mov    %edi,%edx
  801dc2:	89 f0                	mov    %esi,%eax
  801dc4:	f7 f1                	div    %ecx
  801dc6:	89 c6                	mov    %eax,%esi
  801dc8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801dca:	89 f0                	mov    %esi,%eax
  801dcc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dce:	83 c4 10             	add    $0x10,%esp
  801dd1:	5e                   	pop    %esi
  801dd2:	5f                   	pop    %edi
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    
  801dd5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801dd8:	89 f1                	mov    %esi,%ecx
  801dda:	d3 e0                	shl    %cl,%eax
  801ddc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801de0:	b8 20 00 00 00       	mov    $0x20,%eax
  801de5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801de7:	89 ea                	mov    %ebp,%edx
  801de9:	88 c1                	mov    %al,%cl
  801deb:	d3 ea                	shr    %cl,%edx
  801ded:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801df1:	09 ca                	or     %ecx,%edx
  801df3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801df7:	89 f1                	mov    %esi,%ecx
  801df9:	d3 e5                	shl    %cl,%ebp
  801dfb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801dff:	89 fd                	mov    %edi,%ebp
  801e01:	88 c1                	mov    %al,%cl
  801e03:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801e05:	89 fa                	mov    %edi,%edx
  801e07:	89 f1                	mov    %esi,%ecx
  801e09:	d3 e2                	shl    %cl,%edx
  801e0b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e0f:	88 c1                	mov    %al,%cl
  801e11:	d3 ef                	shr    %cl,%edi
  801e13:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e15:	89 f8                	mov    %edi,%eax
  801e17:	89 ea                	mov    %ebp,%edx
  801e19:	f7 74 24 08          	divl   0x8(%esp)
  801e1d:	89 d1                	mov    %edx,%ecx
  801e1f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801e21:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e25:	39 d1                	cmp    %edx,%ecx
  801e27:	72 17                	jb     801e40 <__udivdi3+0x10c>
  801e29:	74 09                	je     801e34 <__udivdi3+0x100>
  801e2b:	89 fe                	mov    %edi,%esi
  801e2d:	31 ff                	xor    %edi,%edi
  801e2f:	e9 41 ff ff ff       	jmp    801d75 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e34:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e38:	89 f1                	mov    %esi,%ecx
  801e3a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e3c:	39 c2                	cmp    %eax,%edx
  801e3e:	73 eb                	jae    801e2b <__udivdi3+0xf7>
		{
		  q0--;
  801e40:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e43:	31 ff                	xor    %edi,%edi
  801e45:	e9 2b ff ff ff       	jmp    801d75 <__udivdi3+0x41>
  801e4a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e4c:	31 f6                	xor    %esi,%esi
  801e4e:	e9 22 ff ff ff       	jmp    801d75 <__udivdi3+0x41>
	...

00801e54 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e54:	55                   	push   %ebp
  801e55:	57                   	push   %edi
  801e56:	56                   	push   %esi
  801e57:	83 ec 20             	sub    $0x20,%esp
  801e5a:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e5e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e62:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e66:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801e6a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e6e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801e72:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801e74:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e76:	85 ed                	test   %ebp,%ebp
  801e78:	75 16                	jne    801e90 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801e7a:	39 f1                	cmp    %esi,%ecx
  801e7c:	0f 86 a6 00 00 00    	jbe    801f28 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e82:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801e84:	89 d0                	mov    %edx,%eax
  801e86:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e88:	83 c4 20             	add    $0x20,%esp
  801e8b:	5e                   	pop    %esi
  801e8c:	5f                   	pop    %edi
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    
  801e8f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e90:	39 f5                	cmp    %esi,%ebp
  801e92:	0f 87 ac 00 00 00    	ja     801f44 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e98:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801e9b:	83 f0 1f             	xor    $0x1f,%eax
  801e9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ea2:	0f 84 a8 00 00 00    	je     801f50 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801ea8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801eac:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801eae:	bf 20 00 00 00       	mov    $0x20,%edi
  801eb3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801eb7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ebb:	89 f9                	mov    %edi,%ecx
  801ebd:	d3 e8                	shr    %cl,%eax
  801ebf:	09 e8                	or     %ebp,%eax
  801ec1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801ec5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ec9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801ecd:	d3 e0                	shl    %cl,%eax
  801ecf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ed3:	89 f2                	mov    %esi,%edx
  801ed5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801ed7:	8b 44 24 14          	mov    0x14(%esp),%eax
  801edb:	d3 e0                	shl    %cl,%eax
  801edd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ee1:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ee5:	89 f9                	mov    %edi,%ecx
  801ee7:	d3 e8                	shr    %cl,%eax
  801ee9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801eeb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801eed:	89 f2                	mov    %esi,%edx
  801eef:	f7 74 24 18          	divl   0x18(%esp)
  801ef3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801ef5:	f7 64 24 0c          	mull   0xc(%esp)
  801ef9:	89 c5                	mov    %eax,%ebp
  801efb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801efd:	39 d6                	cmp    %edx,%esi
  801eff:	72 67                	jb     801f68 <__umoddi3+0x114>
  801f01:	74 75                	je     801f78 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801f03:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801f07:	29 e8                	sub    %ebp,%eax
  801f09:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801f0b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f0f:	d3 e8                	shr    %cl,%eax
  801f11:	89 f2                	mov    %esi,%edx
  801f13:	89 f9                	mov    %edi,%ecx
  801f15:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f17:	09 d0                	or     %edx,%eax
  801f19:	89 f2                	mov    %esi,%edx
  801f1b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f1f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f21:	83 c4 20             	add    $0x20,%esp
  801f24:	5e                   	pop    %esi
  801f25:	5f                   	pop    %edi
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f28:	85 c9                	test   %ecx,%ecx
  801f2a:	75 0b                	jne    801f37 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f2c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f31:	31 d2                	xor    %edx,%edx
  801f33:	f7 f1                	div    %ecx
  801f35:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f37:	89 f0                	mov    %esi,%eax
  801f39:	31 d2                	xor    %edx,%edx
  801f3b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f3d:	89 f8                	mov    %edi,%eax
  801f3f:	e9 3e ff ff ff       	jmp    801e82 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f44:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f46:	83 c4 20             	add    $0x20,%esp
  801f49:	5e                   	pop    %esi
  801f4a:	5f                   	pop    %edi
  801f4b:	5d                   	pop    %ebp
  801f4c:	c3                   	ret    
  801f4d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f50:	39 f5                	cmp    %esi,%ebp
  801f52:	72 04                	jb     801f58 <__umoddi3+0x104>
  801f54:	39 f9                	cmp    %edi,%ecx
  801f56:	77 06                	ja     801f5e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f58:	89 f2                	mov    %esi,%edx
  801f5a:	29 cf                	sub    %ecx,%edi
  801f5c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801f5e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f60:	83 c4 20             	add    $0x20,%esp
  801f63:	5e                   	pop    %esi
  801f64:	5f                   	pop    %edi
  801f65:	5d                   	pop    %ebp
  801f66:	c3                   	ret    
  801f67:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f68:	89 d1                	mov    %edx,%ecx
  801f6a:	89 c5                	mov    %eax,%ebp
  801f6c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f70:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f74:	eb 8d                	jmp    801f03 <__umoddi3+0xaf>
  801f76:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f78:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f7c:	72 ea                	jb     801f68 <__umoddi3+0x114>
  801f7e:	89 f1                	mov    %esi,%ecx
  801f80:	eb 81                	jmp    801f03 <__umoddi3+0xaf>
