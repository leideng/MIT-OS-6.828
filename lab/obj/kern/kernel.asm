
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 03 01 00 00       	call   f0100141 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
		monitor(NULL);
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
f0100047:	8d 5d 14             	lea    0x14(%ebp),%ebx
{
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f010004a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010004d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100051:	8b 45 08             	mov    0x8(%ebp),%eax
f0100054:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100058:	c7 04 24 00 19 10 f0 	movl   $0xf0101900,(%esp)
f010005f:	e8 bf 08 00 00       	call   f0100923 <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 7d 08 00 00       	call   f01008f0 <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 ab 19 10 f0 	movl   $0xf01019ab,(%esp)
f010007a:	e8 a4 08 00 00       	call   f0100923 <cprintf>
	va_end(ap);
}
f010007f:	83 c4 14             	add    $0x14,%esp
f0100082:	5b                   	pop    %ebx
f0100083:	5d                   	pop    %ebp
f0100084:	c3                   	ret    

f0100085 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100085:	55                   	push   %ebp
f0100086:	89 e5                	mov    %esp,%ebp
f0100088:	56                   	push   %esi
f0100089:	53                   	push   %ebx
f010008a:	83 ec 10             	sub    $0x10,%esp
f010008d:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100090:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f0100097:	75 3d                	jne    f01000d6 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010009f:	fa                   	cli    
f01000a0:	fc                   	cld    
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
f01000a1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000a7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01000ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b2:	c7 04 24 1a 19 10 f0 	movl   $0xf010191a,(%esp)
f01000b9:	e8 65 08 00 00       	call   f0100923 <cprintf>
	vcprintf(fmt, ap);
f01000be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000c2:	89 34 24             	mov    %esi,(%esp)
f01000c5:	e8 26 08 00 00       	call   f01008f0 <vcprintf>
	cprintf("\n");
f01000ca:	c7 04 24 ab 19 10 f0 	movl   $0xf01019ab,(%esp)
f01000d1:	e8 4d 08 00 00       	call   f0100923 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000dd:	e8 cb 06 00 00       	call   f01007ad <monitor>
f01000e2:	eb f2                	jmp    f01000d6 <_panic+0x51>

f01000e4 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f01000e4:	55                   	push   %ebp
f01000e5:	89 e5                	mov    %esp,%ebp
f01000e7:	53                   	push   %ebx
f01000e8:	83 ec 14             	sub    $0x14,%esp
f01000eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f01000ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000f2:	c7 04 24 32 19 10 f0 	movl   $0xf0101932,(%esp)
f01000f9:	e8 25 08 00 00       	call   f0100923 <cprintf>
	if (x > 0)
f01000fe:	85 db                	test   %ebx,%ebx
f0100100:	7e 0d                	jle    f010010f <test_backtrace+0x2b>
		test_backtrace(x-1);
f0100102:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100105:	89 04 24             	mov    %eax,(%esp)
f0100108:	e8 d7 ff ff ff       	call   f01000e4 <test_backtrace>
f010010d:	eb 1c                	jmp    f010012b <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010010f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100116:	00 
f0100117:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010011e:	00 
f010011f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100126:	e8 65 05 00 00       	call   f0100690 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f010012b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010012f:	c7 04 24 4e 19 10 f0 	movl   $0xf010194e,(%esp)
f0100136:	e8 e8 07 00 00       	call   f0100923 <cprintf>
}
f010013b:	83 c4 14             	add    $0x14,%esp
f010013e:	5b                   	pop    %ebx
f010013f:	5d                   	pop    %ebp
f0100140:	c3                   	ret    

f0100141 <i386_init>:

void
i386_init(void)
{
f0100141:	55                   	push   %ebp
f0100142:	89 e5                	mov    %esp,%ebp
f0100144:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100147:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010014c:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f0100151:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100155:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010015c:	00 
f010015d:	c7 04 24 00 23 11 f0 	movl   $0xf0112300,(%esp)
f0100164:	e8 e7 12 00 00       	call   f0101450 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100169:	e8 24 03 00 00       	call   f0100492 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010016e:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100175:	00 
f0100176:	c7 04 24 69 19 10 f0 	movl   $0xf0101969,(%esp)
f010017d:	e8 a1 07 00 00       	call   f0100923 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f0100182:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100189:	e8 56 ff ff ff       	call   f01000e4 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010018e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100195:	e8 13 06 00 00       	call   f01007ad <monitor>
f010019a:	eb f2                	jmp    f010018e <i386_init+0x4d>
f010019c:	00 00                	add    %al,(%eax)
	...

f01001a0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001a3:	ba 84 00 00 00       	mov    $0x84,%edx
f01001a8:	ec                   	in     (%dx),%al
f01001a9:	ec                   	in     (%dx),%al
f01001aa:	ec                   	in     (%dx),%al
f01001ab:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01001ac:	5d                   	pop    %ebp
f01001ad:	c3                   	ret    

f01001ae <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001ae:	55                   	push   %ebp
f01001af:	89 e5                	mov    %esp,%ebp
f01001b1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001b6:	ec                   	in     (%dx),%al
f01001b7:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001be:	f6 c2 01             	test   $0x1,%dl
f01001c1:	74 09                	je     f01001cc <serial_proc_data+0x1e>
f01001c3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001c8:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001c9:	0f b6 c0             	movzbl %al,%eax
}
f01001cc:	5d                   	pop    %ebp
f01001cd:	c3                   	ret    

f01001ce <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ce:	55                   	push   %ebp
f01001cf:	89 e5                	mov    %esp,%ebp
f01001d1:	57                   	push   %edi
f01001d2:	56                   	push   %esi
f01001d3:	53                   	push   %ebx
f01001d4:	83 ec 0c             	sub    $0xc,%esp
f01001d7:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001d9:	bb 24 25 11 f0       	mov    $0xf0112524,%ebx
f01001de:	bf 20 23 11 f0       	mov    $0xf0112320,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001e3:	eb 1b                	jmp    f0100200 <cons_intr+0x32>
		if (c == 0)
f01001e5:	85 c0                	test   %eax,%eax
f01001e7:	74 17                	je     f0100200 <cons_intr+0x32>
			continue;
		cons.buf[cons.wpos++] = c;
f01001e9:	8b 13                	mov    (%ebx),%edx
f01001eb:	88 04 17             	mov    %al,(%edi,%edx,1)
f01001ee:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f01001f1:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f01001f6:	ba 00 00 00 00       	mov    $0x0,%edx
f01001fb:	0f 44 c2             	cmove  %edx,%eax
f01001fe:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100200:	ff d6                	call   *%esi
f0100202:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100205:	75 de                	jne    f01001e5 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100207:	83 c4 0c             	add    $0xc,%esp
f010020a:	5b                   	pop    %ebx
f010020b:	5e                   	pop    %esi
f010020c:	5f                   	pop    %edi
f010020d:	5d                   	pop    %ebp
f010020e:	c3                   	ret    

f010020f <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010020f:	55                   	push   %ebp
f0100210:	89 e5                	mov    %esp,%ebp
f0100212:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100215:	b8 82 05 10 f0       	mov    $0xf0100582,%eax
f010021a:	e8 af ff ff ff       	call   f01001ce <cons_intr>
}
f010021f:	c9                   	leave  
f0100220:	c3                   	ret    

f0100221 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100221:	55                   	push   %ebp
f0100222:	89 e5                	mov    %esp,%ebp
f0100224:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100227:	80 3d 04 23 11 f0 00 	cmpb   $0x0,0xf0112304
f010022e:	74 0a                	je     f010023a <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100230:	b8 ae 01 10 f0       	mov    $0xf01001ae,%eax
f0100235:	e8 94 ff ff ff       	call   f01001ce <cons_intr>
}
f010023a:	c9                   	leave  
f010023b:	c3                   	ret    

f010023c <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010023c:	55                   	push   %ebp
f010023d:	89 e5                	mov    %esp,%ebp
f010023f:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100242:	e8 da ff ff ff       	call   f0100221 <serial_intr>
	kbd_intr();
f0100247:	e8 c3 ff ff ff       	call   f010020f <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010024c:	8b 15 20 25 11 f0    	mov    0xf0112520,%edx
f0100252:	b8 00 00 00 00       	mov    $0x0,%eax
f0100257:	3b 15 24 25 11 f0    	cmp    0xf0112524,%edx
f010025d:	74 1e                	je     f010027d <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010025f:	0f b6 82 20 23 11 f0 	movzbl -0xfeedce0(%edx),%eax
f0100266:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f0100269:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f010026f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100274:	0f 44 d1             	cmove  %ecx,%edx
f0100277:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
		return c;
	}
	return 0;
}
f010027d:	c9                   	leave  
f010027e:	c3                   	ret    

f010027f <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f010027f:	55                   	push   %ebp
f0100280:	89 e5                	mov    %esp,%ebp
f0100282:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100285:	e8 b2 ff ff ff       	call   f010023c <cons_getc>
f010028a:	85 c0                	test   %eax,%eax
f010028c:	74 f7                	je     f0100285 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010028e:	c9                   	leave  
f010028f:	c3                   	ret    

f0100290 <iscons>:

