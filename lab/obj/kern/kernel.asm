
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
f0100015:	b8 00 10 11 00       	mov    $0x111000,%eax
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
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 a6 00 00 00       	call   f01000e4 <i386_init>

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
f0100058:	c7 04 24 a0 1b 10 f0 	movl   $0xf0101ba0,(%esp)
f010005f:	e8 bb 0a 00 00       	call   f0100b1f <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 79 0a 00 00       	call   f0100aec <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 14 1c 10 f0 	movl   $0xf0101c14,(%esp)
f010007a:	e8 a0 0a 00 00       	call   f0100b1f <cprintf>
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
f0100090:	83 3d 40 39 11 f0 00 	cmpl   $0x0,0xf0113940
f0100097:	75 3d                	jne    f01000d6 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 40 39 11 f0    	mov    %esi,0xf0113940

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
f01000b2:	c7 04 24 ba 1b 10 f0 	movl   $0xf0101bba,(%esp)
f01000b9:	e8 61 0a 00 00       	call   f0100b1f <cprintf>
	vcprintf(fmt, ap);
f01000be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000c2:	89 34 24             	mov    %esi,(%esp)
f01000c5:	e8 22 0a 00 00       	call   f0100aec <vcprintf>
	cprintf("\n");
f01000ca:	c7 04 24 14 1c 10 f0 	movl   $0xf0101c14,(%esp)
f01000d1:	e8 49 0a 00 00       	call   f0100b1f <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000dd:	e8 61 06 00 00       	call   f0100743 <monitor>
f01000e2:	eb f2                	jmp    f01000d6 <_panic+0x51>

f01000e4 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f01000e4:	55                   	push   %ebp
f01000e5:	89 e5                	mov    %esp,%ebp
f01000e7:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000ea:	b8 50 39 11 f0       	mov    $0xf0113950,%eax
f01000ef:	2d 00 33 11 f0       	sub    $0xf0113300,%eax
f01000f4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000ff:	00 
f0100100:	c7 04 24 00 33 11 f0 	movl   $0xf0113300,(%esp)
f0100107:	e8 d4 15 00 00       	call   f01016e0 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010010c:	e8 21 03 00 00       	call   f0100432 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100111:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100118:	00 
f0100119:	c7 04 24 d2 1b 10 f0 	movl   $0xf0101bd2,(%esp)
f0100120:	e8 fa 09 00 00       	call   f0100b1f <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100125:	e8 e8 08 00 00       	call   f0100a12 <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010012a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100131:	e8 0d 06 00 00       	call   f0100743 <monitor>
f0100136:	eb f2                	jmp    f010012a <i386_init+0x46>
	...

f0100140 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100140:	55                   	push   %ebp
f0100141:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100143:	ba 84 00 00 00       	mov    $0x84,%edx
f0100148:	ec                   	in     (%dx),%al
f0100149:	ec                   	in     (%dx),%al
f010014a:	ec                   	in     (%dx),%al
f010014b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010014c:	5d                   	pop    %ebp
f010014d:	c3                   	ret    

f010014e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010014e:	55                   	push   %ebp
f010014f:	89 e5                	mov    %esp,%ebp
f0100151:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100156:	ec                   	in     (%dx),%al
f0100157:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100159:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010015e:	f6 c2 01             	test   $0x1,%dl
f0100161:	74 09                	je     f010016c <serial_proc_data+0x1e>
f0100163:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100168:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100169:	0f b6 c0             	movzbl %al,%eax
}
f010016c:	5d                   	pop    %ebp
f010016d:	c3                   	ret    

f010016e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010016e:	55                   	push   %ebp
f010016f:	89 e5                	mov    %esp,%ebp
f0100171:	57                   	push   %edi
f0100172:	56                   	push   %esi
f0100173:	53                   	push   %ebx
f0100174:	83 ec 0c             	sub    $0xc,%esp
f0100177:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100179:	bb 24 35 11 f0       	mov    $0xf0113524,%ebx
f010017e:	bf 20 33 11 f0       	mov    $0xf0113320,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100183:	eb 1b                	jmp    f01001a0 <cons_intr+0x32>
		if (c == 0)
f0100185:	85 c0                	test   %eax,%eax
f0100187:	74 17                	je     f01001a0 <cons_intr+0x32>
			continue;
		cons.buf[cons.wpos++] = c;
f0100189:	8b 13                	mov    (%ebx),%edx
f010018b:	88 04 17             	mov    %al,(%edi,%edx,1)
f010018e:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100191:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100196:	ba 00 00 00 00       	mov    $0x0,%edx
f010019b:	0f 44 c2             	cmove  %edx,%eax
f010019e:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001a0:	ff d6                	call   *%esi
f01001a2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001a5:	75 de                	jne    f0100185 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001a7:	83 c4 0c             	add    $0xc,%esp
f01001aa:	5b                   	pop    %ebx
f01001ab:	5e                   	pop    %esi
f01001ac:	5f                   	pop    %edi
f01001ad:	5d                   	pop    %ebp
f01001ae:	c3                   	ret    

f01001af <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01001af:	55                   	push   %ebp
f01001b0:	89 e5                	mov    %esp,%ebp
f01001b2:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01001b5:	b8 22 05 10 f0       	mov    $0xf0100522,%eax
f01001ba:	e8 af ff ff ff       	call   f010016e <cons_intr>
}
f01001bf:	c9                   	leave  
f01001c0:	c3                   	ret    

f01001c1 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01001c1:	55                   	push   %ebp
f01001c2:	89 e5                	mov    %esp,%ebp
f01001c4:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01001c7:	80 3d 04 33 11 f0 00 	cmpb   $0x0,0xf0113304
f01001ce:	74 0a                	je     f01001da <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01001d0:	b8 4e 01 10 f0       	mov    $0xf010014e,%eax
f01001d5:	e8 94 ff ff ff       	call   f010016e <cons_intr>
}
f01001da:	c9                   	leave  
f01001db:	c3                   	ret    

f01001dc <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01001dc:	55                   	push   %ebp
f01001dd:	89 e5                	mov    %esp,%ebp
f01001df:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01001e2:	e8 da ff ff ff       	call   f01001c1 <serial_intr>
	kbd_intr();
f01001e7:	e8 c3 ff ff ff       	call   f01001af <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01001ec:	8b 15 20 35 11 f0    	mov    0xf0113520,%edx
f01001f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01001f7:	3b 15 24 35 11 f0    	cmp    0xf0113524,%edx
f01001fd:	74 1e                	je     f010021d <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01001ff:	0f b6 82 20 33 11 f0 	movzbl -0xfeecce0(%edx),%eax
f0100206:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f0100209:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f010020f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100214:	0f 44 d1             	cmove  %ecx,%edx
f0100217:	89 15 20 35 11 f0    	mov    %edx,0xf0113520
		return c;
	}
	return 0;
}
f010021d:	c9                   	leave  
f010021e:	c3                   	ret    

f010021f <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f010021f:	55                   	push   %ebp
f0100220:	89 e5                	mov    %esp,%ebp
f0100222:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100225:	e8 b2 ff ff ff       	call   f01001dc <cons_getc>
f010022a:	85 c0                	test   %eax,%eax
f010022c:	74 f7                	je     f0100225 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010022e:	c9                   	leave  
f010022f:	c3                   	ret    

f0100230 <iscons>:

int
iscons(int fdnum)
{
f0100230:	55                   	push   %ebp
f0100231:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100233:	b8 01 00 00 00       	mov    $0x1,%eax
f0100238:	5d                   	pop    %ebp
f0100239:	c3                   	ret    

f010023a <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010023a:	55                   	push   %ebp
f010023b:	89 e5                	mov    %esp,%ebp
f010023d:	57                   	push   %edi
f010023e:	56                   	push   %esi
f010023f:	53                   	push   %ebx
f0100240:	83 ec 2c             	sub    $0x2c,%esp
f0100243:	89 c7                	mov    %eax,%edi
f0100245:	bb 00 00 00 00       	mov    $0x0,%ebx
f010024a:	be fd 03 00 00       	mov    $0x3fd,%esi
f010024f:	eb 08                	jmp    f0100259 <cons_putc+0x1f>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100251:	e8 ea fe ff ff       	call   f0100140 <delay>
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100256:	83 c3 01             	add    $0x1,%ebx
f0100259:	89 f2                	mov    %esi,%edx
f010025b:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010025c:	a8 20                	test   $0x20,%al
f010025e:	75 08                	jne    f0100268 <cons_putc+0x2e>
f0100260:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100266:	75 e9                	jne    f0100251 <cons_putc+0x17>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100268:	89 fa                	mov    %edi,%edx
f010026a:	89 f8                	mov    %edi,%eax
f010026c:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010026f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100274:	ee                   	out    %al,(%dx)
f0100275:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010027a:	be 79 03 00 00       	mov    $0x379,%esi
f010027f:	eb 08                	jmp    f0100289 <cons_putc+0x4f>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f0100281:	e8 ba fe ff ff       	call   f0100140 <delay>
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100286:	83 c3 01             	add    $0x1,%ebx
f0100289:	89 f2                	mov    %esi,%edx
f010028b:	ec                   	in     (%dx),%al
f010028c:	84 c0                	test   %al,%al
f010028e:	78 08                	js     f0100298 <cons_putc+0x5e>
f0100290:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100296:	75 e9                	jne    f0100281 <cons_putc+0x47>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100298:	ba 78 03 00 00       	mov    $0x378,%edx
f010029d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01002a1:	ee                   	out    %al,(%dx)
f01002a2:	b2 7a                	mov    $0x7a,%dl
f01002a4:	b8 0d 00 00 00       	mov    $0xd,%eax
f01002a9:	ee                   	out    %al,(%dx)
f01002aa:	b8 08 00 00 00       	mov    $0x8,%eax
f01002af:	ee                   	out    %al,(%dx)
static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;
f01002b0:	89 f8                	mov    %edi,%eax
f01002b2:	80 cc 07             	or     $0x7,%ah
f01002b5:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01002bb:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01002be:	89 f8                	mov    %edi,%eax
f01002c0:	25 ff 00 00 00       	and    $0xff,%eax
f01002c5:	83 f8 09             	cmp    $0x9,%eax
f01002c8:	0f 84 7e 00 00 00    	je     f010034c <cons_putc+0x112>
f01002ce:	83 f8 09             	cmp    $0x9,%eax
f01002d1:	7f 0f                	jg     f01002e2 <cons_putc+0xa8>
f01002d3:	83 f8 08             	cmp    $0x8,%eax
f01002d6:	0f 85 a4 00 00 00    	jne    f0100380 <cons_putc+0x146>
f01002dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01002e0:	eb 10                	jmp    f01002f2 <cons_putc+0xb8>
f01002e2:	83 f8 0a             	cmp    $0xa,%eax
f01002e5:	74 3b                	je     f0100322 <cons_putc+0xe8>
f01002e7:	83 f8 0d             	cmp    $0xd,%eax
f01002ea:	0f 85 90 00 00 00    	jne    f0100380 <cons_putc+0x146>
f01002f0:	eb 38                	jmp    f010032a <cons_putc+0xf0>
	case '\b':
		if (crt_pos > 0) {
f01002f2:	0f b7 05 10 33 11 f0 	movzwl 0xf0113310,%eax
f01002f9:	66 85 c0             	test   %ax,%ax
f01002fc:	0f 84 e8 00 00 00    	je     f01003ea <cons_putc+0x1b0>
			crt_pos--;
f0100302:	83 e8 01             	sub    $0x1,%eax
f0100305:	66 a3 10 33 11 f0    	mov    %ax,0xf0113310
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010030b:	0f b7 c0             	movzwl %ax,%eax
f010030e:	66 81 e7 00 ff       	and    $0xff00,%di
f0100313:	83 cf 20             	or     $0x20,%edi
f0100316:	8b 15 0c 33 11 f0    	mov    0xf011330c,%edx
f010031c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100320:	eb 7b                	jmp    f010039d <cons_putc+0x163>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100322:	66 83 05 10 33 11 f0 	addw   $0x50,0xf0113310
f0100329:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010032a:	0f b7 05 10 33 11 f0 	movzwl 0xf0113310,%eax
f0100331:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100337:	c1 e8 10             	shr    $0x10,%eax
f010033a:	66 c1 e8 06          	shr    $0x6,%ax
f010033e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100341:	c1 e0 04             	shl    $0x4,%eax
f0100344:	66 a3 10 33 11 f0    	mov    %ax,0xf0113310
f010034a:	eb 51                	jmp    f010039d <cons_putc+0x163>
		break;
	case '\t':
		cons_putc(' ');
f010034c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100351:	e8 e4 fe ff ff       	call   f010023a <cons_putc>
		cons_putc(' ');
f0100356:	b8 20 00 00 00       	mov    $0x20,%eax
f010035b:	e8 da fe ff ff       	call   f010023a <cons_putc>
		cons_putc(' ');
f0100360:	b8 20 00 00 00       	mov    $0x20,%eax
f0100365:	e8 d0 fe ff ff       	call   f010023a <cons_putc>
		cons_putc(' ');
f010036a:	b8 20 00 00 00       	mov    $0x20,%eax
f010036f:	e8 c6 fe ff ff       	call   f010023a <cons_putc>
		cons_putc(' ');
f0100374:	b8 20 00 00 00       	mov    $0x20,%eax
f0100379:	e8 bc fe ff ff       	call   f010023a <cons_putc>
f010037e:	eb 1d                	jmp    f010039d <cons_putc+0x163>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100380:	0f b7 05 10 33 11 f0 	movzwl 0xf0113310,%eax
f0100387:	0f b7 c8             	movzwl %ax,%ecx
f010038a:	8b 15 0c 33 11 f0    	mov    0xf011330c,%edx
f0100390:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f0100394:	83 c0 01             	add    $0x1,%eax
f0100397:	66 a3 10 33 11 f0    	mov    %ax,0xf0113310
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010039d:	66 81 3d 10 33 11 f0 	cmpw   $0x7cf,0xf0113310
f01003a4:	cf 07 
f01003a6:	76 42                	jbe    f01003ea <cons_putc+0x1b0>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01003a8:	a1 0c 33 11 f0       	mov    0xf011330c,%eax
f01003ad:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01003b4:	00 
f01003b5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01003bb:	89 54 24 04          	mov    %edx,0x4(%esp)
f01003bf:	89 04 24             	mov    %eax,(%esp)
f01003c2:	e8 78 13 00 00       	call   f010173f <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01003c7:	8b 15 0c 33 11 f0    	mov    0xf011330c,%edx
f01003cd:	b8 80 07 00 00       	mov    $0x780,%eax
f01003d2:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01003d8:	83 c0 01             	add    $0x1,%eax
f01003db:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01003e0:	75 f0                	jne    f01003d2 <cons_putc+0x198>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01003e2:	66 83 2d 10 33 11 f0 	subw   $0x50,0xf0113310
f01003e9:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01003ea:	8b 0d 08 33 11 f0    	mov    0xf0113308,%ecx
f01003f0:	89 cb                	mov    %ecx,%ebx
f01003f2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01003f7:	89 ca                	mov    %ecx,%edx
f01003f9:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003fa:	0f b7 35 10 33 11 f0 	movzwl 0xf0113310,%esi
f0100401:	83 c1 01             	add    $0x1,%ecx
f0100404:	89 f0                	mov    %esi,%eax
f0100406:	66 c1 e8 08          	shr    $0x8,%ax
f010040a:	89 ca                	mov    %ecx,%edx
f010040c:	ee                   	out    %al,(%dx)
f010040d:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100412:	89 da                	mov    %ebx,%edx
f0100414:	ee                   	out    %al,(%dx)
f0100415:	89 f0                	mov    %esi,%eax
f0100417:	89 ca                	mov    %ecx,%edx
f0100419:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010041a:	83 c4 2c             	add    $0x2c,%esp
f010041d:	5b                   	pop    %ebx
f010041e:	5e                   	pop    %esi
f010041f:	5f                   	pop    %edi
f0100420:	5d                   	pop    %ebp
f0100421:	c3                   	ret    

f0100422 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100422:	55                   	push   %ebp
f0100423:	89 e5                	mov    %esp,%ebp
f0100425:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100428:	8b 45 08             	mov    0x8(%ebp),%eax
f010042b:	e8 0a fe ff ff       	call   f010023a <cons_putc>
}
f0100430:	c9                   	leave  
f0100431:	c3                   	ret    

f0100432 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100432:	55                   	push   %ebp
f0100433:	89 e5                	mov    %esp,%ebp
f0100435:	57                   	push   %edi
f0100436:	56                   	push   %esi
f0100437:	53                   	push   %ebx
f0100438:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010043b:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100440:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f0100443:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f0100448:	0f b7 00             	movzwl (%eax),%eax
f010044b:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010044f:	74 11                	je     f0100462 <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100451:	c7 05 08 33 11 f0 b4 	movl   $0x3b4,0xf0113308
f0100458:	03 00 00 
f010045b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100460:	eb 16                	jmp    f0100478 <cons_init+0x46>
	} else {
		*cp = was;
f0100462:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100469:	c7 05 08 33 11 f0 d4 	movl   $0x3d4,0xf0113308
f0100470:	03 00 00 
f0100473:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100478:	8b 0d 08 33 11 f0    	mov    0xf0113308,%ecx
f010047e:	89 cb                	mov    %ecx,%ebx
f0100480:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100485:	89 ca                	mov    %ecx,%edx
f0100487:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100488:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010048b:	89 ca                	mov    %ecx,%edx
f010048d:	ec                   	in     (%dx),%al
f010048e:	0f b6 f8             	movzbl %al,%edi
f0100491:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100494:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100499:	89 da                	mov    %ebx,%edx
f010049b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010049c:	89 ca                	mov    %ecx,%edx
f010049e:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010049f:	89 35 0c 33 11 f0    	mov    %esi,0xf011330c
	crt_pos = pos;
f01004a5:	0f b6 c8             	movzbl %al,%ecx
f01004a8:	09 cf                	or     %ecx,%edi
f01004aa:	66 89 3d 10 33 11 f0 	mov    %di,0xf0113310
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004b1:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01004b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01004bb:	89 da                	mov    %ebx,%edx
f01004bd:	ee                   	out    %al,(%dx)
f01004be:	b2 fb                	mov    $0xfb,%dl
f01004c0:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01004c5:	ee                   	out    %al,(%dx)
f01004c6:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01004cb:	b8 0c 00 00 00       	mov    $0xc,%eax
f01004d0:	89 ca                	mov    %ecx,%edx
f01004d2:	ee                   	out    %al,(%dx)
f01004d3:	b2 f9                	mov    $0xf9,%dl
f01004d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01004da:	ee                   	out    %al,(%dx)
f01004db:	b2 fb                	mov    $0xfb,%dl
f01004dd:	b8 03 00 00 00       	mov    $0x3,%eax
f01004e2:	ee                   	out    %al,(%dx)
f01004e3:	b2 fc                	mov    $0xfc,%dl
f01004e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01004ea:	ee                   	out    %al,(%dx)
f01004eb:	b2 f9                	mov    $0xf9,%dl
f01004ed:	b8 01 00 00 00       	mov    $0x1,%eax
f01004f2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004f3:	b2 fd                	mov    $0xfd,%dl
f01004f5:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01004f6:	3c ff                	cmp    $0xff,%al
f01004f8:	0f 95 c0             	setne  %al
f01004fb:	89 c6                	mov    %eax,%esi
f01004fd:	a2 04 33 11 f0       	mov    %al,0xf0113304
f0100502:	89 da                	mov    %ebx,%edx
f0100504:	ec                   	in     (%dx),%al
f0100505:	89 ca                	mov    %ecx,%edx
f0100507:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100508:	89 f0                	mov    %esi,%eax
f010050a:	84 c0                	test   %al,%al
f010050c:	75 0c                	jne    f010051a <cons_init+0xe8>
		cprintf("Serial port does not exist!\n");
f010050e:	c7 04 24 ed 1b 10 f0 	movl   $0xf0101bed,(%esp)
f0100515:	e8 05 06 00 00       	call   f0100b1f <cprintf>
}
f010051a:	83 c4 1c             	add    $0x1c,%esp
f010051d:	5b                   	pop    %ebx
f010051e:	5e                   	pop    %esi
f010051f:	5f                   	pop    %edi
f0100520:	5d                   	pop    %ebp
f0100521:	c3                   	ret    

