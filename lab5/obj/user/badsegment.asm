
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 20             	sub    $0x20,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  80004e:	e8 f0 00 00 00       	call   800143 <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005f:	c1 e0 07             	shl    $0x7,%eax
  800062:	29 d0                	sub    %edx,%eax
  800064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800069:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  80006c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80006f:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	85 f6                	test   %esi,%esi
  800076:	7e 07                	jle    80007f <libmain+0x3f>
		binaryname = argv[0];
  800078:	8b 03                	mov    (%ebx),%eax
  80007a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800083:	89 34 24             	mov    %esi,(%esp)
  800086:	e8 a9 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008b:	e8 08 00 00 00       	call   800098 <exit>
}
  800090:	83 c4 20             	add    $0x20,%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80009e:	e8 32 05 00 00       	call   8005d5 <close_all>
	sys_env_destroy(0);
  8000a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    
  8000b1:	00 00                	add    %al,(%eax)
	...

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 28                	jle    80013b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	89 44 24 10          	mov    %eax,0x10(%esp)
  800117:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011e:	00 
  80011f:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  800126:	00 
  800127:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012e:	00 
  80012f:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  800136:	e8 c1 10 00 00       	call   8011fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	83 c4 2c             	add    $0x2c,%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019a:	8b 55 08             	mov    0x8(%ebp),%edx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 28                	jle    8001cd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b0:	00 
  8001b1:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8001b8:	00 
  8001b9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c0:	00 
  8001c1:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  8001c8:	e8 2f 10 00 00       	call   8011fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001cd:	83 c4 2c             	add    $0x2c,%esp
  8001d0:	5b                   	pop    %ebx
  8001d1:	5e                   	pop    %esi
  8001d2:	5f                   	pop    %edi
  8001d3:	5d                   	pop    %ebp
  8001d4:	c3                   	ret    

008001d5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	57                   	push   %edi
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001de:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f4:	85 c0                	test   %eax,%eax
  8001f6:	7e 28                	jle    800220 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800203:	00 
  800204:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800213:	00 
  800214:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  80021b:	e8 dc 0f 00 00       	call   8011fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800220:	83 c4 2c             	add    $0x2c,%esp
  800223:	5b                   	pop    %ebx
  800224:	5e                   	pop    %esi
  800225:	5f                   	pop    %edi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800231:	bb 00 00 00 00       	mov    $0x0,%ebx
  800236:	b8 06 00 00 00       	mov    $0x6,%eax
  80023b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023e:	8b 55 08             	mov    0x8(%ebp),%edx
  800241:	89 df                	mov    %ebx,%edi
  800243:	89 de                	mov    %ebx,%esi
  800245:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800247:	85 c0                	test   %eax,%eax
  800249:	7e 28                	jle    800273 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800256:	00 
  800257:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  80025e:	00 
  80025f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800266:	00 
  800267:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  80026e:	e8 89 0f 00 00       	call   8011fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800273:	83 c4 2c             	add    $0x2c,%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	57                   	push   %edi
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800284:	bb 00 00 00 00       	mov    $0x0,%ebx
  800289:	b8 08 00 00 00       	mov    $0x8,%eax
  80028e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800291:	8b 55 08             	mov    0x8(%ebp),%edx
  800294:	89 df                	mov    %ebx,%edi
  800296:	89 de                	mov    %ebx,%esi
  800298:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80029a:	85 c0                	test   %eax,%eax
  80029c:	7e 28                	jle    8002c6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a9:	00 
  8002aa:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8002b1:	00 
  8002b2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b9:	00 
  8002ba:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  8002c1:	e8 36 0f 00 00       	call   8011fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c6:	83 c4 2c             	add    $0x2c,%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002dc:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	89 df                	mov    %ebx,%edi
  8002e9:	89 de                	mov    %ebx,%esi
  8002eb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ed:	85 c0                	test   %eax,%eax
  8002ef:	7e 28                	jle    800319 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002fc:	00 
  8002fd:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  800304:	00 
  800305:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80030c:	00 
  80030d:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  800314:	e8 e3 0e 00 00       	call   8011fc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800319:	83 c4 2c             	add    $0x2c,%esp
  80031c:	5b                   	pop    %ebx
  80031d:	5e                   	pop    %esi
  80031e:	5f                   	pop    %edi
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	57                   	push   %edi
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
  800327:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800334:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800337:	8b 55 08             	mov    0x8(%ebp),%edx
  80033a:	89 df                	mov    %ebx,%edi
  80033c:	89 de                	mov    %ebx,%esi
  80033e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800340:	85 c0                	test   %eax,%eax
  800342:	7e 28                	jle    80036c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800344:	89 44 24 10          	mov    %eax,0x10(%esp)
  800348:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80034f:	00 
  800350:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  800357:	00 
  800358:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80035f:	00 
  800360:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  800367:	e8 90 0e 00 00       	call   8011fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80036c:	83 c4 2c             	add    $0x2c,%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	57                   	push   %edi
  800378:	56                   	push   %esi
  800379:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037a:	be 00 00 00 00       	mov    $0x0,%esi
  80037f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800384:	8b 7d 14             	mov    0x14(%ebp),%edi
  800387:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80038a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038d:	8b 55 08             	mov    0x8(%ebp),%edx
  800390:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ad:	89 cb                	mov    %ecx,%ebx
  8003af:	89 cf                	mov    %ecx,%edi
  8003b1:	89 ce                	mov    %ecx,%esi
  8003b3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003b5:	85 c0                	test   %eax,%eax
  8003b7:	7e 28                	jle    8003e1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003bd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c4:	00 
  8003c5:	c7 44 24 08 8a 1f 80 	movl   $0x801f8a,0x8(%esp)
  8003cc:	00 
  8003cd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d4:	00 
  8003d5:	c7 04 24 a7 1f 80 00 	movl   $0x801fa7,(%esp)
  8003dc:	e8 1b 0e 00 00       	call   8011fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003e1:	83 c4 2c             	add    $0x2c,%esp
  8003e4:	5b                   	pop    %ebx
  8003e5:	5e                   	pop    %esi
  8003e6:	5f                   	pop    %edi
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    
  8003e9:	00 00                	add    %al,(%eax)
	...

008003ec <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f2:	05 00 00 00 30       	add    $0x30000000,%eax
  8003f7:	c1 e8 0c             	shr    $0xc,%eax
}
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800402:	8b 45 08             	mov    0x8(%ebp),%eax
  800405:	89 04 24             	mov    %eax,(%esp)
  800408:	e8 df ff ff ff       	call   8003ec <fd2num>
  80040d:	05 20 00 0d 00       	add    $0xd0020,%eax
  800412:	c1 e0 0c             	shl    $0xc,%eax
}
  800415:	c9                   	leave  
  800416:	c3                   	ret    

00800417 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	53                   	push   %ebx
  80041b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80041e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800423:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800425:	89 c2                	mov    %eax,%edx
  800427:	c1 ea 16             	shr    $0x16,%edx
  80042a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800431:	f6 c2 01             	test   $0x1,%dl
  800434:	74 11                	je     800447 <fd_alloc+0x30>
  800436:	89 c2                	mov    %eax,%edx
  800438:	c1 ea 0c             	shr    $0xc,%edx
  80043b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800442:	f6 c2 01             	test   $0x1,%dl
  800445:	75 09                	jne    800450 <fd_alloc+0x39>
			*fd_store = fd;
  800447:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800449:	b8 00 00 00 00       	mov    $0x0,%eax
  80044e:	eb 17                	jmp    800467 <fd_alloc+0x50>
  800450:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800455:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80045a:	75 c7                	jne    800423 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80045c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800462:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800467:	5b                   	pop    %ebx
  800468:	5d                   	pop    %ebp
  800469:	c3                   	ret    

0080046a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800470:	83 f8 1f             	cmp    $0x1f,%eax
  800473:	77 36                	ja     8004ab <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800475:	05 00 00 0d 00       	add    $0xd0000,%eax
  80047a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80047d:	89 c2                	mov    %eax,%edx
  80047f:	c1 ea 16             	shr    $0x16,%edx
  800482:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800489:	f6 c2 01             	test   $0x1,%dl
  80048c:	74 24                	je     8004b2 <fd_lookup+0x48>
  80048e:	89 c2                	mov    %eax,%edx
  800490:	c1 ea 0c             	shr    $0xc,%edx
  800493:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80049a:	f6 c2 01             	test   $0x1,%dl
  80049d:	74 1a                	je     8004b9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80049f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a2:	89 02                	mov    %eax,(%edx)
	return 0;
  8004a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a9:	eb 13                	jmp    8004be <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b0:	eb 0c                	jmp    8004be <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8004b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b7:	eb 05                	jmp    8004be <fd_lookup+0x54>
  8004b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	53                   	push   %ebx
  8004c4:	83 ec 14             	sub    $0x14,%esp
  8004c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8004cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d2:	eb 0e                	jmp    8004e2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8004d4:	39 08                	cmp    %ecx,(%eax)
  8004d6:	75 09                	jne    8004e1 <dev_lookup+0x21>
			*dev = devtab[i];
  8004d8:	89 03                	mov    %eax,(%ebx)
			return 0;
  8004da:	b8 00 00 00 00       	mov    $0x0,%eax
  8004df:	eb 35                	jmp    800516 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004e1:	42                   	inc    %edx
  8004e2:	8b 04 95 34 20 80 00 	mov    0x802034(,%edx,4),%eax
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	75 e7                	jne    8004d4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004ed:	a1 04 40 80 00       	mov    0x804004,%eax
  8004f2:	8b 00                	mov    (%eax),%eax
  8004f4:	8b 40 48             	mov    0x48(%eax),%eax
  8004f7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ff:	c7 04 24 b8 1f 80 00 	movl   $0x801fb8,(%esp)
  800506:	e8 e9 0d 00 00       	call   8012f4 <cprintf>
	*dev = 0;
  80050b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800511:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800516:	83 c4 14             	add    $0x14,%esp
  800519:	5b                   	pop    %ebx
  80051a:	5d                   	pop    %ebp
  80051b:	c3                   	ret    

0080051c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80051c:	55                   	push   %ebp
  80051d:	89 e5                	mov    %esp,%ebp
  80051f:	56                   	push   %esi
  800520:	53                   	push   %ebx
  800521:	83 ec 30             	sub    $0x30,%esp
  800524:	8b 75 08             	mov    0x8(%ebp),%esi
  800527:	8a 45 0c             	mov    0xc(%ebp),%al
  80052a:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80052d:	89 34 24             	mov    %esi,(%esp)
  800530:	e8 b7 fe ff ff       	call   8003ec <fd2num>
  800535:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800538:	89 54 24 04          	mov    %edx,0x4(%esp)
  80053c:	89 04 24             	mov    %eax,(%esp)
  80053f:	e8 26 ff ff ff       	call   80046a <fd_lookup>
  800544:	89 c3                	mov    %eax,%ebx
  800546:	85 c0                	test   %eax,%eax
  800548:	78 05                	js     80054f <fd_close+0x33>
	    || fd != fd2)
  80054a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80054d:	74 0d                	je     80055c <fd_close+0x40>
		return (must_exist ? r : 0);
  80054f:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800553:	75 46                	jne    80059b <fd_close+0x7f>
  800555:	bb 00 00 00 00       	mov    $0x0,%ebx
  80055a:	eb 3f                	jmp    80059b <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80055c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80055f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800563:	8b 06                	mov    (%esi),%eax
  800565:	89 04 24             	mov    %eax,(%esp)
  800568:	e8 53 ff ff ff       	call   8004c0 <dev_lookup>
  80056d:	89 c3                	mov    %eax,%ebx
  80056f:	85 c0                	test   %eax,%eax
  800571:	78 18                	js     80058b <fd_close+0x6f>
		if (dev->dev_close)
  800573:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800576:	8b 40 10             	mov    0x10(%eax),%eax
  800579:	85 c0                	test   %eax,%eax
  80057b:	74 09                	je     800586 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80057d:	89 34 24             	mov    %esi,(%esp)
  800580:	ff d0                	call   *%eax
  800582:	89 c3                	mov    %eax,%ebx
  800584:	eb 05                	jmp    80058b <fd_close+0x6f>
		else
			r = 0;
  800586:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80058b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80058f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800596:	e8 8d fc ff ff       	call   800228 <sys_page_unmap>
	return r;
}
  80059b:	89 d8                	mov    %ebx,%eax
  80059d:	83 c4 30             	add    $0x30,%esp
  8005a0:	5b                   	pop    %ebx
  8005a1:	5e                   	pop    %esi
  8005a2:	5d                   	pop    %ebp
  8005a3:	c3                   	ret    

