
_ln:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	8b 59 04             	mov    0x4(%ecx),%ebx
  if(argc != 3){
  12:	83 39 03             	cmpl   $0x3,(%ecx)
  15:	74 14                	je     2b <main+0x2b>
    printf(2, "Usage: ln old new\n");
  17:	83 ec 08             	sub    $0x8,%esp
  1a:	68 f4 05 00 00       	push   $0x5f4
  1f:	6a 02                	push   $0x2
  21:	e8 15 03 00 00       	call   33b <printf>
    exit();
  26:	e8 be 01 00 00       	call   1e9 <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  2b:	83 ec 08             	sub    $0x8,%esp
  2e:	ff 73 08             	pushl  0x8(%ebx)
  31:	ff 73 04             	pushl  0x4(%ebx)
  34:	e8 10 02 00 00       	call   249 <link>
  39:	83 c4 10             	add    $0x10,%esp
  3c:	85 c0                	test   %eax,%eax
  3e:	78 05                	js     45 <main+0x45>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit();
  40:	e8 a4 01 00 00       	call   1e9 <exit>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  45:	ff 73 08             	pushl  0x8(%ebx)
  48:	ff 73 04             	pushl  0x4(%ebx)
  4b:	68 07 06 00 00       	push   $0x607
  50:	6a 02                	push   $0x2
  52:	e8 e4 02 00 00       	call   33b <printf>
  57:	83 c4 10             	add    $0x10,%esp
  5a:	eb e4                	jmp    40 <main+0x40>

0000005c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  5c:	55                   	push   %ebp
  5d:	89 e5                	mov    %esp,%ebp
  5f:	53                   	push   %ebx
  60:	8b 45 08             	mov    0x8(%ebp),%eax
  63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  66:	89 c2                	mov    %eax,%edx
  68:	0f b6 19             	movzbl (%ecx),%ebx
  6b:	88 1a                	mov    %bl,(%edx)
  6d:	8d 52 01             	lea    0x1(%edx),%edx
  70:	8d 49 01             	lea    0x1(%ecx),%ecx
  73:	84 db                	test   %bl,%bl
  75:	75 f1                	jne    68 <strcpy+0xc>
    ;
  return os;
}
  77:	5b                   	pop    %ebx
  78:	5d                   	pop    %ebp
  79:	c3                   	ret    

0000007a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7a:	55                   	push   %ebp
  7b:	89 e5                	mov    %esp,%ebp
  7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  83:	eb 06                	jmp    8b <strcmp+0x11>
    p++, q++;
  85:	83 c1 01             	add    $0x1,%ecx
  88:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  8b:	0f b6 01             	movzbl (%ecx),%eax
  8e:	84 c0                	test   %al,%al
  90:	74 04                	je     96 <strcmp+0x1c>
  92:	3a 02                	cmp    (%edx),%al
  94:	74 ef                	je     85 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  96:	0f b6 c0             	movzbl %al,%eax
  99:	0f b6 12             	movzbl (%edx),%edx
  9c:	29 d0                	sub    %edx,%eax
}
  9e:	5d                   	pop    %ebp
  9f:	c3                   	ret    

000000a0 <strlen>:

uint
strlen(const char *s)
{
  a0:	55                   	push   %ebp
  a1:	89 e5                	mov    %esp,%ebp
  a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  a6:	ba 00 00 00 00       	mov    $0x0,%edx
  ab:	eb 03                	jmp    b0 <strlen+0x10>
  ad:	83 c2 01             	add    $0x1,%edx
  b0:	89 d0                	mov    %edx,%eax
  b2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  b6:	75 f5                	jne    ad <strlen+0xd>
    ;
  return n;
}
  b8:	5d                   	pop    %ebp
  b9:	c3                   	ret    

000000ba <memset>:

void*
memset(void *dst, int c, uint n)
{
  ba:	55                   	push   %ebp
  bb:	89 e5                	mov    %esp,%ebp
  bd:	57                   	push   %edi
  be:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  c1:	89 d7                	mov    %edx,%edi
  c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  c9:	fc                   	cld    
  ca:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  cc:	89 d0                	mov    %edx,%eax
  ce:	5f                   	pop    %edi
  cf:	5d                   	pop    %ebp
  d0:	c3                   	ret    

000000d1 <strchr>:

char*
strchr(const char *s, char c)
{
  d1:	55                   	push   %ebp
  d2:	89 e5                	mov    %esp,%ebp
  d4:	8b 45 08             	mov    0x8(%ebp),%eax
  d7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  db:	0f b6 10             	movzbl (%eax),%edx
  de:	84 d2                	test   %dl,%dl
  e0:	74 09                	je     eb <strchr+0x1a>
    if(*s == c)
  e2:	38 ca                	cmp    %cl,%dl
  e4:	74 0a                	je     f0 <strchr+0x1f>
  for(; *s; s++)
  e6:	83 c0 01             	add    $0x1,%eax
  e9:	eb f0                	jmp    db <strchr+0xa>
      return (char*)s;
  return 0;
  eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  f0:	5d                   	pop    %ebp
  f1:	c3                   	ret    

000000f2 <gets>:

char*
gets(char *buf, int max)
{
  f2:	55                   	push   %ebp
  f3:	89 e5                	mov    %esp,%ebp
  f5:	57                   	push   %edi
  f6:	56                   	push   %esi
  f7:	53                   	push   %ebx
  f8:	83 ec 1c             	sub    $0x1c,%esp
  fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  fe:	bb 00 00 00 00       	mov    $0x0,%ebx
 103:	8d 73 01             	lea    0x1(%ebx),%esi
 106:	3b 75 0c             	cmp    0xc(%ebp),%esi
 109:	7d 2e                	jge    139 <gets+0x47>
    cc = read(0, &c, 1);
 10b:	83 ec 04             	sub    $0x4,%esp
 10e:	6a 01                	push   $0x1
 110:	8d 45 e7             	lea    -0x19(%ebp),%eax
 113:	50                   	push   %eax
 114:	6a 00                	push   $0x0
 116:	e8 e6 00 00 00       	call   201 <read>
    if(cc < 1)
 11b:	83 c4 10             	add    $0x10,%esp
 11e:	85 c0                	test   %eax,%eax
 120:	7e 17                	jle    139 <gets+0x47>
      break;
    buf[i++] = c;
 122:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 126:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 129:	3c 0a                	cmp    $0xa,%al
 12b:	0f 94 c2             	sete   %dl
 12e:	3c 0d                	cmp    $0xd,%al
 130:	0f 94 c0             	sete   %al
    buf[i++] = c;
 133:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 135:	08 c2                	or     %al,%dl
 137:	74 ca                	je     103 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 139:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 13d:	89 f8                	mov    %edi,%eax
 13f:	8d 65 f4             	lea    -0xc(%ebp),%esp
 142:	5b                   	pop    %ebx
 143:	5e                   	pop    %esi
 144:	5f                   	pop    %edi
 145:	5d                   	pop    %ebp
 146:	c3                   	ret    

00000147 <stat>:

int
stat(const char *n, struct stat *st)
{
 147:	55                   	push   %ebp
 148:	89 e5                	mov    %esp,%ebp
 14a:	56                   	push   %esi
 14b:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 14c:	83 ec 08             	sub    $0x8,%esp
 14f:	6a 00                	push   $0x0
 151:	ff 75 08             	pushl  0x8(%ebp)
 154:	e8 d0 00 00 00       	call   229 <open>
  if(fd < 0)
 159:	83 c4 10             	add    $0x10,%esp
 15c:	85 c0                	test   %eax,%eax
 15e:	78 24                	js     184 <stat+0x3d>
 160:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 162:	83 ec 08             	sub    $0x8,%esp
 165:	ff 75 0c             	pushl  0xc(%ebp)
 168:	50                   	push   %eax
 169:	e8 d3 00 00 00       	call   241 <fstat>
 16e:	89 c6                	mov    %eax,%esi
  close(fd);
 170:	89 1c 24             	mov    %ebx,(%esp)
 173:	e8 99 00 00 00       	call   211 <close>
  return r;
 178:	83 c4 10             	add    $0x10,%esp
}
 17b:	89 f0                	mov    %esi,%eax
 17d:	8d 65 f8             	lea    -0x8(%ebp),%esp
 180:	5b                   	pop    %ebx
 181:	5e                   	pop    %esi
 182:	5d                   	pop    %ebp
 183:	c3                   	ret    
    return -1;
 184:	be ff ff ff ff       	mov    $0xffffffff,%esi
 189:	eb f0                	jmp    17b <stat+0x34>

0000018b <atoi>:

int
atoi(const char *s)
{
 18b:	55                   	push   %ebp
 18c:	89 e5                	mov    %esp,%ebp
 18e:	53                   	push   %ebx
 18f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 192:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 197:	eb 10                	jmp    1a9 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 199:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 19c:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 19f:	83 c1 01             	add    $0x1,%ecx
 1a2:	0f be d2             	movsbl %dl,%edx
 1a5:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1a9:	0f b6 11             	movzbl (%ecx),%edx
 1ac:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1af:	80 fb 09             	cmp    $0x9,%bl
 1b2:	76 e5                	jbe    199 <atoi+0xe>
  return n;
}
 1b4:	5b                   	pop    %ebx
 1b5:	5d                   	pop    %ebp
 1b6:	c3                   	ret    

000001b7 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1b7:	55                   	push   %ebp
 1b8:	89 e5                	mov    %esp,%ebp
 1ba:	56                   	push   %esi
 1bb:	53                   	push   %ebx
 1bc:	8b 45 08             	mov    0x8(%ebp),%eax
 1bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1c2:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1c5:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1c7:	eb 0d                	jmp    1d6 <memmove+0x1f>
    *dst++ = *src++;
 1c9:	0f b6 13             	movzbl (%ebx),%edx
 1cc:	88 11                	mov    %dl,(%ecx)
 1ce:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1d1:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1d4:	89 f2                	mov    %esi,%edx
 1d6:	8d 72 ff             	lea    -0x1(%edx),%esi
 1d9:	85 d2                	test   %edx,%edx
 1db:	7f ec                	jg     1c9 <memmove+0x12>
  return vdst;
}
 1dd:	5b                   	pop    %ebx
 1de:	5e                   	pop    %esi
 1df:	5d                   	pop    %ebp
 1e0:	c3                   	ret    

000001e1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1e1:	b8 01 00 00 00       	mov    $0x1,%eax
 1e6:	cd 40                	int    $0x40
 1e8:	c3                   	ret    

000001e9 <exit>:
SYSCALL(exit)
 1e9:	b8 02 00 00 00       	mov    $0x2,%eax
 1ee:	cd 40                	int    $0x40
 1f0:	c3                   	ret    

000001f1 <wait>:
SYSCALL(wait)
 1f1:	b8 03 00 00 00       	mov    $0x3,%eax
 1f6:	cd 40                	int    $0x40
 1f8:	c3                   	ret    

000001f9 <pipe>:
SYSCALL(pipe)
 1f9:	b8 04 00 00 00       	mov    $0x4,%eax
 1fe:	cd 40                	int    $0x40
 200:	c3                   	ret    

00000201 <read>:
SYSCALL(read)
 201:	b8 05 00 00 00       	mov    $0x5,%eax
 206:	cd 40                	int    $0x40
 208:	c3                   	ret    

00000209 <write>:
SYSCALL(write)
 209:	b8 10 00 00 00       	mov    $0x10,%eax
 20e:	cd 40                	int    $0x40
 210:	c3                   	ret    

00000211 <close>:
SYSCALL(close)
 211:	b8 15 00 00 00       	mov    $0x15,%eax
 216:	cd 40                	int    $0x40
 218:	c3                   	ret    

00000219 <kill>:
SYSCALL(kill)
 219:	b8 06 00 00 00       	mov    $0x6,%eax
 21e:	cd 40                	int    $0x40
 220:	c3                   	ret    

00000221 <exec>:
SYSCALL(exec)
 221:	b8 07 00 00 00       	mov    $0x7,%eax
 226:	cd 40                	int    $0x40
 228:	c3                   	ret    

00000229 <open>:
SYSCALL(open)
 229:	b8 0f 00 00 00       	mov    $0xf,%eax
 22e:	cd 40                	int    $0x40
 230:	c3                   	ret    

00000231 <mknod>:
SYSCALL(mknod)
 231:	b8 11 00 00 00       	mov    $0x11,%eax
 236:	cd 40                	int    $0x40
 238:	c3                   	ret    

00000239 <unlink>:
SYSCALL(unlink)
 239:	b8 12 00 00 00       	mov    $0x12,%eax
 23e:	cd 40                	int    $0x40
 240:	c3                   	ret    

00000241 <fstat>:
SYSCALL(fstat)
 241:	b8 08 00 00 00       	mov    $0x8,%eax
 246:	cd 40                	int    $0x40
 248:	c3                   	ret    

00000249 <link>:
SYSCALL(link)
 249:	b8 13 00 00 00       	mov    $0x13,%eax
 24e:	cd 40                	int    $0x40
 250:	c3                   	ret    

00000251 <mkdir>:
SYSCALL(mkdir)
 251:	b8 14 00 00 00       	mov    $0x14,%eax
 256:	cd 40                	int    $0x40
 258:	c3                   	ret    

00000259 <chdir>:
SYSCALL(chdir)
 259:	b8 09 00 00 00       	mov    $0x9,%eax
 25e:	cd 40                	int    $0x40
 260:	c3                   	ret    

00000261 <dup>:
SYSCALL(dup)
 261:	b8 0a 00 00 00       	mov    $0xa,%eax
 266:	cd 40                	int    $0x40
 268:	c3                   	ret    

00000269 <getpid>:
SYSCALL(getpid)
 269:	b8 0b 00 00 00       	mov    $0xb,%eax
 26e:	cd 40                	int    $0x40
 270:	c3                   	ret    

00000271 <sbrk>:
SYSCALL(sbrk)
 271:	b8 0c 00 00 00       	mov    $0xc,%eax
 276:	cd 40                	int    $0x40
 278:	c3                   	ret    

00000279 <sleep>:
SYSCALL(sleep)
 279:	b8 0d 00 00 00       	mov    $0xd,%eax
 27e:	cd 40                	int    $0x40
 280:	c3                   	ret    

00000281 <uptime>:
SYSCALL(uptime)
 281:	b8 0e 00 00 00       	mov    $0xe,%eax
 286:	cd 40                	int    $0x40
 288:	c3                   	ret    

00000289 <mencrypt>:
SYSCALL(mencrypt)
 289:	b8 16 00 00 00       	mov    $0x16,%eax
 28e:	cd 40                	int    $0x40
 290:	c3                   	ret    

00000291 <getpgtable>:
SYSCALL(getpgtable)
 291:	b8 17 00 00 00       	mov    $0x17,%eax
 296:	cd 40                	int    $0x40
 298:	c3                   	ret    

00000299 <dump_rawphymem>:
SYSCALL(dump_rawphymem)
 299:	b8 18 00 00 00       	mov    $0x18,%eax
 29e:	cd 40                	int    $0x40
 2a0:	c3                   	ret    

000002a1 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2a1:	55                   	push   %ebp
 2a2:	89 e5                	mov    %esp,%ebp
 2a4:	83 ec 1c             	sub    $0x1c,%esp
 2a7:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2aa:	6a 01                	push   $0x1
 2ac:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2af:	52                   	push   %edx
 2b0:	50                   	push   %eax
 2b1:	e8 53 ff ff ff       	call   209 <write>
}
 2b6:	83 c4 10             	add    $0x10,%esp
 2b9:	c9                   	leave  
 2ba:	c3                   	ret    

000002bb <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2bb:	55                   	push   %ebp
 2bc:	89 e5                	mov    %esp,%ebp
 2be:	57                   	push   %edi
 2bf:	56                   	push   %esi
 2c0:	53                   	push   %ebx
 2c1:	83 ec 2c             	sub    $0x2c,%esp
 2c4:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2c6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2ca:	0f 95 c3             	setne  %bl
 2cd:	89 d0                	mov    %edx,%eax
 2cf:	c1 e8 1f             	shr    $0x1f,%eax
 2d2:	84 c3                	test   %al,%bl
 2d4:	74 10                	je     2e6 <printint+0x2b>
    neg = 1;
    x = -xx;
 2d6:	f7 da                	neg    %edx
    neg = 1;
 2d8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2df:	be 00 00 00 00       	mov    $0x0,%esi
 2e4:	eb 0b                	jmp    2f1 <printint+0x36>
  neg = 0;
 2e6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2ed:	eb f0                	jmp    2df <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2ef:	89 c6                	mov    %eax,%esi
 2f1:	89 d0                	mov    %edx,%eax
 2f3:	ba 00 00 00 00       	mov    $0x0,%edx
 2f8:	f7 f1                	div    %ecx
 2fa:	89 c3                	mov    %eax,%ebx
 2fc:	8d 46 01             	lea    0x1(%esi),%eax
 2ff:	0f b6 92 24 06 00 00 	movzbl 0x624(%edx),%edx
 306:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 30a:	89 da                	mov    %ebx,%edx
 30c:	85 db                	test   %ebx,%ebx
 30e:	75 df                	jne    2ef <printint+0x34>
 310:	89 c3                	mov    %eax,%ebx
  if(neg)
 312:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 316:	74 16                	je     32e <printint+0x73>
    buf[i++] = '-';
 318:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 31d:	8d 5e 02             	lea    0x2(%esi),%ebx
 320:	eb 0c                	jmp    32e <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 322:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 327:	89 f8                	mov    %edi,%eax
 329:	e8 73 ff ff ff       	call   2a1 <putc>
  while(--i >= 0)
 32e:	83 eb 01             	sub    $0x1,%ebx
 331:	79 ef                	jns    322 <printint+0x67>
}
 333:	83 c4 2c             	add    $0x2c,%esp
 336:	5b                   	pop    %ebx
 337:	5e                   	pop    %esi
 338:	5f                   	pop    %edi
 339:	5d                   	pop    %ebp
 33a:	c3                   	ret    

