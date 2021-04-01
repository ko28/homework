
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   8:	83 ec 0c             	sub    $0xc,%esp
   b:	53                   	push   %ebx
   c:	e8 18 03 00 00       	call   329 <strlen>
  11:	01 d8                	add    %ebx,%eax
  13:	83 c4 10             	add    $0x10,%esp
  16:	eb 03                	jmp    1b <fmtname+0x1b>
  18:	83 e8 01             	sub    $0x1,%eax
  1b:	39 d8                	cmp    %ebx,%eax
  1d:	72 05                	jb     24 <fmtname+0x24>
  1f:	80 38 2f             	cmpb   $0x2f,(%eax)
  22:	75 f4                	jne    18 <fmtname+0x18>
    ;
  p++;
  24:	8d 58 01             	lea    0x1(%eax),%ebx

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  27:	83 ec 0c             	sub    $0xc,%esp
  2a:	53                   	push   %ebx
  2b:	e8 f9 02 00 00       	call   329 <strlen>
  30:	83 c4 10             	add    $0x10,%esp
  33:	83 f8 0d             	cmp    $0xd,%eax
  36:	76 09                	jbe    41 <fmtname+0x41>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  38:	89 d8                	mov    %ebx,%eax
  3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  3d:	5b                   	pop    %ebx
  3e:	5e                   	pop    %esi
  3f:	5d                   	pop    %ebp
  40:	c3                   	ret    
  memmove(buf, p, strlen(p));
  41:	83 ec 0c             	sub    $0xc,%esp
  44:	53                   	push   %ebx
  45:	e8 df 02 00 00       	call   329 <strlen>
  4a:	83 c4 0c             	add    $0xc,%esp
  4d:	50                   	push   %eax
  4e:	53                   	push   %ebx
  4f:	68 d0 0b 00 00       	push   $0xbd0
  54:	e8 e7 03 00 00       	call   440 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  59:	89 1c 24             	mov    %ebx,(%esp)
  5c:	e8 c8 02 00 00       	call   329 <strlen>
  61:	89 c6                	mov    %eax,%esi
  63:	89 1c 24             	mov    %ebx,(%esp)
  66:	e8 be 02 00 00       	call   329 <strlen>
  6b:	83 c4 0c             	add    $0xc,%esp
  6e:	ba 0e 00 00 00       	mov    $0xe,%edx
  73:	29 f2                	sub    %esi,%edx
  75:	52                   	push   %edx
  76:	6a 20                	push   $0x20
  78:	05 d0 0b 00 00       	add    $0xbd0,%eax
  7d:	50                   	push   %eax
  7e:	e8 c0 02 00 00       	call   343 <memset>
  return buf;
  83:	83 c4 10             	add    $0x10,%esp
  86:	bb d0 0b 00 00       	mov    $0xbd0,%ebx
  8b:	eb ab                	jmp    38 <fmtname+0x38>

0000008d <ls>:

void
ls(char *path)
{
  8d:	55                   	push   %ebp
  8e:	89 e5                	mov    %esp,%ebp
  90:	57                   	push   %edi
  91:	56                   	push   %esi
  92:	53                   	push   %ebx
  93:	81 ec 54 02 00 00    	sub    $0x254,%esp
  99:	8b 75 08             	mov    0x8(%ebp),%esi
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  9c:	6a 00                	push   $0x0
  9e:	56                   	push   %esi
  9f:	e8 0e 04 00 00       	call   4b2 <open>
  a4:	83 c4 10             	add    $0x10,%esp
  a7:	85 c0                	test   %eax,%eax
  a9:	0f 88 8c 00 00 00    	js     13b <ls+0xae>
  af:	89 c3                	mov    %eax,%ebx
    printf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  b1:	83 ec 08             	sub    $0x8,%esp
  b4:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
  ba:	50                   	push   %eax
  bb:	53                   	push   %ebx
  bc:	e8 09 04 00 00       	call   4ca <fstat>
  c1:	83 c4 10             	add    $0x10,%esp
  c4:	85 c0                	test   %eax,%eax
  c6:	0f 88 84 00 00 00    	js     150 <ls+0xc3>
    printf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  cc:	0f b7 85 c4 fd ff ff 	movzwl -0x23c(%ebp),%eax
  d3:	0f bf f8             	movswl %ax,%edi
  d6:	66 83 f8 01          	cmp    $0x1,%ax
  da:	0f 84 8d 00 00 00    	je     16d <ls+0xe0>
  e0:	66 83 f8 02          	cmp    $0x2,%ax
  e4:	75 41                	jne    127 <ls+0x9a>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
  e6:	8b 85 d4 fd ff ff    	mov    -0x22c(%ebp),%eax
  ec:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
  f2:	8b 95 cc fd ff ff    	mov    -0x234(%ebp),%edx
  f8:	89 95 b0 fd ff ff    	mov    %edx,-0x250(%ebp)
  fe:	83 ec 0c             	sub    $0xc,%esp
 101:	56                   	push   %esi
 102:	e8 f9 fe ff ff       	call   0 <fmtname>
 107:	83 c4 08             	add    $0x8,%esp
 10a:	ff b5 b4 fd ff ff    	pushl  -0x24c(%ebp)
 110:	ff b5 b0 fd ff ff    	pushl  -0x250(%ebp)
 116:	57                   	push   %edi
 117:	50                   	push   %eax
 118:	68 a4 08 00 00       	push   $0x8a4
 11d:	6a 01                	push   $0x1
 11f:	e8 a0 04 00 00       	call   5c4 <printf>
    break;
 124:	83 c4 20             	add    $0x20,%esp
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 127:	83 ec 0c             	sub    $0xc,%esp
 12a:	53                   	push   %ebx
 12b:	e8 6a 03 00 00       	call   49a <close>
 130:	83 c4 10             	add    $0x10,%esp
}
 133:	8d 65 f4             	lea    -0xc(%ebp),%esp
 136:	5b                   	pop    %ebx
 137:	5e                   	pop    %esi
 138:	5f                   	pop    %edi
 139:	5d                   	pop    %ebp
 13a:	c3                   	ret    
    printf(2, "ls: cannot open %s\n", path);
 13b:	83 ec 04             	sub    $0x4,%esp
 13e:	56                   	push   %esi
 13f:	68 7c 08 00 00       	push   $0x87c
 144:	6a 02                	push   $0x2
 146:	e8 79 04 00 00       	call   5c4 <printf>
    return;
 14b:	83 c4 10             	add    $0x10,%esp
 14e:	eb e3                	jmp    133 <ls+0xa6>
    printf(2, "ls: cannot stat %s\n", path);
 150:	83 ec 04             	sub    $0x4,%esp
 153:	56                   	push   %esi
 154:	68 90 08 00 00       	push   $0x890
 159:	6a 02                	push   $0x2
 15b:	e8 64 04 00 00       	call   5c4 <printf>
    close(fd);
 160:	89 1c 24             	mov    %ebx,(%esp)
 163:	e8 32 03 00 00       	call   49a <close>
    return;
 168:	83 c4 10             	add    $0x10,%esp
 16b:	eb c6                	jmp    133 <ls+0xa6>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 16d:	83 ec 0c             	sub    $0xc,%esp
 170:	56                   	push   %esi
 171:	e8 b3 01 00 00       	call   329 <strlen>
 176:	83 c0 10             	add    $0x10,%eax
 179:	83 c4 10             	add    $0x10,%esp
 17c:	3d 00 02 00 00       	cmp    $0x200,%eax
 181:	76 14                	jbe    197 <ls+0x10a>
      printf(1, "ls: path too long\n");
 183:	83 ec 08             	sub    $0x8,%esp
 186:	68 b1 08 00 00       	push   $0x8b1
 18b:	6a 01                	push   $0x1
 18d:	e8 32 04 00 00       	call   5c4 <printf>
      break;
 192:	83 c4 10             	add    $0x10,%esp
 195:	eb 90                	jmp    127 <ls+0x9a>
    strcpy(buf, path);
 197:	83 ec 08             	sub    $0x8,%esp
 19a:	56                   	push   %esi
 19b:	8d b5 e8 fd ff ff    	lea    -0x218(%ebp),%esi
 1a1:	56                   	push   %esi
 1a2:	e8 3e 01 00 00       	call   2e5 <strcpy>
    p = buf+strlen(buf);
 1a7:	89 34 24             	mov    %esi,(%esp)
 1aa:	e8 7a 01 00 00       	call   329 <strlen>
 1af:	01 c6                	add    %eax,%esi
    *p++ = '/';
 1b1:	8d 46 01             	lea    0x1(%esi),%eax
 1b4:	89 85 ac fd ff ff    	mov    %eax,-0x254(%ebp)
 1ba:	c6 06 2f             	movb   $0x2f,(%esi)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1bd:	83 c4 10             	add    $0x10,%esp
 1c0:	83 ec 04             	sub    $0x4,%esp
 1c3:	6a 10                	push   $0x10
 1c5:	8d 85 d8 fd ff ff    	lea    -0x228(%ebp),%eax
 1cb:	50                   	push   %eax
 1cc:	53                   	push   %ebx
 1cd:	e8 b8 02 00 00       	call   48a <read>
 1d2:	83 c4 10             	add    $0x10,%esp
 1d5:	83 f8 10             	cmp    $0x10,%eax
 1d8:	0f 85 49 ff ff ff    	jne    127 <ls+0x9a>
      if(de.inum == 0)
 1de:	66 83 bd d8 fd ff ff 	cmpw   $0x0,-0x228(%ebp)
 1e5:	00 
 1e6:	74 d8                	je     1c0 <ls+0x133>
      memmove(p, de.name, DIRSIZ);
 1e8:	83 ec 04             	sub    $0x4,%esp
 1eb:	6a 0e                	push   $0xe
 1ed:	8d 85 da fd ff ff    	lea    -0x226(%ebp),%eax
 1f3:	50                   	push   %eax
 1f4:	ff b5 ac fd ff ff    	pushl  -0x254(%ebp)
 1fa:	e8 41 02 00 00       	call   440 <memmove>
      p[DIRSIZ] = 0;
 1ff:	c6 46 0f 00          	movb   $0x0,0xf(%esi)
      if(stat(buf, &st) < 0){
 203:	83 c4 08             	add    $0x8,%esp
 206:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
 20c:	50                   	push   %eax
 20d:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
 213:	50                   	push   %eax
 214:	e8 b7 01 00 00       	call   3d0 <stat>
 219:	83 c4 10             	add    $0x10,%esp
 21c:	85 c0                	test   %eax,%eax
 21e:	78 56                	js     276 <ls+0x1e9>
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 220:	8b bd d4 fd ff ff    	mov    -0x22c(%ebp),%edi
 226:	8b 85 cc fd ff ff    	mov    -0x234(%ebp),%eax
 22c:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
 232:	0f b7 8d c4 fd ff ff 	movzwl -0x23c(%ebp),%ecx
 239:	66 89 8d b0 fd ff ff 	mov    %cx,-0x250(%ebp)
 240:	83 ec 0c             	sub    $0xc,%esp
 243:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
 249:	50                   	push   %eax
 24a:	e8 b1 fd ff ff       	call   0 <fmtname>
 24f:	83 c4 08             	add    $0x8,%esp
 252:	57                   	push   %edi
 253:	ff b5 b4 fd ff ff    	pushl  -0x24c(%ebp)
 259:	0f bf 95 b0 fd ff ff 	movswl -0x250(%ebp),%edx
 260:	52                   	push   %edx
 261:	50                   	push   %eax
 262:	68 a4 08 00 00       	push   $0x8a4
 267:	6a 01                	push   $0x1
 269:	e8 56 03 00 00       	call   5c4 <printf>
 26e:	83 c4 20             	add    $0x20,%esp
 271:	e9 4a ff ff ff       	jmp    1c0 <ls+0x133>
        printf(1, "ls: cannot stat %s\n", buf);
 276:	83 ec 04             	sub    $0x4,%esp
 279:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
 27f:	50                   	push   %eax
 280:	68 90 08 00 00       	push   $0x890
 285:	6a 01                	push   $0x1
 287:	e8 38 03 00 00       	call   5c4 <printf>
        continue;
 28c:	83 c4 10             	add    $0x10,%esp
 28f:	e9 2c ff ff ff       	jmp    1c0 <ls+0x133>

00000294 <main>:

int
main(int argc, char *argv[])
{
 294:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 298:	83 e4 f0             	and    $0xfffffff0,%esp
 29b:	ff 71 fc             	pushl  -0x4(%ecx)
 29e:	55                   	push   %ebp
 29f:	89 e5                	mov    %esp,%ebp
 2a1:	57                   	push   %edi
 2a2:	56                   	push   %esi
 2a3:	53                   	push   %ebx
 2a4:	51                   	push   %ecx
 2a5:	83 ec 08             	sub    $0x8,%esp
 2a8:	8b 31                	mov    (%ecx),%esi
 2aa:	8b 79 04             	mov    0x4(%ecx),%edi
  int i;

  if(argc < 2){
 2ad:	83 fe 01             	cmp    $0x1,%esi
 2b0:	7e 07                	jle    2b9 <main+0x25>
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
 2b2:	bb 01 00 00 00       	mov    $0x1,%ebx
 2b7:	eb 23                	jmp    2dc <main+0x48>
    ls(".");
 2b9:	83 ec 0c             	sub    $0xc,%esp
 2bc:	68 c4 08 00 00       	push   $0x8c4
 2c1:	e8 c7 fd ff ff       	call   8d <ls>
    exit();
 2c6:	e8 a7 01 00 00       	call   472 <exit>
    ls(argv[i]);
 2cb:	83 ec 0c             	sub    $0xc,%esp
 2ce:	ff 34 9f             	pushl  (%edi,%ebx,4)
 2d1:	e8 b7 fd ff ff       	call   8d <ls>
  for(i=1; i<argc; i++)
 2d6:	83 c3 01             	add    $0x1,%ebx
 2d9:	83 c4 10             	add    $0x10,%esp
 2dc:	39 f3                	cmp    %esi,%ebx
 2de:	7c eb                	jl     2cb <main+0x37>
  exit();
 2e0:	e8 8d 01 00 00       	call   472 <exit>

000002e5 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 2e5:	55                   	push   %ebp
 2e6:	89 e5                	mov    %esp,%ebp
 2e8:	53                   	push   %ebx
 2e9:	8b 45 08             	mov    0x8(%ebp),%eax
 2ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2ef:	89 c2                	mov    %eax,%edx
 2f1:	0f b6 19             	movzbl (%ecx),%ebx
 2f4:	88 1a                	mov    %bl,(%edx)
 2f6:	8d 52 01             	lea    0x1(%edx),%edx
 2f9:	8d 49 01             	lea    0x1(%ecx),%ecx
 2fc:	84 db                	test   %bl,%bl
 2fe:	75 f1                	jne    2f1 <strcpy+0xc>
    ;
  return os;
}
 300:	5b                   	pop    %ebx
 301:	5d                   	pop    %ebp
 302:	c3                   	ret    

00000303 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 303:	55                   	push   %ebp
 304:	89 e5                	mov    %esp,%ebp
 306:	8b 4d 08             	mov    0x8(%ebp),%ecx
 309:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 30c:	eb 06                	jmp    314 <strcmp+0x11>
    p++, q++;
 30e:	83 c1 01             	add    $0x1,%ecx
 311:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 314:	0f b6 01             	movzbl (%ecx),%eax
 317:	84 c0                	test   %al,%al
 319:	74 04                	je     31f <strcmp+0x1c>
 31b:	3a 02                	cmp    (%edx),%al
 31d:	74 ef                	je     30e <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 31f:	0f b6 c0             	movzbl %al,%eax
 322:	0f b6 12             	movzbl (%edx),%edx
 325:	29 d0                	sub    %edx,%eax
}
 327:	5d                   	pop    %ebp
 328:	c3                   	ret    

00000329 <strlen>:

uint
strlen(const char *s)
{
 329:	55                   	push   %ebp
 32a:	89 e5                	mov    %esp,%ebp
 32c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 32f:	ba 00 00 00 00       	mov    $0x0,%edx
 334:	eb 03                	jmp    339 <strlen+0x10>
 336:	83 c2 01             	add    $0x1,%edx
 339:	89 d0                	mov    %edx,%eax
 33b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 33f:	75 f5                	jne    336 <strlen+0xd>
    ;
  return n;
}
 341:	5d                   	pop    %ebp
 342:	c3                   	ret    

00000343 <memset>:

void*
memset(void *dst, int c, uint n)
{
 343:	55                   	push   %ebp
 344:	89 e5                	mov    %esp,%ebp
 346:	57                   	push   %edi
 347:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 34a:	89 d7                	mov    %edx,%edi
 34c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 34f:	8b 45 0c             	mov    0xc(%ebp),%eax
 352:	fc                   	cld    
 353:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 355:	89 d0                	mov    %edx,%eax
 357:	5f                   	pop    %edi
 358:	5d                   	pop    %ebp
 359:	c3                   	ret    

0000035a <strchr>:

char*
strchr(const char *s, char c)
{
 35a:	55                   	push   %ebp
 35b:	89 e5                	mov    %esp,%ebp
 35d:	8b 45 08             	mov    0x8(%ebp),%eax
 360:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 364:	0f b6 10             	movzbl (%eax),%edx
 367:	84 d2                	test   %dl,%dl
 369:	74 09                	je     374 <strchr+0x1a>
    if(*s == c)
 36b:	38 ca                	cmp    %cl,%dl
 36d:	74 0a                	je     379 <strchr+0x1f>
  for(; *s; s++)
 36f:	83 c0 01             	add    $0x1,%eax
 372:	eb f0                	jmp    364 <strchr+0xa>
      return (char*)s;
  return 0;
 374:	b8 00 00 00 00       	mov    $0x0,%eax
}
 379:	5d                   	pop    %ebp
 37a:	c3                   	ret    

0000037b <gets>:

char*
gets(char *buf, int max)
{
 37b:	55                   	push   %ebp
 37c:	89 e5                	mov    %esp,%ebp
 37e:	57                   	push   %edi
 37f:	56                   	push   %esi
 380:	53                   	push   %ebx
 381:	83 ec 1c             	sub    $0x1c,%esp
 384:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 387:	bb 00 00 00 00       	mov    $0x0,%ebx
 38c:	8d 73 01             	lea    0x1(%ebx),%esi
 38f:	3b 75 0c             	cmp    0xc(%ebp),%esi
 392:	7d 2e                	jge    3c2 <gets+0x47>
    cc = read(0, &c, 1);
 394:	83 ec 04             	sub    $0x4,%esp
 397:	6a 01                	push   $0x1
 399:	8d 45 e7             	lea    -0x19(%ebp),%eax
 39c:	50                   	push   %eax
 39d:	6a 00                	push   $0x0
 39f:	e8 e6 00 00 00       	call   48a <read>
    if(cc < 1)
 3a4:	83 c4 10             	add    $0x10,%esp
 3a7:	85 c0                	test   %eax,%eax
 3a9:	7e 17                	jle    3c2 <gets+0x47>
      break;
    buf[i++] = c;
 3ab:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 3af:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 3b2:	3c 0a                	cmp    $0xa,%al
 3b4:	0f 94 c2             	sete   %dl
 3b7:	3c 0d                	cmp    $0xd,%al
 3b9:	0f 94 c0             	sete   %al
    buf[i++] = c;
 3bc:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 3be:	08 c2                	or     %al,%dl
 3c0:	74 ca                	je     38c <gets+0x11>
      break;
  }
  buf[i] = '\0';
 3c2:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 3c6:	89 f8                	mov    %edi,%eax
 3c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3cb:	5b                   	pop    %ebx
 3cc:	5e                   	pop    %esi
 3cd:	5f                   	pop    %edi
 3ce:	5d                   	pop    %ebp
 3cf:	c3                   	ret    

000003d0 <stat>:

int
stat(const char *n, struct stat *st)
{
 3d0:	55                   	push   %ebp
 3d1:	89 e5                	mov    %esp,%ebp
 3d3:	56                   	push   %esi
 3d4:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3d5:	83 ec 08             	sub    $0x8,%esp
 3d8:	6a 00                	push   $0x0
 3da:	ff 75 08             	pushl  0x8(%ebp)
 3dd:	e8 d0 00 00 00       	call   4b2 <open>
  if(fd < 0)
 3e2:	83 c4 10             	add    $0x10,%esp
 3e5:	85 c0                	test   %eax,%eax
 3e7:	78 24                	js     40d <stat+0x3d>
 3e9:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 3eb:	83 ec 08             	sub    $0x8,%esp
 3ee:	ff 75 0c             	pushl  0xc(%ebp)
 3f1:	50                   	push   %eax
 3f2:	e8 d3 00 00 00       	call   4ca <fstat>
 3f7:	89 c6                	mov    %eax,%esi
  close(fd);
 3f9:	89 1c 24             	mov    %ebx,(%esp)
 3fc:	e8 99 00 00 00       	call   49a <close>
  return r;
 401:	83 c4 10             	add    $0x10,%esp
}
 404:	89 f0                	mov    %esi,%eax
 406:	8d 65 f8             	lea    -0x8(%ebp),%esp
 409:	5b                   	pop    %ebx
 40a:	5e                   	pop    %esi
 40b:	5d                   	pop    %ebp
 40c:	c3                   	ret    
    return -1;
 40d:	be ff ff ff ff       	mov    $0xffffffff,%esi
 412:	eb f0                	jmp    404 <stat+0x34>

00000414 <atoi>:

int
atoi(const char *s)
{
 414:	55                   	push   %ebp
 415:	89 e5                	mov    %esp,%ebp
 417:	53                   	push   %ebx
 418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 41b:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 420:	eb 10                	jmp    432 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 422:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 425:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 428:	83 c1 01             	add    $0x1,%ecx
 42b:	0f be d2             	movsbl %dl,%edx
 42e:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 432:	0f b6 11             	movzbl (%ecx),%edx
 435:	8d 5a d0             	lea    -0x30(%edx),%ebx
 438:	80 fb 09             	cmp    $0x9,%bl
 43b:	76 e5                	jbe    422 <atoi+0xe>
  return n;
}
 43d:	5b                   	pop    %ebx
 43e:	5d                   	pop    %ebp
 43f:	c3                   	ret    

00000440 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 440:	55                   	push   %ebp
 441:	89 e5                	mov    %esp,%ebp
 443:	56                   	push   %esi
 444:	53                   	push   %ebx
 445:	8b 45 08             	mov    0x8(%ebp),%eax
 448:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 44b:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 44e:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 450:	eb 0d                	jmp    45f <memmove+0x1f>
    *dst++ = *src++;
 452:	0f b6 13             	movzbl (%ebx),%edx
 455:	88 11                	mov    %dl,(%ecx)
 457:	8d 5b 01             	lea    0x1(%ebx),%ebx
 45a:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 45d:	89 f2                	mov    %esi,%edx
 45f:	8d 72 ff             	lea    -0x1(%edx),%esi
 462:	85 d2                	test   %edx,%edx
 464:	7f ec                	jg     452 <memmove+0x12>
  return vdst;
}
 466:	5b                   	pop    %ebx
 467:	5e                   	pop    %esi
 468:	5d                   	pop    %ebp
 469:	c3                   	ret    

0000046a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 46a:	b8 01 00 00 00       	mov    $0x1,%eax
 46f:	cd 40                	int    $0x40
 471:	c3                   	ret    

00000472 <exit>:
SYSCALL(exit)
 472:	b8 02 00 00 00       	mov    $0x2,%eax
 477:	cd 40                	int    $0x40
 479:	c3                   	ret    

0000047a <wait>:
SYSCALL(wait)
 47a:	b8 03 00 00 00       	mov    $0x3,%eax
 47f:	cd 40                	int    $0x40
 481:	c3                   	ret    

00000482 <pipe>:
SYSCALL(pipe)
 482:	b8 04 00 00 00       	mov    $0x4,%eax
 487:	cd 40                	int    $0x40
 489:	c3                   	ret    

0000048a <read>:
SYSCALL(read)
 48a:	b8 05 00 00 00       	mov    $0x5,%eax
 48f:	cd 40                	int    $0x40
 491:	c3                   	ret    

00000492 <write>:
SYSCALL(write)
 492:	b8 10 00 00 00       	mov    $0x10,%eax
 497:	cd 40                	int    $0x40
 499:	c3                   	ret    

0000049a <close>:
SYSCALL(close)
 49a:	b8 15 00 00 00       	mov    $0x15,%eax
 49f:	cd 40                	int    $0x40
 4a1:	c3                   	ret    

000004a2 <kill>:
SYSCALL(kill)
 4a2:	b8 06 00 00 00       	mov    $0x6,%eax
 4a7:	cd 40                	int    $0x40
 4a9:	c3                   	ret    

000004aa <exec>:
SYSCALL(exec)
 4aa:	b8 07 00 00 00       	mov    $0x7,%eax
 4af:	cd 40                	int    $0x40
 4b1:	c3                   	ret    

000004b2 <open>:
SYSCALL(open)
 4b2:	b8 0f 00 00 00       	mov    $0xf,%eax
 4b7:	cd 40                	int    $0x40
 4b9:	c3                   	ret    

000004ba <mknod>:
SYSCALL(mknod)
 4ba:	b8 11 00 00 00       	mov    $0x11,%eax
 4bf:	cd 40                	int    $0x40
 4c1:	c3                   	ret    

000004c2 <unlink>:
SYSCALL(unlink)
 4c2:	b8 12 00 00 00       	mov    $0x12,%eax
 4c7:	cd 40                	int    $0x40
 4c9:	c3                   	ret    

000004ca <fstat>:
SYSCALL(fstat)
 4ca:	b8 08 00 00 00       	mov    $0x8,%eax
 4cf:	cd 40                	int    $0x40
 4d1:	c3                   	ret    

000004d2 <link>:
SYSCALL(link)
 4d2:	b8 13 00 00 00       	mov    $0x13,%eax
 4d7:	cd 40                	int    $0x40
 4d9:	c3                   	ret    

000004da <mkdir>:
SYSCALL(mkdir)
 4da:	b8 14 00 00 00       	mov    $0x14,%eax
 4df:	cd 40                	int    $0x40
 4e1:	c3                   	ret    

000004e2 <chdir>:
SYSCALL(chdir)
 4e2:	b8 09 00 00 00       	mov    $0x9,%eax
 4e7:	cd 40                	int    $0x40
 4e9:	c3                   	ret    

000004ea <dup>:
SYSCALL(dup)
 4ea:	b8 0a 00 00 00       	mov    $0xa,%eax
 4ef:	cd 40                	int    $0x40
 4f1:	c3                   	ret    

000004f2 <getpid>:
SYSCALL(getpid)
 4f2:	b8 0b 00 00 00       	mov    $0xb,%eax
 4f7:	cd 40                	int    $0x40
 4f9:	c3                   	ret    

000004fa <sbrk>:
SYSCALL(sbrk)
 4fa:	b8 0c 00 00 00       	mov    $0xc,%eax
 4ff:	cd 40                	int    $0x40
 501:	c3                   	ret    

00000502 <sleep>:
SYSCALL(sleep)
 502:	b8 0d 00 00 00       	mov    $0xd,%eax
 507:	cd 40                	int    $0x40
 509:	c3                   	ret    

0000050a <uptime>:
SYSCALL(uptime)
 50a:	b8 0e 00 00 00       	mov    $0xe,%eax
 50f:	cd 40                	int    $0x40
 511:	c3                   	ret    

00000512 <mencrypt>:
SYSCALL(mencrypt)
 512:	b8 16 00 00 00       	mov    $0x16,%eax
 517:	cd 40                	int    $0x40
 519:	c3                   	ret    

0000051a <getpgtable>:
SYSCALL(getpgtable)
 51a:	b8 17 00 00 00       	mov    $0x17,%eax
 51f:	cd 40                	int    $0x40
 521:	c3                   	ret    

00000522 <dump_rawphymem>:
SYSCALL(dump_rawphymem)
 522:	b8 18 00 00 00       	mov    $0x18,%eax
 527:	cd 40                	int    $0x40
 529:	c3                   	ret    

0000052a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 52a:	55                   	push   %ebp
 52b:	89 e5                	mov    %esp,%ebp
 52d:	83 ec 1c             	sub    $0x1c,%esp
 530:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 533:	6a 01                	push   $0x1
 535:	8d 55 f4             	lea    -0xc(%ebp),%edx
 538:	52                   	push   %edx
 539:	50                   	push   %eax
 53a:	e8 53 ff ff ff       	call   492 <write>
}
 53f:	83 c4 10             	add    $0x10,%esp
 542:	c9                   	leave  
 543:	c3                   	ret    

