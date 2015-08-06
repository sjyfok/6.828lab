
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
f0100039:	e8 3a 00 00 00       	call   f0100078 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
f0100046:	8b 45 08             	mov    0x8(%ebp),%eax
	//cprintf("entering test_backtrace %d\n", x);
	if (x > 0)
f0100049:	85 c0                	test   %eax,%eax
f010004b:	7e 0d                	jle    f010005a <test_backtrace+0x1a>
		test_backtrace(x-1);
f010004d:	83 e8 01             	sub    $0x1,%eax
f0100050:	89 04 24             	mov    %eax,(%esp)
f0100053:	e8 e8 ff ff ff       	call   f0100040 <test_backtrace>
f0100058:	eb 1c                	jmp    f0100076 <test_backtrace+0x36>
	else
		mon_backtrace(0, 0, 0);
f010005a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100061:	00 
f0100062:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100069:	00 
f010006a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100071:	e8 d9 06 00 00       	call   f010074f <mon_backtrace>
//	cprintf("leaving test_backtrace %d\n", x);
}
f0100076:	c9                   	leave  
f0100077:	c3                   	ret    

f0100078 <i386_init>:

void
i386_init(void)
{
f0100078:	55                   	push   %ebp
f0100079:	89 e5                	mov    %esp,%ebp
f010007b:	83 ec 18             	sub    $0x18,%esp
	//int x = 1, y = 3, z = 4;
	//unsigned int i = 0x00646c72;
	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010007e:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f0100083:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f0100088:	89 44 24 08          	mov    %eax,0x8(%esp)
f010008c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100093:	00 
f0100094:	c7 04 24 00 23 11 f0 	movl   $0xf0112300,(%esp)
f010009b:	e8 a7 14 00 00       	call   f0101547 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000a0:	e8 8c 04 00 00       	call   f0100531 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000a5:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000ac:	00 
f01000ad:	c7 04 24 e0 19 10 f0 	movl   $0xf01019e0,(%esp)
f01000b4:	e8 f9 08 00 00       	call   f01009b2 <cprintf>
	//cprintf("H%x Wo%s", 57616, &i);
	//cprintf("x=%d y=%d", 3);
	//cprintf("x %d, y %d, z %d\n", x, y, z);
	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000b9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000c0:	e8 7b ff ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000cc:	e8 59 07 00 00       	call   f010082a <monitor>
f01000d1:	eb f2                	jmp    f01000c5 <i386_init+0x4d>

f01000d3 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000d3:	55                   	push   %ebp
f01000d4:	89 e5                	mov    %esp,%ebp
f01000d6:	56                   	push   %esi
f01000d7:	53                   	push   %ebx
f01000d8:	83 ec 10             	sub    $0x10,%esp
f01000db:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000de:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f01000e5:	75 3d                	jne    f0100124 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000e7:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000ed:	fa                   	cli    
f01000ee:	fc                   	cld    

	va_start(ap, fmt);
f01000ef:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000f2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000f5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01000fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100100:	c7 04 24 fb 19 10 f0 	movl   $0xf01019fb,(%esp)
f0100107:	e8 a6 08 00 00       	call   f01009b2 <cprintf>
	vcprintf(fmt, ap);
f010010c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100110:	89 34 24             	mov    %esi,(%esp)
f0100113:	e8 67 08 00 00       	call   f010097f <vcprintf>
	cprintf("\n");
f0100118:	c7 04 24 37 1a 10 f0 	movl   $0xf0101a37,(%esp)
f010011f:	e8 8e 08 00 00       	call   f01009b2 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100124:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010012b:	e8 fa 06 00 00       	call   f010082a <monitor>
f0100130:	eb f2                	jmp    f0100124 <_panic+0x51>

f0100132 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100132:	55                   	push   %ebp
f0100133:	89 e5                	mov    %esp,%ebp
f0100135:	53                   	push   %ebx
f0100136:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100139:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010013c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010013f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100143:	8b 45 08             	mov    0x8(%ebp),%eax
f0100146:	89 44 24 04          	mov    %eax,0x4(%esp)
f010014a:	c7 04 24 13 1a 10 f0 	movl   $0xf0101a13,(%esp)
f0100151:	e8 5c 08 00 00       	call   f01009b2 <cprintf>
	vcprintf(fmt, ap);
f0100156:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010015a:	8b 45 10             	mov    0x10(%ebp),%eax
f010015d:	89 04 24             	mov    %eax,(%esp)
f0100160:	e8 1a 08 00 00       	call   f010097f <vcprintf>
	cprintf("\n");
f0100165:	c7 04 24 37 1a 10 f0 	movl   $0xf0101a37,(%esp)
f010016c:	e8 41 08 00 00       	call   f01009b2 <cprintf>
	va_end(ap);
}
f0100171:	83 c4 14             	add    $0x14,%esp
f0100174:	5b                   	pop    %ebx
f0100175:	5d                   	pop    %ebp
f0100176:	c3                   	ret    
f0100177:	66 90                	xchg   %ax,%ax
f0100179:	66 90                	xchg   %ax,%ax
f010017b:	66 90                	xchg   %ax,%ax
f010017d:	66 90                	xchg   %ax,%ax
f010017f:	90                   	nop

f0100180 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100180:	55                   	push   %ebp
f0100181:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100183:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100188:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100189:	a8 01                	test   $0x1,%al
f010018b:	74 08                	je     f0100195 <serial_proc_data+0x15>
f010018d:	b2 f8                	mov    $0xf8,%dl
f010018f:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100190:	0f b6 c0             	movzbl %al,%eax
f0100193:	eb 05                	jmp    f010019a <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100195:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010019a:	5d                   	pop    %ebp
f010019b:	c3                   	ret    

f010019c <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010019c:	55                   	push   %ebp
f010019d:	89 e5                	mov    %esp,%ebp
f010019f:	53                   	push   %ebx
f01001a0:	83 ec 04             	sub    $0x4,%esp
f01001a3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001a5:	eb 2a                	jmp    f01001d1 <cons_intr+0x35>
		if (c == 0)
f01001a7:	85 d2                	test   %edx,%edx
f01001a9:	74 26                	je     f01001d1 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01001ab:	a1 24 25 11 f0       	mov    0xf0112524,%eax
f01001b0:	8d 48 01             	lea    0x1(%eax),%ecx
f01001b3:	89 0d 24 25 11 f0    	mov    %ecx,0xf0112524
f01001b9:	88 90 20 23 11 f0    	mov    %dl,-0xfeedce0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01001bf:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01001c5:	75 0a                	jne    f01001d1 <cons_intr+0x35>
			cons.wpos = 0;
f01001c7:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001ce:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001d1:	ff d3                	call   *%ebx
f01001d3:	89 c2                	mov    %eax,%edx
f01001d5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d8:	75 cd                	jne    f01001a7 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001da:	83 c4 04             	add    $0x4,%esp
f01001dd:	5b                   	pop    %ebx
f01001de:	5d                   	pop    %ebp
f01001df:	c3                   	ret    

f01001e0 <kbd_proc_data>:
f01001e0:	ba 64 00 00 00       	mov    $0x64,%edx
f01001e5:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001e6:	a8 01                	test   $0x1,%al
f01001e8:	0f 84 e7 00 00 00    	je     f01002d5 <kbd_proc_data+0xf5>
f01001ee:	b2 60                	mov    $0x60,%dl
f01001f0:	ec                   	in     (%dx),%al
f01001f1:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001f3:	3c e0                	cmp    $0xe0,%al
f01001f5:	75 0d                	jne    f0100204 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01001f7:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f01001fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100203:	c3                   	ret    
	} else if (data & 0x80) {
f0100204:	84 c0                	test   %al,%al
f0100206:	79 30                	jns    f0100238 <kbd_proc_data+0x58>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100208:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010020e:	f6 c1 40             	test   $0x40,%cl
f0100211:	75 05                	jne    f0100218 <kbd_proc_data+0x38>
f0100213:	83 e0 7f             	and    $0x7f,%eax
f0100216:	89 c2                	mov    %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100218:	0f b6 d2             	movzbl %dl,%edx
f010021b:	0f b6 82 80 1b 10 f0 	movzbl -0xfefe480(%edx),%eax
f0100222:	83 c8 40             	or     $0x40,%eax
f0100225:	0f b6 c0             	movzbl %al,%eax
f0100228:	f7 d0                	not    %eax
f010022a:	21 c1                	and    %eax,%ecx
f010022c:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
		return 0;
f0100232:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100237:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100238:	55                   	push   %ebp
f0100239:	89 e5                	mov    %esp,%ebp
f010023b:	53                   	push   %ebx
f010023c:	83 ec 14             	sub    $0x14,%esp
	} else if (data & 0x80) {
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
		shift &= ~(shiftcode[data] | E0ESC);
		return 0;
	} else if (shift & E0ESC) {
f010023f:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100245:	f6 c1 40             	test   $0x40,%cl
f0100248:	74 0e                	je     f0100258 <kbd_proc_data+0x78>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010024a:	83 c8 80             	or     $0xffffff80,%eax
f010024d:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010024f:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100252:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100258:	0f b6 d2             	movzbl %dl,%edx
f010025b:	0f b6 82 80 1b 10 f0 	movzbl -0xfefe480(%edx),%eax
f0100262:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
	shift ^= togglecode[data];
f0100268:	0f b6 8a 80 1a 10 f0 	movzbl -0xfefe580(%edx),%ecx
f010026f:	31 c8                	xor    %ecx,%eax
f0100271:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100276:	89 c1                	mov    %eax,%ecx
f0100278:	83 e1 03             	and    $0x3,%ecx
f010027b:	8b 0c 8d 60 1a 10 f0 	mov    -0xfefe5a0(,%ecx,4),%ecx
f0100282:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100286:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100289:	a8 08                	test   $0x8,%al
f010028b:	74 1a                	je     f01002a7 <kbd_proc_data+0xc7>
		if ('a' <= c && c <= 'z')
f010028d:	89 da                	mov    %ebx,%edx
f010028f:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100292:	83 f9 19             	cmp    $0x19,%ecx
f0100295:	77 05                	ja     f010029c <kbd_proc_data+0xbc>
			c += 'A' - 'a';
f0100297:	83 eb 20             	sub    $0x20,%ebx
f010029a:	eb 0b                	jmp    f01002a7 <kbd_proc_data+0xc7>
		else if ('A' <= c && c <= 'Z')
f010029c:	83 ea 41             	sub    $0x41,%edx
f010029f:	83 fa 19             	cmp    $0x19,%edx
f01002a2:	77 03                	ja     f01002a7 <kbd_proc_data+0xc7>
			c += 'a' - 'A';
f01002a4:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002a7:	f7 d0                	not    %eax
f01002a9:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002ab:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002ad:	f6 c2 06             	test   $0x6,%dl
f01002b0:	75 29                	jne    f01002db <kbd_proc_data+0xfb>
f01002b2:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002b8:	75 21                	jne    f01002db <kbd_proc_data+0xfb>
		cprintf("Rebooting!\n");
f01002ba:	c7 04 24 2d 1a 10 f0 	movl   $0xf0101a2d,(%esp)
f01002c1:	e8 ec 06 00 00       	call   f01009b2 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c6:	ba 92 00 00 00       	mov    $0x92,%edx
f01002cb:	b8 03 00 00 00       	mov    $0x3,%eax
f01002d0:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002d1:	89 d8                	mov    %ebx,%eax
f01002d3:	eb 06                	jmp    f01002db <kbd_proc_data+0xfb>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002da:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002db:	83 c4 14             	add    $0x14,%esp
f01002de:	5b                   	pop    %ebx
f01002df:	5d                   	pop    %ebp
f01002e0:	c3                   	ret    

f01002e1 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002e1:	55                   	push   %ebp
f01002e2:	89 e5                	mov    %esp,%ebp
f01002e4:	57                   	push   %edi
f01002e5:	56                   	push   %esi
f01002e6:	53                   	push   %ebx
f01002e7:	83 ec 1c             	sub    $0x1c,%esp
f01002ea:	89 c7                	mov    %eax,%edi
f01002ec:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f1:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002f6:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002fb:	eb 06                	jmp    f0100303 <cons_putc+0x22>
f01002fd:	89 ca                	mov    %ecx,%edx
f01002ff:	ec                   	in     (%dx),%al
f0100300:	ec                   	in     (%dx),%al
f0100301:	ec                   	in     (%dx),%al
f0100302:	ec                   	in     (%dx),%al
f0100303:	89 f2                	mov    %esi,%edx
f0100305:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100306:	a8 20                	test   $0x20,%al
f0100308:	75 05                	jne    f010030f <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010030a:	83 eb 01             	sub    $0x1,%ebx
f010030d:	75 ee                	jne    f01002fd <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010030f:	89 f8                	mov    %edi,%eax
f0100311:	0f b6 c0             	movzbl %al,%eax
f0100314:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100317:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010031c:	ee                   	out    %al,(%dx)
f010031d:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100322:	be 79 03 00 00       	mov    $0x379,%esi
f0100327:	b9 84 00 00 00       	mov    $0x84,%ecx
f010032c:	eb 06                	jmp    f0100334 <cons_putc+0x53>
f010032e:	89 ca                	mov    %ecx,%edx
f0100330:	ec                   	in     (%dx),%al
f0100331:	ec                   	in     (%dx),%al
f0100332:	ec                   	in     (%dx),%al
f0100333:	ec                   	in     (%dx),%al
f0100334:	89 f2                	mov    %esi,%edx
f0100336:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100337:	84 c0                	test   %al,%al
f0100339:	78 05                	js     f0100340 <cons_putc+0x5f>
f010033b:	83 eb 01             	sub    $0x1,%ebx
f010033e:	75 ee                	jne    f010032e <cons_putc+0x4d>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100340:	ba 78 03 00 00       	mov    $0x378,%edx
f0100345:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100349:	ee                   	out    %al,(%dx)
f010034a:	b2 7a                	mov    $0x7a,%dl
f010034c:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100351:	ee                   	out    %al,(%dx)
f0100352:	b8 08 00 00 00       	mov    $0x8,%eax
f0100357:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100358:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010035e:	75 06                	jne    f0100366 <cons_putc+0x85>
		c |= 0x0700;
f0100360:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f0100366:	89 f8                	mov    %edi,%eax
f0100368:	0f b6 c0             	movzbl %al,%eax
f010036b:	83 f8 09             	cmp    $0x9,%eax
f010036e:	74 74                	je     f01003e4 <cons_putc+0x103>
f0100370:	83 f8 09             	cmp    $0x9,%eax
f0100373:	7f 0a                	jg     f010037f <cons_putc+0x9e>
f0100375:	83 f8 08             	cmp    $0x8,%eax
f0100378:	74 14                	je     f010038e <cons_putc+0xad>
f010037a:	e9 99 00 00 00       	jmp    f0100418 <cons_putc+0x137>
f010037f:	83 f8 0a             	cmp    $0xa,%eax
f0100382:	74 3a                	je     f01003be <cons_putc+0xdd>
f0100384:	83 f8 0d             	cmp    $0xd,%eax
f0100387:	74 3d                	je     f01003c6 <cons_putc+0xe5>
f0100389:	e9 8a 00 00 00       	jmp    f0100418 <cons_putc+0x137>
	case '\b':
		if (crt_pos > 0) {
f010038e:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100395:	66 85 c0             	test   %ax,%ax
f0100398:	0f 84 e5 00 00 00    	je     f0100483 <cons_putc+0x1a2>
			crt_pos--;
f010039e:	83 e8 01             	sub    $0x1,%eax
f01003a1:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003a7:	0f b7 c0             	movzwl %ax,%eax
f01003aa:	66 81 e7 00 ff       	and    $0xff00,%di
f01003af:	83 cf 20             	or     $0x20,%edi
f01003b2:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003b8:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003bc:	eb 78                	jmp    f0100436 <cons_putc+0x155>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003be:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003c5:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003c6:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003cd:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003d3:	c1 e8 16             	shr    $0x16,%eax
f01003d6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003d9:	c1 e0 04             	shl    $0x4,%eax
f01003dc:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f01003e2:	eb 52                	jmp    f0100436 <cons_putc+0x155>
		break;
	case '\t':
		cons_putc(' ');
f01003e4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e9:	e8 f3 fe ff ff       	call   f01002e1 <cons_putc>
		cons_putc(' ');
f01003ee:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f3:	e8 e9 fe ff ff       	call   f01002e1 <cons_putc>
		cons_putc(' ');
f01003f8:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fd:	e8 df fe ff ff       	call   f01002e1 <cons_putc>
		cons_putc(' ');
f0100402:	b8 20 00 00 00       	mov    $0x20,%eax
f0100407:	e8 d5 fe ff ff       	call   f01002e1 <cons_putc>
		cons_putc(' ');
f010040c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100411:	e8 cb fe ff ff       	call   f01002e1 <cons_putc>
f0100416:	eb 1e                	jmp    f0100436 <cons_putc+0x155>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100418:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010041f:	8d 50 01             	lea    0x1(%eax),%edx
f0100422:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f0100429:	0f b7 c0             	movzwl %ax,%eax
f010042c:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100432:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100436:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f010043d:	cf 07 
f010043f:	76 42                	jbe    f0100483 <cons_putc+0x1a2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100441:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100446:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010044d:	00 
f010044e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100454:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100458:	89 04 24             	mov    %eax,(%esp)
f010045b:	e8 34 11 00 00       	call   f0101594 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100460:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100466:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010046b:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100471:	83 c0 01             	add    $0x1,%eax
f0100474:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100479:	75 f0                	jne    f010046b <cons_putc+0x18a>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010047b:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f0100482:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100483:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f0100489:	b8 0e 00 00 00       	mov    $0xe,%eax
f010048e:	89 ca                	mov    %ecx,%edx
f0100490:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100491:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f0100498:	8d 71 01             	lea    0x1(%ecx),%esi
f010049b:	89 d8                	mov    %ebx,%eax
f010049d:	66 c1 e8 08          	shr    $0x8,%ax
f01004a1:	89 f2                	mov    %esi,%edx
f01004a3:	ee                   	out    %al,(%dx)
f01004a4:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004a9:	89 ca                	mov    %ecx,%edx
f01004ab:	ee                   	out    %al,(%dx)
f01004ac:	89 d8                	mov    %ebx,%eax
f01004ae:	89 f2                	mov    %esi,%edx
f01004b0:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004b1:	83 c4 1c             	add    $0x1c,%esp
f01004b4:	5b                   	pop    %ebx
f01004b5:	5e                   	pop    %esi
f01004b6:	5f                   	pop    %edi
f01004b7:	5d                   	pop    %ebp
f01004b8:	c3                   	ret    

f01004b9 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004b9:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004c0:	74 11                	je     f01004d3 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004c2:	55                   	push   %ebp
f01004c3:	89 e5                	mov    %esp,%ebp
f01004c5:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004c8:	b8 80 01 10 f0       	mov    $0xf0100180,%eax
f01004cd:	e8 ca fc ff ff       	call   f010019c <cons_intr>
}
f01004d2:	c9                   	leave  
f01004d3:	f3 c3                	repz ret 

f01004d5 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004d5:	55                   	push   %ebp
f01004d6:	89 e5                	mov    %esp,%ebp
f01004d8:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004db:	b8 e0 01 10 f0       	mov    $0xf01001e0,%eax
f01004e0:	e8 b7 fc ff ff       	call   f010019c <cons_intr>
}
f01004e5:	c9                   	leave  
f01004e6:	c3                   	ret    