0000033b <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 33b:	55                   	push   %ebp
 33c:	89 e5                	mov    %esp,%ebp
 33e:	57                   	push   %edi
 33f:	56                   	push   %esi
 340:	53                   	push   %ebx
 341:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 344:	8d 45 10             	lea    0x10(%ebp),%eax
 347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 34a:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 34f:	bb 00 00 00 00       	mov    $0x0,%ebx
 354:	eb 14                	jmp    36a <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 356:	89 fa                	mov    %edi,%edx
 358:	8b 45 08             	mov    0x8(%ebp),%eax
 35b:	e8 41 ff ff ff       	call   2a1 <putc>
 360:	eb 05                	jmp    367 <printf+0x2c>
      }
    } else if(state == '%'){
 362:	83 fe 25             	cmp    $0x25,%esi
 365:	74 25                	je     38c <printf+0x51>
  for(i = 0; fmt[i]; i++){
 367:	83 c3 01             	add    $0x1,%ebx
 36a:	8b 45 0c             	mov    0xc(%ebp),%eax
 36d:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 371:	84 c0                	test   %al,%al
 373:	0f 84 23 01 00 00    	je     49c <printf+0x161>
    c = fmt[i] & 0xff;
 379:	0f be f8             	movsbl %al,%edi
 37c:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 37f:	85 f6                	test   %esi,%esi
 381:	75 df                	jne    362 <printf+0x27>
      if(c == '%'){
 383:	83 f8 25             	cmp    $0x25,%eax
 386:	75 ce                	jne    356 <printf+0x1b>
        state = '%';
 388:	89 c6                	mov    %eax,%esi
 38a:	eb db                	jmp    367 <printf+0x2c>
      if(c == 'd'){
 38c:	83 f8 64             	cmp    $0x64,%eax
 38f:	74 49                	je     3da <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 391:	83 f8 78             	cmp    $0x78,%eax
 394:	0f 94 c1             	sete   %cl
 397:	83 f8 70             	cmp    $0x70,%eax
 39a:	0f 94 c2             	sete   %dl
 39d:	08 d1                	or     %dl,%cl
 39f:	75 63                	jne    404 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3a1:	83 f8 73             	cmp    $0x73,%eax
 3a4:	0f 84 84 00 00 00    	je     42e <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3aa:	83 f8 63             	cmp    $0x63,%eax
 3ad:	0f 84 b7 00 00 00    	je     46a <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3b3:	83 f8 25             	cmp    $0x25,%eax
 3b6:	0f 84 cc 00 00 00    	je     488 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3bc:	ba 25 00 00 00       	mov    $0x25,%edx
 3c1:	8b 45 08             	mov    0x8(%ebp),%eax
 3c4:	e8 d8 fe ff ff       	call   2a1 <putc>
        putc(fd, c);
 3c9:	89 fa                	mov    %edi,%edx
 3cb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ce:	e8 ce fe ff ff       	call   2a1 <putc>
      }
      state = 0;
 3d3:	be 00 00 00 00       	mov    $0x0,%esi
 3d8:	eb 8d                	jmp    367 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3dd:	8b 17                	mov    (%edi),%edx
 3df:	83 ec 0c             	sub    $0xc,%esp
 3e2:	6a 01                	push   $0x1
 3e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3e9:	8b 45 08             	mov    0x8(%ebp),%eax
 3ec:	e8 ca fe ff ff       	call   2bb <printint>
        ap++;
 3f1:	83 c7 04             	add    $0x4,%edi
 3f4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3f7:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3fa:	be 00 00 00 00       	mov    $0x0,%esi
 3ff:	e9 63 ff ff ff       	jmp    367 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 407:	8b 17                	mov    (%edi),%edx
 409:	83 ec 0c             	sub    $0xc,%esp
 40c:	6a 00                	push   $0x0
 40e:	b9 10 00 00 00       	mov    $0x10,%ecx
 413:	8b 45 08             	mov    0x8(%ebp),%eax
 416:	e8 a0 fe ff ff       	call   2bb <printint>
        ap++;
 41b:	83 c7 04             	add    $0x4,%edi
 41e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 421:	83 c4 10             	add    $0x10,%esp
      state = 0;
 424:	be 00 00 00 00       	mov    $0x0,%esi
 429:	e9 39 ff ff ff       	jmp    367 <printf+0x2c>
        s = (char*)*ap;
 42e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 431:	8b 30                	mov    (%eax),%esi
        ap++;
 433:	83 c0 04             	add    $0x4,%eax
 436:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 439:	85 f6                	test   %esi,%esi
 43b:	75 28                	jne    465 <printf+0x12a>
          s = "(null)";
 43d:	be 1b 06 00 00       	mov    $0x61b,%esi
 442:	8b 7d 08             	mov    0x8(%ebp),%edi
 445:	eb 0d                	jmp    454 <printf+0x119>
          putc(fd, *s);
 447:	0f be d2             	movsbl %dl,%edx
 44a:	89 f8                	mov    %edi,%eax
 44c:	e8 50 fe ff ff       	call   2a1 <putc>
          s++;
 451:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 454:	0f b6 16             	movzbl (%esi),%edx
 457:	84 d2                	test   %dl,%dl
 459:	75 ec                	jne    447 <printf+0x10c>
      state = 0;
 45b:	be 00 00 00 00       	mov    $0x0,%esi
 460:	e9 02 ff ff ff       	jmp    367 <printf+0x2c>
 465:	8b 7d 08             	mov    0x8(%ebp),%edi
 468:	eb ea                	jmp    454 <printf+0x119>
        putc(fd, *ap);
 46a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 46d:	0f be 17             	movsbl (%edi),%edx
 470:	8b 45 08             	mov    0x8(%ebp),%eax
 473:	e8 29 fe ff ff       	call   2a1 <putc>
        ap++;
 478:	83 c7 04             	add    $0x4,%edi
 47b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 47e:	be 00 00 00 00       	mov    $0x0,%esi
 483:	e9 df fe ff ff       	jmp    367 <printf+0x2c>
        putc(fd, c);
 488:	89 fa                	mov    %edi,%edx
 48a:	8b 45 08             	mov    0x8(%ebp),%eax
 48d:	e8 0f fe ff ff       	call   2a1 <putc>
      state = 0;
 492:	be 00 00 00 00       	mov    $0x0,%esi
 497:	e9 cb fe ff ff       	jmp    367 <printf+0x2c>
    }
  }
}
 49c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 49f:	5b                   	pop    %ebx
 4a0:	5e                   	pop    %esi
 4a1:	5f                   	pop    %edi
 4a2:	5d                   	pop    %ebp
 4a3:	c3                   	ret    