f0100522 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100522:	55                   	push   %ebp
f0100523:	89 e5                	mov    %esp,%ebp
f0100525:	53                   	push   %ebx
f0100526:	83 ec 14             	sub    $0x14,%esp
f0100529:	ba 64 00 00 00       	mov    $0x64,%edx
f010052e:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010052f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100534:	a8 01                	test   $0x1,%al
f0100536:	0f 84 dd 00 00 00    	je     f0100619 <kbd_proc_data+0xf7>
f010053c:	b2 60                	mov    $0x60,%dl
f010053e:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010053f:	3c e0                	cmp    $0xe0,%al
f0100541:	75 11                	jne    f0100554 <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f0100543:	83 0d 00 33 11 f0 40 	orl    $0x40,0xf0113300
f010054a:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f010054f:	e9 c5 00 00 00       	jmp    f0100619 <kbd_proc_data+0xf7>
	} else if (data & 0x80) {
f0100554:	84 c0                	test   %al,%al
f0100556:	79 35                	jns    f010058d <kbd_proc_data+0x6b>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100558:	8b 15 00 33 11 f0    	mov    0xf0113300,%edx
f010055e:	89 c1                	mov    %eax,%ecx
f0100560:	83 e1 7f             	and    $0x7f,%ecx
f0100563:	f6 c2 40             	test   $0x40,%dl
f0100566:	0f 44 c1             	cmove  %ecx,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f0100569:	0f b6 c0             	movzbl %al,%eax
f010056c:	0f b6 80 20 1c 10 f0 	movzbl -0xfefe3e0(%eax),%eax
f0100573:	83 c8 40             	or     $0x40,%eax
f0100576:	0f b6 c0             	movzbl %al,%eax
f0100579:	f7 d0                	not    %eax
f010057b:	21 c2                	and    %eax,%edx
f010057d:	89 15 00 33 11 f0    	mov    %edx,0xf0113300
f0100583:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100588:	e9 8c 00 00 00       	jmp    f0100619 <kbd_proc_data+0xf7>
	} else if (shift & E0ESC) {
f010058d:	8b 15 00 33 11 f0    	mov    0xf0113300,%edx
f0100593:	f6 c2 40             	test   $0x40,%dl
f0100596:	74 0c                	je     f01005a4 <kbd_proc_data+0x82>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100598:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f010059b:	83 e2 bf             	and    $0xffffffbf,%edx
f010059e:	89 15 00 33 11 f0    	mov    %edx,0xf0113300
	}

	shift |= shiftcode[data];
f01005a4:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f01005a7:	0f b6 90 20 1c 10 f0 	movzbl -0xfefe3e0(%eax),%edx
f01005ae:	0b 15 00 33 11 f0    	or     0xf0113300,%edx
f01005b4:	0f b6 88 20 1d 10 f0 	movzbl -0xfefe2e0(%eax),%ecx
f01005bb:	31 ca                	xor    %ecx,%edx
f01005bd:	89 15 00 33 11 f0    	mov    %edx,0xf0113300

	c = charcode[shift & (CTL | SHIFT)][data];
f01005c3:	89 d1                	mov    %edx,%ecx
f01005c5:	83 e1 03             	and    $0x3,%ecx
f01005c8:	8b 0c 8d 20 1e 10 f0 	mov    -0xfefe1e0(,%ecx,4),%ecx
f01005cf:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f01005d3:	f6 c2 08             	test   $0x8,%dl
f01005d6:	74 1b                	je     f01005f3 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f01005d8:	89 d9                	mov    %ebx,%ecx
f01005da:	8d 43 9f             	lea    -0x61(%ebx),%eax
f01005dd:	83 f8 19             	cmp    $0x19,%eax
f01005e0:	77 05                	ja     f01005e7 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f01005e2:	83 eb 20             	sub    $0x20,%ebx
f01005e5:	eb 0c                	jmp    f01005f3 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f01005e7:	83 e9 41             	sub    $0x41,%ecx
			c += 'a' - 'A';
f01005ea:	8d 43 20             	lea    0x20(%ebx),%eax
f01005ed:	83 f9 19             	cmp    $0x19,%ecx
f01005f0:	0f 46 d8             	cmovbe %eax,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005f3:	f7 d2                	not    %edx
f01005f5:	f6 c2 06             	test   $0x6,%dl
f01005f8:	75 1f                	jne    f0100619 <kbd_proc_data+0xf7>
f01005fa:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100600:	75 17                	jne    f0100619 <kbd_proc_data+0xf7>
		cprintf("Rebooting!\n");
f0100602:	c7 04 24 0a 1c 10 f0 	movl   $0xf0101c0a,(%esp)
f0100609:	e8 11 05 00 00       	call   f0100b1f <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010060e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100613:	b8 03 00 00 00       	mov    $0x3,%eax
f0100618:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100619:	89 d8                	mov    %ebx,%eax
f010061b:	83 c4 14             	add    $0x14,%esp
f010061e:	5b                   	pop    %ebx
f010061f:	5d                   	pop    %ebp
f0100620:	c3                   	ret    
	...

f0100630 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100630:	55                   	push   %ebp
f0100631:	89 e5                	mov    %esp,%ebp
f0100633:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100636:	c7 04 24 30 1e 10 f0 	movl   $0xf0101e30,(%esp)
f010063d:	e8 dd 04 00 00       	call   f0100b1f <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100642:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100649:	00 
f010064a:	c7 04 24 e4 1e 10 f0 	movl   $0xf0101ee4,(%esp)
f0100651:	e8 c9 04 00 00       	call   f0100b1f <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100656:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010065d:	00 
f010065e:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100665:	f0 
f0100666:	c7 04 24 0c 1f 10 f0 	movl   $0xf0101f0c,(%esp)
f010066d:	e8 ad 04 00 00       	call   f0100b1f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100672:	c7 44 24 08 8b 1b 10 	movl   $0x101b8b,0x8(%esp)
f0100679:	00 
f010067a:	c7 44 24 04 8b 1b 10 	movl   $0xf0101b8b,0x4(%esp)
f0100681:	f0 
f0100682:	c7 04 24 30 1f 10 f0 	movl   $0xf0101f30,(%esp)
f0100689:	e8 91 04 00 00       	call   f0100b1f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010068e:	c7 44 24 08 00 33 11 	movl   $0x113300,0x8(%esp)
f0100695:	00 
f0100696:	c7 44 24 04 00 33 11 	movl   $0xf0113300,0x4(%esp)
f010069d:	f0 
f010069e:	c7 04 24 54 1f 10 f0 	movl   $0xf0101f54,(%esp)
f01006a5:	e8 75 04 00 00       	call   f0100b1f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006aa:	c7 44 24 08 50 39 11 	movl   $0x113950,0x8(%esp)
f01006b1:	00 
f01006b2:	c7 44 24 04 50 39 11 	movl   $0xf0113950,0x4(%esp)
f01006b9:	f0 
f01006ba:	c7 04 24 78 1f 10 f0 	movl   $0xf0101f78,(%esp)
f01006c1:	e8 59 04 00 00       	call   f0100b1f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006c6:	b8 4f 3d 11 f0       	mov    $0xf0113d4f,%eax
f01006cb:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006d0:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01006d5:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006db:	85 c0                	test   %eax,%eax
f01006dd:	0f 48 c2             	cmovs  %edx,%eax
f01006e0:	c1 f8 0a             	sar    $0xa,%eax
f01006e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006e7:	c7 04 24 9c 1f 10 f0 	movl   $0xf0101f9c,(%esp)
f01006ee:	e8 2c 04 00 00       	call   f0100b1f <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01006f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006f8:	c9                   	leave  
f01006f9:	c3                   	ret    

f01006fa <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006fa:	55                   	push   %ebp
f01006fb:	89 e5                	mov    %esp,%ebp
f01006fd:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100700:	a1 78 20 10 f0       	mov    0xf0102078,%eax
f0100705:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100709:	a1 74 20 10 f0       	mov    0xf0102074,%eax
f010070e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100712:	c7 04 24 49 1e 10 f0 	movl   $0xf0101e49,(%esp)
f0100719:	e8 01 04 00 00       	call   f0100b1f <cprintf>
f010071e:	a1 84 20 10 f0       	mov    0xf0102084,%eax
f0100723:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100727:	a1 80 20 10 f0       	mov    0xf0102080,%eax
f010072c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100730:	c7 04 24 49 1e 10 f0 	movl   $0xf0101e49,(%esp)
f0100737:	e8 e3 03 00 00       	call   f0100b1f <cprintf>
	return 0;
}
f010073c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100741:	c9                   	leave  
f0100742:	c3                   	ret    

f0100743 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100743:	55                   	push   %ebp
f0100744:	89 e5                	mov    %esp,%ebp
f0100746:	57                   	push   %edi
f0100747:	56                   	push   %esi
f0100748:	53                   	push   %ebx
f0100749:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010074c:	c7 04 24 c8 1f 10 f0 	movl   $0xf0101fc8,(%esp)
f0100753:	e8 c7 03 00 00       	call   f0100b1f <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100758:	c7 04 24 ec 1f 10 f0 	movl   $0xf0101fec,(%esp)
f010075f:	e8 bb 03 00 00       	call   f0100b1f <cprintf>

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100764:	bf 74 20 10 f0       	mov    $0xf0102074,%edi
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f0100769:	c7 04 24 52 1e 10 f0 	movl   $0xf0101e52,(%esp)
f0100770:	e8 1b 0d 00 00       	call   f0101490 <readline>
f0100775:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100777:	85 c0                	test   %eax,%eax
f0100779:	74 ee                	je     f0100769 <monitor+0x26>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010077b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f0100782:	be 00 00 00 00       	mov    $0x0,%esi
f0100787:	eb 06                	jmp    f010078f <monitor+0x4c>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100789:	c6 03 00             	movb   $0x0,(%ebx)
f010078c:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010078f:	0f b6 03             	movzbl (%ebx),%eax
f0100792:	84 c0                	test   %al,%al
f0100794:	74 63                	je     f01007f9 <monitor+0xb6>
f0100796:	0f be c0             	movsbl %al,%eax
f0100799:	89 44 24 04          	mov    %eax,0x4(%esp)
f010079d:	c7 04 24 56 1e 10 f0 	movl   $0xf0101e56,(%esp)
f01007a4:	e8 fa 0e 00 00       	call   f01016a3 <strchr>
f01007a9:	85 c0                	test   %eax,%eax
f01007ab:	75 dc                	jne    f0100789 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01007ad:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007b0:	74 47                	je     f01007f9 <monitor+0xb6>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01007b2:	83 fe 0f             	cmp    $0xf,%esi
f01007b5:	75 16                	jne    f01007cd <monitor+0x8a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007b7:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01007be:	00 
f01007bf:	c7 04 24 5b 1e 10 f0 	movl   $0xf0101e5b,(%esp)
f01007c6:	e8 54 03 00 00       	call   f0100b1f <cprintf>
f01007cb:	eb 9c                	jmp    f0100769 <monitor+0x26>
			return 0;
		}
		argv[argc++] = buf;