008005a4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
  8005a7:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b4:	89 04 24             	mov    %eax,(%esp)
  8005b7:	e8 ae fe ff ff       	call   80046a <fd_lookup>
  8005bc:	85 c0                	test   %eax,%eax
  8005be:	78 13                	js     8005d3 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8005c0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8005c7:	00 
  8005c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005cb:	89 04 24             	mov    %eax,(%esp)
  8005ce:	e8 49 ff ff ff       	call   80051c <fd_close>
}
  8005d3:	c9                   	leave  
  8005d4:	c3                   	ret    

008005d5 <close_all>:

void
close_all(void)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	53                   	push   %ebx
  8005d9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005dc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005e1:	89 1c 24             	mov    %ebx,(%esp)
  8005e4:	e8 bb ff ff ff       	call   8005a4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005e9:	43                   	inc    %ebx
  8005ea:	83 fb 20             	cmp    $0x20,%ebx
  8005ed:	75 f2                	jne    8005e1 <close_all+0xc>
		close(i);
}
  8005ef:	83 c4 14             	add    $0x14,%esp
  8005f2:	5b                   	pop    %ebx
  8005f3:	5d                   	pop    %ebp
  8005f4:	c3                   	ret    

008005f5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005f5:	55                   	push   %ebp
  8005f6:	89 e5                	mov    %esp,%ebp
  8005f8:	57                   	push   %edi
  8005f9:	56                   	push   %esi
  8005fa:	53                   	push   %ebx
  8005fb:	83 ec 4c             	sub    $0x4c,%esp
  8005fe:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800601:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800604:	89 44 24 04          	mov    %eax,0x4(%esp)
  800608:	8b 45 08             	mov    0x8(%ebp),%eax
  80060b:	89 04 24             	mov    %eax,(%esp)
  80060e:	e8 57 fe ff ff       	call   80046a <fd_lookup>
  800613:	89 c3                	mov    %eax,%ebx
  800615:	85 c0                	test   %eax,%eax
  800617:	0f 88 e1 00 00 00    	js     8006fe <dup+0x109>
		return r;
	close(newfdnum);
  80061d:	89 3c 24             	mov    %edi,(%esp)
  800620:	e8 7f ff ff ff       	call   8005a4 <close>

	newfd = INDEX2FD(newfdnum);
  800625:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  80062b:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80062e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800631:	89 04 24             	mov    %eax,(%esp)
  800634:	e8 c3 fd ff ff       	call   8003fc <fd2data>
  800639:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80063b:	89 34 24             	mov    %esi,(%esp)
  80063e:	e8 b9 fd ff ff       	call   8003fc <fd2data>
  800643:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800646:	89 d8                	mov    %ebx,%eax
  800648:	c1 e8 16             	shr    $0x16,%eax
  80064b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800652:	a8 01                	test   $0x1,%al
  800654:	74 46                	je     80069c <dup+0xa7>
  800656:	89 d8                	mov    %ebx,%eax
  800658:	c1 e8 0c             	shr    $0xc,%eax
  80065b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800662:	f6 c2 01             	test   $0x1,%dl
  800665:	74 35                	je     80069c <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800667:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80066e:	25 07 0e 00 00       	and    $0xe07,%eax
  800673:	89 44 24 10          	mov    %eax,0x10(%esp)
  800677:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80067a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80067e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800685:	00 
  800686:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800691:	e8 3f fb ff ff       	call   8001d5 <sys_page_map>
  800696:	89 c3                	mov    %eax,%ebx
  800698:	85 c0                	test   %eax,%eax
  80069a:	78 3b                	js     8006d7 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80069c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80069f:	89 c2                	mov    %eax,%edx
  8006a1:	c1 ea 0c             	shr    $0xc,%edx
  8006a4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006ab:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8006b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006b5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006c0:	00 
  8006c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006cc:	e8 04 fb ff ff       	call   8001d5 <sys_page_map>
  8006d1:	89 c3                	mov    %eax,%ebx
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	79 25                	jns    8006fc <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8006d7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006e2:	e8 41 fb ff ff       	call   800228 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006f5:	e8 2e fb ff ff       	call   800228 <sys_page_unmap>
	return r;
  8006fa:	eb 02                	jmp    8006fe <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8006fc:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8006fe:	89 d8                	mov    %ebx,%eax
  800700:	83 c4 4c             	add    $0x4c,%esp
  800703:	5b                   	pop    %ebx
  800704:	5e                   	pop    %esi
  800705:	5f                   	pop    %edi
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    

00800708 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	53                   	push   %ebx
  80070c:	83 ec 24             	sub    $0x24,%esp
  80070f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800712:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800715:	89 44 24 04          	mov    %eax,0x4(%esp)
  800719:	89 1c 24             	mov    %ebx,(%esp)
  80071c:	e8 49 fd ff ff       	call   80046a <fd_lookup>
  800721:	85 c0                	test   %eax,%eax
  800723:	78 6f                	js     800794 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800725:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072f:	8b 00                	mov    (%eax),%eax
  800731:	89 04 24             	mov    %eax,(%esp)
  800734:	e8 87 fd ff ff       	call   8004c0 <dev_lookup>
  800739:	85 c0                	test   %eax,%eax
  80073b:	78 57                	js     800794 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80073d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800740:	8b 50 08             	mov    0x8(%eax),%edx
  800743:	83 e2 03             	and    $0x3,%edx
  800746:	83 fa 01             	cmp    $0x1,%edx
  800749:	75 25                	jne    800770 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80074b:	a1 04 40 80 00       	mov    0x804004,%eax
  800750:	8b 00                	mov    (%eax),%eax
  800752:	8b 40 48             	mov    0x48(%eax),%eax
  800755:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075d:	c7 04 24 f9 1f 80 00 	movl   $0x801ff9,(%esp)
  800764:	e8 8b 0b 00 00       	call   8012f4 <cprintf>
		return -E_INVAL;
  800769:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076e:	eb 24                	jmp    800794 <read+0x8c>
	}
	if (!dev->dev_read)
  800770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800773:	8b 52 08             	mov    0x8(%edx),%edx
  800776:	85 d2                	test   %edx,%edx
  800778:	74 15                	je     80078f <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80077a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80077d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800784:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800788:	89 04 24             	mov    %eax,(%esp)
  80078b:	ff d2                	call   *%edx
  80078d:	eb 05                	jmp    800794 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80078f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800794:	83 c4 24             	add    $0x24,%esp
  800797:	5b                   	pop    %ebx
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	57                   	push   %edi
  80079e:	56                   	push   %esi
  80079f:	53                   	push   %ebx
  8007a0:	83 ec 1c             	sub    $0x1c,%esp
  8007a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007a6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007ae:	eb 23                	jmp    8007d3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007b0:	89 f0                	mov    %esi,%eax
  8007b2:	29 d8                	sub    %ebx,%eax
  8007b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bb:	01 d8                	add    %ebx,%eax
  8007bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c1:	89 3c 24             	mov    %edi,(%esp)
  8007c4:	e8 3f ff ff ff       	call   800708 <read>
		if (m < 0)
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 10                	js     8007dd <readn+0x43>
			return m;
		if (m == 0)
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	74 0a                	je     8007db <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007d1:	01 c3                	add    %eax,%ebx
  8007d3:	39 f3                	cmp    %esi,%ebx
  8007d5:	72 d9                	jb     8007b0 <readn+0x16>
  8007d7:	89 d8                	mov    %ebx,%eax
  8007d9:	eb 02                	jmp    8007dd <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8007db:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8007dd:	83 c4 1c             	add    $0x1c,%esp
  8007e0:	5b                   	pop    %ebx
  8007e1:	5e                   	pop    %esi
  8007e2:	5f                   	pop    %edi
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	53                   	push   %ebx
  8007e9:	83 ec 24             	sub    $0x24,%esp
  8007ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f6:	89 1c 24             	mov    %ebx,(%esp)
  8007f9:	e8 6c fc ff ff       	call   80046a <fd_lookup>
  8007fe:	85 c0                	test   %eax,%eax
  800800:	78 6a                	js     80086c <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800802:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800805:	89 44 24 04          	mov    %eax,0x4(%esp)
  800809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080c:	8b 00                	mov    (%eax),%eax
  80080e:	89 04 24             	mov    %eax,(%esp)
  800811:	e8 aa fc ff ff       	call   8004c0 <dev_lookup>
  800816:	85 c0                	test   %eax,%eax
  800818:	78 52                	js     80086c <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80081a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800821:	75 25                	jne    800848 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800823:	a1 04 40 80 00       	mov    0x804004,%eax
  800828:	8b 00                	mov    (%eax),%eax
  80082a:	8b 40 48             	mov    0x48(%eax),%eax
  80082d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800831:	89 44 24 04          	mov    %eax,0x4(%esp)
  800835:	c7 04 24 15 20 80 00 	movl   $0x802015,(%esp)
  80083c:	e8 b3 0a 00 00       	call   8012f4 <cprintf>
		return -E_INVAL;
  800841:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800846:	eb 24                	jmp    80086c <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800848:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80084b:	8b 52 0c             	mov    0xc(%edx),%edx
  80084e:	85 d2                	test   %edx,%edx
  800850:	74 15                	je     800867 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800852:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800855:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800860:	89 04 24             	mov    %eax,(%esp)
  800863:	ff d2                	call   *%edx
  800865:	eb 05                	jmp    80086c <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800867:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80086c:	83 c4 24             	add    $0x24,%esp
  80086f:	5b                   	pop    %ebx
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <seek>:

int
seek(int fdnum, off_t offset)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800878:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80087b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087f:	8b 45 08             	mov    0x8(%ebp),%eax
  800882:	89 04 24             	mov    %eax,(%esp)
  800885:	e8 e0 fb ff ff       	call   80046a <fd_lookup>
  80088a:	85 c0                	test   %eax,%eax
  80088c:	78 0e                	js     80089c <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80088e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
  800894:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089c:	c9                   	leave  
  80089d:	c3                   	ret    

0080089e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	53                   	push   %ebx
  8008a2:	83 ec 24             	sub    $0x24,%esp
  8008a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008af:	89 1c 24             	mov    %ebx,(%esp)
  8008b2:	e8 b3 fb ff ff       	call   80046a <fd_lookup>
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	78 63                	js     80091e <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c5:	8b 00                	mov    (%eax),%eax
  8008c7:	89 04 24             	mov    %eax,(%esp)
  8008ca:	e8 f1 fb ff ff       	call   8004c0 <dev_lookup>
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	78 4b                	js     80091e <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008da:	75 25                	jne    800901 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8008dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8008e1:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008e3:	8b 40 48             	mov    0x48(%eax),%eax
  8008e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ee:	c7 04 24 d8 1f 80 00 	movl   $0x801fd8,(%esp)
  8008f5:	e8 fa 09 00 00       	call   8012f4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8008fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ff:	eb 1d                	jmp    80091e <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  800901:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800904:	8b 52 18             	mov    0x18(%edx),%edx
  800907:	85 d2                	test   %edx,%edx
  800909:	74 0e                	je     800919 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80090b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800912:	89 04 24             	mov    %eax,(%esp)
  800915:	ff d2                	call   *%edx
  800917:	eb 05                	jmp    80091e <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800919:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80091e:	83 c4 24             	add    $0x24,%esp
  800921:	5b                   	pop    %ebx
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	53                   	push   %ebx
  800928:	83 ec 24             	sub    $0x24,%esp
  80092b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80092e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800931:	89 44 24 04          	mov    %eax,0x4(%esp)
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	89 04 24             	mov    %eax,(%esp)
  80093b:	e8 2a fb ff ff       	call   80046a <fd_lookup>
  800940:	85 c0                	test   %eax,%eax
  800942:	78 52                	js     800996 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800944:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800947:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80094e:	8b 00                	mov    (%eax),%eax
  800950:	89 04 24             	mov    %eax,(%esp)
  800953:	e8 68 fb ff ff       	call   8004c0 <dev_lookup>
  800958:	85 c0                	test   %eax,%eax
  80095a:	78 3a                	js     800996 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80095c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800963:	74 2c                	je     800991 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800965:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800968:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80096f:	00 00 00 
	stat->st_isdir = 0;
  800972:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800979:	00 00 00 
	stat->st_dev = dev;
  80097c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800982:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800986:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800989:	89 14 24             	mov    %edx,(%esp)
  80098c:	ff 50 14             	call   *0x14(%eax)
  80098f:	eb 05                	jmp    800996 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800991:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800996:	83 c4 24             	add    $0x24,%esp
  800999:	5b                   	pop    %ebx
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009ab:	00 
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	89 04 24             	mov    %eax,(%esp)
  8009b2:	e8 88 02 00 00       	call   800c3f <open>
  8009b7:	89 c3                	mov    %eax,%ebx
  8009b9:	85 c0                	test   %eax,%eax
  8009bb:	78 1b                	js     8009d8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8009bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c4:	89 1c 24             	mov    %ebx,(%esp)
  8009c7:	e8 58 ff ff ff       	call   800924 <fstat>
  8009cc:	89 c6                	mov    %eax,%esi
	close(fd);
  8009ce:	89 1c 24             	mov    %ebx,(%esp)
  8009d1:	e8 ce fb ff ff       	call   8005a4 <close>
	return r;
  8009d6:	89 f3                	mov    %esi,%ebx
}
  8009d8:	89 d8                	mov    %ebx,%eax
  8009da:	83 c4 10             	add    $0x10,%esp
  8009dd:	5b                   	pop    %ebx
  8009de:	5e                   	pop    %esi
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    
  8009e1:	00 00                	add    %al,(%eax)
	...