f01004e7 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004e7:	55                   	push   %ebp
f01004e8:	89 e5                	mov    %esp,%ebp
f01004ea:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004ed:	e8 c7 ff ff ff       	call   f01004b9 <serial_intr>
	kbd_intr();
f01004f2:	e8 de ff ff ff       	call   f01004d5 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004f7:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f01004fc:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100502:	74 26                	je     f010052a <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100504:	8d 50 01             	lea    0x1(%eax),%edx
f0100507:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f010050d:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100514:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100516:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010051c:	75 11                	jne    f010052f <cons_getc+0x48>
			cons.rpos = 0;
f010051e:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100525:	00 00 00 
f0100528:	eb 05                	jmp    f010052f <cons_getc+0x48>
		return c;
	}
	return 0;
f010052a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010052f:	c9                   	leave  
f0100530:	c3                   	ret    

f0100531 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100531:	55                   	push   %ebp
f0100532:	89 e5                	mov    %esp,%ebp
f0100534:	57                   	push   %edi
f0100535:	56                   	push   %esi
f0100536:	53                   	push   %ebx
f0100537:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010053a:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100541:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100548:	5a a5 
	if (*cp != 0xA55A) {
f010054a:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100551:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100555:	74 11                	je     f0100568 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100557:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f010055e:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100561:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f0100566:	eb 16                	jmp    f010057e <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100568:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010056f:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f0100576:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100579:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010057e:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f0100584:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100589:	89 ca                	mov    %ecx,%edx
f010058b:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010058c:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010058f:	89 da                	mov    %ebx,%edx
f0100591:	ec                   	in     (%dx),%al
f0100592:	0f b6 f0             	movzbl %al,%esi
f0100595:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100598:	b8 0f 00 00 00       	mov    $0xf,%eax
f010059d:	89 ca                	mov    %ecx,%edx
f010059f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a0:	89 da                	mov    %ebx,%edx
f01005a2:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005a3:	89 3d 2c 25 11 f0    	mov    %edi,0xf011252c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005a9:	0f b6 d8             	movzbl %al,%ebx
f01005ac:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005ae:	66 89 35 28 25 11 f0 	mov    %si,0xf0112528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005b5:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01005bf:	89 f2                	mov    %esi,%edx
f01005c1:	ee                   	out    %al,(%dx)
f01005c2:	b2 fb                	mov    $0xfb,%dl
f01005c4:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005c9:	ee                   	out    %al,(%dx)
f01005ca:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005cf:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005d4:	89 da                	mov    %ebx,%edx
f01005d6:	ee                   	out    %al,(%dx)
f01005d7:	b2 f9                	mov    $0xf9,%dl
f01005d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01005de:	ee                   	out    %al,(%dx)
f01005df:	b2 fb                	mov    $0xfb,%dl
f01005e1:	b8 03 00 00 00       	mov    $0x3,%eax
f01005e6:	ee                   	out    %al,(%dx)
f01005e7:	b2 fc                	mov    $0xfc,%dl
f01005e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ee:	ee                   	out    %al,(%dx)
f01005ef:	b2 f9                	mov    $0xf9,%dl
f01005f1:	b8 01 00 00 00       	mov    $0x1,%eax
f01005f6:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005f7:	b2 fd                	mov    $0xfd,%dl
f01005f9:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005fa:	3c ff                	cmp    $0xff,%al
f01005fc:	0f 95 c1             	setne  %cl
f01005ff:	88 0d 34 25 11 f0    	mov    %cl,0xf0112534
f0100605:	89 f2                	mov    %esi,%edx
f0100607:	ec                   	in     (%dx),%al
f0100608:	89 da                	mov    %ebx,%edx
f010060a:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010060b:	84 c9                	test   %cl,%cl
f010060d:	75 0c                	jne    f010061b <cons_init+0xea>
		cprintf("Serial port does not exist!\n");
f010060f:	c7 04 24 39 1a 10 f0 	movl   $0xf0101a39,(%esp)
f0100616:	e8 97 03 00 00       	call   f01009b2 <cprintf>
}
f010061b:	83 c4 1c             	add    $0x1c,%esp
f010061e:	5b                   	pop    %ebx
f010061f:	5e                   	pop    %esi
f0100620:	5f                   	pop    %edi
f0100621:	5d                   	pop    %ebp
f0100622:	c3                   	ret    

f0100623 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100623:	55                   	push   %ebp
f0100624:	89 e5                	mov    %esp,%ebp
f0100626:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100629:	8b 45 08             	mov    0x8(%ebp),%eax
f010062c:	e8 b0 fc ff ff       	call   f01002e1 <cons_putc>
}
f0100631:	c9                   	leave  
f0100632:	c3                   	ret    

f0100633 <getchar>:

int
getchar(void)
{
f0100633:	55                   	push   %ebp
f0100634:	89 e5                	mov    %esp,%ebp
f0100636:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100639:	e8 a9 fe ff ff       	call   f01004e7 <cons_getc>
f010063e:	85 c0                	test   %eax,%eax
f0100640:	74 f7                	je     f0100639 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100642:	c9                   	leave  
f0100643:	c3                   	ret    

f0100644 <iscons>:

int
iscons(int fdnum)
{
f0100644:	55                   	push   %ebp
f0100645:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100647:	b8 01 00 00 00       	mov    $0x1,%eax
f010064c:	5d                   	pop    %ebp
f010064d:	c3                   	ret    
f010064e:	66 90                	xchg   %ax,%ax

f0100650 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100650:	55                   	push   %ebp
f0100651:	89 e5                	mov    %esp,%ebp
f0100653:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100656:	c7 44 24 08 80 1c 10 	movl   $0xf0101c80,0x8(%esp)
f010065d:	f0 
f010065e:	c7 44 24 04 9e 1c 10 	movl   $0xf0101c9e,0x4(%esp)
f0100665:	f0 
f0100666:	c7 04 24 a3 1c 10 f0 	movl   $0xf0101ca3,(%esp)
f010066d:	e8 40 03 00 00       	call   f01009b2 <cprintf>
f0100672:	c7 44 24 08 1c 1d 10 	movl   $0xf0101d1c,0x8(%esp)
f0100679:	f0 
f010067a:	c7 44 24 04 ac 1c 10 	movl   $0xf0101cac,0x4(%esp)
f0100681:	f0 
f0100682:	c7 04 24 a3 1c 10 f0 	movl   $0xf0101ca3,(%esp)
f0100689:	e8 24 03 00 00       	call   f01009b2 <cprintf>
	return 0;
}
f010068e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100693:	c9                   	leave  
f0100694:	c3                   	ret    

f0100695 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100695:	55                   	push   %ebp
f0100696:	89 e5                	mov    %esp,%ebp
f0100698:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010069b:	c7 04 24 b5 1c 10 f0 	movl   $0xf0101cb5,(%esp)
f01006a2:	e8 0b 03 00 00       	call   f01009b2 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006a7:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01006ae:	00 
f01006af:	c7 04 24 44 1d 10 f0 	movl   $0xf0101d44,(%esp)
f01006b6:	e8 f7 02 00 00       	call   f01009b2 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006bb:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006c2:	00 
f01006c3:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006ca:	f0 
f01006cb:	c7 04 24 6c 1d 10 f0 	movl   $0xf0101d6c,(%esp)
f01006d2:	e8 db 02 00 00       	call   f01009b2 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006d7:	c7 44 24 08 d7 19 10 	movl   $0x1019d7,0x8(%esp)
f01006de:	00 
f01006df:	c7 44 24 04 d7 19 10 	movl   $0xf01019d7,0x4(%esp)
f01006e6:	f0 
f01006e7:	c7 04 24 90 1d 10 f0 	movl   $0xf0101d90,(%esp)
f01006ee:	e8 bf 02 00 00       	call   f01009b2 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006f3:	c7 44 24 08 00 23 11 	movl   $0x112300,0x8(%esp)
f01006fa:	00 
f01006fb:	c7 44 24 04 00 23 11 	movl   $0xf0112300,0x4(%esp)
f0100702:	f0 
f0100703:	c7 04 24 b4 1d 10 f0 	movl   $0xf0101db4,(%esp)
f010070a:	e8 a3 02 00 00       	call   f01009b2 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010070f:	c7 44 24 08 44 29 11 	movl   $0x112944,0x8(%esp)
f0100716:	00 
f0100717:	c7 44 24 04 44 29 11 	movl   $0xf0112944,0x4(%esp)
f010071e:	f0 
f010071f:	c7 04 24 d8 1d 10 f0 	movl   $0xf0101dd8,(%esp)
f0100726:	e8 87 02 00 00       	call   f01009b2 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010072b:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100730:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100735:	c1 f8 0a             	sar    $0xa,%eax
f0100738:	89 44 24 04          	mov    %eax,0x4(%esp)
f010073c:	c7 04 24 fc 1d 10 f0 	movl   $0xf0101dfc,(%esp)
f0100743:	e8 6a 02 00 00       	call   f01009b2 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100748:	b8 00 00 00 00       	mov    $0x0,%eax
f010074d:	c9                   	leave  
f010074e:	c3                   	ret    

f010074f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010074f:	55                   	push   %ebp
f0100750:	89 e5                	mov    %esp,%ebp
f0100752:	57                   	push   %edi
f0100753:	56                   	push   %esi
f0100754:	53                   	push   %ebx
f0100755:	83 ec 6c             	sub    $0x6c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100758:	89 e8                	mov    %ebp,%eax
f010075a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	uint32_t *ptr;
	struct Eipdebuginfo info;

	ebp = read_ebp();
	ptr = (uint32_t*)ebp;
	eip = ptr[1];
f010075d:	8b 70 04             	mov    0x4(%eax),%esi
	arg1 = ptr[2];
f0100760:	8b 50 08             	mov    0x8(%eax),%edx
f0100763:	89 55 c0             	mov    %edx,-0x40(%ebp)
	arg2 = ptr[3];
f0100766:	8b 48 0c             	mov    0xc(%eax),%ecx
f0100769:	89 4d bc             	mov    %ecx,-0x44(%ebp)
	arg3 = ptr[4];
f010076c:	8b 50 10             	mov    0x10(%eax),%edx
f010076f:	89 55 b8             	mov    %edx,-0x48(%ebp)
	arg4 = ptr[5];
f0100772:	8b 78 14             	mov    0x14(%eax),%edi
f0100775:	89 7d b4             	mov    %edi,-0x4c(%ebp)
	arg5 = ptr[6];
f0100778:	8b 78 18             	mov    0x18(%eax),%edi
	ptr = (uint32_t*)ptr[0];
f010077b:	8b 18                	mov    (%eax),%ebx
	cprintf("stack backtrace\n");
f010077d:	c7 04 24 ce 1c 10 f0 	movl   $0xf0101cce,(%esp)
f0100784:	e8 29 02 00 00       	call   f01009b2 <cprintf>
f0100789:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010078c:	8b 55 b8             	mov    -0x48(%ebp),%edx
f010078f:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
	while(ptr != 0) {
f0100792:	eb 57                	jmp    f01007eb <mon_backtrace+0x9c>
	  cprintf("ebp %08x  eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100794:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f0100798:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f010079c:	89 54 24 14          	mov    %edx,0x14(%esp)
f01007a0:	89 44 24 10          	mov    %eax,0x10(%esp)
f01007a4:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01007a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01007ab:	89 74 24 08          	mov    %esi,0x8(%esp)
f01007af:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01007b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007b6:	c7 04 24 28 1e 10 f0 	movl   $0xf0101e28,(%esp)
f01007bd:	e8 f0 01 00 00       	call   f01009b2 <cprintf>
		   arg1, arg2, arg3, arg4, arg5);
		debuginfo_eip(eip, &info);
f01007c2:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01007c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007c9:	89 34 24             	mov    %esi,(%esp)
f01007cc:	e8 d8 02 00 00       	call   f0100aa9 <debuginfo_eip>
		ebp = (uint32_t)ptr;
f01007d1:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
		eip = ptr[1];
f01007d4:	8b 73 04             	mov    0x4(%ebx),%esi
		arg1 = ptr[2];
f01007d7:	8b 43 08             	mov    0x8(%ebx),%eax
f01007da:	89 45 c0             	mov    %eax,-0x40(%ebp)
		arg2 = ptr[3];
f01007dd:	8b 43 0c             	mov    0xc(%ebx),%eax
		arg3 = ptr[4];
f01007e0:	8b 53 10             	mov    0x10(%ebx),%edx
		arg4 = ptr[5];
f01007e3:	8b 4b 14             	mov    0x14(%ebx),%ecx
		arg5 = ptr[6];
f01007e6:	8b 7b 18             	mov    0x18(%ebx),%edi
		ptr = (uint32_t*)ptr[0];		
f01007e9:	8b 1b                	mov    (%ebx),%ebx
	arg3 = ptr[4];
	arg4 = ptr[5];
	arg5 = ptr[6];
	ptr = (uint32_t*)ptr[0];
	cprintf("stack backtrace\n");
	while(ptr != 0) {
f01007eb:	85 db                	test   %ebx,%ebx
f01007ed:	75 a5                	jne    f0100794 <mon_backtrace+0x45>
		arg3 = ptr[4];
		arg4 = ptr[5];
		arg5 = ptr[6];
		ptr = (uint32_t*)ptr[0];		
	}
	cprintf("ebp %08x  eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, 
f01007ef:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f01007f3:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f01007f7:	89 54 24 14          	mov    %edx,0x14(%esp)
f01007fb:	89 44 24 10          	mov    %eax,0x10(%esp)
f01007ff:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100802:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100806:	89 74 24 08          	mov    %esi,0x8(%esp)
f010080a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010080d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100811:	c7 04 24 28 1e 10 f0 	movl   $0xf0101e28,(%esp)
f0100818:	e8 95 01 00 00       	call   f01009b2 <cprintf>
		   arg1, arg2, arg3, arg4, arg5);
	return 0;
}
f010081d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100822:	83 c4 6c             	add    $0x6c,%esp
f0100825:	5b                   	pop    %ebx
f0100826:	5e                   	pop    %esi
f0100827:	5f                   	pop    %edi
f0100828:	5d                   	pop    %ebp
f0100829:	c3                   	ret    

f010082a <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010082a:	55                   	push   %ebp
f010082b:	89 e5                	mov    %esp,%ebp
f010082d:	57                   	push   %edi
f010082e:	56                   	push   %esi
f010082f:	53                   	push   %ebx
f0100830:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100833:	c7 04 24 5c 1e 10 f0 	movl   $0xf0101e5c,(%esp)
f010083a:	e8 73 01 00 00       	call   f01009b2 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010083f:	c7 04 24 80 1e 10 f0 	movl   $0xf0101e80,(%esp)
f0100846:	e8 67 01 00 00       	call   f01009b2 <cprintf>


	while (1) {
		buf = readline("K> ");
f010084b:	c7 04 24 df 1c 10 f0 	movl   $0xf0101cdf,(%esp)
f0100852:	e8 99 0a 00 00       	call   f01012f0 <readline>
f0100857:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100859:	85 c0                	test   %eax,%eax
f010085b:	74 ee                	je     f010084b <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010085d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100864:	be 00 00 00 00       	mov    $0x0,%esi
f0100869:	eb 0a                	jmp    f0100875 <monitor+0x4b>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010086b:	c6 03 00             	movb   $0x0,(%ebx)
f010086e:	89 f7                	mov    %esi,%edi
f0100870:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100873:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100875:	0f b6 03             	movzbl (%ebx),%eax
f0100878:	84 c0                	test   %al,%al
f010087a:	74 63                	je     f01008df <monitor+0xb5>
f010087c:	0f be c0             	movsbl %al,%eax
f010087f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100883:	c7 04 24 e3 1c 10 f0 	movl   $0xf0101ce3,(%esp)
f010088a:	e8 7b 0c 00 00       	call   f010150a <strchr>
f010088f:	85 c0                	test   %eax,%eax
f0100891:	75 d8                	jne    f010086b <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100893:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100896:	74 47                	je     f01008df <monitor+0xb5>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100898:	83 fe 0f             	cmp    $0xf,%esi
f010089b:	75 16                	jne    f01008b3 <monitor+0x89>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010089d:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01008a4:	00 
f01008a5:	c7 04 24 e8 1c 10 f0 	movl   $0xf0101ce8,(%esp)
f01008ac:	e8 01 01 00 00       	call   f01009b2 <cprintf>
f01008b1:	eb 98                	jmp    f010084b <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f01008b3:	8d 7e 01             	lea    0x1(%esi),%edi
f01008b6:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008ba:	eb 03                	jmp    f01008bf <monitor+0x95>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008bc:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008bf:	0f b6 03             	movzbl (%ebx),%eax
f01008c2:	84 c0                	test   %al,%al
f01008c4:	74 ad                	je     f0100873 <monitor+0x49>
f01008c6:	0f be c0             	movsbl %al,%eax
f01008c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008cd:	c7 04 24 e3 1c 10 f0 	movl   $0xf0101ce3,(%esp)
f01008d4:	e8 31 0c 00 00       	call   f010150a <strchr>
f01008d9:	85 c0                	test   %eax,%eax
f01008db:	74 df                	je     f01008bc <monitor+0x92>
f01008dd:	eb 94                	jmp    f0100873 <monitor+0x49>
			buf++;
	}
	argv[argc] = 0;
f01008df:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008e6:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008e7:	85 f6                	test   %esi,%esi
f01008e9:	0f 84 5c ff ff ff    	je     f010084b <monitor+0x21>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008ef:	c7 44 24 04 9e 1c 10 	movl   $0xf0101c9e,0x4(%esp)
f01008f6:	f0 
f01008f7:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008fa:	89 04 24             	mov    %eax,(%esp)
f01008fd:	e8 aa 0b 00 00       	call   f01014ac <strcmp>
f0100902:	85 c0                	test   %eax,%eax
f0100904:	74 1b                	je     f0100921 <monitor+0xf7>
f0100906:	c7 44 24 04 ac 1c 10 	movl   $0xf0101cac,0x4(%esp)
f010090d:	f0 
f010090e:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100911:	89 04 24             	mov    %eax,(%esp)
f0100914:	e8 93 0b 00 00       	call   f01014ac <strcmp>
f0100919:	85 c0                	test   %eax,%eax
f010091b:	75 2f                	jne    f010094c <monitor+0x122>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010091d:	b0 01                	mov    $0x1,%al
f010091f:	eb 05                	jmp    f0100926 <monitor+0xfc>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100921:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100926:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100929:	01 d0                	add    %edx,%eax
f010092b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010092e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100932:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100935:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100939:	89 34 24             	mov    %esi,(%esp)
f010093c:	ff 14 85 b0 1e 10 f0 	call   *-0xfefe150(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100943:	85 c0                	test   %eax,%eax
f0100945:	78 1d                	js     f0100964 <monitor+0x13a>
f0100947:	e9 ff fe ff ff       	jmp    f010084b <monitor+0x21>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010094c:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010094f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100953:	c7 04 24 05 1d 10 f0 	movl   $0xf0101d05,(%esp)
f010095a:	e8 53 00 00 00       	call   f01009b2 <cprintf>
f010095f:	e9 e7 fe ff ff       	jmp    f010084b <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100964:	83 c4 5c             	add    $0x5c,%esp
f0100967:	5b                   	pop    %ebx
f0100968:	5e                   	pop    %esi
f0100969:	5f                   	pop    %edi
f010096a:	5d                   	pop    %ebp
f010096b:	c3                   	ret    

f010096c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010096c:	55                   	push   %ebp
f010096d:	89 e5                	mov    %esp,%ebp
f010096f:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0100972:	8b 45 08             	mov    0x8(%ebp),%eax
f0100975:	89 04 24             	mov    %eax,(%esp)
f0100978:	e8 a6 fc ff ff       	call   f0100623 <cputchar>
	*cnt++;
}
f010097d:	c9                   	leave  
f010097e:	c3                   	ret    

f010097f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010097f:	55                   	push   %ebp
f0100980:	89 e5                	mov    %esp,%ebp
f0100982:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100985:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010098c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010098f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100993:	8b 45 08             	mov    0x8(%ebp),%eax
f0100996:	89 44 24 08          	mov    %eax,0x8(%esp)
f010099a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010099d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009a1:	c7 04 24 6c 09 10 f0 	movl   $0xf010096c,(%esp)
f01009a8:	e8 f1 04 00 00       	call   f0100e9e <vprintfmt>
	return cnt;
}
f01009ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01009b0:	c9                   	leave  
f01009b1:	c3                   	ret    

f01009b2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01009b2:	55                   	push   %ebp
f01009b3:	89 e5                	mov    %esp,%ebp
f01009b5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01009b8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01009bb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01009c2:	89 04 24             	mov    %eax,(%esp)
f01009c5:	e8 b5 ff ff ff       	call   f010097f <vcprintf>
	va_end(ap);

	return cnt;
}
f01009ca:	c9                   	leave  
f01009cb:	c3                   	ret    

f01009cc <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009cc:	55                   	push   %ebp
f01009cd:	89 e5                	mov    %esp,%ebp
f01009cf:	57                   	push   %edi
f01009d0:	56                   	push   %esi
f01009d1:	53                   	push   %ebx
f01009d2:	83 ec 10             	sub    $0x10,%esp
f01009d5:	89 c6                	mov    %eax,%esi
f01009d7:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01009da:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01009dd:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009e0:	8b 1a                	mov    (%edx),%ebx
f01009e2:	8b 01                	mov    (%ecx),%eax
f01009e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009e7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f01009ee:	eb 77                	jmp    f0100a67 <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f01009f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009f3:	01 d8                	add    %ebx,%eax
f01009f5:	b9 02 00 00 00       	mov    $0x2,%ecx
f01009fa:	99                   	cltd   
f01009fb:	f7 f9                	idiv   %ecx
f01009fd:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009ff:	eb 01                	jmp    f0100a02 <stab_binsearch+0x36>
			m--;
f0100a01:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a02:	39 d9                	cmp    %ebx,%ecx
f0100a04:	7c 1d                	jl     f0100a23 <stab_binsearch+0x57>
f0100a06:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0100a09:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0100a0e:	39 fa                	cmp    %edi,%edx
f0100a10:	75 ef                	jne    f0100a01 <stab_binsearch+0x35>
f0100a12:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a15:	6b d1 0c             	imul   $0xc,%ecx,%edx
f0100a18:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f0100a1c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100a1f:	73 18                	jae    f0100a39 <stab_binsearch+0x6d>
f0100a21:	eb 05                	jmp    f0100a28 <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a23:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f0100a26:	eb 3f                	jmp    f0100a67 <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100a28:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100a2b:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f0100a2d:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a30:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100a37:	eb 2e                	jmp    f0100a67 <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a39:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a3c:	73 15                	jae    f0100a53 <stab_binsearch+0x87>
			*region_right = m - 1;
f0100a3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100a41:	48                   	dec    %eax
f0100a42:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a45:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100a48:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a4a:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100a51:	eb 14                	jmp    f0100a67 <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a53:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100a56:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0100a59:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0100a5b:	ff 45 0c             	incl   0xc(%ebp)
f0100a5e:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a60:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a67:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a6a:	7e 84                	jle    f01009f0 <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a6c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100a70:	75 0d                	jne    f0100a7f <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0100a72:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100a75:	8b 00                	mov    (%eax),%eax
f0100a77:	48                   	dec    %eax
f0100a78:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100a7b:	89 07                	mov    %eax,(%edi)
f0100a7d:	eb 22                	jmp    f0100aa1 <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a82:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a84:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100a87:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a89:	eb 01                	jmp    f0100a8c <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a8b:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a8c:	39 c1                	cmp    %eax,%ecx
f0100a8e:	7d 0c                	jge    f0100a9c <stab_binsearch+0xd0>
f0100a90:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f0100a93:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f0100a98:	39 fa                	cmp    %edi,%edx
f0100a9a:	75 ef                	jne    f0100a8b <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a9c:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0100a9f:	89 07                	mov    %eax,(%edi)
	}
}
f0100aa1:	83 c4 10             	add    $0x10,%esp
f0100aa4:	5b                   	pop    %ebx
f0100aa5:	5e                   	pop    %esi
f0100aa6:	5f                   	pop    %edi
f0100aa7:	5d                   	pop    %ebp
f0100aa8:	c3                   	ret    

