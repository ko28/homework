
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 80 10 00       	mov    $0x108000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc c0 a5 10 80       	mov    $0x8010a5c0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 52 2a 10 80       	mov    $0x80102a52,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	57                   	push   %edi
80100038:	56                   	push   %esi
80100039:	53                   	push   %ebx
8010003a:	83 ec 18             	sub    $0x18,%esp
8010003d:	89 c6                	mov    %eax,%esi
8010003f:	89 d7                	mov    %edx,%edi
  struct buf *b;

  acquire(&bcache.lock);
80100041:	68 c0 a5 10 80       	push   $0x8010a5c0
80100046:	e8 38 3b 00 00       	call   80103b83 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 10 ed 10 80    	mov    0x8010ed10,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb bc ec 10 80    	cmp    $0x8010ecbc,%ebx
8010005f:	74 30                	je     80100091 <bget+0x5d>
    if(b->dev == dev && b->blockno == blockno){
80100061:	39 73 04             	cmp    %esi,0x4(%ebx)
80100064:	75 f0                	jne    80100056 <bget+0x22>
80100066:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100069:	75 eb                	jne    80100056 <bget+0x22>
      b->refcnt++;
8010006b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010006e:	83 c0 01             	add    $0x1,%eax
80100071:	89 43 4c             	mov    %eax,0x4c(%ebx)
      release(&bcache.lock);
80100074:	83 ec 0c             	sub    $0xc,%esp
80100077:	68 c0 a5 10 80       	push   $0x8010a5c0
8010007c:	e8 67 3b 00 00       	call   80103be8 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 e3 38 00 00       	call   8010396f <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 0c ed 10 80    	mov    0x8010ed0c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb bc ec 10 80    	cmp    $0x8010ecbc,%ebx
801000a2:	74 43                	je     801000e7 <bget+0xb3>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000a4:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801000a8:	75 ef                	jne    80100099 <bget+0x65>
801000aa:	f6 03 04             	testb  $0x4,(%ebx)
801000ad:	75 ea                	jne    80100099 <bget+0x65>
      b->dev = dev;
801000af:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000b2:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000bb:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000c2:	83 ec 0c             	sub    $0xc,%esp
801000c5:	68 c0 a5 10 80       	push   $0x8010a5c0
801000ca:	e8 19 3b 00 00       	call   80103be8 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 95 38 00 00       	call   8010396f <acquiresleep>
      return b;
801000da:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000dd:	89 d8                	mov    %ebx,%eax
801000df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e2:	5b                   	pop    %ebx
801000e3:	5e                   	pop    %esi
801000e4:	5f                   	pop    %edi
801000e5:	5d                   	pop    %ebp
801000e6:	c3                   	ret    
  panic("bget: no buffers");
801000e7:	83 ec 0c             	sub    $0xc,%esp
801000ea:	68 20 65 10 80       	push   $0x80106520
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 31 65 10 80       	push   $0x80106531
80100100:	68 c0 a5 10 80       	push   $0x8010a5c0
80100105:	e8 3d 39 00 00       	call   80103a47 <initlock>
  bcache.head.prev = &bcache.head;
8010010a:	c7 05 0c ed 10 80 bc 	movl   $0x8010ecbc,0x8010ed0c
80100111:	ec 10 80 
  bcache.head.next = &bcache.head;
80100114:	c7 05 10 ed 10 80 bc 	movl   $0x8010ecbc,0x8010ed10
8010011b:	ec 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb f4 a5 10 80       	mov    $0x8010a5f4,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
    b->next = bcache.head.next;
80100128:	a1 10 ed 10 80       	mov    0x8010ed10,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100130:	c7 43 50 bc ec 10 80 	movl   $0x8010ecbc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 38 65 10 80       	push   $0x80106538
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 f4 37 00 00       	call   8010393c <initsleeplock>
    bcache.head.next->prev = b;
80100148:	a1 10 ed 10 80       	mov    0x8010ed10,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100150:	89 1d 10 ed 10 80    	mov    %ebx,0x8010ed10
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb bc ec 10 80    	cmp    $0x8010ecbc,%ebx
80100165:	72 c1                	jb     80100128 <binit+0x34>
}
80100167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010016a:	c9                   	leave  
8010016b:	c3                   	ret    

8010016c <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
8010016c:	55                   	push   %ebp
8010016d:	89 e5                	mov    %esp,%ebp
8010016f:	53                   	push   %ebx
80100170:	83 ec 04             	sub    $0x4,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100173:	8b 55 0c             	mov    0xc(%ebp),%edx
80100176:	8b 45 08             	mov    0x8(%ebp),%eax
80100179:	e8 b6 fe ff ff       	call   80100034 <bget>
8010017e:	89 c3                	mov    %eax,%ebx
  if((b->flags & B_VALID) == 0) {
80100180:	f6 00 02             	testb  $0x2,(%eax)
80100183:	74 07                	je     8010018c <bread+0x20>
    iderw(b);
  }
  return b;
}
80100185:	89 d8                	mov    %ebx,%eax
80100187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010018a:	c9                   	leave  
8010018b:	c3                   	ret    
    iderw(b);
8010018c:	83 ec 0c             	sub    $0xc,%esp
8010018f:	50                   	push   %eax
80100190:	e8 65 1c 00 00       	call   80101dfa <iderw>
80100195:	83 c4 10             	add    $0x10,%esp
  return b;
80100198:	eb eb                	jmp    80100185 <bread+0x19>

8010019a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010019a:	55                   	push   %ebp
8010019b:	89 e5                	mov    %esp,%ebp
8010019d:	53                   	push   %ebx
8010019e:	83 ec 10             	sub    $0x10,%esp
801001a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001a4:	8d 43 0c             	lea    0xc(%ebx),%eax
801001a7:	50                   	push   %eax
801001a8:	e8 4c 38 00 00       	call   801039f9 <holdingsleep>
801001ad:	83 c4 10             	add    $0x10,%esp
801001b0:	85 c0                	test   %eax,%eax
801001b2:	74 14                	je     801001c8 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b4:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b7:	83 ec 0c             	sub    $0xc,%esp
801001ba:	53                   	push   %ebx
801001bb:	e8 3a 1c 00 00       	call   80101dfa <iderw>
}
801001c0:	83 c4 10             	add    $0x10,%esp
801001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c6:	c9                   	leave  
801001c7:	c3                   	ret    
    panic("bwrite");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 3f 65 10 80       	push   $0x8010653f
801001d0:	e8 73 01 00 00       	call   80100348 <panic>

801001d5 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001d5:	55                   	push   %ebp
801001d6:	89 e5                	mov    %esp,%ebp
801001d8:	56                   	push   %esi
801001d9:	53                   	push   %ebx
801001da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001dd:	8d 73 0c             	lea    0xc(%ebx),%esi
801001e0:	83 ec 0c             	sub    $0xc,%esp
801001e3:	56                   	push   %esi
801001e4:	e8 10 38 00 00       	call   801039f9 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 c5 37 00 00       	call   801039be <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 c0 a5 10 80 	movl   $0x8010a5c0,(%esp)
80100200:	e8 7e 39 00 00       	call   80103b83 <acquire>
  b->refcnt--;
80100205:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100208:	83 e8 01             	sub    $0x1,%eax
8010020b:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010020e:	83 c4 10             	add    $0x10,%esp
80100211:	85 c0                	test   %eax,%eax
80100213:	75 2f                	jne    80100244 <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100215:	8b 43 54             	mov    0x54(%ebx),%eax
80100218:	8b 53 50             	mov    0x50(%ebx),%edx
8010021b:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010021e:	8b 43 50             	mov    0x50(%ebx),%eax
80100221:	8b 53 54             	mov    0x54(%ebx),%edx
80100224:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100227:	a1 10 ed 10 80       	mov    0x8010ed10,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022f:	c7 43 50 bc ec 10 80 	movl   $0x8010ecbc,0x50(%ebx)
    bcache.head.next->prev = b;
80100236:	a1 10 ed 10 80       	mov    0x8010ed10,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023e:	89 1d 10 ed 10 80    	mov    %ebx,0x8010ed10
  }
  
  release(&bcache.lock);
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 c0 a5 10 80       	push   $0x8010a5c0
8010024c:	e8 97 39 00 00       	call   80103be8 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 46 65 10 80       	push   $0x80106546
80100263:	e8 e0 00 00 00       	call   80100348 <panic>

80100268 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100268:	55                   	push   %ebp
80100269:	89 e5                	mov    %esp,%ebp
8010026b:	57                   	push   %edi
8010026c:	56                   	push   %esi
8010026d:	53                   	push   %ebx
8010026e:	83 ec 28             	sub    $0x28,%esp
80100271:	8b 7d 08             	mov    0x8(%ebp),%edi
80100274:	8b 75 0c             	mov    0xc(%ebp),%esi
80100277:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
8010027a:	57                   	push   %edi
8010027b:	e8 b1 13 00 00       	call   80101631 <iunlock>
  target = n;
80100280:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
80100283:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
8010028a:	e8 f4 38 00 00       	call   80103b83 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 a0 ef 10 80       	mov    0x8010efa0,%eax
8010029f:	3b 05 a4 ef 10 80    	cmp    0x8010efa4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 38 2f 00 00       	call   801031e4 <myproc>
801002ac:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002b0:	75 17                	jne    801002c9 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b2:	83 ec 08             	sub    $0x8,%esp
801002b5:	68 20 95 10 80       	push   $0x80109520
801002ba:	68 a0 ef 10 80       	push   $0x8010efa0
801002bf:	e8 c4 33 00 00       	call   80103688 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 95 10 80       	push   $0x80109520
801002d1:	e8 12 39 00 00       	call   80103be8 <release>
        ilock(ip);
801002d6:	89 3c 24             	mov    %edi,(%esp)
801002d9:	e8 91 12 00 00       	call   8010156f <ilock>
        return -1;
801002de:	83 c4 10             	add    $0x10,%esp
801002e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002e9:	5b                   	pop    %ebx
801002ea:	5e                   	pop    %esi
801002eb:	5f                   	pop    %edi
801002ec:	5d                   	pop    %ebp
801002ed:	c3                   	ret    
    c = input.buf[input.r++ % INPUT_BUF];
801002ee:	8d 50 01             	lea    0x1(%eax),%edx
801002f1:	89 15 a0 ef 10 80    	mov    %edx,0x8010efa0
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 8a 20 ef 10 80 	movzbl -0x7fef10e0(%edx),%ecx
80100303:	0f be d1             	movsbl %cl,%edx
    if(c == C('D')){  // EOF
80100306:	83 fa 04             	cmp    $0x4,%edx
80100309:	74 14                	je     8010031f <consoleread+0xb7>
    *dst++ = c;
8010030b:	8d 46 01             	lea    0x1(%esi),%eax
8010030e:	88 0e                	mov    %cl,(%esi)
    --n;
80100310:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
80100313:	83 fa 0a             	cmp    $0xa,%edx
80100316:	74 11                	je     80100329 <consoleread+0xc1>
    *dst++ = c;
80100318:	89 c6                	mov    %eax,%esi
8010031a:	e9 73 ff ff ff       	jmp    80100292 <consoleread+0x2a>
      if(n < target){
8010031f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100322:	73 05                	jae    80100329 <consoleread+0xc1>
        input.r--;
80100324:	a3 a0 ef 10 80       	mov    %eax,0x8010efa0
  release(&cons.lock);
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 95 10 80       	push   $0x80109520
80100331:	e8 b2 38 00 00       	call   80103be8 <release>
  ilock(ip);
80100336:	89 3c 24             	mov    %edi,(%esp)
80100339:	e8 31 12 00 00       	call   8010156f <ilock>
  return target - n;
8010033e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100341:	29 d8                	sub    %ebx,%eax
80100343:	83 c4 10             	add    $0x10,%esp
80100346:	eb 9e                	jmp    801002e6 <consoleread+0x7e>

80100348 <panic>:
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	53                   	push   %ebx
8010034c:	83 ec 34             	sub    $0x34,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
8010034f:	fa                   	cli    
  cons.locking = 0;
80100350:	c7 05 54 95 10 80 00 	movl   $0x0,0x80109554
80100357:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
8010035a:	e8 0d 20 00 00       	call   8010236c <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 4d 65 10 80       	push   $0x8010654d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 a3 6e 10 80 	movl   $0x80106ea3,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 ce 36 00 00       	call   80103a62 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 61 65 10 80       	push   $0x80106561
801003aa:	e8 5c 02 00 00       	call   8010060b <cprintf>
  for(i=0; i<10; i++)
801003af:	83 c3 01             	add    $0x1,%ebx
801003b2:	83 c4 10             	add    $0x10,%esp
801003b5:	83 fb 09             	cmp    $0x9,%ebx
801003b8:	7e e4                	jle    8010039e <panic+0x56>
  panicked = 1; // freeze other CPU
801003ba:	c7 05 58 95 10 80 01 	movl   $0x1,0x80109558
801003c1:	00 00 00 
801003c4:	eb fe                	jmp    801003c4 <panic+0x7c>

801003c6 <cgaputc>:
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	57                   	push   %edi
801003ca:	56                   	push   %esi
801003cb:	53                   	push   %ebx
801003cc:	83 ec 0c             	sub    $0xc,%esp
801003cf:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003d1:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
801003d6:	b8 0e 00 00 00       	mov    $0xe,%eax
801003db:	89 ca                	mov    %ecx,%edx
801003dd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003de:	bb d5 03 00 00       	mov    $0x3d5,%ebx
801003e3:	89 da                	mov    %ebx,%edx
801003e5:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801003e6:	0f b6 f8             	movzbl %al,%edi
801003e9:	c1 e7 08             	shl    $0x8,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003ec:	b8 0f 00 00 00       	mov    $0xf,%eax
801003f1:	89 ca                	mov    %ecx,%edx
801003f3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003f4:	89 da                	mov    %ebx,%edx
801003f6:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
801003f7:	0f b6 c8             	movzbl %al,%ecx
801003fa:	09 f9                	or     %edi,%ecx
  if(c == '\n')
801003fc:	83 fe 0a             	cmp    $0xa,%esi
801003ff:	74 6a                	je     8010046b <cgaputc+0xa5>
  else if(c == BACKSPACE){
80100401:	81 fe 00 01 00 00    	cmp    $0x100,%esi
80100407:	0f 84 81 00 00 00    	je     8010048e <cgaputc+0xc8>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010040d:	89 f0                	mov    %esi,%eax
8010040f:	0f b6 f0             	movzbl %al,%esi
80100412:	8d 59 01             	lea    0x1(%ecx),%ebx
80100415:	66 81 ce 00 07       	or     $0x700,%si
8010041a:	66 89 b4 09 00 80 0b 	mov    %si,-0x7ff48000(%ecx,%ecx,1)
80100421:	80 
  if(pos < 0 || pos > 25*80)
80100422:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100428:	77 71                	ja     8010049b <cgaputc+0xd5>
  if((pos/80) >= 24){  // Scroll up.
8010042a:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100430:	7f 76                	jg     801004a8 <cgaputc+0xe2>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100432:	be d4 03 00 00       	mov    $0x3d4,%esi
80100437:	b8 0e 00 00 00       	mov    $0xe,%eax
8010043c:	89 f2                	mov    %esi,%edx
8010043e:	ee                   	out    %al,(%dx)
  outb(CRTPORT+1, pos>>8);
8010043f:	89 d8                	mov    %ebx,%eax
80100441:	c1 f8 08             	sar    $0x8,%eax
80100444:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
80100449:	89 ca                	mov    %ecx,%edx
8010044b:	ee                   	out    %al,(%dx)
8010044c:	b8 0f 00 00 00       	mov    $0xf,%eax
80100451:	89 f2                	mov    %esi,%edx
80100453:	ee                   	out    %al,(%dx)
80100454:	89 d8                	mov    %ebx,%eax
80100456:	89 ca                	mov    %ecx,%edx
80100458:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
80100459:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
80100460:	80 20 07 
}
80100463:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100466:	5b                   	pop    %ebx
80100467:	5e                   	pop    %esi
80100468:	5f                   	pop    %edi
80100469:	5d                   	pop    %ebp
8010046a:	c3                   	ret    
    pos += 80 - pos%80;
8010046b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100470:	89 c8                	mov    %ecx,%eax
80100472:	f7 ea                	imul   %edx
80100474:	c1 fa 05             	sar    $0x5,%edx
80100477:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010047a:	89 d0                	mov    %edx,%eax
8010047c:	c1 e0 04             	shl    $0x4,%eax
8010047f:	89 ca                	mov    %ecx,%edx
80100481:	29 c2                	sub    %eax,%edx
80100483:	bb 50 00 00 00       	mov    $0x50,%ebx
80100488:	29 d3                	sub    %edx,%ebx
8010048a:	01 cb                	add    %ecx,%ebx
8010048c:	eb 94                	jmp    80100422 <cgaputc+0x5c>
    if(pos > 0) --pos;
8010048e:	85 c9                	test   %ecx,%ecx
80100490:	7e 05                	jle    80100497 <cgaputc+0xd1>
80100492:	8d 59 ff             	lea    -0x1(%ecx),%ebx
80100495:	eb 8b                	jmp    80100422 <cgaputc+0x5c>
  pos |= inb(CRTPORT+1);
80100497:	89 cb                	mov    %ecx,%ebx
80100499:	eb 87                	jmp    80100422 <cgaputc+0x5c>
    panic("pos under/overflow");
8010049b:	83 ec 0c             	sub    $0xc,%esp
8010049e:	68 65 65 10 80       	push   $0x80106565
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 eb 37 00 00       	call   80103caa <memmove>
    pos -= 80;
801004bf:	83 eb 50             	sub    $0x50,%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004c2:	b8 80 07 00 00       	mov    $0x780,%eax
801004c7:	29 d8                	sub    %ebx,%eax
801004c9:	8d 94 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edx
801004d0:	83 c4 0c             	add    $0xc,%esp
801004d3:	01 c0                	add    %eax,%eax
801004d5:	50                   	push   %eax
801004d6:	6a 00                	push   $0x0
801004d8:	52                   	push   %edx
801004d9:	e8 51 37 00 00       	call   80103c2f <memset>
801004de:	83 c4 10             	add    $0x10,%esp
801004e1:	e9 4c ff ff ff       	jmp    80100432 <cgaputc+0x6c>

801004e6 <consputc>:
  if(panicked){
801004e6:	83 3d 58 95 10 80 00 	cmpl   $0x0,0x80109558
801004ed:	74 03                	je     801004f2 <consputc+0xc>
  asm volatile("cli");
801004ef:	fa                   	cli    
801004f0:	eb fe                	jmp    801004f0 <consputc+0xa>
{
801004f2:	55                   	push   %ebp
801004f3:	89 e5                	mov    %esp,%ebp
801004f5:	53                   	push   %ebx
801004f6:	83 ec 04             	sub    $0x4,%esp
801004f9:	89 c3                	mov    %eax,%ebx
  if(c == BACKSPACE){
801004fb:	3d 00 01 00 00       	cmp    $0x100,%eax
80100500:	74 18                	je     8010051a <consputc+0x34>
    uartputc(c);
80100502:	83 ec 0c             	sub    $0xc,%esp
80100505:	50                   	push   %eax
80100506:	e8 db 4b 00 00       	call   801050e6 <uartputc>
8010050b:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010050e:	89 d8                	mov    %ebx,%eax
80100510:	e8 b1 fe ff ff       	call   801003c6 <cgaputc>
}
80100515:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100518:	c9                   	leave  
80100519:	c3                   	ret    
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010051a:	83 ec 0c             	sub    $0xc,%esp
8010051d:	6a 08                	push   $0x8
8010051f:	e8 c2 4b 00 00       	call   801050e6 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 b6 4b 00 00       	call   801050e6 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 aa 4b 00 00       	call   801050e6 <uartputc>
8010053c:	83 c4 10             	add    $0x10,%esp
8010053f:	eb cd                	jmp    8010050e <consputc+0x28>

80100541 <printint>:
{
80100541:	55                   	push   %ebp
80100542:	89 e5                	mov    %esp,%ebp
80100544:	57                   	push   %edi
80100545:	56                   	push   %esi
80100546:	53                   	push   %ebx
80100547:	83 ec 1c             	sub    $0x1c,%esp
8010054a:	89 d7                	mov    %edx,%edi
  if(sign && (sign = xx < 0))
8010054c:	85 c9                	test   %ecx,%ecx
8010054e:	74 09                	je     80100559 <printint+0x18>
80100550:	89 c1                	mov    %eax,%ecx
80100552:	c1 e9 1f             	shr    $0x1f,%ecx
80100555:	85 c0                	test   %eax,%eax
80100557:	78 09                	js     80100562 <printint+0x21>
    x = xx;
80100559:	89 c2                	mov    %eax,%edx
  i = 0;
8010055b:	be 00 00 00 00       	mov    $0x0,%esi
80100560:	eb 08                	jmp    8010056a <printint+0x29>
    x = -xx;
80100562:	f7 d8                	neg    %eax
80100564:	89 c2                	mov    %eax,%edx
80100566:	eb f3                	jmp    8010055b <printint+0x1a>
    buf[i++] = digits[x % base];
80100568:	89 de                	mov    %ebx,%esi
8010056a:	89 d0                	mov    %edx,%eax
8010056c:	ba 00 00 00 00       	mov    $0x0,%edx
80100571:	f7 f7                	div    %edi
80100573:	8d 5e 01             	lea    0x1(%esi),%ebx
80100576:	0f b6 92 90 65 10 80 	movzbl -0x7fef9a70(%edx),%edx
8010057d:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
80100581:	89 c2                	mov    %eax,%edx
80100583:	85 c0                	test   %eax,%eax
80100585:	75 e1                	jne    80100568 <printint+0x27>
  if(sign)
80100587:	85 c9                	test   %ecx,%ecx
80100589:	74 14                	je     8010059f <printint+0x5e>
    buf[i++] = '-';
8010058b:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
80100590:	8d 5e 02             	lea    0x2(%esi),%ebx
80100593:	eb 0a                	jmp    8010059f <printint+0x5e>
    consputc(buf[i]);
80100595:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
8010059a:	e8 47 ff ff ff       	call   801004e6 <consputc>
  while(--i >= 0)
8010059f:	83 eb 01             	sub    $0x1,%ebx
801005a2:	79 f1                	jns    80100595 <printint+0x54>
}
801005a4:	83 c4 1c             	add    $0x1c,%esp
801005a7:	5b                   	pop    %ebx
801005a8:	5e                   	pop    %esi
801005a9:	5f                   	pop    %edi
801005aa:	5d                   	pop    %ebp
801005ab:	c3                   	ret    

801005ac <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005ac:	55                   	push   %ebp
801005ad:	89 e5                	mov    %esp,%ebp
801005af:	57                   	push   %edi
801005b0:	56                   	push   %esi
801005b1:	53                   	push   %ebx
801005b2:	83 ec 18             	sub    $0x18,%esp
801005b5:	8b 7d 0c             	mov    0xc(%ebp),%edi
801005b8:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801005bb:	ff 75 08             	pushl  0x8(%ebp)
801005be:	e8 6e 10 00 00       	call   80101631 <iunlock>
  acquire(&cons.lock);
801005c3:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
801005ca:	e8 b4 35 00 00       	call   80103b83 <acquire>
  for(i = 0; i < n; i++)
801005cf:	83 c4 10             	add    $0x10,%esp
801005d2:	bb 00 00 00 00       	mov    $0x0,%ebx
801005d7:	eb 0c                	jmp    801005e5 <consolewrite+0x39>
    consputc(buf[i] & 0xff);
801005d9:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801005dd:	e8 04 ff ff ff       	call   801004e6 <consputc>
  for(i = 0; i < n; i++)
801005e2:	83 c3 01             	add    $0x1,%ebx
801005e5:	39 f3                	cmp    %esi,%ebx
801005e7:	7c f0                	jl     801005d9 <consolewrite+0x2d>
  release(&cons.lock);
801005e9:	83 ec 0c             	sub    $0xc,%esp
801005ec:	68 20 95 10 80       	push   $0x80109520
801005f1:	e8 f2 35 00 00       	call   80103be8 <release>
  ilock(ip);
801005f6:	83 c4 04             	add    $0x4,%esp
801005f9:	ff 75 08             	pushl  0x8(%ebp)
801005fc:	e8 6e 0f 00 00       	call   8010156f <ilock>

  return n;
}
80100601:	89 f0                	mov    %esi,%eax
80100603:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100606:	5b                   	pop    %ebx
80100607:	5e                   	pop    %esi
80100608:	5f                   	pop    %edi
80100609:	5d                   	pop    %ebp
8010060a:	c3                   	ret    

8010060b <cprintf>:
{
8010060b:	55                   	push   %ebp
8010060c:	89 e5                	mov    %esp,%ebp
8010060e:	57                   	push   %edi
8010060f:	56                   	push   %esi
80100610:	53                   	push   %ebx
80100611:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
80100614:	a1 54 95 10 80       	mov    0x80109554,%eax
80100619:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(locking)
8010061c:	85 c0                	test   %eax,%eax
8010061e:	75 10                	jne    80100630 <cprintf+0x25>
  if (fmt == 0)
80100620:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80100624:	74 1c                	je     80100642 <cprintf+0x37>
  argp = (uint*)(void*)(&fmt + 1);
80100626:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100629:	bb 00 00 00 00       	mov    $0x0,%ebx
8010062e:	eb 27                	jmp    80100657 <cprintf+0x4c>
    acquire(&cons.lock);
80100630:	83 ec 0c             	sub    $0xc,%esp
80100633:	68 20 95 10 80       	push   $0x80109520
80100638:	e8 46 35 00 00       	call   80103b83 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 7f 65 10 80       	push   $0x8010657f
8010064a:	e8 f9 fc ff ff       	call   80100348 <panic>
      consputc(c);
8010064f:	e8 92 fe ff ff       	call   801004e6 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100654:	83 c3 01             	add    $0x1,%ebx
80100657:	8b 55 08             	mov    0x8(%ebp),%edx
8010065a:	0f b6 04 1a          	movzbl (%edx,%ebx,1),%eax
8010065e:	85 c0                	test   %eax,%eax
80100660:	0f 84 b8 00 00 00    	je     8010071e <cprintf+0x113>
    if(c != '%'){
80100666:	83 f8 25             	cmp    $0x25,%eax
80100669:	75 e4                	jne    8010064f <cprintf+0x44>
    c = fmt[++i] & 0xff;
8010066b:	83 c3 01             	add    $0x1,%ebx
8010066e:	0f b6 34 1a          	movzbl (%edx,%ebx,1),%esi
    if(c == 0)
80100672:	85 f6                	test   %esi,%esi
80100674:	0f 84 a4 00 00 00    	je     8010071e <cprintf+0x113>
    switch(c){
8010067a:	83 fe 70             	cmp    $0x70,%esi
8010067d:	74 48                	je     801006c7 <cprintf+0xbc>
8010067f:	83 fe 70             	cmp    $0x70,%esi
80100682:	7f 26                	jg     801006aa <cprintf+0x9f>
80100684:	83 fe 25             	cmp    $0x25,%esi
80100687:	0f 84 82 00 00 00    	je     8010070f <cprintf+0x104>
8010068d:	83 fe 64             	cmp    $0x64,%esi
80100690:	75 22                	jne    801006b4 <cprintf+0xa9>
      printint(*argp++, 10, 1);
80100692:	8d 77 04             	lea    0x4(%edi),%esi
80100695:	8b 07                	mov    (%edi),%eax
80100697:	b9 01 00 00 00       	mov    $0x1,%ecx
8010069c:	ba 0a 00 00 00       	mov    $0xa,%edx
801006a1:	e8 9b fe ff ff       	call   80100541 <printint>
801006a6:	89 f7                	mov    %esi,%edi
      break;
801006a8:	eb aa                	jmp    80100654 <cprintf+0x49>
    switch(c){
801006aa:	83 fe 73             	cmp    $0x73,%esi
801006ad:	74 33                	je     801006e2 <cprintf+0xd7>
801006af:	83 fe 78             	cmp    $0x78,%esi
801006b2:	74 13                	je     801006c7 <cprintf+0xbc>
      consputc('%');
801006b4:	b8 25 00 00 00       	mov    $0x25,%eax
801006b9:	e8 28 fe ff ff       	call   801004e6 <consputc>
      consputc(c);
801006be:	89 f0                	mov    %esi,%eax
801006c0:	e8 21 fe ff ff       	call   801004e6 <consputc>
      break;
801006c5:	eb 8d                	jmp    80100654 <cprintf+0x49>
      printint(*argp++, 16, 0);
801006c7:	8d 77 04             	lea    0x4(%edi),%esi
801006ca:	8b 07                	mov    (%edi),%eax
801006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
801006d1:	ba 10 00 00 00       	mov    $0x10,%edx
801006d6:	e8 66 fe ff ff       	call   80100541 <printint>
801006db:	89 f7                	mov    %esi,%edi
      break;
801006dd:	e9 72 ff ff ff       	jmp    80100654 <cprintf+0x49>
      if((s = (char*)*argp++) == 0)
801006e2:	8d 47 04             	lea    0x4(%edi),%eax
801006e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801006e8:	8b 37                	mov    (%edi),%esi
801006ea:	85 f6                	test   %esi,%esi
801006ec:	75 12                	jne    80100700 <cprintf+0xf5>
        s = "(null)";
801006ee:	be 78 65 10 80       	mov    $0x80106578,%esi
801006f3:	eb 0b                	jmp    80100700 <cprintf+0xf5>
        consputc(*s);
801006f5:	0f be c0             	movsbl %al,%eax
801006f8:	e8 e9 fd ff ff       	call   801004e6 <consputc>
      for(; *s; s++)
801006fd:	83 c6 01             	add    $0x1,%esi
80100700:	0f b6 06             	movzbl (%esi),%eax
80100703:	84 c0                	test   %al,%al
80100705:	75 ee                	jne    801006f5 <cprintf+0xea>
      if((s = (char*)*argp++) == 0)
80100707:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010070a:	e9 45 ff ff ff       	jmp    80100654 <cprintf+0x49>
      consputc('%');
8010070f:	b8 25 00 00 00       	mov    $0x25,%eax
80100714:	e8 cd fd ff ff       	call   801004e6 <consputc>
      break;
80100719:	e9 36 ff ff ff       	jmp    80100654 <cprintf+0x49>
  if(locking)
8010071e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100722:	75 08                	jne    8010072c <cprintf+0x121>
}
80100724:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100727:	5b                   	pop    %ebx
80100728:	5e                   	pop    %esi
80100729:	5f                   	pop    %edi
8010072a:	5d                   	pop    %ebp
8010072b:	c3                   	ret    
    release(&cons.lock);
8010072c:	83 ec 0c             	sub    $0xc,%esp
8010072f:	68 20 95 10 80       	push   $0x80109520
80100734:	e8 af 34 00 00       	call   80103be8 <release>
80100739:	83 c4 10             	add    $0x10,%esp
}
8010073c:	eb e6                	jmp    80100724 <cprintf+0x119>

8010073e <consoleintr>:
{
8010073e:	55                   	push   %ebp
8010073f:	89 e5                	mov    %esp,%ebp
80100741:	57                   	push   %edi
80100742:	56                   	push   %esi
80100743:	53                   	push   %ebx
80100744:	83 ec 18             	sub    $0x18,%esp
80100747:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&cons.lock);
8010074a:	68 20 95 10 80       	push   $0x80109520
8010074f:	e8 2f 34 00 00       	call   80103b83 <acquire>
  while((c = getc()) >= 0){
80100754:	83 c4 10             	add    $0x10,%esp
  int c, doprocdump = 0;
80100757:	be 00 00 00 00       	mov    $0x0,%esi
  while((c = getc()) >= 0){
8010075c:	e9 c5 00 00 00       	jmp    80100826 <consoleintr+0xe8>
    switch(c){
80100761:	83 ff 08             	cmp    $0x8,%edi
80100764:	0f 84 e0 00 00 00    	je     8010084a <consoleintr+0x10c>
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010076a:	85 ff                	test   %edi,%edi
8010076c:	0f 84 b4 00 00 00    	je     80100826 <consoleintr+0xe8>
80100772:	a1 a8 ef 10 80       	mov    0x8010efa8,%eax
80100777:	89 c2                	mov    %eax,%edx
80100779:	2b 15 a0 ef 10 80    	sub    0x8010efa0,%edx
8010077f:	83 fa 7f             	cmp    $0x7f,%edx
80100782:	0f 87 9e 00 00 00    	ja     80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100788:	83 ff 0d             	cmp    $0xd,%edi
8010078b:	0f 84 86 00 00 00    	je     80100817 <consoleintr+0xd9>
        input.buf[input.e++ % INPUT_BUF] = c;
80100791:	8d 50 01             	lea    0x1(%eax),%edx
80100794:	89 15 a8 ef 10 80    	mov    %edx,0x8010efa8
8010079a:	83 e0 7f             	and    $0x7f,%eax
8010079d:	89 f9                	mov    %edi,%ecx
8010079f:	88 88 20 ef 10 80    	mov    %cl,-0x7fef10e0(%eax)
        consputc(c);
801007a5:	89 f8                	mov    %edi,%eax
801007a7:	e8 3a fd ff ff       	call   801004e6 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801007ac:	83 ff 0a             	cmp    $0xa,%edi
801007af:	0f 94 c2             	sete   %dl
801007b2:	83 ff 04             	cmp    $0x4,%edi
801007b5:	0f 94 c0             	sete   %al
801007b8:	08 c2                	or     %al,%dl
801007ba:	75 10                	jne    801007cc <consoleintr+0x8e>
801007bc:	a1 a0 ef 10 80       	mov    0x8010efa0,%eax
801007c1:	83 e8 80             	sub    $0xffffff80,%eax
801007c4:	39 05 a8 ef 10 80    	cmp    %eax,0x8010efa8
801007ca:	75 5a                	jne    80100826 <consoleintr+0xe8>
          input.w = input.e;
801007cc:	a1 a8 ef 10 80       	mov    0x8010efa8,%eax
801007d1:	a3 a4 ef 10 80       	mov    %eax,0x8010efa4
          wakeup(&input.r);
801007d6:	83 ec 0c             	sub    $0xc,%esp
801007d9:	68 a0 ef 10 80       	push   $0x8010efa0
801007de:	e8 0a 30 00 00       	call   801037ed <wakeup>
801007e3:	83 c4 10             	add    $0x10,%esp
801007e6:	eb 3e                	jmp    80100826 <consoleintr+0xe8>
        input.e--;
801007e8:	a3 a8 ef 10 80       	mov    %eax,0x8010efa8
        consputc(BACKSPACE);
801007ed:	b8 00 01 00 00       	mov    $0x100,%eax
801007f2:	e8 ef fc ff ff       	call   801004e6 <consputc>
      while(input.e != input.w &&
801007f7:	a1 a8 ef 10 80       	mov    0x8010efa8,%eax
801007fc:	3b 05 a4 ef 10 80    	cmp    0x8010efa4,%eax
80100802:	74 22                	je     80100826 <consoleintr+0xe8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100804:	83 e8 01             	sub    $0x1,%eax
80100807:	89 c2                	mov    %eax,%edx
80100809:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
8010080c:	80 ba 20 ef 10 80 0a 	cmpb   $0xa,-0x7fef10e0(%edx)
80100813:	75 d3                	jne    801007e8 <consoleintr+0xaa>
80100815:	eb 0f                	jmp    80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100817:	bf 0a 00 00 00       	mov    $0xa,%edi
8010081c:	e9 70 ff ff ff       	jmp    80100791 <consoleintr+0x53>
      doprocdump = 1;
80100821:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
80100826:	ff d3                	call   *%ebx
80100828:	89 c7                	mov    %eax,%edi
8010082a:	85 c0                	test   %eax,%eax
8010082c:	78 3d                	js     8010086b <consoleintr+0x12d>
    switch(c){
8010082e:	83 ff 10             	cmp    $0x10,%edi
80100831:	74 ee                	je     80100821 <consoleintr+0xe3>
80100833:	83 ff 10             	cmp    $0x10,%edi
80100836:	0f 8e 25 ff ff ff    	jle    80100761 <consoleintr+0x23>
8010083c:	83 ff 15             	cmp    $0x15,%edi
8010083f:	74 b6                	je     801007f7 <consoleintr+0xb9>
80100841:	83 ff 7f             	cmp    $0x7f,%edi
80100844:	0f 85 20 ff ff ff    	jne    8010076a <consoleintr+0x2c>
      if(input.e != input.w){
8010084a:	a1 a8 ef 10 80       	mov    0x8010efa8,%eax
8010084f:	3b 05 a4 ef 10 80    	cmp    0x8010efa4,%eax
80100855:	74 cf                	je     80100826 <consoleintr+0xe8>
        input.e--;
80100857:	83 e8 01             	sub    $0x1,%eax
8010085a:	a3 a8 ef 10 80       	mov    %eax,0x8010efa8
        consputc(BACKSPACE);
8010085f:	b8 00 01 00 00       	mov    $0x100,%eax
80100864:	e8 7d fc ff ff       	call   801004e6 <consputc>
80100869:	eb bb                	jmp    80100826 <consoleintr+0xe8>
  release(&cons.lock);
8010086b:	83 ec 0c             	sub    $0xc,%esp
8010086e:	68 20 95 10 80       	push   $0x80109520
80100873:	e8 70 33 00 00       	call   80103be8 <release>
  if(doprocdump) {
80100878:	83 c4 10             	add    $0x10,%esp
8010087b:	85 f6                	test   %esi,%esi
8010087d:	75 08                	jne    80100887 <consoleintr+0x149>
}
8010087f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100882:	5b                   	pop    %ebx
80100883:	5e                   	pop    %esi
80100884:	5f                   	pop    %edi
80100885:	5d                   	pop    %ebp
80100886:	c3                   	ret    
    procdump();  // now call procdump() wo. cons.lock held
80100887:	e8 fe 2f 00 00       	call   8010388a <procdump>
}
8010088c:	eb f1                	jmp    8010087f <consoleintr+0x141>

8010088e <consoleinit>:

void
consoleinit(void)
{
8010088e:	55                   	push   %ebp
8010088f:	89 e5                	mov    %esp,%ebp
80100891:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100894:	68 88 65 10 80       	push   $0x80106588
80100899:	68 20 95 10 80       	push   $0x80109520
8010089e:	e8 a4 31 00 00       	call   80103a47 <initlock>

  devsw[CONSOLE].write = consolewrite;
801008a3:	c7 05 6c f9 10 80 ac 	movl   $0x801005ac,0x8010f96c
801008aa:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008ad:	c7 05 68 f9 10 80 68 	movl   $0x80100268,0x8010f968
801008b4:	02 10 80 
  cons.locking = 1;
801008b7:	c7 05 54 95 10 80 01 	movl   $0x1,0x80109554
801008be:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801008c1:	83 c4 08             	add    $0x8,%esp
801008c4:	6a 00                	push   $0x0
801008c6:	6a 01                	push   $0x1
801008c8:	e8 9f 16 00 00       	call   80101f6c <ioapicenable>
}
801008cd:	83 c4 10             	add    $0x10,%esp
801008d0:	c9                   	leave  
801008d1:	c3                   	ret    

801008d2 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801008d2:	55                   	push   %ebp
801008d3:	89 e5                	mov    %esp,%ebp
801008d5:	57                   	push   %edi
801008d6:	56                   	push   %esi
801008d7:	53                   	push   %ebx
801008d8:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
801008de:	e8 01 29 00 00       	call   801031e4 <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 ae 1e 00 00       	call   8010279c <begin_op>

  if((ip = namei(path)) == 0){
801008ee:	83 ec 0c             	sub    $0xc,%esp
801008f1:	ff 75 08             	pushl  0x8(%ebp)
801008f4:	e8 d6 12 00 00       	call   80101bcf <namei>
801008f9:	83 c4 10             	add    $0x10,%esp
801008fc:	85 c0                	test   %eax,%eax
801008fe:	74 4a                	je     8010094a <exec+0x78>
80100900:	89 c3                	mov    %eax,%ebx
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100902:	83 ec 0c             	sub    $0xc,%esp
80100905:	50                   	push   %eax
80100906:	e8 64 0c 00 00       	call   8010156f <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
8010090b:	6a 34                	push   $0x34
8010090d:	6a 00                	push   $0x0
8010090f:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100915:	50                   	push   %eax
80100916:	53                   	push   %ebx
80100917:	e8 45 0e 00 00       	call   80101761 <readi>
8010091c:	83 c4 20             	add    $0x20,%esp
8010091f:	83 f8 34             	cmp    $0x34,%eax
80100922:	74 42                	je     80100966 <exec+0x94>
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
80100924:	85 db                	test   %ebx,%ebx
80100926:	0f 84 dd 02 00 00    	je     80100c09 <exec+0x337>
    iunlockput(ip);
8010092c:	83 ec 0c             	sub    $0xc,%esp
8010092f:	53                   	push   %ebx
80100930:	e8 e1 0d 00 00       	call   80101716 <iunlockput>
    end_op();
80100935:	e8 dc 1e 00 00       	call   80102816 <end_op>
8010093a:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
8010093d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100942:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100945:	5b                   	pop    %ebx
80100946:	5e                   	pop    %esi
80100947:	5f                   	pop    %edi
80100948:	5d                   	pop    %ebp
80100949:	c3                   	ret    
    end_op();
8010094a:	e8 c7 1e 00 00       	call   80102816 <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 a1 65 10 80       	push   $0x801065a1
80100957:	e8 af fc ff ff       	call   8010060b <cprintf>
    return -1;
8010095c:	83 c4 10             	add    $0x10,%esp
8010095f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100964:	eb dc                	jmp    80100942 <exec+0x70>
  if(elf.magic != ELF_MAGIC)
80100966:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
8010096d:	45 4c 46 
80100970:	75 b2                	jne    80100924 <exec+0x52>
  if((pgdir = setupkvm()) == 0)
80100972:	e8 2f 59 00 00       	call   801062a6 <setupkvm>
80100977:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
8010097d:	85 c0                	test   %eax,%eax
8010097f:	0f 84 06 01 00 00    	je     80100a8b <exec+0x1b9>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100985:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  sz = 0;
8010098b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100990:	be 00 00 00 00       	mov    $0x0,%esi
80100995:	eb 0c                	jmp    801009a3 <exec+0xd1>
80100997:	83 c6 01             	add    $0x1,%esi
8010099a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
801009a0:	83 c0 20             	add    $0x20,%eax
801009a3:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
801009aa:	39 f2                	cmp    %esi,%edx
801009ac:	0f 8e 98 00 00 00    	jle    80100a4a <exec+0x178>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801009b2:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009b8:	6a 20                	push   $0x20
801009ba:	50                   	push   %eax
801009bb:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
801009c1:	50                   	push   %eax
801009c2:	53                   	push   %ebx
801009c3:	e8 99 0d 00 00       	call   80101761 <readi>
801009c8:	83 c4 10             	add    $0x10,%esp
801009cb:	83 f8 20             	cmp    $0x20,%eax
801009ce:	0f 85 b7 00 00 00    	jne    80100a8b <exec+0x1b9>
    if(ph.type != ELF_PROG_LOAD)
801009d4:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
801009db:	75 ba                	jne    80100997 <exec+0xc5>
    if(ph.memsz < ph.filesz)
801009dd:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
801009e3:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
801009e9:	0f 82 9c 00 00 00    	jb     80100a8b <exec+0x1b9>
    if(ph.vaddr + ph.memsz < ph.vaddr)
801009ef:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
801009f5:	0f 82 90 00 00 00    	jb     80100a8b <exec+0x1b9>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
801009fb:	83 ec 04             	sub    $0x4,%esp
801009fe:	50                   	push   %eax
801009ff:	57                   	push   %edi
80100a00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a06:	e8 41 57 00 00       	call   8010614c <allocuvm>
80100a0b:	89 c7                	mov    %eax,%edi
80100a0d:	83 c4 10             	add    $0x10,%esp
80100a10:	85 c0                	test   %eax,%eax
80100a12:	74 77                	je     80100a8b <exec+0x1b9>
    if(ph.vaddr % PGSIZE != 0)
80100a14:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a1a:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a1f:	75 6a                	jne    80100a8b <exec+0x1b9>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a21:	83 ec 0c             	sub    $0xc,%esp
80100a24:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100a2a:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100a30:	53                   	push   %ebx
80100a31:	50                   	push   %eax
80100a32:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a38:	e8 dd 55 00 00       	call   8010601a <loaduvm>
80100a3d:	83 c4 20             	add    $0x20,%esp
80100a40:	85 c0                	test   %eax,%eax
80100a42:	0f 89 4f ff ff ff    	jns    80100997 <exec+0xc5>
 bad:
80100a48:	eb 41                	jmp    80100a8b <exec+0x1b9>
  iunlockput(ip);
80100a4a:	83 ec 0c             	sub    $0xc,%esp
80100a4d:	53                   	push   %ebx
80100a4e:	e8 c3 0c 00 00       	call   80101716 <iunlockput>
  end_op();
80100a53:	e8 be 1d 00 00       	call   80102816 <end_op>
  sz = PGROUNDUP(sz);
80100a58:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a63:	83 c4 0c             	add    $0xc,%esp
80100a66:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a6c:	52                   	push   %edx
80100a6d:	50                   	push   %eax
80100a6e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a74:	e8 d3 56 00 00       	call   8010614c <allocuvm>
80100a79:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100a7f:	83 c4 10             	add    $0x10,%esp
80100a82:	85 c0                	test   %eax,%eax
80100a84:	75 24                	jne    80100aaa <exec+0x1d8>
  ip = 0;
80100a86:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(pgdir)
80100a8b:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a91:	85 c0                	test   %eax,%eax
80100a93:	0f 84 8b fe ff ff    	je     80100924 <exec+0x52>
    freevm(pgdir);
80100a99:	83 ec 0c             	sub    $0xc,%esp
80100a9c:	50                   	push   %eax
80100a9d:	e8 94 57 00 00       	call   80106236 <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 6a 58 00 00       	call   8010632b <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100ac1:	83 c4 10             	add    $0x10,%esp
80100ac4:	bb 00 00 00 00       	mov    $0x0,%ebx
80100ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
80100acc:	8d 34 98             	lea    (%eax,%ebx,4),%esi
80100acf:	8b 06                	mov    (%esi),%eax
80100ad1:	85 c0                	test   %eax,%eax
80100ad3:	74 4d                	je     80100b22 <exec+0x250>
    if(argc >= MAXARG)
80100ad5:	83 fb 1f             	cmp    $0x1f,%ebx
80100ad8:	0f 87 0d 01 00 00    	ja     80100beb <exec+0x319>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 ea 32 00 00       	call   80103dd1 <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 d8 32 00 00       	call   80103dd1 <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 6e 59 00 00       	call   80106479 <copyout>
80100b0b:	83 c4 20             	add    $0x20,%esp
80100b0e:	85 c0                	test   %eax,%eax
80100b10:	0f 88 df 00 00 00    	js     80100bf5 <exec+0x323>
    ustack[3+argc] = sp;
80100b16:	89 bc 9d 64 ff ff ff 	mov    %edi,-0x9c(%ebp,%ebx,4)
  for(argc = 0; argv[argc]; argc++) {
80100b1d:	83 c3 01             	add    $0x1,%ebx
80100b20:	eb a7                	jmp    80100ac9 <exec+0x1f7>
  ustack[3+argc] = 0;
80100b22:	c7 84 9d 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%ebx,4)
80100b29:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100b2d:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b34:	ff ff ff 
  ustack[1] = argc;
80100b37:	89 9d 5c ff ff ff    	mov    %ebx,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b3d:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
80100b44:	89 f9                	mov    %edi,%ecx
80100b46:	29 c1                	sub    %eax,%ecx
80100b48:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b4e:	8d 04 9d 10 00 00 00 	lea    0x10(,%ebx,4),%eax
80100b55:	29 c7                	sub    %eax,%edi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b57:	50                   	push   %eax
80100b58:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b5e:	50                   	push   %eax
80100b5f:	57                   	push   %edi
80100b60:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b66:	e8 0e 59 00 00       	call   80106479 <copyout>
80100b6b:	83 c4 10             	add    $0x10,%esp
80100b6e:	85 c0                	test   %eax,%eax
80100b70:	0f 88 89 00 00 00    	js     80100bff <exec+0x32d>
  for(last=s=path; *s; s++)
80100b76:	8b 55 08             	mov    0x8(%ebp),%edx
80100b79:	89 d0                	mov    %edx,%eax
80100b7b:	eb 03                	jmp    80100b80 <exec+0x2ae>
80100b7d:	83 c0 01             	add    $0x1,%eax
80100b80:	0f b6 08             	movzbl (%eax),%ecx
80100b83:	84 c9                	test   %cl,%cl
80100b85:	74 0a                	je     80100b91 <exec+0x2bf>
    if(*s == '/')
80100b87:	80 f9 2f             	cmp    $0x2f,%cl
80100b8a:	75 f1                	jne    80100b7d <exec+0x2ab>
      last = s+1;
80100b8c:	8d 50 01             	lea    0x1(%eax),%edx
80100b8f:	eb ec                	jmp    80100b7d <exec+0x2ab>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100b91:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100b97:	89 f0                	mov    %esi,%eax
80100b99:	83 c0 6c             	add    $0x6c,%eax
80100b9c:	83 ec 04             	sub    $0x4,%esp
80100b9f:	6a 10                	push   $0x10
80100ba1:	52                   	push   %edx
80100ba2:	50                   	push   %eax
80100ba3:	e8 ee 31 00 00       	call   80103d96 <safestrcpy>
  oldpgdir = curproc->pgdir;
80100ba8:	8b 5e 04             	mov    0x4(%esi),%ebx
  curproc->pgdir = pgdir;
80100bab:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100bb1:	89 4e 04             	mov    %ecx,0x4(%esi)
  curproc->sz = sz;
80100bb4:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100bba:	89 0e                	mov    %ecx,(%esi)
  curproc->tf->eip = elf.entry;  // main
80100bbc:	8b 46 18             	mov    0x18(%esi),%eax
80100bbf:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100bc5:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100bc8:	8b 46 18             	mov    0x18(%esi),%eax
80100bcb:	89 78 44             	mov    %edi,0x44(%eax)
  switchuvm(curproc);
80100bce:	89 34 24             	mov    %esi,(%esp)
80100bd1:	e8 c3 52 00 00       	call   80105e99 <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 58 56 00 00       	call   80106236 <freevm>
  return 0;
80100bde:	83 c4 10             	add    $0x10,%esp
80100be1:	b8 00 00 00 00       	mov    $0x0,%eax
80100be6:	e9 57 fd ff ff       	jmp    80100942 <exec+0x70>
  ip = 0;
80100beb:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bf0:	e9 96 fe ff ff       	jmp    80100a8b <exec+0x1b9>
80100bf5:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bfa:	e9 8c fe ff ff       	jmp    80100a8b <exec+0x1b9>
80100bff:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c04:	e9 82 fe ff ff       	jmp    80100a8b <exec+0x1b9>
  return -1;
80100c09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c0e:	e9 2f fd ff ff       	jmp    80100942 <exec+0x70>

80100c13 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c13:	55                   	push   %ebp
80100c14:	89 e5                	mov    %esp,%ebp
80100c16:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100c19:	68 ad 65 10 80       	push   $0x801065ad
80100c1e:	68 c0 ef 10 80       	push   $0x8010efc0
80100c23:	e8 1f 2e 00 00       	call   80103a47 <initlock>
}
80100c28:	83 c4 10             	add    $0x10,%esp
80100c2b:	c9                   	leave  
80100c2c:	c3                   	ret    

80100c2d <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c2d:	55                   	push   %ebp
80100c2e:	89 e5                	mov    %esp,%ebp
80100c30:	53                   	push   %ebx
80100c31:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c34:	68 c0 ef 10 80       	push   $0x8010efc0
80100c39:	e8 45 2f 00 00       	call   80103b83 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c3e:	83 c4 10             	add    $0x10,%esp
80100c41:	bb f4 ef 10 80       	mov    $0x8010eff4,%ebx
80100c46:	81 fb 54 f9 10 80    	cmp    $0x8010f954,%ebx
80100c4c:	73 29                	jae    80100c77 <filealloc+0x4a>
    if(f->ref == 0){
80100c4e:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c52:	74 05                	je     80100c59 <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c54:	83 c3 18             	add    $0x18,%ebx
80100c57:	eb ed                	jmp    80100c46 <filealloc+0x19>
      f->ref = 1;
80100c59:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c60:	83 ec 0c             	sub    $0xc,%esp
80100c63:	68 c0 ef 10 80       	push   $0x8010efc0
80100c68:	e8 7b 2f 00 00       	call   80103be8 <release>
      return f;
80100c6d:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c70:	89 d8                	mov    %ebx,%eax
80100c72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c75:	c9                   	leave  
80100c76:	c3                   	ret    
  release(&ftable.lock);
80100c77:	83 ec 0c             	sub    $0xc,%esp
80100c7a:	68 c0 ef 10 80       	push   $0x8010efc0
80100c7f:	e8 64 2f 00 00       	call   80103be8 <release>
  return 0;
80100c84:	83 c4 10             	add    $0x10,%esp
80100c87:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c8c:	eb e2                	jmp    80100c70 <filealloc+0x43>

80100c8e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100c8e:	55                   	push   %ebp
80100c8f:	89 e5                	mov    %esp,%ebp
80100c91:	53                   	push   %ebx
80100c92:	83 ec 10             	sub    $0x10,%esp
80100c95:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100c98:	68 c0 ef 10 80       	push   $0x8010efc0
80100c9d:	e8 e1 2e 00 00       	call   80103b83 <acquire>
  if(f->ref < 1)
80100ca2:	8b 43 04             	mov    0x4(%ebx),%eax
80100ca5:	83 c4 10             	add    $0x10,%esp
80100ca8:	85 c0                	test   %eax,%eax
80100caa:	7e 1a                	jle    80100cc6 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100cac:	83 c0 01             	add    $0x1,%eax
80100caf:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100cb2:	83 ec 0c             	sub    $0xc,%esp
80100cb5:	68 c0 ef 10 80       	push   $0x8010efc0
80100cba:	e8 29 2f 00 00       	call   80103be8 <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 b4 65 10 80       	push   $0x801065b4
80100cce:	e8 75 f6 ff ff       	call   80100348 <panic>

80100cd3 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100cd3:	55                   	push   %ebp
80100cd4:	89 e5                	mov    %esp,%ebp
80100cd6:	53                   	push   %ebx
80100cd7:	83 ec 30             	sub    $0x30,%esp
80100cda:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100cdd:	68 c0 ef 10 80       	push   $0x8010efc0
80100ce2:	e8 9c 2e 00 00       	call   80103b83 <acquire>
  if(f->ref < 1)
80100ce7:	8b 43 04             	mov    0x4(%ebx),%eax
80100cea:	83 c4 10             	add    $0x10,%esp
80100ced:	85 c0                	test   %eax,%eax
80100cef:	7e 1f                	jle    80100d10 <fileclose+0x3d>
    panic("fileclose");
  if(--f->ref > 0){
80100cf1:	83 e8 01             	sub    $0x1,%eax
80100cf4:	89 43 04             	mov    %eax,0x4(%ebx)
80100cf7:	85 c0                	test   %eax,%eax
80100cf9:	7e 22                	jle    80100d1d <fileclose+0x4a>
    release(&ftable.lock);
80100cfb:	83 ec 0c             	sub    $0xc,%esp
80100cfe:	68 c0 ef 10 80       	push   $0x8010efc0
80100d03:	e8 e0 2e 00 00       	call   80103be8 <release>
    return;
80100d08:	83 c4 10             	add    $0x10,%esp
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100d0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d0e:	c9                   	leave  
80100d0f:	c3                   	ret    
    panic("fileclose");
80100d10:	83 ec 0c             	sub    $0xc,%esp
80100d13:	68 bc 65 10 80       	push   $0x801065bc
80100d18:	e8 2b f6 ff ff       	call   80100348 <panic>
  ff = *f;
80100d1d:	8b 03                	mov    (%ebx),%eax
80100d1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d22:	8b 43 08             	mov    0x8(%ebx),%eax
80100d25:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d28:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d2e:	8b 43 10             	mov    0x10(%ebx),%eax
80100d31:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f->ref = 0;
80100d34:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100d3b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d41:	83 ec 0c             	sub    $0xc,%esp
80100d44:	68 c0 ef 10 80       	push   $0x8010efc0
80100d49:	e8 9a 2e 00 00       	call   80103be8 <release>
  if(ff.type == FD_PIPE)
80100d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	83 f8 01             	cmp    $0x1,%eax
80100d57:	74 1f                	je     80100d78 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d59:	83 f8 02             	cmp    $0x2,%eax
80100d5c:	75 ad                	jne    80100d0b <fileclose+0x38>
    begin_op();
80100d5e:	e8 39 1a 00 00       	call   8010279c <begin_op>
    iput(ff.ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 75 f0             	pushl  -0x10(%ebp)
80100d69:	e8 08 09 00 00       	call   80101676 <iput>
    end_op();
80100d6e:	e8 a3 1a 00 00       	call   80102816 <end_op>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	eb 93                	jmp    80100d0b <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d78:	83 ec 08             	sub    $0x8,%esp
80100d7b:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7f:	50                   	push   %eax
80100d80:	ff 75 ec             	pushl  -0x14(%ebp)
80100d83:	e8 88 20 00 00       	call   80102e10 <pipeclose>
80100d88:	83 c4 10             	add    $0x10,%esp
80100d8b:	e9 7b ff ff ff       	jmp    80100d0b <fileclose+0x38>

80100d90 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100d90:	55                   	push   %ebp
80100d91:	89 e5                	mov    %esp,%ebp
80100d93:	53                   	push   %ebx
80100d94:	83 ec 04             	sub    $0x4,%esp
80100d97:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100d9a:	83 3b 02             	cmpl   $0x2,(%ebx)
80100d9d:	75 31                	jne    80100dd0 <filestat+0x40>
    ilock(f->ip);
80100d9f:	83 ec 0c             	sub    $0xc,%esp
80100da2:	ff 73 10             	pushl  0x10(%ebx)
80100da5:	e8 c5 07 00 00       	call   8010156f <ilock>
    stati(f->ip, st);
80100daa:	83 c4 08             	add    $0x8,%esp
80100dad:	ff 75 0c             	pushl  0xc(%ebp)
80100db0:	ff 73 10             	pushl  0x10(%ebx)
80100db3:	e8 7e 09 00 00       	call   80101736 <stati>
    iunlock(f->ip);
80100db8:	83 c4 04             	add    $0x4,%esp
80100dbb:	ff 73 10             	pushl  0x10(%ebx)
80100dbe:	e8 6e 08 00 00       	call   80101631 <iunlock>
    return 0;
80100dc3:	83 c4 10             	add    $0x10,%esp
80100dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100dcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100dce:	c9                   	leave  
80100dcf:	c3                   	ret    
  return -1;
80100dd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100dd5:	eb f4                	jmp    80100dcb <filestat+0x3b>

80100dd7 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100dd7:	55                   	push   %ebp
80100dd8:	89 e5                	mov    %esp,%ebp
80100dda:	56                   	push   %esi
80100ddb:	53                   	push   %ebx
80100ddc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100ddf:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100de3:	74 70                	je     80100e55 <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100de5:	8b 03                	mov    (%ebx),%eax
80100de7:	83 f8 01             	cmp    $0x1,%eax
80100dea:	74 44                	je     80100e30 <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100dec:	83 f8 02             	cmp    $0x2,%eax
80100def:	75 57                	jne    80100e48 <fileread+0x71>
    ilock(f->ip);
80100df1:	83 ec 0c             	sub    $0xc,%esp
80100df4:	ff 73 10             	pushl  0x10(%ebx)
80100df7:	e8 73 07 00 00       	call   8010156f <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100dfc:	ff 75 10             	pushl  0x10(%ebp)
80100dff:	ff 73 14             	pushl  0x14(%ebx)
80100e02:	ff 75 0c             	pushl  0xc(%ebp)
80100e05:	ff 73 10             	pushl  0x10(%ebx)
80100e08:	e8 54 09 00 00       	call   80101761 <readi>
80100e0d:	89 c6                	mov    %eax,%esi
80100e0f:	83 c4 20             	add    $0x20,%esp
80100e12:	85 c0                	test   %eax,%eax
80100e14:	7e 03                	jle    80100e19 <fileread+0x42>
      f->off += r;
80100e16:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e19:	83 ec 0c             	sub    $0xc,%esp
80100e1c:	ff 73 10             	pushl  0x10(%ebx)
80100e1f:	e8 0d 08 00 00       	call   80101631 <iunlock>
    return r;
80100e24:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100e27:	89 f0                	mov    %esi,%eax
80100e29:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e2c:	5b                   	pop    %ebx
80100e2d:	5e                   	pop    %esi
80100e2e:	5d                   	pop    %ebp
80100e2f:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100e30:	83 ec 04             	sub    $0x4,%esp
80100e33:	ff 75 10             	pushl  0x10(%ebp)
80100e36:	ff 75 0c             	pushl  0xc(%ebp)
80100e39:	ff 73 0c             	pushl  0xc(%ebx)
80100e3c:	e8 27 21 00 00       	call   80102f68 <piperead>
80100e41:	89 c6                	mov    %eax,%esi
80100e43:	83 c4 10             	add    $0x10,%esp
80100e46:	eb df                	jmp    80100e27 <fileread+0x50>
  panic("fileread");
80100e48:	83 ec 0c             	sub    $0xc,%esp
80100e4b:	68 c6 65 10 80       	push   $0x801065c6
80100e50:	e8 f3 f4 ff ff       	call   80100348 <panic>
    return -1;
80100e55:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e5a:	eb cb                	jmp    80100e27 <fileread+0x50>

80100e5c <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e5c:	55                   	push   %ebp
80100e5d:	89 e5                	mov    %esp,%ebp
80100e5f:	57                   	push   %edi
80100e60:	56                   	push   %esi
80100e61:	53                   	push   %ebx
80100e62:	83 ec 1c             	sub    $0x1c,%esp
80100e65:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->writable == 0)
80100e68:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100e6c:	0f 84 c5 00 00 00    	je     80100f37 <filewrite+0xdb>
    return -1;
  if(f->type == FD_PIPE)
80100e72:	8b 03                	mov    (%ebx),%eax
80100e74:	83 f8 01             	cmp    $0x1,%eax
80100e77:	74 10                	je     80100e89 <filewrite+0x2d>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e79:	83 f8 02             	cmp    $0x2,%eax
80100e7c:	0f 85 a8 00 00 00    	jne    80100f2a <filewrite+0xce>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100e82:	bf 00 00 00 00       	mov    $0x0,%edi
80100e87:	eb 67                	jmp    80100ef0 <filewrite+0x94>
    return pipewrite(f->pipe, addr, n);
80100e89:	83 ec 04             	sub    $0x4,%esp
80100e8c:	ff 75 10             	pushl  0x10(%ebp)
80100e8f:	ff 75 0c             	pushl  0xc(%ebp)
80100e92:	ff 73 0c             	pushl  0xc(%ebx)
80100e95:	e8 02 20 00 00       	call   80102e9c <pipewrite>
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	e9 80 00 00 00       	jmp    80100f22 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ea2:	e8 f5 18 00 00       	call   8010279c <begin_op>
      ilock(f->ip);
80100ea7:	83 ec 0c             	sub    $0xc,%esp
80100eaa:	ff 73 10             	pushl  0x10(%ebx)
80100ead:	e8 bd 06 00 00       	call   8010156f <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100eb2:	89 f8                	mov    %edi,%eax
80100eb4:	03 45 0c             	add    0xc(%ebp),%eax
80100eb7:	ff 75 e4             	pushl  -0x1c(%ebp)
80100eba:	ff 73 14             	pushl  0x14(%ebx)
80100ebd:	50                   	push   %eax
80100ebe:	ff 73 10             	pushl  0x10(%ebx)
80100ec1:	e8 98 09 00 00       	call   8010185e <writei>
80100ec6:	89 c6                	mov    %eax,%esi
80100ec8:	83 c4 20             	add    $0x20,%esp
80100ecb:	85 c0                	test   %eax,%eax
80100ecd:	7e 03                	jle    80100ed2 <filewrite+0x76>
        f->off += r;
80100ecf:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
80100ed2:	83 ec 0c             	sub    $0xc,%esp
80100ed5:	ff 73 10             	pushl  0x10(%ebx)
80100ed8:	e8 54 07 00 00       	call   80101631 <iunlock>
      end_op();
80100edd:	e8 34 19 00 00       	call   80102816 <end_op>

      if(r < 0)
80100ee2:	83 c4 10             	add    $0x10,%esp
80100ee5:	85 f6                	test   %esi,%esi
80100ee7:	78 31                	js     80100f1a <filewrite+0xbe>
        break;
      if(r != n1)
80100ee9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
80100eec:	75 1f                	jne    80100f0d <filewrite+0xb1>
        panic("short filewrite");
      i += r;
80100eee:	01 f7                	add    %esi,%edi
    while(i < n){
80100ef0:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100ef3:	7d 25                	jge    80100f1a <filewrite+0xbe>
      int n1 = n - i;
80100ef5:	8b 45 10             	mov    0x10(%ebp),%eax
80100ef8:	29 f8                	sub    %edi,%eax
80100efa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100efd:	3d 00 06 00 00       	cmp    $0x600,%eax
80100f02:	7e 9e                	jle    80100ea2 <filewrite+0x46>
        n1 = max;
80100f04:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100f0b:	eb 95                	jmp    80100ea2 <filewrite+0x46>
        panic("short filewrite");
80100f0d:	83 ec 0c             	sub    $0xc,%esp
80100f10:	68 cf 65 10 80       	push   $0x801065cf
80100f15:	e8 2e f4 ff ff       	call   80100348 <panic>
    }
    return i == n ? n : -1;
80100f1a:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f1d:	75 1f                	jne    80100f3e <filewrite+0xe2>
80100f1f:	8b 45 10             	mov    0x10(%ebp),%eax
  }
  panic("filewrite");
}
80100f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f25:	5b                   	pop    %ebx
80100f26:	5e                   	pop    %esi
80100f27:	5f                   	pop    %edi
80100f28:	5d                   	pop    %ebp
80100f29:	c3                   	ret    
  panic("filewrite");
80100f2a:	83 ec 0c             	sub    $0xc,%esp
80100f2d:	68 d5 65 10 80       	push   $0x801065d5
80100f32:	e8 11 f4 ff ff       	call   80100348 <panic>
    return -1;
80100f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f3c:	eb e4                	jmp    80100f22 <filewrite+0xc6>
    return i == n ? n : -1;
80100f3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f43:	eb dd                	jmp    80100f22 <filewrite+0xc6>

80100f45 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100f45:	55                   	push   %ebp
80100f46:	89 e5                	mov    %esp,%ebp
80100f48:	57                   	push   %edi
80100f49:	56                   	push   %esi
80100f4a:	53                   	push   %ebx
80100f4b:	83 ec 0c             	sub    $0xc,%esp
80100f4e:	89 d7                	mov    %edx,%edi
  char *s;
  int len;

  while(*path == '/')
80100f50:	eb 03                	jmp    80100f55 <skipelem+0x10>
    path++;
80100f52:	83 c0 01             	add    $0x1,%eax
  while(*path == '/')
80100f55:	0f b6 10             	movzbl (%eax),%edx
80100f58:	80 fa 2f             	cmp    $0x2f,%dl
80100f5b:	74 f5                	je     80100f52 <skipelem+0xd>
  if(*path == 0)
80100f5d:	84 d2                	test   %dl,%dl
80100f5f:	74 59                	je     80100fba <skipelem+0x75>
80100f61:	89 c3                	mov    %eax,%ebx
80100f63:	eb 03                	jmp    80100f68 <skipelem+0x23>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f65:	83 c3 01             	add    $0x1,%ebx
  while(*path != '/' && *path != 0)
80100f68:	0f b6 13             	movzbl (%ebx),%edx
80100f6b:	80 fa 2f             	cmp    $0x2f,%dl
80100f6e:	0f 95 c1             	setne  %cl
80100f71:	84 d2                	test   %dl,%dl
80100f73:	0f 95 c2             	setne  %dl
80100f76:	84 d1                	test   %dl,%cl
80100f78:	75 eb                	jne    80100f65 <skipelem+0x20>
  len = path - s;
80100f7a:	89 de                	mov    %ebx,%esi
80100f7c:	29 c6                	sub    %eax,%esi
  if(len >= DIRSIZ)
80100f7e:	83 fe 0d             	cmp    $0xd,%esi
80100f81:	7e 11                	jle    80100f94 <skipelem+0x4f>
    memmove(name, s, DIRSIZ);
80100f83:	83 ec 04             	sub    $0x4,%esp
80100f86:	6a 0e                	push   $0xe
80100f88:	50                   	push   %eax
80100f89:	57                   	push   %edi
80100f8a:	e8 1b 2d 00 00       	call   80103caa <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 0b 2d 00 00       	call   80103caa <memmove>
    name[len] = 0;
80100f9f:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
80100fa3:	83 c4 10             	add    $0x10,%esp
80100fa6:	eb 03                	jmp    80100fab <skipelem+0x66>
  }
  while(*path == '/')
    path++;
80100fa8:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80100fab:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100fae:	74 f8                	je     80100fa8 <skipelem+0x63>
  return path;
}
80100fb0:	89 d8                	mov    %ebx,%eax
80100fb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fb5:	5b                   	pop    %ebx
80100fb6:	5e                   	pop    %esi
80100fb7:	5f                   	pop    %edi
80100fb8:	5d                   	pop    %ebp
80100fb9:	c3                   	ret    
    return 0;
80100fba:	bb 00 00 00 00       	mov    $0x0,%ebx
80100fbf:	eb ef                	jmp    80100fb0 <skipelem+0x6b>

80100fc1 <bzero>:
{
80100fc1:	55                   	push   %ebp
80100fc2:	89 e5                	mov    %esp,%ebp
80100fc4:	53                   	push   %ebx
80100fc5:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100fc8:	52                   	push   %edx
80100fc9:	50                   	push   %eax
80100fca:	e8 9d f1 ff ff       	call   8010016c <bread>
80100fcf:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100fd1:	8d 40 5c             	lea    0x5c(%eax),%eax
80100fd4:	83 c4 0c             	add    $0xc,%esp
80100fd7:	68 00 02 00 00       	push   $0x200
80100fdc:	6a 00                	push   $0x0
80100fde:	50                   	push   %eax
80100fdf:	e8 4b 2c 00 00       	call   80103c2f <memset>
  log_write(bp);
80100fe4:	89 1c 24             	mov    %ebx,(%esp)
80100fe7:	e8 d9 18 00 00       	call   801028c5 <log_write>
  brelse(bp);
80100fec:	89 1c 24             	mov    %ebx,(%esp)
80100fef:	e8 e1 f1 ff ff       	call   801001d5 <brelse>
}
80100ff4:	83 c4 10             	add    $0x10,%esp
80100ff7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ffa:	c9                   	leave  
80100ffb:	c3                   	ret    

80100ffc <bfree>:
{
80100ffc:	55                   	push   %ebp
80100ffd:	89 e5                	mov    %esp,%ebp
80100fff:	56                   	push   %esi
80101000:	53                   	push   %ebx
80101001:	89 d3                	mov    %edx,%ebx
  bp = bread(dev, BBLOCK(b, sb));
80101003:	c1 ea 0c             	shr    $0xc,%edx
80101006:	03 15 d8 f9 10 80    	add    0x8010f9d8,%edx
8010100c:	83 ec 08             	sub    $0x8,%esp
8010100f:	52                   	push   %edx
80101010:	50                   	push   %eax
80101011:	e8 56 f1 ff ff       	call   8010016c <bread>
80101016:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
80101018:	89 d9                	mov    %ebx,%ecx
8010101a:	83 e1 07             	and    $0x7,%ecx
8010101d:	b8 01 00 00 00       	mov    $0x1,%eax
80101022:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101024:	83 c4 10             	add    $0x10,%esp
80101027:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
8010102d:	c1 fb 03             	sar    $0x3,%ebx
80101030:	0f b6 54 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%edx
80101035:	0f b6 ca             	movzbl %dl,%ecx
80101038:	85 c1                	test   %eax,%ecx
8010103a:	74 23                	je     8010105f <bfree+0x63>
  bp->data[bi/8] &= ~m;
8010103c:	f7 d0                	not    %eax
8010103e:	21 d0                	and    %edx,%eax
80101040:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
80101044:	83 ec 0c             	sub    $0xc,%esp
80101047:	56                   	push   %esi
80101048:	e8 78 18 00 00       	call   801028c5 <log_write>
  brelse(bp);
8010104d:	89 34 24             	mov    %esi,(%esp)
80101050:	e8 80 f1 ff ff       	call   801001d5 <brelse>
}
80101055:	83 c4 10             	add    $0x10,%esp
80101058:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010105b:	5b                   	pop    %ebx
8010105c:	5e                   	pop    %esi
8010105d:	5d                   	pop    %ebp
8010105e:	c3                   	ret    
    panic("freeing free block");
8010105f:	83 ec 0c             	sub    $0xc,%esp
80101062:	68 df 65 10 80       	push   $0x801065df
80101067:	e8 dc f2 ff ff       	call   80100348 <panic>

8010106c <balloc>:
{
8010106c:	55                   	push   %ebp
8010106d:	89 e5                	mov    %esp,%ebp
8010106f:	57                   	push   %edi
80101070:	56                   	push   %esi
80101071:	53                   	push   %ebx
80101072:	83 ec 1c             	sub    $0x1c,%esp
80101075:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101078:	be 00 00 00 00       	mov    $0x0,%esi
8010107d:	eb 14                	jmp    80101093 <balloc+0x27>
    brelse(bp);
8010107f:	83 ec 0c             	sub    $0xc,%esp
80101082:	ff 75 e4             	pushl  -0x1c(%ebp)
80101085:	e8 4b f1 ff ff       	call   801001d5 <brelse>
  for(b = 0; b < sb.size; b += BPB){
8010108a:	81 c6 00 10 00 00    	add    $0x1000,%esi
80101090:	83 c4 10             	add    $0x10,%esp
80101093:	39 35 c0 f9 10 80    	cmp    %esi,0x8010f9c0
80101099:	76 75                	jbe    80101110 <balloc+0xa4>
    bp = bread(dev, BBLOCK(b, sb));
8010109b:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
801010a1:	85 f6                	test   %esi,%esi
801010a3:	0f 49 c6             	cmovns %esi,%eax
801010a6:	c1 f8 0c             	sar    $0xc,%eax
801010a9:	03 05 d8 f9 10 80    	add    0x8010f9d8,%eax
801010af:	83 ec 08             	sub    $0x8,%esp
801010b2:	50                   	push   %eax
801010b3:	ff 75 d8             	pushl  -0x28(%ebp)
801010b6:	e8 b1 f0 ff ff       	call   8010016c <bread>
801010bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801010be:	83 c4 10             	add    $0x10,%esp
801010c1:	b8 00 00 00 00       	mov    $0x0,%eax
801010c6:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801010cb:	7f b2                	jg     8010107f <balloc+0x13>
801010cd:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
801010d0:	89 5d e0             	mov    %ebx,-0x20(%ebp)
801010d3:	3b 1d c0 f9 10 80    	cmp    0x8010f9c0,%ebx
801010d9:	73 a4                	jae    8010107f <balloc+0x13>
      m = 1 << (bi % 8);
801010db:	99                   	cltd   
801010dc:	c1 ea 1d             	shr    $0x1d,%edx
801010df:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
801010e2:	83 e1 07             	and    $0x7,%ecx
801010e5:	29 d1                	sub    %edx,%ecx
801010e7:	ba 01 00 00 00       	mov    $0x1,%edx
801010ec:	d3 e2                	shl    %cl,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801010ee:	8d 48 07             	lea    0x7(%eax),%ecx
801010f1:	85 c0                	test   %eax,%eax
801010f3:	0f 49 c8             	cmovns %eax,%ecx
801010f6:	c1 f9 03             	sar    $0x3,%ecx
801010f9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
801010fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801010ff:	0f b6 4c 0f 5c       	movzbl 0x5c(%edi,%ecx,1),%ecx
80101104:	0f b6 f9             	movzbl %cl,%edi
80101107:	85 d7                	test   %edx,%edi
80101109:	74 12                	je     8010111d <balloc+0xb1>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010110b:	83 c0 01             	add    $0x1,%eax
8010110e:	eb b6                	jmp    801010c6 <balloc+0x5a>
  panic("balloc: out of blocks");
80101110:	83 ec 0c             	sub    $0xc,%esp
80101113:	68 f2 65 10 80       	push   $0x801065f2
80101118:	e8 2b f2 ff ff       	call   80100348 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
8010111d:	09 ca                	or     %ecx,%edx
8010111f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101122:	8b 75 dc             	mov    -0x24(%ebp),%esi
80101125:	88 54 30 5c          	mov    %dl,0x5c(%eax,%esi,1)
        log_write(bp);
80101129:	83 ec 0c             	sub    $0xc,%esp
8010112c:	89 c6                	mov    %eax,%esi
8010112e:	50                   	push   %eax
8010112f:	e8 91 17 00 00       	call   801028c5 <log_write>
        brelse(bp);
80101134:	89 34 24             	mov    %esi,(%esp)
80101137:	e8 99 f0 ff ff       	call   801001d5 <brelse>
        bzero(dev, b + bi);
8010113c:	89 da                	mov    %ebx,%edx
8010113e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101141:	e8 7b fe ff ff       	call   80100fc1 <bzero>
}
80101146:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101149:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010114c:	5b                   	pop    %ebx
8010114d:	5e                   	pop    %esi
8010114e:	5f                   	pop    %edi
8010114f:	5d                   	pop    %ebp
80101150:	c3                   	ret    

80101151 <bmap>:
{
80101151:	55                   	push   %ebp
80101152:	89 e5                	mov    %esp,%ebp
80101154:	57                   	push   %edi
80101155:	56                   	push   %esi
80101156:	53                   	push   %ebx
80101157:	83 ec 1c             	sub    $0x1c,%esp
8010115a:	89 c6                	mov    %eax,%esi
8010115c:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
8010115e:	83 fa 0b             	cmp    $0xb,%edx
80101161:	77 17                	ja     8010117a <bmap+0x29>
    if((addr = ip->addrs[bn]) == 0)
80101163:	8b 5c 90 5c          	mov    0x5c(%eax,%edx,4),%ebx
80101167:	85 db                	test   %ebx,%ebx
80101169:	75 4a                	jne    801011b5 <bmap+0x64>
      ip->addrs[bn] = addr = balloc(ip->dev);
8010116b:	8b 00                	mov    (%eax),%eax
8010116d:	e8 fa fe ff ff       	call   8010106c <balloc>
80101172:	89 c3                	mov    %eax,%ebx
80101174:	89 44 be 5c          	mov    %eax,0x5c(%esi,%edi,4)
80101178:	eb 3b                	jmp    801011b5 <bmap+0x64>
  bn -= NDIRECT;
8010117a:	8d 5a f4             	lea    -0xc(%edx),%ebx
  if(bn < NINDIRECT){
8010117d:	83 fb 7f             	cmp    $0x7f,%ebx
80101180:	77 68                	ja     801011ea <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
80101182:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101188:	85 c0                	test   %eax,%eax
8010118a:	74 33                	je     801011bf <bmap+0x6e>
    bp = bread(ip->dev, addr);
8010118c:	83 ec 08             	sub    $0x8,%esp
8010118f:	50                   	push   %eax
80101190:	ff 36                	pushl  (%esi)
80101192:	e8 d5 ef ff ff       	call   8010016c <bread>
80101197:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
80101199:	8d 44 98 5c          	lea    0x5c(%eax,%ebx,4),%eax
8010119d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801011a0:	8b 18                	mov    (%eax),%ebx
801011a2:	83 c4 10             	add    $0x10,%esp
801011a5:	85 db                	test   %ebx,%ebx
801011a7:	74 25                	je     801011ce <bmap+0x7d>
    brelse(bp);
801011a9:	83 ec 0c             	sub    $0xc,%esp
801011ac:	57                   	push   %edi
801011ad:	e8 23 f0 ff ff       	call   801001d5 <brelse>
    return addr;
801011b2:	83 c4 10             	add    $0x10,%esp
}
801011b5:	89 d8                	mov    %ebx,%eax
801011b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011ba:	5b                   	pop    %ebx
801011bb:	5e                   	pop    %esi
801011bc:	5f                   	pop    %edi
801011bd:	5d                   	pop    %ebp
801011be:	c3                   	ret    
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801011bf:	8b 06                	mov    (%esi),%eax
801011c1:	e8 a6 fe ff ff       	call   8010106c <balloc>
801011c6:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
801011cc:	eb be                	jmp    8010118c <bmap+0x3b>
      a[bn] = addr = balloc(ip->dev);
801011ce:	8b 06                	mov    (%esi),%eax
801011d0:	e8 97 fe ff ff       	call   8010106c <balloc>
801011d5:	89 c3                	mov    %eax,%ebx
801011d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801011da:	89 18                	mov    %ebx,(%eax)
      log_write(bp);
801011dc:	83 ec 0c             	sub    $0xc,%esp
801011df:	57                   	push   %edi
801011e0:	e8 e0 16 00 00       	call   801028c5 <log_write>
801011e5:	83 c4 10             	add    $0x10,%esp
801011e8:	eb bf                	jmp    801011a9 <bmap+0x58>
  panic("bmap: out of range");
801011ea:	83 ec 0c             	sub    $0xc,%esp
801011ed:	68 08 66 10 80       	push   $0x80106608
801011f2:	e8 51 f1 ff ff       	call   80100348 <panic>

801011f7 <iget>:
{
801011f7:	55                   	push   %ebp
801011f8:	89 e5                	mov    %esp,%ebp
801011fa:	57                   	push   %edi
801011fb:	56                   	push   %esi
801011fc:	53                   	push   %ebx
801011fd:	83 ec 28             	sub    $0x28,%esp
80101200:	89 c7                	mov    %eax,%edi
80101202:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101205:	68 e0 f9 10 80       	push   $0x8010f9e0
8010120a:	e8 74 29 00 00       	call   80103b83 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010120f:	83 c4 10             	add    $0x10,%esp
  empty = 0;
80101212:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101217:	bb 14 fa 10 80       	mov    $0x8010fa14,%ebx
8010121c:	eb 0a                	jmp    80101228 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010121e:	85 f6                	test   %esi,%esi
80101220:	74 3b                	je     8010125d <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101222:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101228:	81 fb 34 16 11 80    	cmp    $0x80111634,%ebx
8010122e:	73 35                	jae    80101265 <iget+0x6e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101230:	8b 43 08             	mov    0x8(%ebx),%eax
80101233:	85 c0                	test   %eax,%eax
80101235:	7e e7                	jle    8010121e <iget+0x27>
80101237:	39 3b                	cmp    %edi,(%ebx)
80101239:	75 e3                	jne    8010121e <iget+0x27>
8010123b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010123e:	39 4b 04             	cmp    %ecx,0x4(%ebx)
80101241:	75 db                	jne    8010121e <iget+0x27>
      ip->ref++;
80101243:	83 c0 01             	add    $0x1,%eax
80101246:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
80101249:	83 ec 0c             	sub    $0xc,%esp
8010124c:	68 e0 f9 10 80       	push   $0x8010f9e0
80101251:	e8 92 29 00 00       	call   80103be8 <release>
      return ip;
80101256:	83 c4 10             	add    $0x10,%esp
80101259:	89 de                	mov    %ebx,%esi
8010125b:	eb 32                	jmp    8010128f <iget+0x98>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010125d:	85 c0                	test   %eax,%eax
8010125f:	75 c1                	jne    80101222 <iget+0x2b>
      empty = ip;
80101261:	89 de                	mov    %ebx,%esi
80101263:	eb bd                	jmp    80101222 <iget+0x2b>
  if(empty == 0)
80101265:	85 f6                	test   %esi,%esi
80101267:	74 30                	je     80101299 <iget+0xa2>
  ip->dev = dev;
80101269:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
8010126b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010126e:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
80101271:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
80101278:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
8010127f:	83 ec 0c             	sub    $0xc,%esp
80101282:	68 e0 f9 10 80       	push   $0x8010f9e0
80101287:	e8 5c 29 00 00       	call   80103be8 <release>
  return ip;
8010128c:	83 c4 10             	add    $0x10,%esp
}
8010128f:	89 f0                	mov    %esi,%eax
80101291:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101294:	5b                   	pop    %ebx
80101295:	5e                   	pop    %esi
80101296:	5f                   	pop    %edi
80101297:	5d                   	pop    %ebp
80101298:	c3                   	ret    
    panic("iget: no inodes");
80101299:	83 ec 0c             	sub    $0xc,%esp
8010129c:	68 1b 66 10 80       	push   $0x8010661b
801012a1:	e8 a2 f0 ff ff       	call   80100348 <panic>

801012a6 <readsb>:
{
801012a6:	55                   	push   %ebp
801012a7:	89 e5                	mov    %esp,%ebp
801012a9:	53                   	push   %ebx
801012aa:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
801012ad:	6a 01                	push   $0x1
801012af:	ff 75 08             	pushl  0x8(%ebp)
801012b2:	e8 b5 ee ff ff       	call   8010016c <bread>
801012b7:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801012b9:	8d 40 5c             	lea    0x5c(%eax),%eax
801012bc:	83 c4 0c             	add    $0xc,%esp
801012bf:	6a 1c                	push   $0x1c
801012c1:	50                   	push   %eax
801012c2:	ff 75 0c             	pushl  0xc(%ebp)
801012c5:	e8 e0 29 00 00       	call   80103caa <memmove>
  brelse(bp);
801012ca:	89 1c 24             	mov    %ebx,(%esp)
801012cd:	e8 03 ef ff ff       	call   801001d5 <brelse>
}
801012d2:	83 c4 10             	add    $0x10,%esp
801012d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801012d8:	c9                   	leave  
801012d9:	c3                   	ret    

801012da <iinit>:
{
801012da:	55                   	push   %ebp
801012db:	89 e5                	mov    %esp,%ebp
801012dd:	53                   	push   %ebx
801012de:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012e1:	68 2b 66 10 80       	push   $0x8010662b
801012e6:	68 e0 f9 10 80       	push   $0x8010f9e0
801012eb:	e8 57 27 00 00       	call   80103a47 <initlock>
  for(i = 0; i < NINODE; i++) {
801012f0:	83 c4 10             	add    $0x10,%esp
801012f3:	bb 00 00 00 00       	mov    $0x0,%ebx
801012f8:	eb 21                	jmp    8010131b <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
801012fa:	83 ec 08             	sub    $0x8,%esp
801012fd:	68 32 66 10 80       	push   $0x80106632
80101302:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101305:	89 d0                	mov    %edx,%eax
80101307:	c1 e0 04             	shl    $0x4,%eax
8010130a:	05 20 fa 10 80       	add    $0x8010fa20,%eax
8010130f:	50                   	push   %eax
80101310:	e8 27 26 00 00       	call   8010393c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101315:	83 c3 01             	add    $0x1,%ebx
80101318:	83 c4 10             	add    $0x10,%esp
8010131b:	83 fb 31             	cmp    $0x31,%ebx
8010131e:	7e da                	jle    801012fa <iinit+0x20>
  readsb(dev, &sb);
80101320:	83 ec 08             	sub    $0x8,%esp
80101323:	68 c0 f9 10 80       	push   $0x8010f9c0
80101328:	ff 75 08             	pushl  0x8(%ebp)
8010132b:	e8 76 ff ff ff       	call   801012a6 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101330:	ff 35 d8 f9 10 80    	pushl  0x8010f9d8
80101336:	ff 35 d4 f9 10 80    	pushl  0x8010f9d4
8010133c:	ff 35 d0 f9 10 80    	pushl  0x8010f9d0
80101342:	ff 35 cc f9 10 80    	pushl  0x8010f9cc
80101348:	ff 35 c8 f9 10 80    	pushl  0x8010f9c8
8010134e:	ff 35 c4 f9 10 80    	pushl  0x8010f9c4
80101354:	ff 35 c0 f9 10 80    	pushl  0x8010f9c0
8010135a:	68 98 66 10 80       	push   $0x80106698
8010135f:	e8 a7 f2 ff ff       	call   8010060b <cprintf>
}
80101364:	83 c4 30             	add    $0x30,%esp
80101367:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010136a:	c9                   	leave  
8010136b:	c3                   	ret    

8010136c <ialloc>:
{
8010136c:	55                   	push   %ebp
8010136d:	89 e5                	mov    %esp,%ebp
8010136f:	57                   	push   %edi
80101370:	56                   	push   %esi
80101371:	53                   	push   %ebx
80101372:	83 ec 1c             	sub    $0x1c,%esp
80101375:	8b 45 0c             	mov    0xc(%ebp),%eax
80101378:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
8010137b:	bb 01 00 00 00       	mov    $0x1,%ebx
80101380:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80101383:	39 1d c8 f9 10 80    	cmp    %ebx,0x8010f9c8
80101389:	76 3f                	jbe    801013ca <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
8010138b:	89 d8                	mov    %ebx,%eax
8010138d:	c1 e8 03             	shr    $0x3,%eax
80101390:	03 05 d4 f9 10 80    	add    0x8010f9d4,%eax
80101396:	83 ec 08             	sub    $0x8,%esp
80101399:	50                   	push   %eax
8010139a:	ff 75 08             	pushl  0x8(%ebp)
8010139d:	e8 ca ed ff ff       	call   8010016c <bread>
801013a2:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
801013a4:	89 d8                	mov    %ebx,%eax
801013a6:	83 e0 07             	and    $0x7,%eax
801013a9:	c1 e0 06             	shl    $0x6,%eax
801013ac:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
801013b0:	83 c4 10             	add    $0x10,%esp
801013b3:	66 83 3f 00          	cmpw   $0x0,(%edi)
801013b7:	74 1e                	je     801013d7 <ialloc+0x6b>
    brelse(bp);
801013b9:	83 ec 0c             	sub    $0xc,%esp
801013bc:	56                   	push   %esi
801013bd:	e8 13 ee ff ff       	call   801001d5 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801013c2:	83 c3 01             	add    $0x1,%ebx
801013c5:	83 c4 10             	add    $0x10,%esp
801013c8:	eb b6                	jmp    80101380 <ialloc+0x14>
  panic("ialloc: no inodes");
801013ca:	83 ec 0c             	sub    $0xc,%esp
801013cd:	68 38 66 10 80       	push   $0x80106638
801013d2:	e8 71 ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013d7:	83 ec 04             	sub    $0x4,%esp
801013da:	6a 40                	push   $0x40
801013dc:	6a 00                	push   $0x0
801013de:	57                   	push   %edi
801013df:	e8 4b 28 00 00       	call   80103c2f <memset>
      dip->type = type;
801013e4:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013e8:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013eb:	89 34 24             	mov    %esi,(%esp)
801013ee:	e8 d2 14 00 00       	call   801028c5 <log_write>
      brelse(bp);
801013f3:	89 34 24             	mov    %esi,(%esp)
801013f6:	e8 da ed ff ff       	call   801001d5 <brelse>
      return iget(dev, inum);
801013fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801013fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101401:	e8 f1 fd ff ff       	call   801011f7 <iget>
}
80101406:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101409:	5b                   	pop    %ebx
8010140a:	5e                   	pop    %esi
8010140b:	5f                   	pop    %edi
8010140c:	5d                   	pop    %ebp
8010140d:	c3                   	ret    

8010140e <iupdate>:
{
8010140e:	55                   	push   %ebp
8010140f:	89 e5                	mov    %esp,%ebp
80101411:	56                   	push   %esi
80101412:	53                   	push   %ebx
80101413:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101416:	8b 43 04             	mov    0x4(%ebx),%eax
80101419:	c1 e8 03             	shr    $0x3,%eax
8010141c:	03 05 d4 f9 10 80    	add    0x8010f9d4,%eax
80101422:	83 ec 08             	sub    $0x8,%esp
80101425:	50                   	push   %eax
80101426:	ff 33                	pushl  (%ebx)
80101428:	e8 3f ed ff ff       	call   8010016c <bread>
8010142d:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010142f:	8b 43 04             	mov    0x4(%ebx),%eax
80101432:	83 e0 07             	and    $0x7,%eax
80101435:	c1 e0 06             	shl    $0x6,%eax
80101438:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
8010143c:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
80101440:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101443:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
80101447:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010144b:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
8010144f:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101453:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
80101457:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010145b:	8b 53 58             	mov    0x58(%ebx),%edx
8010145e:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101461:	83 c3 5c             	add    $0x5c,%ebx
80101464:	83 c0 0c             	add    $0xc,%eax
80101467:	83 c4 0c             	add    $0xc,%esp
8010146a:	6a 34                	push   $0x34
8010146c:	53                   	push   %ebx
8010146d:	50                   	push   %eax
8010146e:	e8 37 28 00 00       	call   80103caa <memmove>
  log_write(bp);
80101473:	89 34 24             	mov    %esi,(%esp)
80101476:	e8 4a 14 00 00       	call   801028c5 <log_write>
  brelse(bp);
8010147b:	89 34 24             	mov    %esi,(%esp)
8010147e:	e8 52 ed ff ff       	call   801001d5 <brelse>
}
80101483:	83 c4 10             	add    $0x10,%esp
80101486:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101489:	5b                   	pop    %ebx
8010148a:	5e                   	pop    %esi
8010148b:	5d                   	pop    %ebp
8010148c:	c3                   	ret    

8010148d <itrunc>:
{
8010148d:	55                   	push   %ebp
8010148e:	89 e5                	mov    %esp,%ebp
80101490:	57                   	push   %edi
80101491:	56                   	push   %esi
80101492:	53                   	push   %ebx
80101493:	83 ec 1c             	sub    $0x1c,%esp
80101496:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
80101498:	bb 00 00 00 00       	mov    $0x0,%ebx
8010149d:	eb 03                	jmp    801014a2 <itrunc+0x15>
8010149f:	83 c3 01             	add    $0x1,%ebx
801014a2:	83 fb 0b             	cmp    $0xb,%ebx
801014a5:	7f 19                	jg     801014c0 <itrunc+0x33>
    if(ip->addrs[i]){
801014a7:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
801014ab:	85 d2                	test   %edx,%edx
801014ad:	74 f0                	je     8010149f <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
801014af:	8b 06                	mov    (%esi),%eax
801014b1:	e8 46 fb ff ff       	call   80100ffc <bfree>
      ip->addrs[i] = 0;
801014b6:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
801014bd:	00 
801014be:	eb df                	jmp    8010149f <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
801014c0:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
801014c6:	85 c0                	test   %eax,%eax
801014c8:	75 1b                	jne    801014e5 <itrunc+0x58>
  ip->size = 0;
801014ca:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
801014d1:	83 ec 0c             	sub    $0xc,%esp
801014d4:	56                   	push   %esi
801014d5:	e8 34 ff ff ff       	call   8010140e <iupdate>
}
801014da:	83 c4 10             	add    $0x10,%esp
801014dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014e0:	5b                   	pop    %ebx
801014e1:	5e                   	pop    %esi
801014e2:	5f                   	pop    %edi
801014e3:	5d                   	pop    %ebp
801014e4:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801014e5:	83 ec 08             	sub    $0x8,%esp
801014e8:	50                   	push   %eax
801014e9:	ff 36                	pushl  (%esi)
801014eb:	e8 7c ec ff ff       	call   8010016c <bread>
801014f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
801014f3:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
801014f6:	83 c4 10             	add    $0x10,%esp
801014f9:	bb 00 00 00 00       	mov    $0x0,%ebx
801014fe:	eb 03                	jmp    80101503 <itrunc+0x76>
80101500:	83 c3 01             	add    $0x1,%ebx
80101503:	83 fb 7f             	cmp    $0x7f,%ebx
80101506:	77 10                	ja     80101518 <itrunc+0x8b>
      if(a[j])
80101508:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
8010150b:	85 d2                	test   %edx,%edx
8010150d:	74 f1                	je     80101500 <itrunc+0x73>
        bfree(ip->dev, a[j]);
8010150f:	8b 06                	mov    (%esi),%eax
80101511:	e8 e6 fa ff ff       	call   80100ffc <bfree>
80101516:	eb e8                	jmp    80101500 <itrunc+0x73>
    brelse(bp);
80101518:	83 ec 0c             	sub    $0xc,%esp
8010151b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010151e:	e8 b2 ec ff ff       	call   801001d5 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101523:	8b 06                	mov    (%esi),%eax
80101525:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
8010152b:	e8 cc fa ff ff       	call   80100ffc <bfree>
    ip->addrs[NDIRECT] = 0;
80101530:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
80101537:	00 00 00 
8010153a:	83 c4 10             	add    $0x10,%esp
8010153d:	eb 8b                	jmp    801014ca <itrunc+0x3d>

8010153f <idup>:
{
8010153f:	55                   	push   %ebp
80101540:	89 e5                	mov    %esp,%ebp
80101542:	53                   	push   %ebx
80101543:	83 ec 10             	sub    $0x10,%esp
80101546:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
80101549:	68 e0 f9 10 80       	push   $0x8010f9e0
8010154e:	e8 30 26 00 00       	call   80103b83 <acquire>
  ip->ref++;
80101553:	8b 43 08             	mov    0x8(%ebx),%eax
80101556:	83 c0 01             	add    $0x1,%eax
80101559:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010155c:	c7 04 24 e0 f9 10 80 	movl   $0x8010f9e0,(%esp)
80101563:	e8 80 26 00 00       	call   80103be8 <release>
}
80101568:	89 d8                	mov    %ebx,%eax
8010156a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010156d:	c9                   	leave  
8010156e:	c3                   	ret    

8010156f <ilock>:
{
8010156f:	55                   	push   %ebp
80101570:	89 e5                	mov    %esp,%ebp
80101572:	56                   	push   %esi
80101573:	53                   	push   %ebx
80101574:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101577:	85 db                	test   %ebx,%ebx
80101579:	74 22                	je     8010159d <ilock+0x2e>
8010157b:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
8010157f:	7e 1c                	jle    8010159d <ilock+0x2e>
  acquiresleep(&ip->lock);
80101581:	83 ec 0c             	sub    $0xc,%esp
80101584:	8d 43 0c             	lea    0xc(%ebx),%eax
80101587:	50                   	push   %eax
80101588:	e8 e2 23 00 00       	call   8010396f <acquiresleep>
  if(ip->valid == 0){
8010158d:	83 c4 10             	add    $0x10,%esp
80101590:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101594:	74 14                	je     801015aa <ilock+0x3b>
}
80101596:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101599:	5b                   	pop    %ebx
8010159a:	5e                   	pop    %esi
8010159b:	5d                   	pop    %ebp
8010159c:	c3                   	ret    
    panic("ilock");
8010159d:	83 ec 0c             	sub    $0xc,%esp
801015a0:	68 4a 66 10 80       	push   $0x8010664a
801015a5:	e8 9e ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015aa:	8b 43 04             	mov    0x4(%ebx),%eax
801015ad:	c1 e8 03             	shr    $0x3,%eax
801015b0:	03 05 d4 f9 10 80    	add    0x8010f9d4,%eax
801015b6:	83 ec 08             	sub    $0x8,%esp
801015b9:	50                   	push   %eax
801015ba:	ff 33                	pushl  (%ebx)
801015bc:	e8 ab eb ff ff       	call   8010016c <bread>
801015c1:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801015c3:	8b 43 04             	mov    0x4(%ebx),%eax
801015c6:	83 e0 07             	and    $0x7,%eax
801015c9:	c1 e0 06             	shl    $0x6,%eax
801015cc:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801015d0:	0f b7 10             	movzwl (%eax),%edx
801015d3:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801015d7:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801015db:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
801015df:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801015e3:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
801015e7:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801015eb:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
801015ef:	8b 50 08             	mov    0x8(%eax),%edx
801015f2:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801015f5:	83 c0 0c             	add    $0xc,%eax
801015f8:	8d 53 5c             	lea    0x5c(%ebx),%edx
801015fb:	83 c4 0c             	add    $0xc,%esp
801015fe:	6a 34                	push   $0x34
80101600:	50                   	push   %eax
80101601:	52                   	push   %edx
80101602:	e8 a3 26 00 00       	call   80103caa <memmove>
    brelse(bp);
80101607:	89 34 24             	mov    %esi,(%esp)
8010160a:	e8 c6 eb ff ff       	call   801001d5 <brelse>
    ip->valid = 1;
8010160f:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101616:	83 c4 10             	add    $0x10,%esp
80101619:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
8010161e:	0f 85 72 ff ff ff    	jne    80101596 <ilock+0x27>
      panic("ilock: no type");
80101624:	83 ec 0c             	sub    $0xc,%esp
80101627:	68 50 66 10 80       	push   $0x80106650
8010162c:	e8 17 ed ff ff       	call   80100348 <panic>

80101631 <iunlock>:
{
80101631:	55                   	push   %ebp
80101632:	89 e5                	mov    %esp,%ebp
80101634:	56                   	push   %esi
80101635:	53                   	push   %ebx
80101636:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101639:	85 db                	test   %ebx,%ebx
8010163b:	74 2c                	je     80101669 <iunlock+0x38>
8010163d:	8d 73 0c             	lea    0xc(%ebx),%esi
80101640:	83 ec 0c             	sub    $0xc,%esp
80101643:	56                   	push   %esi
80101644:	e8 b0 23 00 00       	call   801039f9 <holdingsleep>
80101649:	83 c4 10             	add    $0x10,%esp
8010164c:	85 c0                	test   %eax,%eax
8010164e:	74 19                	je     80101669 <iunlock+0x38>
80101650:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101654:	7e 13                	jle    80101669 <iunlock+0x38>
  releasesleep(&ip->lock);
80101656:	83 ec 0c             	sub    $0xc,%esp
80101659:	56                   	push   %esi
8010165a:	e8 5f 23 00 00       	call   801039be <releasesleep>
}
8010165f:	83 c4 10             	add    $0x10,%esp
80101662:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101665:	5b                   	pop    %ebx
80101666:	5e                   	pop    %esi
80101667:	5d                   	pop    %ebp
80101668:	c3                   	ret    
    panic("iunlock");
80101669:	83 ec 0c             	sub    $0xc,%esp
8010166c:	68 5f 66 10 80       	push   $0x8010665f
80101671:	e8 d2 ec ff ff       	call   80100348 <panic>

80101676 <iput>:
{
80101676:	55                   	push   %ebp
80101677:	89 e5                	mov    %esp,%ebp
80101679:	57                   	push   %edi
8010167a:	56                   	push   %esi
8010167b:	53                   	push   %ebx
8010167c:	83 ec 18             	sub    $0x18,%esp
8010167f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101682:	8d 73 0c             	lea    0xc(%ebx),%esi
80101685:	56                   	push   %esi
80101686:	e8 e4 22 00 00       	call   8010396f <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010168b:	83 c4 10             	add    $0x10,%esp
8010168e:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101692:	74 07                	je     8010169b <iput+0x25>
80101694:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101699:	74 35                	je     801016d0 <iput+0x5a>
  releasesleep(&ip->lock);
8010169b:	83 ec 0c             	sub    $0xc,%esp
8010169e:	56                   	push   %esi
8010169f:	e8 1a 23 00 00       	call   801039be <releasesleep>
  acquire(&icache.lock);
801016a4:	c7 04 24 e0 f9 10 80 	movl   $0x8010f9e0,(%esp)
801016ab:	e8 d3 24 00 00       	call   80103b83 <acquire>
  ip->ref--;
801016b0:	8b 43 08             	mov    0x8(%ebx),%eax
801016b3:	83 e8 01             	sub    $0x1,%eax
801016b6:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016b9:	c7 04 24 e0 f9 10 80 	movl   $0x8010f9e0,(%esp)
801016c0:	e8 23 25 00 00       	call   80103be8 <release>
}
801016c5:	83 c4 10             	add    $0x10,%esp
801016c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016cb:	5b                   	pop    %ebx
801016cc:	5e                   	pop    %esi
801016cd:	5f                   	pop    %edi
801016ce:	5d                   	pop    %ebp
801016cf:	c3                   	ret    
    acquire(&icache.lock);
801016d0:	83 ec 0c             	sub    $0xc,%esp
801016d3:	68 e0 f9 10 80       	push   $0x8010f9e0
801016d8:	e8 a6 24 00 00       	call   80103b83 <acquire>
    int r = ip->ref;
801016dd:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016e0:	c7 04 24 e0 f9 10 80 	movl   $0x8010f9e0,(%esp)
801016e7:	e8 fc 24 00 00       	call   80103be8 <release>
    if(r == 1){
801016ec:	83 c4 10             	add    $0x10,%esp
801016ef:	83 ff 01             	cmp    $0x1,%edi
801016f2:	75 a7                	jne    8010169b <iput+0x25>
      itrunc(ip);
801016f4:	89 d8                	mov    %ebx,%eax
801016f6:	e8 92 fd ff ff       	call   8010148d <itrunc>
      ip->type = 0;
801016fb:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
80101701:	83 ec 0c             	sub    $0xc,%esp
80101704:	53                   	push   %ebx
80101705:	e8 04 fd ff ff       	call   8010140e <iupdate>
      ip->valid = 0;
8010170a:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101711:	83 c4 10             	add    $0x10,%esp
80101714:	eb 85                	jmp    8010169b <iput+0x25>

80101716 <iunlockput>:
{
80101716:	55                   	push   %ebp
80101717:	89 e5                	mov    %esp,%ebp
80101719:	53                   	push   %ebx
8010171a:	83 ec 10             	sub    $0x10,%esp
8010171d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101720:	53                   	push   %ebx
80101721:	e8 0b ff ff ff       	call   80101631 <iunlock>
  iput(ip);
80101726:	89 1c 24             	mov    %ebx,(%esp)
80101729:	e8 48 ff ff ff       	call   80101676 <iput>
}
8010172e:	83 c4 10             	add    $0x10,%esp
80101731:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101734:	c9                   	leave  
80101735:	c3                   	ret    

80101736 <stati>:
{
80101736:	55                   	push   %ebp
80101737:	89 e5                	mov    %esp,%ebp
80101739:	8b 55 08             	mov    0x8(%ebp),%edx
8010173c:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
8010173f:	8b 0a                	mov    (%edx),%ecx
80101741:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101744:	8b 4a 04             	mov    0x4(%edx),%ecx
80101747:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
8010174a:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
8010174e:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101751:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101755:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101759:	8b 52 58             	mov    0x58(%edx),%edx
8010175c:	89 50 10             	mov    %edx,0x10(%eax)
}
8010175f:	5d                   	pop    %ebp
80101760:	c3                   	ret    

80101761 <readi>:
{
80101761:	55                   	push   %ebp
80101762:	89 e5                	mov    %esp,%ebp
80101764:	57                   	push   %edi
80101765:	56                   	push   %esi
80101766:	53                   	push   %ebx
80101767:	83 ec 1c             	sub    $0x1c,%esp
8010176a:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
8010176d:	8b 45 08             	mov    0x8(%ebp),%eax
80101770:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101775:	74 2c                	je     801017a3 <readi+0x42>
  if(off > ip->size || off + n < off)
80101777:	8b 45 08             	mov    0x8(%ebp),%eax
8010177a:	8b 40 58             	mov    0x58(%eax),%eax
8010177d:	39 f8                	cmp    %edi,%eax
8010177f:	0f 82 cb 00 00 00    	jb     80101850 <readi+0xef>
80101785:	89 fa                	mov    %edi,%edx
80101787:	03 55 14             	add    0x14(%ebp),%edx
8010178a:	0f 82 c7 00 00 00    	jb     80101857 <readi+0xf6>
  if(off + n > ip->size)
80101790:	39 d0                	cmp    %edx,%eax
80101792:	73 05                	jae    80101799 <readi+0x38>
    n = ip->size - off;
80101794:	29 f8                	sub    %edi,%eax
80101796:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101799:	be 00 00 00 00       	mov    $0x0,%esi
8010179e:	e9 8f 00 00 00       	jmp    80101832 <readi+0xd1>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801017a3:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801017a7:	66 83 f8 09          	cmp    $0x9,%ax
801017ab:	0f 87 91 00 00 00    	ja     80101842 <readi+0xe1>
801017b1:	98                   	cwtl   
801017b2:	8b 04 c5 60 f9 10 80 	mov    -0x7fef06a0(,%eax,8),%eax
801017b9:	85 c0                	test   %eax,%eax
801017bb:	0f 84 88 00 00 00    	je     80101849 <readi+0xe8>
    return devsw[ip->major].read(ip, dst, n);
801017c1:	83 ec 04             	sub    $0x4,%esp
801017c4:	ff 75 14             	pushl  0x14(%ebp)
801017c7:	ff 75 0c             	pushl  0xc(%ebp)
801017ca:	ff 75 08             	pushl  0x8(%ebp)
801017cd:	ff d0                	call   *%eax
801017cf:	83 c4 10             	add    $0x10,%esp
801017d2:	eb 66                	jmp    8010183a <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801017d4:	89 fa                	mov    %edi,%edx
801017d6:	c1 ea 09             	shr    $0x9,%edx
801017d9:	8b 45 08             	mov    0x8(%ebp),%eax
801017dc:	e8 70 f9 ff ff       	call   80101151 <bmap>
801017e1:	83 ec 08             	sub    $0x8,%esp
801017e4:	50                   	push   %eax
801017e5:	8b 45 08             	mov    0x8(%ebp),%eax
801017e8:	ff 30                	pushl  (%eax)
801017ea:	e8 7d e9 ff ff       	call   8010016c <bread>
801017ef:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
801017f1:	89 f8                	mov    %edi,%eax
801017f3:	25 ff 01 00 00       	and    $0x1ff,%eax
801017f8:	bb 00 02 00 00       	mov    $0x200,%ebx
801017fd:	29 c3                	sub    %eax,%ebx
801017ff:	8b 55 14             	mov    0x14(%ebp),%edx
80101802:	29 f2                	sub    %esi,%edx
80101804:	83 c4 0c             	add    $0xc,%esp
80101807:	39 d3                	cmp    %edx,%ebx
80101809:	0f 47 da             	cmova  %edx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
8010180c:	53                   	push   %ebx
8010180d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101810:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
80101814:	50                   	push   %eax
80101815:	ff 75 0c             	pushl  0xc(%ebp)
80101818:	e8 8d 24 00 00       	call   80103caa <memmove>
    brelse(bp);
8010181d:	83 c4 04             	add    $0x4,%esp
80101820:	ff 75 e4             	pushl  -0x1c(%ebp)
80101823:	e8 ad e9 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101828:	01 de                	add    %ebx,%esi
8010182a:	01 df                	add    %ebx,%edi
8010182c:	01 5d 0c             	add    %ebx,0xc(%ebp)
8010182f:	83 c4 10             	add    $0x10,%esp
80101832:	39 75 14             	cmp    %esi,0x14(%ebp)
80101835:	77 9d                	ja     801017d4 <readi+0x73>
  return n;
80101837:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010183a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010183d:	5b                   	pop    %ebx
8010183e:	5e                   	pop    %esi
8010183f:	5f                   	pop    %edi
80101840:	5d                   	pop    %ebp
80101841:	c3                   	ret    
      return -1;
80101842:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101847:	eb f1                	jmp    8010183a <readi+0xd9>
80101849:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010184e:	eb ea                	jmp    8010183a <readi+0xd9>
    return -1;
80101850:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101855:	eb e3                	jmp    8010183a <readi+0xd9>
80101857:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010185c:	eb dc                	jmp    8010183a <readi+0xd9>

8010185e <writei>:
{
8010185e:	55                   	push   %ebp
8010185f:	89 e5                	mov    %esp,%ebp
80101861:	57                   	push   %edi
80101862:	56                   	push   %esi
80101863:	53                   	push   %ebx
80101864:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
80101867:	8b 45 08             	mov    0x8(%ebp),%eax
8010186a:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
8010186f:	74 2f                	je     801018a0 <writei+0x42>
  if(off > ip->size || off + n < off)
80101871:	8b 45 08             	mov    0x8(%ebp),%eax
80101874:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101877:	39 48 58             	cmp    %ecx,0x58(%eax)
8010187a:	0f 82 f4 00 00 00    	jb     80101974 <writei+0x116>
80101880:	89 c8                	mov    %ecx,%eax
80101882:	03 45 14             	add    0x14(%ebp),%eax
80101885:	0f 82 f0 00 00 00    	jb     8010197b <writei+0x11d>
  if(off + n > MAXFILE*BSIZE)
8010188b:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101890:	0f 87 ec 00 00 00    	ja     80101982 <writei+0x124>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101896:	be 00 00 00 00       	mov    $0x0,%esi
8010189b:	e9 94 00 00 00       	jmp    80101934 <writei+0xd6>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801018a0:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801018a4:	66 83 f8 09          	cmp    $0x9,%ax
801018a8:	0f 87 b8 00 00 00    	ja     80101966 <writei+0x108>
801018ae:	98                   	cwtl   
801018af:	8b 04 c5 64 f9 10 80 	mov    -0x7fef069c(,%eax,8),%eax
801018b6:	85 c0                	test   %eax,%eax
801018b8:	0f 84 af 00 00 00    	je     8010196d <writei+0x10f>
    return devsw[ip->major].write(ip, src, n);
801018be:	83 ec 04             	sub    $0x4,%esp
801018c1:	ff 75 14             	pushl  0x14(%ebp)
801018c4:	ff 75 0c             	pushl  0xc(%ebp)
801018c7:	ff 75 08             	pushl  0x8(%ebp)
801018ca:	ff d0                	call   *%eax
801018cc:	83 c4 10             	add    $0x10,%esp
801018cf:	eb 7c                	jmp    8010194d <writei+0xef>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801018d1:	8b 55 10             	mov    0x10(%ebp),%edx
801018d4:	c1 ea 09             	shr    $0x9,%edx
801018d7:	8b 45 08             	mov    0x8(%ebp),%eax
801018da:	e8 72 f8 ff ff       	call   80101151 <bmap>
801018df:	83 ec 08             	sub    $0x8,%esp
801018e2:	50                   	push   %eax
801018e3:	8b 45 08             	mov    0x8(%ebp),%eax
801018e6:	ff 30                	pushl  (%eax)
801018e8:	e8 7f e8 ff ff       	call   8010016c <bread>
801018ed:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
801018ef:	8b 45 10             	mov    0x10(%ebp),%eax
801018f2:	25 ff 01 00 00       	and    $0x1ff,%eax
801018f7:	bb 00 02 00 00       	mov    $0x200,%ebx
801018fc:	29 c3                	sub    %eax,%ebx
801018fe:	8b 55 14             	mov    0x14(%ebp),%edx
80101901:	29 f2                	sub    %esi,%edx
80101903:	83 c4 0c             	add    $0xc,%esp
80101906:	39 d3                	cmp    %edx,%ebx
80101908:	0f 47 da             	cmova  %edx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
8010190b:	53                   	push   %ebx
8010190c:	ff 75 0c             	pushl  0xc(%ebp)
8010190f:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
80101913:	50                   	push   %eax
80101914:	e8 91 23 00 00       	call   80103caa <memmove>
    log_write(bp);
80101919:	89 3c 24             	mov    %edi,(%esp)
8010191c:	e8 a4 0f 00 00       	call   801028c5 <log_write>
    brelse(bp);
80101921:	89 3c 24             	mov    %edi,(%esp)
80101924:	e8 ac e8 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101929:	01 de                	add    %ebx,%esi
8010192b:	01 5d 10             	add    %ebx,0x10(%ebp)
8010192e:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101931:	83 c4 10             	add    $0x10,%esp
80101934:	3b 75 14             	cmp    0x14(%ebp),%esi
80101937:	72 98                	jb     801018d1 <writei+0x73>
  if(n > 0 && off > ip->size){
80101939:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010193d:	74 0b                	je     8010194a <writei+0xec>
8010193f:	8b 45 08             	mov    0x8(%ebp),%eax
80101942:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101945:	39 48 58             	cmp    %ecx,0x58(%eax)
80101948:	72 0b                	jb     80101955 <writei+0xf7>
  return n;
8010194a:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010194d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101950:	5b                   	pop    %ebx
80101951:	5e                   	pop    %esi
80101952:	5f                   	pop    %edi
80101953:	5d                   	pop    %ebp
80101954:	c3                   	ret    
    ip->size = off;
80101955:	89 48 58             	mov    %ecx,0x58(%eax)
    iupdate(ip);
80101958:	83 ec 0c             	sub    $0xc,%esp
8010195b:	50                   	push   %eax
8010195c:	e8 ad fa ff ff       	call   8010140e <iupdate>
80101961:	83 c4 10             	add    $0x10,%esp
80101964:	eb e4                	jmp    8010194a <writei+0xec>
      return -1;
80101966:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010196b:	eb e0                	jmp    8010194d <writei+0xef>
8010196d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101972:	eb d9                	jmp    8010194d <writei+0xef>
    return -1;
80101974:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101979:	eb d2                	jmp    8010194d <writei+0xef>
8010197b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101980:	eb cb                	jmp    8010194d <writei+0xef>
    return -1;
80101982:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101987:	eb c4                	jmp    8010194d <writei+0xef>

80101989 <namecmp>:
{
80101989:	55                   	push   %ebp
8010198a:	89 e5                	mov    %esp,%ebp
8010198c:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
8010198f:	6a 0e                	push   $0xe
80101991:	ff 75 0c             	pushl  0xc(%ebp)
80101994:	ff 75 08             	pushl  0x8(%ebp)
80101997:	e8 75 23 00 00       	call   80103d11 <strncmp>
}
8010199c:	c9                   	leave  
8010199d:	c3                   	ret    

8010199e <dirlookup>:
{
8010199e:	55                   	push   %ebp
8010199f:	89 e5                	mov    %esp,%ebp
801019a1:	57                   	push   %edi
801019a2:	56                   	push   %esi
801019a3:	53                   	push   %ebx
801019a4:	83 ec 1c             	sub    $0x1c,%esp
801019a7:	8b 75 08             	mov    0x8(%ebp),%esi
801019aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
801019ad:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801019b2:	75 07                	jne    801019bb <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019b4:	bb 00 00 00 00       	mov    $0x0,%ebx
801019b9:	eb 1d                	jmp    801019d8 <dirlookup+0x3a>
    panic("dirlookup not DIR");
801019bb:	83 ec 0c             	sub    $0xc,%esp
801019be:	68 67 66 10 80       	push   $0x80106667
801019c3:	e8 80 e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019c8:	83 ec 0c             	sub    $0xc,%esp
801019cb:	68 79 66 10 80       	push   $0x80106679
801019d0:	e8 73 e9 ff ff       	call   80100348 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019d5:	83 c3 10             	add    $0x10,%ebx
801019d8:	39 5e 58             	cmp    %ebx,0x58(%esi)
801019db:	76 48                	jbe    80101a25 <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801019dd:	6a 10                	push   $0x10
801019df:	53                   	push   %ebx
801019e0:	8d 45 d8             	lea    -0x28(%ebp),%eax
801019e3:	50                   	push   %eax
801019e4:	56                   	push   %esi
801019e5:	e8 77 fd ff ff       	call   80101761 <readi>
801019ea:	83 c4 10             	add    $0x10,%esp
801019ed:	83 f8 10             	cmp    $0x10,%eax
801019f0:	75 d6                	jne    801019c8 <dirlookup+0x2a>
    if(de.inum == 0)
801019f2:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801019f7:	74 dc                	je     801019d5 <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
801019f9:	83 ec 08             	sub    $0x8,%esp
801019fc:	8d 45 da             	lea    -0x26(%ebp),%eax
801019ff:	50                   	push   %eax
80101a00:	57                   	push   %edi
80101a01:	e8 83 ff ff ff       	call   80101989 <namecmp>
80101a06:	83 c4 10             	add    $0x10,%esp
80101a09:	85 c0                	test   %eax,%eax
80101a0b:	75 c8                	jne    801019d5 <dirlookup+0x37>
      if(poff)
80101a0d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101a11:	74 05                	je     80101a18 <dirlookup+0x7a>
        *poff = off;
80101a13:	8b 45 10             	mov    0x10(%ebp),%eax
80101a16:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
80101a18:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101a1c:	8b 06                	mov    (%esi),%eax
80101a1e:	e8 d4 f7 ff ff       	call   801011f7 <iget>
80101a23:	eb 05                	jmp    80101a2a <dirlookup+0x8c>
  return 0;
80101a25:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101a2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a2d:	5b                   	pop    %ebx
80101a2e:	5e                   	pop    %esi
80101a2f:	5f                   	pop    %edi
80101a30:	5d                   	pop    %ebp
80101a31:	c3                   	ret    

80101a32 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101a32:	55                   	push   %ebp
80101a33:	89 e5                	mov    %esp,%ebp
80101a35:	57                   	push   %edi
80101a36:	56                   	push   %esi
80101a37:	53                   	push   %ebx
80101a38:	83 ec 1c             	sub    $0x1c,%esp
80101a3b:	89 c6                	mov    %eax,%esi
80101a3d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101a40:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101a43:	80 38 2f             	cmpb   $0x2f,(%eax)
80101a46:	74 17                	je     80101a5f <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101a48:	e8 97 17 00 00       	call   801031e4 <myproc>
80101a4d:	83 ec 0c             	sub    $0xc,%esp
80101a50:	ff 70 68             	pushl  0x68(%eax)
80101a53:	e8 e7 fa ff ff       	call   8010153f <idup>
80101a58:	89 c3                	mov    %eax,%ebx
80101a5a:	83 c4 10             	add    $0x10,%esp
80101a5d:	eb 53                	jmp    80101ab2 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101a5f:	ba 01 00 00 00       	mov    $0x1,%edx
80101a64:	b8 01 00 00 00       	mov    $0x1,%eax
80101a69:	e8 89 f7 ff ff       	call   801011f7 <iget>
80101a6e:	89 c3                	mov    %eax,%ebx
80101a70:	eb 40                	jmp    80101ab2 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101a72:	83 ec 0c             	sub    $0xc,%esp
80101a75:	53                   	push   %ebx
80101a76:	e8 9b fc ff ff       	call   80101716 <iunlockput>
      return 0;
80101a7b:	83 c4 10             	add    $0x10,%esp
80101a7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a83:	89 d8                	mov    %ebx,%eax
80101a85:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a88:	5b                   	pop    %ebx
80101a89:	5e                   	pop    %esi
80101a8a:	5f                   	pop    %edi
80101a8b:	5d                   	pop    %ebp
80101a8c:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101a8d:	83 ec 04             	sub    $0x4,%esp
80101a90:	6a 00                	push   $0x0
80101a92:	ff 75 e4             	pushl  -0x1c(%ebp)
80101a95:	53                   	push   %ebx
80101a96:	e8 03 ff ff ff       	call   8010199e <dirlookup>
80101a9b:	89 c7                	mov    %eax,%edi
80101a9d:	83 c4 10             	add    $0x10,%esp
80101aa0:	85 c0                	test   %eax,%eax
80101aa2:	74 4a                	je     80101aee <namex+0xbc>
    iunlockput(ip);
80101aa4:	83 ec 0c             	sub    $0xc,%esp
80101aa7:	53                   	push   %ebx
80101aa8:	e8 69 fc ff ff       	call   80101716 <iunlockput>
    ip = next;
80101aad:	83 c4 10             	add    $0x10,%esp
80101ab0:	89 fb                	mov    %edi,%ebx
  while((path = skipelem(path, name)) != 0){
80101ab2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101ab5:	89 f0                	mov    %esi,%eax
80101ab7:	e8 89 f4 ff ff       	call   80100f45 <skipelem>
80101abc:	89 c6                	mov    %eax,%esi
80101abe:	85 c0                	test   %eax,%eax
80101ac0:	74 3c                	je     80101afe <namex+0xcc>
    ilock(ip);
80101ac2:	83 ec 0c             	sub    $0xc,%esp
80101ac5:	53                   	push   %ebx
80101ac6:	e8 a4 fa ff ff       	call   8010156f <ilock>
    if(ip->type != T_DIR){
80101acb:	83 c4 10             	add    $0x10,%esp
80101ace:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101ad3:	75 9d                	jne    80101a72 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101ad5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101ad9:	74 b2                	je     80101a8d <namex+0x5b>
80101adb:	80 3e 00             	cmpb   $0x0,(%esi)
80101ade:	75 ad                	jne    80101a8d <namex+0x5b>
      iunlock(ip);
80101ae0:	83 ec 0c             	sub    $0xc,%esp
80101ae3:	53                   	push   %ebx
80101ae4:	e8 48 fb ff ff       	call   80101631 <iunlock>
      return ip;
80101ae9:	83 c4 10             	add    $0x10,%esp
80101aec:	eb 95                	jmp    80101a83 <namex+0x51>
      iunlockput(ip);
80101aee:	83 ec 0c             	sub    $0xc,%esp
80101af1:	53                   	push   %ebx
80101af2:	e8 1f fc ff ff       	call   80101716 <iunlockput>
      return 0;
80101af7:	83 c4 10             	add    $0x10,%esp
80101afa:	89 fb                	mov    %edi,%ebx
80101afc:	eb 85                	jmp    80101a83 <namex+0x51>
  if(nameiparent){
80101afe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b02:	0f 84 7b ff ff ff    	je     80101a83 <namex+0x51>
    iput(ip);
80101b08:	83 ec 0c             	sub    $0xc,%esp
80101b0b:	53                   	push   %ebx
80101b0c:	e8 65 fb ff ff       	call   80101676 <iput>
    return 0;
80101b11:	83 c4 10             	add    $0x10,%esp
80101b14:	bb 00 00 00 00       	mov    $0x0,%ebx
80101b19:	e9 65 ff ff ff       	jmp    80101a83 <namex+0x51>

80101b1e <dirlink>:
{
80101b1e:	55                   	push   %ebp
80101b1f:	89 e5                	mov    %esp,%ebp
80101b21:	57                   	push   %edi
80101b22:	56                   	push   %esi
80101b23:	53                   	push   %ebx
80101b24:	83 ec 20             	sub    $0x20,%esp
80101b27:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101b2a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101b2d:	6a 00                	push   $0x0
80101b2f:	57                   	push   %edi
80101b30:	53                   	push   %ebx
80101b31:	e8 68 fe ff ff       	call   8010199e <dirlookup>
80101b36:	83 c4 10             	add    $0x10,%esp
80101b39:	85 c0                	test   %eax,%eax
80101b3b:	75 2d                	jne    80101b6a <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b3d:	b8 00 00 00 00       	mov    $0x0,%eax
80101b42:	89 c6                	mov    %eax,%esi
80101b44:	39 43 58             	cmp    %eax,0x58(%ebx)
80101b47:	76 41                	jbe    80101b8a <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b49:	6a 10                	push   $0x10
80101b4b:	50                   	push   %eax
80101b4c:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101b4f:	50                   	push   %eax
80101b50:	53                   	push   %ebx
80101b51:	e8 0b fc ff ff       	call   80101761 <readi>
80101b56:	83 c4 10             	add    $0x10,%esp
80101b59:	83 f8 10             	cmp    $0x10,%eax
80101b5c:	75 1f                	jne    80101b7d <dirlink+0x5f>
    if(de.inum == 0)
80101b5e:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b63:	74 25                	je     80101b8a <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b65:	8d 46 10             	lea    0x10(%esi),%eax
80101b68:	eb d8                	jmp    80101b42 <dirlink+0x24>
    iput(ip);
80101b6a:	83 ec 0c             	sub    $0xc,%esp
80101b6d:	50                   	push   %eax
80101b6e:	e8 03 fb ff ff       	call   80101676 <iput>
    return -1;
80101b73:	83 c4 10             	add    $0x10,%esp
80101b76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b7b:	eb 3d                	jmp    80101bba <dirlink+0x9c>
      panic("dirlink read");
80101b7d:	83 ec 0c             	sub    $0xc,%esp
80101b80:	68 88 66 10 80       	push   $0x80106688
80101b85:	e8 be e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b8a:	83 ec 04             	sub    $0x4,%esp
80101b8d:	6a 0e                	push   $0xe
80101b8f:	57                   	push   %edi
80101b90:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101b93:	8d 45 da             	lea    -0x26(%ebp),%eax
80101b96:	50                   	push   %eax
80101b97:	e8 b2 21 00 00       	call   80103d4e <strncpy>
  de.inum = inum;
80101b9c:	8b 45 10             	mov    0x10(%ebp),%eax
80101b9f:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101ba3:	6a 10                	push   $0x10
80101ba5:	56                   	push   %esi
80101ba6:	57                   	push   %edi
80101ba7:	53                   	push   %ebx
80101ba8:	e8 b1 fc ff ff       	call   8010185e <writei>
80101bad:	83 c4 20             	add    $0x20,%esp
80101bb0:	83 f8 10             	cmp    $0x10,%eax
80101bb3:	75 0d                	jne    80101bc2 <dirlink+0xa4>
  return 0;
80101bb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101bbd:	5b                   	pop    %ebx
80101bbe:	5e                   	pop    %esi
80101bbf:	5f                   	pop    %edi
80101bc0:	5d                   	pop    %ebp
80101bc1:	c3                   	ret    
    panic("dirlink");
80101bc2:	83 ec 0c             	sub    $0xc,%esp
80101bc5:	68 9c 6c 10 80       	push   $0x80106c9c
80101bca:	e8 79 e7 ff ff       	call   80100348 <panic>

80101bcf <namei>:

struct inode*
namei(char *path)
{
80101bcf:	55                   	push   %ebp
80101bd0:	89 e5                	mov    %esp,%ebp
80101bd2:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101bd5:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101bd8:	ba 00 00 00 00       	mov    $0x0,%edx
80101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101be0:	e8 4d fe ff ff       	call   80101a32 <namex>
}
80101be5:	c9                   	leave  
80101be6:	c3                   	ret    

80101be7 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101be7:	55                   	push   %ebp
80101be8:	89 e5                	mov    %esp,%ebp
80101bea:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101bed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101bf0:	ba 01 00 00 00       	mov    $0x1,%edx
80101bf5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf8:	e8 35 fe ff ff       	call   80101a32 <namex>
}
80101bfd:	c9                   	leave  
80101bfe:	c3                   	ret    

80101bff <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101bff:	55                   	push   %ebp
80101c00:	89 e5                	mov    %esp,%ebp
80101c02:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101c04:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c09:	ec                   	in     (%dx),%al
80101c0a:	89 c2                	mov    %eax,%edx
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101c0c:	83 e0 c0             	and    $0xffffffc0,%eax
80101c0f:	3c 40                	cmp    $0x40,%al
80101c11:	75 f1                	jne    80101c04 <idewait+0x5>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101c13:	85 c9                	test   %ecx,%ecx
80101c15:	74 0c                	je     80101c23 <idewait+0x24>
80101c17:	f6 c2 21             	test   $0x21,%dl
80101c1a:	75 0e                	jne    80101c2a <idewait+0x2b>
    return -1;
  return 0;
80101c1c:	b8 00 00 00 00       	mov    $0x0,%eax
80101c21:	eb 05                	jmp    80101c28 <idewait+0x29>
80101c23:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101c28:	5d                   	pop    %ebp
80101c29:	c3                   	ret    
    return -1;
80101c2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101c2f:	eb f7                	jmp    80101c28 <idewait+0x29>

80101c31 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101c31:	55                   	push   %ebp
80101c32:	89 e5                	mov    %esp,%ebp
80101c34:	56                   	push   %esi
80101c35:	53                   	push   %ebx
  if(b == 0)
80101c36:	85 c0                	test   %eax,%eax
80101c38:	74 7d                	je     80101cb7 <idestart+0x86>
80101c3a:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101c3c:	8b 58 08             	mov    0x8(%eax),%ebx
80101c3f:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101c45:	77 7d                	ja     80101cc4 <idestart+0x93>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101c47:	b8 00 00 00 00       	mov    $0x0,%eax
80101c4c:	e8 ae ff ff ff       	call   80101bff <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c51:	b8 00 00 00 00       	mov    $0x0,%eax
80101c56:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101c5b:	ee                   	out    %al,(%dx)
80101c5c:	b8 01 00 00 00       	mov    $0x1,%eax
80101c61:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101c66:	ee                   	out    %al,(%dx)
80101c67:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c6c:	89 d8                	mov    %ebx,%eax
80101c6e:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101c6f:	89 d8                	mov    %ebx,%eax
80101c71:	c1 f8 08             	sar    $0x8,%eax
80101c74:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c79:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101c7a:	89 d8                	mov    %ebx,%eax
80101c7c:	c1 f8 10             	sar    $0x10,%eax
80101c7f:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101c84:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101c85:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101c89:	c1 e0 04             	shl    $0x4,%eax
80101c8c:	83 e0 10             	and    $0x10,%eax
80101c8f:	c1 fb 18             	sar    $0x18,%ebx
80101c92:	83 e3 0f             	and    $0xf,%ebx
80101c95:	09 d8                	or     %ebx,%eax
80101c97:	83 c8 e0             	or     $0xffffffe0,%eax
80101c9a:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101c9f:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101ca0:	f6 06 04             	testb  $0x4,(%esi)
80101ca3:	75 2c                	jne    80101cd1 <idestart+0xa0>
80101ca5:	b8 20 00 00 00       	mov    $0x20,%eax
80101caa:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101caf:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101cb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101cb3:	5b                   	pop    %ebx
80101cb4:	5e                   	pop    %esi
80101cb5:	5d                   	pop    %ebp
80101cb6:	c3                   	ret    
    panic("idestart");
80101cb7:	83 ec 0c             	sub    $0xc,%esp
80101cba:	68 eb 66 10 80       	push   $0x801066eb
80101cbf:	e8 84 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cc4:	83 ec 0c             	sub    $0xc,%esp
80101cc7:	68 f4 66 10 80       	push   $0x801066f4
80101ccc:	e8 77 e6 ff ff       	call   80100348 <panic>
80101cd1:	b8 30 00 00 00       	mov    $0x30,%eax
80101cd6:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cdb:	ee                   	out    %al,(%dx)
    outsl(0x1f0, b->data, BSIZE/4);
80101cdc:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101cdf:	b9 80 00 00 00       	mov    $0x80,%ecx
80101ce4:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101ce9:	fc                   	cld    
80101cea:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80101cec:	eb c2                	jmp    80101cb0 <idestart+0x7f>

80101cee <ideinit>:
{
80101cee:	55                   	push   %ebp
80101cef:	89 e5                	mov    %esp,%ebp
80101cf1:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101cf4:	68 06 67 10 80       	push   $0x80106706
80101cf9:	68 80 95 10 80       	push   $0x80109580
80101cfe:	e8 44 1d 00 00       	call   80103a47 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101d03:	83 c4 08             	add    $0x8,%esp
80101d06:	a1 00 1d 11 80       	mov    0x80111d00,%eax
80101d0b:	83 e8 01             	sub    $0x1,%eax
80101d0e:	50                   	push   %eax
80101d0f:	6a 0e                	push   $0xe
80101d11:	e8 56 02 00 00       	call   80101f6c <ioapicenable>
  idewait(0);
80101d16:	b8 00 00 00 00       	mov    $0x0,%eax
80101d1b:	e8 df fe ff ff       	call   80101bff <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d20:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101d25:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d2a:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101d2b:	83 c4 10             	add    $0x10,%esp
80101d2e:	b9 00 00 00 00       	mov    $0x0,%ecx
80101d33:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101d39:	7f 19                	jg     80101d54 <ideinit+0x66>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d3b:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d40:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101d41:	84 c0                	test   %al,%al
80101d43:	75 05                	jne    80101d4a <ideinit+0x5c>
  for(i=0; i<1000; i++){
80101d45:	83 c1 01             	add    $0x1,%ecx
80101d48:	eb e9                	jmp    80101d33 <ideinit+0x45>
      havedisk1 = 1;
80101d4a:	c7 05 60 95 10 80 01 	movl   $0x1,0x80109560
80101d51:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d54:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101d59:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d5e:	ee                   	out    %al,(%dx)
}
80101d5f:	c9                   	leave  
80101d60:	c3                   	ret    

80101d61 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101d61:	55                   	push   %ebp
80101d62:	89 e5                	mov    %esp,%ebp
80101d64:	57                   	push   %edi
80101d65:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101d66:	83 ec 0c             	sub    $0xc,%esp
80101d69:	68 80 95 10 80       	push   $0x80109580
80101d6e:	e8 10 1e 00 00       	call   80103b83 <acquire>

  if((b = idequeue) == 0){
80101d73:	8b 1d 64 95 10 80    	mov    0x80109564,%ebx
80101d79:	83 c4 10             	add    $0x10,%esp
80101d7c:	85 db                	test   %ebx,%ebx
80101d7e:	74 48                	je     80101dc8 <ideintr+0x67>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d80:	8b 43 58             	mov    0x58(%ebx),%eax
80101d83:	a3 64 95 10 80       	mov    %eax,0x80109564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d88:	f6 03 04             	testb  $0x4,(%ebx)
80101d8b:	74 4d                	je     80101dda <ideintr+0x79>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101d8d:	8b 03                	mov    (%ebx),%eax
80101d8f:	83 c8 02             	or     $0x2,%eax
  b->flags &= ~B_DIRTY;
80101d92:	83 e0 fb             	and    $0xfffffffb,%eax
80101d95:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101d97:	83 ec 0c             	sub    $0xc,%esp
80101d9a:	53                   	push   %ebx
80101d9b:	e8 4d 1a 00 00       	call   801037ed <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101da0:	a1 64 95 10 80       	mov    0x80109564,%eax
80101da5:	83 c4 10             	add    $0x10,%esp
80101da8:	85 c0                	test   %eax,%eax
80101daa:	74 05                	je     80101db1 <ideintr+0x50>
    idestart(idequeue);
80101dac:	e8 80 fe ff ff       	call   80101c31 <idestart>

  release(&idelock);
80101db1:	83 ec 0c             	sub    $0xc,%esp
80101db4:	68 80 95 10 80       	push   $0x80109580
80101db9:	e8 2a 1e 00 00       	call   80103be8 <release>
80101dbe:	83 c4 10             	add    $0x10,%esp
}
80101dc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101dc4:	5b                   	pop    %ebx
80101dc5:	5f                   	pop    %edi
80101dc6:	5d                   	pop    %ebp
80101dc7:	c3                   	ret    
    release(&idelock);
80101dc8:	83 ec 0c             	sub    $0xc,%esp
80101dcb:	68 80 95 10 80       	push   $0x80109580
80101dd0:	e8 13 1e 00 00       	call   80103be8 <release>
    return;
80101dd5:	83 c4 10             	add    $0x10,%esp
80101dd8:	eb e7                	jmp    80101dc1 <ideintr+0x60>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101dda:	b8 01 00 00 00       	mov    $0x1,%eax
80101ddf:	e8 1b fe ff ff       	call   80101bff <idewait>
80101de4:	85 c0                	test   %eax,%eax
80101de6:	78 a5                	js     80101d8d <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101de8:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101deb:	b9 80 00 00 00       	mov    $0x80,%ecx
80101df0:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101df5:	fc                   	cld    
80101df6:	f3 6d                	rep insl (%dx),%es:(%edi)
80101df8:	eb 93                	jmp    80101d8d <ideintr+0x2c>

80101dfa <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101dfa:	55                   	push   %ebp
80101dfb:	89 e5                	mov    %esp,%ebp
80101dfd:	53                   	push   %ebx
80101dfe:	83 ec 10             	sub    $0x10,%esp
80101e01:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101e04:	8d 43 0c             	lea    0xc(%ebx),%eax
80101e07:	50                   	push   %eax
80101e08:	e8 ec 1b 00 00       	call   801039f9 <holdingsleep>
80101e0d:	83 c4 10             	add    $0x10,%esp
80101e10:	85 c0                	test   %eax,%eax
80101e12:	74 37                	je     80101e4b <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101e14:	8b 03                	mov    (%ebx),%eax
80101e16:	83 e0 06             	and    $0x6,%eax
80101e19:	83 f8 02             	cmp    $0x2,%eax
80101e1c:	74 3a                	je     80101e58 <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101e1e:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101e22:	74 09                	je     80101e2d <iderw+0x33>
80101e24:	83 3d 60 95 10 80 00 	cmpl   $0x0,0x80109560
80101e2b:	74 38                	je     80101e65 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101e2d:	83 ec 0c             	sub    $0xc,%esp
80101e30:	68 80 95 10 80       	push   $0x80109580
80101e35:	e8 49 1d 00 00       	call   80103b83 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e3a:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e41:	83 c4 10             	add    $0x10,%esp
80101e44:	ba 64 95 10 80       	mov    $0x80109564,%edx
80101e49:	eb 2a                	jmp    80101e75 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e4b:	83 ec 0c             	sub    $0xc,%esp
80101e4e:	68 0a 67 10 80       	push   $0x8010670a
80101e53:	e8 f0 e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e58:	83 ec 0c             	sub    $0xc,%esp
80101e5b:	68 20 67 10 80       	push   $0x80106720
80101e60:	e8 e3 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e65:	83 ec 0c             	sub    $0xc,%esp
80101e68:	68 35 67 10 80       	push   $0x80106735
80101e6d:	e8 d6 e4 ff ff       	call   80100348 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e72:	8d 50 58             	lea    0x58(%eax),%edx
80101e75:	8b 02                	mov    (%edx),%eax
80101e77:	85 c0                	test   %eax,%eax
80101e79:	75 f7                	jne    80101e72 <iderw+0x78>
    ;
  *pp = b;
80101e7b:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101e7d:	39 1d 64 95 10 80    	cmp    %ebx,0x80109564
80101e83:	75 1a                	jne    80101e9f <iderw+0xa5>
    idestart(b);
80101e85:	89 d8                	mov    %ebx,%eax
80101e87:	e8 a5 fd ff ff       	call   80101c31 <idestart>
80101e8c:	eb 11                	jmp    80101e9f <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101e8e:	83 ec 08             	sub    $0x8,%esp
80101e91:	68 80 95 10 80       	push   $0x80109580
80101e96:	53                   	push   %ebx
80101e97:	e8 ec 17 00 00       	call   80103688 <sleep>
80101e9c:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101e9f:	8b 03                	mov    (%ebx),%eax
80101ea1:	83 e0 06             	and    $0x6,%eax
80101ea4:	83 f8 02             	cmp    $0x2,%eax
80101ea7:	75 e5                	jne    80101e8e <iderw+0x94>
  }


  release(&idelock);
80101ea9:	83 ec 0c             	sub    $0xc,%esp
80101eac:	68 80 95 10 80       	push   $0x80109580
80101eb1:	e8 32 1d 00 00       	call   80103be8 <release>
}
80101eb6:	83 c4 10             	add    $0x10,%esp
80101eb9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101ebc:	c9                   	leave  
80101ebd:	c3                   	ret    

80101ebe <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80101ebe:	55                   	push   %ebp
80101ebf:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ec1:	8b 15 34 16 11 80    	mov    0x80111634,%edx
80101ec7:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101ec9:	a1 34 16 11 80       	mov    0x80111634,%eax
80101ece:	8b 40 10             	mov    0x10(%eax),%eax
}
80101ed1:	5d                   	pop    %ebp
80101ed2:	c3                   	ret    

80101ed3 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80101ed3:	55                   	push   %ebp
80101ed4:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ed6:	8b 0d 34 16 11 80    	mov    0x80111634,%ecx
80101edc:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101ede:	a1 34 16 11 80       	mov    0x80111634,%eax
80101ee3:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ee6:	5d                   	pop    %ebp
80101ee7:	c3                   	ret    

80101ee8 <ioapicinit>:

void
ioapicinit(void)
{
80101ee8:	55                   	push   %ebp
80101ee9:	89 e5                	mov    %esp,%ebp
80101eeb:	57                   	push   %edi
80101eec:	56                   	push   %esi
80101eed:	53                   	push   %ebx
80101eee:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101ef1:	c7 05 34 16 11 80 00 	movl   $0xfec00000,0x80111634
80101ef8:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101efb:	b8 01 00 00 00       	mov    $0x1,%eax
80101f00:	e8 b9 ff ff ff       	call   80101ebe <ioapicread>
80101f05:	c1 e8 10             	shr    $0x10,%eax
80101f08:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101f0b:	b8 00 00 00 00       	mov    $0x0,%eax
80101f10:	e8 a9 ff ff ff       	call   80101ebe <ioapicread>
80101f15:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101f18:	0f b6 15 60 17 11 80 	movzbl 0x80111760,%edx
80101f1f:	39 c2                	cmp    %eax,%edx
80101f21:	75 07                	jne    80101f2a <ioapicinit+0x42>
{
80101f23:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f28:	eb 36                	jmp    80101f60 <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f2a:	83 ec 0c             	sub    $0xc,%esp
80101f2d:	68 54 67 10 80       	push   $0x80106754
80101f32:	e8 d4 e6 ff ff       	call   8010060b <cprintf>
80101f37:	83 c4 10             	add    $0x10,%esp
80101f3a:	eb e7                	jmp    80101f23 <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101f3c:	8d 53 20             	lea    0x20(%ebx),%edx
80101f3f:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101f45:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101f49:	89 f0                	mov    %esi,%eax
80101f4b:	e8 83 ff ff ff       	call   80101ed3 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101f50:	8d 46 01             	lea    0x1(%esi),%eax
80101f53:	ba 00 00 00 00       	mov    $0x0,%edx
80101f58:	e8 76 ff ff ff       	call   80101ed3 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101f5d:	83 c3 01             	add    $0x1,%ebx
80101f60:	39 fb                	cmp    %edi,%ebx
80101f62:	7e d8                	jle    80101f3c <ioapicinit+0x54>
  }
}
80101f64:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f67:	5b                   	pop    %ebx
80101f68:	5e                   	pop    %esi
80101f69:	5f                   	pop    %edi
80101f6a:	5d                   	pop    %ebp
80101f6b:	c3                   	ret    

80101f6c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101f6c:	55                   	push   %ebp
80101f6d:	89 e5                	mov    %esp,%ebp
80101f6f:	53                   	push   %ebx
80101f70:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101f73:	8d 50 20             	lea    0x20(%eax),%edx
80101f76:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101f7a:	89 d8                	mov    %ebx,%eax
80101f7c:	e8 52 ff ff ff       	call   80101ed3 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f81:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f84:	c1 e2 18             	shl    $0x18,%edx
80101f87:	8d 43 01             	lea    0x1(%ebx),%eax
80101f8a:	e8 44 ff ff ff       	call   80101ed3 <ioapicwrite>
}
80101f8f:	5b                   	pop    %ebx
80101f90:	5d                   	pop    %ebp
80101f91:	c3                   	ret    

80101f92 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101f92:	55                   	push   %ebp
80101f93:	89 e5                	mov    %esp,%ebp
80101f95:	53                   	push   %ebx
80101f96:	83 ec 04             	sub    $0x4,%esp
80101f99:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101f9c:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101fa2:	75 4c                	jne    80101ff0 <kfree+0x5e>
80101fa4:	81 fb a8 44 11 80    	cmp    $0x801144a8,%ebx
80101faa:	72 44                	jb     80101ff0 <kfree+0x5e>
80101fac:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101fb2:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101fb7:	77 37                	ja     80101ff0 <kfree+0x5e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101fb9:	83 ec 04             	sub    $0x4,%esp
80101fbc:	68 00 10 00 00       	push   $0x1000
80101fc1:	6a 01                	push   $0x1
80101fc3:	53                   	push   %ebx
80101fc4:	e8 66 1c 00 00       	call   80103c2f <memset>

  if(kmem.use_lock)
80101fc9:	83 c4 10             	add    $0x10,%esp
80101fcc:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80101fd3:	75 28                	jne    80101ffd <kfree+0x6b>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80101fd5:	a1 78 16 11 80       	mov    0x80111678,%eax
80101fda:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101fdc:	89 1d 78 16 11 80    	mov    %ebx,0x80111678
  if(kmem.use_lock)
80101fe2:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
80101fe9:	75 24                	jne    8010200f <kfree+0x7d>
    release(&kmem.lock);
}
80101feb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101fee:	c9                   	leave  
80101fef:	c3                   	ret    
    panic("kfree");
80101ff0:	83 ec 0c             	sub    $0xc,%esp
80101ff3:	68 86 67 10 80       	push   $0x80106786
80101ff8:	e8 4b e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
80101ffd:	83 ec 0c             	sub    $0xc,%esp
80102000:	68 40 16 11 80       	push   $0x80111640
80102005:	e8 79 1b 00 00       	call   80103b83 <acquire>
8010200a:	83 c4 10             	add    $0x10,%esp
8010200d:	eb c6                	jmp    80101fd5 <kfree+0x43>
    release(&kmem.lock);
8010200f:	83 ec 0c             	sub    $0xc,%esp
80102012:	68 40 16 11 80       	push   $0x80111640
80102017:	e8 cc 1b 00 00       	call   80103be8 <release>
8010201c:	83 c4 10             	add    $0x10,%esp
}
8010201f:	eb ca                	jmp    80101feb <kfree+0x59>

80102021 <freerange>:
{
80102021:	55                   	push   %ebp
80102022:	89 e5                	mov    %esp,%ebp
80102024:	56                   	push   %esi
80102025:	53                   	push   %ebx
80102026:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
80102029:	8b 45 08             	mov    0x8(%ebp),%eax
8010202c:	05 ff 0f 00 00       	add    $0xfff,%eax
80102031:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102036:	eb 0e                	jmp    80102046 <freerange+0x25>
    kfree(p);
80102038:	83 ec 0c             	sub    $0xc,%esp
8010203b:	50                   	push   %eax
8010203c:	e8 51 ff ff ff       	call   80101f92 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102041:	83 c4 10             	add    $0x10,%esp
80102044:	89 f0                	mov    %esi,%eax
80102046:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
8010204c:	39 de                	cmp    %ebx,%esi
8010204e:	76 e8                	jbe    80102038 <freerange+0x17>
}
80102050:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102053:	5b                   	pop    %ebx
80102054:	5e                   	pop    %esi
80102055:	5d                   	pop    %ebp
80102056:	c3                   	ret    

80102057 <kinit1>:
{
80102057:	55                   	push   %ebp
80102058:	89 e5                	mov    %esp,%ebp
8010205a:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
8010205d:	68 8c 67 10 80       	push   $0x8010678c
80102062:	68 40 16 11 80       	push   $0x80111640
80102067:	e8 db 19 00 00       	call   80103a47 <initlock>
  kmem.use_lock = 0;
8010206c:	c7 05 74 16 11 80 00 	movl   $0x0,0x80111674
80102073:	00 00 00 
  freerange(vstart, vend);
80102076:	83 c4 08             	add    $0x8,%esp
80102079:	ff 75 0c             	pushl  0xc(%ebp)
8010207c:	ff 75 08             	pushl  0x8(%ebp)
8010207f:	e8 9d ff ff ff       	call   80102021 <freerange>
}
80102084:	83 c4 10             	add    $0x10,%esp
80102087:	c9                   	leave  
80102088:	c3                   	ret    

80102089 <kinit2>:
{
80102089:	55                   	push   %ebp
8010208a:	89 e5                	mov    %esp,%ebp
8010208c:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
8010208f:	ff 75 0c             	pushl  0xc(%ebp)
80102092:	ff 75 08             	pushl  0x8(%ebp)
80102095:	e8 87 ff ff ff       	call   80102021 <freerange>
  kmem.use_lock = 1;
8010209a:	c7 05 74 16 11 80 01 	movl   $0x1,0x80111674
801020a1:	00 00 00 
}
801020a4:	83 c4 10             	add    $0x10,%esp
801020a7:	c9                   	leave  
801020a8:	c3                   	ret    

801020a9 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801020a9:	55                   	push   %ebp
801020aa:	89 e5                	mov    %esp,%ebp
801020ac:	53                   	push   %ebx
801020ad:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
801020b0:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
801020b7:	75 21                	jne    801020da <kalloc+0x31>
    acquire(&kmem.lock);
  r = kmem.freelist;
801020b9:	8b 1d 78 16 11 80    	mov    0x80111678,%ebx
  if(r)
801020bf:	85 db                	test   %ebx,%ebx
801020c1:	74 07                	je     801020ca <kalloc+0x21>
    kmem.freelist = r->next;
801020c3:	8b 03                	mov    (%ebx),%eax
801020c5:	a3 78 16 11 80       	mov    %eax,0x80111678
  if(kmem.use_lock)
801020ca:	83 3d 74 16 11 80 00 	cmpl   $0x0,0x80111674
801020d1:	75 19                	jne    801020ec <kalloc+0x43>
    release(&kmem.lock);
  return (char*)r;
}
801020d3:	89 d8                	mov    %ebx,%eax
801020d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801020d8:	c9                   	leave  
801020d9:	c3                   	ret    
    acquire(&kmem.lock);
801020da:	83 ec 0c             	sub    $0xc,%esp
801020dd:	68 40 16 11 80       	push   $0x80111640
801020e2:	e8 9c 1a 00 00       	call   80103b83 <acquire>
801020e7:	83 c4 10             	add    $0x10,%esp
801020ea:	eb cd                	jmp    801020b9 <kalloc+0x10>
    release(&kmem.lock);
801020ec:	83 ec 0c             	sub    $0xc,%esp
801020ef:	68 40 16 11 80       	push   $0x80111640
801020f4:	e8 ef 1a 00 00       	call   80103be8 <release>
801020f9:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801020fc:	eb d5                	jmp    801020d3 <kalloc+0x2a>

801020fe <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801020fe:	55                   	push   %ebp
801020ff:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102101:	ba 64 00 00 00       	mov    $0x64,%edx
80102106:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102107:	a8 01                	test   $0x1,%al
80102109:	0f 84 b5 00 00 00    	je     801021c4 <kbdgetc+0xc6>
8010210f:	ba 60 00 00 00       	mov    $0x60,%edx
80102114:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102115:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
80102118:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
8010211e:	74 5c                	je     8010217c <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102120:	84 c0                	test   %al,%al
80102122:	78 66                	js     8010218a <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102124:	8b 0d b4 95 10 80    	mov    0x801095b4,%ecx
8010212a:	f6 c1 40             	test   $0x40,%cl
8010212d:	74 0f                	je     8010213e <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
8010212f:	83 c8 80             	or     $0xffffff80,%eax
80102132:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
80102135:	83 e1 bf             	and    $0xffffffbf,%ecx
80102138:	89 0d b4 95 10 80    	mov    %ecx,0x801095b4
  }

  shift |= shiftcode[data];
8010213e:	0f b6 8a c0 68 10 80 	movzbl -0x7fef9740(%edx),%ecx
80102145:	0b 0d b4 95 10 80    	or     0x801095b4,%ecx
  shift ^= togglecode[data];
8010214b:	0f b6 82 c0 67 10 80 	movzbl -0x7fef9840(%edx),%eax
80102152:	31 c1                	xor    %eax,%ecx
80102154:	89 0d b4 95 10 80    	mov    %ecx,0x801095b4
  c = charcode[shift & (CTL | SHIFT)][data];
8010215a:	89 c8                	mov    %ecx,%eax
8010215c:	83 e0 03             	and    $0x3,%eax
8010215f:	8b 04 85 a0 67 10 80 	mov    -0x7fef9860(,%eax,4),%eax
80102166:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
8010216a:	f6 c1 08             	test   $0x8,%cl
8010216d:	74 19                	je     80102188 <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
8010216f:	8d 50 9f             	lea    -0x61(%eax),%edx
80102172:	83 fa 19             	cmp    $0x19,%edx
80102175:	77 40                	ja     801021b7 <kbdgetc+0xb9>
      c += 'A' - 'a';
80102177:	83 e8 20             	sub    $0x20,%eax
8010217a:	eb 0c                	jmp    80102188 <kbdgetc+0x8a>
    shift |= E0ESC;
8010217c:	83 0d b4 95 10 80 40 	orl    $0x40,0x801095b4
    return 0;
80102183:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102188:	5d                   	pop    %ebp
80102189:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
8010218a:	8b 0d b4 95 10 80    	mov    0x801095b4,%ecx
80102190:	f6 c1 40             	test   $0x40,%cl
80102193:	75 05                	jne    8010219a <kbdgetc+0x9c>
80102195:	89 c2                	mov    %eax,%edx
80102197:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
8010219a:	0f b6 82 c0 68 10 80 	movzbl -0x7fef9740(%edx),%eax
801021a1:	83 c8 40             	or     $0x40,%eax
801021a4:	0f b6 c0             	movzbl %al,%eax
801021a7:	f7 d0                	not    %eax
801021a9:	21 c8                	and    %ecx,%eax
801021ab:	a3 b4 95 10 80       	mov    %eax,0x801095b4
    return 0;
801021b0:	b8 00 00 00 00       	mov    $0x0,%eax
801021b5:	eb d1                	jmp    80102188 <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
801021b7:	8d 50 bf             	lea    -0x41(%eax),%edx
801021ba:	83 fa 19             	cmp    $0x19,%edx
801021bd:	77 c9                	ja     80102188 <kbdgetc+0x8a>
      c += 'a' - 'A';
801021bf:	83 c0 20             	add    $0x20,%eax
  return c;
801021c2:	eb c4                	jmp    80102188 <kbdgetc+0x8a>
    return -1;
801021c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021c9:	eb bd                	jmp    80102188 <kbdgetc+0x8a>

801021cb <kbdintr>:

void
kbdintr(void)
{
801021cb:	55                   	push   %ebp
801021cc:	89 e5                	mov    %esp,%ebp
801021ce:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801021d1:	68 fe 20 10 80       	push   $0x801020fe
801021d6:	e8 63 e5 ff ff       	call   8010073e <consoleintr>
}
801021db:	83 c4 10             	add    $0x10,%esp
801021de:	c9                   	leave  
801021df:	c3                   	ret    

801021e0 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801021e0:	55                   	push   %ebp
801021e1:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801021e3:	8b 0d 7c 16 11 80    	mov    0x8011167c,%ecx
801021e9:	8d 04 81             	lea    (%ecx,%eax,4),%eax
801021ec:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
801021ee:	a1 7c 16 11 80       	mov    0x8011167c,%eax
801021f3:	8b 40 20             	mov    0x20(%eax),%eax
}
801021f6:	5d                   	pop    %ebp
801021f7:	c3                   	ret    

801021f8 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801021f8:	55                   	push   %ebp
801021f9:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801021fb:	ba 70 00 00 00       	mov    $0x70,%edx
80102200:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102201:	ba 71 00 00 00       	mov    $0x71,%edx
80102206:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
80102207:	0f b6 c0             	movzbl %al,%eax
}
8010220a:	5d                   	pop    %ebp
8010220b:	c3                   	ret    

8010220c <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
8010220c:	55                   	push   %ebp
8010220d:	89 e5                	mov    %esp,%ebp
8010220f:	53                   	push   %ebx
80102210:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
80102212:	b8 00 00 00 00       	mov    $0x0,%eax
80102217:	e8 dc ff ff ff       	call   801021f8 <cmos_read>
8010221c:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
8010221e:	b8 02 00 00 00       	mov    $0x2,%eax
80102223:	e8 d0 ff ff ff       	call   801021f8 <cmos_read>
80102228:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
8010222b:	b8 04 00 00 00       	mov    $0x4,%eax
80102230:	e8 c3 ff ff ff       	call   801021f8 <cmos_read>
80102235:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
80102238:	b8 07 00 00 00       	mov    $0x7,%eax
8010223d:	e8 b6 ff ff ff       	call   801021f8 <cmos_read>
80102242:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
80102245:	b8 08 00 00 00       	mov    $0x8,%eax
8010224a:	e8 a9 ff ff ff       	call   801021f8 <cmos_read>
8010224f:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
80102252:	b8 09 00 00 00       	mov    $0x9,%eax
80102257:	e8 9c ff ff ff       	call   801021f8 <cmos_read>
8010225c:	89 43 14             	mov    %eax,0x14(%ebx)
}
8010225f:	5b                   	pop    %ebx
80102260:	5d                   	pop    %ebp
80102261:	c3                   	ret    

80102262 <lapicinit>:
  if(!lapic)
80102262:	83 3d 7c 16 11 80 00 	cmpl   $0x0,0x8011167c
80102269:	0f 84 fb 00 00 00    	je     8010236a <lapicinit+0x108>
{
8010226f:	55                   	push   %ebp
80102270:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102272:	ba 3f 01 00 00       	mov    $0x13f,%edx
80102277:	b8 3c 00 00 00       	mov    $0x3c,%eax
8010227c:	e8 5f ff ff ff       	call   801021e0 <lapicw>
  lapicw(TDCR, X1);
80102281:	ba 0b 00 00 00       	mov    $0xb,%edx
80102286:	b8 f8 00 00 00       	mov    $0xf8,%eax
8010228b:	e8 50 ff ff ff       	call   801021e0 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102290:	ba 20 00 02 00       	mov    $0x20020,%edx
80102295:	b8 c8 00 00 00       	mov    $0xc8,%eax
8010229a:	e8 41 ff ff ff       	call   801021e0 <lapicw>
  lapicw(TICR, 10000000);
8010229f:	ba 80 96 98 00       	mov    $0x989680,%edx
801022a4:	b8 e0 00 00 00       	mov    $0xe0,%eax
801022a9:	e8 32 ff ff ff       	call   801021e0 <lapicw>
  lapicw(LINT0, MASKED);
801022ae:	ba 00 00 01 00       	mov    $0x10000,%edx
801022b3:	b8 d4 00 00 00       	mov    $0xd4,%eax
801022b8:	e8 23 ff ff ff       	call   801021e0 <lapicw>
  lapicw(LINT1, MASKED);
801022bd:	ba 00 00 01 00       	mov    $0x10000,%edx
801022c2:	b8 d8 00 00 00       	mov    $0xd8,%eax
801022c7:	e8 14 ff ff ff       	call   801021e0 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801022cc:	a1 7c 16 11 80       	mov    0x8011167c,%eax
801022d1:	8b 40 30             	mov    0x30(%eax),%eax
801022d4:	c1 e8 10             	shr    $0x10,%eax
801022d7:	3c 03                	cmp    $0x3,%al
801022d9:	77 7b                	ja     80102356 <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801022db:	ba 33 00 00 00       	mov    $0x33,%edx
801022e0:	b8 dc 00 00 00       	mov    $0xdc,%eax
801022e5:	e8 f6 fe ff ff       	call   801021e0 <lapicw>
  lapicw(ESR, 0);
801022ea:	ba 00 00 00 00       	mov    $0x0,%edx
801022ef:	b8 a0 00 00 00       	mov    $0xa0,%eax
801022f4:	e8 e7 fe ff ff       	call   801021e0 <lapicw>
  lapicw(ESR, 0);
801022f9:	ba 00 00 00 00       	mov    $0x0,%edx
801022fe:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102303:	e8 d8 fe ff ff       	call   801021e0 <lapicw>
  lapicw(EOI, 0);
80102308:	ba 00 00 00 00       	mov    $0x0,%edx
8010230d:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102312:	e8 c9 fe ff ff       	call   801021e0 <lapicw>
  lapicw(ICRHI, 0);
80102317:	ba 00 00 00 00       	mov    $0x0,%edx
8010231c:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102321:	e8 ba fe ff ff       	call   801021e0 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102326:	ba 00 85 08 00       	mov    $0x88500,%edx
8010232b:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102330:	e8 ab fe ff ff       	call   801021e0 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102335:	a1 7c 16 11 80       	mov    0x8011167c,%eax
8010233a:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
80102340:	f6 c4 10             	test   $0x10,%ah
80102343:	75 f0                	jne    80102335 <lapicinit+0xd3>
  lapicw(TPR, 0);
80102345:	ba 00 00 00 00       	mov    $0x0,%edx
8010234a:	b8 20 00 00 00       	mov    $0x20,%eax
8010234f:	e8 8c fe ff ff       	call   801021e0 <lapicw>
}
80102354:	5d                   	pop    %ebp
80102355:	c3                   	ret    
    lapicw(PCINT, MASKED);
80102356:	ba 00 00 01 00       	mov    $0x10000,%edx
8010235b:	b8 d0 00 00 00       	mov    $0xd0,%eax
80102360:	e8 7b fe ff ff       	call   801021e0 <lapicw>
80102365:	e9 71 ff ff ff       	jmp    801022db <lapicinit+0x79>
8010236a:	f3 c3                	repz ret 

8010236c <lapicid>:
{
8010236c:	55                   	push   %ebp
8010236d:	89 e5                	mov    %esp,%ebp
  if (!lapic)
8010236f:	a1 7c 16 11 80       	mov    0x8011167c,%eax
80102374:	85 c0                	test   %eax,%eax
80102376:	74 08                	je     80102380 <lapicid+0x14>
  return lapic[ID] >> 24;
80102378:	8b 40 20             	mov    0x20(%eax),%eax
8010237b:	c1 e8 18             	shr    $0x18,%eax
}
8010237e:	5d                   	pop    %ebp
8010237f:	c3                   	ret    
    return 0;
80102380:	b8 00 00 00 00       	mov    $0x0,%eax
80102385:	eb f7                	jmp    8010237e <lapicid+0x12>

80102387 <lapiceoi>:
  if(lapic)
80102387:	83 3d 7c 16 11 80 00 	cmpl   $0x0,0x8011167c
8010238e:	74 14                	je     801023a4 <lapiceoi+0x1d>
{
80102390:	55                   	push   %ebp
80102391:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
80102393:	ba 00 00 00 00       	mov    $0x0,%edx
80102398:	b8 2c 00 00 00       	mov    $0x2c,%eax
8010239d:	e8 3e fe ff ff       	call   801021e0 <lapicw>
}
801023a2:	5d                   	pop    %ebp
801023a3:	c3                   	ret    
801023a4:	f3 c3                	repz ret 

801023a6 <microdelay>:
{
801023a6:	55                   	push   %ebp
801023a7:	89 e5                	mov    %esp,%ebp
}
801023a9:	5d                   	pop    %ebp
801023aa:	c3                   	ret    

801023ab <lapicstartap>:
{
801023ab:	55                   	push   %ebp
801023ac:	89 e5                	mov    %esp,%ebp
801023ae:	57                   	push   %edi
801023af:	56                   	push   %esi
801023b0:	53                   	push   %ebx
801023b1:	8b 75 08             	mov    0x8(%ebp),%esi
801023b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801023b7:	b8 0f 00 00 00       	mov    $0xf,%eax
801023bc:	ba 70 00 00 00       	mov    $0x70,%edx
801023c1:	ee                   	out    %al,(%dx)
801023c2:	b8 0a 00 00 00       	mov    $0xa,%eax
801023c7:	ba 71 00 00 00       	mov    $0x71,%edx
801023cc:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
801023cd:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
801023d4:	00 00 
  wrv[1] = addr >> 4;
801023d6:	89 f8                	mov    %edi,%eax
801023d8:	c1 e8 04             	shr    $0x4,%eax
801023db:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
801023e1:	c1 e6 18             	shl    $0x18,%esi
801023e4:	89 f2                	mov    %esi,%edx
801023e6:	b8 c4 00 00 00       	mov    $0xc4,%eax
801023eb:	e8 f0 fd ff ff       	call   801021e0 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801023f0:	ba 00 c5 00 00       	mov    $0xc500,%edx
801023f5:	b8 c0 00 00 00       	mov    $0xc0,%eax
801023fa:	e8 e1 fd ff ff       	call   801021e0 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
801023ff:	ba 00 85 00 00       	mov    $0x8500,%edx
80102404:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102409:	e8 d2 fd ff ff       	call   801021e0 <lapicw>
  for(i = 0; i < 2; i++){
8010240e:	bb 00 00 00 00       	mov    $0x0,%ebx
80102413:	eb 21                	jmp    80102436 <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
80102415:	89 f2                	mov    %esi,%edx
80102417:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010241c:	e8 bf fd ff ff       	call   801021e0 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102421:	89 fa                	mov    %edi,%edx
80102423:	c1 ea 0c             	shr    $0xc,%edx
80102426:	80 ce 06             	or     $0x6,%dh
80102429:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010242e:	e8 ad fd ff ff       	call   801021e0 <lapicw>
  for(i = 0; i < 2; i++){
80102433:	83 c3 01             	add    $0x1,%ebx
80102436:	83 fb 01             	cmp    $0x1,%ebx
80102439:	7e da                	jle    80102415 <lapicstartap+0x6a>
}
8010243b:	5b                   	pop    %ebx
8010243c:	5e                   	pop    %esi
8010243d:	5f                   	pop    %edi
8010243e:	5d                   	pop    %ebp
8010243f:	c3                   	ret    

80102440 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102440:	55                   	push   %ebp
80102441:	89 e5                	mov    %esp,%ebp
80102443:	57                   	push   %edi
80102444:	56                   	push   %esi
80102445:	53                   	push   %ebx
80102446:	83 ec 3c             	sub    $0x3c,%esp
80102449:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010244c:	b8 0b 00 00 00       	mov    $0xb,%eax
80102451:	e8 a2 fd ff ff       	call   801021f8 <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
80102456:	83 e0 04             	and    $0x4,%eax
80102459:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010245b:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010245e:	e8 a9 fd ff ff       	call   8010220c <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102463:	b8 0a 00 00 00       	mov    $0xa,%eax
80102468:	e8 8b fd ff ff       	call   801021f8 <cmos_read>
8010246d:	a8 80                	test   $0x80,%al
8010246f:	75 ea                	jne    8010245b <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
80102471:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102474:	89 d8                	mov    %ebx,%eax
80102476:	e8 91 fd ff ff       	call   8010220c <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010247b:	83 ec 04             	sub    $0x4,%esp
8010247e:	6a 18                	push   $0x18
80102480:	53                   	push   %ebx
80102481:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102484:	50                   	push   %eax
80102485:	e8 eb 17 00 00       	call   80103c75 <memcmp>
8010248a:	83 c4 10             	add    $0x10,%esp
8010248d:	85 c0                	test   %eax,%eax
8010248f:	75 ca                	jne    8010245b <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
80102491:	85 ff                	test   %edi,%edi
80102493:	0f 85 84 00 00 00    	jne    8010251d <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102499:	8b 55 d0             	mov    -0x30(%ebp),%edx
8010249c:	89 d0                	mov    %edx,%eax
8010249e:	c1 e8 04             	shr    $0x4,%eax
801024a1:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024a4:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024a7:	83 e2 0f             	and    $0xf,%edx
801024aa:	01 d0                	add    %edx,%eax
801024ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
801024af:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801024b2:	89 d0                	mov    %edx,%eax
801024b4:	c1 e8 04             	shr    $0x4,%eax
801024b7:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024ba:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024bd:	83 e2 0f             	and    $0xf,%edx
801024c0:	01 d0                	add    %edx,%eax
801024c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
801024c5:	8b 55 d8             	mov    -0x28(%ebp),%edx
801024c8:	89 d0                	mov    %edx,%eax
801024ca:	c1 e8 04             	shr    $0x4,%eax
801024cd:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024d0:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024d3:	83 e2 0f             	and    $0xf,%edx
801024d6:	01 d0                	add    %edx,%eax
801024d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
801024db:	8b 55 dc             	mov    -0x24(%ebp),%edx
801024de:	89 d0                	mov    %edx,%eax
801024e0:	c1 e8 04             	shr    $0x4,%eax
801024e3:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024e6:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024e9:	83 e2 0f             	and    $0xf,%edx
801024ec:	01 d0                	add    %edx,%eax
801024ee:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
801024f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801024f4:	89 d0                	mov    %edx,%eax
801024f6:	c1 e8 04             	shr    $0x4,%eax
801024f9:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024fc:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024ff:	83 e2 0f             	and    $0xf,%edx
80102502:	01 d0                	add    %edx,%eax
80102504:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
80102507:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010250a:	89 d0                	mov    %edx,%eax
8010250c:	c1 e8 04             	shr    $0x4,%eax
8010250f:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102512:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102515:	83 e2 0f             	and    $0xf,%edx
80102518:	01 d0                	add    %edx,%eax
8010251a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
8010251d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102520:	89 06                	mov    %eax,(%esi)
80102522:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102525:	89 46 04             	mov    %eax,0x4(%esi)
80102528:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010252b:	89 46 08             	mov    %eax,0x8(%esi)
8010252e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102531:	89 46 0c             	mov    %eax,0xc(%esi)
80102534:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102537:	89 46 10             	mov    %eax,0x10(%esi)
8010253a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010253d:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102540:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102547:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010254a:	5b                   	pop    %ebx
8010254b:	5e                   	pop    %esi
8010254c:	5f                   	pop    %edi
8010254d:	5d                   	pop    %ebp
8010254e:	c3                   	ret    

8010254f <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010254f:	55                   	push   %ebp
80102550:	89 e5                	mov    %esp,%ebp
80102552:	53                   	push   %ebx
80102553:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102556:	ff 35 b4 16 11 80    	pushl  0x801116b4
8010255c:	ff 35 c4 16 11 80    	pushl  0x801116c4
80102562:	e8 05 dc ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102567:	8b 58 5c             	mov    0x5c(%eax),%ebx
8010256a:	89 1d c8 16 11 80    	mov    %ebx,0x801116c8
  for (i = 0; i < log.lh.n; i++) {
80102570:	83 c4 10             	add    $0x10,%esp
80102573:	ba 00 00 00 00       	mov    $0x0,%edx
80102578:	eb 0e                	jmp    80102588 <read_head+0x39>
    log.lh.block[i] = lh->block[i];
8010257a:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
8010257e:	89 0c 95 cc 16 11 80 	mov    %ecx,-0x7feee934(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102585:	83 c2 01             	add    $0x1,%edx
80102588:	39 d3                	cmp    %edx,%ebx
8010258a:	7f ee                	jg     8010257a <read_head+0x2b>
  }
  brelse(buf);
8010258c:	83 ec 0c             	sub    $0xc,%esp
8010258f:	50                   	push   %eax
80102590:	e8 40 dc ff ff       	call   801001d5 <brelse>
}
80102595:	83 c4 10             	add    $0x10,%esp
80102598:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010259b:	c9                   	leave  
8010259c:	c3                   	ret    

8010259d <install_trans>:
{
8010259d:	55                   	push   %ebp
8010259e:	89 e5                	mov    %esp,%ebp
801025a0:	57                   	push   %edi
801025a1:	56                   	push   %esi
801025a2:	53                   	push   %ebx
801025a3:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801025a6:	bb 00 00 00 00       	mov    $0x0,%ebx
801025ab:	eb 66                	jmp    80102613 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801025ad:	89 d8                	mov    %ebx,%eax
801025af:	03 05 b4 16 11 80    	add    0x801116b4,%eax
801025b5:	83 c0 01             	add    $0x1,%eax
801025b8:	83 ec 08             	sub    $0x8,%esp
801025bb:	50                   	push   %eax
801025bc:	ff 35 c4 16 11 80    	pushl  0x801116c4
801025c2:	e8 a5 db ff ff       	call   8010016c <bread>
801025c7:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801025c9:	83 c4 08             	add    $0x8,%esp
801025cc:	ff 34 9d cc 16 11 80 	pushl  -0x7feee934(,%ebx,4)
801025d3:	ff 35 c4 16 11 80    	pushl  0x801116c4
801025d9:	e8 8e db ff ff       	call   8010016c <bread>
801025de:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801025e0:	8d 57 5c             	lea    0x5c(%edi),%edx
801025e3:	8d 40 5c             	lea    0x5c(%eax),%eax
801025e6:	83 c4 0c             	add    $0xc,%esp
801025e9:	68 00 02 00 00       	push   $0x200
801025ee:	52                   	push   %edx
801025ef:	50                   	push   %eax
801025f0:	e8 b5 16 00 00       	call   80103caa <memmove>
    bwrite(dbuf);  // write dst to disk
801025f5:	89 34 24             	mov    %esi,(%esp)
801025f8:	e8 9d db ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
801025fd:	89 3c 24             	mov    %edi,(%esp)
80102600:	e8 d0 db ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
80102605:	89 34 24             	mov    %esi,(%esp)
80102608:	e8 c8 db ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010260d:	83 c3 01             	add    $0x1,%ebx
80102610:	83 c4 10             	add    $0x10,%esp
80102613:	39 1d c8 16 11 80    	cmp    %ebx,0x801116c8
80102619:	7f 92                	jg     801025ad <install_trans+0x10>
}
8010261b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010261e:	5b                   	pop    %ebx
8010261f:	5e                   	pop    %esi
80102620:	5f                   	pop    %edi
80102621:	5d                   	pop    %ebp
80102622:	c3                   	ret    

80102623 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102623:	55                   	push   %ebp
80102624:	89 e5                	mov    %esp,%ebp
80102626:	53                   	push   %ebx
80102627:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010262a:	ff 35 b4 16 11 80    	pushl  0x801116b4
80102630:	ff 35 c4 16 11 80    	pushl  0x801116c4
80102636:	e8 31 db ff ff       	call   8010016c <bread>
8010263b:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
8010263d:	8b 0d c8 16 11 80    	mov    0x801116c8,%ecx
80102643:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102646:	83 c4 10             	add    $0x10,%esp
80102649:	b8 00 00 00 00       	mov    $0x0,%eax
8010264e:	eb 0e                	jmp    8010265e <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
80102650:	8b 14 85 cc 16 11 80 	mov    -0x7feee934(,%eax,4),%edx
80102657:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
8010265b:	83 c0 01             	add    $0x1,%eax
8010265e:	39 c1                	cmp    %eax,%ecx
80102660:	7f ee                	jg     80102650 <write_head+0x2d>
  }
  bwrite(buf);
80102662:	83 ec 0c             	sub    $0xc,%esp
80102665:	53                   	push   %ebx
80102666:	e8 2f db ff ff       	call   8010019a <bwrite>
  brelse(buf);
8010266b:	89 1c 24             	mov    %ebx,(%esp)
8010266e:	e8 62 db ff ff       	call   801001d5 <brelse>
}
80102673:	83 c4 10             	add    $0x10,%esp
80102676:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102679:	c9                   	leave  
8010267a:	c3                   	ret    

8010267b <recover_from_log>:

static void
recover_from_log(void)
{
8010267b:	55                   	push   %ebp
8010267c:	89 e5                	mov    %esp,%ebp
8010267e:	83 ec 08             	sub    $0x8,%esp
  read_head();
80102681:	e8 c9 fe ff ff       	call   8010254f <read_head>
  install_trans(); // if committed, copy from log to disk
80102686:	e8 12 ff ff ff       	call   8010259d <install_trans>
  log.lh.n = 0;
8010268b:	c7 05 c8 16 11 80 00 	movl   $0x0,0x801116c8
80102692:	00 00 00 
  write_head(); // clear the log
80102695:	e8 89 ff ff ff       	call   80102623 <write_head>
}
8010269a:	c9                   	leave  
8010269b:	c3                   	ret    

8010269c <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010269c:	55                   	push   %ebp
8010269d:	89 e5                	mov    %esp,%ebp
8010269f:	57                   	push   %edi
801026a0:	56                   	push   %esi
801026a1:	53                   	push   %ebx
801026a2:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801026a5:	bb 00 00 00 00       	mov    $0x0,%ebx
801026aa:	eb 66                	jmp    80102712 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801026ac:	89 d8                	mov    %ebx,%eax
801026ae:	03 05 b4 16 11 80    	add    0x801116b4,%eax
801026b4:	83 c0 01             	add    $0x1,%eax
801026b7:	83 ec 08             	sub    $0x8,%esp
801026ba:	50                   	push   %eax
801026bb:	ff 35 c4 16 11 80    	pushl  0x801116c4
801026c1:	e8 a6 da ff ff       	call   8010016c <bread>
801026c6:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801026c8:	83 c4 08             	add    $0x8,%esp
801026cb:	ff 34 9d cc 16 11 80 	pushl  -0x7feee934(,%ebx,4)
801026d2:	ff 35 c4 16 11 80    	pushl  0x801116c4
801026d8:	e8 8f da ff ff       	call   8010016c <bread>
801026dd:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
801026df:	8d 50 5c             	lea    0x5c(%eax),%edx
801026e2:	8d 46 5c             	lea    0x5c(%esi),%eax
801026e5:	83 c4 0c             	add    $0xc,%esp
801026e8:	68 00 02 00 00       	push   $0x200
801026ed:	52                   	push   %edx
801026ee:	50                   	push   %eax
801026ef:	e8 b6 15 00 00       	call   80103caa <memmove>
    bwrite(to);  // write the log
801026f4:	89 34 24             	mov    %esi,(%esp)
801026f7:	e8 9e da ff ff       	call   8010019a <bwrite>
    brelse(from);
801026fc:	89 3c 24             	mov    %edi,(%esp)
801026ff:	e8 d1 da ff ff       	call   801001d5 <brelse>
    brelse(to);
80102704:	89 34 24             	mov    %esi,(%esp)
80102707:	e8 c9 da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010270c:	83 c3 01             	add    $0x1,%ebx
8010270f:	83 c4 10             	add    $0x10,%esp
80102712:	39 1d c8 16 11 80    	cmp    %ebx,0x801116c8
80102718:	7f 92                	jg     801026ac <write_log+0x10>
  }
}
8010271a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010271d:	5b                   	pop    %ebx
8010271e:	5e                   	pop    %esi
8010271f:	5f                   	pop    %edi
80102720:	5d                   	pop    %ebp
80102721:	c3                   	ret    

80102722 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
80102722:	83 3d c8 16 11 80 00 	cmpl   $0x0,0x801116c8
80102729:	7e 26                	jle    80102751 <commit+0x2f>
{
8010272b:	55                   	push   %ebp
8010272c:	89 e5                	mov    %esp,%ebp
8010272e:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
80102731:	e8 66 ff ff ff       	call   8010269c <write_log>
    write_head();    // Write header to disk -- the real commit
80102736:	e8 e8 fe ff ff       	call   80102623 <write_head>
    install_trans(); // Now install writes to home locations
8010273b:	e8 5d fe ff ff       	call   8010259d <install_trans>
    log.lh.n = 0;
80102740:	c7 05 c8 16 11 80 00 	movl   $0x0,0x801116c8
80102747:	00 00 00 
    write_head();    // Erase the transaction from the log
8010274a:	e8 d4 fe ff ff       	call   80102623 <write_head>
  }
}
8010274f:	c9                   	leave  
80102750:	c3                   	ret    
80102751:	f3 c3                	repz ret 

80102753 <initlog>:
{
80102753:	55                   	push   %ebp
80102754:	89 e5                	mov    %esp,%ebp
80102756:	53                   	push   %ebx
80102757:	83 ec 2c             	sub    $0x2c,%esp
8010275a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
8010275d:	68 c0 69 10 80       	push   $0x801069c0
80102762:	68 80 16 11 80       	push   $0x80111680
80102767:	e8 db 12 00 00       	call   80103a47 <initlock>
  readsb(dev, &sb);
8010276c:	83 c4 08             	add    $0x8,%esp
8010276f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102772:	50                   	push   %eax
80102773:	53                   	push   %ebx
80102774:	e8 2d eb ff ff       	call   801012a6 <readsb>
  log.start = sb.logstart;
80102779:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010277c:	a3 b4 16 11 80       	mov    %eax,0x801116b4
  log.size = sb.nlog;
80102781:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102784:	a3 b8 16 11 80       	mov    %eax,0x801116b8
  log.dev = dev;
80102789:	89 1d c4 16 11 80    	mov    %ebx,0x801116c4
  recover_from_log();
8010278f:	e8 e7 fe ff ff       	call   8010267b <recover_from_log>
}
80102794:	83 c4 10             	add    $0x10,%esp
80102797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010279a:	c9                   	leave  
8010279b:	c3                   	ret    

8010279c <begin_op>:
{
8010279c:	55                   	push   %ebp
8010279d:	89 e5                	mov    %esp,%ebp
8010279f:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
801027a2:	68 80 16 11 80       	push   $0x80111680
801027a7:	e8 d7 13 00 00       	call   80103b83 <acquire>
801027ac:	83 c4 10             	add    $0x10,%esp
801027af:	eb 15                	jmp    801027c6 <begin_op+0x2a>
      sleep(&log, &log.lock);
801027b1:	83 ec 08             	sub    $0x8,%esp
801027b4:	68 80 16 11 80       	push   $0x80111680
801027b9:	68 80 16 11 80       	push   $0x80111680
801027be:	e8 c5 0e 00 00       	call   80103688 <sleep>
801027c3:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
801027c6:	83 3d c0 16 11 80 00 	cmpl   $0x0,0x801116c0
801027cd:	75 e2                	jne    801027b1 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801027cf:	a1 bc 16 11 80       	mov    0x801116bc,%eax
801027d4:	83 c0 01             	add    $0x1,%eax
801027d7:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801027da:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
801027dd:	03 15 c8 16 11 80    	add    0x801116c8,%edx
801027e3:	83 fa 1e             	cmp    $0x1e,%edx
801027e6:	7e 17                	jle    801027ff <begin_op+0x63>
      sleep(&log, &log.lock);
801027e8:	83 ec 08             	sub    $0x8,%esp
801027eb:	68 80 16 11 80       	push   $0x80111680
801027f0:	68 80 16 11 80       	push   $0x80111680
801027f5:	e8 8e 0e 00 00       	call   80103688 <sleep>
801027fa:	83 c4 10             	add    $0x10,%esp
801027fd:	eb c7                	jmp    801027c6 <begin_op+0x2a>
      log.outstanding += 1;
801027ff:	a3 bc 16 11 80       	mov    %eax,0x801116bc
      release(&log.lock);
80102804:	83 ec 0c             	sub    $0xc,%esp
80102807:	68 80 16 11 80       	push   $0x80111680
8010280c:	e8 d7 13 00 00       	call   80103be8 <release>
}
80102811:	83 c4 10             	add    $0x10,%esp
80102814:	c9                   	leave  
80102815:	c3                   	ret    

80102816 <end_op>:
{
80102816:	55                   	push   %ebp
80102817:	89 e5                	mov    %esp,%ebp
80102819:	53                   	push   %ebx
8010281a:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
8010281d:	68 80 16 11 80       	push   $0x80111680
80102822:	e8 5c 13 00 00       	call   80103b83 <acquire>
  log.outstanding -= 1;
80102827:	a1 bc 16 11 80       	mov    0x801116bc,%eax
8010282c:	83 e8 01             	sub    $0x1,%eax
8010282f:	a3 bc 16 11 80       	mov    %eax,0x801116bc
  if(log.committing)
80102834:	8b 1d c0 16 11 80    	mov    0x801116c0,%ebx
8010283a:	83 c4 10             	add    $0x10,%esp
8010283d:	85 db                	test   %ebx,%ebx
8010283f:	75 2c                	jne    8010286d <end_op+0x57>
  if(log.outstanding == 0){
80102841:	85 c0                	test   %eax,%eax
80102843:	75 35                	jne    8010287a <end_op+0x64>
    log.committing = 1;
80102845:	c7 05 c0 16 11 80 01 	movl   $0x1,0x801116c0
8010284c:	00 00 00 
    do_commit = 1;
8010284f:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102854:	83 ec 0c             	sub    $0xc,%esp
80102857:	68 80 16 11 80       	push   $0x80111680
8010285c:	e8 87 13 00 00       	call   80103be8 <release>
  if(do_commit){
80102861:	83 c4 10             	add    $0x10,%esp
80102864:	85 db                	test   %ebx,%ebx
80102866:	75 24                	jne    8010288c <end_op+0x76>
}
80102868:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010286b:	c9                   	leave  
8010286c:	c3                   	ret    
    panic("log.committing");
8010286d:	83 ec 0c             	sub    $0xc,%esp
80102870:	68 c4 69 10 80       	push   $0x801069c4
80102875:	e8 ce da ff ff       	call   80100348 <panic>
    wakeup(&log);
8010287a:	83 ec 0c             	sub    $0xc,%esp
8010287d:	68 80 16 11 80       	push   $0x80111680
80102882:	e8 66 0f 00 00       	call   801037ed <wakeup>
80102887:	83 c4 10             	add    $0x10,%esp
8010288a:	eb c8                	jmp    80102854 <end_op+0x3e>
    commit();
8010288c:	e8 91 fe ff ff       	call   80102722 <commit>
    acquire(&log.lock);
80102891:	83 ec 0c             	sub    $0xc,%esp
80102894:	68 80 16 11 80       	push   $0x80111680
80102899:	e8 e5 12 00 00       	call   80103b83 <acquire>
    log.committing = 0;
8010289e:	c7 05 c0 16 11 80 00 	movl   $0x0,0x801116c0
801028a5:	00 00 00 
    wakeup(&log);
801028a8:	c7 04 24 80 16 11 80 	movl   $0x80111680,(%esp)
801028af:	e8 39 0f 00 00       	call   801037ed <wakeup>
    release(&log.lock);
801028b4:	c7 04 24 80 16 11 80 	movl   $0x80111680,(%esp)
801028bb:	e8 28 13 00 00       	call   80103be8 <release>
801028c0:	83 c4 10             	add    $0x10,%esp
}
801028c3:	eb a3                	jmp    80102868 <end_op+0x52>

801028c5 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801028c5:	55                   	push   %ebp
801028c6:	89 e5                	mov    %esp,%ebp
801028c8:	53                   	push   %ebx
801028c9:	83 ec 04             	sub    $0x4,%esp
801028cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801028cf:	8b 15 c8 16 11 80    	mov    0x801116c8,%edx
801028d5:	83 fa 1d             	cmp    $0x1d,%edx
801028d8:	7f 45                	jg     8010291f <log_write+0x5a>
801028da:	a1 b8 16 11 80       	mov    0x801116b8,%eax
801028df:	83 e8 01             	sub    $0x1,%eax
801028e2:	39 c2                	cmp    %eax,%edx
801028e4:	7d 39                	jge    8010291f <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
801028e6:	83 3d bc 16 11 80 00 	cmpl   $0x0,0x801116bc
801028ed:	7e 3d                	jle    8010292c <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
801028ef:	83 ec 0c             	sub    $0xc,%esp
801028f2:	68 80 16 11 80       	push   $0x80111680
801028f7:	e8 87 12 00 00       	call   80103b83 <acquire>
  for (i = 0; i < log.lh.n; i++) {
801028fc:	83 c4 10             	add    $0x10,%esp
801028ff:	b8 00 00 00 00       	mov    $0x0,%eax
80102904:	8b 15 c8 16 11 80    	mov    0x801116c8,%edx
8010290a:	39 c2                	cmp    %eax,%edx
8010290c:	7e 2b                	jle    80102939 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010290e:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102911:	39 0c 85 cc 16 11 80 	cmp    %ecx,-0x7feee934(,%eax,4)
80102918:	74 1f                	je     80102939 <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
8010291a:	83 c0 01             	add    $0x1,%eax
8010291d:	eb e5                	jmp    80102904 <log_write+0x3f>
    panic("too big a transaction");
8010291f:	83 ec 0c             	sub    $0xc,%esp
80102922:	68 d3 69 10 80       	push   $0x801069d3
80102927:	e8 1c da ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
8010292c:	83 ec 0c             	sub    $0xc,%esp
8010292f:	68 e9 69 10 80       	push   $0x801069e9
80102934:	e8 0f da ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102939:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010293c:	89 0c 85 cc 16 11 80 	mov    %ecx,-0x7feee934(,%eax,4)
  if (i == log.lh.n)
80102943:	39 c2                	cmp    %eax,%edx
80102945:	74 18                	je     8010295f <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102947:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
8010294a:	83 ec 0c             	sub    $0xc,%esp
8010294d:	68 80 16 11 80       	push   $0x80111680
80102952:	e8 91 12 00 00       	call   80103be8 <release>
}
80102957:	83 c4 10             	add    $0x10,%esp
8010295a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010295d:	c9                   	leave  
8010295e:	c3                   	ret    
    log.lh.n++;
8010295f:	83 c2 01             	add    $0x1,%edx
80102962:	89 15 c8 16 11 80    	mov    %edx,0x801116c8
80102968:	eb dd                	jmp    80102947 <log_write+0x82>

8010296a <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010296a:	55                   	push   %ebp
8010296b:	89 e5                	mov    %esp,%ebp
8010296d:	53                   	push   %ebx
8010296e:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102971:	68 8a 00 00 00       	push   $0x8a
80102976:	68 8c 94 10 80       	push   $0x8010948c
8010297b:	68 00 70 00 80       	push   $0x80007000
80102980:	e8 25 13 00 00       	call   80103caa <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102985:	83 c4 10             	add    $0x10,%esp
80102988:	bb 80 17 11 80       	mov    $0x80111780,%ebx
8010298d:	eb 06                	jmp    80102995 <startothers+0x2b>
8010298f:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102995:	69 05 00 1d 11 80 b0 	imul   $0xb0,0x80111d00,%eax
8010299c:	00 00 00 
8010299f:	05 80 17 11 80       	add    $0x80111780,%eax
801029a4:	39 d8                	cmp    %ebx,%eax
801029a6:	76 4c                	jbe    801029f4 <startothers+0x8a>
    if(c == mycpu())  // We've started already.
801029a8:	e8 c0 07 00 00       	call   8010316d <mycpu>
801029ad:	39 d8                	cmp    %ebx,%eax
801029af:	74 de                	je     8010298f <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801029b1:	e8 f3 f6 ff ff       	call   801020a9 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
801029b6:	05 00 10 00 00       	add    $0x1000,%eax
801029bb:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
801029c0:	c7 05 f8 6f 00 80 38 	movl   $0x80102a38,0x80006ff8
801029c7:	2a 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801029ca:	c7 05 f4 6f 00 80 00 	movl   $0x108000,0x80006ff4
801029d1:	80 10 00 

    lapicstartap(c->apicid, V2P(code));
801029d4:	83 ec 08             	sub    $0x8,%esp
801029d7:	68 00 70 00 00       	push   $0x7000
801029dc:	0f b6 03             	movzbl (%ebx),%eax
801029df:	50                   	push   %eax
801029e0:	e8 c6 f9 ff ff       	call   801023ab <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801029e5:	83 c4 10             	add    $0x10,%esp
801029e8:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
801029ee:	85 c0                	test   %eax,%eax
801029f0:	74 f6                	je     801029e8 <startothers+0x7e>
801029f2:	eb 9b                	jmp    8010298f <startothers+0x25>
      ;
  }
}
801029f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801029f7:	c9                   	leave  
801029f8:	c3                   	ret    

801029f9 <mpmain>:
{
801029f9:	55                   	push   %ebp
801029fa:	89 e5                	mov    %esp,%ebp
801029fc:	53                   	push   %ebx
801029fd:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102a00:	e8 c4 07 00 00       	call   801031c9 <cpuid>
80102a05:	89 c3                	mov    %eax,%ebx
80102a07:	e8 bd 07 00 00       	call   801031c9 <cpuid>
80102a0c:	83 ec 04             	sub    $0x4,%esp
80102a0f:	53                   	push   %ebx
80102a10:	50                   	push   %eax
80102a11:	68 04 6a 10 80       	push   $0x80106a04
80102a16:	e8 f0 db ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102a1b:	e8 5e 24 00 00       	call   80104e7e <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102a20:	e8 48 07 00 00       	call   8010316d <mycpu>
80102a25:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102a27:	b8 01 00 00 00       	mov    $0x1,%eax
80102a2c:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102a33:	e8 2b 0a 00 00       	call   80103463 <scheduler>

80102a38 <mpenter>:
{
80102a38:	55                   	push   %ebp
80102a39:	89 e5                	mov    %esp,%ebp
80102a3b:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102a3e:	e8 44 34 00 00       	call   80105e87 <switchkvm>
  seginit();
80102a43:	e8 f3 32 00 00       	call   80105d3b <seginit>
  lapicinit();
80102a48:	e8 15 f8 ff ff       	call   80102262 <lapicinit>
  mpmain();
80102a4d:	e8 a7 ff ff ff       	call   801029f9 <mpmain>

80102a52 <main>:
{
80102a52:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102a56:	83 e4 f0             	and    $0xfffffff0,%esp
80102a59:	ff 71 fc             	pushl  -0x4(%ecx)
80102a5c:	55                   	push   %ebp
80102a5d:	89 e5                	mov    %esp,%ebp
80102a5f:	51                   	push   %ecx
80102a60:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102a63:	68 00 00 40 80       	push   $0x80400000
80102a68:	68 a8 44 11 80       	push   $0x801144a8
80102a6d:	e8 e5 f5 ff ff       	call   80102057 <kinit1>
  kvmalloc();      // kernel page table
80102a72:	e8 9d 38 00 00       	call   80106314 <kvmalloc>
  mpinit();        // detect other processors
80102a77:	e8 c9 01 00 00       	call   80102c45 <mpinit>
  lapicinit();     // interrupt controller
80102a7c:	e8 e1 f7 ff ff       	call   80102262 <lapicinit>
  seginit();       // segment descriptors
80102a81:	e8 b5 32 00 00       	call   80105d3b <seginit>
  picinit();       // disable pic
80102a86:	e8 82 02 00 00       	call   80102d0d <picinit>
  ioapicinit();    // another interrupt controller
80102a8b:	e8 58 f4 ff ff       	call   80101ee8 <ioapicinit>
  consoleinit();   // console hardware
80102a90:	e8 f9 dd ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102a95:	e8 92 26 00 00       	call   8010512c <uartinit>
  pinit();         // process table
80102a9a:	e8 b4 06 00 00       	call   80103153 <pinit>
  tvinit();        // trap vectors
80102a9f:	e8 29 23 00 00       	call   80104dcd <tvinit>
  binit();         // buffer cache
80102aa4:	e8 4b d6 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102aa9:	e8 65 e1 ff ff       	call   80100c13 <fileinit>
  ideinit();       // disk 
80102aae:	e8 3b f2 ff ff       	call   80101cee <ideinit>
  startothers();   // start other processors
80102ab3:	e8 b2 fe ff ff       	call   8010296a <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102ab8:	83 c4 08             	add    $0x8,%esp
80102abb:	68 00 00 00 8e       	push   $0x8e000000
80102ac0:	68 00 00 40 80       	push   $0x80400000
80102ac5:	e8 bf f5 ff ff       	call   80102089 <kinit2>
  userinit();      // first user process
80102aca:	e8 39 07 00 00       	call   80103208 <userinit>
  mpmain();        // finish this processor's setup
80102acf:	e8 25 ff ff ff       	call   801029f9 <mpmain>

80102ad4 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102ad4:	55                   	push   %ebp
80102ad5:	89 e5                	mov    %esp,%ebp
80102ad7:	56                   	push   %esi
80102ad8:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102ad9:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102ade:	b9 00 00 00 00       	mov    $0x0,%ecx
80102ae3:	eb 09                	jmp    80102aee <sum+0x1a>
    sum += addr[i];
80102ae5:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102ae9:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102aeb:	83 c1 01             	add    $0x1,%ecx
80102aee:	39 d1                	cmp    %edx,%ecx
80102af0:	7c f3                	jl     80102ae5 <sum+0x11>
  return sum;
}
80102af2:	89 d8                	mov    %ebx,%eax
80102af4:	5b                   	pop    %ebx
80102af5:	5e                   	pop    %esi
80102af6:	5d                   	pop    %ebp
80102af7:	c3                   	ret    

80102af8 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102af8:	55                   	push   %ebp
80102af9:	89 e5                	mov    %esp,%ebp
80102afb:	56                   	push   %esi
80102afc:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102afd:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102b03:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102b05:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102b07:	eb 03                	jmp    80102b0c <mpsearch1+0x14>
80102b09:	83 c3 10             	add    $0x10,%ebx
80102b0c:	39 f3                	cmp    %esi,%ebx
80102b0e:	73 29                	jae    80102b39 <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102b10:	83 ec 04             	sub    $0x4,%esp
80102b13:	6a 04                	push   $0x4
80102b15:	68 18 6a 10 80       	push   $0x80106a18
80102b1a:	53                   	push   %ebx
80102b1b:	e8 55 11 00 00       	call   80103c75 <memcmp>
80102b20:	83 c4 10             	add    $0x10,%esp
80102b23:	85 c0                	test   %eax,%eax
80102b25:	75 e2                	jne    80102b09 <mpsearch1+0x11>
80102b27:	ba 10 00 00 00       	mov    $0x10,%edx
80102b2c:	89 d8                	mov    %ebx,%eax
80102b2e:	e8 a1 ff ff ff       	call   80102ad4 <sum>
80102b33:	84 c0                	test   %al,%al
80102b35:	75 d2                	jne    80102b09 <mpsearch1+0x11>
80102b37:	eb 05                	jmp    80102b3e <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102b39:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102b3e:	89 d8                	mov    %ebx,%eax
80102b40:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102b43:	5b                   	pop    %ebx
80102b44:	5e                   	pop    %esi
80102b45:	5d                   	pop    %ebp
80102b46:	c3                   	ret    

80102b47 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102b47:	55                   	push   %ebp
80102b48:	89 e5                	mov    %esp,%ebp
80102b4a:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102b4d:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102b54:	c1 e0 08             	shl    $0x8,%eax
80102b57:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102b5e:	09 d0                	or     %edx,%eax
80102b60:	c1 e0 04             	shl    $0x4,%eax
80102b63:	85 c0                	test   %eax,%eax
80102b65:	74 1f                	je     80102b86 <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102b67:	ba 00 04 00 00       	mov    $0x400,%edx
80102b6c:	e8 87 ff ff ff       	call   80102af8 <mpsearch1>
80102b71:	85 c0                	test   %eax,%eax
80102b73:	75 0f                	jne    80102b84 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102b75:	ba 00 00 01 00       	mov    $0x10000,%edx
80102b7a:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102b7f:	e8 74 ff ff ff       	call   80102af8 <mpsearch1>
}
80102b84:	c9                   	leave  
80102b85:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102b86:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102b8d:	c1 e0 08             	shl    $0x8,%eax
80102b90:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102b97:	09 d0                	or     %edx,%eax
80102b99:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102b9c:	2d 00 04 00 00       	sub    $0x400,%eax
80102ba1:	ba 00 04 00 00       	mov    $0x400,%edx
80102ba6:	e8 4d ff ff ff       	call   80102af8 <mpsearch1>
80102bab:	85 c0                	test   %eax,%eax
80102bad:	75 d5                	jne    80102b84 <mpsearch+0x3d>
80102baf:	eb c4                	jmp    80102b75 <mpsearch+0x2e>

80102bb1 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102bb1:	55                   	push   %ebp
80102bb2:	89 e5                	mov    %esp,%ebp
80102bb4:	57                   	push   %edi
80102bb5:	56                   	push   %esi
80102bb6:	53                   	push   %ebx
80102bb7:	83 ec 1c             	sub    $0x1c,%esp
80102bba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102bbd:	e8 85 ff ff ff       	call   80102b47 <mpsearch>
80102bc2:	85 c0                	test   %eax,%eax
80102bc4:	74 5c                	je     80102c22 <mpconfig+0x71>
80102bc6:	89 c7                	mov    %eax,%edi
80102bc8:	8b 58 04             	mov    0x4(%eax),%ebx
80102bcb:	85 db                	test   %ebx,%ebx
80102bcd:	74 5a                	je     80102c29 <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102bcf:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102bd5:	83 ec 04             	sub    $0x4,%esp
80102bd8:	6a 04                	push   $0x4
80102bda:	68 1d 6a 10 80       	push   $0x80106a1d
80102bdf:	56                   	push   %esi
80102be0:	e8 90 10 00 00       	call   80103c75 <memcmp>
80102be5:	83 c4 10             	add    $0x10,%esp
80102be8:	85 c0                	test   %eax,%eax
80102bea:	75 44                	jne    80102c30 <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102bec:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102bf3:	3c 01                	cmp    $0x1,%al
80102bf5:	0f 95 c2             	setne  %dl
80102bf8:	3c 04                	cmp    $0x4,%al
80102bfa:	0f 95 c0             	setne  %al
80102bfd:	84 c2                	test   %al,%dl
80102bff:	75 36                	jne    80102c37 <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102c01:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102c08:	89 f0                	mov    %esi,%eax
80102c0a:	e8 c5 fe ff ff       	call   80102ad4 <sum>
80102c0f:	84 c0                	test   %al,%al
80102c11:	75 2b                	jne    80102c3e <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102c13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102c16:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102c18:	89 f0                	mov    %esi,%eax
80102c1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c1d:	5b                   	pop    %ebx
80102c1e:	5e                   	pop    %esi
80102c1f:	5f                   	pop    %edi
80102c20:	5d                   	pop    %ebp
80102c21:	c3                   	ret    
    return 0;
80102c22:	be 00 00 00 00       	mov    $0x0,%esi
80102c27:	eb ef                	jmp    80102c18 <mpconfig+0x67>
80102c29:	be 00 00 00 00       	mov    $0x0,%esi
80102c2e:	eb e8                	jmp    80102c18 <mpconfig+0x67>
    return 0;
80102c30:	be 00 00 00 00       	mov    $0x0,%esi
80102c35:	eb e1                	jmp    80102c18 <mpconfig+0x67>
    return 0;
80102c37:	be 00 00 00 00       	mov    $0x0,%esi
80102c3c:	eb da                	jmp    80102c18 <mpconfig+0x67>
    return 0;
80102c3e:	be 00 00 00 00       	mov    $0x0,%esi
80102c43:	eb d3                	jmp    80102c18 <mpconfig+0x67>

80102c45 <mpinit>:

void
mpinit(void)
{
80102c45:	55                   	push   %ebp
80102c46:	89 e5                	mov    %esp,%ebp
80102c48:	57                   	push   %edi
80102c49:	56                   	push   %esi
80102c4a:	53                   	push   %ebx
80102c4b:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102c4e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102c51:	e8 5b ff ff ff       	call   80102bb1 <mpconfig>
80102c56:	85 c0                	test   %eax,%eax
80102c58:	74 19                	je     80102c73 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102c5a:	8b 50 24             	mov    0x24(%eax),%edx
80102c5d:	89 15 7c 16 11 80    	mov    %edx,0x8011167c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102c63:	8d 50 2c             	lea    0x2c(%eax),%edx
80102c66:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102c6a:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102c6c:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102c71:	eb 34                	jmp    80102ca7 <mpinit+0x62>
    panic("Expect to run on an SMP");
80102c73:	83 ec 0c             	sub    $0xc,%esp
80102c76:	68 22 6a 10 80       	push   $0x80106a22
80102c7b:	e8 c8 d6 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102c80:	8b 35 00 1d 11 80    	mov    0x80111d00,%esi
80102c86:	83 fe 07             	cmp    $0x7,%esi
80102c89:	7f 19                	jg     80102ca4 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102c8b:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102c8f:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102c95:	88 87 80 17 11 80    	mov    %al,-0x7feee880(%edi)
        ncpu++;
80102c9b:	83 c6 01             	add    $0x1,%esi
80102c9e:	89 35 00 1d 11 80    	mov    %esi,0x80111d00
      }
      p += sizeof(struct mpproc);
80102ca4:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102ca7:	39 ca                	cmp    %ecx,%edx
80102ca9:	73 2b                	jae    80102cd6 <mpinit+0x91>
    switch(*p){
80102cab:	0f b6 02             	movzbl (%edx),%eax
80102cae:	3c 04                	cmp    $0x4,%al
80102cb0:	77 1d                	ja     80102ccf <mpinit+0x8a>
80102cb2:	0f b6 c0             	movzbl %al,%eax
80102cb5:	ff 24 85 5c 6a 10 80 	jmp    *-0x7fef95a4(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102cbc:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102cc0:	a2 60 17 11 80       	mov    %al,0x80111760
      p += sizeof(struct mpioapic);
80102cc5:	83 c2 08             	add    $0x8,%edx
      continue;
80102cc8:	eb dd                	jmp    80102ca7 <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102cca:	83 c2 08             	add    $0x8,%edx
      continue;
80102ccd:	eb d8                	jmp    80102ca7 <mpinit+0x62>
    default:
      ismp = 0;
80102ccf:	bb 00 00 00 00       	mov    $0x0,%ebx
80102cd4:	eb d1                	jmp    80102ca7 <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102cd6:	85 db                	test   %ebx,%ebx
80102cd8:	74 26                	je     80102d00 <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102cda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102cdd:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102ce1:	74 15                	je     80102cf8 <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ce3:	b8 70 00 00 00       	mov    $0x70,%eax
80102ce8:	ba 22 00 00 00       	mov    $0x22,%edx
80102ced:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cee:	ba 23 00 00 00       	mov    $0x23,%edx
80102cf3:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102cf4:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cf7:	ee                   	out    %al,(%dx)
  }
}
80102cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102cfb:	5b                   	pop    %ebx
80102cfc:	5e                   	pop    %esi
80102cfd:	5f                   	pop    %edi
80102cfe:	5d                   	pop    %ebp
80102cff:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102d00:	83 ec 0c             	sub    $0xc,%esp
80102d03:	68 3c 6a 10 80       	push   $0x80106a3c
80102d08:	e8 3b d6 ff ff       	call   80100348 <panic>

80102d0d <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102d0d:	55                   	push   %ebp
80102d0e:	89 e5                	mov    %esp,%ebp
80102d10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d15:	ba 21 00 00 00       	mov    $0x21,%edx
80102d1a:	ee                   	out    %al,(%dx)
80102d1b:	ba a1 00 00 00       	mov    $0xa1,%edx
80102d20:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102d21:	5d                   	pop    %ebp
80102d22:	c3                   	ret    

80102d23 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102d23:	55                   	push   %ebp
80102d24:	89 e5                	mov    %esp,%ebp
80102d26:	57                   	push   %edi
80102d27:	56                   	push   %esi
80102d28:	53                   	push   %ebx
80102d29:	83 ec 0c             	sub    $0xc,%esp
80102d2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102d2f:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102d32:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102d38:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102d3e:	e8 ea de ff ff       	call   80100c2d <filealloc>
80102d43:	89 03                	mov    %eax,(%ebx)
80102d45:	85 c0                	test   %eax,%eax
80102d47:	74 16                	je     80102d5f <pipealloc+0x3c>
80102d49:	e8 df de ff ff       	call   80100c2d <filealloc>
80102d4e:	89 06                	mov    %eax,(%esi)
80102d50:	85 c0                	test   %eax,%eax
80102d52:	74 0b                	je     80102d5f <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102d54:	e8 50 f3 ff ff       	call   801020a9 <kalloc>
80102d59:	89 c7                	mov    %eax,%edi
80102d5b:	85 c0                	test   %eax,%eax
80102d5d:	75 35                	jne    80102d94 <pipealloc+0x71>

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102d5f:	8b 03                	mov    (%ebx),%eax
80102d61:	85 c0                	test   %eax,%eax
80102d63:	74 0c                	je     80102d71 <pipealloc+0x4e>
    fileclose(*f0);
80102d65:	83 ec 0c             	sub    $0xc,%esp
80102d68:	50                   	push   %eax
80102d69:	e8 65 df ff ff       	call   80100cd3 <fileclose>
80102d6e:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102d71:	8b 06                	mov    (%esi),%eax
80102d73:	85 c0                	test   %eax,%eax
80102d75:	0f 84 8b 00 00 00    	je     80102e06 <pipealloc+0xe3>
    fileclose(*f1);
80102d7b:	83 ec 0c             	sub    $0xc,%esp
80102d7e:	50                   	push   %eax
80102d7f:	e8 4f df ff ff       	call   80100cd3 <fileclose>
80102d84:	83 c4 10             	add    $0x10,%esp
  return -1;
80102d87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102d8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d8f:	5b                   	pop    %ebx
80102d90:	5e                   	pop    %esi
80102d91:	5f                   	pop    %edi
80102d92:	5d                   	pop    %ebp
80102d93:	c3                   	ret    
  p->readopen = 1;
80102d94:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102d9b:	00 00 00 
  p->writeopen = 1;
80102d9e:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102da5:	00 00 00 
  p->nwrite = 0;
80102da8:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102daf:	00 00 00 
  p->nread = 0;
80102db2:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102db9:	00 00 00 
  initlock(&p->lock, "pipe");
80102dbc:	83 ec 08             	sub    $0x8,%esp
80102dbf:	68 70 6a 10 80       	push   $0x80106a70
80102dc4:	50                   	push   %eax
80102dc5:	e8 7d 0c 00 00       	call   80103a47 <initlock>
  (*f0)->type = FD_PIPE;
80102dca:	8b 03                	mov    (%ebx),%eax
80102dcc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102dd2:	8b 03                	mov    (%ebx),%eax
80102dd4:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102dd8:	8b 03                	mov    (%ebx),%eax
80102dda:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102dde:	8b 03                	mov    (%ebx),%eax
80102de0:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102de3:	8b 06                	mov    (%esi),%eax
80102de5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102deb:	8b 06                	mov    (%esi),%eax
80102ded:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102df1:	8b 06                	mov    (%esi),%eax
80102df3:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102df7:	8b 06                	mov    (%esi),%eax
80102df9:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102dfc:	83 c4 10             	add    $0x10,%esp
80102dff:	b8 00 00 00 00       	mov    $0x0,%eax
80102e04:	eb 86                	jmp    80102d8c <pipealloc+0x69>
  return -1;
80102e06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e0b:	e9 7c ff ff ff       	jmp    80102d8c <pipealloc+0x69>

80102e10 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102e10:	55                   	push   %ebp
80102e11:	89 e5                	mov    %esp,%ebp
80102e13:	53                   	push   %ebx
80102e14:	83 ec 10             	sub    $0x10,%esp
80102e17:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102e1a:	53                   	push   %ebx
80102e1b:	e8 63 0d 00 00       	call   80103b83 <acquire>
  if(writable){
80102e20:	83 c4 10             	add    $0x10,%esp
80102e23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102e27:	74 3f                	je     80102e68 <pipeclose+0x58>
    p->writeopen = 0;
80102e29:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102e30:	00 00 00 
    wakeup(&p->nread);
80102e33:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102e39:	83 ec 0c             	sub    $0xc,%esp
80102e3c:	50                   	push   %eax
80102e3d:	e8 ab 09 00 00       	call   801037ed <wakeup>
80102e42:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102e45:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102e4c:	75 09                	jne    80102e57 <pipeclose+0x47>
80102e4e:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102e55:	74 2f                	je     80102e86 <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102e57:	83 ec 0c             	sub    $0xc,%esp
80102e5a:	53                   	push   %ebx
80102e5b:	e8 88 0d 00 00       	call   80103be8 <release>
80102e60:	83 c4 10             	add    $0x10,%esp
}
80102e63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102e66:	c9                   	leave  
80102e67:	c3                   	ret    
    p->readopen = 0;
80102e68:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102e6f:	00 00 00 
    wakeup(&p->nwrite);
80102e72:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102e78:	83 ec 0c             	sub    $0xc,%esp
80102e7b:	50                   	push   %eax
80102e7c:	e8 6c 09 00 00       	call   801037ed <wakeup>
80102e81:	83 c4 10             	add    $0x10,%esp
80102e84:	eb bf                	jmp    80102e45 <pipeclose+0x35>
    release(&p->lock);
80102e86:	83 ec 0c             	sub    $0xc,%esp
80102e89:	53                   	push   %ebx
80102e8a:	e8 59 0d 00 00       	call   80103be8 <release>
    kfree((char*)p);
80102e8f:	89 1c 24             	mov    %ebx,(%esp)
80102e92:	e8 fb f0 ff ff       	call   80101f92 <kfree>
80102e97:	83 c4 10             	add    $0x10,%esp
80102e9a:	eb c7                	jmp    80102e63 <pipeclose+0x53>

80102e9c <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80102e9c:	55                   	push   %ebp
80102e9d:	89 e5                	mov    %esp,%ebp
80102e9f:	57                   	push   %edi
80102ea0:	56                   	push   %esi
80102ea1:	53                   	push   %ebx
80102ea2:	83 ec 18             	sub    $0x18,%esp
80102ea5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102ea8:	89 de                	mov    %ebx,%esi
80102eaa:	53                   	push   %ebx
80102eab:	e8 d3 0c 00 00       	call   80103b83 <acquire>
  for(i = 0; i < n; i++){
80102eb0:	83 c4 10             	add    $0x10,%esp
80102eb3:	bf 00 00 00 00       	mov    $0x0,%edi
80102eb8:	3b 7d 10             	cmp    0x10(%ebp),%edi
80102ebb:	0f 8d 88 00 00 00    	jge    80102f49 <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102ec1:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102ec7:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102ecd:	05 00 02 00 00       	add    $0x200,%eax
80102ed2:	39 c2                	cmp    %eax,%edx
80102ed4:	75 51                	jne    80102f27 <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
80102ed6:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102edd:	74 2f                	je     80102f0e <pipewrite+0x72>
80102edf:	e8 00 03 00 00       	call   801031e4 <myproc>
80102ee4:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102ee8:	75 24                	jne    80102f0e <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102eea:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102ef0:	83 ec 0c             	sub    $0xc,%esp
80102ef3:	50                   	push   %eax
80102ef4:	e8 f4 08 00 00       	call   801037ed <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102ef9:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102eff:	83 c4 08             	add    $0x8,%esp
80102f02:	56                   	push   %esi
80102f03:	50                   	push   %eax
80102f04:	e8 7f 07 00 00       	call   80103688 <sleep>
80102f09:	83 c4 10             	add    $0x10,%esp
80102f0c:	eb b3                	jmp    80102ec1 <pipewrite+0x25>
        release(&p->lock);
80102f0e:	83 ec 0c             	sub    $0xc,%esp
80102f11:	53                   	push   %ebx
80102f12:	e8 d1 0c 00 00       	call   80103be8 <release>
        return -1;
80102f17:	83 c4 10             	add    $0x10,%esp
80102f1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80102f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f22:	5b                   	pop    %ebx
80102f23:	5e                   	pop    %esi
80102f24:	5f                   	pop    %edi
80102f25:	5d                   	pop    %ebp
80102f26:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102f27:	8d 42 01             	lea    0x1(%edx),%eax
80102f2a:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80102f30:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102f36:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f39:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80102f3d:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80102f41:	83 c7 01             	add    $0x1,%edi
80102f44:	e9 6f ff ff ff       	jmp    80102eb8 <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102f49:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f4f:	83 ec 0c             	sub    $0xc,%esp
80102f52:	50                   	push   %eax
80102f53:	e8 95 08 00 00       	call   801037ed <wakeup>
  release(&p->lock);
80102f58:	89 1c 24             	mov    %ebx,(%esp)
80102f5b:	e8 88 0c 00 00       	call   80103be8 <release>
  return n;
80102f60:	83 c4 10             	add    $0x10,%esp
80102f63:	8b 45 10             	mov    0x10(%ebp),%eax
80102f66:	eb b7                	jmp    80102f1f <pipewrite+0x83>

80102f68 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80102f68:	55                   	push   %ebp
80102f69:	89 e5                	mov    %esp,%ebp
80102f6b:	57                   	push   %edi
80102f6c:	56                   	push   %esi
80102f6d:	53                   	push   %ebx
80102f6e:	83 ec 18             	sub    $0x18,%esp
80102f71:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102f74:	89 df                	mov    %ebx,%edi
80102f76:	53                   	push   %ebx
80102f77:	e8 07 0c 00 00       	call   80103b83 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102f7c:	83 c4 10             	add    $0x10,%esp
80102f7f:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102f85:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102f8b:	75 3d                	jne    80102fca <piperead+0x62>
80102f8d:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80102f93:	85 f6                	test   %esi,%esi
80102f95:	74 38                	je     80102fcf <piperead+0x67>
    if(myproc()->killed){
80102f97:	e8 48 02 00 00       	call   801031e4 <myproc>
80102f9c:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102fa0:	75 15                	jne    80102fb7 <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80102fa2:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fa8:	83 ec 08             	sub    $0x8,%esp
80102fab:	57                   	push   %edi
80102fac:	50                   	push   %eax
80102fad:	e8 d6 06 00 00       	call   80103688 <sleep>
80102fb2:	83 c4 10             	add    $0x10,%esp
80102fb5:	eb c8                	jmp    80102f7f <piperead+0x17>
      release(&p->lock);
80102fb7:	83 ec 0c             	sub    $0xc,%esp
80102fba:	53                   	push   %ebx
80102fbb:	e8 28 0c 00 00       	call   80103be8 <release>
      return -1;
80102fc0:	83 c4 10             	add    $0x10,%esp
80102fc3:	be ff ff ff ff       	mov    $0xffffffff,%esi
80102fc8:	eb 50                	jmp    8010301a <piperead+0xb2>
80102fca:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80102fcf:	3b 75 10             	cmp    0x10(%ebp),%esi
80102fd2:	7d 2c                	jge    80103000 <piperead+0x98>
    if(p->nread == p->nwrite)
80102fd4:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102fda:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80102fe0:	74 1e                	je     80103000 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80102fe2:	8d 50 01             	lea    0x1(%eax),%edx
80102fe5:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80102feb:	25 ff 01 00 00       	and    $0x1ff,%eax
80102ff0:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
80102ff5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102ff8:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80102ffb:	83 c6 01             	add    $0x1,%esi
80102ffe:	eb cf                	jmp    80102fcf <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103000:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103006:	83 ec 0c             	sub    $0xc,%esp
80103009:	50                   	push   %eax
8010300a:	e8 de 07 00 00       	call   801037ed <wakeup>
  release(&p->lock);
8010300f:	89 1c 24             	mov    %ebx,(%esp)
80103012:	e8 d1 0b 00 00       	call   80103be8 <release>
  return i;
80103017:	83 c4 10             	add    $0x10,%esp
}
8010301a:	89 f0                	mov    %esi,%eax
8010301c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010301f:	5b                   	pop    %ebx
80103020:	5e                   	pop    %esi
80103021:	5f                   	pop    %edi
80103022:	5d                   	pop    %ebp
80103023:	c3                   	ret    

80103024 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80103024:	55                   	push   %ebp
80103025:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103027:	ba 54 1d 11 80       	mov    $0x80111d54,%edx
8010302c:	eb 03                	jmp    80103031 <wakeup1+0xd>
8010302e:	83 c2 7c             	add    $0x7c,%edx
80103031:	81 fa 54 3c 11 80    	cmp    $0x80113c54,%edx
80103037:	73 14                	jae    8010304d <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
80103039:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
8010303d:	75 ef                	jne    8010302e <wakeup1+0xa>
8010303f:	39 42 20             	cmp    %eax,0x20(%edx)
80103042:	75 ea                	jne    8010302e <wakeup1+0xa>
      p->state = RUNNABLE;
80103044:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
8010304b:	eb e1                	jmp    8010302e <wakeup1+0xa>
}
8010304d:	5d                   	pop    %ebp
8010304e:	c3                   	ret    

8010304f <allocproc>:
{
8010304f:	55                   	push   %ebp
80103050:	89 e5                	mov    %esp,%ebp
80103052:	53                   	push   %ebx
80103053:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80103056:	68 20 1d 11 80       	push   $0x80111d20
8010305b:	e8 23 0b 00 00       	call   80103b83 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103060:	83 c4 10             	add    $0x10,%esp
80103063:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103068:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
8010306e:	73 0b                	jae    8010307b <allocproc+0x2c>
    if(p->state == UNUSED)
80103070:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
80103074:	74 1c                	je     80103092 <allocproc+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103076:	83 c3 7c             	add    $0x7c,%ebx
80103079:	eb ed                	jmp    80103068 <allocproc+0x19>
  release(&ptable.lock);
8010307b:	83 ec 0c             	sub    $0xc,%esp
8010307e:	68 20 1d 11 80       	push   $0x80111d20
80103083:	e8 60 0b 00 00       	call   80103be8 <release>
  return 0;
80103088:	83 c4 10             	add    $0x10,%esp
8010308b:	bb 00 00 00 00       	mov    $0x0,%ebx
80103090:	eb 69                	jmp    801030fb <allocproc+0xac>
  p->state = EMBRYO;
80103092:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103099:	a1 04 90 10 80       	mov    0x80109004,%eax
8010309e:	8d 50 01             	lea    0x1(%eax),%edx
801030a1:	89 15 04 90 10 80    	mov    %edx,0x80109004
801030a7:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
801030aa:	83 ec 0c             	sub    $0xc,%esp
801030ad:	68 20 1d 11 80       	push   $0x80111d20
801030b2:	e8 31 0b 00 00       	call   80103be8 <release>
  if((p->kstack = kalloc()) == 0){
801030b7:	e8 ed ef ff ff       	call   801020a9 <kalloc>
801030bc:	89 43 08             	mov    %eax,0x8(%ebx)
801030bf:	83 c4 10             	add    $0x10,%esp
801030c2:	85 c0                	test   %eax,%eax
801030c4:	74 3c                	je     80103102 <allocproc+0xb3>
  sp -= sizeof *p->tf;
801030c6:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
801030cc:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
801030cf:	c7 80 b0 0f 00 00 c2 	movl   $0x80104dc2,0xfb0(%eax)
801030d6:	4d 10 80 
  sp -= sizeof *p->context;
801030d9:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
801030de:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
801030e1:	83 ec 04             	sub    $0x4,%esp
801030e4:	6a 14                	push   $0x14
801030e6:	6a 00                	push   $0x0
801030e8:	50                   	push   %eax
801030e9:	e8 41 0b 00 00       	call   80103c2f <memset>
  p->context->eip = (uint)forkret;
801030ee:	8b 43 1c             	mov    0x1c(%ebx),%eax
801030f1:	c7 40 10 10 31 10 80 	movl   $0x80103110,0x10(%eax)
  return p;
801030f8:	83 c4 10             	add    $0x10,%esp
}
801030fb:	89 d8                	mov    %ebx,%eax
801030fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103100:	c9                   	leave  
80103101:	c3                   	ret    
    p->state = UNUSED;
80103102:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
80103109:	bb 00 00 00 00       	mov    $0x0,%ebx
8010310e:	eb eb                	jmp    801030fb <allocproc+0xac>

80103110 <forkret>:
{
80103110:	55                   	push   %ebp
80103111:	89 e5                	mov    %esp,%ebp
80103113:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
80103116:	68 20 1d 11 80       	push   $0x80111d20
8010311b:	e8 c8 0a 00 00       	call   80103be8 <release>
  if (first) {
80103120:	83 c4 10             	add    $0x10,%esp
80103123:	83 3d 00 90 10 80 00 	cmpl   $0x0,0x80109000
8010312a:	75 02                	jne    8010312e <forkret+0x1e>
}
8010312c:	c9                   	leave  
8010312d:	c3                   	ret    
    first = 0;
8010312e:	c7 05 00 90 10 80 00 	movl   $0x0,0x80109000
80103135:	00 00 00 
    iinit(ROOTDEV);
80103138:	83 ec 0c             	sub    $0xc,%esp
8010313b:	6a 01                	push   $0x1
8010313d:	e8 98 e1 ff ff       	call   801012da <iinit>
    initlog(ROOTDEV);
80103142:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103149:	e8 05 f6 ff ff       	call   80102753 <initlog>
8010314e:	83 c4 10             	add    $0x10,%esp
}
80103151:	eb d9                	jmp    8010312c <forkret+0x1c>

80103153 <pinit>:
{
80103153:	55                   	push   %ebp
80103154:	89 e5                	mov    %esp,%ebp
80103156:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103159:	68 75 6a 10 80       	push   $0x80106a75
8010315e:	68 20 1d 11 80       	push   $0x80111d20
80103163:	e8 df 08 00 00       	call   80103a47 <initlock>
}
80103168:	83 c4 10             	add    $0x10,%esp
8010316b:	c9                   	leave  
8010316c:	c3                   	ret    

8010316d <mycpu>:
{
8010316d:	55                   	push   %ebp
8010316e:	89 e5                	mov    %esp,%ebp
80103170:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103173:	9c                   	pushf  
80103174:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103175:	f6 c4 02             	test   $0x2,%ah
80103178:	75 28                	jne    801031a2 <mycpu+0x35>
  apicid = lapicid();
8010317a:	e8 ed f1 ff ff       	call   8010236c <lapicid>
  for (i = 0; i < ncpu; ++i) {
8010317f:	ba 00 00 00 00       	mov    $0x0,%edx
80103184:	39 15 00 1d 11 80    	cmp    %edx,0x80111d00
8010318a:	7e 23                	jle    801031af <mycpu+0x42>
    if (cpus[i].apicid == apicid)
8010318c:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103192:	0f b6 89 80 17 11 80 	movzbl -0x7feee880(%ecx),%ecx
80103199:	39 c1                	cmp    %eax,%ecx
8010319b:	74 1f                	je     801031bc <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
8010319d:	83 c2 01             	add    $0x1,%edx
801031a0:	eb e2                	jmp    80103184 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
801031a2:	83 ec 0c             	sub    $0xc,%esp
801031a5:	68 58 6b 10 80       	push   $0x80106b58
801031aa:	e8 99 d1 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
801031af:	83 ec 0c             	sub    $0xc,%esp
801031b2:	68 7c 6a 10 80       	push   $0x80106a7c
801031b7:	e8 8c d1 ff ff       	call   80100348 <panic>
      return &cpus[i];
801031bc:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
801031c2:	05 80 17 11 80       	add    $0x80111780,%eax
}
801031c7:	c9                   	leave  
801031c8:	c3                   	ret    

801031c9 <cpuid>:
cpuid() {
801031c9:	55                   	push   %ebp
801031ca:	89 e5                	mov    %esp,%ebp
801031cc:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801031cf:	e8 99 ff ff ff       	call   8010316d <mycpu>
801031d4:	2d 80 17 11 80       	sub    $0x80111780,%eax
801031d9:	c1 f8 04             	sar    $0x4,%eax
801031dc:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801031e2:	c9                   	leave  
801031e3:	c3                   	ret    

801031e4 <myproc>:
myproc(void) {
801031e4:	55                   	push   %ebp
801031e5:	89 e5                	mov    %esp,%ebp
801031e7:	53                   	push   %ebx
801031e8:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801031eb:	e8 b6 08 00 00       	call   80103aa6 <pushcli>
  c = mycpu();
801031f0:	e8 78 ff ff ff       	call   8010316d <mycpu>
  p = c->proc;
801031f5:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801031fb:	e8 e3 08 00 00       	call   80103ae3 <popcli>
}
80103200:	89 d8                	mov    %ebx,%eax
80103202:	83 c4 04             	add    $0x4,%esp
80103205:	5b                   	pop    %ebx
80103206:	5d                   	pop    %ebp
80103207:	c3                   	ret    

80103208 <userinit>:
{
80103208:	55                   	push   %ebp
80103209:	89 e5                	mov    %esp,%ebp
8010320b:	53                   	push   %ebx
8010320c:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
8010320f:	e8 3b fe ff ff       	call   8010304f <allocproc>
80103214:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103216:	a3 b8 95 10 80       	mov    %eax,0x801095b8
  if((p->pgdir = setupkvm()) == 0)
8010321b:	e8 86 30 00 00       	call   801062a6 <setupkvm>
80103220:	89 43 04             	mov    %eax,0x4(%ebx)
80103223:	85 c0                	test   %eax,%eax
80103225:	0f 84 b7 00 00 00    	je     801032e2 <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010322b:	83 ec 04             	sub    $0x4,%esp
8010322e:	68 2c 00 00 00       	push   $0x2c
80103233:	68 60 94 10 80       	push   $0x80109460
80103238:	50                   	push   %eax
80103239:	e8 73 2d 00 00       	call   80105fb1 <inituvm>
  p->sz = PGSIZE;
8010323e:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103244:	83 c4 0c             	add    $0xc,%esp
80103247:	6a 4c                	push   $0x4c
80103249:	6a 00                	push   $0x0
8010324b:	ff 73 18             	pushl  0x18(%ebx)
8010324e:	e8 dc 09 00 00       	call   80103c2f <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103253:	8b 43 18             	mov    0x18(%ebx),%eax
80103256:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010325c:	8b 43 18             	mov    0x18(%ebx),%eax
8010325f:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103265:	8b 43 18             	mov    0x18(%ebx),%eax
80103268:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
8010326c:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103270:	8b 43 18             	mov    0x18(%ebx),%eax
80103273:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103277:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010327b:	8b 43 18             	mov    0x18(%ebx),%eax
8010327e:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103285:	8b 43 18             	mov    0x18(%ebx),%eax
80103288:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010328f:	8b 43 18             	mov    0x18(%ebx),%eax
80103292:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103299:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010329c:	83 c4 0c             	add    $0xc,%esp
8010329f:	6a 10                	push   $0x10
801032a1:	68 a5 6a 10 80       	push   $0x80106aa5
801032a6:	50                   	push   %eax
801032a7:	e8 ea 0a 00 00       	call   80103d96 <safestrcpy>
  p->cwd = namei("/");
801032ac:	c7 04 24 ae 6a 10 80 	movl   $0x80106aae,(%esp)
801032b3:	e8 17 e9 ff ff       	call   80101bcf <namei>
801032b8:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
801032bb:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801032c2:	e8 bc 08 00 00       	call   80103b83 <acquire>
  p->state = RUNNABLE;
801032c7:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
801032ce:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801032d5:	e8 0e 09 00 00       	call   80103be8 <release>
}
801032da:	83 c4 10             	add    $0x10,%esp
801032dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801032e0:	c9                   	leave  
801032e1:	c3                   	ret    
    panic("userinit: out of memory?");
801032e2:	83 ec 0c             	sub    $0xc,%esp
801032e5:	68 8c 6a 10 80       	push   $0x80106a8c
801032ea:	e8 59 d0 ff ff       	call   80100348 <panic>

801032ef <growproc>:
{
801032ef:	55                   	push   %ebp
801032f0:	89 e5                	mov    %esp,%ebp
801032f2:	56                   	push   %esi
801032f3:	53                   	push   %ebx
801032f4:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
801032f7:	e8 e8 fe ff ff       	call   801031e4 <myproc>
801032fc:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
801032fe:	8b 00                	mov    (%eax),%eax
  if(n > 0){
80103300:	85 f6                	test   %esi,%esi
80103302:	7f 21                	jg     80103325 <growproc+0x36>
  } else if(n < 0){
80103304:	85 f6                	test   %esi,%esi
80103306:	79 33                	jns    8010333b <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103308:	83 ec 04             	sub    $0x4,%esp
8010330b:	01 c6                	add    %eax,%esi
8010330d:	56                   	push   %esi
8010330e:	50                   	push   %eax
8010330f:	ff 73 04             	pushl  0x4(%ebx)
80103312:	e8 a3 2d 00 00       	call   801060ba <deallocuvm>
80103317:	83 c4 10             	add    $0x10,%esp
8010331a:	85 c0                	test   %eax,%eax
8010331c:	75 1d                	jne    8010333b <growproc+0x4c>
      return -1;
8010331e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103323:	eb 29                	jmp    8010334e <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103325:	83 ec 04             	sub    $0x4,%esp
80103328:	01 c6                	add    %eax,%esi
8010332a:	56                   	push   %esi
8010332b:	50                   	push   %eax
8010332c:	ff 73 04             	pushl  0x4(%ebx)
8010332f:	e8 18 2e 00 00       	call   8010614c <allocuvm>
80103334:	83 c4 10             	add    $0x10,%esp
80103337:	85 c0                	test   %eax,%eax
80103339:	74 1a                	je     80103355 <growproc+0x66>
  curproc->sz = sz;
8010333b:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
8010333d:	83 ec 0c             	sub    $0xc,%esp
80103340:	53                   	push   %ebx
80103341:	e8 53 2b 00 00       	call   80105e99 <switchuvm>
  return 0;
80103346:	83 c4 10             	add    $0x10,%esp
80103349:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010334e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103351:	5b                   	pop    %ebx
80103352:	5e                   	pop    %esi
80103353:	5d                   	pop    %ebp
80103354:	c3                   	ret    
      return -1;
80103355:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010335a:	eb f2                	jmp    8010334e <growproc+0x5f>

8010335c <fork>:
{
8010335c:	55                   	push   %ebp
8010335d:	89 e5                	mov    %esp,%ebp
8010335f:	57                   	push   %edi
80103360:	56                   	push   %esi
80103361:	53                   	push   %ebx
80103362:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
80103365:	e8 7a fe ff ff       	call   801031e4 <myproc>
8010336a:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
8010336c:	e8 de fc ff ff       	call   8010304f <allocproc>
80103371:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103374:	85 c0                	test   %eax,%eax
80103376:	0f 84 e0 00 00 00    	je     8010345c <fork+0x100>
8010337c:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010337e:	83 ec 08             	sub    $0x8,%esp
80103381:	ff 33                	pushl  (%ebx)
80103383:	ff 73 04             	pushl  0x4(%ebx)
80103386:	e8 cc 2f 00 00       	call   80106357 <copyuvm>
8010338b:	89 47 04             	mov    %eax,0x4(%edi)
8010338e:	83 c4 10             	add    $0x10,%esp
80103391:	85 c0                	test   %eax,%eax
80103393:	74 2a                	je     801033bf <fork+0x63>
  np->sz = curproc->sz;
80103395:	8b 03                	mov    (%ebx),%eax
80103397:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010339a:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
8010339c:	89 c8                	mov    %ecx,%eax
8010339e:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
801033a1:	8b 73 18             	mov    0x18(%ebx),%esi
801033a4:	8b 79 18             	mov    0x18(%ecx),%edi
801033a7:	b9 13 00 00 00       	mov    $0x13,%ecx
801033ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
801033ae:	8b 40 18             	mov    0x18(%eax),%eax
801033b1:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
801033b8:	be 00 00 00 00       	mov    $0x0,%esi
801033bd:	eb 29                	jmp    801033e8 <fork+0x8c>
    kfree(np->kstack);
801033bf:	83 ec 0c             	sub    $0xc,%esp
801033c2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801033c5:	ff 73 08             	pushl  0x8(%ebx)
801033c8:	e8 c5 eb ff ff       	call   80101f92 <kfree>
    np->kstack = 0;
801033cd:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
801033d4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
801033db:	83 c4 10             	add    $0x10,%esp
801033de:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801033e3:	eb 6d                	jmp    80103452 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
801033e5:	83 c6 01             	add    $0x1,%esi
801033e8:	83 fe 0f             	cmp    $0xf,%esi
801033eb:	7f 1d                	jg     8010340a <fork+0xae>
    if(curproc->ofile[i])
801033ed:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801033f1:	85 c0                	test   %eax,%eax
801033f3:	74 f0                	je     801033e5 <fork+0x89>
      np->ofile[i] = filedup(curproc->ofile[i]);
801033f5:	83 ec 0c             	sub    $0xc,%esp
801033f8:	50                   	push   %eax
801033f9:	e8 90 d8 ff ff       	call   80100c8e <filedup>
801033fe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103401:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
80103405:	83 c4 10             	add    $0x10,%esp
80103408:	eb db                	jmp    801033e5 <fork+0x89>
  np->cwd = idup(curproc->cwd);
8010340a:	83 ec 0c             	sub    $0xc,%esp
8010340d:	ff 73 68             	pushl  0x68(%ebx)
80103410:	e8 2a e1 ff ff       	call   8010153f <idup>
80103415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103418:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010341b:	83 c3 6c             	add    $0x6c,%ebx
8010341e:	8d 47 6c             	lea    0x6c(%edi),%eax
80103421:	83 c4 0c             	add    $0xc,%esp
80103424:	6a 10                	push   $0x10
80103426:	53                   	push   %ebx
80103427:	50                   	push   %eax
80103428:	e8 69 09 00 00       	call   80103d96 <safestrcpy>
  pid = np->pid;
8010342d:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
80103430:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103437:	e8 47 07 00 00       	call   80103b83 <acquire>
  np->state = RUNNABLE;
8010343c:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103443:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010344a:	e8 99 07 00 00       	call   80103be8 <release>
  return pid;
8010344f:	83 c4 10             	add    $0x10,%esp
}
80103452:	89 d8                	mov    %ebx,%eax
80103454:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103457:	5b                   	pop    %ebx
80103458:	5e                   	pop    %esi
80103459:	5f                   	pop    %edi
8010345a:	5d                   	pop    %ebp
8010345b:	c3                   	ret    
    return -1;
8010345c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103461:	eb ef                	jmp    80103452 <fork+0xf6>

80103463 <scheduler>:
{
80103463:	55                   	push   %ebp
80103464:	89 e5                	mov    %esp,%ebp
80103466:	56                   	push   %esi
80103467:	53                   	push   %ebx
  struct cpu *c = mycpu();
80103468:	e8 00 fd ff ff       	call   8010316d <mycpu>
8010346d:	89 c6                	mov    %eax,%esi
  c->proc = 0;
8010346f:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103476:	00 00 00 
80103479:	eb 5a                	jmp    801034d5 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010347b:	83 c3 7c             	add    $0x7c,%ebx
8010347e:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
80103484:	73 3f                	jae    801034c5 <scheduler+0x62>
      if(p->state != RUNNABLE)
80103486:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
8010348a:	75 ef                	jne    8010347b <scheduler+0x18>
      c->proc = p;
8010348c:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103492:	83 ec 0c             	sub    $0xc,%esp
80103495:	53                   	push   %ebx
80103496:	e8 fe 29 00 00       	call   80105e99 <switchuvm>
      p->state = RUNNING;
8010349b:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
801034a2:	83 c4 08             	add    $0x8,%esp
801034a5:	ff 73 1c             	pushl  0x1c(%ebx)
801034a8:	8d 46 04             	lea    0x4(%esi),%eax
801034ab:	50                   	push   %eax
801034ac:	e8 38 09 00 00       	call   80103de9 <swtch>
      switchkvm();
801034b1:	e8 d1 29 00 00       	call   80105e87 <switchkvm>
      c->proc = 0;
801034b6:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801034bd:	00 00 00 
801034c0:	83 c4 10             	add    $0x10,%esp
801034c3:	eb b6                	jmp    8010347b <scheduler+0x18>
    release(&ptable.lock);
801034c5:	83 ec 0c             	sub    $0xc,%esp
801034c8:	68 20 1d 11 80       	push   $0x80111d20
801034cd:	e8 16 07 00 00       	call   80103be8 <release>
    sti();
801034d2:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
801034d5:	fb                   	sti    
    acquire(&ptable.lock);
801034d6:	83 ec 0c             	sub    $0xc,%esp
801034d9:	68 20 1d 11 80       	push   $0x80111d20
801034de:	e8 a0 06 00 00       	call   80103b83 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801034e3:	83 c4 10             	add    $0x10,%esp
801034e6:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
801034eb:	eb 91                	jmp    8010347e <scheduler+0x1b>

801034ed <sched>:
{
801034ed:	55                   	push   %ebp
801034ee:	89 e5                	mov    %esp,%ebp
801034f0:	56                   	push   %esi
801034f1:	53                   	push   %ebx
  struct proc *p = myproc();
801034f2:	e8 ed fc ff ff       	call   801031e4 <myproc>
801034f7:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
801034f9:	83 ec 0c             	sub    $0xc,%esp
801034fc:	68 20 1d 11 80       	push   $0x80111d20
80103501:	e8 3d 06 00 00       	call   80103b43 <holding>
80103506:	83 c4 10             	add    $0x10,%esp
80103509:	85 c0                	test   %eax,%eax
8010350b:	74 4f                	je     8010355c <sched+0x6f>
  if(mycpu()->ncli != 1)
8010350d:	e8 5b fc ff ff       	call   8010316d <mycpu>
80103512:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103519:	75 4e                	jne    80103569 <sched+0x7c>
  if(p->state == RUNNING)
8010351b:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
8010351f:	74 55                	je     80103576 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103521:	9c                   	pushf  
80103522:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103523:	f6 c4 02             	test   $0x2,%ah
80103526:	75 5b                	jne    80103583 <sched+0x96>
  intena = mycpu()->intena;
80103528:	e8 40 fc ff ff       	call   8010316d <mycpu>
8010352d:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103533:	e8 35 fc ff ff       	call   8010316d <mycpu>
80103538:	83 ec 08             	sub    $0x8,%esp
8010353b:	ff 70 04             	pushl  0x4(%eax)
8010353e:	83 c3 1c             	add    $0x1c,%ebx
80103541:	53                   	push   %ebx
80103542:	e8 a2 08 00 00       	call   80103de9 <swtch>
  mycpu()->intena = intena;
80103547:	e8 21 fc ff ff       	call   8010316d <mycpu>
8010354c:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103552:	83 c4 10             	add    $0x10,%esp
80103555:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103558:	5b                   	pop    %ebx
80103559:	5e                   	pop    %esi
8010355a:	5d                   	pop    %ebp
8010355b:	c3                   	ret    
    panic("sched ptable.lock");
8010355c:	83 ec 0c             	sub    $0xc,%esp
8010355f:	68 b0 6a 10 80       	push   $0x80106ab0
80103564:	e8 df cd ff ff       	call   80100348 <panic>
    panic("sched locks");
80103569:	83 ec 0c             	sub    $0xc,%esp
8010356c:	68 c2 6a 10 80       	push   $0x80106ac2
80103571:	e8 d2 cd ff ff       	call   80100348 <panic>
    panic("sched running");
80103576:	83 ec 0c             	sub    $0xc,%esp
80103579:	68 ce 6a 10 80       	push   $0x80106ace
8010357e:	e8 c5 cd ff ff       	call   80100348 <panic>
    panic("sched interruptible");
80103583:	83 ec 0c             	sub    $0xc,%esp
80103586:	68 dc 6a 10 80       	push   $0x80106adc
8010358b:	e8 b8 cd ff ff       	call   80100348 <panic>

80103590 <exit>:
{
80103590:	55                   	push   %ebp
80103591:	89 e5                	mov    %esp,%ebp
80103593:	56                   	push   %esi
80103594:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103595:	e8 4a fc ff ff       	call   801031e4 <myproc>
  if(curproc == initproc)
8010359a:	39 05 b8 95 10 80    	cmp    %eax,0x801095b8
801035a0:	74 09                	je     801035ab <exit+0x1b>
801035a2:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801035a4:	bb 00 00 00 00       	mov    $0x0,%ebx
801035a9:	eb 10                	jmp    801035bb <exit+0x2b>
    panic("init exiting");
801035ab:	83 ec 0c             	sub    $0xc,%esp
801035ae:	68 f0 6a 10 80       	push   $0x80106af0
801035b3:	e8 90 cd ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
801035b8:	83 c3 01             	add    $0x1,%ebx
801035bb:	83 fb 0f             	cmp    $0xf,%ebx
801035be:	7f 1e                	jg     801035de <exit+0x4e>
    if(curproc->ofile[fd]){
801035c0:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
801035c4:	85 c0                	test   %eax,%eax
801035c6:	74 f0                	je     801035b8 <exit+0x28>
      fileclose(curproc->ofile[fd]);
801035c8:	83 ec 0c             	sub    $0xc,%esp
801035cb:	50                   	push   %eax
801035cc:	e8 02 d7 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
801035d1:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
801035d8:	00 
801035d9:	83 c4 10             	add    $0x10,%esp
801035dc:	eb da                	jmp    801035b8 <exit+0x28>
  begin_op();
801035de:	e8 b9 f1 ff ff       	call   8010279c <begin_op>
  iput(curproc->cwd);
801035e3:	83 ec 0c             	sub    $0xc,%esp
801035e6:	ff 76 68             	pushl  0x68(%esi)
801035e9:	e8 88 e0 ff ff       	call   80101676 <iput>
  end_op();
801035ee:	e8 23 f2 ff ff       	call   80102816 <end_op>
  curproc->cwd = 0;
801035f3:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
801035fa:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103601:	e8 7d 05 00 00       	call   80103b83 <acquire>
  wakeup1(curproc->parent);
80103606:	8b 46 14             	mov    0x14(%esi),%eax
80103609:	e8 16 fa ff ff       	call   80103024 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010360e:	83 c4 10             	add    $0x10,%esp
80103611:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103616:	eb 03                	jmp    8010361b <exit+0x8b>
80103618:	83 c3 7c             	add    $0x7c,%ebx
8010361b:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
80103621:	73 1a                	jae    8010363d <exit+0xad>
    if(p->parent == curproc){
80103623:	39 73 14             	cmp    %esi,0x14(%ebx)
80103626:	75 f0                	jne    80103618 <exit+0x88>
      p->parent = initproc;
80103628:	a1 b8 95 10 80       	mov    0x801095b8,%eax
8010362d:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
80103630:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103634:	75 e2                	jne    80103618 <exit+0x88>
        wakeup1(initproc);
80103636:	e8 e9 f9 ff ff       	call   80103024 <wakeup1>
8010363b:	eb db                	jmp    80103618 <exit+0x88>
  curproc->state = ZOMBIE;
8010363d:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103644:	e8 a4 fe ff ff       	call   801034ed <sched>
  panic("zombie exit");
80103649:	83 ec 0c             	sub    $0xc,%esp
8010364c:	68 fd 6a 10 80       	push   $0x80106afd
80103651:	e8 f2 cc ff ff       	call   80100348 <panic>

80103656 <yield>:
{
80103656:	55                   	push   %ebp
80103657:	89 e5                	mov    %esp,%ebp
80103659:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010365c:	68 20 1d 11 80       	push   $0x80111d20
80103661:	e8 1d 05 00 00       	call   80103b83 <acquire>
  myproc()->state = RUNNABLE;
80103666:	e8 79 fb ff ff       	call   801031e4 <myproc>
8010366b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103672:	e8 76 fe ff ff       	call   801034ed <sched>
  release(&ptable.lock);
80103677:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010367e:	e8 65 05 00 00       	call   80103be8 <release>
}
80103683:	83 c4 10             	add    $0x10,%esp
80103686:	c9                   	leave  
80103687:	c3                   	ret    

80103688 <sleep>:
{
80103688:	55                   	push   %ebp
80103689:	89 e5                	mov    %esp,%ebp
8010368b:	56                   	push   %esi
8010368c:	53                   	push   %ebx
8010368d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
80103690:	e8 4f fb ff ff       	call   801031e4 <myproc>
  if(p == 0)
80103695:	85 c0                	test   %eax,%eax
80103697:	74 66                	je     801036ff <sleep+0x77>
80103699:	89 c6                	mov    %eax,%esi
  if(lk == 0)
8010369b:	85 db                	test   %ebx,%ebx
8010369d:	74 6d                	je     8010370c <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010369f:	81 fb 20 1d 11 80    	cmp    $0x80111d20,%ebx
801036a5:	74 18                	je     801036bf <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
801036a7:	83 ec 0c             	sub    $0xc,%esp
801036aa:	68 20 1d 11 80       	push   $0x80111d20
801036af:	e8 cf 04 00 00       	call   80103b83 <acquire>
    release(lk);
801036b4:	89 1c 24             	mov    %ebx,(%esp)
801036b7:	e8 2c 05 00 00       	call   80103be8 <release>
801036bc:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
801036bf:	8b 45 08             	mov    0x8(%ebp),%eax
801036c2:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
801036c5:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
801036cc:	e8 1c fe ff ff       	call   801034ed <sched>
  p->chan = 0;
801036d1:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
801036d8:	81 fb 20 1d 11 80    	cmp    $0x80111d20,%ebx
801036de:	74 18                	je     801036f8 <sleep+0x70>
    release(&ptable.lock);
801036e0:	83 ec 0c             	sub    $0xc,%esp
801036e3:	68 20 1d 11 80       	push   $0x80111d20
801036e8:	e8 fb 04 00 00       	call   80103be8 <release>
    acquire(lk);
801036ed:	89 1c 24             	mov    %ebx,(%esp)
801036f0:	e8 8e 04 00 00       	call   80103b83 <acquire>
801036f5:	83 c4 10             	add    $0x10,%esp
}
801036f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801036fb:	5b                   	pop    %ebx
801036fc:	5e                   	pop    %esi
801036fd:	5d                   	pop    %ebp
801036fe:	c3                   	ret    
    panic("sleep");
801036ff:	83 ec 0c             	sub    $0xc,%esp
80103702:	68 09 6b 10 80       	push   $0x80106b09
80103707:	e8 3c cc ff ff       	call   80100348 <panic>
    panic("sleep without lk");
8010370c:	83 ec 0c             	sub    $0xc,%esp
8010370f:	68 0f 6b 10 80       	push   $0x80106b0f
80103714:	e8 2f cc ff ff       	call   80100348 <panic>

80103719 <wait>:
{
80103719:	55                   	push   %ebp
8010371a:	89 e5                	mov    %esp,%ebp
8010371c:	56                   	push   %esi
8010371d:	53                   	push   %ebx
  struct proc *curproc = myproc();
8010371e:	e8 c1 fa ff ff       	call   801031e4 <myproc>
80103723:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103725:	83 ec 0c             	sub    $0xc,%esp
80103728:	68 20 1d 11 80       	push   $0x80111d20
8010372d:	e8 51 04 00 00       	call   80103b83 <acquire>
80103732:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103735:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010373a:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
8010373f:	eb 5b                	jmp    8010379c <wait+0x83>
        pid = p->pid;
80103741:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103744:	83 ec 0c             	sub    $0xc,%esp
80103747:	ff 73 08             	pushl  0x8(%ebx)
8010374a:	e8 43 e8 ff ff       	call   80101f92 <kfree>
        p->kstack = 0;
8010374f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103756:	83 c4 04             	add    $0x4,%esp
80103759:	ff 73 04             	pushl  0x4(%ebx)
8010375c:	e8 d5 2a 00 00       	call   80106236 <freevm>
        p->pid = 0;
80103761:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103768:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
8010376f:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103773:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
8010377a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103781:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103788:	e8 5b 04 00 00       	call   80103be8 <release>
        return pid;
8010378d:	83 c4 10             	add    $0x10,%esp
}
80103790:	89 f0                	mov    %esi,%eax
80103792:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103795:	5b                   	pop    %ebx
80103796:	5e                   	pop    %esi
80103797:	5d                   	pop    %ebp
80103798:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103799:	83 c3 7c             	add    $0x7c,%ebx
8010379c:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
801037a2:	73 12                	jae    801037b6 <wait+0x9d>
      if(p->parent != curproc)
801037a4:	39 73 14             	cmp    %esi,0x14(%ebx)
801037a7:	75 f0                	jne    80103799 <wait+0x80>
      if(p->state == ZOMBIE){
801037a9:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801037ad:	74 92                	je     80103741 <wait+0x28>
      havekids = 1;
801037af:	b8 01 00 00 00       	mov    $0x1,%eax
801037b4:	eb e3                	jmp    80103799 <wait+0x80>
    if(!havekids || curproc->killed){
801037b6:	85 c0                	test   %eax,%eax
801037b8:	74 06                	je     801037c0 <wait+0xa7>
801037ba:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
801037be:	74 17                	je     801037d7 <wait+0xbe>
      release(&ptable.lock);
801037c0:	83 ec 0c             	sub    $0xc,%esp
801037c3:	68 20 1d 11 80       	push   $0x80111d20
801037c8:	e8 1b 04 00 00       	call   80103be8 <release>
      return -1;
801037cd:	83 c4 10             	add    $0x10,%esp
801037d0:	be ff ff ff ff       	mov    $0xffffffff,%esi
801037d5:	eb b9                	jmp    80103790 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801037d7:	83 ec 08             	sub    $0x8,%esp
801037da:	68 20 1d 11 80       	push   $0x80111d20
801037df:	56                   	push   %esi
801037e0:	e8 a3 fe ff ff       	call   80103688 <sleep>
    havekids = 0;
801037e5:	83 c4 10             	add    $0x10,%esp
801037e8:	e9 48 ff ff ff       	jmp    80103735 <wait+0x1c>

801037ed <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801037ed:	55                   	push   %ebp
801037ee:	89 e5                	mov    %esp,%ebp
801037f0:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
801037f3:	68 20 1d 11 80       	push   $0x80111d20
801037f8:	e8 86 03 00 00       	call   80103b83 <acquire>
  wakeup1(chan);
801037fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103800:	e8 1f f8 ff ff       	call   80103024 <wakeup1>
  release(&ptable.lock);
80103805:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010380c:	e8 d7 03 00 00       	call   80103be8 <release>
}
80103811:	83 c4 10             	add    $0x10,%esp
80103814:	c9                   	leave  
80103815:	c3                   	ret    

80103816 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103816:	55                   	push   %ebp
80103817:	89 e5                	mov    %esp,%ebp
80103819:	53                   	push   %ebx
8010381a:	83 ec 10             	sub    $0x10,%esp
8010381d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103820:	68 20 1d 11 80       	push   $0x80111d20
80103825:	e8 59 03 00 00       	call   80103b83 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010382a:	83 c4 10             	add    $0x10,%esp
8010382d:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
80103832:	3d 54 3c 11 80       	cmp    $0x80113c54,%eax
80103837:	73 3a                	jae    80103873 <kill+0x5d>
    if(p->pid == pid){
80103839:	39 58 10             	cmp    %ebx,0x10(%eax)
8010383c:	74 05                	je     80103843 <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010383e:	83 c0 7c             	add    $0x7c,%eax
80103841:	eb ef                	jmp    80103832 <kill+0x1c>
      p->killed = 1;
80103843:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010384a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
8010384e:	74 1a                	je     8010386a <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103850:	83 ec 0c             	sub    $0xc,%esp
80103853:	68 20 1d 11 80       	push   $0x80111d20
80103858:	e8 8b 03 00 00       	call   80103be8 <release>
      return 0;
8010385d:	83 c4 10             	add    $0x10,%esp
80103860:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103865:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103868:	c9                   	leave  
80103869:	c3                   	ret    
        p->state = RUNNABLE;
8010386a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103871:	eb dd                	jmp    80103850 <kill+0x3a>
  release(&ptable.lock);
80103873:	83 ec 0c             	sub    $0xc,%esp
80103876:	68 20 1d 11 80       	push   $0x80111d20
8010387b:	e8 68 03 00 00       	call   80103be8 <release>
  return -1;
80103880:	83 c4 10             	add    $0x10,%esp
80103883:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103888:	eb db                	jmp    80103865 <kill+0x4f>

8010388a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010388a:	55                   	push   %ebp
8010388b:	89 e5                	mov    %esp,%ebp
8010388d:	56                   	push   %esi
8010388e:	53                   	push   %ebx
8010388f:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103892:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103897:	eb 33                	jmp    801038cc <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103899:	b8 20 6b 10 80       	mov    $0x80106b20,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
8010389e:	8d 53 6c             	lea    0x6c(%ebx),%edx
801038a1:	52                   	push   %edx
801038a2:	50                   	push   %eax
801038a3:	ff 73 10             	pushl  0x10(%ebx)
801038a6:	68 24 6b 10 80       	push   $0x80106b24
801038ab:	e8 5b cd ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
801038b0:	83 c4 10             	add    $0x10,%esp
801038b3:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
801038b7:	74 39                	je     801038f2 <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801038b9:	83 ec 0c             	sub    $0xc,%esp
801038bc:	68 a3 6e 10 80       	push   $0x80106ea3
801038c1:	e8 45 cd ff ff       	call   8010060b <cprintf>
801038c6:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038c9:	83 c3 7c             	add    $0x7c,%ebx
801038cc:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
801038d2:	73 61                	jae    80103935 <procdump+0xab>
    if(p->state == UNUSED)
801038d4:	8b 43 0c             	mov    0xc(%ebx),%eax
801038d7:	85 c0                	test   %eax,%eax
801038d9:	74 ee                	je     801038c9 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801038db:	83 f8 05             	cmp    $0x5,%eax
801038de:	77 b9                	ja     80103899 <procdump+0xf>
801038e0:	8b 04 85 80 6b 10 80 	mov    -0x7fef9480(,%eax,4),%eax
801038e7:	85 c0                	test   %eax,%eax
801038e9:	75 b3                	jne    8010389e <procdump+0x14>
      state = "???";
801038eb:	b8 20 6b 10 80       	mov    $0x80106b20,%eax
801038f0:	eb ac                	jmp    8010389e <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801038f2:	8b 43 1c             	mov    0x1c(%ebx),%eax
801038f5:	8b 40 0c             	mov    0xc(%eax),%eax
801038f8:	83 c0 08             	add    $0x8,%eax
801038fb:	83 ec 08             	sub    $0x8,%esp
801038fe:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103901:	52                   	push   %edx
80103902:	50                   	push   %eax
80103903:	e8 5a 01 00 00       	call   80103a62 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103908:	83 c4 10             	add    $0x10,%esp
8010390b:	be 00 00 00 00       	mov    $0x0,%esi
80103910:	eb 14                	jmp    80103926 <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103912:	83 ec 08             	sub    $0x8,%esp
80103915:	50                   	push   %eax
80103916:	68 61 65 10 80       	push   $0x80106561
8010391b:	e8 eb cc ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103920:	83 c6 01             	add    $0x1,%esi
80103923:	83 c4 10             	add    $0x10,%esp
80103926:	83 fe 09             	cmp    $0x9,%esi
80103929:	7f 8e                	jg     801038b9 <procdump+0x2f>
8010392b:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
8010392f:	85 c0                	test   %eax,%eax
80103931:	75 df                	jne    80103912 <procdump+0x88>
80103933:	eb 84                	jmp    801038b9 <procdump+0x2f>
  }
}
80103935:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103938:	5b                   	pop    %ebx
80103939:	5e                   	pop    %esi
8010393a:	5d                   	pop    %ebp
8010393b:	c3                   	ret    

8010393c <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010393c:	55                   	push   %ebp
8010393d:	89 e5                	mov    %esp,%ebp
8010393f:	53                   	push   %ebx
80103940:	83 ec 0c             	sub    $0xc,%esp
80103943:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103946:	68 98 6b 10 80       	push   $0x80106b98
8010394b:	8d 43 04             	lea    0x4(%ebx),%eax
8010394e:	50                   	push   %eax
8010394f:	e8 f3 00 00 00       	call   80103a47 <initlock>
  lk->name = name;
80103954:	8b 45 0c             	mov    0xc(%ebp),%eax
80103957:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
8010395a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103960:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103967:	83 c4 10             	add    $0x10,%esp
8010396a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010396d:	c9                   	leave  
8010396e:	c3                   	ret    

8010396f <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010396f:	55                   	push   %ebp
80103970:	89 e5                	mov    %esp,%ebp
80103972:	56                   	push   %esi
80103973:	53                   	push   %ebx
80103974:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103977:	8d 73 04             	lea    0x4(%ebx),%esi
8010397a:	83 ec 0c             	sub    $0xc,%esp
8010397d:	56                   	push   %esi
8010397e:	e8 00 02 00 00       	call   80103b83 <acquire>
  while (lk->locked) {
80103983:	83 c4 10             	add    $0x10,%esp
80103986:	eb 0d                	jmp    80103995 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103988:	83 ec 08             	sub    $0x8,%esp
8010398b:	56                   	push   %esi
8010398c:	53                   	push   %ebx
8010398d:	e8 f6 fc ff ff       	call   80103688 <sleep>
80103992:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103995:	83 3b 00             	cmpl   $0x0,(%ebx)
80103998:	75 ee                	jne    80103988 <acquiresleep+0x19>
  }
  lk->locked = 1;
8010399a:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
801039a0:	e8 3f f8 ff ff       	call   801031e4 <myproc>
801039a5:	8b 40 10             	mov    0x10(%eax),%eax
801039a8:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
801039ab:	83 ec 0c             	sub    $0xc,%esp
801039ae:	56                   	push   %esi
801039af:	e8 34 02 00 00       	call   80103be8 <release>
}
801039b4:	83 c4 10             	add    $0x10,%esp
801039b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801039ba:	5b                   	pop    %ebx
801039bb:	5e                   	pop    %esi
801039bc:	5d                   	pop    %ebp
801039bd:	c3                   	ret    

801039be <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801039be:	55                   	push   %ebp
801039bf:	89 e5                	mov    %esp,%ebp
801039c1:	56                   	push   %esi
801039c2:	53                   	push   %ebx
801039c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801039c6:	8d 73 04             	lea    0x4(%ebx),%esi
801039c9:	83 ec 0c             	sub    $0xc,%esp
801039cc:	56                   	push   %esi
801039cd:	e8 b1 01 00 00       	call   80103b83 <acquire>
  lk->locked = 0;
801039d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
801039d8:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
801039df:	89 1c 24             	mov    %ebx,(%esp)
801039e2:	e8 06 fe ff ff       	call   801037ed <wakeup>
  release(&lk->lk);
801039e7:	89 34 24             	mov    %esi,(%esp)
801039ea:	e8 f9 01 00 00       	call   80103be8 <release>
}
801039ef:	83 c4 10             	add    $0x10,%esp
801039f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801039f5:	5b                   	pop    %ebx
801039f6:	5e                   	pop    %esi
801039f7:	5d                   	pop    %ebp
801039f8:	c3                   	ret    

801039f9 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801039f9:	55                   	push   %ebp
801039fa:	89 e5                	mov    %esp,%ebp
801039fc:	56                   	push   %esi
801039fd:	53                   	push   %ebx
801039fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103a01:	8d 73 04             	lea    0x4(%ebx),%esi
80103a04:	83 ec 0c             	sub    $0xc,%esp
80103a07:	56                   	push   %esi
80103a08:	e8 76 01 00 00       	call   80103b83 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103a0d:	83 c4 10             	add    $0x10,%esp
80103a10:	83 3b 00             	cmpl   $0x0,(%ebx)
80103a13:	75 17                	jne    80103a2c <holdingsleep+0x33>
80103a15:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103a1a:	83 ec 0c             	sub    $0xc,%esp
80103a1d:	56                   	push   %esi
80103a1e:	e8 c5 01 00 00       	call   80103be8 <release>
  return r;
}
80103a23:	89 d8                	mov    %ebx,%eax
80103a25:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a28:	5b                   	pop    %ebx
80103a29:	5e                   	pop    %esi
80103a2a:	5d                   	pop    %ebp
80103a2b:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103a2c:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103a2f:	e8 b0 f7 ff ff       	call   801031e4 <myproc>
80103a34:	3b 58 10             	cmp    0x10(%eax),%ebx
80103a37:	74 07                	je     80103a40 <holdingsleep+0x47>
80103a39:	bb 00 00 00 00       	mov    $0x0,%ebx
80103a3e:	eb da                	jmp    80103a1a <holdingsleep+0x21>
80103a40:	bb 01 00 00 00       	mov    $0x1,%ebx
80103a45:	eb d3                	jmp    80103a1a <holdingsleep+0x21>

80103a47 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103a47:	55                   	push   %ebp
80103a48:	89 e5                	mov    %esp,%ebp
80103a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103a4d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a50:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103a53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103a59:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103a60:	5d                   	pop    %ebp
80103a61:	c3                   	ret    

80103a62 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103a62:	55                   	push   %ebp
80103a63:	89 e5                	mov    %esp,%ebp
80103a65:	53                   	push   %ebx
80103a66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103a69:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6c:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103a6f:	b8 00 00 00 00       	mov    $0x0,%eax
80103a74:	83 f8 09             	cmp    $0x9,%eax
80103a77:	7f 25                	jg     80103a9e <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103a79:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103a7f:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103a85:	77 17                	ja     80103a9e <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103a87:	8b 5a 04             	mov    0x4(%edx),%ebx
80103a8a:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103a8d:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103a8f:	83 c0 01             	add    $0x1,%eax
80103a92:	eb e0                	jmp    80103a74 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103a94:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103a9b:	83 c0 01             	add    $0x1,%eax
80103a9e:	83 f8 09             	cmp    $0x9,%eax
80103aa1:	7e f1                	jle    80103a94 <getcallerpcs+0x32>
}
80103aa3:	5b                   	pop    %ebx
80103aa4:	5d                   	pop    %ebp
80103aa5:	c3                   	ret    

80103aa6 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103aa6:	55                   	push   %ebp
80103aa7:	89 e5                	mov    %esp,%ebp
80103aa9:	53                   	push   %ebx
80103aaa:	83 ec 04             	sub    $0x4,%esp
80103aad:	9c                   	pushf  
80103aae:	5b                   	pop    %ebx
  asm volatile("cli");
80103aaf:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103ab0:	e8 b8 f6 ff ff       	call   8010316d <mycpu>
80103ab5:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103abc:	74 12                	je     80103ad0 <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103abe:	e8 aa f6 ff ff       	call   8010316d <mycpu>
80103ac3:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103aca:	83 c4 04             	add    $0x4,%esp
80103acd:	5b                   	pop    %ebx
80103ace:	5d                   	pop    %ebp
80103acf:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103ad0:	e8 98 f6 ff ff       	call   8010316d <mycpu>
80103ad5:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103adb:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103ae1:	eb db                	jmp    80103abe <pushcli+0x18>

80103ae3 <popcli>:

void
popcli(void)
{
80103ae3:	55                   	push   %ebp
80103ae4:	89 e5                	mov    %esp,%ebp
80103ae6:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103ae9:	9c                   	pushf  
80103aea:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103aeb:	f6 c4 02             	test   $0x2,%ah
80103aee:	75 28                	jne    80103b18 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103af0:	e8 78 f6 ff ff       	call   8010316d <mycpu>
80103af5:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103afb:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103afe:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103b04:	85 d2                	test   %edx,%edx
80103b06:	78 1d                	js     80103b25 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103b08:	e8 60 f6 ff ff       	call   8010316d <mycpu>
80103b0d:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103b14:	74 1c                	je     80103b32 <popcli+0x4f>
    sti();
}
80103b16:	c9                   	leave  
80103b17:	c3                   	ret    
    panic("popcli - interruptible");
80103b18:	83 ec 0c             	sub    $0xc,%esp
80103b1b:	68 a3 6b 10 80       	push   $0x80106ba3
80103b20:	e8 23 c8 ff ff       	call   80100348 <panic>
    panic("popcli");
80103b25:	83 ec 0c             	sub    $0xc,%esp
80103b28:	68 ba 6b 10 80       	push   $0x80106bba
80103b2d:	e8 16 c8 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103b32:	e8 36 f6 ff ff       	call   8010316d <mycpu>
80103b37:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103b3e:	74 d6                	je     80103b16 <popcli+0x33>
  asm volatile("sti");
80103b40:	fb                   	sti    
}
80103b41:	eb d3                	jmp    80103b16 <popcli+0x33>

80103b43 <holding>:
{
80103b43:	55                   	push   %ebp
80103b44:	89 e5                	mov    %esp,%ebp
80103b46:	53                   	push   %ebx
80103b47:	83 ec 04             	sub    $0x4,%esp
80103b4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103b4d:	e8 54 ff ff ff       	call   80103aa6 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103b52:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b55:	75 12                	jne    80103b69 <holding+0x26>
80103b57:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103b5c:	e8 82 ff ff ff       	call   80103ae3 <popcli>
}
80103b61:	89 d8                	mov    %ebx,%eax
80103b63:	83 c4 04             	add    $0x4,%esp
80103b66:	5b                   	pop    %ebx
80103b67:	5d                   	pop    %ebp
80103b68:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103b69:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103b6c:	e8 fc f5 ff ff       	call   8010316d <mycpu>
80103b71:	39 c3                	cmp    %eax,%ebx
80103b73:	74 07                	je     80103b7c <holding+0x39>
80103b75:	bb 00 00 00 00       	mov    $0x0,%ebx
80103b7a:	eb e0                	jmp    80103b5c <holding+0x19>
80103b7c:	bb 01 00 00 00       	mov    $0x1,%ebx
80103b81:	eb d9                	jmp    80103b5c <holding+0x19>

80103b83 <acquire>:
{
80103b83:	55                   	push   %ebp
80103b84:	89 e5                	mov    %esp,%ebp
80103b86:	53                   	push   %ebx
80103b87:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103b8a:	e8 17 ff ff ff       	call   80103aa6 <pushcli>
  if(holding(lk))
80103b8f:	83 ec 0c             	sub    $0xc,%esp
80103b92:	ff 75 08             	pushl  0x8(%ebp)
80103b95:	e8 a9 ff ff ff       	call   80103b43 <holding>
80103b9a:	83 c4 10             	add    $0x10,%esp
80103b9d:	85 c0                	test   %eax,%eax
80103b9f:	75 3a                	jne    80103bdb <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103ba1:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103ba4:	b8 01 00 00 00       	mov    $0x1,%eax
80103ba9:	f0 87 02             	lock xchg %eax,(%edx)
80103bac:	85 c0                	test   %eax,%eax
80103bae:	75 f1                	jne    80103ba1 <acquire+0x1e>
  __sync_synchronize();
80103bb0:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103bb5:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103bb8:	e8 b0 f5 ff ff       	call   8010316d <mycpu>
80103bbd:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103bc0:	8b 45 08             	mov    0x8(%ebp),%eax
80103bc3:	83 c0 0c             	add    $0xc,%eax
80103bc6:	83 ec 08             	sub    $0x8,%esp
80103bc9:	50                   	push   %eax
80103bca:	8d 45 08             	lea    0x8(%ebp),%eax
80103bcd:	50                   	push   %eax
80103bce:	e8 8f fe ff ff       	call   80103a62 <getcallerpcs>
}
80103bd3:	83 c4 10             	add    $0x10,%esp
80103bd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103bd9:	c9                   	leave  
80103bda:	c3                   	ret    
    panic("acquire");
80103bdb:	83 ec 0c             	sub    $0xc,%esp
80103bde:	68 c1 6b 10 80       	push   $0x80106bc1
80103be3:	e8 60 c7 ff ff       	call   80100348 <panic>

80103be8 <release>:
{
80103be8:	55                   	push   %ebp
80103be9:	89 e5                	mov    %esp,%ebp
80103beb:	53                   	push   %ebx
80103bec:	83 ec 10             	sub    $0x10,%esp
80103bef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103bf2:	53                   	push   %ebx
80103bf3:	e8 4b ff ff ff       	call   80103b43 <holding>
80103bf8:	83 c4 10             	add    $0x10,%esp
80103bfb:	85 c0                	test   %eax,%eax
80103bfd:	74 23                	je     80103c22 <release+0x3a>
  lk->pcs[0] = 0;
80103bff:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103c06:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103c0d:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103c12:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103c18:	e8 c6 fe ff ff       	call   80103ae3 <popcli>
}
80103c1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c20:	c9                   	leave  
80103c21:	c3                   	ret    
    panic("release");
80103c22:	83 ec 0c             	sub    $0xc,%esp
80103c25:	68 c9 6b 10 80       	push   $0x80106bc9
80103c2a:	e8 19 c7 ff ff       	call   80100348 <panic>

80103c2f <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103c2f:	55                   	push   %ebp
80103c30:	89 e5                	mov    %esp,%ebp
80103c32:	57                   	push   %edi
80103c33:	53                   	push   %ebx
80103c34:	8b 55 08             	mov    0x8(%ebp),%edx
80103c37:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103c3a:	f6 c2 03             	test   $0x3,%dl
80103c3d:	75 05                	jne    80103c44 <memset+0x15>
80103c3f:	f6 c1 03             	test   $0x3,%cl
80103c42:	74 0e                	je     80103c52 <memset+0x23>
  asm volatile("cld; rep stosb" :
80103c44:	89 d7                	mov    %edx,%edi
80103c46:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c49:	fc                   	cld    
80103c4a:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103c4c:	89 d0                	mov    %edx,%eax
80103c4e:	5b                   	pop    %ebx
80103c4f:	5f                   	pop    %edi
80103c50:	5d                   	pop    %ebp
80103c51:	c3                   	ret    
    c &= 0xFF;
80103c52:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103c56:	c1 e9 02             	shr    $0x2,%ecx
80103c59:	89 f8                	mov    %edi,%eax
80103c5b:	c1 e0 18             	shl    $0x18,%eax
80103c5e:	89 fb                	mov    %edi,%ebx
80103c60:	c1 e3 10             	shl    $0x10,%ebx
80103c63:	09 d8                	or     %ebx,%eax
80103c65:	89 fb                	mov    %edi,%ebx
80103c67:	c1 e3 08             	shl    $0x8,%ebx
80103c6a:	09 d8                	or     %ebx,%eax
80103c6c:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103c6e:	89 d7                	mov    %edx,%edi
80103c70:	fc                   	cld    
80103c71:	f3 ab                	rep stos %eax,%es:(%edi)
80103c73:	eb d7                	jmp    80103c4c <memset+0x1d>

80103c75 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103c75:	55                   	push   %ebp
80103c76:	89 e5                	mov    %esp,%ebp
80103c78:	56                   	push   %esi
80103c79:	53                   	push   %ebx
80103c7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103c7d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c80:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103c83:	8d 70 ff             	lea    -0x1(%eax),%esi
80103c86:	85 c0                	test   %eax,%eax
80103c88:	74 1c                	je     80103ca6 <memcmp+0x31>
    if(*s1 != *s2)
80103c8a:	0f b6 01             	movzbl (%ecx),%eax
80103c8d:	0f b6 1a             	movzbl (%edx),%ebx
80103c90:	38 d8                	cmp    %bl,%al
80103c92:	75 0a                	jne    80103c9e <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103c94:	83 c1 01             	add    $0x1,%ecx
80103c97:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103c9a:	89 f0                	mov    %esi,%eax
80103c9c:	eb e5                	jmp    80103c83 <memcmp+0xe>
      return *s1 - *s2;
80103c9e:	0f b6 c0             	movzbl %al,%eax
80103ca1:	0f b6 db             	movzbl %bl,%ebx
80103ca4:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103ca6:	5b                   	pop    %ebx
80103ca7:	5e                   	pop    %esi
80103ca8:	5d                   	pop    %ebp
80103ca9:	c3                   	ret    

80103caa <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103caa:	55                   	push   %ebp
80103cab:	89 e5                	mov    %esp,%ebp
80103cad:	56                   	push   %esi
80103cae:	53                   	push   %ebx
80103caf:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103cb5:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103cb8:	39 c1                	cmp    %eax,%ecx
80103cba:	73 3a                	jae    80103cf6 <memmove+0x4c>
80103cbc:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103cbf:	39 c3                	cmp    %eax,%ebx
80103cc1:	76 37                	jbe    80103cfa <memmove+0x50>
    s += n;
    d += n;
80103cc3:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103cc6:	eb 0d                	jmp    80103cd5 <memmove+0x2b>
      *--d = *--s;
80103cc8:	83 eb 01             	sub    $0x1,%ebx
80103ccb:	83 e9 01             	sub    $0x1,%ecx
80103cce:	0f b6 13             	movzbl (%ebx),%edx
80103cd1:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103cd3:	89 f2                	mov    %esi,%edx
80103cd5:	8d 72 ff             	lea    -0x1(%edx),%esi
80103cd8:	85 d2                	test   %edx,%edx
80103cda:	75 ec                	jne    80103cc8 <memmove+0x1e>
80103cdc:	eb 14                	jmp    80103cf2 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103cde:	0f b6 11             	movzbl (%ecx),%edx
80103ce1:	88 13                	mov    %dl,(%ebx)
80103ce3:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103ce6:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103ce9:	89 f2                	mov    %esi,%edx
80103ceb:	8d 72 ff             	lea    -0x1(%edx),%esi
80103cee:	85 d2                	test   %edx,%edx
80103cf0:	75 ec                	jne    80103cde <memmove+0x34>

  return dst;
}
80103cf2:	5b                   	pop    %ebx
80103cf3:	5e                   	pop    %esi
80103cf4:	5d                   	pop    %ebp
80103cf5:	c3                   	ret    
80103cf6:	89 c3                	mov    %eax,%ebx
80103cf8:	eb f1                	jmp    80103ceb <memmove+0x41>
80103cfa:	89 c3                	mov    %eax,%ebx
80103cfc:	eb ed                	jmp    80103ceb <memmove+0x41>

80103cfe <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103cfe:	55                   	push   %ebp
80103cff:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103d01:	ff 75 10             	pushl  0x10(%ebp)
80103d04:	ff 75 0c             	pushl  0xc(%ebp)
80103d07:	ff 75 08             	pushl  0x8(%ebp)
80103d0a:	e8 9b ff ff ff       	call   80103caa <memmove>
}
80103d0f:	c9                   	leave  
80103d10:	c3                   	ret    

80103d11 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103d11:	55                   	push   %ebp
80103d12:	89 e5                	mov    %esp,%ebp
80103d14:	53                   	push   %ebx
80103d15:	8b 55 08             	mov    0x8(%ebp),%edx
80103d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103d1b:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103d1e:	eb 09                	jmp    80103d29 <strncmp+0x18>
    n--, p++, q++;
80103d20:	83 e8 01             	sub    $0x1,%eax
80103d23:	83 c2 01             	add    $0x1,%edx
80103d26:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103d29:	85 c0                	test   %eax,%eax
80103d2b:	74 0b                	je     80103d38 <strncmp+0x27>
80103d2d:	0f b6 1a             	movzbl (%edx),%ebx
80103d30:	84 db                	test   %bl,%bl
80103d32:	74 04                	je     80103d38 <strncmp+0x27>
80103d34:	3a 19                	cmp    (%ecx),%bl
80103d36:	74 e8                	je     80103d20 <strncmp+0xf>
  if(n == 0)
80103d38:	85 c0                	test   %eax,%eax
80103d3a:	74 0b                	je     80103d47 <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103d3c:	0f b6 02             	movzbl (%edx),%eax
80103d3f:	0f b6 11             	movzbl (%ecx),%edx
80103d42:	29 d0                	sub    %edx,%eax
}
80103d44:	5b                   	pop    %ebx
80103d45:	5d                   	pop    %ebp
80103d46:	c3                   	ret    
    return 0;
80103d47:	b8 00 00 00 00       	mov    $0x0,%eax
80103d4c:	eb f6                	jmp    80103d44 <strncmp+0x33>

80103d4e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103d4e:	55                   	push   %ebp
80103d4f:	89 e5                	mov    %esp,%ebp
80103d51:	57                   	push   %edi
80103d52:	56                   	push   %esi
80103d53:	53                   	push   %ebx
80103d54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103d57:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80103d5d:	eb 04                	jmp    80103d63 <strncpy+0x15>
80103d5f:	89 fb                	mov    %edi,%ebx
80103d61:	89 f0                	mov    %esi,%eax
80103d63:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103d66:	85 c9                	test   %ecx,%ecx
80103d68:	7e 1d                	jle    80103d87 <strncpy+0x39>
80103d6a:	8d 7b 01             	lea    0x1(%ebx),%edi
80103d6d:	8d 70 01             	lea    0x1(%eax),%esi
80103d70:	0f b6 1b             	movzbl (%ebx),%ebx
80103d73:	88 18                	mov    %bl,(%eax)
80103d75:	89 d1                	mov    %edx,%ecx
80103d77:	84 db                	test   %bl,%bl
80103d79:	75 e4                	jne    80103d5f <strncpy+0x11>
80103d7b:	89 f0                	mov    %esi,%eax
80103d7d:	eb 08                	jmp    80103d87 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103d7f:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103d82:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103d84:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103d87:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103d8a:	85 d2                	test   %edx,%edx
80103d8c:	7f f1                	jg     80103d7f <strncpy+0x31>
  return os;
}
80103d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d91:	5b                   	pop    %ebx
80103d92:	5e                   	pop    %esi
80103d93:	5f                   	pop    %edi
80103d94:	5d                   	pop    %ebp
80103d95:	c3                   	ret    

80103d96 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103d96:	55                   	push   %ebp
80103d97:	89 e5                	mov    %esp,%ebp
80103d99:	57                   	push   %edi
80103d9a:	56                   	push   %esi
80103d9b:	53                   	push   %ebx
80103d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103da2:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103da5:	85 d2                	test   %edx,%edx
80103da7:	7e 23                	jle    80103dcc <safestrcpy+0x36>
80103da9:	89 c1                	mov    %eax,%ecx
80103dab:	eb 04                	jmp    80103db1 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103dad:	89 fb                	mov    %edi,%ebx
80103daf:	89 f1                	mov    %esi,%ecx
80103db1:	83 ea 01             	sub    $0x1,%edx
80103db4:	85 d2                	test   %edx,%edx
80103db6:	7e 11                	jle    80103dc9 <safestrcpy+0x33>
80103db8:	8d 7b 01             	lea    0x1(%ebx),%edi
80103dbb:	8d 71 01             	lea    0x1(%ecx),%esi
80103dbe:	0f b6 1b             	movzbl (%ebx),%ebx
80103dc1:	88 19                	mov    %bl,(%ecx)
80103dc3:	84 db                	test   %bl,%bl
80103dc5:	75 e6                	jne    80103dad <safestrcpy+0x17>
80103dc7:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103dc9:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103dcc:	5b                   	pop    %ebx
80103dcd:	5e                   	pop    %esi
80103dce:	5f                   	pop    %edi
80103dcf:	5d                   	pop    %ebp
80103dd0:	c3                   	ret    

80103dd1 <strlen>:

int
strlen(const char *s)
{
80103dd1:	55                   	push   %ebp
80103dd2:	89 e5                	mov    %esp,%ebp
80103dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103dd7:	b8 00 00 00 00       	mov    $0x0,%eax
80103ddc:	eb 03                	jmp    80103de1 <strlen+0x10>
80103dde:	83 c0 01             	add    $0x1,%eax
80103de1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103de5:	75 f7                	jne    80103dde <strlen+0xd>
    ;
  return n;
}
80103de7:	5d                   	pop    %ebp
80103de8:	c3                   	ret    

80103de9 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103de9:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103ded:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103df1:	55                   	push   %ebp
  pushl %ebx
80103df2:	53                   	push   %ebx
  pushl %esi
80103df3:	56                   	push   %esi
  pushl %edi
80103df4:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103df5:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103df7:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103df9:	5f                   	pop    %edi
  popl %esi
80103dfa:	5e                   	pop    %esi
  popl %ebx
80103dfb:	5b                   	pop    %ebx
  popl %ebp
80103dfc:	5d                   	pop    %ebp
  ret
80103dfd:	c3                   	ret    

80103dfe <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103dfe:	55                   	push   %ebp
80103dff:	89 e5                	mov    %esp,%ebp
80103e01:	53                   	push   %ebx
80103e02:	83 ec 04             	sub    $0x4,%esp
80103e05:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103e08:	e8 d7 f3 ff ff       	call   801031e4 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103e0d:	8b 00                	mov    (%eax),%eax
80103e0f:	39 d8                	cmp    %ebx,%eax
80103e11:	76 19                	jbe    80103e2c <fetchint+0x2e>
80103e13:	8d 53 04             	lea    0x4(%ebx),%edx
80103e16:	39 d0                	cmp    %edx,%eax
80103e18:	72 19                	jb     80103e33 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103e1a:	8b 13                	mov    (%ebx),%edx
80103e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e1f:	89 10                	mov    %edx,(%eax)
  return 0;
80103e21:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e26:	83 c4 04             	add    $0x4,%esp
80103e29:	5b                   	pop    %ebx
80103e2a:	5d                   	pop    %ebp
80103e2b:	c3                   	ret    
    return -1;
80103e2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e31:	eb f3                	jmp    80103e26 <fetchint+0x28>
80103e33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e38:	eb ec                	jmp    80103e26 <fetchint+0x28>

80103e3a <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103e3a:	55                   	push   %ebp
80103e3b:	89 e5                	mov    %esp,%ebp
80103e3d:	53                   	push   %ebx
80103e3e:	83 ec 04             	sub    $0x4,%esp
80103e41:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103e44:	e8 9b f3 ff ff       	call   801031e4 <myproc>

  if(addr >= curproc->sz)
80103e49:	39 18                	cmp    %ebx,(%eax)
80103e4b:	76 26                	jbe    80103e73 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80103e4d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e50:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103e52:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80103e54:	89 d8                	mov    %ebx,%eax
80103e56:	39 d0                	cmp    %edx,%eax
80103e58:	73 0e                	jae    80103e68 <fetchstr+0x2e>
    if(*s == 0)
80103e5a:	80 38 00             	cmpb   $0x0,(%eax)
80103e5d:	74 05                	je     80103e64 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80103e5f:	83 c0 01             	add    $0x1,%eax
80103e62:	eb f2                	jmp    80103e56 <fetchstr+0x1c>
      return s - *pp;
80103e64:	29 d8                	sub    %ebx,%eax
80103e66:	eb 05                	jmp    80103e6d <fetchstr+0x33>
  }
  return -1;
80103e68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103e6d:	83 c4 04             	add    $0x4,%esp
80103e70:	5b                   	pop    %ebx
80103e71:	5d                   	pop    %ebp
80103e72:	c3                   	ret    
    return -1;
80103e73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e78:	eb f3                	jmp    80103e6d <fetchstr+0x33>

80103e7a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80103e7a:	55                   	push   %ebp
80103e7b:	89 e5                	mov    %esp,%ebp
80103e7d:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103e80:	e8 5f f3 ff ff       	call   801031e4 <myproc>
80103e85:	8b 50 18             	mov    0x18(%eax),%edx
80103e88:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8b:	c1 e0 02             	shl    $0x2,%eax
80103e8e:	03 42 44             	add    0x44(%edx),%eax
80103e91:	83 ec 08             	sub    $0x8,%esp
80103e94:	ff 75 0c             	pushl  0xc(%ebp)
80103e97:	83 c0 04             	add    $0x4,%eax
80103e9a:	50                   	push   %eax
80103e9b:	e8 5e ff ff ff       	call   80103dfe <fetchint>
}
80103ea0:	c9                   	leave  
80103ea1:	c3                   	ret    

80103ea2 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80103ea2:	55                   	push   %ebp
80103ea3:	89 e5                	mov    %esp,%ebp
80103ea5:	56                   	push   %esi
80103ea6:	53                   	push   %ebx
80103ea7:	83 ec 10             	sub    $0x10,%esp
80103eaa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103ead:	e8 32 f3 ff ff       	call   801031e4 <myproc>
80103eb2:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80103eb4:	83 ec 08             	sub    $0x8,%esp
80103eb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103eba:	50                   	push   %eax
80103ebb:	ff 75 08             	pushl  0x8(%ebp)
80103ebe:	e8 b7 ff ff ff       	call   80103e7a <argint>
80103ec3:	83 c4 10             	add    $0x10,%esp
80103ec6:	85 c0                	test   %eax,%eax
80103ec8:	78 24                	js     80103eee <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80103eca:	85 db                	test   %ebx,%ebx
80103ecc:	78 27                	js     80103ef5 <argptr+0x53>
80103ece:	8b 16                	mov    (%esi),%edx
80103ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ed3:	39 c2                	cmp    %eax,%edx
80103ed5:	76 25                	jbe    80103efc <argptr+0x5a>
80103ed7:	01 c3                	add    %eax,%ebx
80103ed9:	39 da                	cmp    %ebx,%edx
80103edb:	72 26                	jb     80103f03 <argptr+0x61>
    return -1;
  *pp = (char*)i;
80103edd:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ee0:	89 02                	mov    %eax,(%edx)
  return 0;
80103ee2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ee7:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103eea:	5b                   	pop    %ebx
80103eeb:	5e                   	pop    %esi
80103eec:	5d                   	pop    %ebp
80103eed:	c3                   	ret    
    return -1;
80103eee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ef3:	eb f2                	jmp    80103ee7 <argptr+0x45>
    return -1;
80103ef5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103efa:	eb eb                	jmp    80103ee7 <argptr+0x45>
80103efc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f01:	eb e4                	jmp    80103ee7 <argptr+0x45>
80103f03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f08:	eb dd                	jmp    80103ee7 <argptr+0x45>

80103f0a <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80103f0a:	55                   	push   %ebp
80103f0b:	89 e5                	mov    %esp,%ebp
80103f0d:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80103f10:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103f13:	50                   	push   %eax
80103f14:	ff 75 08             	pushl  0x8(%ebp)
80103f17:	e8 5e ff ff ff       	call   80103e7a <argint>
80103f1c:	83 c4 10             	add    $0x10,%esp
80103f1f:	85 c0                	test   %eax,%eax
80103f21:	78 13                	js     80103f36 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80103f23:	83 ec 08             	sub    $0x8,%esp
80103f26:	ff 75 0c             	pushl  0xc(%ebp)
80103f29:	ff 75 f4             	pushl  -0xc(%ebp)
80103f2c:	e8 09 ff ff ff       	call   80103e3a <fetchstr>
80103f31:	83 c4 10             	add    $0x10,%esp
}
80103f34:	c9                   	leave  
80103f35:	c3                   	ret    
    return -1;
80103f36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f3b:	eb f7                	jmp    80103f34 <argstr+0x2a>

80103f3d <syscall>:

};

void
syscall(void)
{
80103f3d:	55                   	push   %ebp
80103f3e:	89 e5                	mov    %esp,%ebp
80103f40:	53                   	push   %ebx
80103f41:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80103f44:	e8 9b f2 ff ff       	call   801031e4 <myproc>
80103f49:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80103f4b:	8b 40 18             	mov    0x18(%eax),%eax
80103f4e:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80103f51:	8d 50 ff             	lea    -0x1(%eax),%edx
80103f54:	83 fa 17             	cmp    $0x17,%edx
80103f57:	77 18                	ja     80103f71 <syscall+0x34>
80103f59:	8b 14 85 00 6c 10 80 	mov    -0x7fef9400(,%eax,4),%edx
80103f60:	85 d2                	test   %edx,%edx
80103f62:	74 0d                	je     80103f71 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80103f64:	ff d2                	call   *%edx
80103f66:	8b 53 18             	mov    0x18(%ebx),%edx
80103f69:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80103f6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103f6f:	c9                   	leave  
80103f70:	c3                   	ret    
            curproc->pid, curproc->name, num);
80103f71:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80103f74:	50                   	push   %eax
80103f75:	52                   	push   %edx
80103f76:	ff 73 10             	pushl  0x10(%ebx)
80103f79:	68 d1 6b 10 80       	push   $0x80106bd1
80103f7e:	e8 88 c6 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80103f83:	8b 43 18             	mov    0x18(%ebx),%eax
80103f86:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80103f8d:	83 c4 10             	add    $0x10,%esp
}
80103f90:	eb da                	jmp    80103f6c <syscall+0x2f>

80103f92 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80103f92:	55                   	push   %ebp
80103f93:	89 e5                	mov    %esp,%ebp
80103f95:	56                   	push   %esi
80103f96:	53                   	push   %ebx
80103f97:	83 ec 18             	sub    $0x18,%esp
80103f9a:	89 d6                	mov    %edx,%esi
80103f9c:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80103f9e:	8d 55 f4             	lea    -0xc(%ebp),%edx
80103fa1:	52                   	push   %edx
80103fa2:	50                   	push   %eax
80103fa3:	e8 d2 fe ff ff       	call   80103e7a <argint>
80103fa8:	83 c4 10             	add    $0x10,%esp
80103fab:	85 c0                	test   %eax,%eax
80103fad:	78 2e                	js     80103fdd <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80103faf:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80103fb3:	77 2f                	ja     80103fe4 <argfd+0x52>
80103fb5:	e8 2a f2 ff ff       	call   801031e4 <myproc>
80103fba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fbd:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80103fc1:	85 c0                	test   %eax,%eax
80103fc3:	74 26                	je     80103feb <argfd+0x59>
    return -1;
  if(pfd)
80103fc5:	85 f6                	test   %esi,%esi
80103fc7:	74 02                	je     80103fcb <argfd+0x39>
    *pfd = fd;
80103fc9:	89 16                	mov    %edx,(%esi)
  if(pf)
80103fcb:	85 db                	test   %ebx,%ebx
80103fcd:	74 23                	je     80103ff2 <argfd+0x60>
    *pf = f;
80103fcf:	89 03                	mov    %eax,(%ebx)
  return 0;
80103fd1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103fd6:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103fd9:	5b                   	pop    %ebx
80103fda:	5e                   	pop    %esi
80103fdb:	5d                   	pop    %ebp
80103fdc:	c3                   	ret    
    return -1;
80103fdd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fe2:	eb f2                	jmp    80103fd6 <argfd+0x44>
    return -1;
80103fe4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fe9:	eb eb                	jmp    80103fd6 <argfd+0x44>
80103feb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ff0:	eb e4                	jmp    80103fd6 <argfd+0x44>
  return 0;
80103ff2:	b8 00 00 00 00       	mov    $0x0,%eax
80103ff7:	eb dd                	jmp    80103fd6 <argfd+0x44>

80103ff9 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80103ff9:	55                   	push   %ebp
80103ffa:	89 e5                	mov    %esp,%ebp
80103ffc:	53                   	push   %ebx
80103ffd:	83 ec 04             	sub    $0x4,%esp
80104000:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
80104002:	e8 dd f1 ff ff       	call   801031e4 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
80104007:	ba 00 00 00 00       	mov    $0x0,%edx
8010400c:	83 fa 0f             	cmp    $0xf,%edx
8010400f:	7f 18                	jg     80104029 <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
80104011:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
80104016:	74 05                	je     8010401d <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
80104018:	83 c2 01             	add    $0x1,%edx
8010401b:	eb ef                	jmp    8010400c <fdalloc+0x13>
      curproc->ofile[fd] = f;
8010401d:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
80104021:	89 d0                	mov    %edx,%eax
80104023:	83 c4 04             	add    $0x4,%esp
80104026:	5b                   	pop    %ebx
80104027:	5d                   	pop    %ebp
80104028:	c3                   	ret    
  return -1;
80104029:	ba ff ff ff ff       	mov    $0xffffffff,%edx
8010402e:	eb f1                	jmp    80104021 <fdalloc+0x28>

80104030 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80104030:	55                   	push   %ebp
80104031:	89 e5                	mov    %esp,%ebp
80104033:	56                   	push   %esi
80104034:	53                   	push   %ebx
80104035:	83 ec 10             	sub    $0x10,%esp
80104038:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010403a:	b8 20 00 00 00       	mov    $0x20,%eax
8010403f:	89 c6                	mov    %eax,%esi
80104041:	39 43 58             	cmp    %eax,0x58(%ebx)
80104044:	76 2e                	jbe    80104074 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104046:	6a 10                	push   $0x10
80104048:	50                   	push   %eax
80104049:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010404c:	50                   	push   %eax
8010404d:	53                   	push   %ebx
8010404e:	e8 0e d7 ff ff       	call   80101761 <readi>
80104053:	83 c4 10             	add    $0x10,%esp
80104056:	83 f8 10             	cmp    $0x10,%eax
80104059:	75 0c                	jne    80104067 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
8010405b:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80104060:	75 1e                	jne    80104080 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104062:	8d 46 10             	lea    0x10(%esi),%eax
80104065:	eb d8                	jmp    8010403f <isdirempty+0xf>
      panic("isdirempty: readi");
80104067:	83 ec 0c             	sub    $0xc,%esp
8010406a:	68 64 6c 10 80       	push   $0x80106c64
8010406f:	e8 d4 c2 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104074:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104079:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010407c:	5b                   	pop    %ebx
8010407d:	5e                   	pop    %esi
8010407e:	5d                   	pop    %ebp
8010407f:	c3                   	ret    
      return 0;
80104080:	b8 00 00 00 00       	mov    $0x0,%eax
80104085:	eb f2                	jmp    80104079 <isdirempty+0x49>

80104087 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104087:	55                   	push   %ebp
80104088:	89 e5                	mov    %esp,%ebp
8010408a:	57                   	push   %edi
8010408b:	56                   	push   %esi
8010408c:	53                   	push   %ebx
8010408d:	83 ec 34             	sub    $0x34,%esp
80104090:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80104093:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104096:	8b 7d 08             	mov    0x8(%ebp),%edi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104099:	8d 55 da             	lea    -0x26(%ebp),%edx
8010409c:	52                   	push   %edx
8010409d:	50                   	push   %eax
8010409e:	e8 44 db ff ff       	call   80101be7 <nameiparent>
801040a3:	89 c6                	mov    %eax,%esi
801040a5:	83 c4 10             	add    $0x10,%esp
801040a8:	85 c0                	test   %eax,%eax
801040aa:	0f 84 38 01 00 00    	je     801041e8 <create+0x161>
    return 0;
  ilock(dp);
801040b0:	83 ec 0c             	sub    $0xc,%esp
801040b3:	50                   	push   %eax
801040b4:	e8 b6 d4 ff ff       	call   8010156f <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
801040b9:	83 c4 0c             	add    $0xc,%esp
801040bc:	6a 00                	push   $0x0
801040be:	8d 45 da             	lea    -0x26(%ebp),%eax
801040c1:	50                   	push   %eax
801040c2:	56                   	push   %esi
801040c3:	e8 d6 d8 ff ff       	call   8010199e <dirlookup>
801040c8:	89 c3                	mov    %eax,%ebx
801040ca:	83 c4 10             	add    $0x10,%esp
801040cd:	85 c0                	test   %eax,%eax
801040cf:	74 3f                	je     80104110 <create+0x89>
    iunlockput(dp);
801040d1:	83 ec 0c             	sub    $0xc,%esp
801040d4:	56                   	push   %esi
801040d5:	e8 3c d6 ff ff       	call   80101716 <iunlockput>
    ilock(ip);
801040da:	89 1c 24             	mov    %ebx,(%esp)
801040dd:	e8 8d d4 ff ff       	call   8010156f <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801040e2:	83 c4 10             	add    $0x10,%esp
801040e5:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801040ea:	75 11                	jne    801040fd <create+0x76>
801040ec:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801040f1:	75 0a                	jne    801040fd <create+0x76>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801040f3:	89 d8                	mov    %ebx,%eax
801040f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801040f8:	5b                   	pop    %ebx
801040f9:	5e                   	pop    %esi
801040fa:	5f                   	pop    %edi
801040fb:	5d                   	pop    %ebp
801040fc:	c3                   	ret    
    iunlockput(ip);
801040fd:	83 ec 0c             	sub    $0xc,%esp
80104100:	53                   	push   %ebx
80104101:	e8 10 d6 ff ff       	call   80101716 <iunlockput>
    return 0;
80104106:	83 c4 10             	add    $0x10,%esp
80104109:	bb 00 00 00 00       	mov    $0x0,%ebx
8010410e:	eb e3                	jmp    801040f3 <create+0x6c>
  if((ip = ialloc(dp->dev, type)) == 0)
80104110:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80104114:	83 ec 08             	sub    $0x8,%esp
80104117:	50                   	push   %eax
80104118:	ff 36                	pushl  (%esi)
8010411a:	e8 4d d2 ff ff       	call   8010136c <ialloc>
8010411f:	89 c3                	mov    %eax,%ebx
80104121:	83 c4 10             	add    $0x10,%esp
80104124:	85 c0                	test   %eax,%eax
80104126:	74 55                	je     8010417d <create+0xf6>
  ilock(ip);
80104128:	83 ec 0c             	sub    $0xc,%esp
8010412b:	50                   	push   %eax
8010412c:	e8 3e d4 ff ff       	call   8010156f <ilock>
  ip->major = major;
80104131:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80104135:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104139:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
8010413d:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104143:	89 1c 24             	mov    %ebx,(%esp)
80104146:	e8 c3 d2 ff ff       	call   8010140e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
8010414b:	83 c4 10             	add    $0x10,%esp
8010414e:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80104153:	74 35                	je     8010418a <create+0x103>
  if(dirlink(dp, name, ip->inum) < 0)
80104155:	83 ec 04             	sub    $0x4,%esp
80104158:	ff 73 04             	pushl  0x4(%ebx)
8010415b:	8d 45 da             	lea    -0x26(%ebp),%eax
8010415e:	50                   	push   %eax
8010415f:	56                   	push   %esi
80104160:	e8 b9 d9 ff ff       	call   80101b1e <dirlink>
80104165:	83 c4 10             	add    $0x10,%esp
80104168:	85 c0                	test   %eax,%eax
8010416a:	78 6f                	js     801041db <create+0x154>
  iunlockput(dp);
8010416c:	83 ec 0c             	sub    $0xc,%esp
8010416f:	56                   	push   %esi
80104170:	e8 a1 d5 ff ff       	call   80101716 <iunlockput>
  return ip;
80104175:	83 c4 10             	add    $0x10,%esp
80104178:	e9 76 ff ff ff       	jmp    801040f3 <create+0x6c>
    panic("create: ialloc");
8010417d:	83 ec 0c             	sub    $0xc,%esp
80104180:	68 76 6c 10 80       	push   $0x80106c76
80104185:	e8 be c1 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
8010418a:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010418e:	83 c0 01             	add    $0x1,%eax
80104191:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104195:	83 ec 0c             	sub    $0xc,%esp
80104198:	56                   	push   %esi
80104199:	e8 70 d2 ff ff       	call   8010140e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010419e:	83 c4 0c             	add    $0xc,%esp
801041a1:	ff 73 04             	pushl  0x4(%ebx)
801041a4:	68 86 6c 10 80       	push   $0x80106c86
801041a9:	53                   	push   %ebx
801041aa:	e8 6f d9 ff ff       	call   80101b1e <dirlink>
801041af:	83 c4 10             	add    $0x10,%esp
801041b2:	85 c0                	test   %eax,%eax
801041b4:	78 18                	js     801041ce <create+0x147>
801041b6:	83 ec 04             	sub    $0x4,%esp
801041b9:	ff 76 04             	pushl  0x4(%esi)
801041bc:	68 85 6c 10 80       	push   $0x80106c85
801041c1:	53                   	push   %ebx
801041c2:	e8 57 d9 ff ff       	call   80101b1e <dirlink>
801041c7:	83 c4 10             	add    $0x10,%esp
801041ca:	85 c0                	test   %eax,%eax
801041cc:	79 87                	jns    80104155 <create+0xce>
      panic("create dots");
801041ce:	83 ec 0c             	sub    $0xc,%esp
801041d1:	68 88 6c 10 80       	push   $0x80106c88
801041d6:	e8 6d c1 ff ff       	call   80100348 <panic>
    panic("create: dirlink");
801041db:	83 ec 0c             	sub    $0xc,%esp
801041de:	68 94 6c 10 80       	push   $0x80106c94
801041e3:	e8 60 c1 ff ff       	call   80100348 <panic>
    return 0;
801041e8:	89 c3                	mov    %eax,%ebx
801041ea:	e9 04 ff ff ff       	jmp    801040f3 <create+0x6c>

801041ef <sys_dup>:
{
801041ef:	55                   	push   %ebp
801041f0:	89 e5                	mov    %esp,%ebp
801041f2:	53                   	push   %ebx
801041f3:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801041f6:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801041f9:	ba 00 00 00 00       	mov    $0x0,%edx
801041fe:	b8 00 00 00 00       	mov    $0x0,%eax
80104203:	e8 8a fd ff ff       	call   80103f92 <argfd>
80104208:	85 c0                	test   %eax,%eax
8010420a:	78 23                	js     8010422f <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
8010420c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010420f:	e8 e5 fd ff ff       	call   80103ff9 <fdalloc>
80104214:	89 c3                	mov    %eax,%ebx
80104216:	85 c0                	test   %eax,%eax
80104218:	78 1c                	js     80104236 <sys_dup+0x47>
  filedup(f);
8010421a:	83 ec 0c             	sub    $0xc,%esp
8010421d:	ff 75 f4             	pushl  -0xc(%ebp)
80104220:	e8 69 ca ff ff       	call   80100c8e <filedup>
  return fd;
80104225:	83 c4 10             	add    $0x10,%esp
}
80104228:	89 d8                	mov    %ebx,%eax
8010422a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010422d:	c9                   	leave  
8010422e:	c3                   	ret    
    return -1;
8010422f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104234:	eb f2                	jmp    80104228 <sys_dup+0x39>
    return -1;
80104236:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010423b:	eb eb                	jmp    80104228 <sys_dup+0x39>

8010423d <sys_read>:
{
8010423d:	55                   	push   %ebp
8010423e:	89 e5                	mov    %esp,%ebp
80104240:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104243:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104246:	ba 00 00 00 00       	mov    $0x0,%edx
8010424b:	b8 00 00 00 00       	mov    $0x0,%eax
80104250:	e8 3d fd ff ff       	call   80103f92 <argfd>
80104255:	85 c0                	test   %eax,%eax
80104257:	78 43                	js     8010429c <sys_read+0x5f>
80104259:	83 ec 08             	sub    $0x8,%esp
8010425c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010425f:	50                   	push   %eax
80104260:	6a 02                	push   $0x2
80104262:	e8 13 fc ff ff       	call   80103e7a <argint>
80104267:	83 c4 10             	add    $0x10,%esp
8010426a:	85 c0                	test   %eax,%eax
8010426c:	78 35                	js     801042a3 <sys_read+0x66>
8010426e:	83 ec 04             	sub    $0x4,%esp
80104271:	ff 75 f0             	pushl  -0x10(%ebp)
80104274:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104277:	50                   	push   %eax
80104278:	6a 01                	push   $0x1
8010427a:	e8 23 fc ff ff       	call   80103ea2 <argptr>
8010427f:	83 c4 10             	add    $0x10,%esp
80104282:	85 c0                	test   %eax,%eax
80104284:	78 24                	js     801042aa <sys_read+0x6d>
  return fileread(f, p, n);
80104286:	83 ec 04             	sub    $0x4,%esp
80104289:	ff 75 f0             	pushl  -0x10(%ebp)
8010428c:	ff 75 ec             	pushl  -0x14(%ebp)
8010428f:	ff 75 f4             	pushl  -0xc(%ebp)
80104292:	e8 40 cb ff ff       	call   80100dd7 <fileread>
80104297:	83 c4 10             	add    $0x10,%esp
}
8010429a:	c9                   	leave  
8010429b:	c3                   	ret    
    return -1;
8010429c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042a1:	eb f7                	jmp    8010429a <sys_read+0x5d>
801042a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042a8:	eb f0                	jmp    8010429a <sys_read+0x5d>
801042aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042af:	eb e9                	jmp    8010429a <sys_read+0x5d>

801042b1 <sys_write>:
{
801042b1:	55                   	push   %ebp
801042b2:	89 e5                	mov    %esp,%ebp
801042b4:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801042b7:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801042ba:	ba 00 00 00 00       	mov    $0x0,%edx
801042bf:	b8 00 00 00 00       	mov    $0x0,%eax
801042c4:	e8 c9 fc ff ff       	call   80103f92 <argfd>
801042c9:	85 c0                	test   %eax,%eax
801042cb:	78 43                	js     80104310 <sys_write+0x5f>
801042cd:	83 ec 08             	sub    $0x8,%esp
801042d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801042d3:	50                   	push   %eax
801042d4:	6a 02                	push   $0x2
801042d6:	e8 9f fb ff ff       	call   80103e7a <argint>
801042db:	83 c4 10             	add    $0x10,%esp
801042de:	85 c0                	test   %eax,%eax
801042e0:	78 35                	js     80104317 <sys_write+0x66>
801042e2:	83 ec 04             	sub    $0x4,%esp
801042e5:	ff 75 f0             	pushl  -0x10(%ebp)
801042e8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801042eb:	50                   	push   %eax
801042ec:	6a 01                	push   $0x1
801042ee:	e8 af fb ff ff       	call   80103ea2 <argptr>
801042f3:	83 c4 10             	add    $0x10,%esp
801042f6:	85 c0                	test   %eax,%eax
801042f8:	78 24                	js     8010431e <sys_write+0x6d>
  return filewrite(f, p, n);
801042fa:	83 ec 04             	sub    $0x4,%esp
801042fd:	ff 75 f0             	pushl  -0x10(%ebp)
80104300:	ff 75 ec             	pushl  -0x14(%ebp)
80104303:	ff 75 f4             	pushl  -0xc(%ebp)
80104306:	e8 51 cb ff ff       	call   80100e5c <filewrite>
8010430b:	83 c4 10             	add    $0x10,%esp
}
8010430e:	c9                   	leave  
8010430f:	c3                   	ret    
    return -1;
80104310:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104315:	eb f7                	jmp    8010430e <sys_write+0x5d>
80104317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010431c:	eb f0                	jmp    8010430e <sys_write+0x5d>
8010431e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104323:	eb e9                	jmp    8010430e <sys_write+0x5d>

80104325 <sys_close>:
{
80104325:	55                   	push   %ebp
80104326:	89 e5                	mov    %esp,%ebp
80104328:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
8010432b:	8d 4d f0             	lea    -0x10(%ebp),%ecx
8010432e:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104331:	b8 00 00 00 00       	mov    $0x0,%eax
80104336:	e8 57 fc ff ff       	call   80103f92 <argfd>
8010433b:	85 c0                	test   %eax,%eax
8010433d:	78 25                	js     80104364 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
8010433f:	e8 a0 ee ff ff       	call   801031e4 <myproc>
80104344:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104347:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
8010434e:	00 
  fileclose(f);
8010434f:	83 ec 0c             	sub    $0xc,%esp
80104352:	ff 75 f0             	pushl  -0x10(%ebp)
80104355:	e8 79 c9 ff ff       	call   80100cd3 <fileclose>
  return 0;
8010435a:	83 c4 10             	add    $0x10,%esp
8010435d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104362:	c9                   	leave  
80104363:	c3                   	ret    
    return -1;
80104364:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104369:	eb f7                	jmp    80104362 <sys_close+0x3d>

8010436b <sys_fstat>:
{
8010436b:	55                   	push   %ebp
8010436c:	89 e5                	mov    %esp,%ebp
8010436e:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104371:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104374:	ba 00 00 00 00       	mov    $0x0,%edx
80104379:	b8 00 00 00 00       	mov    $0x0,%eax
8010437e:	e8 0f fc ff ff       	call   80103f92 <argfd>
80104383:	85 c0                	test   %eax,%eax
80104385:	78 2a                	js     801043b1 <sys_fstat+0x46>
80104387:	83 ec 04             	sub    $0x4,%esp
8010438a:	6a 14                	push   $0x14
8010438c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010438f:	50                   	push   %eax
80104390:	6a 01                	push   $0x1
80104392:	e8 0b fb ff ff       	call   80103ea2 <argptr>
80104397:	83 c4 10             	add    $0x10,%esp
8010439a:	85 c0                	test   %eax,%eax
8010439c:	78 1a                	js     801043b8 <sys_fstat+0x4d>
  return filestat(f, st);
8010439e:	83 ec 08             	sub    $0x8,%esp
801043a1:	ff 75 f0             	pushl  -0x10(%ebp)
801043a4:	ff 75 f4             	pushl  -0xc(%ebp)
801043a7:	e8 e4 c9 ff ff       	call   80100d90 <filestat>
801043ac:	83 c4 10             	add    $0x10,%esp
}
801043af:	c9                   	leave  
801043b0:	c3                   	ret    
    return -1;
801043b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043b6:	eb f7                	jmp    801043af <sys_fstat+0x44>
801043b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043bd:	eb f0                	jmp    801043af <sys_fstat+0x44>

801043bf <sys_link>:
{
801043bf:	55                   	push   %ebp
801043c0:	89 e5                	mov    %esp,%ebp
801043c2:	56                   	push   %esi
801043c3:	53                   	push   %ebx
801043c4:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801043c7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801043ca:	50                   	push   %eax
801043cb:	6a 00                	push   $0x0
801043cd:	e8 38 fb ff ff       	call   80103f0a <argstr>
801043d2:	83 c4 10             	add    $0x10,%esp
801043d5:	85 c0                	test   %eax,%eax
801043d7:	0f 88 32 01 00 00    	js     8010450f <sys_link+0x150>
801043dd:	83 ec 08             	sub    $0x8,%esp
801043e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801043e3:	50                   	push   %eax
801043e4:	6a 01                	push   $0x1
801043e6:	e8 1f fb ff ff       	call   80103f0a <argstr>
801043eb:	83 c4 10             	add    $0x10,%esp
801043ee:	85 c0                	test   %eax,%eax
801043f0:	0f 88 20 01 00 00    	js     80104516 <sys_link+0x157>
  begin_op();
801043f6:	e8 a1 e3 ff ff       	call   8010279c <begin_op>
  if((ip = namei(old)) == 0){
801043fb:	83 ec 0c             	sub    $0xc,%esp
801043fe:	ff 75 e0             	pushl  -0x20(%ebp)
80104401:	e8 c9 d7 ff ff       	call   80101bcf <namei>
80104406:	89 c3                	mov    %eax,%ebx
80104408:	83 c4 10             	add    $0x10,%esp
8010440b:	85 c0                	test   %eax,%eax
8010440d:	0f 84 99 00 00 00    	je     801044ac <sys_link+0xed>
  ilock(ip);
80104413:	83 ec 0c             	sub    $0xc,%esp
80104416:	50                   	push   %eax
80104417:	e8 53 d1 ff ff       	call   8010156f <ilock>
  if(ip->type == T_DIR){
8010441c:	83 c4 10             	add    $0x10,%esp
8010441f:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104424:	0f 84 8e 00 00 00    	je     801044b8 <sys_link+0xf9>
  ip->nlink++;
8010442a:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010442e:	83 c0 01             	add    $0x1,%eax
80104431:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104435:	83 ec 0c             	sub    $0xc,%esp
80104438:	53                   	push   %ebx
80104439:	e8 d0 cf ff ff       	call   8010140e <iupdate>
  iunlock(ip);
8010443e:	89 1c 24             	mov    %ebx,(%esp)
80104441:	e8 eb d1 ff ff       	call   80101631 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104446:	83 c4 08             	add    $0x8,%esp
80104449:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010444c:	50                   	push   %eax
8010444d:	ff 75 e4             	pushl  -0x1c(%ebp)
80104450:	e8 92 d7 ff ff       	call   80101be7 <nameiparent>
80104455:	89 c6                	mov    %eax,%esi
80104457:	83 c4 10             	add    $0x10,%esp
8010445a:	85 c0                	test   %eax,%eax
8010445c:	74 7e                	je     801044dc <sys_link+0x11d>
  ilock(dp);
8010445e:	83 ec 0c             	sub    $0xc,%esp
80104461:	50                   	push   %eax
80104462:	e8 08 d1 ff ff       	call   8010156f <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104467:	83 c4 10             	add    $0x10,%esp
8010446a:	8b 03                	mov    (%ebx),%eax
8010446c:	39 06                	cmp    %eax,(%esi)
8010446e:	75 60                	jne    801044d0 <sys_link+0x111>
80104470:	83 ec 04             	sub    $0x4,%esp
80104473:	ff 73 04             	pushl  0x4(%ebx)
80104476:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104479:	50                   	push   %eax
8010447a:	56                   	push   %esi
8010447b:	e8 9e d6 ff ff       	call   80101b1e <dirlink>
80104480:	83 c4 10             	add    $0x10,%esp
80104483:	85 c0                	test   %eax,%eax
80104485:	78 49                	js     801044d0 <sys_link+0x111>
  iunlockput(dp);
80104487:	83 ec 0c             	sub    $0xc,%esp
8010448a:	56                   	push   %esi
8010448b:	e8 86 d2 ff ff       	call   80101716 <iunlockput>
  iput(ip);
80104490:	89 1c 24             	mov    %ebx,(%esp)
80104493:	e8 de d1 ff ff       	call   80101676 <iput>
  end_op();
80104498:	e8 79 e3 ff ff       	call   80102816 <end_op>
  return 0;
8010449d:	83 c4 10             	add    $0x10,%esp
801044a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801044a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
801044a8:	5b                   	pop    %ebx
801044a9:	5e                   	pop    %esi
801044aa:	5d                   	pop    %ebp
801044ab:	c3                   	ret    
    end_op();
801044ac:	e8 65 e3 ff ff       	call   80102816 <end_op>
    return -1;
801044b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044b6:	eb ed                	jmp    801044a5 <sys_link+0xe6>
    iunlockput(ip);
801044b8:	83 ec 0c             	sub    $0xc,%esp
801044bb:	53                   	push   %ebx
801044bc:	e8 55 d2 ff ff       	call   80101716 <iunlockput>
    end_op();
801044c1:	e8 50 e3 ff ff       	call   80102816 <end_op>
    return -1;
801044c6:	83 c4 10             	add    $0x10,%esp
801044c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044ce:	eb d5                	jmp    801044a5 <sys_link+0xe6>
    iunlockput(dp);
801044d0:	83 ec 0c             	sub    $0xc,%esp
801044d3:	56                   	push   %esi
801044d4:	e8 3d d2 ff ff       	call   80101716 <iunlockput>
    goto bad;
801044d9:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801044dc:	83 ec 0c             	sub    $0xc,%esp
801044df:	53                   	push   %ebx
801044e0:	e8 8a d0 ff ff       	call   8010156f <ilock>
  ip->nlink--;
801044e5:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801044e9:	83 e8 01             	sub    $0x1,%eax
801044ec:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801044f0:	89 1c 24             	mov    %ebx,(%esp)
801044f3:	e8 16 cf ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
801044f8:	89 1c 24             	mov    %ebx,(%esp)
801044fb:	e8 16 d2 ff ff       	call   80101716 <iunlockput>
  end_op();
80104500:	e8 11 e3 ff ff       	call   80102816 <end_op>
  return -1;
80104505:	83 c4 10             	add    $0x10,%esp
80104508:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010450d:	eb 96                	jmp    801044a5 <sys_link+0xe6>
    return -1;
8010450f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104514:	eb 8f                	jmp    801044a5 <sys_link+0xe6>
80104516:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010451b:	eb 88                	jmp    801044a5 <sys_link+0xe6>

8010451d <sys_unlink>:
{
8010451d:	55                   	push   %ebp
8010451e:	89 e5                	mov    %esp,%ebp
80104520:	57                   	push   %edi
80104521:	56                   	push   %esi
80104522:	53                   	push   %ebx
80104523:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104526:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104529:	50                   	push   %eax
8010452a:	6a 00                	push   $0x0
8010452c:	e8 d9 f9 ff ff       	call   80103f0a <argstr>
80104531:	83 c4 10             	add    $0x10,%esp
80104534:	85 c0                	test   %eax,%eax
80104536:	0f 88 83 01 00 00    	js     801046bf <sys_unlink+0x1a2>
  begin_op();
8010453c:	e8 5b e2 ff ff       	call   8010279c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104541:	83 ec 08             	sub    $0x8,%esp
80104544:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104547:	50                   	push   %eax
80104548:	ff 75 c4             	pushl  -0x3c(%ebp)
8010454b:	e8 97 d6 ff ff       	call   80101be7 <nameiparent>
80104550:	89 c6                	mov    %eax,%esi
80104552:	83 c4 10             	add    $0x10,%esp
80104555:	85 c0                	test   %eax,%eax
80104557:	0f 84 ed 00 00 00    	je     8010464a <sys_unlink+0x12d>
  ilock(dp);
8010455d:	83 ec 0c             	sub    $0xc,%esp
80104560:	50                   	push   %eax
80104561:	e8 09 d0 ff ff       	call   8010156f <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104566:	83 c4 08             	add    $0x8,%esp
80104569:	68 86 6c 10 80       	push   $0x80106c86
8010456e:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104571:	50                   	push   %eax
80104572:	e8 12 d4 ff ff       	call   80101989 <namecmp>
80104577:	83 c4 10             	add    $0x10,%esp
8010457a:	85 c0                	test   %eax,%eax
8010457c:	0f 84 fc 00 00 00    	je     8010467e <sys_unlink+0x161>
80104582:	83 ec 08             	sub    $0x8,%esp
80104585:	68 85 6c 10 80       	push   $0x80106c85
8010458a:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010458d:	50                   	push   %eax
8010458e:	e8 f6 d3 ff ff       	call   80101989 <namecmp>
80104593:	83 c4 10             	add    $0x10,%esp
80104596:	85 c0                	test   %eax,%eax
80104598:	0f 84 e0 00 00 00    	je     8010467e <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010459e:	83 ec 04             	sub    $0x4,%esp
801045a1:	8d 45 c0             	lea    -0x40(%ebp),%eax
801045a4:	50                   	push   %eax
801045a5:	8d 45 ca             	lea    -0x36(%ebp),%eax
801045a8:	50                   	push   %eax
801045a9:	56                   	push   %esi
801045aa:	e8 ef d3 ff ff       	call   8010199e <dirlookup>
801045af:	89 c3                	mov    %eax,%ebx
801045b1:	83 c4 10             	add    $0x10,%esp
801045b4:	85 c0                	test   %eax,%eax
801045b6:	0f 84 c2 00 00 00    	je     8010467e <sys_unlink+0x161>
  ilock(ip);
801045bc:	83 ec 0c             	sub    $0xc,%esp
801045bf:	50                   	push   %eax
801045c0:	e8 aa cf ff ff       	call   8010156f <ilock>
  if(ip->nlink < 1)
801045c5:	83 c4 10             	add    $0x10,%esp
801045c8:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801045cd:	0f 8e 83 00 00 00    	jle    80104656 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
801045d3:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801045d8:	0f 84 85 00 00 00    	je     80104663 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
801045de:	83 ec 04             	sub    $0x4,%esp
801045e1:	6a 10                	push   $0x10
801045e3:	6a 00                	push   $0x0
801045e5:	8d 7d d8             	lea    -0x28(%ebp),%edi
801045e8:	57                   	push   %edi
801045e9:	e8 41 f6 ff ff       	call   80103c2f <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801045ee:	6a 10                	push   $0x10
801045f0:	ff 75 c0             	pushl  -0x40(%ebp)
801045f3:	57                   	push   %edi
801045f4:	56                   	push   %esi
801045f5:	e8 64 d2 ff ff       	call   8010185e <writei>
801045fa:	83 c4 20             	add    $0x20,%esp
801045fd:	83 f8 10             	cmp    $0x10,%eax
80104600:	0f 85 90 00 00 00    	jne    80104696 <sys_unlink+0x179>
  if(ip->type == T_DIR){
80104606:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010460b:	0f 84 92 00 00 00    	je     801046a3 <sys_unlink+0x186>
  iunlockput(dp);
80104611:	83 ec 0c             	sub    $0xc,%esp
80104614:	56                   	push   %esi
80104615:	e8 fc d0 ff ff       	call   80101716 <iunlockput>
  ip->nlink--;
8010461a:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010461e:	83 e8 01             	sub    $0x1,%eax
80104621:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104625:	89 1c 24             	mov    %ebx,(%esp)
80104628:	e8 e1 cd ff ff       	call   8010140e <iupdate>
  iunlockput(ip);
8010462d:	89 1c 24             	mov    %ebx,(%esp)
80104630:	e8 e1 d0 ff ff       	call   80101716 <iunlockput>
  end_op();
80104635:	e8 dc e1 ff ff       	call   80102816 <end_op>
  return 0;
8010463a:	83 c4 10             	add    $0x10,%esp
8010463d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104642:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104645:	5b                   	pop    %ebx
80104646:	5e                   	pop    %esi
80104647:	5f                   	pop    %edi
80104648:	5d                   	pop    %ebp
80104649:	c3                   	ret    
    end_op();
8010464a:	e8 c7 e1 ff ff       	call   80102816 <end_op>
    return -1;
8010464f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104654:	eb ec                	jmp    80104642 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104656:	83 ec 0c             	sub    $0xc,%esp
80104659:	68 a4 6c 10 80       	push   $0x80106ca4
8010465e:	e8 e5 bc ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104663:	89 d8                	mov    %ebx,%eax
80104665:	e8 c6 f9 ff ff       	call   80104030 <isdirempty>
8010466a:	85 c0                	test   %eax,%eax
8010466c:	0f 85 6c ff ff ff    	jne    801045de <sys_unlink+0xc1>
    iunlockput(ip);
80104672:	83 ec 0c             	sub    $0xc,%esp
80104675:	53                   	push   %ebx
80104676:	e8 9b d0 ff ff       	call   80101716 <iunlockput>
    goto bad;
8010467b:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
8010467e:	83 ec 0c             	sub    $0xc,%esp
80104681:	56                   	push   %esi
80104682:	e8 8f d0 ff ff       	call   80101716 <iunlockput>
  end_op();
80104687:	e8 8a e1 ff ff       	call   80102816 <end_op>
  return -1;
8010468c:	83 c4 10             	add    $0x10,%esp
8010468f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104694:	eb ac                	jmp    80104642 <sys_unlink+0x125>
    panic("unlink: writei");
80104696:	83 ec 0c             	sub    $0xc,%esp
80104699:	68 b6 6c 10 80       	push   $0x80106cb6
8010469e:	e8 a5 bc ff ff       	call   80100348 <panic>
    dp->nlink--;
801046a3:	0f b7 46 56          	movzwl 0x56(%esi),%eax
801046a7:	83 e8 01             	sub    $0x1,%eax
801046aa:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
801046ae:	83 ec 0c             	sub    $0xc,%esp
801046b1:	56                   	push   %esi
801046b2:	e8 57 cd ff ff       	call   8010140e <iupdate>
801046b7:	83 c4 10             	add    $0x10,%esp
801046ba:	e9 52 ff ff ff       	jmp    80104611 <sys_unlink+0xf4>
    return -1;
801046bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046c4:	e9 79 ff ff ff       	jmp    80104642 <sys_unlink+0x125>

801046c9 <sys_open>:

int
sys_open(void)
{
801046c9:	55                   	push   %ebp
801046ca:	89 e5                	mov    %esp,%ebp
801046cc:	57                   	push   %edi
801046cd:	56                   	push   %esi
801046ce:	53                   	push   %ebx
801046cf:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801046d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801046d5:	50                   	push   %eax
801046d6:	6a 00                	push   $0x0
801046d8:	e8 2d f8 ff ff       	call   80103f0a <argstr>
801046dd:	83 c4 10             	add    $0x10,%esp
801046e0:	85 c0                	test   %eax,%eax
801046e2:	0f 88 30 01 00 00    	js     80104818 <sys_open+0x14f>
801046e8:	83 ec 08             	sub    $0x8,%esp
801046eb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801046ee:	50                   	push   %eax
801046ef:	6a 01                	push   $0x1
801046f1:	e8 84 f7 ff ff       	call   80103e7a <argint>
801046f6:	83 c4 10             	add    $0x10,%esp
801046f9:	85 c0                	test   %eax,%eax
801046fb:	0f 88 21 01 00 00    	js     80104822 <sys_open+0x159>
    return -1;

  begin_op();
80104701:	e8 96 e0 ff ff       	call   8010279c <begin_op>

  if(omode & O_CREATE){
80104706:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
8010470a:	0f 84 84 00 00 00    	je     80104794 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
80104710:	83 ec 0c             	sub    $0xc,%esp
80104713:	6a 00                	push   $0x0
80104715:	b9 00 00 00 00       	mov    $0x0,%ecx
8010471a:	ba 02 00 00 00       	mov    $0x2,%edx
8010471f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104722:	e8 60 f9 ff ff       	call   80104087 <create>
80104727:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104729:	83 c4 10             	add    $0x10,%esp
8010472c:	85 c0                	test   %eax,%eax
8010472e:	74 58                	je     80104788 <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104730:	e8 f8 c4 ff ff       	call   80100c2d <filealloc>
80104735:	89 c3                	mov    %eax,%ebx
80104737:	85 c0                	test   %eax,%eax
80104739:	0f 84 ae 00 00 00    	je     801047ed <sys_open+0x124>
8010473f:	e8 b5 f8 ff ff       	call   80103ff9 <fdalloc>
80104744:	89 c7                	mov    %eax,%edi
80104746:	85 c0                	test   %eax,%eax
80104748:	0f 88 9f 00 00 00    	js     801047ed <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
8010474e:	83 ec 0c             	sub    $0xc,%esp
80104751:	56                   	push   %esi
80104752:	e8 da ce ff ff       	call   80101631 <iunlock>
  end_op();
80104757:	e8 ba e0 ff ff       	call   80102816 <end_op>

  f->type = FD_INODE;
8010475c:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104762:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104765:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
8010476c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010476f:	83 c4 10             	add    $0x10,%esp
80104772:	a8 01                	test   $0x1,%al
80104774:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104778:	a8 03                	test   $0x3,%al
8010477a:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
8010477e:	89 f8                	mov    %edi,%eax
80104780:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104783:	5b                   	pop    %ebx
80104784:	5e                   	pop    %esi
80104785:	5f                   	pop    %edi
80104786:	5d                   	pop    %ebp
80104787:	c3                   	ret    
      end_op();
80104788:	e8 89 e0 ff ff       	call   80102816 <end_op>
      return -1;
8010478d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104792:	eb ea                	jmp    8010477e <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104794:	83 ec 0c             	sub    $0xc,%esp
80104797:	ff 75 e4             	pushl  -0x1c(%ebp)
8010479a:	e8 30 d4 ff ff       	call   80101bcf <namei>
8010479f:	89 c6                	mov    %eax,%esi
801047a1:	83 c4 10             	add    $0x10,%esp
801047a4:	85 c0                	test   %eax,%eax
801047a6:	74 39                	je     801047e1 <sys_open+0x118>
    ilock(ip);
801047a8:	83 ec 0c             	sub    $0xc,%esp
801047ab:	50                   	push   %eax
801047ac:	e8 be cd ff ff       	call   8010156f <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801047b1:	83 c4 10             	add    $0x10,%esp
801047b4:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801047b9:	0f 85 71 ff ff ff    	jne    80104730 <sys_open+0x67>
801047bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801047c3:	0f 84 67 ff ff ff    	je     80104730 <sys_open+0x67>
      iunlockput(ip);
801047c9:	83 ec 0c             	sub    $0xc,%esp
801047cc:	56                   	push   %esi
801047cd:	e8 44 cf ff ff       	call   80101716 <iunlockput>
      end_op();
801047d2:	e8 3f e0 ff ff       	call   80102816 <end_op>
      return -1;
801047d7:	83 c4 10             	add    $0x10,%esp
801047da:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801047df:	eb 9d                	jmp    8010477e <sys_open+0xb5>
      end_op();
801047e1:	e8 30 e0 ff ff       	call   80102816 <end_op>
      return -1;
801047e6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801047eb:	eb 91                	jmp    8010477e <sys_open+0xb5>
    if(f)
801047ed:	85 db                	test   %ebx,%ebx
801047ef:	74 0c                	je     801047fd <sys_open+0x134>
      fileclose(f);
801047f1:	83 ec 0c             	sub    $0xc,%esp
801047f4:	53                   	push   %ebx
801047f5:	e8 d9 c4 ff ff       	call   80100cd3 <fileclose>
801047fa:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801047fd:	83 ec 0c             	sub    $0xc,%esp
80104800:	56                   	push   %esi
80104801:	e8 10 cf ff ff       	call   80101716 <iunlockput>
    end_op();
80104806:	e8 0b e0 ff ff       	call   80102816 <end_op>
    return -1;
8010480b:	83 c4 10             	add    $0x10,%esp
8010480e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104813:	e9 66 ff ff ff       	jmp    8010477e <sys_open+0xb5>
    return -1;
80104818:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010481d:	e9 5c ff ff ff       	jmp    8010477e <sys_open+0xb5>
80104822:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104827:	e9 52 ff ff ff       	jmp    8010477e <sys_open+0xb5>

8010482c <sys_mkdir>:

int
sys_mkdir(void)
{
8010482c:	55                   	push   %ebp
8010482d:	89 e5                	mov    %esp,%ebp
8010482f:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104832:	e8 65 df ff ff       	call   8010279c <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104837:	83 ec 08             	sub    $0x8,%esp
8010483a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010483d:	50                   	push   %eax
8010483e:	6a 00                	push   $0x0
80104840:	e8 c5 f6 ff ff       	call   80103f0a <argstr>
80104845:	83 c4 10             	add    $0x10,%esp
80104848:	85 c0                	test   %eax,%eax
8010484a:	78 36                	js     80104882 <sys_mkdir+0x56>
8010484c:	83 ec 0c             	sub    $0xc,%esp
8010484f:	6a 00                	push   $0x0
80104851:	b9 00 00 00 00       	mov    $0x0,%ecx
80104856:	ba 01 00 00 00       	mov    $0x1,%edx
8010485b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010485e:	e8 24 f8 ff ff       	call   80104087 <create>
80104863:	83 c4 10             	add    $0x10,%esp
80104866:	85 c0                	test   %eax,%eax
80104868:	74 18                	je     80104882 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010486a:	83 ec 0c             	sub    $0xc,%esp
8010486d:	50                   	push   %eax
8010486e:	e8 a3 ce ff ff       	call   80101716 <iunlockput>
  end_op();
80104873:	e8 9e df ff ff       	call   80102816 <end_op>
  return 0;
80104878:	83 c4 10             	add    $0x10,%esp
8010487b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104880:	c9                   	leave  
80104881:	c3                   	ret    
    end_op();
80104882:	e8 8f df ff ff       	call   80102816 <end_op>
    return -1;
80104887:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010488c:	eb f2                	jmp    80104880 <sys_mkdir+0x54>

8010488e <sys_mknod>:

int
sys_mknod(void)
{
8010488e:	55                   	push   %ebp
8010488f:	89 e5                	mov    %esp,%ebp
80104891:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104894:	e8 03 df ff ff       	call   8010279c <begin_op>
  if((argstr(0, &path)) < 0 ||
80104899:	83 ec 08             	sub    $0x8,%esp
8010489c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010489f:	50                   	push   %eax
801048a0:	6a 00                	push   $0x0
801048a2:	e8 63 f6 ff ff       	call   80103f0a <argstr>
801048a7:	83 c4 10             	add    $0x10,%esp
801048aa:	85 c0                	test   %eax,%eax
801048ac:	78 62                	js     80104910 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
801048ae:	83 ec 08             	sub    $0x8,%esp
801048b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801048b4:	50                   	push   %eax
801048b5:	6a 01                	push   $0x1
801048b7:	e8 be f5 ff ff       	call   80103e7a <argint>
  if((argstr(0, &path)) < 0 ||
801048bc:	83 c4 10             	add    $0x10,%esp
801048bf:	85 c0                	test   %eax,%eax
801048c1:	78 4d                	js     80104910 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
801048c3:	83 ec 08             	sub    $0x8,%esp
801048c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801048c9:	50                   	push   %eax
801048ca:	6a 02                	push   $0x2
801048cc:	e8 a9 f5 ff ff       	call   80103e7a <argint>
     argint(1, &major) < 0 ||
801048d1:	83 c4 10             	add    $0x10,%esp
801048d4:	85 c0                	test   %eax,%eax
801048d6:	78 38                	js     80104910 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
801048d8:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
801048dc:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
801048e0:	83 ec 0c             	sub    $0xc,%esp
801048e3:	50                   	push   %eax
801048e4:	ba 03 00 00 00       	mov    $0x3,%edx
801048e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ec:	e8 96 f7 ff ff       	call   80104087 <create>
801048f1:	83 c4 10             	add    $0x10,%esp
801048f4:	85 c0                	test   %eax,%eax
801048f6:	74 18                	je     80104910 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
801048f8:	83 ec 0c             	sub    $0xc,%esp
801048fb:	50                   	push   %eax
801048fc:	e8 15 ce ff ff       	call   80101716 <iunlockput>
  end_op();
80104901:	e8 10 df ff ff       	call   80102816 <end_op>
  return 0;
80104906:	83 c4 10             	add    $0x10,%esp
80104909:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010490e:	c9                   	leave  
8010490f:	c3                   	ret    
    end_op();
80104910:	e8 01 df ff ff       	call   80102816 <end_op>
    return -1;
80104915:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010491a:	eb f2                	jmp    8010490e <sys_mknod+0x80>

8010491c <sys_chdir>:

int
sys_chdir(void)
{
8010491c:	55                   	push   %ebp
8010491d:	89 e5                	mov    %esp,%ebp
8010491f:	56                   	push   %esi
80104920:	53                   	push   %ebx
80104921:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104924:	e8 bb e8 ff ff       	call   801031e4 <myproc>
80104929:	89 c6                	mov    %eax,%esi
  
  begin_op();
8010492b:	e8 6c de ff ff       	call   8010279c <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104930:	83 ec 08             	sub    $0x8,%esp
80104933:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104936:	50                   	push   %eax
80104937:	6a 00                	push   $0x0
80104939:	e8 cc f5 ff ff       	call   80103f0a <argstr>
8010493e:	83 c4 10             	add    $0x10,%esp
80104941:	85 c0                	test   %eax,%eax
80104943:	78 52                	js     80104997 <sys_chdir+0x7b>
80104945:	83 ec 0c             	sub    $0xc,%esp
80104948:	ff 75 f4             	pushl  -0xc(%ebp)
8010494b:	e8 7f d2 ff ff       	call   80101bcf <namei>
80104950:	89 c3                	mov    %eax,%ebx
80104952:	83 c4 10             	add    $0x10,%esp
80104955:	85 c0                	test   %eax,%eax
80104957:	74 3e                	je     80104997 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104959:	83 ec 0c             	sub    $0xc,%esp
8010495c:	50                   	push   %eax
8010495d:	e8 0d cc ff ff       	call   8010156f <ilock>
  if(ip->type != T_DIR){
80104962:	83 c4 10             	add    $0x10,%esp
80104965:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010496a:	75 37                	jne    801049a3 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
8010496c:	83 ec 0c             	sub    $0xc,%esp
8010496f:	53                   	push   %ebx
80104970:	e8 bc cc ff ff       	call   80101631 <iunlock>
  iput(curproc->cwd);
80104975:	83 c4 04             	add    $0x4,%esp
80104978:	ff 76 68             	pushl  0x68(%esi)
8010497b:	e8 f6 cc ff ff       	call   80101676 <iput>
  end_op();
80104980:	e8 91 de ff ff       	call   80102816 <end_op>
  curproc->cwd = ip;
80104985:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104988:	83 c4 10             	add    $0x10,%esp
8010498b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104990:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104993:	5b                   	pop    %ebx
80104994:	5e                   	pop    %esi
80104995:	5d                   	pop    %ebp
80104996:	c3                   	ret    
    end_op();
80104997:	e8 7a de ff ff       	call   80102816 <end_op>
    return -1;
8010499c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049a1:	eb ed                	jmp    80104990 <sys_chdir+0x74>
    iunlockput(ip);
801049a3:	83 ec 0c             	sub    $0xc,%esp
801049a6:	53                   	push   %ebx
801049a7:	e8 6a cd ff ff       	call   80101716 <iunlockput>
    end_op();
801049ac:	e8 65 de ff ff       	call   80102816 <end_op>
    return -1;
801049b1:	83 c4 10             	add    $0x10,%esp
801049b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049b9:	eb d5                	jmp    80104990 <sys_chdir+0x74>

801049bb <sys_exec>:

int
sys_exec(void)
{
801049bb:	55                   	push   %ebp
801049bc:	89 e5                	mov    %esp,%ebp
801049be:	53                   	push   %ebx
801049bf:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801049c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801049c8:	50                   	push   %eax
801049c9:	6a 00                	push   $0x0
801049cb:	e8 3a f5 ff ff       	call   80103f0a <argstr>
801049d0:	83 c4 10             	add    $0x10,%esp
801049d3:	85 c0                	test   %eax,%eax
801049d5:	0f 88 a8 00 00 00    	js     80104a83 <sys_exec+0xc8>
801049db:	83 ec 08             	sub    $0x8,%esp
801049de:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801049e4:	50                   	push   %eax
801049e5:	6a 01                	push   $0x1
801049e7:	e8 8e f4 ff ff       	call   80103e7a <argint>
801049ec:	83 c4 10             	add    $0x10,%esp
801049ef:	85 c0                	test   %eax,%eax
801049f1:	0f 88 93 00 00 00    	js     80104a8a <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
801049f7:	83 ec 04             	sub    $0x4,%esp
801049fa:	68 80 00 00 00       	push   $0x80
801049ff:	6a 00                	push   $0x0
80104a01:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104a07:	50                   	push   %eax
80104a08:	e8 22 f2 ff ff       	call   80103c2f <memset>
80104a0d:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104a10:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104a15:	83 fb 1f             	cmp    $0x1f,%ebx
80104a18:	77 77                	ja     80104a91 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104a1a:	83 ec 08             	sub    $0x8,%esp
80104a1d:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104a23:	50                   	push   %eax
80104a24:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104a2a:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104a2d:	50                   	push   %eax
80104a2e:	e8 cb f3 ff ff       	call   80103dfe <fetchint>
80104a33:	83 c4 10             	add    $0x10,%esp
80104a36:	85 c0                	test   %eax,%eax
80104a38:	78 5e                	js     80104a98 <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104a3a:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104a40:	85 c0                	test   %eax,%eax
80104a42:	74 1d                	je     80104a61 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104a44:	83 ec 08             	sub    $0x8,%esp
80104a47:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104a4e:	52                   	push   %edx
80104a4f:	50                   	push   %eax
80104a50:	e8 e5 f3 ff ff       	call   80103e3a <fetchstr>
80104a55:	83 c4 10             	add    $0x10,%esp
80104a58:	85 c0                	test   %eax,%eax
80104a5a:	78 46                	js     80104aa2 <sys_exec+0xe7>
  for(i=0;; i++){
80104a5c:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104a5f:	eb b4                	jmp    80104a15 <sys_exec+0x5a>
      argv[i] = 0;
80104a61:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104a68:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104a6c:	83 ec 08             	sub    $0x8,%esp
80104a6f:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104a75:	50                   	push   %eax
80104a76:	ff 75 f4             	pushl  -0xc(%ebp)
80104a79:	e8 54 be ff ff       	call   801008d2 <exec>
80104a7e:	83 c4 10             	add    $0x10,%esp
80104a81:	eb 1a                	jmp    80104a9d <sys_exec+0xe2>
    return -1;
80104a83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a88:	eb 13                	jmp    80104a9d <sys_exec+0xe2>
80104a8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a8f:	eb 0c                	jmp    80104a9d <sys_exec+0xe2>
      return -1;
80104a91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a96:	eb 05                	jmp    80104a9d <sys_exec+0xe2>
      return -1;
80104a98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104a9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104aa0:	c9                   	leave  
80104aa1:	c3                   	ret    
      return -1;
80104aa2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aa7:	eb f4                	jmp    80104a9d <sys_exec+0xe2>

80104aa9 <sys_pipe>:

int
sys_pipe(void)
{
80104aa9:	55                   	push   %ebp
80104aaa:	89 e5                	mov    %esp,%ebp
80104aac:	53                   	push   %ebx
80104aad:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104ab0:	6a 08                	push   $0x8
80104ab2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ab5:	50                   	push   %eax
80104ab6:	6a 00                	push   $0x0
80104ab8:	e8 e5 f3 ff ff       	call   80103ea2 <argptr>
80104abd:	83 c4 10             	add    $0x10,%esp
80104ac0:	85 c0                	test   %eax,%eax
80104ac2:	78 77                	js     80104b3b <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104ac4:	83 ec 08             	sub    $0x8,%esp
80104ac7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104aca:	50                   	push   %eax
80104acb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ace:	50                   	push   %eax
80104acf:	e8 4f e2 ff ff       	call   80102d23 <pipealloc>
80104ad4:	83 c4 10             	add    $0x10,%esp
80104ad7:	85 c0                	test   %eax,%eax
80104ad9:	78 67                	js     80104b42 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104adb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ade:	e8 16 f5 ff ff       	call   80103ff9 <fdalloc>
80104ae3:	89 c3                	mov    %eax,%ebx
80104ae5:	85 c0                	test   %eax,%eax
80104ae7:	78 21                	js     80104b0a <sys_pipe+0x61>
80104ae9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104aec:	e8 08 f5 ff ff       	call   80103ff9 <fdalloc>
80104af1:	85 c0                	test   %eax,%eax
80104af3:	78 15                	js     80104b0a <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104af5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104af8:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104afa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104afd:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104b00:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b08:	c9                   	leave  
80104b09:	c3                   	ret    
    if(fd0 >= 0)
80104b0a:	85 db                	test   %ebx,%ebx
80104b0c:	78 0d                	js     80104b1b <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104b0e:	e8 d1 e6 ff ff       	call   801031e4 <myproc>
80104b13:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104b1a:	00 
    fileclose(rf);
80104b1b:	83 ec 0c             	sub    $0xc,%esp
80104b1e:	ff 75 f0             	pushl  -0x10(%ebp)
80104b21:	e8 ad c1 ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104b26:	83 c4 04             	add    $0x4,%esp
80104b29:	ff 75 ec             	pushl  -0x14(%ebp)
80104b2c:	e8 a2 c1 ff ff       	call   80100cd3 <fileclose>
    return -1;
80104b31:	83 c4 10             	add    $0x10,%esp
80104b34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b39:	eb ca                	jmp    80104b05 <sys_pipe+0x5c>
    return -1;
80104b3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b40:	eb c3                	jmp    80104b05 <sys_pipe+0x5c>
    return -1;
80104b42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b47:	eb bc                	jmp    80104b05 <sys_pipe+0x5c>

80104b49 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104b49:	55                   	push   %ebp
80104b4a:	89 e5                	mov    %esp,%ebp
80104b4c:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104b4f:	e8 08 e8 ff ff       	call   8010335c <fork>
}
80104b54:	c9                   	leave  
80104b55:	c3                   	ret    

80104b56 <sys_exit>:

int
sys_exit(void)
{
80104b56:	55                   	push   %ebp
80104b57:	89 e5                	mov    %esp,%ebp
80104b59:	83 ec 08             	sub    $0x8,%esp
  exit();
80104b5c:	e8 2f ea ff ff       	call   80103590 <exit>
  return 0;  // not reached
}
80104b61:	b8 00 00 00 00       	mov    $0x0,%eax
80104b66:	c9                   	leave  
80104b67:	c3                   	ret    

80104b68 <sys_wait>:

int
sys_wait(void)
{
80104b68:	55                   	push   %ebp
80104b69:	89 e5                	mov    %esp,%ebp
80104b6b:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104b6e:	e8 a6 eb ff ff       	call   80103719 <wait>
}
80104b73:	c9                   	leave  
80104b74:	c3                   	ret    

80104b75 <sys_kill>:

int
sys_kill(void)
{
80104b75:	55                   	push   %ebp
80104b76:	89 e5                	mov    %esp,%ebp
80104b78:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104b7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b7e:	50                   	push   %eax
80104b7f:	6a 00                	push   $0x0
80104b81:	e8 f4 f2 ff ff       	call   80103e7a <argint>
80104b86:	83 c4 10             	add    $0x10,%esp
80104b89:	85 c0                	test   %eax,%eax
80104b8b:	78 10                	js     80104b9d <sys_kill+0x28>
    return -1;
  return kill(pid);
80104b8d:	83 ec 0c             	sub    $0xc,%esp
80104b90:	ff 75 f4             	pushl  -0xc(%ebp)
80104b93:	e8 7e ec ff ff       	call   80103816 <kill>
80104b98:	83 c4 10             	add    $0x10,%esp
}
80104b9b:	c9                   	leave  
80104b9c:	c3                   	ret    
    return -1;
80104b9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ba2:	eb f7                	jmp    80104b9b <sys_kill+0x26>

80104ba4 <sys_getpid>:

int
sys_getpid(void)
{
80104ba4:	55                   	push   %ebp
80104ba5:	89 e5                	mov    %esp,%ebp
80104ba7:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104baa:	e8 35 e6 ff ff       	call   801031e4 <myproc>
80104baf:	8b 40 10             	mov    0x10(%eax),%eax
}
80104bb2:	c9                   	leave  
80104bb3:	c3                   	ret    

80104bb4 <sys_sbrk>:

int
sys_sbrk(void)
{
80104bb4:	55                   	push   %ebp
80104bb5:	89 e5                	mov    %esp,%ebp
80104bb7:	53                   	push   %ebx
80104bb8:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104bbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104bbe:	50                   	push   %eax
80104bbf:	6a 00                	push   $0x0
80104bc1:	e8 b4 f2 ff ff       	call   80103e7a <argint>
80104bc6:	83 c4 10             	add    $0x10,%esp
80104bc9:	85 c0                	test   %eax,%eax
80104bcb:	78 27                	js     80104bf4 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104bcd:	e8 12 e6 ff ff       	call   801031e4 <myproc>
80104bd2:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104bd4:	83 ec 0c             	sub    $0xc,%esp
80104bd7:	ff 75 f4             	pushl  -0xc(%ebp)
80104bda:	e8 10 e7 ff ff       	call   801032ef <growproc>
80104bdf:	83 c4 10             	add    $0x10,%esp
80104be2:	85 c0                	test   %eax,%eax
80104be4:	78 07                	js     80104bed <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104be6:	89 d8                	mov    %ebx,%eax
80104be8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104beb:	c9                   	leave  
80104bec:	c3                   	ret    
    return -1;
80104bed:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104bf2:	eb f2                	jmp    80104be6 <sys_sbrk+0x32>
    return -1;
80104bf4:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104bf9:	eb eb                	jmp    80104be6 <sys_sbrk+0x32>

80104bfb <sys_sleep>:

int
sys_sleep(void)
{
80104bfb:	55                   	push   %ebp
80104bfc:	89 e5                	mov    %esp,%ebp
80104bfe:	53                   	push   %ebx
80104bff:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104c02:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c05:	50                   	push   %eax
80104c06:	6a 00                	push   $0x0
80104c08:	e8 6d f2 ff ff       	call   80103e7a <argint>
80104c0d:	83 c4 10             	add    $0x10,%esp
80104c10:	85 c0                	test   %eax,%eax
80104c12:	78 75                	js     80104c89 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104c14:	83 ec 0c             	sub    $0xc,%esp
80104c17:	68 60 3c 11 80       	push   $0x80113c60
80104c1c:	e8 62 ef ff ff       	call   80103b83 <acquire>
  ticks0 = ticks;
80104c21:	8b 1d a0 44 11 80    	mov    0x801144a0,%ebx
  while(ticks - ticks0 < n){
80104c27:	83 c4 10             	add    $0x10,%esp
80104c2a:	a1 a0 44 11 80       	mov    0x801144a0,%eax
80104c2f:	29 d8                	sub    %ebx,%eax
80104c31:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104c34:	73 39                	jae    80104c6f <sys_sleep+0x74>
    if(myproc()->killed){
80104c36:	e8 a9 e5 ff ff       	call   801031e4 <myproc>
80104c3b:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104c3f:	75 17                	jne    80104c58 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104c41:	83 ec 08             	sub    $0x8,%esp
80104c44:	68 60 3c 11 80       	push   $0x80113c60
80104c49:	68 a0 44 11 80       	push   $0x801144a0
80104c4e:	e8 35 ea ff ff       	call   80103688 <sleep>
80104c53:	83 c4 10             	add    $0x10,%esp
80104c56:	eb d2                	jmp    80104c2a <sys_sleep+0x2f>
      release(&tickslock);
80104c58:	83 ec 0c             	sub    $0xc,%esp
80104c5b:	68 60 3c 11 80       	push   $0x80113c60
80104c60:	e8 83 ef ff ff       	call   80103be8 <release>
      return -1;
80104c65:	83 c4 10             	add    $0x10,%esp
80104c68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c6d:	eb 15                	jmp    80104c84 <sys_sleep+0x89>
  }
  release(&tickslock);
80104c6f:	83 ec 0c             	sub    $0xc,%esp
80104c72:	68 60 3c 11 80       	push   $0x80113c60
80104c77:	e8 6c ef ff ff       	call   80103be8 <release>
  return 0;
80104c7c:	83 c4 10             	add    $0x10,%esp
80104c7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c87:	c9                   	leave  
80104c88:	c3                   	ret    
    return -1;
80104c89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c8e:	eb f4                	jmp    80104c84 <sys_sleep+0x89>

80104c90 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104c90:	55                   	push   %ebp
80104c91:	89 e5                	mov    %esp,%ebp
80104c93:	53                   	push   %ebx
80104c94:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104c97:	68 60 3c 11 80       	push   $0x80113c60
80104c9c:	e8 e2 ee ff ff       	call   80103b83 <acquire>
  xticks = ticks;
80104ca1:	8b 1d a0 44 11 80    	mov    0x801144a0,%ebx
  release(&tickslock);
80104ca7:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
80104cae:	e8 35 ef ff ff       	call   80103be8 <release>
  return xticks;
}
80104cb3:	89 d8                	mov    %ebx,%eax
80104cb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104cb8:	c9                   	leave  
80104cb9:	c3                   	ret    

80104cba <sys_mencrypt>:
#include "defs.h"
#include "vm.h"

int
sys_mencrypt(void)
{
80104cba:	55                   	push   %ebp
80104cbb:	89 e5                	mov    %esp,%ebp
80104cbd:	83 ec 1c             	sub    $0x1c,%esp
	char* virtual_addr;
	int len;

  	if(argptr(0, (void *)&virtual_addr, sizeof(*virtual_addr)) < 0 || argint(1, &len) < 0){
80104cc0:	6a 01                	push   $0x1
80104cc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cc5:	50                   	push   %eax
80104cc6:	6a 00                	push   $0x0
80104cc8:	e8 d5 f1 ff ff       	call   80103ea2 <argptr>
80104ccd:	83 c4 10             	add    $0x10,%esp
80104cd0:	85 c0                	test   %eax,%eax
80104cd2:	78 28                	js     80104cfc <sys_mencrypt+0x42>
80104cd4:	83 ec 08             	sub    $0x8,%esp
80104cd7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104cda:	50                   	push   %eax
80104cdb:	6a 01                	push   $0x1
80104cdd:	e8 98 f1 ff ff       	call   80103e7a <argint>
80104ce2:	83 c4 10             	add    $0x10,%esp
80104ce5:	85 c0                	test   %eax,%eax
80104ce7:	78 1a                	js     80104d03 <sys_mencrypt+0x49>
    	return -1;
  	}

	return mencrypt(virtual_addr, len);
80104ce9:	83 ec 08             	sub    $0x8,%esp
80104cec:	ff 75 f0             	pushl  -0x10(%ebp)
80104cef:	ff 75 f4             	pushl  -0xc(%ebp)
80104cf2:	e8 fc 17 00 00       	call   801064f3 <mencrypt>
80104cf7:	83 c4 10             	add    $0x10,%esp
}
80104cfa:	c9                   	leave  
80104cfb:	c3                   	ret    
    	return -1;
80104cfc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d01:	eb f7                	jmp    80104cfa <sys_mencrypt+0x40>
80104d03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d08:	eb f0                	jmp    80104cfa <sys_mencrypt+0x40>

80104d0a <sys_getpgtable>:

int 
sys_getpgtable(void)
{
80104d0a:	55                   	push   %ebp
80104d0b:	89 e5                	mov    %esp,%ebp
80104d0d:	83 ec 1c             	sub    $0x1c,%esp
	struct pt_entry* entries;
	int num;
	
	if(argptr(0, (void *)&entries, sizeof(*entries)) < 0 || argint(1, &num) < 0){
80104d10:	6a 08                	push   $0x8
80104d12:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d15:	50                   	push   %eax
80104d16:	6a 00                	push   $0x0
80104d18:	e8 85 f1 ff ff       	call   80103ea2 <argptr>
80104d1d:	83 c4 10             	add    $0x10,%esp
80104d20:	85 c0                	test   %eax,%eax
80104d22:	78 28                	js     80104d4c <sys_getpgtable+0x42>
80104d24:	83 ec 08             	sub    $0x8,%esp
80104d27:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d2a:	50                   	push   %eax
80104d2b:	6a 01                	push   $0x1
80104d2d:	e8 48 f1 ff ff       	call   80103e7a <argint>
80104d32:	83 c4 10             	add    $0x10,%esp
80104d35:	85 c0                	test   %eax,%eax
80104d37:	78 1a                	js     80104d53 <sys_getpgtable+0x49>
    	return -1;
  	}

	return getpgtable(entries, num);
80104d39:	83 ec 08             	sub    $0x8,%esp
80104d3c:	ff 75 f0             	pushl  -0x10(%ebp)
80104d3f:	ff 75 f4             	pushl  -0xc(%ebp)
80104d42:	e8 b6 17 00 00       	call   801064fd <getpgtable>
80104d47:	83 c4 10             	add    $0x10,%esp
}
80104d4a:	c9                   	leave  
80104d4b:	c3                   	ret    
    	return -1;
80104d4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d51:	eb f7                	jmp    80104d4a <sys_getpgtable+0x40>
80104d53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d58:	eb f0                	jmp    80104d4a <sys_getpgtable+0x40>

80104d5a <sys_dump_rawphymem>:

int sys_dump_rawphymem(void)
{
80104d5a:	55                   	push   %ebp
80104d5b:	89 e5                	mov    %esp,%ebp
80104d5d:	83 ec 20             	sub    $0x20,%esp
	uint physical_addr;
	char* buffer;

	if(argint(0, (int *)&physical_addr) < 0 || argptr(1, (void *)&buffer, sizeof(*buffer)) < 0){
80104d60:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d63:	50                   	push   %eax
80104d64:	6a 00                	push   $0x0
80104d66:	e8 0f f1 ff ff       	call   80103e7a <argint>
80104d6b:	83 c4 10             	add    $0x10,%esp
80104d6e:	85 c0                	test   %eax,%eax
80104d70:	78 2a                	js     80104d9c <sys_dump_rawphymem+0x42>
80104d72:	83 ec 04             	sub    $0x4,%esp
80104d75:	6a 01                	push   $0x1
80104d77:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d7a:	50                   	push   %eax
80104d7b:	6a 01                	push   $0x1
80104d7d:	e8 20 f1 ff ff       	call   80103ea2 <argptr>
80104d82:	83 c4 10             	add    $0x10,%esp
80104d85:	85 c0                	test   %eax,%eax
80104d87:	78 1a                	js     80104da3 <sys_dump_rawphymem+0x49>
    	return -1;
  	}

	return dump_rawphymem(physical_addr, buffer);
80104d89:	83 ec 08             	sub    $0x8,%esp
80104d8c:	ff 75 f0             	pushl  -0x10(%ebp)
80104d8f:	ff 75 f4             	pushl  -0xc(%ebp)
80104d92:	e8 70 17 00 00       	call   80106507 <dump_rawphymem>
80104d97:	83 c4 10             	add    $0x10,%esp
80104d9a:	c9                   	leave  
80104d9b:	c3                   	ret    
    	return -1;
80104d9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104da1:	eb f7                	jmp    80104d9a <sys_dump_rawphymem+0x40>
80104da3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104da8:	eb f0                	jmp    80104d9a <sys_dump_rawphymem+0x40>

80104daa <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104daa:	1e                   	push   %ds
  pushl %es
80104dab:	06                   	push   %es
  pushl %fs
80104dac:	0f a0                	push   %fs
  pushl %gs
80104dae:	0f a8                	push   %gs
  pushal
80104db0:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104db1:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104db5:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104db7:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104db9:	54                   	push   %esp
  call trap
80104dba:	e8 e3 00 00 00       	call   80104ea2 <trap>
  addl $4, %esp
80104dbf:	83 c4 04             	add    $0x4,%esp

80104dc2 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104dc2:	61                   	popa   
  popl %gs
80104dc3:	0f a9                	pop    %gs
  popl %fs
80104dc5:	0f a1                	pop    %fs
  popl %es
80104dc7:	07                   	pop    %es
  popl %ds
80104dc8:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104dc9:	83 c4 08             	add    $0x8,%esp
  iret
80104dcc:	cf                   	iret   

80104dcd <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104dcd:	55                   	push   %ebp
80104dce:	89 e5                	mov    %esp,%ebp
80104dd0:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104dd3:	b8 00 00 00 00       	mov    $0x0,%eax
80104dd8:	eb 4a                	jmp    80104e24 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104dda:	8b 0c 85 08 90 10 80 	mov    -0x7fef6ff8(,%eax,4),%ecx
80104de1:	66 89 0c c5 a0 3c 11 	mov    %cx,-0x7feec360(,%eax,8)
80104de8:	80 
80104de9:	66 c7 04 c5 a2 3c 11 	movw   $0x8,-0x7feec35e(,%eax,8)
80104df0:	80 08 00 
80104df3:	c6 04 c5 a4 3c 11 80 	movb   $0x0,-0x7feec35c(,%eax,8)
80104dfa:	00 
80104dfb:	0f b6 14 c5 a5 3c 11 	movzbl -0x7feec35b(,%eax,8),%edx
80104e02:	80 
80104e03:	83 e2 f0             	and    $0xfffffff0,%edx
80104e06:	83 ca 0e             	or     $0xe,%edx
80104e09:	83 e2 8f             	and    $0xffffff8f,%edx
80104e0c:	83 ca 80             	or     $0xffffff80,%edx
80104e0f:	88 14 c5 a5 3c 11 80 	mov    %dl,-0x7feec35b(,%eax,8)
80104e16:	c1 e9 10             	shr    $0x10,%ecx
80104e19:	66 89 0c c5 a6 3c 11 	mov    %cx,-0x7feec35a(,%eax,8)
80104e20:	80 
  for(i = 0; i < 256; i++)
80104e21:	83 c0 01             	add    $0x1,%eax
80104e24:	3d ff 00 00 00       	cmp    $0xff,%eax
80104e29:	7e af                	jle    80104dda <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104e2b:	8b 15 08 91 10 80    	mov    0x80109108,%edx
80104e31:	66 89 15 a0 3e 11 80 	mov    %dx,0x80113ea0
80104e38:	66 c7 05 a2 3e 11 80 	movw   $0x8,0x80113ea2
80104e3f:	08 00 
80104e41:	c6 05 a4 3e 11 80 00 	movb   $0x0,0x80113ea4
80104e48:	0f b6 05 a5 3e 11 80 	movzbl 0x80113ea5,%eax
80104e4f:	83 c8 0f             	or     $0xf,%eax
80104e52:	83 e0 ef             	and    $0xffffffef,%eax
80104e55:	83 c8 e0             	or     $0xffffffe0,%eax
80104e58:	a2 a5 3e 11 80       	mov    %al,0x80113ea5
80104e5d:	c1 ea 10             	shr    $0x10,%edx
80104e60:	66 89 15 a6 3e 11 80 	mov    %dx,0x80113ea6

  initlock(&tickslock, "time");
80104e67:	83 ec 08             	sub    $0x8,%esp
80104e6a:	68 c5 6c 10 80       	push   $0x80106cc5
80104e6f:	68 60 3c 11 80       	push   $0x80113c60
80104e74:	e8 ce eb ff ff       	call   80103a47 <initlock>
}
80104e79:	83 c4 10             	add    $0x10,%esp
80104e7c:	c9                   	leave  
80104e7d:	c3                   	ret    

80104e7e <idtinit>:

void
idtinit(void)
{
80104e7e:	55                   	push   %ebp
80104e7f:	89 e5                	mov    %esp,%ebp
80104e81:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104e84:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104e8a:	b8 a0 3c 11 80       	mov    $0x80113ca0,%eax
80104e8f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104e93:	c1 e8 10             	shr    $0x10,%eax
80104e96:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104e9a:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104e9d:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104ea0:	c9                   	leave  
80104ea1:	c3                   	ret    

80104ea2 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80104ea2:	55                   	push   %ebp
80104ea3:	89 e5                	mov    %esp,%ebp
80104ea5:	57                   	push   %edi
80104ea6:	56                   	push   %esi
80104ea7:	53                   	push   %ebx
80104ea8:	83 ec 1c             	sub    $0x1c,%esp
80104eab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104eae:	8b 43 30             	mov    0x30(%ebx),%eax
80104eb1:	83 f8 40             	cmp    $0x40,%eax
80104eb4:	74 13                	je     80104ec9 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104eb6:	83 e8 20             	sub    $0x20,%eax
80104eb9:	83 f8 1f             	cmp    $0x1f,%eax
80104ebc:	0f 87 3a 01 00 00    	ja     80104ffc <trap+0x15a>
80104ec2:	ff 24 85 6c 6d 10 80 	jmp    *-0x7fef9294(,%eax,4)
    if(myproc()->killed)
80104ec9:	e8 16 e3 ff ff       	call   801031e4 <myproc>
80104ece:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104ed2:	75 1f                	jne    80104ef3 <trap+0x51>
    myproc()->tf = tf;
80104ed4:	e8 0b e3 ff ff       	call   801031e4 <myproc>
80104ed9:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80104edc:	e8 5c f0 ff ff       	call   80103f3d <syscall>
    if(myproc()->killed)
80104ee1:	e8 fe e2 ff ff       	call   801031e4 <myproc>
80104ee6:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104eea:	74 7e                	je     80104f6a <trap+0xc8>
      exit();
80104eec:	e8 9f e6 ff ff       	call   80103590 <exit>
80104ef1:	eb 77                	jmp    80104f6a <trap+0xc8>
      exit();
80104ef3:	e8 98 e6 ff ff       	call   80103590 <exit>
80104ef8:	eb da                	jmp    80104ed4 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104efa:	e8 ca e2 ff ff       	call   801031c9 <cpuid>
80104eff:	85 c0                	test   %eax,%eax
80104f01:	74 6f                	je     80104f72 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80104f03:	e8 7f d4 ff ff       	call   80102387 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f08:	e8 d7 e2 ff ff       	call   801031e4 <myproc>
80104f0d:	85 c0                	test   %eax,%eax
80104f0f:	74 1c                	je     80104f2d <trap+0x8b>
80104f11:	e8 ce e2 ff ff       	call   801031e4 <myproc>
80104f16:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f1a:	74 11                	je     80104f2d <trap+0x8b>
80104f1c:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f20:	83 e0 03             	and    $0x3,%eax
80104f23:	66 83 f8 03          	cmp    $0x3,%ax
80104f27:	0f 84 62 01 00 00    	je     8010508f <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80104f2d:	e8 b2 e2 ff ff       	call   801031e4 <myproc>
80104f32:	85 c0                	test   %eax,%eax
80104f34:	74 0f                	je     80104f45 <trap+0xa3>
80104f36:	e8 a9 e2 ff ff       	call   801031e4 <myproc>
80104f3b:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80104f3f:	0f 84 54 01 00 00    	je     80105099 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f45:	e8 9a e2 ff ff       	call   801031e4 <myproc>
80104f4a:	85 c0                	test   %eax,%eax
80104f4c:	74 1c                	je     80104f6a <trap+0xc8>
80104f4e:	e8 91 e2 ff ff       	call   801031e4 <myproc>
80104f53:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f57:	74 11                	je     80104f6a <trap+0xc8>
80104f59:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f5d:	83 e0 03             	and    $0x3,%eax
80104f60:	66 83 f8 03          	cmp    $0x3,%ax
80104f64:	0f 84 43 01 00 00    	je     801050ad <trap+0x20b>
    exit();
}
80104f6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f6d:	5b                   	pop    %ebx
80104f6e:	5e                   	pop    %esi
80104f6f:	5f                   	pop    %edi
80104f70:	5d                   	pop    %ebp
80104f71:	c3                   	ret    
      acquire(&tickslock);
80104f72:	83 ec 0c             	sub    $0xc,%esp
80104f75:	68 60 3c 11 80       	push   $0x80113c60
80104f7a:	e8 04 ec ff ff       	call   80103b83 <acquire>
      ticks++;
80104f7f:	83 05 a0 44 11 80 01 	addl   $0x1,0x801144a0
      wakeup(&ticks);
80104f86:	c7 04 24 a0 44 11 80 	movl   $0x801144a0,(%esp)
80104f8d:	e8 5b e8 ff ff       	call   801037ed <wakeup>
      release(&tickslock);
80104f92:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
80104f99:	e8 4a ec ff ff       	call   80103be8 <release>
80104f9e:	83 c4 10             	add    $0x10,%esp
80104fa1:	e9 5d ff ff ff       	jmp    80104f03 <trap+0x61>
    ideintr();
80104fa6:	e8 b6 cd ff ff       	call   80101d61 <ideintr>
    lapiceoi();
80104fab:	e8 d7 d3 ff ff       	call   80102387 <lapiceoi>
    break;
80104fb0:	e9 53 ff ff ff       	jmp    80104f08 <trap+0x66>
    kbdintr();
80104fb5:	e8 11 d2 ff ff       	call   801021cb <kbdintr>
    lapiceoi();
80104fba:	e8 c8 d3 ff ff       	call   80102387 <lapiceoi>
    break;
80104fbf:	e9 44 ff ff ff       	jmp    80104f08 <trap+0x66>
    uartintr();
80104fc4:	e8 05 02 00 00       	call   801051ce <uartintr>
    lapiceoi();
80104fc9:	e8 b9 d3 ff ff       	call   80102387 <lapiceoi>
    break;
80104fce:	e9 35 ff ff ff       	jmp    80104f08 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104fd3:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80104fd6:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104fda:	e8 ea e1 ff ff       	call   801031c9 <cpuid>
80104fdf:	57                   	push   %edi
80104fe0:	0f b7 f6             	movzwl %si,%esi
80104fe3:	56                   	push   %esi
80104fe4:	50                   	push   %eax
80104fe5:	68 d0 6c 10 80       	push   $0x80106cd0
80104fea:	e8 1c b6 ff ff       	call   8010060b <cprintf>
    lapiceoi();
80104fef:	e8 93 d3 ff ff       	call   80102387 <lapiceoi>
    break;
80104ff4:	83 c4 10             	add    $0x10,%esp
80104ff7:	e9 0c ff ff ff       	jmp    80104f08 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
80104ffc:	e8 e3 e1 ff ff       	call   801031e4 <myproc>
80105001:	85 c0                	test   %eax,%eax
80105003:	74 5f                	je     80105064 <trap+0x1c2>
80105005:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105009:	74 59                	je     80105064 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010500b:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010500e:	8b 43 38             	mov    0x38(%ebx),%eax
80105011:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105014:	e8 b0 e1 ff ff       	call   801031c9 <cpuid>
80105019:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010501c:	8b 53 34             	mov    0x34(%ebx),%edx
8010501f:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105022:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105025:	e8 ba e1 ff ff       	call   801031e4 <myproc>
8010502a:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010502d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105030:	e8 af e1 ff ff       	call   801031e4 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105035:	57                   	push   %edi
80105036:	ff 75 e4             	pushl  -0x1c(%ebp)
80105039:	ff 75 e0             	pushl  -0x20(%ebp)
8010503c:	ff 75 dc             	pushl  -0x24(%ebp)
8010503f:	56                   	push   %esi
80105040:	ff 75 d8             	pushl  -0x28(%ebp)
80105043:	ff 70 10             	pushl  0x10(%eax)
80105046:	68 28 6d 10 80       	push   $0x80106d28
8010504b:	e8 bb b5 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
80105050:	83 c4 20             	add    $0x20,%esp
80105053:	e8 8c e1 ff ff       	call   801031e4 <myproc>
80105058:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010505f:	e9 a4 fe ff ff       	jmp    80104f08 <trap+0x66>
80105064:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105067:	8b 73 38             	mov    0x38(%ebx),%esi
8010506a:	e8 5a e1 ff ff       	call   801031c9 <cpuid>
8010506f:	83 ec 0c             	sub    $0xc,%esp
80105072:	57                   	push   %edi
80105073:	56                   	push   %esi
80105074:	50                   	push   %eax
80105075:	ff 73 30             	pushl  0x30(%ebx)
80105078:	68 f4 6c 10 80       	push   $0x80106cf4
8010507d:	e8 89 b5 ff ff       	call   8010060b <cprintf>
      panic("trap");
80105082:	83 c4 14             	add    $0x14,%esp
80105085:	68 ca 6c 10 80       	push   $0x80106cca
8010508a:	e8 b9 b2 ff ff       	call   80100348 <panic>
    exit();
8010508f:	e8 fc e4 ff ff       	call   80103590 <exit>
80105094:	e9 94 fe ff ff       	jmp    80104f2d <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
80105099:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
8010509d:	0f 85 a2 fe ff ff    	jne    80104f45 <trap+0xa3>
    yield();
801050a3:	e8 ae e5 ff ff       	call   80103656 <yield>
801050a8:	e9 98 fe ff ff       	jmp    80104f45 <trap+0xa3>
    exit();
801050ad:	e8 de e4 ff ff       	call   80103590 <exit>
801050b2:	e9 b3 fe ff ff       	jmp    80104f6a <trap+0xc8>

801050b7 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801050b7:	55                   	push   %ebp
801050b8:	89 e5                	mov    %esp,%ebp
  if(!uart)
801050ba:	83 3d bc 95 10 80 00 	cmpl   $0x0,0x801095bc
801050c1:	74 15                	je     801050d8 <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801050c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
801050c8:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801050c9:	a8 01                	test   $0x1,%al
801050cb:	74 12                	je     801050df <uartgetc+0x28>
801050cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
801050d2:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801050d3:	0f b6 c0             	movzbl %al,%eax
}
801050d6:	5d                   	pop    %ebp
801050d7:	c3                   	ret    
    return -1;
801050d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050dd:	eb f7                	jmp    801050d6 <uartgetc+0x1f>
    return -1;
801050df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050e4:	eb f0                	jmp    801050d6 <uartgetc+0x1f>

801050e6 <uartputc>:
  if(!uart)
801050e6:	83 3d bc 95 10 80 00 	cmpl   $0x0,0x801095bc
801050ed:	74 3b                	je     8010512a <uartputc+0x44>
{
801050ef:	55                   	push   %ebp
801050f0:	89 e5                	mov    %esp,%ebp
801050f2:	53                   	push   %ebx
801050f3:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801050f6:	bb 00 00 00 00       	mov    $0x0,%ebx
801050fb:	eb 10                	jmp    8010510d <uartputc+0x27>
    microdelay(10);
801050fd:	83 ec 0c             	sub    $0xc,%esp
80105100:	6a 0a                	push   $0xa
80105102:	e8 9f d2 ff ff       	call   801023a6 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105107:	83 c3 01             	add    $0x1,%ebx
8010510a:	83 c4 10             	add    $0x10,%esp
8010510d:	83 fb 7f             	cmp    $0x7f,%ebx
80105110:	7f 0a                	jg     8010511c <uartputc+0x36>
80105112:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105117:	ec                   	in     (%dx),%al
80105118:	a8 20                	test   $0x20,%al
8010511a:	74 e1                	je     801050fd <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010511c:	8b 45 08             	mov    0x8(%ebp),%eax
8010511f:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105124:	ee                   	out    %al,(%dx)
}
80105125:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105128:	c9                   	leave  
80105129:	c3                   	ret    
8010512a:	f3 c3                	repz ret 

8010512c <uartinit>:
{
8010512c:	55                   	push   %ebp
8010512d:	89 e5                	mov    %esp,%ebp
8010512f:	56                   	push   %esi
80105130:	53                   	push   %ebx
80105131:	b9 00 00 00 00       	mov    $0x0,%ecx
80105136:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010513b:	89 c8                	mov    %ecx,%eax
8010513d:	ee                   	out    %al,(%dx)
8010513e:	be fb 03 00 00       	mov    $0x3fb,%esi
80105143:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105148:	89 f2                	mov    %esi,%edx
8010514a:	ee                   	out    %al,(%dx)
8010514b:	b8 0c 00 00 00       	mov    $0xc,%eax
80105150:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105155:	ee                   	out    %al,(%dx)
80105156:	bb f9 03 00 00       	mov    $0x3f9,%ebx
8010515b:	89 c8                	mov    %ecx,%eax
8010515d:	89 da                	mov    %ebx,%edx
8010515f:	ee                   	out    %al,(%dx)
80105160:	b8 03 00 00 00       	mov    $0x3,%eax
80105165:	89 f2                	mov    %esi,%edx
80105167:	ee                   	out    %al,(%dx)
80105168:	ba fc 03 00 00       	mov    $0x3fc,%edx
8010516d:	89 c8                	mov    %ecx,%eax
8010516f:	ee                   	out    %al,(%dx)
80105170:	b8 01 00 00 00       	mov    $0x1,%eax
80105175:	89 da                	mov    %ebx,%edx
80105177:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105178:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010517d:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
8010517e:	3c ff                	cmp    $0xff,%al
80105180:	74 45                	je     801051c7 <uartinit+0x9b>
  uart = 1;
80105182:	c7 05 bc 95 10 80 01 	movl   $0x1,0x801095bc
80105189:	00 00 00 
8010518c:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105191:	ec                   	in     (%dx),%al
80105192:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105197:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105198:	83 ec 08             	sub    $0x8,%esp
8010519b:	6a 00                	push   $0x0
8010519d:	6a 04                	push   $0x4
8010519f:	e8 c8 cd ff ff       	call   80101f6c <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801051a4:	83 c4 10             	add    $0x10,%esp
801051a7:	bb ec 6d 10 80       	mov    $0x80106dec,%ebx
801051ac:	eb 12                	jmp    801051c0 <uartinit+0x94>
    uartputc(*p);
801051ae:	83 ec 0c             	sub    $0xc,%esp
801051b1:	0f be c0             	movsbl %al,%eax
801051b4:	50                   	push   %eax
801051b5:	e8 2c ff ff ff       	call   801050e6 <uartputc>
  for(p="xv6...\n"; *p; p++)
801051ba:	83 c3 01             	add    $0x1,%ebx
801051bd:	83 c4 10             	add    $0x10,%esp
801051c0:	0f b6 03             	movzbl (%ebx),%eax
801051c3:	84 c0                	test   %al,%al
801051c5:	75 e7                	jne    801051ae <uartinit+0x82>
}
801051c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801051ca:	5b                   	pop    %ebx
801051cb:	5e                   	pop    %esi
801051cc:	5d                   	pop    %ebp
801051cd:	c3                   	ret    

801051ce <uartintr>:

void
uartintr(void)
{
801051ce:	55                   	push   %ebp
801051cf:	89 e5                	mov    %esp,%ebp
801051d1:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801051d4:	68 b7 50 10 80       	push   $0x801050b7
801051d9:	e8 60 b5 ff ff       	call   8010073e <consoleintr>
}
801051de:	83 c4 10             	add    $0x10,%esp
801051e1:	c9                   	leave  
801051e2:	c3                   	ret    

801051e3 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801051e3:	6a 00                	push   $0x0
  pushl $0
801051e5:	6a 00                	push   $0x0
  jmp alltraps
801051e7:	e9 be fb ff ff       	jmp    80104daa <alltraps>

801051ec <vector1>:
.globl vector1
vector1:
  pushl $0
801051ec:	6a 00                	push   $0x0
  pushl $1
801051ee:	6a 01                	push   $0x1
  jmp alltraps
801051f0:	e9 b5 fb ff ff       	jmp    80104daa <alltraps>

801051f5 <vector2>:
.globl vector2
vector2:
  pushl $0
801051f5:	6a 00                	push   $0x0
  pushl $2
801051f7:	6a 02                	push   $0x2
  jmp alltraps
801051f9:	e9 ac fb ff ff       	jmp    80104daa <alltraps>

801051fe <vector3>:
.globl vector3
vector3:
  pushl $0
801051fe:	6a 00                	push   $0x0
  pushl $3
80105200:	6a 03                	push   $0x3
  jmp alltraps
80105202:	e9 a3 fb ff ff       	jmp    80104daa <alltraps>

80105207 <vector4>:
.globl vector4
vector4:
  pushl $0
80105207:	6a 00                	push   $0x0
  pushl $4
80105209:	6a 04                	push   $0x4
  jmp alltraps
8010520b:	e9 9a fb ff ff       	jmp    80104daa <alltraps>

80105210 <vector5>:
.globl vector5
vector5:
  pushl $0
80105210:	6a 00                	push   $0x0
  pushl $5
80105212:	6a 05                	push   $0x5
  jmp alltraps
80105214:	e9 91 fb ff ff       	jmp    80104daa <alltraps>

80105219 <vector6>:
.globl vector6
vector6:
  pushl $0
80105219:	6a 00                	push   $0x0
  pushl $6
8010521b:	6a 06                	push   $0x6
  jmp alltraps
8010521d:	e9 88 fb ff ff       	jmp    80104daa <alltraps>

80105222 <vector7>:
.globl vector7
vector7:
  pushl $0
80105222:	6a 00                	push   $0x0
  pushl $7
80105224:	6a 07                	push   $0x7
  jmp alltraps
80105226:	e9 7f fb ff ff       	jmp    80104daa <alltraps>

8010522b <vector8>:
.globl vector8
vector8:
  pushl $8
8010522b:	6a 08                	push   $0x8
  jmp alltraps
8010522d:	e9 78 fb ff ff       	jmp    80104daa <alltraps>

80105232 <vector9>:
.globl vector9
vector9:
  pushl $0
80105232:	6a 00                	push   $0x0
  pushl $9
80105234:	6a 09                	push   $0x9
  jmp alltraps
80105236:	e9 6f fb ff ff       	jmp    80104daa <alltraps>

8010523b <vector10>:
.globl vector10
vector10:
  pushl $10
8010523b:	6a 0a                	push   $0xa
  jmp alltraps
8010523d:	e9 68 fb ff ff       	jmp    80104daa <alltraps>

80105242 <vector11>:
.globl vector11
vector11:
  pushl $11
80105242:	6a 0b                	push   $0xb
  jmp alltraps
80105244:	e9 61 fb ff ff       	jmp    80104daa <alltraps>

80105249 <vector12>:
.globl vector12
vector12:
  pushl $12
80105249:	6a 0c                	push   $0xc
  jmp alltraps
8010524b:	e9 5a fb ff ff       	jmp    80104daa <alltraps>

80105250 <vector13>:
.globl vector13
vector13:
  pushl $13
80105250:	6a 0d                	push   $0xd
  jmp alltraps
80105252:	e9 53 fb ff ff       	jmp    80104daa <alltraps>

80105257 <vector14>:
.globl vector14
vector14:
  pushl $14
80105257:	6a 0e                	push   $0xe
  jmp alltraps
80105259:	e9 4c fb ff ff       	jmp    80104daa <alltraps>

8010525e <vector15>:
.globl vector15
vector15:
  pushl $0
8010525e:	6a 00                	push   $0x0
  pushl $15
80105260:	6a 0f                	push   $0xf
  jmp alltraps
80105262:	e9 43 fb ff ff       	jmp    80104daa <alltraps>

80105267 <vector16>:
.globl vector16
vector16:
  pushl $0
80105267:	6a 00                	push   $0x0
  pushl $16
80105269:	6a 10                	push   $0x10
  jmp alltraps
8010526b:	e9 3a fb ff ff       	jmp    80104daa <alltraps>

80105270 <vector17>:
.globl vector17
vector17:
  pushl $17
80105270:	6a 11                	push   $0x11
  jmp alltraps
80105272:	e9 33 fb ff ff       	jmp    80104daa <alltraps>

80105277 <vector18>:
.globl vector18
vector18:
  pushl $0
80105277:	6a 00                	push   $0x0
  pushl $18
80105279:	6a 12                	push   $0x12
  jmp alltraps
8010527b:	e9 2a fb ff ff       	jmp    80104daa <alltraps>

80105280 <vector19>:
.globl vector19
vector19:
  pushl $0
80105280:	6a 00                	push   $0x0
  pushl $19
80105282:	6a 13                	push   $0x13
  jmp alltraps
80105284:	e9 21 fb ff ff       	jmp    80104daa <alltraps>

80105289 <vector20>:
.globl vector20
vector20:
  pushl $0
80105289:	6a 00                	push   $0x0
  pushl $20
8010528b:	6a 14                	push   $0x14
  jmp alltraps
8010528d:	e9 18 fb ff ff       	jmp    80104daa <alltraps>

80105292 <vector21>:
.globl vector21
vector21:
  pushl $0
80105292:	6a 00                	push   $0x0
  pushl $21
80105294:	6a 15                	push   $0x15
  jmp alltraps
80105296:	e9 0f fb ff ff       	jmp    80104daa <alltraps>

8010529b <vector22>:
.globl vector22
vector22:
  pushl $0
8010529b:	6a 00                	push   $0x0
  pushl $22
8010529d:	6a 16                	push   $0x16
  jmp alltraps
8010529f:	e9 06 fb ff ff       	jmp    80104daa <alltraps>

801052a4 <vector23>:
.globl vector23
vector23:
  pushl $0
801052a4:	6a 00                	push   $0x0
  pushl $23
801052a6:	6a 17                	push   $0x17
  jmp alltraps
801052a8:	e9 fd fa ff ff       	jmp    80104daa <alltraps>

801052ad <vector24>:
.globl vector24
vector24:
  pushl $0
801052ad:	6a 00                	push   $0x0
  pushl $24
801052af:	6a 18                	push   $0x18
  jmp alltraps
801052b1:	e9 f4 fa ff ff       	jmp    80104daa <alltraps>

801052b6 <vector25>:
.globl vector25
vector25:
  pushl $0
801052b6:	6a 00                	push   $0x0
  pushl $25
801052b8:	6a 19                	push   $0x19
  jmp alltraps
801052ba:	e9 eb fa ff ff       	jmp    80104daa <alltraps>

801052bf <vector26>:
.globl vector26
vector26:
  pushl $0
801052bf:	6a 00                	push   $0x0
  pushl $26
801052c1:	6a 1a                	push   $0x1a
  jmp alltraps
801052c3:	e9 e2 fa ff ff       	jmp    80104daa <alltraps>

801052c8 <vector27>:
.globl vector27
vector27:
  pushl $0
801052c8:	6a 00                	push   $0x0
  pushl $27
801052ca:	6a 1b                	push   $0x1b
  jmp alltraps
801052cc:	e9 d9 fa ff ff       	jmp    80104daa <alltraps>

801052d1 <vector28>:
.globl vector28
vector28:
  pushl $0
801052d1:	6a 00                	push   $0x0
  pushl $28
801052d3:	6a 1c                	push   $0x1c
  jmp alltraps
801052d5:	e9 d0 fa ff ff       	jmp    80104daa <alltraps>

801052da <vector29>:
.globl vector29
vector29:
  pushl $0
801052da:	6a 00                	push   $0x0
  pushl $29
801052dc:	6a 1d                	push   $0x1d
  jmp alltraps
801052de:	e9 c7 fa ff ff       	jmp    80104daa <alltraps>

801052e3 <vector30>:
.globl vector30
vector30:
  pushl $0
801052e3:	6a 00                	push   $0x0
  pushl $30
801052e5:	6a 1e                	push   $0x1e
  jmp alltraps
801052e7:	e9 be fa ff ff       	jmp    80104daa <alltraps>

801052ec <vector31>:
.globl vector31
vector31:
  pushl $0
801052ec:	6a 00                	push   $0x0
  pushl $31
801052ee:	6a 1f                	push   $0x1f
  jmp alltraps
801052f0:	e9 b5 fa ff ff       	jmp    80104daa <alltraps>

801052f5 <vector32>:
.globl vector32
vector32:
  pushl $0
801052f5:	6a 00                	push   $0x0
  pushl $32
801052f7:	6a 20                	push   $0x20
  jmp alltraps
801052f9:	e9 ac fa ff ff       	jmp    80104daa <alltraps>

801052fe <vector33>:
.globl vector33
vector33:
  pushl $0
801052fe:	6a 00                	push   $0x0
  pushl $33
80105300:	6a 21                	push   $0x21
  jmp alltraps
80105302:	e9 a3 fa ff ff       	jmp    80104daa <alltraps>

80105307 <vector34>:
.globl vector34
vector34:
  pushl $0
80105307:	6a 00                	push   $0x0
  pushl $34
80105309:	6a 22                	push   $0x22
  jmp alltraps
8010530b:	e9 9a fa ff ff       	jmp    80104daa <alltraps>

80105310 <vector35>:
.globl vector35
vector35:
  pushl $0
80105310:	6a 00                	push   $0x0
  pushl $35
80105312:	6a 23                	push   $0x23
  jmp alltraps
80105314:	e9 91 fa ff ff       	jmp    80104daa <alltraps>

80105319 <vector36>:
.globl vector36
vector36:
  pushl $0
80105319:	6a 00                	push   $0x0
  pushl $36
8010531b:	6a 24                	push   $0x24
  jmp alltraps
8010531d:	e9 88 fa ff ff       	jmp    80104daa <alltraps>

80105322 <vector37>:
.globl vector37
vector37:
  pushl $0
80105322:	6a 00                	push   $0x0
  pushl $37
80105324:	6a 25                	push   $0x25
  jmp alltraps
80105326:	e9 7f fa ff ff       	jmp    80104daa <alltraps>

8010532b <vector38>:
.globl vector38
vector38:
  pushl $0
8010532b:	6a 00                	push   $0x0
  pushl $38
8010532d:	6a 26                	push   $0x26
  jmp alltraps
8010532f:	e9 76 fa ff ff       	jmp    80104daa <alltraps>

80105334 <vector39>:
.globl vector39
vector39:
  pushl $0
80105334:	6a 00                	push   $0x0
  pushl $39
80105336:	6a 27                	push   $0x27
  jmp alltraps
80105338:	e9 6d fa ff ff       	jmp    80104daa <alltraps>

8010533d <vector40>:
.globl vector40
vector40:
  pushl $0
8010533d:	6a 00                	push   $0x0
  pushl $40
8010533f:	6a 28                	push   $0x28
  jmp alltraps
80105341:	e9 64 fa ff ff       	jmp    80104daa <alltraps>

80105346 <vector41>:
.globl vector41
vector41:
  pushl $0
80105346:	6a 00                	push   $0x0
  pushl $41
80105348:	6a 29                	push   $0x29
  jmp alltraps
8010534a:	e9 5b fa ff ff       	jmp    80104daa <alltraps>

8010534f <vector42>:
.globl vector42
vector42:
  pushl $0
8010534f:	6a 00                	push   $0x0
  pushl $42
80105351:	6a 2a                	push   $0x2a
  jmp alltraps
80105353:	e9 52 fa ff ff       	jmp    80104daa <alltraps>

80105358 <vector43>:
.globl vector43
vector43:
  pushl $0
80105358:	6a 00                	push   $0x0
  pushl $43
8010535a:	6a 2b                	push   $0x2b
  jmp alltraps
8010535c:	e9 49 fa ff ff       	jmp    80104daa <alltraps>

80105361 <vector44>:
.globl vector44
vector44:
  pushl $0
80105361:	6a 00                	push   $0x0
  pushl $44
80105363:	6a 2c                	push   $0x2c
  jmp alltraps
80105365:	e9 40 fa ff ff       	jmp    80104daa <alltraps>

8010536a <vector45>:
.globl vector45
vector45:
  pushl $0
8010536a:	6a 00                	push   $0x0
  pushl $45
8010536c:	6a 2d                	push   $0x2d
  jmp alltraps
8010536e:	e9 37 fa ff ff       	jmp    80104daa <alltraps>

80105373 <vector46>:
.globl vector46
vector46:
  pushl $0
80105373:	6a 00                	push   $0x0
  pushl $46
80105375:	6a 2e                	push   $0x2e
  jmp alltraps
80105377:	e9 2e fa ff ff       	jmp    80104daa <alltraps>

8010537c <vector47>:
.globl vector47
vector47:
  pushl $0
8010537c:	6a 00                	push   $0x0
  pushl $47
8010537e:	6a 2f                	push   $0x2f
  jmp alltraps
80105380:	e9 25 fa ff ff       	jmp    80104daa <alltraps>

80105385 <vector48>:
.globl vector48
vector48:
  pushl $0
80105385:	6a 00                	push   $0x0
  pushl $48
80105387:	6a 30                	push   $0x30
  jmp alltraps
80105389:	e9 1c fa ff ff       	jmp    80104daa <alltraps>

8010538e <vector49>:
.globl vector49
vector49:
  pushl $0
8010538e:	6a 00                	push   $0x0
  pushl $49
80105390:	6a 31                	push   $0x31
  jmp alltraps
80105392:	e9 13 fa ff ff       	jmp    80104daa <alltraps>

80105397 <vector50>:
.globl vector50
vector50:
  pushl $0
80105397:	6a 00                	push   $0x0
  pushl $50
80105399:	6a 32                	push   $0x32
  jmp alltraps
8010539b:	e9 0a fa ff ff       	jmp    80104daa <alltraps>

801053a0 <vector51>:
.globl vector51
vector51:
  pushl $0
801053a0:	6a 00                	push   $0x0
  pushl $51
801053a2:	6a 33                	push   $0x33
  jmp alltraps
801053a4:	e9 01 fa ff ff       	jmp    80104daa <alltraps>

801053a9 <vector52>:
.globl vector52
vector52:
  pushl $0
801053a9:	6a 00                	push   $0x0
  pushl $52
801053ab:	6a 34                	push   $0x34
  jmp alltraps
801053ad:	e9 f8 f9 ff ff       	jmp    80104daa <alltraps>

801053b2 <vector53>:
.globl vector53
vector53:
  pushl $0
801053b2:	6a 00                	push   $0x0
  pushl $53
801053b4:	6a 35                	push   $0x35
  jmp alltraps
801053b6:	e9 ef f9 ff ff       	jmp    80104daa <alltraps>

801053bb <vector54>:
.globl vector54
vector54:
  pushl $0
801053bb:	6a 00                	push   $0x0
  pushl $54
801053bd:	6a 36                	push   $0x36
  jmp alltraps
801053bf:	e9 e6 f9 ff ff       	jmp    80104daa <alltraps>

801053c4 <vector55>:
.globl vector55
vector55:
  pushl $0
801053c4:	6a 00                	push   $0x0
  pushl $55
801053c6:	6a 37                	push   $0x37
  jmp alltraps
801053c8:	e9 dd f9 ff ff       	jmp    80104daa <alltraps>

801053cd <vector56>:
.globl vector56
vector56:
  pushl $0
801053cd:	6a 00                	push   $0x0
  pushl $56
801053cf:	6a 38                	push   $0x38
  jmp alltraps
801053d1:	e9 d4 f9 ff ff       	jmp    80104daa <alltraps>

801053d6 <vector57>:
.globl vector57
vector57:
  pushl $0
801053d6:	6a 00                	push   $0x0
  pushl $57
801053d8:	6a 39                	push   $0x39
  jmp alltraps
801053da:	e9 cb f9 ff ff       	jmp    80104daa <alltraps>

801053df <vector58>:
.globl vector58
vector58:
  pushl $0
801053df:	6a 00                	push   $0x0
  pushl $58
801053e1:	6a 3a                	push   $0x3a
  jmp alltraps
801053e3:	e9 c2 f9 ff ff       	jmp    80104daa <alltraps>

801053e8 <vector59>:
.globl vector59
vector59:
  pushl $0
801053e8:	6a 00                	push   $0x0
  pushl $59
801053ea:	6a 3b                	push   $0x3b
  jmp alltraps
801053ec:	e9 b9 f9 ff ff       	jmp    80104daa <alltraps>

801053f1 <vector60>:
.globl vector60
vector60:
  pushl $0
801053f1:	6a 00                	push   $0x0
  pushl $60
801053f3:	6a 3c                	push   $0x3c
  jmp alltraps
801053f5:	e9 b0 f9 ff ff       	jmp    80104daa <alltraps>

801053fa <vector61>:
.globl vector61
vector61:
  pushl $0
801053fa:	6a 00                	push   $0x0
  pushl $61
801053fc:	6a 3d                	push   $0x3d
  jmp alltraps
801053fe:	e9 a7 f9 ff ff       	jmp    80104daa <alltraps>

80105403 <vector62>:
.globl vector62
vector62:
  pushl $0
80105403:	6a 00                	push   $0x0
  pushl $62
80105405:	6a 3e                	push   $0x3e
  jmp alltraps
80105407:	e9 9e f9 ff ff       	jmp    80104daa <alltraps>

8010540c <vector63>:
.globl vector63
vector63:
  pushl $0
8010540c:	6a 00                	push   $0x0
  pushl $63
8010540e:	6a 3f                	push   $0x3f
  jmp alltraps
80105410:	e9 95 f9 ff ff       	jmp    80104daa <alltraps>

80105415 <vector64>:
.globl vector64
vector64:
  pushl $0
80105415:	6a 00                	push   $0x0
  pushl $64
80105417:	6a 40                	push   $0x40
  jmp alltraps
80105419:	e9 8c f9 ff ff       	jmp    80104daa <alltraps>

8010541e <vector65>:
.globl vector65
vector65:
  pushl $0
8010541e:	6a 00                	push   $0x0
  pushl $65
80105420:	6a 41                	push   $0x41
  jmp alltraps
80105422:	e9 83 f9 ff ff       	jmp    80104daa <alltraps>

80105427 <vector66>:
.globl vector66
vector66:
  pushl $0
80105427:	6a 00                	push   $0x0
  pushl $66
80105429:	6a 42                	push   $0x42
  jmp alltraps
8010542b:	e9 7a f9 ff ff       	jmp    80104daa <alltraps>

80105430 <vector67>:
.globl vector67
vector67:
  pushl $0
80105430:	6a 00                	push   $0x0
  pushl $67
80105432:	6a 43                	push   $0x43
  jmp alltraps
80105434:	e9 71 f9 ff ff       	jmp    80104daa <alltraps>

80105439 <vector68>:
.globl vector68
vector68:
  pushl $0
80105439:	6a 00                	push   $0x0
  pushl $68
8010543b:	6a 44                	push   $0x44
  jmp alltraps
8010543d:	e9 68 f9 ff ff       	jmp    80104daa <alltraps>

80105442 <vector69>:
.globl vector69
vector69:
  pushl $0
80105442:	6a 00                	push   $0x0
  pushl $69
80105444:	6a 45                	push   $0x45
  jmp alltraps
80105446:	e9 5f f9 ff ff       	jmp    80104daa <alltraps>

8010544b <vector70>:
.globl vector70
vector70:
  pushl $0
8010544b:	6a 00                	push   $0x0
  pushl $70
8010544d:	6a 46                	push   $0x46
  jmp alltraps
8010544f:	e9 56 f9 ff ff       	jmp    80104daa <alltraps>

80105454 <vector71>:
.globl vector71
vector71:
  pushl $0
80105454:	6a 00                	push   $0x0
  pushl $71
80105456:	6a 47                	push   $0x47
  jmp alltraps
80105458:	e9 4d f9 ff ff       	jmp    80104daa <alltraps>

8010545d <vector72>:
.globl vector72
vector72:
  pushl $0
8010545d:	6a 00                	push   $0x0
  pushl $72
8010545f:	6a 48                	push   $0x48
  jmp alltraps
80105461:	e9 44 f9 ff ff       	jmp    80104daa <alltraps>

80105466 <vector73>:
.globl vector73
vector73:
  pushl $0
80105466:	6a 00                	push   $0x0
  pushl $73
80105468:	6a 49                	push   $0x49
  jmp alltraps
8010546a:	e9 3b f9 ff ff       	jmp    80104daa <alltraps>

8010546f <vector74>:
.globl vector74
vector74:
  pushl $0
8010546f:	6a 00                	push   $0x0
  pushl $74
80105471:	6a 4a                	push   $0x4a
  jmp alltraps
80105473:	e9 32 f9 ff ff       	jmp    80104daa <alltraps>

80105478 <vector75>:
.globl vector75
vector75:
  pushl $0
80105478:	6a 00                	push   $0x0
  pushl $75
8010547a:	6a 4b                	push   $0x4b
  jmp alltraps
8010547c:	e9 29 f9 ff ff       	jmp    80104daa <alltraps>

80105481 <vector76>:
.globl vector76
vector76:
  pushl $0
80105481:	6a 00                	push   $0x0
  pushl $76
80105483:	6a 4c                	push   $0x4c
  jmp alltraps
80105485:	e9 20 f9 ff ff       	jmp    80104daa <alltraps>

8010548a <vector77>:
.globl vector77
vector77:
  pushl $0
8010548a:	6a 00                	push   $0x0
  pushl $77
8010548c:	6a 4d                	push   $0x4d
  jmp alltraps
8010548e:	e9 17 f9 ff ff       	jmp    80104daa <alltraps>

80105493 <vector78>:
.globl vector78
vector78:
  pushl $0
80105493:	6a 00                	push   $0x0
  pushl $78
80105495:	6a 4e                	push   $0x4e
  jmp alltraps
80105497:	e9 0e f9 ff ff       	jmp    80104daa <alltraps>

8010549c <vector79>:
.globl vector79
vector79:
  pushl $0
8010549c:	6a 00                	push   $0x0
  pushl $79
8010549e:	6a 4f                	push   $0x4f
  jmp alltraps
801054a0:	e9 05 f9 ff ff       	jmp    80104daa <alltraps>

801054a5 <vector80>:
.globl vector80
vector80:
  pushl $0
801054a5:	6a 00                	push   $0x0
  pushl $80
801054a7:	6a 50                	push   $0x50
  jmp alltraps
801054a9:	e9 fc f8 ff ff       	jmp    80104daa <alltraps>

801054ae <vector81>:
.globl vector81
vector81:
  pushl $0
801054ae:	6a 00                	push   $0x0
  pushl $81
801054b0:	6a 51                	push   $0x51
  jmp alltraps
801054b2:	e9 f3 f8 ff ff       	jmp    80104daa <alltraps>

801054b7 <vector82>:
.globl vector82
vector82:
  pushl $0
801054b7:	6a 00                	push   $0x0
  pushl $82
801054b9:	6a 52                	push   $0x52
  jmp alltraps
801054bb:	e9 ea f8 ff ff       	jmp    80104daa <alltraps>

801054c0 <vector83>:
.globl vector83
vector83:
  pushl $0
801054c0:	6a 00                	push   $0x0
  pushl $83
801054c2:	6a 53                	push   $0x53
  jmp alltraps
801054c4:	e9 e1 f8 ff ff       	jmp    80104daa <alltraps>

801054c9 <vector84>:
.globl vector84
vector84:
  pushl $0
801054c9:	6a 00                	push   $0x0
  pushl $84
801054cb:	6a 54                	push   $0x54
  jmp alltraps
801054cd:	e9 d8 f8 ff ff       	jmp    80104daa <alltraps>

801054d2 <vector85>:
.globl vector85
vector85:
  pushl $0
801054d2:	6a 00                	push   $0x0
  pushl $85
801054d4:	6a 55                	push   $0x55
  jmp alltraps
801054d6:	e9 cf f8 ff ff       	jmp    80104daa <alltraps>

801054db <vector86>:
.globl vector86
vector86:
  pushl $0
801054db:	6a 00                	push   $0x0
  pushl $86
801054dd:	6a 56                	push   $0x56
  jmp alltraps
801054df:	e9 c6 f8 ff ff       	jmp    80104daa <alltraps>

801054e4 <vector87>:
.globl vector87
vector87:
  pushl $0
801054e4:	6a 00                	push   $0x0
  pushl $87
801054e6:	6a 57                	push   $0x57
  jmp alltraps
801054e8:	e9 bd f8 ff ff       	jmp    80104daa <alltraps>

801054ed <vector88>:
.globl vector88
vector88:
  pushl $0
801054ed:	6a 00                	push   $0x0
  pushl $88
801054ef:	6a 58                	push   $0x58
  jmp alltraps
801054f1:	e9 b4 f8 ff ff       	jmp    80104daa <alltraps>

801054f6 <vector89>:
.globl vector89
vector89:
  pushl $0
801054f6:	6a 00                	push   $0x0
  pushl $89
801054f8:	6a 59                	push   $0x59
  jmp alltraps
801054fa:	e9 ab f8 ff ff       	jmp    80104daa <alltraps>

801054ff <vector90>:
.globl vector90
vector90:
  pushl $0
801054ff:	6a 00                	push   $0x0
  pushl $90
80105501:	6a 5a                	push   $0x5a
  jmp alltraps
80105503:	e9 a2 f8 ff ff       	jmp    80104daa <alltraps>

80105508 <vector91>:
.globl vector91
vector91:
  pushl $0
80105508:	6a 00                	push   $0x0
  pushl $91
8010550a:	6a 5b                	push   $0x5b
  jmp alltraps
8010550c:	e9 99 f8 ff ff       	jmp    80104daa <alltraps>

80105511 <vector92>:
.globl vector92
vector92:
  pushl $0
80105511:	6a 00                	push   $0x0
  pushl $92
80105513:	6a 5c                	push   $0x5c
  jmp alltraps
80105515:	e9 90 f8 ff ff       	jmp    80104daa <alltraps>

8010551a <vector93>:
.globl vector93
vector93:
  pushl $0
8010551a:	6a 00                	push   $0x0
  pushl $93
8010551c:	6a 5d                	push   $0x5d
  jmp alltraps
8010551e:	e9 87 f8 ff ff       	jmp    80104daa <alltraps>

80105523 <vector94>:
.globl vector94
vector94:
  pushl $0
80105523:	6a 00                	push   $0x0
  pushl $94
80105525:	6a 5e                	push   $0x5e
  jmp alltraps
80105527:	e9 7e f8 ff ff       	jmp    80104daa <alltraps>

8010552c <vector95>:
.globl vector95
vector95:
  pushl $0
8010552c:	6a 00                	push   $0x0
  pushl $95
8010552e:	6a 5f                	push   $0x5f
  jmp alltraps
80105530:	e9 75 f8 ff ff       	jmp    80104daa <alltraps>

80105535 <vector96>:
.globl vector96
vector96:
  pushl $0
80105535:	6a 00                	push   $0x0
  pushl $96
80105537:	6a 60                	push   $0x60
  jmp alltraps
80105539:	e9 6c f8 ff ff       	jmp    80104daa <alltraps>

8010553e <vector97>:
.globl vector97
vector97:
  pushl $0
8010553e:	6a 00                	push   $0x0
  pushl $97
80105540:	6a 61                	push   $0x61
  jmp alltraps
80105542:	e9 63 f8 ff ff       	jmp    80104daa <alltraps>

80105547 <vector98>:
.globl vector98
vector98:
  pushl $0
80105547:	6a 00                	push   $0x0
  pushl $98
80105549:	6a 62                	push   $0x62
  jmp alltraps
8010554b:	e9 5a f8 ff ff       	jmp    80104daa <alltraps>

80105550 <vector99>:
.globl vector99
vector99:
  pushl $0
80105550:	6a 00                	push   $0x0
  pushl $99
80105552:	6a 63                	push   $0x63
  jmp alltraps
80105554:	e9 51 f8 ff ff       	jmp    80104daa <alltraps>

80105559 <vector100>:
.globl vector100
vector100:
  pushl $0
80105559:	6a 00                	push   $0x0
  pushl $100
8010555b:	6a 64                	push   $0x64
  jmp alltraps
8010555d:	e9 48 f8 ff ff       	jmp    80104daa <alltraps>

80105562 <vector101>:
.globl vector101
vector101:
  pushl $0
80105562:	6a 00                	push   $0x0
  pushl $101
80105564:	6a 65                	push   $0x65
  jmp alltraps
80105566:	e9 3f f8 ff ff       	jmp    80104daa <alltraps>

8010556b <vector102>:
.globl vector102
vector102:
  pushl $0
8010556b:	6a 00                	push   $0x0
  pushl $102
8010556d:	6a 66                	push   $0x66
  jmp alltraps
8010556f:	e9 36 f8 ff ff       	jmp    80104daa <alltraps>

80105574 <vector103>:
.globl vector103
vector103:
  pushl $0
80105574:	6a 00                	push   $0x0
  pushl $103
80105576:	6a 67                	push   $0x67
  jmp alltraps
80105578:	e9 2d f8 ff ff       	jmp    80104daa <alltraps>

8010557d <vector104>:
.globl vector104
vector104:
  pushl $0
8010557d:	6a 00                	push   $0x0
  pushl $104
8010557f:	6a 68                	push   $0x68
  jmp alltraps
80105581:	e9 24 f8 ff ff       	jmp    80104daa <alltraps>

80105586 <vector105>:
.globl vector105
vector105:
  pushl $0
80105586:	6a 00                	push   $0x0
  pushl $105
80105588:	6a 69                	push   $0x69
  jmp alltraps
8010558a:	e9 1b f8 ff ff       	jmp    80104daa <alltraps>

8010558f <vector106>:
.globl vector106
vector106:
  pushl $0
8010558f:	6a 00                	push   $0x0
  pushl $106
80105591:	6a 6a                	push   $0x6a
  jmp alltraps
80105593:	e9 12 f8 ff ff       	jmp    80104daa <alltraps>

80105598 <vector107>:
.globl vector107
vector107:
  pushl $0
80105598:	6a 00                	push   $0x0
  pushl $107
8010559a:	6a 6b                	push   $0x6b
  jmp alltraps
8010559c:	e9 09 f8 ff ff       	jmp    80104daa <alltraps>

801055a1 <vector108>:
.globl vector108
vector108:
  pushl $0
801055a1:	6a 00                	push   $0x0
  pushl $108
801055a3:	6a 6c                	push   $0x6c
  jmp alltraps
801055a5:	e9 00 f8 ff ff       	jmp    80104daa <alltraps>

801055aa <vector109>:
.globl vector109
vector109:
  pushl $0
801055aa:	6a 00                	push   $0x0
  pushl $109
801055ac:	6a 6d                	push   $0x6d
  jmp alltraps
801055ae:	e9 f7 f7 ff ff       	jmp    80104daa <alltraps>

801055b3 <vector110>:
.globl vector110
vector110:
  pushl $0
801055b3:	6a 00                	push   $0x0
  pushl $110
801055b5:	6a 6e                	push   $0x6e
  jmp alltraps
801055b7:	e9 ee f7 ff ff       	jmp    80104daa <alltraps>

801055bc <vector111>:
.globl vector111
vector111:
  pushl $0
801055bc:	6a 00                	push   $0x0
  pushl $111
801055be:	6a 6f                	push   $0x6f
  jmp alltraps
801055c0:	e9 e5 f7 ff ff       	jmp    80104daa <alltraps>

801055c5 <vector112>:
.globl vector112
vector112:
  pushl $0
801055c5:	6a 00                	push   $0x0
  pushl $112
801055c7:	6a 70                	push   $0x70
  jmp alltraps
801055c9:	e9 dc f7 ff ff       	jmp    80104daa <alltraps>

801055ce <vector113>:
.globl vector113
vector113:
  pushl $0
801055ce:	6a 00                	push   $0x0
  pushl $113
801055d0:	6a 71                	push   $0x71
  jmp alltraps
801055d2:	e9 d3 f7 ff ff       	jmp    80104daa <alltraps>

801055d7 <vector114>:
.globl vector114
vector114:
  pushl $0
801055d7:	6a 00                	push   $0x0
  pushl $114
801055d9:	6a 72                	push   $0x72
  jmp alltraps
801055db:	e9 ca f7 ff ff       	jmp    80104daa <alltraps>

801055e0 <vector115>:
.globl vector115
vector115:
  pushl $0
801055e0:	6a 00                	push   $0x0
  pushl $115
801055e2:	6a 73                	push   $0x73
  jmp alltraps
801055e4:	e9 c1 f7 ff ff       	jmp    80104daa <alltraps>

801055e9 <vector116>:
.globl vector116
vector116:
  pushl $0
801055e9:	6a 00                	push   $0x0
  pushl $116
801055eb:	6a 74                	push   $0x74
  jmp alltraps
801055ed:	e9 b8 f7 ff ff       	jmp    80104daa <alltraps>

801055f2 <vector117>:
.globl vector117
vector117:
  pushl $0
801055f2:	6a 00                	push   $0x0
  pushl $117
801055f4:	6a 75                	push   $0x75
  jmp alltraps
801055f6:	e9 af f7 ff ff       	jmp    80104daa <alltraps>

801055fb <vector118>:
.globl vector118
vector118:
  pushl $0
801055fb:	6a 00                	push   $0x0
  pushl $118
801055fd:	6a 76                	push   $0x76
  jmp alltraps
801055ff:	e9 a6 f7 ff ff       	jmp    80104daa <alltraps>

80105604 <vector119>:
.globl vector119
vector119:
  pushl $0
80105604:	6a 00                	push   $0x0
  pushl $119
80105606:	6a 77                	push   $0x77
  jmp alltraps
80105608:	e9 9d f7 ff ff       	jmp    80104daa <alltraps>

8010560d <vector120>:
.globl vector120
vector120:
  pushl $0
8010560d:	6a 00                	push   $0x0
  pushl $120
8010560f:	6a 78                	push   $0x78
  jmp alltraps
80105611:	e9 94 f7 ff ff       	jmp    80104daa <alltraps>

80105616 <vector121>:
.globl vector121
vector121:
  pushl $0
80105616:	6a 00                	push   $0x0
  pushl $121
80105618:	6a 79                	push   $0x79
  jmp alltraps
8010561a:	e9 8b f7 ff ff       	jmp    80104daa <alltraps>

8010561f <vector122>:
.globl vector122
vector122:
  pushl $0
8010561f:	6a 00                	push   $0x0
  pushl $122
80105621:	6a 7a                	push   $0x7a
  jmp alltraps
80105623:	e9 82 f7 ff ff       	jmp    80104daa <alltraps>

80105628 <vector123>:
.globl vector123
vector123:
  pushl $0
80105628:	6a 00                	push   $0x0
  pushl $123
8010562a:	6a 7b                	push   $0x7b
  jmp alltraps
8010562c:	e9 79 f7 ff ff       	jmp    80104daa <alltraps>

80105631 <vector124>:
.globl vector124
vector124:
  pushl $0
80105631:	6a 00                	push   $0x0
  pushl $124
80105633:	6a 7c                	push   $0x7c
  jmp alltraps
80105635:	e9 70 f7 ff ff       	jmp    80104daa <alltraps>

8010563a <vector125>:
.globl vector125
vector125:
  pushl $0
8010563a:	6a 00                	push   $0x0
  pushl $125
8010563c:	6a 7d                	push   $0x7d
  jmp alltraps
8010563e:	e9 67 f7 ff ff       	jmp    80104daa <alltraps>

80105643 <vector126>:
.globl vector126
vector126:
  pushl $0
80105643:	6a 00                	push   $0x0
  pushl $126
80105645:	6a 7e                	push   $0x7e
  jmp alltraps
80105647:	e9 5e f7 ff ff       	jmp    80104daa <alltraps>

8010564c <vector127>:
.globl vector127
vector127:
  pushl $0
8010564c:	6a 00                	push   $0x0
  pushl $127
8010564e:	6a 7f                	push   $0x7f
  jmp alltraps
80105650:	e9 55 f7 ff ff       	jmp    80104daa <alltraps>

80105655 <vector128>:
.globl vector128
vector128:
  pushl $0
80105655:	6a 00                	push   $0x0
  pushl $128
80105657:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010565c:	e9 49 f7 ff ff       	jmp    80104daa <alltraps>

80105661 <vector129>:
.globl vector129
vector129:
  pushl $0
80105661:	6a 00                	push   $0x0
  pushl $129
80105663:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105668:	e9 3d f7 ff ff       	jmp    80104daa <alltraps>

8010566d <vector130>:
.globl vector130
vector130:
  pushl $0
8010566d:	6a 00                	push   $0x0
  pushl $130
8010566f:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105674:	e9 31 f7 ff ff       	jmp    80104daa <alltraps>

80105679 <vector131>:
.globl vector131
vector131:
  pushl $0
80105679:	6a 00                	push   $0x0
  pushl $131
8010567b:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105680:	e9 25 f7 ff ff       	jmp    80104daa <alltraps>

80105685 <vector132>:
.globl vector132
vector132:
  pushl $0
80105685:	6a 00                	push   $0x0
  pushl $132
80105687:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010568c:	e9 19 f7 ff ff       	jmp    80104daa <alltraps>

80105691 <vector133>:
.globl vector133
vector133:
  pushl $0
80105691:	6a 00                	push   $0x0
  pushl $133
80105693:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105698:	e9 0d f7 ff ff       	jmp    80104daa <alltraps>

8010569d <vector134>:
.globl vector134
vector134:
  pushl $0
8010569d:	6a 00                	push   $0x0
  pushl $134
8010569f:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801056a4:	e9 01 f7 ff ff       	jmp    80104daa <alltraps>

801056a9 <vector135>:
.globl vector135
vector135:
  pushl $0
801056a9:	6a 00                	push   $0x0
  pushl $135
801056ab:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801056b0:	e9 f5 f6 ff ff       	jmp    80104daa <alltraps>

801056b5 <vector136>:
.globl vector136
vector136:
  pushl $0
801056b5:	6a 00                	push   $0x0
  pushl $136
801056b7:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801056bc:	e9 e9 f6 ff ff       	jmp    80104daa <alltraps>

801056c1 <vector137>:
.globl vector137
vector137:
  pushl $0
801056c1:	6a 00                	push   $0x0
  pushl $137
801056c3:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801056c8:	e9 dd f6 ff ff       	jmp    80104daa <alltraps>

801056cd <vector138>:
.globl vector138
vector138:
  pushl $0
801056cd:	6a 00                	push   $0x0
  pushl $138
801056cf:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801056d4:	e9 d1 f6 ff ff       	jmp    80104daa <alltraps>

801056d9 <vector139>:
.globl vector139
vector139:
  pushl $0
801056d9:	6a 00                	push   $0x0
  pushl $139
801056db:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801056e0:	e9 c5 f6 ff ff       	jmp    80104daa <alltraps>

801056e5 <vector140>:
.globl vector140
vector140:
  pushl $0
801056e5:	6a 00                	push   $0x0
  pushl $140
801056e7:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801056ec:	e9 b9 f6 ff ff       	jmp    80104daa <alltraps>

801056f1 <vector141>:
.globl vector141
vector141:
  pushl $0
801056f1:	6a 00                	push   $0x0
  pushl $141
801056f3:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801056f8:	e9 ad f6 ff ff       	jmp    80104daa <alltraps>

801056fd <vector142>:
.globl vector142
vector142:
  pushl $0
801056fd:	6a 00                	push   $0x0
  pushl $142
801056ff:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105704:	e9 a1 f6 ff ff       	jmp    80104daa <alltraps>

80105709 <vector143>:
.globl vector143
vector143:
  pushl $0
80105709:	6a 00                	push   $0x0
  pushl $143
8010570b:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105710:	e9 95 f6 ff ff       	jmp    80104daa <alltraps>

80105715 <vector144>:
.globl vector144
vector144:
  pushl $0
80105715:	6a 00                	push   $0x0
  pushl $144
80105717:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010571c:	e9 89 f6 ff ff       	jmp    80104daa <alltraps>

80105721 <vector145>:
.globl vector145
vector145:
  pushl $0
80105721:	6a 00                	push   $0x0
  pushl $145
80105723:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105728:	e9 7d f6 ff ff       	jmp    80104daa <alltraps>

8010572d <vector146>:
.globl vector146
vector146:
  pushl $0
8010572d:	6a 00                	push   $0x0
  pushl $146
8010572f:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105734:	e9 71 f6 ff ff       	jmp    80104daa <alltraps>

80105739 <vector147>:
.globl vector147
vector147:
  pushl $0
80105739:	6a 00                	push   $0x0
  pushl $147
8010573b:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105740:	e9 65 f6 ff ff       	jmp    80104daa <alltraps>

80105745 <vector148>:
.globl vector148
vector148:
  pushl $0
80105745:	6a 00                	push   $0x0
  pushl $148
80105747:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010574c:	e9 59 f6 ff ff       	jmp    80104daa <alltraps>

80105751 <vector149>:
.globl vector149
vector149:
  pushl $0
80105751:	6a 00                	push   $0x0
  pushl $149
80105753:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105758:	e9 4d f6 ff ff       	jmp    80104daa <alltraps>

8010575d <vector150>:
.globl vector150
vector150:
  pushl $0
8010575d:	6a 00                	push   $0x0
  pushl $150
8010575f:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105764:	e9 41 f6 ff ff       	jmp    80104daa <alltraps>

80105769 <vector151>:
.globl vector151
vector151:
  pushl $0
80105769:	6a 00                	push   $0x0
  pushl $151
8010576b:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105770:	e9 35 f6 ff ff       	jmp    80104daa <alltraps>

80105775 <vector152>:
.globl vector152
vector152:
  pushl $0
80105775:	6a 00                	push   $0x0
  pushl $152
80105777:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010577c:	e9 29 f6 ff ff       	jmp    80104daa <alltraps>

80105781 <vector153>:
.globl vector153
vector153:
  pushl $0
80105781:	6a 00                	push   $0x0
  pushl $153
80105783:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105788:	e9 1d f6 ff ff       	jmp    80104daa <alltraps>

8010578d <vector154>:
.globl vector154
vector154:
  pushl $0
8010578d:	6a 00                	push   $0x0
  pushl $154
8010578f:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105794:	e9 11 f6 ff ff       	jmp    80104daa <alltraps>

80105799 <vector155>:
.globl vector155
vector155:
  pushl $0
80105799:	6a 00                	push   $0x0
  pushl $155
8010579b:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801057a0:	e9 05 f6 ff ff       	jmp    80104daa <alltraps>

801057a5 <vector156>:
.globl vector156
vector156:
  pushl $0
801057a5:	6a 00                	push   $0x0
  pushl $156
801057a7:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801057ac:	e9 f9 f5 ff ff       	jmp    80104daa <alltraps>

801057b1 <vector157>:
.globl vector157
vector157:
  pushl $0
801057b1:	6a 00                	push   $0x0
  pushl $157
801057b3:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801057b8:	e9 ed f5 ff ff       	jmp    80104daa <alltraps>

801057bd <vector158>:
.globl vector158
vector158:
  pushl $0
801057bd:	6a 00                	push   $0x0
  pushl $158
801057bf:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801057c4:	e9 e1 f5 ff ff       	jmp    80104daa <alltraps>

801057c9 <vector159>:
.globl vector159
vector159:
  pushl $0
801057c9:	6a 00                	push   $0x0
  pushl $159
801057cb:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801057d0:	e9 d5 f5 ff ff       	jmp    80104daa <alltraps>

801057d5 <vector160>:
.globl vector160
vector160:
  pushl $0
801057d5:	6a 00                	push   $0x0
  pushl $160
801057d7:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801057dc:	e9 c9 f5 ff ff       	jmp    80104daa <alltraps>

801057e1 <vector161>:
.globl vector161
vector161:
  pushl $0
801057e1:	6a 00                	push   $0x0
  pushl $161
801057e3:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801057e8:	e9 bd f5 ff ff       	jmp    80104daa <alltraps>

801057ed <vector162>:
.globl vector162
vector162:
  pushl $0
801057ed:	6a 00                	push   $0x0
  pushl $162
801057ef:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801057f4:	e9 b1 f5 ff ff       	jmp    80104daa <alltraps>

801057f9 <vector163>:
.globl vector163
vector163:
  pushl $0
801057f9:	6a 00                	push   $0x0
  pushl $163
801057fb:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105800:	e9 a5 f5 ff ff       	jmp    80104daa <alltraps>

80105805 <vector164>:
.globl vector164
vector164:
  pushl $0
80105805:	6a 00                	push   $0x0
  pushl $164
80105807:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010580c:	e9 99 f5 ff ff       	jmp    80104daa <alltraps>

80105811 <vector165>:
.globl vector165
vector165:
  pushl $0
80105811:	6a 00                	push   $0x0
  pushl $165
80105813:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105818:	e9 8d f5 ff ff       	jmp    80104daa <alltraps>

8010581d <vector166>:
.globl vector166
vector166:
  pushl $0
8010581d:	6a 00                	push   $0x0
  pushl $166
8010581f:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105824:	e9 81 f5 ff ff       	jmp    80104daa <alltraps>

80105829 <vector167>:
.globl vector167
vector167:
  pushl $0
80105829:	6a 00                	push   $0x0
  pushl $167
8010582b:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105830:	e9 75 f5 ff ff       	jmp    80104daa <alltraps>

80105835 <vector168>:
.globl vector168
vector168:
  pushl $0
80105835:	6a 00                	push   $0x0
  pushl $168
80105837:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010583c:	e9 69 f5 ff ff       	jmp    80104daa <alltraps>

80105841 <vector169>:
.globl vector169
vector169:
  pushl $0
80105841:	6a 00                	push   $0x0
  pushl $169
80105843:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105848:	e9 5d f5 ff ff       	jmp    80104daa <alltraps>

8010584d <vector170>:
.globl vector170
vector170:
  pushl $0
8010584d:	6a 00                	push   $0x0
  pushl $170
8010584f:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105854:	e9 51 f5 ff ff       	jmp    80104daa <alltraps>

80105859 <vector171>:
.globl vector171
vector171:
  pushl $0
80105859:	6a 00                	push   $0x0
  pushl $171
8010585b:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105860:	e9 45 f5 ff ff       	jmp    80104daa <alltraps>

80105865 <vector172>:
.globl vector172
vector172:
  pushl $0
80105865:	6a 00                	push   $0x0
  pushl $172
80105867:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010586c:	e9 39 f5 ff ff       	jmp    80104daa <alltraps>

80105871 <vector173>:
.globl vector173
vector173:
  pushl $0
80105871:	6a 00                	push   $0x0
  pushl $173
80105873:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105878:	e9 2d f5 ff ff       	jmp    80104daa <alltraps>

8010587d <vector174>:
.globl vector174
vector174:
  pushl $0
8010587d:	6a 00                	push   $0x0
  pushl $174
8010587f:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105884:	e9 21 f5 ff ff       	jmp    80104daa <alltraps>

80105889 <vector175>:
.globl vector175
vector175:
  pushl $0
80105889:	6a 00                	push   $0x0
  pushl $175
8010588b:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105890:	e9 15 f5 ff ff       	jmp    80104daa <alltraps>

80105895 <vector176>:
.globl vector176
vector176:
  pushl $0
80105895:	6a 00                	push   $0x0
  pushl $176
80105897:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010589c:	e9 09 f5 ff ff       	jmp    80104daa <alltraps>

801058a1 <vector177>:
.globl vector177
vector177:
  pushl $0
801058a1:	6a 00                	push   $0x0
  pushl $177
801058a3:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801058a8:	e9 fd f4 ff ff       	jmp    80104daa <alltraps>

801058ad <vector178>:
.globl vector178
vector178:
  pushl $0
801058ad:	6a 00                	push   $0x0
  pushl $178
801058af:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801058b4:	e9 f1 f4 ff ff       	jmp    80104daa <alltraps>

801058b9 <vector179>:
.globl vector179
vector179:
  pushl $0
801058b9:	6a 00                	push   $0x0
  pushl $179
801058bb:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801058c0:	e9 e5 f4 ff ff       	jmp    80104daa <alltraps>

801058c5 <vector180>:
.globl vector180
vector180:
  pushl $0
801058c5:	6a 00                	push   $0x0
  pushl $180
801058c7:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801058cc:	e9 d9 f4 ff ff       	jmp    80104daa <alltraps>

801058d1 <vector181>:
.globl vector181
vector181:
  pushl $0
801058d1:	6a 00                	push   $0x0
  pushl $181
801058d3:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801058d8:	e9 cd f4 ff ff       	jmp    80104daa <alltraps>

801058dd <vector182>:
.globl vector182
vector182:
  pushl $0
801058dd:	6a 00                	push   $0x0
  pushl $182
801058df:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801058e4:	e9 c1 f4 ff ff       	jmp    80104daa <alltraps>

801058e9 <vector183>:
.globl vector183
vector183:
  pushl $0
801058e9:	6a 00                	push   $0x0
  pushl $183
801058eb:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801058f0:	e9 b5 f4 ff ff       	jmp    80104daa <alltraps>

801058f5 <vector184>:
.globl vector184
vector184:
  pushl $0
801058f5:	6a 00                	push   $0x0
  pushl $184
801058f7:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801058fc:	e9 a9 f4 ff ff       	jmp    80104daa <alltraps>

80105901 <vector185>:
.globl vector185
vector185:
  pushl $0
80105901:	6a 00                	push   $0x0
  pushl $185
80105903:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105908:	e9 9d f4 ff ff       	jmp    80104daa <alltraps>

8010590d <vector186>:
.globl vector186
vector186:
  pushl $0
8010590d:	6a 00                	push   $0x0
  pushl $186
8010590f:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105914:	e9 91 f4 ff ff       	jmp    80104daa <alltraps>

80105919 <vector187>:
.globl vector187
vector187:
  pushl $0
80105919:	6a 00                	push   $0x0
  pushl $187
8010591b:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105920:	e9 85 f4 ff ff       	jmp    80104daa <alltraps>

80105925 <vector188>:
.globl vector188
vector188:
  pushl $0
80105925:	6a 00                	push   $0x0
  pushl $188
80105927:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010592c:	e9 79 f4 ff ff       	jmp    80104daa <alltraps>

80105931 <vector189>:
.globl vector189
vector189:
  pushl $0
80105931:	6a 00                	push   $0x0
  pushl $189
80105933:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105938:	e9 6d f4 ff ff       	jmp    80104daa <alltraps>

8010593d <vector190>:
.globl vector190
vector190:
  pushl $0
8010593d:	6a 00                	push   $0x0
  pushl $190
8010593f:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105944:	e9 61 f4 ff ff       	jmp    80104daa <alltraps>

80105949 <vector191>:
.globl vector191
vector191:
  pushl $0
80105949:	6a 00                	push   $0x0
  pushl $191
8010594b:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105950:	e9 55 f4 ff ff       	jmp    80104daa <alltraps>

80105955 <vector192>:
.globl vector192
vector192:
  pushl $0
80105955:	6a 00                	push   $0x0
  pushl $192
80105957:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010595c:	e9 49 f4 ff ff       	jmp    80104daa <alltraps>

80105961 <vector193>:
.globl vector193
vector193:
  pushl $0
80105961:	6a 00                	push   $0x0
  pushl $193
80105963:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105968:	e9 3d f4 ff ff       	jmp    80104daa <alltraps>

8010596d <vector194>:
.globl vector194
vector194:
  pushl $0
8010596d:	6a 00                	push   $0x0
  pushl $194
8010596f:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105974:	e9 31 f4 ff ff       	jmp    80104daa <alltraps>

80105979 <vector195>:
.globl vector195
vector195:
  pushl $0
80105979:	6a 00                	push   $0x0
  pushl $195
8010597b:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105980:	e9 25 f4 ff ff       	jmp    80104daa <alltraps>

80105985 <vector196>:
.globl vector196
vector196:
  pushl $0
80105985:	6a 00                	push   $0x0
  pushl $196
80105987:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010598c:	e9 19 f4 ff ff       	jmp    80104daa <alltraps>

80105991 <vector197>:
.globl vector197
vector197:
  pushl $0
80105991:	6a 00                	push   $0x0
  pushl $197
80105993:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105998:	e9 0d f4 ff ff       	jmp    80104daa <alltraps>

8010599d <vector198>:
.globl vector198
vector198:
  pushl $0
8010599d:	6a 00                	push   $0x0
  pushl $198
8010599f:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801059a4:	e9 01 f4 ff ff       	jmp    80104daa <alltraps>

801059a9 <vector199>:
.globl vector199
vector199:
  pushl $0
801059a9:	6a 00                	push   $0x0
  pushl $199
801059ab:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801059b0:	e9 f5 f3 ff ff       	jmp    80104daa <alltraps>

801059b5 <vector200>:
.globl vector200
vector200:
  pushl $0
801059b5:	6a 00                	push   $0x0
  pushl $200
801059b7:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801059bc:	e9 e9 f3 ff ff       	jmp    80104daa <alltraps>

801059c1 <vector201>:
.globl vector201
vector201:
  pushl $0
801059c1:	6a 00                	push   $0x0
  pushl $201
801059c3:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801059c8:	e9 dd f3 ff ff       	jmp    80104daa <alltraps>

801059cd <vector202>:
.globl vector202
vector202:
  pushl $0
801059cd:	6a 00                	push   $0x0
  pushl $202
801059cf:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801059d4:	e9 d1 f3 ff ff       	jmp    80104daa <alltraps>

801059d9 <vector203>:
.globl vector203
vector203:
  pushl $0
801059d9:	6a 00                	push   $0x0
  pushl $203
801059db:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801059e0:	e9 c5 f3 ff ff       	jmp    80104daa <alltraps>

801059e5 <vector204>:
.globl vector204
vector204:
  pushl $0
801059e5:	6a 00                	push   $0x0
  pushl $204
801059e7:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801059ec:	e9 b9 f3 ff ff       	jmp    80104daa <alltraps>

801059f1 <vector205>:
.globl vector205
vector205:
  pushl $0
801059f1:	6a 00                	push   $0x0
  pushl $205
801059f3:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801059f8:	e9 ad f3 ff ff       	jmp    80104daa <alltraps>

801059fd <vector206>:
.globl vector206
vector206:
  pushl $0
801059fd:	6a 00                	push   $0x0
  pushl $206
801059ff:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105a04:	e9 a1 f3 ff ff       	jmp    80104daa <alltraps>

80105a09 <vector207>:
.globl vector207
vector207:
  pushl $0
80105a09:	6a 00                	push   $0x0
  pushl $207
80105a0b:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105a10:	e9 95 f3 ff ff       	jmp    80104daa <alltraps>

80105a15 <vector208>:
.globl vector208
vector208:
  pushl $0
80105a15:	6a 00                	push   $0x0
  pushl $208
80105a17:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105a1c:	e9 89 f3 ff ff       	jmp    80104daa <alltraps>

80105a21 <vector209>:
.globl vector209
vector209:
  pushl $0
80105a21:	6a 00                	push   $0x0
  pushl $209
80105a23:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105a28:	e9 7d f3 ff ff       	jmp    80104daa <alltraps>

80105a2d <vector210>:
.globl vector210
vector210:
  pushl $0
80105a2d:	6a 00                	push   $0x0
  pushl $210
80105a2f:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105a34:	e9 71 f3 ff ff       	jmp    80104daa <alltraps>

80105a39 <vector211>:
.globl vector211
vector211:
  pushl $0
80105a39:	6a 00                	push   $0x0
  pushl $211
80105a3b:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105a40:	e9 65 f3 ff ff       	jmp    80104daa <alltraps>

80105a45 <vector212>:
.globl vector212
vector212:
  pushl $0
80105a45:	6a 00                	push   $0x0
  pushl $212
80105a47:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105a4c:	e9 59 f3 ff ff       	jmp    80104daa <alltraps>

80105a51 <vector213>:
.globl vector213
vector213:
  pushl $0
80105a51:	6a 00                	push   $0x0
  pushl $213
80105a53:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105a58:	e9 4d f3 ff ff       	jmp    80104daa <alltraps>

80105a5d <vector214>:
.globl vector214
vector214:
  pushl $0
80105a5d:	6a 00                	push   $0x0
  pushl $214
80105a5f:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105a64:	e9 41 f3 ff ff       	jmp    80104daa <alltraps>

80105a69 <vector215>:
.globl vector215
vector215:
  pushl $0
80105a69:	6a 00                	push   $0x0
  pushl $215
80105a6b:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105a70:	e9 35 f3 ff ff       	jmp    80104daa <alltraps>

80105a75 <vector216>:
.globl vector216
vector216:
  pushl $0
80105a75:	6a 00                	push   $0x0
  pushl $216
80105a77:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105a7c:	e9 29 f3 ff ff       	jmp    80104daa <alltraps>

80105a81 <vector217>:
.globl vector217
vector217:
  pushl $0
80105a81:	6a 00                	push   $0x0
  pushl $217
80105a83:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105a88:	e9 1d f3 ff ff       	jmp    80104daa <alltraps>

80105a8d <vector218>:
.globl vector218
vector218:
  pushl $0
80105a8d:	6a 00                	push   $0x0
  pushl $218
80105a8f:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105a94:	e9 11 f3 ff ff       	jmp    80104daa <alltraps>

80105a99 <vector219>:
.globl vector219
vector219:
  pushl $0
80105a99:	6a 00                	push   $0x0
  pushl $219
80105a9b:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105aa0:	e9 05 f3 ff ff       	jmp    80104daa <alltraps>

80105aa5 <vector220>:
.globl vector220
vector220:
  pushl $0
80105aa5:	6a 00                	push   $0x0
  pushl $220
80105aa7:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105aac:	e9 f9 f2 ff ff       	jmp    80104daa <alltraps>

80105ab1 <vector221>:
.globl vector221
vector221:
  pushl $0
80105ab1:	6a 00                	push   $0x0
  pushl $221
80105ab3:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105ab8:	e9 ed f2 ff ff       	jmp    80104daa <alltraps>

80105abd <vector222>:
.globl vector222
vector222:
  pushl $0
80105abd:	6a 00                	push   $0x0
  pushl $222
80105abf:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105ac4:	e9 e1 f2 ff ff       	jmp    80104daa <alltraps>

80105ac9 <vector223>:
.globl vector223
vector223:
  pushl $0
80105ac9:	6a 00                	push   $0x0
  pushl $223
80105acb:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105ad0:	e9 d5 f2 ff ff       	jmp    80104daa <alltraps>

80105ad5 <vector224>:
.globl vector224
vector224:
  pushl $0
80105ad5:	6a 00                	push   $0x0
  pushl $224
80105ad7:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105adc:	e9 c9 f2 ff ff       	jmp    80104daa <alltraps>

80105ae1 <vector225>:
.globl vector225
vector225:
  pushl $0
80105ae1:	6a 00                	push   $0x0
  pushl $225
80105ae3:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105ae8:	e9 bd f2 ff ff       	jmp    80104daa <alltraps>

80105aed <vector226>:
.globl vector226
vector226:
  pushl $0
80105aed:	6a 00                	push   $0x0
  pushl $226
80105aef:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105af4:	e9 b1 f2 ff ff       	jmp    80104daa <alltraps>

80105af9 <vector227>:
.globl vector227
vector227:
  pushl $0
80105af9:	6a 00                	push   $0x0
  pushl $227
80105afb:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105b00:	e9 a5 f2 ff ff       	jmp    80104daa <alltraps>

80105b05 <vector228>:
.globl vector228
vector228:
  pushl $0
80105b05:	6a 00                	push   $0x0
  pushl $228
80105b07:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105b0c:	e9 99 f2 ff ff       	jmp    80104daa <alltraps>

80105b11 <vector229>:
.globl vector229
vector229:
  pushl $0
80105b11:	6a 00                	push   $0x0
  pushl $229
80105b13:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105b18:	e9 8d f2 ff ff       	jmp    80104daa <alltraps>

80105b1d <vector230>:
.globl vector230
vector230:
  pushl $0
80105b1d:	6a 00                	push   $0x0
  pushl $230
80105b1f:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105b24:	e9 81 f2 ff ff       	jmp    80104daa <alltraps>

80105b29 <vector231>:
.globl vector231
vector231:
  pushl $0
80105b29:	6a 00                	push   $0x0
  pushl $231
80105b2b:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105b30:	e9 75 f2 ff ff       	jmp    80104daa <alltraps>

80105b35 <vector232>:
.globl vector232
vector232:
  pushl $0
80105b35:	6a 00                	push   $0x0
  pushl $232
80105b37:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105b3c:	e9 69 f2 ff ff       	jmp    80104daa <alltraps>

80105b41 <vector233>:
.globl vector233
vector233:
  pushl $0
80105b41:	6a 00                	push   $0x0
  pushl $233
80105b43:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105b48:	e9 5d f2 ff ff       	jmp    80104daa <alltraps>

80105b4d <vector234>:
.globl vector234
vector234:
  pushl $0
80105b4d:	6a 00                	push   $0x0
  pushl $234
80105b4f:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105b54:	e9 51 f2 ff ff       	jmp    80104daa <alltraps>

80105b59 <vector235>:
.globl vector235
vector235:
  pushl $0
80105b59:	6a 00                	push   $0x0
  pushl $235
80105b5b:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105b60:	e9 45 f2 ff ff       	jmp    80104daa <alltraps>

80105b65 <vector236>:
.globl vector236
vector236:
  pushl $0
80105b65:	6a 00                	push   $0x0
  pushl $236
80105b67:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105b6c:	e9 39 f2 ff ff       	jmp    80104daa <alltraps>

80105b71 <vector237>:
.globl vector237
vector237:
  pushl $0
80105b71:	6a 00                	push   $0x0
  pushl $237
80105b73:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105b78:	e9 2d f2 ff ff       	jmp    80104daa <alltraps>

80105b7d <vector238>:
.globl vector238
vector238:
  pushl $0
80105b7d:	6a 00                	push   $0x0
  pushl $238
80105b7f:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105b84:	e9 21 f2 ff ff       	jmp    80104daa <alltraps>

80105b89 <vector239>:
.globl vector239
vector239:
  pushl $0
80105b89:	6a 00                	push   $0x0
  pushl $239
80105b8b:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105b90:	e9 15 f2 ff ff       	jmp    80104daa <alltraps>

80105b95 <vector240>:
.globl vector240
vector240:
  pushl $0
80105b95:	6a 00                	push   $0x0
  pushl $240
80105b97:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105b9c:	e9 09 f2 ff ff       	jmp    80104daa <alltraps>

80105ba1 <vector241>:
.globl vector241
vector241:
  pushl $0
80105ba1:	6a 00                	push   $0x0
  pushl $241
80105ba3:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105ba8:	e9 fd f1 ff ff       	jmp    80104daa <alltraps>

80105bad <vector242>:
.globl vector242
vector242:
  pushl $0
80105bad:	6a 00                	push   $0x0
  pushl $242
80105baf:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105bb4:	e9 f1 f1 ff ff       	jmp    80104daa <alltraps>

80105bb9 <vector243>:
.globl vector243
vector243:
  pushl $0
80105bb9:	6a 00                	push   $0x0
  pushl $243
80105bbb:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105bc0:	e9 e5 f1 ff ff       	jmp    80104daa <alltraps>

80105bc5 <vector244>:
.globl vector244
vector244:
  pushl $0
80105bc5:	6a 00                	push   $0x0
  pushl $244
80105bc7:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105bcc:	e9 d9 f1 ff ff       	jmp    80104daa <alltraps>

80105bd1 <vector245>:
.globl vector245
vector245:
  pushl $0
80105bd1:	6a 00                	push   $0x0
  pushl $245
80105bd3:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105bd8:	e9 cd f1 ff ff       	jmp    80104daa <alltraps>

80105bdd <vector246>:
.globl vector246
vector246:
  pushl $0
80105bdd:	6a 00                	push   $0x0
  pushl $246
80105bdf:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105be4:	e9 c1 f1 ff ff       	jmp    80104daa <alltraps>

80105be9 <vector247>:
.globl vector247
vector247:
  pushl $0
80105be9:	6a 00                	push   $0x0
  pushl $247
80105beb:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105bf0:	e9 b5 f1 ff ff       	jmp    80104daa <alltraps>

80105bf5 <vector248>:
.globl vector248
vector248:
  pushl $0
80105bf5:	6a 00                	push   $0x0
  pushl $248
80105bf7:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105bfc:	e9 a9 f1 ff ff       	jmp    80104daa <alltraps>

80105c01 <vector249>:
.globl vector249
vector249:
  pushl $0
80105c01:	6a 00                	push   $0x0
  pushl $249
80105c03:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105c08:	e9 9d f1 ff ff       	jmp    80104daa <alltraps>

80105c0d <vector250>:
.globl vector250
vector250:
  pushl $0
80105c0d:	6a 00                	push   $0x0
  pushl $250
80105c0f:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105c14:	e9 91 f1 ff ff       	jmp    80104daa <alltraps>

80105c19 <vector251>:
.globl vector251
vector251:
  pushl $0
80105c19:	6a 00                	push   $0x0
  pushl $251
80105c1b:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105c20:	e9 85 f1 ff ff       	jmp    80104daa <alltraps>

80105c25 <vector252>:
.globl vector252
vector252:
  pushl $0
80105c25:	6a 00                	push   $0x0
  pushl $252
80105c27:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105c2c:	e9 79 f1 ff ff       	jmp    80104daa <alltraps>

80105c31 <vector253>:
.globl vector253
vector253:
  pushl $0
80105c31:	6a 00                	push   $0x0
  pushl $253
80105c33:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105c38:	e9 6d f1 ff ff       	jmp    80104daa <alltraps>

80105c3d <vector254>:
.globl vector254
vector254:
  pushl $0
80105c3d:	6a 00                	push   $0x0
  pushl $254
80105c3f:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105c44:	e9 61 f1 ff ff       	jmp    80104daa <alltraps>

80105c49 <vector255>:
.globl vector255
vector255:
  pushl $0
80105c49:	6a 00                	push   $0x0
  pushl $255
80105c4b:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105c50:	e9 55 f1 ff ff       	jmp    80104daa <alltraps>

80105c55 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105c55:	55                   	push   %ebp
80105c56:	89 e5                	mov    %esp,%ebp
80105c58:	57                   	push   %edi
80105c59:	56                   	push   %esi
80105c5a:	53                   	push   %ebx
80105c5b:	83 ec 0c             	sub    $0xc,%esp
80105c5e:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105c60:	c1 ea 16             	shr    $0x16,%edx
80105c63:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105c66:	8b 1f                	mov    (%edi),%ebx
80105c68:	f6 c3 01             	test   $0x1,%bl
80105c6b:	74 22                	je     80105c8f <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105c6d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105c73:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105c79:	c1 ee 0c             	shr    $0xc,%esi
80105c7c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105c82:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105c85:	89 d8                	mov    %ebx,%eax
80105c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105c8a:	5b                   	pop    %ebx
80105c8b:	5e                   	pop    %esi
80105c8c:	5f                   	pop    %edi
80105c8d:	5d                   	pop    %ebp
80105c8e:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105c8f:	85 c9                	test   %ecx,%ecx
80105c91:	74 2b                	je     80105cbe <walkpgdir+0x69>
80105c93:	e8 11 c4 ff ff       	call   801020a9 <kalloc>
80105c98:	89 c3                	mov    %eax,%ebx
80105c9a:	85 c0                	test   %eax,%eax
80105c9c:	74 e7                	je     80105c85 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105c9e:	83 ec 04             	sub    $0x4,%esp
80105ca1:	68 00 10 00 00       	push   $0x1000
80105ca6:	6a 00                	push   $0x0
80105ca8:	50                   	push   %eax
80105ca9:	e8 81 df ff ff       	call   80103c2f <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105cae:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105cb4:	83 c8 07             	or     $0x7,%eax
80105cb7:	89 07                	mov    %eax,(%edi)
80105cb9:	83 c4 10             	add    $0x10,%esp
80105cbc:	eb bb                	jmp    80105c79 <walkpgdir+0x24>
      return 0;
80105cbe:	bb 00 00 00 00       	mov    $0x0,%ebx
80105cc3:	eb c0                	jmp    80105c85 <walkpgdir+0x30>

80105cc5 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105cc5:	55                   	push   %ebp
80105cc6:	89 e5                	mov    %esp,%ebp
80105cc8:	57                   	push   %edi
80105cc9:	56                   	push   %esi
80105cca:	53                   	push   %ebx
80105ccb:	83 ec 1c             	sub    $0x1c,%esp
80105cce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105cd1:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105cd4:	89 d3                	mov    %edx,%ebx
80105cd6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105cdc:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105ce0:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105ce6:	b9 01 00 00 00       	mov    $0x1,%ecx
80105ceb:	89 da                	mov    %ebx,%edx
80105ced:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cf0:	e8 60 ff ff ff       	call   80105c55 <walkpgdir>
80105cf5:	85 c0                	test   %eax,%eax
80105cf7:	74 2e                	je     80105d27 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105cf9:	f6 00 01             	testb  $0x1,(%eax)
80105cfc:	75 1c                	jne    80105d1a <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105cfe:	89 f2                	mov    %esi,%edx
80105d00:	0b 55 0c             	or     0xc(%ebp),%edx
80105d03:	83 ca 01             	or     $0x1,%edx
80105d06:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105d08:	39 fb                	cmp    %edi,%ebx
80105d0a:	74 28                	je     80105d34 <mappages+0x6f>
      break;
    a += PGSIZE;
80105d0c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105d12:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105d18:	eb cc                	jmp    80105ce6 <mappages+0x21>
      panic("remap");
80105d1a:	83 ec 0c             	sub    $0xc,%esp
80105d1d:	68 f4 6d 10 80       	push   $0x80106df4
80105d22:	e8 21 a6 ff ff       	call   80100348 <panic>
      return -1;
80105d27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d2f:	5b                   	pop    %ebx
80105d30:	5e                   	pop    %esi
80105d31:	5f                   	pop    %edi
80105d32:	5d                   	pop    %ebp
80105d33:	c3                   	ret    
  return 0;
80105d34:	b8 00 00 00 00       	mov    $0x0,%eax
80105d39:	eb f1                	jmp    80105d2c <mappages+0x67>

80105d3b <seginit>:
{
80105d3b:	55                   	push   %ebp
80105d3c:	89 e5                	mov    %esp,%ebp
80105d3e:	53                   	push   %ebx
80105d3f:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105d42:	e8 82 d4 ff ff       	call   801031c9 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105d47:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105d4d:	66 c7 80 f8 17 11 80 	movw   $0xffff,-0x7feee808(%eax)
80105d54:	ff ff 
80105d56:	66 c7 80 fa 17 11 80 	movw   $0x0,-0x7feee806(%eax)
80105d5d:	00 00 
80105d5f:	c6 80 fc 17 11 80 00 	movb   $0x0,-0x7feee804(%eax)
80105d66:	0f b6 88 fd 17 11 80 	movzbl -0x7feee803(%eax),%ecx
80105d6d:	83 e1 f0             	and    $0xfffffff0,%ecx
80105d70:	83 c9 1a             	or     $0x1a,%ecx
80105d73:	83 e1 9f             	and    $0xffffff9f,%ecx
80105d76:	83 c9 80             	or     $0xffffff80,%ecx
80105d79:	88 88 fd 17 11 80    	mov    %cl,-0x7feee803(%eax)
80105d7f:	0f b6 88 fe 17 11 80 	movzbl -0x7feee802(%eax),%ecx
80105d86:	83 c9 0f             	or     $0xf,%ecx
80105d89:	83 e1 cf             	and    $0xffffffcf,%ecx
80105d8c:	83 c9 c0             	or     $0xffffffc0,%ecx
80105d8f:	88 88 fe 17 11 80    	mov    %cl,-0x7feee802(%eax)
80105d95:	c6 80 ff 17 11 80 00 	movb   $0x0,-0x7feee801(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105d9c:	66 c7 80 00 18 11 80 	movw   $0xffff,-0x7feee800(%eax)
80105da3:	ff ff 
80105da5:	66 c7 80 02 18 11 80 	movw   $0x0,-0x7feee7fe(%eax)
80105dac:	00 00 
80105dae:	c6 80 04 18 11 80 00 	movb   $0x0,-0x7feee7fc(%eax)
80105db5:	0f b6 88 05 18 11 80 	movzbl -0x7feee7fb(%eax),%ecx
80105dbc:	83 e1 f0             	and    $0xfffffff0,%ecx
80105dbf:	83 c9 12             	or     $0x12,%ecx
80105dc2:	83 e1 9f             	and    $0xffffff9f,%ecx
80105dc5:	83 c9 80             	or     $0xffffff80,%ecx
80105dc8:	88 88 05 18 11 80    	mov    %cl,-0x7feee7fb(%eax)
80105dce:	0f b6 88 06 18 11 80 	movzbl -0x7feee7fa(%eax),%ecx
80105dd5:	83 c9 0f             	or     $0xf,%ecx
80105dd8:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ddb:	83 c9 c0             	or     $0xffffffc0,%ecx
80105dde:	88 88 06 18 11 80    	mov    %cl,-0x7feee7fa(%eax)
80105de4:	c6 80 07 18 11 80 00 	movb   $0x0,-0x7feee7f9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105deb:	66 c7 80 08 18 11 80 	movw   $0xffff,-0x7feee7f8(%eax)
80105df2:	ff ff 
80105df4:	66 c7 80 0a 18 11 80 	movw   $0x0,-0x7feee7f6(%eax)
80105dfb:	00 00 
80105dfd:	c6 80 0c 18 11 80 00 	movb   $0x0,-0x7feee7f4(%eax)
80105e04:	c6 80 0d 18 11 80 fa 	movb   $0xfa,-0x7feee7f3(%eax)
80105e0b:	0f b6 88 0e 18 11 80 	movzbl -0x7feee7f2(%eax),%ecx
80105e12:	83 c9 0f             	or     $0xf,%ecx
80105e15:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e18:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e1b:	88 88 0e 18 11 80    	mov    %cl,-0x7feee7f2(%eax)
80105e21:	c6 80 0f 18 11 80 00 	movb   $0x0,-0x7feee7f1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105e28:	66 c7 80 10 18 11 80 	movw   $0xffff,-0x7feee7f0(%eax)
80105e2f:	ff ff 
80105e31:	66 c7 80 12 18 11 80 	movw   $0x0,-0x7feee7ee(%eax)
80105e38:	00 00 
80105e3a:	c6 80 14 18 11 80 00 	movb   $0x0,-0x7feee7ec(%eax)
80105e41:	c6 80 15 18 11 80 f2 	movb   $0xf2,-0x7feee7eb(%eax)
80105e48:	0f b6 88 16 18 11 80 	movzbl -0x7feee7ea(%eax),%ecx
80105e4f:	83 c9 0f             	or     $0xf,%ecx
80105e52:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e55:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e58:	88 88 16 18 11 80    	mov    %cl,-0x7feee7ea(%eax)
80105e5e:	c6 80 17 18 11 80 00 	movb   $0x0,-0x7feee7e9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105e65:	05 f0 17 11 80       	add    $0x801117f0,%eax
  pd[0] = size-1;
80105e6a:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105e70:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105e74:	c1 e8 10             	shr    $0x10,%eax
80105e77:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105e7b:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105e7e:	0f 01 10             	lgdtl  (%eax)
}
80105e81:	83 c4 14             	add    $0x14,%esp
80105e84:	5b                   	pop    %ebx
80105e85:	5d                   	pop    %ebp
80105e86:	c3                   	ret    

80105e87 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80105e87:	55                   	push   %ebp
80105e88:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105e8a:	a1 a4 44 11 80       	mov    0x801144a4,%eax
80105e8f:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105e94:	0f 22 d8             	mov    %eax,%cr3
}
80105e97:	5d                   	pop    %ebp
80105e98:	c3                   	ret    

80105e99 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105e99:	55                   	push   %ebp
80105e9a:	89 e5                	mov    %esp,%ebp
80105e9c:	57                   	push   %edi
80105e9d:	56                   	push   %esi
80105e9e:	53                   	push   %ebx
80105e9f:	83 ec 1c             	sub    $0x1c,%esp
80105ea2:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105ea5:	85 f6                	test   %esi,%esi
80105ea7:	0f 84 dd 00 00 00    	je     80105f8a <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80105ead:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80105eb1:	0f 84 e0 00 00 00    	je     80105f97 <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80105eb7:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80105ebb:	0f 84 e3 00 00 00    	je     80105fa4 <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80105ec1:	e8 e0 db ff ff       	call   80103aa6 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80105ec6:	e8 a2 d2 ff ff       	call   8010316d <mycpu>
80105ecb:	89 c3                	mov    %eax,%ebx
80105ecd:	e8 9b d2 ff ff       	call   8010316d <mycpu>
80105ed2:	8d 78 08             	lea    0x8(%eax),%edi
80105ed5:	e8 93 d2 ff ff       	call   8010316d <mycpu>
80105eda:	83 c0 08             	add    $0x8,%eax
80105edd:	c1 e8 10             	shr    $0x10,%eax
80105ee0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105ee3:	e8 85 d2 ff ff       	call   8010316d <mycpu>
80105ee8:	83 c0 08             	add    $0x8,%eax
80105eeb:	c1 e8 18             	shr    $0x18,%eax
80105eee:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80105ef5:	67 00 
80105ef7:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80105efe:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80105f02:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80105f08:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80105f0f:	83 e2 f0             	and    $0xfffffff0,%edx
80105f12:	83 ca 19             	or     $0x19,%edx
80105f15:	83 e2 9f             	and    $0xffffff9f,%edx
80105f18:	83 ca 80             	or     $0xffffff80,%edx
80105f1b:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80105f21:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80105f28:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80105f2e:	e8 3a d2 ff ff       	call   8010316d <mycpu>
80105f33:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80105f3a:	83 e2 ef             	and    $0xffffffef,%edx
80105f3d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80105f43:	e8 25 d2 ff ff       	call   8010316d <mycpu>
80105f48:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80105f4e:	8b 5e 08             	mov    0x8(%esi),%ebx
80105f51:	e8 17 d2 ff ff       	call   8010316d <mycpu>
80105f56:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80105f5c:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80105f5f:	e8 09 d2 ff ff       	call   8010316d <mycpu>
80105f64:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80105f6a:	b8 28 00 00 00       	mov    $0x28,%eax
80105f6f:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80105f72:	8b 46 04             	mov    0x4(%esi),%eax
80105f75:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105f7a:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80105f7d:	e8 61 db ff ff       	call   80103ae3 <popcli>
}
80105f82:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f85:	5b                   	pop    %ebx
80105f86:	5e                   	pop    %esi
80105f87:	5f                   	pop    %edi
80105f88:	5d                   	pop    %ebp
80105f89:	c3                   	ret    
    panic("switchuvm: no process");
80105f8a:	83 ec 0c             	sub    $0xc,%esp
80105f8d:	68 fa 6d 10 80       	push   $0x80106dfa
80105f92:	e8 b1 a3 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
80105f97:	83 ec 0c             	sub    $0xc,%esp
80105f9a:	68 10 6e 10 80       	push   $0x80106e10
80105f9f:	e8 a4 a3 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
80105fa4:	83 ec 0c             	sub    $0xc,%esp
80105fa7:	68 25 6e 10 80       	push   $0x80106e25
80105fac:	e8 97 a3 ff ff       	call   80100348 <panic>

80105fb1 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80105fb1:	55                   	push   %ebp
80105fb2:	89 e5                	mov    %esp,%ebp
80105fb4:	56                   	push   %esi
80105fb5:	53                   	push   %ebx
80105fb6:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80105fb9:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80105fbf:	77 4c                	ja     8010600d <inituvm+0x5c>
    panic("inituvm: more than a page");
  mem = kalloc();
80105fc1:	e8 e3 c0 ff ff       	call   801020a9 <kalloc>
80105fc6:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80105fc8:	83 ec 04             	sub    $0x4,%esp
80105fcb:	68 00 10 00 00       	push   $0x1000
80105fd0:	6a 00                	push   $0x0
80105fd2:	50                   	push   %eax
80105fd3:	e8 57 dc ff ff       	call   80103c2f <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80105fd8:	83 c4 08             	add    $0x8,%esp
80105fdb:	6a 06                	push   $0x6
80105fdd:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105fe3:	50                   	push   %eax
80105fe4:	b9 00 10 00 00       	mov    $0x1000,%ecx
80105fe9:	ba 00 00 00 00       	mov    $0x0,%edx
80105fee:	8b 45 08             	mov    0x8(%ebp),%eax
80105ff1:	e8 cf fc ff ff       	call   80105cc5 <mappages>
  memmove(mem, init, sz);
80105ff6:	83 c4 0c             	add    $0xc,%esp
80105ff9:	56                   	push   %esi
80105ffa:	ff 75 0c             	pushl  0xc(%ebp)
80105ffd:	53                   	push   %ebx
80105ffe:	e8 a7 dc ff ff       	call   80103caa <memmove>
}
80106003:	83 c4 10             	add    $0x10,%esp
80106006:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106009:	5b                   	pop    %ebx
8010600a:	5e                   	pop    %esi
8010600b:	5d                   	pop    %ebp
8010600c:	c3                   	ret    
    panic("inituvm: more than a page");
8010600d:	83 ec 0c             	sub    $0xc,%esp
80106010:	68 39 6e 10 80       	push   $0x80106e39
80106015:	e8 2e a3 ff ff       	call   80100348 <panic>

8010601a <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010601a:	55                   	push   %ebp
8010601b:	89 e5                	mov    %esp,%ebp
8010601d:	57                   	push   %edi
8010601e:	56                   	push   %esi
8010601f:	53                   	push   %ebx
80106020:	83 ec 0c             	sub    $0xc,%esp
80106023:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106026:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
8010602d:	75 07                	jne    80106036 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010602f:	bb 00 00 00 00       	mov    $0x0,%ebx
80106034:	eb 3c                	jmp    80106072 <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
80106036:	83 ec 0c             	sub    $0xc,%esp
80106039:	68 f4 6e 10 80       	push   $0x80106ef4
8010603e:	e8 05 a3 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106043:	83 ec 0c             	sub    $0xc,%esp
80106046:	68 53 6e 10 80       	push   $0x80106e53
8010604b:	e8 f8 a2 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106050:	05 00 00 00 80       	add    $0x80000000,%eax
80106055:	56                   	push   %esi
80106056:	89 da                	mov    %ebx,%edx
80106058:	03 55 14             	add    0x14(%ebp),%edx
8010605b:	52                   	push   %edx
8010605c:	50                   	push   %eax
8010605d:	ff 75 10             	pushl  0x10(%ebp)
80106060:	e8 fc b6 ff ff       	call   80101761 <readi>
80106065:	83 c4 10             	add    $0x10,%esp
80106068:	39 f0                	cmp    %esi,%eax
8010606a:	75 47                	jne    801060b3 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
8010606c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106072:	39 fb                	cmp    %edi,%ebx
80106074:	73 30                	jae    801060a6 <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106076:	89 da                	mov    %ebx,%edx
80106078:	03 55 0c             	add    0xc(%ebp),%edx
8010607b:	b9 00 00 00 00       	mov    $0x0,%ecx
80106080:	8b 45 08             	mov    0x8(%ebp),%eax
80106083:	e8 cd fb ff ff       	call   80105c55 <walkpgdir>
80106088:	85 c0                	test   %eax,%eax
8010608a:	74 b7                	je     80106043 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
8010608c:	8b 00                	mov    (%eax),%eax
8010608e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106093:	89 fe                	mov    %edi,%esi
80106095:	29 de                	sub    %ebx,%esi
80106097:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010609d:	76 b1                	jbe    80106050 <loaduvm+0x36>
      n = PGSIZE;
8010609f:	be 00 10 00 00       	mov    $0x1000,%esi
801060a4:	eb aa                	jmp    80106050 <loaduvm+0x36>
      return -1;
  }
  return 0;
801060a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060ae:	5b                   	pop    %ebx
801060af:	5e                   	pop    %esi
801060b0:	5f                   	pop    %edi
801060b1:	5d                   	pop    %ebp
801060b2:	c3                   	ret    
      return -1;
801060b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b8:	eb f1                	jmp    801060ab <loaduvm+0x91>

801060ba <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801060ba:	55                   	push   %ebp
801060bb:	89 e5                	mov    %esp,%ebp
801060bd:	57                   	push   %edi
801060be:	56                   	push   %esi
801060bf:	53                   	push   %ebx
801060c0:	83 ec 0c             	sub    $0xc,%esp
801060c3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801060c6:	39 7d 10             	cmp    %edi,0x10(%ebp)
801060c9:	73 11                	jae    801060dc <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
801060cb:	8b 45 10             	mov    0x10(%ebp),%eax
801060ce:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801060d4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801060da:	eb 19                	jmp    801060f5 <deallocuvm+0x3b>
    return oldsz;
801060dc:	89 f8                	mov    %edi,%eax
801060de:	eb 64                	jmp    80106144 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801060e0:	c1 eb 16             	shr    $0x16,%ebx
801060e3:	83 c3 01             	add    $0x1,%ebx
801060e6:	c1 e3 16             	shl    $0x16,%ebx
801060e9:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801060ef:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801060f5:	39 fb                	cmp    %edi,%ebx
801060f7:	73 48                	jae    80106141 <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
801060f9:	b9 00 00 00 00       	mov    $0x0,%ecx
801060fe:	89 da                	mov    %ebx,%edx
80106100:	8b 45 08             	mov    0x8(%ebp),%eax
80106103:	e8 4d fb ff ff       	call   80105c55 <walkpgdir>
80106108:	89 c6                	mov    %eax,%esi
    if(!pte)
8010610a:	85 c0                	test   %eax,%eax
8010610c:	74 d2                	je     801060e0 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
8010610e:	8b 00                	mov    (%eax),%eax
80106110:	a8 01                	test   $0x1,%al
80106112:	74 db                	je     801060ef <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106114:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106119:	74 19                	je     80106134 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
8010611b:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106120:	83 ec 0c             	sub    $0xc,%esp
80106123:	50                   	push   %eax
80106124:	e8 69 be ff ff       	call   80101f92 <kfree>
      *pte = 0;
80106129:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010612f:	83 c4 10             	add    $0x10,%esp
80106132:	eb bb                	jmp    801060ef <deallocuvm+0x35>
        panic("kfree");
80106134:	83 ec 0c             	sub    $0xc,%esp
80106137:	68 86 67 10 80       	push   $0x80106786
8010613c:	e8 07 a2 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106141:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106144:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106147:	5b                   	pop    %ebx
80106148:	5e                   	pop    %esi
80106149:	5f                   	pop    %edi
8010614a:	5d                   	pop    %ebp
8010614b:	c3                   	ret    

8010614c <allocuvm>:
{
8010614c:	55                   	push   %ebp
8010614d:	89 e5                	mov    %esp,%ebp
8010614f:	57                   	push   %edi
80106150:	56                   	push   %esi
80106151:	53                   	push   %ebx
80106152:	83 ec 1c             	sub    $0x1c,%esp
80106155:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
80106158:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010615b:	85 ff                	test   %edi,%edi
8010615d:	0f 88 c1 00 00 00    	js     80106224 <allocuvm+0xd8>
  if(newsz < oldsz)
80106163:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106166:	72 5c                	jb     801061c4 <allocuvm+0x78>
  a = PGROUNDUP(oldsz);
80106168:	8b 45 0c             	mov    0xc(%ebp),%eax
8010616b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106171:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
80106177:	39 fb                	cmp    %edi,%ebx
80106179:	0f 83 ac 00 00 00    	jae    8010622b <allocuvm+0xdf>
    mem = kalloc();
8010617f:	e8 25 bf ff ff       	call   801020a9 <kalloc>
80106184:	89 c6                	mov    %eax,%esi
    if(mem == 0){
80106186:	85 c0                	test   %eax,%eax
80106188:	74 42                	je     801061cc <allocuvm+0x80>
    memset(mem, 0, PGSIZE);
8010618a:	83 ec 04             	sub    $0x4,%esp
8010618d:	68 00 10 00 00       	push   $0x1000
80106192:	6a 00                	push   $0x0
80106194:	50                   	push   %eax
80106195:	e8 95 da ff ff       	call   80103c2f <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010619a:	83 c4 08             	add    $0x8,%esp
8010619d:	6a 06                	push   $0x6
8010619f:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801061a5:	50                   	push   %eax
801061a6:	b9 00 10 00 00       	mov    $0x1000,%ecx
801061ab:	89 da                	mov    %ebx,%edx
801061ad:	8b 45 08             	mov    0x8(%ebp),%eax
801061b0:	e8 10 fb ff ff       	call   80105cc5 <mappages>
801061b5:	83 c4 10             	add    $0x10,%esp
801061b8:	85 c0                	test   %eax,%eax
801061ba:	78 38                	js     801061f4 <allocuvm+0xa8>
  for(; a < newsz; a += PGSIZE){
801061bc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801061c2:	eb b3                	jmp    80106177 <allocuvm+0x2b>
    return oldsz;
801061c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801061c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801061ca:	eb 5f                	jmp    8010622b <allocuvm+0xdf>
      cprintf("allocuvm out of memory\n");
801061cc:	83 ec 0c             	sub    $0xc,%esp
801061cf:	68 71 6e 10 80       	push   $0x80106e71
801061d4:	e8 32 a4 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801061d9:	83 c4 0c             	add    $0xc,%esp
801061dc:	ff 75 0c             	pushl  0xc(%ebp)
801061df:	57                   	push   %edi
801061e0:	ff 75 08             	pushl  0x8(%ebp)
801061e3:	e8 d2 fe ff ff       	call   801060ba <deallocuvm>
      return 0;
801061e8:	83 c4 10             	add    $0x10,%esp
801061eb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801061f2:	eb 37                	jmp    8010622b <allocuvm+0xdf>
      cprintf("allocuvm out of memory (2)\n");
801061f4:	83 ec 0c             	sub    $0xc,%esp
801061f7:	68 89 6e 10 80       	push   $0x80106e89
801061fc:	e8 0a a4 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106201:	83 c4 0c             	add    $0xc,%esp
80106204:	ff 75 0c             	pushl  0xc(%ebp)
80106207:	57                   	push   %edi
80106208:	ff 75 08             	pushl  0x8(%ebp)
8010620b:	e8 aa fe ff ff       	call   801060ba <deallocuvm>
      kfree(mem);
80106210:	89 34 24             	mov    %esi,(%esp)
80106213:	e8 7a bd ff ff       	call   80101f92 <kfree>
      return 0;
80106218:	83 c4 10             	add    $0x10,%esp
8010621b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106222:	eb 07                	jmp    8010622b <allocuvm+0xdf>
    return 0;
80106224:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
8010622b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010622e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106231:	5b                   	pop    %ebx
80106232:	5e                   	pop    %esi
80106233:	5f                   	pop    %edi
80106234:	5d                   	pop    %ebp
80106235:	c3                   	ret    

80106236 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106236:	55                   	push   %ebp
80106237:	89 e5                	mov    %esp,%ebp
80106239:	56                   	push   %esi
8010623a:	53                   	push   %ebx
8010623b:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
8010623e:	85 f6                	test   %esi,%esi
80106240:	74 1a                	je     8010625c <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
80106242:	83 ec 04             	sub    $0x4,%esp
80106245:	6a 00                	push   $0x0
80106247:	68 00 00 00 80       	push   $0x80000000
8010624c:	56                   	push   %esi
8010624d:	e8 68 fe ff ff       	call   801060ba <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80106252:	83 c4 10             	add    $0x10,%esp
80106255:	bb 00 00 00 00       	mov    $0x0,%ebx
8010625a:	eb 10                	jmp    8010626c <freevm+0x36>
    panic("freevm: no pgdir");
8010625c:	83 ec 0c             	sub    $0xc,%esp
8010625f:	68 a5 6e 10 80       	push   $0x80106ea5
80106264:	e8 df a0 ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
80106269:	83 c3 01             	add    $0x1,%ebx
8010626c:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106272:	77 1f                	ja     80106293 <freevm+0x5d>
    if(pgdir[i] & PTE_P){
80106274:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106277:	a8 01                	test   $0x1,%al
80106279:	74 ee                	je     80106269 <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010627b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106280:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106285:	83 ec 0c             	sub    $0xc,%esp
80106288:	50                   	push   %eax
80106289:	e8 04 bd ff ff       	call   80101f92 <kfree>
8010628e:	83 c4 10             	add    $0x10,%esp
80106291:	eb d6                	jmp    80106269 <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
80106293:	83 ec 0c             	sub    $0xc,%esp
80106296:	56                   	push   %esi
80106297:	e8 f6 bc ff ff       	call   80101f92 <kfree>
}
8010629c:	83 c4 10             	add    $0x10,%esp
8010629f:	8d 65 f8             	lea    -0x8(%ebp),%esp
801062a2:	5b                   	pop    %ebx
801062a3:	5e                   	pop    %esi
801062a4:	5d                   	pop    %ebp
801062a5:	c3                   	ret    

801062a6 <setupkvm>:
{
801062a6:	55                   	push   %ebp
801062a7:	89 e5                	mov    %esp,%ebp
801062a9:	56                   	push   %esi
801062aa:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801062ab:	e8 f9 bd ff ff       	call   801020a9 <kalloc>
801062b0:	89 c6                	mov    %eax,%esi
801062b2:	85 c0                	test   %eax,%eax
801062b4:	74 55                	je     8010630b <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
801062b6:	83 ec 04             	sub    $0x4,%esp
801062b9:	68 00 10 00 00       	push   $0x1000
801062be:	6a 00                	push   $0x0
801062c0:	50                   	push   %eax
801062c1:	e8 69 d9 ff ff       	call   80103c2f <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801062c6:	83 c4 10             	add    $0x10,%esp
801062c9:	bb 20 94 10 80       	mov    $0x80109420,%ebx
801062ce:	81 fb 60 94 10 80    	cmp    $0x80109460,%ebx
801062d4:	73 35                	jae    8010630b <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
801062d6:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801062d9:	8b 4b 08             	mov    0x8(%ebx),%ecx
801062dc:	29 c1                	sub    %eax,%ecx
801062de:	83 ec 08             	sub    $0x8,%esp
801062e1:	ff 73 0c             	pushl  0xc(%ebx)
801062e4:	50                   	push   %eax
801062e5:	8b 13                	mov    (%ebx),%edx
801062e7:	89 f0                	mov    %esi,%eax
801062e9:	e8 d7 f9 ff ff       	call   80105cc5 <mappages>
801062ee:	83 c4 10             	add    $0x10,%esp
801062f1:	85 c0                	test   %eax,%eax
801062f3:	78 05                	js     801062fa <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801062f5:	83 c3 10             	add    $0x10,%ebx
801062f8:	eb d4                	jmp    801062ce <setupkvm+0x28>
      freevm(pgdir);
801062fa:	83 ec 0c             	sub    $0xc,%esp
801062fd:	56                   	push   %esi
801062fe:	e8 33 ff ff ff       	call   80106236 <freevm>
      return 0;
80106303:	83 c4 10             	add    $0x10,%esp
80106306:	be 00 00 00 00       	mov    $0x0,%esi
}
8010630b:	89 f0                	mov    %esi,%eax
8010630d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106310:	5b                   	pop    %ebx
80106311:	5e                   	pop    %esi
80106312:	5d                   	pop    %ebp
80106313:	c3                   	ret    

80106314 <kvmalloc>:
{
80106314:	55                   	push   %ebp
80106315:	89 e5                	mov    %esp,%ebp
80106317:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010631a:	e8 87 ff ff ff       	call   801062a6 <setupkvm>
8010631f:	a3 a4 44 11 80       	mov    %eax,0x801144a4
  switchkvm();
80106324:	e8 5e fb ff ff       	call   80105e87 <switchkvm>
}
80106329:	c9                   	leave  
8010632a:	c3                   	ret    

8010632b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010632b:	55                   	push   %ebp
8010632c:	89 e5                	mov    %esp,%ebp
8010632e:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106331:	b9 00 00 00 00       	mov    $0x0,%ecx
80106336:	8b 55 0c             	mov    0xc(%ebp),%edx
80106339:	8b 45 08             	mov    0x8(%ebp),%eax
8010633c:	e8 14 f9 ff ff       	call   80105c55 <walkpgdir>
  if(pte == 0)
80106341:	85 c0                	test   %eax,%eax
80106343:	74 05                	je     8010634a <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106345:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106348:	c9                   	leave  
80106349:	c3                   	ret    
    panic("clearpteu");
8010634a:	83 ec 0c             	sub    $0xc,%esp
8010634d:	68 b6 6e 10 80       	push   $0x80106eb6
80106352:	e8 f1 9f ff ff       	call   80100348 <panic>

80106357 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106357:	55                   	push   %ebp
80106358:	89 e5                	mov    %esp,%ebp
8010635a:	57                   	push   %edi
8010635b:	56                   	push   %esi
8010635c:	53                   	push   %ebx
8010635d:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106360:	e8 41 ff ff ff       	call   801062a6 <setupkvm>
80106365:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106368:	85 c0                	test   %eax,%eax
8010636a:	0f 84 c4 00 00 00    	je     80106434 <copyuvm+0xdd>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106370:	bf 00 00 00 00       	mov    $0x0,%edi
80106375:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106378:	0f 83 b6 00 00 00    	jae    80106434 <copyuvm+0xdd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010637e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106381:	b9 00 00 00 00       	mov    $0x0,%ecx
80106386:	89 fa                	mov    %edi,%edx
80106388:	8b 45 08             	mov    0x8(%ebp),%eax
8010638b:	e8 c5 f8 ff ff       	call   80105c55 <walkpgdir>
80106390:	85 c0                	test   %eax,%eax
80106392:	74 65                	je     801063f9 <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
80106394:	8b 00                	mov    (%eax),%eax
80106396:	a8 01                	test   $0x1,%al
80106398:	74 6c                	je     80106406 <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
8010639a:	89 c6                	mov    %eax,%esi
8010639c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
801063a2:	25 ff 0f 00 00       	and    $0xfff,%eax
801063a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
801063aa:	e8 fa bc ff ff       	call   801020a9 <kalloc>
801063af:	89 c3                	mov    %eax,%ebx
801063b1:	85 c0                	test   %eax,%eax
801063b3:	74 6a                	je     8010641f <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801063b5:	81 c6 00 00 00 80    	add    $0x80000000,%esi
801063bb:	83 ec 04             	sub    $0x4,%esp
801063be:	68 00 10 00 00       	push   $0x1000
801063c3:	56                   	push   %esi
801063c4:	50                   	push   %eax
801063c5:	e8 e0 d8 ff ff       	call   80103caa <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801063ca:	83 c4 08             	add    $0x8,%esp
801063cd:	ff 75 e0             	pushl  -0x20(%ebp)
801063d0:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801063d6:	50                   	push   %eax
801063d7:	b9 00 10 00 00       	mov    $0x1000,%ecx
801063dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801063df:	8b 45 dc             	mov    -0x24(%ebp),%eax
801063e2:	e8 de f8 ff ff       	call   80105cc5 <mappages>
801063e7:	83 c4 10             	add    $0x10,%esp
801063ea:	85 c0                	test   %eax,%eax
801063ec:	78 25                	js     80106413 <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
801063ee:	81 c7 00 10 00 00    	add    $0x1000,%edi
801063f4:	e9 7c ff ff ff       	jmp    80106375 <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
801063f9:	83 ec 0c             	sub    $0xc,%esp
801063fc:	68 c0 6e 10 80       	push   $0x80106ec0
80106401:	e8 42 9f ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
80106406:	83 ec 0c             	sub    $0xc,%esp
80106409:	68 da 6e 10 80       	push   $0x80106eda
8010640e:	e8 35 9f ff ff       	call   80100348 <panic>
      kfree(mem);
80106413:	83 ec 0c             	sub    $0xc,%esp
80106416:	53                   	push   %ebx
80106417:	e8 76 bb ff ff       	call   80101f92 <kfree>
      goto bad;
8010641c:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
8010641f:	83 ec 0c             	sub    $0xc,%esp
80106422:	ff 75 dc             	pushl  -0x24(%ebp)
80106425:	e8 0c fe ff ff       	call   80106236 <freevm>
  return 0;
8010642a:	83 c4 10             	add    $0x10,%esp
8010642d:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106434:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106437:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010643a:	5b                   	pop    %ebx
8010643b:	5e                   	pop    %esi
8010643c:	5f                   	pop    %edi
8010643d:	5d                   	pop    %ebp
8010643e:	c3                   	ret    

8010643f <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010643f:	55                   	push   %ebp
80106440:	89 e5                	mov    %esp,%ebp
80106442:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106445:	b9 00 00 00 00       	mov    $0x0,%ecx
8010644a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010644d:	8b 45 08             	mov    0x8(%ebp),%eax
80106450:	e8 00 f8 ff ff       	call   80105c55 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106455:	8b 00                	mov    (%eax),%eax
80106457:	a8 01                	test   $0x1,%al
80106459:	74 10                	je     8010646b <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
8010645b:	a8 04                	test   $0x4,%al
8010645d:	74 13                	je     80106472 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
8010645f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106464:	05 00 00 00 80       	add    $0x80000000,%eax
}
80106469:	c9                   	leave  
8010646a:	c3                   	ret    
    return 0;
8010646b:	b8 00 00 00 00       	mov    $0x0,%eax
80106470:	eb f7                	jmp    80106469 <uva2ka+0x2a>
    return 0;
80106472:	b8 00 00 00 00       	mov    $0x0,%eax
80106477:	eb f0                	jmp    80106469 <uva2ka+0x2a>

80106479 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106479:	55                   	push   %ebp
8010647a:	89 e5                	mov    %esp,%ebp
8010647c:	57                   	push   %edi
8010647d:	56                   	push   %esi
8010647e:	53                   	push   %ebx
8010647f:	83 ec 0c             	sub    $0xc,%esp
80106482:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106485:	eb 25                	jmp    801064ac <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106487:	8b 55 0c             	mov    0xc(%ebp),%edx
8010648a:	29 f2                	sub    %esi,%edx
8010648c:	01 d0                	add    %edx,%eax
8010648e:	83 ec 04             	sub    $0x4,%esp
80106491:	53                   	push   %ebx
80106492:	ff 75 10             	pushl  0x10(%ebp)
80106495:	50                   	push   %eax
80106496:	e8 0f d8 ff ff       	call   80103caa <memmove>
    len -= n;
8010649b:	29 df                	sub    %ebx,%edi
    buf += n;
8010649d:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
801064a0:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
801064a6:	89 45 0c             	mov    %eax,0xc(%ebp)
801064a9:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
801064ac:	85 ff                	test   %edi,%edi
801064ae:	74 2f                	je     801064df <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
801064b0:	8b 75 0c             	mov    0xc(%ebp),%esi
801064b3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801064b9:	83 ec 08             	sub    $0x8,%esp
801064bc:	56                   	push   %esi
801064bd:	ff 75 08             	pushl  0x8(%ebp)
801064c0:	e8 7a ff ff ff       	call   8010643f <uva2ka>
    if(pa0 == 0)
801064c5:	83 c4 10             	add    $0x10,%esp
801064c8:	85 c0                	test   %eax,%eax
801064ca:	74 20                	je     801064ec <copyout+0x73>
    n = PGSIZE - (va - va0);
801064cc:	89 f3                	mov    %esi,%ebx
801064ce:	2b 5d 0c             	sub    0xc(%ebp),%ebx
801064d1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801064d7:	39 df                	cmp    %ebx,%edi
801064d9:	73 ac                	jae    80106487 <copyout+0xe>
      n = len;
801064db:	89 fb                	mov    %edi,%ebx
801064dd:	eb a8                	jmp    80106487 <copyout+0xe>
  }
  return 0;
801064df:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064e7:	5b                   	pop    %ebx
801064e8:	5e                   	pop    %esi
801064e9:	5f                   	pop    %edi
801064ea:	5d                   	pop    %ebp
801064eb:	c3                   	ret    
      return -1;
801064ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064f1:	eb f1                	jmp    801064e4 <copyout+0x6b>

801064f3 <mencrypt>:
// Blank page.
//PAGEBREAK!
// Blank page.


int mencrypt(char* virtual_addr, int len){
801064f3:	55                   	push   %ebp
801064f4:	89 e5                	mov    %esp,%ebp
	return -1;
}
801064f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064fb:	5d                   	pop    %ebp
801064fc:	c3                   	ret    

801064fd <getpgtable>:

int getpgtable(struct pt_entry* entries, int num){
801064fd:	55                   	push   %ebp
801064fe:	89 e5                	mov    %esp,%ebp
	return 69;
}
80106500:	b8 45 00 00 00       	mov    $0x45,%eax
80106505:	5d                   	pop    %ebp
80106506:	c3                   	ret    

80106507 <dump_rawphymem>:

int dump_rawphymem(uint physical_addr, char* buffer){
80106507:	55                   	push   %ebp
80106508:	89 e5                	mov    %esp,%ebp
	return 10;
}
8010650a:	b8 0a 00 00 00       	mov    $0xa,%eax
8010650f:	5d                   	pop    %ebp
80106510:	c3                   	ret    