008009e4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	83 ec 10             	sub    $0x10,%esp
  8009ec:	89 c3                	mov    %eax,%ebx
  8009ee:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8009f0:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8009f7:	75 11                	jne    800a0a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a00:	e8 92 12 00 00       	call   801c97 <ipc_find_env>
  800a05:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a0a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a11:	00 
  800a12:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a19:	00 
  800a1a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a1e:	a1 00 40 80 00       	mov    0x804000,%eax
  800a23:	89 04 24             	mov    %eax,(%esp)
  800a26:	e8 06 12 00 00       	call   801c31 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  800a2b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a32:	00 
  800a33:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a3e:	e8 81 11 00 00       	call   801bc4 <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  800a43:	83 c4 10             	add    $0x10,%esp
  800a46:	5b                   	pop    %ebx
  800a47:	5e                   	pop    %esi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 40 0c             	mov    0xc(%eax),%eax
  800a56:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800a63:	ba 00 00 00 00       	mov    $0x0,%edx
  800a68:	b8 02 00 00 00       	mov    $0x2,%eax
  800a6d:	e8 72 ff ff ff       	call   8009e4 <fsipc>
}
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a80:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a85:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8a:	b8 06 00 00 00       	mov    $0x6,%eax
  800a8f:	e8 50 ff ff ff       	call   8009e4 <fsipc>
}
  800a94:	c9                   	leave  
  800a95:	c3                   	ret    

00800a96 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	53                   	push   %ebx
  800a9a:	83 ec 14             	sub    $0x14,%esp
  800a9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	8b 40 0c             	mov    0xc(%eax),%eax
  800aa6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800aab:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ab5:	e8 2a ff ff ff       	call   8009e4 <fsipc>
  800aba:	85 c0                	test   %eax,%eax
  800abc:	78 2b                	js     800ae9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800abe:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ac5:	00 
  800ac6:	89 1c 24             	mov    %ebx,(%esp)
  800ac9:	e8 d1 0d 00 00       	call   80189f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ace:	a1 80 50 80 00       	mov    0x805080,%eax
  800ad3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ad9:	a1 84 50 80 00       	mov    0x805084,%eax
  800ade:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae9:	83 c4 14             	add    $0x14,%esp
  800aec:	5b                   	pop    %ebx
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	53                   	push   %ebx
  800af3:	83 ec 14             	sub    $0x14,%esp
  800af6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	8b 40 0c             	mov    0xc(%eax),%eax
  800aff:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  800b04:	89 d8                	mov    %ebx,%eax
  800b06:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800b0c:	76 05                	jbe    800b13 <devfile_write+0x24>
  800b0e:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800b13:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  800b18:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b23:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b2a:	e8 53 0f 00 00       	call   801a82 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  800b2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b34:	b8 04 00 00 00       	mov    $0x4,%eax
  800b39:	e8 a6 fe ff ff       	call   8009e4 <fsipc>
  800b3e:	85 c0                	test   %eax,%eax
  800b40:	78 53                	js     800b95 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  800b42:	39 c3                	cmp    %eax,%ebx
  800b44:	73 24                	jae    800b6a <devfile_write+0x7b>
  800b46:	c7 44 24 0c 44 20 80 	movl   $0x802044,0xc(%esp)
  800b4d:	00 
  800b4e:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800b55:	00 
  800b56:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  800b5d:	00 
  800b5e:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800b65:	e8 92 06 00 00       	call   8011fc <_panic>
	assert(r <= PGSIZE);
  800b6a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b6f:	7e 24                	jle    800b95 <devfile_write+0xa6>
  800b71:	c7 44 24 0c 6b 20 80 	movl   $0x80206b,0xc(%esp)
  800b78:	00 
  800b79:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800b80:	00 
  800b81:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  800b88:	00 
  800b89:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800b90:	e8 67 06 00 00       	call   8011fc <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  800b95:	83 c4 14             	add    $0x14,%esp
  800b98:	5b                   	pop    %ebx
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 10             	sub    $0x10,%esp
  800ba3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba9:	8b 40 0c             	mov    0xc(%eax),%eax
  800bac:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800bb1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbc:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc1:	e8 1e fe ff ff       	call   8009e4 <fsipc>
  800bc6:	89 c3                	mov    %eax,%ebx
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	78 6a                	js     800c36 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800bcc:	39 c6                	cmp    %eax,%esi
  800bce:	73 24                	jae    800bf4 <devfile_read+0x59>
  800bd0:	c7 44 24 0c 44 20 80 	movl   $0x802044,0xc(%esp)
  800bd7:	00 
  800bd8:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800bdf:	00 
  800be0:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  800be7:	00 
  800be8:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800bef:	e8 08 06 00 00       	call   8011fc <_panic>
	assert(r <= PGSIZE);
  800bf4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800bf9:	7e 24                	jle    800c1f <devfile_read+0x84>
  800bfb:	c7 44 24 0c 6b 20 80 	movl   $0x80206b,0xc(%esp)
  800c02:	00 
  800c03:	c7 44 24 08 4b 20 80 	movl   $0x80204b,0x8(%esp)
  800c0a:	00 
  800c0b:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  800c12:	00 
  800c13:	c7 04 24 60 20 80 00 	movl   $0x802060,(%esp)
  800c1a:	e8 dd 05 00 00       	call   8011fc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c23:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c2a:	00 
  800c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2e:	89 04 24             	mov    %eax,(%esp)
  800c31:	e8 e2 0d 00 00       	call   801a18 <memmove>
	return r;
}
  800c36:	89 d8                	mov    %ebx,%eax
  800c38:	83 c4 10             	add    $0x10,%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 20             	sub    $0x20,%esp
  800c47:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c4a:	89 34 24             	mov    %esi,(%esp)
  800c4d:	e8 1a 0c 00 00       	call   80186c <strlen>
  800c52:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c57:	7f 60                	jg     800cb9 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c5c:	89 04 24             	mov    %eax,(%esp)
  800c5f:	e8 b3 f7 ff ff       	call   800417 <fd_alloc>
  800c64:	89 c3                	mov    %eax,%ebx
  800c66:	85 c0                	test   %eax,%eax
  800c68:	78 54                	js     800cbe <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c6e:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c75:	e8 25 0c 00 00       	call   80189f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c82:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c85:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8a:	e8 55 fd ff ff       	call   8009e4 <fsipc>
  800c8f:	89 c3                	mov    %eax,%ebx
  800c91:	85 c0                	test   %eax,%eax
  800c93:	79 15                	jns    800caa <open+0x6b>
		fd_close(fd, 0);
  800c95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c9c:	00 
  800c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca0:	89 04 24             	mov    %eax,(%esp)
  800ca3:	e8 74 f8 ff ff       	call   80051c <fd_close>
		return r;
  800ca8:	eb 14                	jmp    800cbe <open+0x7f>
	}

	return fd2num(fd);
  800caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cad:	89 04 24             	mov    %eax,(%esp)
  800cb0:	e8 37 f7 ff ff       	call   8003ec <fd2num>
  800cb5:	89 c3                	mov    %eax,%ebx
  800cb7:	eb 05                	jmp    800cbe <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cb9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800cbe:	89 d8                	mov    %ebx,%eax
  800cc0:	83 c4 20             	add    $0x20,%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ccd:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd2:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd7:	e8 08 fd ff ff       	call   8009e4 <fsipc>
}
  800cdc:	c9                   	leave  
  800cdd:	c3                   	ret    
	...

00800ce0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 10             	sub    $0x10,%esp
  800ce8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	89 04 24             	mov    %eax,(%esp)
  800cf1:	e8 06 f7 ff ff       	call   8003fc <fd2data>
  800cf6:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  800cf8:	c7 44 24 04 77 20 80 	movl   $0x802077,0x4(%esp)
  800cff:	00 
  800d00:	89 34 24             	mov    %esi,(%esp)
  800d03:	e8 97 0b 00 00       	call   80189f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800d08:	8b 43 04             	mov    0x4(%ebx),%eax
  800d0b:	2b 03                	sub    (%ebx),%eax
  800d0d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  800d13:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  800d1a:	00 00 00 
	stat->st_dev = &devpipe;
  800d1d:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  800d24:	30 80 00 
	return 0;
}
  800d27:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2c:	83 c4 10             	add    $0x10,%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	53                   	push   %ebx
  800d37:	83 ec 14             	sub    $0x14,%esp
  800d3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800d3d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d48:	e8 db f4 ff ff       	call   800228 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800d4d:	89 1c 24             	mov    %ebx,(%esp)
  800d50:	e8 a7 f6 ff ff       	call   8003fc <fd2data>
  800d55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d60:	e8 c3 f4 ff ff       	call   800228 <sys_page_unmap>
}
  800d65:	83 c4 14             	add    $0x14,%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 2c             	sub    $0x2c,%esp
  800d74:	89 c7                	mov    %eax,%edi
  800d76:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800d79:	a1 04 40 80 00       	mov    0x804004,%eax
  800d7e:	8b 00                	mov    (%eax),%eax
  800d80:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800d83:	89 3c 24             	mov    %edi,(%esp)
  800d86:	e8 51 0f 00 00       	call   801cdc <pageref>
  800d8b:	89 c6                	mov    %eax,%esi
  800d8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d90:	89 04 24             	mov    %eax,(%esp)
  800d93:	e8 44 0f 00 00       	call   801cdc <pageref>
  800d98:	39 c6                	cmp    %eax,%esi
  800d9a:	0f 94 c0             	sete   %al
  800d9d:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800da0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800da6:	8b 12                	mov    (%edx),%edx
  800da8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800dab:	39 cb                	cmp    %ecx,%ebx
  800dad:	75 08                	jne    800db7 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  800daf:	83 c4 2c             	add    $0x2c,%esp
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  800db7:	83 f8 01             	cmp    $0x1,%eax
  800dba:	75 bd                	jne    800d79 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800dbc:	8b 42 58             	mov    0x58(%edx),%eax
  800dbf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  800dc6:	00 
  800dc7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dcb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dcf:	c7 04 24 7e 20 80 00 	movl   $0x80207e,(%esp)
  800dd6:	e8 19 05 00 00       	call   8012f4 <cprintf>
  800ddb:	eb 9c                	jmp    800d79 <_pipeisclosed+0xe>