int
iscons(int fdnum)
{
f0100290:	55                   	push   %ebp
f0100291:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100293:	b8 01 00 00 00       	mov    $0x1,%eax
f0100298:	5d                   	pop    %ebp
f0100299:	c3                   	ret    

f010029a <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010029a:	55                   	push   %ebp
f010029b:	89 e5                	mov    %esp,%ebp
f010029d:	57                   	push   %edi
f010029e:	56                   	push   %esi
f010029f:	53                   	push   %ebx
f01002a0:	83 ec 2c             	sub    $0x2c,%esp
f01002a3:	89 c7                	mov    %eax,%edi
f01002a5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002aa:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002af:	eb 08                	jmp    f01002b9 <cons_putc+0x1f>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01002b1:	e8 ea fe ff ff       	call   f01001a0 <delay>
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002b6:	83 c3 01             	add    $0x1,%ebx
f01002b9:	89 f2                	mov    %esi,%edx
f01002bb:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002bc:	a8 20                	test   $0x20,%al
f01002be:	75 08                	jne    f01002c8 <cons_putc+0x2e>
f01002c0:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01002c6:	75 e9                	jne    f01002b1 <cons_putc+0x17>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01002c8:	89 fa                	mov    %edi,%edx
f01002ca:	89 f8                	mov    %edi,%eax
f01002cc:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002cf:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002d4:	ee                   	out    %al,(%dx)
f01002d5:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002da:	be 79 03 00 00       	mov    $0x379,%esi
f01002df:	eb 08                	jmp    f01002e9 <cons_putc+0x4f>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f01002e1:	e8 ba fe ff ff       	call   f01001a0 <delay>
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002e6:	83 c3 01             	add    $0x1,%ebx
f01002e9:	89 f2                	mov    %esi,%edx
f01002eb:	ec                   	in     (%dx),%al
f01002ec:	84 c0                	test   %al,%al
f01002ee:	78 08                	js     f01002f8 <cons_putc+0x5e>
f01002f0:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01002f6:	75 e9                	jne    f01002e1 <cons_putc+0x47>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002f8:	ba 78 03 00 00       	mov    $0x378,%edx
f01002fd:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100301:	ee                   	out    %al,(%dx)
f0100302:	b2 7a                	mov    $0x7a,%dl
f0100304:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100309:	ee                   	out    %al,(%dx)
f010030a:	b8 08 00 00 00       	mov    $0x8,%eax
f010030f:	ee                   	out    %al,(%dx)
static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;
f0100310:	89 f8                	mov    %edi,%eax
f0100312:	80 cc 07             	or     $0x7,%ah
f0100315:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010031b:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010031e:	89 f8                	mov    %edi,%eax
f0100320:	25 ff 00 00 00       	and    $0xff,%eax
f0100325:	83 f8 09             	cmp    $0x9,%eax
f0100328:	0f 84 7e 00 00 00    	je     f01003ac <cons_putc+0x112>
f010032e:	83 f8 09             	cmp    $0x9,%eax
f0100331:	7f 0f                	jg     f0100342 <cons_putc+0xa8>
f0100333:	83 f8 08             	cmp    $0x8,%eax
f0100336:	0f 85 a4 00 00 00    	jne    f01003e0 <cons_putc+0x146>
f010033c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100340:	eb 10                	jmp    f0100352 <cons_putc+0xb8>
f0100342:	83 f8 0a             	cmp    $0xa,%eax
f0100345:	74 3b                	je     f0100382 <cons_putc+0xe8>
f0100347:	83 f8 0d             	cmp    $0xd,%eax
f010034a:	0f 85 90 00 00 00    	jne    f01003e0 <cons_putc+0x146>
f0100350:	eb 38                	jmp    f010038a <cons_putc+0xf0>
	case '\b':
		if (crt_pos > 0) {
f0100352:	0f b7 05 10 23 11 f0 	movzwl 0xf0112310,%eax
f0100359:	66 85 c0             	test   %ax,%ax
f010035c:	0f 84 e8 00 00 00    	je     f010044a <cons_putc+0x1b0>
			crt_pos--;
f0100362:	83 e8 01             	sub    $0x1,%eax
f0100365:	66 a3 10 23 11 f0    	mov    %ax,0xf0112310
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010036b:	0f b7 c0             	movzwl %ax,%eax
f010036e:	66 81 e7 00 ff       	and    $0xff00,%di
f0100373:	83 cf 20             	or     $0x20,%edi
f0100376:	8b 15 0c 23 11 f0    	mov    0xf011230c,%edx
f010037c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100380:	eb 7b                	jmp    f01003fd <cons_putc+0x163>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100382:	66 83 05 10 23 11 f0 	addw   $0x50,0xf0112310
f0100389:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010038a:	0f b7 05 10 23 11 f0 	movzwl 0xf0112310,%eax
f0100391:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100397:	c1 e8 10             	shr    $0x10,%eax
f010039a:	66 c1 e8 06          	shr    $0x6,%ax
f010039e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003a1:	c1 e0 04             	shl    $0x4,%eax
f01003a4:	66 a3 10 23 11 f0    	mov    %ax,0xf0112310
f01003aa:	eb 51                	jmp    f01003fd <cons_putc+0x163>
		break;
	case '\t':
		cons_putc(' ');
f01003ac:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b1:	e8 e4 fe ff ff       	call   f010029a <cons_putc>
		cons_putc(' ');
f01003b6:	b8 20 00 00 00       	mov    $0x20,%eax
f01003bb:	e8 da fe ff ff       	call   f010029a <cons_putc>
		cons_putc(' ');
f01003c0:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c5:	e8 d0 fe ff ff       	call   f010029a <cons_putc>
		cons_putc(' ');
f01003ca:	b8 20 00 00 00       	mov    $0x20,%eax
f01003cf:	e8 c6 fe ff ff       	call   f010029a <cons_putc>
		cons_putc(' ');
f01003d4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d9:	e8 bc fe ff ff       	call   f010029a <cons_putc>
f01003de:	eb 1d                	jmp    f01003fd <cons_putc+0x163>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003e0:	0f b7 05 10 23 11 f0 	movzwl 0xf0112310,%eax
f01003e7:	0f b7 c8             	movzwl %ax,%ecx
f01003ea:	8b 15 0c 23 11 f0    	mov    0xf011230c,%edx
f01003f0:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f01003f4:	83 c0 01             	add    $0x1,%eax
f01003f7:	66 a3 10 23 11 f0    	mov    %ax,0xf0112310
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003fd:	66 81 3d 10 23 11 f0 	cmpw   $0x7cf,0xf0112310
f0100404:	cf 07 
f0100406:	76 42                	jbe    f010044a <cons_putc+0x1b0>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100408:	a1 0c 23 11 f0       	mov    0xf011230c,%eax
f010040d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100414:	00 
f0100415:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010041b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010041f:	89 04 24             	mov    %eax,(%esp)
f0100422:	e8 88 10 00 00       	call   f01014af <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100427:	8b 15 0c 23 11 f0    	mov    0xf011230c,%edx
f010042d:	b8 80 07 00 00       	mov    $0x780,%eax
f0100432:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100438:	83 c0 01             	add    $0x1,%eax
f010043b:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100440:	75 f0                	jne    f0100432 <cons_putc+0x198>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100442:	66 83 2d 10 23 11 f0 	subw   $0x50,0xf0112310
f0100449:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010044a:	8b 0d 08 23 11 f0    	mov    0xf0112308,%ecx
f0100450:	89 cb                	mov    %ecx,%ebx
f0100452:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100457:	89 ca                	mov    %ecx,%edx
f0100459:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010045a:	0f b7 35 10 23 11 f0 	movzwl 0xf0112310,%esi
f0100461:	83 c1 01             	add    $0x1,%ecx
f0100464:	89 f0                	mov    %esi,%eax
f0100466:	66 c1 e8 08          	shr    $0x8,%ax
f010046a:	89 ca                	mov    %ecx,%edx
f010046c:	ee                   	out    %al,(%dx)
f010046d:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100472:	89 da                	mov    %ebx,%edx
f0100474:	ee                   	out    %al,(%dx)
f0100475:	89 f0                	mov    %esi,%eax
f0100477:	89 ca                	mov    %ecx,%edx
f0100479:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010047a:	83 c4 2c             	add    $0x2c,%esp
f010047d:	5b                   	pop    %ebx
f010047e:	5e                   	pop    %esi
f010047f:	5f                   	pop    %edi
f0100480:	5d                   	pop    %ebp
f0100481:	c3                   	ret    

f0100482 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100482:	55                   	push   %ebp
f0100483:	89 e5                	mov    %esp,%ebp
f0100485:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100488:	8b 45 08             	mov    0x8(%ebp),%eax
f010048b:	e8 0a fe ff ff       	call   f010029a <cons_putc>
}
f0100490:	c9                   	leave  
f0100491:	c3                   	ret    

f0100492 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100492:	55                   	push   %ebp
f0100493:	89 e5                	mov    %esp,%ebp
f0100495:	57                   	push   %edi
f0100496:	56                   	push   %esi
f0100497:	53                   	push   %ebx
f0100498:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010049b:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f01004a0:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f01004a3:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01004a8:	0f b7 00             	movzwl (%eax),%eax
f01004ab:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01004af:	74 11                	je     f01004c2 <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01004b1:	c7 05 08 23 11 f0 b4 	movl   $0x3b4,0xf0112308
f01004b8:	03 00 00 
f01004bb:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01004c0:	eb 16                	jmp    f01004d8 <cons_init+0x46>
	} else {
		*cp = was;
f01004c2:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01004c9:	c7 05 08 23 11 f0 d4 	movl   $0x3d4,0xf0112308
f01004d0:	03 00 00 
f01004d3:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01004d8:	8b 0d 08 23 11 f0    	mov    0xf0112308,%ecx
f01004de:	89 cb                	mov    %ecx,%ebx
f01004e0:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004e5:	89 ca                	mov    %ecx,%edx
f01004e7:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01004e8:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004eb:	89 ca                	mov    %ecx,%edx
f01004ed:	ec                   	in     (%dx),%al
f01004ee:	0f b6 f8             	movzbl %al,%edi
f01004f1:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004f4:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004f9:	89 da                	mov    %ebx,%edx
f01004fb:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004fc:	89 ca                	mov    %ecx,%edx
f01004fe:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01004ff:	89 35 0c 23 11 f0    	mov    %esi,0xf011230c
	crt_pos = pos;
f0100505:	0f b6 c8             	movzbl %al,%ecx
f0100508:	09 cf                	or     %ecx,%edi
f010050a:	66 89 3d 10 23 11 f0 	mov    %di,0xf0112310
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100511:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100516:	b8 00 00 00 00       	mov    $0x0,%eax
f010051b:	89 da                	mov    %ebx,%edx
f010051d:	ee                   	out    %al,(%dx)
f010051e:	b2 fb                	mov    $0xfb,%dl
f0100520:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100525:	ee                   	out    %al,(%dx)
f0100526:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010052b:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100530:	89 ca                	mov    %ecx,%edx
f0100532:	ee                   	out    %al,(%dx)
f0100533:	b2 f9                	mov    $0xf9,%dl
f0100535:	b8 00 00 00 00       	mov    $0x0,%eax
f010053a:	ee                   	out    %al,(%dx)
f010053b:	b2 fb                	mov    $0xfb,%dl
f010053d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100542:	ee                   	out    %al,(%dx)
f0100543:	b2 fc                	mov    $0xfc,%dl
f0100545:	b8 00 00 00 00       	mov    $0x0,%eax
f010054a:	ee                   	out    %al,(%dx)
f010054b:	b2 f9                	mov    $0xf9,%dl
f010054d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100552:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100553:	b2 fd                	mov    $0xfd,%dl
f0100555:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100556:	3c ff                	cmp    $0xff,%al
f0100558:	0f 95 c0             	setne  %al
f010055b:	89 c6                	mov    %eax,%esi
f010055d:	a2 04 23 11 f0       	mov    %al,0xf0112304
f0100562:	89 da                	mov    %ebx,%edx
f0100564:	ec                   	in     (%dx),%al
f0100565:	89 ca                	mov    %ecx,%edx
f0100567:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100568:	89 f0                	mov    %esi,%eax
f010056a:	84 c0                	test   %al,%al
f010056c:	75 0c                	jne    f010057a <cons_init+0xe8>
		cprintf("Serial port does not exist!\n");
f010056e:	c7 04 24 84 19 10 f0 	movl   $0xf0101984,(%esp)
f0100575:	e8 a9 03 00 00       	call   f0100923 <cprintf>
}
f010057a:	83 c4 1c             	add    $0x1c,%esp
f010057d:	5b                   	pop    %ebx
f010057e:	5e                   	pop    %esi
f010057f:	5f                   	pop    %edi
f0100580:	5d                   	pop    %ebp
f0100581:	c3                   	ret    

f0100582 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100582:	55                   	push   %ebp
f0100583:	89 e5                	mov    %esp,%ebp
f0100585:	53                   	push   %ebx
f0100586:	83 ec 14             	sub    $0x14,%esp
f0100589:	ba 64 00 00 00       	mov    $0x64,%edx
f010058e:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010058f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100594:	a8 01                	test   $0x1,%al
f0100596:	0f 84 dd 00 00 00    	je     f0100679 <kbd_proc_data+0xf7>
f010059c:	b2 60                	mov    $0x60,%dl
f010059e:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010059f:	3c e0                	cmp    $0xe0,%al
f01005a1:	75 11                	jne    f01005b4 <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f01005a3:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
f01005aa:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01005af:	e9 c5 00 00 00       	jmp    f0100679 <kbd_proc_data+0xf7>
	} else if (data & 0x80) {
f01005b4:	84 c0                	test   %al,%al
f01005b6:	79 35                	jns    f01005ed <kbd_proc_data+0x6b>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01005b8:	8b 15 00 23 11 f0    	mov    0xf0112300,%edx
f01005be:	89 c1                	mov    %eax,%ecx
f01005c0:	83 e1 7f             	and    $0x7f,%ecx
f01005c3:	f6 c2 40             	test   $0x40,%dl
f01005c6:	0f 44 c1             	cmove  %ecx,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f01005c9:	0f b6 c0             	movzbl %al,%eax
f01005cc:	0f b6 80 c0 19 10 f0 	movzbl -0xfefe640(%eax),%eax
f01005d3:	83 c8 40             	or     $0x40,%eax
f01005d6:	0f b6 c0             	movzbl %al,%eax
f01005d9:	f7 d0                	not    %eax
f01005db:	21 c2                	and    %eax,%edx
f01005dd:	89 15 00 23 11 f0    	mov    %edx,0xf0112300
f01005e3:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01005e8:	e9 8c 00 00 00       	jmp    f0100679 <kbd_proc_data+0xf7>
	} else if (shift & E0ESC) {
f01005ed:	8b 15 00 23 11 f0    	mov    0xf0112300,%edx
f01005f3:	f6 c2 40             	test   $0x40,%dl
f01005f6:	74 0c                	je     f0100604 <kbd_proc_data+0x82>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01005f8:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f01005fb:	83 e2 bf             	and    $0xffffffbf,%edx
f01005fe:	89 15 00 23 11 f0    	mov    %edx,0xf0112300
	}

	shift |= shiftcode[data];
f0100604:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f0100607:	0f b6 90 c0 19 10 f0 	movzbl -0xfefe640(%eax),%edx
f010060e:	0b 15 00 23 11 f0    	or     0xf0112300,%edx
f0100614:	0f b6 88 c0 1a 10 f0 	movzbl -0xfefe540(%eax),%ecx
f010061b:	31 ca                	xor    %ecx,%edx
f010061d:	89 15 00 23 11 f0    	mov    %edx,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100623:	89 d1                	mov    %edx,%ecx
f0100625:	83 e1 03             	and    $0x3,%ecx
f0100628:	8b 0c 8d c0 1b 10 f0 	mov    -0xfefe440(,%ecx,4),%ecx
f010062f:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100633:	f6 c2 08             	test   $0x8,%dl
f0100636:	74 1b                	je     f0100653 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100638:	89 d9                	mov    %ebx,%ecx
f010063a:	8d 43 9f             	lea    -0x61(%ebx),%eax
f010063d:	83 f8 19             	cmp    $0x19,%eax
f0100640:	77 05                	ja     f0100647 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100642:	83 eb 20             	sub    $0x20,%ebx
f0100645:	eb 0c                	jmp    f0100653 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100647:	83 e9 41             	sub    $0x41,%ecx
			c += 'a' - 'A';
f010064a:	8d 43 20             	lea    0x20(%ebx),%eax
f010064d:	83 f9 19             	cmp    $0x19,%ecx
f0100650:	0f 46 d8             	cmovbe %eax,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100653:	f7 d2                	not    %edx
f0100655:	f6 c2 06             	test   $0x6,%dl
f0100658:	75 1f                	jne    f0100679 <kbd_proc_data+0xf7>
f010065a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100660:	75 17                	jne    f0100679 <kbd_proc_data+0xf7>
		cprintf("Rebooting!\n");
f0100662:	c7 04 24 a1 19 10 f0 	movl   $0xf01019a1,(%esp)
f0100669:	e8 b5 02 00 00       	call   f0100923 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010066e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100673:	b8 03 00 00 00       	mov    $0x3,%eax
f0100678:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100679:	89 d8                	mov    %ebx,%eax
f010067b:	83 c4 14             	add    $0x14,%esp
f010067e:	5b                   	pop    %ebx
f010067f:	5d                   	pop    %ebp
f0100680:	c3                   	ret    
	...

f0100690 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100690:	55                   	push   %ebp
f0100691:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100693:	b8 00 00 00 00       	mov    $0x0,%eax
f0100698:	5d                   	pop    %ebp
f0100699:	c3                   	ret    