f01007cd:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01007d1:	83 c6 01             	add    $0x1,%esi
f01007d4:	eb 03                	jmp    f01007d9 <monitor+0x96>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01007d6:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01007d9:	0f b6 03             	movzbl (%ebx),%eax
f01007dc:	84 c0                	test   %al,%al
f01007de:	74 af                	je     f010078f <monitor+0x4c>
f01007e0:	0f be c0             	movsbl %al,%eax
f01007e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007e7:	c7 04 24 56 1e 10 f0 	movl   $0xf0101e56,(%esp)
f01007ee:	e8 b0 0e 00 00       	call   f01016a3 <strchr>
f01007f3:	85 c0                	test   %eax,%eax
f01007f5:	74 df                	je     f01007d6 <monitor+0x93>
f01007f7:	eb 96                	jmp    f010078f <monitor+0x4c>
			buf++;
	}
	argv[argc] = 0;
f01007f9:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100800:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100801:	85 f6                	test   %esi,%esi
f0100803:	0f 84 60 ff ff ff    	je     f0100769 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100809:	8b 07                	mov    (%edi),%eax
f010080b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010080f:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100812:	89 04 24             	mov    %eax,(%esp)
f0100815:	e8 2a 0e 00 00       	call   f0101644 <strcmp>
f010081a:	ba 00 00 00 00       	mov    $0x0,%edx
f010081f:	85 c0                	test   %eax,%eax
f0100821:	74 1d                	je     f0100840 <monitor+0xfd>
f0100823:	a1 80 20 10 f0       	mov    0xf0102080,%eax
f0100828:	89 44 24 04          	mov    %eax,0x4(%esp)
f010082c:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010082f:	89 04 24             	mov    %eax,(%esp)
f0100832:	e8 0d 0e 00 00       	call   f0101644 <strcmp>
f0100837:	85 c0                	test   %eax,%eax
f0100839:	75 28                	jne    f0100863 <monitor+0x120>
f010083b:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f0100840:	6b d2 0c             	imul   $0xc,%edx,%edx
f0100843:	8b 45 08             	mov    0x8(%ebp),%eax
f0100846:	89 44 24 08          	mov    %eax,0x8(%esp)
f010084a:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010084d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100851:	89 34 24             	mov    %esi,(%esp)
f0100854:	ff 92 7c 20 10 f0    	call   *-0xfefdf84(%edx)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010085a:	85 c0                	test   %eax,%eax
f010085c:	78 1d                	js     f010087b <monitor+0x138>
f010085e:	e9 06 ff ff ff       	jmp    f0100769 <monitor+0x26>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100863:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100866:	89 44 24 04          	mov    %eax,0x4(%esp)
f010086a:	c7 04 24 78 1e 10 f0 	movl   $0xf0101e78,(%esp)
f0100871:	e8 a9 02 00 00       	call   f0100b1f <cprintf>
f0100876:	e9 ee fe ff ff       	jmp    f0100769 <monitor+0x26>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010087b:	83 c4 5c             	add    $0x5c,%esp
f010087e:	5b                   	pop    %ebx
f010087f:	5e                   	pop    %esi
f0100880:	5f                   	pop    %edi
f0100881:	5d                   	pop    %ebp
f0100882:	c3                   	ret    

f0100883 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100883:	55                   	push   %ebp
f0100884:	89 e5                	mov    %esp,%ebp
f0100886:	57                   	push   %edi
f0100887:	56                   	push   %esi
f0100888:	53                   	push   %ebx
f0100889:	83 ec 6c             	sub    $0x6c,%esp
    // Your code here.
    cprintf("Stack backtrace:\n");
f010088c:	c7 04 24 8e 1e 10 f0 	movl   $0xf0101e8e,(%esp)
f0100893:	e8 87 02 00 00       	call   f0100b1f <cprintf>
    uint32_t* ebp = (uint32_t*) read_ebp();
f0100898:	89 eb                	mov    %ebp,%ebx
    while(ebp)
f010089a:	e9 98 00 00 00       	jmp    f0100937 <mon_backtrace+0xb4>
    {
        uint32_t saved_ebp = ebp[0];
f010089f:	8b 03                	mov    (%ebx),%eax
f01008a1:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        uint32_t ret_eip = ebp[1];
f01008a4:	8b 73 04             	mov    0x4(%ebx),%esi
        uint32_t arg0 = ebp[2];
f01008a7:	8b 43 08             	mov    0x8(%ebx),%eax
f01008aa:	89 45 b8             	mov    %eax,-0x48(%ebp)
        uint32_t arg1 = ebp[3];
f01008ad:	8b 43 0c             	mov    0xc(%ebx),%eax
f01008b0:	89 45 bc             	mov    %eax,-0x44(%ebp)
        uint32_t arg2 = ebp[4];
f01008b3:	8b 43 10             	mov    0x10(%ebx),%eax
f01008b6:	89 45 c0             	mov    %eax,-0x40(%ebp)
        uint32_t arg3 = ebp[5];
f01008b9:	8b 43 14             	mov    0x14(%ebx),%eax
f01008bc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        uint32_t arg4 = ebp[6];
f01008bf:	8b 7b 18             	mov    0x18(%ebx),%edi
        
        struct Eipdebuginfo info;
        debuginfo_eip(ret_eip, &info);
f01008c2:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008c9:	89 34 24             	mov    %esi,(%esp)
f01008cc:	e8 81 03 00 00       	call   f0100c52 <debuginfo_eip>
        
        cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, ret_eip, arg0, arg1, arg2, arg3, arg4);
f01008d1:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f01008d5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01008d8:	89 44 24 18          	mov    %eax,0x18(%esp)
f01008dc:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01008df:	89 44 24 14          	mov    %eax,0x14(%esp)
f01008e3:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01008e6:	89 44 24 10          	mov    %eax,0x10(%esp)
f01008ea:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01008ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01008f1:	89 74 24 08          	mov    %esi,0x8(%esp)
f01008f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01008f9:	c7 04 24 14 20 10 f0 	movl   $0xf0102014,(%esp)
f0100900:	e8 1a 02 00 00       	call   f0100b1f <cprintf>
        cprintf("     %s:%d: %.*s+%u\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name,       
f0100905:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100908:	89 74 24 14          	mov    %esi,0x14(%esp)
f010090c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010090f:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100913:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100916:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010091a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010091d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100921:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100924:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100928:	c7 04 24 a0 1e 10 f0 	movl   $0xf0101ea0,(%esp)
f010092f:	e8 eb 01 00 00       	call   f0100b1f <cprintf>
                      ret_eip - info.eip_fn_addr);
        ebp = (uint32_t*)saved_ebp;
f0100934:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
    // Your code here.
    cprintf("Stack backtrace:\n");
    uint32_t* ebp = (uint32_t*) read_ebp();
    while(ebp)
f0100937:	85 db                	test   %ebx,%ebx
f0100939:	0f 85 60 ff ff ff    	jne    f010089f <mon_backtrace+0x1c>
                      ret_eip - info.eip_fn_addr);
        ebp = (uint32_t*)saved_ebp;
    }

	return 0;
}
f010093f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100944:	83 c4 6c             	add    $0x6c,%esp
f0100947:	5b                   	pop    %ebx
f0100948:	5e                   	pop    %esi
f0100949:	5f                   	pop    %edi
f010094a:	5d                   	pop    %ebp
f010094b:	c3                   	ret    

f010094c <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f010094c:	55                   	push   %ebp
f010094d:	89 e5                	mov    %esp,%ebp
f010094f:	53                   	push   %ebx
f0100950:	8b 0d 2c 35 11 f0    	mov    0xf011352c,%ecx
f0100956:	b8 00 00 00 00       	mov    $0x0,%eax
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f010095b:	eb 28                	jmp    f0100985 <page_init+0x39>
f010095d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100964:	8b 1d 4c 39 11 f0    	mov    0xf011394c,%ebx
f010096a:	66 c7 44 13 04 00 00 	movw   $0x0,0x4(%ebx,%edx,1)
		pages[i].pp_link = page_free_list;
f0100971:	8b 1d 4c 39 11 f0    	mov    0xf011394c,%ebx
f0100977:	89 0c 13             	mov    %ecx,(%ebx,%edx,1)
		page_free_list = &pages[i];
f010097a:	89 d1                	mov    %edx,%ecx
f010097c:	03 0d 4c 39 11 f0    	add    0xf011394c,%ecx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100982:	83 c0 01             	add    $0x1,%eax
f0100985:	3b 05 44 39 11 f0    	cmp    0xf0113944,%eax
f010098b:	72 d0                	jb     f010095d <page_init+0x11>
f010098d:	89 0d 2c 35 11 f0    	mov    %ecx,0xf011352c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100993:	5b                   	pop    %ebx
f0100994:	5d                   	pop    %ebp
f0100995:	c3                   	ret    

f0100996 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100996:	55                   	push   %ebp
f0100997:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100999:	b8 00 00 00 00       	mov    $0x0,%eax
f010099e:	5d                   	pop    %ebp
f010099f:	c3                   	ret    

f01009a0 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f01009a0:	55                   	push   %ebp
f01009a1:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
}
f01009a3:	5d                   	pop    %ebp
f01009a4:	c3                   	ret    

f01009a5 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01009a5:	55                   	push   %ebp
f01009a6:	89 e5                	mov    %esp,%ebp
f01009a8:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01009ab:	66 83 68 04 01       	subw   $0x1,0x4(%eax)
		page_free(pp);
}
f01009b0:	5d                   	pop    %ebp
f01009b1:	c3                   	ret    

f01009b2 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01009b2:	55                   	push   %ebp
f01009b3:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f01009b5:	b8 00 00 00 00       	mov    $0x0,%eax
f01009ba:	5d                   	pop    %ebp
f01009bb:	c3                   	ret    

f01009bc <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01009bc:	55                   	push   %ebp
f01009bd:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f01009bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01009c4:	5d                   	pop    %ebp
f01009c5:	c3                   	ret    

f01009c6 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01009c6:	55                   	push   %ebp
f01009c7:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f01009c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01009ce:	5d                   	pop    %ebp
f01009cf:	c3                   	ret    

f01009d0 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01009d0:	55                   	push   %ebp
f01009d1:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f01009d3:	5d                   	pop    %ebp
f01009d4:	c3                   	ret    

f01009d5 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01009d5:	55                   	push   %ebp
f01009d6:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01009d8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01009db:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01009de:	5d                   	pop    %ebp
f01009df:	c3                   	ret    

f01009e0 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01009e0:	55                   	push   %ebp
f01009e1:	89 e5                	mov    %esp,%ebp
f01009e3:	83 ec 18             	sub    $0x18,%esp
f01009e6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01009e9:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01009ec:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01009ee:	89 04 24             	mov    %eax,(%esp)
f01009f1:	e8 ce 00 00 00       	call   f0100ac4 <mc146818_read>
f01009f6:	89 c6                	mov    %eax,%esi
f01009f8:	83 c3 01             	add    $0x1,%ebx
f01009fb:	89 1c 24             	mov    %ebx,(%esp)
f01009fe:	e8 c1 00 00 00       	call   f0100ac4 <mc146818_read>
f0100a03:	c1 e0 08             	shl    $0x8,%eax
f0100a06:	09 f0                	or     %esi,%eax
}
f0100a08:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100a0b:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100a0e:	89 ec                	mov    %ebp,%esp
f0100a10:	5d                   	pop    %ebp
f0100a11:	c3                   	ret    

f0100a12 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100a12:	55                   	push   %ebp
f0100a13:	89 e5                	mov    %esp,%ebp
f0100a15:	83 ec 18             	sub    $0x18,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100a18:	b8 15 00 00 00       	mov    $0x15,%eax
f0100a1d:	e8 be ff ff ff       	call   f01009e0 <nvram_read>
f0100a22:	c1 e0 0a             	shl    $0xa,%eax
f0100a25:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100a2b:	85 c0                	test   %eax,%eax
f0100a2d:	0f 48 c2             	cmovs  %edx,%eax
f0100a30:	c1 f8 0c             	sar    $0xc,%eax
f0100a33:	a3 28 35 11 f0       	mov    %eax,0xf0113528
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0100a38:	b8 17 00 00 00       	mov    $0x17,%eax
f0100a3d:	e8 9e ff ff ff       	call   f01009e0 <nvram_read>
f0100a42:	c1 e0 0a             	shl    $0xa,%eax
f0100a45:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100a4b:	85 c0                	test   %eax,%eax
f0100a4d:	0f 48 c2             	cmovs  %edx,%eax
f0100a50:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100a53:	85 c0                	test   %eax,%eax
f0100a55:	74 0e                	je     f0100a65 <mem_init+0x53>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100a57:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0100a5d:	89 15 44 39 11 f0    	mov    %edx,0xf0113944
f0100a63:	eb 0c                	jmp    f0100a71 <mem_init+0x5f>
	else
		npages = npages_basemem;
f0100a65:	8b 15 28 35 11 f0    	mov    0xf0113528,%edx
f0100a6b:	89 15 44 39 11 f0    	mov    %edx,0xf0113944

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100a71:	c1 e0 0c             	shl    $0xc,%eax
f0100a74:	c1 e8 0a             	shr    $0xa,%eax
f0100a77:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a7b:	a1 28 35 11 f0       	mov    0xf0113528,%eax
f0100a80:	c1 e0 0c             	shl    $0xc,%eax
f0100a83:	c1 e8 0a             	shr    $0xa,%eax
f0100a86:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a8a:	a1 44 39 11 f0       	mov    0xf0113944,%eax
f0100a8f:	c1 e0 0c             	shl    $0xc,%eax
f0100a92:	c1 e8 0a             	shr    $0xa,%eax
f0100a95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a99:	c7 04 24 8c 20 10 f0 	movl   $0xf010208c,(%esp)
f0100aa0:	e8 7a 00 00 00       	call   f0100b1f <cprintf>

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	// Remove this line when you're ready to test this function.
	panic("mem_init: This function is not finished\n");
f0100aa5:	c7 44 24 08 c8 20 10 	movl   $0xf01020c8,0x8(%esp)
f0100aac:	f0 
f0100aad:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
f0100ab4:	00 
f0100ab5:	c7 04 24 f4 20 10 f0 	movl   $0xf01020f4,(%esp)
f0100abc:	e8 c4 f5 ff ff       	call   f0100085 <_panic>
f0100ac1:	00 00                	add    %al,(%eax)
	...

f0100ac4 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100ac4:	55                   	push   %ebp
f0100ac5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100ac7:	ba 70 00 00 00       	mov    $0x70,%edx
f0100acc:	8b 45 08             	mov    0x8(%ebp),%eax
f0100acf:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100ad0:	b2 71                	mov    $0x71,%dl
f0100ad2:	ec                   	in     (%dx),%al
f0100ad3:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f0100ad6:	5d                   	pop    %ebp
f0100ad7:	c3                   	ret    

