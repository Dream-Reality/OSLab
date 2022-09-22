
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
  80003d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800040:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800043:	83 ff 01             	cmp    $0x1,%edi
  800046:	7e 24                	jle    80006c <umain+0x38>
  800048:	c7 44 24 04 40 20 80 	movl   $0x802040,0x4(%esp)
  80004f:	00 
  800050:	8b 46 04             	mov    0x4(%esi),%eax
  800053:	89 04 24             	mov    %eax,(%esp)
  800056:	e8 eb 01 00 00       	call   800246 <strcmp>
  80005b:	85 c0                	test   %eax,%eax
  80005d:	75 16                	jne    800075 <umain+0x41>
		nflag = 1;
		argc--;
  80005f:	4f                   	dec    %edi
		argv++;
  800060:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800063:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  80006a:	eb 10                	jmp    80007c <umain+0x48>
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  80006c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800073:	eb 07                	jmp    80007c <umain+0x48>
  800075:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  80007c:	bb 01 00 00 00       	mov    $0x1,%ebx
  800081:	eb 44                	jmp    8000c7 <umain+0x93>
		if (i > 1)
  800083:	83 fb 01             	cmp    $0x1,%ebx
  800086:	7e 1c                	jle    8000a4 <umain+0x70>
			write(1, " ", 1);
  800088:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80008f:	00 
  800090:	c7 44 24 04 43 20 80 	movl   $0x802043,0x4(%esp)
  800097:	00 
  800098:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80009f:	e8 51 0b 00 00       	call   800bf5 <write>
		write(1, argv[i], strlen(argv[i]));
  8000a4:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000a7:	89 04 24             	mov    %eax,(%esp)
  8000aa:	e8 bd 00 00 00       	call   80016c <strlen>
  8000af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b3:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000c1:	e8 2f 0b 00 00       	call   800bf5 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000c6:	43                   	inc    %ebx
  8000c7:	39 df                	cmp    %ebx,%edi
  8000c9:	7f b8                	jg     800083 <umain+0x4f>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000cf:	75 1c                	jne    8000ed <umain+0xb9>
		write(1, "\n", 1);
  8000d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000d8:	00 
  8000d9:	c7 44 24 04 90 24 80 	movl   $0x802490,0x4(%esp)
  8000e0:	00 
  8000e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000e8:	e8 08 0b 00 00       	call   800bf5 <write>
}
  8000ed:	83 c4 2c             	add    $0x2c,%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <libmain>:
#define thisenv (*pthisenv)
const volatile struct Env **pthisenv;

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 20             	sub    $0x20,%esp
  800100:	8b 75 08             	mov    0x8(%ebp),%esi
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// cprintf("thisenv %x\n",thisenv);
	// thisenv = 0;
	const volatile struct Env *local_thisenv = (envs + ENVX(sys_getenvid()));
  800106:	e8 48 04 00 00       	call   800553 <sys_getenvid>
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800117:	c1 e0 07             	shl    $0x7,%eax
  80011a:	29 d0                	sub    %edx,%eax
  80011c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800121:	89 45 f4             	mov    %eax,-0xc(%ebp)
	pthisenv = &local_thisenv;
  800124:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800127:	a3 04 40 80 00       	mov    %eax,0x804004
	// cprintf("%x\n",pthisenv);
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012c:	85 f6                	test   %esi,%esi
  80012e:	7e 07                	jle    800137 <libmain+0x3f>
		binaryname = argv[0];
  800130:	8b 03                	mov    (%ebx),%eax
  800132:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800137:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013b:	89 34 24             	mov    %esi,(%esp)
  80013e:	e8 f1 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800143:	e8 08 00 00 00       	call   800150 <exit>
}
  800148:	83 c4 20             	add    $0x20,%esp
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    
	...

00800150 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800156:	e8 8a 08 00 00       	call   8009e5 <close_all>
	sys_env_destroy(0);
  80015b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800162:	e8 9a 03 00 00       	call   800501 <sys_env_destroy>
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    
  800169:	00 00                	add    %al,(%eax)
	...

0080016c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800172:	b8 00 00 00 00       	mov    $0x0,%eax
  800177:	eb 01                	jmp    80017a <strlen+0xe>
		n++;
  800179:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80017a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80017e:	75 f9                	jne    800179 <strlen+0xd>
		n++;
	return n;
}
  800180:	5d                   	pop    %ebp
  800181:	c3                   	ret    

00800182 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800188:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80018b:	b8 00 00 00 00       	mov    $0x0,%eax
  800190:	eb 01                	jmp    800193 <strnlen+0x11>
		n++;
  800192:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800193:	39 d0                	cmp    %edx,%eax
  800195:	74 06                	je     80019d <strnlen+0x1b>
  800197:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80019b:	75 f5                	jne    800192 <strnlen+0x10>
		n++;
	return n;
}
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    

0080019f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	53                   	push   %ebx
  8001a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8001a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ae:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8001b1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8001b4:	42                   	inc    %edx
  8001b5:	84 c9                	test   %cl,%cl
  8001b7:	75 f5                	jne    8001ae <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8001b9:	5b                   	pop    %ebx
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	53                   	push   %ebx
  8001c0:	83 ec 08             	sub    $0x8,%esp
  8001c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001c6:	89 1c 24             	mov    %ebx,(%esp)
  8001c9:	e8 9e ff ff ff       	call   80016c <strlen>
	strcpy(dst + len, src);
  8001ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001d5:	01 d8                	add    %ebx,%eax
  8001d7:	89 04 24             	mov    %eax,(%esp)
  8001da:	e8 c0 ff ff ff       	call   80019f <strcpy>
	return dst;
}
  8001df:	89 d8                	mov    %ebx,%eax
  8001e1:	83 c4 08             	add    $0x8,%esp
  8001e4:	5b                   	pop    %ebx
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    

008001e7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	56                   	push   %esi
  8001eb:	53                   	push   %ebx
  8001ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001fa:	eb 0c                	jmp    800208 <strncpy+0x21>
		*dst++ = *src;
  8001fc:	8a 1a                	mov    (%edx),%bl
  8001fe:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800201:	80 3a 01             	cmpb   $0x1,(%edx)
  800204:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800207:	41                   	inc    %ecx
  800208:	39 f1                	cmp    %esi,%ecx
  80020a:	75 f0                	jne    8001fc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80020c:	5b                   	pop    %ebx
  80020d:	5e                   	pop    %esi
  80020e:	5d                   	pop    %ebp
  80020f:	c3                   	ret    

00800210 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	8b 75 08             	mov    0x8(%ebp),%esi
  800218:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80021e:	85 d2                	test   %edx,%edx
  800220:	75 0a                	jne    80022c <strlcpy+0x1c>
  800222:	89 f0                	mov    %esi,%eax
  800224:	eb 1a                	jmp    800240 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800226:	88 18                	mov    %bl,(%eax)
  800228:	40                   	inc    %eax
  800229:	41                   	inc    %ecx
  80022a:	eb 02                	jmp    80022e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80022c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80022e:	4a                   	dec    %edx
  80022f:	74 0a                	je     80023b <strlcpy+0x2b>
  800231:	8a 19                	mov    (%ecx),%bl
  800233:	84 db                	test   %bl,%bl
  800235:	75 ef                	jne    800226 <strlcpy+0x16>
  800237:	89 c2                	mov    %eax,%edx
  800239:	eb 02                	jmp    80023d <strlcpy+0x2d>
  80023b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80023d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800240:	29 f0                	sub    %esi,%eax
}
  800242:	5b                   	pop    %ebx
  800243:	5e                   	pop    %esi
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    

00800246 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80024f:	eb 02                	jmp    800253 <strcmp+0xd>
		p++, q++;
  800251:	41                   	inc    %ecx
  800252:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800253:	8a 01                	mov    (%ecx),%al
  800255:	84 c0                	test   %al,%al
  800257:	74 04                	je     80025d <strcmp+0x17>
  800259:	3a 02                	cmp    (%edx),%al
  80025b:	74 f4                	je     800251 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80025d:	0f b6 c0             	movzbl %al,%eax
  800260:	0f b6 12             	movzbl (%edx),%edx
  800263:	29 d0                	sub    %edx,%eax
}
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	53                   	push   %ebx
  80026b:	8b 45 08             	mov    0x8(%ebp),%eax
  80026e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800271:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800274:	eb 03                	jmp    800279 <strncmp+0x12>
		n--, p++, q++;
  800276:	4a                   	dec    %edx
  800277:	40                   	inc    %eax
  800278:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800279:	85 d2                	test   %edx,%edx
  80027b:	74 14                	je     800291 <strncmp+0x2a>
  80027d:	8a 18                	mov    (%eax),%bl
  80027f:	84 db                	test   %bl,%bl
  800281:	74 04                	je     800287 <strncmp+0x20>
  800283:	3a 19                	cmp    (%ecx),%bl
  800285:	74 ef                	je     800276 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800287:	0f b6 00             	movzbl (%eax),%eax
  80028a:	0f b6 11             	movzbl (%ecx),%edx
  80028d:	29 d0                	sub    %edx,%eax
  80028f:	eb 05                	jmp    800296 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800291:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800296:	5b                   	pop    %ebx
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8002a2:	eb 05                	jmp    8002a9 <strchr+0x10>
		if (*s == c)
  8002a4:	38 ca                	cmp    %cl,%dl
  8002a6:	74 0c                	je     8002b4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8002a8:	40                   	inc    %eax
  8002a9:	8a 10                	mov    (%eax),%dl
  8002ab:	84 d2                	test   %dl,%dl
  8002ad:	75 f5                	jne    8002a4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8002af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8002bf:	eb 05                	jmp    8002c6 <strfind+0x10>
		if (*s == c)
  8002c1:	38 ca                	cmp    %cl,%dl
  8002c3:	74 07                	je     8002cc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8002c5:	40                   	inc    %eax
  8002c6:	8a 10                	mov    (%eax),%dl
  8002c8:	84 d2                	test   %dl,%dl
  8002ca:	75 f5                	jne    8002c1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002dd:	85 c9                	test   %ecx,%ecx
  8002df:	74 30                	je     800311 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002e1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002e7:	75 25                	jne    80030e <memset+0x40>
  8002e9:	f6 c1 03             	test   $0x3,%cl
  8002ec:	75 20                	jne    80030e <memset+0x40>
		c &= 0xFF;
  8002ee:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002f1:	89 d3                	mov    %edx,%ebx
  8002f3:	c1 e3 08             	shl    $0x8,%ebx
  8002f6:	89 d6                	mov    %edx,%esi
  8002f8:	c1 e6 18             	shl    $0x18,%esi
  8002fb:	89 d0                	mov    %edx,%eax
  8002fd:	c1 e0 10             	shl    $0x10,%eax
  800300:	09 f0                	or     %esi,%eax
  800302:	09 d0                	or     %edx,%eax
  800304:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800306:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800309:	fc                   	cld    
  80030a:	f3 ab                	rep stos %eax,%es:(%edi)
  80030c:	eb 03                	jmp    800311 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80030e:	fc                   	cld    
  80030f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800311:	89 f8                	mov    %edi,%eax
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	5f                   	pop    %edi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	8b 45 08             	mov    0x8(%ebp),%eax
  800320:	8b 75 0c             	mov    0xc(%ebp),%esi
  800323:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800326:	39 c6                	cmp    %eax,%esi
  800328:	73 34                	jae    80035e <memmove+0x46>
  80032a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80032d:	39 d0                	cmp    %edx,%eax
  80032f:	73 2d                	jae    80035e <memmove+0x46>
		s += n;
		d += n;
  800331:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800334:	f6 c2 03             	test   $0x3,%dl
  800337:	75 1b                	jne    800354 <memmove+0x3c>
  800339:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80033f:	75 13                	jne    800354 <memmove+0x3c>
  800341:	f6 c1 03             	test   $0x3,%cl
  800344:	75 0e                	jne    800354 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800346:	83 ef 04             	sub    $0x4,%edi
  800349:	8d 72 fc             	lea    -0x4(%edx),%esi
  80034c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80034f:	fd                   	std    
  800350:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800352:	eb 07                	jmp    80035b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800354:	4f                   	dec    %edi
  800355:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800358:	fd                   	std    
  800359:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80035b:	fc                   	cld    
  80035c:	eb 20                	jmp    80037e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80035e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800364:	75 13                	jne    800379 <memmove+0x61>
  800366:	a8 03                	test   $0x3,%al
  800368:	75 0f                	jne    800379 <memmove+0x61>
  80036a:	f6 c1 03             	test   $0x3,%cl
  80036d:	75 0a                	jne    800379 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80036f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800372:	89 c7                	mov    %eax,%edi
  800374:	fc                   	cld    
  800375:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800377:	eb 05                	jmp    80037e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800379:	89 c7                	mov    %eax,%edi
  80037b:	fc                   	cld    
  80037c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80037e:	5e                   	pop    %esi
  80037f:	5f                   	pop    %edi
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800388:	8b 45 10             	mov    0x10(%ebp),%eax
  80038b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800392:	89 44 24 04          	mov    %eax,0x4(%esp)
  800396:	8b 45 08             	mov    0x8(%ebp),%eax
  800399:	89 04 24             	mov    %eax,(%esp)
  80039c:	e8 77 ff ff ff       	call   800318 <memmove>
}
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    

008003a3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	57                   	push   %edi
  8003a7:	56                   	push   %esi
  8003a8:	53                   	push   %ebx
  8003a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b7:	eb 16                	jmp    8003cf <memcmp+0x2c>
		if (*s1 != *s2)
  8003b9:	8a 04 17             	mov    (%edi,%edx,1),%al
  8003bc:	42                   	inc    %edx
  8003bd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8003c1:	38 c8                	cmp    %cl,%al
  8003c3:	74 0a                	je     8003cf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8003c5:	0f b6 c0             	movzbl %al,%eax
  8003c8:	0f b6 c9             	movzbl %cl,%ecx
  8003cb:	29 c8                	sub    %ecx,%eax
  8003cd:	eb 09                	jmp    8003d8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003cf:	39 da                	cmp    %ebx,%edx
  8003d1:	75 e6                	jne    8003b9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003d8:	5b                   	pop    %ebx
  8003d9:	5e                   	pop    %esi
  8003da:	5f                   	pop    %edi
  8003db:	5d                   	pop    %ebp
  8003dc:	c3                   	ret    