f0100aa9 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100aa9:	55                   	push   %ebp
f0100aaa:	89 e5                	mov    %esp,%ebp
f0100aac:	57                   	push   %edi
f0100aad:	56                   	push   %esi
f0100aae:	53                   	push   %ebx
f0100aaf:	83 ec 3c             	sub    $0x3c,%esp
f0100ab2:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ab5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100ab8:	c7 03 c0 1e 10 f0    	movl   $0xf0101ec0,(%ebx)
	info->eip_line = 0;
f0100abe:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100ac5:	c7 43 08 c0 1e 10 f0 	movl   $0xf0101ec0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100acc:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100ad3:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100ad6:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100add:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100ae3:	76 72                	jbe    f0100b57 <debuginfo_eip+0xae>
		cprintf("addr %x\n", addr);
f0100ae5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ae9:	c7 04 24 ca 1e 10 f0 	movl   $0xf0101eca,(%esp)
f0100af0:	e8 bd fe ff ff       	call   f01009b2 <cprintf>
		stabs = __STAB_BEGIN__;
		cprintf(" begin  %x\n", stabs);
f0100af5:	c7 44 24 04 50 21 10 	movl   $0xf0102150,0x4(%esp)
f0100afc:	f0 
f0100afd:	c7 04 24 d3 1e 10 f0 	movl   $0xf0101ed3,(%esp)
f0100b04:	e8 a9 fe ff ff       	call   f01009b2 <cprintf>
		stab_end = __STAB_END__;
		cprintf(" end %x\n", stab_end);
f0100b09:	c7 44 24 04 4c 5b 10 	movl   $0xf0105b4c,0x4(%esp)
f0100b10:	f0 
f0100b11:	c7 04 24 df 1e 10 f0 	movl   $0xf0101edf,(%esp)
f0100b18:	e8 95 fe ff ff       	call   f01009b2 <cprintf>
		stabstr = __STABSTR_BEGIN__;
		cprintf(" str %x\n", stabstr);
f0100b1d:	c7 44 24 04 4d 5b 10 	movl   $0xf0105b4d,0x4(%esp)
f0100b24:	f0 
f0100b25:	c7 04 24 e8 1e 10 f0 	movl   $0xf0101ee8,(%esp)
f0100b2c:	e8 81 fe ff ff       	call   f01009b2 <cprintf>
		stabstr_end = __STABSTR_END__;
		cprintf("strend %x\n", stabstr_end);
f0100b31:	c7 44 24 04 6e 74 10 	movl   $0xf010746e,0x4(%esp)
f0100b38:	f0 
f0100b39:	c7 04 24 f1 1e 10 f0 	movl   $0xf0101ef1,(%esp)
f0100b40:	e8 6d fe ff ff       	call   f01009b2 <cprintf>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b45:	b8 6e 74 10 f0       	mov    $0xf010746e,%eax
f0100b4a:	3d 4d 5b 10 f0       	cmp    $0xf0105b4d,%eax
f0100b4f:	0f 86 b1 01 00 00    	jbe    f0100d06 <debuginfo_eip+0x25d>
f0100b55:	eb 1c                	jmp    f0100b73 <debuginfo_eip+0xca>
		cprintf(" str %x\n", stabstr);
		stabstr_end = __STABSTR_END__;
		cprintf("strend %x\n", stabstr_end);
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b57:	c7 44 24 08 fc 1e 10 	movl   $0xf0101efc,0x8(%esp)
f0100b5e:	f0 
f0100b5f:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
f0100b66:	00 
f0100b67:	c7 04 24 09 1f 10 f0 	movl   $0xf0101f09,(%esp)
f0100b6e:	e8 60 f5 ff ff       	call   f01000d3 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b73:	80 3d 6d 74 10 f0 00 	cmpb   $0x0,0xf010746d
f0100b7a:	0f 85 8d 01 00 00    	jne    f0100d0d <debuginfo_eip+0x264>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b80:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b87:	b8 4c 5b 10 f0       	mov    $0xf0105b4c,%eax
f0100b8c:	2d 50 21 10 f0       	sub    $0xf0102150,%eax
f0100b91:	c1 f8 02             	sar    $0x2,%eax
f0100b94:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b9a:	83 e8 01             	sub    $0x1,%eax
f0100b9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100ba0:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ba4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100bab:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100bae:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100bb1:	b8 50 21 10 f0       	mov    $0xf0102150,%eax
f0100bb6:	e8 11 fe ff ff       	call   f01009cc <stab_binsearch>
	if (lfile == 0)
f0100bbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bbe:	85 c0                	test   %eax,%eax
f0100bc0:	0f 84 4e 01 00 00    	je     f0100d14 <debuginfo_eip+0x26b>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100bc6:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100bc9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bcc:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100bcf:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100bd3:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100bda:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100bdd:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100be0:	b8 50 21 10 f0       	mov    $0xf0102150,%eax
f0100be5:	e8 e2 fd ff ff       	call   f01009cc <stab_binsearch>

	if (lfun <= rfun) {
f0100bea:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100bed:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100bf0:	39 d0                	cmp    %edx,%eax
f0100bf2:	7f 3d                	jg     f0100c31 <debuginfo_eip+0x188>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100bf4:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0100bf7:	8d b9 50 21 10 f0    	lea    -0xfefdeb0(%ecx),%edi
f0100bfd:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100c00:	8b 89 50 21 10 f0    	mov    -0xfefdeb0(%ecx),%ecx
f0100c06:	bf 6e 74 10 f0       	mov    $0xf010746e,%edi
f0100c0b:	81 ef 4d 5b 10 f0    	sub    $0xf0105b4d,%edi
f0100c11:	39 f9                	cmp    %edi,%ecx
f0100c13:	73 09                	jae    f0100c1e <debuginfo_eip+0x175>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100c15:	81 c1 4d 5b 10 f0    	add    $0xf0105b4d,%ecx
f0100c1b:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100c1e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100c21:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100c24:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100c27:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100c29:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100c2c:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100c2f:	eb 0f                	jmp    f0100c40 <debuginfo_eip+0x197>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100c31:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100c34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c37:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100c3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c3d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c40:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100c47:	00 
f0100c48:	8b 43 08             	mov    0x8(%ebx),%eax
f0100c4b:	89 04 24             	mov    %eax,(%esp)
f0100c4e:	e8 d8 08 00 00       	call   f010152b <strfind>
f0100c53:	2b 43 08             	sub    0x8(%ebx),%eax
f0100c56:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SO, addr);
f0100c59:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100c5d:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100c64:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100c67:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100c6a:	b8 50 21 10 f0       	mov    $0xf0102150,%eax
f0100c6f:	e8 58 fd ff ff       	call   f01009cc <stab_binsearch>
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c77:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100c7a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c7d:	6b d0 0c             	imul   $0xc,%eax,%edx
f0100c80:	81 c2 50 21 10 f0    	add    $0xf0102150,%edx
f0100c86:	eb 06                	jmp    f0100c8e <debuginfo_eip+0x1e5>
f0100c88:	83 e8 01             	sub    $0x1,%eax
f0100c8b:	83 ea 0c             	sub    $0xc,%edx
f0100c8e:	89 c6                	mov    %eax,%esi
f0100c90:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100c93:	7f 33                	jg     f0100cc8 <debuginfo_eip+0x21f>
	       && stabs[lline].n_type != N_SOL
f0100c95:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100c99:	80 f9 84             	cmp    $0x84,%cl
f0100c9c:	74 0b                	je     f0100ca9 <debuginfo_eip+0x200>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c9e:	80 f9 64             	cmp    $0x64,%cl
f0100ca1:	75 e5                	jne    f0100c88 <debuginfo_eip+0x1df>
f0100ca3:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0100ca7:	74 df                	je     f0100c88 <debuginfo_eip+0x1df>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100ca9:	6b f6 0c             	imul   $0xc,%esi,%esi
f0100cac:	8b 86 50 21 10 f0    	mov    -0xfefdeb0(%esi),%eax
f0100cb2:	ba 6e 74 10 f0       	mov    $0xf010746e,%edx
f0100cb7:	81 ea 4d 5b 10 f0    	sub    $0xf0105b4d,%edx
f0100cbd:	39 d0                	cmp    %edx,%eax
f0100cbf:	73 07                	jae    f0100cc8 <debuginfo_eip+0x21f>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100cc1:	05 4d 5b 10 f0       	add    $0xf0105b4d,%eax
f0100cc6:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100cc8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ccb:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cce:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100cd3:	39 ca                	cmp    %ecx,%edx
f0100cd5:	7d 49                	jge    f0100d20 <debuginfo_eip+0x277>
		for (lline = lfun + 1;
f0100cd7:	8d 42 01             	lea    0x1(%edx),%eax
f0100cda:	89 c2                	mov    %eax,%edx
f0100cdc:	6b c0 0c             	imul   $0xc,%eax,%eax
f0100cdf:	05 50 21 10 f0       	add    $0xf0102150,%eax
f0100ce4:	89 ce                	mov    %ecx,%esi
f0100ce6:	eb 04                	jmp    f0100cec <debuginfo_eip+0x243>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100ce8:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100cec:	39 d6                	cmp    %edx,%esi
f0100cee:	7e 2b                	jle    f0100d1b <debuginfo_eip+0x272>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100cf0:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100cf4:	83 c2 01             	add    $0x1,%edx
f0100cf7:	83 c0 0c             	add    $0xc,%eax
f0100cfa:	80 f9 a0             	cmp    $0xa0,%cl
f0100cfd:	74 e9                	je     f0100ce8 <debuginfo_eip+0x23f>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cff:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d04:	eb 1a                	jmp    f0100d20 <debuginfo_eip+0x277>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100d06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d0b:	eb 13                	jmp    f0100d20 <debuginfo_eip+0x277>
f0100d0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d12:	eb 0c                	jmp    f0100d20 <debuginfo_eip+0x277>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100d14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d19:	eb 05                	jmp    f0100d20 <debuginfo_eip+0x277>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d20:	83 c4 3c             	add    $0x3c,%esp
f0100d23:	5b                   	pop    %ebx
f0100d24:	5e                   	pop    %esi
f0100d25:	5f                   	pop    %edi
f0100d26:	5d                   	pop    %ebp
f0100d27:	c3                   	ret    
f0100d28:	66 90                	xchg   %ax,%ax
f0100d2a:	66 90                	xchg   %ax,%ax
f0100d2c:	66 90                	xchg   %ax,%ax
f0100d2e:	66 90                	xchg   %ax,%ax

f0100d30 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100d30:	55                   	push   %ebp
f0100d31:	89 e5                	mov    %esp,%ebp
f0100d33:	57                   	push   %edi
f0100d34:	56                   	push   %esi
f0100d35:	53                   	push   %ebx
f0100d36:	83 ec 3c             	sub    $0x3c,%esp
f0100d39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d3c:	89 d7                	mov    %edx,%edi
f0100d3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d41:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d44:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d47:	89 c3                	mov    %eax,%ebx
f0100d49:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100d4c:	8b 45 10             	mov    0x10(%ebp),%eax
f0100d4f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100d52:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100d57:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100d5a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100d5d:	39 d9                	cmp    %ebx,%ecx
f0100d5f:	72 05                	jb     f0100d66 <printnum+0x36>
f0100d61:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0100d64:	77 69                	ja     f0100dcf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d66:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0100d69:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0100d6d:	83 ee 01             	sub    $0x1,%esi
f0100d70:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100d74:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d78:	8b 44 24 08          	mov    0x8(%esp),%eax
f0100d7c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0100d80:	89 c3                	mov    %eax,%ebx
f0100d82:	89 d6                	mov    %edx,%esi
f0100d84:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100d87:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100d8a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100d8e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100d92:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d95:	89 04 24             	mov    %eax,(%esp)
f0100d98:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d9b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d9f:	e8 ac 09 00 00       	call   f0101750 <__udivdi3>
f0100da4:	89 d9                	mov    %ebx,%ecx
f0100da6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0100daa:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100dae:	89 04 24             	mov    %eax,(%esp)
f0100db1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100db5:	89 fa                	mov    %edi,%edx
f0100db7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100dba:	e8 71 ff ff ff       	call   f0100d30 <printnum>
f0100dbf:	eb 1b                	jmp    f0100ddc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100dc1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100dc5:	8b 45 18             	mov    0x18(%ebp),%eax
f0100dc8:	89 04 24             	mov    %eax,(%esp)
f0100dcb:	ff d3                	call   *%ebx
f0100dcd:	eb 03                	jmp    f0100dd2 <printnum+0xa2>
f0100dcf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100dd2:	83 ee 01             	sub    $0x1,%esi
f0100dd5:	85 f6                	test   %esi,%esi
f0100dd7:	7f e8                	jg     f0100dc1 <printnum+0x91>
f0100dd9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100ddc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100de0:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100de4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100de7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100dea:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100dee:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100df2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100df5:	89 04 24             	mov    %eax,(%esp)
f0100df8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100dfb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dff:	e8 7c 0a 00 00       	call   f0101880 <__umoddi3>
f0100e04:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100e08:	0f be 80 17 1f 10 f0 	movsbl -0xfefe0e9(%eax),%eax
f0100e0f:	89 04 24             	mov    %eax,(%esp)
f0100e12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e15:	ff d0                	call   *%eax
}
f0100e17:	83 c4 3c             	add    $0x3c,%esp
f0100e1a:	5b                   	pop    %ebx
f0100e1b:	5e                   	pop    %esi
f0100e1c:	5f                   	pop    %edi
f0100e1d:	5d                   	pop    %ebp
f0100e1e:	c3                   	ret    

