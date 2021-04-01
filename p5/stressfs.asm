
_stressfs:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	56                   	push   %esi
   e:	53                   	push   %ebx
   f:	51                   	push   %ecx
  10:	81 ec 24 02 00 00    	sub    $0x224,%esp
  int fd, i;
  char path[] = "stressfs0";
  16:	c7 45 de 73 74 72 65 	movl   $0x65727473,-0x22(%ebp)
  1d:	c7 45 e2 73 73 66 73 	movl   $0x73667373,-0x1e(%ebp)
  24:	66 c7 45 e6 30 00    	movw   $0x30,-0x1a(%ebp)
  char data[512];

  printf(1, "stressfs starting\n");
  2a:	68 b4 06 00 00       	push   $0x6b4
  2f:	6a 01                	push   $0x1
  31:	e8 c5 03 00 00       	call   3fb <printf>
  memset(data, 'a', sizeof(data));
  36:	83 c4 0c             	add    $0xc,%esp
  39:	68 00 02 00 00       	push   $0x200
  3e:	6a 61                	push   $0x61
  40:	8d 85 de fd ff ff    	lea    -0x222(%ebp),%eax
  46:	50                   	push   %eax
  47:	e8 2e 01 00 00       	call   17a <memset>

  for(i = 0; i < 4; i++)
  4c:	83 c4 10             	add    $0x10,%esp
  4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  54:	83 fb 03             	cmp    $0x3,%ebx
  57:	7f 0e                	jg     67 <main+0x67>
    if(fork() > 0)
  59:	e8 43 02 00 00       	call   2a1 <fork>
  5e:	85 c0                	test   %eax,%eax
  60:	7f 05                	jg     67 <main+0x67>
  for(i = 0; i < 4; i++)
  62:	83 c3 01             	add    $0x1,%ebx
  65:	eb ed                	jmp    54 <main+0x54>
      break;

  printf(1, "write %d\n", i);
  67:	83 ec 04             	sub    $0x4,%esp
  6a:	53                   	push   %ebx
  6b:	68 c7 06 00 00       	push   $0x6c7
  70:	6a 01                	push   $0x1
  72:	e8 84 03 00 00       	call   3fb <printf>

  path[8] += i;
  77:	00 5d e6             	add    %bl,-0x1a(%ebp)
  fd = open(path, O_CREATE | O_RDWR);
  7a:	83 c4 08             	add    $0x8,%esp
  7d:	68 02 02 00 00       	push   $0x202
  82:	8d 45 de             	lea    -0x22(%ebp),%eax
  85:	50                   	push   %eax
  86:	e8 5e 02 00 00       	call   2e9 <open>
  8b:	89 c6                	mov    %eax,%esi
  for(i = 0; i < 20; i++)
  8d:	83 c4 10             	add    $0x10,%esp
  90:	bb 00 00 00 00       	mov    $0x0,%ebx
  95:	eb 1b                	jmp    b2 <main+0xb2>
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  97:	83 ec 04             	sub    $0x4,%esp
  9a:	68 00 02 00 00       	push   $0x200
  9f:	8d 85 de fd ff ff    	lea    -0x222(%ebp),%eax
  a5:	50                   	push   %eax
  a6:	56                   	push   %esi
  a7:	e8 1d 02 00 00       	call   2c9 <write>
  for(i = 0; i < 20; i++)
  ac:	83 c3 01             	add    $0x1,%ebx
  af:	83 c4 10             	add    $0x10,%esp
  b2:	83 fb 13             	cmp    $0x13,%ebx
  b5:	7e e0                	jle    97 <main+0x97>
  close(fd);
  b7:	83 ec 0c             	sub    $0xc,%esp
  ba:	56                   	push   %esi
  bb:	e8 11 02 00 00       	call   2d1 <close>

  printf(1, "read\n");
  c0:	83 c4 08             	add    $0x8,%esp
  c3:	68 d1 06 00 00       	push   $0x6d1
  c8:	6a 01                	push   $0x1
  ca:	e8 2c 03 00 00       	call   3fb <printf>

  fd = open(path, O_RDONLY);
  cf:	83 c4 08             	add    $0x8,%esp
  d2:	6a 00                	push   $0x0
  d4:	8d 45 de             	lea    -0x22(%ebp),%eax
  d7:	50                   	push   %eax
  d8:	e8 0c 02 00 00       	call   2e9 <open>
  dd:	89 c6                	mov    %eax,%esi
  for (i = 0; i < 20; i++)
  df:	83 c4 10             	add    $0x10,%esp
  e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  e7:	eb 1b                	jmp    104 <main+0x104>
    read(fd, data, sizeof(data));
  e9:	83 ec 04             	sub    $0x4,%esp
  ec:	68 00 02 00 00       	push   $0x200
  f1:	8d 85 de fd ff ff    	lea    -0x222(%ebp),%eax
  f7:	50                   	push   %eax
  f8:	56                   	push   %esi
  f9:	e8 c3 01 00 00       	call   2c1 <read>
  for (i = 0; i < 20; i++)
  fe:	83 c3 01             	add    $0x1,%ebx
 101:	83 c4 10             	add    $0x10,%esp
 104:	83 fb 13             	cmp    $0x13,%ebx
 107:	7e e0                	jle    e9 <main+0xe9>
  close(fd);
 109:	83 ec 0c             	sub    $0xc,%esp
 10c:	56                   	push   %esi
 10d:	e8 bf 01 00 00       	call   2d1 <close>

  wait();
 112:	e8 9a 01 00 00       	call   2b1 <wait>

  exit();
 117:	e8 8d 01 00 00       	call   2a9 <exit>