000004a4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4a4:	55                   	push   %ebp
 4a5:	89 e5                	mov    %esp,%ebp
 4a7:	57                   	push   %edi
 4a8:	56                   	push   %esi
 4a9:	53                   	push   %ebx
 4aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4ad:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4b0:	a1 c0 08 00 00       	mov    0x8c0,%eax
 4b5:	eb 02                	jmp    4b9 <free+0x15>
 4b7:	89 d0                	mov    %edx,%eax
 4b9:	39 c8                	cmp    %ecx,%eax
 4bb:	73 04                	jae    4c1 <free+0x1d>
 4bd:	39 08                	cmp    %ecx,(%eax)
 4bf:	77 12                	ja     4d3 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4c1:	8b 10                	mov    (%eax),%edx
 4c3:	39 c2                	cmp    %eax,%edx
 4c5:	77 f0                	ja     4b7 <free+0x13>
 4c7:	39 c8                	cmp    %ecx,%eax
 4c9:	72 08                	jb     4d3 <free+0x2f>
 4cb:	39 ca                	cmp    %ecx,%edx
 4cd:	77 04                	ja     4d3 <free+0x2f>
 4cf:	89 d0                	mov    %edx,%eax
 4d1:	eb e6                	jmp    4b9 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4d3:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4d6:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4d9:	8b 10                	mov    (%eax),%edx
 4db:	39 d7                	cmp    %edx,%edi
 4dd:	74 19                	je     4f8 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4df:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4e2:	8b 50 04             	mov    0x4(%eax),%edx
 4e5:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4e8:	39 ce                	cmp    %ecx,%esi
 4ea:	74 1b                	je     507 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4ec:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4ee:	a3 c0 08 00 00       	mov    %eax,0x8c0
}
 4f3:	5b                   	pop    %ebx
 4f4:	5e                   	pop    %esi
 4f5:	5f                   	pop    %edi
 4f6:	5d                   	pop    %ebp
 4f7:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4f8:	03 72 04             	add    0x4(%edx),%esi
 4fb:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4fe:	8b 10                	mov    (%eax),%edx
 500:	8b 12                	mov    (%edx),%edx
 502:	89 53 f8             	mov    %edx,-0x8(%ebx)
 505:	eb db                	jmp    4e2 <free+0x3e>
    p->s.size += bp->s.size;
 507:	03 53 fc             	add    -0x4(%ebx),%edx
 50a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 50d:	8b 53 f8             	mov    -0x8(%ebx),%edx
 510:	89 10                	mov    %edx,(%eax)
 512:	eb da                	jmp    4ee <free+0x4a>