008003dd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
  8003e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8003e6:	89 c2                	mov    %eax,%edx
  8003e8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8003eb:	eb 05                	jmp    8003f2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003ed:	38 08                	cmp    %cl,(%eax)
  8003ef:	74 05                	je     8003f6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003f1:	40                   	inc    %eax
  8003f2:	39 d0                	cmp    %edx,%eax
  8003f4:	72 f7                	jb     8003ed <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003f6:	5d                   	pop    %ebp
  8003f7:	c3                   	ret    

008003f8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
  8003fb:	57                   	push   %edi
  8003fc:	56                   	push   %esi
  8003fd:	53                   	push   %ebx
  8003fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800401:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800404:	eb 01                	jmp    800407 <strtol+0xf>
		s++;
  800406:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800407:	8a 02                	mov    (%edx),%al
  800409:	3c 20                	cmp    $0x20,%al
  80040b:	74 f9                	je     800406 <strtol+0xe>
  80040d:	3c 09                	cmp    $0x9,%al
  80040f:	74 f5                	je     800406 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800411:	3c 2b                	cmp    $0x2b,%al
  800413:	75 08                	jne    80041d <strtol+0x25>
		s++;
  800415:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800416:	bf 00 00 00 00       	mov    $0x0,%edi
  80041b:	eb 13                	jmp    800430 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80041d:	3c 2d                	cmp    $0x2d,%al
  80041f:	75 0a                	jne    80042b <strtol+0x33>
		s++, neg = 1;
  800421:	8d 52 01             	lea    0x1(%edx),%edx
  800424:	bf 01 00 00 00       	mov    $0x1,%edi
  800429:	eb 05                	jmp    800430 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80042b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800430:	85 db                	test   %ebx,%ebx
  800432:	74 05                	je     800439 <strtol+0x41>
  800434:	83 fb 10             	cmp    $0x10,%ebx
  800437:	75 28                	jne    800461 <strtol+0x69>
  800439:	8a 02                	mov    (%edx),%al
  80043b:	3c 30                	cmp    $0x30,%al
  80043d:	75 10                	jne    80044f <strtol+0x57>
  80043f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800443:	75 0a                	jne    80044f <strtol+0x57>
		s += 2, base = 16;
  800445:	83 c2 02             	add    $0x2,%edx
  800448:	bb 10 00 00 00       	mov    $0x10,%ebx
  80044d:	eb 12                	jmp    800461 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80044f:	85 db                	test   %ebx,%ebx
  800451:	75 0e                	jne    800461 <strtol+0x69>
  800453:	3c 30                	cmp    $0x30,%al
  800455:	75 05                	jne    80045c <strtol+0x64>
		s++, base = 8;
  800457:	42                   	inc    %edx
  800458:	b3 08                	mov    $0x8,%bl
  80045a:	eb 05                	jmp    800461 <strtol+0x69>
	else if (base == 0)
		base = 10;
  80045c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800461:	b8 00 00 00 00       	mov    $0x0,%eax
  800466:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800468:	8a 0a                	mov    (%edx),%cl
  80046a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80046d:	80 fb 09             	cmp    $0x9,%bl
  800470:	77 08                	ja     80047a <strtol+0x82>
			dig = *s - '0';
  800472:	0f be c9             	movsbl %cl,%ecx
  800475:	83 e9 30             	sub    $0x30,%ecx
  800478:	eb 1e                	jmp    800498 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80047a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80047d:	80 fb 19             	cmp    $0x19,%bl
  800480:	77 08                	ja     80048a <strtol+0x92>
			dig = *s - 'a' + 10;
  800482:	0f be c9             	movsbl %cl,%ecx
  800485:	83 e9 57             	sub    $0x57,%ecx
  800488:	eb 0e                	jmp    800498 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80048a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80048d:	80 fb 19             	cmp    $0x19,%bl
  800490:	77 12                	ja     8004a4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800492:	0f be c9             	movsbl %cl,%ecx
  800495:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800498:	39 f1                	cmp    %esi,%ecx
  80049a:	7d 0c                	jge    8004a8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  80049c:	42                   	inc    %edx
  80049d:	0f af c6             	imul   %esi,%eax
  8004a0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8004a2:	eb c4                	jmp    800468 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8004a4:	89 c1                	mov    %eax,%ecx
  8004a6:	eb 02                	jmp    8004aa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8004a8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8004aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004ae:	74 05                	je     8004b5 <strtol+0xbd>
		*endptr = (char *) s;
  8004b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8004b5:	85 ff                	test   %edi,%edi
  8004b7:	74 04                	je     8004bd <strtol+0xc5>
  8004b9:	89 c8                	mov    %ecx,%eax
  8004bb:	f7 d8                	neg    %eax
}
  8004bd:	5b                   	pop    %ebx
  8004be:	5e                   	pop    %esi
  8004bf:	5f                   	pop    %edi
  8004c0:	5d                   	pop    %ebp
  8004c1:	c3                   	ret    
	...

008004c4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	57                   	push   %edi
  8004c8:	56                   	push   %esi
  8004c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d5:	89 c3                	mov    %eax,%ebx
  8004d7:	89 c7                	mov    %eax,%edi
  8004d9:	89 c6                	mov    %eax,%esi
  8004db:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004dd:	5b                   	pop    %ebx
  8004de:	5e                   	pop    %esi
  8004df:	5f                   	pop    %edi
  8004e0:	5d                   	pop    %ebp
  8004e1:	c3                   	ret    

008004e2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	57                   	push   %edi
  8004e6:	56                   	push   %esi
  8004e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8004f2:	89 d1                	mov    %edx,%ecx
  8004f4:	89 d3                	mov    %edx,%ebx
  8004f6:	89 d7                	mov    %edx,%edi
  8004f8:	89 d6                	mov    %edx,%esi
  8004fa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004fc:	5b                   	pop    %ebx
  8004fd:	5e                   	pop    %esi
  8004fe:	5f                   	pop    %edi
  8004ff:	5d                   	pop    %ebp
  800500:	c3                   	ret    

00800501 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800501:	55                   	push   %ebp
  800502:	89 e5                	mov    %esp,%ebp
  800504:	57                   	push   %edi
  800505:	56                   	push   %esi
  800506:	53                   	push   %ebx
  800507:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80050a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050f:	b8 03 00 00 00       	mov    $0x3,%eax
  800514:	8b 55 08             	mov    0x8(%ebp),%edx
  800517:	89 cb                	mov    %ecx,%ebx
  800519:	89 cf                	mov    %ecx,%edi
  80051b:	89 ce                	mov    %ecx,%esi
  80051d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80051f:	85 c0                	test   %eax,%eax
  800521:	7e 28                	jle    80054b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800523:	89 44 24 10          	mov    %eax,0x10(%esp)
  800527:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80052e:	00 
  80052f:	c7 44 24 08 4f 20 80 	movl   $0x80204f,0x8(%esp)
  800536:	00 
  800537:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80053e:	00 
  80053f:	c7 04 24 6c 20 80 00 	movl   $0x80206c,(%esp)
  800546:	e8 c1 10 00 00       	call   80160c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80054b:	83 c4 2c             	add    $0x2c,%esp
  80054e:	5b                   	pop    %ebx
  80054f:	5e                   	pop    %esi
  800550:	5f                   	pop    %edi
  800551:	5d                   	pop    %ebp
  800552:	c3                   	ret    

00800553 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800553:	55                   	push   %ebp
  800554:	89 e5                	mov    %esp,%ebp
  800556:	57                   	push   %edi
  800557:	56                   	push   %esi
  800558:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800559:	ba 00 00 00 00       	mov    $0x0,%edx
  80055e:	b8 02 00 00 00       	mov    $0x2,%eax
  800563:	89 d1                	mov    %edx,%ecx
  800565:	89 d3                	mov    %edx,%ebx
  800567:	89 d7                	mov    %edx,%edi
  800569:	89 d6                	mov    %edx,%esi
  80056b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80056d:	5b                   	pop    %ebx
  80056e:	5e                   	pop    %esi
  80056f:	5f                   	pop    %edi
  800570:	5d                   	pop    %ebp
  800571:	c3                   	ret    

00800572 <sys_yield>:

void
sys_yield(void)
{
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
  800575:	57                   	push   %edi
  800576:	56                   	push   %esi
  800577:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800578:	ba 00 00 00 00       	mov    $0x0,%edx
  80057d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800582:	89 d1                	mov    %edx,%ecx
  800584:	89 d3                	mov    %edx,%ebx
  800586:	89 d7                	mov    %edx,%edi
  800588:	89 d6                	mov    %edx,%esi
  80058a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80058c:	5b                   	pop    %ebx
  80058d:	5e                   	pop    %esi
  80058e:	5f                   	pop    %edi
  80058f:	5d                   	pop    %ebp
  800590:	c3                   	ret    

00800591 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	57                   	push   %edi
  800595:	56                   	push   %esi
  800596:	53                   	push   %ebx
  800597:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80059a:	be 00 00 00 00       	mov    $0x0,%esi
  80059f:	b8 04 00 00 00       	mov    $0x4,%eax
  8005a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ad:	89 f7                	mov    %esi,%edi
  8005af:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8005b1:	85 c0                	test   %eax,%eax
  8005b3:	7e 28                	jle    8005dd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005b9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8005c0:	00 
  8005c1:	c7 44 24 08 4f 20 80 	movl   $0x80204f,0x8(%esp)
  8005c8:	00 
  8005c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005d0:	00 
  8005d1:	c7 04 24 6c 20 80 00 	movl   $0x80206c,(%esp)
  8005d8:	e8 2f 10 00 00       	call   80160c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005dd:	83 c4 2c             	add    $0x2c,%esp
  8005e0:	5b                   	pop    %ebx
  8005e1:	5e                   	pop    %esi
  8005e2:	5f                   	pop    %edi
  8005e3:	5d                   	pop    %ebp
  8005e4:	c3                   	ret    

008005e5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005e5:	55                   	push   %ebp
  8005e6:	89 e5                	mov    %esp,%ebp
  8005e8:	57                   	push   %edi
  8005e9:	56                   	push   %esi
  8005ea:	53                   	push   %ebx
  8005eb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8005f3:	8b 75 18             	mov    0x18(%ebp),%esi
  8005f6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800602:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800604:	85 c0                	test   %eax,%eax
  800606:	7e 28                	jle    800630 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800608:	89 44 24 10          	mov    %eax,0x10(%esp)
  80060c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800613:	00 
  800614:	c7 44 24 08 4f 20 80 	movl   $0x80204f,0x8(%esp)
  80061b:	00 
  80061c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800623:	00 
  800624:	c7 04 24 6c 20 80 00 	movl   $0x80206c,(%esp)
  80062b:	e8 dc 0f 00 00       	call   80160c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800630:	83 c4 2c             	add    $0x2c,%esp
  800633:	5b                   	pop    %ebx
  800634:	5e                   	pop    %esi
  800635:	5f                   	pop    %edi
  800636:	5d                   	pop    %ebp
  800637:	c3                   	ret    

00800638 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800638:	55                   	push   %ebp
  800639:	89 e5                	mov    %esp,%ebp
  80063b:	57                   	push   %edi
  80063c:	56                   	push   %esi
  80063d:	53                   	push   %ebx
  80063e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800641:	bb 00 00 00 00       	mov    $0x0,%ebx
  800646:	b8 06 00 00 00       	mov    $0x6,%eax
  80064b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80064e:	8b 55 08             	mov    0x8(%ebp),%edx
  800651:	89 df                	mov    %ebx,%edi
  800653:	89 de                	mov    %ebx,%esi
  800655:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800657:	85 c0                	test   %eax,%eax
  800659:	7e 28                	jle    800683 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80065b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80065f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800666:	00 
  800667:	c7 44 24 08 4f 20 80 	movl   $0x80204f,0x8(%esp)
  80066e:	00 
  80066f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800676:	00 
  800677:	c7 04 24 6c 20 80 00 	movl   $0x80206c,(%esp)
  80067e:	e8 89 0f 00 00       	call   80160c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800683:	83 c4 2c             	add    $0x2c,%esp
  800686:	5b                   	pop    %ebx
  800687:	5e                   	pop    %esi
  800688:	5f                   	pop    %edi
  800689:	5d                   	pop    %ebp
  80068a:	c3                   	ret    

0080068b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80068b:	55                   	push   %ebp
  80068c:	89 e5                	mov    %esp,%ebp
  80068e:	57                   	push   %edi
  80068f:	56                   	push   %esi
  800690:	53                   	push   %ebx
  800691:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800694:	bb 00 00 00 00       	mov    $0x0,%ebx
  800699:	b8 08 00 00 00       	mov    $0x8,%eax
  80069e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a4:	89 df                	mov    %ebx,%edi
  8006a6:	89 de                	mov    %ebx,%esi
  8006a8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006aa:	85 c0                	test   %eax,%eax
  8006ac:	7e 28                	jle    8006d6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006b2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8006b9:	00 
  8006ba:	c7 44 24 08 4f 20 80 	movl   $0x80204f,0x8(%esp)
  8006c1:	00 
  8006c2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006c9:	00 
  8006ca:	c7 04 24 6c 20 80 00 	movl   $0x80206c,(%esp)
  8006d1:	e8 36 0f 00 00       	call   80160c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8006d6:	83 c4 2c             	add    $0x2c,%esp
  8006d9:	5b                   	pop    %ebx
  8006da:	5e                   	pop    %esi
  8006db:	5f                   	pop    %edi
  8006dc:	5d                   	pop    %ebp
  8006dd:	c3                   	ret    

008006de <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	57                   	push   %edi
  8006e2:	56                   	push   %esi
  8006e3:	53                   	push   %ebx
  8006e4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ec:	b8 09 00 00 00       	mov    $0x9,%eax
  8006f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f7:	89 df                	mov    %ebx,%edi
  8006f9:	89 de                	mov    %ebx,%esi
  8006fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	7e 28                	jle    800729 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800701:	89 44 24 10          	mov    %eax,0x10(%esp)
  800705:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80070c:	00 
  80070d:	c7 44 24 08 4f 20 80 	movl   $0x80204f,0x8(%esp)
  800714:	00 
  800715:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80071c:	00 
  80071d:	c7 04 24 6c 20 80 00 	movl   $0x80206c,(%esp)
  800724:	e8 e3 0e 00 00       	call   80160c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800729:	83 c4 2c             	add    $0x2c,%esp
  80072c:	5b                   	pop    %ebx
  80072d:	5e                   	pop    %esi
  80072e:	5f                   	pop    %edi
  80072f:	5d                   	pop    %ebp
  800730:	c3                   	ret    

00800731 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	57                   	push   %edi
  800735:	56                   	push   %esi
  800736:	53                   	push   %ebx
  800737:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80073a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80073f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800744:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800747:	8b 55 08             	mov    0x8(%ebp),%edx
  80074a:	89 df                	mov    %ebx,%edi
  80074c:	89 de                	mov    %ebx,%esi
  80074e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800750:	85 c0                	test   %eax,%eax
  800752:	7e 28                	jle    80077c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800754:	89 44 24 10          	mov    %eax,0x10(%esp)
  800758:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80075f:	00 
  800760:	c7 44 24 08 4f 20 80 	movl   $0x80204f,0x8(%esp)
  800767:	00 
  800768:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80076f:	00 
  800770:	c7 04 24 6c 20 80 00 	movl   $0x80206c,(%esp)
  800777:	e8 90 0e 00 00       	call   80160c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80077c:	83 c4 2c             	add    $0x2c,%esp
  80077f:	5b                   	pop    %ebx
  800780:	5e                   	pop    %esi
  800781:	5f                   	pop    %edi
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	57                   	push   %edi
  800788:	56                   	push   %esi
  800789:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80078a:	be 00 00 00 00       	mov    $0x0,%esi
  80078f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800794:	8b 7d 14             	mov    0x14(%ebp),%edi
  800797:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80079a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079d:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8007a2:	5b                   	pop    %ebx
  8007a3:	5e                   	pop    %esi
  8007a4:	5f                   	pop    %edi
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	57                   	push   %edi
  8007ab:	56                   	push   %esi
  8007ac:	53                   	push   %ebx
  8007ad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8007ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8007bd:	89 cb                	mov    %ecx,%ebx
  8007bf:	89 cf                	mov    %ecx,%edi
  8007c1:	89 ce                	mov    %ecx,%esi
  8007c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8007c5:	85 c0                	test   %eax,%eax
  8007c7:	7e 28                	jle    8007f1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007c9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007cd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8007d4:	00 
  8007d5:	c7 44 24 08 4f 20 80 	movl   $0x80204f,0x8(%esp)
  8007dc:	00 
  8007dd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007e4:	00 
  8007e5:	c7 04 24 6c 20 80 00 	movl   $0x80206c,(%esp)
  8007ec:	e8 1b 0e 00 00       	call   80160c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8007f1:	83 c4 2c             	add    $0x2c,%esp
  8007f4:	5b                   	pop    %ebx
  8007f5:	5e                   	pop    %esi
  8007f6:	5f                   	pop    %edi
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    
  8007f9:	00 00                	add    %al,(%eax)
	...

008007fc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	05 00 00 00 30       	add    $0x30000000,%eax
  800807:	c1 e8 0c             	shr    $0xc,%eax
}
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800812:	8b 45 08             	mov    0x8(%ebp),%eax
  800815:	89 04 24             	mov    %eax,(%esp)
  800818:	e8 df ff ff ff       	call   8007fc <fd2num>
  80081d:	05 20 00 0d 00       	add    $0xd0020,%eax
  800822:	c1 e0 0c             	shl    $0xc,%eax
}
  800825:	c9                   	leave  
  800826:	c3                   	ret    