f0100e1f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100e1f:	55                   	push   %ebp
f0100e20:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100e22:	83 fa 01             	cmp    $0x1,%edx
f0100e25:	7e 0e                	jle    f0100e35 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100e27:	8b 10                	mov    (%eax),%edx
f0100e29:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100e2c:	89 08                	mov    %ecx,(%eax)
f0100e2e:	8b 02                	mov    (%edx),%eax
f0100e30:	8b 52 04             	mov    0x4(%edx),%edx
f0100e33:	eb 22                	jmp    f0100e57 <getuint+0x38>
	else if (lflag)
f0100e35:	85 d2                	test   %edx,%edx
f0100e37:	74 10                	je     f0100e49 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100e39:	8b 10                	mov    (%eax),%edx
f0100e3b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100e3e:	89 08                	mov    %ecx,(%eax)
f0100e40:	8b 02                	mov    (%edx),%eax
f0100e42:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e47:	eb 0e                	jmp    f0100e57 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100e49:	8b 10                	mov    (%eax),%edx
f0100e4b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100e4e:	89 08                	mov    %ecx,(%eax)
f0100e50:	8b 02                	mov    (%edx),%eax
f0100e52:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100e57:	5d                   	pop    %ebp
f0100e58:	c3                   	ret    

f0100e59 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100e59:	55                   	push   %ebp
f0100e5a:	89 e5                	mov    %esp,%ebp
f0100e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100e5f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100e63:	8b 10                	mov    (%eax),%edx
f0100e65:	3b 50 04             	cmp    0x4(%eax),%edx
f0100e68:	73 0a                	jae    f0100e74 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100e6a:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100e6d:	89 08                	mov    %ecx,(%eax)
f0100e6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e72:	88 02                	mov    %al,(%edx)
}
f0100e74:	5d                   	pop    %ebp
f0100e75:	c3                   	ret    

f0100e76 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100e76:	55                   	push   %ebp
f0100e77:	89 e5                	mov    %esp,%ebp
f0100e79:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0100e7c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100e7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e83:	8b 45 10             	mov    0x10(%ebp),%eax
f0100e86:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100e91:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e94:	89 04 24             	mov    %eax,(%esp)
f0100e97:	e8 02 00 00 00       	call   f0100e9e <vprintfmt>
	va_end(ap);
}
f0100e9c:	c9                   	leave  
f0100e9d:	c3                   	ret    

f0100e9e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100e9e:	55                   	push   %ebp
f0100e9f:	89 e5                	mov    %esp,%ebp
f0100ea1:	57                   	push   %edi
f0100ea2:	56                   	push   %esi
f0100ea3:	53                   	push   %ebx
f0100ea4:	83 ec 3c             	sub    $0x3c,%esp
f0100ea7:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100eaa:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0100ead:	eb 14                	jmp    f0100ec3 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100eaf:	85 c0                	test   %eax,%eax
f0100eb1:	0f 84 a9 03 00 00    	je     f0101260 <vprintfmt+0x3c2>
				return;
			putch(ch, putdat);
f0100eb7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100ebb:	89 04 24             	mov    %eax,(%esp)
f0100ebe:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100ec1:	89 f3                	mov    %esi,%ebx
f0100ec3:	8d 73 01             	lea    0x1(%ebx),%esi
f0100ec6:	0f b6 03             	movzbl (%ebx),%eax
f0100ec9:	83 f8 25             	cmp    $0x25,%eax
f0100ecc:	75 e1                	jne    f0100eaf <vprintfmt+0x11>
f0100ece:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0100ed2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100ed9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0100ee0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0100ee7:	ba 00 00 00 00       	mov    $0x0,%edx
f0100eec:	eb 1d                	jmp    f0100f0b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eee:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100ef0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0100ef4:	eb 15                	jmp    f0100f0b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ef6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100ef8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0100efc:	eb 0d                	jmp    f0100f0b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100efe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100f01:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100f04:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f0b:	8d 5e 01             	lea    0x1(%esi),%ebx
f0100f0e:	0f b6 0e             	movzbl (%esi),%ecx
f0100f11:	0f b6 c1             	movzbl %cl,%eax
f0100f14:	83 e9 23             	sub    $0x23,%ecx
f0100f17:	80 f9 55             	cmp    $0x55,%cl
f0100f1a:	0f 87 20 03 00 00    	ja     f0101240 <vprintfmt+0x3a2>
f0100f20:	0f b6 c9             	movzbl %cl,%ecx
f0100f23:	ff 24 8d c0 1f 10 f0 	jmp    *-0xfefe040(,%ecx,4)
f0100f2a:	89 de                	mov    %ebx,%esi
f0100f2c:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100f31:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0100f34:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0100f38:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0100f3b:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0100f3e:	83 fb 09             	cmp    $0x9,%ebx
f0100f41:	77 31                	ja     f0100f74 <vprintfmt+0xd6>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100f43:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100f46:	eb e9                	jmp    f0100f31 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100f48:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f4b:	8d 48 04             	lea    0x4(%eax),%ecx
f0100f4e:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100f51:	8b 00                	mov    (%eax),%eax
f0100f53:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f56:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100f58:	eb 1d                	jmp    f0100f77 <vprintfmt+0xd9>
f0100f5a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f5d:	c1 f8 1f             	sar    $0x1f,%eax
f0100f60:	f7 d0                	not    %eax
f0100f62:	21 45 dc             	and    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f65:	89 de                	mov    %ebx,%esi
f0100f67:	eb a2                	jmp    f0100f0b <vprintfmt+0x6d>
f0100f69:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100f6b:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0100f72:	eb 97                	jmp    f0100f0b <vprintfmt+0x6d>
f0100f74:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f0100f77:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100f7b:	79 8e                	jns    f0100f0b <vprintfmt+0x6d>
f0100f7d:	e9 7c ff ff ff       	jmp    f0100efe <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100f82:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f85:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100f87:	eb 82                	jmp    f0100f0b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100f89:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f8c:	8d 50 04             	lea    0x4(%eax),%edx
f0100f8f:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f92:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100f96:	8b 00                	mov    (%eax),%eax
f0100f98:	89 04 24             	mov    %eax,(%esp)
f0100f9b:	ff 55 08             	call   *0x8(%ebp)
			break;
f0100f9e:	e9 20 ff ff ff       	jmp    f0100ec3 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100fa3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fa6:	8d 50 04             	lea    0x4(%eax),%edx
f0100fa9:	89 55 14             	mov    %edx,0x14(%ebp)
f0100fac:	8b 00                	mov    (%eax),%eax
f0100fae:	99                   	cltd   
f0100faf:	31 d0                	xor    %edx,%eax
f0100fb1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100fb3:	83 f8 07             	cmp    $0x7,%eax
f0100fb6:	7f 0b                	jg     f0100fc3 <vprintfmt+0x125>
f0100fb8:	8b 14 85 20 21 10 f0 	mov    -0xfefdee0(,%eax,4),%edx
f0100fbf:	85 d2                	test   %edx,%edx
f0100fc1:	75 20                	jne    f0100fe3 <vprintfmt+0x145>
				printfmt(putch, putdat, "error %d", err);
f0100fc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fc7:	c7 44 24 08 2f 1f 10 	movl   $0xf0101f2f,0x8(%esp)
f0100fce:	f0 
f0100fcf:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100fd3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fd6:	89 04 24             	mov    %eax,(%esp)
f0100fd9:	e8 98 fe ff ff       	call   f0100e76 <printfmt>
f0100fde:	e9 e0 fe ff ff       	jmp    f0100ec3 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0100fe3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100fe7:	c7 44 24 08 38 1f 10 	movl   $0xf0101f38,0x8(%esp)
f0100fee:	f0 
f0100fef:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100ff3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ff6:	89 04 24             	mov    %eax,(%esp)
f0100ff9:	e8 78 fe ff ff       	call   f0100e76 <printfmt>
f0100ffe:	e9 c0 fe ff ff       	jmp    f0100ec3 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101003:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101006:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101009:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010100c:	8b 45 14             	mov    0x14(%ebp),%eax
f010100f:	8d 50 04             	lea    0x4(%eax),%edx
f0101012:	89 55 14             	mov    %edx,0x14(%ebp)
f0101015:	8b 30                	mov    (%eax),%esi
f0101017:	85 f6                	test   %esi,%esi
f0101019:	75 05                	jne    f0101020 <vprintfmt+0x182>
				p = "(null)";
f010101b:	be 28 1f 10 f0       	mov    $0xf0101f28,%esi
			if (width > 0 && padc != '-')
f0101020:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0101024:	0f 84 96 00 00 00    	je     f01010c0 <vprintfmt+0x222>
f010102a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010102e:	0f 8e 9a 00 00 00    	jle    f01010ce <vprintfmt+0x230>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101034:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101038:	89 34 24             	mov    %esi,(%esp)
f010103b:	e8 98 03 00 00       	call   f01013d8 <strnlen>
f0101040:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101043:	29 c2                	sub    %eax,%edx
f0101045:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
f0101048:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f010104c:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010104f:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0101052:	8b 75 08             	mov    0x8(%ebp),%esi
f0101055:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101058:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010105a:	eb 0f                	jmp    f010106b <vprintfmt+0x1cd>
					putch(padc, putdat);
f010105c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101060:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101063:	89 04 24             	mov    %eax,(%esp)
f0101066:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101068:	83 eb 01             	sub    $0x1,%ebx
f010106b:	85 db                	test   %ebx,%ebx
f010106d:	7f ed                	jg     f010105c <vprintfmt+0x1be>
f010106f:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0101072:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101075:	89 d0                	mov    %edx,%eax
f0101077:	c1 f8 1f             	sar    $0x1f,%eax
f010107a:	f7 d0                	not    %eax
f010107c:	21 d0                	and    %edx,%eax
f010107e:	29 c2                	sub    %eax,%edx
f0101080:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0101083:	89 d7                	mov    %edx,%edi
f0101085:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101088:	eb 50                	jmp    f01010da <vprintfmt+0x23c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010108a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010108e:	74 1e                	je     f01010ae <vprintfmt+0x210>
f0101090:	0f be d2             	movsbl %dl,%edx
f0101093:	83 ea 20             	sub    $0x20,%edx
f0101096:	83 fa 5e             	cmp    $0x5e,%edx
f0101099:	76 13                	jbe    f01010ae <vprintfmt+0x210>
					putch('?', putdat);
f010109b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010109e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010a2:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01010a9:	ff 55 08             	call   *0x8(%ebp)
f01010ac:	eb 0d                	jmp    f01010bb <vprintfmt+0x21d>
				else
					putch(ch, putdat);
f01010ae:	8b 55 0c             	mov    0xc(%ebp),%edx
f01010b1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01010b5:	89 04 24             	mov    %eax,(%esp)
f01010b8:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01010bb:	83 ef 01             	sub    $0x1,%edi
f01010be:	eb 1a                	jmp    f01010da <vprintfmt+0x23c>
f01010c0:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01010c3:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01010c6:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01010c9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01010cc:	eb 0c                	jmp    f01010da <vprintfmt+0x23c>
f01010ce:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01010d1:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01010d4:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01010d7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01010da:	83 c6 01             	add    $0x1,%esi
f01010dd:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f01010e1:	0f be c2             	movsbl %dl,%eax
f01010e4:	85 c0                	test   %eax,%eax
f01010e6:	74 27                	je     f010110f <vprintfmt+0x271>
f01010e8:	85 db                	test   %ebx,%ebx
f01010ea:	78 9e                	js     f010108a <vprintfmt+0x1ec>
f01010ec:	83 eb 01             	sub    $0x1,%ebx
f01010ef:	79 99                	jns    f010108a <vprintfmt+0x1ec>
f01010f1:	89 f8                	mov    %edi,%eax
f01010f3:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01010f6:	8b 75 08             	mov    0x8(%ebp),%esi
f01010f9:	89 c3                	mov    %eax,%ebx
f01010fb:	eb 1a                	jmp    f0101117 <vprintfmt+0x279>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01010fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101101:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101108:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010110a:	83 eb 01             	sub    $0x1,%ebx
f010110d:	eb 08                	jmp    f0101117 <vprintfmt+0x279>
f010110f:	89 fb                	mov    %edi,%ebx
f0101111:	8b 75 08             	mov    0x8(%ebp),%esi
f0101114:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101117:	85 db                	test   %ebx,%ebx
f0101119:	7f e2                	jg     f01010fd <vprintfmt+0x25f>
f010111b:	89 75 08             	mov    %esi,0x8(%ebp)
f010111e:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0101121:	e9 9d fd ff ff       	jmp    f0100ec3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101126:	83 fa 01             	cmp    $0x1,%edx
f0101129:	7e 16                	jle    f0101141 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
f010112b:	8b 45 14             	mov    0x14(%ebp),%eax
f010112e:	8d 50 08             	lea    0x8(%eax),%edx
f0101131:	89 55 14             	mov    %edx,0x14(%ebp)
f0101134:	8b 50 04             	mov    0x4(%eax),%edx
f0101137:	8b 00                	mov    (%eax),%eax
f0101139:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010113c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010113f:	eb 32                	jmp    f0101173 <vprintfmt+0x2d5>
	else if (lflag)
f0101141:	85 d2                	test   %edx,%edx
f0101143:	74 18                	je     f010115d <vprintfmt+0x2bf>
		return va_arg(*ap, long);
f0101145:	8b 45 14             	mov    0x14(%ebp),%eax
f0101148:	8d 50 04             	lea    0x4(%eax),%edx
f010114b:	89 55 14             	mov    %edx,0x14(%ebp)
f010114e:	8b 30                	mov    (%eax),%esi
f0101150:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0101153:	89 f0                	mov    %esi,%eax
f0101155:	c1 f8 1f             	sar    $0x1f,%eax
f0101158:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010115b:	eb 16                	jmp    f0101173 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
f010115d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101160:	8d 50 04             	lea    0x4(%eax),%edx
f0101163:	89 55 14             	mov    %edx,0x14(%ebp)
f0101166:	8b 30                	mov    (%eax),%esi
f0101168:	89 75 e0             	mov    %esi,-0x20(%ebp)
f010116b:	89 f0                	mov    %esi,%eax
f010116d:	c1 f8 1f             	sar    $0x1f,%eax
f0101170:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101173:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101176:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101179:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010117e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101182:	0f 89 80 00 00 00    	jns    f0101208 <vprintfmt+0x36a>
				putch('-', putdat);
f0101188:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010118c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101193:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101196:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101199:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010119c:	f7 d8                	neg    %eax
f010119e:	83 d2 00             	adc    $0x0,%edx
f01011a1:	f7 da                	neg    %edx
			}
			base = 10;