00800ddd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 1c             	sub    $0x1c,%esp
  800de6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800de9:	89 34 24             	mov    %esi,(%esp)
  800dec:	e8 0b f6 ff ff       	call   8003fc <fd2data>
  800df1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800df3:	bf 00 00 00 00       	mov    $0x0,%edi
  800df8:	eb 3c                	jmp    800e36 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800dfa:	89 da                	mov    %ebx,%edx
  800dfc:	89 f0                	mov    %esi,%eax
  800dfe:	e8 68 ff ff ff       	call   800d6b <_pipeisclosed>
  800e03:	85 c0                	test   %eax,%eax
  800e05:	75 38                	jne    800e3f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800e07:	e8 56 f3 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800e0c:	8b 43 04             	mov    0x4(%ebx),%eax
  800e0f:	8b 13                	mov    (%ebx),%edx
  800e11:	83 c2 20             	add    $0x20,%edx
  800e14:	39 d0                	cmp    %edx,%eax
  800e16:	73 e2                	jae    800dfa <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800e18:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e1b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  800e1e:	89 c2                	mov    %eax,%edx
  800e20:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  800e26:	79 05                	jns    800e2d <devpipe_write+0x50>
  800e28:	4a                   	dec    %edx
  800e29:	83 ca e0             	or     $0xffffffe0,%edx
  800e2c:	42                   	inc    %edx
  800e2d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800e31:	40                   	inc    %eax
  800e32:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e35:	47                   	inc    %edi
  800e36:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800e39:	75 d1                	jne    800e0c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800e3b:	89 f8                	mov    %edi,%eax
  800e3d:	eb 05                	jmp    800e44 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800e3f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800e44:	83 c4 1c             	add    $0x1c,%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 1c             	sub    $0x1c,%esp
  800e55:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800e58:	89 3c 24             	mov    %edi,(%esp)
  800e5b:	e8 9c f5 ff ff       	call   8003fc <fd2data>
  800e60:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800e62:	be 00 00 00 00       	mov    $0x0,%esi
  800e67:	eb 3a                	jmp    800ea3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800e69:	85 f6                	test   %esi,%esi
  800e6b:	74 04                	je     800e71 <devpipe_read+0x25>
				return i;
  800e6d:	89 f0                	mov    %esi,%eax
  800e6f:	eb 40                	jmp    800eb1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800e71:	89 da                	mov    %ebx,%edx
  800e73:	89 f8                	mov    %edi,%eax
  800e75:	e8 f1 fe ff ff       	call   800d6b <_pipeisclosed>
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	75 2e                	jne    800eac <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800e7e:	e8 df f2 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800e83:	8b 03                	mov    (%ebx),%eax
  800e85:	3b 43 04             	cmp    0x4(%ebx),%eax
  800e88:	74 df                	je     800e69 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800e8a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  800e8f:	79 05                	jns    800e96 <devpipe_read+0x4a>
  800e91:	48                   	dec    %eax
  800e92:	83 c8 e0             	or     $0xffffffe0,%eax
  800e95:	40                   	inc    %eax
  800e96:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  800e9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e9d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  800ea0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ea2:	46                   	inc    %esi
  800ea3:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ea6:	75 db                	jne    800e83 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800ea8:	89 f0                	mov    %esi,%eax
  800eaa:	eb 05                	jmp    800eb1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800eac:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800eb1:	83 c4 1c             	add    $0x1c,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 3c             	sub    $0x3c,%esp
  800ec2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800ec5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ec8:	89 04 24             	mov    %eax,(%esp)
  800ecb:	e8 47 f5 ff ff       	call   800417 <fd_alloc>
  800ed0:	89 c3                	mov    %eax,%ebx
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	0f 88 45 01 00 00    	js     80101f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800eda:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ee1:	00 
  800ee2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ee5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ef0:	e8 8c f2 ff ff       	call   800181 <sys_page_alloc>
  800ef5:	89 c3                	mov    %eax,%ebx
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	0f 88 20 01 00 00    	js     80101f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800eff:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f02:	89 04 24             	mov    %eax,(%esp)
  800f05:	e8 0d f5 ff ff       	call   800417 <fd_alloc>
  800f0a:	89 c3                	mov    %eax,%ebx
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	0f 88 f8 00 00 00    	js     80100c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f14:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f1b:	00 
  800f1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f2a:	e8 52 f2 ff ff       	call   800181 <sys_page_alloc>
  800f2f:	89 c3                	mov    %eax,%ebx
  800f31:	85 c0                	test   %eax,%eax
  800f33:	0f 88 d3 00 00 00    	js     80100c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800f39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f3c:	89 04 24             	mov    %eax,(%esp)
  800f3f:	e8 b8 f4 ff ff       	call   8003fc <fd2data>
  800f44:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f46:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f4d:	00 
  800f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f59:	e8 23 f2 ff ff       	call   800181 <sys_page_alloc>
  800f5e:	89 c3                	mov    %eax,%ebx
  800f60:	85 c0                	test   %eax,%eax
  800f62:	0f 88 91 00 00 00    	js     800ff9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800f68:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f6b:	89 04 24             	mov    %eax,(%esp)
  800f6e:	e8 89 f4 ff ff       	call   8003fc <fd2data>
  800f73:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  800f7a:	00 
  800f7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f7f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f86:	00 
  800f87:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f92:	e8 3e f2 ff ff       	call   8001d5 <sys_page_map>
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 4c                	js     800fe9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800f9d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800fa3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fa6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800fa8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800fb2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800fb8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fbb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800fbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fc0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800fc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fca:	89 04 24             	mov    %eax,(%esp)
  800fcd:	e8 1a f4 ff ff       	call   8003ec <fd2num>
  800fd2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  800fd4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800fd7:	89 04 24             	mov    %eax,(%esp)
  800fda:	e8 0d f4 ff ff       	call   8003ec <fd2num>
  800fdf:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  800fe2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe7:	eb 36                	jmp    80101f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  800fe9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ff4:	e8 2f f2 ff ff       	call   800228 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  800ff9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ffc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801000:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801007:	e8 1c f2 ff ff       	call   800228 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80100c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80100f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801013:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80101a:	e8 09 f2 ff ff       	call   800228 <sys_page_unmap>
    err:
	return r;
}
  80101f:	89 d8                	mov    %ebx,%eax
  801021:	83 c4 3c             	add    $0x3c,%esp
  801024:	5b                   	pop    %ebx
  801025:	5e                   	pop    %esi
  801026:	5f                   	pop    %edi
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    

00801029 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80102f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801032:	89 44 24 04          	mov    %eax,0x4(%esp)
  801036:	8b 45 08             	mov    0x8(%ebp),%eax
  801039:	89 04 24             	mov    %eax,(%esp)
  80103c:	e8 29 f4 ff ff       	call   80046a <fd_lookup>
  801041:	85 c0                	test   %eax,%eax
  801043:	78 15                	js     80105a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801045:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801048:	89 04 24             	mov    %eax,(%esp)
  80104b:	e8 ac f3 ff ff       	call   8003fc <fd2data>
	return _pipeisclosed(fd, p);
  801050:	89 c2                	mov    %eax,%edx
  801052:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801055:	e8 11 fd ff ff       	call   800d6b <_pipeisclosed>
}
  80105a:	c9                   	leave  
  80105b:	c3                   	ret    

0080105c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80105f:	b8 00 00 00 00       	mov    $0x0,%eax
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80106c:	c7 44 24 04 96 20 80 	movl   $0x802096,0x4(%esp)
  801073:	00 
  801074:	8b 45 0c             	mov    0xc(%ebp),%eax
  801077:	89 04 24             	mov    %eax,(%esp)
  80107a:	e8 20 08 00 00       	call   80189f <strcpy>
	return 0;
}
  80107f:	b8 00 00 00 00       	mov    $0x0,%eax
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	57                   	push   %edi
  80108a:	56                   	push   %esi
  80108b:	53                   	push   %ebx
  80108c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801092:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801097:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80109d:	eb 30                	jmp    8010cf <devcons_write+0x49>
		m = n - tot;
  80109f:	8b 75 10             	mov    0x10(%ebp),%esi
  8010a2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8010a4:	83 fe 7f             	cmp    $0x7f,%esi
  8010a7:	76 05                	jbe    8010ae <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8010a9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8010ae:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010b2:	03 45 0c             	add    0xc(%ebp),%eax
  8010b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b9:	89 3c 24             	mov    %edi,(%esp)
  8010bc:	e8 57 09 00 00       	call   801a18 <memmove>
		sys_cputs(buf, m);
  8010c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c5:	89 3c 24             	mov    %edi,(%esp)
  8010c8:	e8 e7 ef ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8010cd:	01 f3                	add    %esi,%ebx
  8010cf:	89 d8                	mov    %ebx,%eax
  8010d1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010d4:	72 c9                	jb     80109f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8010d6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5f                   	pop    %edi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8010e7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010eb:	75 07                	jne    8010f4 <devcons_read+0x13>
  8010ed:	eb 25                	jmp    801114 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8010ef:	e8 6e f0 ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8010f4:	e8 d9 ef ff ff       	call   8000d2 <sys_cgetc>
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	74 f2                	je     8010ef <devcons_read+0xe>
  8010fd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8010ff:	85 c0                	test   %eax,%eax
  801101:	78 1d                	js     801120 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801103:	83 f8 04             	cmp    $0x4,%eax
  801106:	74 13                	je     80111b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801108:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110b:	88 10                	mov    %dl,(%eax)
	return 1;
  80110d:	b8 01 00 00 00       	mov    $0x1,%eax
  801112:	eb 0c                	jmp    801120 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801114:	b8 00 00 00 00       	mov    $0x0,%eax
  801119:	eb 05                	jmp    801120 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80111b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801120:	c9                   	leave  
  801121:	c3                   	ret    

00801122 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801128:	8b 45 08             	mov    0x8(%ebp),%eax
  80112b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80112e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801135:	00 
  801136:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801139:	89 04 24             	mov    %eax,(%esp)
  80113c:	e8 73 ef ff ff       	call   8000b4 <sys_cputs>
}
  801141:	c9                   	leave  
  801142:	c3                   	ret    

00801143 <getchar>:

int
getchar(void)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801149:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801150:	00 
  801151:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801154:	89 44 24 04          	mov    %eax,0x4(%esp)
  801158:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80115f:	e8 a4 f5 ff ff       	call   800708 <read>
	if (r < 0)
  801164:	85 c0                	test   %eax,%eax
  801166:	78 0f                	js     801177 <getchar+0x34>
		return r;
	if (r < 1)
  801168:	85 c0                	test   %eax,%eax
  80116a:	7e 06                	jle    801172 <getchar+0x2f>
		return -E_EOF;
	return c;
  80116c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801170:	eb 05                	jmp    801177 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801172:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801177:	c9                   	leave  
  801178:	c3                   	ret    

00801179 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80117f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801182:	89 44 24 04          	mov    %eax,0x4(%esp)
  801186:	8b 45 08             	mov    0x8(%ebp),%eax
  801189:	89 04 24             	mov    %eax,(%esp)
  80118c:	e8 d9 f2 ff ff       	call   80046a <fd_lookup>
  801191:	85 c0                	test   %eax,%eax
  801193:	78 11                	js     8011a6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801198:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80119e:	39 10                	cmp    %edx,(%eax)
  8011a0:	0f 94 c0             	sete   %al
  8011a3:	0f b6 c0             	movzbl %al,%eax
}
  8011a6:	c9                   	leave  
  8011a7:	c3                   	ret    

008011a8 <opencons>:

int
opencons(void)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8011ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b1:	89 04 24             	mov    %eax,(%esp)
  8011b4:	e8 5e f2 ff ff       	call   800417 <fd_alloc>
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 3c                	js     8011f9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8011bd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8011c4:	00 
  8011c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d3:	e8 a9 ef ff ff       	call   800181 <sys_page_alloc>
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	78 1d                	js     8011f9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8011dc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8011e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8011e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ea:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8011f1:	89 04 24             	mov    %eax,(%esp)
  8011f4:	e8 f3 f1 ff ff       	call   8003ec <fd2num>
}
  8011f9:	c9                   	leave  
  8011fa:	c3                   	ret    
	...

008011fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	56                   	push   %esi
  801200:	53                   	push   %ebx
  801201:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801204:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801207:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80120d:	e8 31 ef ff ff       	call   800143 <sys_getenvid>
  801212:	8b 55 0c             	mov    0xc(%ebp),%edx
  801215:	89 54 24 10          	mov    %edx,0x10(%esp)
  801219:	8b 55 08             	mov    0x8(%ebp),%edx
  80121c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801220:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801224:	89 44 24 04          	mov    %eax,0x4(%esp)
  801228:	c7 04 24 a4 20 80 00 	movl   $0x8020a4,(%esp)
  80122f:	e8 c0 00 00 00       	call   8012f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801234:	89 74 24 04          	mov    %esi,0x4(%esp)
  801238:	8b 45 10             	mov    0x10(%ebp),%eax
  80123b:	89 04 24             	mov    %eax,(%esp)
  80123e:	e8 50 00 00 00       	call   801293 <vcprintf>
	cprintf("\n");
  801243:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  80124a:	e8 a5 00 00 00       	call   8012f4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80124f:	cc                   	int3   
  801250:	eb fd                	jmp    80124f <_panic+0x53>
	...

00801254 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	53                   	push   %ebx
  801258:	83 ec 14             	sub    $0x14,%esp
  80125b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80125e:	8b 03                	mov    (%ebx),%eax
  801260:	8b 55 08             	mov    0x8(%ebp),%edx
  801263:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801267:	40                   	inc    %eax
  801268:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80126a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80126f:	75 19                	jne    80128a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801271:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801278:	00 
  801279:	8d 43 08             	lea    0x8(%ebx),%eax
  80127c:	89 04 24             	mov    %eax,(%esp)
  80127f:	e8 30 ee ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  801284:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80128a:	ff 43 04             	incl   0x4(%ebx)
}
  80128d:	83 c4 14             	add    $0x14,%esp
  801290:	5b                   	pop    %ebx
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    