f010069a <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010069a:	55                   	push   %ebp
f010069b:	89 e5                	mov    %esp,%ebp
f010069d:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006a0:	c7 04 24 d0 1b 10 f0 	movl   $0xf0101bd0,(%esp)
f01006a7:	e8 77 02 00 00       	call   f0100923 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006ac:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01006b3:	00 
f01006b4:	c7 04 24 5c 1c 10 f0 	movl   $0xf0101c5c,(%esp)
f01006bb:	e8 63 02 00 00       	call   f0100923 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006c0:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006c7:	00 
f01006c8:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006cf:	f0 
f01006d0:	c7 04 24 84 1c 10 f0 	movl   $0xf0101c84,(%esp)
f01006d7:	e8 47 02 00 00       	call   f0100923 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006dc:	c7 44 24 08 fb 18 10 	movl   $0x1018fb,0x8(%esp)
f01006e3:	00 
f01006e4:	c7 44 24 04 fb 18 10 	movl   $0xf01018fb,0x4(%esp)
f01006eb:	f0 
f01006ec:	c7 04 24 a8 1c 10 f0 	movl   $0xf0101ca8,(%esp)
f01006f3:	e8 2b 02 00 00       	call   f0100923 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006f8:	c7 44 24 08 00 23 11 	movl   $0x112300,0x8(%esp)
f01006ff:	00 
f0100700:	c7 44 24 04 00 23 11 	movl   $0xf0112300,0x4(%esp)
f0100707:	f0 
f0100708:	c7 04 24 cc 1c 10 f0 	movl   $0xf0101ccc,(%esp)
f010070f:	e8 0f 02 00 00       	call   f0100923 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100714:	c7 44 24 08 44 29 11 	movl   $0x112944,0x8(%esp)
f010071b:	00 
f010071c:	c7 44 24 04 44 29 11 	movl   $0xf0112944,0x4(%esp)
f0100723:	f0 
f0100724:	c7 04 24 f0 1c 10 f0 	movl   $0xf0101cf0,(%esp)
f010072b:	e8 f3 01 00 00       	call   f0100923 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100730:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100735:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010073a:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010073f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100745:	85 c0                	test   %eax,%eax
f0100747:	0f 48 c2             	cmovs  %edx,%eax
f010074a:	c1 f8 0a             	sar    $0xa,%eax
f010074d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100751:	c7 04 24 14 1d 10 f0 	movl   $0xf0101d14,(%esp)
f0100758:	e8 c6 01 00 00       	call   f0100923 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010075d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100762:	c9                   	leave  
f0100763:	c3                   	ret    

f0100764 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100764:	55                   	push   %ebp
f0100765:	89 e5                	mov    %esp,%ebp
f0100767:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010076a:	a1 b8 1d 10 f0       	mov    0xf0101db8,%eax
f010076f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100773:	a1 b4 1d 10 f0       	mov    0xf0101db4,%eax
f0100778:	89 44 24 04          	mov    %eax,0x4(%esp)
f010077c:	c7 04 24 e9 1b 10 f0 	movl   $0xf0101be9,(%esp)
f0100783:	e8 9b 01 00 00       	call   f0100923 <cprintf>
f0100788:	a1 c4 1d 10 f0       	mov    0xf0101dc4,%eax
f010078d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100791:	a1 c0 1d 10 f0       	mov    0xf0101dc0,%eax
f0100796:	89 44 24 04          	mov    %eax,0x4(%esp)
f010079a:	c7 04 24 e9 1b 10 f0 	movl   $0xf0101be9,(%esp)
f01007a1:	e8 7d 01 00 00       	call   f0100923 <cprintf>
	return 0;
}
f01007a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ab:	c9                   	leave  
f01007ac:	c3                   	ret    

f01007ad <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007ad:	55                   	push   %ebp
f01007ae:	89 e5                	mov    %esp,%ebp
f01007b0:	57                   	push   %edi
f01007b1:	56                   	push   %esi
f01007b2:	53                   	push   %ebx
f01007b3:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007b6:	c7 04 24 40 1d 10 f0 	movl   $0xf0101d40,(%esp)
f01007bd:	e8 61 01 00 00       	call   f0100923 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007c2:	c7 04 24 64 1d 10 f0 	movl   $0xf0101d64,(%esp)
f01007c9:	e8 55 01 00 00       	call   f0100923 <cprintf>

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01007ce:	bf b4 1d 10 f0       	mov    $0xf0101db4,%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f01007d3:	c7 04 24 f2 1b 10 f0 	movl   $0xf0101bf2,(%esp)
f01007da:	e8 21 0a 00 00       	call   f0101200 <readline>
f01007df:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007e1:	85 c0                	test   %eax,%eax
f01007e3:	74 ee                	je     f01007d3 <monitor+0x26>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007e5:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f01007ec:	be 00 00 00 00       	mov    $0x0,%esi
f01007f1:	eb 06                	jmp    f01007f9 <monitor+0x4c>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007f3:	c6 03 00             	movb   $0x0,(%ebx)
f01007f6:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007f9:	0f b6 03             	movzbl (%ebx),%eax
f01007fc:	84 c0                	test   %al,%al
f01007fe:	74 64                	je     f0100864 <monitor+0xb7>
f0100800:	0f be c0             	movsbl %al,%eax
f0100803:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100807:	c7 04 24 f6 1b 10 f0 	movl   $0xf0101bf6,(%esp)
f010080e:	e8 00 0c 00 00       	call   f0101413 <strchr>
f0100813:	85 c0                	test   %eax,%eax
f0100815:	75 dc                	jne    f01007f3 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100817:	80 3b 00             	cmpb   $0x0,(%ebx)
f010081a:	74 48                	je     f0100864 <monitor+0xb7>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010081c:	83 fe 0f             	cmp    $0xf,%esi
f010081f:	90                   	nop
f0100820:	75 16                	jne    f0100838 <monitor+0x8b>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100822:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100829:	00 
f010082a:	c7 04 24 fb 1b 10 f0 	movl   $0xf0101bfb,(%esp)
f0100831:	e8 ed 00 00 00       	call   f0100923 <cprintf>
f0100836:	eb 9b                	jmp    f01007d3 <monitor+0x26>
			return 0;
		}
		argv[argc++] = buf;
f0100838:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010083c:	83 c6 01             	add    $0x1,%esi
f010083f:	eb 03                	jmp    f0100844 <monitor+0x97>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100841:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100844:	0f b6 03             	movzbl (%ebx),%eax
f0100847:	84 c0                	test   %al,%al
f0100849:	74 ae                	je     f01007f9 <monitor+0x4c>
f010084b:	0f be c0             	movsbl %al,%eax
f010084e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100852:	c7 04 24 f6 1b 10 f0 	movl   $0xf0101bf6,(%esp)
f0100859:	e8 b5 0b 00 00       	call   f0101413 <strchr>
f010085e:	85 c0                	test   %eax,%eax
f0100860:	74 df                	je     f0100841 <monitor+0x94>
f0100862:	eb 95                	jmp    f01007f9 <monitor+0x4c>
			buf++;
	}
	argv[argc] = 0;
f0100864:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010086b:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010086c:	85 f6                	test   %esi,%esi
f010086e:	0f 84 5f ff ff ff    	je     f01007d3 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100874:	8b 07                	mov    (%edi),%eax
f0100876:	89 44 24 04          	mov    %eax,0x4(%esp)
f010087a:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010087d:	89 04 24             	mov    %eax,(%esp)
f0100880:	e8 2f 0b 00 00       	call   f01013b4 <strcmp>
f0100885:	ba 00 00 00 00       	mov    $0x0,%edx
f010088a:	85 c0                	test   %eax,%eax
f010088c:	74 1d                	je     f01008ab <monitor+0xfe>
f010088e:	a1 c0 1d 10 f0       	mov    0xf0101dc0,%eax
f0100893:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100897:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010089a:	89 04 24             	mov    %eax,(%esp)
f010089d:	e8 12 0b 00 00       	call   f01013b4 <strcmp>
f01008a2:	85 c0                	test   %eax,%eax
f01008a4:	75 28                	jne    f01008ce <monitor+0x121>
f01008a6:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f01008ab:	6b d2 0c             	imul   $0xc,%edx,%edx
f01008ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01008b1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008b5:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01008b8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008bc:	89 34 24             	mov    %esi,(%esp)
f01008bf:	ff 92 bc 1d 10 f0    	call   *-0xfefe244(%edx)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008c5:	85 c0                	test   %eax,%eax
f01008c7:	78 1d                	js     f01008e6 <monitor+0x139>
f01008c9:	e9 05 ff ff ff       	jmp    f01007d3 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008ce:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008d5:	c7 04 24 18 1c 10 f0 	movl   $0xf0101c18,(%esp)
f01008dc:	e8 42 00 00 00       	call   f0100923 <cprintf>
f01008e1:	e9 ed fe ff ff       	jmp    f01007d3 <monitor+0x26>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008e6:	83 c4 5c             	add    $0x5c,%esp
f01008e9:	5b                   	pop    %ebx
f01008ea:	5e                   	pop    %esi
f01008eb:	5f                   	pop    %edi
f01008ec:	5d                   	pop    %ebp
f01008ed:	c3                   	ret    
	...

f01008f0 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f01008f0:	55                   	push   %ebp
f01008f1:	89 e5                	mov    %esp,%ebp
f01008f3:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01008f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100900:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100904:	8b 45 08             	mov    0x8(%ebp),%eax
f0100907:	89 44 24 08          	mov    %eax,0x8(%esp)
f010090b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010090e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100912:	c7 04 24 3d 09 10 f0 	movl   $0xf010093d,(%esp)
f0100919:	e8 41 04 00 00       	call   f0100d5f <vprintfmt>
	return cnt;
}
f010091e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100921:	c9                   	leave  
f0100922:	c3                   	ret    

f0100923 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100923:	55                   	push   %ebp
f0100924:	89 e5                	mov    %esp,%ebp
f0100926:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0100929:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f010092c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100930:	8b 45 08             	mov    0x8(%ebp),%eax
f0100933:	89 04 24             	mov    %eax,(%esp)
f0100936:	e8 b5 ff ff ff       	call   f01008f0 <vcprintf>
	va_end(ap);

	return cnt;
}
f010093b:	c9                   	leave  
f010093c:	c3                   	ret    

f010093d <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010093d:	55                   	push   %ebp
f010093e:	89 e5                	mov    %esp,%ebp
f0100940:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100943:	8b 45 08             	mov    0x8(%ebp),%eax
f0100946:	89 04 24             	mov    %eax,(%esp)
f0100949:	e8 34 fb ff ff       	call   f0100482 <cputchar>
	*cnt++;
}
f010094e:	c9                   	leave  
f010094f:	c3                   	ret    

f0100950 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100950:	55                   	push   %ebp
f0100951:	89 e5                	mov    %esp,%ebp
f0100953:	57                   	push   %edi
f0100954:	56                   	push   %esi
f0100955:	53                   	push   %ebx
f0100956:	83 ec 14             	sub    $0x14,%esp
f0100959:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010095c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010095f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100962:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100965:	8b 1a                	mov    (%edx),%ebx
f0100967:	8b 01                	mov    (%ecx),%eax
f0100969:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010096c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f0100973:	e9 88 00 00 00       	jmp    f0100a00 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0100978:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010097b:	01 d8                	add    %ebx,%eax
f010097d:	89 c7                	mov    %eax,%edi
f010097f:	c1 ef 1f             	shr    $0x1f,%edi
f0100982:	01 c7                	add    %eax,%edi
f0100984:	d1 ff                	sar    %edi
f0100986:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100989:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010098c:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100990:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100992:	eb 03                	jmp    f0100997 <stab_binsearch+0x47>
			m--;
f0100994:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100997:	39 c3                	cmp    %eax,%ebx
f0100999:	7f 0c                	jg     f01009a7 <stab_binsearch+0x57>
f010099b:	0f b6 0a             	movzbl (%edx),%ecx
f010099e:	83 ea 0c             	sub    $0xc,%edx
f01009a1:	39 f1                	cmp    %esi,%ecx
f01009a3:	75 ef                	jne    f0100994 <stab_binsearch+0x44>
f01009a5:	eb 05                	jmp    f01009ac <stab_binsearch+0x5c>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01009a7:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01009aa:	eb 54                	jmp    f0100a00 <stab_binsearch+0xb0>
f01009ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009af:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009b2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009b5:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01009b9:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01009bc:	76 11                	jbe    f01009cf <stab_binsearch+0x7f>
			*region_left = m;