0000011c <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 11c:	55                   	push   %ebp
 11d:	89 e5                	mov    %esp,%ebp
 11f:	53                   	push   %ebx
 120:	8b 45 08             	mov    0x8(%ebp),%eax
 123:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 126:	89 c2                	mov    %eax,%edx
 128:	0f b6 19             	movzbl (%ecx),%ebx
 12b:	88 1a                	mov    %bl,(%edx)
 12d:	8d 52 01             	lea    0x1(%edx),%edx
 130:	8d 49 01             	lea    0x1(%ecx),%ecx
 133:	84 db                	test   %bl,%bl
 135:	75 f1                	jne    128 <strcpy+0xc>
    ;
  return os;
}
 137:	5b                   	pop    %ebx
 138:	5d                   	pop    %ebp
 139:	c3                   	ret    

0000013a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 13a:	55                   	push   %ebp
 13b:	89 e5                	mov    %esp,%ebp
 13d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 140:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 143:	eb 06                	jmp    14b <strcmp+0x11>
    p++, q++;
 145:	83 c1 01             	add    $0x1,%ecx
 148:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 14b:	0f b6 01             	movzbl (%ecx),%eax
 14e:	84 c0                	test   %al,%al
 150:	74 04                	je     156 <strcmp+0x1c>
 152:	3a 02                	cmp    (%edx),%al
 154:	74 ef                	je     145 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 156:	0f b6 c0             	movzbl %al,%eax
 159:	0f b6 12             	movzbl (%edx),%edx
 15c:	29 d0                	sub    %edx,%eax
}
 15e:	5d                   	pop    %ebp
 15f:	c3                   	ret    

00000160 <strlen>:

uint
strlen(const char *s)
{
 160:	55                   	push   %ebp
 161:	89 e5                	mov    %esp,%ebp
 163:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 166:	ba 00 00 00 00       	mov    $0x0,%edx
 16b:	eb 03                	jmp    170 <strlen+0x10>
 16d:	83 c2 01             	add    $0x1,%edx
 170:	89 d0                	mov    %edx,%eax
 172:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 176:	75 f5                	jne    16d <strlen+0xd>
    ;
  return n;
}
 178:	5d                   	pop    %ebp
 179:	c3                   	ret    

0000017a <memset>:

void*
memset(void *dst, int c, uint n)
{
 17a:	55                   	push   %ebp
 17b:	89 e5                	mov    %esp,%ebp
 17d:	57                   	push   %edi
 17e:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 181:	89 d7                	mov    %edx,%edi
 183:	8b 4d 10             	mov    0x10(%ebp),%ecx
 186:	8b 45 0c             	mov    0xc(%ebp),%eax
 189:	fc                   	cld    
 18a:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 18c:	89 d0                	mov    %edx,%eax
 18e:	5f                   	pop    %edi
 18f:	5d                   	pop    %ebp
 190:	c3                   	ret    

00000191 <strchr>:

char*
strchr(const char *s, char c)
{
 191:	55                   	push   %ebp
 192:	89 e5                	mov    %esp,%ebp
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 19b:	0f b6 10             	movzbl (%eax),%edx
 19e:	84 d2                	test   %dl,%dl
 1a0:	74 09                	je     1ab <strchr+0x1a>
    if(*s == c)
 1a2:	38 ca                	cmp    %cl,%dl
 1a4:	74 0a                	je     1b0 <strchr+0x1f>
  for(; *s; s++)
 1a6:	83 c0 01             	add    $0x1,%eax
 1a9:	eb f0                	jmp    19b <strchr+0xa>
      return (char*)s;
  return 0;
 1ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1b0:	5d                   	pop    %ebp
 1b1:	c3                   	ret    

000001b2 <gets>:

char*
gets(char *buf, int max)
{
 1b2:	55                   	push   %ebp
 1b3:	89 e5                	mov    %esp,%ebp
 1b5:	57                   	push   %edi
 1b6:	56                   	push   %esi
 1b7:	53                   	push   %ebx
 1b8:	83 ec 1c             	sub    $0x1c,%esp
 1bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1be:	bb 00 00 00 00       	mov    $0x0,%ebx
 1c3:	8d 73 01             	lea    0x1(%ebx),%esi
 1c6:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1c9:	7d 2e                	jge    1f9 <gets+0x47>
    cc = read(0, &c, 1);
 1cb:	83 ec 04             	sub    $0x4,%esp
 1ce:	6a 01                	push   $0x1
 1d0:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1d3:	50                   	push   %eax
 1d4:	6a 00                	push   $0x0
 1d6:	e8 e6 00 00 00       	call   2c1 <read>
    if(cc < 1)
 1db:	83 c4 10             	add    $0x10,%esp
 1de:	85 c0                	test   %eax,%eax
 1e0:	7e 17                	jle    1f9 <gets+0x47>
      break;
    buf[i++] = c;
 1e2:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1e6:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1e9:	3c 0a                	cmp    $0xa,%al
 1eb:	0f 94 c2             	sete   %dl
 1ee:	3c 0d                	cmp    $0xd,%al
 1f0:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1f3:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1f5:	08 c2                	or     %al,%dl
 1f7:	74 ca                	je     1c3 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1f9:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1fd:	89 f8                	mov    %edi,%eax
 1ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
 202:	5b                   	pop    %ebx
 203:	5e                   	pop    %esi
 204:	5f                   	pop    %edi
 205:	5d                   	pop    %ebp
 206:	c3                   	ret    

00000207 <stat>:

int
stat(const char *n, struct stat *st)
{
 207:	55                   	push   %ebp
 208:	89 e5                	mov    %esp,%ebp
 20a:	56                   	push   %esi
 20b:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20c:	83 ec 08             	sub    $0x8,%esp
 20f:	6a 00                	push   $0x0
 211:	ff 75 08             	pushl  0x8(%ebp)
 214:	e8 d0 00 00 00       	call   2e9 <open>
  if(fd < 0)
 219:	83 c4 10             	add    $0x10,%esp
 21c:	85 c0                	test   %eax,%eax
 21e:	78 24                	js     244 <stat+0x3d>
 220:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 222:	83 ec 08             	sub    $0x8,%esp
 225:	ff 75 0c             	pushl  0xc(%ebp)
 228:	50                   	push   %eax
 229:	e8 d3 00 00 00       	call   301 <fstat>
 22e:	89 c6                	mov    %eax,%esi
  close(fd);
 230:	89 1c 24             	mov    %ebx,(%esp)
 233:	e8 99 00 00 00       	call   2d1 <close>
  return r;
 238:	83 c4 10             	add    $0x10,%esp
}
 23b:	89 f0                	mov    %esi,%eax
 23d:	8d 65 f8             	lea    -0x8(%ebp),%esp
 240:	5b                   	pop    %ebx
 241:	5e                   	pop    %esi
 242:	5d                   	pop    %ebp
 243:	c3                   	ret    
    return -1;
 244:	be ff ff ff ff       	mov    $0xffffffff,%esi
 249:	eb f0                	jmp    23b <stat+0x34>

0000024b <atoi>:

int
atoi(const char *s)
{
 24b:	55                   	push   %ebp
 24c:	89 e5                	mov    %esp,%ebp
 24e:	53                   	push   %ebx
 24f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 252:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 257:	eb 10                	jmp    269 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 259:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 25c:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 25f:	83 c1 01             	add    $0x1,%ecx
 262:	0f be d2             	movsbl %dl,%edx
 265:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 269:	0f b6 11             	movzbl (%ecx),%edx
 26c:	8d 5a d0             	lea    -0x30(%edx),%ebx
 26f:	80 fb 09             	cmp    $0x9,%bl
 272:	76 e5                	jbe    259 <atoi+0xe>
  return n;
}
 274:	5b                   	pop    %ebx
 275:	5d                   	pop    %ebp
 276:	c3                   	ret    

00000277 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 277:	55                   	push   %ebp
 278:	89 e5                	mov    %esp,%ebp
 27a:	56                   	push   %esi
 27b:	53                   	push   %ebx
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 282:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 285:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 287:	eb 0d                	jmp    296 <memmove+0x1f>
    *dst++ = *src++;
 289:	0f b6 13             	movzbl (%ebx),%edx
 28c:	88 11                	mov    %dl,(%ecx)
 28e:	8d 5b 01             	lea    0x1(%ebx),%ebx
 291:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 294:	89 f2                	mov    %esi,%edx
 296:	8d 72 ff             	lea    -0x1(%edx),%esi
 299:	85 d2                	test   %edx,%edx
 29b:	7f ec                	jg     289 <memmove+0x12>
  return vdst;
}
 29d:	5b                   	pop    %ebx
 29e:	5e                   	pop    %esi
 29f:	5d                   	pop    %ebp
 2a0:	c3                   	ret    

000002a1 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2a1:	b8 01 00 00 00       	mov    $0x1,%eax
 2a6:	cd 40                	int    $0x40
 2a8:	c3                   	ret    

000002a9 <exit>:
SYSCALL(exit)
 2a9:	b8 02 00 00 00       	mov    $0x2,%eax
 2ae:	cd 40                	int    $0x40
 2b0:	c3                   	ret    

000002b1 <wait>:
SYSCALL(wait)
 2b1:	b8 03 00 00 00       	mov    $0x3,%eax
 2b6:	cd 40                	int    $0x40
 2b8:	c3                   	ret    

000002b9 <pipe>:
SYSCALL(pipe)
 2b9:	b8 04 00 00 00       	mov    $0x4,%eax
 2be:	cd 40                	int    $0x40
 2c0:	c3                   	ret    

000002c1 <read>:
SYSCALL(read)
 2c1:	b8 05 00 00 00       	mov    $0x5,%eax
 2c6:	cd 40                	int    $0x40
 2c8:	c3                   	ret    

000002c9 <write>:
SYSCALL(write)
 2c9:	b8 10 00 00 00       	mov    $0x10,%eax
 2ce:	cd 40                	int    $0x40
 2d0:	c3                   	ret    

000002d1 <close>:
SYSCALL(close)
 2d1:	b8 15 00 00 00       	mov    $0x15,%eax
 2d6:	cd 40                	int    $0x40
 2d8:	c3                   	ret    

000002d9 <kill>:
SYSCALL(kill)
 2d9:	b8 06 00 00 00       	mov    $0x6,%eax
 2de:	cd 40                	int    $0x40
 2e0:	c3                   	ret    

000002e1 <exec>:
SYSCALL(exec)
 2e1:	b8 07 00 00 00       	mov    $0x7,%eax
 2e6:	cd 40                	int    $0x40
 2e8:	c3                   	ret    

000002e9 <open>:
SYSCALL(open)
 2e9:	b8 0f 00 00 00       	mov    $0xf,%eax
 2ee:	cd 40                	int    $0x40
 2f0:	c3                   	ret    

000002f1 <mknod>:
SYSCALL(mknod)
 2f1:	b8 11 00 00 00       	mov    $0x11,%eax
 2f6:	cd 40                	int    $0x40
 2f8:	c3                   	ret    

000002f9 <unlink>:
SYSCALL(unlink)
 2f9:	b8 12 00 00 00       	mov    $0x12,%eax
 2fe:	cd 40                	int    $0x40
 300:	c3                   	ret    

00000301 <fstat>:
SYSCALL(fstat)
 301:	b8 08 00 00 00       	mov    $0x8,%eax
 306:	cd 40                	int    $0x40
 308:	c3                   	ret    

00000309 <link>:
SYSCALL(link)
 309:	b8 13 00 00 00       	mov    $0x13,%eax
 30e:	cd 40                	int    $0x40
 310:	c3                   	ret    

00000311 <mkdir>:
SYSCALL(mkdir)
 311:	b8 14 00 00 00       	mov    $0x14,%eax
 316:	cd 40                	int    $0x40
 318:	c3                   	ret    

00000319 <chdir>:
SYSCALL(chdir)
 319:	b8 09 00 00 00       	mov    $0x9,%eax
 31e:	cd 40                	int    $0x40
 320:	c3                   	ret    

00000321 <dup>:
SYSCALL(dup)
 321:	b8 0a 00 00 00       	mov    $0xa,%eax
 326:	cd 40                	int    $0x40
 328:	c3                   	ret    

00000329 <getpid>:
SYSCALL(getpid)
 329:	b8 0b 00 00 00       	mov    $0xb,%eax
 32e:	cd 40                	int    $0x40
 330:	c3                   	ret    

00000331 <sbrk>:
SYSCALL(sbrk)
 331:	b8 0c 00 00 00       	mov    $0xc,%eax
 336:	cd 40                	int    $0x40
 338:	c3                   	ret    

00000339 <sleep>:
SYSCALL(sleep)
 339:	b8 0d 00 00 00       	mov    $0xd,%eax
 33e:	cd 40                	int    $0x40
 340:	c3                   	ret    

00000341 <uptime>:
SYSCALL(uptime)
 341:	b8 0e 00 00 00       	mov    $0xe,%eax
 346:	cd 40                	int    $0x40
 348:	c3                   	ret    

00000349 <mencrypt>:
SYSCALL(mencrypt)
 349:	b8 16 00 00 00       	mov    $0x16,%eax
 34e:	cd 40                	int    $0x40
 350:	c3                   	ret    

00000351 <getpgtable>:
SYSCALL(getpgtable)
 351:	b8 17 00 00 00       	mov    $0x17,%eax
 356:	cd 40                	int    $0x40
 358:	c3                   	ret    

00000359 <dump_rawphymem>:
SYSCALL(dump_rawphymem)
 359:	b8 18 00 00 00       	mov    $0x18,%eax
 35e:	cd 40                	int    $0x40
 360:	c3                   	ret    

00000361 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 361:	55                   	push   %ebp
 362:	89 e5                	mov    %esp,%ebp
 364:	83 ec 1c             	sub    $0x1c,%esp
 367:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 36a:	6a 01                	push   $0x1
 36c:	8d 55 f4             	lea    -0xc(%ebp),%edx
 36f:	52                   	push   %edx
 370:	50                   	push   %eax
 371:	e8 53 ff ff ff       	call   2c9 <write>
}
 376:	83 c4 10             	add    $0x10,%esp
 379:	c9                   	leave  
 37a:	c3                   	ret    

0000037b <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 37b:	55                   	push   %ebp
 37c:	89 e5                	mov    %esp,%ebp
 37e:	57                   	push   %edi
 37f:	56                   	push   %esi
 380:	53                   	push   %ebx
 381:	83 ec 2c             	sub    $0x2c,%esp
 384:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 386:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 38a:	0f 95 c3             	setne  %bl
 38d:	89 d0                	mov    %edx,%eax
 38f:	c1 e8 1f             	shr    $0x1f,%eax
 392:	84 c3                	test   %al,%bl
 394:	74 10                	je     3a6 <printint+0x2b>
    neg = 1;
    x = -xx;
 396:	f7 da                	neg    %edx
    neg = 1;
 398:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 39f:	be 00 00 00 00       	mov    $0x0,%esi
 3a4:	eb 0b                	jmp    3b1 <printint+0x36>
  neg = 0;
 3a6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 3ad:	eb f0                	jmp    39f <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 3af:	89 c6                	mov    %eax,%esi
 3b1:	89 d0                	mov    %edx,%eax
 3b3:	ba 00 00 00 00       	mov    $0x0,%edx
 3b8:	f7 f1                	div    %ecx
 3ba:	89 c3                	mov    %eax,%ebx
 3bc:	8d 46 01             	lea    0x1(%esi),%eax
 3bf:	0f b6 92 e0 06 00 00 	movzbl 0x6e0(%edx),%edx
 3c6:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3ca:	89 da                	mov    %ebx,%edx
 3cc:	85 db                	test   %ebx,%ebx
 3ce:	75 df                	jne    3af <printint+0x34>
 3d0:	89 c3                	mov    %eax,%ebx
  if(neg)
 3d2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3d6:	74 16                	je     3ee <printint+0x73>
    buf[i++] = '-';
 3d8:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 3dd:	8d 5e 02             	lea    0x2(%esi),%ebx
 3e0:	eb 0c                	jmp    3ee <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 3e2:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3e7:	89 f8                	mov    %edi,%eax
 3e9:	e8 73 ff ff ff       	call   361 <putc>
  while(--i >= 0)
 3ee:	83 eb 01             	sub    $0x1,%ebx
 3f1:	79 ef                	jns    3e2 <printint+0x67>
}
 3f3:	83 c4 2c             	add    $0x2c,%esp
 3f6:	5b                   	pop    %ebx
 3f7:	5e                   	pop    %esi
 3f8:	5f                   	pop    %edi
 3f9:	5d                   	pop    %ebp
 3fa:	c3                   	ret    