00000514 <morecore>:

static Header*
morecore(uint nu)
{
 514:	55                   	push   %ebp
 515:	89 e5                	mov    %esp,%ebp
 517:	53                   	push   %ebx
 518:	83 ec 04             	sub    $0x4,%esp
 51b:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 51d:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 522:	77 05                	ja     529 <morecore+0x15>
    nu = 4096;
 524:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 529:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 530:	83 ec 0c             	sub    $0xc,%esp
 533:	50                   	push   %eax
 534:	e8 38 fd ff ff       	call   271 <sbrk>
  if(p == (char*)-1)
 539:	83 c4 10             	add    $0x10,%esp
 53c:	83 f8 ff             	cmp    $0xffffffff,%eax
 53f:	74 1c                	je     55d <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 541:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 544:	83 c0 08             	add    $0x8,%eax
 547:	83 ec 0c             	sub    $0xc,%esp
 54a:	50                   	push   %eax
 54b:	e8 54 ff ff ff       	call   4a4 <free>
  return freep;
 550:	a1 c0 08 00 00       	mov    0x8c0,%eax
 555:	83 c4 10             	add    $0x10,%esp
}
 558:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 55b:	c9                   	leave  
 55c:	c3                   	ret    
    return 0;
 55d:	b8 00 00 00 00       	mov    $0x0,%eax
 562:	eb f4                	jmp    558 <morecore+0x44>