f01009be:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01009c1:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01009c3:	8d 5f 01             	lea    0x1(%edi),%ebx
f01009c6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01009cd:	eb 31                	jmp    f0100a00 <stab_binsearch+0xb0>
		} else if (stabs[m].n_value > addr) {
f01009cf:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01009d2:	73 17                	jae    f01009eb <stab_binsearch+0x9b>
			*region_right = m - 1;
f01009d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009d7:	83 e8 01             	sub    $0x1,%eax
f01009da:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009dd:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01009e0:	89 02                	mov    %eax,(%edx)
f01009e2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01009e9:	eb 15                	jmp    f0100a00 <stab_binsearch+0xb0>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01009eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01009ee:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01009f1:	89 19                	mov    %ebx,(%ecx)
			l = m;
			addr++;
f01009f3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01009f7:	89 c3                	mov    %eax,%ebx
f01009f9:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a00:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a03:	0f 8e 6f ff ff ff    	jle    f0100978 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a09:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100a0d:	75 0f                	jne    f0100a1e <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0100a0f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a12:	8b 02                	mov    (%edx),%eax
f0100a14:	83 e8 01             	sub    $0x1,%eax
f0100a17:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100a1a:	89 01                	mov    %eax,(%ecx)
f0100a1c:	eb 2c                	jmp    f0100a4a <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a1e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100a21:	8b 03                	mov    (%ebx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a23:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a26:	8b 0a                	mov    (%edx),%ecx
f0100a28:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a2b:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0100a2e:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a32:	eb 03                	jmp    f0100a37 <stab_binsearch+0xe7>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a34:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a37:	39 c8                	cmp    %ecx,%eax
f0100a39:	7e 0a                	jle    f0100a45 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0100a3b:	0f b6 1a             	movzbl (%edx),%ebx
f0100a3e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a41:	39 f3                	cmp    %esi,%ebx
f0100a43:	75 ef                	jne    f0100a34 <stab_binsearch+0xe4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a45:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a48:	89 02                	mov    %eax,(%edx)
	}
}
f0100a4a:	83 c4 14             	add    $0x14,%esp
f0100a4d:	5b                   	pop    %ebx
f0100a4e:	5e                   	pop    %esi
f0100a4f:	5f                   	pop    %edi
f0100a50:	5d                   	pop    %ebp
f0100a51:	c3                   	ret    

f0100a52 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a52:	55                   	push   %ebp
f0100a53:	89 e5                	mov    %esp,%ebp
f0100a55:	83 ec 28             	sub    $0x28,%esp
f0100a58:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100a5b:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100a5e:	8b 75 08             	mov    0x8(%ebp),%esi
f0100a61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a64:	c7 03 cc 1d 10 f0    	movl   $0xf0101dcc,(%ebx)
	info->eip_line = 0;
f0100a6a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100a71:	c7 43 08 cc 1d 10 f0 	movl   $0xf0101dcc,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100a78:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100a7f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100a82:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100a89:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100a8f:	76 12                	jbe    f0100aa3 <debuginfo_eip+0x51>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a91:	b8 b9 73 10 f0       	mov    $0xf01073b9,%eax
f0100a96:	3d 31 5a 10 f0       	cmp    $0xf0105a31,%eax
f0100a9b:	0f 86 4f 01 00 00    	jbe    f0100bf0 <debuginfo_eip+0x19e>
f0100aa1:	eb 1c                	jmp    f0100abf <debuginfo_eip+0x6d>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100aa3:	c7 44 24 08 d6 1d 10 	movl   $0xf0101dd6,0x8(%esp)
f0100aaa:	f0 
f0100aab:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100ab2:	00 
f0100ab3:	c7 04 24 e3 1d 10 f0 	movl   $0xf0101de3,(%esp)
f0100aba:	e8 c6 f5 ff ff       	call   f0100085 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100abf:	80 3d b8 73 10 f0 00 	cmpb   $0x0,0xf01073b8
f0100ac6:	0f 85 24 01 00 00    	jne    f0100bf0 <debuginfo_eip+0x19e>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100acc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100ad3:	b8 30 5a 10 f0       	mov    $0xf0105a30,%eax
f0100ad8:	2d 10 20 10 f0       	sub    $0xf0102010,%eax
f0100add:	c1 f8 02             	sar    $0x2,%eax
f0100ae0:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100ae6:	83 e8 01             	sub    $0x1,%eax
f0100ae9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100aec:	8d 4d f0             	lea    -0x10(%ebp),%ecx
f0100aef:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0100af2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100af6:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100afd:	b8 10 20 10 f0       	mov    $0xf0102010,%eax
f0100b02:	e8 49 fe ff ff       	call   f0100950 <stab_binsearch>
	if (lfile == 0)
f0100b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b0a:	85 c0                	test   %eax,%eax
f0100b0c:	0f 84 de 00 00 00    	je     f0100bf0 <debuginfo_eip+0x19e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b12:	89 45 ec             	mov    %eax,-0x14(%ebp)
	rfun = rfile;