00801293 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80129c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8012a3:	00 00 00 
	b.cnt = 0;
  8012a6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8012ad:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8012b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012be:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8012c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c8:	c7 04 24 54 12 80 00 	movl   $0x801254,(%esp)
  8012cf:	e8 82 01 00 00       	call   801456 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8012d4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8012da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012de:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8012e4:	89 04 24             	mov    %eax,(%esp)
  8012e7:	e8 c8 ed ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  8012ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8012f2:	c9                   	leave  
  8012f3:	c3                   	ret    

008012f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8012fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8012fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801301:	8b 45 08             	mov    0x8(%ebp),%eax
  801304:	89 04 24             	mov    %eax,(%esp)
  801307:	e8 87 ff ff ff       	call   801293 <vcprintf>
	va_end(ap);

	return cnt;
}
  80130c:	c9                   	leave  
  80130d:	c3                   	ret    
	...

00801310 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	57                   	push   %edi
  801314:	56                   	push   %esi
  801315:	53                   	push   %ebx
  801316:	83 ec 3c             	sub    $0x3c,%esp
  801319:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80131c:	89 d7                	mov    %edx,%edi
  80131e:	8b 45 08             	mov    0x8(%ebp),%eax
  801321:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801324:	8b 45 0c             	mov    0xc(%ebp),%eax
  801327:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80132a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80132d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801330:	85 c0                	test   %eax,%eax
  801332:	75 08                	jne    80133c <printnum+0x2c>
  801334:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801337:	39 45 10             	cmp    %eax,0x10(%ebp)
  80133a:	77 57                	ja     801393 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80133c:	89 74 24 10          	mov    %esi,0x10(%esp)
  801340:	4b                   	dec    %ebx
  801341:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801345:	8b 45 10             	mov    0x10(%ebp),%eax
  801348:	89 44 24 08          	mov    %eax,0x8(%esp)
  80134c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801350:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801354:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80135b:	00 
  80135c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80135f:	89 04 24             	mov    %eax,(%esp)
  801362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801365:	89 44 24 04          	mov    %eax,0x4(%esp)
  801369:	e8 b2 09 00 00       	call   801d20 <__udivdi3>
  80136e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801372:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801376:	89 04 24             	mov    %eax,(%esp)
  801379:	89 54 24 04          	mov    %edx,0x4(%esp)
  80137d:	89 fa                	mov    %edi,%edx
  80137f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801382:	e8 89 ff ff ff       	call   801310 <printnum>
  801387:	eb 0f                	jmp    801398 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801389:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80138d:	89 34 24             	mov    %esi,(%esp)
  801390:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801393:	4b                   	dec    %ebx
  801394:	85 db                	test   %ebx,%ebx
  801396:	7f f1                	jg     801389 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801398:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80139c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8013a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013ae:	00 
  8013af:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8013b2:	89 04 24             	mov    %eax,(%esp)
  8013b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bc:	e8 7f 0a 00 00       	call   801e40 <__umoddi3>
  8013c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013c5:	0f be 80 c7 20 80 00 	movsbl 0x8020c7(%eax),%eax
  8013cc:	89 04 24             	mov    %eax,(%esp)
  8013cf:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8013d2:	83 c4 3c             	add    $0x3c,%esp
  8013d5:	5b                   	pop    %ebx
  8013d6:	5e                   	pop    %esi
  8013d7:	5f                   	pop    %edi
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8013dd:	83 fa 01             	cmp    $0x1,%edx
  8013e0:	7e 0e                	jle    8013f0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8013e2:	8b 10                	mov    (%eax),%edx
  8013e4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8013e7:	89 08                	mov    %ecx,(%eax)
  8013e9:	8b 02                	mov    (%edx),%eax
  8013eb:	8b 52 04             	mov    0x4(%edx),%edx
  8013ee:	eb 22                	jmp    801412 <getuint+0x38>
	else if (lflag)
  8013f0:	85 d2                	test   %edx,%edx
  8013f2:	74 10                	je     801404 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8013f4:	8b 10                	mov    (%eax),%edx
  8013f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8013f9:	89 08                	mov    %ecx,(%eax)
  8013fb:	8b 02                	mov    (%edx),%eax
  8013fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801402:	eb 0e                	jmp    801412 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801404:	8b 10                	mov    (%eax),%edx
  801406:	8d 4a 04             	lea    0x4(%edx),%ecx
  801409:	89 08                	mov    %ecx,(%eax)
  80140b:	8b 02                	mov    (%edx),%eax
  80140d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    

00801414 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80141a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80141d:	8b 10                	mov    (%eax),%edx
  80141f:	3b 50 04             	cmp    0x4(%eax),%edx
  801422:	73 08                	jae    80142c <sprintputch+0x18>
		*b->buf++ = ch;
  801424:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801427:	88 0a                	mov    %cl,(%edx)
  801429:	42                   	inc    %edx
  80142a:	89 10                	mov    %edx,(%eax)
}
  80142c:	5d                   	pop    %ebp
  80142d:	c3                   	ret    

0080142e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801434:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801437:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80143b:	8b 45 10             	mov    0x10(%ebp),%eax
  80143e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801442:	8b 45 0c             	mov    0xc(%ebp),%eax
  801445:	89 44 24 04          	mov    %eax,0x4(%esp)
  801449:	8b 45 08             	mov    0x8(%ebp),%eax
  80144c:	89 04 24             	mov    %eax,(%esp)
  80144f:	e8 02 00 00 00       	call   801456 <vprintfmt>
	va_end(ap);
}
  801454:	c9                   	leave  
  801455:	c3                   	ret    

00801456 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	57                   	push   %edi
  80145a:	56                   	push   %esi
  80145b:	53                   	push   %ebx
  80145c:	83 ec 4c             	sub    $0x4c,%esp
  80145f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801462:	8b 75 10             	mov    0x10(%ebp),%esi
  801465:	eb 12                	jmp    801479 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801467:	85 c0                	test   %eax,%eax
  801469:	0f 84 6b 03 00 00    	je     8017da <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80146f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801473:	89 04 24             	mov    %eax,(%esp)
  801476:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801479:	0f b6 06             	movzbl (%esi),%eax
  80147c:	46                   	inc    %esi
  80147d:	83 f8 25             	cmp    $0x25,%eax
  801480:	75 e5                	jne    801467 <vprintfmt+0x11>
  801482:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801486:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80148d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801492:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801499:	b9 00 00 00 00       	mov    $0x0,%ecx
  80149e:	eb 26                	jmp    8014c6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8014a3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8014a7:	eb 1d                	jmp    8014c6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8014ac:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8014b0:	eb 14                	jmp    8014c6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8014b5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8014bc:	eb 08                	jmp    8014c6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8014be:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8014c1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014c6:	0f b6 06             	movzbl (%esi),%eax
  8014c9:	8d 56 01             	lea    0x1(%esi),%edx
  8014cc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8014cf:	8a 16                	mov    (%esi),%dl
  8014d1:	83 ea 23             	sub    $0x23,%edx
  8014d4:	80 fa 55             	cmp    $0x55,%dl
  8014d7:	0f 87 e1 02 00 00    	ja     8017be <vprintfmt+0x368>
  8014dd:	0f b6 d2             	movzbl %dl,%edx
  8014e0:	ff 24 95 00 22 80 00 	jmp    *0x802200(,%edx,4)
  8014e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8014ea:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8014ef:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8014f2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8014f6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8014f9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8014fc:	83 fa 09             	cmp    $0x9,%edx
  8014ff:	77 2a                	ja     80152b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801501:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801502:	eb eb                	jmp    8014ef <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801504:	8b 45 14             	mov    0x14(%ebp),%eax
  801507:	8d 50 04             	lea    0x4(%eax),%edx
  80150a:	89 55 14             	mov    %edx,0x14(%ebp)
  80150d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80150f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801512:	eb 17                	jmp    80152b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801514:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801518:	78 98                	js     8014b2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80151a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80151d:	eb a7                	jmp    8014c6 <vprintfmt+0x70>
  80151f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801522:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801529:	eb 9b                	jmp    8014c6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80152b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80152f:	79 95                	jns    8014c6 <vprintfmt+0x70>
  801531:	eb 8b                	jmp    8014be <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801533:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801534:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801537:	eb 8d                	jmp    8014c6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801539:	8b 45 14             	mov    0x14(%ebp),%eax
  80153c:	8d 50 04             	lea    0x4(%eax),%edx
  80153f:	89 55 14             	mov    %edx,0x14(%ebp)
  801542:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801546:	8b 00                	mov    (%eax),%eax
  801548:	89 04 24             	mov    %eax,(%esp)
  80154b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80154e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801551:	e9 23 ff ff ff       	jmp    801479 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801556:	8b 45 14             	mov    0x14(%ebp),%eax
  801559:	8d 50 04             	lea    0x4(%eax),%edx
  80155c:	89 55 14             	mov    %edx,0x14(%ebp)
  80155f:	8b 00                	mov    (%eax),%eax
  801561:	85 c0                	test   %eax,%eax
  801563:	79 02                	jns    801567 <vprintfmt+0x111>
  801565:	f7 d8                	neg    %eax
  801567:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801569:	83 f8 0f             	cmp    $0xf,%eax
  80156c:	7f 0b                	jg     801579 <vprintfmt+0x123>
  80156e:	8b 04 85 60 23 80 00 	mov    0x802360(,%eax,4),%eax
  801575:	85 c0                	test   %eax,%eax
  801577:	75 23                	jne    80159c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801579:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80157d:	c7 44 24 08 df 20 80 	movl   $0x8020df,0x8(%esp)
  801584:	00 
  801585:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801589:	8b 45 08             	mov    0x8(%ebp),%eax
  80158c:	89 04 24             	mov    %eax,(%esp)
  80158f:	e8 9a fe ff ff       	call   80142e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801594:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801597:	e9 dd fe ff ff       	jmp    801479 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80159c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015a0:	c7 44 24 08 5d 20 80 	movl   $0x80205d,0x8(%esp)
  8015a7:	00 
  8015a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8015af:	89 14 24             	mov    %edx,(%esp)
  8015b2:	e8 77 fe ff ff       	call   80142e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015b7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8015ba:	e9 ba fe ff ff       	jmp    801479 <vprintfmt+0x23>
  8015bf:	89 f9                	mov    %edi,%ecx
  8015c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8015c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ca:	8d 50 04             	lea    0x4(%eax),%edx
  8015cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8015d0:	8b 30                	mov    (%eax),%esi
  8015d2:	85 f6                	test   %esi,%esi
  8015d4:	75 05                	jne    8015db <vprintfmt+0x185>
				p = "(null)";
  8015d6:	be d8 20 80 00       	mov    $0x8020d8,%esi
			if (width > 0 && padc != '-')
  8015db:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8015df:	0f 8e 84 00 00 00    	jle    801669 <vprintfmt+0x213>
  8015e5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8015e9:	74 7e                	je     801669 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8015eb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015ef:	89 34 24             	mov    %esi,(%esp)
  8015f2:	e8 8b 02 00 00       	call   801882 <strnlen>
  8015f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8015fa:	29 c2                	sub    %eax,%edx
  8015fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8015ff:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801603:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801606:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801609:	89 de                	mov    %ebx,%esi
  80160b:	89 d3                	mov    %edx,%ebx
  80160d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80160f:	eb 0b                	jmp    80161c <vprintfmt+0x1c6>
					putch(padc, putdat);
  801611:	89 74 24 04          	mov    %esi,0x4(%esp)
  801615:	89 3c 24             	mov    %edi,(%esp)
  801618:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80161b:	4b                   	dec    %ebx
  80161c:	85 db                	test   %ebx,%ebx
  80161e:	7f f1                	jg     801611 <vprintfmt+0x1bb>
  801620:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801623:	89 f3                	mov    %esi,%ebx
  801625:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801628:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80162b:	85 c0                	test   %eax,%eax
  80162d:	79 05                	jns    801634 <vprintfmt+0x1de>
  80162f:	b8 00 00 00 00       	mov    $0x0,%eax
  801634:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801637:	29 c2                	sub    %eax,%edx
  801639:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80163c:	eb 2b                	jmp    801669 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80163e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801642:	74 18                	je     80165c <vprintfmt+0x206>
  801644:	8d 50 e0             	lea    -0x20(%eax),%edx
  801647:	83 fa 5e             	cmp    $0x5e,%edx
  80164a:	76 10                	jbe    80165c <vprintfmt+0x206>
					putch('?', putdat);
  80164c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801650:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801657:	ff 55 08             	call   *0x8(%ebp)
  80165a:	eb 0a                	jmp    801666 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80165c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801660:	89 04 24             	mov    %eax,(%esp)
  801663:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801666:	ff 4d e4             	decl   -0x1c(%ebp)
  801669:	0f be 06             	movsbl (%esi),%eax
  80166c:	46                   	inc    %esi
  80166d:	85 c0                	test   %eax,%eax
  80166f:	74 21                	je     801692 <vprintfmt+0x23c>
  801671:	85 ff                	test   %edi,%edi
  801673:	78 c9                	js     80163e <vprintfmt+0x1e8>
  801675:	4f                   	dec    %edi
  801676:	79 c6                	jns    80163e <vprintfmt+0x1e8>
  801678:	8b 7d 08             	mov    0x8(%ebp),%edi
  80167b:	89 de                	mov    %ebx,%esi
  80167d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801680:	eb 18                	jmp    80169a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801682:	89 74 24 04          	mov    %esi,0x4(%esp)
  801686:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80168d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80168f:	4b                   	dec    %ebx
  801690:	eb 08                	jmp    80169a <vprintfmt+0x244>
  801692:	8b 7d 08             	mov    0x8(%ebp),%edi
  801695:	89 de                	mov    %ebx,%esi
  801697:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80169a:	85 db                	test   %ebx,%ebx
  80169c:	7f e4                	jg     801682 <vprintfmt+0x22c>
  80169e:	89 7d 08             	mov    %edi,0x8(%ebp)
  8016a1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8016a6:	e9 ce fd ff ff       	jmp    801479 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8016ab:	83 f9 01             	cmp    $0x1,%ecx
  8016ae:	7e 10                	jle    8016c0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8016b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b3:	8d 50 08             	lea    0x8(%eax),%edx
  8016b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8016b9:	8b 30                	mov    (%eax),%esi
  8016bb:	8b 78 04             	mov    0x4(%eax),%edi
  8016be:	eb 26                	jmp    8016e6 <vprintfmt+0x290>
	else if (lflag)
  8016c0:	85 c9                	test   %ecx,%ecx
  8016c2:	74 12                	je     8016d6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8016c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c7:	8d 50 04             	lea    0x4(%eax),%edx
  8016ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8016cd:	8b 30                	mov    (%eax),%esi
  8016cf:	89 f7                	mov    %esi,%edi
  8016d1:	c1 ff 1f             	sar    $0x1f,%edi
  8016d4:	eb 10                	jmp    8016e6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8016d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d9:	8d 50 04             	lea    0x4(%eax),%edx
  8016dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8016df:	8b 30                	mov    (%eax),%esi
  8016e1:	89 f7                	mov    %esi,%edi
  8016e3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8016e6:	85 ff                	test   %edi,%edi
  8016e8:	78 0a                	js     8016f4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8016ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016ef:	e9 8c 00 00 00       	jmp    801780 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8016f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016f8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8016ff:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801702:	f7 de                	neg    %esi
  801704:	83 d7 00             	adc    $0x0,%edi
  801707:	f7 df                	neg    %edi
			}
			base = 10;
  801709:	b8 0a 00 00 00       	mov    $0xa,%eax
  80170e:	eb 70                	jmp    801780 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801710:	89 ca                	mov    %ecx,%edx
  801712:	8d 45 14             	lea    0x14(%ebp),%eax
  801715:	e8 c0 fc ff ff       	call   8013da <getuint>
  80171a:	89 c6                	mov    %eax,%esi
  80171c:	89 d7                	mov    %edx,%edi
			base = 10;
  80171e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801723:	eb 5b                	jmp    801780 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801725:	89 ca                	mov    %ecx,%edx
  801727:	8d 45 14             	lea    0x14(%ebp),%eax
  80172a:	e8 ab fc ff ff       	call   8013da <getuint>
  80172f:	89 c6                	mov    %eax,%esi
  801731:	89 d7                	mov    %edx,%edi
			base = 8;
  801733:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801738:	eb 46                	jmp    801780 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80173a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80173e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801745:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801748:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80174c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801753:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801756:	8b 45 14             	mov    0x14(%ebp),%eax
  801759:	8d 50 04             	lea    0x4(%eax),%edx
  80175c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80175f:	8b 30                	mov    (%eax),%esi
  801761:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801766:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80176b:	eb 13                	jmp    801780 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80176d:	89 ca                	mov    %ecx,%edx
  80176f:	8d 45 14             	lea    0x14(%ebp),%eax
  801772:	e8 63 fc ff ff       	call   8013da <getuint>
  801777:	89 c6                	mov    %eax,%esi
  801779:	89 d7                	mov    %edx,%edi
			base = 16;
  80177b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801780:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801784:	89 54 24 10          	mov    %edx,0x10(%esp)
  801788:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80178b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80178f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801793:	89 34 24             	mov    %esi,(%esp)
  801796:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80179a:	89 da                	mov    %ebx,%edx
  80179c:	8b 45 08             	mov    0x8(%ebp),%eax
  80179f:	e8 6c fb ff ff       	call   801310 <printnum>
			break;
  8017a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8017a7:	e9 cd fc ff ff       	jmp    801479 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8017ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017b0:	89 04 24             	mov    %eax,(%esp)
  8017b3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8017b9:	e9 bb fc ff ff       	jmp    801479 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8017be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8017c9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8017cc:	eb 01                	jmp    8017cf <vprintfmt+0x379>
  8017ce:	4e                   	dec    %esi
  8017cf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8017d3:	75 f9                	jne    8017ce <vprintfmt+0x378>
  8017d5:	e9 9f fc ff ff       	jmp    801479 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8017da:	83 c4 4c             	add    $0x4c,%esp
  8017dd:	5b                   	pop    %ebx
  8017de:	5e                   	pop    %esi
  8017df:	5f                   	pop    %edi
  8017e0:	5d                   	pop    %ebp
  8017e1:	c3                   	ret    