00800827 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80082e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800833:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800835:	89 c2                	mov    %eax,%edx
  800837:	c1 ea 16             	shr    $0x16,%edx
  80083a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800841:	f6 c2 01             	test   $0x1,%dl
  800844:	74 11                	je     800857 <fd_alloc+0x30>
  800846:	89 c2                	mov    %eax,%edx
  800848:	c1 ea 0c             	shr    $0xc,%edx
  80084b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800852:	f6 c2 01             	test   $0x1,%dl
  800855:	75 09                	jne    800860 <fd_alloc+0x39>
			*fd_store = fd;
  800857:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
  80085e:	eb 17                	jmp    800877 <fd_alloc+0x50>
  800860:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800865:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80086a:	75 c7                	jne    800833 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80086c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800872:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800877:	5b                   	pop    %ebx
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800880:	83 f8 1f             	cmp    $0x1f,%eax
  800883:	77 36                	ja     8008bb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800885:	05 00 00 0d 00       	add    $0xd0000,%eax
  80088a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80088d:	89 c2                	mov    %eax,%edx
  80088f:	c1 ea 16             	shr    $0x16,%edx
  800892:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800899:	f6 c2 01             	test   $0x1,%dl
  80089c:	74 24                	je     8008c2 <fd_lookup+0x48>
  80089e:	89 c2                	mov    %eax,%edx
  8008a0:	c1 ea 0c             	shr    $0xc,%edx
  8008a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8008aa:	f6 c2 01             	test   $0x1,%dl
  8008ad:	74 1a                	je     8008c9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b2:	89 02                	mov    %eax,(%edx)
	return 0;
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b9:	eb 13                	jmp    8008ce <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c0:	eb 0c                	jmp    8008ce <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c7:	eb 05                	jmp    8008ce <fd_lookup+0x54>
  8008c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	53                   	push   %ebx
  8008d4:	83 ec 14             	sub    $0x14,%esp
  8008d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8008dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e2:	eb 0e                	jmp    8008f2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8008e4:	39 08                	cmp    %ecx,(%eax)
  8008e6:	75 09                	jne    8008f1 <dev_lookup+0x21>
			*dev = devtab[i];
  8008e8:	89 03                	mov    %eax,(%ebx)
			return 0;
  8008ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ef:	eb 35                	jmp    800926 <dev_lookup+0x56>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008f1:	42                   	inc    %edx
  8008f2:	8b 04 95 f8 20 80 00 	mov    0x8020f8(,%edx,4),%eax
  8008f9:	85 c0                	test   %eax,%eax
  8008fb:	75 e7                	jne    8008e4 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8008fd:	a1 04 40 80 00       	mov    0x804004,%eax
  800902:	8b 00                	mov    (%eax),%eax
  800904:	8b 40 48             	mov    0x48(%eax),%eax
  800907:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80090b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090f:	c7 04 24 7c 20 80 00 	movl   $0x80207c,(%esp)
  800916:	e8 e9 0d 00 00       	call   801704 <cprintf>
	*dev = 0;
  80091b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800921:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800926:	83 c4 14             	add    $0x14,%esp
  800929:	5b                   	pop    %ebx
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	83 ec 30             	sub    $0x30,%esp
  800934:	8b 75 08             	mov    0x8(%ebp),%esi
  800937:	8a 45 0c             	mov    0xc(%ebp),%al
  80093a:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80093d:	89 34 24             	mov    %esi,(%esp)
  800940:	e8 b7 fe ff ff       	call   8007fc <fd2num>
  800945:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800948:	89 54 24 04          	mov    %edx,0x4(%esp)
  80094c:	89 04 24             	mov    %eax,(%esp)
  80094f:	e8 26 ff ff ff       	call   80087a <fd_lookup>
  800954:	89 c3                	mov    %eax,%ebx
  800956:	85 c0                	test   %eax,%eax
  800958:	78 05                	js     80095f <fd_close+0x33>
	    || fd != fd2)
  80095a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80095d:	74 0d                	je     80096c <fd_close+0x40>
		return (must_exist ? r : 0);
  80095f:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800963:	75 46                	jne    8009ab <fd_close+0x7f>
  800965:	bb 00 00 00 00       	mov    $0x0,%ebx
  80096a:	eb 3f                	jmp    8009ab <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80096c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80096f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800973:	8b 06                	mov    (%esi),%eax
  800975:	89 04 24             	mov    %eax,(%esp)
  800978:	e8 53 ff ff ff       	call   8008d0 <dev_lookup>
  80097d:	89 c3                	mov    %eax,%ebx
  80097f:	85 c0                	test   %eax,%eax
  800981:	78 18                	js     80099b <fd_close+0x6f>
		if (dev->dev_close)
  800983:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800986:	8b 40 10             	mov    0x10(%eax),%eax
  800989:	85 c0                	test   %eax,%eax
  80098b:	74 09                	je     800996 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80098d:	89 34 24             	mov    %esi,(%esp)
  800990:	ff d0                	call   *%eax
  800992:	89 c3                	mov    %eax,%ebx
  800994:	eb 05                	jmp    80099b <fd_close+0x6f>
		else
			r = 0;
  800996:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80099b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80099f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009a6:	e8 8d fc ff ff       	call   800638 <sys_page_unmap>
	return r;
}
  8009ab:	89 d8                	mov    %ebx,%eax
  8009ad:	83 c4 30             	add    $0x30,%esp
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	89 04 24             	mov    %eax,(%esp)
  8009c7:	e8 ae fe ff ff       	call   80087a <fd_lookup>
  8009cc:	85 c0                	test   %eax,%eax
  8009ce:	78 13                	js     8009e3 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8009d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8009d7:	00 
  8009d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009db:	89 04 24             	mov    %eax,(%esp)
  8009de:	e8 49 ff ff ff       	call   80092c <fd_close>
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <close_all>:

void
close_all(void)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	53                   	push   %ebx
  8009e9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8009ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8009f1:	89 1c 24             	mov    %ebx,(%esp)
  8009f4:	e8 bb ff ff ff       	call   8009b4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8009f9:	43                   	inc    %ebx
  8009fa:	83 fb 20             	cmp    $0x20,%ebx
  8009fd:	75 f2                	jne    8009f1 <close_all+0xc>
		close(i);
}
  8009ff:	83 c4 14             	add    $0x14,%esp
  800a02:	5b                   	pop    %ebx
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	57                   	push   %edi
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	83 ec 4c             	sub    $0x4c,%esp
  800a0e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800a11:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	89 04 24             	mov    %eax,(%esp)
  800a1e:	e8 57 fe ff ff       	call   80087a <fd_lookup>
  800a23:	89 c3                	mov    %eax,%ebx
  800a25:	85 c0                	test   %eax,%eax
  800a27:	0f 88 e1 00 00 00    	js     800b0e <dup+0x109>
		return r;
	close(newfdnum);
  800a2d:	89 3c 24             	mov    %edi,(%esp)
  800a30:	e8 7f ff ff ff       	call   8009b4 <close>

	newfd = INDEX2FD(newfdnum);
  800a35:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800a3b:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800a3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a41:	89 04 24             	mov    %eax,(%esp)
  800a44:	e8 c3 fd ff ff       	call   80080c <fd2data>
  800a49:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800a4b:	89 34 24             	mov    %esi,(%esp)
  800a4e:	e8 b9 fd ff ff       	call   80080c <fd2data>
  800a53:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a56:	89 d8                	mov    %ebx,%eax
  800a58:	c1 e8 16             	shr    $0x16,%eax
  800a5b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a62:	a8 01                	test   $0x1,%al
  800a64:	74 46                	je     800aac <dup+0xa7>
  800a66:	89 d8                	mov    %ebx,%eax
  800a68:	c1 e8 0c             	shr    $0xc,%eax
  800a6b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a72:	f6 c2 01             	test   $0x1,%dl
  800a75:	74 35                	je     800aac <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a77:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a7e:	25 07 0e 00 00       	and    $0xe07,%eax
  800a83:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a87:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800a8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a8e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a95:	00 
  800a96:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800aa1:	e8 3f fb ff ff       	call   8005e5 <sys_page_map>
  800aa6:	89 c3                	mov    %eax,%ebx
  800aa8:	85 c0                	test   %eax,%eax
  800aaa:	78 3b                	js     800ae7 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800aac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aaf:	89 c2                	mov    %eax,%edx
  800ab1:	c1 ea 0c             	shr    $0xc,%edx
  800ab4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800abb:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800ac1:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ac5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ac9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ad0:	00 
  800ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800adc:	e8 04 fb ff ff       	call   8005e5 <sys_page_map>
  800ae1:	89 c3                	mov    %eax,%ebx
  800ae3:	85 c0                	test   %eax,%eax
  800ae5:	79 25                	jns    800b0c <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800ae7:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aeb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800af2:	e8 41 fb ff ff       	call   800638 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800af7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800afa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b05:	e8 2e fb ff ff       	call   800638 <sys_page_unmap>
	return r;
  800b0a:	eb 02                	jmp    800b0e <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800b0c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800b0e:	89 d8                	mov    %ebx,%eax
  800b10:	83 c4 4c             	add    $0x4c,%esp
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5f                   	pop    %edi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	53                   	push   %ebx
  800b1c:	83 ec 24             	sub    $0x24,%esp
  800b1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b22:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b29:	89 1c 24             	mov    %ebx,(%esp)
  800b2c:	e8 49 fd ff ff       	call   80087a <fd_lookup>
  800b31:	85 c0                	test   %eax,%eax
  800b33:	78 6f                	js     800ba4 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b3f:	8b 00                	mov    (%eax),%eax
  800b41:	89 04 24             	mov    %eax,(%esp)
  800b44:	e8 87 fd ff ff       	call   8008d0 <dev_lookup>
  800b49:	85 c0                	test   %eax,%eax
  800b4b:	78 57                	js     800ba4 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b50:	8b 50 08             	mov    0x8(%eax),%edx
  800b53:	83 e2 03             	and    $0x3,%edx
  800b56:	83 fa 01             	cmp    $0x1,%edx
  800b59:	75 25                	jne    800b80 <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b5b:	a1 04 40 80 00       	mov    0x804004,%eax
  800b60:	8b 00                	mov    (%eax),%eax
  800b62:	8b 40 48             	mov    0x48(%eax),%eax
  800b65:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b69:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b6d:	c7 04 24 bd 20 80 00 	movl   $0x8020bd,(%esp)
  800b74:	e8 8b 0b 00 00       	call   801704 <cprintf>
		return -E_INVAL;
  800b79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b7e:	eb 24                	jmp    800ba4 <read+0x8c>
	}
	if (!dev->dev_read)
  800b80:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b83:	8b 52 08             	mov    0x8(%edx),%edx
  800b86:	85 d2                	test   %edx,%edx
  800b88:	74 15                	je     800b9f <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b98:	89 04 24             	mov    %eax,(%esp)
  800b9b:	ff d2                	call   *%edx
  800b9d:	eb 05                	jmp    800ba4 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800b9f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800ba4:	83 c4 24             	add    $0x24,%esp
  800ba7:	5b                   	pop    %ebx
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
  800bb0:	83 ec 1c             	sub    $0x1c,%esp
  800bb3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bb6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800bb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbe:	eb 23                	jmp    800be3 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800bc0:	89 f0                	mov    %esi,%eax
  800bc2:	29 d8                	sub    %ebx,%eax
  800bc4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcb:	01 d8                	add    %ebx,%eax
  800bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd1:	89 3c 24             	mov    %edi,(%esp)
  800bd4:	e8 3f ff ff ff       	call   800b18 <read>
		if (m < 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	78 10                	js     800bed <readn+0x43>
			return m;
		if (m == 0)
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	74 0a                	je     800beb <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800be1:	01 c3                	add    %eax,%ebx
  800be3:	39 f3                	cmp    %esi,%ebx
  800be5:	72 d9                	jb     800bc0 <readn+0x16>
  800be7:	89 d8                	mov    %ebx,%eax
  800be9:	eb 02                	jmp    800bed <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800beb:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800bed:	83 c4 1c             	add    $0x1c,%esp
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 24             	sub    $0x24,%esp
  800bfc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c06:	89 1c 24             	mov    %ebx,(%esp)
  800c09:	e8 6c fc ff ff       	call   80087a <fd_lookup>
  800c0e:	85 c0                	test   %eax,%eax
  800c10:	78 6a                	js     800c7c <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c1c:	8b 00                	mov    (%eax),%eax
  800c1e:	89 04 24             	mov    %eax,(%esp)
  800c21:	e8 aa fc ff ff       	call   8008d0 <dev_lookup>
  800c26:	85 c0                	test   %eax,%eax
  800c28:	78 52                	js     800c7c <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c2d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c31:	75 25                	jne    800c58 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800c33:	a1 04 40 80 00       	mov    0x804004,%eax
  800c38:	8b 00                	mov    (%eax),%eax
  800c3a:	8b 40 48             	mov    0x48(%eax),%eax
  800c3d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c41:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c45:	c7 04 24 d9 20 80 00 	movl   $0x8020d9,(%esp)
  800c4c:	e8 b3 0a 00 00       	call   801704 <cprintf>
		return -E_INVAL;
  800c51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c56:	eb 24                	jmp    800c7c <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800c58:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c5b:	8b 52 0c             	mov    0xc(%edx),%edx
  800c5e:	85 d2                	test   %edx,%edx
  800c60:	74 15                	je     800c77 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800c62:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c65:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c70:	89 04 24             	mov    %eax,(%esp)
  800c73:	ff d2                	call   *%edx
  800c75:	eb 05                	jmp    800c7c <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800c77:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800c7c:	83 c4 24             	add    $0x24,%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <seek>:

int
seek(int fdnum, off_t offset)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c88:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c92:	89 04 24             	mov    %eax,(%esp)
  800c95:	e8 e0 fb ff ff       	call   80087a <fd_lookup>
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	78 0e                	js     800cac <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800c9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ca1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cac:	c9                   	leave  
  800cad:	c3                   	ret    

00800cae <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 24             	sub    $0x24,%esp
  800cb5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cb8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cbb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cbf:	89 1c 24             	mov    %ebx,(%esp)
  800cc2:	e8 b3 fb ff ff       	call   80087a <fd_lookup>
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	78 63                	js     800d2e <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ccb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cce:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cd5:	8b 00                	mov    (%eax),%eax
  800cd7:	89 04 24             	mov    %eax,(%esp)
  800cda:	e8 f1 fb ff ff       	call   8008d0 <dev_lookup>
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	78 4b                	js     800d2e <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ce3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ce6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cea:	75 25                	jne    800d11 <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800cec:	a1 04 40 80 00       	mov    0x804004,%eax
  800cf1:	8b 00                	mov    (%eax),%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800cf3:	8b 40 48             	mov    0x48(%eax),%eax
  800cf6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800cfa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cfe:	c7 04 24 9c 20 80 00 	movl   $0x80209c,(%esp)
  800d05:	e8 fa 09 00 00       	call   801704 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800d0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d0f:	eb 1d                	jmp    800d2e <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  800d11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d14:	8b 52 18             	mov    0x18(%edx),%edx
  800d17:	85 d2                	test   %edx,%edx
  800d19:	74 0e                	je     800d29 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d22:	89 04 24             	mov    %eax,(%esp)
  800d25:	ff d2                	call   *%edx
  800d27:	eb 05                	jmp    800d2e <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800d29:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800d2e:	83 c4 24             	add    $0x24,%esp
  800d31:	5b                   	pop    %ebx
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	53                   	push   %ebx
  800d38:	83 ec 24             	sub    $0x24,%esp
  800d3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d3e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d41:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d45:	8b 45 08             	mov    0x8(%ebp),%eax
  800d48:	89 04 24             	mov    %eax,(%esp)
  800d4b:	e8 2a fb ff ff       	call   80087a <fd_lookup>
  800d50:	85 c0                	test   %eax,%eax
  800d52:	78 52                	js     800da6 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d5e:	8b 00                	mov    (%eax),%eax
  800d60:	89 04 24             	mov    %eax,(%esp)
  800d63:	e8 68 fb ff ff       	call   8008d0 <dev_lookup>
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	78 3a                	js     800da6 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d6f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800d73:	74 2c                	je     800da1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800d75:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800d78:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800d7f:	00 00 00 
	stat->st_isdir = 0;
  800d82:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800d89:	00 00 00 
	stat->st_dev = dev;
  800d8c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d96:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d99:	89 14 24             	mov    %edx,(%esp)
  800d9c:	ff 50 14             	call   *0x14(%eax)
  800d9f:	eb 05                	jmp    800da6 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800da1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800da6:	83 c4 24             	add    $0x24,%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800db4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dbb:	00 
  800dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbf:	89 04 24             	mov    %eax,(%esp)
  800dc2:	e8 88 02 00 00       	call   80104f <open>
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	78 1b                	js     800de8 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dd4:	89 1c 24             	mov    %ebx,(%esp)
  800dd7:	e8 58 ff ff ff       	call   800d34 <fstat>
  800ddc:	89 c6                	mov    %eax,%esi
	close(fd);
  800dde:	89 1c 24             	mov    %ebx,(%esp)
  800de1:	e8 ce fb ff ff       	call   8009b4 <close>
	return r;
  800de6:	89 f3                	mov    %esi,%ebx
}
  800de8:	89 d8                	mov    %ebx,%eax
  800dea:	83 c4 10             	add    $0x10,%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    
  800df1:	00 00                	add    %al,(%eax)
	...

00800df4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	83 ec 10             	sub    $0x10,%esp
  800dfc:	89 c3                	mov    %eax,%ebx
  800dfe:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800e00:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800e07:	75 11                	jne    800e1a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800e09:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800e10:	e8 3a 0f 00 00       	call   801d4f <ipc_find_env>
  800e15:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	// cprintf("%x\n",dstva);
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800e1a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800e21:	00 
  800e22:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800e29:	00 
  800e2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e2e:	a1 00 40 80 00       	mov    0x804000,%eax
  800e33:	89 04 24             	mov    %eax,(%esp)
  800e36:	e8 ae 0e 00 00       	call   801ce9 <ipc_send>
	// cprintf("fsipc dstva:%x\n",dstva);
	int temp = ipc_recv(NULL, dstva, NULL);
  800e3b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e42:	00 
  800e43:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e4e:	e8 29 0e 00 00       	call   801c7c <ipc_recv>
	// cprintf("temp: %x\n",temp);
	return temp;
}
  800e53:	83 c4 10             	add    $0x10,%esp
  800e56:	5b                   	pop    %ebx
  800e57:	5e                   	pop    %esi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800e60:	8b 45 08             	mov    0x8(%ebp),%eax
  800e63:	8b 40 0c             	mov    0xc(%eax),%eax
  800e66:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800e73:	ba 00 00 00 00       	mov    $0x0,%edx
  800e78:	b8 02 00 00 00       	mov    $0x2,%eax
  800e7d:	e8 72 ff ff ff       	call   800df4 <fsipc>
}
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8d:	8b 40 0c             	mov    0xc(%eax),%eax
  800e90:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800e95:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9a:	b8 06 00 00 00       	mov    $0x6,%eax
  800e9f:	e8 50 ff ff ff       	call   800df4 <fsipc>
}
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    

00800ea6 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	53                   	push   %ebx
  800eaa:	83 ec 14             	sub    $0x14,%esp
  800ead:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb3:	8b 40 0c             	mov    0xc(%eax),%eax
  800eb6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800ebb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ec5:	e8 2a ff ff ff       	call   800df4 <fsipc>
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	78 2b                	js     800ef9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ece:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ed5:	00 
  800ed6:	89 1c 24             	mov    %ebx,(%esp)
  800ed9:	e8 c1 f2 ff ff       	call   80019f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ede:	a1 80 50 80 00       	mov    0x805080,%eax
  800ee3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ee9:	a1 84 50 80 00       	mov    0x805084,%eax
  800eee:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ef4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ef9:	83 c4 14             	add    $0x14,%esp
  800efc:	5b                   	pop    %ebx
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	53                   	push   %ebx
  800f03:	83 ec 14             	sub    $0x14,%esp
  800f06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f09:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0c:	8b 40 0c             	mov    0xc(%eax),%eax
  800f0f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.write.req_n = (n>sizeof(fsipcbuf.write.req_buf))?sizeof(fsipcbuf.write.req_buf):n;
  800f14:	89 d8                	mov    %ebx,%eax
  800f16:	81 fb f8 0f 00 00    	cmp    $0xff8,%ebx
  800f1c:	76 05                	jbe    800f23 <devfile_write+0x24>
  800f1e:	b8 f8 0f 00 00       	mov    $0xff8,%eax
  800f23:	a3 04 50 80 00       	mov    %eax,0x805004
	memcpy(fsipcbuf.write.req_buf,buf,fsipcbuf.write.req_n);
  800f28:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f33:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800f3a:	e8 43 f4 ff ff       	call   800382 <memcpy>
	// cprintf("write\n");
	if ((r = fsipc(FSREQ_WRITE,NULL)) < 0)
  800f3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f44:	b8 04 00 00 00       	mov    $0x4,%eax
  800f49:	e8 a6 fe ff ff       	call   800df4 <fsipc>
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	78 53                	js     800fa5 <devfile_write+0xa6>
		return r; 
	// cprintf("r:%x\n",r);
	assert(r <= n);
  800f52:	39 c3                	cmp    %eax,%ebx
  800f54:	73 24                	jae    800f7a <devfile_write+0x7b>
  800f56:	c7 44 24 0c 08 21 80 	movl   $0x802108,0xc(%esp)
  800f5d:	00 
  800f5e:	c7 44 24 08 0f 21 80 	movl   $0x80210f,0x8(%esp)
  800f65:	00 
  800f66:	c7 44 24 04 9b 00 00 	movl   $0x9b,0x4(%esp)
  800f6d:	00 
  800f6e:	c7 04 24 24 21 80 00 	movl   $0x802124,(%esp)
  800f75:	e8 92 06 00 00       	call   80160c <_panic>
	assert(r <= PGSIZE);
  800f7a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800f7f:	7e 24                	jle    800fa5 <devfile_write+0xa6>
  800f81:	c7 44 24 0c 2f 21 80 	movl   $0x80212f,0xc(%esp)
  800f88:	00 
  800f89:	c7 44 24 08 0f 21 80 	movl   $0x80210f,0x8(%esp)
  800f90:	00 
  800f91:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  800f98:	00 
  800f99:	c7 04 24 24 21 80 00 	movl   $0x802124,(%esp)
  800fa0:	e8 67 06 00 00       	call   80160c <_panic>
	// cprintf("r:%x\n",r);
	return r;
	panic("devfile_write not implemented");
}
  800fa5:	83 c4 14             	add    $0x14,%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    

00800fab <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	56                   	push   %esi
  800faf:	53                   	push   %ebx
  800fb0:	83 ec 10             	sub    $0x10,%esp
  800fb3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb9:	8b 40 0c             	mov    0xc(%eax),%eax
  800fbc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800fc1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800fc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fcc:	b8 03 00 00 00       	mov    $0x3,%eax
  800fd1:	e8 1e fe ff ff       	call   800df4 <fsipc>
  800fd6:	89 c3                	mov    %eax,%ebx
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	78 6a                	js     801046 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800fdc:	39 c6                	cmp    %eax,%esi
  800fde:	73 24                	jae    801004 <devfile_read+0x59>
  800fe0:	c7 44 24 0c 08 21 80 	movl   $0x802108,0xc(%esp)
  800fe7:	00 
  800fe8:	c7 44 24 08 0f 21 80 	movl   $0x80210f,0x8(%esp)
  800fef:	00 
  800ff0:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
  800ff7:	00 
  800ff8:	c7 04 24 24 21 80 00 	movl   $0x802124,(%esp)
  800fff:	e8 08 06 00 00       	call   80160c <_panic>
	assert(r <= PGSIZE);
  801004:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801009:	7e 24                	jle    80102f <devfile_read+0x84>
  80100b:	c7 44 24 0c 2f 21 80 	movl   $0x80212f,0xc(%esp)
  801012:	00 
  801013:	c7 44 24 08 0f 21 80 	movl   $0x80210f,0x8(%esp)
  80101a:	00 
  80101b:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801022:	00 
  801023:	c7 04 24 24 21 80 00 	movl   $0x802124,(%esp)
  80102a:	e8 dd 05 00 00       	call   80160c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80102f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801033:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80103a:	00 
  80103b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103e:	89 04 24             	mov    %eax,(%esp)
  801041:	e8 d2 f2 ff ff       	call   800318 <memmove>
	return r;
}
  801046:	89 d8                	mov    %ebx,%eax
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    