00000544 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 544:	55                   	push   %ebp
 545:	89 e5                	mov    %esp,%ebp
 547:	57                   	push   %edi
 548:	56                   	push   %esi
 549:	53                   	push   %ebx
 54a:	83 ec 2c             	sub    $0x2c,%esp
 54d:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 54f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 553:	0f 95 c3             	setne  %bl
 556:	89 d0                	mov    %edx,%eax
 558:	c1 e8 1f             	shr    $0x1f,%eax
 55b:	84 c3                	test   %al,%bl
 55d:	74 10                	je     56f <printint+0x2b>
    neg = 1;
    x = -xx;
 55f:	f7 da                	neg    %edx
    neg = 1;
 561:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 568:	be 00 00 00 00       	mov    $0x0,%esi
 56d:	eb 0b                	jmp    57a <printint+0x36>
  neg = 0;
 56f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 576:	eb f0                	jmp    568 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 578:	89 c6                	mov    %eax,%esi
 57a:	89 d0                	mov    %edx,%eax
 57c:	ba 00 00 00 00       	mov    $0x0,%edx
 581:	f7 f1                	div    %ecx
 583:	89 c3                	mov    %eax,%ebx
 585:	8d 46 01             	lea    0x1(%esi),%eax
 588:	0f b6 92 d0 08 00 00 	movzbl 0x8d0(%edx),%edx
 58f:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 593:	89 da                	mov    %ebx,%edx
 595:	85 db                	test   %ebx,%ebx
 597:	75 df                	jne    578 <printint+0x34>
 599:	89 c3                	mov    %eax,%ebx
  if(neg)
 59b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 59f:	74 16                	je     5b7 <printint+0x73>
    buf[i++] = '-';
 5a1:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 5a6:	8d 5e 02             	lea    0x2(%esi),%ebx
 5a9:	eb 0c                	jmp    5b7 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 5ab:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 5b0:	89 f8                	mov    %edi,%eax
 5b2:	e8 73 ff ff ff       	call   52a <putc>
  while(--i >= 0)
 5b7:	83 eb 01             	sub    $0x1,%ebx
 5ba:	79 ef                	jns    5ab <printint+0x67>
}
 5bc:	83 c4 2c             	add    $0x2c,%esp
 5bf:	5b                   	pop    %ebx
 5c0:	5e                   	pop    %esi
 5c1:	5f                   	pop    %edi
 5c2:	5d                   	pop    %ebp
 5c3:	c3                   	ret    