008017e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	83 ec 28             	sub    $0x28,%esp
  8017e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8017ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8017f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8017f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8017f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8017ff:	85 c0                	test   %eax,%eax
  801801:	74 30                	je     801833 <vsnprintf+0x51>
  801803:	85 d2                	test   %edx,%edx
  801805:	7e 33                	jle    80183a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801807:	8b 45 14             	mov    0x14(%ebp),%eax
  80180a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80180e:	8b 45 10             	mov    0x10(%ebp),%eax
  801811:	89 44 24 08          	mov    %eax,0x8(%esp)
  801815:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181c:	c7 04 24 14 14 80 00 	movl   $0x801414,(%esp)
  801823:	e8 2e fc ff ff       	call   801456 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801828:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80182b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80182e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801831:	eb 0c                	jmp    80183f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801833:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801838:	eb 05                	jmp    80183f <vsnprintf+0x5d>
  80183a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80183f:	c9                   	leave  
  801840:	c3                   	ret    

00801841 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801847:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80184a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80184e:	8b 45 10             	mov    0x10(%ebp),%eax
  801851:	89 44 24 08          	mov    %eax,0x8(%esp)
  801855:	8b 45 0c             	mov    0xc(%ebp),%eax
  801858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185c:	8b 45 08             	mov    0x8(%ebp),%eax
  80185f:	89 04 24             	mov    %eax,(%esp)
  801862:	e8 7b ff ff ff       	call   8017e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801867:	c9                   	leave  
  801868:	c3                   	ret    
  801869:	00 00                	add    %al,(%eax)
	...

0080186c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801872:	b8 00 00 00 00       	mov    $0x0,%eax
  801877:	eb 01                	jmp    80187a <strlen+0xe>
		n++;
  801879:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80187a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80187e:	75 f9                	jne    801879 <strlen+0xd>
		n++;
	return n;
}
  801880:	5d                   	pop    %ebp
  801881:	c3                   	ret    

00801882 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801888:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80188b:	b8 00 00 00 00       	mov    $0x0,%eax
  801890:	eb 01                	jmp    801893 <strnlen+0x11>
		n++;
  801892:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801893:	39 d0                	cmp    %edx,%eax
  801895:	74 06                	je     80189d <strnlen+0x1b>
  801897:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80189b:	75 f5                	jne    801892 <strnlen+0x10>
		n++;
	return n;
}
  80189d:	5d                   	pop    %ebp
  80189e:	c3                   	ret    

0080189f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	53                   	push   %ebx
  8018a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8018a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ae:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8018b1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8018b4:	42                   	inc    %edx
  8018b5:	84 c9                	test   %cl,%cl
  8018b7:	75 f5                	jne    8018ae <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8018b9:	5b                   	pop    %ebx
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8018c6:	89 1c 24             	mov    %ebx,(%esp)
  8018c9:	e8 9e ff ff ff       	call   80186c <strlen>
	strcpy(dst + len, src);
  8018ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018d5:	01 d8                	add    %ebx,%eax
  8018d7:	89 04 24             	mov    %eax,(%esp)
  8018da:	e8 c0 ff ff ff       	call   80189f <strcpy>
	return dst;
}
  8018df:	89 d8                	mov    %ebx,%eax
  8018e1:	83 c4 08             	add    $0x8,%esp
  8018e4:	5b                   	pop    %ebx
  8018e5:	5d                   	pop    %ebp
  8018e6:	c3                   	ret    

008018e7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	56                   	push   %esi
  8018eb:	53                   	push   %ebx
  8018ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8018f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018fa:	eb 0c                	jmp    801908 <strncpy+0x21>
		*dst++ = *src;
  8018fc:	8a 1a                	mov    (%edx),%bl
  8018fe:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801901:	80 3a 01             	cmpb   $0x1,(%edx)
  801904:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801907:	41                   	inc    %ecx
  801908:	39 f1                	cmp    %esi,%ecx
  80190a:	75 f0                	jne    8018fc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80190c:	5b                   	pop    %ebx
  80190d:	5e                   	pop    %esi
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    

00801910 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	56                   	push   %esi
  801914:	53                   	push   %ebx
  801915:	8b 75 08             	mov    0x8(%ebp),%esi
  801918:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80191b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80191e:	85 d2                	test   %edx,%edx
  801920:	75 0a                	jne    80192c <strlcpy+0x1c>
  801922:	89 f0                	mov    %esi,%eax
  801924:	eb 1a                	jmp    801940 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801926:	88 18                	mov    %bl,(%eax)
  801928:	40                   	inc    %eax
  801929:	41                   	inc    %ecx
  80192a:	eb 02                	jmp    80192e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80192c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80192e:	4a                   	dec    %edx
  80192f:	74 0a                	je     80193b <strlcpy+0x2b>
  801931:	8a 19                	mov    (%ecx),%bl
  801933:	84 db                	test   %bl,%bl
  801935:	75 ef                	jne    801926 <strlcpy+0x16>
  801937:	89 c2                	mov    %eax,%edx
  801939:	eb 02                	jmp    80193d <strlcpy+0x2d>
  80193b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80193d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801940:	29 f0                	sub    %esi,%eax
}
  801942:	5b                   	pop    %ebx
  801943:	5e                   	pop    %esi
  801944:	5d                   	pop    %ebp
  801945:	c3                   	ret    

00801946 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80194f:	eb 02                	jmp    801953 <strcmp+0xd>
		p++, q++;
  801951:	41                   	inc    %ecx
  801952:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801953:	8a 01                	mov    (%ecx),%al
  801955:	84 c0                	test   %al,%al
  801957:	74 04                	je     80195d <strcmp+0x17>
  801959:	3a 02                	cmp    (%edx),%al
  80195b:	74 f4                	je     801951 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80195d:	0f b6 c0             	movzbl %al,%eax
  801960:	0f b6 12             	movzbl (%edx),%edx
  801963:	29 d0                	sub    %edx,%eax
}
  801965:	5d                   	pop    %ebp
  801966:	c3                   	ret    

00801967 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	53                   	push   %ebx
  80196b:	8b 45 08             	mov    0x8(%ebp),%eax
  80196e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801971:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801974:	eb 03                	jmp    801979 <strncmp+0x12>
		n--, p++, q++;
  801976:	4a                   	dec    %edx
  801977:	40                   	inc    %eax
  801978:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801979:	85 d2                	test   %edx,%edx
  80197b:	74 14                	je     801991 <strncmp+0x2a>
  80197d:	8a 18                	mov    (%eax),%bl
  80197f:	84 db                	test   %bl,%bl
  801981:	74 04                	je     801987 <strncmp+0x20>
  801983:	3a 19                	cmp    (%ecx),%bl
  801985:	74 ef                	je     801976 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801987:	0f b6 00             	movzbl (%eax),%eax
  80198a:	0f b6 11             	movzbl (%ecx),%edx
  80198d:	29 d0                	sub    %edx,%eax
  80198f:	eb 05                	jmp    801996 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801991:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801996:	5b                   	pop    %ebx
  801997:	5d                   	pop    %ebp
  801998:	c3                   	ret    