0080104f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 20             	sub    $0x20,%esp
  801057:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80105a:	89 34 24             	mov    %esi,(%esp)
  80105d:	e8 0a f1 ff ff       	call   80016c <strlen>
  801062:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801067:	7f 60                	jg     8010c9 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801069:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106c:	89 04 24             	mov    %eax,(%esp)
  80106f:	e8 b3 f7 ff ff       	call   800827 <fd_alloc>
  801074:	89 c3                	mov    %eax,%ebx
  801076:	85 c0                	test   %eax,%eax
  801078:	78 54                	js     8010ce <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80107a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80107e:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801085:	e8 15 f1 ff ff       	call   80019f <strcpy>
	fsipcbuf.open.req_omode = mode;
  80108a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801092:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801095:	b8 01 00 00 00       	mov    $0x1,%eax
  80109a:	e8 55 fd ff ff       	call   800df4 <fsipc>
  80109f:	89 c3                	mov    %eax,%ebx
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	79 15                	jns    8010ba <open+0x6b>
		fd_close(fd, 0);
  8010a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010ac:	00 
  8010ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b0:	89 04 24             	mov    %eax,(%esp)
  8010b3:	e8 74 f8 ff ff       	call   80092c <fd_close>
		return r;
  8010b8:	eb 14                	jmp    8010ce <open+0x7f>
	}

	return fd2num(fd);
  8010ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010bd:	89 04 24             	mov    %eax,(%esp)
  8010c0:	e8 37 f7 ff ff       	call   8007fc <fd2num>
  8010c5:	89 c3                	mov    %eax,%ebx
  8010c7:	eb 05                	jmp    8010ce <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010c9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010ce:	89 d8                	mov    %ebx,%eax
  8010d0:	83 c4 20             	add    $0x20,%esp
  8010d3:	5b                   	pop    %ebx
  8010d4:	5e                   	pop    %esi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e2:	b8 08 00 00 00       	mov    $0x8,%eax
  8010e7:	e8 08 fd ff ff       	call   800df4 <fsipc>
}
  8010ec:	c9                   	leave  
  8010ed:	c3                   	ret    
	...

008010f0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	56                   	push   %esi
  8010f4:	53                   	push   %ebx
  8010f5:	83 ec 10             	sub    $0x10,%esp
  8010f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fe:	89 04 24             	mov    %eax,(%esp)
  801101:	e8 06 f7 ff ff       	call   80080c <fd2data>
  801106:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801108:	c7 44 24 04 3b 21 80 	movl   $0x80213b,0x4(%esp)
  80110f:	00 
  801110:	89 34 24             	mov    %esi,(%esp)
  801113:	e8 87 f0 ff ff       	call   80019f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801118:	8b 43 04             	mov    0x4(%ebx),%eax
  80111b:	2b 03                	sub    (%ebx),%eax
  80111d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801123:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80112a:	00 00 00 
	stat->st_dev = &devpipe;
  80112d:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801134:	30 80 00 
	return 0;
}
  801137:	b8 00 00 00 00       	mov    $0x0,%eax
  80113c:	83 c4 10             	add    $0x10,%esp
  80113f:	5b                   	pop    %ebx
  801140:	5e                   	pop    %esi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	53                   	push   %ebx
  801147:	83 ec 14             	sub    $0x14,%esp
  80114a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80114d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801151:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801158:	e8 db f4 ff ff       	call   800638 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80115d:	89 1c 24             	mov    %ebx,(%esp)
  801160:	e8 a7 f6 ff ff       	call   80080c <fd2data>
  801165:	89 44 24 04          	mov    %eax,0x4(%esp)
  801169:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801170:	e8 c3 f4 ff ff       	call   800638 <sys_page_unmap>
}
  801175:	83 c4 14             	add    $0x14,%esp
  801178:	5b                   	pop    %ebx
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    

0080117b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	57                   	push   %edi
  80117f:	56                   	push   %esi
  801180:	53                   	push   %ebx
  801181:	83 ec 2c             	sub    $0x2c,%esp
  801184:	89 c7                	mov    %eax,%edi
  801186:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801189:	a1 04 40 80 00       	mov    0x804004,%eax
  80118e:	8b 00                	mov    (%eax),%eax
  801190:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801193:	89 3c 24             	mov    %edi,(%esp)
  801196:	e8 f9 0b 00 00       	call   801d94 <pageref>
  80119b:	89 c6                	mov    %eax,%esi
  80119d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011a0:	89 04 24             	mov    %eax,(%esp)
  8011a3:	e8 ec 0b 00 00       	call   801d94 <pageref>
  8011a8:	39 c6                	cmp    %eax,%esi
  8011aa:	0f 94 c0             	sete   %al
  8011ad:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8011b0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8011b6:	8b 12                	mov    (%edx),%edx
  8011b8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8011bb:	39 cb                	cmp    %ecx,%ebx
  8011bd:	75 08                	jne    8011c7 <_pipeisclosed+0x4c>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8011bf:	83 c4 2c             	add    $0x2c,%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8011c7:	83 f8 01             	cmp    $0x1,%eax
  8011ca:	75 bd                	jne    801189 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011cc:	8b 42 58             	mov    0x58(%edx),%eax
  8011cf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8011d6:	00 
  8011d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011df:	c7 04 24 42 21 80 00 	movl   $0x802142,(%esp)
  8011e6:	e8 19 05 00 00       	call   801704 <cprintf>
  8011eb:	eb 9c                	jmp    801189 <_pipeisclosed+0xe>

008011ed <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	57                   	push   %edi
  8011f1:	56                   	push   %esi
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 1c             	sub    $0x1c,%esp
  8011f6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011f9:	89 34 24             	mov    %esi,(%esp)
  8011fc:	e8 0b f6 ff ff       	call   80080c <fd2data>
  801201:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801203:	bf 00 00 00 00       	mov    $0x0,%edi
  801208:	eb 3c                	jmp    801246 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80120a:	89 da                	mov    %ebx,%edx
  80120c:	89 f0                	mov    %esi,%eax
  80120e:	e8 68 ff ff ff       	call   80117b <_pipeisclosed>
  801213:	85 c0                	test   %eax,%eax
  801215:	75 38                	jne    80124f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801217:	e8 56 f3 ff ff       	call   800572 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80121c:	8b 43 04             	mov    0x4(%ebx),%eax
  80121f:	8b 13                	mov    (%ebx),%edx
  801221:	83 c2 20             	add    $0x20,%edx
  801224:	39 d0                	cmp    %edx,%eax
  801226:	73 e2                	jae    80120a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801228:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80122e:	89 c2                	mov    %eax,%edx
  801230:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801236:	79 05                	jns    80123d <devpipe_write+0x50>
  801238:	4a                   	dec    %edx
  801239:	83 ca e0             	or     $0xffffffe0,%edx
  80123c:	42                   	inc    %edx
  80123d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801241:	40                   	inc    %eax
  801242:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801245:	47                   	inc    %edi
  801246:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801249:	75 d1                	jne    80121c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80124b:	89 f8                	mov    %edi,%eax
  80124d:	eb 05                	jmp    801254 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80124f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801254:	83 c4 1c             	add    $0x1c,%esp
  801257:	5b                   	pop    %ebx
  801258:	5e                   	pop    %esi
  801259:	5f                   	pop    %edi
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	57                   	push   %edi
  801260:	56                   	push   %esi
  801261:	53                   	push   %ebx
  801262:	83 ec 1c             	sub    $0x1c,%esp
  801265:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801268:	89 3c 24             	mov    %edi,(%esp)
  80126b:	e8 9c f5 ff ff       	call   80080c <fd2data>
  801270:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801272:	be 00 00 00 00       	mov    $0x0,%esi
  801277:	eb 3a                	jmp    8012b3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801279:	85 f6                	test   %esi,%esi
  80127b:	74 04                	je     801281 <devpipe_read+0x25>
				return i;
  80127d:	89 f0                	mov    %esi,%eax
  80127f:	eb 40                	jmp    8012c1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801281:	89 da                	mov    %ebx,%edx
  801283:	89 f8                	mov    %edi,%eax
  801285:	e8 f1 fe ff ff       	call   80117b <_pipeisclosed>
  80128a:	85 c0                	test   %eax,%eax
  80128c:	75 2e                	jne    8012bc <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80128e:	e8 df f2 ff ff       	call   800572 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801293:	8b 03                	mov    (%ebx),%eax
  801295:	3b 43 04             	cmp    0x4(%ebx),%eax
  801298:	74 df                	je     801279 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80129a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80129f:	79 05                	jns    8012a6 <devpipe_read+0x4a>
  8012a1:	48                   	dec    %eax
  8012a2:	83 c8 e0             	or     $0xffffffe0,%eax
  8012a5:	40                   	inc    %eax
  8012a6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8012aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ad:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8012b0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012b2:	46                   	inc    %esi
  8012b3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8012b6:	75 db                	jne    801293 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012b8:	89 f0                	mov    %esi,%eax
  8012ba:	eb 05                	jmp    8012c1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012bc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012c1:	83 c4 1c             	add    $0x1c,%esp
  8012c4:	5b                   	pop    %ebx
  8012c5:	5e                   	pop    %esi
  8012c6:	5f                   	pop    %edi
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	57                   	push   %edi
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 3c             	sub    $0x3c,%esp
  8012d2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012d8:	89 04 24             	mov    %eax,(%esp)
  8012db:	e8 47 f5 ff ff       	call   800827 <fd_alloc>
  8012e0:	89 c3                	mov    %eax,%ebx
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	0f 88 45 01 00 00    	js     80142f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ea:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8012f1:	00 
  8012f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801300:	e8 8c f2 ff ff       	call   800591 <sys_page_alloc>
  801305:	89 c3                	mov    %eax,%ebx
  801307:	85 c0                	test   %eax,%eax
  801309:	0f 88 20 01 00 00    	js     80142f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80130f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801312:	89 04 24             	mov    %eax,(%esp)
  801315:	e8 0d f5 ff ff       	call   800827 <fd_alloc>
  80131a:	89 c3                	mov    %eax,%ebx
  80131c:	85 c0                	test   %eax,%eax
  80131e:	0f 88 f8 00 00 00    	js     80141c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801324:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80132b:	00 
  80132c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80132f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801333:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80133a:	e8 52 f2 ff ff       	call   800591 <sys_page_alloc>
  80133f:	89 c3                	mov    %eax,%ebx
  801341:	85 c0                	test   %eax,%eax
  801343:	0f 88 d3 00 00 00    	js     80141c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801349:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80134c:	89 04 24             	mov    %eax,(%esp)
  80134f:	e8 b8 f4 ff ff       	call   80080c <fd2data>
  801354:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801356:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80135d:	00 
  80135e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801362:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801369:	e8 23 f2 ff ff       	call   800591 <sys_page_alloc>
  80136e:	89 c3                	mov    %eax,%ebx
  801370:	85 c0                	test   %eax,%eax
  801372:	0f 88 91 00 00 00    	js     801409 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801378:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80137b:	89 04 24             	mov    %eax,(%esp)
  80137e:	e8 89 f4 ff ff       	call   80080c <fd2data>
  801383:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80138a:	00 
  80138b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80138f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801396:	00 
  801397:	89 74 24 04          	mov    %esi,0x4(%esp)
  80139b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013a2:	e8 3e f2 ff ff       	call   8005e5 <sys_page_map>
  8013a7:	89 c3                	mov    %eax,%ebx
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 4c                	js     8013f9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8013ad:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8013b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013b6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8013b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013bb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8013c2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8013c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013cb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8013cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013d0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013da:	89 04 24             	mov    %eax,(%esp)
  8013dd:	e8 1a f4 ff ff       	call   8007fc <fd2num>
  8013e2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8013e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013e7:	89 04 24             	mov    %eax,(%esp)
  8013ea:	e8 0d f4 ff ff       	call   8007fc <fd2num>
  8013ef:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8013f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f7:	eb 36                	jmp    80142f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8013f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801404:	e8 2f f2 ff ff       	call   800638 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801409:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80140c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801410:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801417:	e8 1c f2 ff ff       	call   800638 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80141c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80141f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801423:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80142a:	e8 09 f2 ff ff       	call   800638 <sys_page_unmap>
    err:
	return r;
}
  80142f:	89 d8                	mov    %ebx,%eax
  801431:	83 c4 3c             	add    $0x3c,%esp
  801434:	5b                   	pop    %ebx
  801435:	5e                   	pop    %esi
  801436:	5f                   	pop    %edi
  801437:	5d                   	pop    %ebp
  801438:	c3                   	ret    

00801439 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80143f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801442:	89 44 24 04          	mov    %eax,0x4(%esp)
  801446:	8b 45 08             	mov    0x8(%ebp),%eax
  801449:	89 04 24             	mov    %eax,(%esp)
  80144c:	e8 29 f4 ff ff       	call   80087a <fd_lookup>
  801451:	85 c0                	test   %eax,%eax
  801453:	78 15                	js     80146a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801455:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801458:	89 04 24             	mov    %eax,(%esp)
  80145b:	e8 ac f3 ff ff       	call   80080c <fd2data>
	return _pipeisclosed(fd, p);
  801460:	89 c2                	mov    %eax,%edx
  801462:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801465:	e8 11 fd ff ff       	call   80117b <_pipeisclosed>
}
  80146a:	c9                   	leave  
  80146b:	c3                   	ret    

0080146c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80146f:	b8 00 00 00 00       	mov    $0x0,%eax
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    

00801476 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80147c:	c7 44 24 04 5a 21 80 	movl   $0x80215a,0x4(%esp)
  801483:	00 
  801484:	8b 45 0c             	mov    0xc(%ebp),%eax
  801487:	89 04 24             	mov    %eax,(%esp)
  80148a:	e8 10 ed ff ff       	call   80019f <strcpy>
	return 0;
}
  80148f:	b8 00 00 00 00       	mov    $0x0,%eax
  801494:	c9                   	leave  
  801495:	c3                   	ret    

00801496 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	57                   	push   %edi
  80149a:	56                   	push   %esi
  80149b:	53                   	push   %ebx
  80149c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8014a7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014ad:	eb 30                	jmp    8014df <devcons_write+0x49>
		m = n - tot;
  8014af:	8b 75 10             	mov    0x10(%ebp),%esi
  8014b2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8014b4:	83 fe 7f             	cmp    $0x7f,%esi
  8014b7:	76 05                	jbe    8014be <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8014b9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8014be:	89 74 24 08          	mov    %esi,0x8(%esp)
  8014c2:	03 45 0c             	add    0xc(%ebp),%eax
  8014c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c9:	89 3c 24             	mov    %edi,(%esp)
  8014cc:	e8 47 ee ff ff       	call   800318 <memmove>
		sys_cputs(buf, m);
  8014d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014d5:	89 3c 24             	mov    %edi,(%esp)
  8014d8:	e8 e7 ef ff ff       	call   8004c4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014dd:	01 f3                	add    %esi,%ebx
  8014df:	89 d8                	mov    %ebx,%eax
  8014e1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8014e4:	72 c9                	jb     8014af <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014e6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8014ec:	5b                   	pop    %ebx
  8014ed:	5e                   	pop    %esi
  8014ee:	5f                   	pop    %edi
  8014ef:	5d                   	pop    %ebp
  8014f0:	c3                   	ret    