f0100b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b18:	89 45 e8             	mov    %eax,-0x18(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b1b:	8d 4d e8             	lea    -0x18(%ebp),%ecx
f0100b1e:	8d 55 ec             	lea    -0x14(%ebp),%edx
f0100b21:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b25:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100b2c:	b8 10 20 10 f0       	mov    $0xf0102010,%eax
f0100b31:	e8 1a fe ff ff       	call   f0100950 <stab_binsearch>

	if (lfun <= rfun) {
f0100b36:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100b39:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0100b3c:	7f 31                	jg     f0100b6f <debuginfo_eip+0x11d>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b3e:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100b41:	8b 80 10 20 10 f0    	mov    -0xfefdff0(%eax),%eax
f0100b47:	ba b9 73 10 f0       	mov    $0xf01073b9,%edx
f0100b4c:	81 ea 31 5a 10 f0    	sub    $0xf0105a31,%edx
f0100b52:	39 d0                	cmp    %edx,%eax
f0100b54:	73 08                	jae    f0100b5e <debuginfo_eip+0x10c>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b56:	05 31 5a 10 f0       	add    $0xf0105a31,%eax
f0100b5b:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b5e:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100b61:	6b c6 0c             	imul   $0xc,%esi,%eax
f0100b64:	8b 80 18 20 10 f0    	mov    -0xfefdfe8(%eax),%eax
f0100b6a:	89 43 10             	mov    %eax,0x10(%ebx)
f0100b6d:	eb 06                	jmp    f0100b75 <debuginfo_eip+0x123>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100b6f:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100b72:	8b 75 f4             	mov    -0xc(%ebp),%esi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100b75:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100b7c:	00 
f0100b7d:	8b 43 08             	mov    0x8(%ebx),%eax
f0100b80:	89 04 24             	mov    %eax,(%esp)
f0100b83:	e8 ac 08 00 00       	call   f0101434 <strfind>
f0100b88:	2b 43 08             	sub    0x8(%ebx),%eax
f0100b8b:	89 43 0c             	mov    %eax,0xc(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0100b8e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f0100b91:	6b c6 0c             	imul   $0xc,%esi,%eax
f0100b94:	05 18 20 10 f0       	add    $0xf0102018,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b99:	eb 06                	jmp    f0100ba1 <debuginfo_eip+0x14f>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100b9b:	83 ee 01             	sub    $0x1,%esi
f0100b9e:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100ba1:	39 ce                	cmp    %ecx,%esi
f0100ba3:	7c 1c                	jl     f0100bc1 <debuginfo_eip+0x16f>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100ba5:	0f b6 50 fc          	movzbl -0x4(%eax),%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100ba9:	80 fa 84             	cmp    $0x84,%dl
f0100bac:	74 58                	je     f0100c06 <debuginfo_eip+0x1b4>
f0100bae:	80 fa 64             	cmp    $0x64,%dl
f0100bb1:	75 e8                	jne    f0100b9b <debuginfo_eip+0x149>
f0100bb3:	83 38 00             	cmpl   $0x0,(%eax)
f0100bb6:	74 e3                	je     f0100b9b <debuginfo_eip+0x149>
f0100bb8:	eb 4c                	jmp    f0100c06 <debuginfo_eip+0x1b4>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100bba:	05 31 5a 10 f0       	add    $0xf0105a31,%eax
f0100bbf:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100bc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100bc4:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0100bc7:	7d 2e                	jge    f0100bf7 <debuginfo_eip+0x1a5>
		for (lline = lfun + 1;
f0100bc9:	83 c0 01             	add    $0x1,%eax
f0100bcc:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100bcf:	81 c2 14 20 10 f0    	add    $0xf0102014,%edx
f0100bd5:	eb 07                	jmp    f0100bde <debuginfo_eip+0x18c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100bd7:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100bdb:	83 c0 01             	add    $0x1,%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100bde:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0100be1:	7d 14                	jge    f0100bf7 <debuginfo_eip+0x1a5>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100be3:	0f b6 0a             	movzbl (%edx),%ecx
f0100be6:	83 c2 0c             	add    $0xc,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100be9:	80 f9 a0             	cmp    $0xa0,%cl
f0100bec:	74 e9                	je     f0100bd7 <debuginfo_eip+0x185>
f0100bee:	eb 07                	jmp    f0100bf7 <debuginfo_eip+0x1a5>
f0100bf0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bf5:	eb 05                	jmp    f0100bfc <debuginfo_eip+0x1aa>
f0100bf7:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0100bfc:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100bff:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100c02:	89 ec                	mov    %ebp,%esp
f0100c04:	5d                   	pop    %ebp
f0100c05:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c06:	6b f6 0c             	imul   $0xc,%esi,%esi
f0100c09:	8b 86 10 20 10 f0    	mov    -0xfefdff0(%esi),%eax
f0100c0f:	ba b9 73 10 f0       	mov    $0xf01073b9,%edx
f0100c14:	81 ea 31 5a 10 f0    	sub    $0xf0105a31,%edx
f0100c1a:	39 d0                	cmp    %edx,%eax
f0100c1c:	72 9c                	jb     f0100bba <debuginfo_eip+0x168>
f0100c1e:	eb a1                	jmp    f0100bc1 <debuginfo_eip+0x16f>

f0100c20 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100c20:	55                   	push   %ebp
f0100c21:	89 e5                	mov    %esp,%ebp
f0100c23:	57                   	push   %edi
f0100c24:	56                   	push   %esi
f0100c25:	53                   	push   %ebx
f0100c26:	83 ec 4c             	sub    $0x4c,%esp
f0100c29:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100c2c:	89 d6                	mov    %edx,%esi
f0100c2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c31:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100c34:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100c37:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c3a:	8b 45 10             	mov    0x10(%ebp),%eax
f0100c3d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100c40:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100c43:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100c46:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100c4b:	39 d1                	cmp    %edx,%ecx
f0100c4d:	72 07                	jb     f0100c56 <printnum+0x36>
f0100c4f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100c52:	39 d0                	cmp    %edx,%eax
f0100c54:	77 69                	ja     f0100cbf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100c56:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0100c5a:	83 eb 01             	sub    $0x1,%ebx
f0100c5d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100c61:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0100c69:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0100c6d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100c70:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0100c73:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100c76:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100c7a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100c81:	00 
f0100c82:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c85:	89 04 24             	mov    %eax,(%esp)
f0100c88:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100c8b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100c8f:	e8 fc 09 00 00       	call   f0101690 <__udivdi3>
f0100c94:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100c97:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c9a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100c9e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100ca2:	89 04 24             	mov    %eax,(%esp)
f0100ca5:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100ca9:	89 f2                	mov    %esi,%edx
f0100cab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cae:	e8 6d ff ff ff       	call   f0100c20 <printnum>
f0100cb3:	eb 11                	jmp    f0100cc6 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100cb5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100cb9:	89 3c 24             	mov    %edi,(%esp)
f0100cbc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100cbf:	83 eb 01             	sub    $0x1,%ebx
f0100cc2:	85 db                	test   %ebx,%ebx
f0100cc4:	7f ef                	jg     f0100cb5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100cc6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100cca:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100cce:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cd1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100cd5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100cdc:	00 
f0100cdd:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100ce0:	89 14 24             	mov    %edx,(%esp)
f0100ce3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100ce6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100cea:	e8 d1 0a 00 00       	call   f01017c0 <__umoddi3>
f0100cef:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100cf3:	0f be 80 f1 1d 10 f0 	movsbl -0xfefe20f(%eax),%eax
f0100cfa:	89 04 24             	mov    %eax,(%esp)
f0100cfd:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100d00:	83 c4 4c             	add    $0x4c,%esp
f0100d03:	5b                   	pop    %ebx
f0100d04:	5e                   	pop    %esi
f0100d05:	5f                   	pop    %edi
f0100d06:	5d                   	pop    %ebp
f0100d07:	c3                   	ret    

f0100d08 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d08:	55                   	push   %ebp
f0100d09:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d0b:	83 fa 01             	cmp    $0x1,%edx
f0100d0e:	7e 0e                	jle    f0100d1e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d10:	8b 10                	mov    (%eax),%edx
f0100d12:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d15:	89 08                	mov    %ecx,(%eax)
f0100d17:	8b 02                	mov    (%edx),%eax
f0100d19:	8b 52 04             	mov    0x4(%edx),%edx
f0100d1c:	eb 22                	jmp    f0100d40 <getuint+0x38>
	else if (lflag)
f0100d1e:	85 d2                	test   %edx,%edx
f0100d20:	74 10                	je     f0100d32 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d22:	8b 10                	mov    (%eax),%edx
f0100d24:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d27:	89 08                	mov    %ecx,(%eax)
f0100d29:	8b 02                	mov    (%edx),%eax
f0100d2b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d30:	eb 0e                	jmp    f0100d40 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100d32:	8b 10                	mov    (%eax),%edx
f0100d34:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d37:	89 08                	mov    %ecx,(%eax)
f0100d39:	8b 02                	mov    (%edx),%eax
f0100d3b:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100d40:	5d                   	pop    %ebp
f0100d41:	c3                   	ret    

f0100d42 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d42:	55                   	push   %ebp
f0100d43:	89 e5                	mov    %esp,%ebp
f0100d45:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d48:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100d4c:	8b 10                	mov    (%eax),%edx
f0100d4e:	3b 50 04             	cmp    0x4(%eax),%edx
f0100d51:	73 0a                	jae    f0100d5d <sprintputch+0x1b>
		*b->buf++ = ch;
f0100d53:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100d56:	88 0a                	mov    %cl,(%edx)
f0100d58:	83 c2 01             	add    $0x1,%edx
f0100d5b:	89 10                	mov    %edx,(%eax)
}
f0100d5d:	5d                   	pop    %ebp
f0100d5e:	c3                   	ret    

f0100d5f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100d5f:	55                   	push   %ebp
f0100d60:	89 e5                	mov    %esp,%ebp
f0100d62:	57                   	push   %edi
f0100d63:	56                   	push   %esi
f0100d64:	53                   	push   %ebx
f0100d65:	83 ec 4c             	sub    $0x4c,%esp
f0100d68:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100d6b:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100d6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0100d71:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0100d78:	eb 11                	jmp    f0100d8b <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100d7a:	85 c0                	test   %eax,%eax
f0100d7c:	0f 84 cd 03 00 00    	je     f010114f <vprintfmt+0x3f0>
				return;
			putch(ch, putdat);
f0100d82:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d86:	89 04 24             	mov    %eax,(%esp)
f0100d89:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100d8b:	0f b6 03             	movzbl (%ebx),%eax
f0100d8e:	83 c3 01             	add    $0x1,%ebx
f0100d91:	83 f8 25             	cmp    $0x25,%eax
f0100d94:	75 e4                	jne    f0100d7a <vprintfmt+0x1b>
f0100d96:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
f0100d9a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100da1:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0100da8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100daf:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100db4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100db7:	eb 06                	jmp    f0100dbf <vprintfmt+0x60>
f0100db9:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
f0100dbd:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dbf:	0f b6 0b             	movzbl (%ebx),%ecx
f0100dc2:	0f b6 c1             	movzbl %cl,%eax
f0100dc5:	8d 53 01             	lea    0x1(%ebx),%edx
f0100dc8:	83 e9 23             	sub    $0x23,%ecx
f0100dcb:	80 f9 55             	cmp    $0x55,%cl
f0100dce:	0f 87 5e 03 00 00    	ja     f0101132 <vprintfmt+0x3d3>
f0100dd4:	0f b6 c9             	movzbl %cl,%ecx
f0100dd7:	ff 24 8d 80 1e 10 f0 	jmp    *-0xfefe180(,%ecx,4)
f0100dde:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
f0100de2:	eb d9                	jmp    f0100dbd <vprintfmt+0x5e>
f0100de4:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0100deb:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100df0:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0100df3:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0100df7:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
f0100dfa:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0100dfd:	83 fb 09             	cmp    $0x9,%ebx
f0100e00:	77 30                	ja     f0100e32 <vprintfmt+0xd3>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e02:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100e05:	eb e9                	jmp    f0100df0 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e07:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e0a:	8d 48 04             	lea    0x4(%eax),%ecx
f0100e0d:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100e10:	8b 00                	mov    (%eax),%eax
f0100e12:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
f0100e15:	eb 1e                	jmp    f0100e35 <vprintfmt+0xd6>

		case '.':
			if (width < 0)
f0100e17:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100e1b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e20:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
f0100e24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e27:	eb 94                	jmp    f0100dbd <vprintfmt+0x5e>
f0100e29:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0100e30:	eb 8b                	jmp    f0100dbd <vprintfmt+0x5e>
f0100e32:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
f0100e35:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100e39:	79 82                	jns    f0100dbd <vprintfmt+0x5e>
f0100e3b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100e3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e41:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100e44:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100e47:	e9 71 ff ff ff       	jmp    f0100dbd <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100e4c:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0100e50:	e9 68 ff ff ff       	jmp    f0100dbd <vprintfmt+0x5e>
f0100e55:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100e58:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e5b:	8d 50 04             	lea    0x4(%eax),%edx
f0100e5e:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e61:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100e65:	8b 00                	mov    (%eax),%eax
f0100e67:	89 04 24             	mov    %eax,(%esp)
f0100e6a:	ff d7                	call   *%edi
f0100e6c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f0100e6f:	e9 17 ff ff ff       	jmp    f0100d8b <vprintfmt+0x2c>
f0100e74:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100e77:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e7a:	8d 50 04             	lea    0x4(%eax),%edx
f0100e7d:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e80:	8b 00                	mov    (%eax),%eax
f0100e82:	89 c2                	mov    %eax,%edx
f0100e84:	c1 fa 1f             	sar    $0x1f,%edx
f0100e87:	31 d0                	xor    %edx,%eax
f0100e89:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100e8b:	83 f8 07             	cmp    $0x7,%eax
f0100e8e:	7f 0b                	jg     f0100e9b <vprintfmt+0x13c>
f0100e90:	8b 14 85 e0 1f 10 f0 	mov    -0xfefe020(,%eax,4),%edx
f0100e97:	85 d2                	test   %edx,%edx
f0100e99:	75 20                	jne    f0100ebb <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f0100e9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e9f:	c7 44 24 08 02 1e 10 	movl   $0xf0101e02,0x8(%esp)
f0100ea6:	f0 
f0100ea7:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100eab:	89 3c 24             	mov    %edi,(%esp)
f0100eae:	e8 24 03 00 00       	call   f01011d7 <printfmt>
f0100eb3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100eb6:	e9 d0 fe ff ff       	jmp    f0100d8b <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0100ebb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100ebf:	c7 44 24 08 0b 1e 10 	movl   $0xf0101e0b,0x8(%esp)
f0100ec6:	f0 
f0100ec7:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ecb:	89 3c 24             	mov    %edi,(%esp)
f0100ece:	e8 04 03 00 00       	call   f01011d7 <printfmt>
f0100ed3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100ed6:	e9 b0 fe ff ff       	jmp    f0100d8b <vprintfmt+0x2c>
f0100edb:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100ede:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100ee1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ee4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100ee7:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eea:	8d 50 04             	lea    0x4(%eax),%edx
f0100eed:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ef0:	8b 18                	mov    (%eax),%ebx
f0100ef2:	85 db                	test   %ebx,%ebx
f0100ef4:	b8 0e 1e 10 f0       	mov    $0xf0101e0e,%eax
f0100ef9:	0f 44 d8             	cmove  %eax,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
f0100efc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100f00:	7e 76                	jle    f0100f78 <vprintfmt+0x219>
f0100f02:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
f0100f06:	74 7a                	je     f0100f82 <vprintfmt+0x223>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f08:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100f0c:	89 1c 24             	mov    %ebx,(%esp)
f0100f0f:	e8 d4 03 00 00       	call   f01012e8 <strnlen>
f0100f14:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100f17:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
f0100f19:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
f0100f1d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100f20:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0100f23:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f25:	eb 0f                	jmp    f0100f36 <vprintfmt+0x1d7>
					putch(padc, putdat);
f0100f27:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f2e:	89 04 24             	mov    %eax,(%esp)
f0100f31:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f33:	83 eb 01             	sub    $0x1,%ebx
f0100f36:	85 db                	test   %ebx,%ebx
f0100f38:	7f ed                	jg     f0100f27 <vprintfmt+0x1c8>
f0100f3a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100f3d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100f40:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0100f43:	89 f7                	mov    %esi,%edi
f0100f45:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0100f48:	eb 40                	jmp    f0100f8a <vprintfmt+0x22b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100f4a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100f4e:	74 18                	je     f0100f68 <vprintfmt+0x209>
f0100f50:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100f53:	83 fa 5e             	cmp    $0x5e,%edx
f0100f56:	76 10                	jbe    f0100f68 <vprintfmt+0x209>
					putch('?', putdat);
f0100f58:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100f5c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0100f63:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100f66:	eb 0a                	jmp    f0100f72 <vprintfmt+0x213>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0100f68:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100f6c:	89 04 24             	mov    %eax,(%esp)
f0100f6f:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100f72:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0100f76:	eb 12                	jmp    f0100f8a <vprintfmt+0x22b>
f0100f78:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0100f7b:	89 f7                	mov    %esi,%edi
f0100f7d:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0100f80:	eb 08                	jmp    f0100f8a <vprintfmt+0x22b>
f0100f82:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0100f85:	89 f7                	mov    %esi,%edi
f0100f87:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0100f8a:	0f be 03             	movsbl (%ebx),%eax
f0100f8d:	83 c3 01             	add    $0x1,%ebx
f0100f90:	85 c0                	test   %eax,%eax
f0100f92:	74 25                	je     f0100fb9 <vprintfmt+0x25a>
f0100f94:	85 f6                	test   %esi,%esi
f0100f96:	78 b2                	js     f0100f4a <vprintfmt+0x1eb>
f0100f98:	83 ee 01             	sub    $0x1,%esi
f0100f9b:	79 ad                	jns    f0100f4a <vprintfmt+0x1eb>
f0100f9d:	89 fe                	mov    %edi,%esi
f0100f9f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100fa2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100fa5:	eb 1a                	jmp    f0100fc1 <vprintfmt+0x262>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100fa7:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100fab:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0100fb2:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100fb4:	83 eb 01             	sub    $0x1,%ebx
f0100fb7:	eb 08                	jmp    f0100fc1 <vprintfmt+0x262>
f0100fb9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100fbc:	89 fe                	mov    %edi,%esi
f0100fbe:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100fc1:	85 db                	test   %ebx,%ebx
f0100fc3:	7f e2                	jg     f0100fa7 <vprintfmt+0x248>
f0100fc5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100fc8:	e9 be fd ff ff       	jmp    f0100d8b <vprintfmt+0x2c>
f0100fcd:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100fd0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100fd3:	83 f9 01             	cmp    $0x1,%ecx
f0100fd6:	7e 16                	jle    f0100fee <vprintfmt+0x28f>
		return va_arg(*ap, long long);
f0100fd8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fdb:	8d 50 08             	lea    0x8(%eax),%edx
f0100fde:	89 55 14             	mov    %edx,0x14(%ebp)
f0100fe1:	8b 10                	mov    (%eax),%edx
f0100fe3:	8b 48 04             	mov    0x4(%eax),%ecx
f0100fe6:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0100fe9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100fec:	eb 32                	jmp    f0101020 <vprintfmt+0x2c1>
	else if (lflag)
f0100fee:	85 c9                	test   %ecx,%ecx
f0100ff0:	74 18                	je     f010100a <vprintfmt+0x2ab>
		return va_arg(*ap, long);
f0100ff2:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff5:	8d 50 04             	lea    0x4(%eax),%edx
f0100ff8:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ffb:	8b 00                	mov    (%eax),%eax
f0100ffd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101000:	89 c1                	mov    %eax,%ecx
f0101002:	c1 f9 1f             	sar    $0x1f,%ecx
f0101005:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101008:	eb 16                	jmp    f0101020 <vprintfmt+0x2c1>
	else
		return va_arg(*ap, int);
f010100a:	8b 45 14             	mov    0x14(%ebp),%eax
f010100d:	8d 50 04             	lea    0x4(%eax),%edx
f0101010:	89 55 14             	mov    %edx,0x14(%ebp)
f0101013:	8b 00                	mov    (%eax),%eax
f0101015:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101018:	89 c2                	mov    %eax,%edx
f010101a:	c1 fa 1f             	sar    $0x1f,%edx
f010101d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101020:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0101023:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101026:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f010102b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010102f:	0f 89 be 00 00 00    	jns    f01010f3 <vprintfmt+0x394>
				putch('-', putdat);
f0101035:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101039:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101040:	ff d7                	call   *%edi
				num = -(long long) num;
f0101042:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0101045:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101048:	f7 d9                	neg    %ecx
f010104a:	83 d3 00             	adc    $0x0,%ebx
f010104d:	f7 db                	neg    %ebx
f010104f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101054:	e9 9a 00 00 00       	jmp    f01010f3 <vprintfmt+0x394>
f0101059:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010105c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010105f:	89 ca                	mov    %ecx,%edx
f0101061:	8d 45 14             	lea    0x14(%ebp),%eax
f0101064:	e8 9f fc ff ff       	call   f0100d08 <getuint>
f0101069:	89 c1                	mov    %eax,%ecx
f010106b:	89 d3                	mov    %edx,%ebx
f010106d:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0101072:	eb 7f                	jmp    f01010f3 <vprintfmt+0x394>
f0101074:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0101077:	89 74 24 04          	mov    %esi,0x4(%esp)
f010107b:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101082:	ff d7                	call   *%edi
			putch('X', putdat);
f0101084:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101088:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010108f:	ff d7                	call   *%edi
			putch('X', putdat);
f0101091:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101095:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010109c:	ff d7                	call   *%edi
f010109e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f01010a1:	e9 e5 fc ff ff       	jmp    f0100d8b <vprintfmt+0x2c>
f01010a6:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f01010a9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010ad:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01010b4:	ff d7                	call   *%edi
			putch('x', putdat);
f01010b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010ba:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01010c1:	ff d7                	call   *%edi
			num = (unsigned long long)
f01010c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c6:	8d 50 04             	lea    0x4(%eax),%edx
f01010c9:	89 55 14             	mov    %edx,0x14(%ebp)
f01010cc:	8b 08                	mov    (%eax),%ecx
f01010ce:	bb 00 00 00 00       	mov    $0x0,%ebx
f01010d3:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01010d8:	eb 19                	jmp    f01010f3 <vprintfmt+0x394>
f01010da:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01010dd:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01010e0:	89 ca                	mov    %ecx,%edx
f01010e2:	8d 45 14             	lea    0x14(%ebp),%eax
f01010e5:	e8 1e fc ff ff       	call   f0100d08 <getuint>
f01010ea:	89 c1                	mov    %eax,%ecx
f01010ec:	89 d3                	mov    %edx,%ebx
f01010ee:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f01010f3:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
f01010f7:	89 54 24 10          	mov    %edx,0x10(%esp)
f01010fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01010fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101102:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101106:	89 0c 24             	mov    %ecx,(%esp)
f0101109:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010110d:	89 f2                	mov    %esi,%edx
f010110f:	89 f8                	mov    %edi,%eax
f0101111:	e8 0a fb ff ff       	call   f0100c20 <printnum>
f0101116:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f0101119:	e9 6d fc ff ff       	jmp    f0100d8b <vprintfmt+0x2c>
f010111e:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101121:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101125:	89 04 24             	mov    %eax,(%esp)
f0101128:	ff d7                	call   *%edi
f010112a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f010112d:	e9 59 fc ff ff       	jmp    f0100d8b <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101132:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101136:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010113d:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010113f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101142:	80 38 25             	cmpb   $0x25,(%eax)
f0101145:	0f 84 40 fc ff ff    	je     f0100d8b <vprintfmt+0x2c>
f010114b:	89 c3                	mov    %eax,%ebx
f010114d:	eb f0                	jmp    f010113f <vprintfmt+0x3e0>
				/* do nothing */;
			break;
		}
	}
}
f010114f:	83 c4 4c             	add    $0x4c,%esp
f0101152:	5b                   	pop    %ebx
f0101153:	5e                   	pop    %esi
f0101154:	5f                   	pop    %edi
f0101155:	5d                   	pop    %ebp
f0101156:	c3                   	ret    