00801999 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	8b 45 08             	mov    0x8(%ebp),%eax
  80199f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8019a2:	eb 05                	jmp    8019a9 <strchr+0x10>
		if (*s == c)
  8019a4:	38 ca                	cmp    %cl,%dl
  8019a6:	74 0c                	je     8019b4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8019a8:	40                   	inc    %eax
  8019a9:	8a 10                	mov    (%eax),%dl
  8019ab:	84 d2                	test   %dl,%dl
  8019ad:	75 f5                	jne    8019a4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8019af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b4:	5d                   	pop    %ebp
  8019b5:	c3                   	ret    

008019b6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8019bf:	eb 05                	jmp    8019c6 <strfind+0x10>
		if (*s == c)
  8019c1:	38 ca                	cmp    %cl,%dl
  8019c3:	74 07                	je     8019cc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8019c5:	40                   	inc    %eax
  8019c6:	8a 10                	mov    (%eax),%dl
  8019c8:	84 d2                	test   %dl,%dl
  8019ca:	75 f5                	jne    8019c1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8019cc:	5d                   	pop    %ebp
  8019cd:	c3                   	ret    

008019ce <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	57                   	push   %edi
  8019d2:	56                   	push   %esi
  8019d3:	53                   	push   %ebx
  8019d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8019dd:	85 c9                	test   %ecx,%ecx
  8019df:	74 30                	je     801a11 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8019e1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8019e7:	75 25                	jne    801a0e <memset+0x40>
  8019e9:	f6 c1 03             	test   $0x3,%cl
  8019ec:	75 20                	jne    801a0e <memset+0x40>
		c &= 0xFF;
  8019ee:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8019f1:	89 d3                	mov    %edx,%ebx
  8019f3:	c1 e3 08             	shl    $0x8,%ebx
  8019f6:	89 d6                	mov    %edx,%esi
  8019f8:	c1 e6 18             	shl    $0x18,%esi
  8019fb:	89 d0                	mov    %edx,%eax
  8019fd:	c1 e0 10             	shl    $0x10,%eax
  801a00:	09 f0                	or     %esi,%eax
  801a02:	09 d0                	or     %edx,%eax
  801a04:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801a06:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801a09:	fc                   	cld    
  801a0a:	f3 ab                	rep stos %eax,%es:(%edi)
  801a0c:	eb 03                	jmp    801a11 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801a0e:	fc                   	cld    
  801a0f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801a11:	89 f8                	mov    %edi,%eax
  801a13:	5b                   	pop    %ebx
  801a14:	5e                   	pop    %esi
  801a15:	5f                   	pop    %edi
  801a16:	5d                   	pop    %ebp
  801a17:	c3                   	ret    

00801a18 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	57                   	push   %edi
  801a1c:	56                   	push   %esi
  801a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a20:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801a26:	39 c6                	cmp    %eax,%esi
  801a28:	73 34                	jae    801a5e <memmove+0x46>
  801a2a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801a2d:	39 d0                	cmp    %edx,%eax
  801a2f:	73 2d                	jae    801a5e <memmove+0x46>
		s += n;
		d += n;
  801a31:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a34:	f6 c2 03             	test   $0x3,%dl
  801a37:	75 1b                	jne    801a54 <memmove+0x3c>
  801a39:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801a3f:	75 13                	jne    801a54 <memmove+0x3c>
  801a41:	f6 c1 03             	test   $0x3,%cl
  801a44:	75 0e                	jne    801a54 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801a46:	83 ef 04             	sub    $0x4,%edi
  801a49:	8d 72 fc             	lea    -0x4(%edx),%esi
  801a4c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801a4f:	fd                   	std    
  801a50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a52:	eb 07                	jmp    801a5b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801a54:	4f                   	dec    %edi
  801a55:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801a58:	fd                   	std    
  801a59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801a5b:	fc                   	cld    
  801a5c:	eb 20                	jmp    801a7e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801a5e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801a64:	75 13                	jne    801a79 <memmove+0x61>
  801a66:	a8 03                	test   $0x3,%al
  801a68:	75 0f                	jne    801a79 <memmove+0x61>
  801a6a:	f6 c1 03             	test   $0x3,%cl
  801a6d:	75 0a                	jne    801a79 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801a6f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801a72:	89 c7                	mov    %eax,%edi
  801a74:	fc                   	cld    
  801a75:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801a77:	eb 05                	jmp    801a7e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801a79:	89 c7                	mov    %eax,%edi
  801a7b:	fc                   	cld    
  801a7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801a7e:	5e                   	pop    %esi
  801a7f:	5f                   	pop    %edi
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    

00801a82 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801a88:	8b 45 10             	mov    0x10(%ebp),%eax
  801a8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a96:	8b 45 08             	mov    0x8(%ebp),%eax
  801a99:	89 04 24             	mov    %eax,(%esp)
  801a9c:	e8 77 ff ff ff       	call   801a18 <memmove>
}
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    

00801aa3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	57                   	push   %edi
  801aa7:	56                   	push   %esi
  801aa8:	53                   	push   %ebx
  801aa9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aac:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aaf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ab2:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab7:	eb 16                	jmp    801acf <memcmp+0x2c>
		if (*s1 != *s2)
  801ab9:	8a 04 17             	mov    (%edi,%edx,1),%al
  801abc:	42                   	inc    %edx
  801abd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801ac1:	38 c8                	cmp    %cl,%al
  801ac3:	74 0a                	je     801acf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801ac5:	0f b6 c0             	movzbl %al,%eax
  801ac8:	0f b6 c9             	movzbl %cl,%ecx
  801acb:	29 c8                	sub    %ecx,%eax
  801acd:	eb 09                	jmp    801ad8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801acf:	39 da                	cmp    %ebx,%edx
  801ad1:	75 e6                	jne    801ab9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801ad3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ad8:	5b                   	pop    %ebx
  801ad9:	5e                   	pop    %esi
  801ada:	5f                   	pop    %edi
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    

00801add <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801ae6:	89 c2                	mov    %eax,%edx
  801ae8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801aeb:	eb 05                	jmp    801af2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801aed:	38 08                	cmp    %cl,(%eax)
  801aef:	74 05                	je     801af6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801af1:	40                   	inc    %eax
  801af2:	39 d0                	cmp    %edx,%eax
  801af4:	72 f7                	jb     801aed <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801af6:	5d                   	pop    %ebp
  801af7:	c3                   	ret    

00801af8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	57                   	push   %edi
  801afc:	56                   	push   %esi
  801afd:	53                   	push   %ebx
  801afe:	8b 55 08             	mov    0x8(%ebp),%edx
  801b01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b04:	eb 01                	jmp    801b07 <strtol+0xf>
		s++;
  801b06:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801b07:	8a 02                	mov    (%edx),%al
  801b09:	3c 20                	cmp    $0x20,%al
  801b0b:	74 f9                	je     801b06 <strtol+0xe>
  801b0d:	3c 09                	cmp    $0x9,%al
  801b0f:	74 f5                	je     801b06 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801b11:	3c 2b                	cmp    $0x2b,%al
  801b13:	75 08                	jne    801b1d <strtol+0x25>
		s++;
  801b15:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b16:	bf 00 00 00 00       	mov    $0x0,%edi
  801b1b:	eb 13                	jmp    801b30 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801b1d:	3c 2d                	cmp    $0x2d,%al
  801b1f:	75 0a                	jne    801b2b <strtol+0x33>
		s++, neg = 1;
  801b21:	8d 52 01             	lea    0x1(%edx),%edx
  801b24:	bf 01 00 00 00       	mov    $0x1,%edi
  801b29:	eb 05                	jmp    801b30 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801b2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801b30:	85 db                	test   %ebx,%ebx
  801b32:	74 05                	je     801b39 <strtol+0x41>
  801b34:	83 fb 10             	cmp    $0x10,%ebx
  801b37:	75 28                	jne    801b61 <strtol+0x69>
  801b39:	8a 02                	mov    (%edx),%al
  801b3b:	3c 30                	cmp    $0x30,%al
  801b3d:	75 10                	jne    801b4f <strtol+0x57>
  801b3f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801b43:	75 0a                	jne    801b4f <strtol+0x57>
		s += 2, base = 16;
  801b45:	83 c2 02             	add    $0x2,%edx
  801b48:	bb 10 00 00 00       	mov    $0x10,%ebx
  801b4d:	eb 12                	jmp    801b61 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801b4f:	85 db                	test   %ebx,%ebx
  801b51:	75 0e                	jne    801b61 <strtol+0x69>
  801b53:	3c 30                	cmp    $0x30,%al
  801b55:	75 05                	jne    801b5c <strtol+0x64>
		s++, base = 8;
  801b57:	42                   	inc    %edx
  801b58:	b3 08                	mov    $0x8,%bl
  801b5a:	eb 05                	jmp    801b61 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801b5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801b61:	b8 00 00 00 00       	mov    $0x0,%eax
  801b66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801b68:	8a 0a                	mov    (%edx),%cl
  801b6a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801b6d:	80 fb 09             	cmp    $0x9,%bl
  801b70:	77 08                	ja     801b7a <strtol+0x82>
			dig = *s - '0';
  801b72:	0f be c9             	movsbl %cl,%ecx
  801b75:	83 e9 30             	sub    $0x30,%ecx
  801b78:	eb 1e                	jmp    801b98 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801b7a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801b7d:	80 fb 19             	cmp    $0x19,%bl
  801b80:	77 08                	ja     801b8a <strtol+0x92>
			dig = *s - 'a' + 10;
  801b82:	0f be c9             	movsbl %cl,%ecx
  801b85:	83 e9 57             	sub    $0x57,%ecx
  801b88:	eb 0e                	jmp    801b98 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801b8a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801b8d:	80 fb 19             	cmp    $0x19,%bl
  801b90:	77 12                	ja     801ba4 <strtol+0xac>
			dig = *s - 'A' + 10;
  801b92:	0f be c9             	movsbl %cl,%ecx
  801b95:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801b98:	39 f1                	cmp    %esi,%ecx
  801b9a:	7d 0c                	jge    801ba8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801b9c:	42                   	inc    %edx
  801b9d:	0f af c6             	imul   %esi,%eax
  801ba0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801ba2:	eb c4                	jmp    801b68 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801ba4:	89 c1                	mov    %eax,%ecx
  801ba6:	eb 02                	jmp    801baa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801ba8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801baa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801bae:	74 05                	je     801bb5 <strtol+0xbd>
		*endptr = (char *) s;
  801bb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bb3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801bb5:	85 ff                	test   %edi,%edi
  801bb7:	74 04                	je     801bbd <strtol+0xc5>
  801bb9:	89 c8                	mov    %ecx,%eax
  801bbb:	f7 d8                	neg    %eax
}
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5f                   	pop    %edi
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    
	...

00801bc4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	56                   	push   %esi
  801bc8:	53                   	push   %ebx
  801bc9:	83 ec 10             	sub    $0x10,%esp
  801bcc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	75 05                	jne    801bde <ipc_recv+0x1a>
  801bd9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801bde:	89 04 24             	mov    %eax,(%esp)
  801be1:	e8 b1 e7 ff ff       	call   800397 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801be6:	85 c0                	test   %eax,%eax
  801be8:	79 16                	jns    801c00 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801bea:	85 db                	test   %ebx,%ebx
  801bec:	74 06                	je     801bf4 <ipc_recv+0x30>
  801bee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801bf4:	85 f6                	test   %esi,%esi
  801bf6:	74 32                	je     801c2a <ipc_recv+0x66>
  801bf8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801bfe:	eb 2a                	jmp    801c2a <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801c00:	85 db                	test   %ebx,%ebx
  801c02:	74 0c                	je     801c10 <ipc_recv+0x4c>
  801c04:	a1 04 40 80 00       	mov    0x804004,%eax
  801c09:	8b 00                	mov    (%eax),%eax
  801c0b:	8b 40 74             	mov    0x74(%eax),%eax
  801c0e:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801c10:	85 f6                	test   %esi,%esi
  801c12:	74 0c                	je     801c20 <ipc_recv+0x5c>
  801c14:	a1 04 40 80 00       	mov    0x804004,%eax
  801c19:	8b 00                	mov    (%eax),%eax
  801c1b:	8b 40 78             	mov    0x78(%eax),%eax
  801c1e:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801c20:	a1 04 40 80 00       	mov    0x804004,%eax
  801c25:	8b 00                	mov    (%eax),%eax
  801c27:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    