000003fb <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3fb:	55                   	push   %ebp
 3fc:	89 e5                	mov    %esp,%ebp
 3fe:	57                   	push   %edi
 3ff:	56                   	push   %esi
 400:	53                   	push   %ebx
 401:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 404:	8d 45 10             	lea    0x10(%ebp),%eax
 407:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 40a:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 40f:	bb 00 00 00 00       	mov    $0x0,%ebx
 414:	eb 14                	jmp    42a <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 416:	89 fa                	mov    %edi,%edx
 418:	8b 45 08             	mov    0x8(%ebp),%eax
 41b:	e8 41 ff ff ff       	call   361 <putc>
 420:	eb 05                	jmp    427 <printf+0x2c>
      }
    } else if(state == '%'){
 422:	83 fe 25             	cmp    $0x25,%esi
 425:	74 25                	je     44c <printf+0x51>
  for(i = 0; fmt[i]; i++){
 427:	83 c3 01             	add    $0x1,%ebx
 42a:	8b 45 0c             	mov    0xc(%ebp),%eax
 42d:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 431:	84 c0                	test   %al,%al
 433:	0f 84 23 01 00 00    	je     55c <printf+0x161>
    c = fmt[i] & 0xff;
 439:	0f be f8             	movsbl %al,%edi
 43c:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 43f:	85 f6                	test   %esi,%esi
 441:	75 df                	jne    422 <printf+0x27>
      if(c == '%'){
 443:	83 f8 25             	cmp    $0x25,%eax
 446:	75 ce                	jne    416 <printf+0x1b>
        state = '%';
 448:	89 c6                	mov    %eax,%esi
 44a:	eb db                	jmp    427 <printf+0x2c>
      if(c == 'd'){
 44c:	83 f8 64             	cmp    $0x64,%eax
 44f:	74 49                	je     49a <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 451:	83 f8 78             	cmp    $0x78,%eax
 454:	0f 94 c1             	sete   %cl
 457:	83 f8 70             	cmp    $0x70,%eax
 45a:	0f 94 c2             	sete   %dl
 45d:	08 d1                	or     %dl,%cl
 45f:	75 63                	jne    4c4 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 461:	83 f8 73             	cmp    $0x73,%eax
 464:	0f 84 84 00 00 00    	je     4ee <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 46a:	83 f8 63             	cmp    $0x63,%eax
 46d:	0f 84 b7 00 00 00    	je     52a <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 473:	83 f8 25             	cmp    $0x25,%eax
 476:	0f 84 cc 00 00 00    	je     548 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 47c:	ba 25 00 00 00       	mov    $0x25,%edx
 481:	8b 45 08             	mov    0x8(%ebp),%eax
 484:	e8 d8 fe ff ff       	call   361 <putc>
        putc(fd, c);
 489:	89 fa                	mov    %edi,%edx
 48b:	8b 45 08             	mov    0x8(%ebp),%eax
 48e:	e8 ce fe ff ff       	call   361 <putc>
      }
      state = 0;
 493:	be 00 00 00 00       	mov    $0x0,%esi
 498:	eb 8d                	jmp    427 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 49a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 49d:	8b 17                	mov    (%edi),%edx
 49f:	83 ec 0c             	sub    $0xc,%esp
 4a2:	6a 01                	push   $0x1
 4a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4a9:	8b 45 08             	mov    0x8(%ebp),%eax
 4ac:	e8 ca fe ff ff       	call   37b <printint>
        ap++;
 4b1:	83 c7 04             	add    $0x4,%edi
 4b4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4b7:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4ba:	be 00 00 00 00       	mov    $0x0,%esi
 4bf:	e9 63 ff ff ff       	jmp    427 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4c7:	8b 17                	mov    (%edi),%edx
 4c9:	83 ec 0c             	sub    $0xc,%esp
 4cc:	6a 00                	push   $0x0
 4ce:	b9 10 00 00 00       	mov    $0x10,%ecx
 4d3:	8b 45 08             	mov    0x8(%ebp),%eax
 4d6:	e8 a0 fe ff ff       	call   37b <printint>
        ap++;
 4db:	83 c7 04             	add    $0x4,%edi
 4de:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4e1:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4e4:	be 00 00 00 00       	mov    $0x0,%esi
 4e9:	e9 39 ff ff ff       	jmp    427 <printf+0x2c>
        s = (char*)*ap;
 4ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4f1:	8b 30                	mov    (%eax),%esi
        ap++;
 4f3:	83 c0 04             	add    $0x4,%eax
 4f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4f9:	85 f6                	test   %esi,%esi
 4fb:	75 28                	jne    525 <printf+0x12a>
          s = "(null)";
 4fd:	be d7 06 00 00       	mov    $0x6d7,%esi
 502:	8b 7d 08             	mov    0x8(%ebp),%edi
 505:	eb 0d                	jmp    514 <printf+0x119>
          putc(fd, *s);
 507:	0f be d2             	movsbl %dl,%edx
 50a:	89 f8                	mov    %edi,%eax
 50c:	e8 50 fe ff ff       	call   361 <putc>
          s++;
 511:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 514:	0f b6 16             	movzbl (%esi),%edx
 517:	84 d2                	test   %dl,%dl
 519:	75 ec                	jne    507 <printf+0x10c>
      state = 0;
 51b:	be 00 00 00 00       	mov    $0x0,%esi
 520:	e9 02 ff ff ff       	jmp    427 <printf+0x2c>
 525:	8b 7d 08             	mov    0x8(%ebp),%edi
 528:	eb ea                	jmp    514 <printf+0x119>
        putc(fd, *ap);
 52a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 52d:	0f be 17             	movsbl (%edi),%edx
 530:	8b 45 08             	mov    0x8(%ebp),%eax
 533:	e8 29 fe ff ff       	call   361 <putc>
        ap++;
 538:	83 c7 04             	add    $0x4,%edi
 53b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 53e:	be 00 00 00 00       	mov    $0x0,%esi
 543:	e9 df fe ff ff       	jmp    427 <printf+0x2c>
        putc(fd, c);
 548:	89 fa                	mov    %edi,%edx
 54a:	8b 45 08             	mov    0x8(%ebp),%eax
 54d:	e8 0f fe ff ff       	call   361 <putc>
      state = 0;
 552:	be 00 00 00 00       	mov    $0x0,%esi
 557:	e9 cb fe ff ff       	jmp    427 <printf+0x2c>
    }
  }
}
 55c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 55f:	5b                   	pop    %ebx
 560:	5e                   	pop    %esi
 561:	5f                   	pop    %edi
 562:	5d                   	pop    %ebp
 563:	c3                   	ret    