f0100ad8 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100ad8:	55                   	push   %ebp
f0100ad9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100adb:	ba 70 00 00 00       	mov    $0x70,%edx
f0100ae0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ae3:	ee                   	out    %al,(%dx)
f0100ae4:	b2 71                	mov    $0x71,%dl
f0100ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ae9:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100aea:	5d                   	pop    %ebp
f0100aeb:	c3                   	ret    

f0100aec <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0100aec:	55                   	push   %ebp
f0100aed:	89 e5                	mov    %esp,%ebp
f0100aef:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100af2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100af9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100afc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b00:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b03:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b07:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b0a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b0e:	c7 04 24 39 0b 10 f0 	movl   $0xf0100b39,(%esp)
f0100b15:	e8 e9 04 00 00       	call   f0101003 <vprintfmt>
	return cnt;
}
f0100b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b1d:	c9                   	leave  
f0100b1e:	c3                   	ret    

f0100b1f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b1f:	55                   	push   %ebp
f0100b20:	89 e5                	mov    %esp,%ebp
f0100b22:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0100b25:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0100b28:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b2c:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b2f:	89 04 24             	mov    %eax,(%esp)
f0100b32:	e8 b5 ff ff ff       	call   f0100aec <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b37:	c9                   	leave  
f0100b38:	c3                   	ret    

f0100b39 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100b39:	55                   	push   %ebp
f0100b3a:	89 e5                	mov    %esp,%ebp
f0100b3c:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100b3f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b42:	89 04 24             	mov    %eax,(%esp)
f0100b45:	e8 d8 f8 ff ff       	call   f0100422 <cputchar>
	*cnt++;
}
f0100b4a:	c9                   	leave  
f0100b4b:	c3                   	ret    
f0100b4c:	00 00                	add    %al,(%eax)
	...

f0100b50 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b50:	55                   	push   %ebp
f0100b51:	89 e5                	mov    %esp,%ebp
f0100b53:	57                   	push   %edi
f0100b54:	56                   	push   %esi
f0100b55:	53                   	push   %ebx
f0100b56:	83 ec 14             	sub    $0x14,%esp
f0100b59:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b5c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0100b5f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b62:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b65:	8b 1a                	mov    (%edx),%ebx
f0100b67:	8b 01                	mov    (%ecx),%eax
f0100b69:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b6c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f0100b73:	e9 88 00 00 00       	jmp    f0100c00 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0100b78:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b7b:	01 d8                	add    %ebx,%eax
f0100b7d:	89 c7                	mov    %eax,%edi
f0100b7f:	c1 ef 1f             	shr    $0x1f,%edi
f0100b82:	01 c7                	add    %eax,%edi
f0100b84:	d1 ff                	sar    %edi
f0100b86:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0100b89:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b8c:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100b90:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100b92:	eb 03                	jmp    f0100b97 <stab_binsearch+0x47>
			m--;
f0100b94:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100b97:	39 c3                	cmp    %eax,%ebx
f0100b99:	7f 0c                	jg     f0100ba7 <stab_binsearch+0x57>
f0100b9b:	0f b6 0a             	movzbl (%edx),%ecx
f0100b9e:	83 ea 0c             	sub    $0xc,%edx
f0100ba1:	39 f1                	cmp    %esi,%ecx
f0100ba3:	75 ef                	jne    f0100b94 <stab_binsearch+0x44>
f0100ba5:	eb 05                	jmp    f0100bac <stab_binsearch+0x5c>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100ba7:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100baa:	eb 54                	jmp    f0100c00 <stab_binsearch+0xb0>
f0100bac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100baf:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bb2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100bb5:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100bb9:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100bbc:	76 11                	jbe    f0100bcf <stab_binsearch+0x7f>
			*region_left = m;
f0100bbe:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100bc1:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100bc3:	8d 5f 01             	lea    0x1(%edi),%ebx
f0100bc6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0100bcd:	eb 31                	jmp    f0100c00 <stab_binsearch+0xb0>
		} else if (stabs[m].n_value > addr) {
f0100bcf:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100bd2:	73 17                	jae    f0100beb <stab_binsearch+0x9b>
			*region_right = m - 1;
f0100bd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bd7:	83 e8 01             	sub    $0x1,%eax
f0100bda:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100bdd:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100be0:	89 02                	mov    %eax,(%edx)
f0100be2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0100be9:	eb 15                	jmp    f0100c00 <stab_binsearch+0xb0>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100beb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100bee:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100bf1:	89 19                	mov    %ebx,(%ecx)
			l = m;
			addr++;
f0100bf3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100bf7:	89 c3                	mov    %eax,%ebx
f0100bf9:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100c00:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100c03:	0f 8e 6f ff ff ff    	jle    f0100b78 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100c09:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100c0d:	75 0f                	jne    f0100c1e <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0100c0f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100c12:	8b 02                	mov    (%edx),%eax
f0100c14:	83 e8 01             	sub    $0x1,%eax
f0100c17:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100c1a:	89 01                	mov    %eax,(%ecx)
f0100c1c:	eb 2c                	jmp    f0100c4a <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c1e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100c21:	8b 03                	mov    (%ebx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100c23:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100c26:	8b 0a                	mov    (%edx),%ecx
f0100c28:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c2b:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0100c2e:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c32:	eb 03                	jmp    f0100c37 <stab_binsearch+0xe7>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100c34:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c37:	39 c8                	cmp    %ecx,%eax
f0100c39:	7e 0a                	jle    f0100c45 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0100c3b:	0f b6 1a             	movzbl (%edx),%ebx
f0100c3e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100c41:	39 f3                	cmp    %esi,%ebx
f0100c43:	75 ef                	jne    f0100c34 <stab_binsearch+0xe4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0100c45:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100c48:	89 02                	mov    %eax,(%edx)
	}
}
f0100c4a:	83 c4 14             	add    $0x14,%esp
f0100c4d:	5b                   	pop    %ebx
f0100c4e:	5e                   	pop    %esi
f0100c4f:	5f                   	pop    %edi
f0100c50:	5d                   	pop    %ebp
f0100c51:	c3                   	ret    

f0100c52 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c52:	55                   	push   %ebp
f0100c53:	89 e5                	mov    %esp,%ebp
f0100c55:	83 ec 58             	sub    $0x58,%esp
f0100c58:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100c5b:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100c5e:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100c61:	8b 75 08             	mov    0x8(%ebp),%esi
f0100c64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c67:	c7 03 00 21 10 f0    	movl   $0xf0102100,(%ebx)
	info->eip_line = 0;
f0100c6d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100c74:	c7 43 08 00 21 10 f0 	movl   $0xf0102100,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100c7b:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100c82:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100c85:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c8c:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100c92:	76 12                	jbe    f0100ca6 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c94:	b8 f6 83 10 f0       	mov    $0xf01083f6,%eax
f0100c99:	3d 0d 67 10 f0       	cmp    $0xf010670d,%eax
f0100c9e:	0f 86 ec 01 00 00    	jbe    f0100e90 <debuginfo_eip+0x23e>
f0100ca4:	eb 1c                	jmp    f0100cc2 <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100ca6:	c7 44 24 08 0a 21 10 	movl   $0xf010210a,0x8(%esp)
f0100cad:	f0 
f0100cae:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100cb5:	00 
f0100cb6:	c7 04 24 17 21 10 f0 	movl   $0xf0102117,(%esp)
f0100cbd:	e8 c3 f3 ff ff       	call   f0100085 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100cc2:	80 3d f5 83 10 f0 00 	cmpb   $0x0,0xf01083f5
f0100cc9:	0f 85 c1 01 00 00    	jne    f0100e90 <debuginfo_eip+0x23e>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100ccf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100cd6:	b8 0c 67 10 f0       	mov    $0xf010670c,%eax
f0100cdb:	2d 50 23 10 f0       	sub    $0xf0102350,%eax
f0100ce0:	c1 f8 02             	sar    $0x2,%eax
f0100ce3:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100ce9:	83 e8 01             	sub    $0x1,%eax
f0100cec:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100cef:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100cf2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100cf5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100cf9:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100d00:	b8 50 23 10 f0       	mov    $0xf0102350,%eax
f0100d05:	e8 46 fe ff ff       	call   f0100b50 <stab_binsearch>
	if (lfile == 0)