000005c4 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 5c4:	55                   	push   %ebp
 5c5:	89 e5                	mov    %esp,%ebp
 5c7:	57                   	push   %edi
 5c8:	56                   	push   %esi
 5c9:	53                   	push   %ebx
 5ca:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 5cd:	8d 45 10             	lea    0x10(%ebp),%eax
 5d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 5d3:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 5d8:	bb 00 00 00 00       	mov    $0x0,%ebx
 5dd:	eb 14                	jmp    5f3 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 5df:	89 fa                	mov    %edi,%edx
 5e1:	8b 45 08             	mov    0x8(%ebp),%eax
 5e4:	e8 41 ff ff ff       	call   52a <putc>
 5e9:	eb 05                	jmp    5f0 <printf+0x2c>
      }
    } else if(state == '%'){
 5eb:	83 fe 25             	cmp    $0x25,%esi
 5ee:	74 25                	je     615 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 5f0:	83 c3 01             	add    $0x1,%ebx
 5f3:	8b 45 0c             	mov    0xc(%ebp),%eax
 5f6:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 5fa:	84 c0                	test   %al,%al
 5fc:	0f 84 23 01 00 00    	je     725 <printf+0x161>
    c = fmt[i] & 0xff;
 602:	0f be f8             	movsbl %al,%edi
 605:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 608:	85 f6                	test   %esi,%esi
 60a:	75 df                	jne    5eb <printf+0x27>
      if(c == '%'){
 60c:	83 f8 25             	cmp    $0x25,%eax
 60f:	75 ce                	jne    5df <printf+0x1b>
        state = '%';
 611:	89 c6                	mov    %eax,%esi
 613:	eb db                	jmp    5f0 <printf+0x2c>
      if(c == 'd'){
 615:	83 f8 64             	cmp    $0x64,%eax
 618:	74 49                	je     663 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 61a:	83 f8 78             	cmp    $0x78,%eax
 61d:	0f 94 c1             	sete   %cl
 620:	83 f8 70             	cmp    $0x70,%eax
 623:	0f 94 c2             	sete   %dl
 626:	08 d1                	or     %dl,%cl
 628:	75 63                	jne    68d <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 62a:	83 f8 73             	cmp    $0x73,%eax
 62d:	0f 84 84 00 00 00    	je     6b7 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 633:	83 f8 63             	cmp    $0x63,%eax
 636:	0f 84 b7 00 00 00    	je     6f3 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 63c:	83 f8 25             	cmp    $0x25,%eax
 63f:	0f 84 cc 00 00 00    	je     711 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 645:	ba 25 00 00 00       	mov    $0x25,%edx
 64a:	8b 45 08             	mov    0x8(%ebp),%eax
 64d:	e8 d8 fe ff ff       	call   52a <putc>
        putc(fd, c);
 652:	89 fa                	mov    %edi,%edx
 654:	8b 45 08             	mov    0x8(%ebp),%eax
 657:	e8 ce fe ff ff       	call   52a <putc>
      }
      state = 0;
 65c:	be 00 00 00 00       	mov    $0x0,%esi
 661:	eb 8d                	jmp    5f0 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 663:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 666:	8b 17                	mov    (%edi),%edx
 668:	83 ec 0c             	sub    $0xc,%esp
 66b:	6a 01                	push   $0x1
 66d:	b9 0a 00 00 00       	mov    $0xa,%ecx
 672:	8b 45 08             	mov    0x8(%ebp),%eax
 675:	e8 ca fe ff ff       	call   544 <printint>
        ap++;
 67a:	83 c7 04             	add    $0x4,%edi
 67d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 680:	83 c4 10             	add    $0x10,%esp
      state = 0;
 683:	be 00 00 00 00       	mov    $0x0,%esi
 688:	e9 63 ff ff ff       	jmp    5f0 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 68d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 690:	8b 17                	mov    (%edi),%edx
 692:	83 ec 0c             	sub    $0xc,%esp
 695:	6a 00                	push   $0x0
 697:	b9 10 00 00 00       	mov    $0x10,%ecx
 69c:	8b 45 08             	mov    0x8(%ebp),%eax
 69f:	e8 a0 fe ff ff       	call   544 <printint>
        ap++;
 6a4:	83 c7 04             	add    $0x4,%edi
 6a7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 6aa:	83 c4 10             	add    $0x10,%esp
      state = 0;
 6ad:	be 00 00 00 00       	mov    $0x0,%esi
 6b2:	e9 39 ff ff ff       	jmp    5f0 <printf+0x2c>
        s = (char*)*ap;
 6b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ba:	8b 30                	mov    (%eax),%esi
        ap++;
 6bc:	83 c0 04             	add    $0x4,%eax
 6bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 6c2:	85 f6                	test   %esi,%esi
 6c4:	75 28                	jne    6ee <printf+0x12a>
          s = "(null)";
 6c6:	be c6 08 00 00       	mov    $0x8c6,%esi
 6cb:	8b 7d 08             	mov    0x8(%ebp),%edi
 6ce:	eb 0d                	jmp    6dd <printf+0x119>
          putc(fd, *s);
 6d0:	0f be d2             	movsbl %dl,%edx
 6d3:	89 f8                	mov    %edi,%eax
 6d5:	e8 50 fe ff ff       	call   52a <putc>
          s++;
 6da:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 6dd:	0f b6 16             	movzbl (%esi),%edx
 6e0:	84 d2                	test   %dl,%dl
 6e2:	75 ec                	jne    6d0 <printf+0x10c>
      state = 0;
 6e4:	be 00 00 00 00       	mov    $0x0,%esi
 6e9:	e9 02 ff ff ff       	jmp    5f0 <printf+0x2c>
 6ee:	8b 7d 08             	mov    0x8(%ebp),%edi
 6f1:	eb ea                	jmp    6dd <printf+0x119>
        putc(fd, *ap);
 6f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 6f6:	0f be 17             	movsbl (%edi),%edx
 6f9:	8b 45 08             	mov    0x8(%ebp),%eax
 6fc:	e8 29 fe ff ff       	call   52a <putc>
        ap++;
 701:	83 c7 04             	add    $0x4,%edi
 704:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 707:	be 00 00 00 00       	mov    $0x0,%esi
 70c:	e9 df fe ff ff       	jmp    5f0 <printf+0x2c>
        putc(fd, c);
 711:	89 fa                	mov    %edi,%edx
 713:	8b 45 08             	mov    0x8(%ebp),%eax
 716:	e8 0f fe ff ff       	call   52a <putc>
      state = 0;
 71b:	be 00 00 00 00       	mov    $0x0,%esi
 720:	e9 cb fe ff ff       	jmp    5f0 <printf+0x2c>
    }
  }
}
 725:	8d 65 f4             	lea    -0xc(%ebp),%esp
 728:	5b                   	pop    %ebx
 729:	5e                   	pop    %esi
 72a:	5f                   	pop    %edi
 72b:	5d                   	pop    %ebp
 72c:	c3                   	ret    