f0101157 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101157:	55                   	push   %ebp
f0101158:	89 e5                	mov    %esp,%ebp
f010115a:	83 ec 28             	sub    $0x28,%esp
f010115d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101160:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0101163:	85 c0                	test   %eax,%eax
f0101165:	74 04                	je     f010116b <vsnprintf+0x14>
f0101167:	85 d2                	test   %edx,%edx
f0101169:	7f 07                	jg     f0101172 <vsnprintf+0x1b>
f010116b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101170:	eb 3b                	jmp    f01011ad <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101172:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101175:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0101179:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010117c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101183:	8b 45 14             	mov    0x14(%ebp),%eax
f0101186:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010118a:	8b 45 10             	mov    0x10(%ebp),%eax
f010118d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101191:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101194:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101198:	c7 04 24 42 0d 10 f0 	movl   $0xf0100d42,(%esp)
f010119f:	e8 bb fb ff ff       	call   f0100d5f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011a7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01011aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f01011ad:	c9                   	leave  
f01011ae:	c3                   	ret    

f01011af <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01011af:	55                   	push   %ebp
f01011b0:	89 e5                	mov    %esp,%ebp
f01011b2:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f01011b5:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f01011b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011bc:	8b 45 10             	mov    0x10(%ebp),%eax
f01011bf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01011c3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01011cd:	89 04 24             	mov    %eax,(%esp)
f01011d0:	e8 82 ff ff ff       	call   f0101157 <vsnprintf>
	va_end(ap);

	return rc;
}
f01011d5:	c9                   	leave  
f01011d6:	c3                   	ret    

f01011d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01011d7:	55                   	push   %ebp
f01011d8:	89 e5                	mov    %esp,%ebp
f01011da:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f01011dd:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f01011e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011e4:	8b 45 10             	mov    0x10(%ebp),%eax
f01011e7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01011eb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01011f5:	89 04 24             	mov    %eax,(%esp)
f01011f8:	e8 62 fb ff ff       	call   f0100d5f <vprintfmt>
	va_end(ap);
}
f01011fd:	c9                   	leave  
f01011fe:	c3                   	ret    
	...

f0101200 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101200:	55                   	push   %ebp
f0101201:	89 e5                	mov    %esp,%ebp
f0101203:	57                   	push   %edi
f0101204:	56                   	push   %esi
f0101205:	53                   	push   %ebx
f0101206:	83 ec 1c             	sub    $0x1c,%esp
f0101209:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010120c:	85 c0                	test   %eax,%eax
f010120e:	74 10                	je     f0101220 <readline+0x20>
		cprintf("%s", prompt);
f0101210:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101214:	c7 04 24 0b 1e 10 f0 	movl   $0xf0101e0b,(%esp)
f010121b:	e8 03 f7 ff ff       	call   f0100923 <cprintf>

	i = 0;
	echoing = iscons(0);
f0101220:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101227:	e8 64 f0 ff ff       	call   f0100290 <iscons>
f010122c:	89 c7                	mov    %eax,%edi
f010122e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0101233:	e8 47 f0 ff ff       	call   f010027f <getchar>
f0101238:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010123a:	85 c0                	test   %eax,%eax
f010123c:	79 17                	jns    f0101255 <readline+0x55>
			cprintf("read error: %e\n", c);
f010123e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101242:	c7 04 24 00 20 10 f0 	movl   $0xf0102000,(%esp)
f0101249:	e8 d5 f6 ff ff       	call   f0100923 <cprintf>
f010124e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0101253:	eb 6d                	jmp    f01012c2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101255:	83 f8 08             	cmp    $0x8,%eax
f0101258:	74 05                	je     f010125f <readline+0x5f>
f010125a:	83 f8 7f             	cmp    $0x7f,%eax
f010125d:	75 19                	jne    f0101278 <readline+0x78>
f010125f:	85 f6                	test   %esi,%esi
f0101261:	7e 15                	jle    f0101278 <readline+0x78>
			if (echoing)
f0101263:	85 ff                	test   %edi,%edi
f0101265:	74 0c                	je     f0101273 <readline+0x73>
				cputchar('\b');
f0101267:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010126e:	e8 0f f2 ff ff       	call   f0100482 <cputchar>
			i--;
f0101273:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101276:	eb bb                	jmp    f0101233 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101278:	83 fb 1f             	cmp    $0x1f,%ebx
f010127b:	7e 1f                	jle    f010129c <readline+0x9c>
f010127d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101283:	7f 17                	jg     f010129c <readline+0x9c>
			if (echoing)
f0101285:	85 ff                	test   %edi,%edi
f0101287:	74 08                	je     f0101291 <readline+0x91>
				cputchar(c);
f0101289:	89 1c 24             	mov    %ebx,(%esp)
f010128c:	e8 f1 f1 ff ff       	call   f0100482 <cputchar>
			buf[i++] = c;
f0101291:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101297:	83 c6 01             	add    $0x1,%esi
f010129a:	eb 97                	jmp    f0101233 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010129c:	83 fb 0a             	cmp    $0xa,%ebx
f010129f:	74 05                	je     f01012a6 <readline+0xa6>
f01012a1:	83 fb 0d             	cmp    $0xd,%ebx
f01012a4:	75 8d                	jne    f0101233 <readline+0x33>
			if (echoing)
f01012a6:	85 ff                	test   %edi,%edi
f01012a8:	74 0c                	je     f01012b6 <readline+0xb6>
				cputchar('\n');
f01012aa:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01012b1:	e8 cc f1 ff ff       	call   f0100482 <cputchar>
			buf[i] = 0;
f01012b6:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
f01012bd:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
			return buf;
		}
	}
}
f01012c2:	83 c4 1c             	add    $0x1c,%esp
f01012c5:	5b                   	pop    %ebx
f01012c6:	5e                   	pop    %esi
f01012c7:	5f                   	pop    %edi
f01012c8:	5d                   	pop    %ebp
f01012c9:	c3                   	ret    
f01012ca:	00 00                	add    %al,(%eax)
f01012cc:	00 00                	add    %al,(%eax)
	...

f01012d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01012d0:	55                   	push   %ebp
f01012d1:	89 e5                	mov    %esp,%ebp
f01012d3:	8b 55 08             	mov    0x8(%ebp),%edx
f01012d6:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
f01012db:	eb 03                	jmp    f01012e0 <strlen+0x10>
		n++;
f01012dd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01012e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01012e4:	75 f7                	jne    f01012dd <strlen+0xd>
		n++;
	return n;
}
f01012e6:	5d                   	pop    %ebp
f01012e7:	c3                   	ret    

f01012e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01012e8:	55                   	push   %ebp
f01012e9:	89 e5                	mov    %esp,%ebp
f01012eb:	53                   	push   %ebx
f01012ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01012ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01012f2:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012f7:	eb 03                	jmp    f01012fc <strnlen+0x14>
		n++;
f01012f9:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012fc:	39 c1                	cmp    %eax,%ecx
f01012fe:	74 06                	je     f0101306 <strnlen+0x1e>
f0101300:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f0101304:	75 f3                	jne    f01012f9 <strnlen+0x11>
		n++;
	return n;
}
f0101306:	5b                   	pop    %ebx
f0101307:	5d                   	pop    %ebp
f0101308:	c3                   	ret    

f0101309 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101309:	55                   	push   %ebp
f010130a:	89 e5                	mov    %esp,%ebp
f010130c:	53                   	push   %ebx
f010130d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101310:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101313:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101318:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010131c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f010131f:	83 c2 01             	add    $0x1,%edx
f0101322:	84 c9                	test   %cl,%cl
f0101324:	75 f2                	jne    f0101318 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0101326:	5b                   	pop    %ebx
f0101327:	5d                   	pop    %ebp
f0101328:	c3                   	ret    

f0101329 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101329:	55                   	push   %ebp
f010132a:	89 e5                	mov    %esp,%ebp
f010132c:	53                   	push   %ebx
f010132d:	83 ec 08             	sub    $0x8,%esp
f0101330:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101333:	89 1c 24             	mov    %ebx,(%esp)
f0101336:	e8 95 ff ff ff       	call   f01012d0 <strlen>
	strcpy(dst + len, src);
f010133b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010133e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101342:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0101345:	89 04 24             	mov    %eax,(%esp)
f0101348:	e8 bc ff ff ff       	call   f0101309 <strcpy>
	return dst;
}
f010134d:	89 d8                	mov    %ebx,%eax
f010134f:	83 c4 08             	add    $0x8,%esp
f0101352:	5b                   	pop    %ebx
f0101353:	5d                   	pop    %ebp
f0101354:	c3                   	ret    

f0101355 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101355:	55                   	push   %ebp
f0101356:	89 e5                	mov    %esp,%ebp
f0101358:	56                   	push   %esi
f0101359:	53                   	push   %ebx
f010135a:	8b 45 08             	mov    0x8(%ebp),%eax
f010135d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101360:	8b 75 10             	mov    0x10(%ebp),%esi
f0101363:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101368:	eb 0f                	jmp    f0101379 <strncpy+0x24>
		*dst++ = *src;
f010136a:	0f b6 19             	movzbl (%ecx),%ebx
f010136d:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101370:	80 39 01             	cmpb   $0x1,(%ecx)
f0101373:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101376:	83 c2 01             	add    $0x1,%edx
f0101379:	39 f2                	cmp    %esi,%edx
f010137b:	72 ed                	jb     f010136a <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010137d:	5b                   	pop    %ebx
f010137e:	5e                   	pop    %esi
f010137f:	5d                   	pop    %ebp
f0101380:	c3                   	ret    

f0101381 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101381:	55                   	push   %ebp
f0101382:	89 e5                	mov    %esp,%ebp
f0101384:	56                   	push   %esi
f0101385:	53                   	push   %ebx
f0101386:	8b 75 08             	mov    0x8(%ebp),%esi
f0101389:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010138c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010138f:	89 f0                	mov    %esi,%eax
f0101391:	85 d2                	test   %edx,%edx
f0101393:	75 0a                	jne    f010139f <strlcpy+0x1e>
f0101395:	eb 17                	jmp    f01013ae <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101397:	88 18                	mov    %bl,(%eax)
f0101399:	83 c0 01             	add    $0x1,%eax
f010139c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010139f:	83 ea 01             	sub    $0x1,%edx
f01013a2:	74 07                	je     f01013ab <strlcpy+0x2a>
f01013a4:	0f b6 19             	movzbl (%ecx),%ebx
f01013a7:	84 db                	test   %bl,%bl
f01013a9:	75 ec                	jne    f0101397 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
f01013ab:	c6 00 00             	movb   $0x0,(%eax)
f01013ae:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f01013b0:	5b                   	pop    %ebx
f01013b1:	5e                   	pop    %esi
f01013b2:	5d                   	pop    %ebp
f01013b3:	c3                   	ret    

f01013b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01013b4:	55                   	push   %ebp
f01013b5:	89 e5                	mov    %esp,%ebp
f01013b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01013bd:	eb 06                	jmp    f01013c5 <strcmp+0x11>
		p++, q++;
f01013bf:	83 c1 01             	add    $0x1,%ecx
f01013c2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01013c5:	0f b6 01             	movzbl (%ecx),%eax
f01013c8:	84 c0                	test   %al,%al
f01013ca:	74 04                	je     f01013d0 <strcmp+0x1c>
f01013cc:	3a 02                	cmp    (%edx),%al
f01013ce:	74 ef                	je     f01013bf <strcmp+0xb>
f01013d0:	0f b6 c0             	movzbl %al,%eax
f01013d3:	0f b6 12             	movzbl (%edx),%edx
f01013d6:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01013d8:	5d                   	pop    %ebp
f01013d9:	c3                   	ret    

f01013da <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01013da:	55                   	push   %ebp
f01013db:	89 e5                	mov    %esp,%ebp
f01013dd:	53                   	push   %ebx
f01013de:	8b 45 08             	mov    0x8(%ebp),%eax
f01013e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013e4:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f01013e7:	eb 09                	jmp    f01013f2 <strncmp+0x18>
		n--, p++, q++;