f0100d0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d0d:	85 c0                	test   %eax,%eax
f0100d0f:	0f 84 7b 01 00 00    	je     f0100e90 <debuginfo_eip+0x23e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100d15:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100d18:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100d1e:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100d21:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d24:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100d28:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100d2f:	b8 50 23 10 f0       	mov    $0xf0102350,%eax
f0100d34:	e8 17 fe ff ff       	call   f0100b50 <stab_binsearch>

	if (lfun <= rfun) {
f0100d39:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d3c:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100d3f:	7f 3c                	jg     f0100d7d <debuginfo_eip+0x12b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d41:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100d44:	8b 80 50 23 10 f0    	mov    -0xfefdcb0(%eax),%eax
f0100d4a:	ba f6 83 10 f0       	mov    $0xf01083f6,%edx
f0100d4f:	81 ea 0d 67 10 f0    	sub    $0xf010670d,%edx
f0100d55:	39 d0                	cmp    %edx,%eax
f0100d57:	73 08                	jae    f0100d61 <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d59:	05 0d 67 10 f0       	add    $0xf010670d,%eax
f0100d5e:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d61:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d64:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100d67:	8b 92 58 23 10 f0    	mov    -0xfefdca8(%edx),%edx
f0100d6d:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100d70:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100d72:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100d75:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d78:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d7b:	eb 0f                	jmp    f0100d8c <debuginfo_eip+0x13a>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100d7d:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100d80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100d86:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d89:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d8c:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100d93:	00 
f0100d94:	8b 43 08             	mov    0x8(%ebx),%eax
f0100d97:	89 04 24             	mov    %eax,(%esp)
f0100d9a:	e8 25 09 00 00       	call   f01016c4 <strfind>
f0100d9f:	2b 43 08             	sub    0x8(%ebx),%eax
f0100da2:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
    if (lfun <= rfun) 
f0100da5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100da8:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100dab:	7f 28                	jg     f0100dd5 <debuginfo_eip+0x183>
    {
        // If lfun <= rfun, it's a function span search.
        // In this case, n_value is in order!
        // So use binary search.
        stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100dad:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100db0:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100db3:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100db7:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0100dbe:	b8 50 23 10 f0       	mov    $0xf0102350,%eax
f0100dc3:	e8 88 fd ff ff       	call   f0100b50 <stab_binsearch>

        if (lline > rline)
f0100dc8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100dcb:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100dce:	7e 47                	jle    f0100e17 <debuginfo_eip+0x1c5>
f0100dd0:	e9 bb 00 00 00       	jmp    f0100e90 <debuginfo_eip+0x23e>
        // Note that if lfun > rfun, lline, rline == lfile, rfile,
        // which means a file span search.
        // In this case, n_value is not in order!
        // Cannot use binary search, so just sequential search.
        int index;
        for (index = lline; index <= rline; ++index)
f0100dd5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100dd8:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0100ddb:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100dde:	81 c2 54 23 10 f0    	add    $0xf0102354,%edx
f0100de4:	eb 23                	jmp    f0100e09 <debuginfo_eip+0x1b7>
            if (stabs[index].n_type == N_SLINE) {
f0100de6:	80 3a 44             	cmpb   $0x44,(%edx)
f0100de9:	75 18                	jne    f0100e03 <debuginfo_eip+0x1b1>
                uintptr_t stab_addr = stabs[index].n_value;
f0100deb:	8b 4a 04             	mov    0x4(%edx),%ecx
                if (stab_addr == addr) {
f0100dee:	39 f1                	cmp    %esi,%ecx
f0100df0:	75 05                	jne    f0100df7 <debuginfo_eip+0x1a5>
                    lline = index;
f0100df2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
                    break;
f0100df5:	eb 1b                	jmp    f0100e12 <debuginfo_eip+0x1c0>
                } else if (stab_addr > addr) {
f0100df7:	39 ce                	cmp    %ecx,%esi
f0100df9:	73 08                	jae    f0100e03 <debuginfo_eip+0x1b1>
                    lline = index - 1;
f0100dfb:	8d 50 ff             	lea    -0x1(%eax),%edx
f0100dfe:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                    break;
f0100e01:	eb 0f                	jmp    f0100e12 <debuginfo_eip+0x1c0>
        // Note that if lfun > rfun, lline, rline == lfile, rfile,
        // which means a file span search.
        // In this case, n_value is not in order!
        // Cannot use binary search, so just sequential search.
        int index;
        for (index = lline; index <= rline; ++index)
f0100e03:	83 c0 01             	add    $0x1,%eax
f0100e06:	83 c2 0c             	add    $0xc,%edx
f0100e09:	39 f8                	cmp    %edi,%eax
f0100e0b:	7e d9                	jle    f0100de6 <debuginfo_eip+0x194>
f0100e0d:	e9 7e 00 00 00       	jmp    f0100e90 <debuginfo_eip+0x23e>
                    lline = index - 1;
                    break;
                }
            }

        if (index > rline)
f0100e12:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0100e15:	7c 79                	jl     f0100e90 <debuginfo_eip+0x23e>
            return -1;
    }

    info->eip_line = stabs[lline].n_desc;
f0100e17:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100e1a:	6b c2 0c             	imul   $0xc,%edx,%eax
f0100e1d:	0f b7 88 56 23 10 f0 	movzwl -0xfefdcaa(%eax),%ecx
f0100e24:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0100e27:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100e2a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100e2d:	05 58 23 10 f0       	add    $0xf0102358,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e32:	eb 06                	jmp    f0100e3a <debuginfo_eip+0x1e8>
f0100e34:	83 ea 01             	sub    $0x1,%edx
f0100e37:	83 e8 0c             	sub    $0xc,%eax
f0100e3a:	89 d7                	mov    %edx,%edi
f0100e3c:	3b 55 c4             	cmp    -0x3c(%ebp),%edx
f0100e3f:	7c 1e                	jl     f0100e5f <debuginfo_eip+0x20d>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e41:	0f b6 70 fc          	movzbl -0x4(%eax),%esi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e45:	89 f1                	mov    %esi,%ecx
f0100e47:	80 f9 84             	cmp    $0x84,%cl
f0100e4a:	74 5d                	je     f0100ea9 <debuginfo_eip+0x257>
f0100e4c:	80 f9 64             	cmp    $0x64,%cl
f0100e4f:	75 e3                	jne    f0100e34 <debuginfo_eip+0x1e2>
f0100e51:	83 38 00             	cmpl   $0x0,(%eax)
f0100e54:	74 de                	je     f0100e34 <debuginfo_eip+0x1e2>
f0100e56:	eb 51                	jmp    f0100ea9 <debuginfo_eip+0x257>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e58:	05 0d 67 10 f0       	add    $0xf010670d,%eax
f0100e5d:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100e5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100e62:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100e65:	7d 30                	jge    f0100e97 <debuginfo_eip+0x245>
		for (lline = lfun + 1;
f0100e67:	83 c0 01             	add    $0x1,%eax
f0100e6a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e6d:	ba 50 23 10 f0       	mov    $0xf0102350,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100e72:	eb 08                	jmp    f0100e7c <debuginfo_eip+0x22a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100e74:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100e78:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e7c:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100e7f:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100e82:	7d 13                	jge    f0100e97 <debuginfo_eip+0x245>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e84:	6b c0 0c             	imul   $0xc,%eax,%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100e87:	80 7c 10 04 a0       	cmpb   $0xa0,0x4(%eax,%edx,1)
f0100e8c:	74 e6                	je     f0100e74 <debuginfo_eip+0x222>
f0100e8e:	eb 07                	jmp    f0100e97 <debuginfo_eip+0x245>
f0100e90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e95:	eb 05                	jmp    f0100e9c <debuginfo_eip+0x24a>
f0100e97:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0100e9c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100e9f:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100ea2:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100ea5:	89 ec                	mov    %ebp,%esp
f0100ea7:	5d                   	pop    %ebp
f0100ea8:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100ea9:	6b c7 0c             	imul   $0xc,%edi,%eax
f0100eac:	8b 80 50 23 10 f0    	mov    -0xfefdcb0(%eax),%eax
f0100eb2:	ba f6 83 10 f0       	mov    $0xf01083f6,%edx
f0100eb7:	81 ea 0d 67 10 f0    	sub    $0xf010670d,%edx
f0100ebd:	39 d0                	cmp    %edx,%eax
f0100ebf:	72 97                	jb     f0100e58 <debuginfo_eip+0x206>
f0100ec1:	eb 9c                	jmp    f0100e5f <debuginfo_eip+0x20d>
	...

f0100ec4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ec4:	55                   	push   %ebp
f0100ec5:	89 e5                	mov    %esp,%ebp
f0100ec7:	57                   	push   %edi
f0100ec8:	56                   	push   %esi
f0100ec9:	53                   	push   %ebx
f0100eca:	83 ec 4c             	sub    $0x4c,%esp
f0100ecd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100ed0:	89 d6                	mov    %edx,%esi
f0100ed2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ed5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100ed8:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100edb:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ede:	8b 45 10             	mov    0x10(%ebp),%eax
f0100ee1:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100ee4:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100ee7:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100eea:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100eef:	39 d1                	cmp    %edx,%ecx
f0100ef1:	72 07                	jb     f0100efa <printnum+0x36>
f0100ef3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100ef6:	39 d0                	cmp    %edx,%eax
f0100ef8:	77 69                	ja     f0100f63 <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100efa:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0100efe:	83 eb 01             	sub    $0x1,%ebx
f0100f01:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100f05:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f09:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0100f0d:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0100f11:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0100f14:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0100f17:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f1a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100f1e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100f25:	00 
f0100f26:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f29:	89 04 24             	mov    %eax,(%esp)
f0100f2c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100f2f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100f33:	e8 e8 09 00 00       	call   f0101920 <__udivdi3>
f0100f38:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100f3b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100f3e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100f42:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100f46:	89 04 24             	mov    %eax,(%esp)
f0100f49:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100f4d:	89 f2                	mov    %esi,%edx
f0100f4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f52:	e8 6d ff ff ff       	call   f0100ec4 <printnum>
f0100f57:	eb 11                	jmp    f0100f6a <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f59:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f5d:	89 3c 24             	mov    %edi,(%esp)
f0100f60:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100f63:	83 eb 01             	sub    $0x1,%ebx
f0100f66:	85 db                	test   %ebx,%ebx
f0100f68:	7f ef                	jg     f0100f59 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f6a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f6e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0100f72:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f75:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100f79:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100f80:	00 
f0100f81:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100f84:	89 14 24             	mov    %edx,(%esp)
f0100f87:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100f8a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100f8e:	e8 bd 0a 00 00       	call   f0101a50 <__umoddi3>
f0100f93:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f97:	0f be 80 25 21 10 f0 	movsbl -0xfefdedb(%eax),%eax
f0100f9e:	89 04 24             	mov    %eax,(%esp)
f0100fa1:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100fa4:	83 c4 4c             	add    $0x4c,%esp
f0100fa7:	5b                   	pop    %ebx
f0100fa8:	5e                   	pop    %esi
f0100fa9:	5f                   	pop    %edi
f0100faa:	5d                   	pop    %ebp
f0100fab:	c3                   	ret    

f0100fac <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100fac:	55                   	push   %ebp
f0100fad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100faf:	83 fa 01             	cmp    $0x1,%edx
f0100fb2:	7e 0e                	jle    f0100fc2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100fb4:	8b 10                	mov    (%eax),%edx
f0100fb6:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100fb9:	89 08                	mov    %ecx,(%eax)
f0100fbb:	8b 02                	mov    (%edx),%eax
f0100fbd:	8b 52 04             	mov    0x4(%edx),%edx
f0100fc0:	eb 22                	jmp    f0100fe4 <getuint+0x38>
	else if (lflag)
f0100fc2:	85 d2                	test   %edx,%edx
f0100fc4:	74 10                	je     f0100fd6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100fc6:	8b 10                	mov    (%eax),%edx
f0100fc8:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100fcb:	89 08                	mov    %ecx,(%eax)
f0100fcd:	8b 02                	mov    (%edx),%eax
f0100fcf:	ba 00 00 00 00       	mov    $0x0,%edx
f0100fd4:	eb 0e                	jmp    f0100fe4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100fd6:	8b 10                	mov    (%eax),%edx
f0100fd8:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100fdb:	89 08                	mov    %ecx,(%eax)
f0100fdd:	8b 02                	mov    (%edx),%eax
f0100fdf:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100fe4:	5d                   	pop    %ebp
f0100fe5:	c3                   	ret    

f0100fe6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100fe6:	55                   	push   %ebp
f0100fe7:	89 e5                	mov    %esp,%ebp
f0100fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100fec:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100ff0:	8b 10                	mov    (%eax),%edx
f0100ff2:	3b 50 04             	cmp    0x4(%eax),%edx
f0100ff5:	73 0a                	jae    f0101001 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100ff7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100ffa:	88 0a                	mov    %cl,(%edx)
f0100ffc:	83 c2 01             	add    $0x1,%edx
f0100fff:	89 10                	mov    %edx,(%eax)
}
f0101001:	5d                   	pop    %ebp
f0101002:	c3                   	ret    

f0101003 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0101003:	55                   	push   %ebp
f0101004:	89 e5                	mov    %esp,%ebp
f0101006:	57                   	push   %edi
f0101007:	56                   	push   %esi
f0101008:	53                   	push   %ebx
f0101009:	83 ec 4c             	sub    $0x4c,%esp
f010100c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010100f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101012:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0101015:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f010101c:	eb 11                	jmp    f010102f <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010101e:	85 c0                	test   %eax,%eax
f0101020:	0f 84 b6 03 00 00    	je     f01013dc <vprintfmt+0x3d9>
				return;
			putch(ch, putdat);
f0101026:	89 74 24 04          	mov    %esi,0x4(%esp)
f010102a:	89 04 24             	mov    %eax,(%esp)
f010102d:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010102f:	0f b6 03             	movzbl (%ebx),%eax
f0101032:	83 c3 01             	add    $0x1,%ebx
f0101035:	83 f8 25             	cmp    $0x25,%eax
f0101038:	75 e4                	jne    f010101e <vprintfmt+0x1b>
f010103a:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
f010103e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0101045:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f010104c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0101053:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101058:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f010105b:	eb 06                	jmp    f0101063 <vprintfmt+0x60>
f010105d:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
f0101061:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101063:	0f b6 0b             	movzbl (%ebx),%ecx
f0101066:	0f b6 c1             	movzbl %cl,%eax
f0101069:	8d 53 01             	lea    0x1(%ebx),%edx
f010106c:	83 e9 23             	sub    $0x23,%ecx
f010106f:	80 f9 55             	cmp    $0x55,%cl
f0101072:	0f 87 47 03 00 00    	ja     f01013bf <vprintfmt+0x3bc>
f0101078:	0f b6 c9             	movzbl %cl,%ecx
f010107b:	ff 24 8d c0 21 10 f0 	jmp    *-0xfefde40(,%ecx,4)
f0101082:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
f0101086:	eb d9                	jmp    f0101061 <vprintfmt+0x5e>
f0101088:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f010108f:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101094:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0101097:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f010109b:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
f010109e:	8d 58 d0             	lea    -0x30(%eax),%ebx
f01010a1:	83 fb 09             	cmp    $0x9,%ebx
f01010a4:	77 30                	ja     f01010d6 <vprintfmt+0xd3>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01010a6:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01010a9:	eb e9                	jmp    f0101094 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01010ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ae:	8d 48 04             	lea    0x4(%eax),%ecx
f01010b1:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01010b4:	8b 00                	mov    (%eax),%eax
f01010b6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
f01010b9:	eb 1e                	jmp    f01010d9 <vprintfmt+0xd6>

		case '.':
			if (width < 0)
f01010bb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01010bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01010c4:	0f 49 45 e4          	cmovns -0x1c(%ebp),%eax
f01010c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010cb:	eb 94                	jmp    f0101061 <vprintfmt+0x5e>
f01010cd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f01010d4:	eb 8b                	jmp    f0101061 <vprintfmt+0x5e>
f01010d6:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
f01010d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01010dd:	79 82                	jns    f0101061 <vprintfmt+0x5e>
f01010df:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01010e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010e5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01010e8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f01010eb:	e9 71 ff ff ff       	jmp    f0101061 <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01010f0:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01010f4:	e9 68 ff ff ff       	jmp    f0101061 <vprintfmt+0x5e>
f01010f9:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01010fc:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ff:	8d 50 04             	lea    0x4(%eax),%edx
f0101102:	89 55 14             	mov    %edx,0x14(%ebp)
f0101105:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101109:	8b 00                	mov    (%eax),%eax
f010110b:	89 04 24             	mov    %eax,(%esp)
f010110e:	ff d7                	call   *%edi
f0101110:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f0101113:	e9 17 ff ff ff       	jmp    f010102f <vprintfmt+0x2c>
f0101118:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f010111b:	8b 45 14             	mov    0x14(%ebp),%eax
f010111e:	8d 50 04             	lea    0x4(%eax),%edx
f0101121:	89 55 14             	mov    %edx,0x14(%ebp)
f0101124:	8b 00                	mov    (%eax),%eax
f0101126:	89 c2                	mov    %eax,%edx
f0101128:	c1 fa 1f             	sar    $0x1f,%edx
f010112b:	31 d0                	xor    %edx,%eax
f010112d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010112f:	83 f8 07             	cmp    $0x7,%eax
f0101132:	7f 0b                	jg     f010113f <vprintfmt+0x13c>
f0101134:	8b 14 85 20 23 10 f0 	mov    -0xfefdce0(,%eax,4),%edx
f010113b:	85 d2                	test   %edx,%edx
f010113d:	75 20                	jne    f010115f <vprintfmt+0x15c>
				printfmt(putch, putdat, "error %d", err);
f010113f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101143:	c7 44 24 08 36 21 10 	movl   $0xf0102136,0x8(%esp)
f010114a:	f0 
f010114b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010114f:	89 3c 24             	mov    %edi,(%esp)
f0101152:	e8 0d 03 00 00       	call   f0101464 <printfmt>
f0101157:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010115a:	e9 d0 fe ff ff       	jmp    f010102f <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f010115f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101163:	c7 44 24 08 3f 21 10 	movl   $0xf010213f,0x8(%esp)
f010116a:	f0 
f010116b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010116f:	89 3c 24             	mov    %edi,(%esp)
f0101172:	e8 ed 02 00 00       	call   f0101464 <printfmt>
f0101177:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010117a:	e9 b0 fe ff ff       	jmp    f010102f <vprintfmt+0x2c>
f010117f:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0101182:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101185:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101188:	89 45 d4             	mov    %eax,-0x2c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010118b:	8b 45 14             	mov    0x14(%ebp),%eax
f010118e:	8d 50 04             	lea    0x4(%eax),%edx
f0101191:	89 55 14             	mov    %edx,0x14(%ebp)
f0101194:	8b 18                	mov    (%eax),%ebx
f0101196:	85 db                	test   %ebx,%ebx
f0101198:	b8 42 21 10 f0       	mov    $0xf0102142,%eax
f010119d:	0f 44 d8             	cmove  %eax,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
f01011a0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01011a4:	7e 76                	jle    f010121c <vprintfmt+0x219>
f01011a6:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
f01011aa:	74 7a                	je     f0101226 <vprintfmt+0x223>
				for (width -= strnlen(p, precision); width > 0; width--)
f01011ac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01011b0:	89 1c 24             	mov    %ebx,(%esp)
f01011b3:	e8 c0 03 00 00       	call   f0101578 <strnlen>
f01011b8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01011bb:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
f01011bd:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
f01011c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01011c4:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01011c7:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01011c9:	eb 0f                	jmp    f01011da <vprintfmt+0x1d7>
					putch(padc, putdat);
f01011cb:	89 74 24 04          	mov    %esi,0x4(%esp)
f01011cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011d2:	89 04 24             	mov    %eax,(%esp)
f01011d5:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01011d7:	83 eb 01             	sub    $0x1,%ebx
f01011da:	85 db                	test   %ebx,%ebx
f01011dc:	7f ed                	jg     f01011cb <vprintfmt+0x1c8>
f01011de:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01011e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01011e4:	89 7d e0             	mov    %edi,-0x20(%ebp)
f01011e7:	89 f7                	mov    %esi,%edi
f01011e9:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01011ec:	eb 40                	jmp    f010122e <vprintfmt+0x22b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01011ee:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01011f2:	74 18                	je     f010120c <vprintfmt+0x209>
f01011f4:	8d 50 e0             	lea    -0x20(%eax),%edx
f01011f7:	83 fa 5e             	cmp    $0x5e,%edx
f01011fa:	76 10                	jbe    f010120c <vprintfmt+0x209>
					putch('?', putdat);
f01011fc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101200:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0101207:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010120a:	eb 0a                	jmp    f0101216 <vprintfmt+0x213>
					putch('?', putdat);
				else
					putch(ch, putdat);
f010120c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101210:	89 04 24             	mov    %eax,(%esp)
f0101213:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101216:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f010121a:	eb 12                	jmp    f010122e <vprintfmt+0x22b>
f010121c:	89 7d e0             	mov    %edi,-0x20(%ebp)
f010121f:	89 f7                	mov    %esi,%edi
f0101221:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101224:	eb 08                	jmp    f010122e <vprintfmt+0x22b>
f0101226:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0101229:	89 f7                	mov    %esi,%edi
f010122b:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010122e:	0f be 03             	movsbl (%ebx),%eax
f0101231:	83 c3 01             	add    $0x1,%ebx
f0101234:	85 c0                	test   %eax,%eax
f0101236:	74 25                	je     f010125d <vprintfmt+0x25a>
f0101238:	85 f6                	test   %esi,%esi
f010123a:	78 b2                	js     f01011ee <vprintfmt+0x1eb>
f010123c:	83 ee 01             	sub    $0x1,%esi
f010123f:	79 ad                	jns    f01011ee <vprintfmt+0x1eb>
f0101241:	89 fe                	mov    %edi,%esi
f0101243:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101246:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101249:	eb 1a                	jmp    f0101265 <vprintfmt+0x262>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010124b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010124f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101256:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101258:	83 eb 01             	sub    $0x1,%ebx
f010125b:	eb 08                	jmp    f0101265 <vprintfmt+0x262>
f010125d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101260:	89 fe                	mov    %edi,%esi
f0101262:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101265:	85 db                	test   %ebx,%ebx
f0101267:	7f e2                	jg     f010124b <vprintfmt+0x248>
f0101269:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010126c:	e9 be fd ff ff       	jmp    f010102f <vprintfmt+0x2c>
f0101271:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0101274:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101277:	83 f9 01             	cmp    $0x1,%ecx
f010127a:	7e 16                	jle    f0101292 <vprintfmt+0x28f>
		return va_arg(*ap, long long);
f010127c:	8b 45 14             	mov    0x14(%ebp),%eax
f010127f:	8d 50 08             	lea    0x8(%eax),%edx
f0101282:	89 55 14             	mov    %edx,0x14(%ebp)
f0101285:	8b 10                	mov    (%eax),%edx
f0101287:	8b 48 04             	mov    0x4(%eax),%ecx
f010128a:	89 55 d8             	mov    %edx,-0x28(%ebp)
f010128d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101290:	eb 32                	jmp    f01012c4 <vprintfmt+0x2c1>
	else if (lflag)
f0101292:	85 c9                	test   %ecx,%ecx
f0101294:	74 18                	je     f01012ae <vprintfmt+0x2ab>
		return va_arg(*ap, long);
f0101296:	8b 45 14             	mov    0x14(%ebp),%eax
f0101299:	8d 50 04             	lea    0x4(%eax),%edx
f010129c:	89 55 14             	mov    %edx,0x14(%ebp)
f010129f:	8b 00                	mov    (%eax),%eax
f01012a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012a4:	89 c1                	mov    %eax,%ecx
f01012a6:	c1 f9 1f             	sar    $0x1f,%ecx
f01012a9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01012ac:	eb 16                	jmp    f01012c4 <vprintfmt+0x2c1>
	else
		return va_arg(*ap, int);
f01012ae:	8b 45 14             	mov    0x14(%ebp),%eax
f01012b1:	8d 50 04             	lea    0x4(%eax),%edx
f01012b4:	89 55 14             	mov    %edx,0x14(%ebp)
f01012b7:	8b 00                	mov    (%eax),%eax
f01012b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012bc:	89 c2                	mov    %eax,%edx
f01012be:	c1 fa 1f             	sar    $0x1f,%edx
f01012c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01012c4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01012c7:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01012ca:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01012cf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01012d3:	0f 89 a7 00 00 00    	jns    f0101380 <vprintfmt+0x37d>
				putch('-', putdat);
f01012d9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01012dd:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01012e4:	ff d7                	call   *%edi
				num = -(long long) num;
f01012e6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01012e9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01012ec:	f7 d9                	neg    %ecx
f01012ee:	83 d3 00             	adc    $0x0,%ebx
f01012f1:	f7 db                	neg    %ebx
f01012f3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012f8:	e9 83 00 00 00       	jmp    f0101380 <vprintfmt+0x37d>
f01012fd:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0101300:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101303:	89 ca                	mov    %ecx,%edx
f0101305:	8d 45 14             	lea    0x14(%ebp),%eax
f0101308:	e8 9f fc ff ff       	call   f0100fac <getuint>
f010130d:	89 c1                	mov    %eax,%ecx
f010130f:	89 d3                	mov    %edx,%ebx
f0101311:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0101316:	eb 68                	jmp    f0101380 <vprintfmt+0x37d>
f0101318:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010131b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			// break;
            num = getuint(&ap, lflag);
f010131e:	89 ca                	mov    %ecx,%edx
f0101320:	8d 45 14             	lea    0x14(%ebp),%eax
f0101323:	e8 84 fc ff ff       	call   f0100fac <getuint>
f0101328:	89 c1                	mov    %eax,%ecx
f010132a:	89 d3                	mov    %edx,%ebx
f010132c:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
		    goto number;
f0101331:	eb 4d                	jmp    f0101380 <vprintfmt+0x37d>
f0101333:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0101336:	89 74 24 04          	mov    %esi,0x4(%esp)
f010133a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101341:	ff d7                	call   *%edi
			putch('x', putdat);
f0101343:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101347:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010134e:	ff d7                	call   *%edi
			num = (unsigned long long)
f0101350:	8b 45 14             	mov    0x14(%ebp),%eax
f0101353:	8d 50 04             	lea    0x4(%eax),%edx
f0101356:	89 55 14             	mov    %edx,0x14(%ebp)
f0101359:	8b 08                	mov    (%eax),%ecx
f010135b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101360:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101365:	eb 19                	jmp    f0101380 <vprintfmt+0x37d>
f0101367:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010136a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010136d:	89 ca                	mov    %ecx,%edx
f010136f:	8d 45 14             	lea    0x14(%ebp),%eax
f0101372:	e8 35 fc ff ff       	call   f0100fac <getuint>
f0101377:	89 c1                	mov    %eax,%ecx
f0101379:	89 d3                	mov    %edx,%ebx
f010137b:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101380:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
f0101384:	89 54 24 10          	mov    %edx,0x10(%esp)
f0101388:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010138b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010138f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101393:	89 0c 24             	mov    %ecx,(%esp)
f0101396:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010139a:	89 f2                	mov    %esi,%edx
f010139c:	89 f8                	mov    %edi,%eax
f010139e:	e8 21 fb ff ff       	call   f0100ec4 <printnum>
f01013a3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f01013a6:	e9 84 fc ff ff       	jmp    f010102f <vprintfmt+0x2c>
f01013ab:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01013ae:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013b2:	89 04 24             	mov    %eax,(%esp)
f01013b5:	ff d7                	call   *%edi
f01013b7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f01013ba:	e9 70 fc ff ff       	jmp    f010102f <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01013bf:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013c3:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01013ca:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01013cc:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01013cf:	80 38 25             	cmpb   $0x25,(%eax)
f01013d2:	0f 84 57 fc ff ff    	je     f010102f <vprintfmt+0x2c>
f01013d8:	89 c3                	mov    %eax,%ebx
f01013da:	eb f0                	jmp    f01013cc <vprintfmt+0x3c9>
				/* do nothing */;
			break;
		}
	}
}
f01013dc:	83 c4 4c             	add    $0x4c,%esp
f01013df:	5b                   	pop    %ebx
f01013e0:	5e                   	pop    %esi
f01013e1:	5f                   	pop    %edi
f01013e2:	5d                   	pop    %ebp
f01013e3:	c3                   	ret    