0000072d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 72d:	55                   	push   %ebp
 72e:	89 e5                	mov    %esp,%ebp
 730:	57                   	push   %edi
 731:	56                   	push   %esi
 732:	53                   	push   %ebx
 733:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 736:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 739:	a1 e0 0b 00 00       	mov    0xbe0,%eax
 73e:	eb 02                	jmp    742 <free+0x15>
 740:	89 d0                	mov    %edx,%eax
 742:	39 c8                	cmp    %ecx,%eax
 744:	73 04                	jae    74a <free+0x1d>
 746:	39 08                	cmp    %ecx,(%eax)
 748:	77 12                	ja     75c <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74a:	8b 10                	mov    (%eax),%edx
 74c:	39 c2                	cmp    %eax,%edx
 74e:	77 f0                	ja     740 <free+0x13>
 750:	39 c8                	cmp    %ecx,%eax
 752:	72 08                	jb     75c <free+0x2f>
 754:	39 ca                	cmp    %ecx,%edx
 756:	77 04                	ja     75c <free+0x2f>
 758:	89 d0                	mov    %edx,%eax
 75a:	eb e6                	jmp    742 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 75c:	8b 73 fc             	mov    -0x4(%ebx),%esi
 75f:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 762:	8b 10                	mov    (%eax),%edx
 764:	39 d7                	cmp    %edx,%edi
 766:	74 19                	je     781 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 768:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 76b:	8b 50 04             	mov    0x4(%eax),%edx
 76e:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 771:	39 ce                	cmp    %ecx,%esi
 773:	74 1b                	je     790 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 775:	89 08                	mov    %ecx,(%eax)
  freep = p;
 777:	a3 e0 0b 00 00       	mov    %eax,0xbe0
}
 77c:	5b                   	pop    %ebx
 77d:	5e                   	pop    %esi
 77e:	5f                   	pop    %edi
 77f:	5d                   	pop    %ebp
 780:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 781:	03 72 04             	add    0x4(%edx),%esi
 784:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 787:	8b 10                	mov    (%eax),%edx
 789:	8b 12                	mov    (%edx),%edx
 78b:	89 53 f8             	mov    %edx,-0x8(%ebx)
 78e:	eb db                	jmp    76b <free+0x3e>
    p->s.size += bp->s.size;
 790:	03 53 fc             	add    -0x4(%ebx),%edx
 793:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 796:	8b 53 f8             	mov    -0x8(%ebx),%edx
 799:	89 10                	mov    %edx,(%eax)
 79b:	eb da                	jmp    777 <free+0x4a>