f01011a3:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01011a8:	eb 5e                	jmp    f0101208 <vprintfmt+0x36a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01011aa:	8d 45 14             	lea    0x14(%ebp),%eax
f01011ad:	e8 6d fc ff ff       	call   f0100e1f <getuint>
			base = 10;
f01011b2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01011b7:	eb 4f                	jmp    f0101208 <vprintfmt+0x36a>
		case 'o':
			// Replace this with your code.
			//putch('X', putdat);
			//putch('X', putdat);
			//putch('X', putdat);
				num = getuint(&ap, lflag);
f01011b9:	8d 45 14             	lea    0x14(%ebp),%eax
f01011bc:	e8 5e fc ff ff       	call   f0100e1f <getuint>
				base = 8;
f01011c1:	b9 08 00 00 00       	mov    $0x8,%ecx
				goto number;
f01011c6:	eb 40                	jmp    f0101208 <vprintfmt+0x36a>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f01011c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01011cc:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01011d3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01011d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01011da:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01011e1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01011e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01011e7:	8d 50 04             	lea    0x4(%eax),%edx
f01011ea:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01011ed:	8b 00                	mov    (%eax),%eax
f01011ef:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01011f4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01011f9:	eb 0d                	jmp    f0101208 <vprintfmt+0x36a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01011fb:	8d 45 14             	lea    0x14(%ebp),%eax
f01011fe:	e8 1c fc ff ff       	call   f0100e1f <getuint>
			base = 16;
f0101203:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101208:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f010120c:	89 74 24 10          	mov    %esi,0x10(%esp)
f0101210:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0101213:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101217:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010121b:	89 04 24             	mov    %eax,(%esp)
f010121e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101222:	89 fa                	mov    %edi,%edx
f0101224:	8b 45 08             	mov    0x8(%ebp),%eax
f0101227:	e8 04 fb ff ff       	call   f0100d30 <printnum>
			break;
f010122c:	e9 92 fc ff ff       	jmp    f0100ec3 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101231:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101235:	89 04 24             	mov    %eax,(%esp)
f0101238:	ff 55 08             	call   *0x8(%ebp)
			break;
f010123b:	e9 83 fc ff ff       	jmp    f0100ec3 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101240:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101244:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f010124b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010124e:	89 f3                	mov    %esi,%ebx
f0101250:	eb 03                	jmp    f0101255 <vprintfmt+0x3b7>
f0101252:	83 eb 01             	sub    $0x1,%ebx
f0101255:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0101259:	75 f7                	jne    f0101252 <vprintfmt+0x3b4>
f010125b:	e9 63 fc ff ff       	jmp    f0100ec3 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0101260:	83 c4 3c             	add    $0x3c,%esp
f0101263:	5b                   	pop    %ebx
f0101264:	5e                   	pop    %esi
f0101265:	5f                   	pop    %edi
f0101266:	5d                   	pop    %ebp
f0101267:	c3                   	ret    

f0101268 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101268:	55                   	push   %ebp
f0101269:	89 e5                	mov    %esp,%ebp
f010126b:	83 ec 28             	sub    $0x28,%esp
f010126e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101271:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101274:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101277:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010127b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010127e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101285:	85 c0                	test   %eax,%eax
f0101287:	74 30                	je     f01012b9 <vsnprintf+0x51>
f0101289:	85 d2                	test   %edx,%edx
f010128b:	7e 2c                	jle    f01012b9 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010128d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101290:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101294:	8b 45 10             	mov    0x10(%ebp),%eax
f0101297:	89 44 24 08          	mov    %eax,0x8(%esp)
f010129b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010129e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012a2:	c7 04 24 59 0e 10 f0 	movl   $0xf0100e59,(%esp)
f01012a9:	e8 f0 fb ff ff       	call   f0100e9e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01012ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01012b1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01012b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01012b7:	eb 05                	jmp    f01012be <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01012b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01012be:	c9                   	leave  
f01012bf:	c3                   	ret    

f01012c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01012c0:	55                   	push   %ebp
f01012c1:	89 e5                	mov    %esp,%ebp
f01012c3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01012c6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01012c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012cd:	8b 45 10             	mov    0x10(%ebp),%eax
f01012d0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01012d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012db:	8b 45 08             	mov    0x8(%ebp),%eax
f01012de:	89 04 24             	mov    %eax,(%esp)
f01012e1:	e8 82 ff ff ff       	call   f0101268 <vsnprintf>
	va_end(ap);

	return rc;
}
f01012e6:	c9                   	leave  
f01012e7:	c3                   	ret    
f01012e8:	66 90                	xchg   %ax,%ax
f01012ea:	66 90                	xchg   %ax,%ax
f01012ec:	66 90                	xchg   %ax,%ax
f01012ee:	66 90                	xchg   %ax,%ax

f01012f0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01012f0:	55                   	push   %ebp
f01012f1:	89 e5                	mov    %esp,%ebp
f01012f3:	57                   	push   %edi
f01012f4:	56                   	push   %esi
f01012f5:	53                   	push   %ebx
f01012f6:	83 ec 1c             	sub    $0x1c,%esp
f01012f9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01012fc:	85 c0                	test   %eax,%eax
f01012fe:	74 10                	je     f0101310 <readline+0x20>
		cprintf("%s", prompt);
f0101300:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101304:	c7 04 24 38 1f 10 f0 	movl   $0xf0101f38,(%esp)
f010130b:	e8 a2 f6 ff ff       	call   f01009b2 <cprintf>

	i = 0;
	echoing = iscons(0);
f0101310:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101317:	e8 28 f3 ff ff       	call   f0100644 <iscons>
f010131c:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010131e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101323:	e8 0b f3 ff ff       	call   f0100633 <getchar>
f0101328:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010132a:	85 c0                	test   %eax,%eax
f010132c:	79 17                	jns    f0101345 <readline+0x55>
			cprintf("read error: %e\n", c);
f010132e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101332:	c7 04 24 40 21 10 f0 	movl   $0xf0102140,(%esp)
f0101339:	e8 74 f6 ff ff       	call   f01009b2 <cprintf>
			return NULL;
f010133e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101343:	eb 6d                	jmp    f01013b2 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101345:	83 f8 7f             	cmp    $0x7f,%eax
f0101348:	74 05                	je     f010134f <readline+0x5f>
f010134a:	83 f8 08             	cmp    $0x8,%eax
f010134d:	75 19                	jne    f0101368 <readline+0x78>
f010134f:	85 f6                	test   %esi,%esi
f0101351:	7e 15                	jle    f0101368 <readline+0x78>
			if (echoing)
f0101353:	85 ff                	test   %edi,%edi
f0101355:	74 0c                	je     f0101363 <readline+0x73>
				cputchar('\b');
f0101357:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010135e:	e8 c0 f2 ff ff       	call   f0100623 <cputchar>
			i--;
f0101363:	83 ee 01             	sub    $0x1,%esi
f0101366:	eb bb                	jmp    f0101323 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101368:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010136e:	7f 1c                	jg     f010138c <readline+0x9c>
f0101370:	83 fb 1f             	cmp    $0x1f,%ebx
f0101373:	7e 17                	jle    f010138c <readline+0x9c>
			if (echoing)
f0101375:	85 ff                	test   %edi,%edi
f0101377:	74 08                	je     f0101381 <readline+0x91>
				cputchar(c);
f0101379:	89 1c 24             	mov    %ebx,(%esp)
f010137c:	e8 a2 f2 ff ff       	call   f0100623 <cputchar>
			buf[i++] = c;
f0101381:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101387:	8d 76 01             	lea    0x1(%esi),%esi
f010138a:	eb 97                	jmp    f0101323 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010138c:	83 fb 0d             	cmp    $0xd,%ebx
f010138f:	74 05                	je     f0101396 <readline+0xa6>
f0101391:	83 fb 0a             	cmp    $0xa,%ebx
f0101394:	75 8d                	jne    f0101323 <readline+0x33>
			if (echoing)
f0101396:	85 ff                	test   %edi,%edi
f0101398:	74 0c                	je     f01013a6 <readline+0xb6>
				cputchar('\n');
f010139a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01013a1:	e8 7d f2 ff ff       	call   f0100623 <cputchar>
			buf[i] = 0;
f01013a6:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01013ad:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f01013b2:	83 c4 1c             	add    $0x1c,%esp
f01013b5:	5b                   	pop    %ebx
f01013b6:	5e                   	pop    %esi
f01013b7:	5f                   	pop    %edi
f01013b8:	5d                   	pop    %ebp
f01013b9:	c3                   	ret    
f01013ba:	66 90                	xchg   %ax,%ax
f01013bc:	66 90                	xchg   %ax,%ax
f01013be:	66 90                	xchg   %ax,%ax

f01013c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01013c0:	55                   	push   %ebp
f01013c1:	89 e5                	mov    %esp,%ebp
f01013c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01013c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01013cb:	eb 03                	jmp    f01013d0 <strlen+0x10>
		n++;
f01013cd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01013d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01013d4:	75 f7                	jne    f01013cd <strlen+0xd>
		n++;
	return n;
}
f01013d6:	5d                   	pop    %ebp
f01013d7:	c3                   	ret    

f01013d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01013d8:	55                   	push   %ebp
f01013d9:	89 e5                	mov    %esp,%ebp
f01013db:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01013e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01013e6:	eb 03                	jmp    f01013eb <strnlen+0x13>
		n++;
f01013e8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01013eb:	39 d0                	cmp    %edx,%eax
f01013ed:	74 06                	je     f01013f5 <strnlen+0x1d>
f01013ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01013f3:	75 f3                	jne    f01013e8 <strnlen+0x10>
		n++;
	return n;
}
f01013f5:	5d                   	pop    %ebp
f01013f6:	c3                   	ret    

f01013f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01013f7:	55                   	push   %ebp
f01013f8:	89 e5                	mov    %esp,%ebp
f01013fa:	53                   	push   %ebx
f01013fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01013fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101401:	89 c2                	mov    %eax,%edx
f0101403:	83 c2 01             	add    $0x1,%edx
f0101406:	83 c1 01             	add    $0x1,%ecx
f0101409:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010140d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101410:	84 db                	test   %bl,%bl
f0101412:	75 ef                	jne    f0101403 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101414:	5b                   	pop    %ebx
f0101415:	5d                   	pop    %ebp
f0101416:	c3                   	ret    

f0101417 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101417:	55                   	push   %ebp
f0101418:	89 e5                	mov    %esp,%ebp
f010141a:	53                   	push   %ebx
f010141b:	83 ec 08             	sub    $0x8,%esp
f010141e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101421:	89 1c 24             	mov    %ebx,(%esp)
f0101424:	e8 97 ff ff ff       	call   f01013c0 <strlen>
	strcpy(dst + len, src);
f0101429:	8b 55 0c             	mov    0xc(%ebp),%edx
f010142c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101430:	01 d8                	add    %ebx,%eax
f0101432:	89 04 24             	mov    %eax,(%esp)
f0101435:	e8 bd ff ff ff       	call   f01013f7 <strcpy>
	return dst;
}
f010143a:	89 d8                	mov    %ebx,%eax
f010143c:	83 c4 08             	add    $0x8,%esp
f010143f:	5b                   	pop    %ebx
f0101440:	5d                   	pop    %ebp
f0101441:	c3                   	ret    

f0101442 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101442:	55                   	push   %ebp
f0101443:	89 e5                	mov    %esp,%ebp
f0101445:	56                   	push   %esi
f0101446:	53                   	push   %ebx
f0101447:	8b 75 08             	mov    0x8(%ebp),%esi
f010144a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010144d:	89 f3                	mov    %esi,%ebx
f010144f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101452:	89 f2                	mov    %esi,%edx
f0101454:	eb 0f                	jmp    f0101465 <strncpy+0x23>
		*dst++ = *src;
f0101456:	83 c2 01             	add    $0x1,%edx
f0101459:	0f b6 01             	movzbl (%ecx),%eax
f010145c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010145f:	80 39 01             	cmpb   $0x1,(%ecx)
f0101462:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101465:	39 da                	cmp    %ebx,%edx
f0101467:	75 ed                	jne    f0101456 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101469:	89 f0                	mov    %esi,%eax
f010146b:	5b                   	pop    %ebx
f010146c:	5e                   	pop    %esi
f010146d:	5d                   	pop    %ebp
f010146e:	c3                   	ret    

f010146f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010146f:	55                   	push   %ebp
f0101470:	89 e5                	mov    %esp,%ebp
f0101472:	56                   	push   %esi
f0101473:	53                   	push   %ebx
f0101474:	8b 75 08             	mov    0x8(%ebp),%esi
f0101477:	8b 55 0c             	mov    0xc(%ebp),%edx
f010147a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010147d:	89 f0                	mov    %esi,%eax
f010147f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101483:	85 c9                	test   %ecx,%ecx
f0101485:	75 0b                	jne    f0101492 <strlcpy+0x23>
f0101487:	eb 1d                	jmp    f01014a6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101489:	83 c0 01             	add    $0x1,%eax
f010148c:	83 c2 01             	add    $0x1,%edx
f010148f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101492:	39 d8                	cmp    %ebx,%eax
f0101494:	74 0b                	je     f01014a1 <strlcpy+0x32>
f0101496:	0f b6 0a             	movzbl (%edx),%ecx
f0101499:	84 c9                	test   %cl,%cl
f010149b:	75 ec                	jne    f0101489 <strlcpy+0x1a>
f010149d:	89 c2                	mov    %eax,%edx
f010149f:	eb 02                	jmp    f01014a3 <strlcpy+0x34>
f01014a1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f01014a3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f01014a6:	29 f0                	sub    %esi,%eax
}
f01014a8:	5b                   	pop    %ebx
f01014a9:	5e                   	pop    %esi
f01014aa:	5d                   	pop    %ebp
f01014ab:	c3                   	ret    

f01014ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01014ac:	55                   	push   %ebp
f01014ad:	89 e5                	mov    %esp,%ebp
f01014af:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01014b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01014b5:	eb 06                	jmp    f01014bd <strcmp+0x11>
		p++, q++;
f01014b7:	83 c1 01             	add    $0x1,%ecx
f01014ba:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01014bd:	0f b6 01             	movzbl (%ecx),%eax
f01014c0:	84 c0                	test   %al,%al
f01014c2:	74 04                	je     f01014c8 <strcmp+0x1c>
f01014c4:	3a 02                	cmp    (%edx),%al
f01014c6:	74 ef                	je     f01014b7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01014c8:	0f b6 c0             	movzbl %al,%eax
f01014cb:	0f b6 12             	movzbl (%edx),%edx
f01014ce:	29 d0                	sub    %edx,%eax
}
f01014d0:	5d                   	pop    %ebp
f01014d1:	c3                   	ret    