f01013e4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01013e4:	55                   	push   %ebp
f01013e5:	89 e5                	mov    %esp,%ebp
f01013e7:	83 ec 28             	sub    $0x28,%esp
f01013ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01013ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f01013f0:	85 c0                	test   %eax,%eax
f01013f2:	74 04                	je     f01013f8 <vsnprintf+0x14>
f01013f4:	85 d2                	test   %edx,%edx
f01013f6:	7f 07                	jg     f01013ff <vsnprintf+0x1b>
f01013f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01013fd:	eb 3b                	jmp    f010143a <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f01013ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101402:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0101406:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101409:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101410:	8b 45 14             	mov    0x14(%ebp),%eax
f0101413:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101417:	8b 45 10             	mov    0x10(%ebp),%eax
f010141a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010141e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101421:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101425:	c7 04 24 e6 0f 10 f0 	movl   $0xf0100fe6,(%esp)
f010142c:	e8 d2 fb ff ff       	call   f0101003 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101431:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101434:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101437:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f010143a:	c9                   	leave  
f010143b:	c3                   	ret    

f010143c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010143c:	55                   	push   %ebp
f010143d:	89 e5                	mov    %esp,%ebp
f010143f:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f0101442:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0101445:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101449:	8b 45 10             	mov    0x10(%ebp),%eax
f010144c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101450:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101453:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101457:	8b 45 08             	mov    0x8(%ebp),%eax
f010145a:	89 04 24             	mov    %eax,(%esp)
f010145d:	e8 82 ff ff ff       	call   f01013e4 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101462:	c9                   	leave  
f0101463:	c3                   	ret    

f0101464 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101464:	55                   	push   %ebp
f0101465:	89 e5                	mov    %esp,%ebp
f0101467:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f010146a:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f010146d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101471:	8b 45 10             	mov    0x10(%ebp),%eax
f0101474:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101478:	8b 45 0c             	mov    0xc(%ebp),%eax
f010147b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010147f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101482:	89 04 24             	mov    %eax,(%esp)
f0101485:	e8 79 fb ff ff       	call   f0101003 <vprintfmt>
	va_end(ap);
}
f010148a:	c9                   	leave  
f010148b:	c3                   	ret    
f010148c:	00 00                	add    %al,(%eax)
	...

f0101490 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101490:	55                   	push   %ebp
f0101491:	89 e5                	mov    %esp,%ebp
f0101493:	57                   	push   %edi
f0101494:	56                   	push   %esi
f0101495:	53                   	push   %ebx
f0101496:	83 ec 1c             	sub    $0x1c,%esp
f0101499:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010149c:	85 c0                	test   %eax,%eax
f010149e:	74 10                	je     f01014b0 <readline+0x20>
		cprintf("%s", prompt);
f01014a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014a4:	c7 04 24 3f 21 10 f0 	movl   $0xf010213f,(%esp)
f01014ab:	e8 6f f6 ff ff       	call   f0100b1f <cprintf>

	i = 0;
	echoing = iscons(0);
f01014b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014b7:	e8 74 ed ff ff       	call   f0100230 <iscons>
f01014bc:	89 c7                	mov    %eax,%edi
f01014be:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f01014c3:	e8 57 ed ff ff       	call   f010021f <getchar>
f01014c8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01014ca:	85 c0                	test   %eax,%eax
f01014cc:	79 17                	jns    f01014e5 <readline+0x55>
			cprintf("read error: %e\n", c);
f01014ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014d2:	c7 04 24 40 23 10 f0 	movl   $0xf0102340,(%esp)
f01014d9:	e8 41 f6 ff ff       	call   f0100b1f <cprintf>
f01014de:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f01014e3:	eb 6d                	jmp    f0101552 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01014e5:	83 f8 08             	cmp    $0x8,%eax
f01014e8:	74 05                	je     f01014ef <readline+0x5f>
f01014ea:	83 f8 7f             	cmp    $0x7f,%eax
f01014ed:	75 19                	jne    f0101508 <readline+0x78>
f01014ef:	85 f6                	test   %esi,%esi
f01014f1:	7e 15                	jle    f0101508 <readline+0x78>
			if (echoing)
f01014f3:	85 ff                	test   %edi,%edi
f01014f5:	74 0c                	je     f0101503 <readline+0x73>
				cputchar('\b');
f01014f7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01014fe:	e8 1f ef ff ff       	call   f0100422 <cputchar>
			i--;
f0101503:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101506:	eb bb                	jmp    f01014c3 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101508:	83 fb 1f             	cmp    $0x1f,%ebx
f010150b:	7e 1f                	jle    f010152c <readline+0x9c>
f010150d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101513:	7f 17                	jg     f010152c <readline+0x9c>
			if (echoing)
f0101515:	85 ff                	test   %edi,%edi
f0101517:	74 08                	je     f0101521 <readline+0x91>
				cputchar(c);
f0101519:	89 1c 24             	mov    %ebx,(%esp)
f010151c:	e8 01 ef ff ff       	call   f0100422 <cputchar>
			buf[i++] = c;
f0101521:	88 9e 40 35 11 f0    	mov    %bl,-0xfeecac0(%esi)
f0101527:	83 c6 01             	add    $0x1,%esi
f010152a:	eb 97                	jmp    f01014c3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010152c:	83 fb 0a             	cmp    $0xa,%ebx
f010152f:	74 05                	je     f0101536 <readline+0xa6>
f0101531:	83 fb 0d             	cmp    $0xd,%ebx
f0101534:	75 8d                	jne    f01014c3 <readline+0x33>
			if (echoing)
f0101536:	85 ff                	test   %edi,%edi
f0101538:	74 0c                	je     f0101546 <readline+0xb6>
				cputchar('\n');
f010153a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0101541:	e8 dc ee ff ff       	call   f0100422 <cputchar>
			buf[i] = 0;
f0101546:	c6 86 40 35 11 f0 00 	movb   $0x0,-0xfeecac0(%esi)
f010154d:	b8 40 35 11 f0       	mov    $0xf0113540,%eax
			return buf;
		}
	}
}
f0101552:	83 c4 1c             	add    $0x1c,%esp
f0101555:	5b                   	pop    %ebx
f0101556:	5e                   	pop    %esi
f0101557:	5f                   	pop    %edi
f0101558:	5d                   	pop    %ebp
f0101559:	c3                   	ret    
f010155a:	00 00                	add    %al,(%eax)
f010155c:	00 00                	add    %al,(%eax)
	...

f0101560 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101560:	55                   	push   %ebp
f0101561:	89 e5                	mov    %esp,%ebp
f0101563:	8b 55 08             	mov    0x8(%ebp),%edx
f0101566:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
f010156b:	eb 03                	jmp    f0101570 <strlen+0x10>
		n++;
f010156d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101570:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101574:	75 f7                	jne    f010156d <strlen+0xd>
		n++;
	return n;
}
f0101576:	5d                   	pop    %ebp
f0101577:	c3                   	ret    

f0101578 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101578:	55                   	push   %ebp
f0101579:	89 e5                	mov    %esp,%ebp
f010157b:	53                   	push   %ebx
f010157c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010157f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101582:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101587:	eb 03                	jmp    f010158c <strnlen+0x14>
		n++;
f0101589:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010158c:	39 c1                	cmp    %eax,%ecx
f010158e:	74 06                	je     f0101596 <strnlen+0x1e>
f0101590:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f0101594:	75 f3                	jne    f0101589 <strnlen+0x11>
		n++;
	return n;
}
f0101596:	5b                   	pop    %ebx
f0101597:	5d                   	pop    %ebp
f0101598:	c3                   	ret    

f0101599 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101599:	55                   	push   %ebp
f010159a:	89 e5                	mov    %esp,%ebp
f010159c:	53                   	push   %ebx
f010159d:	8b 45 08             	mov    0x8(%ebp),%eax
f01015a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01015a3:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01015a8:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01015ac:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01015af:	83 c2 01             	add    $0x1,%edx
f01015b2:	84 c9                	test   %cl,%cl
f01015b4:	75 f2                	jne    f01015a8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01015b6:	5b                   	pop    %ebx
f01015b7:	5d                   	pop    %ebp
f01015b8:	c3                   	ret    

f01015b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01015b9:	55                   	push   %ebp
f01015ba:	89 e5                	mov    %esp,%ebp
f01015bc:	53                   	push   %ebx
f01015bd:	83 ec 08             	sub    $0x8,%esp
f01015c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01015c3:	89 1c 24             	mov    %ebx,(%esp)
f01015c6:	e8 95 ff ff ff       	call   f0101560 <strlen>
	strcpy(dst + len, src);
f01015cb:	8b 55 0c             	mov    0xc(%ebp),%edx
f01015ce:	89 54 24 04          	mov    %edx,0x4(%esp)
f01015d2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f01015d5:	89 04 24             	mov    %eax,(%esp)
f01015d8:	e8 bc ff ff ff       	call   f0101599 <strcpy>
	return dst;
}
f01015dd:	89 d8                	mov    %ebx,%eax
f01015df:	83 c4 08             	add    $0x8,%esp
f01015e2:	5b                   	pop    %ebx
f01015e3:	5d                   	pop    %ebp
f01015e4:	c3                   	ret    