008014f1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014f1:	55                   	push   %ebp
  8014f2:	89 e5                	mov    %esp,%ebp
  8014f4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8014f7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014fb:	75 07                	jne    801504 <devcons_read+0x13>
  8014fd:	eb 25                	jmp    801524 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014ff:	e8 6e f0 ff ff       	call   800572 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801504:	e8 d9 ef ff ff       	call   8004e2 <sys_cgetc>
  801509:	85 c0                	test   %eax,%eax
  80150b:	74 f2                	je     8014ff <devcons_read+0xe>
  80150d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 1d                	js     801530 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801513:	83 f8 04             	cmp    $0x4,%eax
  801516:	74 13                	je     80152b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801518:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151b:	88 10                	mov    %dl,(%eax)
	return 1;
  80151d:	b8 01 00 00 00       	mov    $0x1,%eax
  801522:	eb 0c                	jmp    801530 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801524:	b8 00 00 00 00       	mov    $0x0,%eax
  801529:	eb 05                	jmp    801530 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80152b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801530:	c9                   	leave  
  801531:	c3                   	ret    

00801532 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801532:	55                   	push   %ebp
  801533:	89 e5                	mov    %esp,%ebp
  801535:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801538:	8b 45 08             	mov    0x8(%ebp),%eax
  80153b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80153e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801545:	00 
  801546:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801549:	89 04 24             	mov    %eax,(%esp)
  80154c:	e8 73 ef ff ff       	call   8004c4 <sys_cputs>
}
  801551:	c9                   	leave  
  801552:	c3                   	ret    

00801553 <getchar>:

int
getchar(void)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801559:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801560:	00 
  801561:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801564:	89 44 24 04          	mov    %eax,0x4(%esp)
  801568:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80156f:	e8 a4 f5 ff ff       	call   800b18 <read>
	if (r < 0)
  801574:	85 c0                	test   %eax,%eax
  801576:	78 0f                	js     801587 <getchar+0x34>
		return r;
	if (r < 1)
  801578:	85 c0                	test   %eax,%eax
  80157a:	7e 06                	jle    801582 <getchar+0x2f>
		return -E_EOF;
	return c;
  80157c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801580:	eb 05                	jmp    801587 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801582:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801587:	c9                   	leave  
  801588:	c3                   	ret    

00801589 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80158f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801592:	89 44 24 04          	mov    %eax,0x4(%esp)
  801596:	8b 45 08             	mov    0x8(%ebp),%eax
  801599:	89 04 24             	mov    %eax,(%esp)
  80159c:	e8 d9 f2 ff ff       	call   80087a <fd_lookup>
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 11                	js     8015b6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8015a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015ae:	39 10                	cmp    %edx,(%eax)
  8015b0:	0f 94 c0             	sete   %al
  8015b3:	0f b6 c0             	movzbl %al,%eax
}
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <opencons>:

int
opencons(void)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8015be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c1:	89 04 24             	mov    %eax,(%esp)
  8015c4:	e8 5e f2 ff ff       	call   800827 <fd_alloc>
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 3c                	js     801609 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015cd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8015d4:	00 
  8015d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e3:	e8 a9 ef ff ff       	call   800591 <sys_page_alloc>
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 1d                	js     801609 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8015ec:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801601:	89 04 24             	mov    %eax,(%esp)
  801604:	e8 f3 f1 ff ff       	call   8007fc <fd2num>
}
  801609:	c9                   	leave  
  80160a:	c3                   	ret    
	...

0080160c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	56                   	push   %esi
  801610:	53                   	push   %ebx
  801611:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801614:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801617:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80161d:	e8 31 ef ff ff       	call   800553 <sys_getenvid>
  801622:	8b 55 0c             	mov    0xc(%ebp),%edx
  801625:	89 54 24 10          	mov    %edx,0x10(%esp)
  801629:	8b 55 08             	mov    0x8(%ebp),%edx
  80162c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801630:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801634:	89 44 24 04          	mov    %eax,0x4(%esp)
  801638:	c7 04 24 68 21 80 00 	movl   $0x802168,(%esp)
  80163f:	e8 c0 00 00 00       	call   801704 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801644:	89 74 24 04          	mov    %esi,0x4(%esp)
  801648:	8b 45 10             	mov    0x10(%ebp),%eax
  80164b:	89 04 24             	mov    %eax,(%esp)
  80164e:	e8 50 00 00 00       	call   8016a3 <vcprintf>
	cprintf("\n");
  801653:	c7 04 24 90 24 80 00 	movl   $0x802490,(%esp)
  80165a:	e8 a5 00 00 00       	call   801704 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80165f:	cc                   	int3   
  801660:	eb fd                	jmp    80165f <_panic+0x53>
	...

00801664 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	53                   	push   %ebx
  801668:	83 ec 14             	sub    $0x14,%esp
  80166b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80166e:	8b 03                	mov    (%ebx),%eax
  801670:	8b 55 08             	mov    0x8(%ebp),%edx
  801673:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801677:	40                   	inc    %eax
  801678:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80167a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80167f:	75 19                	jne    80169a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801681:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801688:	00 
  801689:	8d 43 08             	lea    0x8(%ebx),%eax
  80168c:	89 04 24             	mov    %eax,(%esp)
  80168f:	e8 30 ee ff ff       	call   8004c4 <sys_cputs>
		b->idx = 0;
  801694:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80169a:	ff 43 04             	incl   0x4(%ebx)
}
  80169d:	83 c4 14             	add    $0x14,%esp
  8016a0:	5b                   	pop    %ebx
  8016a1:	5d                   	pop    %ebp
  8016a2:	c3                   	ret    

008016a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8016ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016b3:	00 00 00 
	b.cnt = 0;
  8016b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8016bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8016c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8016d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d8:	c7 04 24 64 16 80 00 	movl   $0x801664,(%esp)
  8016df:	e8 82 01 00 00       	call   801866 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8016e4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8016ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ee:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8016f4:	89 04 24             	mov    %eax,(%esp)
  8016f7:	e8 c8 ed ff ff       	call   8004c4 <sys_cputs>

	return b.cnt;
}
  8016fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801702:	c9                   	leave  
  801703:	c3                   	ret    

00801704 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80170a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80170d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801711:	8b 45 08             	mov    0x8(%ebp),%eax
  801714:	89 04 24             	mov    %eax,(%esp)
  801717:	e8 87 ff ff ff       	call   8016a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80171c:	c9                   	leave  
  80171d:	c3                   	ret    
	...

00801720 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	57                   	push   %edi
  801724:	56                   	push   %esi
  801725:	53                   	push   %ebx
  801726:	83 ec 3c             	sub    $0x3c,%esp
  801729:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80172c:	89 d7                	mov    %edx,%edi
  80172e:	8b 45 08             	mov    0x8(%ebp),%eax
  801731:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801734:	8b 45 0c             	mov    0xc(%ebp),%eax
  801737:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80173a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80173d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801740:	85 c0                	test   %eax,%eax
  801742:	75 08                	jne    80174c <printnum+0x2c>
  801744:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801747:	39 45 10             	cmp    %eax,0x10(%ebp)
  80174a:	77 57                	ja     8017a3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80174c:	89 74 24 10          	mov    %esi,0x10(%esp)
  801750:	4b                   	dec    %ebx
  801751:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801755:	8b 45 10             	mov    0x10(%ebp),%eax
  801758:	89 44 24 08          	mov    %eax,0x8(%esp)
  80175c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801760:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801764:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80176b:	00 
  80176c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80176f:	89 04 24             	mov    %eax,(%esp)
  801772:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801775:	89 44 24 04          	mov    %eax,0x4(%esp)
  801779:	e8 5a 06 00 00       	call   801dd8 <__udivdi3>
  80177e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801782:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801786:	89 04 24             	mov    %eax,(%esp)
  801789:	89 54 24 04          	mov    %edx,0x4(%esp)
  80178d:	89 fa                	mov    %edi,%edx
  80178f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801792:	e8 89 ff ff ff       	call   801720 <printnum>
  801797:	eb 0f                	jmp    8017a8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801799:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80179d:	89 34 24             	mov    %esi,(%esp)
  8017a0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8017a3:	4b                   	dec    %ebx
  8017a4:	85 db                	test   %ebx,%ebx
  8017a6:	7f f1                	jg     801799 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8017a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017ac:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8017b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8017b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8017be:	00 
  8017bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8017c2:	89 04 24             	mov    %eax,(%esp)
  8017c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cc:	e8 27 07 00 00       	call   801ef8 <__umoddi3>
  8017d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017d5:	0f be 80 8b 21 80 00 	movsbl 0x80218b(%eax),%eax
  8017dc:	89 04 24             	mov    %eax,(%esp)
  8017df:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8017e2:	83 c4 3c             	add    $0x3c,%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5f                   	pop    %edi
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8017ed:	83 fa 01             	cmp    $0x1,%edx
  8017f0:	7e 0e                	jle    801800 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8017f2:	8b 10                	mov    (%eax),%edx
  8017f4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8017f7:	89 08                	mov    %ecx,(%eax)
  8017f9:	8b 02                	mov    (%edx),%eax
  8017fb:	8b 52 04             	mov    0x4(%edx),%edx
  8017fe:	eb 22                	jmp    801822 <getuint+0x38>
	else if (lflag)
  801800:	85 d2                	test   %edx,%edx
  801802:	74 10                	je     801814 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801804:	8b 10                	mov    (%eax),%edx
  801806:	8d 4a 04             	lea    0x4(%edx),%ecx
  801809:	89 08                	mov    %ecx,(%eax)
  80180b:	8b 02                	mov    (%edx),%eax
  80180d:	ba 00 00 00 00       	mov    $0x0,%edx
  801812:	eb 0e                	jmp    801822 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801814:	8b 10                	mov    (%eax),%edx
  801816:	8d 4a 04             	lea    0x4(%edx),%ecx
  801819:	89 08                	mov    %ecx,(%eax)
  80181b:	8b 02                	mov    (%edx),%eax
  80181d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80182a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80182d:	8b 10                	mov    (%eax),%edx
  80182f:	3b 50 04             	cmp    0x4(%eax),%edx
  801832:	73 08                	jae    80183c <sprintputch+0x18>
		*b->buf++ = ch;
  801834:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801837:	88 0a                	mov    %cl,(%edx)
  801839:	42                   	inc    %edx
  80183a:	89 10                	mov    %edx,(%eax)
}
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801844:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801847:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80184b:	8b 45 10             	mov    0x10(%ebp),%eax
  80184e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801852:	8b 45 0c             	mov    0xc(%ebp),%eax
  801855:	89 44 24 04          	mov    %eax,0x4(%esp)
  801859:	8b 45 08             	mov    0x8(%ebp),%eax
  80185c:	89 04 24             	mov    %eax,(%esp)
  80185f:	e8 02 00 00 00       	call   801866 <vprintfmt>
	va_end(ap);
}
  801864:	c9                   	leave  
  801865:	c3                   	ret    