f01013e9:	83 ea 01             	sub    $0x1,%edx
f01013ec:	83 c0 01             	add    $0x1,%eax
f01013ef:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01013f2:	85 d2                	test   %edx,%edx
f01013f4:	75 07                	jne    f01013fd <strncmp+0x23>
f01013f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01013fb:	eb 13                	jmp    f0101410 <strncmp+0x36>
f01013fd:	0f b6 18             	movzbl (%eax),%ebx
f0101400:	84 db                	test   %bl,%bl
f0101402:	74 04                	je     f0101408 <strncmp+0x2e>
f0101404:	3a 19                	cmp    (%ecx),%bl
f0101406:	74 e1                	je     f01013e9 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101408:	0f b6 00             	movzbl (%eax),%eax
f010140b:	0f b6 11             	movzbl (%ecx),%edx
f010140e:	29 d0                	sub    %edx,%eax
}
f0101410:	5b                   	pop    %ebx
f0101411:	5d                   	pop    %ebp
f0101412:	c3                   	ret    

f0101413 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101413:	55                   	push   %ebp
f0101414:	89 e5                	mov    %esp,%ebp
f0101416:	8b 45 08             	mov    0x8(%ebp),%eax
f0101419:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010141d:	eb 07                	jmp    f0101426 <strchr+0x13>
		if (*s == c)
f010141f:	38 ca                	cmp    %cl,%dl
f0101421:	74 0f                	je     f0101432 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101423:	83 c0 01             	add    $0x1,%eax
f0101426:	0f b6 10             	movzbl (%eax),%edx
f0101429:	84 d2                	test   %dl,%dl
f010142b:	75 f2                	jne    f010141f <strchr+0xc>
f010142d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0101432:	5d                   	pop    %ebp
f0101433:	c3                   	ret    

f0101434 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101434:	55                   	push   %ebp
f0101435:	89 e5                	mov    %esp,%ebp
f0101437:	8b 45 08             	mov    0x8(%ebp),%eax
f010143a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010143e:	eb 07                	jmp    f0101447 <strfind+0x13>
		if (*s == c)
f0101440:	38 ca                	cmp    %cl,%dl
f0101442:	74 0a                	je     f010144e <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101444:	83 c0 01             	add    $0x1,%eax
f0101447:	0f b6 10             	movzbl (%eax),%edx
f010144a:	84 d2                	test   %dl,%dl
f010144c:	75 f2                	jne    f0101440 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f010144e:	5d                   	pop    %ebp
f010144f:	c3                   	ret    

f0101450 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101450:	55                   	push   %ebp
f0101451:	89 e5                	mov    %esp,%ebp
f0101453:	83 ec 0c             	sub    $0xc,%esp
f0101456:	89 1c 24             	mov    %ebx,(%esp)
f0101459:	89 74 24 04          	mov    %esi,0x4(%esp)
f010145d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101461:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101464:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101467:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010146a:	85 c9                	test   %ecx,%ecx
f010146c:	74 30                	je     f010149e <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010146e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101474:	75 25                	jne    f010149b <memset+0x4b>
f0101476:	f6 c1 03             	test   $0x3,%cl
f0101479:	75 20                	jne    f010149b <memset+0x4b>
		c &= 0xFF;
f010147b:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010147e:	89 d3                	mov    %edx,%ebx
f0101480:	c1 e3 08             	shl    $0x8,%ebx
f0101483:	89 d6                	mov    %edx,%esi
f0101485:	c1 e6 18             	shl    $0x18,%esi
f0101488:	89 d0                	mov    %edx,%eax
f010148a:	c1 e0 10             	shl    $0x10,%eax
f010148d:	09 f0                	or     %esi,%eax
f010148f:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0101491:	09 d8                	or     %ebx,%eax
f0101493:	c1 e9 02             	shr    $0x2,%ecx
f0101496:	fc                   	cld    
f0101497:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101499:	eb 03                	jmp    f010149e <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010149b:	fc                   	cld    
f010149c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010149e:	89 f8                	mov    %edi,%eax
f01014a0:	8b 1c 24             	mov    (%esp),%ebx
f01014a3:	8b 74 24 04          	mov    0x4(%esp),%esi
f01014a7:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01014ab:	89 ec                	mov    %ebp,%esp
f01014ad:	5d                   	pop    %ebp
f01014ae:	c3                   	ret    

f01014af <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01014af:	55                   	push   %ebp
f01014b0:	89 e5                	mov    %esp,%ebp
f01014b2:	83 ec 08             	sub    $0x8,%esp
f01014b5:	89 34 24             	mov    %esi,(%esp)
f01014b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01014bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01014bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
f01014c2:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f01014c5:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f01014c7:	39 c6                	cmp    %eax,%esi
f01014c9:	73 35                	jae    f0101500 <memmove+0x51>
f01014cb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01014ce:	39 d0                	cmp    %edx,%eax
f01014d0:	73 2e                	jae    f0101500 <memmove+0x51>
		s += n;
		d += n;
f01014d2:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014d4:	f6 c2 03             	test   $0x3,%dl
f01014d7:	75 1b                	jne    f01014f4 <memmove+0x45>
f01014d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01014df:	75 13                	jne    f01014f4 <memmove+0x45>
f01014e1:	f6 c1 03             	test   $0x3,%cl
f01014e4:	75 0e                	jne    f01014f4 <memmove+0x45>
			asm volatile("std; rep movsl\n"
f01014e6:	83 ef 04             	sub    $0x4,%edi
f01014e9:	8d 72 fc             	lea    -0x4(%edx),%esi
f01014ec:	c1 e9 02             	shr    $0x2,%ecx
f01014ef:	fd                   	std    
f01014f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014f2:	eb 09                	jmp    f01014fd <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01014f4:	83 ef 01             	sub    $0x1,%edi
f01014f7:	8d 72 ff             	lea    -0x1(%edx),%esi
f01014fa:	fd                   	std    
f01014fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01014fd:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01014fe:	eb 20                	jmp    f0101520 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101500:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101506:	75 15                	jne    f010151d <memmove+0x6e>
f0101508:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010150e:	75 0d                	jne    f010151d <memmove+0x6e>
f0101510:	f6 c1 03             	test   $0x3,%cl
f0101513:	75 08                	jne    f010151d <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f0101515:	c1 e9 02             	shr    $0x2,%ecx
f0101518:	fc                   	cld    
f0101519:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010151b:	eb 03                	jmp    f0101520 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010151d:	fc                   	cld    
f010151e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101520:	8b 34 24             	mov    (%esp),%esi
f0101523:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101527:	89 ec                	mov    %ebp,%esp
f0101529:	5d                   	pop    %ebp
f010152a:	c3                   	ret    

f010152b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010152b:	55                   	push   %ebp
f010152c:	89 e5                	mov    %esp,%ebp
f010152e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101531:	8b 45 10             	mov    0x10(%ebp),%eax
f0101534:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101538:	8b 45 0c             	mov    0xc(%ebp),%eax
f010153b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010153f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101542:	89 04 24             	mov    %eax,(%esp)
f0101545:	e8 65 ff ff ff       	call   f01014af <memmove>
}
f010154a:	c9                   	leave  
f010154b:	c3                   	ret    

f010154c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010154c:	55                   	push   %ebp
f010154d:	89 e5                	mov    %esp,%ebp
f010154f:	57                   	push   %edi
f0101550:	56                   	push   %esi
f0101551:	53                   	push   %ebx
f0101552:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101555:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101558:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010155b:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101560:	eb 1c                	jmp    f010157e <memcmp+0x32>
		if (*s1 != *s2)
f0101562:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
f0101566:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
f010156a:	83 c2 01             	add    $0x1,%edx
f010156d:	83 e9 01             	sub    $0x1,%ecx
f0101570:	38 d8                	cmp    %bl,%al
f0101572:	74 0a                	je     f010157e <memcmp+0x32>
			return (int) *s1 - (int) *s2;
f0101574:	0f b6 c0             	movzbl %al,%eax
f0101577:	0f b6 db             	movzbl %bl,%ebx
f010157a:	29 d8                	sub    %ebx,%eax
f010157c:	eb 09                	jmp    f0101587 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010157e:	85 c9                	test   %ecx,%ecx
f0101580:	75 e0                	jne    f0101562 <memcmp+0x16>
f0101582:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0101587:	5b                   	pop    %ebx
f0101588:	5e                   	pop    %esi
f0101589:	5f                   	pop    %edi
f010158a:	5d                   	pop    %ebp
f010158b:	c3                   	ret    

f010158c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010158c:	55                   	push   %ebp
f010158d:	89 e5                	mov    %esp,%ebp
f010158f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101592:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101595:	89 c2                	mov    %eax,%edx
f0101597:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010159a:	eb 07                	jmp    f01015a3 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f010159c:	38 08                	cmp    %cl,(%eax)
f010159e:	74 07                	je     f01015a7 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01015a0:	83 c0 01             	add    $0x1,%eax
f01015a3:	39 d0                	cmp    %edx,%eax
f01015a5:	72 f5                	jb     f010159c <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01015a7:	5d                   	pop    %ebp
f01015a8:	c3                   	ret    

f01015a9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01015a9:	55                   	push   %ebp
f01015aa:	89 e5                	mov    %esp,%ebp
f01015ac:	57                   	push   %edi
f01015ad:	56                   	push   %esi
f01015ae:	53                   	push   %ebx
f01015af:	83 ec 04             	sub    $0x4,%esp
f01015b2:	8b 55 08             	mov    0x8(%ebp),%edx
f01015b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015b8:	eb 03                	jmp    f01015bd <strtol+0x14>
		s++;
f01015ba:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015bd:	0f b6 02             	movzbl (%edx),%eax
f01015c0:	3c 20                	cmp    $0x20,%al
f01015c2:	74 f6                	je     f01015ba <strtol+0x11>
f01015c4:	3c 09                	cmp    $0x9,%al
f01015c6:	74 f2                	je     f01015ba <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
f01015c8:	3c 2b                	cmp    $0x2b,%al
f01015ca:	75 0c                	jne    f01015d8 <strtol+0x2f>
		s++;
f01015cc:	8d 52 01             	lea    0x1(%edx),%edx
f01015cf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01015d6:	eb 15                	jmp    f01015ed <strtol+0x44>
	else if (*s == '-')
f01015d8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01015df:	3c 2d                	cmp    $0x2d,%al
f01015e1:	75 0a                	jne    f01015ed <strtol+0x44>
		s++, neg = 1;
f01015e3:	8d 52 01             	lea    0x1(%edx),%edx
f01015e6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01015ed:	85 db                	test   %ebx,%ebx
f01015ef:	0f 94 c0             	sete   %al
f01015f2:	74 05                	je     f01015f9 <strtol+0x50>
f01015f4:	83 fb 10             	cmp    $0x10,%ebx
f01015f7:	75 15                	jne    f010160e <strtol+0x65>
f01015f9:	80 3a 30             	cmpb   $0x30,(%edx)
f01015fc:	75 10                	jne    f010160e <strtol+0x65>
f01015fe:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101602:	75 0a                	jne    f010160e <strtol+0x65>
		s += 2, base = 16;
f0101604:	83 c2 02             	add    $0x2,%edx
f0101607:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010160c:	eb 13                	jmp    f0101621 <strtol+0x78>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010160e:	84 c0                	test   %al,%al
f0101610:	74 0f                	je     f0101621 <strtol+0x78>
f0101612:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0101617:	80 3a 30             	cmpb   $0x30,(%edx)
f010161a:	75 05                	jne    f0101621 <strtol+0x78>
		s++, base = 8;
f010161c:	83 c2 01             	add    $0x1,%edx
f010161f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101621:	b8 00 00 00 00       	mov    $0x0,%eax
f0101626:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101628:	0f b6 0a             	movzbl (%edx),%ecx
f010162b:	89 cf                	mov    %ecx,%edi
f010162d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0101630:	80 fb 09             	cmp    $0x9,%bl
f0101633:	77 08                	ja     f010163d <strtol+0x94>
			dig = *s - '0';
f0101635:	0f be c9             	movsbl %cl,%ecx
f0101638:	83 e9 30             	sub    $0x30,%ecx
f010163b:	eb 1e                	jmp    f010165b <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
f010163d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0101640:	80 fb 19             	cmp    $0x19,%bl
f0101643:	77 08                	ja     f010164d <strtol+0xa4>
			dig = *s - 'a' + 10;
f0101645:	0f be c9             	movsbl %cl,%ecx
f0101648:	83 e9 57             	sub    $0x57,%ecx
f010164b:	eb 0e                	jmp    f010165b <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
f010164d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0101650:	80 fb 19             	cmp    $0x19,%bl
f0101653:	77 15                	ja     f010166a <strtol+0xc1>
			dig = *s - 'A' + 10;
f0101655:	0f be c9             	movsbl %cl,%ecx
f0101658:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010165b:	39 f1                	cmp    %esi,%ecx
f010165d:	7d 0b                	jge    f010166a <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f010165f:	83 c2 01             	add    $0x1,%edx
f0101662:	0f af c6             	imul   %esi,%eax
f0101665:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0101668:	eb be                	jmp    f0101628 <strtol+0x7f>
f010166a:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010166c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101670:	74 05                	je     f0101677 <strtol+0xce>
		*endptr = (char *) s;