f01015e5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01015e5:	55                   	push   %ebp
f01015e6:	89 e5                	mov    %esp,%ebp
f01015e8:	56                   	push   %esi
f01015e9:	53                   	push   %ebx
f01015ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01015ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01015f0:	8b 75 10             	mov    0x10(%ebp),%esi
f01015f3:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01015f8:	eb 0f                	jmp    f0101609 <strncpy+0x24>
		*dst++ = *src;
f01015fa:	0f b6 19             	movzbl (%ecx),%ebx
f01015fd:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101600:	80 39 01             	cmpb   $0x1,(%ecx)
f0101603:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101606:	83 c2 01             	add    $0x1,%edx
f0101609:	39 f2                	cmp    %esi,%edx
f010160b:	72 ed                	jb     f01015fa <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010160d:	5b                   	pop    %ebx
f010160e:	5e                   	pop    %esi
f010160f:	5d                   	pop    %ebp
f0101610:	c3                   	ret    

f0101611 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101611:	55                   	push   %ebp
f0101612:	89 e5                	mov    %esp,%ebp
f0101614:	56                   	push   %esi
f0101615:	53                   	push   %ebx
f0101616:	8b 75 08             	mov    0x8(%ebp),%esi
f0101619:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010161c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010161f:	89 f0                	mov    %esi,%eax
f0101621:	85 d2                	test   %edx,%edx
f0101623:	75 0a                	jne    f010162f <strlcpy+0x1e>
f0101625:	eb 17                	jmp    f010163e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101627:	88 18                	mov    %bl,(%eax)
f0101629:	83 c0 01             	add    $0x1,%eax
f010162c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010162f:	83 ea 01             	sub    $0x1,%edx
f0101632:	74 07                	je     f010163b <strlcpy+0x2a>
f0101634:	0f b6 19             	movzbl (%ecx),%ebx
f0101637:	84 db                	test   %bl,%bl
f0101639:	75 ec                	jne    f0101627 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
f010163b:	c6 00 00             	movb   $0x0,(%eax)
f010163e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0101640:	5b                   	pop    %ebx
f0101641:	5e                   	pop    %esi
f0101642:	5d                   	pop    %ebp
f0101643:	c3                   	ret    

f0101644 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101644:	55                   	push   %ebp
f0101645:	89 e5                	mov    %esp,%ebp
f0101647:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010164a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010164d:	eb 06                	jmp    f0101655 <strcmp+0x11>
		p++, q++;
f010164f:	83 c1 01             	add    $0x1,%ecx
f0101652:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101655:	0f b6 01             	movzbl (%ecx),%eax
f0101658:	84 c0                	test   %al,%al
f010165a:	74 04                	je     f0101660 <strcmp+0x1c>
f010165c:	3a 02                	cmp    (%edx),%al
f010165e:	74 ef                	je     f010164f <strcmp+0xb>
f0101660:	0f b6 c0             	movzbl %al,%eax
f0101663:	0f b6 12             	movzbl (%edx),%edx
f0101666:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101668:	5d                   	pop    %ebp
f0101669:	c3                   	ret    

f010166a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010166a:	55                   	push   %ebp
f010166b:	89 e5                	mov    %esp,%ebp
f010166d:	53                   	push   %ebx
f010166e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101671:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101674:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0101677:	eb 09                	jmp    f0101682 <strncmp+0x18>
		n--, p++, q++;
f0101679:	83 ea 01             	sub    $0x1,%edx
f010167c:	83 c0 01             	add    $0x1,%eax
f010167f:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101682:	85 d2                	test   %edx,%edx
f0101684:	75 07                	jne    f010168d <strncmp+0x23>
f0101686:	b8 00 00 00 00       	mov    $0x0,%eax
f010168b:	eb 13                	jmp    f01016a0 <strncmp+0x36>
f010168d:	0f b6 18             	movzbl (%eax),%ebx
f0101690:	84 db                	test   %bl,%bl
f0101692:	74 04                	je     f0101698 <strncmp+0x2e>
f0101694:	3a 19                	cmp    (%ecx),%bl
f0101696:	74 e1                	je     f0101679 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101698:	0f b6 00             	movzbl (%eax),%eax
f010169b:	0f b6 11             	movzbl (%ecx),%edx
f010169e:	29 d0                	sub    %edx,%eax
}
f01016a0:	5b                   	pop    %ebx
f01016a1:	5d                   	pop    %ebp
f01016a2:	c3                   	ret    

f01016a3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01016a3:	55                   	push   %ebp
f01016a4:	89 e5                	mov    %esp,%ebp
f01016a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01016a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016ad:	eb 07                	jmp    f01016b6 <strchr+0x13>
		if (*s == c)
f01016af:	38 ca                	cmp    %cl,%dl
f01016b1:	74 0f                	je     f01016c2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01016b3:	83 c0 01             	add    $0x1,%eax
f01016b6:	0f b6 10             	movzbl (%eax),%edx
f01016b9:	84 d2                	test   %dl,%dl
f01016bb:	75 f2                	jne    f01016af <strchr+0xc>
f01016bd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f01016c2:	5d                   	pop    %ebp
f01016c3:	c3                   	ret    

f01016c4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01016c4:	55                   	push   %ebp
f01016c5:	89 e5                	mov    %esp,%ebp
f01016c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01016ca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016ce:	eb 07                	jmp    f01016d7 <strfind+0x13>
		if (*s == c)
f01016d0:	38 ca                	cmp    %cl,%dl
f01016d2:	74 0a                	je     f01016de <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01016d4:	83 c0 01             	add    $0x1,%eax
f01016d7:	0f b6 10             	movzbl (%eax),%edx
f01016da:	84 d2                	test   %dl,%dl
f01016dc:	75 f2                	jne    f01016d0 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f01016de:	5d                   	pop    %ebp
f01016df:	c3                   	ret    

f01016e0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01016e0:	55                   	push   %ebp
f01016e1:	89 e5                	mov    %esp,%ebp
f01016e3:	83 ec 0c             	sub    $0xc,%esp
f01016e6:	89 1c 24             	mov    %ebx,(%esp)
f01016e9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01016ed:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01016f1:	8b 7d 08             	mov    0x8(%ebp),%edi
f01016f4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01016fa:	85 c9                	test   %ecx,%ecx
f01016fc:	74 30                	je     f010172e <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01016fe:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101704:	75 25                	jne    f010172b <memset+0x4b>
f0101706:	f6 c1 03             	test   $0x3,%cl
f0101709:	75 20                	jne    f010172b <memset+0x4b>
		c &= 0xFF;
f010170b:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010170e:	89 d3                	mov    %edx,%ebx
f0101710:	c1 e3 08             	shl    $0x8,%ebx
f0101713:	89 d6                	mov    %edx,%esi
f0101715:	c1 e6 18             	shl    $0x18,%esi
f0101718:	89 d0                	mov    %edx,%eax
f010171a:	c1 e0 10             	shl    $0x10,%eax
f010171d:	09 f0                	or     %esi,%eax
f010171f:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0101721:	09 d8                	or     %ebx,%eax
f0101723:	c1 e9 02             	shr    $0x2,%ecx
f0101726:	fc                   	cld    
f0101727:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101729:	eb 03                	jmp    f010172e <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010172b:	fc                   	cld    
f010172c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010172e:	89 f8                	mov    %edi,%eax
f0101730:	8b 1c 24             	mov    (%esp),%ebx
f0101733:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101737:	8b 7c 24 08          	mov    0x8(%esp),%edi
f010173b:	89 ec                	mov    %ebp,%esp
f010173d:	5d                   	pop    %ebp
f010173e:	c3                   	ret    

f010173f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010173f:	55                   	push   %ebp
f0101740:	89 e5                	mov    %esp,%ebp
f0101742:	83 ec 08             	sub    $0x8,%esp
f0101745:	89 34 24             	mov    %esi,(%esp)
f0101748:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010174c:	8b 45 08             	mov    0x8(%ebp),%eax
f010174f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
f0101752:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f0101755:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f0101757:	39 c6                	cmp    %eax,%esi
f0101759:	73 35                	jae    f0101790 <memmove+0x51>
f010175b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010175e:	39 d0                	cmp    %edx,%eax
f0101760:	73 2e                	jae    f0101790 <memmove+0x51>
		s += n;
		d += n;
f0101762:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101764:	f6 c2 03             	test   $0x3,%dl
f0101767:	75 1b                	jne    f0101784 <memmove+0x45>
f0101769:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010176f:	75 13                	jne    f0101784 <memmove+0x45>
f0101771:	f6 c1 03             	test   $0x3,%cl
f0101774:	75 0e                	jne    f0101784 <memmove+0x45>
			asm volatile("std; rep movsl\n"
f0101776:	83 ef 04             	sub    $0x4,%edi
f0101779:	8d 72 fc             	lea    -0x4(%edx),%esi
f010177c:	c1 e9 02             	shr    $0x2,%ecx
f010177f:	fd                   	std    
f0101780:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101782:	eb 09                	jmp    f010178d <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101784:	83 ef 01             	sub    $0x1,%edi
f0101787:	8d 72 ff             	lea    -0x1(%edx),%esi
f010178a:	fd                   	std    
f010178b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010178d:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010178e:	eb 20                	jmp    f01017b0 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101790:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101796:	75 15                	jne    f01017ad <memmove+0x6e>
f0101798:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010179e:	75 0d                	jne    f01017ad <memmove+0x6e>
f01017a0:	f6 c1 03             	test   $0x3,%cl
f01017a3:	75 08                	jne    f01017ad <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f01017a5:	c1 e9 02             	shr    $0x2,%ecx
f01017a8:	fc                   	cld    
f01017a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017ab:	eb 03                	jmp    f01017b0 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01017ad:	fc                   	cld    
f01017ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01017b0:	8b 34 24             	mov    (%esp),%esi
f01017b3:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01017b7:	89 ec                	mov    %ebp,%esp
f01017b9:	5d                   	pop    %ebp
f01017ba:	c3                   	ret    

f01017bb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01017bb:	55                   	push   %ebp
f01017bc:	89 e5                	mov    %esp,%ebp
f01017be:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01017c1:	8b 45 10             	mov    0x10(%ebp),%eax
f01017c4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01017c8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01017cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01017d2:	89 04 24             	mov    %eax,(%esp)
f01017d5:	e8 65 ff ff ff       	call   f010173f <memmove>
}
f01017da:	c9                   	leave  
f01017db:	c3                   	ret    

f01017dc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01017dc:	55                   	push   %ebp
f01017dd:	89 e5                	mov    %esp,%ebp
f01017df:	57                   	push   %edi
f01017e0:	56                   	push   %esi
f01017e1:	53                   	push   %ebx
f01017e2:	8b 7d 08             	mov    0x8(%ebp),%edi
f01017e5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01017eb:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01017f0:	eb 1c                	jmp    f010180e <memcmp+0x32>
		if (*s1 != *s2)
f01017f2:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
f01017f6:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
f01017fa:	83 c2 01             	add    $0x1,%edx
f01017fd:	83 e9 01             	sub    $0x1,%ecx
f0101800:	38 d8                	cmp    %bl,%al
f0101802:	74 0a                	je     f010180e <memcmp+0x32>
			return (int) *s1 - (int) *s2;
f0101804:	0f b6 c0             	movzbl %al,%eax
f0101807:	0f b6 db             	movzbl %bl,%ebx
f010180a:	29 d8                	sub    %ebx,%eax
f010180c:	eb 09                	jmp    f0101817 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010180e:	85 c9                	test   %ecx,%ecx
f0101810:	75 e0                	jne    f01017f2 <memcmp+0x16>
f0101812:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0101817:	5b                   	pop    %ebx
f0101818:	5e                   	pop    %esi
f0101819:	5f                   	pop    %edi
f010181a:	5d                   	pop    %ebp
f010181b:	c3                   	ret    

f010181c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010181c:	55                   	push   %ebp
f010181d:	89 e5                	mov    %esp,%ebp
f010181f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101825:	89 c2                	mov    %eax,%edx
f0101827:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010182a:	eb 07                	jmp    f0101833 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f010182c:	38 08                	cmp    %cl,(%eax)
f010182e:	74 07                	je     f0101837 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101830:	83 c0 01             	add    $0x1,%eax
f0101833:	39 d0                	cmp    %edx,%eax
f0101835:	72 f5                	jb     f010182c <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101837:	5d                   	pop    %ebp
f0101838:	c3                   	ret    

f0101839 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101839:	55                   	push   %ebp
f010183a:	89 e5                	mov    %esp,%ebp
f010183c:	57                   	push   %edi
f010183d:	56                   	push   %esi
f010183e:	53                   	push   %ebx
f010183f:	83 ec 04             	sub    $0x4,%esp
f0101842:	8b 55 08             	mov    0x8(%ebp),%edx
f0101845:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101848:	eb 03                	jmp    f010184d <strtol+0x14>
		s++;
f010184a:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010184d:	0f b6 02             	movzbl (%edx),%eax
f0101850:	3c 20                	cmp    $0x20,%al
f0101852:	74 f6                	je     f010184a <strtol+0x11>
f0101854:	3c 09                	cmp    $0x9,%al
f0101856:	74 f2                	je     f010184a <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101858:	3c 2b                	cmp    $0x2b,%al
f010185a:	75 0c                	jne    f0101868 <strtol+0x2f>
		s++;
f010185c:	8d 52 01             	lea    0x1(%edx),%edx
f010185f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0101866:	eb 15                	jmp    f010187d <strtol+0x44>
	else if (*s == '-')
f0101868:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010186f:	3c 2d                	cmp    $0x2d,%al
f0101871:	75 0a                	jne    f010187d <strtol+0x44>
		s++, neg = 1;
f0101873:	8d 52 01             	lea    0x1(%edx),%edx
f0101876:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010187d:	85 db                	test   %ebx,%ebx
f010187f:	0f 94 c0             	sete   %al
f0101882:	74 05                	je     f0101889 <strtol+0x50>
f0101884:	83 fb 10             	cmp    $0x10,%ebx
f0101887:	75 15                	jne    f010189e <strtol+0x65>
f0101889:	80 3a 30             	cmpb   $0x30,(%edx)
f010188c:	75 10                	jne    f010189e <strtol+0x65>
f010188e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101892:	75 0a                	jne    f010189e <strtol+0x65>
		s += 2, base = 16;
f0101894:	83 c2 02             	add    $0x2,%edx
f0101897:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010189c:	eb 13                	jmp    f01018b1 <strtol+0x78>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010189e:	84 c0                	test   %al,%al
f01018a0:	74 0f                	je     f01018b1 <strtol+0x78>
f01018a2:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01018a7:	80 3a 30             	cmpb   $0x30,(%edx)
f01018aa:	75 05                	jne    f01018b1 <strtol+0x78>
		s++, base = 8;
f01018ac:	83 c2 01             	add    $0x1,%edx
f01018af:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01018b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01018b6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01018b8:	0f b6 0a             	movzbl (%edx),%ecx
f01018bb:	89 cf                	mov    %ecx,%edi
f01018bd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01018c0:	80 fb 09             	cmp    $0x9,%bl
f01018c3:	77 08                	ja     f01018cd <strtol+0x94>
			dig = *s - '0';
f01018c5:	0f be c9             	movsbl %cl,%ecx
f01018c8:	83 e9 30             	sub    $0x30,%ecx
f01018cb:	eb 1e                	jmp    f01018eb <strtol+0xb2>
		else if (*s >= 'a' && *s <= 'z')