00801866 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	57                   	push   %edi
  80186a:	56                   	push   %esi
  80186b:	53                   	push   %ebx
  80186c:	83 ec 4c             	sub    $0x4c,%esp
  80186f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801872:	8b 75 10             	mov    0x10(%ebp),%esi
  801875:	eb 12                	jmp    801889 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801877:	85 c0                	test   %eax,%eax
  801879:	0f 84 6b 03 00 00    	je     801bea <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80187f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801883:	89 04 24             	mov    %eax,(%esp)
  801886:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801889:	0f b6 06             	movzbl (%esi),%eax
  80188c:	46                   	inc    %esi
  80188d:	83 f8 25             	cmp    $0x25,%eax
  801890:	75 e5                	jne    801877 <vprintfmt+0x11>
  801892:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801896:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80189d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8018a2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8018a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018ae:	eb 26                	jmp    8018d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8018b3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8018b7:	eb 1d                	jmp    8018d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8018bc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8018c0:	eb 14                	jmp    8018d6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018c2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8018c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8018cc:	eb 08                	jmp    8018d6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8018ce:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8018d1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d6:	0f b6 06             	movzbl (%esi),%eax
  8018d9:	8d 56 01             	lea    0x1(%esi),%edx
  8018dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018df:	8a 16                	mov    (%esi),%dl
  8018e1:	83 ea 23             	sub    $0x23,%edx
  8018e4:	80 fa 55             	cmp    $0x55,%dl
  8018e7:	0f 87 e1 02 00 00    	ja     801bce <vprintfmt+0x368>
  8018ed:	0f b6 d2             	movzbl %dl,%edx
  8018f0:	ff 24 95 c0 22 80 00 	jmp    *0x8022c0(,%edx,4)
  8018f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8018fa:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8018ff:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801902:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  801906:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801909:	8d 50 d0             	lea    -0x30(%eax),%edx
  80190c:	83 fa 09             	cmp    $0x9,%edx
  80190f:	77 2a                	ja     80193b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801911:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801912:	eb eb                	jmp    8018ff <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801914:	8b 45 14             	mov    0x14(%ebp),%eax
  801917:	8d 50 04             	lea    0x4(%eax),%edx
  80191a:	89 55 14             	mov    %edx,0x14(%ebp)
  80191d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80191f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801922:	eb 17                	jmp    80193b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801924:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801928:	78 98                	js     8018c2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80192a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80192d:	eb a7                	jmp    8018d6 <vprintfmt+0x70>
  80192f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801932:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801939:	eb 9b                	jmp    8018d6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80193b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80193f:	79 95                	jns    8018d6 <vprintfmt+0x70>
  801941:	eb 8b                	jmp    8018ce <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801943:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801944:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801947:	eb 8d                	jmp    8018d6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801949:	8b 45 14             	mov    0x14(%ebp),%eax
  80194c:	8d 50 04             	lea    0x4(%eax),%edx
  80194f:	89 55 14             	mov    %edx,0x14(%ebp)
  801952:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801956:	8b 00                	mov    (%eax),%eax
  801958:	89 04 24             	mov    %eax,(%esp)
  80195b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80195e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801961:	e9 23 ff ff ff       	jmp    801889 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801966:	8b 45 14             	mov    0x14(%ebp),%eax
  801969:	8d 50 04             	lea    0x4(%eax),%edx
  80196c:	89 55 14             	mov    %edx,0x14(%ebp)
  80196f:	8b 00                	mov    (%eax),%eax
  801971:	85 c0                	test   %eax,%eax
  801973:	79 02                	jns    801977 <vprintfmt+0x111>
  801975:	f7 d8                	neg    %eax
  801977:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801979:	83 f8 0f             	cmp    $0xf,%eax
  80197c:	7f 0b                	jg     801989 <vprintfmt+0x123>
  80197e:	8b 04 85 20 24 80 00 	mov    0x802420(,%eax,4),%eax
  801985:	85 c0                	test   %eax,%eax
  801987:	75 23                	jne    8019ac <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801989:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80198d:	c7 44 24 08 a3 21 80 	movl   $0x8021a3,0x8(%esp)
  801994:	00 
  801995:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801999:	8b 45 08             	mov    0x8(%ebp),%eax
  80199c:	89 04 24             	mov    %eax,(%esp)
  80199f:	e8 9a fe ff ff       	call   80183e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8019a7:	e9 dd fe ff ff       	jmp    801889 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8019ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019b0:	c7 44 24 08 21 21 80 	movl   $0x802121,0x8(%esp)
  8019b7:	00 
  8019b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8019bf:	89 14 24             	mov    %edx,(%esp)
  8019c2:	e8 77 fe ff ff       	call   80183e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8019ca:	e9 ba fe ff ff       	jmp    801889 <vprintfmt+0x23>
  8019cf:	89 f9                	mov    %edi,%ecx
  8019d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8019d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8019da:	8d 50 04             	lea    0x4(%eax),%edx
  8019dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8019e0:	8b 30                	mov    (%eax),%esi
  8019e2:	85 f6                	test   %esi,%esi
  8019e4:	75 05                	jne    8019eb <vprintfmt+0x185>
				p = "(null)";
  8019e6:	be 9c 21 80 00       	mov    $0x80219c,%esi
			if (width > 0 && padc != '-')
  8019eb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8019ef:	0f 8e 84 00 00 00    	jle    801a79 <vprintfmt+0x213>
  8019f5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8019f9:	74 7e                	je     801a79 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8019fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019ff:	89 34 24             	mov    %esi,(%esp)
  801a02:	e8 7b e7 ff ff       	call   800182 <strnlen>
  801a07:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801a0a:	29 c2                	sub    %eax,%edx
  801a0c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801a0f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801a13:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801a16:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801a19:	89 de                	mov    %ebx,%esi
  801a1b:	89 d3                	mov    %edx,%ebx
  801a1d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a1f:	eb 0b                	jmp    801a2c <vprintfmt+0x1c6>
					putch(padc, putdat);
  801a21:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a25:	89 3c 24             	mov    %edi,(%esp)
  801a28:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a2b:	4b                   	dec    %ebx
  801a2c:	85 db                	test   %ebx,%ebx
  801a2e:	7f f1                	jg     801a21 <vprintfmt+0x1bb>
  801a30:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801a33:	89 f3                	mov    %esi,%ebx
  801a35:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801a38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	79 05                	jns    801a44 <vprintfmt+0x1de>
  801a3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a44:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801a47:	29 c2                	sub    %eax,%edx
  801a49:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801a4c:	eb 2b                	jmp    801a79 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a4e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a52:	74 18                	je     801a6c <vprintfmt+0x206>
  801a54:	8d 50 e0             	lea    -0x20(%eax),%edx
  801a57:	83 fa 5e             	cmp    $0x5e,%edx
  801a5a:	76 10                	jbe    801a6c <vprintfmt+0x206>
					putch('?', putdat);
  801a5c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a60:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801a67:	ff 55 08             	call   *0x8(%ebp)
  801a6a:	eb 0a                	jmp    801a76 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801a6c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a70:	89 04 24             	mov    %eax,(%esp)
  801a73:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a76:	ff 4d e4             	decl   -0x1c(%ebp)
  801a79:	0f be 06             	movsbl (%esi),%eax
  801a7c:	46                   	inc    %esi
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	74 21                	je     801aa2 <vprintfmt+0x23c>
  801a81:	85 ff                	test   %edi,%edi
  801a83:	78 c9                	js     801a4e <vprintfmt+0x1e8>
  801a85:	4f                   	dec    %edi
  801a86:	79 c6                	jns    801a4e <vprintfmt+0x1e8>
  801a88:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a8b:	89 de                	mov    %ebx,%esi
  801a8d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801a90:	eb 18                	jmp    801aaa <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a92:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a96:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801a9d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a9f:	4b                   	dec    %ebx
  801aa0:	eb 08                	jmp    801aaa <vprintfmt+0x244>
  801aa2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aa5:	89 de                	mov    %ebx,%esi
  801aa7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801aaa:	85 db                	test   %ebx,%ebx
  801aac:	7f e4                	jg     801a92 <vprintfmt+0x22c>
  801aae:	89 7d 08             	mov    %edi,0x8(%ebp)
  801ab1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ab3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801ab6:	e9 ce fd ff ff       	jmp    801889 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801abb:	83 f9 01             	cmp    $0x1,%ecx
  801abe:	7e 10                	jle    801ad0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801ac0:	8b 45 14             	mov    0x14(%ebp),%eax
  801ac3:	8d 50 08             	lea    0x8(%eax),%edx
  801ac6:	89 55 14             	mov    %edx,0x14(%ebp)
  801ac9:	8b 30                	mov    (%eax),%esi
  801acb:	8b 78 04             	mov    0x4(%eax),%edi
  801ace:	eb 26                	jmp    801af6 <vprintfmt+0x290>
	else if (lflag)
  801ad0:	85 c9                	test   %ecx,%ecx
  801ad2:	74 12                	je     801ae6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  801ad4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ad7:	8d 50 04             	lea    0x4(%eax),%edx
  801ada:	89 55 14             	mov    %edx,0x14(%ebp)
  801add:	8b 30                	mov    (%eax),%esi
  801adf:	89 f7                	mov    %esi,%edi
  801ae1:	c1 ff 1f             	sar    $0x1f,%edi
  801ae4:	eb 10                	jmp    801af6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801ae6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae9:	8d 50 04             	lea    0x4(%eax),%edx
  801aec:	89 55 14             	mov    %edx,0x14(%ebp)
  801aef:	8b 30                	mov    (%eax),%esi
  801af1:	89 f7                	mov    %esi,%edi
  801af3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801af6:	85 ff                	test   %edi,%edi
  801af8:	78 0a                	js     801b04 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801afa:	b8 0a 00 00 00       	mov    $0xa,%eax
  801aff:	e9 8c 00 00 00       	jmp    801b90 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801b04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b08:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801b0f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801b12:	f7 de                	neg    %esi
  801b14:	83 d7 00             	adc    $0x0,%edi
  801b17:	f7 df                	neg    %edi
			}
			base = 10;
  801b19:	b8 0a 00 00 00       	mov    $0xa,%eax
  801b1e:	eb 70                	jmp    801b90 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b20:	89 ca                	mov    %ecx,%edx
  801b22:	8d 45 14             	lea    0x14(%ebp),%eax
  801b25:	e8 c0 fc ff ff       	call   8017ea <getuint>
  801b2a:	89 c6                	mov    %eax,%esi
  801b2c:	89 d7                	mov    %edx,%edi
			base = 10;
  801b2e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801b33:	eb 5b                	jmp    801b90 <vprintfmt+0x32a>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801b35:	89 ca                	mov    %ecx,%edx
  801b37:	8d 45 14             	lea    0x14(%ebp),%eax
  801b3a:	e8 ab fc ff ff       	call   8017ea <getuint>
  801b3f:	89 c6                	mov    %eax,%esi
  801b41:	89 d7                	mov    %edx,%edi
			base = 8;
  801b43:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801b48:	eb 46                	jmp    801b90 <vprintfmt+0x32a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  801b4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b4e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801b55:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801b58:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b5c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801b63:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b66:	8b 45 14             	mov    0x14(%ebp),%eax
  801b69:	8d 50 04             	lea    0x4(%eax),%edx
  801b6c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b6f:	8b 30                	mov    (%eax),%esi
  801b71:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b76:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801b7b:	eb 13                	jmp    801b90 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b7d:	89 ca                	mov    %ecx,%edx
  801b7f:	8d 45 14             	lea    0x14(%ebp),%eax
  801b82:	e8 63 fc ff ff       	call   8017ea <getuint>
  801b87:	89 c6                	mov    %eax,%esi
  801b89:	89 d7                	mov    %edx,%edi
			base = 16;
  801b8b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b90:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801b94:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b98:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba3:	89 34 24             	mov    %esi,(%esp)
  801ba6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801baa:	89 da                	mov    %ebx,%edx
  801bac:	8b 45 08             	mov    0x8(%ebp),%eax
  801baf:	e8 6c fb ff ff       	call   801720 <printnum>
			break;
  801bb4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801bb7:	e9 cd fc ff ff       	jmp    801889 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801bbc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bc0:	89 04 24             	mov    %eax,(%esp)
  801bc3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bc6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801bc9:	e9 bb fc ff ff       	jmp    801889 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801bce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bd2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801bd9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801bdc:	eb 01                	jmp    801bdf <vprintfmt+0x379>
  801bde:	4e                   	dec    %esi
  801bdf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801be3:	75 f9                	jne    801bde <vprintfmt+0x378>
  801be5:	e9 9f fc ff ff       	jmp    801889 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801bea:	83 c4 4c             	add    $0x4c,%esp
  801bed:	5b                   	pop    %ebx
  801bee:	5e                   	pop    %esi
  801bef:	5f                   	pop    %edi
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    

00801bf2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	83 ec 28             	sub    $0x28,%esp
  801bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801bfe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c01:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801c05:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	74 30                	je     801c43 <vsnprintf+0x51>
  801c13:	85 d2                	test   %edx,%edx
  801c15:	7e 33                	jle    801c4a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801c17:	8b 45 14             	mov    0x14(%ebp),%eax
  801c1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c1e:	8b 45 10             	mov    0x10(%ebp),%eax
  801c21:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c25:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801c28:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c2c:	c7 04 24 24 18 80 00 	movl   $0x801824,(%esp)
  801c33:	e8 2e fc ff ff       	call   801866 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801c38:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c3b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c41:	eb 0c                	jmp    801c4f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801c43:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c48:	eb 05                	jmp    801c4f <vsnprintf+0x5d>
  801c4a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801c4f:	c9                   	leave  
  801c50:	c3                   	ret    

00801c51 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801c57:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801c5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c5e:	8b 45 10             	mov    0x10(%ebp),%eax
  801c61:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6f:	89 04 24             	mov    %eax,(%esp)
  801c72:	e8 7b ff ff ff       	call   801bf2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    
  801c79:	00 00                	add    %al,(%eax)
	...

00801c7c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	56                   	push   %esi
  801c80:	53                   	push   %ebx
  801c81:	83 ec 10             	sub    $0x10,%esp
  801c84:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801c8d:	85 c0                	test   %eax,%eax
  801c8f:	75 05                	jne    801c96 <ipc_recv+0x1a>
  801c91:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
	// cprintf("now %x\n",pg);
	int err = sys_ipc_recv(pg);
  801c96:	89 04 24             	mov    %eax,(%esp)
  801c99:	e8 09 eb ff ff       	call   8007a7 <sys_ipc_recv>
	// cprintf("err %x %x\n",pg,err);
	if (err < 0){
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	79 16                	jns    801cb8 <ipc_recv+0x3c>
		if (from_env_store != NULL)*from_env_store=0;
  801ca2:	85 db                	test   %ebx,%ebx
  801ca4:	74 06                	je     801cac <ipc_recv+0x30>
  801ca6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if (perm_store != NULL)*perm_store=0;
  801cac:	85 f6                	test   %esi,%esi
  801cae:	74 32                	je     801ce2 <ipc_recv+0x66>
  801cb0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801cb6:	eb 2a                	jmp    801ce2 <ipc_recv+0x66>
		return err;
	}else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  801cb8:	85 db                	test   %ebx,%ebx
  801cba:	74 0c                	je     801cc8 <ipc_recv+0x4c>
  801cbc:	a1 04 40 80 00       	mov    0x804004,%eax
  801cc1:	8b 00                	mov    (%eax),%eax
  801cc3:	8b 40 74             	mov    0x74(%eax),%eax
  801cc6:	89 03                	mov    %eax,(%ebx)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  801cc8:	85 f6                	test   %esi,%esi
  801cca:	74 0c                	je     801cd8 <ipc_recv+0x5c>
  801ccc:	a1 04 40 80 00       	mov    0x804004,%eax
  801cd1:	8b 00                	mov    (%eax),%eax
  801cd3:	8b 40 78             	mov    0x78(%eax),%eax
  801cd6:	89 06                	mov    %eax,(%esi)
		// cprintf("%x\n",thisenv->env_ipc_value);
		return thisenv->env_ipc_value;
  801cd8:	a1 04 40 80 00       	mov    0x804004,%eax
  801cdd:	8b 00                	mov    (%eax),%eax
  801cdf:	8b 40 70             	mov    0x70(%eax),%eax
    }
	panic("ipc_recv not implemented");
	return 0;
}
  801ce2:	83 c4 10             	add    $0x10,%esp
  801ce5:	5b                   	pop    %ebx
  801ce6:	5e                   	pop    %esi
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    