f01014d2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01014d2:	55                   	push   %ebp
f01014d3:	89 e5                	mov    %esp,%ebp
f01014d5:	53                   	push   %ebx
f01014d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01014d9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014dc:	89 c3                	mov    %eax,%ebx
f01014de:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01014e1:	eb 06                	jmp    f01014e9 <strncmp+0x17>
		n--, p++, q++;
f01014e3:	83 c0 01             	add    $0x1,%eax
f01014e6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01014e9:	39 d8                	cmp    %ebx,%eax
f01014eb:	74 15                	je     f0101502 <strncmp+0x30>
f01014ed:	0f b6 08             	movzbl (%eax),%ecx
f01014f0:	84 c9                	test   %cl,%cl
f01014f2:	74 04                	je     f01014f8 <strncmp+0x26>
f01014f4:	3a 0a                	cmp    (%edx),%cl
f01014f6:	74 eb                	je     f01014e3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01014f8:	0f b6 00             	movzbl (%eax),%eax
f01014fb:	0f b6 12             	movzbl (%edx),%edx
f01014fe:	29 d0                	sub    %edx,%eax
f0101500:	eb 05                	jmp    f0101507 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101502:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101507:	5b                   	pop    %ebx
f0101508:	5d                   	pop    %ebp
f0101509:	c3                   	ret    

f010150a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010150a:	55                   	push   %ebp
f010150b:	89 e5                	mov    %esp,%ebp
f010150d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101510:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101514:	eb 07                	jmp    f010151d <strchr+0x13>
		if (*s == c)
f0101516:	38 ca                	cmp    %cl,%dl
f0101518:	74 0f                	je     f0101529 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010151a:	83 c0 01             	add    $0x1,%eax
f010151d:	0f b6 10             	movzbl (%eax),%edx
f0101520:	84 d2                	test   %dl,%dl
f0101522:	75 f2                	jne    f0101516 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101524:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101529:	5d                   	pop    %ebp
f010152a:	c3                   	ret    

f010152b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010152b:	55                   	push   %ebp
f010152c:	89 e5                	mov    %esp,%ebp
f010152e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101531:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101535:	eb 07                	jmp    f010153e <strfind+0x13>
		if (*s == c)
f0101537:	38 ca                	cmp    %cl,%dl
f0101539:	74 0a                	je     f0101545 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010153b:	83 c0 01             	add    $0x1,%eax
f010153e:	0f b6 10             	movzbl (%eax),%edx
f0101541:	84 d2                	test   %dl,%dl
f0101543:	75 f2                	jne    f0101537 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0101545:	5d                   	pop    %ebp
f0101546:	c3                   	ret    

f0101547 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101547:	55                   	push   %ebp
f0101548:	89 e5                	mov    %esp,%ebp
f010154a:	57                   	push   %edi
f010154b:	56                   	push   %esi
f010154c:	53                   	push   %ebx
f010154d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101550:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101553:	85 c9                	test   %ecx,%ecx
f0101555:	74 36                	je     f010158d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101557:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010155d:	75 28                	jne    f0101587 <memset+0x40>
f010155f:	f6 c1 03             	test   $0x3,%cl
f0101562:	75 23                	jne    f0101587 <memset+0x40>
		c &= 0xFF;
f0101564:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101568:	89 d3                	mov    %edx,%ebx
f010156a:	c1 e3 08             	shl    $0x8,%ebx
f010156d:	89 d6                	mov    %edx,%esi
f010156f:	c1 e6 18             	shl    $0x18,%esi
f0101572:	89 d0                	mov    %edx,%eax
f0101574:	c1 e0 10             	shl    $0x10,%eax
f0101577:	09 f0                	or     %esi,%eax
f0101579:	09 c2                	or     %eax,%edx
f010157b:	89 d0                	mov    %edx,%eax
f010157d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010157f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101582:	fc                   	cld    
f0101583:	f3 ab                	rep stos %eax,%es:(%edi)
f0101585:	eb 06                	jmp    f010158d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101587:	8b 45 0c             	mov    0xc(%ebp),%eax
f010158a:	fc                   	cld    
f010158b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010158d:	89 f8                	mov    %edi,%eax
f010158f:	5b                   	pop    %ebx
f0101590:	5e                   	pop    %esi
f0101591:	5f                   	pop    %edi
f0101592:	5d                   	pop    %ebp
f0101593:	c3                   	ret    

f0101594 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101594:	55                   	push   %ebp
f0101595:	89 e5                	mov    %esp,%ebp
f0101597:	57                   	push   %edi
f0101598:	56                   	push   %esi
f0101599:	8b 45 08             	mov    0x8(%ebp),%eax
f010159c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010159f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01015a2:	39 c6                	cmp    %eax,%esi
f01015a4:	73 35                	jae    f01015db <memmove+0x47>
f01015a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01015a9:	39 d0                	cmp    %edx,%eax
f01015ab:	73 2e                	jae    f01015db <memmove+0x47>
		s += n;
		d += n;
f01015ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f01015b0:	89 d6                	mov    %edx,%esi
f01015b2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01015b4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01015ba:	75 13                	jne    f01015cf <memmove+0x3b>
f01015bc:	f6 c1 03             	test   $0x3,%cl
f01015bf:	75 0e                	jne    f01015cf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01015c1:	83 ef 04             	sub    $0x4,%edi
f01015c4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01015c7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01015ca:	fd                   	std    
f01015cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01015cd:	eb 09                	jmp    f01015d8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01015cf:	83 ef 01             	sub    $0x1,%edi
f01015d2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01015d5:	fd                   	std    
f01015d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01015d8:	fc                   	cld    
f01015d9:	eb 1d                	jmp    f01015f8 <memmove+0x64>
f01015db:	89 f2                	mov    %esi,%edx
f01015dd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01015df:	f6 c2 03             	test   $0x3,%dl
f01015e2:	75 0f                	jne    f01015f3 <memmove+0x5f>
f01015e4:	f6 c1 03             	test   $0x3,%cl
f01015e7:	75 0a                	jne    f01015f3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01015e9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01015ec:	89 c7                	mov    %eax,%edi
f01015ee:	fc                   	cld    
f01015ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01015f1:	eb 05                	jmp    f01015f8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01015f3:	89 c7                	mov    %eax,%edi
f01015f5:	fc                   	cld    
f01015f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01015f8:	5e                   	pop    %esi
f01015f9:	5f                   	pop    %edi
f01015fa:	5d                   	pop    %ebp
f01015fb:	c3                   	ret    

f01015fc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01015fc:	55                   	push   %ebp
f01015fd:	89 e5                	mov    %esp,%ebp
f01015ff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101602:	8b 45 10             	mov    0x10(%ebp),%eax
f0101605:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101609:	8b 45 0c             	mov    0xc(%ebp),%eax
f010160c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101610:	8b 45 08             	mov    0x8(%ebp),%eax
f0101613:	89 04 24             	mov    %eax,(%esp)
f0101616:	e8 79 ff ff ff       	call   f0101594 <memmove>
}
f010161b:	c9                   	leave  
f010161c:	c3                   	ret    

f010161d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010161d:	55                   	push   %ebp
f010161e:	89 e5                	mov    %esp,%ebp
f0101620:	56                   	push   %esi
f0101621:	53                   	push   %ebx
f0101622:	8b 55 08             	mov    0x8(%ebp),%edx
f0101625:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101628:	89 d6                	mov    %edx,%esi
f010162a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010162d:	eb 1a                	jmp    f0101649 <memcmp+0x2c>
		if (*s1 != *s2)
f010162f:	0f b6 02             	movzbl (%edx),%eax
f0101632:	0f b6 19             	movzbl (%ecx),%ebx
f0101635:	38 d8                	cmp    %bl,%al
f0101637:	74 0a                	je     f0101643 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0101639:	0f b6 c0             	movzbl %al,%eax
f010163c:	0f b6 db             	movzbl %bl,%ebx
f010163f:	29 d8                	sub    %ebx,%eax
f0101641:	eb 0f                	jmp    f0101652 <memcmp+0x35>
		s1++, s2++;
f0101643:	83 c2 01             	add    $0x1,%edx
f0101646:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101649:	39 f2                	cmp    %esi,%edx
f010164b:	75 e2                	jne    f010162f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010164d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101652:	5b                   	pop    %ebx
f0101653:	5e                   	pop    %esi
f0101654:	5d                   	pop    %ebp
f0101655:	c3                   	ret    

f0101656 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101656:	55                   	push   %ebp
f0101657:	89 e5                	mov    %esp,%ebp
f0101659:	8b 45 08             	mov    0x8(%ebp),%eax
f010165c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010165f:	89 c2                	mov    %eax,%edx
f0101661:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101664:	eb 07                	jmp    f010166d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101666:	38 08                	cmp    %cl,(%eax)
f0101668:	74 07                	je     f0101671 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010166a:	83 c0 01             	add    $0x1,%eax
f010166d:	39 d0                	cmp    %edx,%eax
f010166f:	72 f5                	jb     f0101666 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101671:	5d                   	pop    %ebp
f0101672:	c3                   	ret    

f0101673 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101673:	55                   	push   %ebp
f0101674:	89 e5                	mov    %esp,%ebp
f0101676:	57                   	push   %edi
f0101677:	56                   	push   %esi
f0101678:	53                   	push   %ebx
f0101679:	8b 55 08             	mov    0x8(%ebp),%edx
f010167c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010167f:	eb 03                	jmp    f0101684 <strtol+0x11>
		s++;
f0101681:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101684:	0f b6 02             	movzbl (%edx),%eax
f0101687:	3c 09                	cmp    $0x9,%al
f0101689:	74 f6                	je     f0101681 <strtol+0xe>
f010168b:	3c 20                	cmp    $0x20,%al
f010168d:	74 f2                	je     f0101681 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010168f:	3c 2b                	cmp    $0x2b,%al
f0101691:	75 0a                	jne    f010169d <strtol+0x2a>
		s++;
f0101693:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101696:	bf 00 00 00 00       	mov    $0x0,%edi
f010169b:	eb 10                	jmp    f01016ad <strtol+0x3a>
f010169d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01016a2:	3c 2d                	cmp    $0x2d,%al
f01016a4:	75 07                	jne    f01016ad <strtol+0x3a>
		s++, neg = 1;
f01016a6:	8d 52 01             	lea    0x1(%edx),%edx
f01016a9:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01016ad:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01016b3:	75 15                	jne    f01016ca <strtol+0x57>
f01016b5:	80 3a 30             	cmpb   $0x30,(%edx)
f01016b8:	75 10                	jne    f01016ca <strtol+0x57>
f01016ba:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01016be:	75 0a                	jne    f01016ca <strtol+0x57>
		s += 2, base = 16;
f01016c0:	83 c2 02             	add    $0x2,%edx
f01016c3:	bb 10 00 00 00       	mov    $0x10,%ebx
f01016c8:	eb 10                	jmp    f01016da <strtol+0x67>
	else if (base == 0 && s[0] == '0')
f01016ca:	85 db                	test   %ebx,%ebx
f01016cc:	75 0c                	jne    f01016da <strtol+0x67>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01016ce:	b3 0a                	mov    $0xa,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01016d0:	80 3a 30             	cmpb   $0x30,(%edx)
f01016d3:	75 05                	jne    f01016da <strtol+0x67>
		s++, base = 8;
f01016d5:	83 c2 01             	add    $0x1,%edx
f01016d8:	b3 08                	mov    $0x8,%bl
	else if (base == 0)
		base = 10;
f01016da:	b8 00 00 00 00       	mov    $0x0,%eax
f01016df:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01016e2:	0f b6 0a             	movzbl (%edx),%ecx
f01016e5:	8d 71 d0             	lea    -0x30(%ecx),%esi
f01016e8:	89 f3                	mov    %esi,%ebx
f01016ea:	80 fb 09             	cmp    $0x9,%bl
f01016ed:	77 08                	ja     f01016f7 <strtol+0x84>
			dig = *s - '0';
f01016ef:	0f be c9             	movsbl %cl,%ecx
f01016f2:	83 e9 30             	sub    $0x30,%ecx
f01016f5:	eb 22                	jmp    f0101719 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f01016f7:	8d 71 9f             	lea    -0x61(%ecx),%esi
f01016fa:	89 f3                	mov    %esi,%ebx
f01016fc:	80 fb 19             	cmp    $0x19,%bl
f01016ff:	77 08                	ja     f0101709 <strtol+0x96>
			dig = *s - 'a' + 10;
f0101701:	0f be c9             	movsbl %cl,%ecx
f0101704:	83 e9 57             	sub    $0x57,%ecx
f0101707:	eb 10                	jmp    f0101719 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0101709:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010170c:	89 f3                	mov    %esi,%ebx
f010170e:	80 fb 19             	cmp    $0x19,%bl
f0101711:	77 16                	ja     f0101729 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0101713:	0f be c9             	movsbl %cl,%ecx
f0101716:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101719:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f010171c:	7d 0f                	jge    f010172d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f010171e:	83 c2 01             	add    $0x1,%edx
f0101721:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101725:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0101727:	eb b9                	jmp    f01016e2 <strtol+0x6f>
f0101729:	89 c1                	mov    %eax,%ecx
f010172b:	eb 02                	jmp    f010172f <strtol+0xbc>
f010172d:	89 c1                	mov    %eax,%ecx

	if (endptr)
f010172f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101733:	74 05                	je     f010173a <strtol+0xc7>
		*endptr = (char *) s;
f0101735:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101738:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f010173a:	85 ff                	test   %edi,%edi
f010173c:	74 04                	je     f0101742 <strtol+0xcf>
f010173e:	89 c8                	mov    %ecx,%eax
f0101740:	f7 d8                	neg    %eax
}
f0101742:	5b                   	pop    %ebx
f0101743:	5e                   	pop    %esi
f0101744:	5f                   	pop    %edi
f0101745:	5d                   	pop    %ebp
f0101746:	c3                   	ret    
f0101747:	66 90                	xchg   %ax,%ax
f0101749:	66 90                	xchg   %ax,%ax
f010174b:	66 90                	xchg   %ax,%ax
f010174d:	66 90                	xchg   %ax,%ax
f010174f:	90                   	nop