00801c31 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	57                   	push   %edi
  801c35:	56                   	push   %esi
  801c36:	53                   	push   %ebx
  801c37:	83 ec 1c             	sub    $0x1c,%esp
  801c3a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c40:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801c43:	85 db                	test   %ebx,%ebx
  801c45:	75 05                	jne    801c4c <ipc_send+0x1b>
  801c47:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801c4c:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c50:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c54:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c58:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5b:	89 04 24             	mov    %eax,(%esp)
  801c5e:	e8 11 e7 ff ff       	call   800374 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801c63:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c66:	75 07                	jne    801c6f <ipc_send+0x3e>
  801c68:	e8 f5 e4 ff ff       	call   800162 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801c6d:	eb dd                	jmp    801c4c <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	79 1c                	jns    801c8f <ipc_send+0x5e>
  801c73:	c7 44 24 08 c0 23 80 	movl   $0x8023c0,0x8(%esp)
  801c7a:	00 
  801c7b:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801c82:	00 
  801c83:	c7 04 24 d2 23 80 00 	movl   $0x8023d2,(%esp)
  801c8a:	e8 6d f5 ff ff       	call   8011fc <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801c8f:	83 c4 1c             	add    $0x1c,%esp
  801c92:	5b                   	pop    %ebx
  801c93:	5e                   	pop    %esi
  801c94:	5f                   	pop    %edi
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    

00801c97 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	53                   	push   %ebx
  801c9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801c9e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ca3:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801caa:	89 c2                	mov    %eax,%edx
  801cac:	c1 e2 07             	shl    $0x7,%edx
  801caf:	29 ca                	sub    %ecx,%edx
  801cb1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801cb7:	8b 52 50             	mov    0x50(%edx),%edx
  801cba:	39 da                	cmp    %ebx,%edx
  801cbc:	75 0f                	jne    801ccd <ipc_find_env+0x36>
			return envs[i].env_id;
  801cbe:	c1 e0 07             	shl    $0x7,%eax
  801cc1:	29 c8                	sub    %ecx,%eax
  801cc3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801cc8:	8b 40 40             	mov    0x40(%eax),%eax
  801ccb:	eb 0c                	jmp    801cd9 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ccd:	40                   	inc    %eax
  801cce:	3d 00 04 00 00       	cmp    $0x400,%eax
  801cd3:	75 ce                	jne    801ca3 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801cd5:	66 b8 00 00          	mov    $0x0,%ax
}
  801cd9:	5b                   	pop    %ebx
  801cda:	5d                   	pop    %ebp
  801cdb:	c3                   	ret    

00801cdc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801ce2:	89 c2                	mov    %eax,%edx
  801ce4:	c1 ea 16             	shr    $0x16,%edx
  801ce7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cee:	f6 c2 01             	test   $0x1,%dl
  801cf1:	74 1e                	je     801d11 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801cf3:	c1 e8 0c             	shr    $0xc,%eax
  801cf6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801cfd:	a8 01                	test   $0x1,%al
  801cff:	74 17                	je     801d18 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d01:	c1 e8 0c             	shr    $0xc,%eax
  801d04:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801d0b:	ef 
  801d0c:	0f b7 c0             	movzwl %ax,%eax
  801d0f:	eb 0c                	jmp    801d1d <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801d11:	b8 00 00 00 00       	mov    $0x0,%eax
  801d16:	eb 05                	jmp    801d1d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801d18:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801d1d:	5d                   	pop    %ebp
  801d1e:	c3                   	ret    
	...

00801d20 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801d20:	55                   	push   %ebp
  801d21:	57                   	push   %edi
  801d22:	56                   	push   %esi
  801d23:	83 ec 10             	sub    $0x10,%esp
  801d26:	8b 74 24 20          	mov    0x20(%esp),%esi
  801d2a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801d2e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d32:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801d36:	89 cd                	mov    %ecx,%ebp
  801d38:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	75 2c                	jne    801d6c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801d40:	39 f9                	cmp    %edi,%ecx
  801d42:	77 68                	ja     801dac <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801d44:	85 c9                	test   %ecx,%ecx
  801d46:	75 0b                	jne    801d53 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801d48:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4d:	31 d2                	xor    %edx,%edx
  801d4f:	f7 f1                	div    %ecx
  801d51:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801d53:	31 d2                	xor    %edx,%edx
  801d55:	89 f8                	mov    %edi,%eax
  801d57:	f7 f1                	div    %ecx
  801d59:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801d5b:	89 f0                	mov    %esi,%eax
  801d5d:	f7 f1                	div    %ecx
  801d5f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d61:	89 f0                	mov    %esi,%eax
  801d63:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d65:	83 c4 10             	add    $0x10,%esp
  801d68:	5e                   	pop    %esi
  801d69:	5f                   	pop    %edi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d6c:	39 f8                	cmp    %edi,%eax
  801d6e:	77 2c                	ja     801d9c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801d70:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801d73:	83 f6 1f             	xor    $0x1f,%esi
  801d76:	75 4c                	jne    801dc4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d78:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d7a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801d7f:	72 0a                	jb     801d8b <__udivdi3+0x6b>
  801d81:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801d85:	0f 87 ad 00 00 00    	ja     801e38 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801d8b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801d90:	89 f0                	mov    %esi,%eax
  801d92:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801d94:	83 c4 10             	add    $0x10,%esp
  801d97:	5e                   	pop    %esi
  801d98:	5f                   	pop    %edi
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    
  801d9b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801d9c:	31 ff                	xor    %edi,%edi
  801d9e:	31 f6                	xor    %esi,%esi
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
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801dac:	89 fa                	mov    %edi,%edx
  801dae:	89 f0                	mov    %esi,%eax
  801db0:	f7 f1                	div    %ecx
  801db2:	89 c6                	mov    %eax,%esi
  801db4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801db6:	89 f0                	mov    %esi,%eax
  801db8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801dba:	83 c4 10             	add    $0x10,%esp
  801dbd:	5e                   	pop    %esi
  801dbe:	5f                   	pop    %edi
  801dbf:	5d                   	pop    %ebp
  801dc0:	c3                   	ret    
  801dc1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801dc4:	89 f1                	mov    %esi,%ecx
  801dc6:	d3 e0                	shl    %cl,%eax
  801dc8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801dcc:	b8 20 00 00 00       	mov    $0x20,%eax
  801dd1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801dd3:	89 ea                	mov    %ebp,%edx
  801dd5:	88 c1                	mov    %al,%cl
  801dd7:	d3 ea                	shr    %cl,%edx
  801dd9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801ddd:	09 ca                	or     %ecx,%edx
  801ddf:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801de3:	89 f1                	mov    %esi,%ecx
  801de5:	d3 e5                	shl    %cl,%ebp
  801de7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801deb:	89 fd                	mov    %edi,%ebp
  801ded:	88 c1                	mov    %al,%cl
  801def:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801df1:	89 fa                	mov    %edi,%edx
  801df3:	89 f1                	mov    %esi,%ecx
  801df5:	d3 e2                	shl    %cl,%edx
  801df7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801dfb:	88 c1                	mov    %al,%cl
  801dfd:	d3 ef                	shr    %cl,%edi
  801dff:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801e01:	89 f8                	mov    %edi,%eax
  801e03:	89 ea                	mov    %ebp,%edx
  801e05:	f7 74 24 08          	divl   0x8(%esp)
  801e09:	89 d1                	mov    %edx,%ecx
  801e0b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801e0d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e11:	39 d1                	cmp    %edx,%ecx
  801e13:	72 17                	jb     801e2c <__udivdi3+0x10c>
  801e15:	74 09                	je     801e20 <__udivdi3+0x100>
  801e17:	89 fe                	mov    %edi,%esi
  801e19:	31 ff                	xor    %edi,%edi
  801e1b:	e9 41 ff ff ff       	jmp    801d61 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801e20:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e24:	89 f1                	mov    %esi,%ecx
  801e26:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801e28:	39 c2                	cmp    %eax,%edx
  801e2a:	73 eb                	jae    801e17 <__udivdi3+0xf7>
		{
		  q0--;
  801e2c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801e2f:	31 ff                	xor    %edi,%edi
  801e31:	e9 2b ff ff ff       	jmp    801d61 <__udivdi3+0x41>
  801e36:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e38:	31 f6                	xor    %esi,%esi
  801e3a:	e9 22 ff ff ff       	jmp    801d61 <__udivdi3+0x41>
	...

00801e40 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801e40:	55                   	push   %ebp
  801e41:	57                   	push   %edi
  801e42:	56                   	push   %esi
  801e43:	83 ec 20             	sub    $0x20,%esp
  801e46:	8b 44 24 30          	mov    0x30(%esp),%eax
  801e4a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801e4e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801e52:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801e56:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e5a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801e5e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801e60:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801e62:	85 ed                	test   %ebp,%ebp
  801e64:	75 16                	jne    801e7c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801e66:	39 f1                	cmp    %esi,%ecx
  801e68:	0f 86 a6 00 00 00    	jbe    801f14 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e6e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801e70:	89 d0                	mov    %edx,%eax
  801e72:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801e74:	83 c4 20             	add    $0x20,%esp
  801e77:	5e                   	pop    %esi
  801e78:	5f                   	pop    %edi
  801e79:	5d                   	pop    %ebp
  801e7a:	c3                   	ret    
  801e7b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e7c:	39 f5                	cmp    %esi,%ebp
  801e7e:	0f 87 ac 00 00 00    	ja     801f30 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e84:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801e87:	83 f0 1f             	xor    $0x1f,%eax
  801e8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e8e:	0f 84 a8 00 00 00    	je     801f3c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e94:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801e98:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e9a:	bf 20 00 00 00       	mov    $0x20,%edi
  801e9f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801ea3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ea7:	89 f9                	mov    %edi,%ecx
  801ea9:	d3 e8                	shr    %cl,%eax
  801eab:	09 e8                	or     %ebp,%eax
  801ead:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801eb1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801eb5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801eb9:	d3 e0                	shl    %cl,%eax
  801ebb:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ebf:	89 f2                	mov    %esi,%edx
  801ec1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801ec3:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ec7:	d3 e0                	shl    %cl,%eax
  801ec9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801ecd:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ed1:	89 f9                	mov    %edi,%ecx
  801ed3:	d3 e8                	shr    %cl,%eax
  801ed5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801ed7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801ed9:	89 f2                	mov    %esi,%edx
  801edb:	f7 74 24 18          	divl   0x18(%esp)
  801edf:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801ee1:	f7 64 24 0c          	mull   0xc(%esp)
  801ee5:	89 c5                	mov    %eax,%ebp
  801ee7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ee9:	39 d6                	cmp    %edx,%esi
  801eeb:	72 67                	jb     801f54 <__umoddi3+0x114>
  801eed:	74 75                	je     801f64 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801eef:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801ef3:	29 e8                	sub    %ebp,%eax
  801ef5:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801ef7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801efb:	d3 e8                	shr    %cl,%eax
  801efd:	89 f2                	mov    %esi,%edx
  801eff:	89 f9                	mov    %edi,%ecx
  801f01:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801f03:	09 d0                	or     %edx,%eax
  801f05:	89 f2                	mov    %esi,%edx
  801f07:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f0b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f0d:	83 c4 20             	add    $0x20,%esp
  801f10:	5e                   	pop    %esi
  801f11:	5f                   	pop    %edi
  801f12:	5d                   	pop    %ebp
  801f13:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801f14:	85 c9                	test   %ecx,%ecx
  801f16:	75 0b                	jne    801f23 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801f18:	b8 01 00 00 00       	mov    $0x1,%eax
  801f1d:	31 d2                	xor    %edx,%edx
  801f1f:	f7 f1                	div    %ecx
  801f21:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801f23:	89 f0                	mov    %esi,%eax
  801f25:	31 d2                	xor    %edx,%edx
  801f27:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f29:	89 f8                	mov    %edi,%eax
  801f2b:	e9 3e ff ff ff       	jmp    801e6e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801f30:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f32:	83 c4 20             	add    $0x20,%esp
  801f35:	5e                   	pop    %esi
  801f36:	5f                   	pop    %edi
  801f37:	5d                   	pop    %ebp
  801f38:	c3                   	ret    
  801f39:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801f3c:	39 f5                	cmp    %esi,%ebp
  801f3e:	72 04                	jb     801f44 <__umoddi3+0x104>
  801f40:	39 f9                	cmp    %edi,%ecx
  801f42:	77 06                	ja     801f4a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801f44:	89 f2                	mov    %esi,%edx
  801f46:	29 cf                	sub    %ecx,%edi
  801f48:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  801f4a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f4c:	83 c4 20             	add    $0x20,%esp
  801f4f:	5e                   	pop    %esi
  801f50:	5f                   	pop    %edi
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    
  801f53:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801f54:	89 d1                	mov    %edx,%ecx
  801f56:	89 c5                	mov    %eax,%ebp
  801f58:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801f5c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801f60:	eb 8d                	jmp    801eef <__umoddi3+0xaf>
  801f62:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801f64:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801f68:	72 ea                	jb     801f54 <__umoddi3+0x114>
  801f6a:	89 f1                	mov    %esi,%ecx
  801f6c:	eb 81                	jmp    801eef <__umoddi3+0xaf>