00801ce9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	57                   	push   %edi
  801ced:	56                   	push   %esi
  801cee:	53                   	push   %ebx
  801cef:	83 ec 1c             	sub    $0x1c,%esp
  801cf2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801cf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cf8:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 4: Your code here.
	if (pg==NULL)pg=(void *)UTOP;
  801cfb:	85 db                	test   %ebx,%ebx
  801cfd:	75 05                	jne    801d04 <ipc_send+0x1b>
  801cff:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
  801d04:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d08:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d0c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d10:	8b 45 08             	mov    0x8(%ebp),%eax
  801d13:	89 04 24             	mov    %eax,(%esp)
  801d16:	e8 69 ea ff ff       	call   800784 <sys_ipc_try_send>
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
  801d1b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d1e:	75 07                	jne    801d27 <ipc_send+0x3e>
  801d20:	e8 4d e8 ff ff       	call   800572 <sys_yield>
		else if (err < 0)panic("ipc send: error!\n");
		else return;
    }
  801d25:	eb dd                	jmp    801d04 <ipc_send+0x1b>
	int err;
	while (true){
		err = sys_ipc_try_send(to_env,val,pg,perm);
		// cprintf("%x\n",err);
		if (err == -E_IPC_NOT_RECV)sys_yield();
		else if (err < 0)panic("ipc send: error!\n");
  801d27:	85 c0                	test   %eax,%eax
  801d29:	79 1c                	jns    801d47 <ipc_send+0x5e>
  801d2b:	c7 44 24 08 80 24 80 	movl   $0x802480,0x8(%esp)
  801d32:	00 
  801d33:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801d3a:	00 
  801d3b:	c7 04 24 92 24 80 00 	movl   $0x802492,(%esp)
  801d42:	e8 c5 f8 ff ff       	call   80160c <_panic>
		else return;
    }
	return;
	panic("ipc_send not implemented");
}
  801d47:	83 c4 1c             	add    $0x1c,%esp
  801d4a:	5b                   	pop    %ebx
  801d4b:	5e                   	pop    %esi
  801d4c:	5f                   	pop    %edi
  801d4d:	5d                   	pop    %ebp
  801d4e:	c3                   	ret    

00801d4f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	53                   	push   %ebx
  801d53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801d56:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d5b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801d62:	89 c2                	mov    %eax,%edx
  801d64:	c1 e2 07             	shl    $0x7,%edx
  801d67:	29 ca                	sub    %ecx,%edx
  801d69:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d6f:	8b 52 50             	mov    0x50(%edx),%edx
  801d72:	39 da                	cmp    %ebx,%edx
  801d74:	75 0f                	jne    801d85 <ipc_find_env+0x36>
			return envs[i].env_id;
  801d76:	c1 e0 07             	shl    $0x7,%eax
  801d79:	29 c8                	sub    %ecx,%eax
  801d7b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801d80:	8b 40 40             	mov    0x40(%eax),%eax
  801d83:	eb 0c                	jmp    801d91 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d85:	40                   	inc    %eax
  801d86:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d8b:	75 ce                	jne    801d5b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d8d:	66 b8 00 00          	mov    $0x0,%ax
}
  801d91:	5b                   	pop    %ebx
  801d92:	5d                   	pop    %ebp
  801d93:	c3                   	ret    

00801d94 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
  801d9a:	89 c2                	mov    %eax,%edx
  801d9c:	c1 ea 16             	shr    $0x16,%edx
  801d9f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801da6:	f6 c2 01             	test   $0x1,%dl
  801da9:	74 1e                	je     801dc9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801dab:	c1 e8 0c             	shr    $0xc,%eax
  801dae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801db5:	a8 01                	test   $0x1,%al
  801db7:	74 17                	je     801dd0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801db9:	c1 e8 0c             	shr    $0xc,%eax
  801dbc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801dc3:	ef 
  801dc4:	0f b7 c0             	movzwl %ax,%eax
  801dc7:	eb 0c                	jmp    801dd5 <pageref+0x41>
int
pageref(void *v)
{
	pte_t pte;
	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801dc9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dce:	eb 05                	jmp    801dd5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801dd0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801dd5:	5d                   	pop    %ebp
  801dd6:	c3                   	ret    
	...

00801dd8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  801dd8:	55                   	push   %ebp
  801dd9:	57                   	push   %edi
  801dda:	56                   	push   %esi
  801ddb:	83 ec 10             	sub    $0x10,%esp
  801dde:	8b 74 24 20          	mov    0x20(%esp),%esi
  801de2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801de6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dea:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  801dee:	89 cd                	mov    %ecx,%ebp
  801df0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801df4:	85 c0                	test   %eax,%eax
  801df6:	75 2c                	jne    801e24 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  801df8:	39 f9                	cmp    %edi,%ecx
  801dfa:	77 68                	ja     801e64 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801dfc:	85 c9                	test   %ecx,%ecx
  801dfe:	75 0b                	jne    801e0b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801e00:	b8 01 00 00 00       	mov    $0x1,%eax
  801e05:	31 d2                	xor    %edx,%edx
  801e07:	f7 f1                	div    %ecx
  801e09:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801e0b:	31 d2                	xor    %edx,%edx
  801e0d:	89 f8                	mov    %edi,%eax
  801e0f:	f7 f1                	div    %ecx
  801e11:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e13:	89 f0                	mov    %esi,%eax
  801e15:	f7 f1                	div    %ecx
  801e17:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e19:	89 f0                	mov    %esi,%eax
  801e1b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e1d:	83 c4 10             	add    $0x10,%esp
  801e20:	5e                   	pop    %esi
  801e21:	5f                   	pop    %edi
  801e22:	5d                   	pop    %ebp
  801e23:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e24:	39 f8                	cmp    %edi,%eax
  801e26:	77 2c                	ja     801e54 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801e28:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  801e2b:	83 f6 1f             	xor    $0x1f,%esi
  801e2e:	75 4c                	jne    801e7c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e30:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e32:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801e37:	72 0a                	jb     801e43 <__udivdi3+0x6b>
  801e39:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801e3d:	0f 87 ad 00 00 00    	ja     801ef0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801e43:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e48:	89 f0                	mov    %esi,%eax
  801e4a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e4c:	83 c4 10             	add    $0x10,%esp
  801e4f:	5e                   	pop    %esi
  801e50:	5f                   	pop    %edi
  801e51:	5d                   	pop    %ebp
  801e52:	c3                   	ret    
  801e53:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801e54:	31 ff                	xor    %edi,%edi
  801e56:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e58:	89 f0                	mov    %esi,%eax
  801e5a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e5c:	83 c4 10             	add    $0x10,%esp
  801e5f:	5e                   	pop    %esi
  801e60:	5f                   	pop    %edi
  801e61:	5d                   	pop    %ebp
  801e62:	c3                   	ret    
  801e63:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801e64:	89 fa                	mov    %edi,%edx
  801e66:	89 f0                	mov    %esi,%eax
  801e68:	f7 f1                	div    %ecx
  801e6a:	89 c6                	mov    %eax,%esi
  801e6c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  801e6e:	89 f0                	mov    %esi,%eax
  801e70:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  801e72:	83 c4 10             	add    $0x10,%esp
  801e75:	5e                   	pop    %esi
  801e76:	5f                   	pop    %edi
  801e77:	5d                   	pop    %ebp
  801e78:	c3                   	ret    
  801e79:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801e7c:	89 f1                	mov    %esi,%ecx
  801e7e:	d3 e0                	shl    %cl,%eax
  801e80:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801e84:	b8 20 00 00 00       	mov    $0x20,%eax
  801e89:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  801e8b:	89 ea                	mov    %ebp,%edx
  801e8d:	88 c1                	mov    %al,%cl
  801e8f:	d3 ea                	shr    %cl,%edx
  801e91:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801e95:	09 ca                	or     %ecx,%edx
  801e97:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  801e9b:	89 f1                	mov    %esi,%ecx
  801e9d:	d3 e5                	shl    %cl,%ebp
  801e9f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  801ea3:	89 fd                	mov    %edi,%ebp
  801ea5:	88 c1                	mov    %al,%cl
  801ea7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  801ea9:	89 fa                	mov    %edi,%edx
  801eab:	89 f1                	mov    %esi,%ecx
  801ead:	d3 e2                	shl    %cl,%edx
  801eaf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801eb3:	88 c1                	mov    %al,%cl
  801eb5:	d3 ef                	shr    %cl,%edi
  801eb7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801eb9:	89 f8                	mov    %edi,%eax
  801ebb:	89 ea                	mov    %ebp,%edx
  801ebd:	f7 74 24 08          	divl   0x8(%esp)
  801ec1:	89 d1                	mov    %edx,%ecx
  801ec3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  801ec5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ec9:	39 d1                	cmp    %edx,%ecx
  801ecb:	72 17                	jb     801ee4 <__udivdi3+0x10c>
  801ecd:	74 09                	je     801ed8 <__udivdi3+0x100>
  801ecf:	89 fe                	mov    %edi,%esi
  801ed1:	31 ff                	xor    %edi,%edi
  801ed3:	e9 41 ff ff ff       	jmp    801e19 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  801ed8:	8b 54 24 04          	mov    0x4(%esp),%edx
  801edc:	89 f1                	mov    %esi,%ecx
  801ede:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801ee0:	39 c2                	cmp    %eax,%edx
  801ee2:	73 eb                	jae    801ecf <__udivdi3+0xf7>
		{
		  q0--;
  801ee4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  801ee7:	31 ff                	xor    %edi,%edi
  801ee9:	e9 2b ff ff ff       	jmp    801e19 <__udivdi3+0x41>
  801eee:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ef0:	31 f6                	xor    %esi,%esi
  801ef2:	e9 22 ff ff ff       	jmp    801e19 <__udivdi3+0x41>
	...

00801ef8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  801ef8:	55                   	push   %ebp
  801ef9:	57                   	push   %edi
  801efa:	56                   	push   %esi
  801efb:	83 ec 20             	sub    $0x20,%esp
  801efe:	8b 44 24 30          	mov    0x30(%esp),%eax
  801f02:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  801f06:	89 44 24 14          	mov    %eax,0x14(%esp)
  801f0a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  801f0e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801f12:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  801f16:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  801f18:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  801f1a:	85 ed                	test   %ebp,%ebp
  801f1c:	75 16                	jne    801f34 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  801f1e:	39 f1                	cmp    %esi,%ecx
  801f20:	0f 86 a6 00 00 00    	jbe    801fcc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801f26:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  801f28:	89 d0                	mov    %edx,%eax
  801f2a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801f2c:	83 c4 20             	add    $0x20,%esp
  801f2f:	5e                   	pop    %esi
  801f30:	5f                   	pop    %edi
  801f31:	5d                   	pop    %ebp
  801f32:	c3                   	ret    
  801f33:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  801f34:	39 f5                	cmp    %esi,%ebp
  801f36:	0f 87 ac 00 00 00    	ja     801fe8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  801f3c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  801f3f:	83 f0 1f             	xor    $0x1f,%eax
  801f42:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f46:	0f 84 a8 00 00 00    	je     801ff4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  801f4c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f50:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  801f52:	bf 20 00 00 00       	mov    $0x20,%edi
  801f57:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  801f5b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f5f:	89 f9                	mov    %edi,%ecx
  801f61:	d3 e8                	shr    %cl,%eax
  801f63:	09 e8                	or     %ebp,%eax
  801f65:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  801f69:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801f6d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801f71:	d3 e0                	shl    %cl,%eax
  801f73:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f77:	89 f2                	mov    %esi,%edx
  801f79:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  801f7b:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f7f:	d3 e0                	shl    %cl,%eax
  801f81:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  801f85:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f89:	89 f9                	mov    %edi,%ecx
  801f8b:	d3 e8                	shr    %cl,%eax
  801f8d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  801f8f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  801f91:	89 f2                	mov    %esi,%edx
  801f93:	f7 74 24 18          	divl   0x18(%esp)
  801f97:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  801f99:	f7 64 24 0c          	mull   0xc(%esp)
  801f9d:	89 c5                	mov    %eax,%ebp
  801f9f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  801fa1:	39 d6                	cmp    %edx,%esi
  801fa3:	72 67                	jb     80200c <__umoddi3+0x114>
  801fa5:	74 75                	je     80201c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  801fa7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801fab:	29 e8                	sub    %ebp,%eax
  801fad:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  801faf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801fb3:	d3 e8                	shr    %cl,%eax
  801fb5:	89 f2                	mov    %esi,%edx
  801fb7:	89 f9                	mov    %edi,%ecx
  801fb9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  801fbb:	09 d0                	or     %edx,%eax
  801fbd:	89 f2                	mov    %esi,%edx
  801fbf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801fc3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fc5:	83 c4 20             	add    $0x20,%esp
  801fc8:	5e                   	pop    %esi
  801fc9:	5f                   	pop    %edi
  801fca:	5d                   	pop    %ebp
  801fcb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  801fcc:	85 c9                	test   %ecx,%ecx
  801fce:	75 0b                	jne    801fdb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  801fd0:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd5:	31 d2                	xor    %edx,%edx
  801fd7:	f7 f1                	div    %ecx
  801fd9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  801fdb:	89 f0                	mov    %esi,%eax
  801fdd:	31 d2                	xor    %edx,%edx
  801fdf:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  801fe1:	89 f8                	mov    %edi,%eax
  801fe3:	e9 3e ff ff ff       	jmp    801f26 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  801fe8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  801fea:	83 c4 20             	add    $0x20,%esp
  801fed:	5e                   	pop    %esi
  801fee:	5f                   	pop    %edi
  801fef:	5d                   	pop    %ebp
  801ff0:	c3                   	ret    
  801ff1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  801ff4:	39 f5                	cmp    %esi,%ebp
  801ff6:	72 04                	jb     801ffc <__umoddi3+0x104>
  801ff8:	39 f9                	cmp    %edi,%ecx
  801ffa:	77 06                	ja     802002 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  801ffc:	89 f2                	mov    %esi,%edx
  801ffe:	29 cf                	sub    %ecx,%edi
  802000:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802002:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802004:	83 c4 20             	add    $0x20,%esp
  802007:	5e                   	pop    %esi
  802008:	5f                   	pop    %edi
  802009:	5d                   	pop    %ebp
  80200a:	c3                   	ret    
  80200b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80200c:	89 d1                	mov    %edx,%ecx
  80200e:	89 c5                	mov    %eax,%ebp
  802010:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802014:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802018:	eb 8d                	jmp    801fa7 <__umoddi3+0xaf>
  80201a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80201c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802020:	72 ea                	jb     80200c <__umoddi3+0x114>
  802022:	89 f1                	mov    %esi,%ecx
  802024:	eb 81                	jmp    801fa7 <__umoddi3+0xaf>