f0101750 <__udivdi3>:
f0101750:	55                   	push   %ebp
f0101751:	57                   	push   %edi
f0101752:	56                   	push   %esi
f0101753:	83 ec 0c             	sub    $0xc,%esp
f0101756:	8b 44 24 28          	mov    0x28(%esp),%eax
f010175a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010175e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0101762:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0101766:	85 c0                	test   %eax,%eax
f0101768:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010176c:	89 ea                	mov    %ebp,%edx
f010176e:	89 0c 24             	mov    %ecx,(%esp)
f0101771:	75 2d                	jne    f01017a0 <__udivdi3+0x50>
f0101773:	39 e9                	cmp    %ebp,%ecx
f0101775:	77 61                	ja     f01017d8 <__udivdi3+0x88>
f0101777:	85 c9                	test   %ecx,%ecx
f0101779:	89 ce                	mov    %ecx,%esi
f010177b:	75 0b                	jne    f0101788 <__udivdi3+0x38>
f010177d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101782:	31 d2                	xor    %edx,%edx
f0101784:	f7 f1                	div    %ecx
f0101786:	89 c6                	mov    %eax,%esi
f0101788:	31 d2                	xor    %edx,%edx
f010178a:	89 e8                	mov    %ebp,%eax
f010178c:	f7 f6                	div    %esi
f010178e:	89 c5                	mov    %eax,%ebp
f0101790:	89 f8                	mov    %edi,%eax
f0101792:	f7 f6                	div    %esi
f0101794:	89 ea                	mov    %ebp,%edx
f0101796:	83 c4 0c             	add    $0xc,%esp
f0101799:	5e                   	pop    %esi
f010179a:	5f                   	pop    %edi
f010179b:	5d                   	pop    %ebp
f010179c:	c3                   	ret    
f010179d:	8d 76 00             	lea    0x0(%esi),%esi
f01017a0:	39 e8                	cmp    %ebp,%eax
f01017a2:	77 24                	ja     f01017c8 <__udivdi3+0x78>
f01017a4:	0f bd e8             	bsr    %eax,%ebp
f01017a7:	83 f5 1f             	xor    $0x1f,%ebp
f01017aa:	75 3c                	jne    f01017e8 <__udivdi3+0x98>
f01017ac:	8b 74 24 04          	mov    0x4(%esp),%esi
f01017b0:	39 34 24             	cmp    %esi,(%esp)
f01017b3:	0f 86 9f 00 00 00    	jbe    f0101858 <__udivdi3+0x108>
f01017b9:	39 d0                	cmp    %edx,%eax
f01017bb:	0f 82 97 00 00 00    	jb     f0101858 <__udivdi3+0x108>
f01017c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017c8:	31 d2                	xor    %edx,%edx
f01017ca:	31 c0                	xor    %eax,%eax
f01017cc:	83 c4 0c             	add    $0xc,%esp
f01017cf:	5e                   	pop    %esi
f01017d0:	5f                   	pop    %edi
f01017d1:	5d                   	pop    %ebp
f01017d2:	c3                   	ret    
f01017d3:	90                   	nop
f01017d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017d8:	89 f8                	mov    %edi,%eax
f01017da:	f7 f1                	div    %ecx
f01017dc:	31 d2                	xor    %edx,%edx
f01017de:	83 c4 0c             	add    $0xc,%esp
f01017e1:	5e                   	pop    %esi
f01017e2:	5f                   	pop    %edi
f01017e3:	5d                   	pop    %ebp
f01017e4:	c3                   	ret    
f01017e5:	8d 76 00             	lea    0x0(%esi),%esi
f01017e8:	89 e9                	mov    %ebp,%ecx
f01017ea:	8b 3c 24             	mov    (%esp),%edi
f01017ed:	d3 e0                	shl    %cl,%eax
f01017ef:	89 c6                	mov    %eax,%esi
f01017f1:	b8 20 00 00 00       	mov    $0x20,%eax
f01017f6:	29 e8                	sub    %ebp,%eax
f01017f8:	89 c1                	mov    %eax,%ecx
f01017fa:	d3 ef                	shr    %cl,%edi
f01017fc:	89 e9                	mov    %ebp,%ecx
f01017fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101802:	8b 3c 24             	mov    (%esp),%edi
f0101805:	09 74 24 08          	or     %esi,0x8(%esp)
f0101809:	89 d6                	mov    %edx,%esi
f010180b:	d3 e7                	shl    %cl,%edi
f010180d:	89 c1                	mov    %eax,%ecx
f010180f:	89 3c 24             	mov    %edi,(%esp)
f0101812:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101816:	d3 ee                	shr    %cl,%esi
f0101818:	89 e9                	mov    %ebp,%ecx
f010181a:	d3 e2                	shl    %cl,%edx
f010181c:	89 c1                	mov    %eax,%ecx
f010181e:	d3 ef                	shr    %cl,%edi
f0101820:	09 d7                	or     %edx,%edi
f0101822:	89 f2                	mov    %esi,%edx
f0101824:	89 f8                	mov    %edi,%eax
f0101826:	f7 74 24 08          	divl   0x8(%esp)
f010182a:	89 d6                	mov    %edx,%esi
f010182c:	89 c7                	mov    %eax,%edi
f010182e:	f7 24 24             	mull   (%esp)
f0101831:	39 d6                	cmp    %edx,%esi
f0101833:	89 14 24             	mov    %edx,(%esp)
f0101836:	72 30                	jb     f0101868 <__udivdi3+0x118>
f0101838:	8b 54 24 04          	mov    0x4(%esp),%edx
f010183c:	89 e9                	mov    %ebp,%ecx
f010183e:	d3 e2                	shl    %cl,%edx
f0101840:	39 c2                	cmp    %eax,%edx
f0101842:	73 05                	jae    f0101849 <__udivdi3+0xf9>
f0101844:	3b 34 24             	cmp    (%esp),%esi
f0101847:	74 1f                	je     f0101868 <__udivdi3+0x118>
f0101849:	89 f8                	mov    %edi,%eax
f010184b:	31 d2                	xor    %edx,%edx
f010184d:	e9 7a ff ff ff       	jmp    f01017cc <__udivdi3+0x7c>
f0101852:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101858:	31 d2                	xor    %edx,%edx
f010185a:	b8 01 00 00 00       	mov    $0x1,%eax
f010185f:	e9 68 ff ff ff       	jmp    f01017cc <__udivdi3+0x7c>
f0101864:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101868:	8d 47 ff             	lea    -0x1(%edi),%eax
f010186b:	31 d2                	xor    %edx,%edx
f010186d:	83 c4 0c             	add    $0xc,%esp
f0101870:	5e                   	pop    %esi
f0101871:	5f                   	pop    %edi
f0101872:	5d                   	pop    %ebp
f0101873:	c3                   	ret    
f0101874:	66 90                	xchg   %ax,%ax
f0101876:	66 90                	xchg   %ax,%ax
f0101878:	66 90                	xchg   %ax,%ax
f010187a:	66 90                	xchg   %ax,%ax
f010187c:	66 90                	xchg   %ax,%ax
f010187e:	66 90                	xchg   %ax,%ax

f0101880 <__umoddi3>:
f0101880:	55                   	push   %ebp
f0101881:	57                   	push   %edi
f0101882:	56                   	push   %esi
f0101883:	83 ec 14             	sub    $0x14,%esp
f0101886:	8b 44 24 28          	mov    0x28(%esp),%eax
f010188a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010188e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0101892:	89 c7                	mov    %eax,%edi
f0101894:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101898:	8b 44 24 30          	mov    0x30(%esp),%eax
f010189c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01018a0:	89 34 24             	mov    %esi,(%esp)
f01018a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01018a7:	85 c0                	test   %eax,%eax
f01018a9:	89 c2                	mov    %eax,%edx
f01018ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01018af:	75 17                	jne    f01018c8 <__umoddi3+0x48>
f01018b1:	39 fe                	cmp    %edi,%esi
f01018b3:	76 4b                	jbe    f0101900 <__umoddi3+0x80>
f01018b5:	89 c8                	mov    %ecx,%eax
f01018b7:	89 fa                	mov    %edi,%edx
f01018b9:	f7 f6                	div    %esi
f01018bb:	89 d0                	mov    %edx,%eax
f01018bd:	31 d2                	xor    %edx,%edx
f01018bf:	83 c4 14             	add    $0x14,%esp
f01018c2:	5e                   	pop    %esi
f01018c3:	5f                   	pop    %edi
f01018c4:	5d                   	pop    %ebp
f01018c5:	c3                   	ret    
f01018c6:	66 90                	xchg   %ax,%ax
f01018c8:	39 f8                	cmp    %edi,%eax
f01018ca:	77 54                	ja     f0101920 <__umoddi3+0xa0>
f01018cc:	0f bd e8             	bsr    %eax,%ebp
f01018cf:	83 f5 1f             	xor    $0x1f,%ebp
f01018d2:	75 5c                	jne    f0101930 <__umoddi3+0xb0>
f01018d4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01018d8:	39 3c 24             	cmp    %edi,(%esp)
f01018db:	0f 87 e7 00 00 00    	ja     f01019c8 <__umoddi3+0x148>
f01018e1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01018e5:	29 f1                	sub    %esi,%ecx
f01018e7:	19 c7                	sbb    %eax,%edi
f01018e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01018ed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01018f1:	8b 44 24 08          	mov    0x8(%esp),%eax
f01018f5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01018f9:	83 c4 14             	add    $0x14,%esp
f01018fc:	5e                   	pop    %esi
f01018fd:	5f                   	pop    %edi
f01018fe:	5d                   	pop    %ebp
f01018ff:	c3                   	ret    
f0101900:	85 f6                	test   %esi,%esi
f0101902:	89 f5                	mov    %esi,%ebp
f0101904:	75 0b                	jne    f0101911 <__umoddi3+0x91>
f0101906:	b8 01 00 00 00       	mov    $0x1,%eax
f010190b:	31 d2                	xor    %edx,%edx
f010190d:	f7 f6                	div    %esi
f010190f:	89 c5                	mov    %eax,%ebp
f0101911:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101915:	31 d2                	xor    %edx,%edx
f0101917:	f7 f5                	div    %ebp
f0101919:	89 c8                	mov    %ecx,%eax
f010191b:	f7 f5                	div    %ebp
f010191d:	eb 9c                	jmp    f01018bb <__umoddi3+0x3b>
f010191f:	90                   	nop
f0101920:	89 c8                	mov    %ecx,%eax
f0101922:	89 fa                	mov    %edi,%edx
f0101924:	83 c4 14             	add    $0x14,%esp
f0101927:	5e                   	pop    %esi
f0101928:	5f                   	pop    %edi
f0101929:	5d                   	pop    %ebp
f010192a:	c3                   	ret    
f010192b:	90                   	nop
f010192c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101930:	8b 04 24             	mov    (%esp),%eax
f0101933:	be 20 00 00 00       	mov    $0x20,%esi
f0101938:	89 e9                	mov    %ebp,%ecx
f010193a:	29 ee                	sub    %ebp,%esi
f010193c:	d3 e2                	shl    %cl,%edx
f010193e:	89 f1                	mov    %esi,%ecx
f0101940:	d3 e8                	shr    %cl,%eax
f0101942:	89 e9                	mov    %ebp,%ecx
f0101944:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101948:	8b 04 24             	mov    (%esp),%eax
f010194b:	09 54 24 04          	or     %edx,0x4(%esp)
f010194f:	89 fa                	mov    %edi,%edx
f0101951:	d3 e0                	shl    %cl,%eax
f0101953:	89 f1                	mov    %esi,%ecx
f0101955:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101959:	8b 44 24 10          	mov    0x10(%esp),%eax
f010195d:	d3 ea                	shr    %cl,%edx
f010195f:	89 e9                	mov    %ebp,%ecx
f0101961:	d3 e7                	shl    %cl,%edi
f0101963:	89 f1                	mov    %esi,%ecx
f0101965:	d3 e8                	shr    %cl,%eax
f0101967:	89 e9                	mov    %ebp,%ecx
f0101969:	09 f8                	or     %edi,%eax
f010196b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f010196f:	f7 74 24 04          	divl   0x4(%esp)
f0101973:	d3 e7                	shl    %cl,%edi
f0101975:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101979:	89 d7                	mov    %edx,%edi
f010197b:	f7 64 24 08          	mull   0x8(%esp)
f010197f:	39 d7                	cmp    %edx,%edi
f0101981:	89 c1                	mov    %eax,%ecx
f0101983:	89 14 24             	mov    %edx,(%esp)
f0101986:	72 2c                	jb     f01019b4 <__umoddi3+0x134>
f0101988:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010198c:	72 22                	jb     f01019b0 <__umoddi3+0x130>
f010198e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101992:	29 c8                	sub    %ecx,%eax
f0101994:	19 d7                	sbb    %edx,%edi
f0101996:	89 e9                	mov    %ebp,%ecx
f0101998:	89 fa                	mov    %edi,%edx
f010199a:	d3 e8                	shr    %cl,%eax
f010199c:	89 f1                	mov    %esi,%ecx
f010199e:	d3 e2                	shl    %cl,%edx
f01019a0:	89 e9                	mov    %ebp,%ecx
f01019a2:	d3 ef                	shr    %cl,%edi
f01019a4:	09 d0                	or     %edx,%eax
f01019a6:	89 fa                	mov    %edi,%edx
f01019a8:	83 c4 14             	add    $0x14,%esp
f01019ab:	5e                   	pop    %esi
f01019ac:	5f                   	pop    %edi
f01019ad:	5d                   	pop    %ebp
f01019ae:	c3                   	ret    
f01019af:	90                   	nop
f01019b0:	39 d7                	cmp    %edx,%edi
f01019b2:	75 da                	jne    f010198e <__umoddi3+0x10e>
f01019b4:	8b 14 24             	mov    (%esp),%edx
f01019b7:	89 c1                	mov    %eax,%ecx
f01019b9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f01019bd:	1b 54 24 04          	sbb    0x4(%esp),%edx
f01019c1:	eb cb                	jmp    f010198e <__umoddi3+0x10e>
f01019c3:	90                   	nop
f01019c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01019c8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f01019cc:	0f 82 0f ff ff ff    	jb     f01018e1 <__umoddi3+0x61>
f01019d2:	e9 1a ff ff ff       	jmp    f01018f1 <__umoddi3+0x71>