f01018cd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f01018d0:	80 fb 19             	cmp    $0x19,%bl
f01018d3:	77 08                	ja     f01018dd <strtol+0xa4>
			dig = *s - 'a' + 10;
f01018d5:	0f be c9             	movsbl %cl,%ecx
f01018d8:	83 e9 57             	sub    $0x57,%ecx
f01018db:	eb 0e                	jmp    f01018eb <strtol+0xb2>
		else if (*s >= 'A' && *s <= 'Z')
f01018dd:	8d 5f bf             	lea    -0x41(%edi),%ebx
f01018e0:	80 fb 19             	cmp    $0x19,%bl
f01018e3:	77 15                	ja     f01018fa <strtol+0xc1>
			dig = *s - 'A' + 10;
f01018e5:	0f be c9             	movsbl %cl,%ecx
f01018e8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01018eb:	39 f1                	cmp    %esi,%ecx
f01018ed:	7d 0b                	jge    f01018fa <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f01018ef:	83 c2 01             	add    $0x1,%edx
f01018f2:	0f af c6             	imul   %esi,%eax
f01018f5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f01018f8:	eb be                	jmp    f01018b8 <strtol+0x7f>
f01018fa:	89 c1                	mov    %eax,%ecx

	if (endptr)
f01018fc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101900:	74 05                	je     f0101907 <strtol+0xce>
		*endptr = (char *) s;
f0101902:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101905:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0101907:	89 ca                	mov    %ecx,%edx
f0101909:	f7 da                	neg    %edx
f010190b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010190f:	0f 45 c2             	cmovne %edx,%eax
}
f0101912:	83 c4 04             	add    $0x4,%esp
f0101915:	5b                   	pop    %ebx
f0101916:	5e                   	pop    %esi
f0101917:	5f                   	pop    %edi
f0101918:	5d                   	pop    %ebp
f0101919:	c3                   	ret    
f010191a:	00 00                	add    %al,(%eax)
f010191c:	00 00                	add    %al,(%eax)
	...

f0101920 <__udivdi3>:
f0101920:	55                   	push   %ebp
f0101921:	89 e5                	mov    %esp,%ebp
f0101923:	57                   	push   %edi
f0101924:	56                   	push   %esi
f0101925:	83 ec 10             	sub    $0x10,%esp
f0101928:	8b 45 14             	mov    0x14(%ebp),%eax
f010192b:	8b 55 08             	mov    0x8(%ebp),%edx
f010192e:	8b 75 10             	mov    0x10(%ebp),%esi
f0101931:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101934:	85 c0                	test   %eax,%eax
f0101936:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0101939:	75 35                	jne    f0101970 <__udivdi3+0x50>
f010193b:	39 fe                	cmp    %edi,%esi
f010193d:	77 61                	ja     f01019a0 <__udivdi3+0x80>
f010193f:	85 f6                	test   %esi,%esi
f0101941:	75 0b                	jne    f010194e <__udivdi3+0x2e>
f0101943:	b8 01 00 00 00       	mov    $0x1,%eax
f0101948:	31 d2                	xor    %edx,%edx
f010194a:	f7 f6                	div    %esi
f010194c:	89 c6                	mov    %eax,%esi
f010194e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0101951:	31 d2                	xor    %edx,%edx
f0101953:	89 f8                	mov    %edi,%eax
f0101955:	f7 f6                	div    %esi
f0101957:	89 c7                	mov    %eax,%edi
f0101959:	89 c8                	mov    %ecx,%eax
f010195b:	f7 f6                	div    %esi
f010195d:	89 c1                	mov    %eax,%ecx
f010195f:	89 fa                	mov    %edi,%edx
f0101961:	89 c8                	mov    %ecx,%eax
f0101963:	83 c4 10             	add    $0x10,%esp
f0101966:	5e                   	pop    %esi
f0101967:	5f                   	pop    %edi
f0101968:	5d                   	pop    %ebp
f0101969:	c3                   	ret    
f010196a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101970:	39 f8                	cmp    %edi,%eax
f0101972:	77 1c                	ja     f0101990 <__udivdi3+0x70>
f0101974:	0f bd d0             	bsr    %eax,%edx
f0101977:	83 f2 1f             	xor    $0x1f,%edx
f010197a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010197d:	75 39                	jne    f01019b8 <__udivdi3+0x98>
f010197f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0101982:	0f 86 a0 00 00 00    	jbe    f0101a28 <__udivdi3+0x108>
f0101988:	39 f8                	cmp    %edi,%eax
f010198a:	0f 82 98 00 00 00    	jb     f0101a28 <__udivdi3+0x108>
f0101990:	31 ff                	xor    %edi,%edi
f0101992:	31 c9                	xor    %ecx,%ecx
f0101994:	89 c8                	mov    %ecx,%eax
f0101996:	89 fa                	mov    %edi,%edx
f0101998:	83 c4 10             	add    $0x10,%esp
f010199b:	5e                   	pop    %esi
f010199c:	5f                   	pop    %edi
f010199d:	5d                   	pop    %ebp
f010199e:	c3                   	ret    
f010199f:	90                   	nop
f01019a0:	89 d1                	mov    %edx,%ecx
f01019a2:	89 fa                	mov    %edi,%edx
f01019a4:	89 c8                	mov    %ecx,%eax
f01019a6:	31 ff                	xor    %edi,%edi
f01019a8:	f7 f6                	div    %esi
f01019aa:	89 c1                	mov    %eax,%ecx
f01019ac:	89 fa                	mov    %edi,%edx
f01019ae:	89 c8                	mov    %ecx,%eax
f01019b0:	83 c4 10             	add    $0x10,%esp
f01019b3:	5e                   	pop    %esi
f01019b4:	5f                   	pop    %edi
f01019b5:	5d                   	pop    %ebp
f01019b6:	c3                   	ret    
f01019b7:	90                   	nop
f01019b8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01019bc:	89 f2                	mov    %esi,%edx
f01019be:	d3 e0                	shl    %cl,%eax
f01019c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01019c3:	b8 20 00 00 00       	mov    $0x20,%eax
f01019c8:	2b 45 f4             	sub    -0xc(%ebp),%eax
f01019cb:	89 c1                	mov    %eax,%ecx
f01019cd:	d3 ea                	shr    %cl,%edx
f01019cf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01019d3:	0b 55 ec             	or     -0x14(%ebp),%edx
f01019d6:	d3 e6                	shl    %cl,%esi
f01019d8:	89 c1                	mov    %eax,%ecx
f01019da:	89 75 e8             	mov    %esi,-0x18(%ebp)
f01019dd:	89 fe                	mov    %edi,%esi
f01019df:	d3 ee                	shr    %cl,%esi
f01019e1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01019e5:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01019e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01019eb:	d3 e7                	shl    %cl,%edi
f01019ed:	89 c1                	mov    %eax,%ecx
f01019ef:	d3 ea                	shr    %cl,%edx
f01019f1:	09 d7                	or     %edx,%edi
f01019f3:	89 f2                	mov    %esi,%edx
f01019f5:	89 f8                	mov    %edi,%eax
f01019f7:	f7 75 ec             	divl   -0x14(%ebp)
f01019fa:	89 d6                	mov    %edx,%esi
f01019fc:	89 c7                	mov    %eax,%edi
f01019fe:	f7 65 e8             	mull   -0x18(%ebp)
f0101a01:	39 d6                	cmp    %edx,%esi
f0101a03:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101a06:	72 30                	jb     f0101a38 <__udivdi3+0x118>
f0101a08:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101a0b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0101a0f:	d3 e2                	shl    %cl,%edx
f0101a11:	39 c2                	cmp    %eax,%edx
f0101a13:	73 05                	jae    f0101a1a <__udivdi3+0xfa>
f0101a15:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0101a18:	74 1e                	je     f0101a38 <__udivdi3+0x118>
f0101a1a:	89 f9                	mov    %edi,%ecx
f0101a1c:	31 ff                	xor    %edi,%edi
f0101a1e:	e9 71 ff ff ff       	jmp    f0101994 <__udivdi3+0x74>
f0101a23:	90                   	nop
f0101a24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101a28:	31 ff                	xor    %edi,%edi
f0101a2a:	b9 01 00 00 00       	mov    $0x1,%ecx
f0101a2f:	e9 60 ff ff ff       	jmp    f0101994 <__udivdi3+0x74>
f0101a34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101a38:	8d 4f ff             	lea    -0x1(%edi),%ecx
f0101a3b:	31 ff                	xor    %edi,%edi
f0101a3d:	89 c8                	mov    %ecx,%eax
f0101a3f:	89 fa                	mov    %edi,%edx
f0101a41:	83 c4 10             	add    $0x10,%esp
f0101a44:	5e                   	pop    %esi
f0101a45:	5f                   	pop    %edi
f0101a46:	5d                   	pop    %ebp
f0101a47:	c3                   	ret    
	...

f0101a50 <__umoddi3>:
f0101a50:	55                   	push   %ebp
f0101a51:	89 e5                	mov    %esp,%ebp
f0101a53:	57                   	push   %edi
f0101a54:	56                   	push   %esi
f0101a55:	83 ec 20             	sub    $0x20,%esp
f0101a58:	8b 55 14             	mov    0x14(%ebp),%edx
f0101a5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101a5e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101a61:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101a64:	85 d2                	test   %edx,%edx
f0101a66:	89 c8                	mov    %ecx,%eax
f0101a68:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0101a6b:	75 13                	jne    f0101a80 <__umoddi3+0x30>
f0101a6d:	39 f7                	cmp    %esi,%edi
f0101a6f:	76 3f                	jbe    f0101ab0 <__umoddi3+0x60>
f0101a71:	89 f2                	mov    %esi,%edx
f0101a73:	f7 f7                	div    %edi
f0101a75:	89 d0                	mov    %edx,%eax
f0101a77:	31 d2                	xor    %edx,%edx
f0101a79:	83 c4 20             	add    $0x20,%esp
f0101a7c:	5e                   	pop    %esi
f0101a7d:	5f                   	pop    %edi
f0101a7e:	5d                   	pop    %ebp
f0101a7f:	c3                   	ret    
f0101a80:	39 f2                	cmp    %esi,%edx
f0101a82:	77 4c                	ja     f0101ad0 <__umoddi3+0x80>
f0101a84:	0f bd ca             	bsr    %edx,%ecx
f0101a87:	83 f1 1f             	xor    $0x1f,%ecx
f0101a8a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101a8d:	75 51                	jne    f0101ae0 <__umoddi3+0x90>
f0101a8f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0101a92:	0f 87 e0 00 00 00    	ja     f0101b78 <__umoddi3+0x128>
f0101a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101a9b:	29 f8                	sub    %edi,%eax
f0101a9d:	19 d6                	sbb    %edx,%esi
f0101a9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101aa5:	89 f2                	mov    %esi,%edx
f0101aa7:	83 c4 20             	add    $0x20,%esp
f0101aaa:	5e                   	pop    %esi
f0101aab:	5f                   	pop    %edi
f0101aac:	5d                   	pop    %ebp
f0101aad:	c3                   	ret    
f0101aae:	66 90                	xchg   %ax,%ax
f0101ab0:	85 ff                	test   %edi,%edi
f0101ab2:	75 0b                	jne    f0101abf <__umoddi3+0x6f>
f0101ab4:	b8 01 00 00 00       	mov    $0x1,%eax
f0101ab9:	31 d2                	xor    %edx,%edx
f0101abb:	f7 f7                	div    %edi
f0101abd:	89 c7                	mov    %eax,%edi
f0101abf:	89 f0                	mov    %esi,%eax
f0101ac1:	31 d2                	xor    %edx,%edx
f0101ac3:	f7 f7                	div    %edi
f0101ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101ac8:	f7 f7                	div    %edi
f0101aca:	eb a9                	jmp    f0101a75 <__umoddi3+0x25>
f0101acc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101ad0:	89 c8                	mov    %ecx,%eax
f0101ad2:	89 f2                	mov    %esi,%edx
f0101ad4:	83 c4 20             	add    $0x20,%esp
f0101ad7:	5e                   	pop    %esi
f0101ad8:	5f                   	pop    %edi
f0101ad9:	5d                   	pop    %ebp
f0101ada:	c3                   	ret    
f0101adb:	90                   	nop
f0101adc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101ae0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101ae4:	d3 e2                	shl    %cl,%edx
f0101ae6:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101ae9:	ba 20 00 00 00       	mov    $0x20,%edx
f0101aee:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0101af1:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101af4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101af8:	89 fa                	mov    %edi,%edx
f0101afa:	d3 ea                	shr    %cl,%edx
f0101afc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101b00:	0b 55 f4             	or     -0xc(%ebp),%edx
f0101b03:	d3 e7                	shl    %cl,%edi
f0101b05:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101b09:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101b0c:	89 f2                	mov    %esi,%edx
f0101b0e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0101b11:	89 c7                	mov    %eax,%edi
f0101b13:	d3 ea                	shr    %cl,%edx
f0101b15:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101b19:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101b1c:	89 c2                	mov    %eax,%edx
f0101b1e:	d3 e6                	shl    %cl,%esi
f0101b20:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101b24:	d3 ea                	shr    %cl,%edx
f0101b26:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101b2a:	09 d6                	or     %edx,%esi
f0101b2c:	89 f0                	mov    %esi,%eax
f0101b2e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101b31:	d3 e7                	shl    %cl,%edi
f0101b33:	89 f2                	mov    %esi,%edx
f0101b35:	f7 75 f4             	divl   -0xc(%ebp)
f0101b38:	89 d6                	mov    %edx,%esi
f0101b3a:	f7 65 e8             	mull   -0x18(%ebp)
f0101b3d:	39 d6                	cmp    %edx,%esi
f0101b3f:	72 2b                	jb     f0101b6c <__umoddi3+0x11c>
f0101b41:	39 c7                	cmp    %eax,%edi
f0101b43:	72 23                	jb     f0101b68 <__umoddi3+0x118>
f0101b45:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101b49:	29 c7                	sub    %eax,%edi
f0101b4b:	19 d6                	sbb    %edx,%esi
f0101b4d:	89 f0                	mov    %esi,%eax
f0101b4f:	89 f2                	mov    %esi,%edx
f0101b51:	d3 ef                	shr    %cl,%edi
f0101b53:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101b57:	d3 e0                	shl    %cl,%eax
f0101b59:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101b5d:	09 f8                	or     %edi,%eax
f0101b5f:	d3 ea                	shr    %cl,%edx
f0101b61:	83 c4 20             	add    $0x20,%esp
f0101b64:	5e                   	pop    %esi
f0101b65:	5f                   	pop    %edi
f0101b66:	5d                   	pop    %ebp
f0101b67:	c3                   	ret    
f0101b68:	39 d6                	cmp    %edx,%esi
f0101b6a:	75 d9                	jne    f0101b45 <__umoddi3+0xf5>
f0101b6c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f0101b6f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0101b72:	eb d1                	jmp    f0101b45 <__umoddi3+0xf5>
f0101b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b78:	39 f2                	cmp    %esi,%edx
f0101b7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b80:	0f 82 12 ff ff ff    	jb     f0101a98 <__umoddi3+0x48>
f0101b86:	e9 17 ff ff ff       	jmp    f0101aa2 <__umoddi3+0x52>