00000564 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 564:	55                   	push   %ebp
 565:	89 e5                	mov    %esp,%ebp
 567:	57                   	push   %edi
 568:	56                   	push   %esi
 569:	53                   	push   %ebx
 56a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 56d:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 570:	a1 80 09 00 00       	mov    0x980,%eax
 575:	eb 02                	jmp    579 <free+0x15>
 577:	89 d0                	mov    %edx,%eax
 579:	39 c8                	cmp    %ecx,%eax
 57b:	73 04                	jae    581 <free+0x1d>
 57d:	39 08                	cmp    %ecx,(%eax)
 57f:	77 12                	ja     593 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 581:	8b 10                	mov    (%eax),%edx
 583:	39 c2                	cmp    %eax,%edx
 585:	77 f0                	ja     577 <free+0x13>
 587:	39 c8                	cmp    %ecx,%eax
 589:	72 08                	jb     593 <free+0x2f>
 58b:	39 ca                	cmp    %ecx,%edx
 58d:	77 04                	ja     593 <free+0x2f>
 58f:	89 d0                	mov    %edx,%eax
 591:	eb e6                	jmp    579 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 593:	8b 73 fc             	mov    -0x4(%ebx),%esi
 596:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 599:	8b 10                	mov    (%eax),%edx
 59b:	39 d7                	cmp    %edx,%edi
 59d:	74 19                	je     5b8 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 59f:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5a2:	8b 50 04             	mov    0x4(%eax),%edx
 5a5:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5a8:	39 ce                	cmp    %ecx,%esi
 5aa:	74 1b                	je     5c7 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5ac:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5ae:	a3 80 09 00 00       	mov    %eax,0x980
}
 5b3:	5b                   	pop    %ebx
 5b4:	5e                   	pop    %esi
 5b5:	5f                   	pop    %edi
 5b6:	5d                   	pop    %ebp
 5b7:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5b8:	03 72 04             	add    0x4(%edx),%esi
 5bb:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5be:	8b 10                	mov    (%eax),%edx
 5c0:	8b 12                	mov    (%edx),%edx
 5c2:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5c5:	eb db                	jmp    5a2 <free+0x3e>
    p->s.size += bp->s.size;
 5c7:	03 53 fc             	add    -0x4(%ebx),%edx
 5ca:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5cd:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5d0:	89 10                	mov    %edx,(%eax)
 5d2:	eb da                	jmp    5ae <free+0x4a>

