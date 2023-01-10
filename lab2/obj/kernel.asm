
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 80 11 00       	mov    $0x118000,%eax
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
c0100020:	a3 00 80 11 c0       	mov    %eax,0xc0118000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 70 11 c0       	mov    $0xc0117000,%esp
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
c010003c:	ba 28 af 11 c0       	mov    $0xc011af28,%edx
c0100041:	b8 00 a0 11 c0       	mov    $0xc011a000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 a0 11 c0 	movl   $0xc011a000,(%esp)
c010005d:	e8 a8 5c 00 00       	call   c0105d0a <memset>

    cons_init();                // init the console
c0100062:	e8 82 15 00 00       	call   c01015e9 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 a0 5e 10 c0 	movl   $0xc0105ea0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 bc 5e 10 c0 	movl   $0xc0105ebc,(%esp)
c010007c:	e8 c7 02 00 00       	call   c0100348 <cprintf>

    print_kerninfo();
c0100081:	e8 f6 07 00 00       	call   c010087c <print_kerninfo>

    grade_backtrace();
c0100086:	e8 86 00 00 00       	call   c0100111 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 e0 41 00 00       	call   c0104270 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 bd 16 00 00       	call   c0101752 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 35 18 00 00       	call   c01018cf <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 00 0d 00 00       	call   c0100d9f <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 1c 16 00 00       	call   c01016c0 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a4:	eb fe                	jmp    c01000a4 <kern_init+0x6e>

c01000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a6:	55                   	push   %ebp
c01000a7:	89 e5                	mov    %esp,%ebp
c01000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b3:	00 
c01000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000bb:	00 
c01000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c3:	e8 f8 0b 00 00       	call   c0100cc0 <mon_backtrace>
}
c01000c8:	c9                   	leave  
c01000c9:	c3                   	ret    

c01000ca <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000ca:	55                   	push   %ebp
c01000cb:	89 e5                	mov    %esp,%ebp
c01000cd:	53                   	push   %ebx
c01000ce:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d1:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000d7:	8d 55 08             	lea    0x8(%ebp),%edx
c01000da:	8b 45 08             	mov    0x8(%ebp),%eax
c01000dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000e5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01000e9:	89 04 24             	mov    %eax,(%esp)
c01000ec:	e8 b5 ff ff ff       	call   c01000a6 <grade_backtrace2>
}
c01000f1:	83 c4 14             	add    $0x14,%esp
c01000f4:	5b                   	pop    %ebx
c01000f5:	5d                   	pop    %ebp
c01000f6:	c3                   	ret    

c01000f7 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f7:	55                   	push   %ebp
c01000f8:	89 e5                	mov    %esp,%ebp
c01000fa:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000fd:	8b 45 10             	mov    0x10(%ebp),%eax
c0100100:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100104:	8b 45 08             	mov    0x8(%ebp),%eax
c0100107:	89 04 24             	mov    %eax,(%esp)
c010010a:	e8 bb ff ff ff       	call   c01000ca <grade_backtrace1>
}
c010010f:	c9                   	leave  
c0100110:	c3                   	ret    

c0100111 <grade_backtrace>:

void
grade_backtrace(void) {
c0100111:	55                   	push   %ebp
c0100112:	89 e5                	mov    %esp,%ebp
c0100114:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100117:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010011c:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100123:	ff 
c0100124:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100128:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010012f:	e8 c3 ff ff ff       	call   c01000f7 <grade_backtrace0>
}
c0100134:	c9                   	leave  
c0100135:	c3                   	ret    

c0100136 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100136:	55                   	push   %ebp
c0100137:	89 e5                	mov    %esp,%ebp
c0100139:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010013c:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010013f:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100142:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100145:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100148:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010014c:	0f b7 c0             	movzwl %ax,%eax
c010014f:	83 e0 03             	and    $0x3,%eax
c0100152:	89 c2                	mov    %eax,%edx
c0100154:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100159:	89 54 24 08          	mov    %edx,0x8(%esp)
c010015d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100161:	c7 04 24 c1 5e 10 c0 	movl   $0xc0105ec1,(%esp)
c0100168:	e8 db 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100171:	0f b7 d0             	movzwl %ax,%edx
c0100174:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 cf 5e 10 c0 	movl   $0xc0105ecf,(%esp)
c0100188:	e8 bb 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	0f b7 d0             	movzwl %ax,%edx
c0100194:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c0100199:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a1:	c7 04 24 dd 5e 10 c0 	movl   $0xc0105edd,(%esp)
c01001a8:	e8 9b 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ad:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b1:	0f b7 d0             	movzwl %ax,%edx
c01001b4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c1:	c7 04 24 eb 5e 10 c0 	movl   $0xc0105eeb,(%esp)
c01001c8:	e8 7b 01 00 00       	call   c0100348 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cd:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d1:	0f b7 d0             	movzwl %ax,%edx
c01001d4:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001d9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e1:	c7 04 24 f9 5e 10 c0 	movl   $0xc0105ef9,(%esp)
c01001e8:	e8 5b 01 00 00       	call   c0100348 <cprintf>
    round ++;
c01001ed:	a1 00 a0 11 c0       	mov    0xc011a000,%eax
c01001f2:	83 c0 01             	add    $0x1,%eax
c01001f5:	a3 00 a0 11 c0       	mov    %eax,0xc011a000
}
c01001fa:	c9                   	leave  
c01001fb:	c3                   	ret    

c01001fc <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001fc:	55                   	push   %ebp
c01001fd:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c01001ff:	5d                   	pop    %ebp
c0100200:	c3                   	ret    

c0100201 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100201:	55                   	push   %ebp
c0100202:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100204:	5d                   	pop    %ebp
c0100205:	c3                   	ret    

c0100206 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100206:	55                   	push   %ebp
c0100207:	89 e5                	mov    %esp,%ebp
c0100209:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010020c:	e8 25 ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100211:	c7 04 24 08 5f 10 c0 	movl   $0xc0105f08,(%esp)
c0100218:	e8 2b 01 00 00       	call   c0100348 <cprintf>
    lab1_switch_to_user();
c010021d:	e8 da ff ff ff       	call   c01001fc <lab1_switch_to_user>
    lab1_print_cur_status();
c0100222:	e8 0f ff ff ff       	call   c0100136 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100227:	c7 04 24 28 5f 10 c0 	movl   $0xc0105f28,(%esp)
c010022e:	e8 15 01 00 00       	call   c0100348 <cprintf>
    lab1_switch_to_kernel();
c0100233:	e8 c9 ff ff ff       	call   c0100201 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100238:	e8 f9 fe ff ff       	call   c0100136 <lab1_print_cur_status>
}
c010023d:	c9                   	leave  
c010023e:	c3                   	ret    

c010023f <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010023f:	55                   	push   %ebp
c0100240:	89 e5                	mov    %esp,%ebp
c0100242:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100245:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100249:	74 13                	je     c010025e <readline+0x1f>
        cprintf("%s", prompt);
c010024b:	8b 45 08             	mov    0x8(%ebp),%eax
c010024e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100252:	c7 04 24 47 5f 10 c0 	movl   $0xc0105f47,(%esp)
c0100259:	e8 ea 00 00 00       	call   c0100348 <cprintf>
    }
    int i = 0, c;
c010025e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100265:	e8 66 01 00 00       	call   c01003d0 <getchar>
c010026a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010026d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100271:	79 07                	jns    c010027a <readline+0x3b>
            return NULL;
c0100273:	b8 00 00 00 00       	mov    $0x0,%eax
c0100278:	eb 79                	jmp    c01002f3 <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010027a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010027e:	7e 28                	jle    c01002a8 <readline+0x69>
c0100280:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100287:	7f 1f                	jg     c01002a8 <readline+0x69>
            cputchar(c);
c0100289:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010028c:	89 04 24             	mov    %eax,(%esp)
c010028f:	e8 da 00 00 00       	call   c010036e <cputchar>
            buf[i ++] = c;
c0100294:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100297:	8d 50 01             	lea    0x1(%eax),%edx
c010029a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010029d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002a0:	88 90 20 a0 11 c0    	mov    %dl,-0x3fee5fe0(%eax)
c01002a6:	eb 46                	jmp    c01002ee <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c01002a8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002ac:	75 17                	jne    c01002c5 <readline+0x86>
c01002ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002b2:	7e 11                	jle    c01002c5 <readline+0x86>
            cputchar(c);
c01002b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b7:	89 04 24             	mov    %eax,(%esp)
c01002ba:	e8 af 00 00 00       	call   c010036e <cputchar>
            i --;
c01002bf:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01002c3:	eb 29                	jmp    c01002ee <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c01002c5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002c9:	74 06                	je     c01002d1 <readline+0x92>
c01002cb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002cf:	75 1d                	jne    c01002ee <readline+0xaf>
            cputchar(c);
c01002d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002d4:	89 04 24             	mov    %eax,(%esp)
c01002d7:	e8 92 00 00 00       	call   c010036e <cputchar>
            buf[i] = '\0';
c01002dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002df:	05 20 a0 11 c0       	add    $0xc011a020,%eax
c01002e4:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002e7:	b8 20 a0 11 c0       	mov    $0xc011a020,%eax
c01002ec:	eb 05                	jmp    c01002f3 <readline+0xb4>
        }
    }
c01002ee:	e9 72 ff ff ff       	jmp    c0100265 <readline+0x26>
}
c01002f3:	c9                   	leave  
c01002f4:	c3                   	ret    

c01002f5 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c01002f5:	55                   	push   %ebp
c01002f6:	89 e5                	mov    %esp,%ebp
c01002f8:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01002fe:	89 04 24             	mov    %eax,(%esp)
c0100301:	e8 0f 13 00 00       	call   c0101615 <cons_putc>
    (*cnt) ++;
c0100306:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100309:	8b 00                	mov    (%eax),%eax
c010030b:	8d 50 01             	lea    0x1(%eax),%edx
c010030e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100311:	89 10                	mov    %edx,(%eax)
}
c0100313:	c9                   	leave  
c0100314:	c3                   	ret    

c0100315 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100315:	55                   	push   %ebp
c0100316:	89 e5                	mov    %esp,%ebp
c0100318:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010031b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100322:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100325:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100329:	8b 45 08             	mov    0x8(%ebp),%eax
c010032c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100330:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100333:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100337:	c7 04 24 f5 02 10 c0 	movl   $0xc01002f5,(%esp)
c010033e:	e8 e0 51 00 00       	call   c0105523 <vprintfmt>
    return cnt;
c0100343:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100346:	c9                   	leave  
c0100347:	c3                   	ret    

c0100348 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100348:	55                   	push   %ebp
c0100349:	89 e5                	mov    %esp,%ebp
c010034b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010034e:	8d 45 0c             	lea    0xc(%ebp),%eax
c0100351:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100354:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100357:	89 44 24 04          	mov    %eax,0x4(%esp)
c010035b:	8b 45 08             	mov    0x8(%ebp),%eax
c010035e:	89 04 24             	mov    %eax,(%esp)
c0100361:	e8 af ff ff ff       	call   c0100315 <vcprintf>
c0100366:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100369:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010036c:	c9                   	leave  
c010036d:	c3                   	ret    

c010036e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010036e:	55                   	push   %ebp
c010036f:	89 e5                	mov    %esp,%ebp
c0100371:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100374:	8b 45 08             	mov    0x8(%ebp),%eax
c0100377:	89 04 24             	mov    %eax,(%esp)
c010037a:	e8 96 12 00 00       	call   c0101615 <cons_putc>
}
c010037f:	c9                   	leave  
c0100380:	c3                   	ret    

c0100381 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100381:	55                   	push   %ebp
c0100382:	89 e5                	mov    %esp,%ebp
c0100384:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100387:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010038e:	eb 13                	jmp    c01003a3 <cputs+0x22>
        cputch(c, &cnt);
c0100390:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0100394:	8d 55 f0             	lea    -0x10(%ebp),%edx
c0100397:	89 54 24 04          	mov    %edx,0x4(%esp)
c010039b:	89 04 24             	mov    %eax,(%esp)
c010039e:	e8 52 ff ff ff       	call   c01002f5 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01003a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01003a6:	8d 50 01             	lea    0x1(%eax),%edx
c01003a9:	89 55 08             	mov    %edx,0x8(%ebp)
c01003ac:	0f b6 00             	movzbl (%eax),%eax
c01003af:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003b2:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003b6:	75 d8                	jne    c0100390 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c01003b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003bf:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003c6:	e8 2a ff ff ff       	call   c01002f5 <cputch>
    return cnt;
c01003cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003ce:	c9                   	leave  
c01003cf:	c3                   	ret    

c01003d0 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003d0:	55                   	push   %ebp
c01003d1:	89 e5                	mov    %esp,%ebp
c01003d3:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003d6:	e8 76 12 00 00       	call   c0101651 <cons_getc>
c01003db:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003e2:	74 f2                	je     c01003d6 <getchar+0x6>
        /* do nothing */;
    return c;
c01003e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003e7:	c9                   	leave  
c01003e8:	c3                   	ret    

c01003e9 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01003e9:	55                   	push   %ebp
c01003ea:	89 e5                	mov    %esp,%ebp
c01003ec:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01003ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003f2:	8b 00                	mov    (%eax),%eax
c01003f4:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01003f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01003fa:	8b 00                	mov    (%eax),%eax
c01003fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01003ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100406:	e9 d2 00 00 00       	jmp    c01004dd <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c010040b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010040e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100411:	01 d0                	add    %edx,%eax
c0100413:	89 c2                	mov    %eax,%edx
c0100415:	c1 ea 1f             	shr    $0x1f,%edx
c0100418:	01 d0                	add    %edx,%eax
c010041a:	d1 f8                	sar    %eax
c010041c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010041f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100422:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100425:	eb 04                	jmp    c010042b <stab_binsearch+0x42>
            m --;
c0100427:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010042b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010042e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100431:	7c 1f                	jl     c0100452 <stab_binsearch+0x69>
c0100433:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100436:	89 d0                	mov    %edx,%eax
c0100438:	01 c0                	add    %eax,%eax
c010043a:	01 d0                	add    %edx,%eax
c010043c:	c1 e0 02             	shl    $0x2,%eax
c010043f:	89 c2                	mov    %eax,%edx
c0100441:	8b 45 08             	mov    0x8(%ebp),%eax
c0100444:	01 d0                	add    %edx,%eax
c0100446:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010044a:	0f b6 c0             	movzbl %al,%eax
c010044d:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100450:	75 d5                	jne    c0100427 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100452:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100455:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100458:	7d 0b                	jge    c0100465 <stab_binsearch+0x7c>
            l = true_m + 1;
c010045a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010045d:	83 c0 01             	add    $0x1,%eax
c0100460:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100463:	eb 78                	jmp    c01004dd <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c0100465:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010046c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010046f:	89 d0                	mov    %edx,%eax
c0100471:	01 c0                	add    %eax,%eax
c0100473:	01 d0                	add    %edx,%eax
c0100475:	c1 e0 02             	shl    $0x2,%eax
c0100478:	89 c2                	mov    %eax,%edx
c010047a:	8b 45 08             	mov    0x8(%ebp),%eax
c010047d:	01 d0                	add    %edx,%eax
c010047f:	8b 40 08             	mov    0x8(%eax),%eax
c0100482:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100485:	73 13                	jae    c010049a <stab_binsearch+0xb1>
            *region_left = m;
c0100487:	8b 45 0c             	mov    0xc(%ebp),%eax
c010048a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010048d:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010048f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100492:	83 c0 01             	add    $0x1,%eax
c0100495:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100498:	eb 43                	jmp    c01004dd <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c010049a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010049d:	89 d0                	mov    %edx,%eax
c010049f:	01 c0                	add    %eax,%eax
c01004a1:	01 d0                	add    %edx,%eax
c01004a3:	c1 e0 02             	shl    $0x2,%eax
c01004a6:	89 c2                	mov    %eax,%edx
c01004a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01004ab:	01 d0                	add    %edx,%eax
c01004ad:	8b 40 08             	mov    0x8(%eax),%eax
c01004b0:	3b 45 18             	cmp    0x18(%ebp),%eax
c01004b3:	76 16                	jbe    c01004cb <stab_binsearch+0xe2>
            *region_right = m - 1;
c01004b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004b8:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004bb:	8b 45 10             	mov    0x10(%ebp),%eax
c01004be:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004c3:	83 e8 01             	sub    $0x1,%eax
c01004c6:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004c9:	eb 12                	jmp    c01004dd <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004d1:	89 10                	mov    %edx,(%eax)
            l = m;
c01004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004d9:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01004dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004e3:	0f 8e 22 ff ff ff    	jle    c010040b <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01004e9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004ed:	75 0f                	jne    c01004fe <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c01004ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004f2:	8b 00                	mov    (%eax),%eax
c01004f4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004f7:	8b 45 10             	mov    0x10(%ebp),%eax
c01004fa:	89 10                	mov    %edx,(%eax)
c01004fc:	eb 3f                	jmp    c010053d <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01004fe:	8b 45 10             	mov    0x10(%ebp),%eax
c0100501:	8b 00                	mov    (%eax),%eax
c0100503:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100506:	eb 04                	jmp    c010050c <stab_binsearch+0x123>
c0100508:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c010050c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010050f:	8b 00                	mov    (%eax),%eax
c0100511:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100514:	7d 1f                	jge    c0100535 <stab_binsearch+0x14c>
c0100516:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100519:	89 d0                	mov    %edx,%eax
c010051b:	01 c0                	add    %eax,%eax
c010051d:	01 d0                	add    %edx,%eax
c010051f:	c1 e0 02             	shl    $0x2,%eax
c0100522:	89 c2                	mov    %eax,%edx
c0100524:	8b 45 08             	mov    0x8(%ebp),%eax
c0100527:	01 d0                	add    %edx,%eax
c0100529:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010052d:	0f b6 c0             	movzbl %al,%eax
c0100530:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100533:	75 d3                	jne    c0100508 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c0100535:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100538:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010053b:	89 10                	mov    %edx,(%eax)
    }
}
c010053d:	c9                   	leave  
c010053e:	c3                   	ret    

c010053f <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010053f:	55                   	push   %ebp
c0100540:	89 e5                	mov    %esp,%ebp
c0100542:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100545:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100548:	c7 00 4c 5f 10 c0    	movl   $0xc0105f4c,(%eax)
    info->eip_line = 0;
c010054e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100551:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100558:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055b:	c7 40 08 4c 5f 10 c0 	movl   $0xc0105f4c,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100562:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100565:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010056c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056f:	8b 55 08             	mov    0x8(%ebp),%edx
c0100572:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100575:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100578:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010057f:	c7 45 f4 b0 71 10 c0 	movl   $0xc01071b0,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100586:	c7 45 f0 40 1d 11 c0 	movl   $0xc0111d40,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010058d:	c7 45 ec 41 1d 11 c0 	movl   $0xc0111d41,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100594:	c7 45 e8 a4 47 11 c0 	movl   $0xc01147a4,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010059b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010059e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005a1:	76 0d                	jbe    c01005b0 <debuginfo_eip+0x71>
c01005a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005a6:	83 e8 01             	sub    $0x1,%eax
c01005a9:	0f b6 00             	movzbl (%eax),%eax
c01005ac:	84 c0                	test   %al,%al
c01005ae:	74 0a                	je     c01005ba <debuginfo_eip+0x7b>
        return -1;
c01005b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005b5:	e9 c0 02 00 00       	jmp    c010087a <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005c7:	29 c2                	sub    %eax,%edx
c01005c9:	89 d0                	mov    %edx,%eax
c01005cb:	c1 f8 02             	sar    $0x2,%eax
c01005ce:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005d4:	83 e8 01             	sub    $0x1,%eax
c01005d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005da:	8b 45 08             	mov    0x8(%ebp),%eax
c01005dd:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005e1:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005e8:	00 
c01005e9:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005ec:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01005f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01005f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005fa:	89 04 24             	mov    %eax,(%esp)
c01005fd:	e8 e7 fd ff ff       	call   c01003e9 <stab_binsearch>
    if (lfile == 0)
c0100602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100605:	85 c0                	test   %eax,%eax
c0100607:	75 0a                	jne    c0100613 <debuginfo_eip+0xd4>
        return -1;
c0100609:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010060e:	e9 67 02 00 00       	jmp    c010087a <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100613:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100616:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100619:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010061f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100622:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100626:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010062d:	00 
c010062e:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100631:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100635:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100638:	89 44 24 04          	mov    %eax,0x4(%esp)
c010063c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010063f:	89 04 24             	mov    %eax,(%esp)
c0100642:	e8 a2 fd ff ff       	call   c01003e9 <stab_binsearch>

    if (lfun <= rfun) {
c0100647:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010064a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010064d:	39 c2                	cmp    %eax,%edx
c010064f:	7f 7c                	jg     c01006cd <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100651:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100654:	89 c2                	mov    %eax,%edx
c0100656:	89 d0                	mov    %edx,%eax
c0100658:	01 c0                	add    %eax,%eax
c010065a:	01 d0                	add    %edx,%eax
c010065c:	c1 e0 02             	shl    $0x2,%eax
c010065f:	89 c2                	mov    %eax,%edx
c0100661:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100664:	01 d0                	add    %edx,%eax
c0100666:	8b 10                	mov    (%eax),%edx
c0100668:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010066b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010066e:	29 c1                	sub    %eax,%ecx
c0100670:	89 c8                	mov    %ecx,%eax
c0100672:	39 c2                	cmp    %eax,%edx
c0100674:	73 22                	jae    c0100698 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100676:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100679:	89 c2                	mov    %eax,%edx
c010067b:	89 d0                	mov    %edx,%eax
c010067d:	01 c0                	add    %eax,%eax
c010067f:	01 d0                	add    %edx,%eax
c0100681:	c1 e0 02             	shl    $0x2,%eax
c0100684:	89 c2                	mov    %eax,%edx
c0100686:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100689:	01 d0                	add    %edx,%eax
c010068b:	8b 10                	mov    (%eax),%edx
c010068d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100690:	01 c2                	add    %eax,%edx
c0100692:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100695:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100698:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010069b:	89 c2                	mov    %eax,%edx
c010069d:	89 d0                	mov    %edx,%eax
c010069f:	01 c0                	add    %eax,%eax
c01006a1:	01 d0                	add    %edx,%eax
c01006a3:	c1 e0 02             	shl    $0x2,%eax
c01006a6:	89 c2                	mov    %eax,%edx
c01006a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ab:	01 d0                	add    %edx,%eax
c01006ad:	8b 50 08             	mov    0x8(%eax),%edx
c01006b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b3:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b9:	8b 40 10             	mov    0x10(%eax),%eax
c01006bc:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006cb:	eb 15                	jmp    c01006e2 <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006d0:	8b 55 08             	mov    0x8(%ebp),%edx
c01006d3:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006df:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006e2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006e5:	8b 40 08             	mov    0x8(%eax),%eax
c01006e8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006ef:	00 
c01006f0:	89 04 24             	mov    %eax,(%esp)
c01006f3:	e8 86 54 00 00       	call   c0105b7e <strfind>
c01006f8:	89 c2                	mov    %eax,%edx
c01006fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006fd:	8b 40 08             	mov    0x8(%eax),%eax
c0100700:	29 c2                	sub    %eax,%edx
c0100702:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100705:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100708:	8b 45 08             	mov    0x8(%ebp),%eax
c010070b:	89 44 24 10          	mov    %eax,0x10(%esp)
c010070f:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100716:	00 
c0100717:	8d 45 d0             	lea    -0x30(%ebp),%eax
c010071a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010071e:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100721:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100725:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100728:	89 04 24             	mov    %eax,(%esp)
c010072b:	e8 b9 fc ff ff       	call   c01003e9 <stab_binsearch>
    if (lline <= rline) {
c0100730:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100733:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100736:	39 c2                	cmp    %eax,%edx
c0100738:	7f 24                	jg     c010075e <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c010073a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010073d:	89 c2                	mov    %eax,%edx
c010073f:	89 d0                	mov    %edx,%eax
c0100741:	01 c0                	add    %eax,%eax
c0100743:	01 d0                	add    %edx,%eax
c0100745:	c1 e0 02             	shl    $0x2,%eax
c0100748:	89 c2                	mov    %eax,%edx
c010074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010074d:	01 d0                	add    %edx,%eax
c010074f:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100753:	0f b7 d0             	movzwl %ax,%edx
c0100756:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100759:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010075c:	eb 13                	jmp    c0100771 <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c010075e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100763:	e9 12 01 00 00       	jmp    c010087a <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100768:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010076b:	83 e8 01             	sub    $0x1,%eax
c010076e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100771:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100774:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100777:	39 c2                	cmp    %eax,%edx
c0100779:	7c 56                	jl     c01007d1 <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c010077b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010077e:	89 c2                	mov    %eax,%edx
c0100780:	89 d0                	mov    %edx,%eax
c0100782:	01 c0                	add    %eax,%eax
c0100784:	01 d0                	add    %edx,%eax
c0100786:	c1 e0 02             	shl    $0x2,%eax
c0100789:	89 c2                	mov    %eax,%edx
c010078b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010078e:	01 d0                	add    %edx,%eax
c0100790:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100794:	3c 84                	cmp    $0x84,%al
c0100796:	74 39                	je     c01007d1 <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100798:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010079b:	89 c2                	mov    %eax,%edx
c010079d:	89 d0                	mov    %edx,%eax
c010079f:	01 c0                	add    %eax,%eax
c01007a1:	01 d0                	add    %edx,%eax
c01007a3:	c1 e0 02             	shl    $0x2,%eax
c01007a6:	89 c2                	mov    %eax,%edx
c01007a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ab:	01 d0                	add    %edx,%eax
c01007ad:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007b1:	3c 64                	cmp    $0x64,%al
c01007b3:	75 b3                	jne    c0100768 <debuginfo_eip+0x229>
c01007b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007b8:	89 c2                	mov    %eax,%edx
c01007ba:	89 d0                	mov    %edx,%eax
c01007bc:	01 c0                	add    %eax,%eax
c01007be:	01 d0                	add    %edx,%eax
c01007c0:	c1 e0 02             	shl    $0x2,%eax
c01007c3:	89 c2                	mov    %eax,%edx
c01007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c8:	01 d0                	add    %edx,%eax
c01007ca:	8b 40 08             	mov    0x8(%eax),%eax
c01007cd:	85 c0                	test   %eax,%eax
c01007cf:	74 97                	je     c0100768 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007d1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007d7:	39 c2                	cmp    %eax,%edx
c01007d9:	7c 46                	jl     c0100821 <debuginfo_eip+0x2e2>
c01007db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007de:	89 c2                	mov    %eax,%edx
c01007e0:	89 d0                	mov    %edx,%eax
c01007e2:	01 c0                	add    %eax,%eax
c01007e4:	01 d0                	add    %edx,%eax
c01007e6:	c1 e0 02             	shl    $0x2,%eax
c01007e9:	89 c2                	mov    %eax,%edx
c01007eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ee:	01 d0                	add    %edx,%eax
c01007f0:	8b 10                	mov    (%eax),%edx
c01007f2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01007f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007f8:	29 c1                	sub    %eax,%ecx
c01007fa:	89 c8                	mov    %ecx,%eax
c01007fc:	39 c2                	cmp    %eax,%edx
c01007fe:	73 21                	jae    c0100821 <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100800:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100803:	89 c2                	mov    %eax,%edx
c0100805:	89 d0                	mov    %edx,%eax
c0100807:	01 c0                	add    %eax,%eax
c0100809:	01 d0                	add    %edx,%eax
c010080b:	c1 e0 02             	shl    $0x2,%eax
c010080e:	89 c2                	mov    %eax,%edx
c0100810:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100813:	01 d0                	add    %edx,%eax
c0100815:	8b 10                	mov    (%eax),%edx
c0100817:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010081a:	01 c2                	add    %eax,%edx
c010081c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081f:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100821:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100824:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100827:	39 c2                	cmp    %eax,%edx
c0100829:	7d 4a                	jge    c0100875 <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c010082b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010082e:	83 c0 01             	add    $0x1,%eax
c0100831:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100834:	eb 18                	jmp    c010084e <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100836:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100839:	8b 40 14             	mov    0x14(%eax),%eax
c010083c:	8d 50 01             	lea    0x1(%eax),%edx
c010083f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100842:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100848:	83 c0 01             	add    $0x1,%eax
c010084b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010084e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100851:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100854:	39 c2                	cmp    %eax,%edx
c0100856:	7d 1d                	jge    c0100875 <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100858:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010085b:	89 c2                	mov    %eax,%edx
c010085d:	89 d0                	mov    %edx,%eax
c010085f:	01 c0                	add    %eax,%eax
c0100861:	01 d0                	add    %edx,%eax
c0100863:	c1 e0 02             	shl    $0x2,%eax
c0100866:	89 c2                	mov    %eax,%edx
c0100868:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010086b:	01 d0                	add    %edx,%eax
c010086d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100871:	3c a0                	cmp    $0xa0,%al
c0100873:	74 c1                	je     c0100836 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100875:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010087a:	c9                   	leave  
c010087b:	c3                   	ret    

c010087c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010087c:	55                   	push   %ebp
c010087d:	89 e5                	mov    %esp,%ebp
c010087f:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100882:	c7 04 24 56 5f 10 c0 	movl   $0xc0105f56,(%esp)
c0100889:	e8 ba fa ff ff       	call   c0100348 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010088e:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100895:	c0 
c0100896:	c7 04 24 6f 5f 10 c0 	movl   $0xc0105f6f,(%esp)
c010089d:	e8 a6 fa ff ff       	call   c0100348 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01008a2:	c7 44 24 04 93 5e 10 	movl   $0xc0105e93,0x4(%esp)
c01008a9:	c0 
c01008aa:	c7 04 24 87 5f 10 c0 	movl   $0xc0105f87,(%esp)
c01008b1:	e8 92 fa ff ff       	call   c0100348 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008b6:	c7 44 24 04 00 a0 11 	movl   $0xc011a000,0x4(%esp)
c01008bd:	c0 
c01008be:	c7 04 24 9f 5f 10 c0 	movl   $0xc0105f9f,(%esp)
c01008c5:	e8 7e fa ff ff       	call   c0100348 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008ca:	c7 44 24 04 28 af 11 	movl   $0xc011af28,0x4(%esp)
c01008d1:	c0 
c01008d2:	c7 04 24 b7 5f 10 c0 	movl   $0xc0105fb7,(%esp)
c01008d9:	e8 6a fa ff ff       	call   c0100348 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008de:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c01008e3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008e9:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01008ee:	29 c2                	sub    %eax,%edx
c01008f0:	89 d0                	mov    %edx,%eax
c01008f2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f8:	85 c0                	test   %eax,%eax
c01008fa:	0f 48 c2             	cmovs  %edx,%eax
c01008fd:	c1 f8 0a             	sar    $0xa,%eax
c0100900:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100904:	c7 04 24 d0 5f 10 c0 	movl   $0xc0105fd0,(%esp)
c010090b:	e8 38 fa ff ff       	call   c0100348 <cprintf>
}
c0100910:	c9                   	leave  
c0100911:	c3                   	ret    

c0100912 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100912:	55                   	push   %ebp
c0100913:	89 e5                	mov    %esp,%ebp
c0100915:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c010091b:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010091e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100922:	8b 45 08             	mov    0x8(%ebp),%eax
c0100925:	89 04 24             	mov    %eax,(%esp)
c0100928:	e8 12 fc ff ff       	call   c010053f <debuginfo_eip>
c010092d:	85 c0                	test   %eax,%eax
c010092f:	74 15                	je     c0100946 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100931:	8b 45 08             	mov    0x8(%ebp),%eax
c0100934:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100938:	c7 04 24 fa 5f 10 c0 	movl   $0xc0105ffa,(%esp)
c010093f:	e8 04 fa ff ff       	call   c0100348 <cprintf>
c0100944:	eb 6d                	jmp    c01009b3 <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010094d:	eb 1c                	jmp    c010096b <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c010094f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100952:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100955:	01 d0                	add    %edx,%eax
c0100957:	0f b6 00             	movzbl (%eax),%eax
c010095a:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100960:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100963:	01 ca                	add    %ecx,%edx
c0100965:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100967:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010096b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010096e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100971:	7f dc                	jg     c010094f <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100973:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100979:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010097c:	01 d0                	add    %edx,%eax
c010097e:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100981:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100984:	8b 55 08             	mov    0x8(%ebp),%edx
c0100987:	89 d1                	mov    %edx,%ecx
c0100989:	29 c1                	sub    %eax,%ecx
c010098b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010098e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100991:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100995:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010099b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010099f:	89 54 24 08          	mov    %edx,0x8(%esp)
c01009a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009a7:	c7 04 24 16 60 10 c0 	movl   $0xc0106016,(%esp)
c01009ae:	e8 95 f9 ff ff       	call   c0100348 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c01009b3:	c9                   	leave  
c01009b4:	c3                   	ret    

c01009b5 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009b5:	55                   	push   %ebp
c01009b6:	89 e5                	mov    %esp,%ebp
c01009b8:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009bb:	8b 45 04             	mov    0x4(%ebp),%eax
c01009be:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009c4:	c9                   	leave  
c01009c5:	c3                   	ret    

c01009c6 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009c6:	55                   	push   %ebp
c01009c7:	89 e5                	mov    %esp,%ebp
c01009c9:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009cc:	89 e8                	mov    %ebp,%eax
c01009ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c01009d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp_curr=read_ebp(), eip_curr=read_eip();
c01009d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01009d7:	e8 d9 ff ff ff       	call   c01009b5 <read_eip>
c01009dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int stack_level,num;
    	for(stack_level=0;stack_level<STACKFRAME_DEPTH&&ebp_curr!=0;stack_level++){
c01009df:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009e6:	e9 88 00 00 00       	jmp    c0100a73 <print_stackframe+0xad>
     		cprintf("ebp:0x%08x eip:0x%08x args:",ebp_curr,eip_curr); 
c01009eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009ee:	89 44 24 08          	mov    %eax,0x8(%esp)
c01009f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009f5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009f9:	c7 04 24 28 60 10 c0 	movl   $0xc0106028,(%esp)
c0100a00:	e8 43 f9 ff ff       	call   c0100348 <cprintf>
        	uint32_t *args=(uint32_t *)ebp_curr+2;
c0100a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a08:	83 c0 08             	add    $0x8,%eax
c0100a0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        	for(num=0;num<4;num++){
c0100a0e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100a15:	eb 25                	jmp    c0100a3c <print_stackframe+0x76>
            		cprintf("0x%08x ", args[num]);
c0100a17:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100a24:	01 d0                	add    %edx,%eax
c0100a26:	8b 00                	mov    (%eax),%eax
c0100a28:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a2c:	c7 04 24 44 60 10 c0 	movl   $0xc0106044,(%esp)
c0100a33:	e8 10 f9 ff ff       	call   c0100348 <cprintf>
    uint32_t ebp_curr=read_ebp(), eip_curr=read_eip();
	int stack_level,num;
    	for(stack_level=0;stack_level<STACKFRAME_DEPTH&&ebp_curr!=0;stack_level++){
     		cprintf("ebp:0x%08x eip:0x%08x args:",ebp_curr,eip_curr); 
        	uint32_t *args=(uint32_t *)ebp_curr+2;
        	for(num=0;num<4;num++){
c0100a38:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0100a3c:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100a40:	7e d5                	jle    c0100a17 <print_stackframe+0x51>
            		cprintf("0x%08x ", args[num]);
        	}
        	cprintf("\n");
c0100a42:	c7 04 24 4c 60 10 c0 	movl   $0xc010604c,(%esp)
c0100a49:	e8 fa f8 ff ff       	call   c0100348 <cprintf>
        	print_debuginfo(eip_curr-1);
c0100a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a51:	83 e8 01             	sub    $0x1,%eax
c0100a54:	89 04 24             	mov    %eax,(%esp)
c0100a57:	e8 b6 fe ff ff       	call   c0100912 <print_debuginfo>
        	eip_curr=((uint32_t *)ebp_curr)[1];
c0100a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a5f:	83 c0 04             	add    $0x4,%eax
c0100a62:	8b 00                	mov    (%eax),%eax
c0100a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
        	ebp_curr=((uint32_t *)ebp_curr)[0];
c0100a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a6a:	8b 00                	mov    (%eax),%eax
c0100a6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp_curr=read_ebp(), eip_curr=read_eip();
	int stack_level,num;
    	for(stack_level=0;stack_level<STACKFRAME_DEPTH&&ebp_curr!=0;stack_level++){
c0100a6f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0100a73:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a77:	7f 0a                	jg     c0100a83 <print_stackframe+0xbd>
c0100a79:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a7d:	0f 85 68 ff ff ff    	jne    c01009eb <print_stackframe+0x25>
        	cprintf("\n");
        	print_debuginfo(eip_curr-1);
        	eip_curr=((uint32_t *)ebp_curr)[1];
        	ebp_curr=((uint32_t *)ebp_curr)[0];
	}
}
c0100a83:	c9                   	leave  
c0100a84:	c3                   	ret    

c0100a85 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a85:	55                   	push   %ebp
c0100a86:	89 e5                	mov    %esp,%ebp
c0100a88:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100a8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a92:	eb 0c                	jmp    c0100aa0 <parse+0x1b>
            *buf ++ = '\0';
c0100a94:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a97:	8d 50 01             	lea    0x1(%eax),%edx
c0100a9a:	89 55 08             	mov    %edx,0x8(%ebp)
c0100a9d:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100aa0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa3:	0f b6 00             	movzbl (%eax),%eax
c0100aa6:	84 c0                	test   %al,%al
c0100aa8:	74 1d                	je     c0100ac7 <parse+0x42>
c0100aaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aad:	0f b6 00             	movzbl (%eax),%eax
c0100ab0:	0f be c0             	movsbl %al,%eax
c0100ab3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ab7:	c7 04 24 d0 60 10 c0 	movl   $0xc01060d0,(%esp)
c0100abe:	e8 88 50 00 00       	call   c0105b4b <strchr>
c0100ac3:	85 c0                	test   %eax,%eax
c0100ac5:	75 cd                	jne    c0100a94 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100ac7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aca:	0f b6 00             	movzbl (%eax),%eax
c0100acd:	84 c0                	test   %al,%al
c0100acf:	75 02                	jne    c0100ad3 <parse+0x4e>
            break;
c0100ad1:	eb 67                	jmp    c0100b3a <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100ad3:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100ad7:	75 14                	jne    c0100aed <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ad9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100ae0:	00 
c0100ae1:	c7 04 24 d5 60 10 c0 	movl   $0xc01060d5,(%esp)
c0100ae8:	e8 5b f8 ff ff       	call   c0100348 <cprintf>
        }
        argv[argc ++] = buf;
c0100aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100af0:	8d 50 01             	lea    0x1(%eax),%edx
c0100af3:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100af6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100afd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b00:	01 c2                	add    %eax,%edx
c0100b02:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b05:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b07:	eb 04                	jmp    c0100b0d <parse+0x88>
            buf ++;
c0100b09:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b10:	0f b6 00             	movzbl (%eax),%eax
c0100b13:	84 c0                	test   %al,%al
c0100b15:	74 1d                	je     c0100b34 <parse+0xaf>
c0100b17:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b1a:	0f b6 00             	movzbl (%eax),%eax
c0100b1d:	0f be c0             	movsbl %al,%eax
c0100b20:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b24:	c7 04 24 d0 60 10 c0 	movl   $0xc01060d0,(%esp)
c0100b2b:	e8 1b 50 00 00       	call   c0105b4b <strchr>
c0100b30:	85 c0                	test   %eax,%eax
c0100b32:	74 d5                	je     c0100b09 <parse+0x84>
            buf ++;
        }
    }
c0100b34:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b35:	e9 66 ff ff ff       	jmp    c0100aa0 <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b3d:	c9                   	leave  
c0100b3e:	c3                   	ret    

c0100b3f <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b3f:	55                   	push   %ebp
c0100b40:	89 e5                	mov    %esp,%ebp
c0100b42:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b45:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b4f:	89 04 24             	mov    %eax,(%esp)
c0100b52:	e8 2e ff ff ff       	call   c0100a85 <parse>
c0100b57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b5e:	75 0a                	jne    c0100b6a <runcmd+0x2b>
        return 0;
c0100b60:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b65:	e9 85 00 00 00       	jmp    c0100bef <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b71:	eb 5c                	jmp    c0100bcf <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b73:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100b76:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b79:	89 d0                	mov    %edx,%eax
c0100b7b:	01 c0                	add    %eax,%eax
c0100b7d:	01 d0                	add    %edx,%eax
c0100b7f:	c1 e0 02             	shl    $0x2,%eax
c0100b82:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100b87:	8b 00                	mov    (%eax),%eax
c0100b89:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100b8d:	89 04 24             	mov    %eax,(%esp)
c0100b90:	e8 17 4f 00 00       	call   c0105aac <strcmp>
c0100b95:	85 c0                	test   %eax,%eax
c0100b97:	75 32                	jne    c0100bcb <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b9c:	89 d0                	mov    %edx,%eax
c0100b9e:	01 c0                	add    %eax,%eax
c0100ba0:	01 d0                	add    %edx,%eax
c0100ba2:	c1 e0 02             	shl    $0x2,%eax
c0100ba5:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100baa:	8b 40 08             	mov    0x8(%eax),%eax
c0100bad:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100bb0:	8d 4a ff             	lea    -0x1(%edx),%ecx
c0100bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100bb6:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100bba:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0100bbd:	83 c2 04             	add    $0x4,%edx
c0100bc0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100bc4:	89 0c 24             	mov    %ecx,(%esp)
c0100bc7:	ff d0                	call   *%eax
c0100bc9:	eb 24                	jmp    c0100bef <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bcb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bd2:	83 f8 02             	cmp    $0x2,%eax
c0100bd5:	76 9c                	jbe    c0100b73 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100bd7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100bda:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bde:	c7 04 24 f3 60 10 c0 	movl   $0xc01060f3,(%esp)
c0100be5:	e8 5e f7 ff ff       	call   c0100348 <cprintf>
    return 0;
c0100bea:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100bef:	c9                   	leave  
c0100bf0:	c3                   	ret    

c0100bf1 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100bf1:	55                   	push   %ebp
c0100bf2:	89 e5                	mov    %esp,%ebp
c0100bf4:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100bf7:	c7 04 24 0c 61 10 c0 	movl   $0xc010610c,(%esp)
c0100bfe:	e8 45 f7 ff ff       	call   c0100348 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c03:	c7 04 24 34 61 10 c0 	movl   $0xc0106134,(%esp)
c0100c0a:	e8 39 f7 ff ff       	call   c0100348 <cprintf>

    if (tf != NULL) {
c0100c0f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c13:	74 0b                	je     c0100c20 <kmonitor+0x2f>
        print_trapframe(tf);
c0100c15:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c18:	89 04 24             	mov    %eax,(%esp)
c0100c1b:	e8 e7 0d 00 00       	call   c0101a07 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c20:	c7 04 24 59 61 10 c0 	movl   $0xc0106159,(%esp)
c0100c27:	e8 13 f6 ff ff       	call   c010023f <readline>
c0100c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c33:	74 18                	je     c0100c4d <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c0100c35:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c38:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c3f:	89 04 24             	mov    %eax,(%esp)
c0100c42:	e8 f8 fe ff ff       	call   c0100b3f <runcmd>
c0100c47:	85 c0                	test   %eax,%eax
c0100c49:	79 02                	jns    c0100c4d <kmonitor+0x5c>
                break;
c0100c4b:	eb 02                	jmp    c0100c4f <kmonitor+0x5e>
            }
        }
    }
c0100c4d:	eb d1                	jmp    c0100c20 <kmonitor+0x2f>
}
c0100c4f:	c9                   	leave  
c0100c50:	c3                   	ret    

c0100c51 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c51:	55                   	push   %ebp
c0100c52:	89 e5                	mov    %esp,%ebp
c0100c54:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c5e:	eb 3f                	jmp    c0100c9f <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c60:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c63:	89 d0                	mov    %edx,%eax
c0100c65:	01 c0                	add    %eax,%eax
c0100c67:	01 d0                	add    %edx,%eax
c0100c69:	c1 e0 02             	shl    $0x2,%eax
c0100c6c:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c71:	8b 48 04             	mov    0x4(%eax),%ecx
c0100c74:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c77:	89 d0                	mov    %edx,%eax
c0100c79:	01 c0                	add    %eax,%eax
c0100c7b:	01 d0                	add    %edx,%eax
c0100c7d:	c1 e0 02             	shl    $0x2,%eax
c0100c80:	05 00 70 11 c0       	add    $0xc0117000,%eax
c0100c85:	8b 00                	mov    (%eax),%eax
c0100c87:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c8f:	c7 04 24 5d 61 10 c0 	movl   $0xc010615d,(%esp)
c0100c96:	e8 ad f6 ff ff       	call   c0100348 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c9b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ca2:	83 f8 02             	cmp    $0x2,%eax
c0100ca5:	76 b9                	jbe    c0100c60 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cac:	c9                   	leave  
c0100cad:	c3                   	ret    

c0100cae <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cae:	55                   	push   %ebp
c0100caf:	89 e5                	mov    %esp,%ebp
c0100cb1:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cb4:	e8 c3 fb ff ff       	call   c010087c <print_kerninfo>
    return 0;
c0100cb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cbe:	c9                   	leave  
c0100cbf:	c3                   	ret    

c0100cc0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cc0:	55                   	push   %ebp
c0100cc1:	89 e5                	mov    %esp,%ebp
c0100cc3:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cc6:	e8 fb fc ff ff       	call   c01009c6 <print_stackframe>
    return 0;
c0100ccb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cd0:	c9                   	leave  
c0100cd1:	c3                   	ret    

c0100cd2 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100cd2:	55                   	push   %ebp
c0100cd3:	89 e5                	mov    %esp,%ebp
c0100cd5:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100cd8:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
c0100cdd:	85 c0                	test   %eax,%eax
c0100cdf:	74 02                	je     c0100ce3 <__panic+0x11>
        goto panic_dead;
c0100ce1:	eb 59                	jmp    c0100d3c <__panic+0x6a>
    }
    is_panic = 1;
c0100ce3:	c7 05 20 a4 11 c0 01 	movl   $0x1,0xc011a420
c0100cea:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100ced:	8d 45 14             	lea    0x14(%ebp),%eax
c0100cf0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100cf6:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100cfa:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d01:	c7 04 24 66 61 10 c0 	movl   $0xc0106166,(%esp)
c0100d08:	e8 3b f6 ff ff       	call   c0100348 <cprintf>
    vcprintf(fmt, ap);
c0100d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d14:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d17:	89 04 24             	mov    %eax,(%esp)
c0100d1a:	e8 f6 f5 ff ff       	call   c0100315 <vcprintf>
    cprintf("\n");
c0100d1f:	c7 04 24 82 61 10 c0 	movl   $0xc0106182,(%esp)
c0100d26:	e8 1d f6 ff ff       	call   c0100348 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d2b:	c7 04 24 84 61 10 c0 	movl   $0xc0106184,(%esp)
c0100d32:	e8 11 f6 ff ff       	call   c0100348 <cprintf>
    print_stackframe();
c0100d37:	e8 8a fc ff ff       	call   c01009c6 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d3c:	e8 85 09 00 00       	call   c01016c6 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d48:	e8 a4 fe ff ff       	call   c0100bf1 <kmonitor>
    }
c0100d4d:	eb f2                	jmp    c0100d41 <__panic+0x6f>

c0100d4f <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d4f:	55                   	push   %ebp
c0100d50:	89 e5                	mov    %esp,%ebp
c0100d52:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d55:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d58:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d5e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d62:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d65:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d69:	c7 04 24 96 61 10 c0 	movl   $0xc0106196,(%esp)
c0100d70:	e8 d3 f5 ff ff       	call   c0100348 <cprintf>
    vcprintf(fmt, ap);
c0100d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d78:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d7c:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d7f:	89 04 24             	mov    %eax,(%esp)
c0100d82:	e8 8e f5 ff ff       	call   c0100315 <vcprintf>
    cprintf("\n");
c0100d87:	c7 04 24 82 61 10 c0 	movl   $0xc0106182,(%esp)
c0100d8e:	e8 b5 f5 ff ff       	call   c0100348 <cprintf>
    va_end(ap);
}
c0100d93:	c9                   	leave  
c0100d94:	c3                   	ret    

c0100d95 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100d95:	55                   	push   %ebp
c0100d96:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100d98:	a1 20 a4 11 c0       	mov    0xc011a420,%eax
}
c0100d9d:	5d                   	pop    %ebp
c0100d9e:	c3                   	ret    

c0100d9f <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d9f:	55                   	push   %ebp
c0100da0:	89 e5                	mov    %esp,%ebp
c0100da2:	83 ec 28             	sub    $0x28,%esp
c0100da5:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100dab:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100daf:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100db3:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100db7:	ee                   	out    %al,(%dx)
c0100db8:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dbe:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c0100dc2:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dc6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dca:	ee                   	out    %al,(%dx)
c0100dcb:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c0100dd1:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c0100dd5:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dd9:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100ddd:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dde:	c7 05 0c af 11 c0 00 	movl   $0x0,0xc011af0c
c0100de5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100de8:	c7 04 24 b4 61 10 c0 	movl   $0xc01061b4,(%esp)
c0100def:	e8 54 f5 ff ff       	call   c0100348 <cprintf>
    pic_enable(IRQ_TIMER);
c0100df4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100dfb:	e8 24 09 00 00       	call   c0101724 <pic_enable>
}
c0100e00:	c9                   	leave  
c0100e01:	c3                   	ret    

c0100e02 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e02:	55                   	push   %ebp
c0100e03:	89 e5                	mov    %esp,%ebp
c0100e05:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e08:	9c                   	pushf  
c0100e09:	58                   	pop    %eax
c0100e0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e10:	25 00 02 00 00       	and    $0x200,%eax
c0100e15:	85 c0                	test   %eax,%eax
c0100e17:	74 0c                	je     c0100e25 <__intr_save+0x23>
        intr_disable();
c0100e19:	e8 a8 08 00 00       	call   c01016c6 <intr_disable>
        return 1;
c0100e1e:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e23:	eb 05                	jmp    c0100e2a <__intr_save+0x28>
    }
    return 0;
c0100e25:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e2a:	c9                   	leave  
c0100e2b:	c3                   	ret    

c0100e2c <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e2c:	55                   	push   %ebp
c0100e2d:	89 e5                	mov    %esp,%ebp
c0100e2f:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e32:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e36:	74 05                	je     c0100e3d <__intr_restore+0x11>
        intr_enable();
c0100e38:	e8 83 08 00 00       	call   c01016c0 <intr_enable>
    }
}
c0100e3d:	c9                   	leave  
c0100e3e:	c3                   	ret    

c0100e3f <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e3f:	55                   	push   %ebp
c0100e40:	89 e5                	mov    %esp,%ebp
c0100e42:	83 ec 10             	sub    $0x10,%esp
c0100e45:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e4b:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e4f:	89 c2                	mov    %eax,%edx
c0100e51:	ec                   	in     (%dx),%al
c0100e52:	88 45 fd             	mov    %al,-0x3(%ebp)
c0100e55:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e5b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e5f:	89 c2                	mov    %eax,%edx
c0100e61:	ec                   	in     (%dx),%al
c0100e62:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e65:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e6b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e6f:	89 c2                	mov    %eax,%edx
c0100e71:	ec                   	in     (%dx),%al
c0100e72:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e75:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0100e7b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e7f:	89 c2                	mov    %eax,%edx
c0100e81:	ec                   	in     (%dx),%al
c0100e82:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e85:	c9                   	leave  
c0100e86:	c3                   	ret    

c0100e87 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e87:	55                   	push   %ebp
c0100e88:	89 e5                	mov    %esp,%ebp
c0100e8a:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e8d:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e97:	0f b7 00             	movzwl (%eax),%eax
c0100e9a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea1:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ea6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea9:	0f b7 00             	movzwl (%eax),%eax
c0100eac:	66 3d 5a a5          	cmp    $0xa55a,%ax
c0100eb0:	74 12                	je     c0100ec4 <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100eb2:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100eb9:	66 c7 05 46 a4 11 c0 	movw   $0x3b4,0xc011a446
c0100ec0:	b4 03 
c0100ec2:	eb 13                	jmp    c0100ed7 <cga_init+0x50>
    } else {
        *cp = was;
c0100ec4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ec7:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ecb:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ece:	66 c7 05 46 a4 11 c0 	movw   $0x3d4,0xc011a446
c0100ed5:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ed7:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ede:	0f b7 c0             	movzwl %ax,%eax
c0100ee1:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0100ee5:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ee9:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100eed:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ef1:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ef2:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100ef9:	83 c0 01             	add    $0x1,%eax
c0100efc:	0f b7 c0             	movzwl %ax,%eax
c0100eff:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f03:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f07:	89 c2                	mov    %eax,%edx
c0100f09:	ec                   	in     (%dx),%al
c0100f0a:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f0d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f11:	0f b6 c0             	movzbl %al,%eax
c0100f14:	c1 e0 08             	shl    $0x8,%eax
c0100f17:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f1a:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f21:	0f b7 c0             	movzwl %ax,%eax
c0100f24:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c0100f28:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f2c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f30:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100f34:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f35:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0100f3c:	83 c0 01             	add    $0x1,%eax
c0100f3f:	0f b7 c0             	movzwl %ax,%eax
c0100f42:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f46:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0100f4a:	89 c2                	mov    %eax,%edx
c0100f4c:	ec                   	in     (%dx),%al
c0100f4d:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c0100f50:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f54:	0f b6 c0             	movzbl %al,%eax
c0100f57:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f5a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f5d:	a3 40 a4 11 c0       	mov    %eax,0xc011a440
    crt_pos = pos;
c0100f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f65:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
}
c0100f6b:	c9                   	leave  
c0100f6c:	c3                   	ret    

c0100f6d <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f6d:	55                   	push   %ebp
c0100f6e:	89 e5                	mov    %esp,%ebp
c0100f70:	83 ec 48             	sub    $0x48,%esp
c0100f73:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f79:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f7d:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100f81:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f85:	ee                   	out    %al,(%dx)
c0100f86:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0100f8c:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c0100f90:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f94:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f98:	ee                   	out    %al,(%dx)
c0100f99:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0100f9f:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c0100fa3:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100fa7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fab:	ee                   	out    %al,(%dx)
c0100fac:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fb2:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0100fb6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100fba:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fbe:	ee                   	out    %al,(%dx)
c0100fbf:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c0100fc5:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0100fc9:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100fcd:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100fd1:	ee                   	out    %al,(%dx)
c0100fd2:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0100fd8:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0100fdc:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100fe0:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100fe4:	ee                   	out    %al,(%dx)
c0100fe5:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100feb:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0100fef:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100ff3:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100ff7:	ee                   	out    %al,(%dx)
c0100ff8:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ffe:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c0101002:	89 c2                	mov    %eax,%edx
c0101004:	ec                   	in     (%dx),%al
c0101005:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c0101008:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010100c:	3c ff                	cmp    $0xff,%al
c010100e:	0f 95 c0             	setne  %al
c0101011:	0f b6 c0             	movzbl %al,%eax
c0101014:	a3 48 a4 11 c0       	mov    %eax,0xc011a448
c0101019:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010101f:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c0101023:	89 c2                	mov    %eax,%edx
c0101025:	ec                   	in     (%dx),%al
c0101026:	88 45 d5             	mov    %al,-0x2b(%ebp)
c0101029:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c010102f:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c0101033:	89 c2                	mov    %eax,%edx
c0101035:	ec                   	in     (%dx),%al
c0101036:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101039:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c010103e:	85 c0                	test   %eax,%eax
c0101040:	74 0c                	je     c010104e <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c0101042:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101049:	e8 d6 06 00 00       	call   c0101724 <pic_enable>
    }
}
c010104e:	c9                   	leave  
c010104f:	c3                   	ret    

c0101050 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101050:	55                   	push   %ebp
c0101051:	89 e5                	mov    %esp,%ebp
c0101053:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101056:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c010105d:	eb 09                	jmp    c0101068 <lpt_putc_sub+0x18>
        delay();
c010105f:	e8 db fd ff ff       	call   c0100e3f <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101064:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0101068:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c010106e:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101072:	89 c2                	mov    %eax,%edx
c0101074:	ec                   	in     (%dx),%al
c0101075:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101078:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010107c:	84 c0                	test   %al,%al
c010107e:	78 09                	js     c0101089 <lpt_putc_sub+0x39>
c0101080:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101087:	7e d6                	jle    c010105f <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0101089:	8b 45 08             	mov    0x8(%ebp),%eax
c010108c:	0f b6 c0             	movzbl %al,%eax
c010108f:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c0101095:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101098:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010109c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010a0:	ee                   	out    %al,(%dx)
c01010a1:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010a7:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01010ab:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010af:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010b3:	ee                   	out    %al,(%dx)
c01010b4:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c01010ba:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c01010be:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010c2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010c6:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010c7:	c9                   	leave  
c01010c8:	c3                   	ret    

c01010c9 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010c9:	55                   	push   %ebp
c01010ca:	89 e5                	mov    %esp,%ebp
c01010cc:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010cf:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010d3:	74 0d                	je     c01010e2 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01010d8:	89 04 24             	mov    %eax,(%esp)
c01010db:	e8 70 ff ff ff       	call   c0101050 <lpt_putc_sub>
c01010e0:	eb 24                	jmp    c0101106 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c01010e2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010e9:	e8 62 ff ff ff       	call   c0101050 <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010f5:	e8 56 ff ff ff       	call   c0101050 <lpt_putc_sub>
        lpt_putc_sub('\b');
c01010fa:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101101:	e8 4a ff ff ff       	call   c0101050 <lpt_putc_sub>
    }
}
c0101106:	c9                   	leave  
c0101107:	c3                   	ret    

c0101108 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101108:	55                   	push   %ebp
c0101109:	89 e5                	mov    %esp,%ebp
c010110b:	53                   	push   %ebx
c010110c:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c010110f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101112:	b0 00                	mov    $0x0,%al
c0101114:	85 c0                	test   %eax,%eax
c0101116:	75 07                	jne    c010111f <cga_putc+0x17>
        c |= 0x0700;
c0101118:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010111f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101122:	0f b6 c0             	movzbl %al,%eax
c0101125:	83 f8 0a             	cmp    $0xa,%eax
c0101128:	74 4c                	je     c0101176 <cga_putc+0x6e>
c010112a:	83 f8 0d             	cmp    $0xd,%eax
c010112d:	74 57                	je     c0101186 <cga_putc+0x7e>
c010112f:	83 f8 08             	cmp    $0x8,%eax
c0101132:	0f 85 88 00 00 00    	jne    c01011c0 <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c0101138:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010113f:	66 85 c0             	test   %ax,%ax
c0101142:	74 30                	je     c0101174 <cga_putc+0x6c>
            crt_pos --;
c0101144:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010114b:	83 e8 01             	sub    $0x1,%eax
c010114e:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101154:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101159:	0f b7 15 44 a4 11 c0 	movzwl 0xc011a444,%edx
c0101160:	0f b7 d2             	movzwl %dx,%edx
c0101163:	01 d2                	add    %edx,%edx
c0101165:	01 c2                	add    %eax,%edx
c0101167:	8b 45 08             	mov    0x8(%ebp),%eax
c010116a:	b0 00                	mov    $0x0,%al
c010116c:	83 c8 20             	or     $0x20,%eax
c010116f:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101172:	eb 72                	jmp    c01011e6 <cga_putc+0xde>
c0101174:	eb 70                	jmp    c01011e6 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0101176:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c010117d:	83 c0 50             	add    $0x50,%eax
c0101180:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0101186:	0f b7 1d 44 a4 11 c0 	movzwl 0xc011a444,%ebx
c010118d:	0f b7 0d 44 a4 11 c0 	movzwl 0xc011a444,%ecx
c0101194:	0f b7 c1             	movzwl %cx,%eax
c0101197:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c010119d:	c1 e8 10             	shr    $0x10,%eax
c01011a0:	89 c2                	mov    %eax,%edx
c01011a2:	66 c1 ea 06          	shr    $0x6,%dx
c01011a6:	89 d0                	mov    %edx,%eax
c01011a8:	c1 e0 02             	shl    $0x2,%eax
c01011ab:	01 d0                	add    %edx,%eax
c01011ad:	c1 e0 04             	shl    $0x4,%eax
c01011b0:	29 c1                	sub    %eax,%ecx
c01011b2:	89 ca                	mov    %ecx,%edx
c01011b4:	89 d8                	mov    %ebx,%eax
c01011b6:	29 d0                	sub    %edx,%eax
c01011b8:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
        break;
c01011be:	eb 26                	jmp    c01011e6 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011c0:	8b 0d 40 a4 11 c0    	mov    0xc011a440,%ecx
c01011c6:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011cd:	8d 50 01             	lea    0x1(%eax),%edx
c01011d0:	66 89 15 44 a4 11 c0 	mov    %dx,0xc011a444
c01011d7:	0f b7 c0             	movzwl %ax,%eax
c01011da:	01 c0                	add    %eax,%eax
c01011dc:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011df:	8b 45 08             	mov    0x8(%ebp),%eax
c01011e2:	66 89 02             	mov    %ax,(%edx)
        break;
c01011e5:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011e6:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01011ed:	66 3d cf 07          	cmp    $0x7cf,%ax
c01011f1:	76 5b                	jbe    c010124e <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011f3:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c01011f8:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01011fe:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101203:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c010120a:	00 
c010120b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010120f:	89 04 24             	mov    %eax,(%esp)
c0101212:	e8 32 4b 00 00       	call   c0105d49 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101217:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010121e:	eb 15                	jmp    c0101235 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c0101220:	a1 40 a4 11 c0       	mov    0xc011a440,%eax
c0101225:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101228:	01 d2                	add    %edx,%edx
c010122a:	01 d0                	add    %edx,%eax
c010122c:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101231:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101235:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010123c:	7e e2                	jle    c0101220 <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c010123e:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101245:	83 e8 50             	sub    $0x50,%eax
c0101248:	66 a3 44 a4 11 c0    	mov    %ax,0xc011a444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010124e:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c0101255:	0f b7 c0             	movzwl %ax,%eax
c0101258:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010125c:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c0101260:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101264:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101268:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101269:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c0101270:	66 c1 e8 08          	shr    $0x8,%ax
c0101274:	0f b6 c0             	movzbl %al,%eax
c0101277:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c010127e:	83 c2 01             	add    $0x1,%edx
c0101281:	0f b7 d2             	movzwl %dx,%edx
c0101284:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0101288:	88 45 ed             	mov    %al,-0x13(%ebp)
c010128b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010128f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101293:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101294:	0f b7 05 46 a4 11 c0 	movzwl 0xc011a446,%eax
c010129b:	0f b7 c0             	movzwl %ax,%eax
c010129e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01012a2:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c01012a6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012aa:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012ae:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012af:	0f b7 05 44 a4 11 c0 	movzwl 0xc011a444,%eax
c01012b6:	0f b6 c0             	movzbl %al,%eax
c01012b9:	0f b7 15 46 a4 11 c0 	movzwl 0xc011a446,%edx
c01012c0:	83 c2 01             	add    $0x1,%edx
c01012c3:	0f b7 d2             	movzwl %dx,%edx
c01012c6:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012ca:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01012cd:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012d1:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012d5:	ee                   	out    %al,(%dx)
}
c01012d6:	83 c4 34             	add    $0x34,%esp
c01012d9:	5b                   	pop    %ebx
c01012da:	5d                   	pop    %ebp
c01012db:	c3                   	ret    

c01012dc <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012dc:	55                   	push   %ebp
c01012dd:	89 e5                	mov    %esp,%ebp
c01012df:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012e2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012e9:	eb 09                	jmp    c01012f4 <serial_putc_sub+0x18>
        delay();
c01012eb:	e8 4f fb ff ff       	call   c0100e3f <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012f0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01012f4:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012fa:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01012fe:	89 c2                	mov    %eax,%edx
c0101300:	ec                   	in     (%dx),%al
c0101301:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101304:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101308:	0f b6 c0             	movzbl %al,%eax
c010130b:	83 e0 20             	and    $0x20,%eax
c010130e:	85 c0                	test   %eax,%eax
c0101310:	75 09                	jne    c010131b <serial_putc_sub+0x3f>
c0101312:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101319:	7e d0                	jle    c01012eb <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c010131b:	8b 45 08             	mov    0x8(%ebp),%eax
c010131e:	0f b6 c0             	movzbl %al,%eax
c0101321:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101327:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010132a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010132e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101332:	ee                   	out    %al,(%dx)
}
c0101333:	c9                   	leave  
c0101334:	c3                   	ret    

c0101335 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101335:	55                   	push   %ebp
c0101336:	89 e5                	mov    %esp,%ebp
c0101338:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010133b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010133f:	74 0d                	je     c010134e <serial_putc+0x19>
        serial_putc_sub(c);
c0101341:	8b 45 08             	mov    0x8(%ebp),%eax
c0101344:	89 04 24             	mov    %eax,(%esp)
c0101347:	e8 90 ff ff ff       	call   c01012dc <serial_putc_sub>
c010134c:	eb 24                	jmp    c0101372 <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c010134e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101355:	e8 82 ff ff ff       	call   c01012dc <serial_putc_sub>
        serial_putc_sub(' ');
c010135a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101361:	e8 76 ff ff ff       	call   c01012dc <serial_putc_sub>
        serial_putc_sub('\b');
c0101366:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010136d:	e8 6a ff ff ff       	call   c01012dc <serial_putc_sub>
    }
}
c0101372:	c9                   	leave  
c0101373:	c3                   	ret    

c0101374 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101374:	55                   	push   %ebp
c0101375:	89 e5                	mov    %esp,%ebp
c0101377:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c010137a:	eb 33                	jmp    c01013af <cons_intr+0x3b>
        if (c != 0) {
c010137c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101380:	74 2d                	je     c01013af <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101382:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c0101387:	8d 50 01             	lea    0x1(%eax),%edx
c010138a:	89 15 64 a6 11 c0    	mov    %edx,0xc011a664
c0101390:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101393:	88 90 60 a4 11 c0    	mov    %dl,-0x3fee5ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101399:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010139e:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013a3:	75 0a                	jne    c01013af <cons_intr+0x3b>
                cons.wpos = 0;
c01013a5:	c7 05 64 a6 11 c0 00 	movl   $0x0,0xc011a664
c01013ac:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01013af:	8b 45 08             	mov    0x8(%ebp),%eax
c01013b2:	ff d0                	call   *%eax
c01013b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013b7:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013bb:	75 bf                	jne    c010137c <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013bd:	c9                   	leave  
c01013be:	c3                   	ret    

c01013bf <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013bf:	55                   	push   %ebp
c01013c0:	89 e5                	mov    %esp,%ebp
c01013c2:	83 ec 10             	sub    $0x10,%esp
c01013c5:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013cb:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013cf:	89 c2                	mov    %eax,%edx
c01013d1:	ec                   	in     (%dx),%al
c01013d2:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013d5:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013d9:	0f b6 c0             	movzbl %al,%eax
c01013dc:	83 e0 01             	and    $0x1,%eax
c01013df:	85 c0                	test   %eax,%eax
c01013e1:	75 07                	jne    c01013ea <serial_proc_data+0x2b>
        return -1;
c01013e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013e8:	eb 2a                	jmp    c0101414 <serial_proc_data+0x55>
c01013ea:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013f0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01013f4:	89 c2                	mov    %eax,%edx
c01013f6:	ec                   	in     (%dx),%al
c01013f7:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01013fa:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01013fe:	0f b6 c0             	movzbl %al,%eax
c0101401:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101404:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101408:	75 07                	jne    c0101411 <serial_proc_data+0x52>
        c = '\b';
c010140a:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101411:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101414:	c9                   	leave  
c0101415:	c3                   	ret    

c0101416 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101416:	55                   	push   %ebp
c0101417:	89 e5                	mov    %esp,%ebp
c0101419:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c010141c:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101421:	85 c0                	test   %eax,%eax
c0101423:	74 0c                	je     c0101431 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101425:	c7 04 24 bf 13 10 c0 	movl   $0xc01013bf,(%esp)
c010142c:	e8 43 ff ff ff       	call   c0101374 <cons_intr>
    }
}
c0101431:	c9                   	leave  
c0101432:	c3                   	ret    

c0101433 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101433:	55                   	push   %ebp
c0101434:	89 e5                	mov    %esp,%ebp
c0101436:	83 ec 38             	sub    $0x38,%esp
c0101439:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010143f:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0101443:	89 c2                	mov    %eax,%edx
c0101445:	ec                   	in     (%dx),%al
c0101446:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c0101449:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c010144d:	0f b6 c0             	movzbl %al,%eax
c0101450:	83 e0 01             	and    $0x1,%eax
c0101453:	85 c0                	test   %eax,%eax
c0101455:	75 0a                	jne    c0101461 <kbd_proc_data+0x2e>
        return -1;
c0101457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010145c:	e9 59 01 00 00       	jmp    c01015ba <kbd_proc_data+0x187>
c0101461:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101467:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c010146b:	89 c2                	mov    %eax,%edx
c010146d:	ec                   	in     (%dx),%al
c010146e:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101471:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101475:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101478:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c010147c:	75 17                	jne    c0101495 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c010147e:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101483:	83 c8 40             	or     $0x40,%eax
c0101486:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c010148b:	b8 00 00 00 00       	mov    $0x0,%eax
c0101490:	e9 25 01 00 00       	jmp    c01015ba <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101495:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101499:	84 c0                	test   %al,%al
c010149b:	79 47                	jns    c01014e4 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c010149d:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014a2:	83 e0 40             	and    $0x40,%eax
c01014a5:	85 c0                	test   %eax,%eax
c01014a7:	75 09                	jne    c01014b2 <kbd_proc_data+0x7f>
c01014a9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ad:	83 e0 7f             	and    $0x7f,%eax
c01014b0:	eb 04                	jmp    c01014b6 <kbd_proc_data+0x83>
c01014b2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014b6:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014b9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014bd:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c01014c4:	83 c8 40             	or     $0x40,%eax
c01014c7:	0f b6 c0             	movzbl %al,%eax
c01014ca:	f7 d0                	not    %eax
c01014cc:	89 c2                	mov    %eax,%edx
c01014ce:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014d3:	21 d0                	and    %edx,%eax
c01014d5:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
        return 0;
c01014da:	b8 00 00 00 00       	mov    $0x0,%eax
c01014df:	e9 d6 00 00 00       	jmp    c01015ba <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01014e4:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014e9:	83 e0 40             	and    $0x40,%eax
c01014ec:	85 c0                	test   %eax,%eax
c01014ee:	74 11                	je     c0101501 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014f0:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014f4:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c01014f9:	83 e0 bf             	and    $0xffffffbf,%eax
c01014fc:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    }

    shift |= shiftcode[data];
c0101501:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101505:	0f b6 80 40 70 11 c0 	movzbl -0x3fee8fc0(%eax),%eax
c010150c:	0f b6 d0             	movzbl %al,%edx
c010150f:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101514:	09 d0                	or     %edx,%eax
c0101516:	a3 68 a6 11 c0       	mov    %eax,0xc011a668
    shift ^= togglecode[data];
c010151b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151f:	0f b6 80 40 71 11 c0 	movzbl -0x3fee8ec0(%eax),%eax
c0101526:	0f b6 d0             	movzbl %al,%edx
c0101529:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010152e:	31 d0                	xor    %edx,%eax
c0101530:	a3 68 a6 11 c0       	mov    %eax,0xc011a668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101535:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c010153a:	83 e0 03             	and    $0x3,%eax
c010153d:	8b 14 85 40 75 11 c0 	mov    -0x3fee8ac0(,%eax,4),%edx
c0101544:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101548:	01 d0                	add    %edx,%eax
c010154a:	0f b6 00             	movzbl (%eax),%eax
c010154d:	0f b6 c0             	movzbl %al,%eax
c0101550:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101553:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101558:	83 e0 08             	and    $0x8,%eax
c010155b:	85 c0                	test   %eax,%eax
c010155d:	74 22                	je     c0101581 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c010155f:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101563:	7e 0c                	jle    c0101571 <kbd_proc_data+0x13e>
c0101565:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101569:	7f 06                	jg     c0101571 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c010156b:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010156f:	eb 10                	jmp    c0101581 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101571:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101575:	7e 0a                	jle    c0101581 <kbd_proc_data+0x14e>
c0101577:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010157b:	7f 04                	jg     c0101581 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010157d:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101581:	a1 68 a6 11 c0       	mov    0xc011a668,%eax
c0101586:	f7 d0                	not    %eax
c0101588:	83 e0 06             	and    $0x6,%eax
c010158b:	85 c0                	test   %eax,%eax
c010158d:	75 28                	jne    c01015b7 <kbd_proc_data+0x184>
c010158f:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101596:	75 1f                	jne    c01015b7 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0101598:	c7 04 24 cf 61 10 c0 	movl   $0xc01061cf,(%esp)
c010159f:	e8 a4 ed ff ff       	call   c0100348 <cprintf>
c01015a4:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c01015aa:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015ae:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c01015b2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01015b6:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015ba:	c9                   	leave  
c01015bb:	c3                   	ret    

c01015bc <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015bc:	55                   	push   %ebp
c01015bd:	89 e5                	mov    %esp,%ebp
c01015bf:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015c2:	c7 04 24 33 14 10 c0 	movl   $0xc0101433,(%esp)
c01015c9:	e8 a6 fd ff ff       	call   c0101374 <cons_intr>
}
c01015ce:	c9                   	leave  
c01015cf:	c3                   	ret    

c01015d0 <kbd_init>:

static void
kbd_init(void) {
c01015d0:	55                   	push   %ebp
c01015d1:	89 e5                	mov    %esp,%ebp
c01015d3:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015d6:	e8 e1 ff ff ff       	call   c01015bc <kbd_intr>
    pic_enable(IRQ_KBD);
c01015db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015e2:	e8 3d 01 00 00       	call   c0101724 <pic_enable>
}
c01015e7:	c9                   	leave  
c01015e8:	c3                   	ret    

c01015e9 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015e9:	55                   	push   %ebp
c01015ea:	89 e5                	mov    %esp,%ebp
c01015ec:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015ef:	e8 93 f8 ff ff       	call   c0100e87 <cga_init>
    serial_init();
c01015f4:	e8 74 f9 ff ff       	call   c0100f6d <serial_init>
    kbd_init();
c01015f9:	e8 d2 ff ff ff       	call   c01015d0 <kbd_init>
    if (!serial_exists) {
c01015fe:	a1 48 a4 11 c0       	mov    0xc011a448,%eax
c0101603:	85 c0                	test   %eax,%eax
c0101605:	75 0c                	jne    c0101613 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101607:	c7 04 24 db 61 10 c0 	movl   $0xc01061db,(%esp)
c010160e:	e8 35 ed ff ff       	call   c0100348 <cprintf>
    }
}
c0101613:	c9                   	leave  
c0101614:	c3                   	ret    

c0101615 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101615:	55                   	push   %ebp
c0101616:	89 e5                	mov    %esp,%ebp
c0101618:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010161b:	e8 e2 f7 ff ff       	call   c0100e02 <__intr_save>
c0101620:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101623:	8b 45 08             	mov    0x8(%ebp),%eax
c0101626:	89 04 24             	mov    %eax,(%esp)
c0101629:	e8 9b fa ff ff       	call   c01010c9 <lpt_putc>
        cga_putc(c);
c010162e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101631:	89 04 24             	mov    %eax,(%esp)
c0101634:	e8 cf fa ff ff       	call   c0101108 <cga_putc>
        serial_putc(c);
c0101639:	8b 45 08             	mov    0x8(%ebp),%eax
c010163c:	89 04 24             	mov    %eax,(%esp)
c010163f:	e8 f1 fc ff ff       	call   c0101335 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101644:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101647:	89 04 24             	mov    %eax,(%esp)
c010164a:	e8 dd f7 ff ff       	call   c0100e2c <__intr_restore>
}
c010164f:	c9                   	leave  
c0101650:	c3                   	ret    

c0101651 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101651:	55                   	push   %ebp
c0101652:	89 e5                	mov    %esp,%ebp
c0101654:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101657:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010165e:	e8 9f f7 ff ff       	call   c0100e02 <__intr_save>
c0101663:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101666:	e8 ab fd ff ff       	call   c0101416 <serial_intr>
        kbd_intr();
c010166b:	e8 4c ff ff ff       	call   c01015bc <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101670:	8b 15 60 a6 11 c0    	mov    0xc011a660,%edx
c0101676:	a1 64 a6 11 c0       	mov    0xc011a664,%eax
c010167b:	39 c2                	cmp    %eax,%edx
c010167d:	74 31                	je     c01016b0 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c010167f:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c0101684:	8d 50 01             	lea    0x1(%eax),%edx
c0101687:	89 15 60 a6 11 c0    	mov    %edx,0xc011a660
c010168d:	0f b6 80 60 a4 11 c0 	movzbl -0x3fee5ba0(%eax),%eax
c0101694:	0f b6 c0             	movzbl %al,%eax
c0101697:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c010169a:	a1 60 a6 11 c0       	mov    0xc011a660,%eax
c010169f:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016a4:	75 0a                	jne    c01016b0 <cons_getc+0x5f>
                cons.rpos = 0;
c01016a6:	c7 05 60 a6 11 c0 00 	movl   $0x0,0xc011a660
c01016ad:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016b3:	89 04 24             	mov    %eax,(%esp)
c01016b6:	e8 71 f7 ff ff       	call   c0100e2c <__intr_restore>
    return c;
c01016bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016be:	c9                   	leave  
c01016bf:	c3                   	ret    

c01016c0 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01016c0:	55                   	push   %ebp
c01016c1:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01016c3:	fb                   	sti    
    sti();
}
c01016c4:	5d                   	pop    %ebp
c01016c5:	c3                   	ret    

c01016c6 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01016c6:	55                   	push   %ebp
c01016c7:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01016c9:	fa                   	cli    
    cli();
}
c01016ca:	5d                   	pop    %ebp
c01016cb:	c3                   	ret    

c01016cc <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016cc:	55                   	push   %ebp
c01016cd:	89 e5                	mov    %esp,%ebp
c01016cf:	83 ec 14             	sub    $0x14,%esp
c01016d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01016d5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016d9:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016dd:	66 a3 50 75 11 c0    	mov    %ax,0xc0117550
    if (did_init) {
c01016e3:	a1 6c a6 11 c0       	mov    0xc011a66c,%eax
c01016e8:	85 c0                	test   %eax,%eax
c01016ea:	74 36                	je     c0101722 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01016ec:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016f0:	0f b6 c0             	movzbl %al,%eax
c01016f3:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016f9:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01016fc:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101700:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101704:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101705:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101709:	66 c1 e8 08          	shr    $0x8,%ax
c010170d:	0f b6 c0             	movzbl %al,%eax
c0101710:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0101716:	88 45 f9             	mov    %al,-0x7(%ebp)
c0101719:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010171d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101721:	ee                   	out    %al,(%dx)
    }
}
c0101722:	c9                   	leave  
c0101723:	c3                   	ret    

c0101724 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101724:	55                   	push   %ebp
c0101725:	89 e5                	mov    %esp,%ebp
c0101727:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c010172a:	8b 45 08             	mov    0x8(%ebp),%eax
c010172d:	ba 01 00 00 00       	mov    $0x1,%edx
c0101732:	89 c1                	mov    %eax,%ecx
c0101734:	d3 e2                	shl    %cl,%edx
c0101736:	89 d0                	mov    %edx,%eax
c0101738:	f7 d0                	not    %eax
c010173a:	89 c2                	mov    %eax,%edx
c010173c:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101743:	21 d0                	and    %edx,%eax
c0101745:	0f b7 c0             	movzwl %ax,%eax
c0101748:	89 04 24             	mov    %eax,(%esp)
c010174b:	e8 7c ff ff ff       	call   c01016cc <pic_setmask>
}
c0101750:	c9                   	leave  
c0101751:	c3                   	ret    

c0101752 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101752:	55                   	push   %ebp
c0101753:	89 e5                	mov    %esp,%ebp
c0101755:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0101758:	c7 05 6c a6 11 c0 01 	movl   $0x1,0xc011a66c
c010175f:	00 00 00 
c0101762:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101768:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c010176c:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101770:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101774:	ee                   	out    %al,(%dx)
c0101775:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c010177b:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c010177f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101783:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101787:	ee                   	out    %al,(%dx)
c0101788:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010178e:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c0101792:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101796:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010179a:	ee                   	out    %al,(%dx)
c010179b:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c01017a1:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c01017a5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01017a9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017ad:	ee                   	out    %al,(%dx)
c01017ae:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c01017b4:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c01017b8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01017bc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017c0:	ee                   	out    %al,(%dx)
c01017c1:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c01017c7:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c01017cb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01017cf:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01017d3:	ee                   	out    %al,(%dx)
c01017d4:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01017da:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c01017de:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01017e2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01017e6:	ee                   	out    %al,(%dx)
c01017e7:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c01017ed:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c01017f1:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01017f5:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01017f9:	ee                   	out    %al,(%dx)
c01017fa:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c0101800:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0101804:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101808:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010180c:	ee                   	out    %al,(%dx)
c010180d:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0101813:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0101817:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010181b:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010181f:	ee                   	out    %al,(%dx)
c0101820:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c0101826:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c010182a:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010182e:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101832:	ee                   	out    %al,(%dx)
c0101833:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101839:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c010183d:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101841:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101845:	ee                   	out    %al,(%dx)
c0101846:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c010184c:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c0101850:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101854:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101858:	ee                   	out    %al,(%dx)
c0101859:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c010185f:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c0101863:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101867:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010186b:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010186c:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101873:	66 83 f8 ff          	cmp    $0xffff,%ax
c0101877:	74 12                	je     c010188b <pic_init+0x139>
        pic_setmask(irq_mask);
c0101879:	0f b7 05 50 75 11 c0 	movzwl 0xc0117550,%eax
c0101880:	0f b7 c0             	movzwl %ax,%eax
c0101883:	89 04 24             	mov    %eax,(%esp)
c0101886:	e8 41 fe ff ff       	call   c01016cc <pic_setmask>
    }
}
c010188b:	c9                   	leave  
c010188c:	c3                   	ret    

c010188d <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010188d:	55                   	push   %ebp
c010188e:	89 e5                	mov    %esp,%ebp
c0101890:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c0101893:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c010189a:	00 
c010189b:	c7 04 24 00 62 10 c0 	movl   $0xc0106200,(%esp)
c01018a2:	e8 a1 ea ff ff       	call   c0100348 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c01018a7:	c7 04 24 0a 62 10 c0 	movl   $0xc010620a,(%esp)
c01018ae:	e8 95 ea ff ff       	call   c0100348 <cprintf>
    panic("EOT: kernel seems ok.");
c01018b3:	c7 44 24 08 18 62 10 	movl   $0xc0106218,0x8(%esp)
c01018ba:	c0 
c01018bb:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c01018c2:	00 
c01018c3:	c7 04 24 2e 62 10 c0 	movl   $0xc010622e,(%esp)
c01018ca:	e8 03 f4 ff ff       	call   c0100cd2 <__panic>

c01018cf <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018cf:	55                   	push   %ebp
c01018d0:	89 e5                	mov    %esp,%ebp
c01018d2:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < 256; i ++) {
c01018d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018dc:	e9 c3 00 00 00       	jmp    c01019a4 <idt_init+0xd5>
	SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018e4:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c01018eb:	89 c2                	mov    %eax,%edx
c01018ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018f0:	66 89 14 c5 80 a6 11 	mov    %dx,-0x3fee5980(,%eax,8)
c01018f7:	c0 
c01018f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018fb:	66 c7 04 c5 82 a6 11 	movw   $0x8,-0x3fee597e(,%eax,8)
c0101902:	c0 08 00 
c0101905:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101908:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c010190f:	c0 
c0101910:	83 e2 e0             	and    $0xffffffe0,%edx
c0101913:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c010191a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010191d:	0f b6 14 c5 84 a6 11 	movzbl -0x3fee597c(,%eax,8),%edx
c0101924:	c0 
c0101925:	83 e2 1f             	and    $0x1f,%edx
c0101928:	88 14 c5 84 a6 11 c0 	mov    %dl,-0x3fee597c(,%eax,8)
c010192f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101932:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101939:	c0 
c010193a:	83 e2 f0             	and    $0xfffffff0,%edx
c010193d:	83 ca 0e             	or     $0xe,%edx
c0101940:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101947:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010194a:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101951:	c0 
c0101952:	83 e2 ef             	and    $0xffffffef,%edx
c0101955:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c010195c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010195f:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c0101966:	c0 
c0101967:	83 e2 9f             	and    $0xffffff9f,%edx
c010196a:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101971:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101974:	0f b6 14 c5 85 a6 11 	movzbl -0x3fee597b(,%eax,8),%edx
c010197b:	c0 
c010197c:	83 ca 80             	or     $0xffffff80,%edx
c010197f:	88 14 c5 85 a6 11 c0 	mov    %dl,-0x3fee597b(,%eax,8)
c0101986:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101989:	8b 04 85 e0 75 11 c0 	mov    -0x3fee8a20(,%eax,4),%eax
c0101990:	c1 e8 10             	shr    $0x10,%eax
c0101993:	89 c2                	mov    %eax,%edx
c0101995:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101998:	66 89 14 c5 86 a6 11 	mov    %dx,-0x3fee597a(,%eax,8)
c010199f:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < 256; i ++) {
c01019a0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01019a4:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c01019ab:	0f 8e 30 ff ff ff    	jle    c01018e1 <idt_init+0x12>
c01019b1:	c7 45 f8 60 75 11 c0 	movl   $0xc0117560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01019b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01019bb:	0f 01 18             	lidtl  (%eax)
	SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
c01019be:	c9                   	leave  
c01019bf:	c3                   	ret    

c01019c0 <trapname>:

static const char *
trapname(int trapno) {
c01019c0:	55                   	push   %ebp
c01019c1:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01019c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01019c6:	83 f8 13             	cmp    $0x13,%eax
c01019c9:	77 0c                	ja     c01019d7 <trapname+0x17>
        return excnames[trapno];
c01019cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01019ce:	8b 04 85 80 65 10 c0 	mov    -0x3fef9a80(,%eax,4),%eax
c01019d5:	eb 18                	jmp    c01019ef <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01019d7:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01019db:	7e 0d                	jle    c01019ea <trapname+0x2a>
c01019dd:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01019e1:	7f 07                	jg     c01019ea <trapname+0x2a>
        return "Hardware Interrupt";
c01019e3:	b8 3f 62 10 c0       	mov    $0xc010623f,%eax
c01019e8:	eb 05                	jmp    c01019ef <trapname+0x2f>
    }
    return "(unknown trap)";
c01019ea:	b8 52 62 10 c0       	mov    $0xc0106252,%eax
}
c01019ef:	5d                   	pop    %ebp
c01019f0:	c3                   	ret    

c01019f1 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01019f1:	55                   	push   %ebp
c01019f2:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01019f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01019f7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01019fb:	66 83 f8 08          	cmp    $0x8,%ax
c01019ff:	0f 94 c0             	sete   %al
c0101a02:	0f b6 c0             	movzbl %al,%eax
}
c0101a05:	5d                   	pop    %ebp
c0101a06:	c3                   	ret    

c0101a07 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a07:	55                   	push   %ebp
c0101a08:	89 e5                	mov    %esp,%ebp
c0101a0a:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a14:	c7 04 24 93 62 10 c0 	movl   $0xc0106293,(%esp)
c0101a1b:	e8 28 e9 ff ff       	call   c0100348 <cprintf>
    print_regs(&tf->tf_regs);
c0101a20:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a23:	89 04 24             	mov    %eax,(%esp)
c0101a26:	e8 a1 01 00 00       	call   c0101bcc <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a2e:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a32:	0f b7 c0             	movzwl %ax,%eax
c0101a35:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a39:	c7 04 24 a4 62 10 c0 	movl   $0xc01062a4,(%esp)
c0101a40:	e8 03 e9 ff ff       	call   c0100348 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a45:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a48:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101a4c:	0f b7 c0             	movzwl %ax,%eax
c0101a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a53:	c7 04 24 b7 62 10 c0 	movl   $0xc01062b7,(%esp)
c0101a5a:	e8 e9 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101a5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a62:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101a66:	0f b7 c0             	movzwl %ax,%eax
c0101a69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a6d:	c7 04 24 ca 62 10 c0 	movl   $0xc01062ca,(%esp)
c0101a74:	e8 cf e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101a79:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a7c:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101a80:	0f b7 c0             	movzwl %ax,%eax
c0101a83:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a87:	c7 04 24 dd 62 10 c0 	movl   $0xc01062dd,(%esp)
c0101a8e:	e8 b5 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101a93:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a96:	8b 40 30             	mov    0x30(%eax),%eax
c0101a99:	89 04 24             	mov    %eax,(%esp)
c0101a9c:	e8 1f ff ff ff       	call   c01019c0 <trapname>
c0101aa1:	8b 55 08             	mov    0x8(%ebp),%edx
c0101aa4:	8b 52 30             	mov    0x30(%edx),%edx
c0101aa7:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101aab:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101aaf:	c7 04 24 f0 62 10 c0 	movl   $0xc01062f0,(%esp)
c0101ab6:	e8 8d e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101abb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101abe:	8b 40 34             	mov    0x34(%eax),%eax
c0101ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ac5:	c7 04 24 02 63 10 c0 	movl   $0xc0106302,(%esp)
c0101acc:	e8 77 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101ad1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ad4:	8b 40 38             	mov    0x38(%eax),%eax
c0101ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101adb:	c7 04 24 11 63 10 c0 	movl   $0xc0106311,(%esp)
c0101ae2:	e8 61 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101ae7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aea:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101aee:	0f b7 c0             	movzwl %ax,%eax
c0101af1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101af5:	c7 04 24 20 63 10 c0 	movl   $0xc0106320,(%esp)
c0101afc:	e8 47 e8 ff ff       	call   c0100348 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101b01:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b04:	8b 40 40             	mov    0x40(%eax),%eax
c0101b07:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b0b:	c7 04 24 33 63 10 c0 	movl   $0xc0106333,(%esp)
c0101b12:	e8 31 e8 ff ff       	call   c0100348 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b1e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101b25:	eb 3e                	jmp    c0101b65 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101b27:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b2a:	8b 50 40             	mov    0x40(%eax),%edx
c0101b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b30:	21 d0                	and    %edx,%eax
c0101b32:	85 c0                	test   %eax,%eax
c0101b34:	74 28                	je     c0101b5e <print_trapframe+0x157>
c0101b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b39:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101b40:	85 c0                	test   %eax,%eax
c0101b42:	74 1a                	je     c0101b5e <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0101b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b47:	8b 04 85 80 75 11 c0 	mov    -0x3fee8a80(,%eax,4),%eax
c0101b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b52:	c7 04 24 42 63 10 c0 	movl   $0xc0106342,(%esp)
c0101b59:	e8 ea e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b5e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101b62:	d1 65 f0             	shll   -0x10(%ebp)
c0101b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b68:	83 f8 17             	cmp    $0x17,%eax
c0101b6b:	76 ba                	jbe    c0101b27 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b70:	8b 40 40             	mov    0x40(%eax),%eax
c0101b73:	25 00 30 00 00       	and    $0x3000,%eax
c0101b78:	c1 e8 0c             	shr    $0xc,%eax
c0101b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b7f:	c7 04 24 46 63 10 c0 	movl   $0xc0106346,(%esp)
c0101b86:	e8 bd e7 ff ff       	call   c0100348 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101b8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b8e:	89 04 24             	mov    %eax,(%esp)
c0101b91:	e8 5b fe ff ff       	call   c01019f1 <trap_in_kernel>
c0101b96:	85 c0                	test   %eax,%eax
c0101b98:	75 30                	jne    c0101bca <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101b9a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b9d:	8b 40 44             	mov    0x44(%eax),%eax
c0101ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ba4:	c7 04 24 4f 63 10 c0 	movl   $0xc010634f,(%esp)
c0101bab:	e8 98 e7 ff ff       	call   c0100348 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101bb0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bb3:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101bb7:	0f b7 c0             	movzwl %ax,%eax
c0101bba:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bbe:	c7 04 24 5e 63 10 c0 	movl   $0xc010635e,(%esp)
c0101bc5:	e8 7e e7 ff ff       	call   c0100348 <cprintf>
    }
}
c0101bca:	c9                   	leave  
c0101bcb:	c3                   	ret    

c0101bcc <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101bcc:	55                   	push   %ebp
c0101bcd:	89 e5                	mov    %esp,%ebp
c0101bcf:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101bd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd5:	8b 00                	mov    (%eax),%eax
c0101bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bdb:	c7 04 24 71 63 10 c0 	movl   $0xc0106371,(%esp)
c0101be2:	e8 61 e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101be7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bea:	8b 40 04             	mov    0x4(%eax),%eax
c0101bed:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bf1:	c7 04 24 80 63 10 c0 	movl   $0xc0106380,(%esp)
c0101bf8:	e8 4b e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c00:	8b 40 08             	mov    0x8(%eax),%eax
c0101c03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c07:	c7 04 24 8f 63 10 c0 	movl   $0xc010638f,(%esp)
c0101c0e:	e8 35 e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101c13:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c16:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c19:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c1d:	c7 04 24 9e 63 10 c0 	movl   $0xc010639e,(%esp)
c0101c24:	e8 1f e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c29:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c2c:	8b 40 10             	mov    0x10(%eax),%eax
c0101c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c33:	c7 04 24 ad 63 10 c0 	movl   $0xc01063ad,(%esp)
c0101c3a:	e8 09 e7 ff ff       	call   c0100348 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c42:	8b 40 14             	mov    0x14(%eax),%eax
c0101c45:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c49:	c7 04 24 bc 63 10 c0 	movl   $0xc01063bc,(%esp)
c0101c50:	e8 f3 e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101c55:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c58:	8b 40 18             	mov    0x18(%eax),%eax
c0101c5b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c5f:	c7 04 24 cb 63 10 c0 	movl   $0xc01063cb,(%esp)
c0101c66:	e8 dd e6 ff ff       	call   c0100348 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101c6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c6e:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101c71:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c75:	c7 04 24 da 63 10 c0 	movl   $0xc01063da,(%esp)
c0101c7c:	e8 c7 e6 ff ff       	call   c0100348 <cprintf>
}
c0101c81:	c9                   	leave  
c0101c82:	c3                   	ret    

c0101c83 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101c83:	55                   	push   %ebp
c0101c84:	89 e5                	mov    %esp,%ebp
c0101c86:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101c89:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c8c:	8b 40 30             	mov    0x30(%eax),%eax
c0101c8f:	83 f8 2f             	cmp    $0x2f,%eax
c0101c92:	77 21                	ja     c0101cb5 <trap_dispatch+0x32>
c0101c94:	83 f8 2e             	cmp    $0x2e,%eax
c0101c97:	0f 83 04 01 00 00    	jae    c0101da1 <trap_dispatch+0x11e>
c0101c9d:	83 f8 21             	cmp    $0x21,%eax
c0101ca0:	0f 84 81 00 00 00    	je     c0101d27 <trap_dispatch+0xa4>
c0101ca6:	83 f8 24             	cmp    $0x24,%eax
c0101ca9:	74 56                	je     c0101d01 <trap_dispatch+0x7e>
c0101cab:	83 f8 20             	cmp    $0x20,%eax
c0101cae:	74 16                	je     c0101cc6 <trap_dispatch+0x43>
c0101cb0:	e9 b4 00 00 00       	jmp    c0101d69 <trap_dispatch+0xe6>
c0101cb5:	83 e8 78             	sub    $0x78,%eax
c0101cb8:	83 f8 01             	cmp    $0x1,%eax
c0101cbb:	0f 87 a8 00 00 00    	ja     c0101d69 <trap_dispatch+0xe6>
c0101cc1:	e9 87 00 00 00       	jmp    c0101d4d <trap_dispatch+0xca>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101cc6:	a1 0c af 11 c0       	mov    0xc011af0c,%eax
c0101ccb:	83 c0 01             	add    $0x1,%eax
c0101cce:	a3 0c af 11 c0       	mov    %eax,0xc011af0c
        if (ticks % TICK_NUM == 0) {
c0101cd3:	8b 0d 0c af 11 c0    	mov    0xc011af0c,%ecx
c0101cd9:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101cde:	89 c8                	mov    %ecx,%eax
c0101ce0:	f7 e2                	mul    %edx
c0101ce2:	89 d0                	mov    %edx,%eax
c0101ce4:	c1 e8 05             	shr    $0x5,%eax
c0101ce7:	6b c0 64             	imul   $0x64,%eax,%eax
c0101cea:	29 c1                	sub    %eax,%ecx
c0101cec:	89 c8                	mov    %ecx,%eax
c0101cee:	85 c0                	test   %eax,%eax
c0101cf0:	75 0a                	jne    c0101cfc <trap_dispatch+0x79>
            print_ticks();
c0101cf2:	e8 96 fb ff ff       	call   c010188d <print_ticks>
        }
        break;
c0101cf7:	e9 a6 00 00 00       	jmp    c0101da2 <trap_dispatch+0x11f>
c0101cfc:	e9 a1 00 00 00       	jmp    c0101da2 <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101d01:	e8 4b f9 ff ff       	call   c0101651 <cons_getc>
c0101d06:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101d09:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d0d:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d11:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d15:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d19:	c7 04 24 e9 63 10 c0 	movl   $0xc01063e9,(%esp)
c0101d20:	e8 23 e6 ff ff       	call   c0100348 <cprintf>
        break;
c0101d25:	eb 7b                	jmp    c0101da2 <trap_dispatch+0x11f>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d27:	e8 25 f9 ff ff       	call   c0101651 <cons_getc>
c0101d2c:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d2f:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d33:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d37:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d3f:	c7 04 24 fb 63 10 c0 	movl   $0xc01063fb,(%esp)
c0101d46:	e8 fd e5 ff ff       	call   c0100348 <cprintf>
        break;
c0101d4b:	eb 55                	jmp    c0101da2 <trap_dispatch+0x11f>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101d4d:	c7 44 24 08 0a 64 10 	movl   $0xc010640a,0x8(%esp)
c0101d54:	c0 
c0101d55:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
c0101d5c:	00 
c0101d5d:	c7 04 24 2e 62 10 c0 	movl   $0xc010622e,(%esp)
c0101d64:	e8 69 ef ff ff       	call   c0100cd2 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101d69:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d6c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101d70:	0f b7 c0             	movzwl %ax,%eax
c0101d73:	83 e0 03             	and    $0x3,%eax
c0101d76:	85 c0                	test   %eax,%eax
c0101d78:	75 28                	jne    c0101da2 <trap_dispatch+0x11f>
            print_trapframe(tf);
c0101d7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d7d:	89 04 24             	mov    %eax,(%esp)
c0101d80:	e8 82 fc ff ff       	call   c0101a07 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101d85:	c7 44 24 08 1a 64 10 	movl   $0xc010641a,0x8(%esp)
c0101d8c:	c0 
c0101d8d:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0101d94:	00 
c0101d95:	c7 04 24 2e 62 10 c0 	movl   $0xc010622e,(%esp)
c0101d9c:	e8 31 ef ff ff       	call   c0100cd2 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101da1:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101da2:	c9                   	leave  
c0101da3:	c3                   	ret    

c0101da4 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101da4:	55                   	push   %ebp
c0101da5:	89 e5                	mov    %esp,%ebp
c0101da7:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101daa:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dad:	89 04 24             	mov    %eax,(%esp)
c0101db0:	e8 ce fe ff ff       	call   c0101c83 <trap_dispatch>
}
c0101db5:	c9                   	leave  
c0101db6:	c3                   	ret    

c0101db7 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101db7:	1e                   	push   %ds
    pushl %es
c0101db8:	06                   	push   %es
    pushl %fs
c0101db9:	0f a0                	push   %fs
    pushl %gs
c0101dbb:	0f a8                	push   %gs
    pushal
c0101dbd:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101dbe:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101dc3:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101dc5:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101dc7:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101dc8:	e8 d7 ff ff ff       	call   c0101da4 <trap>

    # pop the pushed stack pointer
    popl %esp
c0101dcd:	5c                   	pop    %esp

c0101dce <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101dce:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0101dcf:	0f a9                	pop    %gs
    popl %fs
c0101dd1:	0f a1                	pop    %fs
    popl %es
c0101dd3:	07                   	pop    %es
    popl %ds
c0101dd4:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101dd5:	83 c4 08             	add    $0x8,%esp
    iret
c0101dd8:	cf                   	iret   

c0101dd9 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101dd9:	6a 00                	push   $0x0
  pushl $0
c0101ddb:	6a 00                	push   $0x0
  jmp __alltraps
c0101ddd:	e9 d5 ff ff ff       	jmp    c0101db7 <__alltraps>

c0101de2 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101de2:	6a 00                	push   $0x0
  pushl $1
c0101de4:	6a 01                	push   $0x1
  jmp __alltraps
c0101de6:	e9 cc ff ff ff       	jmp    c0101db7 <__alltraps>

c0101deb <vector2>:
.globl vector2
vector2:
  pushl $0
c0101deb:	6a 00                	push   $0x0
  pushl $2
c0101ded:	6a 02                	push   $0x2
  jmp __alltraps
c0101def:	e9 c3 ff ff ff       	jmp    c0101db7 <__alltraps>

c0101df4 <vector3>:
.globl vector3
vector3:
  pushl $0
c0101df4:	6a 00                	push   $0x0
  pushl $3
c0101df6:	6a 03                	push   $0x3
  jmp __alltraps
c0101df8:	e9 ba ff ff ff       	jmp    c0101db7 <__alltraps>

c0101dfd <vector4>:
.globl vector4
vector4:
  pushl $0
c0101dfd:	6a 00                	push   $0x0
  pushl $4
c0101dff:	6a 04                	push   $0x4
  jmp __alltraps
c0101e01:	e9 b1 ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e06 <vector5>:
.globl vector5
vector5:
  pushl $0
c0101e06:	6a 00                	push   $0x0
  pushl $5
c0101e08:	6a 05                	push   $0x5
  jmp __alltraps
c0101e0a:	e9 a8 ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e0f <vector6>:
.globl vector6
vector6:
  pushl $0
c0101e0f:	6a 00                	push   $0x0
  pushl $6
c0101e11:	6a 06                	push   $0x6
  jmp __alltraps
c0101e13:	e9 9f ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e18 <vector7>:
.globl vector7
vector7:
  pushl $0
c0101e18:	6a 00                	push   $0x0
  pushl $7
c0101e1a:	6a 07                	push   $0x7
  jmp __alltraps
c0101e1c:	e9 96 ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e21 <vector8>:
.globl vector8
vector8:
  pushl $8
c0101e21:	6a 08                	push   $0x8
  jmp __alltraps
c0101e23:	e9 8f ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e28 <vector9>:
.globl vector9
vector9:
  pushl $9
c0101e28:	6a 09                	push   $0x9
  jmp __alltraps
c0101e2a:	e9 88 ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e2f <vector10>:
.globl vector10
vector10:
  pushl $10
c0101e2f:	6a 0a                	push   $0xa
  jmp __alltraps
c0101e31:	e9 81 ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e36 <vector11>:
.globl vector11
vector11:
  pushl $11
c0101e36:	6a 0b                	push   $0xb
  jmp __alltraps
c0101e38:	e9 7a ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e3d <vector12>:
.globl vector12
vector12:
  pushl $12
c0101e3d:	6a 0c                	push   $0xc
  jmp __alltraps
c0101e3f:	e9 73 ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e44 <vector13>:
.globl vector13
vector13:
  pushl $13
c0101e44:	6a 0d                	push   $0xd
  jmp __alltraps
c0101e46:	e9 6c ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e4b <vector14>:
.globl vector14
vector14:
  pushl $14
c0101e4b:	6a 0e                	push   $0xe
  jmp __alltraps
c0101e4d:	e9 65 ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e52 <vector15>:
.globl vector15
vector15:
  pushl $0
c0101e52:	6a 00                	push   $0x0
  pushl $15
c0101e54:	6a 0f                	push   $0xf
  jmp __alltraps
c0101e56:	e9 5c ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e5b <vector16>:
.globl vector16
vector16:
  pushl $0
c0101e5b:	6a 00                	push   $0x0
  pushl $16
c0101e5d:	6a 10                	push   $0x10
  jmp __alltraps
c0101e5f:	e9 53 ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e64 <vector17>:
.globl vector17
vector17:
  pushl $17
c0101e64:	6a 11                	push   $0x11
  jmp __alltraps
c0101e66:	e9 4c ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e6b <vector18>:
.globl vector18
vector18:
  pushl $0
c0101e6b:	6a 00                	push   $0x0
  pushl $18
c0101e6d:	6a 12                	push   $0x12
  jmp __alltraps
c0101e6f:	e9 43 ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e74 <vector19>:
.globl vector19
vector19:
  pushl $0
c0101e74:	6a 00                	push   $0x0
  pushl $19
c0101e76:	6a 13                	push   $0x13
  jmp __alltraps
c0101e78:	e9 3a ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e7d <vector20>:
.globl vector20
vector20:
  pushl $0
c0101e7d:	6a 00                	push   $0x0
  pushl $20
c0101e7f:	6a 14                	push   $0x14
  jmp __alltraps
c0101e81:	e9 31 ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e86 <vector21>:
.globl vector21
vector21:
  pushl $0
c0101e86:	6a 00                	push   $0x0
  pushl $21
c0101e88:	6a 15                	push   $0x15
  jmp __alltraps
c0101e8a:	e9 28 ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e8f <vector22>:
.globl vector22
vector22:
  pushl $0
c0101e8f:	6a 00                	push   $0x0
  pushl $22
c0101e91:	6a 16                	push   $0x16
  jmp __alltraps
c0101e93:	e9 1f ff ff ff       	jmp    c0101db7 <__alltraps>

c0101e98 <vector23>:
.globl vector23
vector23:
  pushl $0
c0101e98:	6a 00                	push   $0x0
  pushl $23
c0101e9a:	6a 17                	push   $0x17
  jmp __alltraps
c0101e9c:	e9 16 ff ff ff       	jmp    c0101db7 <__alltraps>

c0101ea1 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101ea1:	6a 00                	push   $0x0
  pushl $24
c0101ea3:	6a 18                	push   $0x18
  jmp __alltraps
c0101ea5:	e9 0d ff ff ff       	jmp    c0101db7 <__alltraps>

c0101eaa <vector25>:
.globl vector25
vector25:
  pushl $0
c0101eaa:	6a 00                	push   $0x0
  pushl $25
c0101eac:	6a 19                	push   $0x19
  jmp __alltraps
c0101eae:	e9 04 ff ff ff       	jmp    c0101db7 <__alltraps>

c0101eb3 <vector26>:
.globl vector26
vector26:
  pushl $0
c0101eb3:	6a 00                	push   $0x0
  pushl $26
c0101eb5:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101eb7:	e9 fb fe ff ff       	jmp    c0101db7 <__alltraps>

c0101ebc <vector27>:
.globl vector27
vector27:
  pushl $0
c0101ebc:	6a 00                	push   $0x0
  pushl $27
c0101ebe:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101ec0:	e9 f2 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101ec5 <vector28>:
.globl vector28
vector28:
  pushl $0
c0101ec5:	6a 00                	push   $0x0
  pushl $28
c0101ec7:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101ec9:	e9 e9 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101ece <vector29>:
.globl vector29
vector29:
  pushl $0
c0101ece:	6a 00                	push   $0x0
  pushl $29
c0101ed0:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101ed2:	e9 e0 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101ed7 <vector30>:
.globl vector30
vector30:
  pushl $0
c0101ed7:	6a 00                	push   $0x0
  pushl $30
c0101ed9:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101edb:	e9 d7 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101ee0 <vector31>:
.globl vector31
vector31:
  pushl $0
c0101ee0:	6a 00                	push   $0x0
  pushl $31
c0101ee2:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101ee4:	e9 ce fe ff ff       	jmp    c0101db7 <__alltraps>

c0101ee9 <vector32>:
.globl vector32
vector32:
  pushl $0
c0101ee9:	6a 00                	push   $0x0
  pushl $32
c0101eeb:	6a 20                	push   $0x20
  jmp __alltraps
c0101eed:	e9 c5 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101ef2 <vector33>:
.globl vector33
vector33:
  pushl $0
c0101ef2:	6a 00                	push   $0x0
  pushl $33
c0101ef4:	6a 21                	push   $0x21
  jmp __alltraps
c0101ef6:	e9 bc fe ff ff       	jmp    c0101db7 <__alltraps>

c0101efb <vector34>:
.globl vector34
vector34:
  pushl $0
c0101efb:	6a 00                	push   $0x0
  pushl $34
c0101efd:	6a 22                	push   $0x22
  jmp __alltraps
c0101eff:	e9 b3 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f04 <vector35>:
.globl vector35
vector35:
  pushl $0
c0101f04:	6a 00                	push   $0x0
  pushl $35
c0101f06:	6a 23                	push   $0x23
  jmp __alltraps
c0101f08:	e9 aa fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f0d <vector36>:
.globl vector36
vector36:
  pushl $0
c0101f0d:	6a 00                	push   $0x0
  pushl $36
c0101f0f:	6a 24                	push   $0x24
  jmp __alltraps
c0101f11:	e9 a1 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f16 <vector37>:
.globl vector37
vector37:
  pushl $0
c0101f16:	6a 00                	push   $0x0
  pushl $37
c0101f18:	6a 25                	push   $0x25
  jmp __alltraps
c0101f1a:	e9 98 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f1f <vector38>:
.globl vector38
vector38:
  pushl $0
c0101f1f:	6a 00                	push   $0x0
  pushl $38
c0101f21:	6a 26                	push   $0x26
  jmp __alltraps
c0101f23:	e9 8f fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f28 <vector39>:
.globl vector39
vector39:
  pushl $0
c0101f28:	6a 00                	push   $0x0
  pushl $39
c0101f2a:	6a 27                	push   $0x27
  jmp __alltraps
c0101f2c:	e9 86 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f31 <vector40>:
.globl vector40
vector40:
  pushl $0
c0101f31:	6a 00                	push   $0x0
  pushl $40
c0101f33:	6a 28                	push   $0x28
  jmp __alltraps
c0101f35:	e9 7d fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f3a <vector41>:
.globl vector41
vector41:
  pushl $0
c0101f3a:	6a 00                	push   $0x0
  pushl $41
c0101f3c:	6a 29                	push   $0x29
  jmp __alltraps
c0101f3e:	e9 74 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f43 <vector42>:
.globl vector42
vector42:
  pushl $0
c0101f43:	6a 00                	push   $0x0
  pushl $42
c0101f45:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101f47:	e9 6b fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f4c <vector43>:
.globl vector43
vector43:
  pushl $0
c0101f4c:	6a 00                	push   $0x0
  pushl $43
c0101f4e:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101f50:	e9 62 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f55 <vector44>:
.globl vector44
vector44:
  pushl $0
c0101f55:	6a 00                	push   $0x0
  pushl $44
c0101f57:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101f59:	e9 59 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f5e <vector45>:
.globl vector45
vector45:
  pushl $0
c0101f5e:	6a 00                	push   $0x0
  pushl $45
c0101f60:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101f62:	e9 50 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f67 <vector46>:
.globl vector46
vector46:
  pushl $0
c0101f67:	6a 00                	push   $0x0
  pushl $46
c0101f69:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101f6b:	e9 47 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f70 <vector47>:
.globl vector47
vector47:
  pushl $0
c0101f70:	6a 00                	push   $0x0
  pushl $47
c0101f72:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101f74:	e9 3e fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f79 <vector48>:
.globl vector48
vector48:
  pushl $0
c0101f79:	6a 00                	push   $0x0
  pushl $48
c0101f7b:	6a 30                	push   $0x30
  jmp __alltraps
c0101f7d:	e9 35 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f82 <vector49>:
.globl vector49
vector49:
  pushl $0
c0101f82:	6a 00                	push   $0x0
  pushl $49
c0101f84:	6a 31                	push   $0x31
  jmp __alltraps
c0101f86:	e9 2c fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f8b <vector50>:
.globl vector50
vector50:
  pushl $0
c0101f8b:	6a 00                	push   $0x0
  pushl $50
c0101f8d:	6a 32                	push   $0x32
  jmp __alltraps
c0101f8f:	e9 23 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f94 <vector51>:
.globl vector51
vector51:
  pushl $0
c0101f94:	6a 00                	push   $0x0
  pushl $51
c0101f96:	6a 33                	push   $0x33
  jmp __alltraps
c0101f98:	e9 1a fe ff ff       	jmp    c0101db7 <__alltraps>

c0101f9d <vector52>:
.globl vector52
vector52:
  pushl $0
c0101f9d:	6a 00                	push   $0x0
  pushl $52
c0101f9f:	6a 34                	push   $0x34
  jmp __alltraps
c0101fa1:	e9 11 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101fa6 <vector53>:
.globl vector53
vector53:
  pushl $0
c0101fa6:	6a 00                	push   $0x0
  pushl $53
c0101fa8:	6a 35                	push   $0x35
  jmp __alltraps
c0101faa:	e9 08 fe ff ff       	jmp    c0101db7 <__alltraps>

c0101faf <vector54>:
.globl vector54
vector54:
  pushl $0
c0101faf:	6a 00                	push   $0x0
  pushl $54
c0101fb1:	6a 36                	push   $0x36
  jmp __alltraps
c0101fb3:	e9 ff fd ff ff       	jmp    c0101db7 <__alltraps>

c0101fb8 <vector55>:
.globl vector55
vector55:
  pushl $0
c0101fb8:	6a 00                	push   $0x0
  pushl $55
c0101fba:	6a 37                	push   $0x37
  jmp __alltraps
c0101fbc:	e9 f6 fd ff ff       	jmp    c0101db7 <__alltraps>

c0101fc1 <vector56>:
.globl vector56
vector56:
  pushl $0
c0101fc1:	6a 00                	push   $0x0
  pushl $56
c0101fc3:	6a 38                	push   $0x38
  jmp __alltraps
c0101fc5:	e9 ed fd ff ff       	jmp    c0101db7 <__alltraps>

c0101fca <vector57>:
.globl vector57
vector57:
  pushl $0
c0101fca:	6a 00                	push   $0x0
  pushl $57
c0101fcc:	6a 39                	push   $0x39
  jmp __alltraps
c0101fce:	e9 e4 fd ff ff       	jmp    c0101db7 <__alltraps>

c0101fd3 <vector58>:
.globl vector58
vector58:
  pushl $0
c0101fd3:	6a 00                	push   $0x0
  pushl $58
c0101fd5:	6a 3a                	push   $0x3a
  jmp __alltraps
c0101fd7:	e9 db fd ff ff       	jmp    c0101db7 <__alltraps>

c0101fdc <vector59>:
.globl vector59
vector59:
  pushl $0
c0101fdc:	6a 00                	push   $0x0
  pushl $59
c0101fde:	6a 3b                	push   $0x3b
  jmp __alltraps
c0101fe0:	e9 d2 fd ff ff       	jmp    c0101db7 <__alltraps>

c0101fe5 <vector60>:
.globl vector60
vector60:
  pushl $0
c0101fe5:	6a 00                	push   $0x0
  pushl $60
c0101fe7:	6a 3c                	push   $0x3c
  jmp __alltraps
c0101fe9:	e9 c9 fd ff ff       	jmp    c0101db7 <__alltraps>

c0101fee <vector61>:
.globl vector61
vector61:
  pushl $0
c0101fee:	6a 00                	push   $0x0
  pushl $61
c0101ff0:	6a 3d                	push   $0x3d
  jmp __alltraps
c0101ff2:	e9 c0 fd ff ff       	jmp    c0101db7 <__alltraps>

c0101ff7 <vector62>:
.globl vector62
vector62:
  pushl $0
c0101ff7:	6a 00                	push   $0x0
  pushl $62
c0101ff9:	6a 3e                	push   $0x3e
  jmp __alltraps
c0101ffb:	e9 b7 fd ff ff       	jmp    c0101db7 <__alltraps>

c0102000 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102000:	6a 00                	push   $0x0
  pushl $63
c0102002:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102004:	e9 ae fd ff ff       	jmp    c0101db7 <__alltraps>

c0102009 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102009:	6a 00                	push   $0x0
  pushl $64
c010200b:	6a 40                	push   $0x40
  jmp __alltraps
c010200d:	e9 a5 fd ff ff       	jmp    c0101db7 <__alltraps>

c0102012 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102012:	6a 00                	push   $0x0
  pushl $65
c0102014:	6a 41                	push   $0x41
  jmp __alltraps
c0102016:	e9 9c fd ff ff       	jmp    c0101db7 <__alltraps>

c010201b <vector66>:
.globl vector66
vector66:
  pushl $0
c010201b:	6a 00                	push   $0x0
  pushl $66
c010201d:	6a 42                	push   $0x42
  jmp __alltraps
c010201f:	e9 93 fd ff ff       	jmp    c0101db7 <__alltraps>

c0102024 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102024:	6a 00                	push   $0x0
  pushl $67
c0102026:	6a 43                	push   $0x43
  jmp __alltraps
c0102028:	e9 8a fd ff ff       	jmp    c0101db7 <__alltraps>

c010202d <vector68>:
.globl vector68
vector68:
  pushl $0
c010202d:	6a 00                	push   $0x0
  pushl $68
c010202f:	6a 44                	push   $0x44
  jmp __alltraps
c0102031:	e9 81 fd ff ff       	jmp    c0101db7 <__alltraps>

c0102036 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102036:	6a 00                	push   $0x0
  pushl $69
c0102038:	6a 45                	push   $0x45
  jmp __alltraps
c010203a:	e9 78 fd ff ff       	jmp    c0101db7 <__alltraps>

c010203f <vector70>:
.globl vector70
vector70:
  pushl $0
c010203f:	6a 00                	push   $0x0
  pushl $70
c0102041:	6a 46                	push   $0x46
  jmp __alltraps
c0102043:	e9 6f fd ff ff       	jmp    c0101db7 <__alltraps>

c0102048 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102048:	6a 00                	push   $0x0
  pushl $71
c010204a:	6a 47                	push   $0x47
  jmp __alltraps
c010204c:	e9 66 fd ff ff       	jmp    c0101db7 <__alltraps>

c0102051 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102051:	6a 00                	push   $0x0
  pushl $72
c0102053:	6a 48                	push   $0x48
  jmp __alltraps
c0102055:	e9 5d fd ff ff       	jmp    c0101db7 <__alltraps>

c010205a <vector73>:
.globl vector73
vector73:
  pushl $0
c010205a:	6a 00                	push   $0x0
  pushl $73
c010205c:	6a 49                	push   $0x49
  jmp __alltraps
c010205e:	e9 54 fd ff ff       	jmp    c0101db7 <__alltraps>

c0102063 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102063:	6a 00                	push   $0x0
  pushl $74
c0102065:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102067:	e9 4b fd ff ff       	jmp    c0101db7 <__alltraps>

c010206c <vector75>:
.globl vector75
vector75:
  pushl $0
c010206c:	6a 00                	push   $0x0
  pushl $75
c010206e:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102070:	e9 42 fd ff ff       	jmp    c0101db7 <__alltraps>

c0102075 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102075:	6a 00                	push   $0x0
  pushl $76
c0102077:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102079:	e9 39 fd ff ff       	jmp    c0101db7 <__alltraps>

c010207e <vector77>:
.globl vector77
vector77:
  pushl $0
c010207e:	6a 00                	push   $0x0
  pushl $77
c0102080:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102082:	e9 30 fd ff ff       	jmp    c0101db7 <__alltraps>

c0102087 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102087:	6a 00                	push   $0x0
  pushl $78
c0102089:	6a 4e                	push   $0x4e
  jmp __alltraps
c010208b:	e9 27 fd ff ff       	jmp    c0101db7 <__alltraps>

c0102090 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102090:	6a 00                	push   $0x0
  pushl $79
c0102092:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102094:	e9 1e fd ff ff       	jmp    c0101db7 <__alltraps>

c0102099 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102099:	6a 00                	push   $0x0
  pushl $80
c010209b:	6a 50                	push   $0x50
  jmp __alltraps
c010209d:	e9 15 fd ff ff       	jmp    c0101db7 <__alltraps>

c01020a2 <vector81>:
.globl vector81
vector81:
  pushl $0
c01020a2:	6a 00                	push   $0x0
  pushl $81
c01020a4:	6a 51                	push   $0x51
  jmp __alltraps
c01020a6:	e9 0c fd ff ff       	jmp    c0101db7 <__alltraps>

c01020ab <vector82>:
.globl vector82
vector82:
  pushl $0
c01020ab:	6a 00                	push   $0x0
  pushl $82
c01020ad:	6a 52                	push   $0x52
  jmp __alltraps
c01020af:	e9 03 fd ff ff       	jmp    c0101db7 <__alltraps>

c01020b4 <vector83>:
.globl vector83
vector83:
  pushl $0
c01020b4:	6a 00                	push   $0x0
  pushl $83
c01020b6:	6a 53                	push   $0x53
  jmp __alltraps
c01020b8:	e9 fa fc ff ff       	jmp    c0101db7 <__alltraps>

c01020bd <vector84>:
.globl vector84
vector84:
  pushl $0
c01020bd:	6a 00                	push   $0x0
  pushl $84
c01020bf:	6a 54                	push   $0x54
  jmp __alltraps
c01020c1:	e9 f1 fc ff ff       	jmp    c0101db7 <__alltraps>

c01020c6 <vector85>:
.globl vector85
vector85:
  pushl $0
c01020c6:	6a 00                	push   $0x0
  pushl $85
c01020c8:	6a 55                	push   $0x55
  jmp __alltraps
c01020ca:	e9 e8 fc ff ff       	jmp    c0101db7 <__alltraps>

c01020cf <vector86>:
.globl vector86
vector86:
  pushl $0
c01020cf:	6a 00                	push   $0x0
  pushl $86
c01020d1:	6a 56                	push   $0x56
  jmp __alltraps
c01020d3:	e9 df fc ff ff       	jmp    c0101db7 <__alltraps>

c01020d8 <vector87>:
.globl vector87
vector87:
  pushl $0
c01020d8:	6a 00                	push   $0x0
  pushl $87
c01020da:	6a 57                	push   $0x57
  jmp __alltraps
c01020dc:	e9 d6 fc ff ff       	jmp    c0101db7 <__alltraps>

c01020e1 <vector88>:
.globl vector88
vector88:
  pushl $0
c01020e1:	6a 00                	push   $0x0
  pushl $88
c01020e3:	6a 58                	push   $0x58
  jmp __alltraps
c01020e5:	e9 cd fc ff ff       	jmp    c0101db7 <__alltraps>

c01020ea <vector89>:
.globl vector89
vector89:
  pushl $0
c01020ea:	6a 00                	push   $0x0
  pushl $89
c01020ec:	6a 59                	push   $0x59
  jmp __alltraps
c01020ee:	e9 c4 fc ff ff       	jmp    c0101db7 <__alltraps>

c01020f3 <vector90>:
.globl vector90
vector90:
  pushl $0
c01020f3:	6a 00                	push   $0x0
  pushl $90
c01020f5:	6a 5a                	push   $0x5a
  jmp __alltraps
c01020f7:	e9 bb fc ff ff       	jmp    c0101db7 <__alltraps>

c01020fc <vector91>:
.globl vector91
vector91:
  pushl $0
c01020fc:	6a 00                	push   $0x0
  pushl $91
c01020fe:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102100:	e9 b2 fc ff ff       	jmp    c0101db7 <__alltraps>

c0102105 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102105:	6a 00                	push   $0x0
  pushl $92
c0102107:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102109:	e9 a9 fc ff ff       	jmp    c0101db7 <__alltraps>

c010210e <vector93>:
.globl vector93
vector93:
  pushl $0
c010210e:	6a 00                	push   $0x0
  pushl $93
c0102110:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102112:	e9 a0 fc ff ff       	jmp    c0101db7 <__alltraps>

c0102117 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102117:	6a 00                	push   $0x0
  pushl $94
c0102119:	6a 5e                	push   $0x5e
  jmp __alltraps
c010211b:	e9 97 fc ff ff       	jmp    c0101db7 <__alltraps>

c0102120 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102120:	6a 00                	push   $0x0
  pushl $95
c0102122:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102124:	e9 8e fc ff ff       	jmp    c0101db7 <__alltraps>

c0102129 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102129:	6a 00                	push   $0x0
  pushl $96
c010212b:	6a 60                	push   $0x60
  jmp __alltraps
c010212d:	e9 85 fc ff ff       	jmp    c0101db7 <__alltraps>

c0102132 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102132:	6a 00                	push   $0x0
  pushl $97
c0102134:	6a 61                	push   $0x61
  jmp __alltraps
c0102136:	e9 7c fc ff ff       	jmp    c0101db7 <__alltraps>

c010213b <vector98>:
.globl vector98
vector98:
  pushl $0
c010213b:	6a 00                	push   $0x0
  pushl $98
c010213d:	6a 62                	push   $0x62
  jmp __alltraps
c010213f:	e9 73 fc ff ff       	jmp    c0101db7 <__alltraps>

c0102144 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102144:	6a 00                	push   $0x0
  pushl $99
c0102146:	6a 63                	push   $0x63
  jmp __alltraps
c0102148:	e9 6a fc ff ff       	jmp    c0101db7 <__alltraps>

c010214d <vector100>:
.globl vector100
vector100:
  pushl $0
c010214d:	6a 00                	push   $0x0
  pushl $100
c010214f:	6a 64                	push   $0x64
  jmp __alltraps
c0102151:	e9 61 fc ff ff       	jmp    c0101db7 <__alltraps>

c0102156 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102156:	6a 00                	push   $0x0
  pushl $101
c0102158:	6a 65                	push   $0x65
  jmp __alltraps
c010215a:	e9 58 fc ff ff       	jmp    c0101db7 <__alltraps>

c010215f <vector102>:
.globl vector102
vector102:
  pushl $0
c010215f:	6a 00                	push   $0x0
  pushl $102
c0102161:	6a 66                	push   $0x66
  jmp __alltraps
c0102163:	e9 4f fc ff ff       	jmp    c0101db7 <__alltraps>

c0102168 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102168:	6a 00                	push   $0x0
  pushl $103
c010216a:	6a 67                	push   $0x67
  jmp __alltraps
c010216c:	e9 46 fc ff ff       	jmp    c0101db7 <__alltraps>

c0102171 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102171:	6a 00                	push   $0x0
  pushl $104
c0102173:	6a 68                	push   $0x68
  jmp __alltraps
c0102175:	e9 3d fc ff ff       	jmp    c0101db7 <__alltraps>

c010217a <vector105>:
.globl vector105
vector105:
  pushl $0
c010217a:	6a 00                	push   $0x0
  pushl $105
c010217c:	6a 69                	push   $0x69
  jmp __alltraps
c010217e:	e9 34 fc ff ff       	jmp    c0101db7 <__alltraps>

c0102183 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102183:	6a 00                	push   $0x0
  pushl $106
c0102185:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102187:	e9 2b fc ff ff       	jmp    c0101db7 <__alltraps>

c010218c <vector107>:
.globl vector107
vector107:
  pushl $0
c010218c:	6a 00                	push   $0x0
  pushl $107
c010218e:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102190:	e9 22 fc ff ff       	jmp    c0101db7 <__alltraps>

c0102195 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102195:	6a 00                	push   $0x0
  pushl $108
c0102197:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102199:	e9 19 fc ff ff       	jmp    c0101db7 <__alltraps>

c010219e <vector109>:
.globl vector109
vector109:
  pushl $0
c010219e:	6a 00                	push   $0x0
  pushl $109
c01021a0:	6a 6d                	push   $0x6d
  jmp __alltraps
c01021a2:	e9 10 fc ff ff       	jmp    c0101db7 <__alltraps>

c01021a7 <vector110>:
.globl vector110
vector110:
  pushl $0
c01021a7:	6a 00                	push   $0x0
  pushl $110
c01021a9:	6a 6e                	push   $0x6e
  jmp __alltraps
c01021ab:	e9 07 fc ff ff       	jmp    c0101db7 <__alltraps>

c01021b0 <vector111>:
.globl vector111
vector111:
  pushl $0
c01021b0:	6a 00                	push   $0x0
  pushl $111
c01021b2:	6a 6f                	push   $0x6f
  jmp __alltraps
c01021b4:	e9 fe fb ff ff       	jmp    c0101db7 <__alltraps>

c01021b9 <vector112>:
.globl vector112
vector112:
  pushl $0
c01021b9:	6a 00                	push   $0x0
  pushl $112
c01021bb:	6a 70                	push   $0x70
  jmp __alltraps
c01021bd:	e9 f5 fb ff ff       	jmp    c0101db7 <__alltraps>

c01021c2 <vector113>:
.globl vector113
vector113:
  pushl $0
c01021c2:	6a 00                	push   $0x0
  pushl $113
c01021c4:	6a 71                	push   $0x71
  jmp __alltraps
c01021c6:	e9 ec fb ff ff       	jmp    c0101db7 <__alltraps>

c01021cb <vector114>:
.globl vector114
vector114:
  pushl $0
c01021cb:	6a 00                	push   $0x0
  pushl $114
c01021cd:	6a 72                	push   $0x72
  jmp __alltraps
c01021cf:	e9 e3 fb ff ff       	jmp    c0101db7 <__alltraps>

c01021d4 <vector115>:
.globl vector115
vector115:
  pushl $0
c01021d4:	6a 00                	push   $0x0
  pushl $115
c01021d6:	6a 73                	push   $0x73
  jmp __alltraps
c01021d8:	e9 da fb ff ff       	jmp    c0101db7 <__alltraps>

c01021dd <vector116>:
.globl vector116
vector116:
  pushl $0
c01021dd:	6a 00                	push   $0x0
  pushl $116
c01021df:	6a 74                	push   $0x74
  jmp __alltraps
c01021e1:	e9 d1 fb ff ff       	jmp    c0101db7 <__alltraps>

c01021e6 <vector117>:
.globl vector117
vector117:
  pushl $0
c01021e6:	6a 00                	push   $0x0
  pushl $117
c01021e8:	6a 75                	push   $0x75
  jmp __alltraps
c01021ea:	e9 c8 fb ff ff       	jmp    c0101db7 <__alltraps>

c01021ef <vector118>:
.globl vector118
vector118:
  pushl $0
c01021ef:	6a 00                	push   $0x0
  pushl $118
c01021f1:	6a 76                	push   $0x76
  jmp __alltraps
c01021f3:	e9 bf fb ff ff       	jmp    c0101db7 <__alltraps>

c01021f8 <vector119>:
.globl vector119
vector119:
  pushl $0
c01021f8:	6a 00                	push   $0x0
  pushl $119
c01021fa:	6a 77                	push   $0x77
  jmp __alltraps
c01021fc:	e9 b6 fb ff ff       	jmp    c0101db7 <__alltraps>

c0102201 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102201:	6a 00                	push   $0x0
  pushl $120
c0102203:	6a 78                	push   $0x78
  jmp __alltraps
c0102205:	e9 ad fb ff ff       	jmp    c0101db7 <__alltraps>

c010220a <vector121>:
.globl vector121
vector121:
  pushl $0
c010220a:	6a 00                	push   $0x0
  pushl $121
c010220c:	6a 79                	push   $0x79
  jmp __alltraps
c010220e:	e9 a4 fb ff ff       	jmp    c0101db7 <__alltraps>

c0102213 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102213:	6a 00                	push   $0x0
  pushl $122
c0102215:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102217:	e9 9b fb ff ff       	jmp    c0101db7 <__alltraps>

c010221c <vector123>:
.globl vector123
vector123:
  pushl $0
c010221c:	6a 00                	push   $0x0
  pushl $123
c010221e:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102220:	e9 92 fb ff ff       	jmp    c0101db7 <__alltraps>

c0102225 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102225:	6a 00                	push   $0x0
  pushl $124
c0102227:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102229:	e9 89 fb ff ff       	jmp    c0101db7 <__alltraps>

c010222e <vector125>:
.globl vector125
vector125:
  pushl $0
c010222e:	6a 00                	push   $0x0
  pushl $125
c0102230:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102232:	e9 80 fb ff ff       	jmp    c0101db7 <__alltraps>

c0102237 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102237:	6a 00                	push   $0x0
  pushl $126
c0102239:	6a 7e                	push   $0x7e
  jmp __alltraps
c010223b:	e9 77 fb ff ff       	jmp    c0101db7 <__alltraps>

c0102240 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102240:	6a 00                	push   $0x0
  pushl $127
c0102242:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102244:	e9 6e fb ff ff       	jmp    c0101db7 <__alltraps>

c0102249 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102249:	6a 00                	push   $0x0
  pushl $128
c010224b:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102250:	e9 62 fb ff ff       	jmp    c0101db7 <__alltraps>

c0102255 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102255:	6a 00                	push   $0x0
  pushl $129
c0102257:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c010225c:	e9 56 fb ff ff       	jmp    c0101db7 <__alltraps>

c0102261 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102261:	6a 00                	push   $0x0
  pushl $130
c0102263:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102268:	e9 4a fb ff ff       	jmp    c0101db7 <__alltraps>

c010226d <vector131>:
.globl vector131
vector131:
  pushl $0
c010226d:	6a 00                	push   $0x0
  pushl $131
c010226f:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102274:	e9 3e fb ff ff       	jmp    c0101db7 <__alltraps>

c0102279 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102279:	6a 00                	push   $0x0
  pushl $132
c010227b:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102280:	e9 32 fb ff ff       	jmp    c0101db7 <__alltraps>

c0102285 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102285:	6a 00                	push   $0x0
  pushl $133
c0102287:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c010228c:	e9 26 fb ff ff       	jmp    c0101db7 <__alltraps>

c0102291 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102291:	6a 00                	push   $0x0
  pushl $134
c0102293:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102298:	e9 1a fb ff ff       	jmp    c0101db7 <__alltraps>

c010229d <vector135>:
.globl vector135
vector135:
  pushl $0
c010229d:	6a 00                	push   $0x0
  pushl $135
c010229f:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01022a4:	e9 0e fb ff ff       	jmp    c0101db7 <__alltraps>

c01022a9 <vector136>:
.globl vector136
vector136:
  pushl $0
c01022a9:	6a 00                	push   $0x0
  pushl $136
c01022ab:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01022b0:	e9 02 fb ff ff       	jmp    c0101db7 <__alltraps>

c01022b5 <vector137>:
.globl vector137
vector137:
  pushl $0
c01022b5:	6a 00                	push   $0x0
  pushl $137
c01022b7:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c01022bc:	e9 f6 fa ff ff       	jmp    c0101db7 <__alltraps>

c01022c1 <vector138>:
.globl vector138
vector138:
  pushl $0
c01022c1:	6a 00                	push   $0x0
  pushl $138
c01022c3:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01022c8:	e9 ea fa ff ff       	jmp    c0101db7 <__alltraps>

c01022cd <vector139>:
.globl vector139
vector139:
  pushl $0
c01022cd:	6a 00                	push   $0x0
  pushl $139
c01022cf:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01022d4:	e9 de fa ff ff       	jmp    c0101db7 <__alltraps>

c01022d9 <vector140>:
.globl vector140
vector140:
  pushl $0
c01022d9:	6a 00                	push   $0x0
  pushl $140
c01022db:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01022e0:	e9 d2 fa ff ff       	jmp    c0101db7 <__alltraps>

c01022e5 <vector141>:
.globl vector141
vector141:
  pushl $0
c01022e5:	6a 00                	push   $0x0
  pushl $141
c01022e7:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01022ec:	e9 c6 fa ff ff       	jmp    c0101db7 <__alltraps>

c01022f1 <vector142>:
.globl vector142
vector142:
  pushl $0
c01022f1:	6a 00                	push   $0x0
  pushl $142
c01022f3:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01022f8:	e9 ba fa ff ff       	jmp    c0101db7 <__alltraps>

c01022fd <vector143>:
.globl vector143
vector143:
  pushl $0
c01022fd:	6a 00                	push   $0x0
  pushl $143
c01022ff:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102304:	e9 ae fa ff ff       	jmp    c0101db7 <__alltraps>

c0102309 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102309:	6a 00                	push   $0x0
  pushl $144
c010230b:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102310:	e9 a2 fa ff ff       	jmp    c0101db7 <__alltraps>

c0102315 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102315:	6a 00                	push   $0x0
  pushl $145
c0102317:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c010231c:	e9 96 fa ff ff       	jmp    c0101db7 <__alltraps>

c0102321 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102321:	6a 00                	push   $0x0
  pushl $146
c0102323:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102328:	e9 8a fa ff ff       	jmp    c0101db7 <__alltraps>

c010232d <vector147>:
.globl vector147
vector147:
  pushl $0
c010232d:	6a 00                	push   $0x0
  pushl $147
c010232f:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102334:	e9 7e fa ff ff       	jmp    c0101db7 <__alltraps>

c0102339 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102339:	6a 00                	push   $0x0
  pushl $148
c010233b:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102340:	e9 72 fa ff ff       	jmp    c0101db7 <__alltraps>

c0102345 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102345:	6a 00                	push   $0x0
  pushl $149
c0102347:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c010234c:	e9 66 fa ff ff       	jmp    c0101db7 <__alltraps>

c0102351 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102351:	6a 00                	push   $0x0
  pushl $150
c0102353:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102358:	e9 5a fa ff ff       	jmp    c0101db7 <__alltraps>

c010235d <vector151>:
.globl vector151
vector151:
  pushl $0
c010235d:	6a 00                	push   $0x0
  pushl $151
c010235f:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102364:	e9 4e fa ff ff       	jmp    c0101db7 <__alltraps>

c0102369 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102369:	6a 00                	push   $0x0
  pushl $152
c010236b:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102370:	e9 42 fa ff ff       	jmp    c0101db7 <__alltraps>

c0102375 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102375:	6a 00                	push   $0x0
  pushl $153
c0102377:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c010237c:	e9 36 fa ff ff       	jmp    c0101db7 <__alltraps>

c0102381 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102381:	6a 00                	push   $0x0
  pushl $154
c0102383:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102388:	e9 2a fa ff ff       	jmp    c0101db7 <__alltraps>

c010238d <vector155>:
.globl vector155
vector155:
  pushl $0
c010238d:	6a 00                	push   $0x0
  pushl $155
c010238f:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102394:	e9 1e fa ff ff       	jmp    c0101db7 <__alltraps>

c0102399 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102399:	6a 00                	push   $0x0
  pushl $156
c010239b:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01023a0:	e9 12 fa ff ff       	jmp    c0101db7 <__alltraps>

c01023a5 <vector157>:
.globl vector157
vector157:
  pushl $0
c01023a5:	6a 00                	push   $0x0
  pushl $157
c01023a7:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01023ac:	e9 06 fa ff ff       	jmp    c0101db7 <__alltraps>

c01023b1 <vector158>:
.globl vector158
vector158:
  pushl $0
c01023b1:	6a 00                	push   $0x0
  pushl $158
c01023b3:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c01023b8:	e9 fa f9 ff ff       	jmp    c0101db7 <__alltraps>

c01023bd <vector159>:
.globl vector159
vector159:
  pushl $0
c01023bd:	6a 00                	push   $0x0
  pushl $159
c01023bf:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01023c4:	e9 ee f9 ff ff       	jmp    c0101db7 <__alltraps>

c01023c9 <vector160>:
.globl vector160
vector160:
  pushl $0
c01023c9:	6a 00                	push   $0x0
  pushl $160
c01023cb:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01023d0:	e9 e2 f9 ff ff       	jmp    c0101db7 <__alltraps>

c01023d5 <vector161>:
.globl vector161
vector161:
  pushl $0
c01023d5:	6a 00                	push   $0x0
  pushl $161
c01023d7:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01023dc:	e9 d6 f9 ff ff       	jmp    c0101db7 <__alltraps>

c01023e1 <vector162>:
.globl vector162
vector162:
  pushl $0
c01023e1:	6a 00                	push   $0x0
  pushl $162
c01023e3:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01023e8:	e9 ca f9 ff ff       	jmp    c0101db7 <__alltraps>

c01023ed <vector163>:
.globl vector163
vector163:
  pushl $0
c01023ed:	6a 00                	push   $0x0
  pushl $163
c01023ef:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01023f4:	e9 be f9 ff ff       	jmp    c0101db7 <__alltraps>

c01023f9 <vector164>:
.globl vector164
vector164:
  pushl $0
c01023f9:	6a 00                	push   $0x0
  pushl $164
c01023fb:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102400:	e9 b2 f9 ff ff       	jmp    c0101db7 <__alltraps>

c0102405 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102405:	6a 00                	push   $0x0
  pushl $165
c0102407:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c010240c:	e9 a6 f9 ff ff       	jmp    c0101db7 <__alltraps>

c0102411 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102411:	6a 00                	push   $0x0
  pushl $166
c0102413:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102418:	e9 9a f9 ff ff       	jmp    c0101db7 <__alltraps>

c010241d <vector167>:
.globl vector167
vector167:
  pushl $0
c010241d:	6a 00                	push   $0x0
  pushl $167
c010241f:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102424:	e9 8e f9 ff ff       	jmp    c0101db7 <__alltraps>

c0102429 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102429:	6a 00                	push   $0x0
  pushl $168
c010242b:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102430:	e9 82 f9 ff ff       	jmp    c0101db7 <__alltraps>

c0102435 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102435:	6a 00                	push   $0x0
  pushl $169
c0102437:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c010243c:	e9 76 f9 ff ff       	jmp    c0101db7 <__alltraps>

c0102441 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102441:	6a 00                	push   $0x0
  pushl $170
c0102443:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102448:	e9 6a f9 ff ff       	jmp    c0101db7 <__alltraps>

c010244d <vector171>:
.globl vector171
vector171:
  pushl $0
c010244d:	6a 00                	push   $0x0
  pushl $171
c010244f:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102454:	e9 5e f9 ff ff       	jmp    c0101db7 <__alltraps>

c0102459 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102459:	6a 00                	push   $0x0
  pushl $172
c010245b:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102460:	e9 52 f9 ff ff       	jmp    c0101db7 <__alltraps>

c0102465 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102465:	6a 00                	push   $0x0
  pushl $173
c0102467:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c010246c:	e9 46 f9 ff ff       	jmp    c0101db7 <__alltraps>

c0102471 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102471:	6a 00                	push   $0x0
  pushl $174
c0102473:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102478:	e9 3a f9 ff ff       	jmp    c0101db7 <__alltraps>

c010247d <vector175>:
.globl vector175
vector175:
  pushl $0
c010247d:	6a 00                	push   $0x0
  pushl $175
c010247f:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102484:	e9 2e f9 ff ff       	jmp    c0101db7 <__alltraps>

c0102489 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102489:	6a 00                	push   $0x0
  pushl $176
c010248b:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102490:	e9 22 f9 ff ff       	jmp    c0101db7 <__alltraps>

c0102495 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102495:	6a 00                	push   $0x0
  pushl $177
c0102497:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010249c:	e9 16 f9 ff ff       	jmp    c0101db7 <__alltraps>

c01024a1 <vector178>:
.globl vector178
vector178:
  pushl $0
c01024a1:	6a 00                	push   $0x0
  pushl $178
c01024a3:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c01024a8:	e9 0a f9 ff ff       	jmp    c0101db7 <__alltraps>

c01024ad <vector179>:
.globl vector179
vector179:
  pushl $0
c01024ad:	6a 00                	push   $0x0
  pushl $179
c01024af:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01024b4:	e9 fe f8 ff ff       	jmp    c0101db7 <__alltraps>

c01024b9 <vector180>:
.globl vector180
vector180:
  pushl $0
c01024b9:	6a 00                	push   $0x0
  pushl $180
c01024bb:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01024c0:	e9 f2 f8 ff ff       	jmp    c0101db7 <__alltraps>

c01024c5 <vector181>:
.globl vector181
vector181:
  pushl $0
c01024c5:	6a 00                	push   $0x0
  pushl $181
c01024c7:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01024cc:	e9 e6 f8 ff ff       	jmp    c0101db7 <__alltraps>

c01024d1 <vector182>:
.globl vector182
vector182:
  pushl $0
c01024d1:	6a 00                	push   $0x0
  pushl $182
c01024d3:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01024d8:	e9 da f8 ff ff       	jmp    c0101db7 <__alltraps>

c01024dd <vector183>:
.globl vector183
vector183:
  pushl $0
c01024dd:	6a 00                	push   $0x0
  pushl $183
c01024df:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01024e4:	e9 ce f8 ff ff       	jmp    c0101db7 <__alltraps>

c01024e9 <vector184>:
.globl vector184
vector184:
  pushl $0
c01024e9:	6a 00                	push   $0x0
  pushl $184
c01024eb:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01024f0:	e9 c2 f8 ff ff       	jmp    c0101db7 <__alltraps>

c01024f5 <vector185>:
.globl vector185
vector185:
  pushl $0
c01024f5:	6a 00                	push   $0x0
  pushl $185
c01024f7:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01024fc:	e9 b6 f8 ff ff       	jmp    c0101db7 <__alltraps>

c0102501 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102501:	6a 00                	push   $0x0
  pushl $186
c0102503:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102508:	e9 aa f8 ff ff       	jmp    c0101db7 <__alltraps>

c010250d <vector187>:
.globl vector187
vector187:
  pushl $0
c010250d:	6a 00                	push   $0x0
  pushl $187
c010250f:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102514:	e9 9e f8 ff ff       	jmp    c0101db7 <__alltraps>

c0102519 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102519:	6a 00                	push   $0x0
  pushl $188
c010251b:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102520:	e9 92 f8 ff ff       	jmp    c0101db7 <__alltraps>

c0102525 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102525:	6a 00                	push   $0x0
  pushl $189
c0102527:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c010252c:	e9 86 f8 ff ff       	jmp    c0101db7 <__alltraps>

c0102531 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102531:	6a 00                	push   $0x0
  pushl $190
c0102533:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102538:	e9 7a f8 ff ff       	jmp    c0101db7 <__alltraps>

c010253d <vector191>:
.globl vector191
vector191:
  pushl $0
c010253d:	6a 00                	push   $0x0
  pushl $191
c010253f:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102544:	e9 6e f8 ff ff       	jmp    c0101db7 <__alltraps>

c0102549 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102549:	6a 00                	push   $0x0
  pushl $192
c010254b:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102550:	e9 62 f8 ff ff       	jmp    c0101db7 <__alltraps>

c0102555 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102555:	6a 00                	push   $0x0
  pushl $193
c0102557:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c010255c:	e9 56 f8 ff ff       	jmp    c0101db7 <__alltraps>

c0102561 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102561:	6a 00                	push   $0x0
  pushl $194
c0102563:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102568:	e9 4a f8 ff ff       	jmp    c0101db7 <__alltraps>

c010256d <vector195>:
.globl vector195
vector195:
  pushl $0
c010256d:	6a 00                	push   $0x0
  pushl $195
c010256f:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102574:	e9 3e f8 ff ff       	jmp    c0101db7 <__alltraps>

c0102579 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102579:	6a 00                	push   $0x0
  pushl $196
c010257b:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102580:	e9 32 f8 ff ff       	jmp    c0101db7 <__alltraps>

c0102585 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102585:	6a 00                	push   $0x0
  pushl $197
c0102587:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c010258c:	e9 26 f8 ff ff       	jmp    c0101db7 <__alltraps>

c0102591 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102591:	6a 00                	push   $0x0
  pushl $198
c0102593:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102598:	e9 1a f8 ff ff       	jmp    c0101db7 <__alltraps>

c010259d <vector199>:
.globl vector199
vector199:
  pushl $0
c010259d:	6a 00                	push   $0x0
  pushl $199
c010259f:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01025a4:	e9 0e f8 ff ff       	jmp    c0101db7 <__alltraps>

c01025a9 <vector200>:
.globl vector200
vector200:
  pushl $0
c01025a9:	6a 00                	push   $0x0
  pushl $200
c01025ab:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01025b0:	e9 02 f8 ff ff       	jmp    c0101db7 <__alltraps>

c01025b5 <vector201>:
.globl vector201
vector201:
  pushl $0
c01025b5:	6a 00                	push   $0x0
  pushl $201
c01025b7:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01025bc:	e9 f6 f7 ff ff       	jmp    c0101db7 <__alltraps>

c01025c1 <vector202>:
.globl vector202
vector202:
  pushl $0
c01025c1:	6a 00                	push   $0x0
  pushl $202
c01025c3:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01025c8:	e9 ea f7 ff ff       	jmp    c0101db7 <__alltraps>

c01025cd <vector203>:
.globl vector203
vector203:
  pushl $0
c01025cd:	6a 00                	push   $0x0
  pushl $203
c01025cf:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01025d4:	e9 de f7 ff ff       	jmp    c0101db7 <__alltraps>

c01025d9 <vector204>:
.globl vector204
vector204:
  pushl $0
c01025d9:	6a 00                	push   $0x0
  pushl $204
c01025db:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01025e0:	e9 d2 f7 ff ff       	jmp    c0101db7 <__alltraps>

c01025e5 <vector205>:
.globl vector205
vector205:
  pushl $0
c01025e5:	6a 00                	push   $0x0
  pushl $205
c01025e7:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01025ec:	e9 c6 f7 ff ff       	jmp    c0101db7 <__alltraps>

c01025f1 <vector206>:
.globl vector206
vector206:
  pushl $0
c01025f1:	6a 00                	push   $0x0
  pushl $206
c01025f3:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01025f8:	e9 ba f7 ff ff       	jmp    c0101db7 <__alltraps>

c01025fd <vector207>:
.globl vector207
vector207:
  pushl $0
c01025fd:	6a 00                	push   $0x0
  pushl $207
c01025ff:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102604:	e9 ae f7 ff ff       	jmp    c0101db7 <__alltraps>

c0102609 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102609:	6a 00                	push   $0x0
  pushl $208
c010260b:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102610:	e9 a2 f7 ff ff       	jmp    c0101db7 <__alltraps>

c0102615 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102615:	6a 00                	push   $0x0
  pushl $209
c0102617:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c010261c:	e9 96 f7 ff ff       	jmp    c0101db7 <__alltraps>

c0102621 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102621:	6a 00                	push   $0x0
  pushl $210
c0102623:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102628:	e9 8a f7 ff ff       	jmp    c0101db7 <__alltraps>

c010262d <vector211>:
.globl vector211
vector211:
  pushl $0
c010262d:	6a 00                	push   $0x0
  pushl $211
c010262f:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102634:	e9 7e f7 ff ff       	jmp    c0101db7 <__alltraps>

c0102639 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102639:	6a 00                	push   $0x0
  pushl $212
c010263b:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102640:	e9 72 f7 ff ff       	jmp    c0101db7 <__alltraps>

c0102645 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102645:	6a 00                	push   $0x0
  pushl $213
c0102647:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010264c:	e9 66 f7 ff ff       	jmp    c0101db7 <__alltraps>

c0102651 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102651:	6a 00                	push   $0x0
  pushl $214
c0102653:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102658:	e9 5a f7 ff ff       	jmp    c0101db7 <__alltraps>

c010265d <vector215>:
.globl vector215
vector215:
  pushl $0
c010265d:	6a 00                	push   $0x0
  pushl $215
c010265f:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102664:	e9 4e f7 ff ff       	jmp    c0101db7 <__alltraps>

c0102669 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102669:	6a 00                	push   $0x0
  pushl $216
c010266b:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102670:	e9 42 f7 ff ff       	jmp    c0101db7 <__alltraps>

c0102675 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102675:	6a 00                	push   $0x0
  pushl $217
c0102677:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c010267c:	e9 36 f7 ff ff       	jmp    c0101db7 <__alltraps>

c0102681 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102681:	6a 00                	push   $0x0
  pushl $218
c0102683:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102688:	e9 2a f7 ff ff       	jmp    c0101db7 <__alltraps>

c010268d <vector219>:
.globl vector219
vector219:
  pushl $0
c010268d:	6a 00                	push   $0x0
  pushl $219
c010268f:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102694:	e9 1e f7 ff ff       	jmp    c0101db7 <__alltraps>

c0102699 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102699:	6a 00                	push   $0x0
  pushl $220
c010269b:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01026a0:	e9 12 f7 ff ff       	jmp    c0101db7 <__alltraps>

c01026a5 <vector221>:
.globl vector221
vector221:
  pushl $0
c01026a5:	6a 00                	push   $0x0
  pushl $221
c01026a7:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01026ac:	e9 06 f7 ff ff       	jmp    c0101db7 <__alltraps>

c01026b1 <vector222>:
.globl vector222
vector222:
  pushl $0
c01026b1:	6a 00                	push   $0x0
  pushl $222
c01026b3:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01026b8:	e9 fa f6 ff ff       	jmp    c0101db7 <__alltraps>

c01026bd <vector223>:
.globl vector223
vector223:
  pushl $0
c01026bd:	6a 00                	push   $0x0
  pushl $223
c01026bf:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01026c4:	e9 ee f6 ff ff       	jmp    c0101db7 <__alltraps>

c01026c9 <vector224>:
.globl vector224
vector224:
  pushl $0
c01026c9:	6a 00                	push   $0x0
  pushl $224
c01026cb:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01026d0:	e9 e2 f6 ff ff       	jmp    c0101db7 <__alltraps>

c01026d5 <vector225>:
.globl vector225
vector225:
  pushl $0
c01026d5:	6a 00                	push   $0x0
  pushl $225
c01026d7:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01026dc:	e9 d6 f6 ff ff       	jmp    c0101db7 <__alltraps>

c01026e1 <vector226>:
.globl vector226
vector226:
  pushl $0
c01026e1:	6a 00                	push   $0x0
  pushl $226
c01026e3:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01026e8:	e9 ca f6 ff ff       	jmp    c0101db7 <__alltraps>

c01026ed <vector227>:
.globl vector227
vector227:
  pushl $0
c01026ed:	6a 00                	push   $0x0
  pushl $227
c01026ef:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01026f4:	e9 be f6 ff ff       	jmp    c0101db7 <__alltraps>

c01026f9 <vector228>:
.globl vector228
vector228:
  pushl $0
c01026f9:	6a 00                	push   $0x0
  pushl $228
c01026fb:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102700:	e9 b2 f6 ff ff       	jmp    c0101db7 <__alltraps>

c0102705 <vector229>:
.globl vector229
vector229:
  pushl $0
c0102705:	6a 00                	push   $0x0
  pushl $229
c0102707:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c010270c:	e9 a6 f6 ff ff       	jmp    c0101db7 <__alltraps>

c0102711 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102711:	6a 00                	push   $0x0
  pushl $230
c0102713:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102718:	e9 9a f6 ff ff       	jmp    c0101db7 <__alltraps>

c010271d <vector231>:
.globl vector231
vector231:
  pushl $0
c010271d:	6a 00                	push   $0x0
  pushl $231
c010271f:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102724:	e9 8e f6 ff ff       	jmp    c0101db7 <__alltraps>

c0102729 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102729:	6a 00                	push   $0x0
  pushl $232
c010272b:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102730:	e9 82 f6 ff ff       	jmp    c0101db7 <__alltraps>

c0102735 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102735:	6a 00                	push   $0x0
  pushl $233
c0102737:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c010273c:	e9 76 f6 ff ff       	jmp    c0101db7 <__alltraps>

c0102741 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102741:	6a 00                	push   $0x0
  pushl $234
c0102743:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102748:	e9 6a f6 ff ff       	jmp    c0101db7 <__alltraps>

c010274d <vector235>:
.globl vector235
vector235:
  pushl $0
c010274d:	6a 00                	push   $0x0
  pushl $235
c010274f:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102754:	e9 5e f6 ff ff       	jmp    c0101db7 <__alltraps>

c0102759 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102759:	6a 00                	push   $0x0
  pushl $236
c010275b:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102760:	e9 52 f6 ff ff       	jmp    c0101db7 <__alltraps>

c0102765 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102765:	6a 00                	push   $0x0
  pushl $237
c0102767:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c010276c:	e9 46 f6 ff ff       	jmp    c0101db7 <__alltraps>

c0102771 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102771:	6a 00                	push   $0x0
  pushl $238
c0102773:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102778:	e9 3a f6 ff ff       	jmp    c0101db7 <__alltraps>

c010277d <vector239>:
.globl vector239
vector239:
  pushl $0
c010277d:	6a 00                	push   $0x0
  pushl $239
c010277f:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102784:	e9 2e f6 ff ff       	jmp    c0101db7 <__alltraps>

c0102789 <vector240>:
.globl vector240
vector240:
  pushl $0
c0102789:	6a 00                	push   $0x0
  pushl $240
c010278b:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102790:	e9 22 f6 ff ff       	jmp    c0101db7 <__alltraps>

c0102795 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102795:	6a 00                	push   $0x0
  pushl $241
c0102797:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c010279c:	e9 16 f6 ff ff       	jmp    c0101db7 <__alltraps>

c01027a1 <vector242>:
.globl vector242
vector242:
  pushl $0
c01027a1:	6a 00                	push   $0x0
  pushl $242
c01027a3:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01027a8:	e9 0a f6 ff ff       	jmp    c0101db7 <__alltraps>

c01027ad <vector243>:
.globl vector243
vector243:
  pushl $0
c01027ad:	6a 00                	push   $0x0
  pushl $243
c01027af:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01027b4:	e9 fe f5 ff ff       	jmp    c0101db7 <__alltraps>

c01027b9 <vector244>:
.globl vector244
vector244:
  pushl $0
c01027b9:	6a 00                	push   $0x0
  pushl $244
c01027bb:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01027c0:	e9 f2 f5 ff ff       	jmp    c0101db7 <__alltraps>

c01027c5 <vector245>:
.globl vector245
vector245:
  pushl $0
c01027c5:	6a 00                	push   $0x0
  pushl $245
c01027c7:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01027cc:	e9 e6 f5 ff ff       	jmp    c0101db7 <__alltraps>

c01027d1 <vector246>:
.globl vector246
vector246:
  pushl $0
c01027d1:	6a 00                	push   $0x0
  pushl $246
c01027d3:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01027d8:	e9 da f5 ff ff       	jmp    c0101db7 <__alltraps>

c01027dd <vector247>:
.globl vector247
vector247:
  pushl $0
c01027dd:	6a 00                	push   $0x0
  pushl $247
c01027df:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01027e4:	e9 ce f5 ff ff       	jmp    c0101db7 <__alltraps>

c01027e9 <vector248>:
.globl vector248
vector248:
  pushl $0
c01027e9:	6a 00                	push   $0x0
  pushl $248
c01027eb:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01027f0:	e9 c2 f5 ff ff       	jmp    c0101db7 <__alltraps>

c01027f5 <vector249>:
.globl vector249
vector249:
  pushl $0
c01027f5:	6a 00                	push   $0x0
  pushl $249
c01027f7:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01027fc:	e9 b6 f5 ff ff       	jmp    c0101db7 <__alltraps>

c0102801 <vector250>:
.globl vector250
vector250:
  pushl $0
c0102801:	6a 00                	push   $0x0
  pushl $250
c0102803:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102808:	e9 aa f5 ff ff       	jmp    c0101db7 <__alltraps>

c010280d <vector251>:
.globl vector251
vector251:
  pushl $0
c010280d:	6a 00                	push   $0x0
  pushl $251
c010280f:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102814:	e9 9e f5 ff ff       	jmp    c0101db7 <__alltraps>

c0102819 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102819:	6a 00                	push   $0x0
  pushl $252
c010281b:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102820:	e9 92 f5 ff ff       	jmp    c0101db7 <__alltraps>

c0102825 <vector253>:
.globl vector253
vector253:
  pushl $0
c0102825:	6a 00                	push   $0x0
  pushl $253
c0102827:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c010282c:	e9 86 f5 ff ff       	jmp    c0101db7 <__alltraps>

c0102831 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102831:	6a 00                	push   $0x0
  pushl $254
c0102833:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102838:	e9 7a f5 ff ff       	jmp    c0101db7 <__alltraps>

c010283d <vector255>:
.globl vector255
vector255:
  pushl $0
c010283d:	6a 00                	push   $0x0
  pushl $255
c010283f:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102844:	e9 6e f5 ff ff       	jmp    c0101db7 <__alltraps>

c0102849 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102849:	55                   	push   %ebp
c010284a:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010284c:	8b 55 08             	mov    0x8(%ebp),%edx
c010284f:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0102854:	29 c2                	sub    %eax,%edx
c0102856:	89 d0                	mov    %edx,%eax
c0102858:	c1 f8 02             	sar    $0x2,%eax
c010285b:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102861:	5d                   	pop    %ebp
c0102862:	c3                   	ret    

c0102863 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102863:	55                   	push   %ebp
c0102864:	89 e5                	mov    %esp,%ebp
c0102866:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102869:	8b 45 08             	mov    0x8(%ebp),%eax
c010286c:	89 04 24             	mov    %eax,(%esp)
c010286f:	e8 d5 ff ff ff       	call   c0102849 <page2ppn>
c0102874:	c1 e0 0c             	shl    $0xc,%eax
}
c0102877:	c9                   	leave  
c0102878:	c3                   	ret    

c0102879 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0102879:	55                   	push   %ebp
c010287a:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010287c:	8b 45 08             	mov    0x8(%ebp),%eax
c010287f:	8b 00                	mov    (%eax),%eax
}
c0102881:	5d                   	pop    %ebp
c0102882:	c3                   	ret    

c0102883 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102883:	55                   	push   %ebp
c0102884:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102886:	8b 45 08             	mov    0x8(%ebp),%eax
c0102889:	8b 55 0c             	mov    0xc(%ebp),%edx
c010288c:	89 10                	mov    %edx,(%eax)
}
c010288e:	5d                   	pop    %ebp
c010288f:	c3                   	ret    

c0102890 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0102890:	55                   	push   %ebp
c0102891:	89 e5                	mov    %esp,%ebp
c0102893:	83 ec 10             	sub    $0x10,%esp
c0102896:	c7 45 fc 10 af 11 c0 	movl   $0xc011af10,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010289d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01028a0:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01028a3:	89 50 04             	mov    %edx,0x4(%eax)
c01028a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01028a9:	8b 50 04             	mov    0x4(%eax),%edx
c01028ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01028af:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c01028b1:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c01028b8:	00 00 00 
}
c01028bb:	c9                   	leave  
c01028bc:	c3                   	ret    

c01028bd <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c01028bd:	55                   	push   %ebp
c01028be:	89 e5                	mov    %esp,%ebp
c01028c0:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c01028c3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01028c7:	75 24                	jne    c01028ed <default_init_memmap+0x30>
c01028c9:	c7 44 24 0c d0 65 10 	movl   $0xc01065d0,0xc(%esp)
c01028d0:	c0 
c01028d1:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01028d8:	c0 
c01028d9:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01028e0:	00 
c01028e1:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01028e8:	e8 e5 e3 ff ff       	call   c0100cd2 <__panic>
    struct Page *p = base;
c01028ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01028f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01028f3:	e9 de 00 00 00       	jmp    c01029d6 <default_init_memmap+0x119>
        assert(PageReserved(p));
c01028f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028fb:	83 c0 04             	add    $0x4,%eax
c01028fe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0102905:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102908:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010290b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010290e:	0f a3 10             	bt     %edx,(%eax)
c0102911:	19 c0                	sbb    %eax,%eax
c0102913:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0102916:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010291a:	0f 95 c0             	setne  %al
c010291d:	0f b6 c0             	movzbl %al,%eax
c0102920:	85 c0                	test   %eax,%eax
c0102922:	75 24                	jne    c0102948 <default_init_memmap+0x8b>
c0102924:	c7 44 24 0c 01 66 10 	movl   $0xc0106601,0xc(%esp)
c010292b:	c0 
c010292c:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102933:	c0 
c0102934:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010293b:	00 
c010293c:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102943:	e8 8a e3 ff ff       	call   c0100cd2 <__panic>
        p->flags = p->property = 0;
c0102948:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010294b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0102952:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102955:	8b 50 08             	mov    0x8(%eax),%edx
c0102958:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010295b:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c010295e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102965:	00 
c0102966:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102969:	89 04 24             	mov    %eax,(%esp)
c010296c:	e8 12 ff ff ff       	call   c0102883 <set_page_ref>
	SetPageProperty(p);
c0102971:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102974:	83 c0 04             	add    $0x4,%eax
c0102977:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c010297e:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102981:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102984:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102987:	0f ab 10             	bts    %edx,(%eax)
	list_add_before(&free_list, &(p->page_link));
c010298a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010298d:	83 c0 0c             	add    $0xc,%eax
c0102990:	c7 45 dc 10 af 11 c0 	movl   $0xc011af10,-0x24(%ebp)
c0102997:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010299a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010299d:	8b 00                	mov    (%eax),%eax
c010299f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01029a2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01029a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01029a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01029ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01029ae:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01029b1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01029b4:	89 10                	mov    %edx,(%eax)
c01029b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01029b9:	8b 10                	mov    (%eax),%edx
c01029bb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01029be:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01029c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01029c4:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01029c7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01029ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01029cd:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01029d0:	89 10                	mov    %edx,(%eax)

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01029d2:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01029d6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01029d9:	89 d0                	mov    %edx,%eax
c01029db:	c1 e0 02             	shl    $0x2,%eax
c01029de:	01 d0                	add    %edx,%eax
c01029e0:	c1 e0 02             	shl    $0x2,%eax
c01029e3:	89 c2                	mov    %eax,%edx
c01029e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01029e8:	01 d0                	add    %edx,%eax
c01029ea:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01029ed:	0f 85 05 ff ff ff    	jne    c01028f8 <default_init_memmap+0x3b>
        p->flags = p->property = 0;
        set_page_ref(p, 0);
	SetPageProperty(p);
	list_add_before(&free_list, &(p->page_link));
    }
    base->property = n;
c01029f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01029f6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01029f9:	89 50 08             	mov    %edx,0x8(%eax)
    //SetPageProperty(base);
    nr_free += n;
c01029fc:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c0102a02:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102a05:	01 d0                	add    %edx,%eax
c0102a07:	a3 18 af 11 c0       	mov    %eax,0xc011af18
    //list_add(&free_list, &(base->page_link));
}
c0102a0c:	c9                   	leave  
c0102a0d:	c3                   	ret    

c0102a0e <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0102a0e:	55                   	push   %ebp
c0102a0f:	89 e5                	mov    %esp,%ebp
c0102a11:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102a14:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102a18:	75 24                	jne    c0102a3e <default_alloc_pages+0x30>
c0102a1a:	c7 44 24 0c d0 65 10 	movl   $0xc01065d0,0xc(%esp)
c0102a21:	c0 
c0102a22:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102a29:	c0 
c0102a2a:	c7 44 24 04 7e 00 00 	movl   $0x7e,0x4(%esp)
c0102a31:	00 
c0102a32:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102a39:	e8 94 e2 ff ff       	call   c0100cd2 <__panic>
    if (n > nr_free) {
c0102a3e:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102a43:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102a46:	73 0a                	jae    c0102a52 <default_alloc_pages+0x44>
        return NULL;
c0102a48:	b8 00 00 00 00       	mov    $0x0,%eax
c0102a4d:	e9 46 01 00 00       	jmp    c0102b98 <default_alloc_pages+0x18a>
    }
    struct Page *page = NULL;
c0102a52:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le, *len;
    le = &free_list;
c0102a59:	c7 45 f0 10 af 11 c0 	movl   $0xc011af10,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0102a60:	eb 1c                	jmp    c0102a7e <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0102a62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102a65:	83 e8 0c             	sub    $0xc,%eax
c0102a68:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
c0102a6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102a6e:	8b 40 08             	mov    0x8(%eax),%eax
c0102a71:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102a74:	72 08                	jb     c0102a7e <default_alloc_pages+0x70>
            page = p;
c0102a76:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102a79:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0102a7c:	eb 18                	jmp    c0102a96 <default_alloc_pages+0x88>
c0102a7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102a81:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102a84:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102a87:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le, *len;
    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0102a8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102a8d:	81 7d f0 10 af 11 c0 	cmpl   $0xc011af10,-0x10(%ebp)
c0102a94:	75 cc                	jne    c0102a62 <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) { //has found
c0102a96:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102a9a:	0f 84 f5 00 00 00    	je     c0102b95 <default_alloc_pages+0x187>
	//list_entry_t *len;
	int i;
	for(i=0;i<n;i++){
c0102aa0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102aa7:	eb 7c                	jmp    c0102b25 <default_alloc_pages+0x117>
c0102aa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102aac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0102aaf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102ab2:	8b 40 04             	mov    0x4(%eax),%eax
		len = list_next(le);
c0102ab5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		struct Page *p2 = le2page(le, page_link);
c0102ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102abb:	83 e8 0c             	sub    $0xc,%eax
c0102abe:	89 45 e0             	mov    %eax,-0x20(%ebp)
		SetPageReserved(p2);
c0102ac1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102ac4:	83 c0 04             	add    $0x4,%eax
c0102ac7:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
c0102ace:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0102ad1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102ad4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102ad7:	0f ab 10             	bts    %edx,(%eax)
		ClearPageProperty(p2);
c0102ada:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102add:	83 c0 04             	add    $0x4,%eax
c0102ae0:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0102ae7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102aea:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102aed:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102af0:	0f b3 10             	btr    %edx,(%eax)
c0102af3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102af6:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0102af9:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102afc:	8b 40 04             	mov    0x4(%eax),%eax
c0102aff:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102b02:	8b 12                	mov    (%edx),%edx
c0102b04:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0102b07:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102b0a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102b0d:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102b10:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102b13:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102b16:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102b19:	89 10                	mov    %edx,(%eax)
		list_del(le);
		le = len;	
c0102b1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102b1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
    }
    if (page != NULL) { //has found
	//list_entry_t *len;
	int i;
	for(i=0;i<n;i++){
c0102b21:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0102b25:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102b28:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102b2b:	0f 82 78 ff ff ff    	jb     c0102aa9 <default_alloc_pages+0x9b>
		ClearPageProperty(p2);
		list_del(le);
		le = len;	
	}
        //list_del(&(page->page_link));
	struct Page *p = le2page(le,page_link);
c0102b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b34:	83 e8 0c             	sub    $0xc,%eax
c0102b37:	89 45 dc             	mov    %eax,-0x24(%ebp)
        if (page->property > n) {
c0102b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b3d:	8b 40 08             	mov    0x8(%eax),%eax
c0102b40:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102b43:	76 11                	jbe    c0102b56 <default_alloc_pages+0x148>
            //struct Page *p = page + n;
            	p->property = page->property - n;
c0102b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b48:	8b 40 08             	mov    0x8(%eax),%eax
c0102b4b:	2b 45 08             	sub    0x8(%ebp),%eax
c0102b4e:	89 c2                	mov    %eax,%edx
c0102b50:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102b53:	89 50 08             	mov    %edx,0x8(%eax)
            //list_add(&free_list, &(p->page_link));
		//nr_free -= n;
    	}
        //nr_free -= n;
        ClearPageProperty(page);
c0102b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b59:	83 c0 04             	add    $0x4,%eax
c0102b5c:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c0102b63:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0102b66:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102b69:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102b6c:	0f b3 10             	btr    %edx,(%eax)
	SetPageReserved(page);
c0102b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b72:	83 c0 04             	add    $0x4,%eax
c0102b75:	c7 45 ac 00 00 00 00 	movl   $0x0,-0x54(%ebp)
c0102b7c:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102b7f:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102b82:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0102b85:	0f ab 10             	bts    %edx,(%eax)
	nr_free -= n;
c0102b88:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0102b8d:	2b 45 08             	sub    0x8(%ebp),%eax
c0102b90:	a3 18 af 11 c0       	mov    %eax,0xc011af18
	//return p;
    }
    return page;
c0102b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102b98:	c9                   	leave  
c0102b99:	c3                   	ret    

c0102b9a <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0102b9a:	55                   	push   %ebp
c0102b9b:	89 e5                	mov    %esp,%ebp
c0102b9d:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0102ba0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102ba4:	75 24                	jne    c0102bca <default_free_pages+0x30>
c0102ba6:	c7 44 24 0c d0 65 10 	movl   $0xc01065d0,0xc(%esp)
c0102bad:	c0 
c0102bae:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102bb5:	c0 
c0102bb6:	c7 44 24 04 aa 00 00 	movl   $0xaa,0x4(%esp)
c0102bbd:	00 
c0102bbe:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102bc5:	e8 08 e1 ff ff       	call   c0100cd2 <__panic>
    assert(PageReserved(base));
c0102bca:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bcd:	83 c0 04             	add    $0x4,%eax
c0102bd0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102bd7:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102bda:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102bdd:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102be0:	0f a3 10             	bt     %edx,(%eax)
c0102be3:	19 c0                	sbb    %eax,%eax
c0102be5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0102be8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102bec:	0f 95 c0             	setne  %al
c0102bef:	0f b6 c0             	movzbl %al,%eax
c0102bf2:	85 c0                	test   %eax,%eax
c0102bf4:	75 24                	jne    c0102c1a <default_free_pages+0x80>
c0102bf6:	c7 44 24 0c 11 66 10 	movl   $0xc0106611,0xc(%esp)
c0102bfd:	c0 
c0102bfe:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102c05:	c0 
c0102c06:	c7 44 24 04 ab 00 00 	movl   $0xab,0x4(%esp)
c0102c0d:	00 
c0102c0e:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102c15:	e8 b8 e0 ff ff       	call   c0100cd2 <__panic>
    list_entry_t *le = &free_list;
c0102c1a:	c7 45 f4 10 af 11 c0 	movl   $0xc011af10,-0xc(%ebp)
    struct Page *p = base;
c0102c21:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c24:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while((le=list_next(le)) != &free_list) {
c0102c27:	eb 13                	jmp    c0102c3c <default_free_pages+0xa2>
	p = le2page(le, page_link);
c0102c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c2c:	83 e8 0c             	sub    $0xc,%eax
c0102c2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      	if(p>base){    
c0102c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102c35:	3b 45 08             	cmp    0x8(%ebp),%eax
c0102c38:	76 02                	jbe    c0102c3c <default_free_pages+0xa2>
        	break;
c0102c3a:	eb 18                	jmp    c0102c54 <default_free_pages+0xba>
c0102c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c3f:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0102c42:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102c45:	8b 40 04             	mov    0x4(%eax),%eax
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    assert(PageReserved(base));
    list_entry_t *le = &free_list;
    struct Page *p = base;
    while((le=list_next(le)) != &free_list) {
c0102c48:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102c4b:	81 7d f4 10 af 11 c0 	cmpl   $0xc011af10,-0xc(%ebp)
c0102c52:	75 d5                	jne    c0102c29 <default_free_pages+0x8f>
        //assert(!PageReserved(p) && !PageProperty(p));
        //p->flags = 0;
        //set_page_ref(p, 0);
    //}
//
    base->property = n;
c0102c54:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c57:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c5a:	89 50 08             	mov    %edx,0x8(%eax)
    //p = le2page(le, page_link);
    nr_free += n;
c0102c5d:	8b 15 18 af 11 c0    	mov    0xc011af18,%edx
c0102c63:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102c66:	01 d0                	add    %edx,%eax
c0102c68:	a3 18 af 11 c0       	mov    %eax,0xc011af18
    set_page_ref(base, 0);
c0102c6d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102c74:	00 
c0102c75:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c78:	89 04 24             	mov    %eax,(%esp)
c0102c7b:	e8 03 fc ff ff       	call   c0102883 <set_page_ref>
    if(base+n==p){
c0102c80:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102c83:	89 d0                	mov    %edx,%eax
c0102c85:	c1 e0 02             	shl    $0x2,%eax
c0102c88:	01 d0                	add    %edx,%eax
c0102c8a:	c1 e0 02             	shl    $0x2,%eax
c0102c8d:	89 c2                	mov    %eax,%edx
c0102c8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c92:	01 d0                	add    %edx,%eax
c0102c94:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102c97:	75 1e                	jne    c0102cb7 <default_free_pages+0x11d>
       base->property+=p->property;
c0102c99:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c9c:	8b 50 08             	mov    0x8(%eax),%edx
c0102c9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ca2:	8b 40 08             	mov    0x8(%eax),%eax
c0102ca5:	01 c2                	add    %eax,%edx
c0102ca7:	8b 45 08             	mov    0x8(%ebp),%eax
c0102caa:	89 50 08             	mov    %edx,0x8(%eax)
       p->property=0;
c0102cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102cb0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    }
    for(p=base;p<base+n;p++){
c0102cb7:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cba:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102cbd:	eb 7d                	jmp    c0102d3c <default_free_pages+0x1a2>
       list_add_before(le,&p->page_link);
c0102cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102cc2:	8d 50 0c             	lea    0xc(%eax),%edx
c0102cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102cc8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102ccb:	89 55 d8             	mov    %edx,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0102cce:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102cd1:	8b 00                	mov    (%eax),%eax
c0102cd3:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102cd6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102cd9:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102cdc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102cdf:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102ce2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102ce5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102ce8:	89 10                	mov    %edx,(%eax)
c0102cea:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102ced:	8b 10                	mov    (%eax),%edx
c0102cef:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102cf2:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102cf5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102cf8:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102cfb:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102cfe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102d01:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102d04:	89 10                	mov    %edx,(%eax)
       ClearPageReserved(p);
c0102d06:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d09:	83 c0 04             	add    $0x4,%eax
c0102d0c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
c0102d13:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102d16:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102d19:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102d1c:	0f b3 10             	btr    %edx,(%eax)
       SetPageProperty(p);
c0102d1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d22:	83 c0 04             	add    $0x4,%eax
c0102d25:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0102d2c:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102d2f:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102d32:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102d35:	0f ab 10             	bts    %edx,(%eax)
    set_page_ref(base, 0);
    if(base+n==p){
       base->property+=p->property;
       p->property=0;
    }
    for(p=base;p<base+n;p++){
c0102d38:	83 45 f0 14          	addl   $0x14,-0x10(%ebp)
c0102d3c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102d3f:	89 d0                	mov    %edx,%eax
c0102d41:	c1 e0 02             	shl    $0x2,%eax
c0102d44:	01 d0                	add    %edx,%eax
c0102d46:	c1 e0 02             	shl    $0x2,%eax
c0102d49:	89 c2                	mov    %eax,%edx
c0102d4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d4e:	01 d0                	add    %edx,%eax
c0102d50:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102d53:	0f 87 66 ff ff ff    	ja     c0102cbf <default_free_pages+0x125>
       list_add_before(le,&p->page_link);
       ClearPageReserved(p);
       SetPageProperty(p);
    } 
    le = list_prev(&(base->page_link));
c0102d59:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d5c:	83 c0 0c             	add    $0xc,%eax
c0102d5f:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
c0102d62:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102d65:	8b 00                	mov    (%eax),%eax
c0102d67:	89 45 f4             	mov    %eax,-0xc(%ebp)
    p = le2page(le, page_link);
c0102d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d6d:	83 e8 0c             	sub    $0xc,%eax
c0102d70:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(p==base-1){
c0102d73:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d76:	83 e8 14             	sub    $0x14,%eax
c0102d79:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102d7c:	75 4c                	jne    c0102dca <default_free_pages+0x230>
      while(le!=&free_list){
c0102d7e:	eb 41                	jmp    c0102dc1 <default_free_pages+0x227>
        if(p->property){
c0102d80:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d83:	8b 40 08             	mov    0x8(%eax),%eax
c0102d86:	85 c0                	test   %eax,%eax
c0102d88:	74 20                	je     c0102daa <default_free_pages+0x210>
          p->property += base->property;
c0102d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d8d:	8b 50 08             	mov    0x8(%eax),%edx
c0102d90:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d93:	8b 40 08             	mov    0x8(%eax),%eax
c0102d96:	01 c2                	add    %eax,%edx
c0102d98:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d9b:	89 50 08             	mov    %edx,0x8(%eax)
          base->property = 0;
c0102d9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102da1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          break;
c0102da8:	eb 20                	jmp    c0102dca <default_free_pages+0x230>
c0102daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dad:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0102db0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102db3:	8b 00                	mov    (%eax),%eax
        }
	le=list_prev(le);
c0102db5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	p = le2page(le,page_link);
c0102db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dbb:	83 e8 0c             	sub    $0xc,%eax
c0102dbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
       SetPageProperty(p);
    } 
    le = list_prev(&(base->page_link));
    p = le2page(le, page_link);
    if(p==base-1){
      while(le!=&free_list){
c0102dc1:	81 7d f4 10 af 11 c0 	cmpl   $0xc011af10,-0xc(%ebp)
c0102dc8:	75 b6                	jne    c0102d80 <default_free_pages+0x1e6>
	le=list_prev(le);
	p = le2page(le,page_link);
      }
    }
    //nr_free += n;
    return;
c0102dca:	90                   	nop
}
c0102dcb:	c9                   	leave  
c0102dcc:	c3                   	ret    

c0102dcd <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0102dcd:	55                   	push   %ebp
c0102dce:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0102dd0:	a1 18 af 11 c0       	mov    0xc011af18,%eax
}
c0102dd5:	5d                   	pop    %ebp
c0102dd6:	c3                   	ret    

c0102dd7 <basic_check>:

static void
basic_check(void) {
c0102dd7:	55                   	push   %ebp
c0102dd8:	89 e5                	mov    %esp,%ebp
c0102dda:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0102ddd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102de7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ded:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0102df0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102df7:	e8 9d 0e 00 00       	call   c0103c99 <alloc_pages>
c0102dfc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102dff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0102e03:	75 24                	jne    c0102e29 <basic_check+0x52>
c0102e05:	c7 44 24 0c 24 66 10 	movl   $0xc0106624,0xc(%esp)
c0102e0c:	c0 
c0102e0d:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102e14:	c0 
c0102e15:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0102e1c:	00 
c0102e1d:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102e24:	e8 a9 de ff ff       	call   c0100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0102e29:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102e30:	e8 64 0e 00 00       	call   c0103c99 <alloc_pages>
c0102e35:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102e38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102e3c:	75 24                	jne    c0102e62 <basic_check+0x8b>
c0102e3e:	c7 44 24 0c 40 66 10 	movl   $0xc0106640,0xc(%esp)
c0102e45:	c0 
c0102e46:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102e4d:	c0 
c0102e4e:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0102e55:	00 
c0102e56:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102e5d:	e8 70 de ff ff       	call   c0100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0102e62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102e69:	e8 2b 0e 00 00       	call   c0103c99 <alloc_pages>
c0102e6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102e71:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102e75:	75 24                	jne    c0102e9b <basic_check+0xc4>
c0102e77:	c7 44 24 0c 5c 66 10 	movl   $0xc010665c,0xc(%esp)
c0102e7e:	c0 
c0102e7f:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102e86:	c0 
c0102e87:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c0102e8e:	00 
c0102e8f:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102e96:	e8 37 de ff ff       	call   c0100cd2 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0102e9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102e9e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102ea1:	74 10                	je     c0102eb3 <basic_check+0xdc>
c0102ea3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ea6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102ea9:	74 08                	je     c0102eb3 <basic_check+0xdc>
c0102eab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102eae:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0102eb1:	75 24                	jne    c0102ed7 <basic_check+0x100>
c0102eb3:	c7 44 24 0c 78 66 10 	movl   $0xc0106678,0xc(%esp)
c0102eba:	c0 
c0102ebb:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102ec2:	c0 
c0102ec3:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c0102eca:	00 
c0102ecb:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102ed2:	e8 fb dd ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0102ed7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102eda:	89 04 24             	mov    %eax,(%esp)
c0102edd:	e8 97 f9 ff ff       	call   c0102879 <page_ref>
c0102ee2:	85 c0                	test   %eax,%eax
c0102ee4:	75 1e                	jne    c0102f04 <basic_check+0x12d>
c0102ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ee9:	89 04 24             	mov    %eax,(%esp)
c0102eec:	e8 88 f9 ff ff       	call   c0102879 <page_ref>
c0102ef1:	85 c0                	test   %eax,%eax
c0102ef3:	75 0f                	jne    c0102f04 <basic_check+0x12d>
c0102ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ef8:	89 04 24             	mov    %eax,(%esp)
c0102efb:	e8 79 f9 ff ff       	call   c0102879 <page_ref>
c0102f00:	85 c0                	test   %eax,%eax
c0102f02:	74 24                	je     c0102f28 <basic_check+0x151>
c0102f04:	c7 44 24 0c 9c 66 10 	movl   $0xc010669c,0xc(%esp)
c0102f0b:	c0 
c0102f0c:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102f13:	c0 
c0102f14:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c0102f1b:	00 
c0102f1c:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102f23:	e8 aa dd ff ff       	call   c0100cd2 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0102f28:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102f2b:	89 04 24             	mov    %eax,(%esp)
c0102f2e:	e8 30 f9 ff ff       	call   c0102863 <page2pa>
c0102f33:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0102f39:	c1 e2 0c             	shl    $0xc,%edx
c0102f3c:	39 d0                	cmp    %edx,%eax
c0102f3e:	72 24                	jb     c0102f64 <basic_check+0x18d>
c0102f40:	c7 44 24 0c d8 66 10 	movl   $0xc01066d8,0xc(%esp)
c0102f47:	c0 
c0102f48:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102f4f:	c0 
c0102f50:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0102f57:	00 
c0102f58:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102f5f:	e8 6e dd ff ff       	call   c0100cd2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0102f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f67:	89 04 24             	mov    %eax,(%esp)
c0102f6a:	e8 f4 f8 ff ff       	call   c0102863 <page2pa>
c0102f6f:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0102f75:	c1 e2 0c             	shl    $0xc,%edx
c0102f78:	39 d0                	cmp    %edx,%eax
c0102f7a:	72 24                	jb     c0102fa0 <basic_check+0x1c9>
c0102f7c:	c7 44 24 0c f5 66 10 	movl   $0xc01066f5,0xc(%esp)
c0102f83:	c0 
c0102f84:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102f8b:	c0 
c0102f8c:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c0102f93:	00 
c0102f94:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102f9b:	e8 32 dd ff ff       	call   c0100cd2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0102fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102fa3:	89 04 24             	mov    %eax,(%esp)
c0102fa6:	e8 b8 f8 ff ff       	call   c0102863 <page2pa>
c0102fab:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0102fb1:	c1 e2 0c             	shl    $0xc,%edx
c0102fb4:	39 d0                	cmp    %edx,%eax
c0102fb6:	72 24                	jb     c0102fdc <basic_check+0x205>
c0102fb8:	c7 44 24 0c 12 67 10 	movl   $0xc0106712,0xc(%esp)
c0102fbf:	c0 
c0102fc0:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0102fc7:	c0 
c0102fc8:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c0102fcf:	00 
c0102fd0:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0102fd7:	e8 f6 dc ff ff       	call   c0100cd2 <__panic>

    list_entry_t free_list_store = free_list;
c0102fdc:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c0102fe1:	8b 15 14 af 11 c0    	mov    0xc011af14,%edx
c0102fe7:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102fea:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102fed:	c7 45 e0 10 af 11 c0 	movl   $0xc011af10,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0102ff4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102ff7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102ffa:	89 50 04             	mov    %edx,0x4(%eax)
c0102ffd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103000:	8b 50 04             	mov    0x4(%eax),%edx
c0103003:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103006:	89 10                	mov    %edx,(%eax)
c0103008:	c7 45 dc 10 af 11 c0 	movl   $0xc011af10,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010300f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103012:	8b 40 04             	mov    0x4(%eax),%eax
c0103015:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103018:	0f 94 c0             	sete   %al
c010301b:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010301e:	85 c0                	test   %eax,%eax
c0103020:	75 24                	jne    c0103046 <basic_check+0x26f>
c0103022:	c7 44 24 0c 2f 67 10 	movl   $0xc010672f,0xc(%esp)
c0103029:	c0 
c010302a:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103031:	c0 
c0103032:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c0103039:	00 
c010303a:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103041:	e8 8c dc ff ff       	call   c0100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
c0103046:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c010304b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c010304e:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c0103055:	00 00 00 

    assert(alloc_page() == NULL);
c0103058:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010305f:	e8 35 0c 00 00       	call   c0103c99 <alloc_pages>
c0103064:	85 c0                	test   %eax,%eax
c0103066:	74 24                	je     c010308c <basic_check+0x2b5>
c0103068:	c7 44 24 0c 46 67 10 	movl   $0xc0106746,0xc(%esp)
c010306f:	c0 
c0103070:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103077:	c0 
c0103078:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c010307f:	00 
c0103080:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103087:	e8 46 dc ff ff       	call   c0100cd2 <__panic>

    free_page(p0);
c010308c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103093:	00 
c0103094:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103097:	89 04 24             	mov    %eax,(%esp)
c010309a:	e8 32 0c 00 00       	call   c0103cd1 <free_pages>
    free_page(p1);
c010309f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01030a6:	00 
c01030a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01030aa:	89 04 24             	mov    %eax,(%esp)
c01030ad:	e8 1f 0c 00 00       	call   c0103cd1 <free_pages>
    free_page(p2);
c01030b2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01030b9:	00 
c01030ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01030bd:	89 04 24             	mov    %eax,(%esp)
c01030c0:	e8 0c 0c 00 00       	call   c0103cd1 <free_pages>
    assert(nr_free == 3);
c01030c5:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c01030ca:	83 f8 03             	cmp    $0x3,%eax
c01030cd:	74 24                	je     c01030f3 <basic_check+0x31c>
c01030cf:	c7 44 24 0c 5b 67 10 	movl   $0xc010675b,0xc(%esp)
c01030d6:	c0 
c01030d7:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01030de:	c0 
c01030df:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c01030e6:	00 
c01030e7:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01030ee:	e8 df db ff ff       	call   c0100cd2 <__panic>

    assert((p0 = alloc_page()) != NULL);
c01030f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01030fa:	e8 9a 0b 00 00       	call   c0103c99 <alloc_pages>
c01030ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103102:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103106:	75 24                	jne    c010312c <basic_check+0x355>
c0103108:	c7 44 24 0c 24 66 10 	movl   $0xc0106624,0xc(%esp)
c010310f:	c0 
c0103110:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103117:	c0 
c0103118:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c010311f:	00 
c0103120:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103127:	e8 a6 db ff ff       	call   c0100cd2 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010312c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103133:	e8 61 0b 00 00       	call   c0103c99 <alloc_pages>
c0103138:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010313b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010313f:	75 24                	jne    c0103165 <basic_check+0x38e>
c0103141:	c7 44 24 0c 40 66 10 	movl   $0xc0106640,0xc(%esp)
c0103148:	c0 
c0103149:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103150:	c0 
c0103151:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
c0103158:	00 
c0103159:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103160:	e8 6d db ff ff       	call   c0100cd2 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0103165:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010316c:	e8 28 0b 00 00       	call   c0103c99 <alloc_pages>
c0103171:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103174:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103178:	75 24                	jne    c010319e <basic_check+0x3c7>
c010317a:	c7 44 24 0c 5c 66 10 	movl   $0xc010665c,0xc(%esp)
c0103181:	c0 
c0103182:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103189:	c0 
c010318a:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c0103191:	00 
c0103192:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103199:	e8 34 db ff ff       	call   c0100cd2 <__panic>

    assert(alloc_page() == NULL);
c010319e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01031a5:	e8 ef 0a 00 00       	call   c0103c99 <alloc_pages>
c01031aa:	85 c0                	test   %eax,%eax
c01031ac:	74 24                	je     c01031d2 <basic_check+0x3fb>
c01031ae:	c7 44 24 0c 46 67 10 	movl   $0xc0106746,0xc(%esp)
c01031b5:	c0 
c01031b6:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01031bd:	c0 
c01031be:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c01031c5:	00 
c01031c6:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01031cd:	e8 00 db ff ff       	call   c0100cd2 <__panic>

    free_page(p0);
c01031d2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01031d9:	00 
c01031da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01031dd:	89 04 24             	mov    %eax,(%esp)
c01031e0:	e8 ec 0a 00 00       	call   c0103cd1 <free_pages>
c01031e5:	c7 45 d8 10 af 11 c0 	movl   $0xc011af10,-0x28(%ebp)
c01031ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01031ef:	8b 40 04             	mov    0x4(%eax),%eax
c01031f2:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01031f5:	0f 94 c0             	sete   %al
c01031f8:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c01031fb:	85 c0                	test   %eax,%eax
c01031fd:	74 24                	je     c0103223 <basic_check+0x44c>
c01031ff:	c7 44 24 0c 68 67 10 	movl   $0xc0106768,0xc(%esp)
c0103206:	c0 
c0103207:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010320e:	c0 
c010320f:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c0103216:	00 
c0103217:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010321e:	e8 af da ff ff       	call   c0100cd2 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103223:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010322a:	e8 6a 0a 00 00       	call   c0103c99 <alloc_pages>
c010322f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103232:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103235:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103238:	74 24                	je     c010325e <basic_check+0x487>
c010323a:	c7 44 24 0c 80 67 10 	movl   $0xc0106780,0xc(%esp)
c0103241:	c0 
c0103242:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103249:	c0 
c010324a:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0103251:	00 
c0103252:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103259:	e8 74 da ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c010325e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103265:	e8 2f 0a 00 00       	call   c0103c99 <alloc_pages>
c010326a:	85 c0                	test   %eax,%eax
c010326c:	74 24                	je     c0103292 <basic_check+0x4bb>
c010326e:	c7 44 24 0c 46 67 10 	movl   $0xc0106746,0xc(%esp)
c0103275:	c0 
c0103276:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010327d:	c0 
c010327e:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0103285:	00 
c0103286:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010328d:	e8 40 da ff ff       	call   c0100cd2 <__panic>

    assert(nr_free == 0);
c0103292:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c0103297:	85 c0                	test   %eax,%eax
c0103299:	74 24                	je     c01032bf <basic_check+0x4e8>
c010329b:	c7 44 24 0c 99 67 10 	movl   $0xc0106799,0xc(%esp)
c01032a2:	c0 
c01032a3:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01032aa:	c0 
c01032ab:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c01032b2:	00 
c01032b3:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01032ba:	e8 13 da ff ff       	call   c0100cd2 <__panic>
    free_list = free_list_store;
c01032bf:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01032c2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01032c5:	a3 10 af 11 c0       	mov    %eax,0xc011af10
c01032ca:	89 15 14 af 11 c0    	mov    %edx,0xc011af14
    nr_free = nr_free_store;
c01032d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01032d3:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    free_page(p);
c01032d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01032df:	00 
c01032e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01032e3:	89 04 24             	mov    %eax,(%esp)
c01032e6:	e8 e6 09 00 00       	call   c0103cd1 <free_pages>
    free_page(p1);
c01032eb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01032f2:	00 
c01032f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032f6:	89 04 24             	mov    %eax,(%esp)
c01032f9:	e8 d3 09 00 00       	call   c0103cd1 <free_pages>
    free_page(p2);
c01032fe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103305:	00 
c0103306:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103309:	89 04 24             	mov    %eax,(%esp)
c010330c:	e8 c0 09 00 00       	call   c0103cd1 <free_pages>
}
c0103311:	c9                   	leave  
c0103312:	c3                   	ret    

c0103313 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0103313:	55                   	push   %ebp
c0103314:	89 e5                	mov    %esp,%ebp
c0103316:	53                   	push   %ebx
c0103317:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c010331d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103324:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c010332b:	c7 45 ec 10 af 11 c0 	movl   $0xc011af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103332:	eb 6b                	jmp    c010339f <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0103334:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103337:	83 e8 0c             	sub    $0xc,%eax
c010333a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c010333d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103340:	83 c0 04             	add    $0x4,%eax
c0103343:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c010334a:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010334d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0103350:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103353:	0f a3 10             	bt     %edx,(%eax)
c0103356:	19 c0                	sbb    %eax,%eax
c0103358:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c010335b:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010335f:	0f 95 c0             	setne  %al
c0103362:	0f b6 c0             	movzbl %al,%eax
c0103365:	85 c0                	test   %eax,%eax
c0103367:	75 24                	jne    c010338d <default_check+0x7a>
c0103369:	c7 44 24 0c a6 67 10 	movl   $0xc01067a6,0xc(%esp)
c0103370:	c0 
c0103371:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103378:	c0 
c0103379:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0103380:	00 
c0103381:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103388:	e8 45 d9 ff ff       	call   c0100cd2 <__panic>
        count ++, total += p->property;
c010338d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103391:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103394:	8b 50 08             	mov    0x8(%eax),%edx
c0103397:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010339a:	01 d0                	add    %edx,%eax
c010339c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010339f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01033a2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01033a5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01033a8:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01033ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01033ae:	81 7d ec 10 af 11 c0 	cmpl   $0xc011af10,-0x14(%ebp)
c01033b5:	0f 85 79 ff ff ff    	jne    c0103334 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c01033bb:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c01033be:	e8 40 09 00 00       	call   c0103d03 <nr_free_pages>
c01033c3:	39 c3                	cmp    %eax,%ebx
c01033c5:	74 24                	je     c01033eb <default_check+0xd8>
c01033c7:	c7 44 24 0c b6 67 10 	movl   $0xc01067b6,0xc(%esp)
c01033ce:	c0 
c01033cf:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01033d6:	c0 
c01033d7:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c01033de:	00 
c01033df:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01033e6:	e8 e7 d8 ff ff       	call   c0100cd2 <__panic>

    basic_check();
c01033eb:	e8 e7 f9 ff ff       	call   c0102dd7 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c01033f0:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01033f7:	e8 9d 08 00 00       	call   c0103c99 <alloc_pages>
c01033fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c01033ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103403:	75 24                	jne    c0103429 <default_check+0x116>
c0103405:	c7 44 24 0c cf 67 10 	movl   $0xc01067cf,0xc(%esp)
c010340c:	c0 
c010340d:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103414:	c0 
c0103415:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c010341c:	00 
c010341d:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103424:	e8 a9 d8 ff ff       	call   c0100cd2 <__panic>
    assert(!PageProperty(p0));
c0103429:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010342c:	83 c0 04             	add    $0x4,%eax
c010342f:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0103436:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103439:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010343c:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010343f:	0f a3 10             	bt     %edx,(%eax)
c0103442:	19 c0                	sbb    %eax,%eax
c0103444:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0103447:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c010344b:	0f 95 c0             	setne  %al
c010344e:	0f b6 c0             	movzbl %al,%eax
c0103451:	85 c0                	test   %eax,%eax
c0103453:	74 24                	je     c0103479 <default_check+0x166>
c0103455:	c7 44 24 0c da 67 10 	movl   $0xc01067da,0xc(%esp)
c010345c:	c0 
c010345d:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103464:	c0 
c0103465:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c010346c:	00 
c010346d:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103474:	e8 59 d8 ff ff       	call   c0100cd2 <__panic>

    list_entry_t free_list_store = free_list;
c0103479:	a1 10 af 11 c0       	mov    0xc011af10,%eax
c010347e:	8b 15 14 af 11 c0    	mov    0xc011af14,%edx
c0103484:	89 45 80             	mov    %eax,-0x80(%ebp)
c0103487:	89 55 84             	mov    %edx,-0x7c(%ebp)
c010348a:	c7 45 b4 10 af 11 c0 	movl   $0xc011af10,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0103491:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103494:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103497:	89 50 04             	mov    %edx,0x4(%eax)
c010349a:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010349d:	8b 50 04             	mov    0x4(%eax),%edx
c01034a0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01034a3:	89 10                	mov    %edx,(%eax)
c01034a5:	c7 45 b0 10 af 11 c0 	movl   $0xc011af10,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01034ac:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01034af:	8b 40 04             	mov    0x4(%eax),%eax
c01034b2:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c01034b5:	0f 94 c0             	sete   %al
c01034b8:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01034bb:	85 c0                	test   %eax,%eax
c01034bd:	75 24                	jne    c01034e3 <default_check+0x1d0>
c01034bf:	c7 44 24 0c 2f 67 10 	movl   $0xc010672f,0xc(%esp)
c01034c6:	c0 
c01034c7:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01034ce:	c0 
c01034cf:	c7 44 24 04 2d 01 00 	movl   $0x12d,0x4(%esp)
c01034d6:	00 
c01034d7:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01034de:	e8 ef d7 ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c01034e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01034ea:	e8 aa 07 00 00       	call   c0103c99 <alloc_pages>
c01034ef:	85 c0                	test   %eax,%eax
c01034f1:	74 24                	je     c0103517 <default_check+0x204>
c01034f3:	c7 44 24 0c 46 67 10 	movl   $0xc0106746,0xc(%esp)
c01034fa:	c0 
c01034fb:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103502:	c0 
c0103503:	c7 44 24 04 2e 01 00 	movl   $0x12e,0x4(%esp)
c010350a:	00 
c010350b:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103512:	e8 bb d7 ff ff       	call   c0100cd2 <__panic>

    unsigned int nr_free_store = nr_free;
c0103517:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c010351c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c010351f:	c7 05 18 af 11 c0 00 	movl   $0x0,0xc011af18
c0103526:	00 00 00 

    free_pages(p0 + 2, 3);
c0103529:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010352c:	83 c0 28             	add    $0x28,%eax
c010352f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0103536:	00 
c0103537:	89 04 24             	mov    %eax,(%esp)
c010353a:	e8 92 07 00 00       	call   c0103cd1 <free_pages>
    assert(alloc_pages(4) == NULL);
c010353f:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0103546:	e8 4e 07 00 00       	call   c0103c99 <alloc_pages>
c010354b:	85 c0                	test   %eax,%eax
c010354d:	74 24                	je     c0103573 <default_check+0x260>
c010354f:	c7 44 24 0c ec 67 10 	movl   $0xc01067ec,0xc(%esp)
c0103556:	c0 
c0103557:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010355e:	c0 
c010355f:	c7 44 24 04 34 01 00 	movl   $0x134,0x4(%esp)
c0103566:	00 
c0103567:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010356e:	e8 5f d7 ff ff       	call   c0100cd2 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0103573:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103576:	83 c0 28             	add    $0x28,%eax
c0103579:	83 c0 04             	add    $0x4,%eax
c010357c:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c0103583:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103586:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103589:	8b 55 ac             	mov    -0x54(%ebp),%edx
c010358c:	0f a3 10             	bt     %edx,(%eax)
c010358f:	19 c0                	sbb    %eax,%eax
c0103591:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c0103594:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c0103598:	0f 95 c0             	setne  %al
c010359b:	0f b6 c0             	movzbl %al,%eax
c010359e:	85 c0                	test   %eax,%eax
c01035a0:	74 0e                	je     c01035b0 <default_check+0x29d>
c01035a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01035a5:	83 c0 28             	add    $0x28,%eax
c01035a8:	8b 40 08             	mov    0x8(%eax),%eax
c01035ab:	83 f8 03             	cmp    $0x3,%eax
c01035ae:	74 24                	je     c01035d4 <default_check+0x2c1>
c01035b0:	c7 44 24 0c 04 68 10 	movl   $0xc0106804,0xc(%esp)
c01035b7:	c0 
c01035b8:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01035bf:	c0 
c01035c0:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
c01035c7:	00 
c01035c8:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01035cf:	e8 fe d6 ff ff       	call   c0100cd2 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01035d4:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c01035db:	e8 b9 06 00 00       	call   c0103c99 <alloc_pages>
c01035e0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01035e3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01035e7:	75 24                	jne    c010360d <default_check+0x2fa>
c01035e9:	c7 44 24 0c 30 68 10 	movl   $0xc0106830,0xc(%esp)
c01035f0:	c0 
c01035f1:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01035f8:	c0 
c01035f9:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c0103600:	00 
c0103601:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103608:	e8 c5 d6 ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c010360d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103614:	e8 80 06 00 00       	call   c0103c99 <alloc_pages>
c0103619:	85 c0                	test   %eax,%eax
c010361b:	74 24                	je     c0103641 <default_check+0x32e>
c010361d:	c7 44 24 0c 46 67 10 	movl   $0xc0106746,0xc(%esp)
c0103624:	c0 
c0103625:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010362c:	c0 
c010362d:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c0103634:	00 
c0103635:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010363c:	e8 91 d6 ff ff       	call   c0100cd2 <__panic>
    assert(p0 + 2 == p1);
c0103641:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103644:	83 c0 28             	add    $0x28,%eax
c0103647:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010364a:	74 24                	je     c0103670 <default_check+0x35d>
c010364c:	c7 44 24 0c 4e 68 10 	movl   $0xc010684e,0xc(%esp)
c0103653:	c0 
c0103654:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010365b:	c0 
c010365c:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
c0103663:	00 
c0103664:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010366b:	e8 62 d6 ff ff       	call   c0100cd2 <__panic>

    p2 = p0 + 1;
c0103670:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103673:	83 c0 14             	add    $0x14,%eax
c0103676:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c0103679:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103680:	00 
c0103681:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103684:	89 04 24             	mov    %eax,(%esp)
c0103687:	e8 45 06 00 00       	call   c0103cd1 <free_pages>
    free_pages(p1, 3);
c010368c:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0103693:	00 
c0103694:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103697:	89 04 24             	mov    %eax,(%esp)
c010369a:	e8 32 06 00 00       	call   c0103cd1 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c010369f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01036a2:	83 c0 04             	add    $0x4,%eax
c01036a5:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01036ac:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036af:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01036b2:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01036b5:	0f a3 10             	bt     %edx,(%eax)
c01036b8:	19 c0                	sbb    %eax,%eax
c01036ba:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01036bd:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01036c1:	0f 95 c0             	setne  %al
c01036c4:	0f b6 c0             	movzbl %al,%eax
c01036c7:	85 c0                	test   %eax,%eax
c01036c9:	74 0b                	je     c01036d6 <default_check+0x3c3>
c01036cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01036ce:	8b 40 08             	mov    0x8(%eax),%eax
c01036d1:	83 f8 01             	cmp    $0x1,%eax
c01036d4:	74 24                	je     c01036fa <default_check+0x3e7>
c01036d6:	c7 44 24 0c 5c 68 10 	movl   $0xc010685c,0xc(%esp)
c01036dd:	c0 
c01036de:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01036e5:	c0 
c01036e6:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
c01036ed:	00 
c01036ee:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01036f5:	e8 d8 d5 ff ff       	call   c0100cd2 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01036fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01036fd:	83 c0 04             	add    $0x4,%eax
c0103700:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0103707:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010370a:	8b 45 90             	mov    -0x70(%ebp),%eax
c010370d:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0103710:	0f a3 10             	bt     %edx,(%eax)
c0103713:	19 c0                	sbb    %eax,%eax
c0103715:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0103718:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c010371c:	0f 95 c0             	setne  %al
c010371f:	0f b6 c0             	movzbl %al,%eax
c0103722:	85 c0                	test   %eax,%eax
c0103724:	74 0b                	je     c0103731 <default_check+0x41e>
c0103726:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103729:	8b 40 08             	mov    0x8(%eax),%eax
c010372c:	83 f8 03             	cmp    $0x3,%eax
c010372f:	74 24                	je     c0103755 <default_check+0x442>
c0103731:	c7 44 24 0c 84 68 10 	movl   $0xc0106884,0xc(%esp)
c0103738:	c0 
c0103739:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103740:	c0 
c0103741:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c0103748:	00 
c0103749:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103750:	e8 7d d5 ff ff       	call   c0100cd2 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0103755:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010375c:	e8 38 05 00 00       	call   c0103c99 <alloc_pages>
c0103761:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103764:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103767:	83 e8 14             	sub    $0x14,%eax
c010376a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010376d:	74 24                	je     c0103793 <default_check+0x480>
c010376f:	c7 44 24 0c aa 68 10 	movl   $0xc01068aa,0xc(%esp)
c0103776:	c0 
c0103777:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010377e:	c0 
c010377f:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
c0103786:	00 
c0103787:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010378e:	e8 3f d5 ff ff       	call   c0100cd2 <__panic>
    free_page(p0);
c0103793:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010379a:	00 
c010379b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010379e:	89 04 24             	mov    %eax,(%esp)
c01037a1:	e8 2b 05 00 00       	call   c0103cd1 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01037a6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01037ad:	e8 e7 04 00 00       	call   c0103c99 <alloc_pages>
c01037b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01037b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01037b8:	83 c0 14             	add    $0x14,%eax
c01037bb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01037be:	74 24                	je     c01037e4 <default_check+0x4d1>
c01037c0:	c7 44 24 0c c8 68 10 	movl   $0xc01068c8,0xc(%esp)
c01037c7:	c0 
c01037c8:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c01037cf:	c0 
c01037d0:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
c01037d7:	00 
c01037d8:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c01037df:	e8 ee d4 ff ff       	call   c0100cd2 <__panic>

    free_pages(p0, 2);
c01037e4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01037eb:	00 
c01037ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01037ef:	89 04 24             	mov    %eax,(%esp)
c01037f2:	e8 da 04 00 00       	call   c0103cd1 <free_pages>
    free_page(p2);
c01037f7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01037fe:	00 
c01037ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103802:	89 04 24             	mov    %eax,(%esp)
c0103805:	e8 c7 04 00 00       	call   c0103cd1 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c010380a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103811:	e8 83 04 00 00       	call   c0103c99 <alloc_pages>
c0103816:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103819:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010381d:	75 24                	jne    c0103843 <default_check+0x530>
c010381f:	c7 44 24 0c e8 68 10 	movl   $0xc01068e8,0xc(%esp)
c0103826:	c0 
c0103827:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010382e:	c0 
c010382f:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
c0103836:	00 
c0103837:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010383e:	e8 8f d4 ff ff       	call   c0100cd2 <__panic>
    assert(alloc_page() == NULL);
c0103843:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010384a:	e8 4a 04 00 00       	call   c0103c99 <alloc_pages>
c010384f:	85 c0                	test   %eax,%eax
c0103851:	74 24                	je     c0103877 <default_check+0x564>
c0103853:	c7 44 24 0c 46 67 10 	movl   $0xc0106746,0xc(%esp)
c010385a:	c0 
c010385b:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103862:	c0 
c0103863:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
c010386a:	00 
c010386b:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103872:	e8 5b d4 ff ff       	call   c0100cd2 <__panic>

    assert(nr_free == 0);
c0103877:	a1 18 af 11 c0       	mov    0xc011af18,%eax
c010387c:	85 c0                	test   %eax,%eax
c010387e:	74 24                	je     c01038a4 <default_check+0x591>
c0103880:	c7 44 24 0c 99 67 10 	movl   $0xc0106799,0xc(%esp)
c0103887:	c0 
c0103888:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010388f:	c0 
c0103890:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
c0103897:	00 
c0103898:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010389f:	e8 2e d4 ff ff       	call   c0100cd2 <__panic>
    nr_free = nr_free_store;
c01038a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01038a7:	a3 18 af 11 c0       	mov    %eax,0xc011af18

    free_list = free_list_store;
c01038ac:	8b 45 80             	mov    -0x80(%ebp),%eax
c01038af:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01038b2:	a3 10 af 11 c0       	mov    %eax,0xc011af10
c01038b7:	89 15 14 af 11 c0    	mov    %edx,0xc011af14
    free_pages(p0, 5);
c01038bd:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01038c4:	00 
c01038c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01038c8:	89 04 24             	mov    %eax,(%esp)
c01038cb:	e8 01 04 00 00       	call   c0103cd1 <free_pages>

    le = &free_list;
c01038d0:	c7 45 ec 10 af 11 c0 	movl   $0xc011af10,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01038d7:	eb 1d                	jmp    c01038f6 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c01038d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01038dc:	83 e8 0c             	sub    $0xc,%eax
c01038df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c01038e2:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01038e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01038e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01038ec:	8b 40 08             	mov    0x8(%eax),%eax
c01038ef:	29 c2                	sub    %eax,%edx
c01038f1:	89 d0                	mov    %edx,%eax
c01038f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01038f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01038f9:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01038fc:	8b 45 88             	mov    -0x78(%ebp),%eax
c01038ff:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0103902:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103905:	81 7d ec 10 af 11 c0 	cmpl   $0xc011af10,-0x14(%ebp)
c010390c:	75 cb                	jne    c01038d9 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c010390e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103912:	74 24                	je     c0103938 <default_check+0x625>
c0103914:	c7 44 24 0c 06 69 10 	movl   $0xc0106906,0xc(%esp)
c010391b:	c0 
c010391c:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c0103923:	c0 
c0103924:	c7 44 24 04 55 01 00 	movl   $0x155,0x4(%esp)
c010392b:	00 
c010392c:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c0103933:	e8 9a d3 ff ff       	call   c0100cd2 <__panic>
    assert(total == 0);
c0103938:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010393c:	74 24                	je     c0103962 <default_check+0x64f>
c010393e:	c7 44 24 0c 11 69 10 	movl   $0xc0106911,0xc(%esp)
c0103945:	c0 
c0103946:	c7 44 24 08 d6 65 10 	movl   $0xc01065d6,0x8(%esp)
c010394d:	c0 
c010394e:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
c0103955:	00 
c0103956:	c7 04 24 eb 65 10 c0 	movl   $0xc01065eb,(%esp)
c010395d:	e8 70 d3 ff ff       	call   c0100cd2 <__panic>
}
c0103962:	81 c4 94 00 00 00    	add    $0x94,%esp
c0103968:	5b                   	pop    %ebx
c0103969:	5d                   	pop    %ebp
c010396a:	c3                   	ret    

c010396b <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c010396b:	55                   	push   %ebp
c010396c:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010396e:	8b 55 08             	mov    0x8(%ebp),%edx
c0103971:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0103976:	29 c2                	sub    %eax,%edx
c0103978:	89 d0                	mov    %edx,%eax
c010397a:	c1 f8 02             	sar    $0x2,%eax
c010397d:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103983:	5d                   	pop    %ebp
c0103984:	c3                   	ret    

c0103985 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0103985:	55                   	push   %ebp
c0103986:	89 e5                	mov    %esp,%ebp
c0103988:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c010398b:	8b 45 08             	mov    0x8(%ebp),%eax
c010398e:	89 04 24             	mov    %eax,(%esp)
c0103991:	e8 d5 ff ff ff       	call   c010396b <page2ppn>
c0103996:	c1 e0 0c             	shl    $0xc,%eax
}
c0103999:	c9                   	leave  
c010399a:	c3                   	ret    

c010399b <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c010399b:	55                   	push   %ebp
c010399c:	89 e5                	mov    %esp,%ebp
c010399e:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01039a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01039a4:	c1 e8 0c             	shr    $0xc,%eax
c01039a7:	89 c2                	mov    %eax,%edx
c01039a9:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01039ae:	39 c2                	cmp    %eax,%edx
c01039b0:	72 1c                	jb     c01039ce <pa2page+0x33>
        panic("pa2page called with invalid pa");
c01039b2:	c7 44 24 08 4c 69 10 	movl   $0xc010694c,0x8(%esp)
c01039b9:	c0 
c01039ba:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c01039c1:	00 
c01039c2:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01039c9:	e8 04 d3 ff ff       	call   c0100cd2 <__panic>
    }
    return &pages[PPN(pa)];
c01039ce:	8b 0d 24 af 11 c0    	mov    0xc011af24,%ecx
c01039d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01039d7:	c1 e8 0c             	shr    $0xc,%eax
c01039da:	89 c2                	mov    %eax,%edx
c01039dc:	89 d0                	mov    %edx,%eax
c01039de:	c1 e0 02             	shl    $0x2,%eax
c01039e1:	01 d0                	add    %edx,%eax
c01039e3:	c1 e0 02             	shl    $0x2,%eax
c01039e6:	01 c8                	add    %ecx,%eax
}
c01039e8:	c9                   	leave  
c01039e9:	c3                   	ret    

c01039ea <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01039ea:	55                   	push   %ebp
c01039eb:	89 e5                	mov    %esp,%ebp
c01039ed:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01039f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01039f3:	89 04 24             	mov    %eax,(%esp)
c01039f6:	e8 8a ff ff ff       	call   c0103985 <page2pa>
c01039fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01039fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a01:	c1 e8 0c             	shr    $0xc,%eax
c0103a04:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a07:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103a0c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103a0f:	72 23                	jb     c0103a34 <page2kva+0x4a>
c0103a11:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a14:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103a18:	c7 44 24 08 7c 69 10 	movl   $0xc010697c,0x8(%esp)
c0103a1f:	c0 
c0103a20:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0103a27:	00 
c0103a28:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103a2f:	e8 9e d2 ff ff       	call   c0100cd2 <__panic>
c0103a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a37:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103a3c:	c9                   	leave  
c0103a3d:	c3                   	ret    

c0103a3e <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0103a3e:	55                   	push   %ebp
c0103a3f:	89 e5                	mov    %esp,%ebp
c0103a41:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103a44:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a47:	83 e0 01             	and    $0x1,%eax
c0103a4a:	85 c0                	test   %eax,%eax
c0103a4c:	75 1c                	jne    c0103a6a <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103a4e:	c7 44 24 08 a0 69 10 	movl   $0xc01069a0,0x8(%esp)
c0103a55:	c0 
c0103a56:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103a5d:	00 
c0103a5e:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103a65:	e8 68 d2 ff ff       	call   c0100cd2 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0103a6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a6d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103a72:	89 04 24             	mov    %eax,(%esp)
c0103a75:	e8 21 ff ff ff       	call   c010399b <pa2page>
}
c0103a7a:	c9                   	leave  
c0103a7b:	c3                   	ret    

c0103a7c <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0103a7c:	55                   	push   %ebp
c0103a7d:	89 e5                	mov    %esp,%ebp
c0103a7f:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0103a82:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a85:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103a8a:	89 04 24             	mov    %eax,(%esp)
c0103a8d:	e8 09 ff ff ff       	call   c010399b <pa2page>
}
c0103a92:	c9                   	leave  
c0103a93:	c3                   	ret    

c0103a94 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0103a94:	55                   	push   %ebp
c0103a95:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103a97:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a9a:	8b 00                	mov    (%eax),%eax
}
c0103a9c:	5d                   	pop    %ebp
c0103a9d:	c3                   	ret    

c0103a9e <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103a9e:	55                   	push   %ebp
c0103a9f:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103aa1:	8b 45 08             	mov    0x8(%ebp),%eax
c0103aa4:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103aa7:	89 10                	mov    %edx,(%eax)
}
c0103aa9:	5d                   	pop    %ebp
c0103aaa:	c3                   	ret    

c0103aab <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103aab:	55                   	push   %ebp
c0103aac:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103aae:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ab1:	8b 00                	mov    (%eax),%eax
c0103ab3:	8d 50 01             	lea    0x1(%eax),%edx
c0103ab6:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ab9:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103abb:	8b 45 08             	mov    0x8(%ebp),%eax
c0103abe:	8b 00                	mov    (%eax),%eax
}
c0103ac0:	5d                   	pop    %ebp
c0103ac1:	c3                   	ret    

c0103ac2 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103ac2:	55                   	push   %ebp
c0103ac3:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103ac5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ac8:	8b 00                	mov    (%eax),%eax
c0103aca:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103acd:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ad0:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103ad2:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ad5:	8b 00                	mov    (%eax),%eax
}
c0103ad7:	5d                   	pop    %ebp
c0103ad8:	c3                   	ret    

c0103ad9 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0103ad9:	55                   	push   %ebp
c0103ada:	89 e5                	mov    %esp,%ebp
c0103adc:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103adf:	9c                   	pushf  
c0103ae0:	58                   	pop    %eax
c0103ae1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103ae7:	25 00 02 00 00       	and    $0x200,%eax
c0103aec:	85 c0                	test   %eax,%eax
c0103aee:	74 0c                	je     c0103afc <__intr_save+0x23>
        intr_disable();
c0103af0:	e8 d1 db ff ff       	call   c01016c6 <intr_disable>
        return 1;
c0103af5:	b8 01 00 00 00       	mov    $0x1,%eax
c0103afa:	eb 05                	jmp    c0103b01 <__intr_save+0x28>
    }
    return 0;
c0103afc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103b01:	c9                   	leave  
c0103b02:	c3                   	ret    

c0103b03 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0103b03:	55                   	push   %ebp
c0103b04:	89 e5                	mov    %esp,%ebp
c0103b06:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0103b09:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103b0d:	74 05                	je     c0103b14 <__intr_restore+0x11>
        intr_enable();
c0103b0f:	e8 ac db ff ff       	call   c01016c0 <intr_enable>
    }
}
c0103b14:	c9                   	leave  
c0103b15:	c3                   	ret    

c0103b16 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103b16:	55                   	push   %ebp
c0103b17:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0103b19:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b1c:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103b1f:	b8 23 00 00 00       	mov    $0x23,%eax
c0103b24:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103b26:	b8 23 00 00 00       	mov    $0x23,%eax
c0103b2b:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0103b2d:	b8 10 00 00 00       	mov    $0x10,%eax
c0103b32:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103b34:	b8 10 00 00 00       	mov    $0x10,%eax
c0103b39:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0103b3b:	b8 10 00 00 00       	mov    $0x10,%eax
c0103b40:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103b42:	ea 49 3b 10 c0 08 00 	ljmp   $0x8,$0xc0103b49
}
c0103b49:	5d                   	pop    %ebp
c0103b4a:	c3                   	ret    

c0103b4b <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0103b4b:	55                   	push   %ebp
c0103b4c:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103b4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103b51:	a3 a4 ae 11 c0       	mov    %eax,0xc011aea4
}
c0103b56:	5d                   	pop    %ebp
c0103b57:	c3                   	ret    

c0103b58 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0103b58:	55                   	push   %ebp
c0103b59:	89 e5                	mov    %esp,%ebp
c0103b5b:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103b5e:	b8 00 70 11 c0       	mov    $0xc0117000,%eax
c0103b63:	89 04 24             	mov    %eax,(%esp)
c0103b66:	e8 e0 ff ff ff       	call   c0103b4b <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103b6b:	66 c7 05 a8 ae 11 c0 	movw   $0x10,0xc011aea8
c0103b72:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103b74:	66 c7 05 28 7a 11 c0 	movw   $0x68,0xc0117a28
c0103b7b:	68 00 
c0103b7d:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103b82:	66 a3 2a 7a 11 c0    	mov    %ax,0xc0117a2a
c0103b88:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103b8d:	c1 e8 10             	shr    $0x10,%eax
c0103b90:	a2 2c 7a 11 c0       	mov    %al,0xc0117a2c
c0103b95:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103b9c:	83 e0 f0             	and    $0xfffffff0,%eax
c0103b9f:	83 c8 09             	or     $0x9,%eax
c0103ba2:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103ba7:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103bae:	83 e0 ef             	and    $0xffffffef,%eax
c0103bb1:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103bb6:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103bbd:	83 e0 9f             	and    $0xffffff9f,%eax
c0103bc0:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103bc5:	0f b6 05 2d 7a 11 c0 	movzbl 0xc0117a2d,%eax
c0103bcc:	83 c8 80             	or     $0xffffff80,%eax
c0103bcf:	a2 2d 7a 11 c0       	mov    %al,0xc0117a2d
c0103bd4:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103bdb:	83 e0 f0             	and    $0xfffffff0,%eax
c0103bde:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103be3:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103bea:	83 e0 ef             	and    $0xffffffef,%eax
c0103bed:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103bf2:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103bf9:	83 e0 df             	and    $0xffffffdf,%eax
c0103bfc:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103c01:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103c08:	83 c8 40             	or     $0x40,%eax
c0103c0b:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103c10:	0f b6 05 2e 7a 11 c0 	movzbl 0xc0117a2e,%eax
c0103c17:	83 e0 7f             	and    $0x7f,%eax
c0103c1a:	a2 2e 7a 11 c0       	mov    %al,0xc0117a2e
c0103c1f:	b8 a0 ae 11 c0       	mov    $0xc011aea0,%eax
c0103c24:	c1 e8 18             	shr    $0x18,%eax
c0103c27:	a2 2f 7a 11 c0       	mov    %al,0xc0117a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103c2c:	c7 04 24 30 7a 11 c0 	movl   $0xc0117a30,(%esp)
c0103c33:	e8 de fe ff ff       	call   c0103b16 <lgdt>
c0103c38:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0103c3e:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103c42:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0103c45:	c9                   	leave  
c0103c46:	c3                   	ret    

c0103c47 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0103c47:	55                   	push   %ebp
c0103c48:	89 e5                	mov    %esp,%ebp
c0103c4a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103c4d:	c7 05 1c af 11 c0 30 	movl   $0xc0106930,0xc011af1c
c0103c54:	69 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0103c57:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103c5c:	8b 00                	mov    (%eax),%eax
c0103c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103c62:	c7 04 24 cc 69 10 c0 	movl   $0xc01069cc,(%esp)
c0103c69:	e8 da c6 ff ff       	call   c0100348 <cprintf>
    pmm_manager->init();
c0103c6e:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103c73:	8b 40 04             	mov    0x4(%eax),%eax
c0103c76:	ff d0                	call   *%eax
}
c0103c78:	c9                   	leave  
c0103c79:	c3                   	ret    

c0103c7a <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0103c7a:	55                   	push   %ebp
c0103c7b:	89 e5                	mov    %esp,%ebp
c0103c7d:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0103c80:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103c85:	8b 40 08             	mov    0x8(%eax),%eax
c0103c88:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103c8b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103c8f:	8b 55 08             	mov    0x8(%ebp),%edx
c0103c92:	89 14 24             	mov    %edx,(%esp)
c0103c95:	ff d0                	call   *%eax
}
c0103c97:	c9                   	leave  
c0103c98:	c3                   	ret    

c0103c99 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0103c99:	55                   	push   %ebp
c0103c9a:	89 e5                	mov    %esp,%ebp
c0103c9c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103c9f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0103ca6:	e8 2e fe ff ff       	call   c0103ad9 <__intr_save>
c0103cab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0103cae:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103cb3:	8b 40 0c             	mov    0xc(%eax),%eax
c0103cb6:	8b 55 08             	mov    0x8(%ebp),%edx
c0103cb9:	89 14 24             	mov    %edx,(%esp)
c0103cbc:	ff d0                	call   *%eax
c0103cbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0103cc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cc4:	89 04 24             	mov    %eax,(%esp)
c0103cc7:	e8 37 fe ff ff       	call   c0103b03 <__intr_restore>
    return page;
c0103ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103ccf:	c9                   	leave  
c0103cd0:	c3                   	ret    

c0103cd1 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0103cd1:	55                   	push   %ebp
c0103cd2:	89 e5                	mov    %esp,%ebp
c0103cd4:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0103cd7:	e8 fd fd ff ff       	call   c0103ad9 <__intr_save>
c0103cdc:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103cdf:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103ce4:	8b 40 10             	mov    0x10(%eax),%eax
c0103ce7:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103cea:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103cee:	8b 55 08             	mov    0x8(%ebp),%edx
c0103cf1:	89 14 24             	mov    %edx,(%esp)
c0103cf4:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0103cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cf9:	89 04 24             	mov    %eax,(%esp)
c0103cfc:	e8 02 fe ff ff       	call   c0103b03 <__intr_restore>
}
c0103d01:	c9                   	leave  
c0103d02:	c3                   	ret    

c0103d03 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0103d03:	55                   	push   %ebp
c0103d04:	89 e5                	mov    %esp,%ebp
c0103d06:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0103d09:	e8 cb fd ff ff       	call   c0103ad9 <__intr_save>
c0103d0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103d11:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c0103d16:	8b 40 14             	mov    0x14(%eax),%eax
c0103d19:	ff d0                	call   *%eax
c0103d1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0103d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d21:	89 04 24             	mov    %eax,(%esp)
c0103d24:	e8 da fd ff ff       	call   c0103b03 <__intr_restore>
    return ret;
c0103d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0103d2c:	c9                   	leave  
c0103d2d:	c3                   	ret    

c0103d2e <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0103d2e:	55                   	push   %ebp
c0103d2f:	89 e5                	mov    %esp,%ebp
c0103d31:	57                   	push   %edi
c0103d32:	56                   	push   %esi
c0103d33:	53                   	push   %ebx
c0103d34:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0103d3a:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0103d41:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103d48:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103d4f:	c7 04 24 e3 69 10 c0 	movl   $0xc01069e3,(%esp)
c0103d56:	e8 ed c5 ff ff       	call   c0100348 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103d5b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103d62:	e9 15 01 00 00       	jmp    c0103e7c <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103d67:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103d6a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103d6d:	89 d0                	mov    %edx,%eax
c0103d6f:	c1 e0 02             	shl    $0x2,%eax
c0103d72:	01 d0                	add    %edx,%eax
c0103d74:	c1 e0 02             	shl    $0x2,%eax
c0103d77:	01 c8                	add    %ecx,%eax
c0103d79:	8b 50 08             	mov    0x8(%eax),%edx
c0103d7c:	8b 40 04             	mov    0x4(%eax),%eax
c0103d7f:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0103d82:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0103d85:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103d88:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103d8b:	89 d0                	mov    %edx,%eax
c0103d8d:	c1 e0 02             	shl    $0x2,%eax
c0103d90:	01 d0                	add    %edx,%eax
c0103d92:	c1 e0 02             	shl    $0x2,%eax
c0103d95:	01 c8                	add    %ecx,%eax
c0103d97:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103d9a:	8b 58 10             	mov    0x10(%eax),%ebx
c0103d9d:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103da0:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103da3:	01 c8                	add    %ecx,%eax
c0103da5:	11 da                	adc    %ebx,%edx
c0103da7:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0103daa:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103dad:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103db0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103db3:	89 d0                	mov    %edx,%eax
c0103db5:	c1 e0 02             	shl    $0x2,%eax
c0103db8:	01 d0                	add    %edx,%eax
c0103dba:	c1 e0 02             	shl    $0x2,%eax
c0103dbd:	01 c8                	add    %ecx,%eax
c0103dbf:	83 c0 14             	add    $0x14,%eax
c0103dc2:	8b 00                	mov    (%eax),%eax
c0103dc4:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0103dca:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103dcd:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103dd0:	83 c0 ff             	add    $0xffffffff,%eax
c0103dd3:	83 d2 ff             	adc    $0xffffffff,%edx
c0103dd6:	89 c6                	mov    %eax,%esi
c0103dd8:	89 d7                	mov    %edx,%edi
c0103dda:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103ddd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103de0:	89 d0                	mov    %edx,%eax
c0103de2:	c1 e0 02             	shl    $0x2,%eax
c0103de5:	01 d0                	add    %edx,%eax
c0103de7:	c1 e0 02             	shl    $0x2,%eax
c0103dea:	01 c8                	add    %ecx,%eax
c0103dec:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103def:	8b 58 10             	mov    0x10(%eax),%ebx
c0103df2:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c0103df8:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c0103dfc:	89 74 24 14          	mov    %esi,0x14(%esp)
c0103e00:	89 7c 24 18          	mov    %edi,0x18(%esp)
c0103e04:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103e07:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103e0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103e0e:	89 54 24 10          	mov    %edx,0x10(%esp)
c0103e12:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103e16:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0103e1a:	c7 04 24 f0 69 10 c0 	movl   $0xc01069f0,(%esp)
c0103e21:	e8 22 c5 ff ff       	call   c0100348 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0103e26:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103e29:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103e2c:	89 d0                	mov    %edx,%eax
c0103e2e:	c1 e0 02             	shl    $0x2,%eax
c0103e31:	01 d0                	add    %edx,%eax
c0103e33:	c1 e0 02             	shl    $0x2,%eax
c0103e36:	01 c8                	add    %ecx,%eax
c0103e38:	83 c0 14             	add    $0x14,%eax
c0103e3b:	8b 00                	mov    (%eax),%eax
c0103e3d:	83 f8 01             	cmp    $0x1,%eax
c0103e40:	75 36                	jne    c0103e78 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c0103e42:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e45:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103e48:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103e4b:	77 2b                	ja     c0103e78 <page_init+0x14a>
c0103e4d:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103e50:	72 05                	jb     c0103e57 <page_init+0x129>
c0103e52:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0103e55:	73 21                	jae    c0103e78 <page_init+0x14a>
c0103e57:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103e5b:	77 1b                	ja     c0103e78 <page_init+0x14a>
c0103e5d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103e61:	72 09                	jb     c0103e6c <page_init+0x13e>
c0103e63:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0103e6a:	77 0c                	ja     c0103e78 <page_init+0x14a>
                maxpa = end;
c0103e6c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103e6f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103e72:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103e75:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103e78:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103e7c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103e7f:	8b 00                	mov    (%eax),%eax
c0103e81:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103e84:	0f 8f dd fe ff ff    	jg     c0103d67 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0103e8a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103e8e:	72 1d                	jb     c0103ead <page_init+0x17f>
c0103e90:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103e94:	77 09                	ja     c0103e9f <page_init+0x171>
c0103e96:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0103e9d:	76 0e                	jbe    c0103ead <page_init+0x17f>
        maxpa = KMEMSIZE;
c0103e9f:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0103ea6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0103ead:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103eb0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103eb3:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103eb7:	c1 ea 0c             	shr    $0xc,%edx
c0103eba:	a3 80 ae 11 c0       	mov    %eax,0xc011ae80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0103ebf:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0103ec6:	b8 28 af 11 c0       	mov    $0xc011af28,%eax
c0103ecb:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103ece:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103ed1:	01 d0                	add    %edx,%eax
c0103ed3:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0103ed6:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0103ed9:	ba 00 00 00 00       	mov    $0x0,%edx
c0103ede:	f7 75 ac             	divl   -0x54(%ebp)
c0103ee1:	89 d0                	mov    %edx,%eax
c0103ee3:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103ee6:	29 c2                	sub    %eax,%edx
c0103ee8:	89 d0                	mov    %edx,%eax
c0103eea:	a3 24 af 11 c0       	mov    %eax,0xc011af24

    for (i = 0; i < npage; i ++) {
c0103eef:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103ef6:	eb 2f                	jmp    c0103f27 <page_init+0x1f9>
        SetPageReserved(pages + i);
c0103ef8:	8b 0d 24 af 11 c0    	mov    0xc011af24,%ecx
c0103efe:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f01:	89 d0                	mov    %edx,%eax
c0103f03:	c1 e0 02             	shl    $0x2,%eax
c0103f06:	01 d0                	add    %edx,%eax
c0103f08:	c1 e0 02             	shl    $0x2,%eax
c0103f0b:	01 c8                	add    %ecx,%eax
c0103f0d:	83 c0 04             	add    $0x4,%eax
c0103f10:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0103f17:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103f1a:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103f1d:	8b 55 90             	mov    -0x70(%ebp),%edx
c0103f20:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0103f23:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0103f27:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f2a:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0103f2f:	39 c2                	cmp    %eax,%edx
c0103f31:	72 c5                	jb     c0103ef8 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0103f33:	8b 15 80 ae 11 c0    	mov    0xc011ae80,%edx
c0103f39:	89 d0                	mov    %edx,%eax
c0103f3b:	c1 e0 02             	shl    $0x2,%eax
c0103f3e:	01 d0                	add    %edx,%eax
c0103f40:	c1 e0 02             	shl    $0x2,%eax
c0103f43:	89 c2                	mov    %eax,%edx
c0103f45:	a1 24 af 11 c0       	mov    0xc011af24,%eax
c0103f4a:	01 d0                	add    %edx,%eax
c0103f4c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0103f4f:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0103f56:	77 23                	ja     c0103f7b <page_init+0x24d>
c0103f58:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103f5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f5f:	c7 44 24 08 20 6a 10 	movl   $0xc0106a20,0x8(%esp)
c0103f66:	c0 
c0103f67:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0103f6e:	00 
c0103f6f:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0103f76:	e8 57 cd ff ff       	call   c0100cd2 <__panic>
c0103f7b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103f7e:	05 00 00 00 40       	add    $0x40000000,%eax
c0103f83:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0103f86:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103f8d:	e9 74 01 00 00       	jmp    c0104106 <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103f92:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103f95:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103f98:	89 d0                	mov    %edx,%eax
c0103f9a:	c1 e0 02             	shl    $0x2,%eax
c0103f9d:	01 d0                	add    %edx,%eax
c0103f9f:	c1 e0 02             	shl    $0x2,%eax
c0103fa2:	01 c8                	add    %ecx,%eax
c0103fa4:	8b 50 08             	mov    0x8(%eax),%edx
c0103fa7:	8b 40 04             	mov    0x4(%eax),%eax
c0103faa:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103fad:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103fb0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103fb3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103fb6:	89 d0                	mov    %edx,%eax
c0103fb8:	c1 e0 02             	shl    $0x2,%eax
c0103fbb:	01 d0                	add    %edx,%eax
c0103fbd:	c1 e0 02             	shl    $0x2,%eax
c0103fc0:	01 c8                	add    %ecx,%eax
c0103fc2:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103fc5:	8b 58 10             	mov    0x10(%eax),%ebx
c0103fc8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103fcb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103fce:	01 c8                	add    %ecx,%eax
c0103fd0:	11 da                	adc    %ebx,%edx
c0103fd2:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0103fd5:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0103fd8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103fdb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103fde:	89 d0                	mov    %edx,%eax
c0103fe0:	c1 e0 02             	shl    $0x2,%eax
c0103fe3:	01 d0                	add    %edx,%eax
c0103fe5:	c1 e0 02             	shl    $0x2,%eax
c0103fe8:	01 c8                	add    %ecx,%eax
c0103fea:	83 c0 14             	add    $0x14,%eax
c0103fed:	8b 00                	mov    (%eax),%eax
c0103fef:	83 f8 01             	cmp    $0x1,%eax
c0103ff2:	0f 85 0a 01 00 00    	jne    c0104102 <page_init+0x3d4>
            if (begin < freemem) {
c0103ff8:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0103ffb:	ba 00 00 00 00       	mov    $0x0,%edx
c0104000:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104003:	72 17                	jb     c010401c <page_init+0x2ee>
c0104005:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0104008:	77 05                	ja     c010400f <page_init+0x2e1>
c010400a:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010400d:	76 0d                	jbe    c010401c <page_init+0x2ee>
                begin = freemem;
c010400f:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104012:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104015:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c010401c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104020:	72 1d                	jb     c010403f <page_init+0x311>
c0104022:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0104026:	77 09                	ja     c0104031 <page_init+0x303>
c0104028:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c010402f:	76 0e                	jbe    c010403f <page_init+0x311>
                end = KMEMSIZE;
c0104031:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0104038:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c010403f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104042:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104045:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104048:	0f 87 b4 00 00 00    	ja     c0104102 <page_init+0x3d4>
c010404e:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0104051:	72 09                	jb     c010405c <page_init+0x32e>
c0104053:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0104056:	0f 83 a6 00 00 00    	jae    c0104102 <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c010405c:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0104063:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104066:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104069:	01 d0                	add    %edx,%eax
c010406b:	83 e8 01             	sub    $0x1,%eax
c010406e:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104071:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104074:	ba 00 00 00 00       	mov    $0x0,%edx
c0104079:	f7 75 9c             	divl   -0x64(%ebp)
c010407c:	89 d0                	mov    %edx,%eax
c010407e:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104081:	29 c2                	sub    %eax,%edx
c0104083:	89 d0                	mov    %edx,%eax
c0104085:	ba 00 00 00 00       	mov    $0x0,%edx
c010408a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010408d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104090:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104093:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104096:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104099:	ba 00 00 00 00       	mov    $0x0,%edx
c010409e:	89 c7                	mov    %eax,%edi
c01040a0:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c01040a6:	89 7d 80             	mov    %edi,-0x80(%ebp)
c01040a9:	89 d0                	mov    %edx,%eax
c01040ab:	83 e0 00             	and    $0x0,%eax
c01040ae:	89 45 84             	mov    %eax,-0x7c(%ebp)
c01040b1:	8b 45 80             	mov    -0x80(%ebp),%eax
c01040b4:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01040b7:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01040ba:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c01040bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01040c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01040c3:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01040c6:	77 3a                	ja     c0104102 <page_init+0x3d4>
c01040c8:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01040cb:	72 05                	jb     c01040d2 <page_init+0x3a4>
c01040cd:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01040d0:	73 30                	jae    c0104102 <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01040d2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01040d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c01040d8:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01040db:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01040de:	29 c8                	sub    %ecx,%eax
c01040e0:	19 da                	sbb    %ebx,%edx
c01040e2:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01040e6:	c1 ea 0c             	shr    $0xc,%edx
c01040e9:	89 c3                	mov    %eax,%ebx
c01040eb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01040ee:	89 04 24             	mov    %eax,(%esp)
c01040f1:	e8 a5 f8 ff ff       	call   c010399b <pa2page>
c01040f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01040fa:	89 04 24             	mov    %eax,(%esp)
c01040fd:	e8 78 fb ff ff       	call   c0103c7a <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0104102:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0104106:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104109:	8b 00                	mov    (%eax),%eax
c010410b:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010410e:	0f 8f 7e fe ff ff    	jg     c0103f92 <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0104114:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c010411a:	5b                   	pop    %ebx
c010411b:	5e                   	pop    %esi
c010411c:	5f                   	pop    %edi
c010411d:	5d                   	pop    %ebp
c010411e:	c3                   	ret    

c010411f <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010411f:	55                   	push   %ebp
c0104120:	89 e5                	mov    %esp,%ebp
c0104122:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0104125:	8b 45 14             	mov    0x14(%ebp),%eax
c0104128:	8b 55 0c             	mov    0xc(%ebp),%edx
c010412b:	31 d0                	xor    %edx,%eax
c010412d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104132:	85 c0                	test   %eax,%eax
c0104134:	74 24                	je     c010415a <boot_map_segment+0x3b>
c0104136:	c7 44 24 0c 52 6a 10 	movl   $0xc0106a52,0xc(%esp)
c010413d:	c0 
c010413e:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104145:	c0 
c0104146:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c010414d:	00 
c010414e:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104155:	e8 78 cb ff ff       	call   c0100cd2 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c010415a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0104161:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104164:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104169:	89 c2                	mov    %eax,%edx
c010416b:	8b 45 10             	mov    0x10(%ebp),%eax
c010416e:	01 c2                	add    %eax,%edx
c0104170:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104173:	01 d0                	add    %edx,%eax
c0104175:	83 e8 01             	sub    $0x1,%eax
c0104178:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010417b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010417e:	ba 00 00 00 00       	mov    $0x0,%edx
c0104183:	f7 75 f0             	divl   -0x10(%ebp)
c0104186:	89 d0                	mov    %edx,%eax
c0104188:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010418b:	29 c2                	sub    %eax,%edx
c010418d:	89 d0                	mov    %edx,%eax
c010418f:	c1 e8 0c             	shr    $0xc,%eax
c0104192:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0104195:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104198:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010419b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010419e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01041a3:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01041a6:	8b 45 14             	mov    0x14(%ebp),%eax
c01041a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01041ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01041af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01041b4:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01041b7:	eb 6b                	jmp    c0104224 <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01041b9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01041c0:	00 
c01041c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01041c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01041c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01041cb:	89 04 24             	mov    %eax,(%esp)
c01041ce:	e8 82 01 00 00       	call   c0104355 <get_pte>
c01041d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01041d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01041da:	75 24                	jne    c0104200 <boot_map_segment+0xe1>
c01041dc:	c7 44 24 0c 7e 6a 10 	movl   $0xc0106a7e,0xc(%esp)
c01041e3:	c0 
c01041e4:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c01041eb:	c0 
c01041ec:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c01041f3:	00 
c01041f4:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01041fb:	e8 d2 ca ff ff       	call   c0100cd2 <__panic>
        *ptep = pa | PTE_P | perm;
c0104200:	8b 45 18             	mov    0x18(%ebp),%eax
c0104203:	8b 55 14             	mov    0x14(%ebp),%edx
c0104206:	09 d0                	or     %edx,%eax
c0104208:	83 c8 01             	or     $0x1,%eax
c010420b:	89 c2                	mov    %eax,%edx
c010420d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104210:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104212:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0104216:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010421d:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104224:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104228:	75 8f                	jne    c01041b9 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c010422a:	c9                   	leave  
c010422b:	c3                   	ret    

c010422c <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010422c:	55                   	push   %ebp
c010422d:	89 e5                	mov    %esp,%ebp
c010422f:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0104232:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104239:	e8 5b fa ff ff       	call   c0103c99 <alloc_pages>
c010423e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0104241:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104245:	75 1c                	jne    c0104263 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0104247:	c7 44 24 08 8b 6a 10 	movl   $0xc0106a8b,0x8(%esp)
c010424e:	c0 
c010424f:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0104256:	00 
c0104257:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c010425e:	e8 6f ca ff ff       	call   c0100cd2 <__panic>
    }
    return page2kva(p);
c0104263:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104266:	89 04 24             	mov    %eax,(%esp)
c0104269:	e8 7c f7 ff ff       	call   c01039ea <page2kva>
}
c010426e:	c9                   	leave  
c010426f:	c3                   	ret    

c0104270 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0104270:	55                   	push   %ebp
c0104271:	89 e5                	mov    %esp,%ebp
c0104273:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0104276:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010427b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010427e:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104285:	77 23                	ja     c01042aa <pmm_init+0x3a>
c0104287:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010428a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010428e:	c7 44 24 08 20 6a 10 	movl   $0xc0106a20,0x8(%esp)
c0104295:	c0 
c0104296:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c010429d:	00 
c010429e:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01042a5:	e8 28 ca ff ff       	call   c0100cd2 <__panic>
c01042aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01042ad:	05 00 00 00 40       	add    $0x40000000,%eax
c01042b2:	a3 20 af 11 c0       	mov    %eax,0xc011af20
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01042b7:	e8 8b f9 ff ff       	call   c0103c47 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01042bc:	e8 6d fa ff ff       	call   c0103d2e <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01042c1:	e8 e0 03 00 00       	call   c01046a6 <check_alloc_page>

    check_pgdir();
c01042c6:	e8 f9 03 00 00       	call   c01046c4 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01042cb:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01042d0:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c01042d6:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01042db:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01042de:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01042e5:	77 23                	ja     c010430a <pmm_init+0x9a>
c01042e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01042ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01042ee:	c7 44 24 08 20 6a 10 	movl   $0xc0106a20,0x8(%esp)
c01042f5:	c0 
c01042f6:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01042fd:	00 
c01042fe:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104305:	e8 c8 c9 ff ff       	call   c0100cd2 <__panic>
c010430a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010430d:	05 00 00 00 40       	add    $0x40000000,%eax
c0104312:	83 c8 03             	or     $0x3,%eax
c0104315:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0104317:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010431c:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0104323:	00 
c0104324:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010432b:	00 
c010432c:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0104333:	38 
c0104334:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c010433b:	c0 
c010433c:	89 04 24             	mov    %eax,(%esp)
c010433f:	e8 db fd ff ff       	call   c010411f <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0104344:	e8 0f f8 ff ff       	call   c0103b58 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0104349:	e8 11 0a 00 00       	call   c0104d5f <check_boot_pgdir>

    print_pgdir();
c010434e:	e8 99 0e 00 00       	call   c01051ec <print_pgdir>

}
c0104353:	c9                   	leave  
c0104354:	c3                   	ret    

c0104355 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0104355:	55                   	push   %ebp
c0104356:	89 e5                	mov    %esp,%ebp
c0104358:	83 ec 38             	sub    $0x38,%esp
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
     */
#if 1
    pde_t *pdep = &pgdir[PDX(la)];
c010435b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010435e:	c1 e8 16             	shr    $0x16,%eax
c0104361:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104368:	8b 45 08             	mov    0x8(%ebp),%eax
c010436b:	01 d0                	add    %edx,%eax
c010436d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c0104370:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104373:	8b 00                	mov    (%eax),%eax
c0104375:	83 e0 01             	and    $0x1,%eax
c0104378:	85 c0                	test   %eax,%eax
c010437a:	0f 85 af 00 00 00    	jne    c010442f <get_pte+0xda>
        struct Page *page = alloc_page();
c0104380:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104387:	e8 0d f9 ff ff       	call   c0103c99 <alloc_pages>
c010438c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (!create || !page) {
c010438f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104393:	74 06                	je     c010439b <get_pte+0x46>
c0104395:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104399:	75 0a                	jne    c01043a5 <get_pte+0x50>
            return NULL;
c010439b:	b8 00 00 00 00       	mov    $0x0,%eax
c01043a0:	e9 e6 00 00 00       	jmp    c010448b <get_pte+0x136>
        }
        set_page_ref(page, 1);
c01043a5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01043ac:	00 
c01043ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043b0:	89 04 24             	mov    %eax,(%esp)
c01043b3:	e8 e6 f6 ff ff       	call   c0103a9e <set_page_ref>
        uintptr_t pa = page2pa(page);
c01043b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043bb:	89 04 24             	mov    %eax,(%esp)
c01043be:	e8 c2 f5 ff ff       	call   c0103985 <page2pa>
c01043c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c01043c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01043c9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01043cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01043cf:	c1 e8 0c             	shr    $0xc,%eax
c01043d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01043d5:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01043da:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01043dd:	72 23                	jb     c0104402 <get_pte+0xad>
c01043df:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01043e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01043e6:	c7 44 24 08 7c 69 10 	movl   $0xc010697c,0x8(%esp)
c01043ed:	c0 
c01043ee:	c7 44 24 04 67 01 00 	movl   $0x167,0x4(%esp)
c01043f5:	00 
c01043f6:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01043fd:	e8 d0 c8 ff ff       	call   c0100cd2 <__panic>
c0104402:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104405:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010440a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104411:	00 
c0104412:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104419:	00 
c010441a:	89 04 24             	mov    %eax,(%esp)
c010441d:	e8 e8 18 00 00       	call   c0105d0a <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0104422:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104425:	83 c8 07             	or     $0x7,%eax
c0104428:	89 c2                	mov    %eax,%edx
c010442a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010442d:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c010442f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104432:	8b 00                	mov    (%eax),%eax
c0104434:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104439:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010443c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010443f:	c1 e8 0c             	shr    $0xc,%eax
c0104442:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104445:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c010444a:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c010444d:	72 23                	jb     c0104472 <get_pte+0x11d>
c010444f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104452:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104456:	c7 44 24 08 7c 69 10 	movl   $0xc010697c,0x8(%esp)
c010445d:	c0 
c010445e:	c7 44 24 04 6a 01 00 	movl   $0x16a,0x4(%esp)
c0104465:	00 
c0104466:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c010446d:	e8 60 c8 ff ff       	call   c0100cd2 <__panic>
c0104472:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104475:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010447a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010447d:	c1 ea 0c             	shr    $0xc,%edx
c0104480:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c0104486:	c1 e2 02             	shl    $0x2,%edx
c0104489:	01 d0                	add    %edx,%eax
#endif
}
c010448b:	c9                   	leave  
c010448c:	c3                   	ret    

c010448d <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010448d:	55                   	push   %ebp
c010448e:	89 e5                	mov    %esp,%ebp
c0104490:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104493:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010449a:	00 
c010449b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010449e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01044a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01044a5:	89 04 24             	mov    %eax,(%esp)
c01044a8:	e8 a8 fe ff ff       	call   c0104355 <get_pte>
c01044ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01044b0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01044b4:	74 08                	je     c01044be <get_page+0x31>
        *ptep_store = ptep;
c01044b6:	8b 45 10             	mov    0x10(%ebp),%eax
c01044b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01044bc:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01044be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01044c2:	74 1b                	je     c01044df <get_page+0x52>
c01044c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044c7:	8b 00                	mov    (%eax),%eax
c01044c9:	83 e0 01             	and    $0x1,%eax
c01044cc:	85 c0                	test   %eax,%eax
c01044ce:	74 0f                	je     c01044df <get_page+0x52>
        return pte2page(*ptep);
c01044d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01044d3:	8b 00                	mov    (%eax),%eax
c01044d5:	89 04 24             	mov    %eax,(%esp)
c01044d8:	e8 61 f5 ff ff       	call   c0103a3e <pte2page>
c01044dd:	eb 05                	jmp    c01044e4 <get_page+0x57>
    }
    return NULL;
c01044df:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01044e4:	c9                   	leave  
c01044e5:	c3                   	ret    

c01044e6 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c01044e6:	55                   	push   %ebp
c01044e7:	89 e5                	mov    %esp,%ebp
c01044e9:	83 ec 28             	sub    $0x28,%esp
     *                        edited are the ones currently in use by the processor.
     * DEFINEs:
     *   PTE_P           0x001                   // page table/directory entry flags bit : Present
     */
#if 1
    if (*ptep & PTE_P) {
c01044ec:	8b 45 10             	mov    0x10(%ebp),%eax
c01044ef:	8b 00                	mov    (%eax),%eax
c01044f1:	83 e0 01             	and    $0x1,%eax
c01044f4:	85 c0                	test   %eax,%eax
c01044f6:	74 52                	je     c010454a <page_remove_pte+0x64>
        struct Page *page = pte2page(*ptep);
c01044f8:	8b 45 10             	mov    0x10(%ebp),%eax
c01044fb:	8b 00                	mov    (%eax),%eax
c01044fd:	89 04 24             	mov    %eax,(%esp)
c0104500:	e8 39 f5 ff ff       	call   c0103a3e <pte2page>
c0104505:	89 45 f4             	mov    %eax,-0xc(%ebp)
	page_ref_dec(page);
c0104508:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010450b:	89 04 24             	mov    %eax,(%esp)
c010450e:	e8 af f5 ff ff       	call   c0103ac2 <page_ref_dec>
        if (page->ref == 0) {
c0104513:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104516:	8b 00                	mov    (%eax),%eax
c0104518:	85 c0                	test   %eax,%eax
c010451a:	75 13                	jne    c010452f <page_remove_pte+0x49>
            free_page(page);
c010451c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104523:	00 
c0104524:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104527:	89 04 24             	mov    %eax,(%esp)
c010452a:	e8 a2 f7 ff ff       	call   c0103cd1 <free_pages>
        }
        *ptep = 0;
c010452f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104532:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0104538:	8b 45 0c             	mov    0xc(%ebp),%eax
c010453b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010453f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104542:	89 04 24             	mov    %eax,(%esp)
c0104545:	e8 ff 00 00 00       	call   c0104649 <tlb_invalidate>
    }
#endif
}
c010454a:	c9                   	leave  
c010454b:	c3                   	ret    

c010454c <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c010454c:	55                   	push   %ebp
c010454d:	89 e5                	mov    %esp,%ebp
c010454f:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104552:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104559:	00 
c010455a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010455d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104561:	8b 45 08             	mov    0x8(%ebp),%eax
c0104564:	89 04 24             	mov    %eax,(%esp)
c0104567:	e8 e9 fd ff ff       	call   c0104355 <get_pte>
c010456c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c010456f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104573:	74 19                	je     c010458e <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0104575:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104578:	89 44 24 08          	mov    %eax,0x8(%esp)
c010457c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010457f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104583:	8b 45 08             	mov    0x8(%ebp),%eax
c0104586:	89 04 24             	mov    %eax,(%esp)
c0104589:	e8 58 ff ff ff       	call   c01044e6 <page_remove_pte>
    }
}
c010458e:	c9                   	leave  
c010458f:	c3                   	ret    

c0104590 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0104590:	55                   	push   %ebp
c0104591:	89 e5                	mov    %esp,%ebp
c0104593:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0104596:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010459d:	00 
c010459e:	8b 45 10             	mov    0x10(%ebp),%eax
c01045a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01045a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01045a8:	89 04 24             	mov    %eax,(%esp)
c01045ab:	e8 a5 fd ff ff       	call   c0104355 <get_pte>
c01045b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01045b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01045b7:	75 0a                	jne    c01045c3 <page_insert+0x33>
        return -E_NO_MEM;
c01045b9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01045be:	e9 84 00 00 00       	jmp    c0104647 <page_insert+0xb7>
    }
    page_ref_inc(page);
c01045c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045c6:	89 04 24             	mov    %eax,(%esp)
c01045c9:	e8 dd f4 ff ff       	call   c0103aab <page_ref_inc>
    if (*ptep & PTE_P) {
c01045ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045d1:	8b 00                	mov    (%eax),%eax
c01045d3:	83 e0 01             	and    $0x1,%eax
c01045d6:	85 c0                	test   %eax,%eax
c01045d8:	74 3e                	je     c0104618 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c01045da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045dd:	8b 00                	mov    (%eax),%eax
c01045df:	89 04 24             	mov    %eax,(%esp)
c01045e2:	e8 57 f4 ff ff       	call   c0103a3e <pte2page>
c01045e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01045ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01045ed:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01045f0:	75 0d                	jne    c01045ff <page_insert+0x6f>
            page_ref_dec(page);
c01045f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045f5:	89 04 24             	mov    %eax,(%esp)
c01045f8:	e8 c5 f4 ff ff       	call   c0103ac2 <page_ref_dec>
c01045fd:	eb 19                	jmp    c0104618 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01045ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104602:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104606:	8b 45 10             	mov    0x10(%ebp),%eax
c0104609:	89 44 24 04          	mov    %eax,0x4(%esp)
c010460d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104610:	89 04 24             	mov    %eax,(%esp)
c0104613:	e8 ce fe ff ff       	call   c01044e6 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0104618:	8b 45 0c             	mov    0xc(%ebp),%eax
c010461b:	89 04 24             	mov    %eax,(%esp)
c010461e:	e8 62 f3 ff ff       	call   c0103985 <page2pa>
c0104623:	0b 45 14             	or     0x14(%ebp),%eax
c0104626:	83 c8 01             	or     $0x1,%eax
c0104629:	89 c2                	mov    %eax,%edx
c010462b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010462e:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0104630:	8b 45 10             	mov    0x10(%ebp),%eax
c0104633:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104637:	8b 45 08             	mov    0x8(%ebp),%eax
c010463a:	89 04 24             	mov    %eax,(%esp)
c010463d:	e8 07 00 00 00       	call   c0104649 <tlb_invalidate>
    return 0;
c0104642:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104647:	c9                   	leave  
c0104648:	c3                   	ret    

c0104649 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0104649:	55                   	push   %ebp
c010464a:	89 e5                	mov    %esp,%ebp
c010464c:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c010464f:	0f 20 d8             	mov    %cr3,%eax
c0104652:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0104655:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0104658:	89 c2                	mov    %eax,%edx
c010465a:	8b 45 08             	mov    0x8(%ebp),%eax
c010465d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104660:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0104667:	77 23                	ja     c010468c <tlb_invalidate+0x43>
c0104669:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010466c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104670:	c7 44 24 08 20 6a 10 	movl   $0xc0106a20,0x8(%esp)
c0104677:	c0 
c0104678:	c7 44 24 04 c7 01 00 	movl   $0x1c7,0x4(%esp)
c010467f:	00 
c0104680:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104687:	e8 46 c6 ff ff       	call   c0100cd2 <__panic>
c010468c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010468f:	05 00 00 00 40       	add    $0x40000000,%eax
c0104694:	39 c2                	cmp    %eax,%edx
c0104696:	75 0c                	jne    c01046a4 <tlb_invalidate+0x5b>
        invlpg((void *)la);
c0104698:	8b 45 0c             	mov    0xc(%ebp),%eax
c010469b:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c010469e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01046a1:	0f 01 38             	invlpg (%eax)
    }
}
c01046a4:	c9                   	leave  
c01046a5:	c3                   	ret    

c01046a6 <check_alloc_page>:

static void
check_alloc_page(void) {
c01046a6:	55                   	push   %ebp
c01046a7:	89 e5                	mov    %esp,%ebp
c01046a9:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01046ac:	a1 1c af 11 c0       	mov    0xc011af1c,%eax
c01046b1:	8b 40 18             	mov    0x18(%eax),%eax
c01046b4:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01046b6:	c7 04 24 a4 6a 10 c0 	movl   $0xc0106aa4,(%esp)
c01046bd:	e8 86 bc ff ff       	call   c0100348 <cprintf>
}
c01046c2:	c9                   	leave  
c01046c3:	c3                   	ret    

c01046c4 <check_pgdir>:

static void
check_pgdir(void) {
c01046c4:	55                   	push   %ebp
c01046c5:	89 e5                	mov    %esp,%ebp
c01046c7:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01046ca:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01046cf:	3d 00 80 03 00       	cmp    $0x38000,%eax
c01046d4:	76 24                	jbe    c01046fa <check_pgdir+0x36>
c01046d6:	c7 44 24 0c c3 6a 10 	movl   $0xc0106ac3,0xc(%esp)
c01046dd:	c0 
c01046de:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c01046e5:	c0 
c01046e6:	c7 44 24 04 d4 01 00 	movl   $0x1d4,0x4(%esp)
c01046ed:	00 
c01046ee:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01046f5:	e8 d8 c5 ff ff       	call   c0100cd2 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01046fa:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01046ff:	85 c0                	test   %eax,%eax
c0104701:	74 0e                	je     c0104711 <check_pgdir+0x4d>
c0104703:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104708:	25 ff 0f 00 00       	and    $0xfff,%eax
c010470d:	85 c0                	test   %eax,%eax
c010470f:	74 24                	je     c0104735 <check_pgdir+0x71>
c0104711:	c7 44 24 0c e0 6a 10 	movl   $0xc0106ae0,0xc(%esp)
c0104718:	c0 
c0104719:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104720:	c0 
c0104721:	c7 44 24 04 d5 01 00 	movl   $0x1d5,0x4(%esp)
c0104728:	00 
c0104729:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104730:	e8 9d c5 ff ff       	call   c0100cd2 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0104735:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010473a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104741:	00 
c0104742:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104749:	00 
c010474a:	89 04 24             	mov    %eax,(%esp)
c010474d:	e8 3b fd ff ff       	call   c010448d <get_page>
c0104752:	85 c0                	test   %eax,%eax
c0104754:	74 24                	je     c010477a <check_pgdir+0xb6>
c0104756:	c7 44 24 0c 18 6b 10 	movl   $0xc0106b18,0xc(%esp)
c010475d:	c0 
c010475e:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104765:	c0 
c0104766:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
c010476d:	00 
c010476e:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104775:	e8 58 c5 ff ff       	call   c0100cd2 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c010477a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104781:	e8 13 f5 ff ff       	call   c0103c99 <alloc_pages>
c0104786:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0104789:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010478e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104795:	00 
c0104796:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010479d:	00 
c010479e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01047a1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01047a5:	89 04 24             	mov    %eax,(%esp)
c01047a8:	e8 e3 fd ff ff       	call   c0104590 <page_insert>
c01047ad:	85 c0                	test   %eax,%eax
c01047af:	74 24                	je     c01047d5 <check_pgdir+0x111>
c01047b1:	c7 44 24 0c 40 6b 10 	movl   $0xc0106b40,0xc(%esp)
c01047b8:	c0 
c01047b9:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c01047c0:	c0 
c01047c1:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
c01047c8:	00 
c01047c9:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01047d0:	e8 fd c4 ff ff       	call   c0100cd2 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c01047d5:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01047da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01047e1:	00 
c01047e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01047e9:	00 
c01047ea:	89 04 24             	mov    %eax,(%esp)
c01047ed:	e8 63 fb ff ff       	call   c0104355 <get_pte>
c01047f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01047f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01047f9:	75 24                	jne    c010481f <check_pgdir+0x15b>
c01047fb:	c7 44 24 0c 6c 6b 10 	movl   $0xc0106b6c,0xc(%esp)
c0104802:	c0 
c0104803:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c010480a:	c0 
c010480b:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
c0104812:	00 
c0104813:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c010481a:	e8 b3 c4 ff ff       	call   c0100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
c010481f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104822:	8b 00                	mov    (%eax),%eax
c0104824:	89 04 24             	mov    %eax,(%esp)
c0104827:	e8 12 f2 ff ff       	call   c0103a3e <pte2page>
c010482c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010482f:	74 24                	je     c0104855 <check_pgdir+0x191>
c0104831:	c7 44 24 0c 99 6b 10 	movl   $0xc0106b99,0xc(%esp)
c0104838:	c0 
c0104839:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104840:	c0 
c0104841:	c7 44 24 04 de 01 00 	movl   $0x1de,0x4(%esp)
c0104848:	00 
c0104849:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104850:	e8 7d c4 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p1) == 1);
c0104855:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104858:	89 04 24             	mov    %eax,(%esp)
c010485b:	e8 34 f2 ff ff       	call   c0103a94 <page_ref>
c0104860:	83 f8 01             	cmp    $0x1,%eax
c0104863:	74 24                	je     c0104889 <check_pgdir+0x1c5>
c0104865:	c7 44 24 0c af 6b 10 	movl   $0xc0106baf,0xc(%esp)
c010486c:	c0 
c010486d:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104874:	c0 
c0104875:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
c010487c:	00 
c010487d:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104884:	e8 49 c4 ff ff       	call   c0100cd2 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0104889:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c010488e:	8b 00                	mov    (%eax),%eax
c0104890:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104895:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104898:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010489b:	c1 e8 0c             	shr    $0xc,%eax
c010489e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01048a1:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c01048a6:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01048a9:	72 23                	jb     c01048ce <check_pgdir+0x20a>
c01048ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01048b2:	c7 44 24 08 7c 69 10 	movl   $0xc010697c,0x8(%esp)
c01048b9:	c0 
c01048ba:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c01048c1:	00 
c01048c2:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01048c9:	e8 04 c4 ff ff       	call   c0100cd2 <__panic>
c01048ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048d1:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01048d6:	83 c0 04             	add    $0x4,%eax
c01048d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c01048dc:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01048e1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01048e8:	00 
c01048e9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01048f0:	00 
c01048f1:	89 04 24             	mov    %eax,(%esp)
c01048f4:	e8 5c fa ff ff       	call   c0104355 <get_pte>
c01048f9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01048fc:	74 24                	je     c0104922 <check_pgdir+0x25e>
c01048fe:	c7 44 24 0c c4 6b 10 	movl   $0xc0106bc4,0xc(%esp)
c0104905:	c0 
c0104906:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c010490d:	c0 
c010490e:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
c0104915:	00 
c0104916:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c010491d:	e8 b0 c3 ff ff       	call   c0100cd2 <__panic>

    p2 = alloc_page();
c0104922:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104929:	e8 6b f3 ff ff       	call   c0103c99 <alloc_pages>
c010492e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104931:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104936:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c010493d:	00 
c010493e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104945:	00 
c0104946:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104949:	89 54 24 04          	mov    %edx,0x4(%esp)
c010494d:	89 04 24             	mov    %eax,(%esp)
c0104950:	e8 3b fc ff ff       	call   c0104590 <page_insert>
c0104955:	85 c0                	test   %eax,%eax
c0104957:	74 24                	je     c010497d <check_pgdir+0x2b9>
c0104959:	c7 44 24 0c ec 6b 10 	movl   $0xc0106bec,0xc(%esp)
c0104960:	c0 
c0104961:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104968:	c0 
c0104969:	c7 44 24 04 e5 01 00 	movl   $0x1e5,0x4(%esp)
c0104970:	00 
c0104971:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104978:	e8 55 c3 ff ff       	call   c0100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c010497d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104982:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104989:	00 
c010498a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104991:	00 
c0104992:	89 04 24             	mov    %eax,(%esp)
c0104995:	e8 bb f9 ff ff       	call   c0104355 <get_pte>
c010499a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010499d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01049a1:	75 24                	jne    c01049c7 <check_pgdir+0x303>
c01049a3:	c7 44 24 0c 24 6c 10 	movl   $0xc0106c24,0xc(%esp)
c01049aa:	c0 
c01049ab:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c01049b2:	c0 
c01049b3:	c7 44 24 04 e6 01 00 	movl   $0x1e6,0x4(%esp)
c01049ba:	00 
c01049bb:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01049c2:	e8 0b c3 ff ff       	call   c0100cd2 <__panic>
    assert(*ptep & PTE_U);
c01049c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049ca:	8b 00                	mov    (%eax),%eax
c01049cc:	83 e0 04             	and    $0x4,%eax
c01049cf:	85 c0                	test   %eax,%eax
c01049d1:	75 24                	jne    c01049f7 <check_pgdir+0x333>
c01049d3:	c7 44 24 0c 54 6c 10 	movl   $0xc0106c54,0xc(%esp)
c01049da:	c0 
c01049db:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c01049e2:	c0 
c01049e3:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c01049ea:	00 
c01049eb:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c01049f2:	e8 db c2 ff ff       	call   c0100cd2 <__panic>
    assert(*ptep & PTE_W);
c01049f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01049fa:	8b 00                	mov    (%eax),%eax
c01049fc:	83 e0 02             	and    $0x2,%eax
c01049ff:	85 c0                	test   %eax,%eax
c0104a01:	75 24                	jne    c0104a27 <check_pgdir+0x363>
c0104a03:	c7 44 24 0c 62 6c 10 	movl   $0xc0106c62,0xc(%esp)
c0104a0a:	c0 
c0104a0b:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104a12:	c0 
c0104a13:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0104a1a:	00 
c0104a1b:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104a22:	e8 ab c2 ff ff       	call   c0100cd2 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104a27:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104a2c:	8b 00                	mov    (%eax),%eax
c0104a2e:	83 e0 04             	and    $0x4,%eax
c0104a31:	85 c0                	test   %eax,%eax
c0104a33:	75 24                	jne    c0104a59 <check_pgdir+0x395>
c0104a35:	c7 44 24 0c 70 6c 10 	movl   $0xc0106c70,0xc(%esp)
c0104a3c:	c0 
c0104a3d:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104a44:	c0 
c0104a45:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c0104a4c:	00 
c0104a4d:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104a54:	e8 79 c2 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 1);
c0104a59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a5c:	89 04 24             	mov    %eax,(%esp)
c0104a5f:	e8 30 f0 ff ff       	call   c0103a94 <page_ref>
c0104a64:	83 f8 01             	cmp    $0x1,%eax
c0104a67:	74 24                	je     c0104a8d <check_pgdir+0x3c9>
c0104a69:	c7 44 24 0c 86 6c 10 	movl   $0xc0106c86,0xc(%esp)
c0104a70:	c0 
c0104a71:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104a78:	c0 
c0104a79:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c0104a80:	00 
c0104a81:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104a88:	e8 45 c2 ff ff       	call   c0100cd2 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104a8d:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104a92:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104a99:	00 
c0104a9a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104aa1:	00 
c0104aa2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104aa5:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104aa9:	89 04 24             	mov    %eax,(%esp)
c0104aac:	e8 df fa ff ff       	call   c0104590 <page_insert>
c0104ab1:	85 c0                	test   %eax,%eax
c0104ab3:	74 24                	je     c0104ad9 <check_pgdir+0x415>
c0104ab5:	c7 44 24 0c 98 6c 10 	movl   $0xc0106c98,0xc(%esp)
c0104abc:	c0 
c0104abd:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104ac4:	c0 
c0104ac5:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c0104acc:	00 
c0104acd:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104ad4:	e8 f9 c1 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p1) == 2);
c0104ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104adc:	89 04 24             	mov    %eax,(%esp)
c0104adf:	e8 b0 ef ff ff       	call   c0103a94 <page_ref>
c0104ae4:	83 f8 02             	cmp    $0x2,%eax
c0104ae7:	74 24                	je     c0104b0d <check_pgdir+0x449>
c0104ae9:	c7 44 24 0c c4 6c 10 	movl   $0xc0106cc4,0xc(%esp)
c0104af0:	c0 
c0104af1:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104af8:	c0 
c0104af9:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c0104b00:	00 
c0104b01:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104b08:	e8 c5 c1 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 0);
c0104b0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b10:	89 04 24             	mov    %eax,(%esp)
c0104b13:	e8 7c ef ff ff       	call   c0103a94 <page_ref>
c0104b18:	85 c0                	test   %eax,%eax
c0104b1a:	74 24                	je     c0104b40 <check_pgdir+0x47c>
c0104b1c:	c7 44 24 0c d6 6c 10 	movl   $0xc0106cd6,0xc(%esp)
c0104b23:	c0 
c0104b24:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104b2b:	c0 
c0104b2c:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c0104b33:	00 
c0104b34:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104b3b:	e8 92 c1 ff ff       	call   c0100cd2 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104b40:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104b45:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b4c:	00 
c0104b4d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104b54:	00 
c0104b55:	89 04 24             	mov    %eax,(%esp)
c0104b58:	e8 f8 f7 ff ff       	call   c0104355 <get_pte>
c0104b5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104b60:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b64:	75 24                	jne    c0104b8a <check_pgdir+0x4c6>
c0104b66:	c7 44 24 0c 24 6c 10 	movl   $0xc0106c24,0xc(%esp)
c0104b6d:	c0 
c0104b6e:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104b75:	c0 
c0104b76:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c0104b7d:	00 
c0104b7e:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104b85:	e8 48 c1 ff ff       	call   c0100cd2 <__panic>
    assert(pte2page(*ptep) == p1);
c0104b8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b8d:	8b 00                	mov    (%eax),%eax
c0104b8f:	89 04 24             	mov    %eax,(%esp)
c0104b92:	e8 a7 ee ff ff       	call   c0103a3e <pte2page>
c0104b97:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104b9a:	74 24                	je     c0104bc0 <check_pgdir+0x4fc>
c0104b9c:	c7 44 24 0c 99 6b 10 	movl   $0xc0106b99,0xc(%esp)
c0104ba3:	c0 
c0104ba4:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104bab:	c0 
c0104bac:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0104bb3:	00 
c0104bb4:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104bbb:	e8 12 c1 ff ff       	call   c0100cd2 <__panic>
    assert((*ptep & PTE_U) == 0);
c0104bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bc3:	8b 00                	mov    (%eax),%eax
c0104bc5:	83 e0 04             	and    $0x4,%eax
c0104bc8:	85 c0                	test   %eax,%eax
c0104bca:	74 24                	je     c0104bf0 <check_pgdir+0x52c>
c0104bcc:	c7 44 24 0c e8 6c 10 	movl   $0xc0106ce8,0xc(%esp)
c0104bd3:	c0 
c0104bd4:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104bdb:	c0 
c0104bdc:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0104be3:	00 
c0104be4:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104beb:	e8 e2 c0 ff ff       	call   c0100cd2 <__panic>

    page_remove(boot_pgdir, 0x0);
c0104bf0:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104bf5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104bfc:	00 
c0104bfd:	89 04 24             	mov    %eax,(%esp)
c0104c00:	e8 47 f9 ff ff       	call   c010454c <page_remove>
    assert(page_ref(p1) == 1);
c0104c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c08:	89 04 24             	mov    %eax,(%esp)
c0104c0b:	e8 84 ee ff ff       	call   c0103a94 <page_ref>
c0104c10:	83 f8 01             	cmp    $0x1,%eax
c0104c13:	74 24                	je     c0104c39 <check_pgdir+0x575>
c0104c15:	c7 44 24 0c af 6b 10 	movl   $0xc0106baf,0xc(%esp)
c0104c1c:	c0 
c0104c1d:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104c24:	c0 
c0104c25:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0104c2c:	00 
c0104c2d:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104c34:	e8 99 c0 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 0);
c0104c39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c3c:	89 04 24             	mov    %eax,(%esp)
c0104c3f:	e8 50 ee ff ff       	call   c0103a94 <page_ref>
c0104c44:	85 c0                	test   %eax,%eax
c0104c46:	74 24                	je     c0104c6c <check_pgdir+0x5a8>
c0104c48:	c7 44 24 0c d6 6c 10 	movl   $0xc0106cd6,0xc(%esp)
c0104c4f:	c0 
c0104c50:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104c57:	c0 
c0104c58:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0104c5f:	00 
c0104c60:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104c67:	e8 66 c0 ff ff       	call   c0100cd2 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104c6c:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104c71:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104c78:	00 
c0104c79:	89 04 24             	mov    %eax,(%esp)
c0104c7c:	e8 cb f8 ff ff       	call   c010454c <page_remove>
    assert(page_ref(p1) == 0);
c0104c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c84:	89 04 24             	mov    %eax,(%esp)
c0104c87:	e8 08 ee ff ff       	call   c0103a94 <page_ref>
c0104c8c:	85 c0                	test   %eax,%eax
c0104c8e:	74 24                	je     c0104cb4 <check_pgdir+0x5f0>
c0104c90:	c7 44 24 0c fd 6c 10 	movl   $0xc0106cfd,0xc(%esp)
c0104c97:	c0 
c0104c98:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104c9f:	c0 
c0104ca0:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c0104ca7:	00 
c0104ca8:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104caf:	e8 1e c0 ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p2) == 0);
c0104cb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104cb7:	89 04 24             	mov    %eax,(%esp)
c0104cba:	e8 d5 ed ff ff       	call   c0103a94 <page_ref>
c0104cbf:	85 c0                	test   %eax,%eax
c0104cc1:	74 24                	je     c0104ce7 <check_pgdir+0x623>
c0104cc3:	c7 44 24 0c d6 6c 10 	movl   $0xc0106cd6,0xc(%esp)
c0104cca:	c0 
c0104ccb:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104cd2:	c0 
c0104cd3:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0104cda:	00 
c0104cdb:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104ce2:	e8 eb bf ff ff       	call   c0100cd2 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0104ce7:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104cec:	8b 00                	mov    (%eax),%eax
c0104cee:	89 04 24             	mov    %eax,(%esp)
c0104cf1:	e8 86 ed ff ff       	call   c0103a7c <pde2page>
c0104cf6:	89 04 24             	mov    %eax,(%esp)
c0104cf9:	e8 96 ed ff ff       	call   c0103a94 <page_ref>
c0104cfe:	83 f8 01             	cmp    $0x1,%eax
c0104d01:	74 24                	je     c0104d27 <check_pgdir+0x663>
c0104d03:	c7 44 24 0c 10 6d 10 	movl   $0xc0106d10,0xc(%esp)
c0104d0a:	c0 
c0104d0b:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104d12:	c0 
c0104d13:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0104d1a:	00 
c0104d1b:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104d22:	e8 ab bf ff ff       	call   c0100cd2 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0104d27:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104d2c:	8b 00                	mov    (%eax),%eax
c0104d2e:	89 04 24             	mov    %eax,(%esp)
c0104d31:	e8 46 ed ff ff       	call   c0103a7c <pde2page>
c0104d36:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d3d:	00 
c0104d3e:	89 04 24             	mov    %eax,(%esp)
c0104d41:	e8 8b ef ff ff       	call   c0103cd1 <free_pages>
    boot_pgdir[0] = 0;
c0104d46:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104d4b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0104d51:	c7 04 24 37 6d 10 c0 	movl   $0xc0106d37,(%esp)
c0104d58:	e8 eb b5 ff ff       	call   c0100348 <cprintf>
}
c0104d5d:	c9                   	leave  
c0104d5e:	c3                   	ret    

c0104d5f <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0104d5f:	55                   	push   %ebp
c0104d60:	89 e5                	mov    %esp,%ebp
c0104d62:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104d65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104d6c:	e9 ca 00 00 00       	jmp    c0104e3b <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0104d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d74:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d77:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d7a:	c1 e8 0c             	shr    $0xc,%eax
c0104d7d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104d80:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104d85:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104d88:	72 23                	jb     c0104dad <check_boot_pgdir+0x4e>
c0104d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104d91:	c7 44 24 08 7c 69 10 	movl   $0xc010697c,0x8(%esp)
c0104d98:	c0 
c0104d99:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0104da0:	00 
c0104da1:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104da8:	e8 25 bf ff ff       	call   c0100cd2 <__panic>
c0104dad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104db0:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104db5:	89 c2                	mov    %eax,%edx
c0104db7:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104dbc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104dc3:	00 
c0104dc4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104dc8:	89 04 24             	mov    %eax,(%esp)
c0104dcb:	e8 85 f5 ff ff       	call   c0104355 <get_pte>
c0104dd0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104dd3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104dd7:	75 24                	jne    c0104dfd <check_boot_pgdir+0x9e>
c0104dd9:	c7 44 24 0c 54 6d 10 	movl   $0xc0106d54,0xc(%esp)
c0104de0:	c0 
c0104de1:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104de8:	c0 
c0104de9:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0104df0:	00 
c0104df1:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104df8:	e8 d5 be ff ff       	call   c0100cd2 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0104dfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e00:	8b 00                	mov    (%eax),%eax
c0104e02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e07:	89 c2                	mov    %eax,%edx
c0104e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e0c:	39 c2                	cmp    %eax,%edx
c0104e0e:	74 24                	je     c0104e34 <check_boot_pgdir+0xd5>
c0104e10:	c7 44 24 0c 91 6d 10 	movl   $0xc0106d91,0xc(%esp)
c0104e17:	c0 
c0104e18:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104e1f:	c0 
c0104e20:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c0104e27:	00 
c0104e28:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104e2f:	e8 9e be ff ff       	call   c0100cd2 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0104e34:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0104e3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104e3e:	a1 80 ae 11 c0       	mov    0xc011ae80,%eax
c0104e43:	39 c2                	cmp    %eax,%edx
c0104e45:	0f 82 26 ff ff ff    	jb     c0104d71 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0104e4b:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104e50:	05 ac 0f 00 00       	add    $0xfac,%eax
c0104e55:	8b 00                	mov    (%eax),%eax
c0104e57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e5c:	89 c2                	mov    %eax,%edx
c0104e5e:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104e63:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104e66:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0104e6d:	77 23                	ja     c0104e92 <check_boot_pgdir+0x133>
c0104e6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e72:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104e76:	c7 44 24 08 20 6a 10 	movl   $0xc0106a20,0x8(%esp)
c0104e7d:	c0 
c0104e7e:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0104e85:	00 
c0104e86:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104e8d:	e8 40 be ff ff       	call   c0100cd2 <__panic>
c0104e92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e95:	05 00 00 00 40       	add    $0x40000000,%eax
c0104e9a:	39 c2                	cmp    %eax,%edx
c0104e9c:	74 24                	je     c0104ec2 <check_boot_pgdir+0x163>
c0104e9e:	c7 44 24 0c a8 6d 10 	movl   $0xc0106da8,0xc(%esp)
c0104ea5:	c0 
c0104ea6:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104ead:	c0 
c0104eae:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0104eb5:	00 
c0104eb6:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104ebd:	e8 10 be ff ff       	call   c0100cd2 <__panic>

    assert(boot_pgdir[0] == 0);
c0104ec2:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104ec7:	8b 00                	mov    (%eax),%eax
c0104ec9:	85 c0                	test   %eax,%eax
c0104ecb:	74 24                	je     c0104ef1 <check_boot_pgdir+0x192>
c0104ecd:	c7 44 24 0c dc 6d 10 	movl   $0xc0106ddc,0xc(%esp)
c0104ed4:	c0 
c0104ed5:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104edc:	c0 
c0104edd:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0104ee4:	00 
c0104ee5:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104eec:	e8 e1 bd ff ff       	call   c0100cd2 <__panic>

    struct Page *p;
    p = alloc_page();
c0104ef1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ef8:	e8 9c ed ff ff       	call   c0103c99 <alloc_pages>
c0104efd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0104f00:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104f05:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104f0c:	00 
c0104f0d:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0104f14:	00 
c0104f15:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104f18:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104f1c:	89 04 24             	mov    %eax,(%esp)
c0104f1f:	e8 6c f6 ff ff       	call   c0104590 <page_insert>
c0104f24:	85 c0                	test   %eax,%eax
c0104f26:	74 24                	je     c0104f4c <check_boot_pgdir+0x1ed>
c0104f28:	c7 44 24 0c f0 6d 10 	movl   $0xc0106df0,0xc(%esp)
c0104f2f:	c0 
c0104f30:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104f37:	c0 
c0104f38:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c0104f3f:	00 
c0104f40:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104f47:	e8 86 bd ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p) == 1);
c0104f4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f4f:	89 04 24             	mov    %eax,(%esp)
c0104f52:	e8 3d eb ff ff       	call   c0103a94 <page_ref>
c0104f57:	83 f8 01             	cmp    $0x1,%eax
c0104f5a:	74 24                	je     c0104f80 <check_boot_pgdir+0x221>
c0104f5c:	c7 44 24 0c 1e 6e 10 	movl   $0xc0106e1e,0xc(%esp)
c0104f63:	c0 
c0104f64:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104f6b:	c0 
c0104f6c:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0104f73:	00 
c0104f74:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104f7b:	e8 52 bd ff ff       	call   c0100cd2 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0104f80:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c0104f85:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104f8c:	00 
c0104f8d:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0104f94:	00 
c0104f95:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104f98:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104f9c:	89 04 24             	mov    %eax,(%esp)
c0104f9f:	e8 ec f5 ff ff       	call   c0104590 <page_insert>
c0104fa4:	85 c0                	test   %eax,%eax
c0104fa6:	74 24                	je     c0104fcc <check_boot_pgdir+0x26d>
c0104fa8:	c7 44 24 0c 30 6e 10 	movl   $0xc0106e30,0xc(%esp)
c0104faf:	c0 
c0104fb0:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104fb7:	c0 
c0104fb8:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0104fbf:	00 
c0104fc0:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104fc7:	e8 06 bd ff ff       	call   c0100cd2 <__panic>
    assert(page_ref(p) == 2);
c0104fcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104fcf:	89 04 24             	mov    %eax,(%esp)
c0104fd2:	e8 bd ea ff ff       	call   c0103a94 <page_ref>
c0104fd7:	83 f8 02             	cmp    $0x2,%eax
c0104fda:	74 24                	je     c0105000 <check_boot_pgdir+0x2a1>
c0104fdc:	c7 44 24 0c 67 6e 10 	movl   $0xc0106e67,0xc(%esp)
c0104fe3:	c0 
c0104fe4:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0104feb:	c0 
c0104fec:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0104ff3:	00 
c0104ff4:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0104ffb:	e8 d2 bc ff ff       	call   c0100cd2 <__panic>

    const char *str = "ucore: Hello world!!";
c0105000:	c7 45 dc 78 6e 10 c0 	movl   $0xc0106e78,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0105007:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010500a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010500e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105015:	e8 19 0a 00 00       	call   c0105a33 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c010501a:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0105021:	00 
c0105022:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105029:	e8 7e 0a 00 00       	call   c0105aac <strcmp>
c010502e:	85 c0                	test   %eax,%eax
c0105030:	74 24                	je     c0105056 <check_boot_pgdir+0x2f7>
c0105032:	c7 44 24 0c 90 6e 10 	movl   $0xc0106e90,0xc(%esp)
c0105039:	c0 
c010503a:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0105041:	c0 
c0105042:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0105049:	00 
c010504a:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0105051:	e8 7c bc ff ff       	call   c0100cd2 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0105056:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105059:	89 04 24             	mov    %eax,(%esp)
c010505c:	e8 89 e9 ff ff       	call   c01039ea <page2kva>
c0105061:	05 00 01 00 00       	add    $0x100,%eax
c0105066:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0105069:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0105070:	e8 66 09 00 00       	call   c01059db <strlen>
c0105075:	85 c0                	test   %eax,%eax
c0105077:	74 24                	je     c010509d <check_boot_pgdir+0x33e>
c0105079:	c7 44 24 0c c8 6e 10 	movl   $0xc0106ec8,0xc(%esp)
c0105080:	c0 
c0105081:	c7 44 24 08 69 6a 10 	movl   $0xc0106a69,0x8(%esp)
c0105088:	c0 
c0105089:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0105090:	00 
c0105091:	c7 04 24 44 6a 10 c0 	movl   $0xc0106a44,(%esp)
c0105098:	e8 35 bc ff ff       	call   c0100cd2 <__panic>

    free_page(p);
c010509d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050a4:	00 
c01050a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01050a8:	89 04 24             	mov    %eax,(%esp)
c01050ab:	e8 21 ec ff ff       	call   c0103cd1 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c01050b0:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01050b5:	8b 00                	mov    (%eax),%eax
c01050b7:	89 04 24             	mov    %eax,(%esp)
c01050ba:	e8 bd e9 ff ff       	call   c0103a7c <pde2page>
c01050bf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050c6:	00 
c01050c7:	89 04 24             	mov    %eax,(%esp)
c01050ca:	e8 02 ec ff ff       	call   c0103cd1 <free_pages>
    boot_pgdir[0] = 0;
c01050cf:	a1 e0 79 11 c0       	mov    0xc01179e0,%eax
c01050d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c01050da:	c7 04 24 ec 6e 10 c0 	movl   $0xc0106eec,(%esp)
c01050e1:	e8 62 b2 ff ff       	call   c0100348 <cprintf>
}
c01050e6:	c9                   	leave  
c01050e7:	c3                   	ret    

c01050e8 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c01050e8:	55                   	push   %ebp
c01050e9:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c01050eb:	8b 45 08             	mov    0x8(%ebp),%eax
c01050ee:	83 e0 04             	and    $0x4,%eax
c01050f1:	85 c0                	test   %eax,%eax
c01050f3:	74 07                	je     c01050fc <perm2str+0x14>
c01050f5:	b8 75 00 00 00       	mov    $0x75,%eax
c01050fa:	eb 05                	jmp    c0105101 <perm2str+0x19>
c01050fc:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105101:	a2 08 af 11 c0       	mov    %al,0xc011af08
    str[1] = 'r';
c0105106:	c6 05 09 af 11 c0 72 	movb   $0x72,0xc011af09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c010510d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105110:	83 e0 02             	and    $0x2,%eax
c0105113:	85 c0                	test   %eax,%eax
c0105115:	74 07                	je     c010511e <perm2str+0x36>
c0105117:	b8 77 00 00 00       	mov    $0x77,%eax
c010511c:	eb 05                	jmp    c0105123 <perm2str+0x3b>
c010511e:	b8 2d 00 00 00       	mov    $0x2d,%eax
c0105123:	a2 0a af 11 c0       	mov    %al,0xc011af0a
    str[3] = '\0';
c0105128:	c6 05 0b af 11 c0 00 	movb   $0x0,0xc011af0b
    return str;
c010512f:	b8 08 af 11 c0       	mov    $0xc011af08,%eax
}
c0105134:	5d                   	pop    %ebp
c0105135:	c3                   	ret    

c0105136 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0105136:	55                   	push   %ebp
c0105137:	89 e5                	mov    %esp,%ebp
c0105139:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c010513c:	8b 45 10             	mov    0x10(%ebp),%eax
c010513f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105142:	72 0a                	jb     c010514e <get_pgtable_items+0x18>
        return 0;
c0105144:	b8 00 00 00 00       	mov    $0x0,%eax
c0105149:	e9 9c 00 00 00       	jmp    c01051ea <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c010514e:	eb 04                	jmp    c0105154 <get_pgtable_items+0x1e>
        start ++;
c0105150:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0105154:	8b 45 10             	mov    0x10(%ebp),%eax
c0105157:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010515a:	73 18                	jae    c0105174 <get_pgtable_items+0x3e>
c010515c:	8b 45 10             	mov    0x10(%ebp),%eax
c010515f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105166:	8b 45 14             	mov    0x14(%ebp),%eax
c0105169:	01 d0                	add    %edx,%eax
c010516b:	8b 00                	mov    (%eax),%eax
c010516d:	83 e0 01             	and    $0x1,%eax
c0105170:	85 c0                	test   %eax,%eax
c0105172:	74 dc                	je     c0105150 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c0105174:	8b 45 10             	mov    0x10(%ebp),%eax
c0105177:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010517a:	73 69                	jae    c01051e5 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c010517c:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0105180:	74 08                	je     c010518a <get_pgtable_items+0x54>
            *left_store = start;
c0105182:	8b 45 18             	mov    0x18(%ebp),%eax
c0105185:	8b 55 10             	mov    0x10(%ebp),%edx
c0105188:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c010518a:	8b 45 10             	mov    0x10(%ebp),%eax
c010518d:	8d 50 01             	lea    0x1(%eax),%edx
c0105190:	89 55 10             	mov    %edx,0x10(%ebp)
c0105193:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010519a:	8b 45 14             	mov    0x14(%ebp),%eax
c010519d:	01 d0                	add    %edx,%eax
c010519f:	8b 00                	mov    (%eax),%eax
c01051a1:	83 e0 07             	and    $0x7,%eax
c01051a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01051a7:	eb 04                	jmp    c01051ad <get_pgtable_items+0x77>
            start ++;
c01051a9:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c01051ad:	8b 45 10             	mov    0x10(%ebp),%eax
c01051b0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01051b3:	73 1d                	jae    c01051d2 <get_pgtable_items+0x9c>
c01051b5:	8b 45 10             	mov    0x10(%ebp),%eax
c01051b8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01051bf:	8b 45 14             	mov    0x14(%ebp),%eax
c01051c2:	01 d0                	add    %edx,%eax
c01051c4:	8b 00                	mov    (%eax),%eax
c01051c6:	83 e0 07             	and    $0x7,%eax
c01051c9:	89 c2                	mov    %eax,%edx
c01051cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01051ce:	39 c2                	cmp    %eax,%edx
c01051d0:	74 d7                	je     c01051a9 <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c01051d2:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01051d6:	74 08                	je     c01051e0 <get_pgtable_items+0xaa>
            *right_store = start;
c01051d8:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01051db:	8b 55 10             	mov    0x10(%ebp),%edx
c01051de:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c01051e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01051e3:	eb 05                	jmp    c01051ea <get_pgtable_items+0xb4>
    }
    return 0;
c01051e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01051ea:	c9                   	leave  
c01051eb:	c3                   	ret    

c01051ec <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c01051ec:	55                   	push   %ebp
c01051ed:	89 e5                	mov    %esp,%ebp
c01051ef:	57                   	push   %edi
c01051f0:	56                   	push   %esi
c01051f1:	53                   	push   %ebx
c01051f2:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c01051f5:	c7 04 24 0c 6f 10 c0 	movl   $0xc0106f0c,(%esp)
c01051fc:	e8 47 b1 ff ff       	call   c0100348 <cprintf>
    size_t left, right = 0, perm;
c0105201:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105208:	e9 fa 00 00 00       	jmp    c0105307 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010520d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105210:	89 04 24             	mov    %eax,(%esp)
c0105213:	e8 d0 fe ff ff       	call   c01050e8 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105218:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010521b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010521e:	29 d1                	sub    %edx,%ecx
c0105220:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0105222:	89 d6                	mov    %edx,%esi
c0105224:	c1 e6 16             	shl    $0x16,%esi
c0105227:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010522a:	89 d3                	mov    %edx,%ebx
c010522c:	c1 e3 16             	shl    $0x16,%ebx
c010522f:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105232:	89 d1                	mov    %edx,%ecx
c0105234:	c1 e1 16             	shl    $0x16,%ecx
c0105237:	8b 7d dc             	mov    -0x24(%ebp),%edi
c010523a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010523d:	29 d7                	sub    %edx,%edi
c010523f:	89 fa                	mov    %edi,%edx
c0105241:	89 44 24 14          	mov    %eax,0x14(%esp)
c0105245:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105249:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010524d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105251:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105255:	c7 04 24 3d 6f 10 c0 	movl   $0xc0106f3d,(%esp)
c010525c:	e8 e7 b0 ff ff       	call   c0100348 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0105261:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105264:	c1 e0 0a             	shl    $0xa,%eax
c0105267:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010526a:	eb 54                	jmp    c01052c0 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010526c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010526f:	89 04 24             	mov    %eax,(%esp)
c0105272:	e8 71 fe ff ff       	call   c01050e8 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0105277:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010527a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010527d:	29 d1                	sub    %edx,%ecx
c010527f:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0105281:	89 d6                	mov    %edx,%esi
c0105283:	c1 e6 0c             	shl    $0xc,%esi
c0105286:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105289:	89 d3                	mov    %edx,%ebx
c010528b:	c1 e3 0c             	shl    $0xc,%ebx
c010528e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105291:	c1 e2 0c             	shl    $0xc,%edx
c0105294:	89 d1                	mov    %edx,%ecx
c0105296:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0105299:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010529c:	29 d7                	sub    %edx,%edi
c010529e:	89 fa                	mov    %edi,%edx
c01052a0:	89 44 24 14          	mov    %eax,0x14(%esp)
c01052a4:	89 74 24 10          	mov    %esi,0x10(%esp)
c01052a8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01052ac:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01052b0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01052b4:	c7 04 24 5c 6f 10 c0 	movl   $0xc0106f5c,(%esp)
c01052bb:	e8 88 b0 ff ff       	call   c0100348 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01052c0:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c01052c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01052c8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01052cb:	89 ce                	mov    %ecx,%esi
c01052cd:	c1 e6 0a             	shl    $0xa,%esi
c01052d0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c01052d3:	89 cb                	mov    %ecx,%ebx
c01052d5:	c1 e3 0a             	shl    $0xa,%ebx
c01052d8:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c01052db:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c01052df:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c01052e2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01052e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01052ea:	89 44 24 08          	mov    %eax,0x8(%esp)
c01052ee:	89 74 24 04          	mov    %esi,0x4(%esp)
c01052f2:	89 1c 24             	mov    %ebx,(%esp)
c01052f5:	e8 3c fe ff ff       	call   c0105136 <get_pgtable_items>
c01052fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01052fd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105301:	0f 85 65 ff ff ff    	jne    c010526c <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105307:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c010530c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010530f:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0105312:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0105316:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0105319:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010531d:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105321:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105325:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c010532c:	00 
c010532d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0105334:	e8 fd fd ff ff       	call   c0105136 <get_pgtable_items>
c0105339:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010533c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105340:	0f 85 c7 fe ff ff    	jne    c010520d <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0105346:	c7 04 24 80 6f 10 c0 	movl   $0xc0106f80,(%esp)
c010534d:	e8 f6 af ff ff       	call   c0100348 <cprintf>
}
c0105352:	83 c4 4c             	add    $0x4c,%esp
c0105355:	5b                   	pop    %ebx
c0105356:	5e                   	pop    %esi
c0105357:	5f                   	pop    %edi
c0105358:	5d                   	pop    %ebp
c0105359:	c3                   	ret    

c010535a <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010535a:	55                   	push   %ebp
c010535b:	89 e5                	mov    %esp,%ebp
c010535d:	83 ec 58             	sub    $0x58,%esp
c0105360:	8b 45 10             	mov    0x10(%ebp),%eax
c0105363:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105366:	8b 45 14             	mov    0x14(%ebp),%eax
c0105369:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010536c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010536f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105372:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105375:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0105378:	8b 45 18             	mov    0x18(%ebp),%eax
c010537b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010537e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105381:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105384:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105387:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010538a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010538d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105390:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105394:	74 1c                	je     c01053b2 <printnum+0x58>
c0105396:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105399:	ba 00 00 00 00       	mov    $0x0,%edx
c010539e:	f7 75 e4             	divl   -0x1c(%ebp)
c01053a1:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01053a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01053a7:	ba 00 00 00 00       	mov    $0x0,%edx
c01053ac:	f7 75 e4             	divl   -0x1c(%ebp)
c01053af:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01053b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01053b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01053b8:	f7 75 e4             	divl   -0x1c(%ebp)
c01053bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01053be:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01053c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01053c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01053c7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01053ca:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01053cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053d0:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c01053d3:	8b 45 18             	mov    0x18(%ebp),%eax
c01053d6:	ba 00 00 00 00       	mov    $0x0,%edx
c01053db:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01053de:	77 56                	ja     c0105436 <printnum+0xdc>
c01053e0:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01053e3:	72 05                	jb     c01053ea <printnum+0x90>
c01053e5:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01053e8:	77 4c                	ja     c0105436 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c01053ea:	8b 45 1c             	mov    0x1c(%ebp),%eax
c01053ed:	8d 50 ff             	lea    -0x1(%eax),%edx
c01053f0:	8b 45 20             	mov    0x20(%ebp),%eax
c01053f3:	89 44 24 18          	mov    %eax,0x18(%esp)
c01053f7:	89 54 24 14          	mov    %edx,0x14(%esp)
c01053fb:	8b 45 18             	mov    0x18(%ebp),%eax
c01053fe:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105402:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105405:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105408:	89 44 24 08          	mov    %eax,0x8(%esp)
c010540c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105410:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105413:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105417:	8b 45 08             	mov    0x8(%ebp),%eax
c010541a:	89 04 24             	mov    %eax,(%esp)
c010541d:	e8 38 ff ff ff       	call   c010535a <printnum>
c0105422:	eb 1c                	jmp    c0105440 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105424:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105427:	89 44 24 04          	mov    %eax,0x4(%esp)
c010542b:	8b 45 20             	mov    0x20(%ebp),%eax
c010542e:	89 04 24             	mov    %eax,(%esp)
c0105431:	8b 45 08             	mov    0x8(%ebp),%eax
c0105434:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c0105436:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010543a:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010543e:	7f e4                	jg     c0105424 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105440:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105443:	05 34 70 10 c0       	add    $0xc0107034,%eax
c0105448:	0f b6 00             	movzbl (%eax),%eax
c010544b:	0f be c0             	movsbl %al,%eax
c010544e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105451:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105455:	89 04 24             	mov    %eax,(%esp)
c0105458:	8b 45 08             	mov    0x8(%ebp),%eax
c010545b:	ff d0                	call   *%eax
}
c010545d:	c9                   	leave  
c010545e:	c3                   	ret    

c010545f <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010545f:	55                   	push   %ebp
c0105460:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105462:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105466:	7e 14                	jle    c010547c <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0105468:	8b 45 08             	mov    0x8(%ebp),%eax
c010546b:	8b 00                	mov    (%eax),%eax
c010546d:	8d 48 08             	lea    0x8(%eax),%ecx
c0105470:	8b 55 08             	mov    0x8(%ebp),%edx
c0105473:	89 0a                	mov    %ecx,(%edx)
c0105475:	8b 50 04             	mov    0x4(%eax),%edx
c0105478:	8b 00                	mov    (%eax),%eax
c010547a:	eb 30                	jmp    c01054ac <getuint+0x4d>
    }
    else if (lflag) {
c010547c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105480:	74 16                	je     c0105498 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0105482:	8b 45 08             	mov    0x8(%ebp),%eax
c0105485:	8b 00                	mov    (%eax),%eax
c0105487:	8d 48 04             	lea    0x4(%eax),%ecx
c010548a:	8b 55 08             	mov    0x8(%ebp),%edx
c010548d:	89 0a                	mov    %ecx,(%edx)
c010548f:	8b 00                	mov    (%eax),%eax
c0105491:	ba 00 00 00 00       	mov    $0x0,%edx
c0105496:	eb 14                	jmp    c01054ac <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105498:	8b 45 08             	mov    0x8(%ebp),%eax
c010549b:	8b 00                	mov    (%eax),%eax
c010549d:	8d 48 04             	lea    0x4(%eax),%ecx
c01054a0:	8b 55 08             	mov    0x8(%ebp),%edx
c01054a3:	89 0a                	mov    %ecx,(%edx)
c01054a5:	8b 00                	mov    (%eax),%eax
c01054a7:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c01054ac:	5d                   	pop    %ebp
c01054ad:	c3                   	ret    

c01054ae <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c01054ae:	55                   	push   %ebp
c01054af:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01054b1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01054b5:	7e 14                	jle    c01054cb <getint+0x1d>
        return va_arg(*ap, long long);
c01054b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01054ba:	8b 00                	mov    (%eax),%eax
c01054bc:	8d 48 08             	lea    0x8(%eax),%ecx
c01054bf:	8b 55 08             	mov    0x8(%ebp),%edx
c01054c2:	89 0a                	mov    %ecx,(%edx)
c01054c4:	8b 50 04             	mov    0x4(%eax),%edx
c01054c7:	8b 00                	mov    (%eax),%eax
c01054c9:	eb 28                	jmp    c01054f3 <getint+0x45>
    }
    else if (lflag) {
c01054cb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01054cf:	74 12                	je     c01054e3 <getint+0x35>
        return va_arg(*ap, long);
c01054d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01054d4:	8b 00                	mov    (%eax),%eax
c01054d6:	8d 48 04             	lea    0x4(%eax),%ecx
c01054d9:	8b 55 08             	mov    0x8(%ebp),%edx
c01054dc:	89 0a                	mov    %ecx,(%edx)
c01054de:	8b 00                	mov    (%eax),%eax
c01054e0:	99                   	cltd   
c01054e1:	eb 10                	jmp    c01054f3 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c01054e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01054e6:	8b 00                	mov    (%eax),%eax
c01054e8:	8d 48 04             	lea    0x4(%eax),%ecx
c01054eb:	8b 55 08             	mov    0x8(%ebp),%edx
c01054ee:	89 0a                	mov    %ecx,(%edx)
c01054f0:	8b 00                	mov    (%eax),%eax
c01054f2:	99                   	cltd   
    }
}
c01054f3:	5d                   	pop    %ebp
c01054f4:	c3                   	ret    

c01054f5 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c01054f5:	55                   	push   %ebp
c01054f6:	89 e5                	mov    %esp,%ebp
c01054f8:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c01054fb:	8d 45 14             	lea    0x14(%ebp),%eax
c01054fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105501:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105504:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105508:	8b 45 10             	mov    0x10(%ebp),%eax
c010550b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010550f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105512:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105516:	8b 45 08             	mov    0x8(%ebp),%eax
c0105519:	89 04 24             	mov    %eax,(%esp)
c010551c:	e8 02 00 00 00       	call   c0105523 <vprintfmt>
    va_end(ap);
}
c0105521:	c9                   	leave  
c0105522:	c3                   	ret    

c0105523 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0105523:	55                   	push   %ebp
c0105524:	89 e5                	mov    %esp,%ebp
c0105526:	56                   	push   %esi
c0105527:	53                   	push   %ebx
c0105528:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010552b:	eb 18                	jmp    c0105545 <vprintfmt+0x22>
            if (ch == '\0') {
c010552d:	85 db                	test   %ebx,%ebx
c010552f:	75 05                	jne    c0105536 <vprintfmt+0x13>
                return;
c0105531:	e9 d1 03 00 00       	jmp    c0105907 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c0105536:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105539:	89 44 24 04          	mov    %eax,0x4(%esp)
c010553d:	89 1c 24             	mov    %ebx,(%esp)
c0105540:	8b 45 08             	mov    0x8(%ebp),%eax
c0105543:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105545:	8b 45 10             	mov    0x10(%ebp),%eax
c0105548:	8d 50 01             	lea    0x1(%eax),%edx
c010554b:	89 55 10             	mov    %edx,0x10(%ebp)
c010554e:	0f b6 00             	movzbl (%eax),%eax
c0105551:	0f b6 d8             	movzbl %al,%ebx
c0105554:	83 fb 25             	cmp    $0x25,%ebx
c0105557:	75 d4                	jne    c010552d <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c0105559:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010555d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105564:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105567:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010556a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105571:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105574:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105577:	8b 45 10             	mov    0x10(%ebp),%eax
c010557a:	8d 50 01             	lea    0x1(%eax),%edx
c010557d:	89 55 10             	mov    %edx,0x10(%ebp)
c0105580:	0f b6 00             	movzbl (%eax),%eax
c0105583:	0f b6 d8             	movzbl %al,%ebx
c0105586:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0105589:	83 f8 55             	cmp    $0x55,%eax
c010558c:	0f 87 44 03 00 00    	ja     c01058d6 <vprintfmt+0x3b3>
c0105592:	8b 04 85 58 70 10 c0 	mov    -0x3fef8fa8(,%eax,4),%eax
c0105599:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010559b:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010559f:	eb d6                	jmp    c0105577 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c01055a1:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c01055a5:	eb d0                	jmp    c0105577 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01055a7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c01055ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01055b1:	89 d0                	mov    %edx,%eax
c01055b3:	c1 e0 02             	shl    $0x2,%eax
c01055b6:	01 d0                	add    %edx,%eax
c01055b8:	01 c0                	add    %eax,%eax
c01055ba:	01 d8                	add    %ebx,%eax
c01055bc:	83 e8 30             	sub    $0x30,%eax
c01055bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c01055c2:	8b 45 10             	mov    0x10(%ebp),%eax
c01055c5:	0f b6 00             	movzbl (%eax),%eax
c01055c8:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c01055cb:	83 fb 2f             	cmp    $0x2f,%ebx
c01055ce:	7e 0b                	jle    c01055db <vprintfmt+0xb8>
c01055d0:	83 fb 39             	cmp    $0x39,%ebx
c01055d3:	7f 06                	jg     c01055db <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c01055d5:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c01055d9:	eb d3                	jmp    c01055ae <vprintfmt+0x8b>
            goto process_precision;
c01055db:	eb 33                	jmp    c0105610 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c01055dd:	8b 45 14             	mov    0x14(%ebp),%eax
c01055e0:	8d 50 04             	lea    0x4(%eax),%edx
c01055e3:	89 55 14             	mov    %edx,0x14(%ebp)
c01055e6:	8b 00                	mov    (%eax),%eax
c01055e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c01055eb:	eb 23                	jmp    c0105610 <vprintfmt+0xed>

        case '.':
            if (width < 0)
c01055ed:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01055f1:	79 0c                	jns    c01055ff <vprintfmt+0xdc>
                width = 0;
c01055f3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01055fa:	e9 78 ff ff ff       	jmp    c0105577 <vprintfmt+0x54>
c01055ff:	e9 73 ff ff ff       	jmp    c0105577 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c0105604:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010560b:	e9 67 ff ff ff       	jmp    c0105577 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c0105610:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105614:	79 12                	jns    c0105628 <vprintfmt+0x105>
                width = precision, precision = -1;
c0105616:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105619:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010561c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105623:	e9 4f ff ff ff       	jmp    c0105577 <vprintfmt+0x54>
c0105628:	e9 4a ff ff ff       	jmp    c0105577 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010562d:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c0105631:	e9 41 ff ff ff       	jmp    c0105577 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105636:	8b 45 14             	mov    0x14(%ebp),%eax
c0105639:	8d 50 04             	lea    0x4(%eax),%edx
c010563c:	89 55 14             	mov    %edx,0x14(%ebp)
c010563f:	8b 00                	mov    (%eax),%eax
c0105641:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105644:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105648:	89 04 24             	mov    %eax,(%esp)
c010564b:	8b 45 08             	mov    0x8(%ebp),%eax
c010564e:	ff d0                	call   *%eax
            break;
c0105650:	e9 ac 02 00 00       	jmp    c0105901 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105655:	8b 45 14             	mov    0x14(%ebp),%eax
c0105658:	8d 50 04             	lea    0x4(%eax),%edx
c010565b:	89 55 14             	mov    %edx,0x14(%ebp)
c010565e:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105660:	85 db                	test   %ebx,%ebx
c0105662:	79 02                	jns    c0105666 <vprintfmt+0x143>
                err = -err;
c0105664:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105666:	83 fb 06             	cmp    $0x6,%ebx
c0105669:	7f 0b                	jg     c0105676 <vprintfmt+0x153>
c010566b:	8b 34 9d 18 70 10 c0 	mov    -0x3fef8fe8(,%ebx,4),%esi
c0105672:	85 f6                	test   %esi,%esi
c0105674:	75 23                	jne    c0105699 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c0105676:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010567a:	c7 44 24 08 45 70 10 	movl   $0xc0107045,0x8(%esp)
c0105681:	c0 
c0105682:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105685:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105689:	8b 45 08             	mov    0x8(%ebp),%eax
c010568c:	89 04 24             	mov    %eax,(%esp)
c010568f:	e8 61 fe ff ff       	call   c01054f5 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105694:	e9 68 02 00 00       	jmp    c0105901 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0105699:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010569d:	c7 44 24 08 4e 70 10 	movl   $0xc010704e,0x8(%esp)
c01056a4:	c0 
c01056a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01056a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01056af:	89 04 24             	mov    %eax,(%esp)
c01056b2:	e8 3e fe ff ff       	call   c01054f5 <printfmt>
            }
            break;
c01056b7:	e9 45 02 00 00       	jmp    c0105901 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c01056bc:	8b 45 14             	mov    0x14(%ebp),%eax
c01056bf:	8d 50 04             	lea    0x4(%eax),%edx
c01056c2:	89 55 14             	mov    %edx,0x14(%ebp)
c01056c5:	8b 30                	mov    (%eax),%esi
c01056c7:	85 f6                	test   %esi,%esi
c01056c9:	75 05                	jne    c01056d0 <vprintfmt+0x1ad>
                p = "(null)";
c01056cb:	be 51 70 10 c0       	mov    $0xc0107051,%esi
            }
            if (width > 0 && padc != '-') {
c01056d0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01056d4:	7e 3e                	jle    c0105714 <vprintfmt+0x1f1>
c01056d6:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c01056da:	74 38                	je     c0105714 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c01056dc:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c01056df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01056e2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056e6:	89 34 24             	mov    %esi,(%esp)
c01056e9:	e8 15 03 00 00       	call   c0105a03 <strnlen>
c01056ee:	29 c3                	sub    %eax,%ebx
c01056f0:	89 d8                	mov    %ebx,%eax
c01056f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01056f5:	eb 17                	jmp    c010570e <vprintfmt+0x1eb>
                    putch(padc, putdat);
c01056f7:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c01056fb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01056fe:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105702:	89 04 24             	mov    %eax,(%esp)
c0105705:	8b 45 08             	mov    0x8(%ebp),%eax
c0105708:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c010570a:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010570e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105712:	7f e3                	jg     c01056f7 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105714:	eb 38                	jmp    c010574e <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105716:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010571a:	74 1f                	je     c010573b <vprintfmt+0x218>
c010571c:	83 fb 1f             	cmp    $0x1f,%ebx
c010571f:	7e 05                	jle    c0105726 <vprintfmt+0x203>
c0105721:	83 fb 7e             	cmp    $0x7e,%ebx
c0105724:	7e 15                	jle    c010573b <vprintfmt+0x218>
                    putch('?', putdat);
c0105726:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105729:	89 44 24 04          	mov    %eax,0x4(%esp)
c010572d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105734:	8b 45 08             	mov    0x8(%ebp),%eax
c0105737:	ff d0                	call   *%eax
c0105739:	eb 0f                	jmp    c010574a <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c010573b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010573e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105742:	89 1c 24             	mov    %ebx,(%esp)
c0105745:	8b 45 08             	mov    0x8(%ebp),%eax
c0105748:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010574a:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010574e:	89 f0                	mov    %esi,%eax
c0105750:	8d 70 01             	lea    0x1(%eax),%esi
c0105753:	0f b6 00             	movzbl (%eax),%eax
c0105756:	0f be d8             	movsbl %al,%ebx
c0105759:	85 db                	test   %ebx,%ebx
c010575b:	74 10                	je     c010576d <vprintfmt+0x24a>
c010575d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105761:	78 b3                	js     c0105716 <vprintfmt+0x1f3>
c0105763:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c0105767:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010576b:	79 a9                	jns    c0105716 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010576d:	eb 17                	jmp    c0105786 <vprintfmt+0x263>
                putch(' ', putdat);
c010576f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105772:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105776:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010577d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105780:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0105782:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0105786:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010578a:	7f e3                	jg     c010576f <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c010578c:	e9 70 01 00 00       	jmp    c0105901 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105791:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105794:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105798:	8d 45 14             	lea    0x14(%ebp),%eax
c010579b:	89 04 24             	mov    %eax,(%esp)
c010579e:	e8 0b fd ff ff       	call   c01054ae <getint>
c01057a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01057a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c01057a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01057af:	85 d2                	test   %edx,%edx
c01057b1:	79 26                	jns    c01057d9 <vprintfmt+0x2b6>
                putch('-', putdat);
c01057b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057b6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057ba:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c01057c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01057c4:	ff d0                	call   *%eax
                num = -(long long)num;
c01057c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01057c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01057cc:	f7 d8                	neg    %eax
c01057ce:	83 d2 00             	adc    $0x0,%edx
c01057d1:	f7 da                	neg    %edx
c01057d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01057d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c01057d9:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01057e0:	e9 a8 00 00 00       	jmp    c010588d <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c01057e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057e8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01057ec:	8d 45 14             	lea    0x14(%ebp),%eax
c01057ef:	89 04 24             	mov    %eax,(%esp)
c01057f2:	e8 68 fc ff ff       	call   c010545f <getuint>
c01057f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01057fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c01057fd:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105804:	e9 84 00 00 00       	jmp    c010588d <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105809:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010580c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105810:	8d 45 14             	lea    0x14(%ebp),%eax
c0105813:	89 04 24             	mov    %eax,(%esp)
c0105816:	e8 44 fc ff ff       	call   c010545f <getuint>
c010581b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010581e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105821:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105828:	eb 63                	jmp    c010588d <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c010582a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010582d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105831:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105838:	8b 45 08             	mov    0x8(%ebp),%eax
c010583b:	ff d0                	call   *%eax
            putch('x', putdat);
c010583d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105840:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105844:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010584b:	8b 45 08             	mov    0x8(%ebp),%eax
c010584e:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105850:	8b 45 14             	mov    0x14(%ebp),%eax
c0105853:	8d 50 04             	lea    0x4(%eax),%edx
c0105856:	89 55 14             	mov    %edx,0x14(%ebp)
c0105859:	8b 00                	mov    (%eax),%eax
c010585b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010585e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105865:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010586c:	eb 1f                	jmp    c010588d <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010586e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105871:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105875:	8d 45 14             	lea    0x14(%ebp),%eax
c0105878:	89 04 24             	mov    %eax,(%esp)
c010587b:	e8 df fb ff ff       	call   c010545f <getuint>
c0105880:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105883:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105886:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010588d:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105891:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105894:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105898:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010589b:	89 54 24 14          	mov    %edx,0x14(%esp)
c010589f:	89 44 24 10          	mov    %eax,0x10(%esp)
c01058a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01058a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01058a9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01058ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01058b1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01058bb:	89 04 24             	mov    %eax,(%esp)
c01058be:	e8 97 fa ff ff       	call   c010535a <printnum>
            break;
c01058c3:	eb 3c                	jmp    c0105901 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c01058c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058c8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058cc:	89 1c 24             	mov    %ebx,(%esp)
c01058cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01058d2:	ff d0                	call   *%eax
            break;
c01058d4:	eb 2b                	jmp    c0105901 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01058d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058d9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058dd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c01058e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01058e7:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c01058e9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01058ed:	eb 04                	jmp    c01058f3 <vprintfmt+0x3d0>
c01058ef:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c01058f3:	8b 45 10             	mov    0x10(%ebp),%eax
c01058f6:	83 e8 01             	sub    $0x1,%eax
c01058f9:	0f b6 00             	movzbl (%eax),%eax
c01058fc:	3c 25                	cmp    $0x25,%al
c01058fe:	75 ef                	jne    c01058ef <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c0105900:	90                   	nop
        }
    }
c0105901:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105902:	e9 3e fc ff ff       	jmp    c0105545 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0105907:	83 c4 40             	add    $0x40,%esp
c010590a:	5b                   	pop    %ebx
c010590b:	5e                   	pop    %esi
c010590c:	5d                   	pop    %ebp
c010590d:	c3                   	ret    

c010590e <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010590e:	55                   	push   %ebp
c010590f:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105911:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105914:	8b 40 08             	mov    0x8(%eax),%eax
c0105917:	8d 50 01             	lea    0x1(%eax),%edx
c010591a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010591d:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105920:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105923:	8b 10                	mov    (%eax),%edx
c0105925:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105928:	8b 40 04             	mov    0x4(%eax),%eax
c010592b:	39 c2                	cmp    %eax,%edx
c010592d:	73 12                	jae    c0105941 <sprintputch+0x33>
        *b->buf ++ = ch;
c010592f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105932:	8b 00                	mov    (%eax),%eax
c0105934:	8d 48 01             	lea    0x1(%eax),%ecx
c0105937:	8b 55 0c             	mov    0xc(%ebp),%edx
c010593a:	89 0a                	mov    %ecx,(%edx)
c010593c:	8b 55 08             	mov    0x8(%ebp),%edx
c010593f:	88 10                	mov    %dl,(%eax)
    }
}
c0105941:	5d                   	pop    %ebp
c0105942:	c3                   	ret    

c0105943 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105943:	55                   	push   %ebp
c0105944:	89 e5                	mov    %esp,%ebp
c0105946:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105949:	8d 45 14             	lea    0x14(%ebp),%eax
c010594c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010594f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105952:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105956:	8b 45 10             	mov    0x10(%ebp),%eax
c0105959:	89 44 24 08          	mov    %eax,0x8(%esp)
c010595d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105960:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105964:	8b 45 08             	mov    0x8(%ebp),%eax
c0105967:	89 04 24             	mov    %eax,(%esp)
c010596a:	e8 08 00 00 00       	call   c0105977 <vsnprintf>
c010596f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105972:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105975:	c9                   	leave  
c0105976:	c3                   	ret    

c0105977 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105977:	55                   	push   %ebp
c0105978:	89 e5                	mov    %esp,%ebp
c010597a:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010597d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105980:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105983:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105986:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105989:	8b 45 08             	mov    0x8(%ebp),%eax
c010598c:	01 d0                	add    %edx,%eax
c010598e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105991:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105998:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010599c:	74 0a                	je     c01059a8 <vsnprintf+0x31>
c010599e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01059a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01059a4:	39 c2                	cmp    %eax,%edx
c01059a6:	76 07                	jbe    c01059af <vsnprintf+0x38>
        return -E_INVAL;
c01059a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01059ad:	eb 2a                	jmp    c01059d9 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01059af:	8b 45 14             	mov    0x14(%ebp),%eax
c01059b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01059b6:	8b 45 10             	mov    0x10(%ebp),%eax
c01059b9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01059bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01059c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059c4:	c7 04 24 0e 59 10 c0 	movl   $0xc010590e,(%esp)
c01059cb:	e8 53 fb ff ff       	call   c0105523 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c01059d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059d3:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c01059d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01059d9:	c9                   	leave  
c01059da:	c3                   	ret    

c01059db <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01059db:	55                   	push   %ebp
c01059dc:	89 e5                	mov    %esp,%ebp
c01059de:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01059e1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01059e8:	eb 04                	jmp    c01059ee <strlen+0x13>
        cnt ++;
c01059ea:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c01059ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01059f1:	8d 50 01             	lea    0x1(%eax),%edx
c01059f4:	89 55 08             	mov    %edx,0x8(%ebp)
c01059f7:	0f b6 00             	movzbl (%eax),%eax
c01059fa:	84 c0                	test   %al,%al
c01059fc:	75 ec                	jne    c01059ea <strlen+0xf>
        cnt ++;
    }
    return cnt;
c01059fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105a01:	c9                   	leave  
c0105a02:	c3                   	ret    

c0105a03 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105a03:	55                   	push   %ebp
c0105a04:	89 e5                	mov    %esp,%ebp
c0105a06:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105a09:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105a10:	eb 04                	jmp    c0105a16 <strnlen+0x13>
        cnt ++;
c0105a12:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0105a16:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105a19:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105a1c:	73 10                	jae    c0105a2e <strnlen+0x2b>
c0105a1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a21:	8d 50 01             	lea    0x1(%eax),%edx
c0105a24:	89 55 08             	mov    %edx,0x8(%ebp)
c0105a27:	0f b6 00             	movzbl (%eax),%eax
c0105a2a:	84 c0                	test   %al,%al
c0105a2c:	75 e4                	jne    c0105a12 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0105a2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105a31:	c9                   	leave  
c0105a32:	c3                   	ret    

c0105a33 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105a33:	55                   	push   %ebp
c0105a34:	89 e5                	mov    %esp,%ebp
c0105a36:	57                   	push   %edi
c0105a37:	56                   	push   %esi
c0105a38:	83 ec 20             	sub    $0x20,%esp
c0105a3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a41:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a44:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105a47:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a4d:	89 d1                	mov    %edx,%ecx
c0105a4f:	89 c2                	mov    %eax,%edx
c0105a51:	89 ce                	mov    %ecx,%esi
c0105a53:	89 d7                	mov    %edx,%edi
c0105a55:	ac                   	lods   %ds:(%esi),%al
c0105a56:	aa                   	stos   %al,%es:(%edi)
c0105a57:	84 c0                	test   %al,%al
c0105a59:	75 fa                	jne    c0105a55 <strcpy+0x22>
c0105a5b:	89 fa                	mov    %edi,%edx
c0105a5d:	89 f1                	mov    %esi,%ecx
c0105a5f:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105a62:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105a65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105a6b:	83 c4 20             	add    $0x20,%esp
c0105a6e:	5e                   	pop    %esi
c0105a6f:	5f                   	pop    %edi
c0105a70:	5d                   	pop    %ebp
c0105a71:	c3                   	ret    

c0105a72 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105a72:	55                   	push   %ebp
c0105a73:	89 e5                	mov    %esp,%ebp
c0105a75:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105a78:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105a7e:	eb 21                	jmp    c0105aa1 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c0105a80:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a83:	0f b6 10             	movzbl (%eax),%edx
c0105a86:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105a89:	88 10                	mov    %dl,(%eax)
c0105a8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105a8e:	0f b6 00             	movzbl (%eax),%eax
c0105a91:	84 c0                	test   %al,%al
c0105a93:	74 04                	je     c0105a99 <strncpy+0x27>
            src ++;
c0105a95:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c0105a99:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105a9d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0105aa1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105aa5:	75 d9                	jne    c0105a80 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0105aa7:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105aaa:	c9                   	leave  
c0105aab:	c3                   	ret    

c0105aac <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105aac:	55                   	push   %ebp
c0105aad:	89 e5                	mov    %esp,%ebp
c0105aaf:	57                   	push   %edi
c0105ab0:	56                   	push   %esi
c0105ab1:	83 ec 20             	sub    $0x20,%esp
c0105ab4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105aba:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105abd:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0105ac0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ac6:	89 d1                	mov    %edx,%ecx
c0105ac8:	89 c2                	mov    %eax,%edx
c0105aca:	89 ce                	mov    %ecx,%esi
c0105acc:	89 d7                	mov    %edx,%edi
c0105ace:	ac                   	lods   %ds:(%esi),%al
c0105acf:	ae                   	scas   %es:(%edi),%al
c0105ad0:	75 08                	jne    c0105ada <strcmp+0x2e>
c0105ad2:	84 c0                	test   %al,%al
c0105ad4:	75 f8                	jne    c0105ace <strcmp+0x22>
c0105ad6:	31 c0                	xor    %eax,%eax
c0105ad8:	eb 04                	jmp    c0105ade <strcmp+0x32>
c0105ada:	19 c0                	sbb    %eax,%eax
c0105adc:	0c 01                	or     $0x1,%al
c0105ade:	89 fa                	mov    %edi,%edx
c0105ae0:	89 f1                	mov    %esi,%ecx
c0105ae2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105ae5:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105ae8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0105aeb:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105aee:	83 c4 20             	add    $0x20,%esp
c0105af1:	5e                   	pop    %esi
c0105af2:	5f                   	pop    %edi
c0105af3:	5d                   	pop    %ebp
c0105af4:	c3                   	ret    

c0105af5 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105af5:	55                   	push   %ebp
c0105af6:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105af8:	eb 0c                	jmp    c0105b06 <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0105afa:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0105afe:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105b02:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105b06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b0a:	74 1a                	je     c0105b26 <strncmp+0x31>
c0105b0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b0f:	0f b6 00             	movzbl (%eax),%eax
c0105b12:	84 c0                	test   %al,%al
c0105b14:	74 10                	je     c0105b26 <strncmp+0x31>
c0105b16:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b19:	0f b6 10             	movzbl (%eax),%edx
c0105b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b1f:	0f b6 00             	movzbl (%eax),%eax
c0105b22:	38 c2                	cmp    %al,%dl
c0105b24:	74 d4                	je     c0105afa <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105b26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b2a:	74 18                	je     c0105b44 <strncmp+0x4f>
c0105b2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b2f:	0f b6 00             	movzbl (%eax),%eax
c0105b32:	0f b6 d0             	movzbl %al,%edx
c0105b35:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b38:	0f b6 00             	movzbl (%eax),%eax
c0105b3b:	0f b6 c0             	movzbl %al,%eax
c0105b3e:	29 c2                	sub    %eax,%edx
c0105b40:	89 d0                	mov    %edx,%eax
c0105b42:	eb 05                	jmp    c0105b49 <strncmp+0x54>
c0105b44:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105b49:	5d                   	pop    %ebp
c0105b4a:	c3                   	ret    

c0105b4b <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105b4b:	55                   	push   %ebp
c0105b4c:	89 e5                	mov    %esp,%ebp
c0105b4e:	83 ec 04             	sub    $0x4,%esp
c0105b51:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b54:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105b57:	eb 14                	jmp    c0105b6d <strchr+0x22>
        if (*s == c) {
c0105b59:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b5c:	0f b6 00             	movzbl (%eax),%eax
c0105b5f:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105b62:	75 05                	jne    c0105b69 <strchr+0x1e>
            return (char *)s;
c0105b64:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b67:	eb 13                	jmp    c0105b7c <strchr+0x31>
        }
        s ++;
c0105b69:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0105b6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b70:	0f b6 00             	movzbl (%eax),%eax
c0105b73:	84 c0                	test   %al,%al
c0105b75:	75 e2                	jne    c0105b59 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0105b77:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105b7c:	c9                   	leave  
c0105b7d:	c3                   	ret    

c0105b7e <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105b7e:	55                   	push   %ebp
c0105b7f:	89 e5                	mov    %esp,%ebp
c0105b81:	83 ec 04             	sub    $0x4,%esp
c0105b84:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b87:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105b8a:	eb 11                	jmp    c0105b9d <strfind+0x1f>
        if (*s == c) {
c0105b8c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b8f:	0f b6 00             	movzbl (%eax),%eax
c0105b92:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105b95:	75 02                	jne    c0105b99 <strfind+0x1b>
            break;
c0105b97:	eb 0e                	jmp    c0105ba7 <strfind+0x29>
        }
        s ++;
c0105b99:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0105b9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ba0:	0f b6 00             	movzbl (%eax),%eax
c0105ba3:	84 c0                	test   %al,%al
c0105ba5:	75 e5                	jne    c0105b8c <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c0105ba7:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105baa:	c9                   	leave  
c0105bab:	c3                   	ret    

c0105bac <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105bac:	55                   	push   %ebp
c0105bad:	89 e5                	mov    %esp,%ebp
c0105baf:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105bb2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105bb9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105bc0:	eb 04                	jmp    c0105bc6 <strtol+0x1a>
        s ++;
c0105bc2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105bc6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bc9:	0f b6 00             	movzbl (%eax),%eax
c0105bcc:	3c 20                	cmp    $0x20,%al
c0105bce:	74 f2                	je     c0105bc2 <strtol+0x16>
c0105bd0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bd3:	0f b6 00             	movzbl (%eax),%eax
c0105bd6:	3c 09                	cmp    $0x9,%al
c0105bd8:	74 e8                	je     c0105bc2 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0105bda:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bdd:	0f b6 00             	movzbl (%eax),%eax
c0105be0:	3c 2b                	cmp    $0x2b,%al
c0105be2:	75 06                	jne    c0105bea <strtol+0x3e>
        s ++;
c0105be4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105be8:	eb 15                	jmp    c0105bff <strtol+0x53>
    }
    else if (*s == '-') {
c0105bea:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bed:	0f b6 00             	movzbl (%eax),%eax
c0105bf0:	3c 2d                	cmp    $0x2d,%al
c0105bf2:	75 0b                	jne    c0105bff <strtol+0x53>
        s ++, neg = 1;
c0105bf4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105bf8:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105bff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c03:	74 06                	je     c0105c0b <strtol+0x5f>
c0105c05:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105c09:	75 24                	jne    c0105c2f <strtol+0x83>
c0105c0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c0e:	0f b6 00             	movzbl (%eax),%eax
c0105c11:	3c 30                	cmp    $0x30,%al
c0105c13:	75 1a                	jne    c0105c2f <strtol+0x83>
c0105c15:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c18:	83 c0 01             	add    $0x1,%eax
c0105c1b:	0f b6 00             	movzbl (%eax),%eax
c0105c1e:	3c 78                	cmp    $0x78,%al
c0105c20:	75 0d                	jne    c0105c2f <strtol+0x83>
        s += 2, base = 16;
c0105c22:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105c26:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105c2d:	eb 2a                	jmp    c0105c59 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0105c2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c33:	75 17                	jne    c0105c4c <strtol+0xa0>
c0105c35:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c38:	0f b6 00             	movzbl (%eax),%eax
c0105c3b:	3c 30                	cmp    $0x30,%al
c0105c3d:	75 0d                	jne    c0105c4c <strtol+0xa0>
        s ++, base = 8;
c0105c3f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105c43:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105c4a:	eb 0d                	jmp    c0105c59 <strtol+0xad>
    }
    else if (base == 0) {
c0105c4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105c50:	75 07                	jne    c0105c59 <strtol+0xad>
        base = 10;
c0105c52:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105c59:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c5c:	0f b6 00             	movzbl (%eax),%eax
c0105c5f:	3c 2f                	cmp    $0x2f,%al
c0105c61:	7e 1b                	jle    c0105c7e <strtol+0xd2>
c0105c63:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c66:	0f b6 00             	movzbl (%eax),%eax
c0105c69:	3c 39                	cmp    $0x39,%al
c0105c6b:	7f 11                	jg     c0105c7e <strtol+0xd2>
            dig = *s - '0';
c0105c6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c70:	0f b6 00             	movzbl (%eax),%eax
c0105c73:	0f be c0             	movsbl %al,%eax
c0105c76:	83 e8 30             	sub    $0x30,%eax
c0105c79:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c7c:	eb 48                	jmp    c0105cc6 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105c7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c81:	0f b6 00             	movzbl (%eax),%eax
c0105c84:	3c 60                	cmp    $0x60,%al
c0105c86:	7e 1b                	jle    c0105ca3 <strtol+0xf7>
c0105c88:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c8b:	0f b6 00             	movzbl (%eax),%eax
c0105c8e:	3c 7a                	cmp    $0x7a,%al
c0105c90:	7f 11                	jg     c0105ca3 <strtol+0xf7>
            dig = *s - 'a' + 10;
c0105c92:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c95:	0f b6 00             	movzbl (%eax),%eax
c0105c98:	0f be c0             	movsbl %al,%eax
c0105c9b:	83 e8 57             	sub    $0x57,%eax
c0105c9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ca1:	eb 23                	jmp    c0105cc6 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105ca3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ca6:	0f b6 00             	movzbl (%eax),%eax
c0105ca9:	3c 40                	cmp    $0x40,%al
c0105cab:	7e 3d                	jle    c0105cea <strtol+0x13e>
c0105cad:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cb0:	0f b6 00             	movzbl (%eax),%eax
c0105cb3:	3c 5a                	cmp    $0x5a,%al
c0105cb5:	7f 33                	jg     c0105cea <strtol+0x13e>
            dig = *s - 'A' + 10;
c0105cb7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cba:	0f b6 00             	movzbl (%eax),%eax
c0105cbd:	0f be c0             	movsbl %al,%eax
c0105cc0:	83 e8 37             	sub    $0x37,%eax
c0105cc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cc9:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105ccc:	7c 02                	jl     c0105cd0 <strtol+0x124>
            break;
c0105cce:	eb 1a                	jmp    c0105cea <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c0105cd0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0105cd4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105cd7:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105cdb:	89 c2                	mov    %eax,%edx
c0105cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ce0:	01 d0                	add    %edx,%eax
c0105ce2:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0105ce5:	e9 6f ff ff ff       	jmp    c0105c59 <strtol+0xad>

    if (endptr) {
c0105cea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105cee:	74 08                	je     c0105cf8 <strtol+0x14c>
        *endptr = (char *) s;
c0105cf0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cf3:	8b 55 08             	mov    0x8(%ebp),%edx
c0105cf6:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105cf8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105cfc:	74 07                	je     c0105d05 <strtol+0x159>
c0105cfe:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105d01:	f7 d8                	neg    %eax
c0105d03:	eb 03                	jmp    c0105d08 <strtol+0x15c>
c0105d05:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105d08:	c9                   	leave  
c0105d09:	c3                   	ret    

c0105d0a <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105d0a:	55                   	push   %ebp
c0105d0b:	89 e5                	mov    %esp,%ebp
c0105d0d:	57                   	push   %edi
c0105d0e:	83 ec 24             	sub    $0x24,%esp
c0105d11:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d14:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105d17:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0105d1b:	8b 55 08             	mov    0x8(%ebp),%edx
c0105d1e:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105d21:	88 45 f7             	mov    %al,-0x9(%ebp)
c0105d24:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d27:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105d2a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105d2d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105d31:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105d34:	89 d7                	mov    %edx,%edi
c0105d36:	f3 aa                	rep stos %al,%es:(%edi)
c0105d38:	89 fa                	mov    %edi,%edx
c0105d3a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105d3d:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105d40:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105d43:	83 c4 24             	add    $0x24,%esp
c0105d46:	5f                   	pop    %edi
c0105d47:	5d                   	pop    %ebp
c0105d48:	c3                   	ret    

c0105d49 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105d49:	55                   	push   %ebp
c0105d4a:	89 e5                	mov    %esp,%ebp
c0105d4c:	57                   	push   %edi
c0105d4d:	56                   	push   %esi
c0105d4e:	53                   	push   %ebx
c0105d4f:	83 ec 30             	sub    $0x30,%esp
c0105d52:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d55:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d58:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105d5e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d61:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d67:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105d6a:	73 42                	jae    c0105dae <memmove+0x65>
c0105d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d6f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105d72:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d75:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105d78:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d7b:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105d7e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105d81:	c1 e8 02             	shr    $0x2,%eax
c0105d84:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105d86:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105d89:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105d8c:	89 d7                	mov    %edx,%edi
c0105d8e:	89 c6                	mov    %eax,%esi
c0105d90:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105d92:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105d95:	83 e1 03             	and    $0x3,%ecx
c0105d98:	74 02                	je     c0105d9c <memmove+0x53>
c0105d9a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105d9c:	89 f0                	mov    %esi,%eax
c0105d9e:	89 fa                	mov    %edi,%edx
c0105da0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105da3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105da6:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105dac:	eb 36                	jmp    c0105de4 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105dae:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105db1:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105db4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105db7:	01 c2                	add    %eax,%edx
c0105db9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105dbc:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105dc2:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0105dc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105dc8:	89 c1                	mov    %eax,%ecx
c0105dca:	89 d8                	mov    %ebx,%eax
c0105dcc:	89 d6                	mov    %edx,%esi
c0105dce:	89 c7                	mov    %eax,%edi
c0105dd0:	fd                   	std    
c0105dd1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105dd3:	fc                   	cld    
c0105dd4:	89 f8                	mov    %edi,%eax
c0105dd6:	89 f2                	mov    %esi,%edx
c0105dd8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105ddb:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105dde:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0105de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0105de4:	83 c4 30             	add    $0x30,%esp
c0105de7:	5b                   	pop    %ebx
c0105de8:	5e                   	pop    %esi
c0105de9:	5f                   	pop    %edi
c0105dea:	5d                   	pop    %ebp
c0105deb:	c3                   	ret    

c0105dec <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105dec:	55                   	push   %ebp
c0105ded:	89 e5                	mov    %esp,%ebp
c0105def:	57                   	push   %edi
c0105df0:	56                   	push   %esi
c0105df1:	83 ec 20             	sub    $0x20,%esp
c0105df4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105df7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105dfa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e00:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e03:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105e06:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e09:	c1 e8 02             	shr    $0x2,%eax
c0105e0c:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105e0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105e11:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e14:	89 d7                	mov    %edx,%edi
c0105e16:	89 c6                	mov    %eax,%esi
c0105e18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105e1a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105e1d:	83 e1 03             	and    $0x3,%ecx
c0105e20:	74 02                	je     c0105e24 <memcpy+0x38>
c0105e22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105e24:	89 f0                	mov    %esi,%eax
c0105e26:	89 fa                	mov    %edi,%edx
c0105e28:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105e2b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105e2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105e34:	83 c4 20             	add    $0x20,%esp
c0105e37:	5e                   	pop    %esi
c0105e38:	5f                   	pop    %edi
c0105e39:	5d                   	pop    %ebp
c0105e3a:	c3                   	ret    

c0105e3b <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105e3b:	55                   	push   %ebp
c0105e3c:	89 e5                	mov    %esp,%ebp
c0105e3e:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105e41:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e44:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105e47:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e4a:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105e4d:	eb 30                	jmp    c0105e7f <memcmp+0x44>
        if (*s1 != *s2) {
c0105e4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105e52:	0f b6 10             	movzbl (%eax),%edx
c0105e55:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105e58:	0f b6 00             	movzbl (%eax),%eax
c0105e5b:	38 c2                	cmp    %al,%dl
c0105e5d:	74 18                	je     c0105e77 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105e5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105e62:	0f b6 00             	movzbl (%eax),%eax
c0105e65:	0f b6 d0             	movzbl %al,%edx
c0105e68:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105e6b:	0f b6 00             	movzbl (%eax),%eax
c0105e6e:	0f b6 c0             	movzbl %al,%eax
c0105e71:	29 c2                	sub    %eax,%edx
c0105e73:	89 d0                	mov    %edx,%eax
c0105e75:	eb 1a                	jmp    c0105e91 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0105e77:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0105e7b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0105e7f:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e82:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105e85:	89 55 10             	mov    %edx,0x10(%ebp)
c0105e88:	85 c0                	test   %eax,%eax
c0105e8a:	75 c3                	jne    c0105e4f <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0105e8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105e91:	c9                   	leave  
c0105e92:	c3                   	ret    