0000079d <morecore>:

static Header*
morecore(uint nu)
{
 79d:	55                   	push   %ebp
 79e:	89 e5                	mov    %esp,%ebp
 7a0:	53                   	push   %ebx
 7a1:	83 ec 04             	sub    $0x4,%esp
 7a4:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 7a6:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 7ab:	77 05                	ja     7b2 <morecore+0x15>
    nu = 4096;
 7ad:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 7b2:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 7b9:	83 ec 0c             	sub    $0xc,%esp
 7bc:	50                   	push   %eax
 7bd:	e8 38 fd ff ff       	call   4fa <sbrk>
  if(p == (char*)-1)
 7c2:	83 c4 10             	add    $0x10,%esp
 7c5:	83 f8 ff             	cmp    $0xffffffff,%eax
 7c8:	74 1c                	je     7e6 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 7ca:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 7cd:	83 c0 08             	add    $0x8,%eax
 7d0:	83 ec 0c             	sub    $0xc,%esp
 7d3:	50                   	push   %eax
 7d4:	e8 54 ff ff ff       	call   72d <free>
  return freep;
 7d9:	a1 e0 0b 00 00       	mov    0xbe0,%eax
 7de:	83 c4 10             	add    $0x10,%esp
}
 7e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 7e4:	c9                   	leave  
 7e5:	c3                   	ret    
    return 0;
 7e6:	b8 00 00 00 00       	mov    $0x0,%eax
 7eb:	eb f4                	jmp    7e1 <morecore+0x44>