000005d4 <morecore>:

static Header*
morecore(uint nu)
{
 5d4:	55                   	push   %ebp
 5d5:	89 e5                	mov    %esp,%ebp
 5d7:	53                   	push   %ebx
 5d8:	83 ec 04             	sub    $0x4,%esp
 5db:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 5dd:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 5e2:	77 05                	ja     5e9 <morecore+0x15>
    nu = 4096;
 5e4:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 5e9:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5f0:	83 ec 0c             	sub    $0xc,%esp
 5f3:	50                   	push   %eax
 5f4:	e8 38 fd ff ff       	call   331 <sbrk>
  if(p == (char*)-1)
 5f9:	83 c4 10             	add    $0x10,%esp
 5fc:	83 f8 ff             	cmp    $0xffffffff,%eax
 5ff:	74 1c                	je     61d <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 601:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 604:	83 c0 08             	add    $0x8,%eax
 607:	83 ec 0c             	sub    $0xc,%esp
 60a:	50                   	push   %eax
 60b:	e8 54 ff ff ff       	call   564 <free>
  return freep;
 610:	a1 80 09 00 00       	mov    0x980,%eax
 615:	83 c4 10             	add    $0x10,%esp
}
 618:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 61b:	c9                   	leave  
 61c:	c3                   	ret    
    return 0;
 61d:	b8 00 00 00 00       	mov    $0x0,%eax
 622:	eb f4                	jmp    618 <morecore+0x44>

