
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 10 12 00       	mov    $0x121000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 10 12 c0       	mov    %eax,0xc0121000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 00 12 c0       	mov    $0xc0120000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));

static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 30 41 12 c0       	mov    $0xc0124130,%edx
c0100041:	b8 00 30 12 c0       	mov    $0xc0123000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 30 12 c0 	movl   $0xc0123000,(%esp)
c010005d:	e8 ef 8a 00 00       	call   c0108b51 <memset>

    cons_init();                // init the console
c0100062:	e8 91 15 00 00       	call   c01015f8 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 e0 8c 10 c0 	movl   $0xc0108ce0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 fc 8c 10 c0 	movl   $0xc0108cfc,(%esp)
c010007c:	e8 d6 02 00 00       	call   c0100357 <cprintf>

    print_kerninfo();
c0100081:	e8 05 08 00 00       	call   c010088b <print_kerninfo>

    grade_backtrace();
c0100086:	e8 95 00 00 00       	call   c0100120 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 b0 4c 00 00       	call   c0104d40 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 41 1f 00 00       	call   c0101fd6 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 b9 20 00 00       	call   c0102153 <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 fb 74 00 00       	call   c010759a <vmm_init>

    ide_init();                 // init ide devices
c010009f:	e8 85 16 00 00       	call   c0101729 <ide_init>
    swap_init();                // init swap
c01000a4:	e8 04 60 00 00       	call   c01060ad <swap_init>

    clock_init();               // init clock interrupt
c01000a9:	e8 00 0d 00 00       	call   c0100dae <clock_init>
    intr_enable();              // enable irq interrupt
c01000ae:	e8 91 1e 00 00       	call   c0101f44 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000b3:	eb fe                	jmp    c01000b3 <kern_init+0x7d>

c01000b5 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b5:	55                   	push   %ebp
c01000b6:	89 e5                	mov    %esp,%ebp
c01000b8:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000c2:	00 
c01000c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000ca:	00 
c01000cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000d2:	e8 f8 0b 00 00       	call   c0100ccf <mon_backtrace>
}
c01000d7:	c9                   	leave  
c01000d8:	c3                   	ret    

c01000d9 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d9:	55                   	push   %ebp
c01000da:	89 e5                	mov    %esp,%ebp
c01000dc:	53                   	push   %ebx
c01000dd:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e0:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000e6:	8d 55 08             	lea    0x8(%ebp),%edx
c01000e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01000ec:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000f0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000f4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000f8:	89 04 24             	mov    %eax,(%esp)
c01000fb:	e8 b5 ff ff ff       	call   c01000b5 <grade_backtrace2>
}
c0100100:	83 c4 14             	add    $0x14,%esp
c0100103:	5b                   	pop    %ebx
c0100104:	5d                   	pop    %ebp
c0100105:	c3                   	ret    

c0100106 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100106:	55                   	push   %ebp
c0100107:	89 e5                	mov    %esp,%ebp
c0100109:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c010010c:	8b 45 10             	mov    0x10(%ebp),%eax
c010010f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100113:	8b 45 08             	mov    0x8(%ebp),%eax
c0100116:	89 04 24             	mov    %eax,(%esp)
c0100119:	e8 bb ff ff ff       	call   c01000d9 <grade_backtrace1>
}
c010011e:	c9                   	leave  
c010011f:	c3                   	ret    

c0100120 <grade_backtrace>:

void
grade_backtrace(void) {
c0100120:	55                   	push   %ebp
c0100121:	89 e5                	mov    %esp,%ebp
c0100123:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100126:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010012b:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100132:	ff 
c0100133:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100137:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010013e:	e8 c3 ff ff ff       	call   c0100106 <grade_backtrace0>
}
c0100143:	c9                   	leave  
c0100144:	c3                   	ret    

c0100145 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100145:	55                   	push   %ebp
c0100146:	89 e5                	mov    %esp,%ebp
c0100148:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010014b:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010014e:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100151:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100154:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100157:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010015b:	0f b7 c0             	movzwl %ax,%eax
c010015e:	83 e0 03             	and    $0x3,%eax
c0100161:	89 c2                	mov    %eax,%edx
c0100163:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c0100168:	89 54 24 08          	mov    %edx,0x8(%esp)
c010016c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100170:	c7 04 24 01 8d 10 c0 	movl   $0xc0108d01,(%esp)
c0100177:	e8 db 01 00 00       	call   c0100357 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010017c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100180:	0f b7 d0             	movzwl %ax,%edx
c0100183:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c0100188:	89 54 24 08          	mov    %edx,0x8(%esp)
c010018c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100190:	c7 04 24 0f 8d 10 c0 	movl   $0xc0108d0f,(%esp)
c0100197:	e8 bb 01 00 00       	call   c0100357 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010019c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a0:	0f b7 d0             	movzwl %ax,%edx
c01001a3:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001a8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b0:	c7 04 24 1d 8d 10 c0 	movl   $0xc0108d1d,(%esp)
c01001b7:	e8 9b 01 00 00       	call   c0100357 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001bc:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c0:	0f b7 d0             	movzwl %ax,%edx
c01001c3:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001c8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d0:	c7 04 24 2b 8d 10 c0 	movl   $0xc0108d2b,(%esp)
c01001d7:	e8 7b 01 00 00       	call   c0100357 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001dc:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e0:	0f b7 d0             	movzwl %ax,%edx
c01001e3:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c01001e8:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ec:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f0:	c7 04 24 39 8d 10 c0 	movl   $0xc0108d39,(%esp)
c01001f7:	e8 5b 01 00 00       	call   c0100357 <cprintf>
    round ++;
c01001fc:	a1 00 30 12 c0       	mov    0xc0123000,%eax
c0100201:	83 c0 01             	add    $0x1,%eax
c0100204:	a3 00 30 12 c0       	mov    %eax,0xc0123000
}
c0100209:	c9                   	leave  
c010020a:	c3                   	ret    

c010020b <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c010020b:	55                   	push   %ebp
c010020c:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c010020e:	5d                   	pop    %ebp
c010020f:	c3                   	ret    

c0100210 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100210:	55                   	push   %ebp
c0100211:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100213:	5d                   	pop    %ebp
c0100214:	c3                   	ret    

c0100215 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100215:	55                   	push   %ebp
c0100216:	89 e5                	mov    %esp,%ebp
c0100218:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010021b:	e8 25 ff ff ff       	call   c0100145 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100220:	c7 04 24 48 8d 10 c0 	movl   $0xc0108d48,(%esp)
c0100227:	e8 2b 01 00 00       	call   c0100357 <cprintf>
    lab1_switch_to_user();
c010022c:	e8 da ff ff ff       	call   c010020b <lab1_switch_to_user>
    lab1_print_cur_status();
c0100231:	e8 0f ff ff ff       	call   c0100145 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100236:	c7 04 24 68 8d 10 c0 	movl   $0xc0108d68,(%esp)
c010023d:	e8 15 01 00 00       	call   c0100357 <cprintf>
    lab1_switch_to_kernel();
c0100242:	e8 c9 ff ff ff       	call   c0100210 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100247:	e8 f9 fe ff ff       	call   c0100145 <lab1_print_cur_status>
}
c010024c:	c9                   	leave  
c010024d:	c3                   	ret    

c010024e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010024e:	55                   	push   %ebp
c010024f:	89 e5                	mov    %esp,%ebp
c0100251:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100254:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100258:	74 13                	je     c010026d <readline+0x1f>
        cprintf("%s", prompt);
c010025a:	8b 45 08             	mov    0x8(%ebp),%eax
c010025d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100261:	c7 04 24 87 8d 10 c0 	movl   $0xc0108d87,(%esp)
c0100268:	e8 ea 00 00 00       	call   c0100357 <cprintf>
    }
    int i = 0, c;
c010026d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100274:	e8 66 01 00 00       	call   c01003df <getchar>
c0100279:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010027c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100280:	79 07                	jns    c0100289 <readline+0x3b>
            return NULL;
c0100282:	b8 00 00 00 00       	mov    $0x0,%eax
c0100287:	eb 79                	jmp    c0100302 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100289:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010028d:	7e 28                	jle    c01002b7 <readline+0x69>
c010028f:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100296:	7f 1f                	jg     c01002b7 <readline+0x69>
            cputchar(c);
c0100298:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010029b:	89 04 24             	mov    %eax,(%esp)
c010029e:	e8 da 00 00 00       	call   c010037d <cputchar>
            buf[i ++] = c;
c01002a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002a6:	8d 50 01             	lea    0x1(%eax),%edx
c01002a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002af:	88 90 20 30 12 c0    	mov    %dl,-0x3fedcfe0(%eax)
c01002b5:	eb 46                	jmp    c01002fd <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002b7:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002bb:	75 17                	jne    c01002d4 <readline+0x86>
c01002bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002c1:	7e 11                	jle    c01002d4 <readline+0x86>
            cputchar(c);
c01002c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002c6:	89 04 24             	mov    %eax,(%esp)
c01002c9:	e8 af 00 00 00       	call   c010037d <cputchar>
            i --;
c01002ce:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002d2:	eb 29                	jmp    c01002fd <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002d4:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002d8:	74 06                	je     c01002e0 <readline+0x92>
c01002da:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002de:	75 1d                	jne    c01002fd <readline+0xaf>
            cputchar(c);
c01002e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002e3:	89 04 24             	mov    %eax,(%esp)
c01002e6:	e8 92 00 00 00       	call   c010037d <cputchar>
            buf[i] = '\0';
c01002eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002ee:	05 20 30 12 c0       	add    $0xc0123020,%eax
c01002f3:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002f6:	b8 20 30 12 c0       	mov    $0xc0123020,%eax
c01002fb:	eb 05                	jmp    c0100302 <readline+0xb4>
        }
    }
c01002fd:	e9 72 ff ff ff       	jmp    c0100274 <readline+0x26>
}
c0100302:	c9                   	leave  
c0100303:	c3                   	ret    

c0100304 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100304:	55                   	push   %ebp
c0100305:	89 e5                	mov    %esp,%ebp
c0100307:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010030a:	8b 45 08             	mov    0x8(%ebp),%eax
c010030d:	89 04 24             	mov    %eax,(%esp)
c0100310:	e8 0f 13 00 00       	call   c0101624 <cons_putc>
    (*cnt) ++;
c0100315:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100318:	8b 00                	mov    (%eax),%eax
c010031a:	8d 50 01             	lea    0x1(%eax),%edx
c010031d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100320:	89 10                	mov    %edx,(%eax)
}
c0100322:	c9                   	leave  
c0100323:	c3                   	ret    

c0100324 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100324:	55                   	push   %ebp
c0100325:	89 e5                	mov    %esp,%ebp
c0100327:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010032a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100331:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100334:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100338:	8b 45 08             	mov    0x8(%ebp),%eax
c010033b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010033f:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100342:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100346:	c7 04 24 04 03 10 c0 	movl   $0xc0100304,(%esp)
c010034d:	e8 40 7f 00 00       	call   c0108292 <vprintfmt>
    return cnt;
c0100352:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100355:	c9                   	leave  
c0100356:	c3                   	ret    

c0100357 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100357:	55                   	push   %ebp
c0100358:	89 e5                	mov    %esp,%ebp
c010035a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010035d:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100360:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100363:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100366:	89 44 24 04          	mov    %eax,0x4(%esp)
c010036a:	8b 45 08             	mov    0x8(%ebp),%eax
c010036d:	89 04 24             	mov    %eax,(%esp)
c0100370:	e8 af ff ff ff       	call   c0100324 <vcprintf>
c0100375:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100378:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010037b:	c9                   	leave  
c010037c:	c3                   	ret    

c010037d <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010037d:	55                   	push   %ebp
c010037e:	89 e5                	mov    %esp,%ebp
c0100380:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100383:	8b 45 08             	mov    0x8(%ebp),%eax
c0100386:	89 04 24             	mov    %eax,(%esp)
c0100389:	e8 96 12 00 00       	call   c0101624 <cons_putc>
}
c010038e:	c9                   	leave  
c010038f:	c3                   	ret    

c0100390 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100390:	55                   	push   %ebp
c0100391:	89 e5                	mov    %esp,%ebp
c0100393:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100396:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010039d:	eb 13                	jmp    c01003b2 <cputs+0x22>
        cputch(c, &cnt);
c010039f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003a3:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003a6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003aa:	89 04 24             	mov    %eax,(%esp)
c01003ad:	e8 52 ff ff ff       	call   c0100304 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01003b5:	8d 50 01             	lea    0x1(%eax),%edx
c01003b8:	89 55 08             	mov    %edx,0x8(%ebp)
c01003bb:	0f b6 00             	movzbl (%eax),%eax
c01003be:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003c1:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003c5:	75 d8                	jne    c010039f <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003ce:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003d5:	e8 2a ff ff ff       	call   c0100304 <cputch>
    return cnt;
c01003da:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003dd:	c9                   	leave  
c01003de:	c3                   	ret    

c01003df <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003df:	55                   	push   %ebp
c01003e0:	89 e5                	mov    %esp,%ebp
c01003e2:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003e5:	e8 76 12 00 00       	call   c0101660 <cons_getc>
c01003ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003f1:	74 f2                	je     c01003e5 <getchar+0x6>
        /* do nothing */;
    return c;
c01003f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003f6:	c9                   	leave  
c01003f7:	c3                   	ret    

c01003f8 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003f8:	55                   	push   %ebp
c01003f9:	89 e5                	mov    %esp,%ebp
c01003fb:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100401:	8b 00                	mov    (%eax),%eax
c0100403:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100406:	8b 45 10             	mov    0x10(%ebp),%eax
c0100409:	8b 00                	mov    (%eax),%eax
c010040b:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010040e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100415:	e9 d2 00 00 00       	jmp    c01004ec <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c010041a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010041d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100420:	01 d0                	add    %edx,%eax
c0100422:	89 c2                	mov    %eax,%edx
c0100424:	c1 ea 1f             	shr    $0x1f,%edx
c0100427:	01 d0                	add    %edx,%eax
c0100429:	d1 f8                	sar    %eax
c010042b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010042e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100431:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100434:	eb 04                	jmp    c010043a <stab_binsearch+0x42>
            m --;
c0100436:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010043a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010043d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100440:	7c 1f                	jl     c0100461 <stab_binsearch+0x69>
c0100442:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100445:	89 d0                	mov    %edx,%eax
c0100447:	01 c0                	add    %eax,%eax
c0100449:	01 d0                	add    %edx,%eax
c010044b:	c1 e0 02             	shl    $0x2,%eax
c010044e:	89 c2                	mov    %eax,%edx
c0100450:	8b 45 08             	mov    0x8(%ebp),%eax
c0100453:	01 d0                	add    %edx,%eax
c0100455:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100459:	0f b6 c0             	movzbl %al,%eax
c010045c:	3b 45 14             	cmp    0x14(%ebp),%eax
c010045f:	75 d5                	jne    c0100436 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100461:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100464:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100467:	7d 0b                	jge    c0100474 <stab_binsearch+0x7c>
            l = true_m + 1;
c0100469:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010046c:	83 c0 01             	add    $0x1,%eax
c010046f:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100472:	eb 78                	jmp    c01004ec <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100474:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010047b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010047e:	89 d0                	mov    %edx,%eax
c0100480:	01 c0                	add    %eax,%eax
c0100482:	01 d0                	add    %edx,%eax
c0100484:	c1 e0 02             	shl    $0x2,%eax
c0100487:	89 c2                	mov    %eax,%edx
c0100489:	8b 45 08             	mov    0x8(%ebp),%eax
c010048c:	01 d0                	add    %edx,%eax
c010048e:	8b 40 08             	mov    0x8(%eax),%eax
c0100491:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100494:	73 13                	jae    c01004a9 <stab_binsearch+0xb1>
            *region_left = m;
c0100496:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100499:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010049c:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010049e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004a1:	83 c0 01             	add    $0x1,%eax
c01004a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004a7:	eb 43                	jmp    c01004ec <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c01004a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004ac:	89 d0                	mov    %edx,%eax
c01004ae:	01 c0                	add    %eax,%eax
c01004b0:	01 d0                	add    %edx,%eax
c01004b2:	c1 e0 02             	shl    $0x2,%eax
c01004b5:	89 c2                	mov    %eax,%edx
c01004b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01004ba:	01 d0                	add    %edx,%eax
c01004bc:	8b 40 08             	mov    0x8(%eax),%eax
c01004bf:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004c2:	76 16                	jbe    c01004da <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c7:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004ca:	8b 45 10             	mov    0x10(%ebp),%eax
c01004cd:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d2:	83 e8 01             	sub    $0x1,%eax
c01004d5:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004d8:	eb 12                	jmp    c01004ec <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004da:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004e0:	89 10                	mov    %edx,(%eax)
            l = m;
c01004e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004e8:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004ef:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004f2:	0f 8e 22 ff ff ff    	jle    c010041a <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004fc:	75 0f                	jne    c010050d <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100501:	8b 00                	mov    (%eax),%eax
c0100503:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100506:	8b 45 10             	mov    0x10(%ebp),%eax
c0100509:	89 10                	mov    %edx,(%eax)
c010050b:	eb 3f                	jmp    c010054c <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c010050d:	8b 45 10             	mov    0x10(%ebp),%eax
c0100510:	8b 00                	mov    (%eax),%eax
c0100512:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100515:	eb 04                	jmp    c010051b <stab_binsearch+0x123>
c0100517:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c010051b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051e:	8b 00                	mov    (%eax),%eax
c0100520:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100523:	7d 1f                	jge    c0100544 <stab_binsearch+0x14c>
c0100525:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100528:	89 d0                	mov    %edx,%eax
c010052a:	01 c0                	add    %eax,%eax
c010052c:	01 d0                	add    %edx,%eax
c010052e:	c1 e0 02             	shl    $0x2,%eax
c0100531:	89 c2                	mov    %eax,%edx
c0100533:	8b 45 08             	mov    0x8(%ebp),%eax
c0100536:	01 d0                	add    %edx,%eax
c0100538:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010053c:	0f b6 c0             	movzbl %al,%eax
c010053f:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100542:	75 d3                	jne    c0100517 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100544:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100547:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010054a:	89 10                	mov    %edx,(%eax)
    }
}
c010054c:	c9                   	leave  
c010054d:	c3                   	ret    

c010054e <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010054e:	55                   	push   %ebp
c010054f:	89 e5                	mov    %esp,%ebp
c0100551:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100554:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100557:	c7 00 8c 8d 10 c0    	movl   $0xc0108d8c,(%eax)
    info->eip_line = 0;
c010055d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100560:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100567:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056a:	c7 40 08 8c 8d 10 c0 	movl   $0xc0108d8c,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100571:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100574:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010057b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010057e:	8b 55 08             	mov    0x8(%ebp),%edx
c0100581:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100584:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100587:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010058e:	c7 45 f4 00 ad 10 c0 	movl   $0xc010ad00,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100595:	c7 45 f0 2c 9b 11 c0 	movl   $0xc0119b2c,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010059c:	c7 45 ec 2d 9b 11 c0 	movl   $0xc0119b2d,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005a3:	c7 45 e8 c4 d3 11 c0 	movl   $0xc011d3c4,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005ad:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005b0:	76 0d                	jbe    c01005bf <debuginfo_eip+0x71>
c01005b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b5:	83 e8 01             	sub    $0x1,%eax
c01005b8:	0f b6 00             	movzbl (%eax),%eax
c01005bb:	84 c0                	test   %al,%al
c01005bd:	74 0a                	je     c01005c9 <debuginfo_eip+0x7b>
        return -1;
c01005bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005c4:	e9 c0 02 00 00       	jmp    c0100889 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005d6:	29 c2                	sub    %eax,%edx
c01005d8:	89 d0                	mov    %edx,%eax
c01005da:	c1 f8 02             	sar    $0x2,%eax
c01005dd:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005e3:	83 e8 01             	sub    $0x1,%eax
c01005e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01005ec:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005f0:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005f7:	00 
c01005f8:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005fb:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0100602:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100606:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100609:	89 04 24             	mov    %eax,(%esp)
c010060c:	e8 e7 fd ff ff       	call   c01003f8 <stab_binsearch>
    if (lfile == 0)
c0100611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100614:	85 c0                	test   %eax,%eax
c0100616:	75 0a                	jne    c0100622 <debuginfo_eip+0xd4>
        return -1;
c0100618:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010061d:	e9 67 02 00 00       	jmp    c0100889 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100622:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100625:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100628:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010062b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010062e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100631:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100635:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010063c:	00 
c010063d:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100640:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100644:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100647:	89 44 24 04          	mov    %eax,0x4(%esp)
c010064b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010064e:	89 04 24             	mov    %eax,(%esp)
c0100651:	e8 a2 fd ff ff       	call   c01003f8 <stab_binsearch>

    if (lfun <= rfun) {
c0100656:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100659:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010065c:	39 c2                	cmp    %eax,%edx
c010065e:	7f 7c                	jg     c01006dc <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100660:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100663:	89 c2                	mov    %eax,%edx
c0100665:	89 d0                	mov    %edx,%eax
c0100667:	01 c0                	add    %eax,%eax
c0100669:	01 d0                	add    %edx,%eax
c010066b:	c1 e0 02             	shl    $0x2,%eax
c010066e:	89 c2                	mov    %eax,%edx
c0100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100673:	01 d0                	add    %edx,%eax
c0100675:	8b 10                	mov    (%eax),%edx
c0100677:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010067a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010067d:	29 c1                	sub    %eax,%ecx
c010067f:	89 c8                	mov    %ecx,%eax
c0100681:	39 c2                	cmp    %eax,%edx
c0100683:	73 22                	jae    c01006a7 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100685:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100688:	89 c2                	mov    %eax,%edx
c010068a:	89 d0                	mov    %edx,%eax
c010068c:	01 c0                	add    %eax,%eax
c010068e:	01 d0                	add    %edx,%eax
c0100690:	c1 e0 02             	shl    $0x2,%eax
c0100693:	89 c2                	mov    %eax,%edx
c0100695:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100698:	01 d0                	add    %edx,%eax
c010069a:	8b 10                	mov    (%eax),%edx
c010069c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010069f:	01 c2                	add    %eax,%edx
c01006a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006a4:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01006a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006aa:	89 c2                	mov    %eax,%edx
c01006ac:	89 d0                	mov    %edx,%eax
c01006ae:	01 c0                	add    %eax,%eax
c01006b0:	01 d0                	add    %edx,%eax
c01006b2:	c1 e0 02             	shl    $0x2,%eax
c01006b5:	89 c2                	mov    %eax,%edx
c01006b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ba:	01 d0                	add    %edx,%eax
c01006bc:	8b 50 08             	mov    0x8(%eax),%edx
c01006bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006c2:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006c8:	8b 40 10             	mov    0x10(%eax),%eax
c01006cb:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006da:	eb 15                	jmp    c01006f1 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006df:	8b 55 08             	mov    0x8(%ebp),%edx
c01006e2:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006f4:	8b 40 08             	mov    0x8(%eax),%eax
c01006f7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006fe:	00 
c01006ff:	89 04 24             	mov    %eax,(%esp)
c0100702:	e8 be 82 00 00       	call   c01089c5 <strfind>
c0100707:	89 c2                	mov    %eax,%edx
c0100709:	8b 45 0c             	mov    0xc(%ebp),%eax
c010070c:	8b 40 08             	mov    0x8(%eax),%eax
c010070f:	29 c2                	sub    %eax,%edx
c0100711:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100714:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100717:	8b 45 08             	mov    0x8(%ebp),%eax
c010071a:	89 44 24 10          	mov    %eax,0x10(%esp)
c010071e:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100725:	00 
c0100726:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100729:	89 44 24 08          	mov    %eax,0x8(%esp)
c010072d:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100730:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100734:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100737:	89 04 24             	mov    %eax,(%esp)
c010073a:	e8 b9 fc ff ff       	call   c01003f8 <stab_binsearch>
    if (lline <= rline) {
c010073f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100742:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100745:	39 c2                	cmp    %eax,%edx
c0100747:	7f 24                	jg     c010076d <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c0100749:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010074c:	89 c2                	mov    %eax,%edx
c010074e:	89 d0                	mov    %edx,%eax
c0100750:	01 c0                	add    %eax,%eax
c0100752:	01 d0                	add    %edx,%eax
c0100754:	c1 e0 02             	shl    $0x2,%eax
c0100757:	89 c2                	mov    %eax,%edx
c0100759:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075c:	01 d0                	add    %edx,%eax
c010075e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100762:	0f b7 d0             	movzwl %ax,%edx
c0100765:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100768:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010076b:	eb 13                	jmp    c0100780 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c010076d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100772:	e9 12 01 00 00       	jmp    c0100889 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100777:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010077a:	83 e8 01             	sub    $0x1,%eax
c010077d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100780:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100783:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100786:	39 c2                	cmp    %eax,%edx
c0100788:	7c 56                	jl     c01007e0 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c010078a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010078d:	89 c2                	mov    %eax,%edx
c010078f:	89 d0                	mov    %edx,%eax
c0100791:	01 c0                	add    %eax,%eax
c0100793:	01 d0                	add    %edx,%eax
c0100795:	c1 e0 02             	shl    $0x2,%eax
c0100798:	89 c2                	mov    %eax,%edx
c010079a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010079d:	01 d0                	add    %edx,%eax
c010079f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007a3:	3c 84                	cmp    $0x84,%al
c01007a5:	74 39                	je     c01007e0 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01007a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007aa:	89 c2                	mov    %eax,%edx
c01007ac:	89 d0                	mov    %edx,%eax
c01007ae:	01 c0                	add    %eax,%eax
c01007b0:	01 d0                	add    %edx,%eax
c01007b2:	c1 e0 02             	shl    $0x2,%eax
c01007b5:	89 c2                	mov    %eax,%edx
c01007b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ba:	01 d0                	add    %edx,%eax
c01007bc:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007c0:	3c 64                	cmp    $0x64,%al
c01007c2:	75 b3                	jne    c0100777 <debuginfo_eip+0x229>
c01007c4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007c7:	89 c2                	mov    %eax,%edx
c01007c9:	89 d0                	mov    %edx,%eax
c01007cb:	01 c0                	add    %eax,%eax
c01007cd:	01 d0                	add    %edx,%eax
c01007cf:	c1 e0 02             	shl    $0x2,%eax
c01007d2:	89 c2                	mov    %eax,%edx
c01007d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d7:	01 d0                	add    %edx,%eax
c01007d9:	8b 40 08             	mov    0x8(%eax),%eax
c01007dc:	85 c0                	test   %eax,%eax
c01007de:	74 97                	je     c0100777 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007e0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007e6:	39 c2                	cmp    %eax,%edx
c01007e8:	7c 46                	jl     c0100830 <debuginfo_eip+0x2e2>
c01007ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007ed:	89 c2                	mov    %eax,%edx
c01007ef:	89 d0                	mov    %edx,%eax
c01007f1:	01 c0                	add    %eax,%eax
c01007f3:	01 d0                	add    %edx,%eax
c01007f5:	c1 e0 02             	shl    $0x2,%eax
c01007f8:	89 c2                	mov    %eax,%edx
c01007fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007fd:	01 d0                	add    %edx,%eax
c01007ff:	8b 10                	mov    (%eax),%edx
c0100801:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100804:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100807:	29 c1                	sub    %eax,%ecx
c0100809:	89 c8                	mov    %ecx,%eax
c010080b:	39 c2                	cmp    %eax,%edx
c010080d:	73 21                	jae    c0100830 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c010080f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100812:	89 c2                	mov    %eax,%edx
c0100814:	89 d0                	mov    %edx,%eax
c0100816:	01 c0                	add    %eax,%eax
c0100818:	01 d0                	add    %edx,%eax
c010081a:	c1 e0 02             	shl    $0x2,%eax
c010081d:	89 c2                	mov    %eax,%edx
c010081f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100822:	01 d0                	add    %edx,%eax
c0100824:	8b 10                	mov    (%eax),%edx
c0100826:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100829:	01 c2                	add    %eax,%edx
c010082b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010082e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100830:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100833:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100836:	39 c2                	cmp    %eax,%edx
c0100838:	7d 4a                	jge    c0100884 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c010083a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010083d:	83 c0 01             	add    $0x1,%eax
c0100840:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100843:	eb 18                	jmp    c010085d <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100845:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100848:	8b 40 14             	mov    0x14(%eax),%eax
c010084b:	8d 50 01             	lea    0x1(%eax),%edx
c010084e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100851:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100854:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100857:	83 c0 01             	add    $0x1,%eax
c010085a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010085d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100860:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100863:	39 c2                	cmp    %eax,%edx
c0100865:	7d 1d                	jge    c0100884 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100867:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010086a:	89 c2                	mov    %eax,%edx
c010086c:	89 d0                	mov    %edx,%eax
c010086e:	01 c0                	add    %eax,%eax
c0100870:	01 d0                	add    %edx,%eax
c0100872:	c1 e0 02             	shl    $0x2,%eax
c0100875:	89 c2                	mov    %eax,%edx
c0100877:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010087a:	01 d0                	add    %edx,%eax
c010087c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100880:	3c a0                	cmp    $0xa0,%al
c0100882:	74 c1                	je     c0100845 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100884:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100889:	c9                   	leave  
c010088a:	c3                   	ret    

c010088b <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010088b:	55                   	push   %ebp
c010088c:	89 e5                	mov    %esp,%ebp
c010088e:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100891:	c7 04 24 96 8d 10 c0 	movl   $0xc0108d96,(%esp)
c0100898:	e8 ba fa ff ff       	call   c0100357 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010089d:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01008a4:	c0 
c01008a5:	c7 04 24 af 8d 10 c0 	movl   $0xc0108daf,(%esp)
c01008ac:	e8 a6 fa ff ff       	call   c0100357 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008b1:	c7 44 24 04 da 8c 10 	movl   $0xc0108cda,0x4(%esp)
c01008b8:	c0 
c01008b9:	c7 04 24 c7 8d 10 c0 	movl   $0xc0108dc7,(%esp)
c01008c0:	e8 92 fa ff ff       	call   c0100357 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008c5:	c7 44 24 04 00 30 12 	movl   $0xc0123000,0x4(%esp)
c01008cc:	c0 
c01008cd:	c7 04 24 df 8d 10 c0 	movl   $0xc0108ddf,(%esp)
c01008d4:	e8 7e fa ff ff       	call   c0100357 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008d9:	c7 44 24 04 30 41 12 	movl   $0xc0124130,0x4(%esp)
c01008e0:	c0 
c01008e1:	c7 04 24 f7 8d 10 c0 	movl   $0xc0108df7,(%esp)
c01008e8:	e8 6a fa ff ff       	call   c0100357 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008ed:	b8 30 41 12 c0       	mov    $0xc0124130,%eax
c01008f2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f8:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01008fd:	29 c2                	sub    %eax,%edx
c01008ff:	89 d0                	mov    %edx,%eax
c0100901:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100907:	85 c0                	test   %eax,%eax
c0100909:	0f 48 c2             	cmovs  %edx,%eax
c010090c:	c1 f8 0a             	sar    $0xa,%eax
c010090f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100913:	c7 04 24 10 8e 10 c0 	movl   $0xc0108e10,(%esp)
c010091a:	e8 38 fa ff ff       	call   c0100357 <cprintf>
}
c010091f:	c9                   	leave  
c0100920:	c3                   	ret    

c0100921 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100921:	55                   	push   %ebp
c0100922:	89 e5                	mov    %esp,%ebp
c0100924:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c010092a:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010092d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100931:	8b 45 08             	mov    0x8(%ebp),%eax
c0100934:	89 04 24             	mov    %eax,(%esp)
c0100937:	e8 12 fc ff ff       	call   c010054e <debuginfo_eip>
c010093c:	85 c0                	test   %eax,%eax
c010093e:	74 15                	je     c0100955 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100940:	8b 45 08             	mov    0x8(%ebp),%eax
c0100943:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100947:	c7 04 24 3a 8e 10 c0 	movl   $0xc0108e3a,(%esp)
c010094e:	e8 04 fa ff ff       	call   c0100357 <cprintf>
c0100953:	eb 6d                	jmp    c01009c2 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100955:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010095c:	eb 1c                	jmp    c010097a <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c010095e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100961:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100964:	01 d0                	add    %edx,%eax
c0100966:	0f b6 00             	movzbl (%eax),%eax
c0100969:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010096f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100972:	01 ca                	add    %ecx,%edx
c0100974:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100976:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010097a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010097d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100980:	7f dc                	jg     c010095e <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100982:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100988:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010098b:	01 d0                	add    %edx,%eax
c010098d:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100990:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100993:	8b 55 08             	mov    0x8(%ebp),%edx
c0100996:	89 d1                	mov    %edx,%ecx
c0100998:	29 c1                	sub    %eax,%ecx
c010099a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010099d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01009a0:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01009a4:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01009aa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01009ae:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009b2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009b6:	c7 04 24 56 8e 10 c0 	movl   $0xc0108e56,(%esp)
c01009bd:	e8 95 f9 ff ff       	call   c0100357 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c01009c2:	c9                   	leave  
c01009c3:	c3                   	ret    

c01009c4 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009c4:	55                   	push   %ebp
c01009c5:	89 e5                	mov    %esp,%ebp
c01009c7:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009ca:	8b 45 04             	mov    0x4(%ebp),%eax
c01009cd:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009d3:	c9                   	leave  
c01009d4:	c3                   	ret    

c01009d5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009d5:	55                   	push   %ebp
c01009d6:	89 e5                	mov    %esp,%ebp
c01009d8:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009db:	89 e8                	mov    %ebp,%eax
c01009dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c01009e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c01009e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01009e6:	e8 d9 ff ff ff       	call   c01009c4 <read_eip>
c01009eb:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c01009ee:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009f5:	e9 88 00 00 00       	jmp    c0100a82 <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c01009fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009fd:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a08:	c7 04 24 68 8e 10 c0 	movl   $0xc0108e68,(%esp)
c0100a0f:	e8 43 f9 ff ff       	call   c0100357 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
c0100a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a17:	83 c0 08             	add    $0x8,%eax
c0100a1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100a1d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a24:	eb 25                	jmp    c0100a4b <print_stackframe+0x76>
            cprintf("0x%08x ", args[j]);
c0100a26:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a29:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a33:	01 d0                	add    %edx,%eax
c0100a35:	8b 00                	mov    (%eax),%eax
c0100a37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a3b:	c7 04 24 84 8e 10 c0 	movl   $0xc0108e84,(%esp)
c0100a42:	e8 10 f9 ff ff       	call   c0100357 <cprintf>

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
c0100a47:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0100a4b:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a4f:	7e d5                	jle    c0100a26 <print_stackframe+0x51>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
c0100a51:	c7 04 24 8c 8e 10 c0 	movl   $0xc0108e8c,(%esp)
c0100a58:	e8 fa f8 ff ff       	call   c0100357 <cprintf>
        print_debuginfo(eip - 1);
c0100a5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a60:	83 e8 01             	sub    $0x1,%eax
c0100a63:	89 04 24             	mov    %eax,(%esp)
c0100a66:	e8 b6 fe ff ff       	call   c0100921 <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a6e:	83 c0 04             	add    $0x4,%eax
c0100a71:	8b 00                	mov    (%eax),%eax
c0100a73:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a79:	8b 00                	mov    (%eax),%eax
c0100a7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100a7e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100a82:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a86:	74 0a                	je     c0100a92 <print_stackframe+0xbd>
c0100a88:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a8c:	0f 8e 68 ff ff ff    	jle    c01009fa <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0100a92:	c9                   	leave  
c0100a93:	c3                   	ret    

c0100a94 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a94:	55                   	push   %ebp
c0100a95:	89 e5                	mov    %esp,%ebp
c0100a97:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100a9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100aa1:	eb 0c                	jmp    c0100aaf <parse+0x1b>
            *buf ++ = '\0';
c0100aa3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa6:	8d 50 01             	lea    0x1(%eax),%edx
c0100aa9:	89 55 08             	mov    %edx,0x8(%ebp)
c0100aac:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100aaf:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ab2:	0f b6 00             	movzbl (%eax),%eax
c0100ab5:	84 c0                	test   %al,%al
c0100ab7:	74 1d                	je     c0100ad6 <parse+0x42>
c0100ab9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100abc:	0f b6 00             	movzbl (%eax),%eax
c0100abf:	0f be c0             	movsbl %al,%eax
c0100ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ac6:	c7 04 24 10 8f 10 c0 	movl   $0xc0108f10,(%esp)
c0100acd:	e8 c0 7e 00 00       	call   c0108992 <strchr>
c0100ad2:	85 c0                	test   %eax,%eax
c0100ad4:	75 cd                	jne    c0100aa3 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100ad6:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ad9:	0f b6 00             	movzbl (%eax),%eax
c0100adc:	84 c0                	test   %al,%al
c0100ade:	75 02                	jne    c0100ae2 <parse+0x4e>
            break;
c0100ae0:	eb 67                	jmp    c0100b49 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ae2:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ae6:	75 14                	jne    c0100afc <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ae8:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100aef:	00 
c0100af0:	c7 04 24 15 8f 10 c0 	movl   $0xc0108f15,(%esp)
c0100af7:	e8 5b f8 ff ff       	call   c0100357 <cprintf>
        }
        argv[argc ++] = buf;
c0100afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aff:	8d 50 01             	lea    0x1(%eax),%edx
c0100b02:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100b05:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b0f:	01 c2                	add    %eax,%edx
c0100b11:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b14:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b16:	eb 04                	jmp    c0100b1c <parse+0x88>
            buf ++;
c0100b18:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b1f:	0f b6 00             	movzbl (%eax),%eax
c0100b22:	84 c0                	test   %al,%al
c0100b24:	74 1d                	je     c0100b43 <parse+0xaf>
c0100b26:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b29:	0f b6 00             	movzbl (%eax),%eax
c0100b2c:	0f be c0             	movsbl %al,%eax
c0100b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b33:	c7 04 24 10 8f 10 c0 	movl   $0xc0108f10,(%esp)
c0100b3a:	e8 53 7e 00 00       	call   c0108992 <strchr>
c0100b3f:	85 c0                	test   %eax,%eax
c0100b41:	74 d5                	je     c0100b18 <parse+0x84>
            buf ++;
        }
    }
c0100b43:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b44:	e9 66 ff ff ff       	jmp    c0100aaf <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b4c:	c9                   	leave  
c0100b4d:	c3                   	ret    

c0100b4e <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b4e:	55                   	push   %ebp
c0100b4f:	89 e5                	mov    %esp,%ebp
c0100b51:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b54:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b57:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b5e:	89 04 24             	mov    %eax,(%esp)
c0100b61:	e8 2e ff ff ff       	call   c0100a94 <parse>
c0100b66:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b69:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b6d:	75 0a                	jne    c0100b79 <runcmd+0x2b>
        return 0;
c0100b6f:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b74:	e9 85 00 00 00       	jmp    c0100bfe <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b79:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b80:	eb 5c                	jmp    c0100bde <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b82:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100b85:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b88:	89 d0                	mov    %edx,%eax
c0100b8a:	01 c0                	add    %eax,%eax
c0100b8c:	01 d0                	add    %edx,%eax
c0100b8e:	c1 e0 02             	shl    $0x2,%eax
c0100b91:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100b96:	8b 00                	mov    (%eax),%eax
c0100b98:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100b9c:	89 04 24             	mov    %eax,(%esp)
c0100b9f:	e8 4f 7d 00 00       	call   c01088f3 <strcmp>
c0100ba4:	85 c0                	test   %eax,%eax
c0100ba6:	75 32                	jne    c0100bda <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100ba8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100bab:	89 d0                	mov    %edx,%eax
c0100bad:	01 c0                	add    %eax,%eax
c0100baf:	01 d0                	add    %edx,%eax
c0100bb1:	c1 e0 02             	shl    $0x2,%eax
c0100bb4:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100bb9:	8b 40 08             	mov    0x8(%eax),%eax
c0100bbc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100bbf:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100bc2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100bc5:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100bc9:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100bcc:	83 c2 04             	add    $0x4,%edx
c0100bcf:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bd3:	89 0c 24             	mov    %ecx,(%esp)
c0100bd6:	ff d0                	call   *%eax
c0100bd8:	eb 24                	jmp    c0100bfe <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bda:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100bde:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100be1:	83 f8 02             	cmp    $0x2,%eax
c0100be4:	76 9c                	jbe    c0100b82 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100be6:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100be9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bed:	c7 04 24 33 8f 10 c0 	movl   $0xc0108f33,(%esp)
c0100bf4:	e8 5e f7 ff ff       	call   c0100357 <cprintf>
    return 0;
c0100bf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100bfe:	c9                   	leave  
c0100bff:	c3                   	ret    

c0100c00 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c00:	55                   	push   %ebp
c0100c01:	89 e5                	mov    %esp,%ebp
c0100c03:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c06:	c7 04 24 4c 8f 10 c0 	movl   $0xc0108f4c,(%esp)
c0100c0d:	e8 45 f7 ff ff       	call   c0100357 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c12:	c7 04 24 74 8f 10 c0 	movl   $0xc0108f74,(%esp)
c0100c19:	e8 39 f7 ff ff       	call   c0100357 <cprintf>

    if (tf != NULL) {
c0100c1e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c22:	74 0b                	je     c0100c2f <kmonitor+0x2f>
        print_trapframe(tf);
c0100c24:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c27:	89 04 24             	mov    %eax,(%esp)
c0100c2a:	e8 5d 16 00 00       	call   c010228c <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c2f:	c7 04 24 99 8f 10 c0 	movl   $0xc0108f99,(%esp)
c0100c36:	e8 13 f6 ff ff       	call   c010024e <readline>
c0100c3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c3e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c42:	74 18                	je     c0100c5c <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100c44:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c4e:	89 04 24             	mov    %eax,(%esp)
c0100c51:	e8 f8 fe ff ff       	call   c0100b4e <runcmd>
c0100c56:	85 c0                	test   %eax,%eax
c0100c58:	79 02                	jns    c0100c5c <kmonitor+0x5c>
                break;
c0100c5a:	eb 02                	jmp    c0100c5e <kmonitor+0x5e>
            }
        }
    }
c0100c5c:	eb d1                	jmp    c0100c2f <kmonitor+0x2f>
}
c0100c5e:	c9                   	leave  
c0100c5f:	c3                   	ret    

c0100c60 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c60:	55                   	push   %ebp
c0100c61:	89 e5                	mov    %esp,%ebp
c0100c63:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c6d:	eb 3f                	jmp    c0100cae <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c72:	89 d0                	mov    %edx,%eax
c0100c74:	01 c0                	add    %eax,%eax
c0100c76:	01 d0                	add    %edx,%eax
c0100c78:	c1 e0 02             	shl    $0x2,%eax
c0100c7b:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100c80:	8b 48 04             	mov    0x4(%eax),%ecx
c0100c83:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c86:	89 d0                	mov    %edx,%eax
c0100c88:	01 c0                	add    %eax,%eax
c0100c8a:	01 d0                	add    %edx,%eax
c0100c8c:	c1 e0 02             	shl    $0x2,%eax
c0100c8f:	05 00 00 12 c0       	add    $0xc0120000,%eax
c0100c94:	8b 00                	mov    (%eax),%eax
c0100c96:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c9a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c9e:	c7 04 24 9d 8f 10 c0 	movl   $0xc0108f9d,(%esp)
c0100ca5:	e8 ad f6 ff ff       	call   c0100357 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100caa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cb1:	83 f8 02             	cmp    $0x2,%eax
c0100cb4:	76 b9                	jbe    c0100c6f <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100cb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cbb:	c9                   	leave  
c0100cbc:	c3                   	ret    

c0100cbd <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cbd:	55                   	push   %ebp
c0100cbe:	89 e5                	mov    %esp,%ebp
c0100cc0:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cc3:	e8 c3 fb ff ff       	call   c010088b <print_kerninfo>
    return 0;
c0100cc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ccd:	c9                   	leave  
c0100cce:	c3                   	ret    

c0100ccf <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100ccf:	55                   	push   %ebp
c0100cd0:	89 e5                	mov    %esp,%ebp
c0100cd2:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cd5:	e8 fb fc ff ff       	call   c01009d5 <print_stackframe>
    return 0;
c0100cda:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cdf:	c9                   	leave  
c0100ce0:	c3                   	ret    

c0100ce1 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100ce1:	55                   	push   %ebp
c0100ce2:	89 e5                	mov    %esp,%ebp
c0100ce4:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100ce7:	a1 20 34 12 c0       	mov    0xc0123420,%eax
c0100cec:	85 c0                	test   %eax,%eax
c0100cee:	74 02                	je     c0100cf2 <__panic+0x11>
        goto panic_dead;
c0100cf0:	eb 59                	jmp    c0100d4b <__panic+0x6a>
    }
    is_panic = 1;
c0100cf2:	c7 05 20 34 12 c0 01 	movl   $0x1,0xc0123420
c0100cf9:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100cfc:	8d 45 14             	lea    0x14(%ebp),%eax
c0100cff:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100d02:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d05:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d09:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d10:	c7 04 24 a6 8f 10 c0 	movl   $0xc0108fa6,(%esp)
c0100d17:	e8 3b f6 ff ff       	call   c0100357 <cprintf>
    vcprintf(fmt, ap);
c0100d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d1f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d23:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d26:	89 04 24             	mov    %eax,(%esp)
c0100d29:	e8 f6 f5 ff ff       	call   c0100324 <vcprintf>
    cprintf("\n");
c0100d2e:	c7 04 24 c2 8f 10 c0 	movl   $0xc0108fc2,(%esp)
c0100d35:	e8 1d f6 ff ff       	call   c0100357 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d3a:	c7 04 24 c4 8f 10 c0 	movl   $0xc0108fc4,(%esp)
c0100d41:	e8 11 f6 ff ff       	call   c0100357 <cprintf>
    print_stackframe();
c0100d46:	e8 8a fc ff ff       	call   c01009d5 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d4b:	e8 fa 11 00 00       	call   c0101f4a <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d57:	e8 a4 fe ff ff       	call   c0100c00 <kmonitor>
    }
c0100d5c:	eb f2                	jmp    c0100d50 <__panic+0x6f>

c0100d5e <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d5e:	55                   	push   %ebp
c0100d5f:	89 e5                	mov    %esp,%ebp
c0100d61:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d64:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d67:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d6a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d6d:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d71:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d74:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d78:	c7 04 24 d6 8f 10 c0 	movl   $0xc0108fd6,(%esp)
c0100d7f:	e8 d3 f5 ff ff       	call   c0100357 <cprintf>
    vcprintf(fmt, ap);
c0100d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d87:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d8b:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d8e:	89 04 24             	mov    %eax,(%esp)
c0100d91:	e8 8e f5 ff ff       	call   c0100324 <vcprintf>
    cprintf("\n");
c0100d96:	c7 04 24 c2 8f 10 c0 	movl   $0xc0108fc2,(%esp)
c0100d9d:	e8 b5 f5 ff ff       	call   c0100357 <cprintf>
    va_end(ap);
}
c0100da2:	c9                   	leave  
c0100da3:	c3                   	ret    

c0100da4 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100da4:	55                   	push   %ebp
c0100da5:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100da7:	a1 20 34 12 c0       	mov    0xc0123420,%eax
}
c0100dac:	5d                   	pop    %ebp
c0100dad:	c3                   	ret    

c0100dae <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100dae:	55                   	push   %ebp
c0100daf:	89 e5                	mov    %esp,%ebp
c0100db1:	83 ec 28             	sub    $0x28,%esp
c0100db4:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100dba:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dbe:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100dc2:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dc6:	ee                   	out    %al,(%dx)
c0100dc7:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dcd:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100dd1:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dd5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dd9:	ee                   	out    %al,(%dx)
c0100dda:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100de0:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100de4:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100de8:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100dec:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100ded:	c7 05 3c 40 12 c0 00 	movl   $0x0,0xc012403c
c0100df4:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100df7:	c7 04 24 f4 8f 10 c0 	movl   $0xc0108ff4,(%esp)
c0100dfe:	e8 54 f5 ff ff       	call   c0100357 <cprintf>
    pic_enable(IRQ_TIMER);
c0100e03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e0a:	e8 99 11 00 00       	call   c0101fa8 <pic_enable>
}
c0100e0f:	c9                   	leave  
c0100e10:	c3                   	ret    

c0100e11 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e11:	55                   	push   %ebp
c0100e12:	89 e5                	mov    %esp,%ebp
c0100e14:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e17:	9c                   	pushf  
c0100e18:	58                   	pop    %eax
c0100e19:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e1f:	25 00 02 00 00       	and    $0x200,%eax
c0100e24:	85 c0                	test   %eax,%eax
c0100e26:	74 0c                	je     c0100e34 <__intr_save+0x23>
        intr_disable();
c0100e28:	e8 1d 11 00 00       	call   c0101f4a <intr_disable>
        return 1;
c0100e2d:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e32:	eb 05                	jmp    c0100e39 <__intr_save+0x28>
    }
    return 0;
c0100e34:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e39:	c9                   	leave  
c0100e3a:	c3                   	ret    

c0100e3b <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e3b:	55                   	push   %ebp
c0100e3c:	89 e5                	mov    %esp,%ebp
c0100e3e:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e41:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e45:	74 05                	je     c0100e4c <__intr_restore+0x11>
        intr_enable();
c0100e47:	e8 f8 10 00 00       	call   c0101f44 <intr_enable>
    }
}
c0100e4c:	c9                   	leave  
c0100e4d:	c3                   	ret    

c0100e4e <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e4e:	55                   	push   %ebp
c0100e4f:	89 e5                	mov    %esp,%ebp
c0100e51:	83 ec 10             	sub    $0x10,%esp
c0100e54:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e5a:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e5e:	89 c2                	mov    %eax,%edx
c0100e60:	ec                   	in     (%dx),%al
c0100e61:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100e64:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e6a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e6e:	89 c2                	mov    %eax,%edx
c0100e70:	ec                   	in     (%dx),%al
c0100e71:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e74:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e7a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e7e:	89 c2                	mov    %eax,%edx
c0100e80:	ec                   	in     (%dx),%al
c0100e81:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e84:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100e8a:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e8e:	89 c2                	mov    %eax,%edx
c0100e90:	ec                   	in     (%dx),%al
c0100e91:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e94:	c9                   	leave  
c0100e95:	c3                   	ret    

c0100e96 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e96:	55                   	push   %ebp
c0100e97:	89 e5                	mov    %esp,%ebp
c0100e99:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e9c:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100ea3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea6:	0f b7 00             	movzwl (%eax),%eax
c0100ea9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100ead:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb0:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100eb5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb8:	0f b7 00             	movzwl (%eax),%eax
c0100ebb:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100ebf:	74 12                	je     c0100ed3 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ec1:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ec8:	66 c7 05 46 34 12 c0 	movw   $0x3b4,0xc0123446
c0100ecf:	b4 03 
c0100ed1:	eb 13                	jmp    c0100ee6 <cga_init+0x50>
    } else {
        *cp = was;
c0100ed3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ed6:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100eda:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100edd:	66 c7 05 46 34 12 c0 	movw   $0x3d4,0xc0123446
c0100ee4:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ee6:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c0100eed:	0f b7 c0             	movzwl %ax,%eax
c0100ef0:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100ef4:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ef8:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100efc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f00:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100f01:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c0100f08:	83 c0 01             	add    $0x1,%eax
c0100f0b:	0f b7 c0             	movzwl %ax,%eax
c0100f0e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f12:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f16:	89 c2                	mov    %eax,%edx
c0100f18:	ec                   	in     (%dx),%al
c0100f19:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f1c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f20:	0f b6 c0             	movzbl %al,%eax
c0100f23:	c1 e0 08             	shl    $0x8,%eax
c0100f26:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f29:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c0100f30:	0f b7 c0             	movzwl %ax,%eax
c0100f33:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100f37:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f3b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f3f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f43:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f44:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c0100f4b:	83 c0 01             	add    $0x1,%eax
c0100f4e:	0f b7 c0             	movzwl %ax,%eax
c0100f51:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f55:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100f59:	89 c2                	mov    %eax,%edx
c0100f5b:	ec                   	in     (%dx),%al
c0100f5c:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100f5f:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f63:	0f b6 c0             	movzbl %al,%eax
c0100f66:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f69:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f6c:	a3 40 34 12 c0       	mov    %eax,0xc0123440
    crt_pos = pos;
c0100f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f74:	66 a3 44 34 12 c0    	mov    %ax,0xc0123444
}
c0100f7a:	c9                   	leave  
c0100f7b:	c3                   	ret    

c0100f7c <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f7c:	55                   	push   %ebp
c0100f7d:	89 e5                	mov    %esp,%ebp
c0100f7f:	83 ec 48             	sub    $0x48,%esp
c0100f82:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f88:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f8c:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100f90:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f94:	ee                   	out    %al,(%dx)
c0100f95:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100f9b:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100f9f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100fa3:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100fa7:	ee                   	out    %al,(%dx)
c0100fa8:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100fae:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100fb2:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100fb6:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fba:	ee                   	out    %al,(%dx)
c0100fbb:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fc1:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100fc5:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fc9:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fcd:	ee                   	out    %al,(%dx)
c0100fce:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100fd4:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100fd8:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fdc:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fe0:	ee                   	out    %al,(%dx)
c0100fe1:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100fe7:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100feb:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fef:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100ff3:	ee                   	out    %al,(%dx)
c0100ff4:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100ffa:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0100ffe:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101002:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101006:	ee                   	out    %al,(%dx)
c0101007:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010100d:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0101011:	89 c2                	mov    %eax,%edx
c0101013:	ec                   	in     (%dx),%al
c0101014:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0101017:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010101b:	3c ff                	cmp    $0xff,%al
c010101d:	0f 95 c0             	setne  %al
c0101020:	0f b6 c0             	movzbl %al,%eax
c0101023:	a3 48 34 12 c0       	mov    %eax,0xc0123448
c0101028:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010102e:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0101032:	89 c2                	mov    %eax,%edx
c0101034:	ec                   	in     (%dx),%al
c0101035:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0101038:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c010103e:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101042:	89 c2                	mov    %eax,%edx
c0101044:	ec                   	in     (%dx),%al
c0101045:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101048:	a1 48 34 12 c0       	mov    0xc0123448,%eax
c010104d:	85 c0                	test   %eax,%eax
c010104f:	74 0c                	je     c010105d <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101051:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101058:	e8 4b 0f 00 00       	call   c0101fa8 <pic_enable>
    }
}
c010105d:	c9                   	leave  
c010105e:	c3                   	ret    

c010105f <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010105f:	55                   	push   %ebp
c0101060:	89 e5                	mov    %esp,%ebp
c0101062:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101065:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010106c:	eb 09                	jmp    c0101077 <lpt_putc_sub+0x18>
        delay();
c010106e:	e8 db fd ff ff       	call   c0100e4e <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101073:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101077:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c010107d:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101081:	89 c2                	mov    %eax,%edx
c0101083:	ec                   	in     (%dx),%al
c0101084:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101087:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010108b:	84 c0                	test   %al,%al
c010108d:	78 09                	js     c0101098 <lpt_putc_sub+0x39>
c010108f:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101096:	7e d6                	jle    c010106e <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0101098:	8b 45 08             	mov    0x8(%ebp),%eax
c010109b:	0f b6 c0             	movzbl %al,%eax
c010109e:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c01010a4:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010a7:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010ab:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010af:	ee                   	out    %al,(%dx)
c01010b0:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010b6:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01010ba:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010be:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010c2:	ee                   	out    %al,(%dx)
c01010c3:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01010c9:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01010cd:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010d1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010d5:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010d6:	c9                   	leave  
c01010d7:	c3                   	ret    

c01010d8 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010d8:	55                   	push   %ebp
c01010d9:	89 e5                	mov    %esp,%ebp
c01010db:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010de:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010e2:	74 0d                	je     c01010f1 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01010e7:	89 04 24             	mov    %eax,(%esp)
c01010ea:	e8 70 ff ff ff       	call   c010105f <lpt_putc_sub>
c01010ef:	eb 24                	jmp    c0101115 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01010f1:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010f8:	e8 62 ff ff ff       	call   c010105f <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010fd:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101104:	e8 56 ff ff ff       	call   c010105f <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101109:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101110:	e8 4a ff ff ff       	call   c010105f <lpt_putc_sub>
    }
}
c0101115:	c9                   	leave  
c0101116:	c3                   	ret    

c0101117 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101117:	55                   	push   %ebp
c0101118:	89 e5                	mov    %esp,%ebp
c010111a:	53                   	push   %ebx
c010111b:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c010111e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101121:	b0 00                	mov    $0x0,%al
c0101123:	85 c0                	test   %eax,%eax
c0101125:	75 07                	jne    c010112e <cga_putc+0x17>
        c |= 0x0700;
c0101127:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010112e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101131:	0f b6 c0             	movzbl %al,%eax
c0101134:	83 f8 0a             	cmp    $0xa,%eax
c0101137:	74 4c                	je     c0101185 <cga_putc+0x6e>
c0101139:	83 f8 0d             	cmp    $0xd,%eax
c010113c:	74 57                	je     c0101195 <cga_putc+0x7e>
c010113e:	83 f8 08             	cmp    $0x8,%eax
c0101141:	0f 85 88 00 00 00    	jne    c01011cf <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101147:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c010114e:	66 85 c0             	test   %ax,%ax
c0101151:	74 30                	je     c0101183 <cga_putc+0x6c>
            crt_pos --;
c0101153:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c010115a:	83 e8 01             	sub    $0x1,%eax
c010115d:	66 a3 44 34 12 c0    	mov    %ax,0xc0123444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101163:	a1 40 34 12 c0       	mov    0xc0123440,%eax
c0101168:	0f b7 15 44 34 12 c0 	movzwl 0xc0123444,%edx
c010116f:	0f b7 d2             	movzwl %dx,%edx
c0101172:	01 d2                	add    %edx,%edx
c0101174:	01 c2                	add    %eax,%edx
c0101176:	8b 45 08             	mov    0x8(%ebp),%eax
c0101179:	b0 00                	mov    $0x0,%al
c010117b:	83 c8 20             	or     $0x20,%eax
c010117e:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101181:	eb 72                	jmp    c01011f5 <cga_putc+0xde>
c0101183:	eb 70                	jmp    c01011f5 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101185:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c010118c:	83 c0 50             	add    $0x50,%eax
c010118f:	66 a3 44 34 12 c0    	mov    %ax,0xc0123444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101195:	0f b7 1d 44 34 12 c0 	movzwl 0xc0123444,%ebx
c010119c:	0f b7 0d 44 34 12 c0 	movzwl 0xc0123444,%ecx
c01011a3:	0f b7 c1             	movzwl %cx,%eax
c01011a6:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c01011ac:	c1 e8 10             	shr    $0x10,%eax
c01011af:	89 c2                	mov    %eax,%edx
c01011b1:	66 c1 ea 06          	shr    $0x6,%dx
c01011b5:	89 d0                	mov    %edx,%eax
c01011b7:	c1 e0 02             	shl    $0x2,%eax
c01011ba:	01 d0                	add    %edx,%eax
c01011bc:	c1 e0 04             	shl    $0x4,%eax
c01011bf:	29 c1                	sub    %eax,%ecx
c01011c1:	89 ca                	mov    %ecx,%edx
c01011c3:	89 d8                	mov    %ebx,%eax
c01011c5:	29 d0                	sub    %edx,%eax
c01011c7:	66 a3 44 34 12 c0    	mov    %ax,0xc0123444
        break;
c01011cd:	eb 26                	jmp    c01011f5 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011cf:	8b 0d 40 34 12 c0    	mov    0xc0123440,%ecx
c01011d5:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c01011dc:	8d 50 01             	lea    0x1(%eax),%edx
c01011df:	66 89 15 44 34 12 c0 	mov    %dx,0xc0123444
c01011e6:	0f b7 c0             	movzwl %ax,%eax
c01011e9:	01 c0                	add    %eax,%eax
c01011eb:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01011f1:	66 89 02             	mov    %ax,(%edx)
        break;
c01011f4:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011f5:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c01011fc:	66 3d cf 07          	cmp    $0x7cf,%ax
c0101200:	76 5b                	jbe    c010125d <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101202:	a1 40 34 12 c0       	mov    0xc0123440,%eax
c0101207:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c010120d:	a1 40 34 12 c0       	mov    0xc0123440,%eax
c0101212:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101219:	00 
c010121a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010121e:	89 04 24             	mov    %eax,(%esp)
c0101221:	e8 6a 79 00 00       	call   c0108b90 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101226:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010122d:	eb 15                	jmp    c0101244 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c010122f:	a1 40 34 12 c0       	mov    0xc0123440,%eax
c0101234:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101237:	01 d2                	add    %edx,%edx
c0101239:	01 d0                	add    %edx,%eax
c010123b:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101240:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101244:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010124b:	7e e2                	jle    c010122f <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c010124d:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c0101254:	83 e8 50             	sub    $0x50,%eax
c0101257:	66 a3 44 34 12 c0    	mov    %ax,0xc0123444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010125d:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c0101264:	0f b7 c0             	movzwl %ax,%eax
c0101267:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010126b:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c010126f:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101273:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101277:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101278:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c010127f:	66 c1 e8 08          	shr    $0x8,%ax
c0101283:	0f b6 c0             	movzbl %al,%eax
c0101286:	0f b7 15 46 34 12 c0 	movzwl 0xc0123446,%edx
c010128d:	83 c2 01             	add    $0x1,%edx
c0101290:	0f b7 d2             	movzwl %dx,%edx
c0101293:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0101297:	88 45 ed             	mov    %al,-0x13(%ebp)
c010129a:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010129e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012a2:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01012a3:	0f b7 05 46 34 12 c0 	movzwl 0xc0123446,%eax
c01012aa:	0f b7 c0             	movzwl %ax,%eax
c01012ad:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01012b1:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01012b5:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012b9:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012bd:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012be:	0f b7 05 44 34 12 c0 	movzwl 0xc0123444,%eax
c01012c5:	0f b6 c0             	movzbl %al,%eax
c01012c8:	0f b7 15 46 34 12 c0 	movzwl 0xc0123446,%edx
c01012cf:	83 c2 01             	add    $0x1,%edx
c01012d2:	0f b7 d2             	movzwl %dx,%edx
c01012d5:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012d9:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012dc:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012e0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012e4:	ee                   	out    %al,(%dx)
}
c01012e5:	83 c4 34             	add    $0x34,%esp
c01012e8:	5b                   	pop    %ebx
c01012e9:	5d                   	pop    %ebp
c01012ea:	c3                   	ret    

c01012eb <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012eb:	55                   	push   %ebp
c01012ec:	89 e5                	mov    %esp,%ebp
c01012ee:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012f1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012f8:	eb 09                	jmp    c0101303 <serial_putc_sub+0x18>
        delay();
c01012fa:	e8 4f fb ff ff       	call   c0100e4e <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012ff:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101303:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101309:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010130d:	89 c2                	mov    %eax,%edx
c010130f:	ec                   	in     (%dx),%al
c0101310:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101313:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101317:	0f b6 c0             	movzbl %al,%eax
c010131a:	83 e0 20             	and    $0x20,%eax
c010131d:	85 c0                	test   %eax,%eax
c010131f:	75 09                	jne    c010132a <serial_putc_sub+0x3f>
c0101321:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101328:	7e d0                	jle    c01012fa <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c010132a:	8b 45 08             	mov    0x8(%ebp),%eax
c010132d:	0f b6 c0             	movzbl %al,%eax
c0101330:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101336:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101339:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010133d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101341:	ee                   	out    %al,(%dx)
}
c0101342:	c9                   	leave  
c0101343:	c3                   	ret    

c0101344 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101344:	55                   	push   %ebp
c0101345:	89 e5                	mov    %esp,%ebp
c0101347:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010134a:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010134e:	74 0d                	je     c010135d <serial_putc+0x19>
        serial_putc_sub(c);
c0101350:	8b 45 08             	mov    0x8(%ebp),%eax
c0101353:	89 04 24             	mov    %eax,(%esp)
c0101356:	e8 90 ff ff ff       	call   c01012eb <serial_putc_sub>
c010135b:	eb 24                	jmp    c0101381 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c010135d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101364:	e8 82 ff ff ff       	call   c01012eb <serial_putc_sub>
        serial_putc_sub(' ');
c0101369:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101370:	e8 76 ff ff ff       	call   c01012eb <serial_putc_sub>
        serial_putc_sub('\b');
c0101375:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010137c:	e8 6a ff ff ff       	call   c01012eb <serial_putc_sub>
    }
}
c0101381:	c9                   	leave  
c0101382:	c3                   	ret    

c0101383 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101383:	55                   	push   %ebp
c0101384:	89 e5                	mov    %esp,%ebp
c0101386:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101389:	eb 33                	jmp    c01013be <cons_intr+0x3b>
        if (c != 0) {
c010138b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010138f:	74 2d                	je     c01013be <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101391:	a1 64 36 12 c0       	mov    0xc0123664,%eax
c0101396:	8d 50 01             	lea    0x1(%eax),%edx
c0101399:	89 15 64 36 12 c0    	mov    %edx,0xc0123664
c010139f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01013a2:	88 90 60 34 12 c0    	mov    %dl,-0x3fedcba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01013a8:	a1 64 36 12 c0       	mov    0xc0123664,%eax
c01013ad:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013b2:	75 0a                	jne    c01013be <cons_intr+0x3b>
                cons.wpos = 0;
c01013b4:	c7 05 64 36 12 c0 00 	movl   $0x0,0xc0123664
c01013bb:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01013be:	8b 45 08             	mov    0x8(%ebp),%eax
c01013c1:	ff d0                	call   *%eax
c01013c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013c6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013ca:	75 bf                	jne    c010138b <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013cc:	c9                   	leave  
c01013cd:	c3                   	ret    

c01013ce <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013ce:	55                   	push   %ebp
c01013cf:	89 e5                	mov    %esp,%ebp
c01013d1:	83 ec 10             	sub    $0x10,%esp
c01013d4:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013da:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013de:	89 c2                	mov    %eax,%edx
c01013e0:	ec                   	in     (%dx),%al
c01013e1:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013e4:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013e8:	0f b6 c0             	movzbl %al,%eax
c01013eb:	83 e0 01             	and    $0x1,%eax
c01013ee:	85 c0                	test   %eax,%eax
c01013f0:	75 07                	jne    c01013f9 <serial_proc_data+0x2b>
        return -1;
c01013f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013f7:	eb 2a                	jmp    c0101423 <serial_proc_data+0x55>
c01013f9:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013ff:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101403:	89 c2                	mov    %eax,%edx
c0101405:	ec                   	in     (%dx),%al
c0101406:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101409:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c010140d:	0f b6 c0             	movzbl %al,%eax
c0101410:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101413:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101417:	75 07                	jne    c0101420 <serial_proc_data+0x52>
        c = '\b';
c0101419:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101420:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101423:	c9                   	leave  
c0101424:	c3                   	ret    

c0101425 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101425:	55                   	push   %ebp
c0101426:	89 e5                	mov    %esp,%ebp
c0101428:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010142b:	a1 48 34 12 c0       	mov    0xc0123448,%eax
c0101430:	85 c0                	test   %eax,%eax
c0101432:	74 0c                	je     c0101440 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101434:	c7 04 24 ce 13 10 c0 	movl   $0xc01013ce,(%esp)
c010143b:	e8 43 ff ff ff       	call   c0101383 <cons_intr>
    }
}
c0101440:	c9                   	leave  
c0101441:	c3                   	ret    

c0101442 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101442:	55                   	push   %ebp
c0101443:	89 e5                	mov    %esp,%ebp
c0101445:	83 ec 38             	sub    $0x38,%esp
c0101448:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010144e:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101452:	89 c2                	mov    %eax,%edx
c0101454:	ec                   	in     (%dx),%al
c0101455:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101458:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010145c:	0f b6 c0             	movzbl %al,%eax
c010145f:	83 e0 01             	and    $0x1,%eax
c0101462:	85 c0                	test   %eax,%eax
c0101464:	75 0a                	jne    c0101470 <kbd_proc_data+0x2e>
        return -1;
c0101466:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010146b:	e9 59 01 00 00       	jmp    c01015c9 <kbd_proc_data+0x187>
c0101470:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101476:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010147a:	89 c2                	mov    %eax,%edx
c010147c:	ec                   	in     (%dx),%al
c010147d:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101480:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101484:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101487:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010148b:	75 17                	jne    c01014a4 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c010148d:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c0101492:	83 c8 40             	or     $0x40,%eax
c0101495:	a3 68 36 12 c0       	mov    %eax,0xc0123668
        return 0;
c010149a:	b8 00 00 00 00       	mov    $0x0,%eax
c010149f:	e9 25 01 00 00       	jmp    c01015c9 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c01014a4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014a8:	84 c0                	test   %al,%al
c01014aa:	79 47                	jns    c01014f3 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01014ac:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c01014b1:	83 e0 40             	and    $0x40,%eax
c01014b4:	85 c0                	test   %eax,%eax
c01014b6:	75 09                	jne    c01014c1 <kbd_proc_data+0x7f>
c01014b8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014bc:	83 e0 7f             	and    $0x7f,%eax
c01014bf:	eb 04                	jmp    c01014c5 <kbd_proc_data+0x83>
c01014c1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014c5:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014c8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014cc:	0f b6 80 40 00 12 c0 	movzbl -0x3fedffc0(%eax),%eax
c01014d3:	83 c8 40             	or     $0x40,%eax
c01014d6:	0f b6 c0             	movzbl %al,%eax
c01014d9:	f7 d0                	not    %eax
c01014db:	89 c2                	mov    %eax,%edx
c01014dd:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c01014e2:	21 d0                	and    %edx,%eax
c01014e4:	a3 68 36 12 c0       	mov    %eax,0xc0123668
        return 0;
c01014e9:	b8 00 00 00 00       	mov    $0x0,%eax
c01014ee:	e9 d6 00 00 00       	jmp    c01015c9 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01014f3:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c01014f8:	83 e0 40             	and    $0x40,%eax
c01014fb:	85 c0                	test   %eax,%eax
c01014fd:	74 11                	je     c0101510 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014ff:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101503:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c0101508:	83 e0 bf             	and    $0xffffffbf,%eax
c010150b:	a3 68 36 12 c0       	mov    %eax,0xc0123668
    }

    shift |= shiftcode[data];
c0101510:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101514:	0f b6 80 40 00 12 c0 	movzbl -0x3fedffc0(%eax),%eax
c010151b:	0f b6 d0             	movzbl %al,%edx
c010151e:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c0101523:	09 d0                	or     %edx,%eax
c0101525:	a3 68 36 12 c0       	mov    %eax,0xc0123668
    shift ^= togglecode[data];
c010152a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010152e:	0f b6 80 40 01 12 c0 	movzbl -0x3fedfec0(%eax),%eax
c0101535:	0f b6 d0             	movzbl %al,%edx
c0101538:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c010153d:	31 d0                	xor    %edx,%eax
c010153f:	a3 68 36 12 c0       	mov    %eax,0xc0123668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101544:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c0101549:	83 e0 03             	and    $0x3,%eax
c010154c:	8b 14 85 40 05 12 c0 	mov    -0x3fedfac0(,%eax,4),%edx
c0101553:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101557:	01 d0                	add    %edx,%eax
c0101559:	0f b6 00             	movzbl (%eax),%eax
c010155c:	0f b6 c0             	movzbl %al,%eax
c010155f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101562:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c0101567:	83 e0 08             	and    $0x8,%eax
c010156a:	85 c0                	test   %eax,%eax
c010156c:	74 22                	je     c0101590 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c010156e:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101572:	7e 0c                	jle    c0101580 <kbd_proc_data+0x13e>
c0101574:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101578:	7f 06                	jg     c0101580 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c010157a:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010157e:	eb 10                	jmp    c0101590 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101580:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101584:	7e 0a                	jle    c0101590 <kbd_proc_data+0x14e>
c0101586:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010158a:	7f 04                	jg     c0101590 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010158c:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101590:	a1 68 36 12 c0       	mov    0xc0123668,%eax
c0101595:	f7 d0                	not    %eax
c0101597:	83 e0 06             	and    $0x6,%eax
c010159a:	85 c0                	test   %eax,%eax
c010159c:	75 28                	jne    c01015c6 <kbd_proc_data+0x184>
c010159e:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01015a5:	75 1f                	jne    c01015c6 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c01015a7:	c7 04 24 0f 90 10 c0 	movl   $0xc010900f,(%esp)
c01015ae:	e8 a4 ed ff ff       	call   c0100357 <cprintf>
c01015b3:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015b9:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015bd:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015c1:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01015c5:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015c9:	c9                   	leave  
c01015ca:	c3                   	ret    

c01015cb <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015cb:	55                   	push   %ebp
c01015cc:	89 e5                	mov    %esp,%ebp
c01015ce:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015d1:	c7 04 24 42 14 10 c0 	movl   $0xc0101442,(%esp)
c01015d8:	e8 a6 fd ff ff       	call   c0101383 <cons_intr>
}
c01015dd:	c9                   	leave  
c01015de:	c3                   	ret    

c01015df <kbd_init>:

static void
kbd_init(void) {
c01015df:	55                   	push   %ebp
c01015e0:	89 e5                	mov    %esp,%ebp
c01015e2:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015e5:	e8 e1 ff ff ff       	call   c01015cb <kbd_intr>
    pic_enable(IRQ_KBD);
c01015ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015f1:	e8 b2 09 00 00       	call   c0101fa8 <pic_enable>
}
c01015f6:	c9                   	leave  
c01015f7:	c3                   	ret    

c01015f8 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015f8:	55                   	push   %ebp
c01015f9:	89 e5                	mov    %esp,%ebp
c01015fb:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015fe:	e8 93 f8 ff ff       	call   c0100e96 <cga_init>
    serial_init();
c0101603:	e8 74 f9 ff ff       	call   c0100f7c <serial_init>
    kbd_init();
c0101608:	e8 d2 ff ff ff       	call   c01015df <kbd_init>
    if (!serial_exists) {
c010160d:	a1 48 34 12 c0       	mov    0xc0123448,%eax
c0101612:	85 c0                	test   %eax,%eax
c0101614:	75 0c                	jne    c0101622 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101616:	c7 04 24 1b 90 10 c0 	movl   $0xc010901b,(%esp)
c010161d:	e8 35 ed ff ff       	call   c0100357 <cprintf>
    }
}
c0101622:	c9                   	leave  
c0101623:	c3                   	ret    

c0101624 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101624:	55                   	push   %ebp
c0101625:	89 e5                	mov    %esp,%ebp
c0101627:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010162a:	e8 e2 f7 ff ff       	call   c0100e11 <__intr_save>
c010162f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101632:	8b 45 08             	mov    0x8(%ebp),%eax
c0101635:	89 04 24             	mov    %eax,(%esp)
c0101638:	e8 9b fa ff ff       	call   c01010d8 <lpt_putc>
        cga_putc(c);
c010163d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101640:	89 04 24             	mov    %eax,(%esp)
c0101643:	e8 cf fa ff ff       	call   c0101117 <cga_putc>
        serial_putc(c);
c0101648:	8b 45 08             	mov    0x8(%ebp),%eax
c010164b:	89 04 24             	mov    %eax,(%esp)
c010164e:	e8 f1 fc ff ff       	call   c0101344 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101653:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101656:	89 04 24             	mov    %eax,(%esp)
c0101659:	e8 dd f7 ff ff       	call   c0100e3b <__intr_restore>
}
c010165e:	c9                   	leave  
c010165f:	c3                   	ret    

c0101660 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101660:	55                   	push   %ebp
c0101661:	89 e5                	mov    %esp,%ebp
c0101663:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101666:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010166d:	e8 9f f7 ff ff       	call   c0100e11 <__intr_save>
c0101672:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101675:	e8 ab fd ff ff       	call   c0101425 <serial_intr>
        kbd_intr();
c010167a:	e8 4c ff ff ff       	call   c01015cb <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c010167f:	8b 15 60 36 12 c0    	mov    0xc0123660,%edx
c0101685:	a1 64 36 12 c0       	mov    0xc0123664,%eax
c010168a:	39 c2                	cmp    %eax,%edx
c010168c:	74 31                	je     c01016bf <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010168e:	a1 60 36 12 c0       	mov    0xc0123660,%eax
c0101693:	8d 50 01             	lea    0x1(%eax),%edx
c0101696:	89 15 60 36 12 c0    	mov    %edx,0xc0123660
c010169c:	0f b6 80 60 34 12 c0 	movzbl -0x3fedcba0(%eax),%eax
c01016a3:	0f b6 c0             	movzbl %al,%eax
c01016a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01016a9:	a1 60 36 12 c0       	mov    0xc0123660,%eax
c01016ae:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016b3:	75 0a                	jne    c01016bf <cons_getc+0x5f>
                cons.rpos = 0;
c01016b5:	c7 05 60 36 12 c0 00 	movl   $0x0,0xc0123660
c01016bc:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016c2:	89 04 24             	mov    %eax,(%esp)
c01016c5:	e8 71 f7 ff ff       	call   c0100e3b <__intr_restore>
    return c;
c01016ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016cd:	c9                   	leave  
c01016ce:	c3                   	ret    

c01016cf <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c01016cf:	55                   	push   %ebp
c01016d0:	89 e5                	mov    %esp,%ebp
c01016d2:	83 ec 14             	sub    $0x14,%esp
c01016d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01016d8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c01016dc:	90                   	nop
c01016dd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016e1:	83 c0 07             	add    $0x7,%eax
c01016e4:	0f b7 c0             	movzwl %ax,%eax
c01016e7:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01016eb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01016ef:	89 c2                	mov    %eax,%edx
c01016f1:	ec                   	in     (%dx),%al
c01016f2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01016f5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01016f9:	0f b6 c0             	movzbl %al,%eax
c01016fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01016ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101702:	25 80 00 00 00       	and    $0x80,%eax
c0101707:	85 c0                	test   %eax,%eax
c0101709:	75 d2                	jne    c01016dd <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c010170b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010170f:	74 11                	je     c0101722 <ide_wait_ready+0x53>
c0101711:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101714:	83 e0 21             	and    $0x21,%eax
c0101717:	85 c0                	test   %eax,%eax
c0101719:	74 07                	je     c0101722 <ide_wait_ready+0x53>
        return -1;
c010171b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101720:	eb 05                	jmp    c0101727 <ide_wait_ready+0x58>
    }
    return 0;
c0101722:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101727:	c9                   	leave  
c0101728:	c3                   	ret    

c0101729 <ide_init>:

void
ide_init(void) {
c0101729:	55                   	push   %ebp
c010172a:	89 e5                	mov    %esp,%ebp
c010172c:	57                   	push   %edi
c010172d:	53                   	push   %ebx
c010172e:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101734:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c010173a:	e9 d6 02 00 00       	jmp    c0101a15 <ide_init+0x2ec>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c010173f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101743:	c1 e0 03             	shl    $0x3,%eax
c0101746:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010174d:	29 c2                	sub    %eax,%edx
c010174f:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101755:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0101758:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010175c:	66 d1 e8             	shr    %ax
c010175f:	0f b7 c0             	movzwl %ax,%eax
c0101762:	0f b7 04 85 3c 90 10 	movzwl -0x3fef6fc4(,%eax,4),%eax
c0101769:	c0 
c010176a:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c010176e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101772:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101779:	00 
c010177a:	89 04 24             	mov    %eax,(%esp)
c010177d:	e8 4d ff ff ff       	call   c01016cf <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0101782:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101786:	83 e0 01             	and    $0x1,%eax
c0101789:	c1 e0 04             	shl    $0x4,%eax
c010178c:	83 c8 e0             	or     $0xffffffe0,%eax
c010178f:	0f b6 c0             	movzbl %al,%eax
c0101792:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101796:	83 c2 06             	add    $0x6,%edx
c0101799:	0f b7 d2             	movzwl %dx,%edx
c010179c:	66 89 55 d2          	mov    %dx,-0x2e(%ebp)
c01017a0:	88 45 d1             	mov    %al,-0x2f(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017a3:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01017a7:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01017ab:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01017ac:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01017b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01017b7:	00 
c01017b8:	89 04 24             	mov    %eax,(%esp)
c01017bb:	e8 0f ff ff ff       	call   c01016cf <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c01017c0:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01017c4:	83 c0 07             	add    $0x7,%eax
c01017c7:	0f b7 c0             	movzwl %ax,%eax
c01017ca:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c01017ce:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c01017d2:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01017d6:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01017da:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c01017db:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01017df:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01017e6:	00 
c01017e7:	89 04 24             	mov    %eax,(%esp)
c01017ea:	e8 e0 fe ff ff       	call   c01016cf <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c01017ef:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c01017f3:	83 c0 07             	add    $0x7,%eax
c01017f6:	0f b7 c0             	movzwl %ax,%eax
c01017f9:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017fd:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0101801:	89 c2                	mov    %eax,%edx
c0101803:	ec                   	in     (%dx),%al
c0101804:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0101807:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c010180b:	84 c0                	test   %al,%al
c010180d:	0f 84 f7 01 00 00    	je     c0101a0a <ide_init+0x2e1>
c0101813:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0101817:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010181e:	00 
c010181f:	89 04 24             	mov    %eax,(%esp)
c0101822:	e8 a8 fe ff ff       	call   c01016cf <ide_wait_ready>
c0101827:	85 c0                	test   %eax,%eax
c0101829:	0f 85 db 01 00 00    	jne    c0101a0a <ide_init+0x2e1>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c010182f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101833:	c1 e0 03             	shl    $0x3,%eax
c0101836:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010183d:	29 c2                	sub    %eax,%edx
c010183f:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101845:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0101848:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c010184c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010184f:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101855:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0101858:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c010185f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0101862:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0101865:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0101868:	89 cb                	mov    %ecx,%ebx
c010186a:	89 df                	mov    %ebx,%edi
c010186c:	89 c1                	mov    %eax,%ecx
c010186e:	fc                   	cld    
c010186f:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101871:	89 c8                	mov    %ecx,%eax
c0101873:	89 fb                	mov    %edi,%ebx
c0101875:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0101878:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c010187b:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0101881:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0101884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101887:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c010188d:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0101890:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101893:	25 00 00 00 04       	and    $0x4000000,%eax
c0101898:	85 c0                	test   %eax,%eax
c010189a:	74 0e                	je     c01018aa <ide_init+0x181>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c010189c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010189f:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c01018a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01018a8:	eb 09                	jmp    c01018b3 <ide_init+0x18a>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c01018aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01018ad:	8b 40 78             	mov    0x78(%eax),%eax
c01018b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c01018b3:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01018b7:	c1 e0 03             	shl    $0x3,%eax
c01018ba:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01018c1:	29 c2                	sub    %eax,%edx
c01018c3:	81 c2 80 36 12 c0    	add    $0xc0123680,%edx
c01018c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01018cc:	89 42 04             	mov    %eax,0x4(%edx)
        ide_devices[ideno].size = sectors;
c01018cf:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01018d3:	c1 e0 03             	shl    $0x3,%eax
c01018d6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01018dd:	29 c2                	sub    %eax,%edx
c01018df:	81 c2 80 36 12 c0    	add    $0xc0123680,%edx
c01018e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01018e8:	89 42 08             	mov    %eax,0x8(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01018eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01018ee:	83 c0 62             	add    $0x62,%eax
c01018f1:	0f b7 00             	movzwl (%eax),%eax
c01018f4:	0f b7 c0             	movzwl %ax,%eax
c01018f7:	25 00 02 00 00       	and    $0x200,%eax
c01018fc:	85 c0                	test   %eax,%eax
c01018fe:	75 24                	jne    c0101924 <ide_init+0x1fb>
c0101900:	c7 44 24 0c 44 90 10 	movl   $0xc0109044,0xc(%esp)
c0101907:	c0 
c0101908:	c7 44 24 08 87 90 10 	movl   $0xc0109087,0x8(%esp)
c010190f:	c0 
c0101910:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0101917:	00 
c0101918:	c7 04 24 9c 90 10 c0 	movl   $0xc010909c,(%esp)
c010191f:	e8 bd f3 ff ff       	call   c0100ce1 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0101924:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101928:	c1 e0 03             	shl    $0x3,%eax
c010192b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101932:	29 c2                	sub    %eax,%edx
c0101934:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c010193a:	83 c0 0c             	add    $0xc,%eax
c010193d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101940:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101943:	83 c0 36             	add    $0x36,%eax
c0101946:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0101949:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0101950:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101957:	eb 34                	jmp    c010198d <ide_init+0x264>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101959:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010195c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010195f:	01 c2                	add    %eax,%edx
c0101961:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101964:	8d 48 01             	lea    0x1(%eax),%ecx
c0101967:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010196a:	01 c8                	add    %ecx,%eax
c010196c:	0f b6 00             	movzbl (%eax),%eax
c010196f:	88 02                	mov    %al,(%edx)
c0101971:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101974:	8d 50 01             	lea    0x1(%eax),%edx
c0101977:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010197a:	01 c2                	add    %eax,%edx
c010197c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010197f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0101982:	01 c8                	add    %ecx,%eax
c0101984:	0f b6 00             	movzbl (%eax),%eax
c0101987:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c0101989:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c010198d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101990:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0101993:	72 c4                	jb     c0101959 <ide_init+0x230>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c0101995:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101998:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010199b:	01 d0                	add    %edx,%eax
c010199d:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c01019a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019a3:	8d 50 ff             	lea    -0x1(%eax),%edx
c01019a6:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01019a9:	85 c0                	test   %eax,%eax
c01019ab:	74 0f                	je     c01019bc <ide_init+0x293>
c01019ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01019b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01019b3:	01 d0                	add    %edx,%eax
c01019b5:	0f b6 00             	movzbl (%eax),%eax
c01019b8:	3c 20                	cmp    $0x20,%al
c01019ba:	74 d9                	je     c0101995 <ide_init+0x26c>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c01019bc:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019c0:	c1 e0 03             	shl    $0x3,%eax
c01019c3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019ca:	29 c2                	sub    %eax,%edx
c01019cc:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c01019d2:	8d 48 0c             	lea    0xc(%eax),%ecx
c01019d5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019d9:	c1 e0 03             	shl    $0x3,%eax
c01019dc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01019e3:	29 c2                	sub    %eax,%edx
c01019e5:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c01019eb:	8b 50 08             	mov    0x8(%eax),%edx
c01019ee:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01019f2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01019f6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01019fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01019fe:	c7 04 24 ae 90 10 c0 	movl   $0xc01090ae,(%esp)
c0101a05:	e8 4d e9 ff ff       	call   c0100357 <cprintf>

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0101a0a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101a0e:	83 c0 01             	add    $0x1,%eax
c0101a11:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101a15:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0101a1a:	0f 86 1f fd ff ff    	jbe    c010173f <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0101a20:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0101a27:	e8 7c 05 00 00       	call   c0101fa8 <pic_enable>
    pic_enable(IRQ_IDE2);
c0101a2c:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101a33:	e8 70 05 00 00       	call   c0101fa8 <pic_enable>
}
c0101a38:	81 c4 50 02 00 00    	add    $0x250,%esp
c0101a3e:	5b                   	pop    %ebx
c0101a3f:	5f                   	pop    %edi
c0101a40:	5d                   	pop    %ebp
c0101a41:	c3                   	ret    

c0101a42 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101a42:	55                   	push   %ebp
c0101a43:	89 e5                	mov    %esp,%ebp
c0101a45:	83 ec 04             	sub    $0x4,%esp
c0101a48:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a4b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0101a4f:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0101a54:	77 24                	ja     c0101a7a <ide_device_valid+0x38>
c0101a56:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101a5a:	c1 e0 03             	shl    $0x3,%eax
c0101a5d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101a64:	29 c2                	sub    %eax,%edx
c0101a66:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101a6c:	0f b6 00             	movzbl (%eax),%eax
c0101a6f:	84 c0                	test   %al,%al
c0101a71:	74 07                	je     c0101a7a <ide_device_valid+0x38>
c0101a73:	b8 01 00 00 00       	mov    $0x1,%eax
c0101a78:	eb 05                	jmp    c0101a7f <ide_device_valid+0x3d>
c0101a7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101a7f:	c9                   	leave  
c0101a80:	c3                   	ret    

c0101a81 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101a81:	55                   	push   %ebp
c0101a82:	89 e5                	mov    %esp,%ebp
c0101a84:	83 ec 08             	sub    $0x8,%esp
c0101a87:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a8a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0101a8e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101a92:	89 04 24             	mov    %eax,(%esp)
c0101a95:	e8 a8 ff ff ff       	call   c0101a42 <ide_device_valid>
c0101a9a:	85 c0                	test   %eax,%eax
c0101a9c:	74 1b                	je     c0101ab9 <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0101a9e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101aa2:	c1 e0 03             	shl    $0x3,%eax
c0101aa5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101aac:	29 c2                	sub    %eax,%edx
c0101aae:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101ab4:	8b 40 08             	mov    0x8(%eax),%eax
c0101ab7:	eb 05                	jmp    c0101abe <ide_device_size+0x3d>
    }
    return 0;
c0101ab9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101abe:	c9                   	leave  
c0101abf:	c3                   	ret    

c0101ac0 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101ac0:	55                   	push   %ebp
c0101ac1:	89 e5                	mov    %esp,%ebp
c0101ac3:	57                   	push   %edi
c0101ac4:	53                   	push   %ebx
c0101ac5:	83 ec 50             	sub    $0x50,%esp
c0101ac8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101acb:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101acf:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101ad6:	77 24                	ja     c0101afc <ide_read_secs+0x3c>
c0101ad8:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101add:	77 1d                	ja     c0101afc <ide_read_secs+0x3c>
c0101adf:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101ae3:	c1 e0 03             	shl    $0x3,%eax
c0101ae6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101aed:	29 c2                	sub    %eax,%edx
c0101aef:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101af5:	0f b6 00             	movzbl (%eax),%eax
c0101af8:	84 c0                	test   %al,%al
c0101afa:	75 24                	jne    c0101b20 <ide_read_secs+0x60>
c0101afc:	c7 44 24 0c cc 90 10 	movl   $0xc01090cc,0xc(%esp)
c0101b03:	c0 
c0101b04:	c7 44 24 08 87 90 10 	movl   $0xc0109087,0x8(%esp)
c0101b0b:	c0 
c0101b0c:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0101b13:	00 
c0101b14:	c7 04 24 9c 90 10 c0 	movl   $0xc010909c,(%esp)
c0101b1b:	e8 c1 f1 ff ff       	call   c0100ce1 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101b20:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101b27:	77 0f                	ja     c0101b38 <ide_read_secs+0x78>
c0101b29:	8b 45 14             	mov    0x14(%ebp),%eax
c0101b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101b2f:	01 d0                	add    %edx,%eax
c0101b31:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101b36:	76 24                	jbe    c0101b5c <ide_read_secs+0x9c>
c0101b38:	c7 44 24 0c f4 90 10 	movl   $0xc01090f4,0xc(%esp)
c0101b3f:	c0 
c0101b40:	c7 44 24 08 87 90 10 	movl   $0xc0109087,0x8(%esp)
c0101b47:	c0 
c0101b48:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101b4f:	00 
c0101b50:	c7 04 24 9c 90 10 c0 	movl   $0xc010909c,(%esp)
c0101b57:	e8 85 f1 ff ff       	call   c0100ce1 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101b5c:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101b60:	66 d1 e8             	shr    %ax
c0101b63:	0f b7 c0             	movzwl %ax,%eax
c0101b66:	0f b7 04 85 3c 90 10 	movzwl -0x3fef6fc4(,%eax,4),%eax
c0101b6d:	c0 
c0101b6e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101b72:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101b76:	66 d1 e8             	shr    %ax
c0101b79:	0f b7 c0             	movzwl %ax,%eax
c0101b7c:	0f b7 04 85 3e 90 10 	movzwl -0x3fef6fc2(,%eax,4),%eax
c0101b83:	c0 
c0101b84:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101b88:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101b8c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101b93:	00 
c0101b94:	89 04 24             	mov    %eax,(%esp)
c0101b97:	e8 33 fb ff ff       	call   c01016cf <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101b9c:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101ba0:	83 c0 02             	add    $0x2,%eax
c0101ba3:	0f b7 c0             	movzwl %ax,%eax
c0101ba6:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101baa:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101bae:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101bb2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101bb6:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101bb7:	8b 45 14             	mov    0x14(%ebp),%eax
c0101bba:	0f b6 c0             	movzbl %al,%eax
c0101bbd:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101bc1:	83 c2 02             	add    $0x2,%edx
c0101bc4:	0f b7 d2             	movzwl %dx,%edx
c0101bc7:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101bcb:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101bce:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101bd2:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101bd6:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101bda:	0f b6 c0             	movzbl %al,%eax
c0101bdd:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101be1:	83 c2 03             	add    $0x3,%edx
c0101be4:	0f b7 d2             	movzwl %dx,%edx
c0101be7:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101beb:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101bee:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101bf2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101bf6:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101bf7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101bfa:	c1 e8 08             	shr    $0x8,%eax
c0101bfd:	0f b6 c0             	movzbl %al,%eax
c0101c00:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c04:	83 c2 04             	add    $0x4,%edx
c0101c07:	0f b7 d2             	movzwl %dx,%edx
c0101c0a:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101c0e:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101c11:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101c15:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101c19:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101c1a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c1d:	c1 e8 10             	shr    $0x10,%eax
c0101c20:	0f b6 c0             	movzbl %al,%eax
c0101c23:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c27:	83 c2 05             	add    $0x5,%edx
c0101c2a:	0f b7 d2             	movzwl %dx,%edx
c0101c2d:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101c31:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101c34:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101c38:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101c3c:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101c3d:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101c41:	83 e0 01             	and    $0x1,%eax
c0101c44:	c1 e0 04             	shl    $0x4,%eax
c0101c47:	89 c2                	mov    %eax,%edx
c0101c49:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c4c:	c1 e8 18             	shr    $0x18,%eax
c0101c4f:	83 e0 0f             	and    $0xf,%eax
c0101c52:	09 d0                	or     %edx,%eax
c0101c54:	83 c8 e0             	or     $0xffffffe0,%eax
c0101c57:	0f b6 c0             	movzbl %al,%eax
c0101c5a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101c5e:	83 c2 06             	add    $0x6,%edx
c0101c61:	0f b7 d2             	movzwl %dx,%edx
c0101c64:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101c68:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101c6b:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101c6f:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101c73:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c0101c74:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101c78:	83 c0 07             	add    $0x7,%eax
c0101c7b:	0f b7 c0             	movzwl %ax,%eax
c0101c7e:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101c82:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0101c86:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101c8a:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101c8e:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101c8f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101c96:	eb 5a                	jmp    c0101cf2 <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101c98:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101c9c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101ca3:	00 
c0101ca4:	89 04 24             	mov    %eax,(%esp)
c0101ca7:	e8 23 fa ff ff       	call   c01016cf <ide_wait_ready>
c0101cac:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101caf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101cb3:	74 02                	je     c0101cb7 <ide_read_secs+0x1f7>
            goto out;
c0101cb5:	eb 41                	jmp    c0101cf8 <ide_read_secs+0x238>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0101cb7:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101cbb:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101cbe:	8b 45 10             	mov    0x10(%ebp),%eax
c0101cc1:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101cc4:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101ccb:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101cce:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101cd1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101cd4:	89 cb                	mov    %ecx,%ebx
c0101cd6:	89 df                	mov    %ebx,%edi
c0101cd8:	89 c1                	mov    %eax,%ecx
c0101cda:	fc                   	cld    
c0101cdb:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0101cdd:	89 c8                	mov    %ecx,%eax
c0101cdf:	89 fb                	mov    %edi,%ebx
c0101ce1:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101ce4:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101ce7:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101ceb:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101cf2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101cf6:	75 a0                	jne    c0101c98 <ide_read_secs+0x1d8>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101cfb:	83 c4 50             	add    $0x50,%esp
c0101cfe:	5b                   	pop    %ebx
c0101cff:	5f                   	pop    %edi
c0101d00:	5d                   	pop    %ebp
c0101d01:	c3                   	ret    

c0101d02 <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c0101d02:	55                   	push   %ebp
c0101d03:	89 e5                	mov    %esp,%ebp
c0101d05:	56                   	push   %esi
c0101d06:	53                   	push   %ebx
c0101d07:	83 ec 50             	sub    $0x50,%esp
c0101d0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d0d:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0101d11:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0101d18:	77 24                	ja     c0101d3e <ide_write_secs+0x3c>
c0101d1a:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0101d1f:	77 1d                	ja     c0101d3e <ide_write_secs+0x3c>
c0101d21:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101d25:	c1 e0 03             	shl    $0x3,%eax
c0101d28:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101d2f:	29 c2                	sub    %eax,%edx
c0101d31:	8d 82 80 36 12 c0    	lea    -0x3fedc980(%edx),%eax
c0101d37:	0f b6 00             	movzbl (%eax),%eax
c0101d3a:	84 c0                	test   %al,%al
c0101d3c:	75 24                	jne    c0101d62 <ide_write_secs+0x60>
c0101d3e:	c7 44 24 0c cc 90 10 	movl   $0xc01090cc,0xc(%esp)
c0101d45:	c0 
c0101d46:	c7 44 24 08 87 90 10 	movl   $0xc0109087,0x8(%esp)
c0101d4d:	c0 
c0101d4e:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101d55:	00 
c0101d56:	c7 04 24 9c 90 10 c0 	movl   $0xc010909c,(%esp)
c0101d5d:	e8 7f ef ff ff       	call   c0100ce1 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101d62:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101d69:	77 0f                	ja     c0101d7a <ide_write_secs+0x78>
c0101d6b:	8b 45 14             	mov    0x14(%ebp),%eax
c0101d6e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101d71:	01 d0                	add    %edx,%eax
c0101d73:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101d78:	76 24                	jbe    c0101d9e <ide_write_secs+0x9c>
c0101d7a:	c7 44 24 0c f4 90 10 	movl   $0xc01090f4,0xc(%esp)
c0101d81:	c0 
c0101d82:	c7 44 24 08 87 90 10 	movl   $0xc0109087,0x8(%esp)
c0101d89:	c0 
c0101d8a:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c0101d91:	00 
c0101d92:	c7 04 24 9c 90 10 c0 	movl   $0xc010909c,(%esp)
c0101d99:	e8 43 ef ff ff       	call   c0100ce1 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101d9e:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101da2:	66 d1 e8             	shr    %ax
c0101da5:	0f b7 c0             	movzwl %ax,%eax
c0101da8:	0f b7 04 85 3c 90 10 	movzwl -0x3fef6fc4(,%eax,4),%eax
c0101daf:	c0 
c0101db0:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101db4:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101db8:	66 d1 e8             	shr    %ax
c0101dbb:	0f b7 c0             	movzwl %ax,%eax
c0101dbe:	0f b7 04 85 3e 90 10 	movzwl -0x3fef6fc2(,%eax,4),%eax
c0101dc5:	c0 
c0101dc6:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101dca:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101dce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101dd5:	00 
c0101dd6:	89 04 24             	mov    %eax,(%esp)
c0101dd9:	e8 f1 f8 ff ff       	call   c01016cf <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0101dde:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101de2:	83 c0 02             	add    $0x2,%eax
c0101de5:	0f b7 c0             	movzwl %ax,%eax
c0101de8:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101dec:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101df0:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101df4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101df8:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101df9:	8b 45 14             	mov    0x14(%ebp),%eax
c0101dfc:	0f b6 c0             	movzbl %al,%eax
c0101dff:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e03:	83 c2 02             	add    $0x2,%edx
c0101e06:	0f b7 d2             	movzwl %dx,%edx
c0101e09:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101e0d:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101e10:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101e14:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101e18:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0101e19:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e1c:	0f b6 c0             	movzbl %al,%eax
c0101e1f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e23:	83 c2 03             	add    $0x3,%edx
c0101e26:	0f b7 d2             	movzwl %dx,%edx
c0101e29:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0101e2d:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0101e30:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101e34:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101e38:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101e39:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e3c:	c1 e8 08             	shr    $0x8,%eax
c0101e3f:	0f b6 c0             	movzbl %al,%eax
c0101e42:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e46:	83 c2 04             	add    $0x4,%edx
c0101e49:	0f b7 d2             	movzwl %dx,%edx
c0101e4c:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101e50:	88 45 e1             	mov    %al,-0x1f(%ebp)
c0101e53:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101e57:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101e5b:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e5f:	c1 e8 10             	shr    $0x10,%eax
c0101e62:	0f b6 c0             	movzbl %al,%eax
c0101e65:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101e69:	83 c2 05             	add    $0x5,%edx
c0101e6c:	0f b7 d2             	movzwl %dx,%edx
c0101e6f:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c0101e73:	88 45 dd             	mov    %al,-0x23(%ebp)
c0101e76:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101e7a:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101e7e:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101e7f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101e83:	83 e0 01             	and    $0x1,%eax
c0101e86:	c1 e0 04             	shl    $0x4,%eax
c0101e89:	89 c2                	mov    %eax,%edx
c0101e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101e8e:	c1 e8 18             	shr    $0x18,%eax
c0101e91:	83 e0 0f             	and    $0xf,%eax
c0101e94:	09 d0                	or     %edx,%eax
c0101e96:	83 c8 e0             	or     $0xffffffe0,%eax
c0101e99:	0f b6 c0             	movzbl %al,%eax
c0101e9c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ea0:	83 c2 06             	add    $0x6,%edx
c0101ea3:	0f b7 d2             	movzwl %dx,%edx
c0101ea6:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0101eaa:	88 45 d9             	mov    %al,-0x27(%ebp)
c0101ead:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101eb1:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101eb5:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101eb6:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101eba:	83 c0 07             	add    $0x7,%eax
c0101ebd:	0f b7 c0             	movzwl %ax,%eax
c0101ec0:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c0101ec4:	c6 45 d5 30          	movb   $0x30,-0x2b(%ebp)
c0101ec8:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101ecc:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101ed0:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101ed1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101ed8:	eb 5a                	jmp    c0101f34 <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101eda:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101ede:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0101ee5:	00 
c0101ee6:	89 04 24             	mov    %eax,(%esp)
c0101ee9:	e8 e1 f7 ff ff       	call   c01016cf <ide_wait_ready>
c0101eee:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101ef1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101ef5:	74 02                	je     c0101ef9 <ide_write_secs+0x1f7>
            goto out;
c0101ef7:	eb 41                	jmp    c0101f3a <ide_write_secs+0x238>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0101ef9:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101efd:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101f00:	8b 45 10             	mov    0x10(%ebp),%eax
c0101f03:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0101f06:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c0101f0d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0101f10:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c0101f13:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0101f16:	89 cb                	mov    %ecx,%ebx
c0101f18:	89 de                	mov    %ebx,%esi
c0101f1a:	89 c1                	mov    %eax,%ecx
c0101f1c:	fc                   	cld    
c0101f1d:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c0101f1f:	89 c8                	mov    %ecx,%eax
c0101f21:	89 f3                	mov    %esi,%ebx
c0101f23:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c0101f26:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101f29:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0101f2d:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101f34:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101f38:	75 a0                	jne    c0101eda <ide_write_secs+0x1d8>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0101f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f3d:	83 c4 50             	add    $0x50,%esp
c0101f40:	5b                   	pop    %ebx
c0101f41:	5e                   	pop    %esi
c0101f42:	5d                   	pop    %ebp
c0101f43:	c3                   	ret    

c0101f44 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101f44:	55                   	push   %ebp
c0101f45:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c0101f47:	fb                   	sti    
    sti();
}
c0101f48:	5d                   	pop    %ebp
c0101f49:	c3                   	ret    

c0101f4a <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101f4a:	55                   	push   %ebp
c0101f4b:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c0101f4d:	fa                   	cli    
    cli();
}
c0101f4e:	5d                   	pop    %ebp
c0101f4f:	c3                   	ret    

c0101f50 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101f50:	55                   	push   %ebp
c0101f51:	89 e5                	mov    %esp,%ebp
c0101f53:	83 ec 14             	sub    $0x14,%esp
c0101f56:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f59:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101f5d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f61:	66 a3 50 05 12 c0    	mov    %ax,0xc0120550
    if (did_init) {
c0101f67:	a1 60 37 12 c0       	mov    0xc0123760,%eax
c0101f6c:	85 c0                	test   %eax,%eax
c0101f6e:	74 36                	je     c0101fa6 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c0101f70:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f74:	0f b6 c0             	movzbl %al,%eax
c0101f77:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101f7d:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101f80:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101f84:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101f88:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101f89:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f8d:	66 c1 e8 08          	shr    $0x8,%ax
c0101f91:	0f b6 c0             	movzbl %al,%eax
c0101f94:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101f9a:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101f9d:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101fa1:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101fa5:	ee                   	out    %al,(%dx)
    }
}
c0101fa6:	c9                   	leave  
c0101fa7:	c3                   	ret    

c0101fa8 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101fa8:	55                   	push   %ebp
c0101fa9:	89 e5                	mov    %esp,%ebp
c0101fab:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101fae:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fb1:	ba 01 00 00 00       	mov    $0x1,%edx
c0101fb6:	89 c1                	mov    %eax,%ecx
c0101fb8:	d3 e2                	shl    %cl,%edx
c0101fba:	89 d0                	mov    %edx,%eax
c0101fbc:	f7 d0                	not    %eax
c0101fbe:	89 c2                	mov    %eax,%edx
c0101fc0:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c0101fc7:	21 d0                	and    %edx,%eax
c0101fc9:	0f b7 c0             	movzwl %ax,%eax
c0101fcc:	89 04 24             	mov    %eax,(%esp)
c0101fcf:	e8 7c ff ff ff       	call   c0101f50 <pic_setmask>
}
c0101fd4:	c9                   	leave  
c0101fd5:	c3                   	ret    

c0101fd6 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101fd6:	55                   	push   %ebp
c0101fd7:	89 e5                	mov    %esp,%ebp
c0101fd9:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101fdc:	c7 05 60 37 12 c0 01 	movl   $0x1,0xc0123760
c0101fe3:	00 00 00 
c0101fe6:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101fec:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c0101ff0:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101ff4:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101ff8:	ee                   	out    %al,(%dx)
c0101ff9:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101fff:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c0102003:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102007:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010200b:	ee                   	out    %al,(%dx)
c010200c:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0102012:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0102016:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010201a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010201e:	ee                   	out    %al,(%dx)
c010201f:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c0102025:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c0102029:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010202d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102031:	ee                   	out    %al,(%dx)
c0102032:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c0102038:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c010203c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102040:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102044:	ee                   	out    %al,(%dx)
c0102045:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c010204b:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c010204f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102053:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102057:	ee                   	out    %al,(%dx)
c0102058:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c010205e:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c0102062:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102066:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010206a:	ee                   	out    %al,(%dx)
c010206b:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c0102071:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c0102075:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0102079:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010207d:	ee                   	out    %al,(%dx)
c010207e:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c0102084:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0102088:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010208c:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102090:	ee                   	out    %al,(%dx)
c0102091:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0102097:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c010209b:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010209f:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01020a3:	ee                   	out    %al,(%dx)
c01020a4:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c01020aa:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c01020ae:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c01020b2:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01020b6:	ee                   	out    %al,(%dx)
c01020b7:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c01020bd:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c01020c1:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c01020c5:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c01020c9:	ee                   	out    %al,(%dx)
c01020ca:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c01020d0:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c01020d4:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c01020d8:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c01020dc:	ee                   	out    %al,(%dx)
c01020dd:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c01020e3:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c01020e7:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01020eb:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01020ef:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01020f0:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c01020f7:	66 83 f8 ff          	cmp    $0xffff,%ax
c01020fb:	74 12                	je     c010210f <pic_init+0x139>
        pic_setmask(irq_mask);
c01020fd:	0f b7 05 50 05 12 c0 	movzwl 0xc0120550,%eax
c0102104:	0f b7 c0             	movzwl %ax,%eax
c0102107:	89 04 24             	mov    %eax,(%esp)
c010210a:	e8 41 fe ff ff       	call   c0101f50 <pic_setmask>
    }
}
c010210f:	c9                   	leave  
c0102110:	c3                   	ret    

c0102111 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0102111:	55                   	push   %ebp
c0102112:	89 e5                	mov    %esp,%ebp
c0102114:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0102117:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010211e:	00 
c010211f:	c7 04 24 40 91 10 c0 	movl   $0xc0109140,(%esp)
c0102126:	e8 2c e2 ff ff       	call   c0100357 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c010212b:	c7 04 24 4a 91 10 c0 	movl   $0xc010914a,(%esp)
c0102132:	e8 20 e2 ff ff       	call   c0100357 <cprintf>
    panic("EOT: kernel seems ok.");
c0102137:	c7 44 24 08 58 91 10 	movl   $0xc0109158,0x8(%esp)
c010213e:	c0 
c010213f:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0102146:	00 
c0102147:	c7 04 24 6e 91 10 c0 	movl   $0xc010916e,(%esp)
c010214e:	e8 8e eb ff ff       	call   c0100ce1 <__panic>

c0102153 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102153:	55                   	push   %ebp
c0102154:	89 e5                	mov    %esp,%ebp
c0102156:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0102159:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102160:	e9 c3 00 00 00       	jmp    c0102228 <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0102165:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102168:	8b 04 85 e0 05 12 c0 	mov    -0x3fedfa20(,%eax,4),%eax
c010216f:	89 c2                	mov    %eax,%edx
c0102171:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102174:	66 89 14 c5 80 37 12 	mov    %dx,-0x3fedc880(,%eax,8)
c010217b:	c0 
c010217c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010217f:	66 c7 04 c5 82 37 12 	movw   $0x8,-0x3fedc87e(,%eax,8)
c0102186:	c0 08 00 
c0102189:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010218c:	0f b6 14 c5 84 37 12 	movzbl -0x3fedc87c(,%eax,8),%edx
c0102193:	c0 
c0102194:	83 e2 e0             	and    $0xffffffe0,%edx
c0102197:	88 14 c5 84 37 12 c0 	mov    %dl,-0x3fedc87c(,%eax,8)
c010219e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021a1:	0f b6 14 c5 84 37 12 	movzbl -0x3fedc87c(,%eax,8),%edx
c01021a8:	c0 
c01021a9:	83 e2 1f             	and    $0x1f,%edx
c01021ac:	88 14 c5 84 37 12 c0 	mov    %dl,-0x3fedc87c(,%eax,8)
c01021b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021b6:	0f b6 14 c5 85 37 12 	movzbl -0x3fedc87b(,%eax,8),%edx
c01021bd:	c0 
c01021be:	83 e2 f0             	and    $0xfffffff0,%edx
c01021c1:	83 ca 0e             	or     $0xe,%edx
c01021c4:	88 14 c5 85 37 12 c0 	mov    %dl,-0x3fedc87b(,%eax,8)
c01021cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021ce:	0f b6 14 c5 85 37 12 	movzbl -0x3fedc87b(,%eax,8),%edx
c01021d5:	c0 
c01021d6:	83 e2 ef             	and    $0xffffffef,%edx
c01021d9:	88 14 c5 85 37 12 c0 	mov    %dl,-0x3fedc87b(,%eax,8)
c01021e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021e3:	0f b6 14 c5 85 37 12 	movzbl -0x3fedc87b(,%eax,8),%edx
c01021ea:	c0 
c01021eb:	83 e2 9f             	and    $0xffffff9f,%edx
c01021ee:	88 14 c5 85 37 12 c0 	mov    %dl,-0x3fedc87b(,%eax,8)
c01021f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021f8:	0f b6 14 c5 85 37 12 	movzbl -0x3fedc87b(,%eax,8),%edx
c01021ff:	c0 
c0102200:	83 ca 80             	or     $0xffffff80,%edx
c0102203:	88 14 c5 85 37 12 c0 	mov    %dl,-0x3fedc87b(,%eax,8)
c010220a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010220d:	8b 04 85 e0 05 12 c0 	mov    -0x3fedfa20(,%eax,4),%eax
c0102214:	c1 e8 10             	shr    $0x10,%eax
c0102217:	89 c2                	mov    %eax,%edx
c0102219:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010221c:	66 89 14 c5 86 37 12 	mov    %dx,-0x3fedc87a(,%eax,8)
c0102223:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0102224:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102228:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010222b:	3d ff 00 00 00       	cmp    $0xff,%eax
c0102230:	0f 86 2f ff ff ff    	jbe    c0102165 <idt_init+0x12>
c0102236:	c7 45 f8 60 05 12 c0 	movl   $0xc0120560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c010223d:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102240:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
c0102243:	c9                   	leave  
c0102244:	c3                   	ret    

c0102245 <trapname>:

static const char *
trapname(int trapno) {
c0102245:	55                   	push   %ebp
c0102246:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0102248:	8b 45 08             	mov    0x8(%ebp),%eax
c010224b:	83 f8 13             	cmp    $0x13,%eax
c010224e:	77 0c                	ja     c010225c <trapname+0x17>
        return excnames[trapno];
c0102250:	8b 45 08             	mov    0x8(%ebp),%eax
c0102253:	8b 04 85 40 95 10 c0 	mov    -0x3fef6ac0(,%eax,4),%eax
c010225a:	eb 18                	jmp    c0102274 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c010225c:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0102260:	7e 0d                	jle    c010226f <trapname+0x2a>
c0102262:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0102266:	7f 07                	jg     c010226f <trapname+0x2a>
        return "Hardware Interrupt";
c0102268:	b8 7f 91 10 c0       	mov    $0xc010917f,%eax
c010226d:	eb 05                	jmp    c0102274 <trapname+0x2f>
    }
    return "(unknown trap)";
c010226f:	b8 92 91 10 c0       	mov    $0xc0109192,%eax
}
c0102274:	5d                   	pop    %ebp
c0102275:	c3                   	ret    

c0102276 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0102276:	55                   	push   %ebp
c0102277:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0102279:	8b 45 08             	mov    0x8(%ebp),%eax
c010227c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102280:	66 83 f8 08          	cmp    $0x8,%ax
c0102284:	0f 94 c0             	sete   %al
c0102287:	0f b6 c0             	movzbl %al,%eax
}
c010228a:	5d                   	pop    %ebp
c010228b:	c3                   	ret    

c010228c <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c010228c:	55                   	push   %ebp
c010228d:	89 e5                	mov    %esp,%ebp
c010228f:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0102292:	8b 45 08             	mov    0x8(%ebp),%eax
c0102295:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102299:	c7 04 24 d3 91 10 c0 	movl   $0xc01091d3,(%esp)
c01022a0:	e8 b2 e0 ff ff       	call   c0100357 <cprintf>
    print_regs(&tf->tf_regs);
c01022a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01022a8:	89 04 24             	mov    %eax,(%esp)
c01022ab:	e8 a1 01 00 00       	call   c0102451 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c01022b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01022b3:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c01022b7:	0f b7 c0             	movzwl %ax,%eax
c01022ba:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022be:	c7 04 24 e4 91 10 c0 	movl   $0xc01091e4,(%esp)
c01022c5:	e8 8d e0 ff ff       	call   c0100357 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c01022ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01022cd:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c01022d1:	0f b7 c0             	movzwl %ax,%eax
c01022d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022d8:	c7 04 24 f7 91 10 c0 	movl   $0xc01091f7,(%esp)
c01022df:	e8 73 e0 ff ff       	call   c0100357 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c01022e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01022e7:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c01022eb:	0f b7 c0             	movzwl %ax,%eax
c01022ee:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022f2:	c7 04 24 0a 92 10 c0 	movl   $0xc010920a,(%esp)
c01022f9:	e8 59 e0 ff ff       	call   c0100357 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c01022fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102301:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0102305:	0f b7 c0             	movzwl %ax,%eax
c0102308:	89 44 24 04          	mov    %eax,0x4(%esp)
c010230c:	c7 04 24 1d 92 10 c0 	movl   $0xc010921d,(%esp)
c0102313:	e8 3f e0 ff ff       	call   c0100357 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0102318:	8b 45 08             	mov    0x8(%ebp),%eax
c010231b:	8b 40 30             	mov    0x30(%eax),%eax
c010231e:	89 04 24             	mov    %eax,(%esp)
c0102321:	e8 1f ff ff ff       	call   c0102245 <trapname>
c0102326:	8b 55 08             	mov    0x8(%ebp),%edx
c0102329:	8b 52 30             	mov    0x30(%edx),%edx
c010232c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0102330:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102334:	c7 04 24 30 92 10 c0 	movl   $0xc0109230,(%esp)
c010233b:	e8 17 e0 ff ff       	call   c0100357 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0102340:	8b 45 08             	mov    0x8(%ebp),%eax
c0102343:	8b 40 34             	mov    0x34(%eax),%eax
c0102346:	89 44 24 04          	mov    %eax,0x4(%esp)
c010234a:	c7 04 24 42 92 10 c0 	movl   $0xc0109242,(%esp)
c0102351:	e8 01 e0 ff ff       	call   c0100357 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0102356:	8b 45 08             	mov    0x8(%ebp),%eax
c0102359:	8b 40 38             	mov    0x38(%eax),%eax
c010235c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102360:	c7 04 24 51 92 10 c0 	movl   $0xc0109251,(%esp)
c0102367:	e8 eb df ff ff       	call   c0100357 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c010236c:	8b 45 08             	mov    0x8(%ebp),%eax
c010236f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102373:	0f b7 c0             	movzwl %ax,%eax
c0102376:	89 44 24 04          	mov    %eax,0x4(%esp)
c010237a:	c7 04 24 60 92 10 c0 	movl   $0xc0109260,(%esp)
c0102381:	e8 d1 df ff ff       	call   c0100357 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0102386:	8b 45 08             	mov    0x8(%ebp),%eax
c0102389:	8b 40 40             	mov    0x40(%eax),%eax
c010238c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102390:	c7 04 24 73 92 10 c0 	movl   $0xc0109273,(%esp)
c0102397:	e8 bb df ff ff       	call   c0100357 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010239c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01023a3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c01023aa:	eb 3e                	jmp    c01023ea <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c01023ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01023af:	8b 50 40             	mov    0x40(%eax),%edx
c01023b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01023b5:	21 d0                	and    %edx,%eax
c01023b7:	85 c0                	test   %eax,%eax
c01023b9:	74 28                	je     c01023e3 <print_trapframe+0x157>
c01023bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01023be:	8b 04 85 80 05 12 c0 	mov    -0x3fedfa80(,%eax,4),%eax
c01023c5:	85 c0                	test   %eax,%eax
c01023c7:	74 1a                	je     c01023e3 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c01023c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01023cc:	8b 04 85 80 05 12 c0 	mov    -0x3fedfa80(,%eax,4),%eax
c01023d3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023d7:	c7 04 24 82 92 10 c0 	movl   $0xc0109282,(%esp)
c01023de:	e8 74 df ff ff       	call   c0100357 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c01023e3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01023e7:	d1 65 f0             	shll   -0x10(%ebp)
c01023ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01023ed:	83 f8 17             	cmp    $0x17,%eax
c01023f0:	76 ba                	jbe    c01023ac <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c01023f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01023f5:	8b 40 40             	mov    0x40(%eax),%eax
c01023f8:	25 00 30 00 00       	and    $0x3000,%eax
c01023fd:	c1 e8 0c             	shr    $0xc,%eax
c0102400:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102404:	c7 04 24 86 92 10 c0 	movl   $0xc0109286,(%esp)
c010240b:	e8 47 df ff ff       	call   c0100357 <cprintf>

    if (!trap_in_kernel(tf)) {
c0102410:	8b 45 08             	mov    0x8(%ebp),%eax
c0102413:	89 04 24             	mov    %eax,(%esp)
c0102416:	e8 5b fe ff ff       	call   c0102276 <trap_in_kernel>
c010241b:	85 c0                	test   %eax,%eax
c010241d:	75 30                	jne    c010244f <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c010241f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102422:	8b 40 44             	mov    0x44(%eax),%eax
c0102425:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102429:	c7 04 24 8f 92 10 c0 	movl   $0xc010928f,(%esp)
c0102430:	e8 22 df ff ff       	call   c0100357 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0102435:	8b 45 08             	mov    0x8(%ebp),%eax
c0102438:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c010243c:	0f b7 c0             	movzwl %ax,%eax
c010243f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102443:	c7 04 24 9e 92 10 c0 	movl   $0xc010929e,(%esp)
c010244a:	e8 08 df ff ff       	call   c0100357 <cprintf>
    }
}
c010244f:	c9                   	leave  
c0102450:	c3                   	ret    

c0102451 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0102451:	55                   	push   %ebp
c0102452:	89 e5                	mov    %esp,%ebp
c0102454:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0102457:	8b 45 08             	mov    0x8(%ebp),%eax
c010245a:	8b 00                	mov    (%eax),%eax
c010245c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102460:	c7 04 24 b1 92 10 c0 	movl   $0xc01092b1,(%esp)
c0102467:	e8 eb de ff ff       	call   c0100357 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c010246c:	8b 45 08             	mov    0x8(%ebp),%eax
c010246f:	8b 40 04             	mov    0x4(%eax),%eax
c0102472:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102476:	c7 04 24 c0 92 10 c0 	movl   $0xc01092c0,(%esp)
c010247d:	e8 d5 de ff ff       	call   c0100357 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0102482:	8b 45 08             	mov    0x8(%ebp),%eax
c0102485:	8b 40 08             	mov    0x8(%eax),%eax
c0102488:	89 44 24 04          	mov    %eax,0x4(%esp)
c010248c:	c7 04 24 cf 92 10 c0 	movl   $0xc01092cf,(%esp)
c0102493:	e8 bf de ff ff       	call   c0100357 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0102498:	8b 45 08             	mov    0x8(%ebp),%eax
c010249b:	8b 40 0c             	mov    0xc(%eax),%eax
c010249e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024a2:	c7 04 24 de 92 10 c0 	movl   $0xc01092de,(%esp)
c01024a9:	e8 a9 de ff ff       	call   c0100357 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c01024ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01024b1:	8b 40 10             	mov    0x10(%eax),%eax
c01024b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024b8:	c7 04 24 ed 92 10 c0 	movl   $0xc01092ed,(%esp)
c01024bf:	e8 93 de ff ff       	call   c0100357 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c01024c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01024c7:	8b 40 14             	mov    0x14(%eax),%eax
c01024ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024ce:	c7 04 24 fc 92 10 c0 	movl   $0xc01092fc,(%esp)
c01024d5:	e8 7d de ff ff       	call   c0100357 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c01024da:	8b 45 08             	mov    0x8(%ebp),%eax
c01024dd:	8b 40 18             	mov    0x18(%eax),%eax
c01024e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024e4:	c7 04 24 0b 93 10 c0 	movl   $0xc010930b,(%esp)
c01024eb:	e8 67 de ff ff       	call   c0100357 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c01024f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01024f3:	8b 40 1c             	mov    0x1c(%eax),%eax
c01024f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024fa:	c7 04 24 1a 93 10 c0 	movl   $0xc010931a,(%esp)
c0102501:	e8 51 de ff ff       	call   c0100357 <cprintf>
}
c0102506:	c9                   	leave  
c0102507:	c3                   	ret    

c0102508 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0102508:	55                   	push   %ebp
c0102509:	89 e5                	mov    %esp,%ebp
c010250b:	53                   	push   %ebx
c010250c:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c010250f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102512:	8b 40 34             	mov    0x34(%eax),%eax
c0102515:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102518:	85 c0                	test   %eax,%eax
c010251a:	74 07                	je     c0102523 <print_pgfault+0x1b>
c010251c:	b9 29 93 10 c0       	mov    $0xc0109329,%ecx
c0102521:	eb 05                	jmp    c0102528 <print_pgfault+0x20>
c0102523:	b9 3a 93 10 c0       	mov    $0xc010933a,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c0102528:	8b 45 08             	mov    0x8(%ebp),%eax
c010252b:	8b 40 34             	mov    0x34(%eax),%eax
c010252e:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c0102531:	85 c0                	test   %eax,%eax
c0102533:	74 07                	je     c010253c <print_pgfault+0x34>
c0102535:	ba 57 00 00 00       	mov    $0x57,%edx
c010253a:	eb 05                	jmp    c0102541 <print_pgfault+0x39>
c010253c:	ba 52 00 00 00       	mov    $0x52,%edx
            (tf->tf_err & 4) ? 'U' : 'K',
c0102541:	8b 45 08             	mov    0x8(%ebp),%eax
c0102544:	8b 40 34             	mov    0x34(%eax),%eax
c0102547:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c010254a:	85 c0                	test   %eax,%eax
c010254c:	74 07                	je     c0102555 <print_pgfault+0x4d>
c010254e:	b8 55 00 00 00       	mov    $0x55,%eax
c0102553:	eb 05                	jmp    c010255a <print_pgfault+0x52>
c0102555:	b8 4b 00 00 00       	mov    $0x4b,%eax
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c010255a:	0f 20 d3             	mov    %cr2,%ebx
c010255d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
    return cr2;
c0102560:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c0102563:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0102567:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010256b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010256f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0102573:	c7 04 24 48 93 10 c0 	movl   $0xc0109348,(%esp)
c010257a:	e8 d8 dd ff ff       	call   c0100357 <cprintf>
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c010257f:	83 c4 34             	add    $0x34,%esp
c0102582:	5b                   	pop    %ebx
c0102583:	5d                   	pop    %ebp
c0102584:	c3                   	ret    

c0102585 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c0102585:	55                   	push   %ebp
c0102586:	89 e5                	mov    %esp,%ebp
c0102588:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c010258b:	8b 45 08             	mov    0x8(%ebp),%eax
c010258e:	89 04 24             	mov    %eax,(%esp)
c0102591:	e8 72 ff ff ff       	call   c0102508 <print_pgfault>
    if (check_mm_struct != NULL) {
c0102596:	a1 2c 41 12 c0       	mov    0xc012412c,%eax
c010259b:	85 c0                	test   %eax,%eax
c010259d:	74 28                	je     c01025c7 <pgfault_handler+0x42>
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c010259f:	0f 20 d0             	mov    %cr2,%eax
c01025a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c01025a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c01025a8:	89 c1                	mov    %eax,%ecx
c01025aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01025ad:	8b 50 34             	mov    0x34(%eax),%edx
c01025b0:	a1 2c 41 12 c0       	mov    0xc012412c,%eax
c01025b5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01025b9:	89 54 24 04          	mov    %edx,0x4(%esp)
c01025bd:	89 04 24             	mov    %eax,(%esp)
c01025c0:	e8 42 57 00 00       	call   c0107d07 <do_pgfault>
c01025c5:	eb 1c                	jmp    c01025e3 <pgfault_handler+0x5e>
    }
    panic("unhandled page fault.\n");
c01025c7:	c7 44 24 08 6b 93 10 	movl   $0xc010936b,0x8(%esp)
c01025ce:	c0 
c01025cf:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
c01025d6:	00 
c01025d7:	c7 04 24 6e 91 10 c0 	movl   $0xc010916e,(%esp)
c01025de:	e8 fe e6 ff ff       	call   c0100ce1 <__panic>
}
c01025e3:	c9                   	leave  
c01025e4:	c3                   	ret    

c01025e5 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c01025e5:	55                   	push   %ebp
c01025e6:	89 e5                	mov    %esp,%ebp
c01025e8:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c01025eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01025ee:	8b 40 30             	mov    0x30(%eax),%eax
c01025f1:	83 f8 24             	cmp    $0x24,%eax
c01025f4:	0f 84 c2 00 00 00    	je     c01026bc <trap_dispatch+0xd7>
c01025fa:	83 f8 24             	cmp    $0x24,%eax
c01025fd:	77 18                	ja     c0102617 <trap_dispatch+0x32>
c01025ff:	83 f8 20             	cmp    $0x20,%eax
c0102602:	74 7d                	je     c0102681 <trap_dispatch+0x9c>
c0102604:	83 f8 21             	cmp    $0x21,%eax
c0102607:	0f 84 d5 00 00 00    	je     c01026e2 <trap_dispatch+0xfd>
c010260d:	83 f8 0e             	cmp    $0xe,%eax
c0102610:	74 28                	je     c010263a <trap_dispatch+0x55>
c0102612:	e9 0d 01 00 00       	jmp    c0102724 <trap_dispatch+0x13f>
c0102617:	83 f8 2e             	cmp    $0x2e,%eax
c010261a:	0f 82 04 01 00 00    	jb     c0102724 <trap_dispatch+0x13f>
c0102620:	83 f8 2f             	cmp    $0x2f,%eax
c0102623:	0f 86 33 01 00 00    	jbe    c010275c <trap_dispatch+0x177>
c0102629:	83 e8 78             	sub    $0x78,%eax
c010262c:	83 f8 01             	cmp    $0x1,%eax
c010262f:	0f 87 ef 00 00 00    	ja     c0102724 <trap_dispatch+0x13f>
c0102635:	e9 ce 00 00 00       	jmp    c0102708 <trap_dispatch+0x123>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c010263a:	8b 45 08             	mov    0x8(%ebp),%eax
c010263d:	89 04 24             	mov    %eax,(%esp)
c0102640:	e8 40 ff ff ff       	call   c0102585 <pgfault_handler>
c0102645:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102648:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010264c:	74 2e                	je     c010267c <trap_dispatch+0x97>
            print_trapframe(tf);
c010264e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102651:	89 04 24             	mov    %eax,(%esp)
c0102654:	e8 33 fc ff ff       	call   c010228c <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c0102659:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010265c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102660:	c7 44 24 08 82 93 10 	movl   $0xc0109382,0x8(%esp)
c0102667:	c0 
c0102668:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c010266f:	00 
c0102670:	c7 04 24 6e 91 10 c0 	movl   $0xc010916e,(%esp)
c0102677:	e8 65 e6 ff ff       	call   c0100ce1 <__panic>
        }
        break;
c010267c:	e9 dc 00 00 00       	jmp    c010275d <trap_dispatch+0x178>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0102681:	a1 3c 40 12 c0       	mov    0xc012403c,%eax
c0102686:	83 c0 01             	add    $0x1,%eax
c0102689:	a3 3c 40 12 c0       	mov    %eax,0xc012403c
        if (ticks % TICK_NUM == 0) {
c010268e:	8b 0d 3c 40 12 c0    	mov    0xc012403c,%ecx
c0102694:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0102699:	89 c8                	mov    %ecx,%eax
c010269b:	f7 e2                	mul    %edx
c010269d:	89 d0                	mov    %edx,%eax
c010269f:	c1 e8 05             	shr    $0x5,%eax
c01026a2:	6b c0 64             	imul   $0x64,%eax,%eax
c01026a5:	29 c1                	sub    %eax,%ecx
c01026a7:	89 c8                	mov    %ecx,%eax
c01026a9:	85 c0                	test   %eax,%eax
c01026ab:	75 0a                	jne    c01026b7 <trap_dispatch+0xd2>
            print_ticks();
c01026ad:	e8 5f fa ff ff       	call   c0102111 <print_ticks>
        }
        break;
c01026b2:	e9 a6 00 00 00       	jmp    c010275d <trap_dispatch+0x178>
c01026b7:	e9 a1 00 00 00       	jmp    c010275d <trap_dispatch+0x178>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c01026bc:	e8 9f ef ff ff       	call   c0101660 <cons_getc>
c01026c1:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c01026c4:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c01026c8:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c01026cc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01026d0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026d4:	c7 04 24 9d 93 10 c0 	movl   $0xc010939d,(%esp)
c01026db:	e8 77 dc ff ff       	call   c0100357 <cprintf>
        break;
c01026e0:	eb 7b                	jmp    c010275d <trap_dispatch+0x178>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c01026e2:	e8 79 ef ff ff       	call   c0101660 <cons_getc>
c01026e7:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c01026ea:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c01026ee:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c01026f2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01026f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026fa:	c7 04 24 af 93 10 c0 	movl   $0xc01093af,(%esp)
c0102701:	e8 51 dc ff ff       	call   c0100357 <cprintf>
        break;
c0102706:	eb 55                	jmp    c010275d <trap_dispatch+0x178>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0102708:	c7 44 24 08 be 93 10 	movl   $0xc01093be,0x8(%esp)
c010270f:	c0 
c0102710:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0102717:	00 
c0102718:	c7 04 24 6e 91 10 c0 	movl   $0xc010916e,(%esp)
c010271f:	e8 bd e5 ff ff       	call   c0100ce1 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0102724:	8b 45 08             	mov    0x8(%ebp),%eax
c0102727:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010272b:	0f b7 c0             	movzwl %ax,%eax
c010272e:	83 e0 03             	and    $0x3,%eax
c0102731:	85 c0                	test   %eax,%eax
c0102733:	75 28                	jne    c010275d <trap_dispatch+0x178>
            print_trapframe(tf);
c0102735:	8b 45 08             	mov    0x8(%ebp),%eax
c0102738:	89 04 24             	mov    %eax,(%esp)
c010273b:	e8 4c fb ff ff       	call   c010228c <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0102740:	c7 44 24 08 ce 93 10 	movl   $0xc01093ce,0x8(%esp)
c0102747:	c0 
c0102748:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c010274f:	00 
c0102750:	c7 04 24 6e 91 10 c0 	movl   $0xc010916e,(%esp)
c0102757:	e8 85 e5 ff ff       	call   c0100ce1 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c010275c:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c010275d:	c9                   	leave  
c010275e:	c3                   	ret    

c010275f <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c010275f:	55                   	push   %ebp
c0102760:	89 e5                	mov    %esp,%ebp
c0102762:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0102765:	8b 45 08             	mov    0x8(%ebp),%eax
c0102768:	89 04 24             	mov    %eax,(%esp)
c010276b:	e8 75 fe ff ff       	call   c01025e5 <trap_dispatch>
}
c0102770:	c9                   	leave  
c0102771:	c3                   	ret    

c0102772 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102772:	1e                   	push   %ds
    pushl %es
c0102773:	06                   	push   %es
    pushl %fs
c0102774:	0f a0                	push   %fs
    pushl %gs
c0102776:	0f a8                	push   %gs
    pushal
c0102778:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102779:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010277e:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102780:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102782:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102783:	e8 d7 ff ff ff       	call   c010275f <trap>

    # pop the pushed stack pointer
    popl %esp
c0102788:	5c                   	pop    %esp

c0102789 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102789:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c010278a:	0f a9                	pop    %gs
    popl %fs
c010278c:	0f a1                	pop    %fs
    popl %es
c010278e:	07                   	pop    %es
    popl %ds
c010278f:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102790:	83 c4 08             	add    $0x8,%esp
    iret
c0102793:	cf                   	iret   

c0102794 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102794:	6a 00                	push   $0x0
  pushl $0
c0102796:	6a 00                	push   $0x0
  jmp __alltraps
c0102798:	e9 d5 ff ff ff       	jmp    c0102772 <__alltraps>

c010279d <vector1>:
.globl vector1
vector1:
  pushl $0
c010279d:	6a 00                	push   $0x0
  pushl $1
c010279f:	6a 01                	push   $0x1
  jmp __alltraps
c01027a1:	e9 cc ff ff ff       	jmp    c0102772 <__alltraps>

c01027a6 <vector2>:
.globl vector2
vector2:
  pushl $0
c01027a6:	6a 00                	push   $0x0
  pushl $2
c01027a8:	6a 02                	push   $0x2
  jmp __alltraps
c01027aa:	e9 c3 ff ff ff       	jmp    c0102772 <__alltraps>

c01027af <vector3>:
.globl vector3
vector3:
  pushl $0
c01027af:	6a 00                	push   $0x0
  pushl $3
c01027b1:	6a 03                	push   $0x3
  jmp __alltraps
c01027b3:	e9 ba ff ff ff       	jmp    c0102772 <__alltraps>

c01027b8 <vector4>:
.globl vector4
vector4:
  pushl $0
c01027b8:	6a 00                	push   $0x0
  pushl $4
c01027ba:	6a 04                	push   $0x4
  jmp __alltraps
c01027bc:	e9 b1 ff ff ff       	jmp    c0102772 <__alltraps>

c01027c1 <vector5>:
.globl vector5
vector5:
  pushl $0
c01027c1:	6a 00                	push   $0x0
  pushl $5
c01027c3:	6a 05                	push   $0x5
  jmp __alltraps
c01027c5:	e9 a8 ff ff ff       	jmp    c0102772 <__alltraps>

c01027ca <vector6>:
.globl vector6
vector6:
  pushl $0
c01027ca:	6a 00                	push   $0x0
  pushl $6
c01027cc:	6a 06                	push   $0x6
  jmp __alltraps
c01027ce:	e9 9f ff ff ff       	jmp    c0102772 <__alltraps>

c01027d3 <vector7>:
.globl vector7
vector7:
  pushl $0
c01027d3:	6a 00                	push   $0x0
  pushl $7
c01027d5:	6a 07                	push   $0x7
  jmp __alltraps
c01027d7:	e9 96 ff ff ff       	jmp    c0102772 <__alltraps>

c01027dc <vector8>:
.globl vector8
vector8:
  pushl $8
c01027dc:	6a 08                	push   $0x8
  jmp __alltraps
c01027de:	e9 8f ff ff ff       	jmp    c0102772 <__alltraps>

c01027e3 <vector9>:
.globl vector9
vector9:
  pushl $9
c01027e3:	6a 09                	push   $0x9
  jmp __alltraps
c01027e5:	e9 88 ff ff ff       	jmp    c0102772 <__alltraps>

c01027ea <vector10>:
.globl vector10
vector10:
  pushl $10
c01027ea:	6a 0a                	push   $0xa
  jmp __alltraps
c01027ec:	e9 81 ff ff ff       	jmp    c0102772 <__alltraps>

c01027f1 <vector11>:
.globl vector11
vector11:
  pushl $11
c01027f1:	6a 0b                	push   $0xb
  jmp __alltraps
c01027f3:	e9 7a ff ff ff       	jmp    c0102772 <__alltraps>

c01027f8 <vector12>:
.globl vector12
vector12:
  pushl $12
c01027f8:	6a 0c                	push   $0xc
  jmp __alltraps
c01027fa:	e9 73 ff ff ff       	jmp    c0102772 <__alltraps>

c01027ff <vector13>:
.globl vector13
vector13:
  pushl $13
c01027ff:	6a 0d                	push   $0xd
  jmp __alltraps
c0102801:	e9 6c ff ff ff       	jmp    c0102772 <__alltraps>

c0102806 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102806:	6a 0e                	push   $0xe
  jmp __alltraps
c0102808:	e9 65 ff ff ff       	jmp    c0102772 <__alltraps>

c010280d <vector15>:
.globl vector15
vector15:
  pushl $0
c010280d:	6a 00                	push   $0x0
  pushl $15
c010280f:	6a 0f                	push   $0xf
  jmp __alltraps
c0102811:	e9 5c ff ff ff       	jmp    c0102772 <__alltraps>

c0102816 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102816:	6a 00                	push   $0x0
  pushl $16
c0102818:	6a 10                	push   $0x10
  jmp __alltraps
c010281a:	e9 53 ff ff ff       	jmp    c0102772 <__alltraps>

c010281f <vector17>:
.globl vector17
vector17:
  pushl $17
c010281f:	6a 11                	push   $0x11
  jmp __alltraps
c0102821:	e9 4c ff ff ff       	jmp    c0102772 <__alltraps>

c0102826 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102826:	6a 00                	push   $0x0
  pushl $18
c0102828:	6a 12                	push   $0x12
  jmp __alltraps
c010282a:	e9 43 ff ff ff       	jmp    c0102772 <__alltraps>

c010282f <vector19>:
.globl vector19
vector19:
  pushl $0
c010282f:	6a 00                	push   $0x0
  pushl $19
c0102831:	6a 13                	push   $0x13
  jmp __alltraps
c0102833:	e9 3a ff ff ff       	jmp    c0102772 <__alltraps>

c0102838 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102838:	6a 00                	push   $0x0
  pushl $20
c010283a:	6a 14                	push   $0x14
  jmp __alltraps
c010283c:	e9 31 ff ff ff       	jmp    c0102772 <__alltraps>

c0102841 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102841:	6a 00                	push   $0x0
  pushl $21
c0102843:	6a 15                	push   $0x15
  jmp __alltraps
c0102845:	e9 28 ff ff ff       	jmp    c0102772 <__alltraps>

c010284a <vector22>:
.globl vector22
vector22:
  pushl $0
c010284a:	6a 00                	push   $0x0
  pushl $22
c010284c:	6a 16                	push   $0x16
  jmp __alltraps
c010284e:	e9 1f ff ff ff       	jmp    c0102772 <__alltraps>

c0102853 <vector23>:
.globl vector23
vector23:
  pushl $0
c0102853:	6a 00                	push   $0x0
  pushl $23
c0102855:	6a 17                	push   $0x17
  jmp __alltraps
c0102857:	e9 16 ff ff ff       	jmp    c0102772 <__alltraps>

c010285c <vector24>:
.globl vector24
vector24:
  pushl $0
c010285c:	6a 00                	push   $0x0
  pushl $24
c010285e:	6a 18                	push   $0x18
  jmp __alltraps
c0102860:	e9 0d ff ff ff       	jmp    c0102772 <__alltraps>

c0102865 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102865:	6a 00                	push   $0x0
  pushl $25
c0102867:	6a 19                	push   $0x19
  jmp __alltraps
c0102869:	e9 04 ff ff ff       	jmp    c0102772 <__alltraps>

c010286e <vector26>:
.globl vector26
vector26:
  pushl $0
c010286e:	6a 00                	push   $0x0
  pushl $26
c0102870:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102872:	e9 fb fe ff ff       	jmp    c0102772 <__alltraps>

c0102877 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102877:	6a 00                	push   $0x0
  pushl $27
c0102879:	6a 1b                	push   $0x1b
  jmp __alltraps
c010287b:	e9 f2 fe ff ff       	jmp    c0102772 <__alltraps>

c0102880 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102880:	6a 00                	push   $0x0
  pushl $28
c0102882:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102884:	e9 e9 fe ff ff       	jmp    c0102772 <__alltraps>

c0102889 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102889:	6a 00                	push   $0x0
  pushl $29
c010288b:	6a 1d                	push   $0x1d
  jmp __alltraps
c010288d:	e9 e0 fe ff ff       	jmp    c0102772 <__alltraps>

c0102892 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102892:	6a 00                	push   $0x0
  pushl $30
c0102894:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102896:	e9 d7 fe ff ff       	jmp    c0102772 <__alltraps>

c010289b <vector31>:
.globl vector31
vector31:
  pushl $0
c010289b:	6a 00                	push   $0x0
  pushl $31
c010289d:	6a 1f                	push   $0x1f
  jmp __alltraps
c010289f:	e9 ce fe ff ff       	jmp    c0102772 <__alltraps>

c01028a4 <vector32>:
.globl vector32
vector32:
  pushl $0
c01028a4:	6a 00                	push   $0x0
  pushl $32
c01028a6:	6a 20                	push   $0x20
  jmp __alltraps
c01028a8:	e9 c5 fe ff ff       	jmp    c0102772 <__alltraps>

c01028ad <vector33>:
.globl vector33
vector33:
  pushl $0
c01028ad:	6a 00                	push   $0x0
  pushl $33
c01028af:	6a 21                	push   $0x21
  jmp __alltraps
c01028b1:	e9 bc fe ff ff       	jmp    c0102772 <__alltraps>

c01028b6 <vector34>:
.globl vector34
vector34:
  pushl $0
c01028b6:	6a 00                	push   $0x0
  pushl $34
c01028b8:	6a 22                	push   $0x22
  jmp __alltraps
c01028ba:	e9 b3 fe ff ff       	jmp    c0102772 <__alltraps>

c01028bf <vector35>:
.globl vector35
vector35:
  pushl $0
c01028bf:	6a 00                	push   $0x0
  pushl $35
c01028c1:	6a 23                	push   $0x23
  jmp __alltraps
c01028c3:	e9 aa fe ff ff       	jmp    c0102772 <__alltraps>

c01028c8 <vector36>:
.globl vector36
vector36:
  pushl $0
c01028c8:	6a 00                	push   $0x0
  pushl $36
c01028ca:	6a 24                	push   $0x24
  jmp __alltraps
c01028cc:	e9 a1 fe ff ff       	jmp    c0102772 <__alltraps>

c01028d1 <vector37>:
.globl vector37
vector37:
  pushl $0
c01028d1:	6a 00                	push   $0x0
  pushl $37
c01028d3:	6a 25                	push   $0x25
  jmp __alltraps
c01028d5:	e9 98 fe ff ff       	jmp    c0102772 <__alltraps>

c01028da <vector38>:
.globl vector38
vector38:
  pushl $0
c01028da:	6a 00                	push   $0x0
  pushl $38
c01028dc:	6a 26                	push   $0x26
  jmp __alltraps
c01028de:	e9 8f fe ff ff       	jmp    c0102772 <__alltraps>

c01028e3 <vector39>:
.globl vector39
vector39:
  pushl $0
c01028e3:	6a 00                	push   $0x0
  pushl $39
c01028e5:	6a 27                	push   $0x27
  jmp __alltraps
c01028e7:	e9 86 fe ff ff       	jmp    c0102772 <__alltraps>

c01028ec <vector40>:
.globl vector40
vector40:
  pushl $0
c01028ec:	6a 00                	push   $0x0
  pushl $40
c01028ee:	6a 28                	push   $0x28
  jmp __alltraps
c01028f0:	e9 7d fe ff ff       	jmp    c0102772 <__alltraps>

c01028f5 <vector41>:
.globl vector41
vector41:
  pushl $0
c01028f5:	6a 00                	push   $0x0
  pushl $41
c01028f7:	6a 29                	push   $0x29
  jmp __alltraps
c01028f9:	e9 74 fe ff ff       	jmp    c0102772 <__alltraps>

c01028fe <vector42>:
.globl vector42
vector42:
  pushl $0
c01028fe:	6a 00                	push   $0x0
  pushl $42
c0102900:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102902:	e9 6b fe ff ff       	jmp    c0102772 <__alltraps>

c0102907 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102907:	6a 00                	push   $0x0
  pushl $43
c0102909:	6a 2b                	push   $0x2b
  jmp __alltraps
c010290b:	e9 62 fe ff ff       	jmp    c0102772 <__alltraps>

c0102910 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102910:	6a 00                	push   $0x0
  pushl $44
c0102912:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102914:	e9 59 fe ff ff       	jmp    c0102772 <__alltraps>

c0102919 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102919:	6a 00                	push   $0x0
  pushl $45
c010291b:	6a 2d                	push   $0x2d
  jmp __alltraps
c010291d:	e9 50 fe ff ff       	jmp    c0102772 <__alltraps>

c0102922 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102922:	6a 00                	push   $0x0
  pushl $46
c0102924:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102926:	e9 47 fe ff ff       	jmp    c0102772 <__alltraps>

c010292b <vector47>:
.globl vector47
vector47:
  pushl $0
c010292b:	6a 00                	push   $0x0
  pushl $47
c010292d:	6a 2f                	push   $0x2f
  jmp __alltraps
c010292f:	e9 3e fe ff ff       	jmp    c0102772 <__alltraps>

c0102934 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102934:	6a 00                	push   $0x0
  pushl $48
c0102936:	6a 30                	push   $0x30
  jmp __alltraps
c0102938:	e9 35 fe ff ff       	jmp    c0102772 <__alltraps>

c010293d <vector49>:
.globl vector49
vector49:
  pushl $0
c010293d:	6a 00                	push   $0x0
  pushl $49
c010293f:	6a 31                	push   $0x31
  jmp __alltraps
c0102941:	e9 2c fe ff ff       	jmp    c0102772 <__alltraps>

c0102946 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102946:	6a 00                	push   $0x0
  pushl $50
c0102948:	6a 32                	push   $0x32
  jmp __alltraps
c010294a:	e9 23 fe ff ff       	jmp    c0102772 <__alltraps>

c010294f <vector51>:
.globl vector51
vector51:
  pushl $0
c010294f:	6a 00                	push   $0x0
  pushl $51
c0102951:	6a 33                	push   $0x33
  jmp __alltraps
c0102953:	e9 1a fe ff ff       	jmp    c0102772 <__alltraps>

c0102958 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102958:	6a 00                	push   $0x0
  pushl $52
c010295a:	6a 34                	push   $0x34
  jmp __alltraps
c010295c:	e9 11 fe ff ff       	jmp    c0102772 <__alltraps>

c0102961 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102961:	6a 00                	push   $0x0
  pushl $53
c0102963:	6a 35                	push   $0x35
  jmp __alltraps
c0102965:	e9 08 fe ff ff       	jmp    c0102772 <__alltraps>

c010296a <vector54>:
.globl vector54
vector54:
  pushl $0
c010296a:	6a 00                	push   $0x0
  pushl $54
c010296c:	6a 36                	push   $0x36
  jmp __alltraps
c010296e:	e9 ff fd ff ff       	jmp    c0102772 <__alltraps>

c0102973 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102973:	6a 00                	push   $0x0
  pushl $55
c0102975:	6a 37                	push   $0x37
  jmp __alltraps
c0102977:	e9 f6 fd ff ff       	jmp    c0102772 <__alltraps>

c010297c <vector56>:
.globl vector56
vector56:
  pushl $0
c010297c:	6a 00                	push   $0x0
  pushl $56
c010297e:	6a 38                	push   $0x38
  jmp __alltraps
c0102980:	e9 ed fd ff ff       	jmp    c0102772 <__alltraps>

c0102985 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102985:	6a 00                	push   $0x0
  pushl $57
c0102987:	6a 39                	push   $0x39
  jmp __alltraps
c0102989:	e9 e4 fd ff ff       	jmp    c0102772 <__alltraps>

c010298e <vector58>:
.globl vector58
vector58:
  pushl $0
c010298e:	6a 00                	push   $0x0
  pushl $58
c0102990:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102992:	e9 db fd ff ff       	jmp    c0102772 <__alltraps>

c0102997 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102997:	6a 00                	push   $0x0
  pushl $59
c0102999:	6a 3b                	push   $0x3b
  jmp __alltraps
c010299b:	e9 d2 fd ff ff       	jmp    c0102772 <__alltraps>

c01029a0 <vector60>:
.globl vector60
vector60:
  pushl $0
c01029a0:	6a 00                	push   $0x0
  pushl $60
c01029a2:	6a 3c                	push   $0x3c
  jmp __alltraps
c01029a4:	e9 c9 fd ff ff       	jmp    c0102772 <__alltraps>

c01029a9 <vector61>:
.globl vector61
vector61:
  pushl $0
c01029a9:	6a 00                	push   $0x0
  pushl $61
c01029ab:	6a 3d                	push   $0x3d
  jmp __alltraps
c01029ad:	e9 c0 fd ff ff       	jmp    c0102772 <__alltraps>

c01029b2 <vector62>:
.globl vector62
vector62:
  pushl $0
c01029b2:	6a 00                	push   $0x0
  pushl $62
c01029b4:	6a 3e                	push   $0x3e
  jmp __alltraps
c01029b6:	e9 b7 fd ff ff       	jmp    c0102772 <__alltraps>

c01029bb <vector63>:
.globl vector63
vector63:
  pushl $0
c01029bb:	6a 00                	push   $0x0
  pushl $63
c01029bd:	6a 3f                	push   $0x3f
  jmp __alltraps
c01029bf:	e9 ae fd ff ff       	jmp    c0102772 <__alltraps>

c01029c4 <vector64>:
.globl vector64
vector64:
  pushl $0
c01029c4:	6a 00                	push   $0x0
  pushl $64
c01029c6:	6a 40                	push   $0x40
  jmp __alltraps
c01029c8:	e9 a5 fd ff ff       	jmp    c0102772 <__alltraps>

c01029cd <vector65>:
.globl vector65
vector65:
  pushl $0
c01029cd:	6a 00                	push   $0x0
  pushl $65
c01029cf:	6a 41                	push   $0x41
  jmp __alltraps
c01029d1:	e9 9c fd ff ff       	jmp    c0102772 <__alltraps>

c01029d6 <vector66>:
.globl vector66
vector66:
  pushl $0
c01029d6:	6a 00                	push   $0x0
  pushl $66
c01029d8:	6a 42                	push   $0x42
  jmp __alltraps
c01029da:	e9 93 fd ff ff       	jmp    c0102772 <__alltraps>

c01029df <vector67>:
.globl vector67
vector67:
  pushl $0
c01029df:	6a 00                	push   $0x0
  pushl $67
c01029e1:	6a 43                	push   $0x43
  jmp __alltraps
c01029e3:	e9 8a fd ff ff       	jmp    c0102772 <__alltraps>

c01029e8 <vector68>:
.globl vector68
vector68:
  pushl $0
c01029e8:	6a 00                	push   $0x0
  pushl $68
c01029ea:	6a 44                	push   $0x44
  jmp __alltraps
c01029ec:	e9 81 fd ff ff       	jmp    c0102772 <__alltraps>

c01029f1 <vector69>:
.globl vector69
vector69:
  pushl $0
c01029f1:	6a 00                	push   $0x0
  pushl $69
c01029f3:	6a 45                	push   $0x45
  jmp __alltraps
c01029f5:	e9 78 fd ff ff       	jmp    c0102772 <__alltraps>

c01029fa <vector70>:
.globl vector70
vector70:
  pushl $0
c01029fa:	6a 00                	push   $0x0
  pushl $70
c01029fc:	6a 46                	push   $0x46
  jmp __alltraps
c01029fe:	e9 6f fd ff ff       	jmp    c0102772 <__alltraps>

c0102a03 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102a03:	6a 00                	push   $0x0
  pushl $71
c0102a05:	6a 47                	push   $0x47
  jmp __alltraps
c0102a07:	e9 66 fd ff ff       	jmp    c0102772 <__alltraps>

c0102a0c <vector72>:
.globl vector72
vector72:
  pushl $0
c0102a0c:	6a 00                	push   $0x0
  pushl $72
c0102a0e:	6a 48                	push   $0x48
  jmp __alltraps
c0102a10:	e9 5d fd ff ff       	jmp    c0102772 <__alltraps>

c0102a15 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102a15:	6a 00                	push   $0x0
  pushl $73
c0102a17:	6a 49                	push   $0x49
  jmp __alltraps
c0102a19:	e9 54 fd ff ff       	jmp    c0102772 <__alltraps>

c0102a1e <vector74>:
.globl vector74
vector74:
  pushl $0
c0102a1e:	6a 00                	push   $0x0
  pushl $74
c0102a20:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102a22:	e9 4b fd ff ff       	jmp    c0102772 <__alltraps>

c0102a27 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102a27:	6a 00                	push   $0x0
  pushl $75
c0102a29:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102a2b:	e9 42 fd ff ff       	jmp    c0102772 <__alltraps>

c0102a30 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102a30:	6a 00                	push   $0x0
  pushl $76
c0102a32:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102a34:	e9 39 fd ff ff       	jmp    c0102772 <__alltraps>

c0102a39 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102a39:	6a 00                	push   $0x0
  pushl $77
c0102a3b:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102a3d:	e9 30 fd ff ff       	jmp    c0102772 <__alltraps>

c0102a42 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102a42:	6a 00                	push   $0x0
  pushl $78
c0102a44:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102a46:	e9 27 fd ff ff       	jmp    c0102772 <__alltraps>

c0102a4b <vector79>:
.globl vector79
vector79:
  pushl $0
c0102a4b:	6a 00                	push   $0x0
  pushl $79
c0102a4d:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102a4f:	e9 1e fd ff ff       	jmp    c0102772 <__alltraps>

c0102a54 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102a54:	6a 00                	push   $0x0
  pushl $80
c0102a56:	6a 50                	push   $0x50
  jmp __alltraps
c0102a58:	e9 15 fd ff ff       	jmp    c0102772 <__alltraps>

c0102a5d <vector81>:
.globl vector81
vector81:
  pushl $0
c0102a5d:	6a 00                	push   $0x0
  pushl $81
c0102a5f:	6a 51                	push   $0x51
  jmp __alltraps
c0102a61:	e9 0c fd ff ff       	jmp    c0102772 <__alltraps>

c0102a66 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102a66:	6a 00                	push   $0x0
  pushl $82
c0102a68:	6a 52                	push   $0x52
  jmp __alltraps
c0102a6a:	e9 03 fd ff ff       	jmp    c0102772 <__alltraps>

c0102a6f <vector83>:
.globl vector83
vector83:
  pushl $0
c0102a6f:	6a 00                	push   $0x0
  pushl $83
c0102a71:	6a 53                	push   $0x53
  jmp __alltraps
c0102a73:	e9 fa fc ff ff       	jmp    c0102772 <__alltraps>

c0102a78 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102a78:	6a 00                	push   $0x0
  pushl $84
c0102a7a:	6a 54                	push   $0x54
  jmp __alltraps
c0102a7c:	e9 f1 fc ff ff       	jmp    c0102772 <__alltraps>

c0102a81 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102a81:	6a 00                	push   $0x0
  pushl $85
c0102a83:	6a 55                	push   $0x55
  jmp __alltraps
c0102a85:	e9 e8 fc ff ff       	jmp    c0102772 <__alltraps>

c0102a8a <vector86>:
.globl vector86
vector86:
  pushl $0
c0102a8a:	6a 00                	push   $0x0
  pushl $86
c0102a8c:	6a 56                	push   $0x56
  jmp __alltraps
c0102a8e:	e9 df fc ff ff       	jmp    c0102772 <__alltraps>

c0102a93 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102a93:	6a 00                	push   $0x0
  pushl $87
c0102a95:	6a 57                	push   $0x57
  jmp __alltraps
c0102a97:	e9 d6 fc ff ff       	jmp    c0102772 <__alltraps>

c0102a9c <vector88>:
.globl vector88
vector88:
  pushl $0
c0102a9c:	6a 00                	push   $0x0
  pushl $88
c0102a9e:	6a 58                	push   $0x58
  jmp __alltraps
c0102aa0:	e9 cd fc ff ff       	jmp    c0102772 <__alltraps>

c0102aa5 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102aa5:	6a 00                	push   $0x0
  pushl $89
c0102aa7:	6a 59                	push   $0x59
  jmp __alltraps
c0102aa9:	e9 c4 fc ff ff       	jmp    c0102772 <__alltraps>

c0102aae <vector90>:
.globl vector90
vector90:
  pushl $0
c0102aae:	6a 00                	push   $0x0
  pushl $90
c0102ab0:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102ab2:	e9 bb fc ff ff       	jmp    c0102772 <__alltraps>

c0102ab7 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102ab7:	6a 00                	push   $0x0
  pushl $91
c0102ab9:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102abb:	e9 b2 fc ff ff       	jmp    c0102772 <__alltraps>

c0102ac0 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102ac0:	6a 00                	push   $0x0
  pushl $92
c0102ac2:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102ac4:	e9 a9 fc ff ff       	jmp    c0102772 <__alltraps>

c0102ac9 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102ac9:	6a 00                	push   $0x0
  pushl $93
c0102acb:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102acd:	e9 a0 fc ff ff       	jmp    c0102772 <__alltraps>

c0102ad2 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102ad2:	6a 00                	push   $0x0
  pushl $94
c0102ad4:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102ad6:	e9 97 fc ff ff       	jmp    c0102772 <__alltraps>

c0102adb <vector95>:
.globl vector95
vector95:
  pushl $0
c0102adb:	6a 00                	push   $0x0
  pushl $95
c0102add:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102adf:	e9 8e fc ff ff       	jmp    c0102772 <__alltraps>

c0102ae4 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102ae4:	6a 00                	push   $0x0
  pushl $96
c0102ae6:	6a 60                	push   $0x60
  jmp __alltraps
c0102ae8:	e9 85 fc ff ff       	jmp    c0102772 <__alltraps>

c0102aed <vector97>:
.globl vector97
vector97:
  pushl $0
c0102aed:	6a 00                	push   $0x0
  pushl $97
c0102aef:	6a 61                	push   $0x61
  jmp __alltraps
c0102af1:	e9 7c fc ff ff       	jmp    c0102772 <__alltraps>

c0102af6 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102af6:	6a 00                	push   $0x0
  pushl $98
c0102af8:	6a 62                	push   $0x62
  jmp __alltraps
c0102afa:	e9 73 fc ff ff       	jmp    c0102772 <__alltraps>

c0102aff <vector99>:
.globl vector99
vector99:
  pushl $0
c0102aff:	6a 00                	push   $0x0
  pushl $99
c0102b01:	6a 63                	push   $0x63
  jmp __alltraps
c0102b03:	e9 6a fc ff ff       	jmp    c0102772 <__alltraps>

c0102b08 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102b08:	6a 00                	push   $0x0
  pushl $100
c0102b0a:	6a 64                	push   $0x64
  jmp __alltraps
c0102b0c:	e9 61 fc ff ff       	jmp    c0102772 <__alltraps>

c0102b11 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102b11:	6a 00                	push   $0x0
  pushl $101
c0102b13:	6a 65                	push   $0x65
  jmp __alltraps
c0102b15:	e9 58 fc ff ff       	jmp    c0102772 <__alltraps>

c0102b1a <vector102>:
.globl vector102
vector102:
  pushl $0
c0102b1a:	6a 00                	push   $0x0
  pushl $102
c0102b1c:	6a 66                	push   $0x66
  jmp __alltraps
c0102b1e:	e9 4f fc ff ff       	jmp    c0102772 <__alltraps>

c0102b23 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102b23:	6a 00                	push   $0x0
  pushl $103
c0102b25:	6a 67                	push   $0x67
  jmp __alltraps
c0102b27:	e9 46 fc ff ff       	jmp    c0102772 <__alltraps>

c0102b2c <vector104>:
.globl vector104
vector104:
  pushl $0
c0102b2c:	6a 00                	push   $0x0
  pushl $104
c0102b2e:	6a 68                	push   $0x68
  jmp __alltraps
c0102b30:	e9 3d fc ff ff       	jmp    c0102772 <__alltraps>

c0102b35 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102b35:	6a 00                	push   $0x0
  pushl $105
c0102b37:	6a 69                	push   $0x69
  jmp __alltraps
c0102b39:	e9 34 fc ff ff       	jmp    c0102772 <__alltraps>

c0102b3e <vector106>:
.globl vector106
vector106:
  pushl $0
c0102b3e:	6a 00                	push   $0x0
  pushl $106
c0102b40:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102b42:	e9 2b fc ff ff       	jmp    c0102772 <__alltraps>

c0102b47 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102b47:	6a 00                	push   $0x0
  pushl $107
c0102b49:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102b4b:	e9 22 fc ff ff       	jmp    c0102772 <__alltraps>

c0102b50 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102b50:	6a 00                	push   $0x0
  pushl $108
c0102b52:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102b54:	e9 19 fc ff ff       	jmp    c0102772 <__alltraps>

c0102b59 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102b59:	6a 00                	push   $0x0
  pushl $109
c0102b5b:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102b5d:	e9 10 fc ff ff       	jmp    c0102772 <__alltraps>

c0102b62 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102b62:	6a 00                	push   $0x0
  pushl $110
c0102b64:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102b66:	e9 07 fc ff ff       	jmp    c0102772 <__alltraps>

c0102b6b <vector111>:
.globl vector111
vector111:
  pushl $0
c0102b6b:	6a 00                	push   $0x0
  pushl $111
c0102b6d:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102b6f:	e9 fe fb ff ff       	jmp    c0102772 <__alltraps>

c0102b74 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102b74:	6a 00                	push   $0x0
  pushl $112
c0102b76:	6a 70                	push   $0x70
  jmp __alltraps
c0102b78:	e9 f5 fb ff ff       	jmp    c0102772 <__alltraps>

c0102b7d <vector113>:
.globl vector113
vector113:
  pushl $0
c0102b7d:	6a 00                	push   $0x0
  pushl $113
c0102b7f:	6a 71                	push   $0x71
  jmp __alltraps
c0102b81:	e9 ec fb ff ff       	jmp    c0102772 <__alltraps>

c0102b86 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102b86:	6a 00                	push   $0x0
  pushl $114
c0102b88:	6a 72                	push   $0x72
  jmp __alltraps
c0102b8a:	e9 e3 fb ff ff       	jmp    c0102772 <__alltraps>

c0102b8f <vector115>:
.globl vector115
vector115:
  pushl $0
c0102b8f:	6a 00                	push   $0x0
  pushl $115
c0102b91:	6a 73                	push   $0x73
  jmp __alltraps
c0102b93:	e9 da fb ff ff       	jmp    c0102772 <__alltraps>

c0102b98 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102b98:	6a 00                	push   $0x0
  pushl $116
c0102b9a:	6a 74                	push   $0x74
  jmp __alltraps
c0102b9c:	e9 d1 fb ff ff       	jmp    c0102772 <__alltraps>

c0102ba1 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102ba1:	6a 00                	push   $0x0
  pushl $117
c0102ba3:	6a 75                	push   $0x75
  jmp __alltraps
c0102ba5:	e9 c8 fb ff ff       	jmp    c0102772 <__alltraps>

c0102baa <vector118>:
.globl vector118
vector118:
  pushl $0
c0102baa:	6a 00                	push   $0x0
  pushl $118
c0102bac:	6a 76                	push   $0x76
  jmp __alltraps
c0102bae:	e9 bf fb ff ff       	jmp    c0102772 <__alltraps>

c0102bb3 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102bb3:	6a 00                	push   $0x0
  pushl $119
c0102bb5:	6a 77                	push   $0x77
  jmp __alltraps
c0102bb7:	e9 b6 fb ff ff       	jmp    c0102772 <__alltraps>

c0102bbc <vector120>:
.globl vector120
vector120:
  pushl $0
c0102bbc:	6a 00                	push   $0x0
  pushl $120
c0102bbe:	6a 78                	push   $0x78
  jmp __alltraps
c0102bc0:	e9 ad fb ff ff       	jmp    c0102772 <__alltraps>

c0102bc5 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102bc5:	6a 00                	push   $0x0
  pushl $121
c0102bc7:	6a 79                	push   $0x79
  jmp __alltraps
c0102bc9:	e9 a4 fb ff ff       	jmp    c0102772 <__alltraps>

c0102bce <vector122>:
.globl vector122
vector122:
  pushl $0
c0102bce:	6a 00                	push   $0x0
  pushl $122
c0102bd0:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102bd2:	e9 9b fb ff ff       	jmp    c0102772 <__alltraps>

c0102bd7 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102bd7:	6a 00                	push   $0x0
  pushl $123
c0102bd9:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102bdb:	e9 92 fb ff ff       	jmp    c0102772 <__alltraps>

c0102be0 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102be0:	6a 00                	push   $0x0
  pushl $124
c0102be2:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102be4:	e9 89 fb ff ff       	jmp    c0102772 <__alltraps>

c0102be9 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102be9:	6a 00                	push   $0x0
  pushl $125
c0102beb:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102bed:	e9 80 fb ff ff       	jmp    c0102772 <__alltraps>

c0102bf2 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102bf2:	6a 00                	push   $0x0
  pushl $126
c0102bf4:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102bf6:	e9 77 fb ff ff       	jmp    c0102772 <__alltraps>

c0102bfb <vector127>:
.globl vector127
vector127:
  pushl $0
c0102bfb:	6a 00                	push   $0x0
  pushl $127
c0102bfd:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102bff:	e9 6e fb ff ff       	jmp    c0102772 <__alltraps>

c0102c04 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102c04:	6a 00                	push   $0x0
  pushl $128
c0102c06:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102c0b:	e9 62 fb ff ff       	jmp    c0102772 <__alltraps>

c0102c10 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102c10:	6a 00                	push   $0x0
  pushl $129
c0102c12:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102c17:	e9 56 fb ff ff       	jmp    c0102772 <__alltraps>

c0102c1c <vector130>:
.globl vector130
vector130:
  pushl $0
c0102c1c:	6a 00                	push   $0x0
  pushl $130
c0102c1e:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102c23:	e9 4a fb ff ff       	jmp    c0102772 <__alltraps>

c0102c28 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102c28:	6a 00                	push   $0x0
  pushl $131
c0102c2a:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102c2f:	e9 3e fb ff ff       	jmp    c0102772 <__alltraps>

c0102c34 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102c34:	6a 00                	push   $0x0
  pushl $132
c0102c36:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102c3b:	e9 32 fb ff ff       	jmp    c0102772 <__alltraps>

c0102c40 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102c40:	6a 00                	push   $0x0
  pushl $133
c0102c42:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102c47:	e9 26 fb ff ff       	jmp    c0102772 <__alltraps>

c0102c4c <vector134>:
.globl vector134
vector134:
  pushl $0
c0102c4c:	6a 00                	push   $0x0
  pushl $134
c0102c4e:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102c53:	e9 1a fb ff ff       	jmp    c0102772 <__alltraps>

c0102c58 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102c58:	6a 00                	push   $0x0
  pushl $135
c0102c5a:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102c5f:	e9 0e fb ff ff       	jmp    c0102772 <__alltraps>

c0102c64 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102c64:	6a 00                	push   $0x0
  pushl $136
c0102c66:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102c6b:	e9 02 fb ff ff       	jmp    c0102772 <__alltraps>

c0102c70 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102c70:	6a 00                	push   $0x0
  pushl $137
c0102c72:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102c77:	e9 f6 fa ff ff       	jmp    c0102772 <__alltraps>

c0102c7c <vector138>:
.globl vector138
vector138:
  pushl $0
c0102c7c:	6a 00                	push   $0x0
  pushl $138
c0102c7e:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102c83:	e9 ea fa ff ff       	jmp    c0102772 <__alltraps>

c0102c88 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102c88:	6a 00                	push   $0x0
  pushl $139
c0102c8a:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102c8f:	e9 de fa ff ff       	jmp    c0102772 <__alltraps>

c0102c94 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102c94:	6a 00                	push   $0x0
  pushl $140
c0102c96:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102c9b:	e9 d2 fa ff ff       	jmp    c0102772 <__alltraps>

c0102ca0 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102ca0:	6a 00                	push   $0x0
  pushl $141
c0102ca2:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102ca7:	e9 c6 fa ff ff       	jmp    c0102772 <__alltraps>

c0102cac <vector142>:
.globl vector142
vector142:
  pushl $0
c0102cac:	6a 00                	push   $0x0
  pushl $142
c0102cae:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102cb3:	e9 ba fa ff ff       	jmp    c0102772 <__alltraps>

c0102cb8 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102cb8:	6a 00                	push   $0x0
  pushl $143
c0102cba:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102cbf:	e9 ae fa ff ff       	jmp    c0102772 <__alltraps>

c0102cc4 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102cc4:	6a 00                	push   $0x0
  pushl $144
c0102cc6:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102ccb:	e9 a2 fa ff ff       	jmp    c0102772 <__alltraps>

c0102cd0 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102cd0:	6a 00                	push   $0x0
  pushl $145
c0102cd2:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102cd7:	e9 96 fa ff ff       	jmp    c0102772 <__alltraps>

c0102cdc <vector146>:
.globl vector146
vector146:
  pushl $0
c0102cdc:	6a 00                	push   $0x0
  pushl $146
c0102cde:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102ce3:	e9 8a fa ff ff       	jmp    c0102772 <__alltraps>

c0102ce8 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102ce8:	6a 00                	push   $0x0
  pushl $147
c0102cea:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102cef:	e9 7e fa ff ff       	jmp    c0102772 <__alltraps>

c0102cf4 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102cf4:	6a 00                	push   $0x0
  pushl $148
c0102cf6:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102cfb:	e9 72 fa ff ff       	jmp    c0102772 <__alltraps>

c0102d00 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102d00:	6a 00                	push   $0x0
  pushl $149
c0102d02:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102d07:	e9 66 fa ff ff       	jmp    c0102772 <__alltraps>

c0102d0c <vector150>:
.globl vector150
vector150:
  pushl $0
c0102d0c:	6a 00                	push   $0x0
  pushl $150
c0102d0e:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102d13:	e9 5a fa ff ff       	jmp    c0102772 <__alltraps>

c0102d18 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102d18:	6a 00                	push   $0x0
  pushl $151
c0102d1a:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102d1f:	e9 4e fa ff ff       	jmp    c0102772 <__alltraps>

c0102d24 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102d24:	6a 00                	push   $0x0
  pushl $152
c0102d26:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102d2b:	e9 42 fa ff ff       	jmp    c0102772 <__alltraps>

c0102d30 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102d30:	6a 00                	push   $0x0
  pushl $153
c0102d32:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102d37:	e9 36 fa ff ff       	jmp    c0102772 <__alltraps>

c0102d3c <vector154>:
.globl vector154
vector154:
  pushl $0
c0102d3c:	6a 00                	push   $0x0
  pushl $154
c0102d3e:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102d43:	e9 2a fa ff ff       	jmp    c0102772 <__alltraps>

c0102d48 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102d48:	6a 00                	push   $0x0
  pushl $155
c0102d4a:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102d4f:	e9 1e fa ff ff       	jmp    c0102772 <__alltraps>

c0102d54 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102d54:	6a 00                	push   $0x0
  pushl $156
c0102d56:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102d5b:	e9 12 fa ff ff       	jmp    c0102772 <__alltraps>

c0102d60 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102d60:	6a 00                	push   $0x0
  pushl $157
c0102d62:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102d67:	e9 06 fa ff ff       	jmp    c0102772 <__alltraps>

c0102d6c <vector158>:
.globl vector158
vector158:
  pushl $0
c0102d6c:	6a 00                	push   $0x0
  pushl $158
c0102d6e:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102d73:	e9 fa f9 ff ff       	jmp    c0102772 <__alltraps>

c0102d78 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102d78:	6a 00                	push   $0x0
  pushl $159
c0102d7a:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102d7f:	e9 ee f9 ff ff       	jmp    c0102772 <__alltraps>

c0102d84 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102d84:	6a 00                	push   $0x0
  pushl $160
c0102d86:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102d8b:	e9 e2 f9 ff ff       	jmp    c0102772 <__alltraps>

c0102d90 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102d90:	6a 00                	push   $0x0
  pushl $161
c0102d92:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102d97:	e9 d6 f9 ff ff       	jmp    c0102772 <__alltraps>

c0102d9c <vector162>:
.globl vector162
vector162:
  pushl $0
c0102d9c:	6a 00                	push   $0x0
  pushl $162
c0102d9e:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102da3:	e9 ca f9 ff ff       	jmp    c0102772 <__alltraps>

c0102da8 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102da8:	6a 00                	push   $0x0
  pushl $163
c0102daa:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102daf:	e9 be f9 ff ff       	jmp    c0102772 <__alltraps>

c0102db4 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102db4:	6a 00                	push   $0x0
  pushl $164
c0102db6:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102dbb:	e9 b2 f9 ff ff       	jmp    c0102772 <__alltraps>

c0102dc0 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102dc0:	6a 00                	push   $0x0
  pushl $165
c0102dc2:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102dc7:	e9 a6 f9 ff ff       	jmp    c0102772 <__alltraps>

c0102dcc <vector166>:
.globl vector166
vector166:
  pushl $0
c0102dcc:	6a 00                	push   $0x0
  pushl $166
c0102dce:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102dd3:	e9 9a f9 ff ff       	jmp    c0102772 <__alltraps>

c0102dd8 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102dd8:	6a 00                	push   $0x0
  pushl $167
c0102dda:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102ddf:	e9 8e f9 ff ff       	jmp    c0102772 <__alltraps>

c0102de4 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102de4:	6a 00                	push   $0x0
  pushl $168
c0102de6:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102deb:	e9 82 f9 ff ff       	jmp    c0102772 <__alltraps>

c0102df0 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102df0:	6a 00                	push   $0x0
  pushl $169
c0102df2:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102df7:	e9 76 f9 ff ff       	jmp    c0102772 <__alltraps>

c0102dfc <vector170>:
.globl vector170
vector170:
  pushl $0
c0102dfc:	6a 00                	push   $0x0
  pushl $170
c0102dfe:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102e03:	e9 6a f9 ff ff       	jmp    c0102772 <__alltraps>

c0102e08 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102e08:	6a 00                	push   $0x0
  pushl $171
c0102e0a:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102e0f:	e9 5e f9 ff ff       	jmp    c0102772 <__alltraps>

c0102e14 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102e14:	6a 00                	push   $0x0
  pushl $172
c0102e16:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102e1b:	e9 52 f9 ff ff       	jmp    c0102772 <__alltraps>

c0102e20 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102e20:	6a 00                	push   $0x0
  pushl $173
c0102e22:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102e27:	e9 46 f9 ff ff       	jmp    c0102772 <__alltraps>

c0102e2c <vector174>:
.globl vector174
vector174:
  pushl $0
c0102e2c:	6a 00                	push   $0x0
  pushl $174
c0102e2e:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102e33:	e9 3a f9 ff ff       	jmp    c0102772 <__alltraps>

c0102e38 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102e38:	6a 00                	push   $0x0
  pushl $175
c0102e3a:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102e3f:	e9 2e f9 ff ff       	jmp    c0102772 <__alltraps>

c0102e44 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102e44:	6a 00                	push   $0x0
  pushl $176
c0102e46:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102e4b:	e9 22 f9 ff ff       	jmp    c0102772 <__alltraps>

c0102e50 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102e50:	6a 00                	push   $0x0
  pushl $177
c0102e52:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102e57:	e9 16 f9 ff ff       	jmp    c0102772 <__alltraps>

c0102e5c <vector178>:
.globl vector178
vector178:
  pushl $0
c0102e5c:	6a 00                	push   $0x0
  pushl $178
c0102e5e:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102e63:	e9 0a f9 ff ff       	jmp    c0102772 <__alltraps>

c0102e68 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102e68:	6a 00                	push   $0x0
  pushl $179
c0102e6a:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102e6f:	e9 fe f8 ff ff       	jmp    c0102772 <__alltraps>

c0102e74 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102e74:	6a 00                	push   $0x0
  pushl $180
c0102e76:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102e7b:	e9 f2 f8 ff ff       	jmp    c0102772 <__alltraps>

c0102e80 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102e80:	6a 00                	push   $0x0
  pushl $181
c0102e82:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102e87:	e9 e6 f8 ff ff       	jmp    c0102772 <__alltraps>

c0102e8c <vector182>:
.globl vector182
vector182:
  pushl $0
c0102e8c:	6a 00                	push   $0x0
  pushl $182
c0102e8e:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102e93:	e9 da f8 ff ff       	jmp    c0102772 <__alltraps>

c0102e98 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102e98:	6a 00                	push   $0x0
  pushl $183
c0102e9a:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102e9f:	e9 ce f8 ff ff       	jmp    c0102772 <__alltraps>

c0102ea4 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102ea4:	6a 00                	push   $0x0
  pushl $184
c0102ea6:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102eab:	e9 c2 f8 ff ff       	jmp    c0102772 <__alltraps>

c0102eb0 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102eb0:	6a 00                	push   $0x0
  pushl $185
c0102eb2:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102eb7:	e9 b6 f8 ff ff       	jmp    c0102772 <__alltraps>

c0102ebc <vector186>:
.globl vector186
vector186:
  pushl $0
c0102ebc:	6a 00                	push   $0x0
  pushl $186
c0102ebe:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102ec3:	e9 aa f8 ff ff       	jmp    c0102772 <__alltraps>

c0102ec8 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102ec8:	6a 00                	push   $0x0
  pushl $187
c0102eca:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102ecf:	e9 9e f8 ff ff       	jmp    c0102772 <__alltraps>

c0102ed4 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102ed4:	6a 00                	push   $0x0
  pushl $188
c0102ed6:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102edb:	e9 92 f8 ff ff       	jmp    c0102772 <__alltraps>

c0102ee0 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102ee0:	6a 00                	push   $0x0
  pushl $189
c0102ee2:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102ee7:	e9 86 f8 ff ff       	jmp    c0102772 <__alltraps>

c0102eec <vector190>:
.globl vector190
vector190:
  pushl $0
c0102eec:	6a 00                	push   $0x0
  pushl $190
c0102eee:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102ef3:	e9 7a f8 ff ff       	jmp    c0102772 <__alltraps>

c0102ef8 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102ef8:	6a 00                	push   $0x0
  pushl $191
c0102efa:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102eff:	e9 6e f8 ff ff       	jmp    c0102772 <__alltraps>

c0102f04 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102f04:	6a 00                	push   $0x0
  pushl $192
c0102f06:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102f0b:	e9 62 f8 ff ff       	jmp    c0102772 <__alltraps>

c0102f10 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102f10:	6a 00                	push   $0x0
  pushl $193
c0102f12:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102f17:	e9 56 f8 ff ff       	jmp    c0102772 <__alltraps>

c0102f1c <vector194>:
.globl vector194
vector194:
  pushl $0
c0102f1c:	6a 00                	push   $0x0
  pushl $194
c0102f1e:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102f23:	e9 4a f8 ff ff       	jmp    c0102772 <__alltraps>

c0102f28 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102f28:	6a 00                	push   $0x0
  pushl $195
c0102f2a:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102f2f:	e9 3e f8 ff ff       	jmp    c0102772 <__alltraps>

c0102f34 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102f34:	6a 00                	push   $0x0
  pushl $196
c0102f36:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102f3b:	e9 32 f8 ff ff       	jmp    c0102772 <__alltraps>

c0102f40 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102f40:	6a 00                	push   $0x0
  pushl $197
c0102f42:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102f47:	e9 26 f8 ff ff       	jmp    c0102772 <__alltraps>

c0102f4c <vector198>:
.globl vector198
vector198:
  pushl $0
c0102f4c:	6a 00                	push   $0x0
  pushl $198
c0102f4e:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102f53:	e9 1a f8 ff ff       	jmp    c0102772 <__alltraps>

c0102f58 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102f58:	6a 00                	push   $0x0
  pushl $199
c0102f5a:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102f5f:	e9 0e f8 ff ff       	jmp    c0102772 <__alltraps>

c0102f64 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102f64:	6a 00                	push   $0x0
  pushl $200
c0102f66:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102f6b:	e9 02 f8 ff ff       	jmp    c0102772 <__alltraps>

c0102f70 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102f70:	6a 00                	push   $0x0
  pushl $201
c0102f72:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102f77:	e9 f6 f7 ff ff       	jmp    c0102772 <__alltraps>

c0102f7c <vector202>:
.globl vector202
vector202:
  pushl $0
c0102f7c:	6a 00                	push   $0x0
  pushl $202
c0102f7e:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102f83:	e9 ea f7 ff ff       	jmp    c0102772 <__alltraps>

c0102f88 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102f88:	6a 00                	push   $0x0
  pushl $203
c0102f8a:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102f8f:	e9 de f7 ff ff       	jmp    c0102772 <__alltraps>

c0102f94 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102f94:	6a 00                	push   $0x0
  pushl $204
c0102f96:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102f9b:	e9 d2 f7 ff ff       	jmp    c0102772 <__alltraps>

c0102fa0 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102fa0:	6a 00                	push   $0x0
  pushl $205
c0102fa2:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102fa7:	e9 c6 f7 ff ff       	jmp    c0102772 <__alltraps>

c0102fac <vector206>:
.globl vector206
vector206:
  pushl $0
c0102fac:	6a 00                	push   $0x0
  pushl $206
c0102fae:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102fb3:	e9 ba f7 ff ff       	jmp    c0102772 <__alltraps>

c0102fb8 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102fb8:	6a 00                	push   $0x0
  pushl $207
c0102fba:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102fbf:	e9 ae f7 ff ff       	jmp    c0102772 <__alltraps>

c0102fc4 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102fc4:	6a 00                	push   $0x0
  pushl $208
c0102fc6:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102fcb:	e9 a2 f7 ff ff       	jmp    c0102772 <__alltraps>

c0102fd0 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102fd0:	6a 00                	push   $0x0
  pushl $209
c0102fd2:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102fd7:	e9 96 f7 ff ff       	jmp    c0102772 <__alltraps>

c0102fdc <vector210>:
.globl vector210
vector210:
  pushl $0
c0102fdc:	6a 00                	push   $0x0
  pushl $210
c0102fde:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102fe3:	e9 8a f7 ff ff       	jmp    c0102772 <__alltraps>

c0102fe8 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102fe8:	6a 00                	push   $0x0
  pushl $211
c0102fea:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102fef:	e9 7e f7 ff ff       	jmp    c0102772 <__alltraps>

c0102ff4 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102ff4:	6a 00                	push   $0x0
  pushl $212
c0102ff6:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102ffb:	e9 72 f7 ff ff       	jmp    c0102772 <__alltraps>

c0103000 <vector213>:
.globl vector213
vector213:
  pushl $0
c0103000:	6a 00                	push   $0x0
  pushl $213
c0103002:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0103007:	e9 66 f7 ff ff       	jmp    c0102772 <__alltraps>

c010300c <vector214>:
.globl vector214
vector214:
  pushl $0
c010300c:	6a 00                	push   $0x0
  pushl $214
c010300e:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0103013:	e9 5a f7 ff ff       	jmp    c0102772 <__alltraps>

c0103018 <vector215>:
.globl vector215
vector215:
  pushl $0
c0103018:	6a 00                	push   $0x0
  pushl $215
c010301a:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010301f:	e9 4e f7 ff ff       	jmp    c0102772 <__alltraps>

c0103024 <vector216>:
.globl vector216
vector216:
  pushl $0
c0103024:	6a 00                	push   $0x0
  pushl $216
c0103026:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010302b:	e9 42 f7 ff ff       	jmp    c0102772 <__alltraps>

c0103030 <vector217>:
.globl vector217
vector217:
  pushl $0
c0103030:	6a 00                	push   $0x0
  pushl $217
c0103032:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0103037:	e9 36 f7 ff ff       	jmp    c0102772 <__alltraps>

c010303c <vector218>:
.globl vector218
vector218:
  pushl $0
c010303c:	6a 00                	push   $0x0
  pushl $218
c010303e:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0103043:	e9 2a f7 ff ff       	jmp    c0102772 <__alltraps>

c0103048 <vector219>:
.globl vector219
vector219:
  pushl $0
c0103048:	6a 00                	push   $0x0
  pushl $219
c010304a:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c010304f:	e9 1e f7 ff ff       	jmp    c0102772 <__alltraps>

c0103054 <vector220>:
.globl vector220
vector220:
  pushl $0
c0103054:	6a 00                	push   $0x0
  pushl $220
c0103056:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010305b:	e9 12 f7 ff ff       	jmp    c0102772 <__alltraps>

c0103060 <vector221>:
.globl vector221
vector221:
  pushl $0
c0103060:	6a 00                	push   $0x0
  pushl $221
c0103062:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103067:	e9 06 f7 ff ff       	jmp    c0102772 <__alltraps>

c010306c <vector222>:
.globl vector222
vector222:
  pushl $0
c010306c:	6a 00                	push   $0x0
  pushl $222
c010306e:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0103073:	e9 fa f6 ff ff       	jmp    c0102772 <__alltraps>

c0103078 <vector223>:
.globl vector223
vector223:
  pushl $0
c0103078:	6a 00                	push   $0x0
  pushl $223
c010307a:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010307f:	e9 ee f6 ff ff       	jmp    c0102772 <__alltraps>

c0103084 <vector224>:
.globl vector224
vector224:
  pushl $0
c0103084:	6a 00                	push   $0x0
  pushl $224
c0103086:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010308b:	e9 e2 f6 ff ff       	jmp    c0102772 <__alltraps>

c0103090 <vector225>:
.globl vector225
vector225:
  pushl $0
c0103090:	6a 00                	push   $0x0
  pushl $225
c0103092:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0103097:	e9 d6 f6 ff ff       	jmp    c0102772 <__alltraps>

c010309c <vector226>:
.globl vector226
vector226:
  pushl $0
c010309c:	6a 00                	push   $0x0
  pushl $226
c010309e:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01030a3:	e9 ca f6 ff ff       	jmp    c0102772 <__alltraps>

c01030a8 <vector227>:
.globl vector227
vector227:
  pushl $0
c01030a8:	6a 00                	push   $0x0
  pushl $227
c01030aa:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01030af:	e9 be f6 ff ff       	jmp    c0102772 <__alltraps>

c01030b4 <vector228>:
.globl vector228
vector228:
  pushl $0
c01030b4:	6a 00                	push   $0x0
  pushl $228
c01030b6:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01030bb:	e9 b2 f6 ff ff       	jmp    c0102772 <__alltraps>

c01030c0 <vector229>:
.globl vector229
vector229:
  pushl $0
c01030c0:	6a 00                	push   $0x0
  pushl $229
c01030c2:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01030c7:	e9 a6 f6 ff ff       	jmp    c0102772 <__alltraps>

c01030cc <vector230>:
.globl vector230
vector230:
  pushl $0
c01030cc:	6a 00                	push   $0x0
  pushl $230
c01030ce:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01030d3:	e9 9a f6 ff ff       	jmp    c0102772 <__alltraps>

c01030d8 <vector231>:
.globl vector231
vector231:
  pushl $0
c01030d8:	6a 00                	push   $0x0
  pushl $231
c01030da:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01030df:	e9 8e f6 ff ff       	jmp    c0102772 <__alltraps>

c01030e4 <vector232>:
.globl vector232
vector232:
  pushl $0
c01030e4:	6a 00                	push   $0x0
  pushl $232
c01030e6:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01030eb:	e9 82 f6 ff ff       	jmp    c0102772 <__alltraps>

c01030f0 <vector233>:
.globl vector233
vector233:
  pushl $0
c01030f0:	6a 00                	push   $0x0
  pushl $233
c01030f2:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01030f7:	e9 76 f6 ff ff       	jmp    c0102772 <__alltraps>

c01030fc <vector234>:
.globl vector234
vector234:
  pushl $0
c01030fc:	6a 00                	push   $0x0
  pushl $234
c01030fe:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0103103:	e9 6a f6 ff ff       	jmp    c0102772 <__alltraps>

c0103108 <vector235>:
.globl vector235
vector235:
  pushl $0
c0103108:	6a 00                	push   $0x0
  pushl $235
c010310a:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010310f:	e9 5e f6 ff ff       	jmp    c0102772 <__alltraps>

c0103114 <vector236>:
.globl vector236
vector236:
  pushl $0
c0103114:	6a 00                	push   $0x0
  pushl $236
c0103116:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c010311b:	e9 52 f6 ff ff       	jmp    c0102772 <__alltraps>

c0103120 <vector237>:
.globl vector237
vector237:
  pushl $0
c0103120:	6a 00                	push   $0x0
  pushl $237
c0103122:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0103127:	e9 46 f6 ff ff       	jmp    c0102772 <__alltraps>

c010312c <vector238>:
.globl vector238
vector238:
  pushl $0
c010312c:	6a 00                	push   $0x0
  pushl $238
c010312e:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0103133:	e9 3a f6 ff ff       	jmp    c0102772 <__alltraps>

c0103138 <vector239>:
.globl vector239
vector239:
  pushl $0
c0103138:	6a 00                	push   $0x0
  pushl $239
c010313a:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c010313f:	e9 2e f6 ff ff       	jmp    c0102772 <__alltraps>

c0103144 <vector240>:
.globl vector240
vector240:
  pushl $0
c0103144:	6a 00                	push   $0x0
  pushl $240
c0103146:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010314b:	e9 22 f6 ff ff       	jmp    c0102772 <__alltraps>

c0103150 <vector241>:
.globl vector241
vector241:
  pushl $0
c0103150:	6a 00                	push   $0x0
  pushl $241
c0103152:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0103157:	e9 16 f6 ff ff       	jmp    c0102772 <__alltraps>

c010315c <vector242>:
.globl vector242
vector242:
  pushl $0
c010315c:	6a 00                	push   $0x0
  pushl $242
c010315e:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103163:	e9 0a f6 ff ff       	jmp    c0102772 <__alltraps>

c0103168 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103168:	6a 00                	push   $0x0
  pushl $243
c010316a:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010316f:	e9 fe f5 ff ff       	jmp    c0102772 <__alltraps>

c0103174 <vector244>:
.globl vector244
vector244:
  pushl $0
c0103174:	6a 00                	push   $0x0
  pushl $244
c0103176:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010317b:	e9 f2 f5 ff ff       	jmp    c0102772 <__alltraps>

c0103180 <vector245>:
.globl vector245
vector245:
  pushl $0
c0103180:	6a 00                	push   $0x0
  pushl $245
c0103182:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103187:	e9 e6 f5 ff ff       	jmp    c0102772 <__alltraps>

c010318c <vector246>:
.globl vector246
vector246:
  pushl $0
c010318c:	6a 00                	push   $0x0
  pushl $246
c010318e:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0103193:	e9 da f5 ff ff       	jmp    c0102772 <__alltraps>

c0103198 <vector247>:
.globl vector247
vector247:
  pushl $0
c0103198:	6a 00                	push   $0x0
  pushl $247
c010319a:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c010319f:	e9 ce f5 ff ff       	jmp    c0102772 <__alltraps>

c01031a4 <vector248>:
.globl vector248
vector248:
  pushl $0
c01031a4:	6a 00                	push   $0x0
  pushl $248
c01031a6:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01031ab:	e9 c2 f5 ff ff       	jmp    c0102772 <__alltraps>

c01031b0 <vector249>:
.globl vector249
vector249:
  pushl $0
c01031b0:	6a 00                	push   $0x0
  pushl $249
c01031b2:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01031b7:	e9 b6 f5 ff ff       	jmp    c0102772 <__alltraps>

c01031bc <vector250>:
.globl vector250
vector250:
  pushl $0
c01031bc:	6a 00                	push   $0x0
  pushl $250
c01031be:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01031c3:	e9 aa f5 ff ff       	jmp    c0102772 <__alltraps>

c01031c8 <vector251>:
.globl vector251
vector251:
  pushl $0
c01031c8:	6a 00                	push   $0x0
  pushl $251
c01031ca:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01031cf:	e9 9e f5 ff ff       	jmp    c0102772 <__alltraps>

c01031d4 <vector252>:
.globl vector252
vector252:
  pushl $0
c01031d4:	6a 00                	push   $0x0
  pushl $252
c01031d6:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01031db:	e9 92 f5 ff ff       	jmp    c0102772 <__alltraps>

c01031e0 <vector253>:
.globl vector253
vector253:
  pushl $0
c01031e0:	6a 00                	push   $0x0
  pushl $253
c01031e2:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c01031e7:	e9 86 f5 ff ff       	jmp    c0102772 <__alltraps>

c01031ec <vector254>:
.globl vector254
vector254:
  pushl $0
c01031ec:	6a 00                	push   $0x0
  pushl $254
c01031ee:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c01031f3:	e9 7a f5 ff ff       	jmp    c0102772 <__alltraps>

c01031f8 <vector255>:
.globl vector255
vector255:
  pushl $0
c01031f8:	6a 00                	push   $0x0
  pushl $255
c01031fa:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01031ff:	e9 6e f5 ff ff       	jmp    c0102772 <__alltraps>

c0103204 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0103204:	55                   	push   %ebp
c0103205:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103207:	8b 55 08             	mov    0x8(%ebp),%edx
c010320a:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c010320f:	29 c2                	sub    %eax,%edx
c0103211:	89 d0                	mov    %edx,%eax
c0103213:	c1 f8 05             	sar    $0x5,%eax
}
c0103216:	5d                   	pop    %ebp
c0103217:	c3                   	ret    

c0103218 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103218:	55                   	push   %ebp
c0103219:	89 e5                	mov    %esp,%ebp
c010321b:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010321e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103221:	89 04 24             	mov    %eax,(%esp)
c0103224:	e8 db ff ff ff       	call   c0103204 <page2ppn>
c0103229:	c1 e0 0c             	shl    $0xc,%eax
}
c010322c:	c9                   	leave  
c010322d:	c3                   	ret    

c010322e <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c010322e:	55                   	push   %ebp
c010322f:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103231:	8b 45 08             	mov    0x8(%ebp),%eax
c0103234:	8b 00                	mov    (%eax),%eax
}
c0103236:	5d                   	pop    %ebp
c0103237:	c3                   	ret    

c0103238 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103238:	55                   	push   %ebp
c0103239:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010323b:	8b 45 08             	mov    0x8(%ebp),%eax
c010323e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103241:	89 10                	mov    %edx,(%eax)
}
c0103243:	5d                   	pop    %ebp
c0103244:	c3                   	ret    

c0103245 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0103245:	55                   	push   %ebp
c0103246:	89 e5                	mov    %esp,%ebp
c0103248:	83 ec 10             	sub    $0x10,%esp
c010324b:	c7 45 fc 40 40 12 c0 	movl   $0xc0124040,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103252:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103255:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0103258:	89 50 04             	mov    %edx,0x4(%eax)
c010325b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010325e:	8b 50 04             	mov    0x4(%eax),%edx
c0103261:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103264:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0103266:	c7 05 48 40 12 c0 00 	movl   $0x0,0xc0124048
c010326d:	00 00 00 
}
c0103270:	c9                   	leave  
c0103271:	c3                   	ret    

c0103272 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0103272:	55                   	push   %ebp
c0103273:	89 e5                	mov    %esp,%ebp
c0103275:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0103278:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010327c:	75 24                	jne    c01032a2 <default_init_memmap+0x30>
c010327e:	c7 44 24 0c 90 95 10 	movl   $0xc0109590,0xc(%esp)
c0103285:	c0 
c0103286:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c010328d:	c0 
c010328e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0103295:	00 
c0103296:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c010329d:	e8 3f da ff ff       	call   c0100ce1 <__panic>
    struct Page *p = base;
c01032a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01032a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01032a8:	eb 7d                	jmp    c0103327 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c01032aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032ad:	83 c0 04             	add    $0x4,%eax
c01032b0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01032b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01032ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01032c0:	0f a3 10             	bt     %edx,(%eax)
c01032c3:	19 c0                	sbb    %eax,%eax
c01032c5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c01032c8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01032cc:	0f 95 c0             	setne  %al
c01032cf:	0f b6 c0             	movzbl %al,%eax
c01032d2:	85 c0                	test   %eax,%eax
c01032d4:	75 24                	jne    c01032fa <default_init_memmap+0x88>
c01032d6:	c7 44 24 0c c1 95 10 	movl   $0xc01095c1,0xc(%esp)
c01032dd:	c0 
c01032de:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c01032e5:	c0 
c01032e6:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01032ed:	00 
c01032ee:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c01032f5:	e8 e7 d9 ff ff       	call   c0100ce1 <__panic>
        p->flags = p->property = 0;
c01032fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032fd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0103304:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103307:	8b 50 08             	mov    0x8(%eax),%edx
c010330a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010330d:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0103310:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103317:	00 
c0103318:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010331b:	89 04 24             	mov    %eax,(%esp)
c010331e:	e8 15 ff ff ff       	call   c0103238 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0103323:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103327:	8b 45 0c             	mov    0xc(%ebp),%eax
c010332a:	c1 e0 05             	shl    $0x5,%eax
c010332d:	89 c2                	mov    %eax,%edx
c010332f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103332:	01 d0                	add    %edx,%eax
c0103334:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103337:	0f 85 6d ff ff ff    	jne    c01032aa <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c010333d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103340:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103343:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0103346:	8b 45 08             	mov    0x8(%ebp),%eax
c0103349:	83 c0 04             	add    $0x4,%eax
c010334c:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c0103353:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103356:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103359:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010335c:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c010335f:	8b 15 48 40 12 c0    	mov    0xc0124048,%edx
c0103365:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103368:	01 d0                	add    %edx,%eax
c010336a:	a3 48 40 12 c0       	mov    %eax,0xc0124048
    list_add_before(&free_list, &(base->page_link));
c010336f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103372:	83 c0 0c             	add    $0xc,%eax
c0103375:	c7 45 dc 40 40 12 c0 	movl   $0xc0124040,-0x24(%ebp)
c010337c:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010337f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103382:	8b 00                	mov    (%eax),%eax
c0103384:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0103387:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010338a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010338d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103390:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0103393:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103396:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103399:	89 10                	mov    %edx,(%eax)
c010339b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010339e:	8b 10                	mov    (%eax),%edx
c01033a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01033a3:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01033a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01033a9:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01033ac:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01033af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01033b2:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01033b5:	89 10                	mov    %edx,(%eax)
}
c01033b7:	c9                   	leave  
c01033b8:	c3                   	ret    

c01033b9 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01033b9:	55                   	push   %ebp
c01033ba:	89 e5                	mov    %esp,%ebp
c01033bc:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01033bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01033c3:	75 24                	jne    c01033e9 <default_alloc_pages+0x30>
c01033c5:	c7 44 24 0c 90 95 10 	movl   $0xc0109590,0xc(%esp)
c01033cc:	c0 
c01033cd:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c01033d4:	c0 
c01033d5:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c01033dc:	00 
c01033dd:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c01033e4:	e8 f8 d8 ff ff       	call   c0100ce1 <__panic>
    if (n > nr_free) {
c01033e9:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c01033ee:	3b 45 08             	cmp    0x8(%ebp),%eax
c01033f1:	73 0a                	jae    c01033fd <default_alloc_pages+0x44>
        return NULL;
c01033f3:	b8 00 00 00 00       	mov    $0x0,%eax
c01033f8:	e9 36 01 00 00       	jmp    c0103533 <default_alloc_pages+0x17a>
    }
    struct Page *page = NULL;
c01033fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0103404:	c7 45 f0 40 40 12 c0 	movl   $0xc0124040,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c010340b:	eb 1c                	jmp    c0103429 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c010340d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103410:	83 e8 0c             	sub    $0xc,%eax
c0103413:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0103416:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103419:	8b 40 08             	mov    0x8(%eax),%eax
c010341c:	3b 45 08             	cmp    0x8(%ebp),%eax
c010341f:	72 08                	jb     c0103429 <default_alloc_pages+0x70>
            page = p;
c0103421:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103424:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0103427:	eb 18                	jmp    c0103441 <default_alloc_pages+0x88>
c0103429:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010342c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010342f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103432:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c0103435:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103438:	81 7d f0 40 40 12 c0 	cmpl   $0xc0124040,-0x10(%ebp)
c010343f:	75 cc                	jne    c010340d <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0103441:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103445:	0f 84 e5 00 00 00    	je     c0103530 <default_alloc_pages+0x177>
        if (page->property > n) {
c010344b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010344e:	8b 40 08             	mov    0x8(%eax),%eax
c0103451:	3b 45 08             	cmp    0x8(%ebp),%eax
c0103454:	0f 86 85 00 00 00    	jbe    c01034df <default_alloc_pages+0x126>
            struct Page *p = page + n;
c010345a:	8b 45 08             	mov    0x8(%ebp),%eax
c010345d:	c1 e0 05             	shl    $0x5,%eax
c0103460:	89 c2                	mov    %eax,%edx
c0103462:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103465:	01 d0                	add    %edx,%eax
c0103467:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c010346a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010346d:	8b 40 08             	mov    0x8(%eax),%eax
c0103470:	2b 45 08             	sub    0x8(%ebp),%eax
c0103473:	89 c2                	mov    %eax,%edx
c0103475:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103478:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c010347b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010347e:	83 c0 04             	add    $0x4,%eax
c0103481:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0103488:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010348b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010348e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103491:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c0103494:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103497:	83 c0 0c             	add    $0xc,%eax
c010349a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010349d:	83 c2 0c             	add    $0xc,%edx
c01034a0:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01034a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01034a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01034a9:	8b 40 04             	mov    0x4(%eax),%eax
c01034ac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01034af:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01034b2:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01034b5:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01034b8:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01034bb:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01034be:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01034c1:	89 10                	mov    %edx,(%eax)
c01034c3:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01034c6:	8b 10                	mov    (%eax),%edx
c01034c8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01034cb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01034ce:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01034d1:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01034d4:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01034d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01034da:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01034dd:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c01034df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034e2:	83 c0 0c             	add    $0xc,%eax
c01034e5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01034e8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01034eb:	8b 40 04             	mov    0x4(%eax),%eax
c01034ee:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01034f1:	8b 12                	mov    (%edx),%edx
c01034f3:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01034f6:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01034f9:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01034fc:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01034ff:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0103502:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103505:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103508:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c010350a:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c010350f:	2b 45 08             	sub    0x8(%ebp),%eax
c0103512:	a3 48 40 12 c0       	mov    %eax,0xc0124048
        ClearPageProperty(page);
c0103517:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010351a:	83 c0 04             	add    $0x4,%eax
c010351d:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0103524:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103527:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010352a:	8b 55 b8             	mov    -0x48(%ebp),%edx
c010352d:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0103530:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103533:	c9                   	leave  
c0103534:	c3                   	ret    

c0103535 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0103535:	55                   	push   %ebp
c0103536:	89 e5                	mov    %esp,%ebp
c0103538:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c010353e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103542:	75 24                	jne    c0103568 <default_free_pages+0x33>
c0103544:	c7 44 24 0c 90 95 10 	movl   $0xc0109590,0xc(%esp)
c010354b:	c0 
c010354c:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103553:	c0 
c0103554:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c010355b:	00 
c010355c:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103563:	e8 79 d7 ff ff       	call   c0100ce1 <__panic>
    struct Page *p = base;
c0103568:	8b 45 08             	mov    0x8(%ebp),%eax
c010356b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c010356e:	e9 9d 00 00 00       	jmp    c0103610 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0103573:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103576:	83 c0 04             	add    $0x4,%eax
c0103579:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0103580:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103583:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103586:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103589:	0f a3 10             	bt     %edx,(%eax)
c010358c:	19 c0                	sbb    %eax,%eax
c010358e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0103591:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103595:	0f 95 c0             	setne  %al
c0103598:	0f b6 c0             	movzbl %al,%eax
c010359b:	85 c0                	test   %eax,%eax
c010359d:	75 2c                	jne    c01035cb <default_free_pages+0x96>
c010359f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035a2:	83 c0 04             	add    $0x4,%eax
c01035a5:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c01035ac:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01035af:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01035b2:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01035b5:	0f a3 10             	bt     %edx,(%eax)
c01035b8:	19 c0                	sbb    %eax,%eax
c01035ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c01035bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01035c1:	0f 95 c0             	setne  %al
c01035c4:	0f b6 c0             	movzbl %al,%eax
c01035c7:	85 c0                	test   %eax,%eax
c01035c9:	74 24                	je     c01035ef <default_free_pages+0xba>
c01035cb:	c7 44 24 0c d4 95 10 	movl   $0xc01095d4,0xc(%esp)
c01035d2:	c0 
c01035d3:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c01035da:	c0 
c01035db:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
c01035e2:	00 
c01035e3:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c01035ea:	e8 f2 d6 ff ff       	call   c0100ce1 <__panic>
        p->flags = 0;
c01035ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035f2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01035f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103600:	00 
c0103601:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103604:	89 04 24             	mov    %eax,(%esp)
c0103607:	e8 2c fc ff ff       	call   c0103238 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c010360c:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0103610:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103613:	c1 e0 05             	shl    $0x5,%eax
c0103616:	89 c2                	mov    %eax,%edx
c0103618:	8b 45 08             	mov    0x8(%ebp),%eax
c010361b:	01 d0                	add    %edx,%eax
c010361d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103620:	0f 85 4d ff ff ff    	jne    c0103573 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0103626:	8b 45 08             	mov    0x8(%ebp),%eax
c0103629:	8b 55 0c             	mov    0xc(%ebp),%edx
c010362c:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c010362f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103632:	83 c0 04             	add    $0x4,%eax
c0103635:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c010363c:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c010363f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103642:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103645:	0f ab 10             	bts    %edx,(%eax)
c0103648:	c7 45 cc 40 40 12 c0 	movl   $0xc0124040,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010364f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103652:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0103655:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0103658:	e9 fa 00 00 00       	jmp    c0103757 <default_free_pages+0x222>
        p = le2page(le, page_link);
c010365d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103660:	83 e8 0c             	sub    $0xc,%eax
c0103663:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103666:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103669:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010366c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010366f:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0103672:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c0103675:	8b 45 08             	mov    0x8(%ebp),%eax
c0103678:	8b 40 08             	mov    0x8(%eax),%eax
c010367b:	c1 e0 05             	shl    $0x5,%eax
c010367e:	89 c2                	mov    %eax,%edx
c0103680:	8b 45 08             	mov    0x8(%ebp),%eax
c0103683:	01 d0                	add    %edx,%eax
c0103685:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103688:	75 5a                	jne    c01036e4 <default_free_pages+0x1af>
            base->property += p->property;
c010368a:	8b 45 08             	mov    0x8(%ebp),%eax
c010368d:	8b 50 08             	mov    0x8(%eax),%edx
c0103690:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103693:	8b 40 08             	mov    0x8(%eax),%eax
c0103696:	01 c2                	add    %eax,%edx
c0103698:	8b 45 08             	mov    0x8(%ebp),%eax
c010369b:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c010369e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036a1:	83 c0 04             	add    $0x4,%eax
c01036a4:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c01036ab:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01036ae:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01036b1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01036b4:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c01036b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036ba:	83 c0 0c             	add    $0xc,%eax
c01036bd:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01036c0:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01036c3:	8b 40 04             	mov    0x4(%eax),%eax
c01036c6:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01036c9:	8b 12                	mov    (%edx),%edx
c01036cb:	89 55 b8             	mov    %edx,-0x48(%ebp)
c01036ce:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01036d1:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01036d4:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01036d7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01036da:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01036dd:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01036e0:	89 10                	mov    %edx,(%eax)
c01036e2:	eb 73                	jmp    c0103757 <default_free_pages+0x222>
        }
        else if (p + p->property == base) {
c01036e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036e7:	8b 40 08             	mov    0x8(%eax),%eax
c01036ea:	c1 e0 05             	shl    $0x5,%eax
c01036ed:	89 c2                	mov    %eax,%edx
c01036ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036f2:	01 d0                	add    %edx,%eax
c01036f4:	3b 45 08             	cmp    0x8(%ebp),%eax
c01036f7:	75 5e                	jne    c0103757 <default_free_pages+0x222>
            p->property += base->property;
c01036f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036fc:	8b 50 08             	mov    0x8(%eax),%edx
c01036ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0103702:	8b 40 08             	mov    0x8(%eax),%eax
c0103705:	01 c2                	add    %eax,%edx
c0103707:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010370a:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c010370d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103710:	83 c0 04             	add    $0x4,%eax
c0103713:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c010371a:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010371d:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103720:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0103723:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0103726:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103729:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c010372c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010372f:	83 c0 0c             	add    $0xc,%eax
c0103732:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0103735:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103738:	8b 40 04             	mov    0x4(%eax),%eax
c010373b:	8b 55 a8             	mov    -0x58(%ebp),%edx
c010373e:	8b 12                	mov    (%edx),%edx
c0103740:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0103743:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0103746:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103749:	8b 55 a0             	mov    -0x60(%ebp),%edx
c010374c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010374f:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103752:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0103755:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0103757:	81 7d f0 40 40 12 c0 	cmpl   $0xc0124040,-0x10(%ebp)
c010375e:	0f 85 f9 fe ff ff    	jne    c010365d <default_free_pages+0x128>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c0103764:	8b 15 48 40 12 c0    	mov    0xc0124048,%edx
c010376a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010376d:	01 d0                	add    %edx,%eax
c010376f:	a3 48 40 12 c0       	mov    %eax,0xc0124048
c0103774:	c7 45 9c 40 40 12 c0 	movl   $0xc0124040,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010377b:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010377e:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0103781:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0103784:	eb 68                	jmp    c01037ee <default_free_pages+0x2b9>
        p = le2page(le, page_link);
c0103786:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103789:	83 e8 0c             	sub    $0xc,%eax
c010378c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c010378f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103792:	8b 40 08             	mov    0x8(%eax),%eax
c0103795:	c1 e0 05             	shl    $0x5,%eax
c0103798:	89 c2                	mov    %eax,%edx
c010379a:	8b 45 08             	mov    0x8(%ebp),%eax
c010379d:	01 d0                	add    %edx,%eax
c010379f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01037a2:	77 3b                	ja     c01037df <default_free_pages+0x2aa>
            assert(base + base->property != p);
c01037a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01037a7:	8b 40 08             	mov    0x8(%eax),%eax
c01037aa:	c1 e0 05             	shl    $0x5,%eax
c01037ad:	89 c2                	mov    %eax,%edx
c01037af:	8b 45 08             	mov    0x8(%ebp),%eax
c01037b2:	01 d0                	add    %edx,%eax
c01037b4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01037b7:	75 24                	jne    c01037dd <default_free_pages+0x2a8>
c01037b9:	c7 44 24 0c f9 95 10 	movl   $0xc01095f9,0xc(%esp)
c01037c0:	c0 
c01037c1:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c01037c8:	c0 
c01037c9:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c01037d0:	00 
c01037d1:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c01037d8:	e8 04 d5 ff ff       	call   c0100ce1 <__panic>
            break;
c01037dd:	eb 18                	jmp    c01037f7 <default_free_pages+0x2c2>
c01037df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01037e2:	89 45 98             	mov    %eax,-0x68(%ebp)
c01037e5:	8b 45 98             	mov    -0x68(%ebp),%eax
c01037e8:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
c01037eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c01037ee:	81 7d f0 40 40 12 c0 	cmpl   $0xc0124040,-0x10(%ebp)
c01037f5:	75 8f                	jne    c0103786 <default_free_pages+0x251>
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c01037f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01037fa:	8d 50 0c             	lea    0xc(%eax),%edx
c01037fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103800:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0103803:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0103806:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103809:	8b 00                	mov    (%eax),%eax
c010380b:	8b 55 90             	mov    -0x70(%ebp),%edx
c010380e:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0103811:	89 45 88             	mov    %eax,-0x78(%ebp)
c0103814:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103817:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010381a:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010381d:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0103820:	89 10                	mov    %edx,(%eax)
c0103822:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103825:	8b 10                	mov    (%eax),%edx
c0103827:	8b 45 88             	mov    -0x78(%ebp),%eax
c010382a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010382d:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103830:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103833:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103836:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103839:	8b 55 88             	mov    -0x78(%ebp),%edx
c010383c:	89 10                	mov    %edx,(%eax)
}
c010383e:	c9                   	leave  
c010383f:	c3                   	ret    

c0103840 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0103840:	55                   	push   %ebp
c0103841:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103843:	a1 48 40 12 c0       	mov    0xc0124048,%eax
}
c0103848:	5d                   	pop    %ebp
c0103849:	c3                   	ret    

c010384a <basic_check>:

static void
basic_check(void) {
c010384a:	55                   	push   %ebp
c010384b:	89 e5                	mov    %esp,%ebp
c010384d:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103850:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103857:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010385a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010385d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103860:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103863:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010386a:	e8 d7 0e 00 00       	call   c0104746 <alloc_pages>
c010386f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103872:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103876:	75 24                	jne    c010389c <basic_check+0x52>
c0103878:	c7 44 24 0c 14 96 10 	movl   $0xc0109614,0xc(%esp)
c010387f:	c0 
c0103880:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103887:	c0 
c0103888:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c010388f:	00 
c0103890:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103897:	e8 45 d4 ff ff       	call   c0100ce1 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010389c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01038a3:	e8 9e 0e 00 00       	call   c0104746 <alloc_pages>
c01038a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01038ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01038af:	75 24                	jne    c01038d5 <basic_check+0x8b>
c01038b1:	c7 44 24 0c 30 96 10 	movl   $0xc0109630,0xc(%esp)
c01038b8:	c0 
c01038b9:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c01038c0:	c0 
c01038c1:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c01038c8:	00 
c01038c9:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c01038d0:	e8 0c d4 ff ff       	call   c0100ce1 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01038d5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01038dc:	e8 65 0e 00 00       	call   c0104746 <alloc_pages>
c01038e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01038e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01038e8:	75 24                	jne    c010390e <basic_check+0xc4>
c01038ea:	c7 44 24 0c 4c 96 10 	movl   $0xc010964c,0xc(%esp)
c01038f1:	c0 
c01038f2:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c01038f9:	c0 
c01038fa:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0103901:	00 
c0103902:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103909:	e8 d3 d3 ff ff       	call   c0100ce1 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c010390e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103911:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103914:	74 10                	je     c0103926 <basic_check+0xdc>
c0103916:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103919:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010391c:	74 08                	je     c0103926 <basic_check+0xdc>
c010391e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103921:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103924:	75 24                	jne    c010394a <basic_check+0x100>
c0103926:	c7 44 24 0c 68 96 10 	movl   $0xc0109668,0xc(%esp)
c010392d:	c0 
c010392e:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103935:	c0 
c0103936:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c010393d:	00 
c010393e:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103945:	e8 97 d3 ff ff       	call   c0100ce1 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010394a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010394d:	89 04 24             	mov    %eax,(%esp)
c0103950:	e8 d9 f8 ff ff       	call   c010322e <page_ref>
c0103955:	85 c0                	test   %eax,%eax
c0103957:	75 1e                	jne    c0103977 <basic_check+0x12d>
c0103959:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010395c:	89 04 24             	mov    %eax,(%esp)
c010395f:	e8 ca f8 ff ff       	call   c010322e <page_ref>
c0103964:	85 c0                	test   %eax,%eax
c0103966:	75 0f                	jne    c0103977 <basic_check+0x12d>
c0103968:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010396b:	89 04 24             	mov    %eax,(%esp)
c010396e:	e8 bb f8 ff ff       	call   c010322e <page_ref>
c0103973:	85 c0                	test   %eax,%eax
c0103975:	74 24                	je     c010399b <basic_check+0x151>
c0103977:	c7 44 24 0c 8c 96 10 	movl   $0xc010968c,0xc(%esp)
c010397e:	c0 
c010397f:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103986:	c0 
c0103987:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c010398e:	00 
c010398f:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103996:	e8 46 d3 ff ff       	call   c0100ce1 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c010399b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010399e:	89 04 24             	mov    %eax,(%esp)
c01039a1:	e8 72 f8 ff ff       	call   c0103218 <page2pa>
c01039a6:	8b 15 a0 3f 12 c0    	mov    0xc0123fa0,%edx
c01039ac:	c1 e2 0c             	shl    $0xc,%edx
c01039af:	39 d0                	cmp    %edx,%eax
c01039b1:	72 24                	jb     c01039d7 <basic_check+0x18d>
c01039b3:	c7 44 24 0c c8 96 10 	movl   $0xc01096c8,0xc(%esp)
c01039ba:	c0 
c01039bb:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c01039c2:	c0 
c01039c3:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c01039ca:	00 
c01039cb:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c01039d2:	e8 0a d3 ff ff       	call   c0100ce1 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01039d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039da:	89 04 24             	mov    %eax,(%esp)
c01039dd:	e8 36 f8 ff ff       	call   c0103218 <page2pa>
c01039e2:	8b 15 a0 3f 12 c0    	mov    0xc0123fa0,%edx
c01039e8:	c1 e2 0c             	shl    $0xc,%edx
c01039eb:	39 d0                	cmp    %edx,%eax
c01039ed:	72 24                	jb     c0103a13 <basic_check+0x1c9>
c01039ef:	c7 44 24 0c e5 96 10 	movl   $0xc01096e5,0xc(%esp)
c01039f6:	c0 
c01039f7:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c01039fe:	c0 
c01039ff:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0103a06:	00 
c0103a07:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103a0e:	e8 ce d2 ff ff       	call   c0100ce1 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0103a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a16:	89 04 24             	mov    %eax,(%esp)
c0103a19:	e8 fa f7 ff ff       	call   c0103218 <page2pa>
c0103a1e:	8b 15 a0 3f 12 c0    	mov    0xc0123fa0,%edx
c0103a24:	c1 e2 0c             	shl    $0xc,%edx
c0103a27:	39 d0                	cmp    %edx,%eax
c0103a29:	72 24                	jb     c0103a4f <basic_check+0x205>
c0103a2b:	c7 44 24 0c 02 97 10 	movl   $0xc0109702,0xc(%esp)
c0103a32:	c0 
c0103a33:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103a3a:	c0 
c0103a3b:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0103a42:	00 
c0103a43:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103a4a:	e8 92 d2 ff ff       	call   c0100ce1 <__panic>

    list_entry_t free_list_store = free_list;
c0103a4f:	a1 40 40 12 c0       	mov    0xc0124040,%eax
c0103a54:	8b 15 44 40 12 c0    	mov    0xc0124044,%edx
c0103a5a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103a5d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103a60:	c7 45 e0 40 40 12 c0 	movl   $0xc0124040,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103a67:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103a6a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103a6d:	89 50 04             	mov    %edx,0x4(%eax)
c0103a70:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103a73:	8b 50 04             	mov    0x4(%eax),%edx
c0103a76:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103a79:	89 10                	mov    %edx,(%eax)
c0103a7b:	c7 45 dc 40 40 12 c0 	movl   $0xc0124040,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103a82:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103a85:	8b 40 04             	mov    0x4(%eax),%eax
c0103a88:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103a8b:	0f 94 c0             	sete   %al
c0103a8e:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103a91:	85 c0                	test   %eax,%eax
c0103a93:	75 24                	jne    c0103ab9 <basic_check+0x26f>
c0103a95:	c7 44 24 0c 1f 97 10 	movl   $0xc010971f,0xc(%esp)
c0103a9c:	c0 
c0103a9d:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103aa4:	c0 
c0103aa5:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0103aac:	00 
c0103aad:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103ab4:	e8 28 d2 ff ff       	call   c0100ce1 <__panic>

    unsigned int nr_free_store = nr_free;
c0103ab9:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c0103abe:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0103ac1:	c7 05 48 40 12 c0 00 	movl   $0x0,0xc0124048
c0103ac8:	00 00 00 

    assert(alloc_page() == NULL);
c0103acb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ad2:	e8 6f 0c 00 00       	call   c0104746 <alloc_pages>
c0103ad7:	85 c0                	test   %eax,%eax
c0103ad9:	74 24                	je     c0103aff <basic_check+0x2b5>
c0103adb:	c7 44 24 0c 36 97 10 	movl   $0xc0109736,0xc(%esp)
c0103ae2:	c0 
c0103ae3:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103aea:	c0 
c0103aeb:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0103af2:	00 
c0103af3:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103afa:	e8 e2 d1 ff ff       	call   c0100ce1 <__panic>

    free_page(p0);
c0103aff:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103b06:	00 
c0103b07:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103b0a:	89 04 24             	mov    %eax,(%esp)
c0103b0d:	e8 9f 0c 00 00       	call   c01047b1 <free_pages>
    free_page(p1);
c0103b12:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103b19:	00 
c0103b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b1d:	89 04 24             	mov    %eax,(%esp)
c0103b20:	e8 8c 0c 00 00       	call   c01047b1 <free_pages>
    free_page(p2);
c0103b25:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103b2c:	00 
c0103b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b30:	89 04 24             	mov    %eax,(%esp)
c0103b33:	e8 79 0c 00 00       	call   c01047b1 <free_pages>
    assert(nr_free == 3);
c0103b38:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c0103b3d:	83 f8 03             	cmp    $0x3,%eax
c0103b40:	74 24                	je     c0103b66 <basic_check+0x31c>
c0103b42:	c7 44 24 0c 4b 97 10 	movl   $0xc010974b,0xc(%esp)
c0103b49:	c0 
c0103b4a:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103b51:	c0 
c0103b52:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0103b59:	00 
c0103b5a:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103b61:	e8 7b d1 ff ff       	call   c0100ce1 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103b66:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103b6d:	e8 d4 0b 00 00       	call   c0104746 <alloc_pages>
c0103b72:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103b75:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103b79:	75 24                	jne    c0103b9f <basic_check+0x355>
c0103b7b:	c7 44 24 0c 14 96 10 	movl   $0xc0109614,0xc(%esp)
c0103b82:	c0 
c0103b83:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103b8a:	c0 
c0103b8b:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0103b92:	00 
c0103b93:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103b9a:	e8 42 d1 ff ff       	call   c0100ce1 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103b9f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ba6:	e8 9b 0b 00 00       	call   c0104746 <alloc_pages>
c0103bab:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103bae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103bb2:	75 24                	jne    c0103bd8 <basic_check+0x38e>
c0103bb4:	c7 44 24 0c 30 96 10 	movl   $0xc0109630,0xc(%esp)
c0103bbb:	c0 
c0103bbc:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103bc3:	c0 
c0103bc4:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0103bcb:	00 
c0103bcc:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103bd3:	e8 09 d1 ff ff       	call   c0100ce1 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103bd8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103bdf:	e8 62 0b 00 00       	call   c0104746 <alloc_pages>
c0103be4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103be7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103beb:	75 24                	jne    c0103c11 <basic_check+0x3c7>
c0103bed:	c7 44 24 0c 4c 96 10 	movl   $0xc010964c,0xc(%esp)
c0103bf4:	c0 
c0103bf5:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103bfc:	c0 
c0103bfd:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c0103c04:	00 
c0103c05:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103c0c:	e8 d0 d0 ff ff       	call   c0100ce1 <__panic>

    assert(alloc_page() == NULL);
c0103c11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c18:	e8 29 0b 00 00       	call   c0104746 <alloc_pages>
c0103c1d:	85 c0                	test   %eax,%eax
c0103c1f:	74 24                	je     c0103c45 <basic_check+0x3fb>
c0103c21:	c7 44 24 0c 36 97 10 	movl   $0xc0109736,0xc(%esp)
c0103c28:	c0 
c0103c29:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103c30:	c0 
c0103c31:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0103c38:	00 
c0103c39:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103c40:	e8 9c d0 ff ff       	call   c0100ce1 <__panic>

    free_page(p0);
c0103c45:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c4c:	00 
c0103c4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c50:	89 04 24             	mov    %eax,(%esp)
c0103c53:	e8 59 0b 00 00       	call   c01047b1 <free_pages>
c0103c58:	c7 45 d8 40 40 12 c0 	movl   $0xc0124040,-0x28(%ebp)
c0103c5f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103c62:	8b 40 04             	mov    0x4(%eax),%eax
c0103c65:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0103c68:	0f 94 c0             	sete   %al
c0103c6b:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103c6e:	85 c0                	test   %eax,%eax
c0103c70:	74 24                	je     c0103c96 <basic_check+0x44c>
c0103c72:	c7 44 24 0c 58 97 10 	movl   $0xc0109758,0xc(%esp)
c0103c79:	c0 
c0103c7a:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103c81:	c0 
c0103c82:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0103c89:	00 
c0103c8a:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103c91:	e8 4b d0 ff ff       	call   c0100ce1 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103c96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c9d:	e8 a4 0a 00 00       	call   c0104746 <alloc_pages>
c0103ca2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103ca5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ca8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103cab:	74 24                	je     c0103cd1 <basic_check+0x487>
c0103cad:	c7 44 24 0c 70 97 10 	movl   $0xc0109770,0xc(%esp)
c0103cb4:	c0 
c0103cb5:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103cbc:	c0 
c0103cbd:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0103cc4:	00 
c0103cc5:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103ccc:	e8 10 d0 ff ff       	call   c0100ce1 <__panic>
    assert(alloc_page() == NULL);
c0103cd1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103cd8:	e8 69 0a 00 00       	call   c0104746 <alloc_pages>
c0103cdd:	85 c0                	test   %eax,%eax
c0103cdf:	74 24                	je     c0103d05 <basic_check+0x4bb>
c0103ce1:	c7 44 24 0c 36 97 10 	movl   $0xc0109736,0xc(%esp)
c0103ce8:	c0 
c0103ce9:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103cf0:	c0 
c0103cf1:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0103cf8:	00 
c0103cf9:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103d00:	e8 dc cf ff ff       	call   c0100ce1 <__panic>

    assert(nr_free == 0);
c0103d05:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c0103d0a:	85 c0                	test   %eax,%eax
c0103d0c:	74 24                	je     c0103d32 <basic_check+0x4e8>
c0103d0e:	c7 44 24 0c 89 97 10 	movl   $0xc0109789,0xc(%esp)
c0103d15:	c0 
c0103d16:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103d1d:	c0 
c0103d1e:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0103d25:	00 
c0103d26:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103d2d:	e8 af cf ff ff       	call   c0100ce1 <__panic>
    free_list = free_list_store;
c0103d32:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103d35:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103d38:	a3 40 40 12 c0       	mov    %eax,0xc0124040
c0103d3d:	89 15 44 40 12 c0    	mov    %edx,0xc0124044
    nr_free = nr_free_store;
c0103d43:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103d46:	a3 48 40 12 c0       	mov    %eax,0xc0124048

    free_page(p);
c0103d4b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d52:	00 
c0103d53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d56:	89 04 24             	mov    %eax,(%esp)
c0103d59:	e8 53 0a 00 00       	call   c01047b1 <free_pages>
    free_page(p1);
c0103d5e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d65:	00 
c0103d66:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d69:	89 04 24             	mov    %eax,(%esp)
c0103d6c:	e8 40 0a 00 00       	call   c01047b1 <free_pages>
    free_page(p2);
c0103d71:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103d78:	00 
c0103d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d7c:	89 04 24             	mov    %eax,(%esp)
c0103d7f:	e8 2d 0a 00 00       	call   c01047b1 <free_pages>
}
c0103d84:	c9                   	leave  
c0103d85:	c3                   	ret    

c0103d86 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103d86:	55                   	push   %ebp
c0103d87:	89 e5                	mov    %esp,%ebp
c0103d89:	53                   	push   %ebx
c0103d8a:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c0103d90:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103d97:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103d9e:	c7 45 ec 40 40 12 c0 	movl   $0xc0124040,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103da5:	eb 6b                	jmp    c0103e12 <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0103da7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103daa:	83 e8 0c             	sub    $0xc,%eax
c0103dad:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c0103db0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103db3:	83 c0 04             	add    $0x4,%eax
c0103db6:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0103dbd:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103dc0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103dc3:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103dc6:	0f a3 10             	bt     %edx,(%eax)
c0103dc9:	19 c0                	sbb    %eax,%eax
c0103dcb:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0103dce:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0103dd2:	0f 95 c0             	setne  %al
c0103dd5:	0f b6 c0             	movzbl %al,%eax
c0103dd8:	85 c0                	test   %eax,%eax
c0103dda:	75 24                	jne    c0103e00 <default_check+0x7a>
c0103ddc:	c7 44 24 0c 96 97 10 	movl   $0xc0109796,0xc(%esp)
c0103de3:	c0 
c0103de4:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103deb:	c0 
c0103dec:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0103df3:	00 
c0103df4:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103dfb:	e8 e1 ce ff ff       	call   c0100ce1 <__panic>
        count ++, total += p->property;
c0103e00:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103e04:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e07:	8b 50 08             	mov    0x8(%eax),%edx
c0103e0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e0d:	01 d0                	add    %edx,%eax
c0103e0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103e12:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103e15:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0103e18:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103e1b:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0103e1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103e21:	81 7d ec 40 40 12 c0 	cmpl   $0xc0124040,-0x14(%ebp)
c0103e28:	0f 85 79 ff ff ff    	jne    c0103da7 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0103e2e:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0103e31:	e8 ad 09 00 00       	call   c01047e3 <nr_free_pages>
c0103e36:	39 c3                	cmp    %eax,%ebx
c0103e38:	74 24                	je     c0103e5e <default_check+0xd8>
c0103e3a:	c7 44 24 0c a6 97 10 	movl   $0xc01097a6,0xc(%esp)
c0103e41:	c0 
c0103e42:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103e49:	c0 
c0103e4a:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c0103e51:	00 
c0103e52:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103e59:	e8 83 ce ff ff       	call   c0100ce1 <__panic>

    basic_check();
c0103e5e:	e8 e7 f9 ff ff       	call   c010384a <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0103e63:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103e6a:	e8 d7 08 00 00       	call   c0104746 <alloc_pages>
c0103e6f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c0103e72:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103e76:	75 24                	jne    c0103e9c <default_check+0x116>
c0103e78:	c7 44 24 0c bf 97 10 	movl   $0xc01097bf,0xc(%esp)
c0103e7f:	c0 
c0103e80:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103e87:	c0 
c0103e88:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0103e8f:	00 
c0103e90:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103e97:	e8 45 ce ff ff       	call   c0100ce1 <__panic>
    assert(!PageProperty(p0));
c0103e9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e9f:	83 c0 04             	add    $0x4,%eax
c0103ea2:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0103ea9:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103eac:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103eaf:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103eb2:	0f a3 10             	bt     %edx,(%eax)
c0103eb5:	19 c0                	sbb    %eax,%eax
c0103eb7:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0103eba:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0103ebe:	0f 95 c0             	setne  %al
c0103ec1:	0f b6 c0             	movzbl %al,%eax
c0103ec4:	85 c0                	test   %eax,%eax
c0103ec6:	74 24                	je     c0103eec <default_check+0x166>
c0103ec8:	c7 44 24 0c ca 97 10 	movl   $0xc01097ca,0xc(%esp)
c0103ecf:	c0 
c0103ed0:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103ed7:	c0 
c0103ed8:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0103edf:	00 
c0103ee0:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103ee7:	e8 f5 cd ff ff       	call   c0100ce1 <__panic>

    list_entry_t free_list_store = free_list;
c0103eec:	a1 40 40 12 c0       	mov    0xc0124040,%eax
c0103ef1:	8b 15 44 40 12 c0    	mov    0xc0124044,%edx
c0103ef7:	89 45 80             	mov    %eax,-0x80(%ebp)
c0103efa:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0103efd:	c7 45 b4 40 40 12 c0 	movl   $0xc0124040,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103f04:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103f07:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103f0a:	89 50 04             	mov    %edx,0x4(%eax)
c0103f0d:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103f10:	8b 50 04             	mov    0x4(%eax),%edx
c0103f13:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103f16:	89 10                	mov    %edx,(%eax)
c0103f18:	c7 45 b0 40 40 12 c0 	movl   $0xc0124040,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0103f1f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103f22:	8b 40 04             	mov    0x4(%eax),%eax
c0103f25:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c0103f28:	0f 94 c0             	sete   %al
c0103f2b:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103f2e:	85 c0                	test   %eax,%eax
c0103f30:	75 24                	jne    c0103f56 <default_check+0x1d0>
c0103f32:	c7 44 24 0c 1f 97 10 	movl   $0xc010971f,0xc(%esp)
c0103f39:	c0 
c0103f3a:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103f41:	c0 
c0103f42:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0103f49:	00 
c0103f4a:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103f51:	e8 8b cd ff ff       	call   c0100ce1 <__panic>
    assert(alloc_page() == NULL);
c0103f56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f5d:	e8 e4 07 00 00       	call   c0104746 <alloc_pages>
c0103f62:	85 c0                	test   %eax,%eax
c0103f64:	74 24                	je     c0103f8a <default_check+0x204>
c0103f66:	c7 44 24 0c 36 97 10 	movl   $0xc0109736,0xc(%esp)
c0103f6d:	c0 
c0103f6e:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103f75:	c0 
c0103f76:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0103f7d:	00 
c0103f7e:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103f85:	e8 57 cd ff ff       	call   c0100ce1 <__panic>

    unsigned int nr_free_store = nr_free;
c0103f8a:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c0103f8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0103f92:	c7 05 48 40 12 c0 00 	movl   $0x0,0xc0124048
c0103f99:	00 00 00 

    free_pages(p0 + 2, 3);
c0103f9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103f9f:	83 c0 40             	add    $0x40,%eax
c0103fa2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0103fa9:	00 
c0103faa:	89 04 24             	mov    %eax,(%esp)
c0103fad:	e8 ff 07 00 00       	call   c01047b1 <free_pages>
    assert(alloc_pages(4) == NULL);
c0103fb2:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0103fb9:	e8 88 07 00 00       	call   c0104746 <alloc_pages>
c0103fbe:	85 c0                	test   %eax,%eax
c0103fc0:	74 24                	je     c0103fe6 <default_check+0x260>
c0103fc2:	c7 44 24 0c dc 97 10 	movl   $0xc01097dc,0xc(%esp)
c0103fc9:	c0 
c0103fca:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0103fd1:	c0 
c0103fd2:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0103fd9:	00 
c0103fda:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0103fe1:	e8 fb cc ff ff       	call   c0100ce1 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0103fe6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103fe9:	83 c0 40             	add    $0x40,%eax
c0103fec:	83 c0 04             	add    $0x4,%eax
c0103fef:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0103ff6:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103ff9:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103ffc:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103fff:	0f a3 10             	bt     %edx,(%eax)
c0104002:	19 c0                	sbb    %eax,%eax
c0104004:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0104007:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c010400b:	0f 95 c0             	setne  %al
c010400e:	0f b6 c0             	movzbl %al,%eax
c0104011:	85 c0                	test   %eax,%eax
c0104013:	74 0e                	je     c0104023 <default_check+0x29d>
c0104015:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104018:	83 c0 40             	add    $0x40,%eax
c010401b:	8b 40 08             	mov    0x8(%eax),%eax
c010401e:	83 f8 03             	cmp    $0x3,%eax
c0104021:	74 24                	je     c0104047 <default_check+0x2c1>
c0104023:	c7 44 24 0c f4 97 10 	movl   $0xc01097f4,0xc(%esp)
c010402a:	c0 
c010402b:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0104032:	c0 
c0104033:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c010403a:	00 
c010403b:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0104042:	e8 9a cc ff ff       	call   c0100ce1 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0104047:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c010404e:	e8 f3 06 00 00       	call   c0104746 <alloc_pages>
c0104053:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104056:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010405a:	75 24                	jne    c0104080 <default_check+0x2fa>
c010405c:	c7 44 24 0c 20 98 10 	movl   $0xc0109820,0xc(%esp)
c0104063:	c0 
c0104064:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c010406b:	c0 
c010406c:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0104073:	00 
c0104074:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c010407b:	e8 61 cc ff ff       	call   c0100ce1 <__panic>
    assert(alloc_page() == NULL);
c0104080:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104087:	e8 ba 06 00 00       	call   c0104746 <alloc_pages>
c010408c:	85 c0                	test   %eax,%eax
c010408e:	74 24                	je     c01040b4 <default_check+0x32e>
c0104090:	c7 44 24 0c 36 97 10 	movl   $0xc0109736,0xc(%esp)
c0104097:	c0 
c0104098:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c010409f:	c0 
c01040a0:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c01040a7:	00 
c01040a8:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c01040af:	e8 2d cc ff ff       	call   c0100ce1 <__panic>
    assert(p0 + 2 == p1);
c01040b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01040b7:	83 c0 40             	add    $0x40,%eax
c01040ba:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01040bd:	74 24                	je     c01040e3 <default_check+0x35d>
c01040bf:	c7 44 24 0c 3e 98 10 	movl   $0xc010983e,0xc(%esp)
c01040c6:	c0 
c01040c7:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c01040ce:	c0 
c01040cf:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c01040d6:	00 
c01040d7:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c01040de:	e8 fe cb ff ff       	call   c0100ce1 <__panic>

    p2 = p0 + 1;
c01040e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01040e6:	83 c0 20             	add    $0x20,%eax
c01040e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c01040ec:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01040f3:	00 
c01040f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01040f7:	89 04 24             	mov    %eax,(%esp)
c01040fa:	e8 b2 06 00 00       	call   c01047b1 <free_pages>
    free_pages(p1, 3);
c01040ff:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0104106:	00 
c0104107:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010410a:	89 04 24             	mov    %eax,(%esp)
c010410d:	e8 9f 06 00 00       	call   c01047b1 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0104112:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104115:	83 c0 04             	add    $0x4,%eax
c0104118:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c010411f:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104122:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104125:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104128:	0f a3 10             	bt     %edx,(%eax)
c010412b:	19 c0                	sbb    %eax,%eax
c010412d:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0104130:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0104134:	0f 95 c0             	setne  %al
c0104137:	0f b6 c0             	movzbl %al,%eax
c010413a:	85 c0                	test   %eax,%eax
c010413c:	74 0b                	je     c0104149 <default_check+0x3c3>
c010413e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104141:	8b 40 08             	mov    0x8(%eax),%eax
c0104144:	83 f8 01             	cmp    $0x1,%eax
c0104147:	74 24                	je     c010416d <default_check+0x3e7>
c0104149:	c7 44 24 0c 4c 98 10 	movl   $0xc010984c,0xc(%esp)
c0104150:	c0 
c0104151:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0104158:	c0 
c0104159:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c0104160:	00 
c0104161:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0104168:	e8 74 cb ff ff       	call   c0100ce1 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c010416d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104170:	83 c0 04             	add    $0x4,%eax
c0104173:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c010417a:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010417d:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104180:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104183:	0f a3 10             	bt     %edx,(%eax)
c0104186:	19 c0                	sbb    %eax,%eax
c0104188:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c010418b:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c010418f:	0f 95 c0             	setne  %al
c0104192:	0f b6 c0             	movzbl %al,%eax
c0104195:	85 c0                	test   %eax,%eax
c0104197:	74 0b                	je     c01041a4 <default_check+0x41e>
c0104199:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010419c:	8b 40 08             	mov    0x8(%eax),%eax
c010419f:	83 f8 03             	cmp    $0x3,%eax
c01041a2:	74 24                	je     c01041c8 <default_check+0x442>
c01041a4:	c7 44 24 0c 74 98 10 	movl   $0xc0109874,0xc(%esp)
c01041ab:	c0 
c01041ac:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c01041b3:	c0 
c01041b4:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c01041bb:	00 
c01041bc:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c01041c3:	e8 19 cb ff ff       	call   c0100ce1 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c01041c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01041cf:	e8 72 05 00 00       	call   c0104746 <alloc_pages>
c01041d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01041d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01041da:	83 e8 20             	sub    $0x20,%eax
c01041dd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01041e0:	74 24                	je     c0104206 <default_check+0x480>
c01041e2:	c7 44 24 0c 9a 98 10 	movl   $0xc010989a,0xc(%esp)
c01041e9:	c0 
c01041ea:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c01041f1:	c0 
c01041f2:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c01041f9:	00 
c01041fa:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0104201:	e8 db ca ff ff       	call   c0100ce1 <__panic>
    free_page(p0);
c0104206:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010420d:	00 
c010420e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104211:	89 04 24             	mov    %eax,(%esp)
c0104214:	e8 98 05 00 00       	call   c01047b1 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0104219:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0104220:	e8 21 05 00 00       	call   c0104746 <alloc_pages>
c0104225:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104228:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010422b:	83 c0 20             	add    $0x20,%eax
c010422e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0104231:	74 24                	je     c0104257 <default_check+0x4d1>
c0104233:	c7 44 24 0c b8 98 10 	movl   $0xc01098b8,0xc(%esp)
c010423a:	c0 
c010423b:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0104242:	c0 
c0104243:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c010424a:	00 
c010424b:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0104252:	e8 8a ca ff ff       	call   c0100ce1 <__panic>

    free_pages(p0, 2);
c0104257:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c010425e:	00 
c010425f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104262:	89 04 24             	mov    %eax,(%esp)
c0104265:	e8 47 05 00 00       	call   c01047b1 <free_pages>
    free_page(p2);
c010426a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104271:	00 
c0104272:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104275:	89 04 24             	mov    %eax,(%esp)
c0104278:	e8 34 05 00 00       	call   c01047b1 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c010427d:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0104284:	e8 bd 04 00 00       	call   c0104746 <alloc_pages>
c0104289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010428c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104290:	75 24                	jne    c01042b6 <default_check+0x530>
c0104292:	c7 44 24 0c d8 98 10 	movl   $0xc01098d8,0xc(%esp)
c0104299:	c0 
c010429a:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c01042a1:	c0 
c01042a2:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c01042a9:	00 
c01042aa:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c01042b1:	e8 2b ca ff ff       	call   c0100ce1 <__panic>
    assert(alloc_page() == NULL);
c01042b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01042bd:	e8 84 04 00 00       	call   c0104746 <alloc_pages>
c01042c2:	85 c0                	test   %eax,%eax
c01042c4:	74 24                	je     c01042ea <default_check+0x564>
c01042c6:	c7 44 24 0c 36 97 10 	movl   $0xc0109736,0xc(%esp)
c01042cd:	c0 
c01042ce:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c01042d5:	c0 
c01042d6:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c01042dd:	00 
c01042de:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c01042e5:	e8 f7 c9 ff ff       	call   c0100ce1 <__panic>

    assert(nr_free == 0);
c01042ea:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c01042ef:	85 c0                	test   %eax,%eax
c01042f1:	74 24                	je     c0104317 <default_check+0x591>
c01042f3:	c7 44 24 0c 89 97 10 	movl   $0xc0109789,0xc(%esp)
c01042fa:	c0 
c01042fb:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0104302:	c0 
c0104303:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c010430a:	00 
c010430b:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c0104312:	e8 ca c9 ff ff       	call   c0100ce1 <__panic>
    nr_free = nr_free_store;
c0104317:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010431a:	a3 48 40 12 c0       	mov    %eax,0xc0124048

    free_list = free_list_store;
c010431f:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104322:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104325:	a3 40 40 12 c0       	mov    %eax,0xc0124040
c010432a:	89 15 44 40 12 c0    	mov    %edx,0xc0124044
    free_pages(p0, 5);
c0104330:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0104337:	00 
c0104338:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010433b:	89 04 24             	mov    %eax,(%esp)
c010433e:	e8 6e 04 00 00       	call   c01047b1 <free_pages>

    le = &free_list;
c0104343:	c7 45 ec 40 40 12 c0 	movl   $0xc0124040,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010434a:	eb 1d                	jmp    c0104369 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c010434c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010434f:	83 e8 0c             	sub    $0xc,%eax
c0104352:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c0104355:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104359:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010435c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010435f:	8b 40 08             	mov    0x8(%eax),%eax
c0104362:	29 c2                	sub    %eax,%edx
c0104364:	89 d0                	mov    %edx,%eax
c0104366:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104369:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010436c:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010436f:	8b 45 88             	mov    -0x78(%ebp),%eax
c0104372:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104375:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104378:	81 7d ec 40 40 12 c0 	cmpl   $0xc0124040,-0x14(%ebp)
c010437f:	75 cb                	jne    c010434c <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0104381:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104385:	74 24                	je     c01043ab <default_check+0x625>
c0104387:	c7 44 24 0c f6 98 10 	movl   $0xc01098f6,0xc(%esp)
c010438e:	c0 
c010438f:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c0104396:	c0 
c0104397:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c010439e:	00 
c010439f:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c01043a6:	e8 36 c9 ff ff       	call   c0100ce1 <__panic>
    assert(total == 0);
c01043ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01043af:	74 24                	je     c01043d5 <default_check+0x64f>
c01043b1:	c7 44 24 0c 01 99 10 	movl   $0xc0109901,0xc(%esp)
c01043b8:	c0 
c01043b9:	c7 44 24 08 96 95 10 	movl   $0xc0109596,0x8(%esp)
c01043c0:	c0 
c01043c1:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c01043c8:	00 
c01043c9:	c7 04 24 ab 95 10 c0 	movl   $0xc01095ab,(%esp)
c01043d0:	e8 0c c9 ff ff       	call   c0100ce1 <__panic>
}
c01043d5:	81 c4 94 00 00 00    	add    $0x94,%esp
c01043db:	5b                   	pop    %ebx
c01043dc:	5d                   	pop    %ebp
c01043dd:	c3                   	ret    

c01043de <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01043de:	55                   	push   %ebp
c01043df:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01043e1:	8b 55 08             	mov    0x8(%ebp),%edx
c01043e4:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c01043e9:	29 c2                	sub    %eax,%edx
c01043eb:	89 d0                	mov    %edx,%eax
c01043ed:	c1 f8 05             	sar    $0x5,%eax
}
c01043f0:	5d                   	pop    %ebp
c01043f1:	c3                   	ret    

c01043f2 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01043f2:	55                   	push   %ebp
c01043f3:	89 e5                	mov    %esp,%ebp
c01043f5:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01043f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01043fb:	89 04 24             	mov    %eax,(%esp)
c01043fe:	e8 db ff ff ff       	call   c01043de <page2ppn>
c0104403:	c1 e0 0c             	shl    $0xc,%eax
}
c0104406:	c9                   	leave  
c0104407:	c3                   	ret    

c0104408 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0104408:	55                   	push   %ebp
c0104409:	89 e5                	mov    %esp,%ebp
c010440b:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010440e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104411:	c1 e8 0c             	shr    $0xc,%eax
c0104414:	89 c2                	mov    %eax,%edx
c0104416:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c010441b:	39 c2                	cmp    %eax,%edx
c010441d:	72 1c                	jb     c010443b <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010441f:	c7 44 24 08 3c 99 10 	movl   $0xc010993c,0x8(%esp)
c0104426:	c0 
c0104427:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c010442e:	00 
c010442f:	c7 04 24 5b 99 10 c0 	movl   $0xc010995b,(%esp)
c0104436:	e8 a6 c8 ff ff       	call   c0100ce1 <__panic>
    }
    return &pages[PPN(pa)];
c010443b:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c0104440:	8b 55 08             	mov    0x8(%ebp),%edx
c0104443:	c1 ea 0c             	shr    $0xc,%edx
c0104446:	c1 e2 05             	shl    $0x5,%edx
c0104449:	01 d0                	add    %edx,%eax
}
c010444b:	c9                   	leave  
c010444c:	c3                   	ret    

c010444d <page2kva>:

static inline void *
page2kva(struct Page *page) {
c010444d:	55                   	push   %ebp
c010444e:	89 e5                	mov    %esp,%ebp
c0104450:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0104453:	8b 45 08             	mov    0x8(%ebp),%eax
c0104456:	89 04 24             	mov    %eax,(%esp)
c0104459:	e8 94 ff ff ff       	call   c01043f2 <page2pa>
c010445e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104461:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104464:	c1 e8 0c             	shr    $0xc,%eax
c0104467:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010446a:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c010446f:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104472:	72 23                	jb     c0104497 <page2kva+0x4a>
c0104474:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104477:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010447b:	c7 44 24 08 6c 99 10 	movl   $0xc010996c,0x8(%esp)
c0104482:	c0 
c0104483:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c010448a:	00 
c010448b:	c7 04 24 5b 99 10 c0 	movl   $0xc010995b,(%esp)
c0104492:	e8 4a c8 ff ff       	call   c0100ce1 <__panic>
c0104497:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010449a:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010449f:	c9                   	leave  
c01044a0:	c3                   	ret    

c01044a1 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01044a1:	55                   	push   %ebp
c01044a2:	89 e5                	mov    %esp,%ebp
c01044a4:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01044a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01044aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01044ad:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01044b4:	77 23                	ja     c01044d9 <kva2page+0x38>
c01044b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01044bd:	c7 44 24 08 90 99 10 	movl   $0xc0109990,0x8(%esp)
c01044c4:	c0 
c01044c5:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c01044cc:	00 
c01044cd:	c7 04 24 5b 99 10 c0 	movl   $0xc010995b,(%esp)
c01044d4:	e8 08 c8 ff ff       	call   c0100ce1 <__panic>
c01044d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044dc:	05 00 00 00 40       	add    $0x40000000,%eax
c01044e1:	89 04 24             	mov    %eax,(%esp)
c01044e4:	e8 1f ff ff ff       	call   c0104408 <pa2page>
}
c01044e9:	c9                   	leave  
c01044ea:	c3                   	ret    

c01044eb <pte2page>:

static inline struct Page *
pte2page(pte_t pte) {
c01044eb:	55                   	push   %ebp
c01044ec:	89 e5                	mov    %esp,%ebp
c01044ee:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01044f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01044f4:	83 e0 01             	and    $0x1,%eax
c01044f7:	85 c0                	test   %eax,%eax
c01044f9:	75 1c                	jne    c0104517 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01044fb:	c7 44 24 08 b4 99 10 	movl   $0xc01099b4,0x8(%esp)
c0104502:	c0 
c0104503:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010450a:	00 
c010450b:	c7 04 24 5b 99 10 c0 	movl   $0xc010995b,(%esp)
c0104512:	e8 ca c7 ff ff       	call   c0100ce1 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0104517:	8b 45 08             	mov    0x8(%ebp),%eax
c010451a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010451f:	89 04 24             	mov    %eax,(%esp)
c0104522:	e8 e1 fe ff ff       	call   c0104408 <pa2page>
}
c0104527:	c9                   	leave  
c0104528:	c3                   	ret    

c0104529 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0104529:	55                   	push   %ebp
c010452a:	89 e5                	mov    %esp,%ebp
c010452c:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c010452f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104532:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104537:	89 04 24             	mov    %eax,(%esp)
c010453a:	e8 c9 fe ff ff       	call   c0104408 <pa2page>
}
c010453f:	c9                   	leave  
c0104540:	c3                   	ret    

c0104541 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0104541:	55                   	push   %ebp
c0104542:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104544:	8b 45 08             	mov    0x8(%ebp),%eax
c0104547:	8b 00                	mov    (%eax),%eax
}
c0104549:	5d                   	pop    %ebp
c010454a:	c3                   	ret    

c010454b <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c010454b:	55                   	push   %ebp
c010454c:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010454e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104551:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104554:	89 10                	mov    %edx,(%eax)
}
c0104556:	5d                   	pop    %ebp
c0104557:	c3                   	ret    

c0104558 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0104558:	55                   	push   %ebp
c0104559:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c010455b:	8b 45 08             	mov    0x8(%ebp),%eax
c010455e:	8b 00                	mov    (%eax),%eax
c0104560:	8d 50 01             	lea    0x1(%eax),%edx
c0104563:	8b 45 08             	mov    0x8(%ebp),%eax
c0104566:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0104568:	8b 45 08             	mov    0x8(%ebp),%eax
c010456b:	8b 00                	mov    (%eax),%eax
}
c010456d:	5d                   	pop    %ebp
c010456e:	c3                   	ret    

c010456f <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c010456f:	55                   	push   %ebp
c0104570:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0104572:	8b 45 08             	mov    0x8(%ebp),%eax
c0104575:	8b 00                	mov    (%eax),%eax
c0104577:	8d 50 ff             	lea    -0x1(%eax),%edx
c010457a:	8b 45 08             	mov    0x8(%ebp),%eax
c010457d:	89 10                	mov    %edx,(%eax)
    return page->ref;
c010457f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104582:	8b 00                	mov    (%eax),%eax
}
c0104584:	5d                   	pop    %ebp
c0104585:	c3                   	ret    

c0104586 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0104586:	55                   	push   %ebp
c0104587:	89 e5                	mov    %esp,%ebp
c0104589:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010458c:	9c                   	pushf  
c010458d:	58                   	pop    %eax
c010458e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0104591:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0104594:	25 00 02 00 00       	and    $0x200,%eax
c0104599:	85 c0                	test   %eax,%eax
c010459b:	74 0c                	je     c01045a9 <__intr_save+0x23>
        intr_disable();
c010459d:	e8 a8 d9 ff ff       	call   c0101f4a <intr_disable>
        return 1;
c01045a2:	b8 01 00 00 00       	mov    $0x1,%eax
c01045a7:	eb 05                	jmp    c01045ae <__intr_save+0x28>
    }
    return 0;
c01045a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01045ae:	c9                   	leave  
c01045af:	c3                   	ret    

c01045b0 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01045b0:	55                   	push   %ebp
c01045b1:	89 e5                	mov    %esp,%ebp
c01045b3:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01045b6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01045ba:	74 05                	je     c01045c1 <__intr_restore+0x11>
        intr_enable();
c01045bc:	e8 83 d9 ff ff       	call   c0101f44 <intr_enable>
    }
}
c01045c1:	c9                   	leave  
c01045c2:	c3                   	ret    

c01045c3 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01045c3:	55                   	push   %ebp
c01045c4:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01045c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01045c9:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01045cc:	b8 23 00 00 00       	mov    $0x23,%eax
c01045d1:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01045d3:	b8 23 00 00 00       	mov    $0x23,%eax
c01045d8:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c01045da:	b8 10 00 00 00       	mov    $0x10,%eax
c01045df:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c01045e1:	b8 10 00 00 00       	mov    $0x10,%eax
c01045e6:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c01045e8:	b8 10 00 00 00       	mov    $0x10,%eax
c01045ed:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c01045ef:	ea f6 45 10 c0 08 00 	ljmp   $0x8,$0xc01045f6
}
c01045f6:	5d                   	pop    %ebp
c01045f7:	c3                   	ret    

c01045f8 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c01045f8:	55                   	push   %ebp
c01045f9:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c01045fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01045fe:	a3 c4 3f 12 c0       	mov    %eax,0xc0123fc4
}
c0104603:	5d                   	pop    %ebp
c0104604:	c3                   	ret    

c0104605 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0104605:	55                   	push   %ebp
c0104606:	89 e5                	mov    %esp,%ebp
c0104608:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c010460b:	b8 00 00 12 c0       	mov    $0xc0120000,%eax
c0104610:	89 04 24             	mov    %eax,(%esp)
c0104613:	e8 e0 ff ff ff       	call   c01045f8 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0104618:	66 c7 05 c8 3f 12 c0 	movw   $0x10,0xc0123fc8
c010461f:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0104621:	66 c7 05 28 0a 12 c0 	movw   $0x68,0xc0120a28
c0104628:	68 00 
c010462a:	b8 c0 3f 12 c0       	mov    $0xc0123fc0,%eax
c010462f:	66 a3 2a 0a 12 c0    	mov    %ax,0xc0120a2a
c0104635:	b8 c0 3f 12 c0       	mov    $0xc0123fc0,%eax
c010463a:	c1 e8 10             	shr    $0x10,%eax
c010463d:	a2 2c 0a 12 c0       	mov    %al,0xc0120a2c
c0104642:	0f b6 05 2d 0a 12 c0 	movzbl 0xc0120a2d,%eax
c0104649:	83 e0 f0             	and    $0xfffffff0,%eax
c010464c:	83 c8 09             	or     $0x9,%eax
c010464f:	a2 2d 0a 12 c0       	mov    %al,0xc0120a2d
c0104654:	0f b6 05 2d 0a 12 c0 	movzbl 0xc0120a2d,%eax
c010465b:	83 e0 ef             	and    $0xffffffef,%eax
c010465e:	a2 2d 0a 12 c0       	mov    %al,0xc0120a2d
c0104663:	0f b6 05 2d 0a 12 c0 	movzbl 0xc0120a2d,%eax
c010466a:	83 e0 9f             	and    $0xffffff9f,%eax
c010466d:	a2 2d 0a 12 c0       	mov    %al,0xc0120a2d
c0104672:	0f b6 05 2d 0a 12 c0 	movzbl 0xc0120a2d,%eax
c0104679:	83 c8 80             	or     $0xffffff80,%eax
c010467c:	a2 2d 0a 12 c0       	mov    %al,0xc0120a2d
c0104681:	0f b6 05 2e 0a 12 c0 	movzbl 0xc0120a2e,%eax
c0104688:	83 e0 f0             	and    $0xfffffff0,%eax
c010468b:	a2 2e 0a 12 c0       	mov    %al,0xc0120a2e
c0104690:	0f b6 05 2e 0a 12 c0 	movzbl 0xc0120a2e,%eax
c0104697:	83 e0 ef             	and    $0xffffffef,%eax
c010469a:	a2 2e 0a 12 c0       	mov    %al,0xc0120a2e
c010469f:	0f b6 05 2e 0a 12 c0 	movzbl 0xc0120a2e,%eax
c01046a6:	83 e0 df             	and    $0xffffffdf,%eax
c01046a9:	a2 2e 0a 12 c0       	mov    %al,0xc0120a2e
c01046ae:	0f b6 05 2e 0a 12 c0 	movzbl 0xc0120a2e,%eax
c01046b5:	83 c8 40             	or     $0x40,%eax
c01046b8:	a2 2e 0a 12 c0       	mov    %al,0xc0120a2e
c01046bd:	0f b6 05 2e 0a 12 c0 	movzbl 0xc0120a2e,%eax
c01046c4:	83 e0 7f             	and    $0x7f,%eax
c01046c7:	a2 2e 0a 12 c0       	mov    %al,0xc0120a2e
c01046cc:	b8 c0 3f 12 c0       	mov    $0xc0123fc0,%eax
c01046d1:	c1 e8 18             	shr    $0x18,%eax
c01046d4:	a2 2f 0a 12 c0       	mov    %al,0xc0120a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c01046d9:	c7 04 24 30 0a 12 c0 	movl   $0xc0120a30,(%esp)
c01046e0:	e8 de fe ff ff       	call   c01045c3 <lgdt>
c01046e5:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c01046eb:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01046ef:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c01046f2:	c9                   	leave  
c01046f3:	c3                   	ret    

c01046f4 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c01046f4:	55                   	push   %ebp
c01046f5:	89 e5                	mov    %esp,%ebp
c01046f7:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c01046fa:	c7 05 4c 40 12 c0 20 	movl   $0xc0109920,0xc012404c
c0104701:	99 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0104704:	a1 4c 40 12 c0       	mov    0xc012404c,%eax
c0104709:	8b 00                	mov    (%eax),%eax
c010470b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010470f:	c7 04 24 e0 99 10 c0 	movl   $0xc01099e0,(%esp)
c0104716:	e8 3c bc ff ff       	call   c0100357 <cprintf>
    pmm_manager->init();
c010471b:	a1 4c 40 12 c0       	mov    0xc012404c,%eax
c0104720:	8b 40 04             	mov    0x4(%eax),%eax
c0104723:	ff d0                	call   *%eax
}
c0104725:	c9                   	leave  
c0104726:	c3                   	ret    

c0104727 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0104727:	55                   	push   %ebp
c0104728:	89 e5                	mov    %esp,%ebp
c010472a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c010472d:	a1 4c 40 12 c0       	mov    0xc012404c,%eax
c0104732:	8b 40 08             	mov    0x8(%eax),%eax
c0104735:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104738:	89 54 24 04          	mov    %edx,0x4(%esp)
c010473c:	8b 55 08             	mov    0x8(%ebp),%edx
c010473f:	89 14 24             	mov    %edx,(%esp)
c0104742:	ff d0                	call   *%eax
}
c0104744:	c9                   	leave  
c0104745:	c3                   	ret    

c0104746 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0104746:	55                   	push   %ebp
c0104747:	89 e5                	mov    %esp,%ebp
c0104749:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c010474c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c0104753:	e8 2e fe ff ff       	call   c0104586 <__intr_save>
c0104758:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c010475b:	a1 4c 40 12 c0       	mov    0xc012404c,%eax
c0104760:	8b 40 0c             	mov    0xc(%eax),%eax
c0104763:	8b 55 08             	mov    0x8(%ebp),%edx
c0104766:	89 14 24             	mov    %edx,(%esp)
c0104769:	ff d0                	call   *%eax
c010476b:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c010476e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104771:	89 04 24             	mov    %eax,(%esp)
c0104774:	e8 37 fe ff ff       	call   c01045b0 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0104779:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010477d:	75 2d                	jne    c01047ac <alloc_pages+0x66>
c010477f:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c0104783:	77 27                	ja     c01047ac <alloc_pages+0x66>
c0104785:	a1 2c 40 12 c0       	mov    0xc012402c,%eax
c010478a:	85 c0                	test   %eax,%eax
c010478c:	74 1e                	je     c01047ac <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c010478e:	8b 55 08             	mov    0x8(%ebp),%edx
c0104791:	a1 2c 41 12 c0       	mov    0xc012412c,%eax
c0104796:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010479d:	00 
c010479e:	89 54 24 04          	mov    %edx,0x4(%esp)
c01047a2:	89 04 24             	mov    %eax,(%esp)
c01047a5:	e8 0f 1a 00 00       	call   c01061b9 <swap_out>
    }
c01047aa:	eb a7                	jmp    c0104753 <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01047ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01047af:	c9                   	leave  
c01047b0:	c3                   	ret    

c01047b1 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01047b1:	55                   	push   %ebp
c01047b2:	89 e5                	mov    %esp,%ebp
c01047b4:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01047b7:	e8 ca fd ff ff       	call   c0104586 <__intr_save>
c01047bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01047bf:	a1 4c 40 12 c0       	mov    0xc012404c,%eax
c01047c4:	8b 40 10             	mov    0x10(%eax),%eax
c01047c7:	8b 55 0c             	mov    0xc(%ebp),%edx
c01047ca:	89 54 24 04          	mov    %edx,0x4(%esp)
c01047ce:	8b 55 08             	mov    0x8(%ebp),%edx
c01047d1:	89 14 24             	mov    %edx,(%esp)
c01047d4:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c01047d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047d9:	89 04 24             	mov    %eax,(%esp)
c01047dc:	e8 cf fd ff ff       	call   c01045b0 <__intr_restore>
}
c01047e1:	c9                   	leave  
c01047e2:	c3                   	ret    

c01047e3 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c01047e3:	55                   	push   %ebp
c01047e4:	89 e5                	mov    %esp,%ebp
c01047e6:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01047e9:	e8 98 fd ff ff       	call   c0104586 <__intr_save>
c01047ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01047f1:	a1 4c 40 12 c0       	mov    0xc012404c,%eax
c01047f6:	8b 40 14             	mov    0x14(%eax),%eax
c01047f9:	ff d0                	call   *%eax
c01047fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01047fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104801:	89 04 24             	mov    %eax,(%esp)
c0104804:	e8 a7 fd ff ff       	call   c01045b0 <__intr_restore>
    return ret;
c0104809:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010480c:	c9                   	leave  
c010480d:	c3                   	ret    

c010480e <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c010480e:	55                   	push   %ebp
c010480f:	89 e5                	mov    %esp,%ebp
c0104811:	57                   	push   %edi
c0104812:	56                   	push   %esi
c0104813:	53                   	push   %ebx
c0104814:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c010481a:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0104821:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0104828:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c010482f:	c7 04 24 f7 99 10 c0 	movl   $0xc01099f7,(%esp)
c0104836:	e8 1c bb ff ff       	call   c0100357 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c010483b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104842:	e9 15 01 00 00       	jmp    c010495c <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104847:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010484a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010484d:	89 d0                	mov    %edx,%eax
c010484f:	c1 e0 02             	shl    $0x2,%eax
c0104852:	01 d0                	add    %edx,%eax
c0104854:	c1 e0 02             	shl    $0x2,%eax
c0104857:	01 c8                	add    %ecx,%eax
c0104859:	8b 50 08             	mov    0x8(%eax),%edx
c010485c:	8b 40 04             	mov    0x4(%eax),%eax
c010485f:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0104862:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0104865:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104868:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010486b:	89 d0                	mov    %edx,%eax
c010486d:	c1 e0 02             	shl    $0x2,%eax
c0104870:	01 d0                	add    %edx,%eax
c0104872:	c1 e0 02             	shl    $0x2,%eax
c0104875:	01 c8                	add    %ecx,%eax
c0104877:	8b 48 0c             	mov    0xc(%eax),%ecx
c010487a:	8b 58 10             	mov    0x10(%eax),%ebx
c010487d:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104880:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104883:	01 c8                	add    %ecx,%eax
c0104885:	11 da                	adc    %ebx,%edx
c0104887:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010488a:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c010488d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104890:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104893:	89 d0                	mov    %edx,%eax
c0104895:	c1 e0 02             	shl    $0x2,%eax
c0104898:	01 d0                	add    %edx,%eax
c010489a:	c1 e0 02             	shl    $0x2,%eax
c010489d:	01 c8                	add    %ecx,%eax
c010489f:	83 c0 14             	add    $0x14,%eax
c01048a2:	8b 00                	mov    (%eax),%eax
c01048a4:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c01048aa:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01048ad:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01048b0:	83 c0 ff             	add    $0xffffffff,%eax
c01048b3:	83 d2 ff             	adc    $0xffffffff,%edx
c01048b6:	89 c6                	mov    %eax,%esi
c01048b8:	89 d7                	mov    %edx,%edi
c01048ba:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01048bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01048c0:	89 d0                	mov    %edx,%eax
c01048c2:	c1 e0 02             	shl    $0x2,%eax
c01048c5:	01 d0                	add    %edx,%eax
c01048c7:	c1 e0 02             	shl    $0x2,%eax
c01048ca:	01 c8                	add    %ecx,%eax
c01048cc:	8b 48 0c             	mov    0xc(%eax),%ecx
c01048cf:	8b 58 10             	mov    0x10(%eax),%ebx
c01048d2:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c01048d8:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c01048dc:	89 74 24 14          	mov    %esi,0x14(%esp)
c01048e0:	89 7c 24 18          	mov    %edi,0x18(%esp)
c01048e4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01048e7:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01048ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01048ee:	89 54 24 10          	mov    %edx,0x10(%esp)
c01048f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01048f6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c01048fa:	c7 04 24 04 9a 10 c0 	movl   $0xc0109a04,(%esp)
c0104901:	e8 51 ba ff ff       	call   c0100357 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0104906:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104909:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010490c:	89 d0                	mov    %edx,%eax
c010490e:	c1 e0 02             	shl    $0x2,%eax
c0104911:	01 d0                	add    %edx,%eax
c0104913:	c1 e0 02             	shl    $0x2,%eax
c0104916:	01 c8                	add    %ecx,%eax
c0104918:	83 c0 14             	add    $0x14,%eax
c010491b:	8b 00                	mov    (%eax),%eax
c010491d:	83 f8 01             	cmp    $0x1,%eax
c0104920:	75 36                	jne    c0104958 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0104922:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104925:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104928:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c010492b:	77 2b                	ja     c0104958 <page_init+0x14a>
c010492d:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0104930:	72 05                	jb     c0104937 <page_init+0x129>
c0104932:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0104935:	73 21                	jae    c0104958 <page_init+0x14a>
c0104937:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010493b:	77 1b                	ja     c0104958 <page_init+0x14a>
c010493d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0104941:	72 09                	jb     c010494c <page_init+0x13e>
c0104943:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c010494a:	77 0c                	ja     c0104958 <page_init+0x14a>
                maxpa = end;
c010494c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010494f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104952:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104955:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104958:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c010495c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010495f:	8b 00                	mov    (%eax),%eax
c0104961:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104964:	0f 8f dd fe ff ff    	jg     c0104847 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c010496a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010496e:	72 1d                	jb     c010498d <page_init+0x17f>
c0104970:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104974:	77 09                	ja     c010497f <page_init+0x171>
c0104976:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c010497d:	76 0e                	jbe    c010498d <page_init+0x17f>
        maxpa = KMEMSIZE;
c010497f:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0104986:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c010498d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104990:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104993:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104997:	c1 ea 0c             	shr    $0xc,%edx
c010499a:	a3 a0 3f 12 c0       	mov    %eax,0xc0123fa0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c010499f:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c01049a6:	b8 30 41 12 c0       	mov    $0xc0124130,%eax
c01049ab:	8d 50 ff             	lea    -0x1(%eax),%edx
c01049ae:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01049b1:	01 d0                	add    %edx,%eax
c01049b3:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01049b6:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01049b9:	ba 00 00 00 00       	mov    $0x0,%edx
c01049be:	f7 75 ac             	divl   -0x54(%ebp)
c01049c1:	89 d0                	mov    %edx,%eax
c01049c3:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01049c6:	29 c2                	sub    %eax,%edx
c01049c8:	89 d0                	mov    %edx,%eax
c01049ca:	a3 54 40 12 c0       	mov    %eax,0xc0124054

    for (i = 0; i < npage; i ++) {
c01049cf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01049d6:	eb 27                	jmp    c01049ff <page_init+0x1f1>
        SetPageReserved(pages + i);
c01049d8:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c01049dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01049e0:	c1 e2 05             	shl    $0x5,%edx
c01049e3:	01 d0                	add    %edx,%eax
c01049e5:	83 c0 04             	add    $0x4,%eax
c01049e8:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c01049ef:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01049f2:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01049f5:	8b 55 90             	mov    -0x70(%ebp),%edx
c01049f8:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c01049fb:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01049ff:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a02:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0104a07:	39 c2                	cmp    %eax,%edx
c0104a09:	72 cd                	jb     c01049d8 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0104a0b:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0104a10:	c1 e0 05             	shl    $0x5,%eax
c0104a13:	89 c2                	mov    %eax,%edx
c0104a15:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c0104a1a:	01 d0                	add    %edx,%eax
c0104a1c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0104a1f:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0104a26:	77 23                	ja     c0104a4b <page_init+0x23d>
c0104a28:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104a2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104a2f:	c7 44 24 08 90 99 10 	movl   $0xc0109990,0x8(%esp)
c0104a36:	c0 
c0104a37:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0104a3e:	00 
c0104a3f:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0104a46:	e8 96 c2 ff ff       	call   c0100ce1 <__panic>
c0104a4b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104a4e:	05 00 00 00 40       	add    $0x40000000,%eax
c0104a53:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0104a56:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104a5d:	e9 74 01 00 00       	jmp    c0104bd6 <page_init+0x3c8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104a62:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104a65:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a68:	89 d0                	mov    %edx,%eax
c0104a6a:	c1 e0 02             	shl    $0x2,%eax
c0104a6d:	01 d0                	add    %edx,%eax
c0104a6f:	c1 e0 02             	shl    $0x2,%eax
c0104a72:	01 c8                	add    %ecx,%eax
c0104a74:	8b 50 08             	mov    0x8(%eax),%edx
c0104a77:	8b 40 04             	mov    0x4(%eax),%eax
c0104a7a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104a7d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104a80:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104a83:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104a86:	89 d0                	mov    %edx,%eax
c0104a88:	c1 e0 02             	shl    $0x2,%eax
c0104a8b:	01 d0                	add    %edx,%eax
c0104a8d:	c1 e0 02             	shl    $0x2,%eax
c0104a90:	01 c8                	add    %ecx,%eax
c0104a92:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104a95:	8b 58 10             	mov    0x10(%eax),%ebx
c0104a98:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104a9b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104a9e:	01 c8                	add    %ecx,%eax
c0104aa0:	11 da                	adc    %ebx,%edx
c0104aa2:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104aa5:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0104aa8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104aab:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104aae:	89 d0                	mov    %edx,%eax
c0104ab0:	c1 e0 02             	shl    $0x2,%eax
c0104ab3:	01 d0                	add    %edx,%eax
c0104ab5:	c1 e0 02             	shl    $0x2,%eax
c0104ab8:	01 c8                	add    %ecx,%eax
c0104aba:	83 c0 14             	add    $0x14,%eax
c0104abd:	8b 00                	mov    (%eax),%eax
c0104abf:	83 f8 01             	cmp    $0x1,%eax
c0104ac2:	0f 85 0a 01 00 00    	jne    c0104bd2 <page_init+0x3c4>
            if (begin < freemem) {
c0104ac8:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104acb:	ba 00 00 00 00       	mov    $0x0,%edx
c0104ad0:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104ad3:	72 17                	jb     c0104aec <page_init+0x2de>
c0104ad5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104ad8:	77 05                	ja     c0104adf <page_init+0x2d1>
c0104ada:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0104add:	76 0d                	jbe    c0104aec <page_init+0x2de>
                begin = freemem;
c0104adf:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104ae2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104ae5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0104aec:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104af0:	72 1d                	jb     c0104b0f <page_init+0x301>
c0104af2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104af6:	77 09                	ja     c0104b01 <page_init+0x2f3>
c0104af8:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0104aff:	76 0e                	jbe    c0104b0f <page_init+0x301>
                end = KMEMSIZE;
c0104b01:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104b08:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0104b0f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104b12:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104b15:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104b18:	0f 87 b4 00 00 00    	ja     c0104bd2 <page_init+0x3c4>
c0104b1e:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104b21:	72 09                	jb     c0104b2c <page_init+0x31e>
c0104b23:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104b26:	0f 83 a6 00 00 00    	jae    c0104bd2 <page_init+0x3c4>
                begin = ROUNDUP(begin, PGSIZE);
c0104b2c:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0104b33:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104b36:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104b39:	01 d0                	add    %edx,%eax
c0104b3b:	83 e8 01             	sub    $0x1,%eax
c0104b3e:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104b41:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104b44:	ba 00 00 00 00       	mov    $0x0,%edx
c0104b49:	f7 75 9c             	divl   -0x64(%ebp)
c0104b4c:	89 d0                	mov    %edx,%eax
c0104b4e:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104b51:	29 c2                	sub    %eax,%edx
c0104b53:	89 d0                	mov    %edx,%eax
c0104b55:	ba 00 00 00 00       	mov    $0x0,%edx
c0104b5a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104b5d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104b60:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104b63:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104b66:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104b69:	ba 00 00 00 00       	mov    $0x0,%edx
c0104b6e:	89 c7                	mov    %eax,%edi
c0104b70:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0104b76:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0104b79:	89 d0                	mov    %edx,%eax
c0104b7b:	83 e0 00             	and    $0x0,%eax
c0104b7e:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104b81:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104b84:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104b87:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104b8a:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0104b8d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104b90:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104b93:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104b96:	77 3a                	ja     c0104bd2 <page_init+0x3c4>
c0104b98:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104b9b:	72 05                	jb     c0104ba2 <page_init+0x394>
c0104b9d:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104ba0:	73 30                	jae    c0104bd2 <page_init+0x3c4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0104ba2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0104ba5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c0104ba8:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104bab:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104bae:	29 c8                	sub    %ecx,%eax
c0104bb0:	19 da                	sbb    %ebx,%edx
c0104bb2:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104bb6:	c1 ea 0c             	shr    $0xc,%edx
c0104bb9:	89 c3                	mov    %eax,%ebx
c0104bbb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104bbe:	89 04 24             	mov    %eax,(%esp)
c0104bc1:	e8 42 f8 ff ff       	call   c0104408 <pa2page>
c0104bc6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104bca:	89 04 24             	mov    %eax,(%esp)
c0104bcd:	e8 55 fb ff ff       	call   c0104727 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0104bd2:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104bd6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104bd9:	8b 00                	mov    (%eax),%eax
c0104bdb:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0104bde:	0f 8f 7e fe ff ff    	jg     c0104a62 <page_init+0x254>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0104be4:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0104bea:	5b                   	pop    %ebx
c0104beb:	5e                   	pop    %esi
c0104bec:	5f                   	pop    %edi
c0104bed:	5d                   	pop    %ebp
c0104bee:	c3                   	ret    

c0104bef <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0104bef:	55                   	push   %ebp
c0104bf0:	89 e5                	mov    %esp,%ebp
c0104bf2:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104bf5:	8b 45 14             	mov    0x14(%ebp),%eax
c0104bf8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104bfb:	31 d0                	xor    %edx,%eax
c0104bfd:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104c02:	85 c0                	test   %eax,%eax
c0104c04:	74 24                	je     c0104c2a <boot_map_segment+0x3b>
c0104c06:	c7 44 24 0c 42 9a 10 	movl   $0xc0109a42,0xc(%esp)
c0104c0d:	c0 
c0104c0e:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0104c15:	c0 
c0104c16:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0104c1d:	00 
c0104c1e:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0104c25:	e8 b7 c0 ff ff       	call   c0100ce1 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0104c2a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104c31:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104c34:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104c39:	89 c2                	mov    %eax,%edx
c0104c3b:	8b 45 10             	mov    0x10(%ebp),%eax
c0104c3e:	01 c2                	add    %eax,%edx
c0104c40:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c43:	01 d0                	add    %edx,%eax
c0104c45:	83 e8 01             	sub    $0x1,%eax
c0104c48:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104c4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c4e:	ba 00 00 00 00       	mov    $0x0,%edx
c0104c53:	f7 75 f0             	divl   -0x10(%ebp)
c0104c56:	89 d0                	mov    %edx,%eax
c0104c58:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104c5b:	29 c2                	sub    %eax,%edx
c0104c5d:	89 d0                	mov    %edx,%eax
c0104c5f:	c1 e8 0c             	shr    $0xc,%eax
c0104c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104c65:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104c68:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104c6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104c6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104c73:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0104c76:	8b 45 14             	mov    0x14(%ebp),%eax
c0104c79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104c7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c7f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104c84:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104c87:	eb 6b                	jmp    c0104cf4 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0104c89:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104c90:	00 
c0104c91:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104c94:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104c98:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c9b:	89 04 24             	mov    %eax,(%esp)
c0104c9e:	e8 82 01 00 00       	call   c0104e25 <get_pte>
c0104ca3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0104ca6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0104caa:	75 24                	jne    c0104cd0 <boot_map_segment+0xe1>
c0104cac:	c7 44 24 0c 6e 9a 10 	movl   $0xc0109a6e,0xc(%esp)
c0104cb3:	c0 
c0104cb4:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0104cbb:	c0 
c0104cbc:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0104cc3:	00 
c0104cc4:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0104ccb:	e8 11 c0 ff ff       	call   c0100ce1 <__panic>
        *ptep = pa | PTE_P | perm;
c0104cd0:	8b 45 18             	mov    0x18(%ebp),%eax
c0104cd3:	8b 55 14             	mov    0x14(%ebp),%edx
c0104cd6:	09 d0                	or     %edx,%eax
c0104cd8:	83 c8 01             	or     $0x1,%eax
c0104cdb:	89 c2                	mov    %eax,%edx
c0104cdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ce0:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104ce2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104ce6:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0104ced:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104cf4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104cf8:	75 8f                	jne    c0104c89 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0104cfa:	c9                   	leave  
c0104cfb:	c3                   	ret    

c0104cfc <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0104cfc:	55                   	push   %ebp
c0104cfd:	89 e5                	mov    %esp,%ebp
c0104cff:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0104d02:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104d09:	e8 38 fa ff ff       	call   c0104746 <alloc_pages>
c0104d0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104d11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104d15:	75 1c                	jne    c0104d33 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0104d17:	c7 44 24 08 7b 9a 10 	movl   $0xc0109a7b,0x8(%esp)
c0104d1e:	c0 
c0104d1f:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0104d26:	00 
c0104d27:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0104d2e:	e8 ae bf ff ff       	call   c0100ce1 <__panic>
    }
    return page2kva(p);
c0104d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d36:	89 04 24             	mov    %eax,(%esp)
c0104d39:	e8 0f f7 ff ff       	call   c010444d <page2kva>
}
c0104d3e:	c9                   	leave  
c0104d3f:	c3                   	ret    

c0104d40 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0104d40:	55                   	push   %ebp
c0104d41:	89 e5                	mov    %esp,%ebp
c0104d43:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0104d46:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0104d4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104d4e:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104d55:	77 23                	ja     c0104d7a <pmm_init+0x3a>
c0104d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104d5e:	c7 44 24 08 90 99 10 	movl   $0xc0109990,0x8(%esp)
c0104d65:	c0 
c0104d66:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0104d6d:	00 
c0104d6e:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0104d75:	e8 67 bf ff ff       	call   c0100ce1 <__panic>
c0104d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d7d:	05 00 00 00 40       	add    $0x40000000,%eax
c0104d82:	a3 50 40 12 c0       	mov    %eax,0xc0124050
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0104d87:	e8 68 f9 ff ff       	call   c01046f4 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0104d8c:	e8 7d fa ff ff       	call   c010480e <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0104d91:	e8 a6 04 00 00       	call   c010523c <check_alloc_page>

    check_pgdir();
c0104d96:	e8 bf 04 00 00       	call   c010525a <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0104d9b:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0104da0:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0104da6:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0104dab:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104dae:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104db5:	77 23                	ja     c0104dda <pmm_init+0x9a>
c0104db7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dba:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104dbe:	c7 44 24 08 90 99 10 	movl   $0xc0109990,0x8(%esp)
c0104dc5:	c0 
c0104dc6:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0104dcd:	00 
c0104dce:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0104dd5:	e8 07 bf ff ff       	call   c0100ce1 <__panic>
c0104dda:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ddd:	05 00 00 00 40       	add    $0x40000000,%eax
c0104de2:	83 c8 03             	or     $0x3,%eax
c0104de5:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0104de7:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0104dec:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0104df3:	00 
c0104df4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104dfb:	00 
c0104dfc:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0104e03:	38 
c0104e04:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0104e0b:	c0 
c0104e0c:	89 04 24             	mov    %eax,(%esp)
c0104e0f:	e8 db fd ff ff       	call   c0104bef <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0104e14:	e8 ec f7 ff ff       	call   c0104605 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0104e19:	e8 d7 0a 00 00       	call   c01058f5 <check_boot_pgdir>

    print_pgdir();
c0104e1e:	e8 5f 0f 00 00       	call   c0105d82 <print_pgdir>

}
c0104e23:	c9                   	leave  
c0104e24:	c3                   	ret    

c0104e25 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0104e25:	55                   	push   %ebp
c0104e26:	89 e5                	mov    %esp,%ebp
c0104e28:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0104e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104e2e:	c1 e8 16             	shr    $0x16,%eax
c0104e31:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104e38:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e3b:	01 d0                	add    %edx,%eax
c0104e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c0104e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e43:	8b 00                	mov    (%eax),%eax
c0104e45:	83 e0 01             	and    $0x1,%eax
c0104e48:	85 c0                	test   %eax,%eax
c0104e4a:	0f 85 af 00 00 00    	jne    c0104eff <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c0104e50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104e54:	74 15                	je     c0104e6b <get_pte+0x46>
c0104e56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e5d:	e8 e4 f8 ff ff       	call   c0104746 <alloc_pages>
c0104e62:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104e65:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104e69:	75 0a                	jne    c0104e75 <get_pte+0x50>
            return NULL;
c0104e6b:	b8 00 00 00 00       	mov    $0x0,%eax
c0104e70:	e9 e6 00 00 00       	jmp    c0104f5b <get_pte+0x136>
        }
        set_page_ref(page, 1);
c0104e75:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104e7c:	00 
c0104e7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e80:	89 04 24             	mov    %eax,(%esp)
c0104e83:	e8 c3 f6 ff ff       	call   c010454b <set_page_ref>
        uintptr_t pa = page2pa(page);
c0104e88:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e8b:	89 04 24             	mov    %eax,(%esp)
c0104e8e:	e8 5f f5 ff ff       	call   c01043f2 <page2pa>
c0104e93:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0104e96:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e99:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104e9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e9f:	c1 e8 0c             	shr    $0xc,%eax
c0104ea2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104ea5:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0104eaa:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0104ead:	72 23                	jb     c0104ed2 <get_pte+0xad>
c0104eaf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104eb2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104eb6:	c7 44 24 08 6c 99 10 	movl   $0xc010996c,0x8(%esp)
c0104ebd:	c0 
c0104ebe:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
c0104ec5:	00 
c0104ec6:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0104ecd:	e8 0f be ff ff       	call   c0100ce1 <__panic>
c0104ed2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ed5:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104eda:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104ee1:	00 
c0104ee2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104ee9:	00 
c0104eea:	89 04 24             	mov    %eax,(%esp)
c0104eed:	e8 5f 3c 00 00       	call   c0108b51 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0104ef2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ef5:	83 c8 07             	or     $0x7,%eax
c0104ef8:	89 c2                	mov    %eax,%edx
c0104efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104efd:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0104eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f02:	8b 00                	mov    (%eax),%eax
c0104f04:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104f09:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104f0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f0f:	c1 e8 0c             	shr    $0xc,%eax
c0104f12:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104f15:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0104f1a:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104f1d:	72 23                	jb     c0104f42 <get_pte+0x11d>
c0104f1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f22:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104f26:	c7 44 24 08 6c 99 10 	movl   $0xc010996c,0x8(%esp)
c0104f2d:	c0 
c0104f2e:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
c0104f35:	00 
c0104f36:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0104f3d:	e8 9f bd ff ff       	call   c0100ce1 <__panic>
c0104f42:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f45:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104f4a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104f4d:	c1 ea 0c             	shr    $0xc,%edx
c0104f50:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c0104f56:	c1 e2 02             	shl    $0x2,%edx
c0104f59:	01 d0                	add    %edx,%eax
}
c0104f5b:	c9                   	leave  
c0104f5c:	c3                   	ret    

c0104f5d <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0104f5d:	55                   	push   %ebp
c0104f5e:	89 e5                	mov    %esp,%ebp
c0104f60:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104f63:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104f6a:	00 
c0104f6b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f72:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f75:	89 04 24             	mov    %eax,(%esp)
c0104f78:	e8 a8 fe ff ff       	call   c0104e25 <get_pte>
c0104f7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0104f80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104f84:	74 08                	je     c0104f8e <get_page+0x31>
        *ptep_store = ptep;
c0104f86:	8b 45 10             	mov    0x10(%ebp),%eax
c0104f89:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104f8c:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0104f8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104f92:	74 1b                	je     c0104faf <get_page+0x52>
c0104f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f97:	8b 00                	mov    (%eax),%eax
c0104f99:	83 e0 01             	and    $0x1,%eax
c0104f9c:	85 c0                	test   %eax,%eax
c0104f9e:	74 0f                	je     c0104faf <get_page+0x52>
        return pte2page(*ptep);
c0104fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fa3:	8b 00                	mov    (%eax),%eax
c0104fa5:	89 04 24             	mov    %eax,(%esp)
c0104fa8:	e8 3e f5 ff ff       	call   c01044eb <pte2page>
c0104fad:	eb 05                	jmp    c0104fb4 <get_page+0x57>
    }
    return NULL;
c0104faf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104fb4:	c9                   	leave  
c0104fb5:	c3                   	ret    

c0104fb6 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0104fb6:	55                   	push   %ebp
c0104fb7:	89 e5                	mov    %esp,%ebp
c0104fb9:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c0104fbc:	8b 45 10             	mov    0x10(%ebp),%eax
c0104fbf:	8b 00                	mov    (%eax),%eax
c0104fc1:	83 e0 01             	and    $0x1,%eax
c0104fc4:	85 c0                	test   %eax,%eax
c0104fc6:	74 4d                	je     c0105015 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0104fc8:	8b 45 10             	mov    0x10(%ebp),%eax
c0104fcb:	8b 00                	mov    (%eax),%eax
c0104fcd:	89 04 24             	mov    %eax,(%esp)
c0104fd0:	e8 16 f5 ff ff       	call   c01044eb <pte2page>
c0104fd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0104fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104fdb:	89 04 24             	mov    %eax,(%esp)
c0104fde:	e8 8c f5 ff ff       	call   c010456f <page_ref_dec>
c0104fe3:	85 c0                	test   %eax,%eax
c0104fe5:	75 13                	jne    c0104ffa <page_remove_pte+0x44>
            free_page(page);
c0104fe7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104fee:	00 
c0104fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ff2:	89 04 24             	mov    %eax,(%esp)
c0104ff5:	e8 b7 f7 ff ff       	call   c01047b1 <free_pages>
        }
        *ptep = 0;
c0104ffa:	8b 45 10             	mov    0x10(%ebp),%eax
c0104ffd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0105003:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105006:	89 44 24 04          	mov    %eax,0x4(%esp)
c010500a:	8b 45 08             	mov    0x8(%ebp),%eax
c010500d:	89 04 24             	mov    %eax,(%esp)
c0105010:	e8 ff 00 00 00       	call   c0105114 <tlb_invalidate>
    }
}
c0105015:	c9                   	leave  
c0105016:	c3                   	ret    

c0105017 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0105017:	55                   	push   %ebp
c0105018:	89 e5                	mov    %esp,%ebp
c010501a:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010501d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105024:	00 
c0105025:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105028:	89 44 24 04          	mov    %eax,0x4(%esp)
c010502c:	8b 45 08             	mov    0x8(%ebp),%eax
c010502f:	89 04 24             	mov    %eax,(%esp)
c0105032:	e8 ee fd ff ff       	call   c0104e25 <get_pte>
c0105037:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c010503a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010503e:	74 19                	je     c0105059 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0105040:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105043:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105047:	8b 45 0c             	mov    0xc(%ebp),%eax
c010504a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010504e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105051:	89 04 24             	mov    %eax,(%esp)
c0105054:	e8 5d ff ff ff       	call   c0104fb6 <page_remove_pte>
    }
}
c0105059:	c9                   	leave  
c010505a:	c3                   	ret    

c010505b <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c010505b:	55                   	push   %ebp
c010505c:	89 e5                	mov    %esp,%ebp
c010505e:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0105061:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105068:	00 
c0105069:	8b 45 10             	mov    0x10(%ebp),%eax
c010506c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105070:	8b 45 08             	mov    0x8(%ebp),%eax
c0105073:	89 04 24             	mov    %eax,(%esp)
c0105076:	e8 aa fd ff ff       	call   c0104e25 <get_pte>
c010507b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c010507e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105082:	75 0a                	jne    c010508e <page_insert+0x33>
        return -E_NO_MEM;
c0105084:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0105089:	e9 84 00 00 00       	jmp    c0105112 <page_insert+0xb7>
    }
    page_ref_inc(page);
c010508e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105091:	89 04 24             	mov    %eax,(%esp)
c0105094:	e8 bf f4 ff ff       	call   c0104558 <page_ref_inc>
    if (*ptep & PTE_P) {
c0105099:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010509c:	8b 00                	mov    (%eax),%eax
c010509e:	83 e0 01             	and    $0x1,%eax
c01050a1:	85 c0                	test   %eax,%eax
c01050a3:	74 3e                	je     c01050e3 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01050a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050a8:	8b 00                	mov    (%eax),%eax
c01050aa:	89 04 24             	mov    %eax,(%esp)
c01050ad:	e8 39 f4 ff ff       	call   c01044eb <pte2page>
c01050b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01050b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050b8:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01050bb:	75 0d                	jne    c01050ca <page_insert+0x6f>
            page_ref_dec(page);
c01050bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050c0:	89 04 24             	mov    %eax,(%esp)
c01050c3:	e8 a7 f4 ff ff       	call   c010456f <page_ref_dec>
c01050c8:	eb 19                	jmp    c01050e3 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01050ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050cd:	89 44 24 08          	mov    %eax,0x8(%esp)
c01050d1:	8b 45 10             	mov    0x10(%ebp),%eax
c01050d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01050d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01050db:	89 04 24             	mov    %eax,(%esp)
c01050de:	e8 d3 fe ff ff       	call   c0104fb6 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01050e3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050e6:	89 04 24             	mov    %eax,(%esp)
c01050e9:	e8 04 f3 ff ff       	call   c01043f2 <page2pa>
c01050ee:	0b 45 14             	or     0x14(%ebp),%eax
c01050f1:	83 c8 01             	or     $0x1,%eax
c01050f4:	89 c2                	mov    %eax,%edx
c01050f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050f9:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01050fb:	8b 45 10             	mov    0x10(%ebp),%eax
c01050fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105102:	8b 45 08             	mov    0x8(%ebp),%eax
c0105105:	89 04 24             	mov    %eax,(%esp)
c0105108:	e8 07 00 00 00       	call   c0105114 <tlb_invalidate>
    return 0;
c010510d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105112:	c9                   	leave  
c0105113:	c3                   	ret    

c0105114 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0105114:	55                   	push   %ebp
c0105115:	89 e5                	mov    %esp,%ebp
c0105117:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010511a:	0f 20 d8             	mov    %cr3,%eax
c010511d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0105120:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0105123:	89 c2                	mov    %eax,%edx
c0105125:	8b 45 08             	mov    0x8(%ebp),%eax
c0105128:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010512b:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0105132:	77 23                	ja     c0105157 <tlb_invalidate+0x43>
c0105134:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105137:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010513b:	c7 44 24 08 90 99 10 	movl   $0xc0109990,0x8(%esp)
c0105142:	c0 
c0105143:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c010514a:	00 
c010514b:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105152:	e8 8a bb ff ff       	call   c0100ce1 <__panic>
c0105157:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010515a:	05 00 00 00 40       	add    $0x40000000,%eax
c010515f:	39 c2                	cmp    %eax,%edx
c0105161:	75 0c                	jne    c010516f <tlb_invalidate+0x5b>
        invlpg((void *)la);
c0105163:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105166:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0105169:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010516c:	0f 01 38             	invlpg (%eax)
    }
}
c010516f:	c9                   	leave  
c0105170:	c3                   	ret    

c0105171 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0105171:	55                   	push   %ebp
c0105172:	89 e5                	mov    %esp,%ebp
c0105174:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0105177:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010517e:	e8 c3 f5 ff ff       	call   c0104746 <alloc_pages>
c0105183:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0105186:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010518a:	0f 84 a7 00 00 00    	je     c0105237 <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0105190:	8b 45 10             	mov    0x10(%ebp),%eax
c0105193:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105197:	8b 45 0c             	mov    0xc(%ebp),%eax
c010519a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010519e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01051a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01051a8:	89 04 24             	mov    %eax,(%esp)
c01051ab:	e8 ab fe ff ff       	call   c010505b <page_insert>
c01051b0:	85 c0                	test   %eax,%eax
c01051b2:	74 1a                	je     c01051ce <pgdir_alloc_page+0x5d>
            free_page(page);
c01051b4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01051bb:	00 
c01051bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051bf:	89 04 24             	mov    %eax,(%esp)
c01051c2:	e8 ea f5 ff ff       	call   c01047b1 <free_pages>
            return NULL;
c01051c7:	b8 00 00 00 00       	mov    $0x0,%eax
c01051cc:	eb 6c                	jmp    c010523a <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c01051ce:	a1 2c 40 12 c0       	mov    0xc012402c,%eax
c01051d3:	85 c0                	test   %eax,%eax
c01051d5:	74 60                	je     c0105237 <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c01051d7:	a1 2c 41 12 c0       	mov    0xc012412c,%eax
c01051dc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01051e3:	00 
c01051e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01051e7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01051eb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01051ee:	89 54 24 04          	mov    %edx,0x4(%esp)
c01051f2:	89 04 24             	mov    %eax,(%esp)
c01051f5:	e8 73 0f 00 00       	call   c010616d <swap_map_swappable>
            page->pra_vaddr=la;
c01051fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051fd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105200:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c0105203:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105206:	89 04 24             	mov    %eax,(%esp)
c0105209:	e8 33 f3 ff ff       	call   c0104541 <page_ref>
c010520e:	83 f8 01             	cmp    $0x1,%eax
c0105211:	74 24                	je     c0105237 <pgdir_alloc_page+0xc6>
c0105213:	c7 44 24 0c 94 9a 10 	movl   $0xc0109a94,0xc(%esp)
c010521a:	c0 
c010521b:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105222:	c0 
c0105223:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c010522a:	00 
c010522b:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105232:	e8 aa ba ff ff       	call   c0100ce1 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c0105237:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010523a:	c9                   	leave  
c010523b:	c3                   	ret    

c010523c <check_alloc_page>:

static void
check_alloc_page(void) {
c010523c:	55                   	push   %ebp
c010523d:	89 e5                	mov    %esp,%ebp
c010523f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0105242:	a1 4c 40 12 c0       	mov    0xc012404c,%eax
c0105247:	8b 40 18             	mov    0x18(%eax),%eax
c010524a:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c010524c:	c7 04 24 a8 9a 10 c0 	movl   $0xc0109aa8,(%esp)
c0105253:	e8 ff b0 ff ff       	call   c0100357 <cprintf>
}
c0105258:	c9                   	leave  
c0105259:	c3                   	ret    

c010525a <check_pgdir>:

static void
check_pgdir(void) {
c010525a:	55                   	push   %ebp
c010525b:	89 e5                	mov    %esp,%ebp
c010525d:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0105260:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0105265:	3d 00 80 03 00       	cmp    $0x38000,%eax
c010526a:	76 24                	jbe    c0105290 <check_pgdir+0x36>
c010526c:	c7 44 24 0c c7 9a 10 	movl   $0xc0109ac7,0xc(%esp)
c0105273:	c0 
c0105274:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c010527b:	c0 
c010527c:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c0105283:	00 
c0105284:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c010528b:	e8 51 ba ff ff       	call   c0100ce1 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0105290:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105295:	85 c0                	test   %eax,%eax
c0105297:	74 0e                	je     c01052a7 <check_pgdir+0x4d>
c0105299:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c010529e:	25 ff 0f 00 00       	and    $0xfff,%eax
c01052a3:	85 c0                	test   %eax,%eax
c01052a5:	74 24                	je     c01052cb <check_pgdir+0x71>
c01052a7:	c7 44 24 0c e4 9a 10 	movl   $0xc0109ae4,0xc(%esp)
c01052ae:	c0 
c01052af:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c01052b6:	c0 
c01052b7:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c01052be:	00 
c01052bf:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c01052c6:	e8 16 ba ff ff       	call   c0100ce1 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01052cb:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01052d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01052d7:	00 
c01052d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01052df:	00 
c01052e0:	89 04 24             	mov    %eax,(%esp)
c01052e3:	e8 75 fc ff ff       	call   c0104f5d <get_page>
c01052e8:	85 c0                	test   %eax,%eax
c01052ea:	74 24                	je     c0105310 <check_pgdir+0xb6>
c01052ec:	c7 44 24 0c 1c 9b 10 	movl   $0xc0109b1c,0xc(%esp)
c01052f3:	c0 
c01052f4:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c01052fb:	c0 
c01052fc:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c0105303:	00 
c0105304:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c010530b:	e8 d1 b9 ff ff       	call   c0100ce1 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0105310:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105317:	e8 2a f4 ff ff       	call   c0104746 <alloc_pages>
c010531c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c010531f:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105324:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010532b:	00 
c010532c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105333:	00 
c0105334:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105337:	89 54 24 04          	mov    %edx,0x4(%esp)
c010533b:	89 04 24             	mov    %eax,(%esp)
c010533e:	e8 18 fd ff ff       	call   c010505b <page_insert>
c0105343:	85 c0                	test   %eax,%eax
c0105345:	74 24                	je     c010536b <check_pgdir+0x111>
c0105347:	c7 44 24 0c 44 9b 10 	movl   $0xc0109b44,0xc(%esp)
c010534e:	c0 
c010534f:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105356:	c0 
c0105357:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c010535e:	00 
c010535f:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105366:	e8 76 b9 ff ff       	call   c0100ce1 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c010536b:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105370:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105377:	00 
c0105378:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010537f:	00 
c0105380:	89 04 24             	mov    %eax,(%esp)
c0105383:	e8 9d fa ff ff       	call   c0104e25 <get_pte>
c0105388:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010538b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010538f:	75 24                	jne    c01053b5 <check_pgdir+0x15b>
c0105391:	c7 44 24 0c 70 9b 10 	movl   $0xc0109b70,0xc(%esp)
c0105398:	c0 
c0105399:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c01053a0:	c0 
c01053a1:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c01053a8:	00 
c01053a9:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c01053b0:	e8 2c b9 ff ff       	call   c0100ce1 <__panic>
    assert(pte2page(*ptep) == p1);
c01053b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053b8:	8b 00                	mov    (%eax),%eax
c01053ba:	89 04 24             	mov    %eax,(%esp)
c01053bd:	e8 29 f1 ff ff       	call   c01044eb <pte2page>
c01053c2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01053c5:	74 24                	je     c01053eb <check_pgdir+0x191>
c01053c7:	c7 44 24 0c 9d 9b 10 	movl   $0xc0109b9d,0xc(%esp)
c01053ce:	c0 
c01053cf:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c01053d6:	c0 
c01053d7:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c01053de:	00 
c01053df:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c01053e6:	e8 f6 b8 ff ff       	call   c0100ce1 <__panic>
    assert(page_ref(p1) == 1);
c01053eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053ee:	89 04 24             	mov    %eax,(%esp)
c01053f1:	e8 4b f1 ff ff       	call   c0104541 <page_ref>
c01053f6:	83 f8 01             	cmp    $0x1,%eax
c01053f9:	74 24                	je     c010541f <check_pgdir+0x1c5>
c01053fb:	c7 44 24 0c b3 9b 10 	movl   $0xc0109bb3,0xc(%esp)
c0105402:	c0 
c0105403:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c010540a:	c0 
c010540b:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0105412:	00 
c0105413:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c010541a:	e8 c2 b8 ff ff       	call   c0100ce1 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c010541f:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105424:	8b 00                	mov    (%eax),%eax
c0105426:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010542b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010542e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105431:	c1 e8 0c             	shr    $0xc,%eax
c0105434:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105437:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c010543c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010543f:	72 23                	jb     c0105464 <check_pgdir+0x20a>
c0105441:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105444:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105448:	c7 44 24 08 6c 99 10 	movl   $0xc010996c,0x8(%esp)
c010544f:	c0 
c0105450:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0105457:	00 
c0105458:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c010545f:	e8 7d b8 ff ff       	call   c0100ce1 <__panic>
c0105464:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105467:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010546c:	83 c0 04             	add    $0x4,%eax
c010546f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0105472:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105477:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010547e:	00 
c010547f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105486:	00 
c0105487:	89 04 24             	mov    %eax,(%esp)
c010548a:	e8 96 f9 ff ff       	call   c0104e25 <get_pte>
c010548f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105492:	74 24                	je     c01054b8 <check_pgdir+0x25e>
c0105494:	c7 44 24 0c c8 9b 10 	movl   $0xc0109bc8,0xc(%esp)
c010549b:	c0 
c010549c:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c01054a3:	c0 
c01054a4:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c01054ab:	00 
c01054ac:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c01054b3:	e8 29 b8 ff ff       	call   c0100ce1 <__panic>

    p2 = alloc_page();
c01054b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01054bf:	e8 82 f2 ff ff       	call   c0104746 <alloc_pages>
c01054c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01054c7:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01054cc:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01054d3:	00 
c01054d4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01054db:	00 
c01054dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01054df:	89 54 24 04          	mov    %edx,0x4(%esp)
c01054e3:	89 04 24             	mov    %eax,(%esp)
c01054e6:	e8 70 fb ff ff       	call   c010505b <page_insert>
c01054eb:	85 c0                	test   %eax,%eax
c01054ed:	74 24                	je     c0105513 <check_pgdir+0x2b9>
c01054ef:	c7 44 24 0c f0 9b 10 	movl   $0xc0109bf0,0xc(%esp)
c01054f6:	c0 
c01054f7:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c01054fe:	c0 
c01054ff:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c0105506:	00 
c0105507:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c010550e:	e8 ce b7 ff ff       	call   c0100ce1 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0105513:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105518:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010551f:	00 
c0105520:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105527:	00 
c0105528:	89 04 24             	mov    %eax,(%esp)
c010552b:	e8 f5 f8 ff ff       	call   c0104e25 <get_pte>
c0105530:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105533:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105537:	75 24                	jne    c010555d <check_pgdir+0x303>
c0105539:	c7 44 24 0c 28 9c 10 	movl   $0xc0109c28,0xc(%esp)
c0105540:	c0 
c0105541:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105548:	c0 
c0105549:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c0105550:	00 
c0105551:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105558:	e8 84 b7 ff ff       	call   c0100ce1 <__panic>
    assert(*ptep & PTE_U);
c010555d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105560:	8b 00                	mov    (%eax),%eax
c0105562:	83 e0 04             	and    $0x4,%eax
c0105565:	85 c0                	test   %eax,%eax
c0105567:	75 24                	jne    c010558d <check_pgdir+0x333>
c0105569:	c7 44 24 0c 58 9c 10 	movl   $0xc0109c58,0xc(%esp)
c0105570:	c0 
c0105571:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105578:	c0 
c0105579:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0105580:	00 
c0105581:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105588:	e8 54 b7 ff ff       	call   c0100ce1 <__panic>
    assert(*ptep & PTE_W);
c010558d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105590:	8b 00                	mov    (%eax),%eax
c0105592:	83 e0 02             	and    $0x2,%eax
c0105595:	85 c0                	test   %eax,%eax
c0105597:	75 24                	jne    c01055bd <check_pgdir+0x363>
c0105599:	c7 44 24 0c 66 9c 10 	movl   $0xc0109c66,0xc(%esp)
c01055a0:	c0 
c01055a1:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c01055a8:	c0 
c01055a9:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c01055b0:	00 
c01055b1:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c01055b8:	e8 24 b7 ff ff       	call   c0100ce1 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c01055bd:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01055c2:	8b 00                	mov    (%eax),%eax
c01055c4:	83 e0 04             	and    $0x4,%eax
c01055c7:	85 c0                	test   %eax,%eax
c01055c9:	75 24                	jne    c01055ef <check_pgdir+0x395>
c01055cb:	c7 44 24 0c 74 9c 10 	movl   $0xc0109c74,0xc(%esp)
c01055d2:	c0 
c01055d3:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c01055da:	c0 
c01055db:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c01055e2:	00 
c01055e3:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c01055ea:	e8 f2 b6 ff ff       	call   c0100ce1 <__panic>
    assert(page_ref(p2) == 1);
c01055ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01055f2:	89 04 24             	mov    %eax,(%esp)
c01055f5:	e8 47 ef ff ff       	call   c0104541 <page_ref>
c01055fa:	83 f8 01             	cmp    $0x1,%eax
c01055fd:	74 24                	je     c0105623 <check_pgdir+0x3c9>
c01055ff:	c7 44 24 0c 8a 9c 10 	movl   $0xc0109c8a,0xc(%esp)
c0105606:	c0 
c0105607:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c010560e:	c0 
c010560f:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0105616:	00 
c0105617:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c010561e:	e8 be b6 ff ff       	call   c0100ce1 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0105623:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105628:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010562f:	00 
c0105630:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0105637:	00 
c0105638:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010563b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010563f:	89 04 24             	mov    %eax,(%esp)
c0105642:	e8 14 fa ff ff       	call   c010505b <page_insert>
c0105647:	85 c0                	test   %eax,%eax
c0105649:	74 24                	je     c010566f <check_pgdir+0x415>
c010564b:	c7 44 24 0c 9c 9c 10 	movl   $0xc0109c9c,0xc(%esp)
c0105652:	c0 
c0105653:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c010565a:	c0 
c010565b:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0105662:	00 
c0105663:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c010566a:	e8 72 b6 ff ff       	call   c0100ce1 <__panic>
    assert(page_ref(p1) == 2);
c010566f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105672:	89 04 24             	mov    %eax,(%esp)
c0105675:	e8 c7 ee ff ff       	call   c0104541 <page_ref>
c010567a:	83 f8 02             	cmp    $0x2,%eax
c010567d:	74 24                	je     c01056a3 <check_pgdir+0x449>
c010567f:	c7 44 24 0c c8 9c 10 	movl   $0xc0109cc8,0xc(%esp)
c0105686:	c0 
c0105687:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c010568e:	c0 
c010568f:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0105696:	00 
c0105697:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c010569e:	e8 3e b6 ff ff       	call   c0100ce1 <__panic>
    assert(page_ref(p2) == 0);
c01056a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01056a6:	89 04 24             	mov    %eax,(%esp)
c01056a9:	e8 93 ee ff ff       	call   c0104541 <page_ref>
c01056ae:	85 c0                	test   %eax,%eax
c01056b0:	74 24                	je     c01056d6 <check_pgdir+0x47c>
c01056b2:	c7 44 24 0c da 9c 10 	movl   $0xc0109cda,0xc(%esp)
c01056b9:	c0 
c01056ba:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c01056c1:	c0 
c01056c2:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c01056c9:	00 
c01056ca:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c01056d1:	e8 0b b6 ff ff       	call   c0100ce1 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01056d6:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01056db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01056e2:	00 
c01056e3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01056ea:	00 
c01056eb:	89 04 24             	mov    %eax,(%esp)
c01056ee:	e8 32 f7 ff ff       	call   c0104e25 <get_pte>
c01056f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01056f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01056fa:	75 24                	jne    c0105720 <check_pgdir+0x4c6>
c01056fc:	c7 44 24 0c 28 9c 10 	movl   $0xc0109c28,0xc(%esp)
c0105703:	c0 
c0105704:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c010570b:	c0 
c010570c:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c0105713:	00 
c0105714:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c010571b:	e8 c1 b5 ff ff       	call   c0100ce1 <__panic>
    assert(pte2page(*ptep) == p1);
c0105720:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105723:	8b 00                	mov    (%eax),%eax
c0105725:	89 04 24             	mov    %eax,(%esp)
c0105728:	e8 be ed ff ff       	call   c01044eb <pte2page>
c010572d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105730:	74 24                	je     c0105756 <check_pgdir+0x4fc>
c0105732:	c7 44 24 0c 9d 9b 10 	movl   $0xc0109b9d,0xc(%esp)
c0105739:	c0 
c010573a:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105741:	c0 
c0105742:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c0105749:	00 
c010574a:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105751:	e8 8b b5 ff ff       	call   c0100ce1 <__panic>
    assert((*ptep & PTE_U) == 0);
c0105756:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105759:	8b 00                	mov    (%eax),%eax
c010575b:	83 e0 04             	and    $0x4,%eax
c010575e:	85 c0                	test   %eax,%eax
c0105760:	74 24                	je     c0105786 <check_pgdir+0x52c>
c0105762:	c7 44 24 0c ec 9c 10 	movl   $0xc0109cec,0xc(%esp)
c0105769:	c0 
c010576a:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105771:	c0 
c0105772:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c0105779:	00 
c010577a:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105781:	e8 5b b5 ff ff       	call   c0100ce1 <__panic>

    page_remove(boot_pgdir, 0x0);
c0105786:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c010578b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105792:	00 
c0105793:	89 04 24             	mov    %eax,(%esp)
c0105796:	e8 7c f8 ff ff       	call   c0105017 <page_remove>
    assert(page_ref(p1) == 1);
c010579b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010579e:	89 04 24             	mov    %eax,(%esp)
c01057a1:	e8 9b ed ff ff       	call   c0104541 <page_ref>
c01057a6:	83 f8 01             	cmp    $0x1,%eax
c01057a9:	74 24                	je     c01057cf <check_pgdir+0x575>
c01057ab:	c7 44 24 0c b3 9b 10 	movl   $0xc0109bb3,0xc(%esp)
c01057b2:	c0 
c01057b3:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c01057ba:	c0 
c01057bb:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c01057c2:	00 
c01057c3:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c01057ca:	e8 12 b5 ff ff       	call   c0100ce1 <__panic>
    assert(page_ref(p2) == 0);
c01057cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01057d2:	89 04 24             	mov    %eax,(%esp)
c01057d5:	e8 67 ed ff ff       	call   c0104541 <page_ref>
c01057da:	85 c0                	test   %eax,%eax
c01057dc:	74 24                	je     c0105802 <check_pgdir+0x5a8>
c01057de:	c7 44 24 0c da 9c 10 	movl   $0xc0109cda,0xc(%esp)
c01057e5:	c0 
c01057e6:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c01057ed:	c0 
c01057ee:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c01057f5:	00 
c01057f6:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c01057fd:	e8 df b4 ff ff       	call   c0100ce1 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0105802:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105807:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010580e:	00 
c010580f:	89 04 24             	mov    %eax,(%esp)
c0105812:	e8 00 f8 ff ff       	call   c0105017 <page_remove>
    assert(page_ref(p1) == 0);
c0105817:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010581a:	89 04 24             	mov    %eax,(%esp)
c010581d:	e8 1f ed ff ff       	call   c0104541 <page_ref>
c0105822:	85 c0                	test   %eax,%eax
c0105824:	74 24                	je     c010584a <check_pgdir+0x5f0>
c0105826:	c7 44 24 0c 01 9d 10 	movl   $0xc0109d01,0xc(%esp)
c010582d:	c0 
c010582e:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105835:	c0 
c0105836:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c010583d:	00 
c010583e:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105845:	e8 97 b4 ff ff       	call   c0100ce1 <__panic>
    assert(page_ref(p2) == 0);
c010584a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010584d:	89 04 24             	mov    %eax,(%esp)
c0105850:	e8 ec ec ff ff       	call   c0104541 <page_ref>
c0105855:	85 c0                	test   %eax,%eax
c0105857:	74 24                	je     c010587d <check_pgdir+0x623>
c0105859:	c7 44 24 0c da 9c 10 	movl   $0xc0109cda,0xc(%esp)
c0105860:	c0 
c0105861:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105868:	c0 
c0105869:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c0105870:	00 
c0105871:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105878:	e8 64 b4 ff ff       	call   c0100ce1 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c010587d:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105882:	8b 00                	mov    (%eax),%eax
c0105884:	89 04 24             	mov    %eax,(%esp)
c0105887:	e8 9d ec ff ff       	call   c0104529 <pde2page>
c010588c:	89 04 24             	mov    %eax,(%esp)
c010588f:	e8 ad ec ff ff       	call   c0104541 <page_ref>
c0105894:	83 f8 01             	cmp    $0x1,%eax
c0105897:	74 24                	je     c01058bd <check_pgdir+0x663>
c0105899:	c7 44 24 0c 14 9d 10 	movl   $0xc0109d14,0xc(%esp)
c01058a0:	c0 
c01058a1:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c01058a8:	c0 
c01058a9:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c01058b0:	00 
c01058b1:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c01058b8:	e8 24 b4 ff ff       	call   c0100ce1 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c01058bd:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01058c2:	8b 00                	mov    (%eax),%eax
c01058c4:	89 04 24             	mov    %eax,(%esp)
c01058c7:	e8 5d ec ff ff       	call   c0104529 <pde2page>
c01058cc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01058d3:	00 
c01058d4:	89 04 24             	mov    %eax,(%esp)
c01058d7:	e8 d5 ee ff ff       	call   c01047b1 <free_pages>
    boot_pgdir[0] = 0;
c01058dc:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01058e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01058e7:	c7 04 24 3b 9d 10 c0 	movl   $0xc0109d3b,(%esp)
c01058ee:	e8 64 aa ff ff       	call   c0100357 <cprintf>
}
c01058f3:	c9                   	leave  
c01058f4:	c3                   	ret    

c01058f5 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c01058f5:	55                   	push   %ebp
c01058f6:	89 e5                	mov    %esp,%ebp
c01058f8:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01058fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105902:	e9 ca 00 00 00       	jmp    c01059d1 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0105907:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010590a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010590d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105910:	c1 e8 0c             	shr    $0xc,%eax
c0105913:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105916:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c010591b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010591e:	72 23                	jb     c0105943 <check_boot_pgdir+0x4e>
c0105920:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105923:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105927:	c7 44 24 08 6c 99 10 	movl   $0xc010996c,0x8(%esp)
c010592e:	c0 
c010592f:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
c0105936:	00 
c0105937:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c010593e:	e8 9e b3 ff ff       	call   c0100ce1 <__panic>
c0105943:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105946:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010594b:	89 c2                	mov    %eax,%edx
c010594d:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105952:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105959:	00 
c010595a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010595e:	89 04 24             	mov    %eax,(%esp)
c0105961:	e8 bf f4 ff ff       	call   c0104e25 <get_pte>
c0105966:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105969:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010596d:	75 24                	jne    c0105993 <check_boot_pgdir+0x9e>
c010596f:	c7 44 24 0c 58 9d 10 	movl   $0xc0109d58,0xc(%esp)
c0105976:	c0 
c0105977:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c010597e:	c0 
c010597f:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
c0105986:	00 
c0105987:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c010598e:	e8 4e b3 ff ff       	call   c0100ce1 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0105993:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105996:	8b 00                	mov    (%eax),%eax
c0105998:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010599d:	89 c2                	mov    %eax,%edx
c010599f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059a2:	39 c2                	cmp    %eax,%edx
c01059a4:	74 24                	je     c01059ca <check_boot_pgdir+0xd5>
c01059a6:	c7 44 24 0c 95 9d 10 	movl   $0xc0109d95,0xc(%esp)
c01059ad:	c0 
c01059ae:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c01059b5:	c0 
c01059b6:	c7 44 24 04 3c 02 00 	movl   $0x23c,0x4(%esp)
c01059bd:	00 
c01059be:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c01059c5:	e8 17 b3 ff ff       	call   c0100ce1 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01059ca:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01059d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01059d4:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c01059d9:	39 c2                	cmp    %eax,%edx
c01059db:	0f 82 26 ff ff ff    	jb     c0105907 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01059e1:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01059e6:	05 ac 0f 00 00       	add    $0xfac,%eax
c01059eb:	8b 00                	mov    (%eax),%eax
c01059ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01059f2:	89 c2                	mov    %eax,%edx
c01059f4:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c01059f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01059fc:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0105a03:	77 23                	ja     c0105a28 <check_boot_pgdir+0x133>
c0105a05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a08:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105a0c:	c7 44 24 08 90 99 10 	movl   $0xc0109990,0x8(%esp)
c0105a13:	c0 
c0105a14:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c0105a1b:	00 
c0105a1c:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105a23:	e8 b9 b2 ff ff       	call   c0100ce1 <__panic>
c0105a28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a2b:	05 00 00 00 40       	add    $0x40000000,%eax
c0105a30:	39 c2                	cmp    %eax,%edx
c0105a32:	74 24                	je     c0105a58 <check_boot_pgdir+0x163>
c0105a34:	c7 44 24 0c ac 9d 10 	movl   $0xc0109dac,0xc(%esp)
c0105a3b:	c0 
c0105a3c:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105a43:	c0 
c0105a44:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c0105a4b:	00 
c0105a4c:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105a53:	e8 89 b2 ff ff       	call   c0100ce1 <__panic>

    assert(boot_pgdir[0] == 0);
c0105a58:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105a5d:	8b 00                	mov    (%eax),%eax
c0105a5f:	85 c0                	test   %eax,%eax
c0105a61:	74 24                	je     c0105a87 <check_boot_pgdir+0x192>
c0105a63:	c7 44 24 0c e0 9d 10 	movl   $0xc0109de0,0xc(%esp)
c0105a6a:	c0 
c0105a6b:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105a72:	c0 
c0105a73:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c0105a7a:	00 
c0105a7b:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105a82:	e8 5a b2 ff ff       	call   c0100ce1 <__panic>

    struct Page *p;
    p = alloc_page();
c0105a87:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105a8e:	e8 b3 ec ff ff       	call   c0104746 <alloc_pages>
c0105a93:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0105a96:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105a9b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105aa2:	00 
c0105aa3:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0105aaa:	00 
c0105aab:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105aae:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105ab2:	89 04 24             	mov    %eax,(%esp)
c0105ab5:	e8 a1 f5 ff ff       	call   c010505b <page_insert>
c0105aba:	85 c0                	test   %eax,%eax
c0105abc:	74 24                	je     c0105ae2 <check_boot_pgdir+0x1ed>
c0105abe:	c7 44 24 0c f4 9d 10 	movl   $0xc0109df4,0xc(%esp)
c0105ac5:	c0 
c0105ac6:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105acd:	c0 
c0105ace:	c7 44 24 04 45 02 00 	movl   $0x245,0x4(%esp)
c0105ad5:	00 
c0105ad6:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105add:	e8 ff b1 ff ff       	call   c0100ce1 <__panic>
    assert(page_ref(p) == 1);
c0105ae2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ae5:	89 04 24             	mov    %eax,(%esp)
c0105ae8:	e8 54 ea ff ff       	call   c0104541 <page_ref>
c0105aed:	83 f8 01             	cmp    $0x1,%eax
c0105af0:	74 24                	je     c0105b16 <check_boot_pgdir+0x221>
c0105af2:	c7 44 24 0c 22 9e 10 	movl   $0xc0109e22,0xc(%esp)
c0105af9:	c0 
c0105afa:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105b01:	c0 
c0105b02:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
c0105b09:	00 
c0105b0a:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105b11:	e8 cb b1 ff ff       	call   c0100ce1 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0105b16:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105b1b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105b22:	00 
c0105b23:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0105b2a:	00 
c0105b2b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105b2e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105b32:	89 04 24             	mov    %eax,(%esp)
c0105b35:	e8 21 f5 ff ff       	call   c010505b <page_insert>
c0105b3a:	85 c0                	test   %eax,%eax
c0105b3c:	74 24                	je     c0105b62 <check_boot_pgdir+0x26d>
c0105b3e:	c7 44 24 0c 34 9e 10 	movl   $0xc0109e34,0xc(%esp)
c0105b45:	c0 
c0105b46:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105b4d:	c0 
c0105b4e:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
c0105b55:	00 
c0105b56:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105b5d:	e8 7f b1 ff ff       	call   c0100ce1 <__panic>
    assert(page_ref(p) == 2);
c0105b62:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b65:	89 04 24             	mov    %eax,(%esp)
c0105b68:	e8 d4 e9 ff ff       	call   c0104541 <page_ref>
c0105b6d:	83 f8 02             	cmp    $0x2,%eax
c0105b70:	74 24                	je     c0105b96 <check_boot_pgdir+0x2a1>
c0105b72:	c7 44 24 0c 6b 9e 10 	movl   $0xc0109e6b,0xc(%esp)
c0105b79:	c0 
c0105b7a:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105b81:	c0 
c0105b82:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c0105b89:	00 
c0105b8a:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105b91:	e8 4b b1 ff ff       	call   c0100ce1 <__panic>

    const char *str = "ucore: Hello world!!";
c0105b96:	c7 45 dc 7c 9e 10 c0 	movl   $0xc0109e7c,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0105b9d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ba4:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105bab:	e8 ca 2c 00 00       	call   c010887a <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0105bb0:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0105bb7:	00 
c0105bb8:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105bbf:	e8 2f 2d 00 00       	call   c01088f3 <strcmp>
c0105bc4:	85 c0                	test   %eax,%eax
c0105bc6:	74 24                	je     c0105bec <check_boot_pgdir+0x2f7>
c0105bc8:	c7 44 24 0c 94 9e 10 	movl   $0xc0109e94,0xc(%esp)
c0105bcf:	c0 
c0105bd0:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105bd7:	c0 
c0105bd8:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
c0105bdf:	00 
c0105be0:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105be7:	e8 f5 b0 ff ff       	call   c0100ce1 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0105bec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105bef:	89 04 24             	mov    %eax,(%esp)
c0105bf2:	e8 56 e8 ff ff       	call   c010444d <page2kva>
c0105bf7:	05 00 01 00 00       	add    $0x100,%eax
c0105bfc:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0105bff:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105c06:	e8 17 2c 00 00       	call   c0108822 <strlen>
c0105c0b:	85 c0                	test   %eax,%eax
c0105c0d:	74 24                	je     c0105c33 <check_boot_pgdir+0x33e>
c0105c0f:	c7 44 24 0c cc 9e 10 	movl   $0xc0109ecc,0xc(%esp)
c0105c16:	c0 
c0105c17:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105c1e:	c0 
c0105c1f:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
c0105c26:	00 
c0105c27:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105c2e:	e8 ae b0 ff ff       	call   c0100ce1 <__panic>

    free_page(p);
c0105c33:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105c3a:	00 
c0105c3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c3e:	89 04 24             	mov    %eax,(%esp)
c0105c41:	e8 6b eb ff ff       	call   c01047b1 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0105c46:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105c4b:	8b 00                	mov    (%eax),%eax
c0105c4d:	89 04 24             	mov    %eax,(%esp)
c0105c50:	e8 d4 e8 ff ff       	call   c0104529 <pde2page>
c0105c55:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105c5c:	00 
c0105c5d:	89 04 24             	mov    %eax,(%esp)
c0105c60:	e8 4c eb ff ff       	call   c01047b1 <free_pages>
    boot_pgdir[0] = 0;
c0105c65:	a1 e0 09 12 c0       	mov    0xc01209e0,%eax
c0105c6a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105c70:	c7 04 24 f0 9e 10 c0 	movl   $0xc0109ef0,(%esp)
c0105c77:	e8 db a6 ff ff       	call   c0100357 <cprintf>
}
c0105c7c:	c9                   	leave  
c0105c7d:	c3                   	ret    

c0105c7e <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105c7e:	55                   	push   %ebp
c0105c7f:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105c81:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c84:	83 e0 04             	and    $0x4,%eax
c0105c87:	85 c0                	test   %eax,%eax
c0105c89:	74 07                	je     c0105c92 <perm2str+0x14>
c0105c8b:	b8 75 00 00 00       	mov    $0x75,%eax
c0105c90:	eb 05                	jmp    c0105c97 <perm2str+0x19>
c0105c92:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105c97:	a2 28 40 12 c0       	mov    %al,0xc0124028
    str[1] = 'r';
c0105c9c:	c6 05 29 40 12 c0 72 	movb   $0x72,0xc0124029
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105ca3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ca6:	83 e0 02             	and    $0x2,%eax
c0105ca9:	85 c0                	test   %eax,%eax
c0105cab:	74 07                	je     c0105cb4 <perm2str+0x36>
c0105cad:	b8 77 00 00 00       	mov    $0x77,%eax
c0105cb2:	eb 05                	jmp    c0105cb9 <perm2str+0x3b>
c0105cb4:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105cb9:	a2 2a 40 12 c0       	mov    %al,0xc012402a
    str[3] = '\0';
c0105cbe:	c6 05 2b 40 12 c0 00 	movb   $0x0,0xc012402b
    return str;
c0105cc5:	b8 28 40 12 c0       	mov    $0xc0124028,%eax
}
c0105cca:	5d                   	pop    %ebp
c0105ccb:	c3                   	ret    

c0105ccc <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0105ccc:	55                   	push   %ebp
c0105ccd:	89 e5                	mov    %esp,%ebp
c0105ccf:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0105cd2:	8b 45 10             	mov    0x10(%ebp),%eax
c0105cd5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105cd8:	72 0a                	jb     c0105ce4 <get_pgtable_items+0x18>
        return 0;
c0105cda:	b8 00 00 00 00       	mov    $0x0,%eax
c0105cdf:	e9 9c 00 00 00       	jmp    c0105d80 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105ce4:	eb 04                	jmp    c0105cea <get_pgtable_items+0x1e>
        start ++;
c0105ce6:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105cea:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ced:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105cf0:	73 18                	jae    c0105d0a <get_pgtable_items+0x3e>
c0105cf2:	8b 45 10             	mov    0x10(%ebp),%eax
c0105cf5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105cfc:	8b 45 14             	mov    0x14(%ebp),%eax
c0105cff:	01 d0                	add    %edx,%eax
c0105d01:	8b 00                	mov    (%eax),%eax
c0105d03:	83 e0 01             	and    $0x1,%eax
c0105d06:	85 c0                	test   %eax,%eax
c0105d08:	74 dc                	je     c0105ce6 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c0105d0a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d0d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105d10:	73 69                	jae    c0105d7b <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0105d12:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105d16:	74 08                	je     c0105d20 <get_pgtable_items+0x54>
            *left_store = start;
c0105d18:	8b 45 18             	mov    0x18(%ebp),%eax
c0105d1b:	8b 55 10             	mov    0x10(%ebp),%edx
c0105d1e:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0105d20:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d23:	8d 50 01             	lea    0x1(%eax),%edx
c0105d26:	89 55 10             	mov    %edx,0x10(%ebp)
c0105d29:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105d30:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d33:	01 d0                	add    %edx,%eax
c0105d35:	8b 00                	mov    (%eax),%eax
c0105d37:	83 e0 07             	and    $0x7,%eax
c0105d3a:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105d3d:	eb 04                	jmp    c0105d43 <get_pgtable_items+0x77>
            start ++;
c0105d3f:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105d43:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d46:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105d49:	73 1d                	jae    c0105d68 <get_pgtable_items+0x9c>
c0105d4b:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d4e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105d55:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d58:	01 d0                	add    %edx,%eax
c0105d5a:	8b 00                	mov    (%eax),%eax
c0105d5c:	83 e0 07             	and    $0x7,%eax
c0105d5f:	89 c2                	mov    %eax,%edx
c0105d61:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105d64:	39 c2                	cmp    %eax,%edx
c0105d66:	74 d7                	je     c0105d3f <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c0105d68:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105d6c:	74 08                	je     c0105d76 <get_pgtable_items+0xaa>
            *right_store = start;
c0105d6e:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105d71:	8b 55 10             	mov    0x10(%ebp),%edx
c0105d74:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0105d76:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105d79:	eb 05                	jmp    c0105d80 <get_pgtable_items+0xb4>
    }
    return 0;
c0105d7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105d80:	c9                   	leave  
c0105d81:	c3                   	ret    

c0105d82 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0105d82:	55                   	push   %ebp
c0105d83:	89 e5                	mov    %esp,%ebp
c0105d85:	57                   	push   %edi
c0105d86:	56                   	push   %esi
c0105d87:	53                   	push   %ebx
c0105d88:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105d8b:	c7 04 24 10 9f 10 c0 	movl   $0xc0109f10,(%esp)
c0105d92:	e8 c0 a5 ff ff       	call   c0100357 <cprintf>
    size_t left, right = 0, perm;
c0105d97:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105d9e:	e9 fa 00 00 00       	jmp    c0105e9d <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105da3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105da6:	89 04 24             	mov    %eax,(%esp)
c0105da9:	e8 d0 fe ff ff       	call   c0105c7e <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105dae:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105db1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105db4:	29 d1                	sub    %edx,%ecx
c0105db6:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105db8:	89 d6                	mov    %edx,%esi
c0105dba:	c1 e6 16             	shl    $0x16,%esi
c0105dbd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105dc0:	89 d3                	mov    %edx,%ebx
c0105dc2:	c1 e3 16             	shl    $0x16,%ebx
c0105dc5:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105dc8:	89 d1                	mov    %edx,%ecx
c0105dca:	c1 e1 16             	shl    $0x16,%ecx
c0105dcd:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0105dd0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105dd3:	29 d7                	sub    %edx,%edi
c0105dd5:	89 fa                	mov    %edi,%edx
c0105dd7:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105ddb:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105ddf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105de3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105de7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105deb:	c7 04 24 41 9f 10 c0 	movl   $0xc0109f41,(%esp)
c0105df2:	e8 60 a5 ff ff       	call   c0100357 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0105df7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105dfa:	c1 e0 0a             	shl    $0xa,%eax
c0105dfd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105e00:	eb 54                	jmp    c0105e56 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105e02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105e05:	89 04 24             	mov    %eax,(%esp)
c0105e08:	e8 71 fe ff ff       	call   c0105c7e <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0105e0d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0105e10:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105e13:	29 d1                	sub    %edx,%ecx
c0105e15:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105e17:	89 d6                	mov    %edx,%esi
c0105e19:	c1 e6 0c             	shl    $0xc,%esi
c0105e1c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105e1f:	89 d3                	mov    %edx,%ebx
c0105e21:	c1 e3 0c             	shl    $0xc,%ebx
c0105e24:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105e27:	c1 e2 0c             	shl    $0xc,%edx
c0105e2a:	89 d1                	mov    %edx,%ecx
c0105e2c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0105e2f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105e32:	29 d7                	sub    %edx,%edi
c0105e34:	89 fa                	mov    %edi,%edx
c0105e36:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105e3a:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105e3e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105e42:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105e46:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105e4a:	c7 04 24 60 9f 10 c0 	movl   $0xc0109f60,(%esp)
c0105e51:	e8 01 a5 ff ff       	call   c0100357 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105e56:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0105e5b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105e5e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105e61:	89 ce                	mov    %ecx,%esi
c0105e63:	c1 e6 0a             	shl    $0xa,%esi
c0105e66:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0105e69:	89 cb                	mov    %ecx,%ebx
c0105e6b:	c1 e3 0a             	shl    $0xa,%ebx
c0105e6e:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0105e71:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105e75:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c0105e78:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105e7c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105e80:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105e84:	89 74 24 04          	mov    %esi,0x4(%esp)
c0105e88:	89 1c 24             	mov    %ebx,(%esp)
c0105e8b:	e8 3c fe ff ff       	call   c0105ccc <get_pgtable_items>
c0105e90:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105e93:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105e97:	0f 85 65 ff ff ff    	jne    c0105e02 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105e9d:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0105ea2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105ea5:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0105ea8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105eac:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0105eaf:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0105eb3:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105eb7:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105ebb:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0105ec2:	00 
c0105ec3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0105eca:	e8 fd fd ff ff       	call   c0105ccc <get_pgtable_items>
c0105ecf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105ed2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105ed6:	0f 85 c7 fe ff ff    	jne    c0105da3 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0105edc:	c7 04 24 84 9f 10 c0 	movl   $0xc0109f84,(%esp)
c0105ee3:	e8 6f a4 ff ff       	call   c0100357 <cprintf>
}
c0105ee8:	83 c4 4c             	add    $0x4c,%esp
c0105eeb:	5b                   	pop    %ebx
c0105eec:	5e                   	pop    %esi
c0105eed:	5f                   	pop    %edi
c0105eee:	5d                   	pop    %ebp
c0105eef:	c3                   	ret    

c0105ef0 <kmalloc>:

void *
kmalloc(size_t n) {
c0105ef0:	55                   	push   %ebp
c0105ef1:	89 e5                	mov    %esp,%ebp
c0105ef3:	83 ec 28             	sub    $0x28,%esp
    void * ptr=NULL;
c0105ef6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct Page *base=NULL;
c0105efd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    assert(n > 0 && n < 1024*0124);
c0105f04:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105f08:	74 09                	je     c0105f13 <kmalloc+0x23>
c0105f0a:	81 7d 08 ff 4f 01 00 	cmpl   $0x14fff,0x8(%ebp)
c0105f11:	76 24                	jbe    c0105f37 <kmalloc+0x47>
c0105f13:	c7 44 24 0c b5 9f 10 	movl   $0xc0109fb5,0xc(%esp)
c0105f1a:	c0 
c0105f1b:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105f22:	c0 
c0105f23:	c7 44 24 04 9b 02 00 	movl   $0x29b,0x4(%esp)
c0105f2a:	00 
c0105f2b:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105f32:	e8 aa ad ff ff       	call   c0100ce1 <__panic>
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0105f37:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f3a:	05 ff 0f 00 00       	add    $0xfff,%eax
c0105f3f:	c1 e8 0c             	shr    $0xc,%eax
c0105f42:	89 45 ec             	mov    %eax,-0x14(%ebp)
    base = alloc_pages(num_pages);
c0105f45:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f48:	89 04 24             	mov    %eax,(%esp)
c0105f4b:	e8 f6 e7 ff ff       	call   c0104746 <alloc_pages>
c0105f50:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(base != NULL);
c0105f53:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105f57:	75 24                	jne    c0105f7d <kmalloc+0x8d>
c0105f59:	c7 44 24 0c cc 9f 10 	movl   $0xc0109fcc,0xc(%esp)
c0105f60:	c0 
c0105f61:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105f68:	c0 
c0105f69:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
c0105f70:	00 
c0105f71:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105f78:	e8 64 ad ff ff       	call   c0100ce1 <__panic>
    ptr=page2kva(base);
c0105f7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f80:	89 04 24             	mov    %eax,(%esp)
c0105f83:	e8 c5 e4 ff ff       	call   c010444d <page2kva>
c0105f88:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ptr;
c0105f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105f8e:	c9                   	leave  
c0105f8f:	c3                   	ret    

c0105f90 <kfree>:

void 
kfree(void *ptr, size_t n) {
c0105f90:	55                   	push   %ebp
c0105f91:	89 e5                	mov    %esp,%ebp
c0105f93:	83 ec 28             	sub    $0x28,%esp
    assert(n > 0 && n < 1024*0124);
c0105f96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105f9a:	74 09                	je     c0105fa5 <kfree+0x15>
c0105f9c:	81 7d 0c ff 4f 01 00 	cmpl   $0x14fff,0xc(%ebp)
c0105fa3:	76 24                	jbe    c0105fc9 <kfree+0x39>
c0105fa5:	c7 44 24 0c b5 9f 10 	movl   $0xc0109fb5,0xc(%esp)
c0105fac:	c0 
c0105fad:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105fb4:	c0 
c0105fb5:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
c0105fbc:	00 
c0105fbd:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105fc4:	e8 18 ad ff ff       	call   c0100ce1 <__panic>
    assert(ptr != NULL);
c0105fc9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105fcd:	75 24                	jne    c0105ff3 <kfree+0x63>
c0105fcf:	c7 44 24 0c d9 9f 10 	movl   $0xc0109fd9,0xc(%esp)
c0105fd6:	c0 
c0105fd7:	c7 44 24 08 59 9a 10 	movl   $0xc0109a59,0x8(%esp)
c0105fde:	c0 
c0105fdf:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
c0105fe6:	00 
c0105fe7:	c7 04 24 34 9a 10 c0 	movl   $0xc0109a34,(%esp)
c0105fee:	e8 ee ac ff ff       	call   c0100ce1 <__panic>
    struct Page *base=NULL;
c0105ff3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0105ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ffd:	05 ff 0f 00 00       	add    $0xfff,%eax
c0106002:	c1 e8 0c             	shr    $0xc,%eax
c0106005:	89 45 f0             	mov    %eax,-0x10(%ebp)
    base = kva2page(ptr);
c0106008:	8b 45 08             	mov    0x8(%ebp),%eax
c010600b:	89 04 24             	mov    %eax,(%esp)
c010600e:	e8 8e e4 ff ff       	call   c01044a1 <kva2page>
c0106013:	89 45 f4             	mov    %eax,-0xc(%ebp)
    free_pages(base, num_pages);
c0106016:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106019:	89 44 24 04          	mov    %eax,0x4(%esp)
c010601d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106020:	89 04 24             	mov    %eax,(%esp)
c0106023:	e8 89 e7 ff ff       	call   c01047b1 <free_pages>
}
c0106028:	c9                   	leave  
c0106029:	c3                   	ret    

c010602a <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c010602a:	55                   	push   %ebp
c010602b:	89 e5                	mov    %esp,%ebp
c010602d:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0106030:	8b 45 08             	mov    0x8(%ebp),%eax
c0106033:	c1 e8 0c             	shr    $0xc,%eax
c0106036:	89 c2                	mov    %eax,%edx
c0106038:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c010603d:	39 c2                	cmp    %eax,%edx
c010603f:	72 1c                	jb     c010605d <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0106041:	c7 44 24 08 e8 9f 10 	movl   $0xc0109fe8,0x8(%esp)
c0106048:	c0 
c0106049:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0106050:	00 
c0106051:	c7 04 24 07 a0 10 c0 	movl   $0xc010a007,(%esp)
c0106058:	e8 84 ac ff ff       	call   c0100ce1 <__panic>
    }
    return &pages[PPN(pa)];
c010605d:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c0106062:	8b 55 08             	mov    0x8(%ebp),%edx
c0106065:	c1 ea 0c             	shr    $0xc,%edx
c0106068:	c1 e2 05             	shl    $0x5,%edx
c010606b:	01 d0                	add    %edx,%eax
}
c010606d:	c9                   	leave  
c010606e:	c3                   	ret    

c010606f <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c010606f:	55                   	push   %ebp
c0106070:	89 e5                	mov    %esp,%ebp
c0106072:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0106075:	8b 45 08             	mov    0x8(%ebp),%eax
c0106078:	83 e0 01             	and    $0x1,%eax
c010607b:	85 c0                	test   %eax,%eax
c010607d:	75 1c                	jne    c010609b <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c010607f:	c7 44 24 08 18 a0 10 	movl   $0xc010a018,0x8(%esp)
c0106086:	c0 
c0106087:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010608e:	00 
c010608f:	c7 04 24 07 a0 10 c0 	movl   $0xc010a007,(%esp)
c0106096:	e8 46 ac ff ff       	call   c0100ce1 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c010609b:	8b 45 08             	mov    0x8(%ebp),%eax
c010609e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01060a3:	89 04 24             	mov    %eax,(%esp)
c01060a6:	e8 7f ff ff ff       	call   c010602a <pa2page>
}
c01060ab:	c9                   	leave  
c01060ac:	c3                   	ret    

c01060ad <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c01060ad:	55                   	push   %ebp
c01060ae:	89 e5                	mov    %esp,%ebp
c01060b0:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c01060b3:	e8 e5 1e 00 00       	call   c0107f9d <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c01060b8:	a1 fc 40 12 c0       	mov    0xc01240fc,%eax
c01060bd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c01060c2:	76 0c                	jbe    c01060d0 <swap_init+0x23>
c01060c4:	a1 fc 40 12 c0       	mov    0xc01240fc,%eax
c01060c9:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c01060ce:	76 25                	jbe    c01060f5 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c01060d0:	a1 fc 40 12 c0       	mov    0xc01240fc,%eax
c01060d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01060d9:	c7 44 24 08 39 a0 10 	movl   $0xc010a039,0x8(%esp)
c01060e0:	c0 
c01060e1:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c01060e8:	00 
c01060e9:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c01060f0:	e8 ec ab ff ff       	call   c0100ce1 <__panic>
     }
     

     sm = &swap_manager_fifo;
c01060f5:	c7 05 34 40 12 c0 40 	movl   $0xc0120a40,0xc0124034
c01060fc:	0a 12 c0 
     int r = sm->init();
c01060ff:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c0106104:	8b 40 04             	mov    0x4(%eax),%eax
c0106107:	ff d0                	call   *%eax
c0106109:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c010610c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106110:	75 26                	jne    c0106138 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0106112:	c7 05 2c 40 12 c0 01 	movl   $0x1,0xc012402c
c0106119:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c010611c:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c0106121:	8b 00                	mov    (%eax),%eax
c0106123:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106127:	c7 04 24 63 a0 10 c0 	movl   $0xc010a063,(%esp)
c010612e:	e8 24 a2 ff ff       	call   c0100357 <cprintf>
          check_swap();
c0106133:	e8 a4 04 00 00       	call   c01065dc <check_swap>
     }

     return r;
c0106138:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010613b:	c9                   	leave  
c010613c:	c3                   	ret    

c010613d <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c010613d:	55                   	push   %ebp
c010613e:	89 e5                	mov    %esp,%ebp
c0106140:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0106143:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c0106148:	8b 40 08             	mov    0x8(%eax),%eax
c010614b:	8b 55 08             	mov    0x8(%ebp),%edx
c010614e:	89 14 24             	mov    %edx,(%esp)
c0106151:	ff d0                	call   *%eax
}
c0106153:	c9                   	leave  
c0106154:	c3                   	ret    

c0106155 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0106155:	55                   	push   %ebp
c0106156:	89 e5                	mov    %esp,%ebp
c0106158:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c010615b:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c0106160:	8b 40 0c             	mov    0xc(%eax),%eax
c0106163:	8b 55 08             	mov    0x8(%ebp),%edx
c0106166:	89 14 24             	mov    %edx,(%esp)
c0106169:	ff d0                	call   *%eax
}
c010616b:	c9                   	leave  
c010616c:	c3                   	ret    

c010616d <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c010616d:	55                   	push   %ebp
c010616e:	89 e5                	mov    %esp,%ebp
c0106170:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0106173:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c0106178:	8b 40 10             	mov    0x10(%eax),%eax
c010617b:	8b 55 14             	mov    0x14(%ebp),%edx
c010617e:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106182:	8b 55 10             	mov    0x10(%ebp),%edx
c0106185:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106189:	8b 55 0c             	mov    0xc(%ebp),%edx
c010618c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106190:	8b 55 08             	mov    0x8(%ebp),%edx
c0106193:	89 14 24             	mov    %edx,(%esp)
c0106196:	ff d0                	call   *%eax
}
c0106198:	c9                   	leave  
c0106199:	c3                   	ret    

c010619a <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010619a:	55                   	push   %ebp
c010619b:	89 e5                	mov    %esp,%ebp
c010619d:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c01061a0:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c01061a5:	8b 40 14             	mov    0x14(%eax),%eax
c01061a8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01061ab:	89 54 24 04          	mov    %edx,0x4(%esp)
c01061af:	8b 55 08             	mov    0x8(%ebp),%edx
c01061b2:	89 14 24             	mov    %edx,(%esp)
c01061b5:	ff d0                	call   *%eax
}
c01061b7:	c9                   	leave  
c01061b8:	c3                   	ret    

c01061b9 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c01061b9:	55                   	push   %ebp
c01061ba:	89 e5                	mov    %esp,%ebp
c01061bc:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c01061bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01061c6:	e9 5a 01 00 00       	jmp    c0106325 <swap_out+0x16c>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c01061cb:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c01061d0:	8b 40 18             	mov    0x18(%eax),%eax
c01061d3:	8b 55 10             	mov    0x10(%ebp),%edx
c01061d6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01061da:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c01061dd:	89 54 24 04          	mov    %edx,0x4(%esp)
c01061e1:	8b 55 08             	mov    0x8(%ebp),%edx
c01061e4:	89 14 24             	mov    %edx,(%esp)
c01061e7:	ff d0                	call   *%eax
c01061e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c01061ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01061f0:	74 18                	je     c010620a <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c01061f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01061f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01061f9:	c7 04 24 78 a0 10 c0 	movl   $0xc010a078,(%esp)
c0106200:	e8 52 a1 ff ff       	call   c0100357 <cprintf>
c0106205:	e9 27 01 00 00       	jmp    c0106331 <swap_out+0x178>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c010620a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010620d:	8b 40 1c             	mov    0x1c(%eax),%eax
c0106210:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0106213:	8b 45 08             	mov    0x8(%ebp),%eax
c0106216:	8b 40 0c             	mov    0xc(%eax),%eax
c0106219:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106220:	00 
c0106221:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106224:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106228:	89 04 24             	mov    %eax,(%esp)
c010622b:	e8 f5 eb ff ff       	call   c0104e25 <get_pte>
c0106230:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0106233:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106236:	8b 00                	mov    (%eax),%eax
c0106238:	83 e0 01             	and    $0x1,%eax
c010623b:	85 c0                	test   %eax,%eax
c010623d:	75 24                	jne    c0106263 <swap_out+0xaa>
c010623f:	c7 44 24 0c a5 a0 10 	movl   $0xc010a0a5,0xc(%esp)
c0106246:	c0 
c0106247:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c010624e:	c0 
c010624f:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0106256:	00 
c0106257:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c010625e:	e8 7e aa ff ff       	call   c0100ce1 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0106263:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106266:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106269:	8b 52 1c             	mov    0x1c(%edx),%edx
c010626c:	c1 ea 0c             	shr    $0xc,%edx
c010626f:	83 c2 01             	add    $0x1,%edx
c0106272:	c1 e2 08             	shl    $0x8,%edx
c0106275:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106279:	89 14 24             	mov    %edx,(%esp)
c010627c:	e8 d6 1d 00 00       	call   c0108057 <swapfs_write>
c0106281:	85 c0                	test   %eax,%eax
c0106283:	74 34                	je     c01062b9 <swap_out+0x100>
                    cprintf("SWAP: failed to save\n");
c0106285:	c7 04 24 cf a0 10 c0 	movl   $0xc010a0cf,(%esp)
c010628c:	e8 c6 a0 ff ff       	call   c0100357 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0106291:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c0106296:	8b 40 10             	mov    0x10(%eax),%eax
c0106299:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010629c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01062a3:	00 
c01062a4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01062a8:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01062ab:	89 54 24 04          	mov    %edx,0x4(%esp)
c01062af:	8b 55 08             	mov    0x8(%ebp),%edx
c01062b2:	89 14 24             	mov    %edx,(%esp)
c01062b5:	ff d0                	call   *%eax
c01062b7:	eb 68                	jmp    c0106321 <swap_out+0x168>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c01062b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01062bc:	8b 40 1c             	mov    0x1c(%eax),%eax
c01062bf:	c1 e8 0c             	shr    $0xc,%eax
c01062c2:	83 c0 01             	add    $0x1,%eax
c01062c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01062c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01062cc:	89 44 24 08          	mov    %eax,0x8(%esp)
c01062d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062d3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01062d7:	c7 04 24 e8 a0 10 c0 	movl   $0xc010a0e8,(%esp)
c01062de:	e8 74 a0 ff ff       	call   c0100357 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c01062e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01062e6:	8b 40 1c             	mov    0x1c(%eax),%eax
c01062e9:	c1 e8 0c             	shr    $0xc,%eax
c01062ec:	83 c0 01             	add    $0x1,%eax
c01062ef:	c1 e0 08             	shl    $0x8,%eax
c01062f2:	89 c2                	mov    %eax,%edx
c01062f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01062f7:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c01062f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01062fc:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106303:	00 
c0106304:	89 04 24             	mov    %eax,(%esp)
c0106307:	e8 a5 e4 ff ff       	call   c01047b1 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c010630c:	8b 45 08             	mov    0x8(%ebp),%eax
c010630f:	8b 40 0c             	mov    0xc(%eax),%eax
c0106312:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106315:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106319:	89 04 24             	mov    %eax,(%esp)
c010631c:	e8 f3 ed ff ff       	call   c0105114 <tlb_invalidate>

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c0106321:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0106325:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106328:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010632b:	0f 85 9a fe ff ff    	jne    c01061cb <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c0106331:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106334:	c9                   	leave  
c0106335:	c3                   	ret    

c0106336 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0106336:	55                   	push   %ebp
c0106337:	89 e5                	mov    %esp,%ebp
c0106339:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c010633c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106343:	e8 fe e3 ff ff       	call   c0104746 <alloc_pages>
c0106348:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c010634b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010634f:	75 24                	jne    c0106375 <swap_in+0x3f>
c0106351:	c7 44 24 0c 28 a1 10 	movl   $0xc010a128,0xc(%esp)
c0106358:	c0 
c0106359:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c0106360:	c0 
c0106361:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c0106368:	00 
c0106369:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c0106370:	e8 6c a9 ff ff       	call   c0100ce1 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0106375:	8b 45 08             	mov    0x8(%ebp),%eax
c0106378:	8b 40 0c             	mov    0xc(%eax),%eax
c010637b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106382:	00 
c0106383:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106386:	89 54 24 04          	mov    %edx,0x4(%esp)
c010638a:	89 04 24             	mov    %eax,(%esp)
c010638d:	e8 93 ea ff ff       	call   c0104e25 <get_pte>
c0106392:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0106395:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106398:	8b 00                	mov    (%eax),%eax
c010639a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010639d:	89 54 24 04          	mov    %edx,0x4(%esp)
c01063a1:	89 04 24             	mov    %eax,(%esp)
c01063a4:	e8 3c 1c 00 00       	call   c0107fe5 <swapfs_read>
c01063a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01063ac:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01063b0:	74 2a                	je     c01063dc <swap_in+0xa6>
     {
        assert(r!=0);
c01063b2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01063b6:	75 24                	jne    c01063dc <swap_in+0xa6>
c01063b8:	c7 44 24 0c 35 a1 10 	movl   $0xc010a135,0xc(%esp)
c01063bf:	c0 
c01063c0:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c01063c7:	c0 
c01063c8:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c01063cf:	00 
c01063d0:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c01063d7:	e8 05 a9 ff ff       	call   c0100ce1 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c01063dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01063df:	8b 00                	mov    (%eax),%eax
c01063e1:	c1 e8 08             	shr    $0x8,%eax
c01063e4:	89 c2                	mov    %eax,%edx
c01063e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063e9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01063ed:	89 54 24 04          	mov    %edx,0x4(%esp)
c01063f1:	c7 04 24 3c a1 10 c0 	movl   $0xc010a13c,(%esp)
c01063f8:	e8 5a 9f ff ff       	call   c0100357 <cprintf>
     *ptr_result=result;
c01063fd:	8b 45 10             	mov    0x10(%ebp),%eax
c0106400:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106403:	89 10                	mov    %edx,(%eax)
     return 0;
c0106405:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010640a:	c9                   	leave  
c010640b:	c3                   	ret    

c010640c <check_content_set>:



static inline void
check_content_set(void)
{
c010640c:	55                   	push   %ebp
c010640d:	89 e5                	mov    %esp,%ebp
c010640f:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0106412:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106417:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c010641a:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c010641f:	83 f8 01             	cmp    $0x1,%eax
c0106422:	74 24                	je     c0106448 <check_content_set+0x3c>
c0106424:	c7 44 24 0c 7a a1 10 	movl   $0xc010a17a,0xc(%esp)
c010642b:	c0 
c010642c:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c0106433:	c0 
c0106434:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c010643b:	00 
c010643c:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c0106443:	e8 99 a8 ff ff       	call   c0100ce1 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0106448:	b8 10 10 00 00       	mov    $0x1010,%eax
c010644d:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0106450:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106455:	83 f8 01             	cmp    $0x1,%eax
c0106458:	74 24                	je     c010647e <check_content_set+0x72>
c010645a:	c7 44 24 0c 7a a1 10 	movl   $0xc010a17a,0xc(%esp)
c0106461:	c0 
c0106462:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c0106469:	c0 
c010646a:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0106471:	00 
c0106472:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c0106479:	e8 63 a8 ff ff       	call   c0100ce1 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c010647e:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106483:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106486:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c010648b:	83 f8 02             	cmp    $0x2,%eax
c010648e:	74 24                	je     c01064b4 <check_content_set+0xa8>
c0106490:	c7 44 24 0c 89 a1 10 	movl   $0xc010a189,0xc(%esp)
c0106497:	c0 
c0106498:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c010649f:	c0 
c01064a0:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c01064a7:	00 
c01064a8:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c01064af:	e8 2d a8 ff ff       	call   c0100ce1 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c01064b4:	b8 10 20 00 00       	mov    $0x2010,%eax
c01064b9:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c01064bc:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01064c1:	83 f8 02             	cmp    $0x2,%eax
c01064c4:	74 24                	je     c01064ea <check_content_set+0xde>
c01064c6:	c7 44 24 0c 89 a1 10 	movl   $0xc010a189,0xc(%esp)
c01064cd:	c0 
c01064ce:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c01064d5:	c0 
c01064d6:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c01064dd:	00 
c01064de:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c01064e5:	e8 f7 a7 ff ff       	call   c0100ce1 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c01064ea:	b8 00 30 00 00       	mov    $0x3000,%eax
c01064ef:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c01064f2:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01064f7:	83 f8 03             	cmp    $0x3,%eax
c01064fa:	74 24                	je     c0106520 <check_content_set+0x114>
c01064fc:	c7 44 24 0c 98 a1 10 	movl   $0xc010a198,0xc(%esp)
c0106503:	c0 
c0106504:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c010650b:	c0 
c010650c:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0106513:	00 
c0106514:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c010651b:	e8 c1 a7 ff ff       	call   c0100ce1 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c0106520:	b8 10 30 00 00       	mov    $0x3010,%eax
c0106525:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106528:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c010652d:	83 f8 03             	cmp    $0x3,%eax
c0106530:	74 24                	je     c0106556 <check_content_set+0x14a>
c0106532:	c7 44 24 0c 98 a1 10 	movl   $0xc010a198,0xc(%esp)
c0106539:	c0 
c010653a:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c0106541:	c0 
c0106542:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0106549:	00 
c010654a:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c0106551:	e8 8b a7 ff ff       	call   c0100ce1 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0106556:	b8 00 40 00 00       	mov    $0x4000,%eax
c010655b:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c010655e:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106563:	83 f8 04             	cmp    $0x4,%eax
c0106566:	74 24                	je     c010658c <check_content_set+0x180>
c0106568:	c7 44 24 0c a7 a1 10 	movl   $0xc010a1a7,0xc(%esp)
c010656f:	c0 
c0106570:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c0106577:	c0 
c0106578:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c010657f:	00 
c0106580:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c0106587:	e8 55 a7 ff ff       	call   c0100ce1 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c010658c:	b8 10 40 00 00       	mov    $0x4010,%eax
c0106591:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0106594:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106599:	83 f8 04             	cmp    $0x4,%eax
c010659c:	74 24                	je     c01065c2 <check_content_set+0x1b6>
c010659e:	c7 44 24 0c a7 a1 10 	movl   $0xc010a1a7,0xc(%esp)
c01065a5:	c0 
c01065a6:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c01065ad:	c0 
c01065ae:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c01065b5:	00 
c01065b6:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c01065bd:	e8 1f a7 ff ff       	call   c0100ce1 <__panic>
}
c01065c2:	c9                   	leave  
c01065c3:	c3                   	ret    

c01065c4 <check_content_access>:

static inline int
check_content_access(void)
{
c01065c4:	55                   	push   %ebp
c01065c5:	89 e5                	mov    %esp,%ebp
c01065c7:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c01065ca:	a1 34 40 12 c0       	mov    0xc0124034,%eax
c01065cf:	8b 40 1c             	mov    0x1c(%eax),%eax
c01065d2:	ff d0                	call   *%eax
c01065d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c01065d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01065da:	c9                   	leave  
c01065db:	c3                   	ret    

c01065dc <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c01065dc:	55                   	push   %ebp
c01065dd:	89 e5                	mov    %esp,%ebp
c01065df:	53                   	push   %ebx
c01065e0:	83 ec 74             	sub    $0x74,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c01065e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01065ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c01065f1:	c7 45 e8 40 40 12 c0 	movl   $0xc0124040,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c01065f8:	eb 6b                	jmp    c0106665 <check_swap+0x89>
        struct Page *p = le2page(le, page_link);
c01065fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01065fd:	83 e8 0c             	sub    $0xc,%eax
c0106600:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0106603:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106606:	83 c0 04             	add    $0x4,%eax
c0106609:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0106610:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106613:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106616:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106619:	0f a3 10             	bt     %edx,(%eax)
c010661c:	19 c0                	sbb    %eax,%eax
c010661e:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c0106621:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106625:	0f 95 c0             	setne  %al
c0106628:	0f b6 c0             	movzbl %al,%eax
c010662b:	85 c0                	test   %eax,%eax
c010662d:	75 24                	jne    c0106653 <check_swap+0x77>
c010662f:	c7 44 24 0c b6 a1 10 	movl   $0xc010a1b6,0xc(%esp)
c0106636:	c0 
c0106637:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c010663e:	c0 
c010663f:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0106646:	00 
c0106647:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c010664e:	e8 8e a6 ff ff       	call   c0100ce1 <__panic>
        count ++, total += p->property;
c0106653:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0106657:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010665a:	8b 50 08             	mov    0x8(%eax),%edx
c010665d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106660:	01 d0                	add    %edx,%eax
c0106662:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106665:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106668:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010666b:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010666e:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0106671:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106674:	81 7d e8 40 40 12 c0 	cmpl   $0xc0124040,-0x18(%ebp)
c010667b:	0f 85 79 ff ff ff    	jne    c01065fa <check_swap+0x1e>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c0106681:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0106684:	e8 5a e1 ff ff       	call   c01047e3 <nr_free_pages>
c0106689:	39 c3                	cmp    %eax,%ebx
c010668b:	74 24                	je     c01066b1 <check_swap+0xd5>
c010668d:	c7 44 24 0c c6 a1 10 	movl   $0xc010a1c6,0xc(%esp)
c0106694:	c0 
c0106695:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c010669c:	c0 
c010669d:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c01066a4:	00 
c01066a5:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c01066ac:	e8 30 a6 ff ff       	call   c0100ce1 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c01066b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01066b4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01066b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01066bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01066bf:	c7 04 24 e0 a1 10 c0 	movl   $0xc010a1e0,(%esp)
c01066c6:	e8 8c 9c ff ff       	call   c0100357 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c01066cb:	e8 13 0b 00 00       	call   c01071e3 <mm_create>
c01066d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(mm != NULL);
c01066d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01066d7:	75 24                	jne    c01066fd <check_swap+0x121>
c01066d9:	c7 44 24 0c 06 a2 10 	movl   $0xc010a206,0xc(%esp)
c01066e0:	c0 
c01066e1:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c01066e8:	c0 
c01066e9:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c01066f0:	00 
c01066f1:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c01066f8:	e8 e4 a5 ff ff       	call   c0100ce1 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c01066fd:	a1 2c 41 12 c0       	mov    0xc012412c,%eax
c0106702:	85 c0                	test   %eax,%eax
c0106704:	74 24                	je     c010672a <check_swap+0x14e>
c0106706:	c7 44 24 0c 11 a2 10 	movl   $0xc010a211,0xc(%esp)
c010670d:	c0 
c010670e:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c0106715:	c0 
c0106716:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c010671d:	00 
c010671e:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c0106725:	e8 b7 a5 ff ff       	call   c0100ce1 <__panic>

     check_mm_struct = mm;
c010672a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010672d:	a3 2c 41 12 c0       	mov    %eax,0xc012412c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0106732:	8b 15 e0 09 12 c0    	mov    0xc01209e0,%edx
c0106738:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010673b:	89 50 0c             	mov    %edx,0xc(%eax)
c010673e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106741:	8b 40 0c             	mov    0xc(%eax),%eax
c0106744:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(pgdir[0] == 0);
c0106747:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010674a:	8b 00                	mov    (%eax),%eax
c010674c:	85 c0                	test   %eax,%eax
c010674e:	74 24                	je     c0106774 <check_swap+0x198>
c0106750:	c7 44 24 0c 29 a2 10 	movl   $0xc010a229,0xc(%esp)
c0106757:	c0 
c0106758:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c010675f:	c0 
c0106760:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0106767:	00 
c0106768:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c010676f:	e8 6d a5 ff ff       	call   c0100ce1 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0106774:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c010677b:	00 
c010677c:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0106783:	00 
c0106784:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c010678b:	e8 cb 0a 00 00       	call   c010725b <vma_create>
c0106790:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(vma != NULL);
c0106793:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0106797:	75 24                	jne    c01067bd <check_swap+0x1e1>
c0106799:	c7 44 24 0c 37 a2 10 	movl   $0xc010a237,0xc(%esp)
c01067a0:	c0 
c01067a1:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c01067a8:	c0 
c01067a9:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c01067b0:	00 
c01067b1:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c01067b8:	e8 24 a5 ff ff       	call   c0100ce1 <__panic>

     insert_vma_struct(mm, vma);
c01067bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01067c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01067c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01067c7:	89 04 24             	mov    %eax,(%esp)
c01067ca:	e8 1c 0c 00 00       	call   c01073eb <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c01067cf:	c7 04 24 44 a2 10 c0 	movl   $0xc010a244,(%esp)
c01067d6:	e8 7c 9b ff ff       	call   c0100357 <cprintf>
     pte_t *temp_ptep=NULL;
c01067db:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c01067e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01067e5:	8b 40 0c             	mov    0xc(%eax),%eax
c01067e8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01067ef:	00 
c01067f0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01067f7:	00 
c01067f8:	89 04 24             	mov    %eax,(%esp)
c01067fb:	e8 25 e6 ff ff       	call   c0104e25 <get_pte>
c0106800:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(temp_ptep!= NULL);
c0106803:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0106807:	75 24                	jne    c010682d <check_swap+0x251>
c0106809:	c7 44 24 0c 78 a2 10 	movl   $0xc010a278,0xc(%esp)
c0106810:	c0 
c0106811:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c0106818:	c0 
c0106819:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c0106820:	00 
c0106821:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c0106828:	e8 b4 a4 ff ff       	call   c0100ce1 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c010682d:	c7 04 24 8c a2 10 c0 	movl   $0xc010a28c,(%esp)
c0106834:	e8 1e 9b ff ff       	call   c0100357 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106839:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106840:	e9 a3 00 00 00       	jmp    c01068e8 <check_swap+0x30c>
          check_rp[i] = alloc_page();
c0106845:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010684c:	e8 f5 de ff ff       	call   c0104746 <alloc_pages>
c0106851:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106854:	89 04 95 60 40 12 c0 	mov    %eax,-0x3fedbfa0(,%edx,4)
          assert(check_rp[i] != NULL );
c010685b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010685e:	8b 04 85 60 40 12 c0 	mov    -0x3fedbfa0(,%eax,4),%eax
c0106865:	85 c0                	test   %eax,%eax
c0106867:	75 24                	jne    c010688d <check_swap+0x2b1>
c0106869:	c7 44 24 0c b0 a2 10 	movl   $0xc010a2b0,0xc(%esp)
c0106870:	c0 
c0106871:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c0106878:	c0 
c0106879:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0106880:	00 
c0106881:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c0106888:	e8 54 a4 ff ff       	call   c0100ce1 <__panic>
          assert(!PageProperty(check_rp[i]));
c010688d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106890:	8b 04 85 60 40 12 c0 	mov    -0x3fedbfa0(,%eax,4),%eax
c0106897:	83 c0 04             	add    $0x4,%eax
c010689a:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c01068a1:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01068a4:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01068a7:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01068aa:	0f a3 10             	bt     %edx,(%eax)
c01068ad:	19 c0                	sbb    %eax,%eax
c01068af:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c01068b2:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c01068b6:	0f 95 c0             	setne  %al
c01068b9:	0f b6 c0             	movzbl %al,%eax
c01068bc:	85 c0                	test   %eax,%eax
c01068be:	74 24                	je     c01068e4 <check_swap+0x308>
c01068c0:	c7 44 24 0c c4 a2 10 	movl   $0xc010a2c4,0xc(%esp)
c01068c7:	c0 
c01068c8:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c01068cf:	c0 
c01068d0:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c01068d7:	00 
c01068d8:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c01068df:	e8 fd a3 ff ff       	call   c0100ce1 <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01068e4:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01068e8:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01068ec:	0f 8e 53 ff ff ff    	jle    c0106845 <check_swap+0x269>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c01068f2:	a1 40 40 12 c0       	mov    0xc0124040,%eax
c01068f7:	8b 15 44 40 12 c0    	mov    0xc0124044,%edx
c01068fd:	89 45 98             	mov    %eax,-0x68(%ebp)
c0106900:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0106903:	c7 45 a8 40 40 12 c0 	movl   $0xc0124040,-0x58(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010690a:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010690d:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0106910:	89 50 04             	mov    %edx,0x4(%eax)
c0106913:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0106916:	8b 50 04             	mov    0x4(%eax),%edx
c0106919:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010691c:	89 10                	mov    %edx,(%eax)
c010691e:	c7 45 a4 40 40 12 c0 	movl   $0xc0124040,-0x5c(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0106925:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106928:	8b 40 04             	mov    0x4(%eax),%eax
c010692b:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
c010692e:	0f 94 c0             	sete   %al
c0106931:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0106934:	85 c0                	test   %eax,%eax
c0106936:	75 24                	jne    c010695c <check_swap+0x380>
c0106938:	c7 44 24 0c df a2 10 	movl   $0xc010a2df,0xc(%esp)
c010693f:	c0 
c0106940:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c0106947:	c0 
c0106948:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c010694f:	00 
c0106950:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c0106957:	e8 85 a3 ff ff       	call   c0100ce1 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c010695c:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c0106961:	89 45 d0             	mov    %eax,-0x30(%ebp)
     nr_free = 0;
c0106964:	c7 05 48 40 12 c0 00 	movl   $0x0,0xc0124048
c010696b:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010696e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106975:	eb 1e                	jmp    c0106995 <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c0106977:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010697a:	8b 04 85 60 40 12 c0 	mov    -0x3fedbfa0(,%eax,4),%eax
c0106981:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106988:	00 
c0106989:	89 04 24             	mov    %eax,(%esp)
c010698c:	e8 20 de ff ff       	call   c01047b1 <free_pages>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106991:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0106995:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106999:	7e dc                	jle    c0106977 <check_swap+0x39b>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c010699b:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c01069a0:	83 f8 04             	cmp    $0x4,%eax
c01069a3:	74 24                	je     c01069c9 <check_swap+0x3ed>
c01069a5:	c7 44 24 0c f8 a2 10 	movl   $0xc010a2f8,0xc(%esp)
c01069ac:	c0 
c01069ad:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c01069b4:	c0 
c01069b5:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c01069bc:	00 
c01069bd:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c01069c4:	e8 18 a3 ff ff       	call   c0100ce1 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c01069c9:	c7 04 24 1c a3 10 c0 	movl   $0xc010a31c,(%esp)
c01069d0:	e8 82 99 ff ff       	call   c0100357 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c01069d5:	c7 05 38 40 12 c0 00 	movl   $0x0,0xc0124038
c01069dc:	00 00 00 
     
     check_content_set();
c01069df:	e8 28 fa ff ff       	call   c010640c <check_content_set>
     assert( nr_free == 0);         
c01069e4:	a1 48 40 12 c0       	mov    0xc0124048,%eax
c01069e9:	85 c0                	test   %eax,%eax
c01069eb:	74 24                	je     c0106a11 <check_swap+0x435>
c01069ed:	c7 44 24 0c 43 a3 10 	movl   $0xc010a343,0xc(%esp)
c01069f4:	c0 
c01069f5:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c01069fc:	c0 
c01069fd:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0106a04:	00 
c0106a05:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c0106a0c:	e8 d0 a2 ff ff       	call   c0100ce1 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106a11:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106a18:	eb 26                	jmp    c0106a40 <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0106a1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a1d:	c7 04 85 80 40 12 c0 	movl   $0xffffffff,-0x3fedbf80(,%eax,4)
c0106a24:	ff ff ff ff 
c0106a28:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a2b:	8b 14 85 80 40 12 c0 	mov    -0x3fedbf80(,%eax,4),%edx
c0106a32:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a35:	89 14 85 c0 40 12 c0 	mov    %edx,-0x3fedbf40(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106a3c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0106a40:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0106a44:	7e d4                	jle    c0106a1a <check_swap+0x43e>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106a46:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106a4d:	e9 eb 00 00 00       	jmp    c0106b3d <check_swap+0x561>
         check_ptep[i]=0;
c0106a52:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a55:	c7 04 85 14 41 12 c0 	movl   $0x0,-0x3fedbeec(,%eax,4)
c0106a5c:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c0106a60:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a63:	83 c0 01             	add    $0x1,%eax
c0106a66:	c1 e0 0c             	shl    $0xc,%eax
c0106a69:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106a70:	00 
c0106a71:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a75:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106a78:	89 04 24             	mov    %eax,(%esp)
c0106a7b:	e8 a5 e3 ff ff       	call   c0104e25 <get_pte>
c0106a80:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106a83:	89 04 95 14 41 12 c0 	mov    %eax,-0x3fedbeec(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0106a8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106a8d:	8b 04 85 14 41 12 c0 	mov    -0x3fedbeec(,%eax,4),%eax
c0106a94:	85 c0                	test   %eax,%eax
c0106a96:	75 24                	jne    c0106abc <check_swap+0x4e0>
c0106a98:	c7 44 24 0c 50 a3 10 	movl   $0xc010a350,0xc(%esp)
c0106a9f:	c0 
c0106aa0:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c0106aa7:	c0 
c0106aa8:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0106aaf:	00 
c0106ab0:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c0106ab7:	e8 25 a2 ff ff       	call   c0100ce1 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0106abc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106abf:	8b 04 85 14 41 12 c0 	mov    -0x3fedbeec(,%eax,4),%eax
c0106ac6:	8b 00                	mov    (%eax),%eax
c0106ac8:	89 04 24             	mov    %eax,(%esp)
c0106acb:	e8 9f f5 ff ff       	call   c010606f <pte2page>
c0106ad0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106ad3:	8b 14 95 60 40 12 c0 	mov    -0x3fedbfa0(,%edx,4),%edx
c0106ada:	39 d0                	cmp    %edx,%eax
c0106adc:	74 24                	je     c0106b02 <check_swap+0x526>
c0106ade:	c7 44 24 0c 68 a3 10 	movl   $0xc010a368,0xc(%esp)
c0106ae5:	c0 
c0106ae6:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c0106aed:	c0 
c0106aee:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0106af5:	00 
c0106af6:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c0106afd:	e8 df a1 ff ff       	call   c0100ce1 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c0106b02:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b05:	8b 04 85 14 41 12 c0 	mov    -0x3fedbeec(,%eax,4),%eax
c0106b0c:	8b 00                	mov    (%eax),%eax
c0106b0e:	83 e0 01             	and    $0x1,%eax
c0106b11:	85 c0                	test   %eax,%eax
c0106b13:	75 24                	jne    c0106b39 <check_swap+0x55d>
c0106b15:	c7 44 24 0c 90 a3 10 	movl   $0xc010a390,0xc(%esp)
c0106b1c:	c0 
c0106b1d:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c0106b24:	c0 
c0106b25:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0106b2c:	00 
c0106b2d:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c0106b34:	e8 a8 a1 ff ff       	call   c0100ce1 <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106b39:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0106b3d:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106b41:	0f 8e 0b ff ff ff    	jle    c0106a52 <check_swap+0x476>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c0106b47:	c7 04 24 ac a3 10 c0 	movl   $0xc010a3ac,(%esp)
c0106b4e:	e8 04 98 ff ff       	call   c0100357 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0106b53:	e8 6c fa ff ff       	call   c01065c4 <check_content_access>
c0106b58:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(ret==0);
c0106b5b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0106b5f:	74 24                	je     c0106b85 <check_swap+0x5a9>
c0106b61:	c7 44 24 0c d2 a3 10 	movl   $0xc010a3d2,0xc(%esp)
c0106b68:	c0 
c0106b69:	c7 44 24 08 ba a0 10 	movl   $0xc010a0ba,0x8(%esp)
c0106b70:	c0 
c0106b71:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0106b78:	00 
c0106b79:	c7 04 24 54 a0 10 c0 	movl   $0xc010a054,(%esp)
c0106b80:	e8 5c a1 ff ff       	call   c0100ce1 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106b85:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106b8c:	eb 1e                	jmp    c0106bac <check_swap+0x5d0>
         free_pages(check_rp[i],1);
c0106b8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b91:	8b 04 85 60 40 12 c0 	mov    -0x3fedbfa0(,%eax,4),%eax
c0106b98:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106b9f:	00 
c0106ba0:	89 04 24             	mov    %eax,(%esp)
c0106ba3:	e8 09 dc ff ff       	call   c01047b1 <free_pages>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106ba8:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0106bac:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106bb0:	7e dc                	jle    c0106b8e <check_swap+0x5b2>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c0106bb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106bb5:	89 04 24             	mov    %eax,(%esp)
c0106bb8:	e8 5e 09 00 00       	call   c010751b <mm_destroy>
         
     nr_free = nr_free_store;
c0106bbd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106bc0:	a3 48 40 12 c0       	mov    %eax,0xc0124048
     free_list = free_list_store;
c0106bc5:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106bc8:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106bcb:	a3 40 40 12 c0       	mov    %eax,0xc0124040
c0106bd0:	89 15 44 40 12 c0    	mov    %edx,0xc0124044

     
     le = &free_list;
c0106bd6:	c7 45 e8 40 40 12 c0 	movl   $0xc0124040,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106bdd:	eb 1d                	jmp    c0106bfc <check_swap+0x620>
         struct Page *p = le2page(le, page_link);
c0106bdf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106be2:	83 e8 0c             	sub    $0xc,%eax
c0106be5:	89 45 c8             	mov    %eax,-0x38(%ebp)
         count --, total -= p->property;
c0106be8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0106bec:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106bef:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106bf2:	8b 40 08             	mov    0x8(%eax),%eax
c0106bf5:	29 c2                	sub    %eax,%edx
c0106bf7:	89 d0                	mov    %edx,%eax
c0106bf9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106bfc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106bff:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0106c02:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0106c05:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0106c08:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106c0b:	81 7d e8 40 40 12 c0 	cmpl   $0xc0124040,-0x18(%ebp)
c0106c12:	75 cb                	jne    c0106bdf <check_swap+0x603>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c0106c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c17:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c1e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c22:	c7 04 24 d9 a3 10 c0 	movl   $0xc010a3d9,(%esp)
c0106c29:	e8 29 97 ff ff       	call   c0100357 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0106c2e:	c7 04 24 f3 a3 10 c0 	movl   $0xc010a3f3,(%esp)
c0106c35:	e8 1d 97 ff ff       	call   c0100357 <cprintf>
}
c0106c3a:	83 c4 74             	add    $0x74,%esp
c0106c3d:	5b                   	pop    %ebx
c0106c3e:	5d                   	pop    %ebp
c0106c3f:	c3                   	ret    

c0106c40 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0106c40:	55                   	push   %ebp
c0106c41:	89 e5                	mov    %esp,%ebp
c0106c43:	83 ec 10             	sub    $0x10,%esp
c0106c46:	c7 45 fc 24 41 12 c0 	movl   $0xc0124124,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0106c4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106c50:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106c53:	89 50 04             	mov    %edx,0x4(%eax)
c0106c56:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106c59:	8b 50 04             	mov    0x4(%eax),%edx
c0106c5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106c5f:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0106c61:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c64:	c7 40 14 24 41 12 c0 	movl   $0xc0124124,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0106c6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106c70:	c9                   	leave  
c0106c71:	c3                   	ret    

c0106c72 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0106c72:	55                   	push   %ebp
c0106c73:	89 e5                	mov    %esp,%ebp
c0106c75:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0106c78:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c7b:	8b 40 14             	mov    0x14(%eax),%eax
c0106c7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0106c81:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c84:	83 c0 14             	add    $0x14,%eax
c0106c87:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0106c8a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106c8e:	74 06                	je     c0106c96 <_fifo_map_swappable+0x24>
c0106c90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106c94:	75 24                	jne    c0106cba <_fifo_map_swappable+0x48>
c0106c96:	c7 44 24 0c 0c a4 10 	movl   $0xc010a40c,0xc(%esp)
c0106c9d:	c0 
c0106c9e:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0106ca5:	c0 
c0106ca6:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0106cad:	00 
c0106cae:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c0106cb5:	e8 27 a0 ff ff       	call   c0100ce1 <__panic>
c0106cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cbd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106cc3:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106cc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106cc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106ccc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106ccf:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0106cd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106cd5:	8b 40 04             	mov    0x4(%eax),%eax
c0106cd8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106cdb:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0106cde:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106ce1:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0106ce4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0106ce7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106cea:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106ced:	89 10                	mov    %edx,(%eax)
c0106cef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106cf2:	8b 10                	mov    (%eax),%edx
c0106cf4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106cf7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106cfa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106cfd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106d00:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106d03:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106d06:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106d09:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0106d0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106d10:	c9                   	leave  
c0106d11:	c3                   	ret    

c0106d12 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0106d12:	55                   	push   %ebp
c0106d13:	89 e5                	mov    %esp,%ebp
c0106d15:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0106d18:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d1b:	8b 40 14             	mov    0x14(%eax),%eax
c0106d1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0106d21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106d25:	75 24                	jne    c0106d4b <_fifo_swap_out_victim+0x39>
c0106d27:	c7 44 24 0c 53 a4 10 	movl   $0xc010a453,0xc(%esp)
c0106d2e:	c0 
c0106d2f:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0106d36:	c0 
c0106d37:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0106d3e:	00 
c0106d3f:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c0106d46:	e8 96 9f ff ff       	call   c0100ce1 <__panic>
     assert(in_tick==0);
c0106d4b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106d4f:	74 24                	je     c0106d75 <_fifo_swap_out_victim+0x63>
c0106d51:	c7 44 24 0c 60 a4 10 	movl   $0xc010a460,0xc(%esp)
c0106d58:	c0 
c0106d59:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0106d60:	c0 
c0106d61:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0106d68:	00 
c0106d69:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c0106d70:	e8 6c 9f ff ff       	call   c0100ce1 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     /* Select the tail */
     list_entry_t *le = head->prev;
c0106d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d78:	8b 00                	mov    (%eax),%eax
c0106d7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c0106d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d80:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0106d83:	75 24                	jne    c0106da9 <_fifo_swap_out_victim+0x97>
c0106d85:	c7 44 24 0c 6b a4 10 	movl   $0xc010a46b,0xc(%esp)
c0106d8c:	c0 
c0106d8d:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0106d94:	c0 
c0106d95:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c0106d9c:	00 
c0106d9d:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c0106da4:	e8 38 9f ff ff       	call   c0100ce1 <__panic>
     struct Page *p = le2page(le, pra_page_link);
c0106da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106dac:	83 e8 14             	sub    $0x14,%eax
c0106daf:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106db2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106db5:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0106db8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106dbb:	8b 40 04             	mov    0x4(%eax),%eax
c0106dbe:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106dc1:	8b 12                	mov    (%edx),%edx
c0106dc3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0106dc6:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0106dc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106dcc:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106dcf:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106dd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106dd5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106dd8:	89 10                	mov    %edx,(%eax)
     list_del(le);
     assert(p !=NULL);
c0106dda:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106dde:	75 24                	jne    c0106e04 <_fifo_swap_out_victim+0xf2>
c0106de0:	c7 44 24 0c 74 a4 10 	movl   $0xc010a474,0xc(%esp)
c0106de7:	c0 
c0106de8:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0106def:	c0 
c0106df0:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
c0106df7:	00 
c0106df8:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c0106dff:	e8 dd 9e ff ff       	call   c0100ce1 <__panic>
     *ptr_page = p;
c0106e04:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e07:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106e0a:	89 10                	mov    %edx,(%eax)
     return 0;
c0106e0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106e11:	c9                   	leave  
c0106e12:	c3                   	ret    

c0106e13 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0106e13:	55                   	push   %ebp
c0106e14:	89 e5                	mov    %esp,%ebp
c0106e16:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0106e19:	c7 04 24 80 a4 10 c0 	movl   $0xc010a480,(%esp)
c0106e20:	e8 32 95 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0106e25:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106e2a:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0106e2d:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106e32:	83 f8 04             	cmp    $0x4,%eax
c0106e35:	74 24                	je     c0106e5b <_fifo_check_swap+0x48>
c0106e37:	c7 44 24 0c a6 a4 10 	movl   $0xc010a4a6,0xc(%esp)
c0106e3e:	c0 
c0106e3f:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0106e46:	c0 
c0106e47:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
c0106e4e:	00 
c0106e4f:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c0106e56:	e8 86 9e ff ff       	call   c0100ce1 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0106e5b:	c7 04 24 b8 a4 10 c0 	movl   $0xc010a4b8,(%esp)
c0106e62:	e8 f0 94 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0106e67:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106e6c:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0106e6f:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106e74:	83 f8 04             	cmp    $0x4,%eax
c0106e77:	74 24                	je     c0106e9d <_fifo_check_swap+0x8a>
c0106e79:	c7 44 24 0c a6 a4 10 	movl   $0xc010a4a6,0xc(%esp)
c0106e80:	c0 
c0106e81:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0106e88:	c0 
c0106e89:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
c0106e90:	00 
c0106e91:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c0106e98:	e8 44 9e ff ff       	call   c0100ce1 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0106e9d:	c7 04 24 e0 a4 10 c0 	movl   $0xc010a4e0,(%esp)
c0106ea4:	e8 ae 94 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0106ea9:	b8 00 40 00 00       	mov    $0x4000,%eax
c0106eae:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0106eb1:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106eb6:	83 f8 04             	cmp    $0x4,%eax
c0106eb9:	74 24                	je     c0106edf <_fifo_check_swap+0xcc>
c0106ebb:	c7 44 24 0c a6 a4 10 	movl   $0xc010a4a6,0xc(%esp)
c0106ec2:	c0 
c0106ec3:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0106eca:	c0 
c0106ecb:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0106ed2:	00 
c0106ed3:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c0106eda:	e8 02 9e ff ff       	call   c0100ce1 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0106edf:	c7 04 24 08 a5 10 c0 	movl   $0xc010a508,(%esp)
c0106ee6:	e8 6c 94 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0106eeb:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106ef0:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0106ef3:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106ef8:	83 f8 04             	cmp    $0x4,%eax
c0106efb:	74 24                	je     c0106f21 <_fifo_check_swap+0x10e>
c0106efd:	c7 44 24 0c a6 a4 10 	movl   $0xc010a4a6,0xc(%esp)
c0106f04:	c0 
c0106f05:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0106f0c:	c0 
c0106f0d:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0106f14:	00 
c0106f15:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c0106f1c:	e8 c0 9d ff ff       	call   c0100ce1 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0106f21:	c7 04 24 30 a5 10 c0 	movl   $0xc010a530,(%esp)
c0106f28:	e8 2a 94 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0106f2d:	b8 00 50 00 00       	mov    $0x5000,%eax
c0106f32:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0106f35:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106f3a:	83 f8 05             	cmp    $0x5,%eax
c0106f3d:	74 24                	je     c0106f63 <_fifo_check_swap+0x150>
c0106f3f:	c7 44 24 0c 56 a5 10 	movl   $0xc010a556,0xc(%esp)
c0106f46:	c0 
c0106f47:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0106f4e:	c0 
c0106f4f:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0106f56:	00 
c0106f57:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c0106f5e:	e8 7e 9d ff ff       	call   c0100ce1 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0106f63:	c7 04 24 08 a5 10 c0 	movl   $0xc010a508,(%esp)
c0106f6a:	e8 e8 93 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0106f6f:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106f74:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0106f77:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106f7c:	83 f8 05             	cmp    $0x5,%eax
c0106f7f:	74 24                	je     c0106fa5 <_fifo_check_swap+0x192>
c0106f81:	c7 44 24 0c 56 a5 10 	movl   $0xc010a556,0xc(%esp)
c0106f88:	c0 
c0106f89:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0106f90:	c0 
c0106f91:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0106f98:	00 
c0106f99:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c0106fa0:	e8 3c 9d ff ff       	call   c0100ce1 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0106fa5:	c7 04 24 b8 a4 10 c0 	movl   $0xc010a4b8,(%esp)
c0106fac:	e8 a6 93 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0106fb1:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106fb6:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0106fb9:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0106fbe:	83 f8 06             	cmp    $0x6,%eax
c0106fc1:	74 24                	je     c0106fe7 <_fifo_check_swap+0x1d4>
c0106fc3:	c7 44 24 0c 65 a5 10 	movl   $0xc010a565,0xc(%esp)
c0106fca:	c0 
c0106fcb:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0106fd2:	c0 
c0106fd3:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0106fda:	00 
c0106fdb:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c0106fe2:	e8 fa 9c ff ff       	call   c0100ce1 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0106fe7:	c7 04 24 08 a5 10 c0 	movl   $0xc010a508,(%esp)
c0106fee:	e8 64 93 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0106ff3:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106ff8:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0106ffb:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0107000:	83 f8 07             	cmp    $0x7,%eax
c0107003:	74 24                	je     c0107029 <_fifo_check_swap+0x216>
c0107005:	c7 44 24 0c 74 a5 10 	movl   $0xc010a574,0xc(%esp)
c010700c:	c0 
c010700d:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0107014:	c0 
c0107015:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c010701c:	00 
c010701d:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c0107024:	e8 b8 9c ff ff       	call   c0100ce1 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0107029:	c7 04 24 80 a4 10 c0 	movl   $0xc010a480,(%esp)
c0107030:	e8 22 93 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0107035:	b8 00 30 00 00       	mov    $0x3000,%eax
c010703a:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c010703d:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0107042:	83 f8 08             	cmp    $0x8,%eax
c0107045:	74 24                	je     c010706b <_fifo_check_swap+0x258>
c0107047:	c7 44 24 0c 83 a5 10 	movl   $0xc010a583,0xc(%esp)
c010704e:	c0 
c010704f:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0107056:	c0 
c0107057:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010705e:	00 
c010705f:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c0107066:	e8 76 9c ff ff       	call   c0100ce1 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c010706b:	c7 04 24 e0 a4 10 c0 	movl   $0xc010a4e0,(%esp)
c0107072:	e8 e0 92 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0107077:	b8 00 40 00 00       	mov    $0x4000,%eax
c010707c:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c010707f:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0107084:	83 f8 09             	cmp    $0x9,%eax
c0107087:	74 24                	je     c01070ad <_fifo_check_swap+0x29a>
c0107089:	c7 44 24 0c 92 a5 10 	movl   $0xc010a592,0xc(%esp)
c0107090:	c0 
c0107091:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0107098:	c0 
c0107099:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01070a0:	00 
c01070a1:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c01070a8:	e8 34 9c ff ff       	call   c0100ce1 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01070ad:	c7 04 24 30 a5 10 c0 	movl   $0xc010a530,(%esp)
c01070b4:	e8 9e 92 ff ff       	call   c0100357 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c01070b9:	b8 00 50 00 00       	mov    $0x5000,%eax
c01070be:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c01070c1:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c01070c6:	83 f8 0a             	cmp    $0xa,%eax
c01070c9:	74 24                	je     c01070ef <_fifo_check_swap+0x2dc>
c01070cb:	c7 44 24 0c a1 a5 10 	movl   $0xc010a5a1,0xc(%esp)
c01070d2:	c0 
c01070d3:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c01070da:	c0 
c01070db:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c01070e2:	00 
c01070e3:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c01070ea:	e8 f2 9b ff ff       	call   c0100ce1 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01070ef:	c7 04 24 b8 a4 10 c0 	movl   $0xc010a4b8,(%esp)
c01070f6:	e8 5c 92 ff ff       	call   c0100357 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c01070fb:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107100:	0f b6 00             	movzbl (%eax),%eax
c0107103:	3c 0a                	cmp    $0xa,%al
c0107105:	74 24                	je     c010712b <_fifo_check_swap+0x318>
c0107107:	c7 44 24 0c b4 a5 10 	movl   $0xc010a5b4,0xc(%esp)
c010710e:	c0 
c010710f:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c0107116:	c0 
c0107117:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
c010711e:	00 
c010711f:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c0107126:	e8 b6 9b ff ff       	call   c0100ce1 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c010712b:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107130:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0107133:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0107138:	83 f8 0b             	cmp    $0xb,%eax
c010713b:	74 24                	je     c0107161 <_fifo_check_swap+0x34e>
c010713d:	c7 44 24 0c d5 a5 10 	movl   $0xc010a5d5,0xc(%esp)
c0107144:	c0 
c0107145:	c7 44 24 08 2a a4 10 	movl   $0xc010a42a,0x8(%esp)
c010714c:	c0 
c010714d:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
c0107154:	00 
c0107155:	c7 04 24 3f a4 10 c0 	movl   $0xc010a43f,(%esp)
c010715c:	e8 80 9b ff ff       	call   c0100ce1 <__panic>
    return 0;
c0107161:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107166:	c9                   	leave  
c0107167:	c3                   	ret    

c0107168 <_fifo_init>:


static int
_fifo_init(void)
{
c0107168:	55                   	push   %ebp
c0107169:	89 e5                	mov    %esp,%ebp
    return 0;
c010716b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107170:	5d                   	pop    %ebp
c0107171:	c3                   	ret    

c0107172 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0107172:	55                   	push   %ebp
c0107173:	89 e5                	mov    %esp,%ebp
    return 0;
c0107175:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010717a:	5d                   	pop    %ebp
c010717b:	c3                   	ret    

c010717c <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c010717c:	55                   	push   %ebp
c010717d:	89 e5                	mov    %esp,%ebp
c010717f:	b8 00 00 00 00       	mov    $0x0,%eax
c0107184:	5d                   	pop    %ebp
c0107185:	c3                   	ret    

c0107186 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0107186:	55                   	push   %ebp
c0107187:	89 e5                	mov    %esp,%ebp
c0107189:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010718c:	8b 45 08             	mov    0x8(%ebp),%eax
c010718f:	c1 e8 0c             	shr    $0xc,%eax
c0107192:	89 c2                	mov    %eax,%edx
c0107194:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0107199:	39 c2                	cmp    %eax,%edx
c010719b:	72 1c                	jb     c01071b9 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010719d:	c7 44 24 08 f8 a5 10 	movl   $0xc010a5f8,0x8(%esp)
c01071a4:	c0 
c01071a5:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01071ac:	00 
c01071ad:	c7 04 24 17 a6 10 c0 	movl   $0xc010a617,(%esp)
c01071b4:	e8 28 9b ff ff       	call   c0100ce1 <__panic>
    }
    return &pages[PPN(pa)];
c01071b9:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c01071be:	8b 55 08             	mov    0x8(%ebp),%edx
c01071c1:	c1 ea 0c             	shr    $0xc,%edx
c01071c4:	c1 e2 05             	shl    $0x5,%edx
c01071c7:	01 d0                	add    %edx,%eax
}
c01071c9:	c9                   	leave  
c01071ca:	c3                   	ret    

c01071cb <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c01071cb:	55                   	push   %ebp
c01071cc:	89 e5                	mov    %esp,%ebp
c01071ce:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c01071d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01071d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01071d9:	89 04 24             	mov    %eax,(%esp)
c01071dc:	e8 a5 ff ff ff       	call   c0107186 <pa2page>
}
c01071e1:	c9                   	leave  
c01071e2:	c3                   	ret    

c01071e3 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c01071e3:	55                   	push   %ebp
c01071e4:	89 e5                	mov    %esp,%ebp
c01071e6:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c01071e9:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c01071f0:	e8 fb ec ff ff       	call   c0105ef0 <kmalloc>
c01071f5:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c01071f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01071fc:	74 58                	je     c0107256 <mm_create+0x73>
        list_init(&(mm->mmap_list));
c01071fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107201:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107204:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107207:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010720a:	89 50 04             	mov    %edx,0x4(%eax)
c010720d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107210:	8b 50 04             	mov    0x4(%eax),%edx
c0107213:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107216:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0107218:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010721b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0107222:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107225:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c010722c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010722f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0107236:	a1 2c 40 12 c0       	mov    0xc012402c,%eax
c010723b:	85 c0                	test   %eax,%eax
c010723d:	74 0d                	je     c010724c <mm_create+0x69>
c010723f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107242:	89 04 24             	mov    %eax,(%esp)
c0107245:	e8 f3 ee ff ff       	call   c010613d <swap_init_mm>
c010724a:	eb 0a                	jmp    c0107256 <mm_create+0x73>
        else mm->sm_priv = NULL;
c010724c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010724f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0107256:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107259:	c9                   	leave  
c010725a:	c3                   	ret    

c010725b <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c010725b:	55                   	push   %ebp
c010725c:	89 e5                	mov    %esp,%ebp
c010725e:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0107261:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0107268:	e8 83 ec ff ff       	call   c0105ef0 <kmalloc>
c010726d:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0107270:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107274:	74 1b                	je     c0107291 <vma_create+0x36>
        vma->vm_start = vm_start;
c0107276:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107279:	8b 55 08             	mov    0x8(%ebp),%edx
c010727c:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c010727f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107282:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107285:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0107288:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010728b:	8b 55 10             	mov    0x10(%ebp),%edx
c010728e:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0107291:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107294:	c9                   	leave  
c0107295:	c3                   	ret    

c0107296 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0107296:	55                   	push   %ebp
c0107297:	89 e5                	mov    %esp,%ebp
c0107299:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c010729c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c01072a3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01072a7:	0f 84 95 00 00 00    	je     c0107342 <find_vma+0xac>
        vma = mm->mmap_cache;
c01072ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01072b0:	8b 40 08             	mov    0x8(%eax),%eax
c01072b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c01072b6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01072ba:	74 16                	je     c01072d2 <find_vma+0x3c>
c01072bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01072bf:	8b 40 04             	mov    0x4(%eax),%eax
c01072c2:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01072c5:	77 0b                	ja     c01072d2 <find_vma+0x3c>
c01072c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01072ca:	8b 40 08             	mov    0x8(%eax),%eax
c01072cd:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01072d0:	77 61                	ja     c0107333 <find_vma+0x9d>
                bool found = 0;
c01072d2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c01072d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01072dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01072df:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01072e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c01072e5:	eb 28                	jmp    c010730f <find_vma+0x79>
                    vma = le2vma(le, list_link);
c01072e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01072ea:	83 e8 10             	sub    $0x10,%eax
c01072ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c01072f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01072f3:	8b 40 04             	mov    0x4(%eax),%eax
c01072f6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01072f9:	77 14                	ja     c010730f <find_vma+0x79>
c01072fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01072fe:	8b 40 08             	mov    0x8(%eax),%eax
c0107301:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107304:	76 09                	jbe    c010730f <find_vma+0x79>
                        found = 1;
c0107306:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c010730d:	eb 17                	jmp    c0107326 <find_vma+0x90>
c010730f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107312:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0107315:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107318:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c010731b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010731e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107321:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107324:	75 c1                	jne    c01072e7 <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c0107326:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c010732a:	75 07                	jne    c0107333 <find_vma+0x9d>
                    vma = NULL;
c010732c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0107333:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0107337:	74 09                	je     c0107342 <find_vma+0xac>
            mm->mmap_cache = vma;
c0107339:	8b 45 08             	mov    0x8(%ebp),%eax
c010733c:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010733f:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0107342:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0107345:	c9                   	leave  
c0107346:	c3                   	ret    

c0107347 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0107347:	55                   	push   %ebp
c0107348:	89 e5                	mov    %esp,%ebp
c010734a:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c010734d:	8b 45 08             	mov    0x8(%ebp),%eax
c0107350:	8b 50 04             	mov    0x4(%eax),%edx
c0107353:	8b 45 08             	mov    0x8(%ebp),%eax
c0107356:	8b 40 08             	mov    0x8(%eax),%eax
c0107359:	39 c2                	cmp    %eax,%edx
c010735b:	72 24                	jb     c0107381 <check_vma_overlap+0x3a>
c010735d:	c7 44 24 0c 25 a6 10 	movl   $0xc010a625,0xc(%esp)
c0107364:	c0 
c0107365:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c010736c:	c0 
c010736d:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0107374:	00 
c0107375:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c010737c:	e8 60 99 ff ff       	call   c0100ce1 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0107381:	8b 45 08             	mov    0x8(%ebp),%eax
c0107384:	8b 50 08             	mov    0x8(%eax),%edx
c0107387:	8b 45 0c             	mov    0xc(%ebp),%eax
c010738a:	8b 40 04             	mov    0x4(%eax),%eax
c010738d:	39 c2                	cmp    %eax,%edx
c010738f:	76 24                	jbe    c01073b5 <check_vma_overlap+0x6e>
c0107391:	c7 44 24 0c 68 a6 10 	movl   $0xc010a668,0xc(%esp)
c0107398:	c0 
c0107399:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c01073a0:	c0 
c01073a1:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c01073a8:	00 
c01073a9:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c01073b0:	e8 2c 99 ff ff       	call   c0100ce1 <__panic>
    assert(next->vm_start < next->vm_end);
c01073b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01073b8:	8b 50 04             	mov    0x4(%eax),%edx
c01073bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01073be:	8b 40 08             	mov    0x8(%eax),%eax
c01073c1:	39 c2                	cmp    %eax,%edx
c01073c3:	72 24                	jb     c01073e9 <check_vma_overlap+0xa2>
c01073c5:	c7 44 24 0c 87 a6 10 	movl   $0xc010a687,0xc(%esp)
c01073cc:	c0 
c01073cd:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c01073d4:	c0 
c01073d5:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c01073dc:	00 
c01073dd:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c01073e4:	e8 f8 98 ff ff       	call   c0100ce1 <__panic>
}
c01073e9:	c9                   	leave  
c01073ea:	c3                   	ret    

c01073eb <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c01073eb:	55                   	push   %ebp
c01073ec:	89 e5                	mov    %esp,%ebp
c01073ee:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c01073f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01073f4:	8b 50 04             	mov    0x4(%eax),%edx
c01073f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01073fa:	8b 40 08             	mov    0x8(%eax),%eax
c01073fd:	39 c2                	cmp    %eax,%edx
c01073ff:	72 24                	jb     c0107425 <insert_vma_struct+0x3a>
c0107401:	c7 44 24 0c a5 a6 10 	movl   $0xc010a6a5,0xc(%esp)
c0107408:	c0 
c0107409:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c0107410:	c0 
c0107411:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0107418:	00 
c0107419:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c0107420:	e8 bc 98 ff ff       	call   c0100ce1 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0107425:	8b 45 08             	mov    0x8(%ebp),%eax
c0107428:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c010742b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010742e:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0107431:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107434:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0107437:	eb 21                	jmp    c010745a <insert_vma_struct+0x6f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0107439:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010743c:	83 e8 10             	sub    $0x10,%eax
c010743f:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0107442:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107445:	8b 50 04             	mov    0x4(%eax),%edx
c0107448:	8b 45 0c             	mov    0xc(%ebp),%eax
c010744b:	8b 40 04             	mov    0x4(%eax),%eax
c010744e:	39 c2                	cmp    %eax,%edx
c0107450:	76 02                	jbe    c0107454 <insert_vma_struct+0x69>
                break;
c0107452:	eb 1d                	jmp    c0107471 <insert_vma_struct+0x86>
            }
            le_prev = le;
c0107454:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107457:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010745a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010745d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107460:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107463:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c0107466:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107469:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010746c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010746f:	75 c8                	jne    c0107439 <insert_vma_struct+0x4e>
c0107471:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107474:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107477:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010747a:	8b 40 04             	mov    0x4(%eax),%eax
                break;
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c010747d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0107480:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107483:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107486:	74 15                	je     c010749d <insert_vma_struct+0xb2>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0107488:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010748b:	8d 50 f0             	lea    -0x10(%eax),%edx
c010748e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107491:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107495:	89 14 24             	mov    %edx,(%esp)
c0107498:	e8 aa fe ff ff       	call   c0107347 <check_vma_overlap>
    }
    if (le_next != list) {
c010749d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01074a0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01074a3:	74 15                	je     c01074ba <insert_vma_struct+0xcf>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c01074a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01074a8:	83 e8 10             	sub    $0x10,%eax
c01074ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01074af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01074b2:	89 04 24             	mov    %eax,(%esp)
c01074b5:	e8 8d fe ff ff       	call   c0107347 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c01074ba:	8b 45 0c             	mov    0xc(%ebp),%eax
c01074bd:	8b 55 08             	mov    0x8(%ebp),%edx
c01074c0:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c01074c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01074c5:	8d 50 10             	lea    0x10(%eax),%edx
c01074c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01074ce:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01074d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01074d4:	8b 40 04             	mov    0x4(%eax),%eax
c01074d7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01074da:	89 55 d0             	mov    %edx,-0x30(%ebp)
c01074dd:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01074e0:	89 55 cc             	mov    %edx,-0x34(%ebp)
c01074e3:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01074e6:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01074e9:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01074ec:	89 10                	mov    %edx,(%eax)
c01074ee:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01074f1:	8b 10                	mov    (%eax),%edx
c01074f3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01074f6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01074f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01074fc:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01074ff:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107502:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107505:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107508:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c010750a:	8b 45 08             	mov    0x8(%ebp),%eax
c010750d:	8b 40 10             	mov    0x10(%eax),%eax
c0107510:	8d 50 01             	lea    0x1(%eax),%edx
c0107513:	8b 45 08             	mov    0x8(%ebp),%eax
c0107516:	89 50 10             	mov    %edx,0x10(%eax)
}
c0107519:	c9                   	leave  
c010751a:	c3                   	ret    

c010751b <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c010751b:	55                   	push   %ebp
c010751c:	89 e5                	mov    %esp,%ebp
c010751e:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c0107521:	8b 45 08             	mov    0x8(%ebp),%eax
c0107524:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c0107527:	eb 3e                	jmp    c0107567 <mm_destroy+0x4c>
c0107529:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010752c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010752f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107532:	8b 40 04             	mov    0x4(%eax),%eax
c0107535:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107538:	8b 12                	mov    (%edx),%edx
c010753a:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010753d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0107540:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107543:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107546:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107549:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010754c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010754f:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
c0107551:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107554:	83 e8 10             	sub    $0x10,%eax
c0107557:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c010755e:	00 
c010755f:	89 04 24             	mov    %eax,(%esp)
c0107562:	e8 29 ea ff ff       	call   c0105f90 <kfree>
c0107567:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010756a:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010756d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107570:	8b 40 04             	mov    0x4(%eax),%eax
// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c0107573:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107576:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107579:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010757c:	75 ab                	jne    c0107529 <mm_destroy+0xe>
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
c010757e:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c0107585:	00 
c0107586:	8b 45 08             	mov    0x8(%ebp),%eax
c0107589:	89 04 24             	mov    %eax,(%esp)
c010758c:	e8 ff e9 ff ff       	call   c0105f90 <kfree>
    mm=NULL;
c0107591:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0107598:	c9                   	leave  
c0107599:	c3                   	ret    

c010759a <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c010759a:	55                   	push   %ebp
c010759b:	89 e5                	mov    %esp,%ebp
c010759d:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c01075a0:	e8 02 00 00 00       	call   c01075a7 <check_vmm>
}
c01075a5:	c9                   	leave  
c01075a6:	c3                   	ret    

c01075a7 <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c01075a7:	55                   	push   %ebp
c01075a8:	89 e5                	mov    %esp,%ebp
c01075aa:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01075ad:	e8 31 d2 ff ff       	call   c01047e3 <nr_free_pages>
c01075b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c01075b5:	e8 41 00 00 00       	call   c01075fb <check_vma_struct>
    check_pgfault();
c01075ba:	e8 03 05 00 00       	call   c0107ac2 <check_pgfault>

    assert(nr_free_pages_store == nr_free_pages());
c01075bf:	e8 1f d2 ff ff       	call   c01047e3 <nr_free_pages>
c01075c4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01075c7:	74 24                	je     c01075ed <check_vmm+0x46>
c01075c9:	c7 44 24 0c c4 a6 10 	movl   $0xc010a6c4,0xc(%esp)
c01075d0:	c0 
c01075d1:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c01075d8:	c0 
c01075d9:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c01075e0:	00 
c01075e1:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c01075e8:	e8 f4 96 ff ff       	call   c0100ce1 <__panic>

    cprintf("check_vmm() succeeded.\n");
c01075ed:	c7 04 24 eb a6 10 c0 	movl   $0xc010a6eb,(%esp)
c01075f4:	e8 5e 8d ff ff       	call   c0100357 <cprintf>
}
c01075f9:	c9                   	leave  
c01075fa:	c3                   	ret    

c01075fb <check_vma_struct>:

static void
check_vma_struct(void) {
c01075fb:	55                   	push   %ebp
c01075fc:	89 e5                	mov    %esp,%ebp
c01075fe:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107601:	e8 dd d1 ff ff       	call   c01047e3 <nr_free_pages>
c0107606:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0107609:	e8 d5 fb ff ff       	call   c01071e3 <mm_create>
c010760e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0107611:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0107615:	75 24                	jne    c010763b <check_vma_struct+0x40>
c0107617:	c7 44 24 0c 03 a7 10 	movl   $0xc010a703,0xc(%esp)
c010761e:	c0 
c010761f:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c0107626:	c0 
c0107627:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
c010762e:	00 
c010762f:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c0107636:	e8 a6 96 ff ff       	call   c0100ce1 <__panic>

    int step1 = 10, step2 = step1 * 10;
c010763b:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c0107642:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107645:	89 d0                	mov    %edx,%eax
c0107647:	c1 e0 02             	shl    $0x2,%eax
c010764a:	01 d0                	add    %edx,%eax
c010764c:	01 c0                	add    %eax,%eax
c010764e:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c0107651:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107654:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107657:	eb 70                	jmp    c01076c9 <check_vma_struct+0xce>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0107659:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010765c:	89 d0                	mov    %edx,%eax
c010765e:	c1 e0 02             	shl    $0x2,%eax
c0107661:	01 d0                	add    %edx,%eax
c0107663:	83 c0 02             	add    $0x2,%eax
c0107666:	89 c1                	mov    %eax,%ecx
c0107668:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010766b:	89 d0                	mov    %edx,%eax
c010766d:	c1 e0 02             	shl    $0x2,%eax
c0107670:	01 d0                	add    %edx,%eax
c0107672:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107679:	00 
c010767a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c010767e:	89 04 24             	mov    %eax,(%esp)
c0107681:	e8 d5 fb ff ff       	call   c010725b <vma_create>
c0107686:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c0107689:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010768d:	75 24                	jne    c01076b3 <check_vma_struct+0xb8>
c010768f:	c7 44 24 0c 0e a7 10 	movl   $0xc010a70e,0xc(%esp)
c0107696:	c0 
c0107697:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c010769e:	c0 
c010769f:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c01076a6:	00 
c01076a7:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c01076ae:	e8 2e 96 ff ff       	call   c0100ce1 <__panic>
        insert_vma_struct(mm, vma);
c01076b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01076b6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01076ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01076bd:	89 04 24             	mov    %eax,(%esp)
c01076c0:	e8 26 fd ff ff       	call   c01073eb <insert_vma_struct>
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c01076c5:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01076c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01076cd:	7f 8a                	jg     c0107659 <check_vma_struct+0x5e>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c01076cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01076d2:	83 c0 01             	add    $0x1,%eax
c01076d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01076d8:	eb 70                	jmp    c010774a <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01076da:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01076dd:	89 d0                	mov    %edx,%eax
c01076df:	c1 e0 02             	shl    $0x2,%eax
c01076e2:	01 d0                	add    %edx,%eax
c01076e4:	83 c0 02             	add    $0x2,%eax
c01076e7:	89 c1                	mov    %eax,%ecx
c01076e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01076ec:	89 d0                	mov    %edx,%eax
c01076ee:	c1 e0 02             	shl    $0x2,%eax
c01076f1:	01 d0                	add    %edx,%eax
c01076f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01076fa:	00 
c01076fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01076ff:	89 04 24             	mov    %eax,(%esp)
c0107702:	e8 54 fb ff ff       	call   c010725b <vma_create>
c0107707:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c010770a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010770e:	75 24                	jne    c0107734 <check_vma_struct+0x139>
c0107710:	c7 44 24 0c 0e a7 10 	movl   $0xc010a70e,0xc(%esp)
c0107717:	c0 
c0107718:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c010771f:	c0 
c0107720:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c0107727:	00 
c0107728:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c010772f:	e8 ad 95 ff ff       	call   c0100ce1 <__panic>
        insert_vma_struct(mm, vma);
c0107734:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107737:	89 44 24 04          	mov    %eax,0x4(%esp)
c010773b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010773e:	89 04 24             	mov    %eax,(%esp)
c0107741:	e8 a5 fc ff ff       	call   c01073eb <insert_vma_struct>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0107746:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010774a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010774d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107750:	7e 88                	jle    c01076da <check_vma_struct+0xdf>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c0107752:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107755:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0107758:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010775b:	8b 40 04             	mov    0x4(%eax),%eax
c010775e:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c0107761:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0107768:	e9 97 00 00 00       	jmp    c0107804 <check_vma_struct+0x209>
        assert(le != &(mm->mmap_list));
c010776d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107770:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0107773:	75 24                	jne    c0107799 <check_vma_struct+0x19e>
c0107775:	c7 44 24 0c 1a a7 10 	movl   $0xc010a71a,0xc(%esp)
c010777c:	c0 
c010777d:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c0107784:	c0 
c0107785:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c010778c:	00 
c010778d:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c0107794:	e8 48 95 ff ff       	call   c0100ce1 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0107799:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010779c:	83 e8 10             	sub    $0x10,%eax
c010779f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c01077a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01077a5:	8b 48 04             	mov    0x4(%eax),%ecx
c01077a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01077ab:	89 d0                	mov    %edx,%eax
c01077ad:	c1 e0 02             	shl    $0x2,%eax
c01077b0:	01 d0                	add    %edx,%eax
c01077b2:	39 c1                	cmp    %eax,%ecx
c01077b4:	75 17                	jne    c01077cd <check_vma_struct+0x1d2>
c01077b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01077b9:	8b 48 08             	mov    0x8(%eax),%ecx
c01077bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01077bf:	89 d0                	mov    %edx,%eax
c01077c1:	c1 e0 02             	shl    $0x2,%eax
c01077c4:	01 d0                	add    %edx,%eax
c01077c6:	83 c0 02             	add    $0x2,%eax
c01077c9:	39 c1                	cmp    %eax,%ecx
c01077cb:	74 24                	je     c01077f1 <check_vma_struct+0x1f6>
c01077cd:	c7 44 24 0c 34 a7 10 	movl   $0xc010a734,0xc(%esp)
c01077d4:	c0 
c01077d5:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c01077dc:	c0 
c01077dd:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c01077e4:	00 
c01077e5:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c01077ec:	e8 f0 94 ff ff       	call   c0100ce1 <__panic>
c01077f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01077f4:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01077f7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01077fa:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01077fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c0107800:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107804:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107807:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010780a:	0f 8e 5d ff ff ff    	jle    c010776d <check_vma_struct+0x172>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0107810:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0107817:	e9 cd 01 00 00       	jmp    c01079e9 <check_vma_struct+0x3ee>
        struct vma_struct *vma1 = find_vma(mm, i);
c010781c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010781f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107823:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107826:	89 04 24             	mov    %eax,(%esp)
c0107829:	e8 68 fa ff ff       	call   c0107296 <find_vma>
c010782e:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma1 != NULL);
c0107831:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c0107835:	75 24                	jne    c010785b <check_vma_struct+0x260>
c0107837:	c7 44 24 0c 69 a7 10 	movl   $0xc010a769,0xc(%esp)
c010783e:	c0 
c010783f:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c0107846:	c0 
c0107847:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c010784e:	00 
c010784f:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c0107856:	e8 86 94 ff ff       	call   c0100ce1 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c010785b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010785e:	83 c0 01             	add    $0x1,%eax
c0107861:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107865:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107868:	89 04 24             	mov    %eax,(%esp)
c010786b:	e8 26 fa ff ff       	call   c0107296 <find_vma>
c0107870:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma2 != NULL);
c0107873:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0107877:	75 24                	jne    c010789d <check_vma_struct+0x2a2>
c0107879:	c7 44 24 0c 76 a7 10 	movl   $0xc010a776,0xc(%esp)
c0107880:	c0 
c0107881:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c0107888:	c0 
c0107889:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0107890:	00 
c0107891:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c0107898:	e8 44 94 ff ff       	call   c0100ce1 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c010789d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078a0:	83 c0 02             	add    $0x2,%eax
c01078a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01078a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01078aa:	89 04 24             	mov    %eax,(%esp)
c01078ad:	e8 e4 f9 ff ff       	call   c0107296 <find_vma>
c01078b2:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma3 == NULL);
c01078b5:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01078b9:	74 24                	je     c01078df <check_vma_struct+0x2e4>
c01078bb:	c7 44 24 0c 83 a7 10 	movl   $0xc010a783,0xc(%esp)
c01078c2:	c0 
c01078c3:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c01078ca:	c0 
c01078cb:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c01078d2:	00 
c01078d3:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c01078da:	e8 02 94 ff ff       	call   c0100ce1 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c01078df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01078e2:	83 c0 03             	add    $0x3,%eax
c01078e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01078e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01078ec:	89 04 24             	mov    %eax,(%esp)
c01078ef:	e8 a2 f9 ff ff       	call   c0107296 <find_vma>
c01078f4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma4 == NULL);
c01078f7:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c01078fb:	74 24                	je     c0107921 <check_vma_struct+0x326>
c01078fd:	c7 44 24 0c 90 a7 10 	movl   $0xc010a790,0xc(%esp)
c0107904:	c0 
c0107905:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c010790c:	c0 
c010790d:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0107914:	00 
c0107915:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c010791c:	e8 c0 93 ff ff       	call   c0100ce1 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0107921:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107924:	83 c0 04             	add    $0x4,%eax
c0107927:	89 44 24 04          	mov    %eax,0x4(%esp)
c010792b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010792e:	89 04 24             	mov    %eax,(%esp)
c0107931:	e8 60 f9 ff ff       	call   c0107296 <find_vma>
c0107936:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma5 == NULL);
c0107939:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c010793d:	74 24                	je     c0107963 <check_vma_struct+0x368>
c010793f:	c7 44 24 0c 9d a7 10 	movl   $0xc010a79d,0xc(%esp)
c0107946:	c0 
c0107947:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c010794e:	c0 
c010794f:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0107956:	00 
c0107957:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c010795e:	e8 7e 93 ff ff       	call   c0100ce1 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c0107963:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107966:	8b 50 04             	mov    0x4(%eax),%edx
c0107969:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010796c:	39 c2                	cmp    %eax,%edx
c010796e:	75 10                	jne    c0107980 <check_vma_struct+0x385>
c0107970:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107973:	8b 50 08             	mov    0x8(%eax),%edx
c0107976:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107979:	83 c0 02             	add    $0x2,%eax
c010797c:	39 c2                	cmp    %eax,%edx
c010797e:	74 24                	je     c01079a4 <check_vma_struct+0x3a9>
c0107980:	c7 44 24 0c ac a7 10 	movl   $0xc010a7ac,0xc(%esp)
c0107987:	c0 
c0107988:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c010798f:	c0 
c0107990:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0107997:	00 
c0107998:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c010799f:	e8 3d 93 ff ff       	call   c0100ce1 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c01079a4:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01079a7:	8b 50 04             	mov    0x4(%eax),%edx
c01079aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079ad:	39 c2                	cmp    %eax,%edx
c01079af:	75 10                	jne    c01079c1 <check_vma_struct+0x3c6>
c01079b1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01079b4:	8b 50 08             	mov    0x8(%eax),%edx
c01079b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01079ba:	83 c0 02             	add    $0x2,%eax
c01079bd:	39 c2                	cmp    %eax,%edx
c01079bf:	74 24                	je     c01079e5 <check_vma_struct+0x3ea>
c01079c1:	c7 44 24 0c dc a7 10 	movl   $0xc010a7dc,0xc(%esp)
c01079c8:	c0 
c01079c9:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c01079d0:	c0 
c01079d1:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c01079d8:	00 
c01079d9:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c01079e0:	e8 fc 92 ff ff       	call   c0100ce1 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c01079e5:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c01079e9:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01079ec:	89 d0                	mov    %edx,%eax
c01079ee:	c1 e0 02             	shl    $0x2,%eax
c01079f1:	01 d0                	add    %edx,%eax
c01079f3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01079f6:	0f 8d 20 fe ff ff    	jge    c010781c <check_vma_struct+0x221>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c01079fc:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0107a03:	eb 70                	jmp    c0107a75 <check_vma_struct+0x47a>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0107a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a08:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107a0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a0f:	89 04 24             	mov    %eax,(%esp)
c0107a12:	e8 7f f8 ff ff       	call   c0107296 <find_vma>
c0107a17:	89 45 bc             	mov    %eax,-0x44(%ebp)
        if (vma_below_5 != NULL ) {
c0107a1a:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107a1e:	74 27                	je     c0107a47 <check_vma_struct+0x44c>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0107a20:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107a23:	8b 50 08             	mov    0x8(%eax),%edx
c0107a26:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107a29:	8b 40 04             	mov    0x4(%eax),%eax
c0107a2c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107a30:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107a37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107a3b:	c7 04 24 0c a8 10 c0 	movl   $0xc010a80c,(%esp)
c0107a42:	e8 10 89 ff ff       	call   c0100357 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0107a47:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0107a4b:	74 24                	je     c0107a71 <check_vma_struct+0x476>
c0107a4d:	c7 44 24 0c 31 a8 10 	movl   $0xc010a831,0xc(%esp)
c0107a54:	c0 
c0107a55:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c0107a5c:	c0 
c0107a5d:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0107a64:	00 
c0107a65:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c0107a6c:	e8 70 92 ff ff       	call   c0100ce1 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c0107a71:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0107a75:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107a79:	79 8a                	jns    c0107a05 <check_vma_struct+0x40a>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c0107a7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107a7e:	89 04 24             	mov    %eax,(%esp)
c0107a81:	e8 95 fa ff ff       	call   c010751b <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
c0107a86:	e8 58 cd ff ff       	call   c01047e3 <nr_free_pages>
c0107a8b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107a8e:	74 24                	je     c0107ab4 <check_vma_struct+0x4b9>
c0107a90:	c7 44 24 0c c4 a6 10 	movl   $0xc010a6c4,0xc(%esp)
c0107a97:	c0 
c0107a98:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c0107a9f:	c0 
c0107aa0:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0107aa7:	00 
c0107aa8:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c0107aaf:	e8 2d 92 ff ff       	call   c0100ce1 <__panic>

    cprintf("check_vma_struct() succeeded!\n");
c0107ab4:	c7 04 24 48 a8 10 c0 	movl   $0xc010a848,(%esp)
c0107abb:	e8 97 88 ff ff       	call   c0100357 <cprintf>
}
c0107ac0:	c9                   	leave  
c0107ac1:	c3                   	ret    

c0107ac2 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0107ac2:	55                   	push   %ebp
c0107ac3:	89 e5                	mov    %esp,%ebp
c0107ac5:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0107ac8:	e8 16 cd ff ff       	call   c01047e3 <nr_free_pages>
c0107acd:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0107ad0:	e8 0e f7 ff ff       	call   c01071e3 <mm_create>
c0107ad5:	a3 2c 41 12 c0       	mov    %eax,0xc012412c
    assert(check_mm_struct != NULL);
c0107ada:	a1 2c 41 12 c0       	mov    0xc012412c,%eax
c0107adf:	85 c0                	test   %eax,%eax
c0107ae1:	75 24                	jne    c0107b07 <check_pgfault+0x45>
c0107ae3:	c7 44 24 0c 67 a8 10 	movl   $0xc010a867,0xc(%esp)
c0107aea:	c0 
c0107aeb:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c0107af2:	c0 
c0107af3:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c0107afa:	00 
c0107afb:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c0107b02:	e8 da 91 ff ff       	call   c0100ce1 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0107b07:	a1 2c 41 12 c0       	mov    0xc012412c,%eax
c0107b0c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c0107b0f:	8b 15 e0 09 12 c0    	mov    0xc01209e0,%edx
c0107b15:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b18:	89 50 0c             	mov    %edx,0xc(%eax)
c0107b1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107b1e:	8b 40 0c             	mov    0xc(%eax),%eax
c0107b21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0107b24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107b27:	8b 00                	mov    (%eax),%eax
c0107b29:	85 c0                	test   %eax,%eax
c0107b2b:	74 24                	je     c0107b51 <check_pgfault+0x8f>
c0107b2d:	c7 44 24 0c 7f a8 10 	movl   $0xc010a87f,0xc(%esp)
c0107b34:	c0 
c0107b35:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c0107b3c:	c0 
c0107b3d:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0107b44:	00 
c0107b45:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c0107b4c:	e8 90 91 ff ff       	call   c0100ce1 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c0107b51:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c0107b58:	00 
c0107b59:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c0107b60:	00 
c0107b61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0107b68:	e8 ee f6 ff ff       	call   c010725b <vma_create>
c0107b6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c0107b70:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0107b74:	75 24                	jne    c0107b9a <check_pgfault+0xd8>
c0107b76:	c7 44 24 0c 0e a7 10 	movl   $0xc010a70e,0xc(%esp)
c0107b7d:	c0 
c0107b7e:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c0107b85:	c0 
c0107b86:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0107b8d:	00 
c0107b8e:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c0107b95:	e8 47 91 ff ff       	call   c0100ce1 <__panic>

    insert_vma_struct(mm, vma);
c0107b9a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107b9d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ba1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107ba4:	89 04 24             	mov    %eax,(%esp)
c0107ba7:	e8 3f f8 ff ff       	call   c01073eb <insert_vma_struct>

    uintptr_t addr = 0x100;
c0107bac:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0107bb3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107bb6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107bba:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107bbd:	89 04 24             	mov    %eax,(%esp)
c0107bc0:	e8 d1 f6 ff ff       	call   c0107296 <find_vma>
c0107bc5:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0107bc8:	74 24                	je     c0107bee <check_pgfault+0x12c>
c0107bca:	c7 44 24 0c 8d a8 10 	movl   $0xc010a88d,0xc(%esp)
c0107bd1:	c0 
c0107bd2:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c0107bd9:	c0 
c0107bda:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0107be1:	00 
c0107be2:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c0107be9:	e8 f3 90 ff ff       	call   c0100ce1 <__panic>

    int i, sum = 0;
c0107bee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0107bf5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107bfc:	eb 17                	jmp    c0107c15 <check_pgfault+0x153>
        *(char *)(addr + i) = i;
c0107bfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107c01:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107c04:	01 d0                	add    %edx,%eax
c0107c06:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107c09:	88 10                	mov    %dl,(%eax)
        sum += i;
c0107c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107c0e:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0107c11:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107c15:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0107c19:	7e e3                	jle    c0107bfe <check_pgfault+0x13c>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0107c1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107c22:	eb 15                	jmp    c0107c39 <check_pgfault+0x177>
        sum -= *(char *)(addr + i);
c0107c24:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107c27:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107c2a:	01 d0                	add    %edx,%eax
c0107c2c:	0f b6 00             	movzbl (%eax),%eax
c0107c2f:	0f be c0             	movsbl %al,%eax
c0107c32:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c0107c35:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107c39:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0107c3d:	7e e5                	jle    c0107c24 <check_pgfault+0x162>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c0107c3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107c43:	74 24                	je     c0107c69 <check_pgfault+0x1a7>
c0107c45:	c7 44 24 0c a7 a8 10 	movl   $0xc010a8a7,0xc(%esp)
c0107c4c:	c0 
c0107c4d:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c0107c54:	c0 
c0107c55:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c0107c5c:	00 
c0107c5d:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c0107c64:	e8 78 90 ff ff       	call   c0100ce1 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c0107c69:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107c6c:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0107c6f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107c72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107c77:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107c7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107c7e:	89 04 24             	mov    %eax,(%esp)
c0107c81:	e8 91 d3 ff ff       	call   c0105017 <page_remove>
    free_page(pde2page(pgdir[0]));
c0107c86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107c89:	8b 00                	mov    (%eax),%eax
c0107c8b:	89 04 24             	mov    %eax,(%esp)
c0107c8e:	e8 38 f5 ff ff       	call   c01071cb <pde2page>
c0107c93:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107c9a:	00 
c0107c9b:	89 04 24             	mov    %eax,(%esp)
c0107c9e:	e8 0e cb ff ff       	call   c01047b1 <free_pages>
    pgdir[0] = 0;
c0107ca3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107ca6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0107cac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107caf:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0107cb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107cb9:	89 04 24             	mov    %eax,(%esp)
c0107cbc:	e8 5a f8 ff ff       	call   c010751b <mm_destroy>
    check_mm_struct = NULL;
c0107cc1:	c7 05 2c 41 12 c0 00 	movl   $0x0,0xc012412c
c0107cc8:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0107ccb:	e8 13 cb ff ff       	call   c01047e3 <nr_free_pages>
c0107cd0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107cd3:	74 24                	je     c0107cf9 <check_pgfault+0x237>
c0107cd5:	c7 44 24 0c c4 a6 10 	movl   $0xc010a6c4,0xc(%esp)
c0107cdc:	c0 
c0107cdd:	c7 44 24 08 43 a6 10 	movl   $0xc010a643,0x8(%esp)
c0107ce4:	c0 
c0107ce5:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0107cec:	00 
c0107ced:	c7 04 24 58 a6 10 c0 	movl   $0xc010a658,(%esp)
c0107cf4:	e8 e8 8f ff ff       	call   c0100ce1 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0107cf9:	c7 04 24 b0 a8 10 c0 	movl   $0xc010a8b0,(%esp)
c0107d00:	e8 52 86 ff ff       	call   c0100357 <cprintf>
}
c0107d05:	c9                   	leave  
c0107d06:	c3                   	ret    

c0107d07 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0107d07:	55                   	push   %ebp
c0107d08:	89 e5                	mov    %esp,%ebp
c0107d0a:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0107d0d:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0107d14:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d17:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107d1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d1e:	89 04 24             	mov    %eax,(%esp)
c0107d21:	e8 70 f5 ff ff       	call   c0107296 <find_vma>
c0107d26:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0107d29:	a1 38 40 12 c0       	mov    0xc0124038,%eax
c0107d2e:	83 c0 01             	add    $0x1,%eax
c0107d31:	a3 38 40 12 c0       	mov    %eax,0xc0124038
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c0107d36:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107d3a:	74 0b                	je     c0107d47 <do_pgfault+0x40>
c0107d3c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107d3f:	8b 40 04             	mov    0x4(%eax),%eax
c0107d42:	3b 45 10             	cmp    0x10(%ebp),%eax
c0107d45:	76 18                	jbe    c0107d5f <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c0107d47:	8b 45 10             	mov    0x10(%ebp),%eax
c0107d4a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107d4e:	c7 04 24 cc a8 10 c0 	movl   $0xc010a8cc,(%esp)
c0107d55:	e8 fd 85 ff ff       	call   c0100357 <cprintf>
        goto failed;
c0107d5a:	e9 bb 01 00 00       	jmp    c0107f1a <do_pgfault+0x213>
    }
    //check the error_code
    switch (error_code & 3) {
c0107d5f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107d62:	83 e0 03             	and    $0x3,%eax
c0107d65:	85 c0                	test   %eax,%eax
c0107d67:	74 36                	je     c0107d9f <do_pgfault+0x98>
c0107d69:	83 f8 01             	cmp    $0x1,%eax
c0107d6c:	74 20                	je     c0107d8e <do_pgfault+0x87>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c0107d6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107d71:	8b 40 0c             	mov    0xc(%eax),%eax
c0107d74:	83 e0 02             	and    $0x2,%eax
c0107d77:	85 c0                	test   %eax,%eax
c0107d79:	75 11                	jne    c0107d8c <do_pgfault+0x85>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0107d7b:	c7 04 24 fc a8 10 c0 	movl   $0xc010a8fc,(%esp)
c0107d82:	e8 d0 85 ff ff       	call   c0100357 <cprintf>
            goto failed;
c0107d87:	e9 8e 01 00 00       	jmp    c0107f1a <do_pgfault+0x213>
        }
        break;
c0107d8c:	eb 2f                	jmp    c0107dbd <do_pgfault+0xb6>
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c0107d8e:	c7 04 24 5c a9 10 c0 	movl   $0xc010a95c,(%esp)
c0107d95:	e8 bd 85 ff ff       	call   c0100357 <cprintf>
        goto failed;
c0107d9a:	e9 7b 01 00 00       	jmp    c0107f1a <do_pgfault+0x213>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0107d9f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107da2:	8b 40 0c             	mov    0xc(%eax),%eax
c0107da5:	83 e0 05             	and    $0x5,%eax
c0107da8:	85 c0                	test   %eax,%eax
c0107daa:	75 11                	jne    c0107dbd <do_pgfault+0xb6>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0107dac:	c7 04 24 94 a9 10 c0 	movl   $0xc010a994,(%esp)
c0107db3:	e8 9f 85 ff ff       	call   c0100357 <cprintf>
            goto failed;
c0107db8:	e9 5d 01 00 00       	jmp    c0107f1a <do_pgfault+0x213>
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0107dbd:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0107dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107dc7:	8b 40 0c             	mov    0xc(%eax),%eax
c0107dca:	83 e0 02             	and    $0x2,%eax
c0107dcd:	85 c0                	test   %eax,%eax
c0107dcf:	74 04                	je     c0107dd5 <do_pgfault+0xce>
        perm |= PTE_W;
c0107dd1:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0107dd5:	8b 45 10             	mov    0x10(%ebp),%eax
c0107dd8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107ddb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107dde:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107de3:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0107de6:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0107ded:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
   }
#endif
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
///////////////////////////////////////////////////////////////
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0107df4:	8b 45 08             	mov    0x8(%ebp),%eax
c0107df7:	8b 40 0c             	mov    0xc(%eax),%eax
c0107dfa:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0107e01:	00 
c0107e02:	8b 55 10             	mov    0x10(%ebp),%edx
c0107e05:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107e09:	89 04 24             	mov    %eax,(%esp)
c0107e0c:	e8 14 d0 ff ff       	call   c0104e25 <get_pte>
c0107e11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107e14:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107e18:	75 11                	jne    c0107e2b <do_pgfault+0x124>
        cprintf("get_pte in do_pgfault failed\n");
c0107e1a:	c7 04 24 f7 a9 10 c0 	movl   $0xc010a9f7,(%esp)
c0107e21:	e8 31 85 ff ff       	call   c0100357 <cprintf>
        goto failed;
c0107e26:	e9 ef 00 00 00       	jmp    c0107f1a <do_pgfault+0x213>
    }
    
    if (*ptep == 0) {
c0107e2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107e2e:	8b 00                	mov    (%eax),%eax
c0107e30:	85 c0                	test   %eax,%eax
c0107e32:	75 35                	jne    c0107e69 <do_pgfault+0x162>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c0107e34:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e37:	8b 40 0c             	mov    0xc(%eax),%eax
c0107e3a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107e3d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0107e41:	8b 55 10             	mov    0x10(%ebp),%edx
c0107e44:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107e48:	89 04 24             	mov    %eax,(%esp)
c0107e4b:	e8 21 d3 ff ff       	call   c0105171 <pgdir_alloc_page>
c0107e50:	85 c0                	test   %eax,%eax
c0107e52:	0f 85 bb 00 00 00    	jne    c0107f13 <do_pgfault+0x20c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c0107e58:	c7 04 24 18 aa 10 c0 	movl   $0xc010aa18,(%esp)
c0107e5f:	e8 f3 84 ff ff       	call   c0100357 <cprintf>
            goto failed;
c0107e64:	e9 b1 00 00 00       	jmp    c0107f1a <do_pgfault+0x213>
        }
    }
//exe2:

    else {
        if(swap_init_ok) {
c0107e69:	a1 2c 40 12 c0       	mov    0xc012402c,%eax
c0107e6e:	85 c0                	test   %eax,%eax
c0107e70:	0f 84 86 00 00 00    	je     c0107efc <do_pgfault+0x1f5>
            struct Page *page=NULL;
c0107e76:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c0107e7d:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0107e80:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107e84:	8b 45 10             	mov    0x10(%ebp),%eax
c0107e87:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107e8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e8e:	89 04 24             	mov    %eax,(%esp)
c0107e91:	e8 a0 e4 ff ff       	call   c0106336 <swap_in>
c0107e96:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107e99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107e9d:	74 0e                	je     c0107ead <do_pgfault+0x1a6>
                cprintf("swap_in in do_pgfault failed\n");
c0107e9f:	c7 04 24 3f aa 10 c0 	movl   $0xc010aa3f,(%esp)
c0107ea6:	e8 ac 84 ff ff       	call   c0100357 <cprintf>
c0107eab:	eb 6d                	jmp    c0107f1a <do_pgfault+0x213>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c0107ead:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107eb0:	8b 45 08             	mov    0x8(%ebp),%eax
c0107eb3:	8b 40 0c             	mov    0xc(%eax),%eax
c0107eb6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0107eb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0107ebd:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0107ec0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0107ec4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107ec8:	89 04 24             	mov    %eax,(%esp)
c0107ecb:	e8 8b d1 ff ff       	call   c010505b <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c0107ed0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107ed3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0107eda:	00 
c0107edb:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107edf:	8b 45 10             	mov    0x10(%ebp),%eax
c0107ee2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ee6:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ee9:	89 04 24             	mov    %eax,(%esp)
c0107eec:	e8 7c e2 ff ff       	call   c010616d <swap_map_swappable>
            page->pra_vaddr = addr;
c0107ef1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107ef4:	8b 55 10             	mov    0x10(%ebp),%edx
c0107ef7:	89 50 1c             	mov    %edx,0x1c(%eax)
c0107efa:	eb 17                	jmp    c0107f13 <do_pgfault+0x20c>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0107efc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107eff:	8b 00                	mov    (%eax),%eax
c0107f01:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107f05:	c7 04 24 60 aa 10 c0 	movl   $0xc010aa60,(%esp)
c0107f0c:	e8 46 84 ff ff       	call   c0100357 <cprintf>
            goto failed;
c0107f11:	eb 07                	jmp    c0107f1a <do_pgfault+0x213>
        }
   }
/////////////////////////////////////////////////////////////////
   ret = 0;
c0107f13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0107f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107f1d:	c9                   	leave  
c0107f1e:	c3                   	ret    

c0107f1f <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0107f1f:	55                   	push   %ebp
c0107f20:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0107f22:	8b 55 08             	mov    0x8(%ebp),%edx
c0107f25:	a1 54 40 12 c0       	mov    0xc0124054,%eax
c0107f2a:	29 c2                	sub    %eax,%edx
c0107f2c:	89 d0                	mov    %edx,%eax
c0107f2e:	c1 f8 05             	sar    $0x5,%eax
}
c0107f31:	5d                   	pop    %ebp
c0107f32:	c3                   	ret    

c0107f33 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0107f33:	55                   	push   %ebp
c0107f34:	89 e5                	mov    %esp,%ebp
c0107f36:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0107f39:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f3c:	89 04 24             	mov    %eax,(%esp)
c0107f3f:	e8 db ff ff ff       	call   c0107f1f <page2ppn>
c0107f44:	c1 e0 0c             	shl    $0xc,%eax
}
c0107f47:	c9                   	leave  
c0107f48:	c3                   	ret    

c0107f49 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c0107f49:	55                   	push   %ebp
c0107f4a:	89 e5                	mov    %esp,%ebp
c0107f4c:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0107f4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f52:	89 04 24             	mov    %eax,(%esp)
c0107f55:	e8 d9 ff ff ff       	call   c0107f33 <page2pa>
c0107f5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f60:	c1 e8 0c             	shr    $0xc,%eax
c0107f63:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107f66:	a1 a0 3f 12 c0       	mov    0xc0123fa0,%eax
c0107f6b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0107f6e:	72 23                	jb     c0107f93 <page2kva+0x4a>
c0107f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f73:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107f77:	c7 44 24 08 88 aa 10 	movl   $0xc010aa88,0x8(%esp)
c0107f7e:	c0 
c0107f7f:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0107f86:	00 
c0107f87:	c7 04 24 ab aa 10 c0 	movl   $0xc010aaab,(%esp)
c0107f8e:	e8 4e 8d ff ff       	call   c0100ce1 <__panic>
c0107f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f96:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0107f9b:	c9                   	leave  
c0107f9c:	c3                   	ret    

c0107f9d <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0107f9d:	55                   	push   %ebp
c0107f9e:	89 e5                	mov    %esp,%ebp
c0107fa0:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0107fa3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107faa:	e8 93 9a ff ff       	call   c0101a42 <ide_device_valid>
c0107faf:	85 c0                	test   %eax,%eax
c0107fb1:	75 1c                	jne    c0107fcf <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c0107fb3:	c7 44 24 08 b9 aa 10 	movl   $0xc010aab9,0x8(%esp)
c0107fba:	c0 
c0107fbb:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c0107fc2:	00 
c0107fc3:	c7 04 24 d3 aa 10 c0 	movl   $0xc010aad3,(%esp)
c0107fca:	e8 12 8d ff ff       	call   c0100ce1 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0107fcf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107fd6:	e8 a6 9a ff ff       	call   c0101a81 <ide_device_size>
c0107fdb:	c1 e8 03             	shr    $0x3,%eax
c0107fde:	a3 fc 40 12 c0       	mov    %eax,0xc01240fc
}
c0107fe3:	c9                   	leave  
c0107fe4:	c3                   	ret    

c0107fe5 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0107fe5:	55                   	push   %ebp
c0107fe6:	89 e5                	mov    %esp,%ebp
c0107fe8:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0107feb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107fee:	89 04 24             	mov    %eax,(%esp)
c0107ff1:	e8 53 ff ff ff       	call   c0107f49 <page2kva>
c0107ff6:	8b 55 08             	mov    0x8(%ebp),%edx
c0107ff9:	c1 ea 08             	shr    $0x8,%edx
c0107ffc:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0107fff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108003:	74 0b                	je     c0108010 <swapfs_read+0x2b>
c0108005:	8b 15 fc 40 12 c0    	mov    0xc01240fc,%edx
c010800b:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010800e:	72 23                	jb     c0108033 <swapfs_read+0x4e>
c0108010:	8b 45 08             	mov    0x8(%ebp),%eax
c0108013:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108017:	c7 44 24 08 e4 aa 10 	movl   $0xc010aae4,0x8(%esp)
c010801e:	c0 
c010801f:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0108026:	00 
c0108027:	c7 04 24 d3 aa 10 c0 	movl   $0xc010aad3,(%esp)
c010802e:	e8 ae 8c ff ff       	call   c0100ce1 <__panic>
c0108033:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108036:	c1 e2 03             	shl    $0x3,%edx
c0108039:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0108040:	00 
c0108041:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108045:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108049:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108050:	e8 6b 9a ff ff       	call   c0101ac0 <ide_read_secs>
}
c0108055:	c9                   	leave  
c0108056:	c3                   	ret    

c0108057 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0108057:	55                   	push   %ebp
c0108058:	89 e5                	mov    %esp,%ebp
c010805a:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010805d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108060:	89 04 24             	mov    %eax,(%esp)
c0108063:	e8 e1 fe ff ff       	call   c0107f49 <page2kva>
c0108068:	8b 55 08             	mov    0x8(%ebp),%edx
c010806b:	c1 ea 08             	shr    $0x8,%edx
c010806e:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108071:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108075:	74 0b                	je     c0108082 <swapfs_write+0x2b>
c0108077:	8b 15 fc 40 12 c0    	mov    0xc01240fc,%edx
c010807d:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0108080:	72 23                	jb     c01080a5 <swapfs_write+0x4e>
c0108082:	8b 45 08             	mov    0x8(%ebp),%eax
c0108085:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108089:	c7 44 24 08 e4 aa 10 	movl   $0xc010aae4,0x8(%esp)
c0108090:	c0 
c0108091:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0108098:	00 
c0108099:	c7 04 24 d3 aa 10 c0 	movl   $0xc010aad3,(%esp)
c01080a0:	e8 3c 8c ff ff       	call   c0100ce1 <__panic>
c01080a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01080a8:	c1 e2 03             	shl    $0x3,%edx
c01080ab:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01080b2:	00 
c01080b3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01080b7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01080bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01080c2:	e8 3b 9c ff ff       	call   c0101d02 <ide_write_secs>
}
c01080c7:	c9                   	leave  
c01080c8:	c3                   	ret    

c01080c9 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01080c9:	55                   	push   %ebp
c01080ca:	89 e5                	mov    %esp,%ebp
c01080cc:	83 ec 58             	sub    $0x58,%esp
c01080cf:	8b 45 10             	mov    0x10(%ebp),%eax
c01080d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01080d5:	8b 45 14             	mov    0x14(%ebp),%eax
c01080d8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01080db:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01080de:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01080e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01080e4:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01080e7:	8b 45 18             	mov    0x18(%ebp),%eax
c01080ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01080ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01080f0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01080f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01080f6:	89 55 f0             	mov    %edx,-0x10(%ebp)
c01080f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01080fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01080ff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108103:	74 1c                	je     c0108121 <printnum+0x58>
c0108105:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108108:	ba 00 00 00 00       	mov    $0x0,%edx
c010810d:	f7 75 e4             	divl   -0x1c(%ebp)
c0108110:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108113:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108116:	ba 00 00 00 00       	mov    $0x0,%edx
c010811b:	f7 75 e4             	divl   -0x1c(%ebp)
c010811e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108121:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108124:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108127:	f7 75 e4             	divl   -0x1c(%ebp)
c010812a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010812d:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0108130:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108133:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108136:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108139:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010813c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010813f:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0108142:	8b 45 18             	mov    0x18(%ebp),%eax
c0108145:	ba 00 00 00 00       	mov    $0x0,%edx
c010814a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010814d:	77 56                	ja     c01081a5 <printnum+0xdc>
c010814f:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0108152:	72 05                	jb     c0108159 <printnum+0x90>
c0108154:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0108157:	77 4c                	ja     c01081a5 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0108159:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010815c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010815f:	8b 45 20             	mov    0x20(%ebp),%eax
c0108162:	89 44 24 18          	mov    %eax,0x18(%esp)
c0108166:	89 54 24 14          	mov    %edx,0x14(%esp)
c010816a:	8b 45 18             	mov    0x18(%ebp),%eax
c010816d:	89 44 24 10          	mov    %eax,0x10(%esp)
c0108171:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108174:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108177:	89 44 24 08          	mov    %eax,0x8(%esp)
c010817b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010817f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108182:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108186:	8b 45 08             	mov    0x8(%ebp),%eax
c0108189:	89 04 24             	mov    %eax,(%esp)
c010818c:	e8 38 ff ff ff       	call   c01080c9 <printnum>
c0108191:	eb 1c                	jmp    c01081af <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0108193:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108196:	89 44 24 04          	mov    %eax,0x4(%esp)
c010819a:	8b 45 20             	mov    0x20(%ebp),%eax
c010819d:	89 04 24             	mov    %eax,(%esp)
c01081a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01081a3:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c01081a5:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c01081a9:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01081ad:	7f e4                	jg     c0108193 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01081af:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01081b2:	05 84 ab 10 c0       	add    $0xc010ab84,%eax
c01081b7:	0f b6 00             	movzbl (%eax),%eax
c01081ba:	0f be c0             	movsbl %al,%eax
c01081bd:	8b 55 0c             	mov    0xc(%ebp),%edx
c01081c0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01081c4:	89 04 24             	mov    %eax,(%esp)
c01081c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01081ca:	ff d0                	call   *%eax
}
c01081cc:	c9                   	leave  
c01081cd:	c3                   	ret    

c01081ce <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01081ce:	55                   	push   %ebp
c01081cf:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01081d1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01081d5:	7e 14                	jle    c01081eb <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01081d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01081da:	8b 00                	mov    (%eax),%eax
c01081dc:	8d 48 08             	lea    0x8(%eax),%ecx
c01081df:	8b 55 08             	mov    0x8(%ebp),%edx
c01081e2:	89 0a                	mov    %ecx,(%edx)
c01081e4:	8b 50 04             	mov    0x4(%eax),%edx
c01081e7:	8b 00                	mov    (%eax),%eax
c01081e9:	eb 30                	jmp    c010821b <getuint+0x4d>
    }
    else if (lflag) {
c01081eb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01081ef:	74 16                	je     c0108207 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01081f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01081f4:	8b 00                	mov    (%eax),%eax
c01081f6:	8d 48 04             	lea    0x4(%eax),%ecx
c01081f9:	8b 55 08             	mov    0x8(%ebp),%edx
c01081fc:	89 0a                	mov    %ecx,(%edx)
c01081fe:	8b 00                	mov    (%eax),%eax
c0108200:	ba 00 00 00 00       	mov    $0x0,%edx
c0108205:	eb 14                	jmp    c010821b <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0108207:	8b 45 08             	mov    0x8(%ebp),%eax
c010820a:	8b 00                	mov    (%eax),%eax
c010820c:	8d 48 04             	lea    0x4(%eax),%ecx
c010820f:	8b 55 08             	mov    0x8(%ebp),%edx
c0108212:	89 0a                	mov    %ecx,(%edx)
c0108214:	8b 00                	mov    (%eax),%eax
c0108216:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010821b:	5d                   	pop    %ebp
c010821c:	c3                   	ret    

c010821d <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010821d:	55                   	push   %ebp
c010821e:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0108220:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0108224:	7e 14                	jle    c010823a <getint+0x1d>
        return va_arg(*ap, long long);
c0108226:	8b 45 08             	mov    0x8(%ebp),%eax
c0108229:	8b 00                	mov    (%eax),%eax
c010822b:	8d 48 08             	lea    0x8(%eax),%ecx
c010822e:	8b 55 08             	mov    0x8(%ebp),%edx
c0108231:	89 0a                	mov    %ecx,(%edx)
c0108233:	8b 50 04             	mov    0x4(%eax),%edx
c0108236:	8b 00                	mov    (%eax),%eax
c0108238:	eb 28                	jmp    c0108262 <getint+0x45>
    }
    else if (lflag) {
c010823a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010823e:	74 12                	je     c0108252 <getint+0x35>
        return va_arg(*ap, long);
c0108240:	8b 45 08             	mov    0x8(%ebp),%eax
c0108243:	8b 00                	mov    (%eax),%eax
c0108245:	8d 48 04             	lea    0x4(%eax),%ecx
c0108248:	8b 55 08             	mov    0x8(%ebp),%edx
c010824b:	89 0a                	mov    %ecx,(%edx)
c010824d:	8b 00                	mov    (%eax),%eax
c010824f:	99                   	cltd   
c0108250:	eb 10                	jmp    c0108262 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0108252:	8b 45 08             	mov    0x8(%ebp),%eax
c0108255:	8b 00                	mov    (%eax),%eax
c0108257:	8d 48 04             	lea    0x4(%eax),%ecx
c010825a:	8b 55 08             	mov    0x8(%ebp),%edx
c010825d:	89 0a                	mov    %ecx,(%edx)
c010825f:	8b 00                	mov    (%eax),%eax
c0108261:	99                   	cltd   
    }
}
c0108262:	5d                   	pop    %ebp
c0108263:	c3                   	ret    

c0108264 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0108264:	55                   	push   %ebp
c0108265:	89 e5                	mov    %esp,%ebp
c0108267:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010826a:	8d 45 14             	lea    0x14(%ebp),%eax
c010826d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0108270:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108273:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108277:	8b 45 10             	mov    0x10(%ebp),%eax
c010827a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010827e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108281:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108285:	8b 45 08             	mov    0x8(%ebp),%eax
c0108288:	89 04 24             	mov    %eax,(%esp)
c010828b:	e8 02 00 00 00       	call   c0108292 <vprintfmt>
    va_end(ap);
}
c0108290:	c9                   	leave  
c0108291:	c3                   	ret    

c0108292 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0108292:	55                   	push   %ebp
c0108293:	89 e5                	mov    %esp,%ebp
c0108295:	56                   	push   %esi
c0108296:	53                   	push   %ebx
c0108297:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010829a:	eb 18                	jmp    c01082b4 <vprintfmt+0x22>
            if (ch == '\0') {
c010829c:	85 db                	test   %ebx,%ebx
c010829e:	75 05                	jne    c01082a5 <vprintfmt+0x13>
                return;
c01082a0:	e9 d1 03 00 00       	jmp    c0108676 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c01082a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01082a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01082ac:	89 1c 24             	mov    %ebx,(%esp)
c01082af:	8b 45 08             	mov    0x8(%ebp),%eax
c01082b2:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01082b4:	8b 45 10             	mov    0x10(%ebp),%eax
c01082b7:	8d 50 01             	lea    0x1(%eax),%edx
c01082ba:	89 55 10             	mov    %edx,0x10(%ebp)
c01082bd:	0f b6 00             	movzbl (%eax),%eax
c01082c0:	0f b6 d8             	movzbl %al,%ebx
c01082c3:	83 fb 25             	cmp    $0x25,%ebx
c01082c6:	75 d4                	jne    c010829c <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c01082c8:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01082cc:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01082d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01082d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01082d9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01082e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01082e3:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01082e6:	8b 45 10             	mov    0x10(%ebp),%eax
c01082e9:	8d 50 01             	lea    0x1(%eax),%edx
c01082ec:	89 55 10             	mov    %edx,0x10(%ebp)
c01082ef:	0f b6 00             	movzbl (%eax),%eax
c01082f2:	0f b6 d8             	movzbl %al,%ebx
c01082f5:	8d 43 dd             	lea    -0x23(%ebx),%eax
c01082f8:	83 f8 55             	cmp    $0x55,%eax
c01082fb:	0f 87 44 03 00 00    	ja     c0108645 <vprintfmt+0x3b3>
c0108301:	8b 04 85 a8 ab 10 c0 	mov    -0x3fef5458(,%eax,4),%eax
c0108308:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010830a:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010830e:	eb d6                	jmp    c01082e6 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0108310:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0108314:	eb d0                	jmp    c01082e6 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0108316:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010831d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108320:	89 d0                	mov    %edx,%eax
c0108322:	c1 e0 02             	shl    $0x2,%eax
c0108325:	01 d0                	add    %edx,%eax
c0108327:	01 c0                	add    %eax,%eax
c0108329:	01 d8                	add    %ebx,%eax
c010832b:	83 e8 30             	sub    $0x30,%eax
c010832e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0108331:	8b 45 10             	mov    0x10(%ebp),%eax
c0108334:	0f b6 00             	movzbl (%eax),%eax
c0108337:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010833a:	83 fb 2f             	cmp    $0x2f,%ebx
c010833d:	7e 0b                	jle    c010834a <vprintfmt+0xb8>
c010833f:	83 fb 39             	cmp    $0x39,%ebx
c0108342:	7f 06                	jg     c010834a <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0108344:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0108348:	eb d3                	jmp    c010831d <vprintfmt+0x8b>
            goto process_precision;
c010834a:	eb 33                	jmp    c010837f <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c010834c:	8b 45 14             	mov    0x14(%ebp),%eax
c010834f:	8d 50 04             	lea    0x4(%eax),%edx
c0108352:	89 55 14             	mov    %edx,0x14(%ebp)
c0108355:	8b 00                	mov    (%eax),%eax
c0108357:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010835a:	eb 23                	jmp    c010837f <vprintfmt+0xed>

        case '.':
            if (width < 0)
c010835c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108360:	79 0c                	jns    c010836e <vprintfmt+0xdc>
                width = 0;
c0108362:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0108369:	e9 78 ff ff ff       	jmp    c01082e6 <vprintfmt+0x54>
c010836e:	e9 73 ff ff ff       	jmp    c01082e6 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c0108373:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010837a:	e9 67 ff ff ff       	jmp    c01082e6 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c010837f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108383:	79 12                	jns    c0108397 <vprintfmt+0x105>
                width = precision, precision = -1;
c0108385:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108388:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010838b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0108392:	e9 4f ff ff ff       	jmp    c01082e6 <vprintfmt+0x54>
c0108397:	e9 4a ff ff ff       	jmp    c01082e6 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010839c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c01083a0:	e9 41 ff ff ff       	jmp    c01082e6 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c01083a5:	8b 45 14             	mov    0x14(%ebp),%eax
c01083a8:	8d 50 04             	lea    0x4(%eax),%edx
c01083ab:	89 55 14             	mov    %edx,0x14(%ebp)
c01083ae:	8b 00                	mov    (%eax),%eax
c01083b0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01083b3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01083b7:	89 04 24             	mov    %eax,(%esp)
c01083ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01083bd:	ff d0                	call   *%eax
            break;
c01083bf:	e9 ac 02 00 00       	jmp    c0108670 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c01083c4:	8b 45 14             	mov    0x14(%ebp),%eax
c01083c7:	8d 50 04             	lea    0x4(%eax),%edx
c01083ca:	89 55 14             	mov    %edx,0x14(%ebp)
c01083cd:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01083cf:	85 db                	test   %ebx,%ebx
c01083d1:	79 02                	jns    c01083d5 <vprintfmt+0x143>
                err = -err;
c01083d3:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01083d5:	83 fb 06             	cmp    $0x6,%ebx
c01083d8:	7f 0b                	jg     c01083e5 <vprintfmt+0x153>
c01083da:	8b 34 9d 68 ab 10 c0 	mov    -0x3fef5498(,%ebx,4),%esi
c01083e1:	85 f6                	test   %esi,%esi
c01083e3:	75 23                	jne    c0108408 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c01083e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01083e9:	c7 44 24 08 95 ab 10 	movl   $0xc010ab95,0x8(%esp)
c01083f0:	c0 
c01083f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01083f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01083f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01083fb:	89 04 24             	mov    %eax,(%esp)
c01083fe:	e8 61 fe ff ff       	call   c0108264 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0108403:	e9 68 02 00 00       	jmp    c0108670 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0108408:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010840c:	c7 44 24 08 9e ab 10 	movl   $0xc010ab9e,0x8(%esp)
c0108413:	c0 
c0108414:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108417:	89 44 24 04          	mov    %eax,0x4(%esp)
c010841b:	8b 45 08             	mov    0x8(%ebp),%eax
c010841e:	89 04 24             	mov    %eax,(%esp)
c0108421:	e8 3e fe ff ff       	call   c0108264 <printfmt>
            }
            break;
c0108426:	e9 45 02 00 00       	jmp    c0108670 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010842b:	8b 45 14             	mov    0x14(%ebp),%eax
c010842e:	8d 50 04             	lea    0x4(%eax),%edx
c0108431:	89 55 14             	mov    %edx,0x14(%ebp)
c0108434:	8b 30                	mov    (%eax),%esi
c0108436:	85 f6                	test   %esi,%esi
c0108438:	75 05                	jne    c010843f <vprintfmt+0x1ad>
                p = "(null)";
c010843a:	be a1 ab 10 c0       	mov    $0xc010aba1,%esi
            }
            if (width > 0 && padc != '-') {
c010843f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108443:	7e 3e                	jle    c0108483 <vprintfmt+0x1f1>
c0108445:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0108449:	74 38                	je     c0108483 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010844b:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c010844e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108451:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108455:	89 34 24             	mov    %esi,(%esp)
c0108458:	e8 ed 03 00 00       	call   c010884a <strnlen>
c010845d:	29 c3                	sub    %eax,%ebx
c010845f:	89 d8                	mov    %ebx,%eax
c0108461:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108464:	eb 17                	jmp    c010847d <vprintfmt+0x1eb>
                    putch(padc, putdat);
c0108466:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010846a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010846d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108471:	89 04 24             	mov    %eax,(%esp)
c0108474:	8b 45 08             	mov    0x8(%ebp),%eax
c0108477:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0108479:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010847d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108481:	7f e3                	jg     c0108466 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0108483:	eb 38                	jmp    c01084bd <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c0108485:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108489:	74 1f                	je     c01084aa <vprintfmt+0x218>
c010848b:	83 fb 1f             	cmp    $0x1f,%ebx
c010848e:	7e 05                	jle    c0108495 <vprintfmt+0x203>
c0108490:	83 fb 7e             	cmp    $0x7e,%ebx
c0108493:	7e 15                	jle    c01084aa <vprintfmt+0x218>
                    putch('?', putdat);
c0108495:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108498:	89 44 24 04          	mov    %eax,0x4(%esp)
c010849c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c01084a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01084a6:	ff d0                	call   *%eax
c01084a8:	eb 0f                	jmp    c01084b9 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c01084aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084ad:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084b1:	89 1c 24             	mov    %ebx,(%esp)
c01084b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01084b7:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01084b9:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01084bd:	89 f0                	mov    %esi,%eax
c01084bf:	8d 70 01             	lea    0x1(%eax),%esi
c01084c2:	0f b6 00             	movzbl (%eax),%eax
c01084c5:	0f be d8             	movsbl %al,%ebx
c01084c8:	85 db                	test   %ebx,%ebx
c01084ca:	74 10                	je     c01084dc <vprintfmt+0x24a>
c01084cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01084d0:	78 b3                	js     c0108485 <vprintfmt+0x1f3>
c01084d2:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c01084d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01084da:	79 a9                	jns    c0108485 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c01084dc:	eb 17                	jmp    c01084f5 <vprintfmt+0x263>
                putch(' ', putdat);
c01084de:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084e1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01084e5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01084ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01084ef:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c01084f1:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c01084f5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01084f9:	7f e3                	jg     c01084de <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c01084fb:	e9 70 01 00 00       	jmp    c0108670 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0108500:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108503:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108507:	8d 45 14             	lea    0x14(%ebp),%eax
c010850a:	89 04 24             	mov    %eax,(%esp)
c010850d:	e8 0b fd ff ff       	call   c010821d <getint>
c0108512:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108515:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0108518:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010851b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010851e:	85 d2                	test   %edx,%edx
c0108520:	79 26                	jns    c0108548 <vprintfmt+0x2b6>
                putch('-', putdat);
c0108522:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108525:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108529:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0108530:	8b 45 08             	mov    0x8(%ebp),%eax
c0108533:	ff d0                	call   *%eax
                num = -(long long)num;
c0108535:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108538:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010853b:	f7 d8                	neg    %eax
c010853d:	83 d2 00             	adc    $0x0,%edx
c0108540:	f7 da                	neg    %edx
c0108542:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108545:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0108548:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010854f:	e9 a8 00 00 00       	jmp    c01085fc <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0108554:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108557:	89 44 24 04          	mov    %eax,0x4(%esp)
c010855b:	8d 45 14             	lea    0x14(%ebp),%eax
c010855e:	89 04 24             	mov    %eax,(%esp)
c0108561:	e8 68 fc ff ff       	call   c01081ce <getuint>
c0108566:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108569:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010856c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0108573:	e9 84 00 00 00       	jmp    c01085fc <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0108578:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010857b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010857f:	8d 45 14             	lea    0x14(%ebp),%eax
c0108582:	89 04 24             	mov    %eax,(%esp)
c0108585:	e8 44 fc ff ff       	call   c01081ce <getuint>
c010858a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010858d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0108590:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0108597:	eb 63                	jmp    c01085fc <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c0108599:	8b 45 0c             	mov    0xc(%ebp),%eax
c010859c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01085a0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c01085a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01085aa:	ff d0                	call   *%eax
            putch('x', putdat);
c01085ac:	8b 45 0c             	mov    0xc(%ebp),%eax
c01085af:	89 44 24 04          	mov    %eax,0x4(%esp)
c01085b3:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c01085ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01085bd:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c01085bf:	8b 45 14             	mov    0x14(%ebp),%eax
c01085c2:	8d 50 04             	lea    0x4(%eax),%edx
c01085c5:	89 55 14             	mov    %edx,0x14(%ebp)
c01085c8:	8b 00                	mov    (%eax),%eax
c01085ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01085cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c01085d4:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c01085db:	eb 1f                	jmp    c01085fc <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c01085dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01085e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01085e4:	8d 45 14             	lea    0x14(%ebp),%eax
c01085e7:	89 04 24             	mov    %eax,(%esp)
c01085ea:	e8 df fb ff ff       	call   c01081ce <getuint>
c01085ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01085f2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c01085f5:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c01085fc:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0108600:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108603:	89 54 24 18          	mov    %edx,0x18(%esp)
c0108607:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010860a:	89 54 24 14          	mov    %edx,0x14(%esp)
c010860e:	89 44 24 10          	mov    %eax,0x10(%esp)
c0108612:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108615:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108618:	89 44 24 08          	mov    %eax,0x8(%esp)
c010861c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108620:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108623:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108627:	8b 45 08             	mov    0x8(%ebp),%eax
c010862a:	89 04 24             	mov    %eax,(%esp)
c010862d:	e8 97 fa ff ff       	call   c01080c9 <printnum>
            break;
c0108632:	eb 3c                	jmp    c0108670 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0108634:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108637:	89 44 24 04          	mov    %eax,0x4(%esp)
c010863b:	89 1c 24             	mov    %ebx,(%esp)
c010863e:	8b 45 08             	mov    0x8(%ebp),%eax
c0108641:	ff d0                	call   *%eax
            break;
c0108643:	eb 2b                	jmp    c0108670 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0108645:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108648:	89 44 24 04          	mov    %eax,0x4(%esp)
c010864c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0108653:	8b 45 08             	mov    0x8(%ebp),%eax
c0108656:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0108658:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010865c:	eb 04                	jmp    c0108662 <vprintfmt+0x3d0>
c010865e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0108662:	8b 45 10             	mov    0x10(%ebp),%eax
c0108665:	83 e8 01             	sub    $0x1,%eax
c0108668:	0f b6 00             	movzbl (%eax),%eax
c010866b:	3c 25                	cmp    $0x25,%al
c010866d:	75 ef                	jne    c010865e <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c010866f:	90                   	nop
        }
    }
c0108670:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108671:	e9 3e fc ff ff       	jmp    c01082b4 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0108676:	83 c4 40             	add    $0x40,%esp
c0108679:	5b                   	pop    %ebx
c010867a:	5e                   	pop    %esi
c010867b:	5d                   	pop    %ebp
c010867c:	c3                   	ret    

c010867d <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010867d:	55                   	push   %ebp
c010867e:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0108680:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108683:	8b 40 08             	mov    0x8(%eax),%eax
c0108686:	8d 50 01             	lea    0x1(%eax),%edx
c0108689:	8b 45 0c             	mov    0xc(%ebp),%eax
c010868c:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010868f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108692:	8b 10                	mov    (%eax),%edx
c0108694:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108697:	8b 40 04             	mov    0x4(%eax),%eax
c010869a:	39 c2                	cmp    %eax,%edx
c010869c:	73 12                	jae    c01086b0 <sprintputch+0x33>
        *b->buf ++ = ch;
c010869e:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086a1:	8b 00                	mov    (%eax),%eax
c01086a3:	8d 48 01             	lea    0x1(%eax),%ecx
c01086a6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01086a9:	89 0a                	mov    %ecx,(%edx)
c01086ab:	8b 55 08             	mov    0x8(%ebp),%edx
c01086ae:	88 10                	mov    %dl,(%eax)
    }
}
c01086b0:	5d                   	pop    %ebp
c01086b1:	c3                   	ret    

c01086b2 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c01086b2:	55                   	push   %ebp
c01086b3:	89 e5                	mov    %esp,%ebp
c01086b5:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01086b8:	8d 45 14             	lea    0x14(%ebp),%eax
c01086bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c01086be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01086c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01086c5:	8b 45 10             	mov    0x10(%ebp),%eax
c01086c8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01086cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086cf:	89 44 24 04          	mov    %eax,0x4(%esp)
c01086d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01086d6:	89 04 24             	mov    %eax,(%esp)
c01086d9:	e8 08 00 00 00       	call   c01086e6 <vsnprintf>
c01086de:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01086e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01086e4:	c9                   	leave  
c01086e5:	c3                   	ret    

c01086e6 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c01086e6:	55                   	push   %ebp
c01086e7:	89 e5                	mov    %esp,%ebp
c01086e9:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c01086ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01086ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01086f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086f5:	8d 50 ff             	lea    -0x1(%eax),%edx
c01086f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01086fb:	01 d0                	add    %edx,%eax
c01086fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108700:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0108707:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010870b:	74 0a                	je     c0108717 <vsnprintf+0x31>
c010870d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108710:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108713:	39 c2                	cmp    %eax,%edx
c0108715:	76 07                	jbe    c010871e <vsnprintf+0x38>
        return -E_INVAL;
c0108717:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010871c:	eb 2a                	jmp    c0108748 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010871e:	8b 45 14             	mov    0x14(%ebp),%eax
c0108721:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108725:	8b 45 10             	mov    0x10(%ebp),%eax
c0108728:	89 44 24 08          	mov    %eax,0x8(%esp)
c010872c:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010872f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108733:	c7 04 24 7d 86 10 c0 	movl   $0xc010867d,(%esp)
c010873a:	e8 53 fb ff ff       	call   c0108292 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010873f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108742:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0108745:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108748:	c9                   	leave  
c0108749:	c3                   	ret    

c010874a <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010874a:	55                   	push   %ebp
c010874b:	89 e5                	mov    %esp,%ebp
c010874d:	57                   	push   %edi
c010874e:	56                   	push   %esi
c010874f:	53                   	push   %ebx
c0108750:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c0108753:	a1 60 0a 12 c0       	mov    0xc0120a60,%eax
c0108758:	8b 15 64 0a 12 c0    	mov    0xc0120a64,%edx
c010875e:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c0108764:	6b f0 05             	imul   $0x5,%eax,%esi
c0108767:	01 f7                	add    %esi,%edi
c0108769:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c010876e:	f7 e6                	mul    %esi
c0108770:	8d 34 17             	lea    (%edi,%edx,1),%esi
c0108773:	89 f2                	mov    %esi,%edx
c0108775:	83 c0 0b             	add    $0xb,%eax
c0108778:	83 d2 00             	adc    $0x0,%edx
c010877b:	89 c7                	mov    %eax,%edi
c010877d:	83 e7 ff             	and    $0xffffffff,%edi
c0108780:	89 f9                	mov    %edi,%ecx
c0108782:	0f b7 da             	movzwl %dx,%ebx
c0108785:	89 0d 60 0a 12 c0    	mov    %ecx,0xc0120a60
c010878b:	89 1d 64 0a 12 c0    	mov    %ebx,0xc0120a64
    unsigned long long result = (next >> 12);
c0108791:	a1 60 0a 12 c0       	mov    0xc0120a60,%eax
c0108796:	8b 15 64 0a 12 c0    	mov    0xc0120a64,%edx
c010879c:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01087a0:	c1 ea 0c             	shr    $0xc,%edx
c01087a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01087a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c01087a9:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c01087b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01087b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01087b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01087b9:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01087bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01087bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01087c2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01087c6:	74 1c                	je     c01087e4 <rand+0x9a>
c01087c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01087cb:	ba 00 00 00 00       	mov    $0x0,%edx
c01087d0:	f7 75 dc             	divl   -0x24(%ebp)
c01087d3:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01087d6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01087d9:	ba 00 00 00 00       	mov    $0x0,%edx
c01087de:	f7 75 dc             	divl   -0x24(%ebp)
c01087e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01087e4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01087e7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01087ea:	f7 75 dc             	divl   -0x24(%ebp)
c01087ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01087f0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01087f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01087f6:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01087f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01087fc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01087ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c0108802:	83 c4 24             	add    $0x24,%esp
c0108805:	5b                   	pop    %ebx
c0108806:	5e                   	pop    %esi
c0108807:	5f                   	pop    %edi
c0108808:	5d                   	pop    %ebp
c0108809:	c3                   	ret    

c010880a <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010880a:	55                   	push   %ebp
c010880b:	89 e5                	mov    %esp,%ebp
    next = seed;
c010880d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108810:	ba 00 00 00 00       	mov    $0x0,%edx
c0108815:	a3 60 0a 12 c0       	mov    %eax,0xc0120a60
c010881a:	89 15 64 0a 12 c0    	mov    %edx,0xc0120a64
}
c0108820:	5d                   	pop    %ebp
c0108821:	c3                   	ret    

c0108822 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0108822:	55                   	push   %ebp
c0108823:	89 e5                	mov    %esp,%ebp
c0108825:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108828:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010882f:	eb 04                	jmp    c0108835 <strlen+0x13>
        cnt ++;
c0108831:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0108835:	8b 45 08             	mov    0x8(%ebp),%eax
c0108838:	8d 50 01             	lea    0x1(%eax),%edx
c010883b:	89 55 08             	mov    %edx,0x8(%ebp)
c010883e:	0f b6 00             	movzbl (%eax),%eax
c0108841:	84 c0                	test   %al,%al
c0108843:	75 ec                	jne    c0108831 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0108845:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108848:	c9                   	leave  
c0108849:	c3                   	ret    

c010884a <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010884a:	55                   	push   %ebp
c010884b:	89 e5                	mov    %esp,%ebp
c010884d:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108850:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0108857:	eb 04                	jmp    c010885d <strnlen+0x13>
        cnt ++;
c0108859:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c010885d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108860:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108863:	73 10                	jae    c0108875 <strnlen+0x2b>
c0108865:	8b 45 08             	mov    0x8(%ebp),%eax
c0108868:	8d 50 01             	lea    0x1(%eax),%edx
c010886b:	89 55 08             	mov    %edx,0x8(%ebp)
c010886e:	0f b6 00             	movzbl (%eax),%eax
c0108871:	84 c0                	test   %al,%al
c0108873:	75 e4                	jne    c0108859 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0108875:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108878:	c9                   	leave  
c0108879:	c3                   	ret    

c010887a <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010887a:	55                   	push   %ebp
c010887b:	89 e5                	mov    %esp,%ebp
c010887d:	57                   	push   %edi
c010887e:	56                   	push   %esi
c010887f:	83 ec 20             	sub    $0x20,%esp
c0108882:	8b 45 08             	mov    0x8(%ebp),%eax
c0108885:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108888:	8b 45 0c             	mov    0xc(%ebp),%eax
c010888b:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010888e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108891:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108894:	89 d1                	mov    %edx,%ecx
c0108896:	89 c2                	mov    %eax,%edx
c0108898:	89 ce                	mov    %ecx,%esi
c010889a:	89 d7                	mov    %edx,%edi
c010889c:	ac                   	lods   %ds:(%esi),%al
c010889d:	aa                   	stos   %al,%es:(%edi)
c010889e:	84 c0                	test   %al,%al
c01088a0:	75 fa                	jne    c010889c <strcpy+0x22>
c01088a2:	89 fa                	mov    %edi,%edx
c01088a4:	89 f1                	mov    %esi,%ecx
c01088a6:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01088a9:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01088ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c01088af:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c01088b2:	83 c4 20             	add    $0x20,%esp
c01088b5:	5e                   	pop    %esi
c01088b6:	5f                   	pop    %edi
c01088b7:	5d                   	pop    %ebp
c01088b8:	c3                   	ret    

c01088b9 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c01088b9:	55                   	push   %ebp
c01088ba:	89 e5                	mov    %esp,%ebp
c01088bc:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c01088bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01088c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c01088c5:	eb 21                	jmp    c01088e8 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c01088c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01088ca:	0f b6 10             	movzbl (%eax),%edx
c01088cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01088d0:	88 10                	mov    %dl,(%eax)
c01088d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01088d5:	0f b6 00             	movzbl (%eax),%eax
c01088d8:	84 c0                	test   %al,%al
c01088da:	74 04                	je     c01088e0 <strncpy+0x27>
            src ++;
c01088dc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c01088e0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01088e4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c01088e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01088ec:	75 d9                	jne    c01088c7 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c01088ee:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01088f1:	c9                   	leave  
c01088f2:	c3                   	ret    

c01088f3 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c01088f3:	55                   	push   %ebp
c01088f4:	89 e5                	mov    %esp,%ebp
c01088f6:	57                   	push   %edi
c01088f7:	56                   	push   %esi
c01088f8:	83 ec 20             	sub    $0x20,%esp
c01088fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01088fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108901:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108904:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0108907:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010890a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010890d:	89 d1                	mov    %edx,%ecx
c010890f:	89 c2                	mov    %eax,%edx
c0108911:	89 ce                	mov    %ecx,%esi
c0108913:	89 d7                	mov    %edx,%edi
c0108915:	ac                   	lods   %ds:(%esi),%al
c0108916:	ae                   	scas   %es:(%edi),%al
c0108917:	75 08                	jne    c0108921 <strcmp+0x2e>
c0108919:	84 c0                	test   %al,%al
c010891b:	75 f8                	jne    c0108915 <strcmp+0x22>
c010891d:	31 c0                	xor    %eax,%eax
c010891f:	eb 04                	jmp    c0108925 <strcmp+0x32>
c0108921:	19 c0                	sbb    %eax,%eax
c0108923:	0c 01                	or     $0x1,%al
c0108925:	89 fa                	mov    %edi,%edx
c0108927:	89 f1                	mov    %esi,%ecx
c0108929:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010892c:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010892f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0108932:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0108935:	83 c4 20             	add    $0x20,%esp
c0108938:	5e                   	pop    %esi
c0108939:	5f                   	pop    %edi
c010893a:	5d                   	pop    %ebp
c010893b:	c3                   	ret    

c010893c <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010893c:	55                   	push   %ebp
c010893d:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010893f:	eb 0c                	jmp    c010894d <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0108941:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0108945:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108949:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010894d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108951:	74 1a                	je     c010896d <strncmp+0x31>
c0108953:	8b 45 08             	mov    0x8(%ebp),%eax
c0108956:	0f b6 00             	movzbl (%eax),%eax
c0108959:	84 c0                	test   %al,%al
c010895b:	74 10                	je     c010896d <strncmp+0x31>
c010895d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108960:	0f b6 10             	movzbl (%eax),%edx
c0108963:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108966:	0f b6 00             	movzbl (%eax),%eax
c0108969:	38 c2                	cmp    %al,%dl
c010896b:	74 d4                	je     c0108941 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010896d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108971:	74 18                	je     c010898b <strncmp+0x4f>
c0108973:	8b 45 08             	mov    0x8(%ebp),%eax
c0108976:	0f b6 00             	movzbl (%eax),%eax
c0108979:	0f b6 d0             	movzbl %al,%edx
c010897c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010897f:	0f b6 00             	movzbl (%eax),%eax
c0108982:	0f b6 c0             	movzbl %al,%eax
c0108985:	29 c2                	sub    %eax,%edx
c0108987:	89 d0                	mov    %edx,%eax
c0108989:	eb 05                	jmp    c0108990 <strncmp+0x54>
c010898b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108990:	5d                   	pop    %ebp
c0108991:	c3                   	ret    

c0108992 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0108992:	55                   	push   %ebp
c0108993:	89 e5                	mov    %esp,%ebp
c0108995:	83 ec 04             	sub    $0x4,%esp
c0108998:	8b 45 0c             	mov    0xc(%ebp),%eax
c010899b:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010899e:	eb 14                	jmp    c01089b4 <strchr+0x22>
        if (*s == c) {
c01089a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01089a3:	0f b6 00             	movzbl (%eax),%eax
c01089a6:	3a 45 fc             	cmp    -0x4(%ebp),%al
c01089a9:	75 05                	jne    c01089b0 <strchr+0x1e>
            return (char *)s;
c01089ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01089ae:	eb 13                	jmp    c01089c3 <strchr+0x31>
        }
        s ++;
c01089b0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c01089b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01089b7:	0f b6 00             	movzbl (%eax),%eax
c01089ba:	84 c0                	test   %al,%al
c01089bc:	75 e2                	jne    c01089a0 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c01089be:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01089c3:	c9                   	leave  
c01089c4:	c3                   	ret    

c01089c5 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c01089c5:	55                   	push   %ebp
c01089c6:	89 e5                	mov    %esp,%ebp
c01089c8:	83 ec 04             	sub    $0x4,%esp
c01089cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01089ce:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01089d1:	eb 11                	jmp    c01089e4 <strfind+0x1f>
        if (*s == c) {
c01089d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01089d6:	0f b6 00             	movzbl (%eax),%eax
c01089d9:	3a 45 fc             	cmp    -0x4(%ebp),%al
c01089dc:	75 02                	jne    c01089e0 <strfind+0x1b>
            break;
c01089de:	eb 0e                	jmp    c01089ee <strfind+0x29>
        }
        s ++;
c01089e0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c01089e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01089e7:	0f b6 00             	movzbl (%eax),%eax
c01089ea:	84 c0                	test   %al,%al
c01089ec:	75 e5                	jne    c01089d3 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c01089ee:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01089f1:	c9                   	leave  
c01089f2:	c3                   	ret    

c01089f3 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c01089f3:	55                   	push   %ebp
c01089f4:	89 e5                	mov    %esp,%ebp
c01089f6:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c01089f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0108a00:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0108a07:	eb 04                	jmp    c0108a0d <strtol+0x1a>
        s ++;
c0108a09:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0108a0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a10:	0f b6 00             	movzbl (%eax),%eax
c0108a13:	3c 20                	cmp    $0x20,%al
c0108a15:	74 f2                	je     c0108a09 <strtol+0x16>
c0108a17:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a1a:	0f b6 00             	movzbl (%eax),%eax
c0108a1d:	3c 09                	cmp    $0x9,%al
c0108a1f:	74 e8                	je     c0108a09 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0108a21:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a24:	0f b6 00             	movzbl (%eax),%eax
c0108a27:	3c 2b                	cmp    $0x2b,%al
c0108a29:	75 06                	jne    c0108a31 <strtol+0x3e>
        s ++;
c0108a2b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108a2f:	eb 15                	jmp    c0108a46 <strtol+0x53>
    }
    else if (*s == '-') {
c0108a31:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a34:	0f b6 00             	movzbl (%eax),%eax
c0108a37:	3c 2d                	cmp    $0x2d,%al
c0108a39:	75 0b                	jne    c0108a46 <strtol+0x53>
        s ++, neg = 1;
c0108a3b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108a3f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0108a46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108a4a:	74 06                	je     c0108a52 <strtol+0x5f>
c0108a4c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0108a50:	75 24                	jne    c0108a76 <strtol+0x83>
c0108a52:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a55:	0f b6 00             	movzbl (%eax),%eax
c0108a58:	3c 30                	cmp    $0x30,%al
c0108a5a:	75 1a                	jne    c0108a76 <strtol+0x83>
c0108a5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a5f:	83 c0 01             	add    $0x1,%eax
c0108a62:	0f b6 00             	movzbl (%eax),%eax
c0108a65:	3c 78                	cmp    $0x78,%al
c0108a67:	75 0d                	jne    c0108a76 <strtol+0x83>
        s += 2, base = 16;
c0108a69:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0108a6d:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0108a74:	eb 2a                	jmp    c0108aa0 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0108a76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108a7a:	75 17                	jne    c0108a93 <strtol+0xa0>
c0108a7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a7f:	0f b6 00             	movzbl (%eax),%eax
c0108a82:	3c 30                	cmp    $0x30,%al
c0108a84:	75 0d                	jne    c0108a93 <strtol+0xa0>
        s ++, base = 8;
c0108a86:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108a8a:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0108a91:	eb 0d                	jmp    c0108aa0 <strtol+0xad>
    }
    else if (base == 0) {
c0108a93:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108a97:	75 07                	jne    c0108aa0 <strtol+0xad>
        base = 10;
c0108a99:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0108aa0:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aa3:	0f b6 00             	movzbl (%eax),%eax
c0108aa6:	3c 2f                	cmp    $0x2f,%al
c0108aa8:	7e 1b                	jle    c0108ac5 <strtol+0xd2>
c0108aaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aad:	0f b6 00             	movzbl (%eax),%eax
c0108ab0:	3c 39                	cmp    $0x39,%al
c0108ab2:	7f 11                	jg     c0108ac5 <strtol+0xd2>
            dig = *s - '0';
c0108ab4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ab7:	0f b6 00             	movzbl (%eax),%eax
c0108aba:	0f be c0             	movsbl %al,%eax
c0108abd:	83 e8 30             	sub    $0x30,%eax
c0108ac0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108ac3:	eb 48                	jmp    c0108b0d <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0108ac5:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ac8:	0f b6 00             	movzbl (%eax),%eax
c0108acb:	3c 60                	cmp    $0x60,%al
c0108acd:	7e 1b                	jle    c0108aea <strtol+0xf7>
c0108acf:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ad2:	0f b6 00             	movzbl (%eax),%eax
c0108ad5:	3c 7a                	cmp    $0x7a,%al
c0108ad7:	7f 11                	jg     c0108aea <strtol+0xf7>
            dig = *s - 'a' + 10;
c0108ad9:	8b 45 08             	mov    0x8(%ebp),%eax
c0108adc:	0f b6 00             	movzbl (%eax),%eax
c0108adf:	0f be c0             	movsbl %al,%eax
c0108ae2:	83 e8 57             	sub    $0x57,%eax
c0108ae5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108ae8:	eb 23                	jmp    c0108b0d <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0108aea:	8b 45 08             	mov    0x8(%ebp),%eax
c0108aed:	0f b6 00             	movzbl (%eax),%eax
c0108af0:	3c 40                	cmp    $0x40,%al
c0108af2:	7e 3d                	jle    c0108b31 <strtol+0x13e>
c0108af4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108af7:	0f b6 00             	movzbl (%eax),%eax
c0108afa:	3c 5a                	cmp    $0x5a,%al
c0108afc:	7f 33                	jg     c0108b31 <strtol+0x13e>
            dig = *s - 'A' + 10;
c0108afe:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b01:	0f b6 00             	movzbl (%eax),%eax
c0108b04:	0f be c0             	movsbl %al,%eax
c0108b07:	83 e8 37             	sub    $0x37,%eax
c0108b0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0108b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b10:	3b 45 10             	cmp    0x10(%ebp),%eax
c0108b13:	7c 02                	jl     c0108b17 <strtol+0x124>
            break;
c0108b15:	eb 1a                	jmp    c0108b31 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0108b17:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0108b1b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108b1e:	0f af 45 10          	imul   0x10(%ebp),%eax
c0108b22:	89 c2                	mov    %eax,%edx
c0108b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108b27:	01 d0                	add    %edx,%eax
c0108b29:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0108b2c:	e9 6f ff ff ff       	jmp    c0108aa0 <strtol+0xad>

    if (endptr) {
c0108b31:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108b35:	74 08                	je     c0108b3f <strtol+0x14c>
        *endptr = (char *) s;
c0108b37:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b3a:	8b 55 08             	mov    0x8(%ebp),%edx
c0108b3d:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0108b3f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108b43:	74 07                	je     c0108b4c <strtol+0x159>
c0108b45:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108b48:	f7 d8                	neg    %eax
c0108b4a:	eb 03                	jmp    c0108b4f <strtol+0x15c>
c0108b4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0108b4f:	c9                   	leave  
c0108b50:	c3                   	ret    

c0108b51 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0108b51:	55                   	push   %ebp
c0108b52:	89 e5                	mov    %esp,%ebp
c0108b54:	57                   	push   %edi
c0108b55:	83 ec 24             	sub    $0x24,%esp
c0108b58:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b5b:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0108b5e:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0108b62:	8b 55 08             	mov    0x8(%ebp),%edx
c0108b65:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0108b68:	88 45 f7             	mov    %al,-0x9(%ebp)
c0108b6b:	8b 45 10             	mov    0x10(%ebp),%eax
c0108b6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0108b71:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0108b74:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0108b78:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0108b7b:	89 d7                	mov    %edx,%edi
c0108b7d:	f3 aa                	rep stos %al,%es:(%edi)
c0108b7f:	89 fa                	mov    %edi,%edx
c0108b81:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0108b84:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0108b87:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0108b8a:	83 c4 24             	add    $0x24,%esp
c0108b8d:	5f                   	pop    %edi
c0108b8e:	5d                   	pop    %ebp
c0108b8f:	c3                   	ret    

c0108b90 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0108b90:	55                   	push   %ebp
c0108b91:	89 e5                	mov    %esp,%ebp
c0108b93:	57                   	push   %edi
c0108b94:	56                   	push   %esi
c0108b95:	53                   	push   %ebx
c0108b96:	83 ec 30             	sub    $0x30,%esp
c0108b99:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108b9f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ba2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108ba5:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ba8:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0108bab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108bae:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108bb1:	73 42                	jae    c0108bf5 <memmove+0x65>
c0108bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108bb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108bb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108bbc:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108bbf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108bc2:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0108bc5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108bc8:	c1 e8 02             	shr    $0x2,%eax
c0108bcb:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0108bcd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108bd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108bd3:	89 d7                	mov    %edx,%edi
c0108bd5:	89 c6                	mov    %eax,%esi
c0108bd7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108bd9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0108bdc:	83 e1 03             	and    $0x3,%ecx
c0108bdf:	74 02                	je     c0108be3 <memmove+0x53>
c0108be1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108be3:	89 f0                	mov    %esi,%eax
c0108be5:	89 fa                	mov    %edi,%edx
c0108be7:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0108bea:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108bed:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0108bf0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108bf3:	eb 36                	jmp    c0108c2b <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0108bf5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108bf8:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108bfb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108bfe:	01 c2                	add    %eax,%edx
c0108c00:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c03:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0108c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c09:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0108c0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108c0f:	89 c1                	mov    %eax,%ecx
c0108c11:	89 d8                	mov    %ebx,%eax
c0108c13:	89 d6                	mov    %edx,%esi
c0108c15:	89 c7                	mov    %eax,%edi
c0108c17:	fd                   	std    
c0108c18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108c1a:	fc                   	cld    
c0108c1b:	89 f8                	mov    %edi,%eax
c0108c1d:	89 f2                	mov    %esi,%edx
c0108c1f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0108c22:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0108c25:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0108c28:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0108c2b:	83 c4 30             	add    $0x30,%esp
c0108c2e:	5b                   	pop    %ebx
c0108c2f:	5e                   	pop    %esi
c0108c30:	5f                   	pop    %edi
c0108c31:	5d                   	pop    %ebp
c0108c32:	c3                   	ret    

c0108c33 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0108c33:	55                   	push   %ebp
c0108c34:	89 e5                	mov    %esp,%ebp
c0108c36:	57                   	push   %edi
c0108c37:	56                   	push   %esi
c0108c38:	83 ec 20             	sub    $0x20,%esp
c0108c3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108c41:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108c44:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108c47:	8b 45 10             	mov    0x10(%ebp),%eax
c0108c4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0108c4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108c50:	c1 e8 02             	shr    $0x2,%eax
c0108c53:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0108c55:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108c58:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108c5b:	89 d7                	mov    %edx,%edi
c0108c5d:	89 c6                	mov    %eax,%esi
c0108c5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108c61:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0108c64:	83 e1 03             	and    $0x3,%ecx
c0108c67:	74 02                	je     c0108c6b <memcpy+0x38>
c0108c69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108c6b:	89 f0                	mov    %esi,%eax
c0108c6d:	89 fa                	mov    %edi,%edx
c0108c6f:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0108c72:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108c75:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0108c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0108c7b:	83 c4 20             	add    $0x20,%esp
c0108c7e:	5e                   	pop    %esi
c0108c7f:	5f                   	pop    %edi
c0108c80:	5d                   	pop    %ebp
c0108c81:	c3                   	ret    

c0108c82 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0108c82:	55                   	push   %ebp
c0108c83:	89 e5                	mov    %esp,%ebp
c0108c85:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0108c88:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c8b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0108c8e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108c91:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0108c94:	eb 30                	jmp    c0108cc6 <memcmp+0x44>
        if (*s1 != *s2) {
c0108c96:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108c99:	0f b6 10             	movzbl (%eax),%edx
c0108c9c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108c9f:	0f b6 00             	movzbl (%eax),%eax
c0108ca2:	38 c2                	cmp    %al,%dl
c0108ca4:	74 18                	je     c0108cbe <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0108ca6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108ca9:	0f b6 00             	movzbl (%eax),%eax
c0108cac:	0f b6 d0             	movzbl %al,%edx
c0108caf:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108cb2:	0f b6 00             	movzbl (%eax),%eax
c0108cb5:	0f b6 c0             	movzbl %al,%eax
c0108cb8:	29 c2                	sub    %eax,%edx
c0108cba:	89 d0                	mov    %edx,%eax
c0108cbc:	eb 1a                	jmp    c0108cd8 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0108cbe:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0108cc2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0108cc6:	8b 45 10             	mov    0x10(%ebp),%eax
c0108cc9:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108ccc:	89 55 10             	mov    %edx,0x10(%ebp)
c0108ccf:	85 c0                	test   %eax,%eax
c0108cd1:	75 c3                	jne    c0108c96 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0108cd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108cd8:	c9                   	leave  
c0108cd9:	c3                   	ret    