f0101672:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101675:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101677:	89 ca                	mov    %ecx,%edx
f0101679:	f7 da                	neg    %edx
f010167b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010167f:	0f 45 c2             	cmovne %edx,%eax
}
f0101682:	83 c4 04             	add    $0x4,%esp
f0101685:	5b                   	pop    %ebx
f0101686:	5e                   	pop    %esi
f0101687:	5f                   	pop    %edi
f0101688:	5d                   	pop    %ebp
f0101689:	c3                   	ret    
f010168a:	00 00                	add    %al,(%eax)
f010168c:	00 00                	add    %al,(%eax)
	...

f0101690 <__udivdi3>:
f0101690:	55                   	push   %ebp
f0101691:	89 e5                	mov    %esp,%ebp
f0101693:	57                   	push   %edi
f0101694:	56                   	push   %esi
f0101695:	83 ec 10             	sub    $0x10,%esp
f0101698:	8b 45 14             	mov    0x14(%ebp),%eax
f010169b:	8b 55 08             	mov    0x8(%ebp),%edx
f010169e:	8b 75 10             	mov    0x10(%ebp),%esi
f01016a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01016a4:	85 c0                	test   %eax,%eax
f01016a6:	89 55 f0             	mov    %edx,-0x10(%ebp)
f01016a9:	75 35                	jne    f01016e0 <__udivdi3+0x50>
f01016ab:	39 fe                	cmp    %edi,%esi
f01016ad:	77 61                	ja     f0101710 <__udivdi3+0x80>
f01016af:	85 f6                	test   %esi,%esi
f01016b1:	75 0b                	jne    f01016be <__udivdi3+0x2e>
f01016b3:	b8 01 00 00 00       	mov    $0x1,%eax
f01016b8:	31 d2                	xor    %edx,%edx
f01016ba:	f7 f6                	div    %esi
f01016bc:	89 c6                	mov    %eax,%esi
f01016be:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f01016c1:	31 d2                	xor    %edx,%edx
f01016c3:	89 f8                	mov    %edi,%eax
f01016c5:	f7 f6                	div    %esi
f01016c7:	89 c7                	mov    %eax,%edi
f01016c9:	89 c8                	mov    %ecx,%eax
f01016cb:	f7 f6                	div    %esi
f01016cd:	89 c1                	mov    %eax,%ecx
f01016cf:	89 fa                	mov    %edi,%edx
f01016d1:	89 c8                	mov    %ecx,%eax
f01016d3:	83 c4 10             	add    $0x10,%esp
f01016d6:	5e                   	pop    %esi
f01016d7:	5f                   	pop    %edi
f01016d8:	5d                   	pop    %ebp
f01016d9:	c3                   	ret    
f01016da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01016e0:	39 f8                	cmp    %edi,%eax
f01016e2:	77 1c                	ja     f0101700 <__udivdi3+0x70>
f01016e4:	0f bd d0             	bsr    %eax,%edx
f01016e7:	83 f2 1f             	xor    $0x1f,%edx
f01016ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01016ed:	75 39                	jne    f0101728 <__udivdi3+0x98>
f01016ef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01016f2:	0f 86 a0 00 00 00    	jbe    f0101798 <__udivdi3+0x108>
f01016f8:	39 f8                	cmp    %edi,%eax
f01016fa:	0f 82 98 00 00 00    	jb     f0101798 <__udivdi3+0x108>
f0101700:	31 ff                	xor    %edi,%edi
f0101702:	31 c9                	xor    %ecx,%ecx
f0101704:	89 c8                	mov    %ecx,%eax
f0101706:	89 fa                	mov    %edi,%edx
f0101708:	83 c4 10             	add    $0x10,%esp
f010170b:	5e                   	pop    %esi
f010170c:	5f                   	pop    %edi
f010170d:	5d                   	pop    %ebp
f010170e:	c3                   	ret    
f010170f:	90                   	nop
f0101710:	89 d1                	mov    %edx,%ecx
f0101712:	89 fa                	mov    %edi,%edx
f0101714:	89 c8                	mov    %ecx,%eax
f0101716:	31 ff                	xor    %edi,%edi
f0101718:	f7 f6                	div    %esi
f010171a:	89 c1                	mov    %eax,%ecx
f010171c:	89 fa                	mov    %edi,%edx
f010171e:	89 c8                	mov    %ecx,%eax
f0101720:	83 c4 10             	add    $0x10,%esp
f0101723:	5e                   	pop    %esi
f0101724:	5f                   	pop    %edi
f0101725:	5d                   	pop    %ebp
f0101726:	c3                   	ret    
f0101727:	90                   	nop
f0101728:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010172c:	89 f2                	mov    %esi,%edx
f010172e:	d3 e0                	shl    %cl,%eax
f0101730:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101733:	b8 20 00 00 00       	mov    $0x20,%eax
f0101738:	2b 45 f4             	sub    -0xc(%ebp),%eax
f010173b:	89 c1                	mov    %eax,%ecx
f010173d:	d3 ea                	shr    %cl,%edx
f010173f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101743:	0b 55 ec             	or     -0x14(%ebp),%edx
f0101746:	d3 e6                	shl    %cl,%esi
f0101748:	89 c1                	mov    %eax,%ecx
f010174a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f010174d:	89 fe                	mov    %edi,%esi
f010174f:	d3 ee                	shr    %cl,%esi
f0101751:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101755:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101758:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010175b:	d3 e7                	shl    %cl,%edi
f010175d:	89 c1                	mov    %eax,%ecx
f010175f:	d3 ea                	shr    %cl,%edx
f0101761:	09 d7                	or     %edx,%edi
f0101763:	89 f2                	mov    %esi,%edx
f0101765:	89 f8                	mov    %edi,%eax
f0101767:	f7 75 ec             	divl   -0x14(%ebp)
f010176a:	89 d6                	mov    %edx,%esi
f010176c:	89 c7                	mov    %eax,%edi
f010176e:	f7 65 e8             	mull   -0x18(%ebp)
f0101771:	39 d6                	cmp    %edx,%esi
f0101773:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101776:	72 30                	jb     f01017a8 <__udivdi3+0x118>
f0101778:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010177b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010177f:	d3 e2                	shl    %cl,%edx
f0101781:	39 c2                	cmp    %eax,%edx
f0101783:	73 05                	jae    f010178a <__udivdi3+0xfa>
f0101785:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0101788:	74 1e                	je     f01017a8 <__udivdi3+0x118>
f010178a:	89 f9                	mov    %edi,%ecx
f010178c:	31 ff                	xor    %edi,%edi
f010178e:	e9 71 ff ff ff       	jmp    f0101704 <__udivdi3+0x74>
f0101793:	90                   	nop
f0101794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101798:	31 ff                	xor    %edi,%edi
f010179a:	b9 01 00 00 00       	mov    $0x1,%ecx
f010179f:	e9 60 ff ff ff       	jmp    f0101704 <__udivdi3+0x74>
f01017a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017a8:	8d 4f ff             	lea    -0x1(%edi),%ecx
f01017ab:	31 ff                	xor    %edi,%edi
f01017ad:	89 c8                	mov    %ecx,%eax
f01017af:	89 fa                	mov    %edi,%edx
f01017b1:	83 c4 10             	add    $0x10,%esp
f01017b4:	5e                   	pop    %esi
f01017b5:	5f                   	pop    %edi
f01017b6:	5d                   	pop    %ebp
f01017b7:	c3                   	ret    
	...

f01017c0 <__umoddi3>:
f01017c0:	55                   	push   %ebp
f01017c1:	89 e5                	mov    %esp,%ebp
f01017c3:	57                   	push   %edi
f01017c4:	56                   	push   %esi
f01017c5:	83 ec 20             	sub    $0x20,%esp
f01017c8:	8b 55 14             	mov    0x14(%ebp),%edx
f01017cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01017ce:	8b 7d 10             	mov    0x10(%ebp),%edi
f01017d1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017d4:	85 d2                	test   %edx,%edx
f01017d6:	89 c8                	mov    %ecx,%eax
f01017d8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f01017db:	75 13                	jne    f01017f0 <__umoddi3+0x30>
f01017dd:	39 f7                	cmp    %esi,%edi
f01017df:	76 3f                	jbe    f0101820 <__umoddi3+0x60>
f01017e1:	89 f2                	mov    %esi,%edx
f01017e3:	f7 f7                	div    %edi
f01017e5:	89 d0                	mov    %edx,%eax
f01017e7:	31 d2                	xor    %edx,%edx
f01017e9:	83 c4 20             	add    $0x20,%esp
f01017ec:	5e                   	pop    %esi
f01017ed:	5f                   	pop    %edi
f01017ee:	5d                   	pop    %ebp
f01017ef:	c3                   	ret    
f01017f0:	39 f2                	cmp    %esi,%edx
f01017f2:	77 4c                	ja     f0101840 <__umoddi3+0x80>
f01017f4:	0f bd ca             	bsr    %edx,%ecx
f01017f7:	83 f1 1f             	xor    $0x1f,%ecx
f01017fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01017fd:	75 51                	jne    f0101850 <__umoddi3+0x90>
f01017ff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0101802:	0f 87 e0 00 00 00    	ja     f01018e8 <__umoddi3+0x128>
f0101808:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010180b:	29 f8                	sub    %edi,%eax
f010180d:	19 d6                	sbb    %edx,%esi
f010180f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101812:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101815:	89 f2                	mov    %esi,%edx
f0101817:	83 c4 20             	add    $0x20,%esp
f010181a:	5e                   	pop    %esi
f010181b:	5f                   	pop    %edi
f010181c:	5d                   	pop    %ebp
f010181d:	c3                   	ret    
f010181e:	66 90                	xchg   %ax,%ax
f0101820:	85 ff                	test   %edi,%edi
f0101822:	75 0b                	jne    f010182f <__umoddi3+0x6f>
f0101824:	b8 01 00 00 00       	mov    $0x1,%eax
f0101829:	31 d2                	xor    %edx,%edx
f010182b:	f7 f7                	div    %edi
f010182d:	89 c7                	mov    %eax,%edi
f010182f:	89 f0                	mov    %esi,%eax
f0101831:	31 d2                	xor    %edx,%edx
f0101833:	f7 f7                	div    %edi
f0101835:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101838:	f7 f7                	div    %edi
f010183a:	eb a9                	jmp    f01017e5 <__umoddi3+0x25>
f010183c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101840:	89 c8                	mov    %ecx,%eax
f0101842:	89 f2                	mov    %esi,%edx
f0101844:	83 c4 20             	add    $0x20,%esp
f0101847:	5e                   	pop    %esi
f0101848:	5f                   	pop    %edi
f0101849:	5d                   	pop    %ebp
f010184a:	c3                   	ret    
f010184b:	90                   	nop
f010184c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101850:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101854:	d3 e2                	shl    %cl,%edx
f0101856:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101859:	ba 20 00 00 00       	mov    $0x20,%edx
f010185e:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0101861:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101864:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101868:	89 fa                	mov    %edi,%edx
f010186a:	d3 ea                	shr    %cl,%edx
f010186c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101870:	0b 55 f4             	or     -0xc(%ebp),%edx
f0101873:	d3 e7                	shl    %cl,%edi
f0101875:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101879:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010187c:	89 f2                	mov    %esi,%edx
f010187e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0101881:	89 c7                	mov    %eax,%edi
f0101883:	d3 ea                	shr    %cl,%edx
f0101885:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101889:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010188c:	89 c2                	mov    %eax,%edx
f010188e:	d3 e6                	shl    %cl,%esi
f0101890:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101894:	d3 ea                	shr    %cl,%edx
f0101896:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010189a:	09 d6                	or     %edx,%esi
f010189c:	89 f0                	mov    %esi,%eax
f010189e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01018a1:	d3 e7                	shl    %cl,%edi
f01018a3:	89 f2                	mov    %esi,%edx
f01018a5:	f7 75 f4             	divl   -0xc(%ebp)
f01018a8:	89 d6                	mov    %edx,%esi
f01018aa:	f7 65 e8             	mull   -0x18(%ebp)
f01018ad:	39 d6                	cmp    %edx,%esi
f01018af:	72 2b                	jb     f01018dc <__umoddi3+0x11c>
f01018b1:	39 c7                	cmp    %eax,%edi
f01018b3:	72 23                	jb     f01018d8 <__umoddi3+0x118>
f01018b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01018b9:	29 c7                	sub    %eax,%edi
f01018bb:	19 d6                	sbb    %edx,%esi
f01018bd:	89 f0                	mov    %esi,%eax
f01018bf:	89 f2                	mov    %esi,%edx
f01018c1:	d3 ef                	shr    %cl,%edi
f01018c3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01018c7:	d3 e0                	shl    %cl,%eax
f01018c9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01018cd:	09 f8                	or     %edi,%eax
f01018cf:	d3 ea                	shr    %cl,%edx
f01018d1:	83 c4 20             	add    $0x20,%esp
f01018d4:	5e                   	pop    %esi
f01018d5:	5f                   	pop    %edi
f01018d6:	5d                   	pop    %ebp
f01018d7:	c3                   	ret    
f01018d8:	39 d6                	cmp    %edx,%esi
f01018da:	75 d9                	jne    f01018b5 <__umoddi3+0xf5>
f01018dc:	2b 45 e8             	sub    -0x18(%ebp),%eax
f01018df:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f01018e2:	eb d1                	jmp    f01018b5 <__umoddi3+0xf5>
f01018e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01018e8:	39 f2                	cmp    %esi,%edx
f01018ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01018f0:	0f 82 12 ff ff ff    	jb     f0101808 <__umoddi3+0x48>
f01018f6:	e9 17 ff ff ff       	jmp    f0101812 <__umoddi3+0x52>