00000624 <malloc>:

void*
malloc(uint nbytes)
{
 624:	55                   	push   %ebp
 625:	89 e5                	mov    %esp,%ebp
 627:	53                   	push   %ebx
 628:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 62b:	8b 45 08             	mov    0x8(%ebp),%eax
 62e:	8d 58 07             	lea    0x7(%eax),%ebx
 631:	c1 eb 03             	shr    $0x3,%ebx
 634:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 637:	8b 0d 80 09 00 00    	mov    0x980,%ecx
 63d:	85 c9                	test   %ecx,%ecx
 63f:	74 04                	je     645 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 641:	8b 01                	mov    (%ecx),%eax
 643:	eb 4d                	jmp    692 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 645:	c7 05 80 09 00 00 84 	movl   $0x984,0x980
 64c:	09 00 00 
 64f:	c7 05 84 09 00 00 84 	movl   $0x984,0x984
 656:	09 00 00 
    base.s.size = 0;
 659:	c7 05 88 09 00 00 00 	movl   $0x0,0x988
 660:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 663:	b9 84 09 00 00       	mov    $0x984,%ecx
 668:	eb d7                	jmp    641 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 66a:	39 da                	cmp    %ebx,%edx
 66c:	74 1a                	je     688 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 66e:	29 da                	sub    %ebx,%edx
 670:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 673:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 676:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 679:	89 0d 80 09 00 00    	mov    %ecx,0x980
      return (void*)(p + 1);
 67f:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 682:	83 c4 04             	add    $0x4,%esp
 685:	5b                   	pop    %ebx
 686:	5d                   	pop    %ebp
 687:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 688:	8b 10                	mov    (%eax),%edx
 68a:	89 11                	mov    %edx,(%ecx)
 68c:	eb eb                	jmp    679 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 68e:	89 c1                	mov    %eax,%ecx
 690:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 692:	8b 50 04             	mov    0x4(%eax),%edx
 695:	39 da                	cmp    %ebx,%edx
 697:	73 d1                	jae    66a <malloc+0x46>
    if(p == freep)
 699:	39 05 80 09 00 00    	cmp    %eax,0x980
 69f:	75 ed                	jne    68e <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 6a1:	89 d8                	mov    %ebx,%eax
 6a3:	e8 2c ff ff ff       	call   5d4 <morecore>
 6a8:	85 c0                	test   %eax,%eax
 6aa:	75 e2                	jne    68e <malloc+0x6a>
        return 0;
 6ac:	b8 00 00 00 00       	mov    $0x0,%eax
 6b1:	eb cf                	jmp    682 <malloc+0x5e>