00000564 <malloc>:

void*
malloc(uint nbytes)
{
 564:	55                   	push   %ebp
 565:	89 e5                	mov    %esp,%ebp
 567:	53                   	push   %ebx
 568:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 56b:	8b 45 08             	mov    0x8(%ebp),%eax
 56e:	8d 58 07             	lea    0x7(%eax),%ebx
 571:	c1 eb 03             	shr    $0x3,%ebx
 574:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 577:	8b 0d c0 08 00 00    	mov    0x8c0,%ecx
 57d:	85 c9                	test   %ecx,%ecx
 57f:	74 04                	je     585 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 581:	8b 01                	mov    (%ecx),%eax
 583:	eb 4d                	jmp    5d2 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 585:	c7 05 c0 08 00 00 c4 	movl   $0x8c4,0x8c0
 58c:	08 00 00 
 58f:	c7 05 c4 08 00 00 c4 	movl   $0x8c4,0x8c4
 596:	08 00 00 
    base.s.size = 0;
 599:	c7 05 c8 08 00 00 00 	movl   $0x0,0x8c8
 5a0:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5a3:	b9 c4 08 00 00       	mov    $0x8c4,%ecx
 5a8:	eb d7                	jmp    581 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5aa:	39 da                	cmp    %ebx,%edx
 5ac:	74 1a                	je     5c8 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5ae:	29 da                	sub    %ebx,%edx
 5b0:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5b3:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5b6:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5b9:	89 0d c0 08 00 00    	mov    %ecx,0x8c0
      return (void*)(p + 1);
 5bf:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5c2:	83 c4 04             	add    $0x4,%esp
 5c5:	5b                   	pop    %ebx
 5c6:	5d                   	pop    %ebp
 5c7:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5c8:	8b 10                	mov    (%eax),%edx
 5ca:	89 11                	mov    %edx,(%ecx)
 5cc:	eb eb                	jmp    5b9 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5ce:	89 c1                	mov    %eax,%ecx
 5d0:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5d2:	8b 50 04             	mov    0x4(%eax),%edx
 5d5:	39 da                	cmp    %ebx,%edx
 5d7:	73 d1                	jae    5aa <malloc+0x46>
    if(p == freep)
 5d9:	39 05 c0 08 00 00    	cmp    %eax,0x8c0
 5df:	75 ed                	jne    5ce <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5e1:	89 d8                	mov    %ebx,%eax
 5e3:	e8 2c ff ff ff       	call   514 <morecore>
 5e8:	85 c0                	test   %eax,%eax
 5ea:	75 e2                	jne    5ce <malloc+0x6a>
        return 0;
 5ec:	b8 00 00 00 00       	mov    $0x0,%eax
 5f1:	eb cf                	jmp    5c2 <malloc+0x5e>