000007ed <malloc>:

void*
malloc(uint nbytes)
{
 7ed:	55                   	push   %ebp
 7ee:	89 e5                	mov    %esp,%ebp
 7f0:	53                   	push   %ebx
 7f1:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f4:	8b 45 08             	mov    0x8(%ebp),%eax
 7f7:	8d 58 07             	lea    0x7(%eax),%ebx
 7fa:	c1 eb 03             	shr    $0x3,%ebx
 7fd:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 800:	8b 0d e0 0b 00 00    	mov    0xbe0,%ecx
 806:	85 c9                	test   %ecx,%ecx
 808:	74 04                	je     80e <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80a:	8b 01                	mov    (%ecx),%eax
 80c:	eb 4d                	jmp    85b <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 80e:	c7 05 e0 0b 00 00 e4 	movl   $0xbe4,0xbe0
 815:	0b 00 00 
 818:	c7 05 e4 0b 00 00 e4 	movl   $0xbe4,0xbe4
 81f:	0b 00 00 
    base.s.size = 0;
 822:	c7 05 e8 0b 00 00 00 	movl   $0x0,0xbe8
 829:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 82c:	b9 e4 0b 00 00       	mov    $0xbe4,%ecx
 831:	eb d7                	jmp    80a <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 833:	39 da                	cmp    %ebx,%edx
 835:	74 1a                	je     851 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 837:	29 da                	sub    %ebx,%edx
 839:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 83c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 83f:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 842:	89 0d e0 0b 00 00    	mov    %ecx,0xbe0
      return (void*)(p + 1);
 848:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 84b:	83 c4 04             	add    $0x4,%esp
 84e:	5b                   	pop    %ebx
 84f:	5d                   	pop    %ebp
 850:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 851:	8b 10                	mov    (%eax),%edx
 853:	89 11                	mov    %edx,(%ecx)
 855:	eb eb                	jmp    842 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 857:	89 c1                	mov    %eax,%ecx
 859:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 85b:	8b 50 04             	mov    0x4(%eax),%edx
 85e:	39 da                	cmp    %ebx,%edx
 860:	73 d1                	jae    833 <malloc+0x46>
    if(p == freep)
 862:	39 05 e0 0b 00 00    	cmp    %eax,0xbe0
 868:	75 ed                	jne    857 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 86a:	89 d8                	mov    %ebx,%eax
 86c:	e8 2c ff ff ff       	call   79d <morecore>
 871:	85 c0                	test   %eax,%eax
 873:	75 e2                	jne    857 <malloc+0x6a>
        return 0;
 875:	b8 00 00 00 00       	mov    $0x0,%eax
 87a:	eb cf                	jmp    84b <malloc+0x5e>
