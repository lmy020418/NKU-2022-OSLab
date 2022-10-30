
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100006:	ba 80 fd 10 00       	mov    $0x10fd80,%edx
  10000b:	b8 16 ea 10 00       	mov    $0x10ea16,%eax
  100010:	29 c2                	sub    %eax,%edx
  100012:	89 d0                	mov    %edx,%eax
  100014:	89 44 24 08          	mov    %eax,0x8(%esp)
  100018:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10001f:	00 
  100020:	c7 04 24 16 ea 10 00 	movl   $0x10ea16,(%esp)
  100027:	e8 ff 33 00 00       	call   10342b <memset>

    cons_init();                // init the console
  10002c:	e8 55 15 00 00       	call   101586 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100031:	c7 45 f4 c0 35 10 00 	movl   $0x1035c0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10003b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10003f:	c7 04 24 dc 35 10 00 	movl   $0x1035dc,(%esp)
  100046:	e8 d7 02 00 00       	call   100322 <cprintf>

    print_kerninfo();
  10004b:	e8 06 08 00 00       	call   100856 <print_kerninfo>

    grade_backtrace();
  100050:	e8 8b 00 00 00       	call   1000e0 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100055:	e8 17 2a 00 00       	call   102a71 <pmm_init>

    pic_init();                 // init interrupt controller
  10005a:	e8 6a 16 00 00       	call   1016c9 <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005f:	e8 e2 17 00 00       	call   101846 <idt_init>

    clock_init();               // init clock interrupt
  100064:	e8 10 0d 00 00       	call   100d79 <clock_init>
    intr_enable();              // enable irq interrupt
  100069:	e8 c9 15 00 00       	call   101637 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  10006e:	e8 6d 01 00 00       	call   1001e0 <lab1_switch_test>

    /* do nothing */
    while (1);
  100073:	eb fe                	jmp    100073 <kern_init+0x73>

00100075 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  100075:	55                   	push   %ebp
  100076:	89 e5                	mov    %esp,%ebp
  100078:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  10007b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  100082:	00 
  100083:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10008a:	00 
  10008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100092:	e8 03 0c 00 00       	call   100c9a <mon_backtrace>
}
  100097:	c9                   	leave  
  100098:	c3                   	ret    

00100099 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  100099:	55                   	push   %ebp
  10009a:	89 e5                	mov    %esp,%ebp
  10009c:	53                   	push   %ebx
  10009d:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000a0:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  1000a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  1000a6:	8d 55 08             	lea    0x8(%ebp),%edx
  1000a9:	8b 45 08             	mov    0x8(%ebp),%eax
  1000ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1000b0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1000b4:	89 54 24 04          	mov    %edx,0x4(%esp)
  1000b8:	89 04 24             	mov    %eax,(%esp)
  1000bb:	e8 b5 ff ff ff       	call   100075 <grade_backtrace2>
}
  1000c0:	83 c4 14             	add    $0x14,%esp
  1000c3:	5b                   	pop    %ebx
  1000c4:	5d                   	pop    %ebp
  1000c5:	c3                   	ret    

001000c6 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000c6:	55                   	push   %ebp
  1000c7:	89 e5                	mov    %esp,%ebp
  1000c9:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000cc:	8b 45 10             	mov    0x10(%ebp),%eax
  1000cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1000d6:	89 04 24             	mov    %eax,(%esp)
  1000d9:	e8 bb ff ff ff       	call   100099 <grade_backtrace1>
}
  1000de:	c9                   	leave  
  1000df:	c3                   	ret    

001000e0 <grade_backtrace>:

void
grade_backtrace(void) {
  1000e0:	55                   	push   %ebp
  1000e1:	89 e5                	mov    %esp,%ebp
  1000e3:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000e6:	b8 00 00 10 00       	mov    $0x100000,%eax
  1000eb:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  1000f2:	ff 
  1000f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000fe:	e8 c3 ff ff ff       	call   1000c6 <grade_backtrace0>
}
  100103:	c9                   	leave  
  100104:	c3                   	ret    

00100105 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100105:	55                   	push   %ebp
  100106:	89 e5                	mov    %esp,%ebp
  100108:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10010b:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  10010e:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100111:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100114:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100117:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10011b:	0f b7 c0             	movzwl %ax,%eax
  10011e:	83 e0 03             	and    $0x3,%eax
  100121:	89 c2                	mov    %eax,%edx
  100123:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100128:	89 54 24 08          	mov    %edx,0x8(%esp)
  10012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100130:	c7 04 24 e1 35 10 00 	movl   $0x1035e1,(%esp)
  100137:	e8 e6 01 00 00       	call   100322 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10013c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100140:	0f b7 d0             	movzwl %ax,%edx
  100143:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100148:	89 54 24 08          	mov    %edx,0x8(%esp)
  10014c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100150:	c7 04 24 ef 35 10 00 	movl   $0x1035ef,(%esp)
  100157:	e8 c6 01 00 00       	call   100322 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10015c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100160:	0f b7 d0             	movzwl %ax,%edx
  100163:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100168:	89 54 24 08          	mov    %edx,0x8(%esp)
  10016c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100170:	c7 04 24 fd 35 10 00 	movl   $0x1035fd,(%esp)
  100177:	e8 a6 01 00 00       	call   100322 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  10017c:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100180:	0f b7 d0             	movzwl %ax,%edx
  100183:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  100188:	89 54 24 08          	mov    %edx,0x8(%esp)
  10018c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100190:	c7 04 24 0b 36 10 00 	movl   $0x10360b,(%esp)
  100197:	e8 86 01 00 00       	call   100322 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  10019c:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001a0:	0f b7 d0             	movzwl %ax,%edx
  1001a3:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001a8:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001b0:	c7 04 24 19 36 10 00 	movl   $0x103619,(%esp)
  1001b7:	e8 66 01 00 00       	call   100322 <cprintf>
    round ++;
  1001bc:	a1 20 ea 10 00       	mov    0x10ea20,%eax
  1001c1:	83 c0 01             	add    $0x1,%eax
  1001c4:	a3 20 ea 10 00       	mov    %eax,0x10ea20
}
  1001c9:	c9                   	leave  
  1001ca:	c3                   	ret    

001001cb <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001cb:	55                   	push   %ebp
  1001cc:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
	asm volatile (
  1001ce:	83 ec 08             	sub    $0x8,%esp
  1001d1:	cd 78                	int    $0x78
  1001d3:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
  1001d5:	5d                   	pop    %ebp
  1001d6:	c3                   	ret    

001001d7 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001d7:	55                   	push   %ebp
  1001d8:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
	asm volatile (
  1001da:	cd 79                	int    $0x79
  1001dc:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
  1001de:	5d                   	pop    %ebp
  1001df:	c3                   	ret    

001001e0 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001e0:	55                   	push   %ebp
  1001e1:	89 e5                	mov    %esp,%ebp
  1001e3:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  1001e6:	e8 1a ff ff ff       	call   100105 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  1001eb:	c7 04 24 28 36 10 00 	movl   $0x103628,(%esp)
  1001f2:	e8 2b 01 00 00       	call   100322 <cprintf>
    lab1_switch_to_user();
  1001f7:	e8 cf ff ff ff       	call   1001cb <lab1_switch_to_user>
    lab1_print_cur_status();
  1001fc:	e8 04 ff ff ff       	call   100105 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100201:	c7 04 24 48 36 10 00 	movl   $0x103648,(%esp)
  100208:	e8 15 01 00 00       	call   100322 <cprintf>
    lab1_switch_to_kernel();
  10020d:	e8 c5 ff ff ff       	call   1001d7 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100212:	e8 ee fe ff ff       	call   100105 <lab1_print_cur_status>
}
  100217:	c9                   	leave  
  100218:	c3                   	ret    

00100219 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100219:	55                   	push   %ebp
  10021a:	89 e5                	mov    %esp,%ebp
  10021c:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10021f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100223:	74 13                	je     100238 <readline+0x1f>
        cprintf("%s", prompt);
  100225:	8b 45 08             	mov    0x8(%ebp),%eax
  100228:	89 44 24 04          	mov    %eax,0x4(%esp)
  10022c:	c7 04 24 67 36 10 00 	movl   $0x103667,(%esp)
  100233:	e8 ea 00 00 00       	call   100322 <cprintf>
    }
    int i = 0, c;
  100238:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10023f:	e8 66 01 00 00       	call   1003aa <getchar>
  100244:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100247:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10024b:	79 07                	jns    100254 <readline+0x3b>
            return NULL;
  10024d:	b8 00 00 00 00       	mov    $0x0,%eax
  100252:	eb 79                	jmp    1002cd <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100254:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100258:	7e 28                	jle    100282 <readline+0x69>
  10025a:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100261:	7f 1f                	jg     100282 <readline+0x69>
            cputchar(c);
  100263:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100266:	89 04 24             	mov    %eax,(%esp)
  100269:	e8 da 00 00 00       	call   100348 <cputchar>
            buf[i ++] = c;
  10026e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100271:	8d 50 01             	lea    0x1(%eax),%edx
  100274:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100277:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10027a:	88 90 40 ea 10 00    	mov    %dl,0x10ea40(%eax)
  100280:	eb 46                	jmp    1002c8 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
  100282:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  100286:	75 17                	jne    10029f <readline+0x86>
  100288:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10028c:	7e 11                	jle    10029f <readline+0x86>
            cputchar(c);
  10028e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100291:	89 04 24             	mov    %eax,(%esp)
  100294:	e8 af 00 00 00       	call   100348 <cputchar>
            i --;
  100299:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
  10029d:	eb 29                	jmp    1002c8 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
  10029f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002a3:	74 06                	je     1002ab <readline+0x92>
  1002a5:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002a9:	75 1d                	jne    1002c8 <readline+0xaf>
            cputchar(c);
  1002ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002ae:	89 04 24             	mov    %eax,(%esp)
  1002b1:	e8 92 00 00 00       	call   100348 <cputchar>
            buf[i] = '\0';
  1002b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002b9:	05 40 ea 10 00       	add    $0x10ea40,%eax
  1002be:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002c1:	b8 40 ea 10 00       	mov    $0x10ea40,%eax
  1002c6:	eb 05                	jmp    1002cd <readline+0xb4>
        }
    }
  1002c8:	e9 72 ff ff ff       	jmp    10023f <readline+0x26>
}
  1002cd:	c9                   	leave  
  1002ce:	c3                   	ret    

001002cf <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002cf:	55                   	push   %ebp
  1002d0:	89 e5                	mov    %esp,%ebp
  1002d2:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1002d8:	89 04 24             	mov    %eax,(%esp)
  1002db:	e8 d2 12 00 00       	call   1015b2 <cons_putc>
    (*cnt) ++;
  1002e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002e3:	8b 00                	mov    (%eax),%eax
  1002e5:	8d 50 01             	lea    0x1(%eax),%edx
  1002e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002eb:	89 10                	mov    %edx,(%eax)
}
  1002ed:	c9                   	leave  
  1002ee:	c3                   	ret    

001002ef <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  1002ef:	55                   	push   %ebp
  1002f0:	89 e5                	mov    %esp,%ebp
  1002f2:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  1002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100303:	8b 45 08             	mov    0x8(%ebp),%eax
  100306:	89 44 24 08          	mov    %eax,0x8(%esp)
  10030a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10030d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100311:	c7 04 24 cf 02 10 00 	movl   $0x1002cf,(%esp)
  100318:	e8 27 29 00 00       	call   102c44 <vprintfmt>
    return cnt;
  10031d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100320:	c9                   	leave  
  100321:	c3                   	ret    

00100322 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100322:	55                   	push   %ebp
  100323:	89 e5                	mov    %esp,%ebp
  100325:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100328:	8d 45 0c             	lea    0xc(%ebp),%eax
  10032b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  10032e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100331:	89 44 24 04          	mov    %eax,0x4(%esp)
  100335:	8b 45 08             	mov    0x8(%ebp),%eax
  100338:	89 04 24             	mov    %eax,(%esp)
  10033b:	e8 af ff ff ff       	call   1002ef <vcprintf>
  100340:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100343:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100346:	c9                   	leave  
  100347:	c3                   	ret    

00100348 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100348:	55                   	push   %ebp
  100349:	89 e5                	mov    %esp,%ebp
  10034b:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  10034e:	8b 45 08             	mov    0x8(%ebp),%eax
  100351:	89 04 24             	mov    %eax,(%esp)
  100354:	e8 59 12 00 00       	call   1015b2 <cons_putc>
}
  100359:	c9                   	leave  
  10035a:	c3                   	ret    

0010035b <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  10035b:	55                   	push   %ebp
  10035c:	89 e5                	mov    %esp,%ebp
  10035e:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100361:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  100368:	eb 13                	jmp    10037d <cputs+0x22>
        cputch(c, &cnt);
  10036a:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  10036e:	8d 55 f0             	lea    -0x10(%ebp),%edx
  100371:	89 54 24 04          	mov    %edx,0x4(%esp)
  100375:	89 04 24             	mov    %eax,(%esp)
  100378:	e8 52 ff ff ff       	call   1002cf <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  10037d:	8b 45 08             	mov    0x8(%ebp),%eax
  100380:	8d 50 01             	lea    0x1(%eax),%edx
  100383:	89 55 08             	mov    %edx,0x8(%ebp)
  100386:	0f b6 00             	movzbl (%eax),%eax
  100389:	88 45 f7             	mov    %al,-0x9(%ebp)
  10038c:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100390:	75 d8                	jne    10036a <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  100392:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100395:	89 44 24 04          	mov    %eax,0x4(%esp)
  100399:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003a0:	e8 2a ff ff ff       	call   1002cf <cputch>
    return cnt;
  1003a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003a8:	c9                   	leave  
  1003a9:	c3                   	ret    

001003aa <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003aa:	55                   	push   %ebp
  1003ab:	89 e5                	mov    %esp,%ebp
  1003ad:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003b0:	e8 26 12 00 00       	call   1015db <cons_getc>
  1003b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003bc:	74 f2                	je     1003b0 <getchar+0x6>
        /* do nothing */;
    return c;
  1003be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003c1:	c9                   	leave  
  1003c2:	c3                   	ret    

001003c3 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1003c3:	55                   	push   %ebp
  1003c4:	89 e5                	mov    %esp,%ebp
  1003c6:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1003c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003cc:	8b 00                	mov    (%eax),%eax
  1003ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1003d1:	8b 45 10             	mov    0x10(%ebp),%eax
  1003d4:	8b 00                	mov    (%eax),%eax
  1003d6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1003e0:	e9 d2 00 00 00       	jmp    1004b7 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
  1003e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1003e8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1003eb:	01 d0                	add    %edx,%eax
  1003ed:	89 c2                	mov    %eax,%edx
  1003ef:	c1 ea 1f             	shr    $0x1f,%edx
  1003f2:	01 d0                	add    %edx,%eax
  1003f4:	d1 f8                	sar    %eax
  1003f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1003f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1003fc:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1003ff:	eb 04                	jmp    100405 <stab_binsearch+0x42>
            m --;
  100401:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100405:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100408:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10040b:	7c 1f                	jl     10042c <stab_binsearch+0x69>
  10040d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100410:	89 d0                	mov    %edx,%eax
  100412:	01 c0                	add    %eax,%eax
  100414:	01 d0                	add    %edx,%eax
  100416:	c1 e0 02             	shl    $0x2,%eax
  100419:	89 c2                	mov    %eax,%edx
  10041b:	8b 45 08             	mov    0x8(%ebp),%eax
  10041e:	01 d0                	add    %edx,%eax
  100420:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100424:	0f b6 c0             	movzbl %al,%eax
  100427:	3b 45 14             	cmp    0x14(%ebp),%eax
  10042a:	75 d5                	jne    100401 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  10042c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10042f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100432:	7d 0b                	jge    10043f <stab_binsearch+0x7c>
            l = true_m + 1;
  100434:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100437:	83 c0 01             	add    $0x1,%eax
  10043a:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10043d:	eb 78                	jmp    1004b7 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
  10043f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100446:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100449:	89 d0                	mov    %edx,%eax
  10044b:	01 c0                	add    %eax,%eax
  10044d:	01 d0                	add    %edx,%eax
  10044f:	c1 e0 02             	shl    $0x2,%eax
  100452:	89 c2                	mov    %eax,%edx
  100454:	8b 45 08             	mov    0x8(%ebp),%eax
  100457:	01 d0                	add    %edx,%eax
  100459:	8b 40 08             	mov    0x8(%eax),%eax
  10045c:	3b 45 18             	cmp    0x18(%ebp),%eax
  10045f:	73 13                	jae    100474 <stab_binsearch+0xb1>
            *region_left = m;
  100461:	8b 45 0c             	mov    0xc(%ebp),%eax
  100464:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100467:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  100469:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10046c:	83 c0 01             	add    $0x1,%eax
  10046f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100472:	eb 43                	jmp    1004b7 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
  100474:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100477:	89 d0                	mov    %edx,%eax
  100479:	01 c0                	add    %eax,%eax
  10047b:	01 d0                	add    %edx,%eax
  10047d:	c1 e0 02             	shl    $0x2,%eax
  100480:	89 c2                	mov    %eax,%edx
  100482:	8b 45 08             	mov    0x8(%ebp),%eax
  100485:	01 d0                	add    %edx,%eax
  100487:	8b 40 08             	mov    0x8(%eax),%eax
  10048a:	3b 45 18             	cmp    0x18(%ebp),%eax
  10048d:	76 16                	jbe    1004a5 <stab_binsearch+0xe2>
            *region_right = m - 1;
  10048f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100492:	8d 50 ff             	lea    -0x1(%eax),%edx
  100495:	8b 45 10             	mov    0x10(%ebp),%eax
  100498:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10049a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10049d:	83 e8 01             	sub    $0x1,%eax
  1004a0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004a3:	eb 12                	jmp    1004b7 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004ab:	89 10                	mov    %edx,(%eax)
            l = m;
  1004ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004b3:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1004b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004ba:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004bd:	0f 8e 22 ff ff ff    	jle    1003e5 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1004c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004c7:	75 0f                	jne    1004d8 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
  1004c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004cc:	8b 00                	mov    (%eax),%eax
  1004ce:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004d1:	8b 45 10             	mov    0x10(%ebp),%eax
  1004d4:	89 10                	mov    %edx,(%eax)
  1004d6:	eb 3f                	jmp    100517 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1004d8:	8b 45 10             	mov    0x10(%ebp),%eax
  1004db:	8b 00                	mov    (%eax),%eax
  1004dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1004e0:	eb 04                	jmp    1004e6 <stab_binsearch+0x123>
  1004e2:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
  1004e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004e9:	8b 00                	mov    (%eax),%eax
  1004eb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004ee:	7d 1f                	jge    10050f <stab_binsearch+0x14c>
  1004f0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004f3:	89 d0                	mov    %edx,%eax
  1004f5:	01 c0                	add    %eax,%eax
  1004f7:	01 d0                	add    %edx,%eax
  1004f9:	c1 e0 02             	shl    $0x2,%eax
  1004fc:	89 c2                	mov    %eax,%edx
  1004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  100501:	01 d0                	add    %edx,%eax
  100503:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100507:	0f b6 c0             	movzbl %al,%eax
  10050a:	3b 45 14             	cmp    0x14(%ebp),%eax
  10050d:	75 d3                	jne    1004e2 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
  10050f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100512:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100515:	89 10                	mov    %edx,(%eax)
    }
}
  100517:	c9                   	leave  
  100518:	c3                   	ret    

00100519 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100519:	55                   	push   %ebp
  10051a:	89 e5                	mov    %esp,%ebp
  10051c:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  10051f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100522:	c7 00 6c 36 10 00    	movl   $0x10366c,(%eax)
    info->eip_line = 0;
  100528:	8b 45 0c             	mov    0xc(%ebp),%eax
  10052b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100532:	8b 45 0c             	mov    0xc(%ebp),%eax
  100535:	c7 40 08 6c 36 10 00 	movl   $0x10366c,0x8(%eax)
    info->eip_fn_namelen = 9;
  10053c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10053f:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100546:	8b 45 0c             	mov    0xc(%ebp),%eax
  100549:	8b 55 08             	mov    0x8(%ebp),%edx
  10054c:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  10054f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100552:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100559:	c7 45 f4 ec 3e 10 00 	movl   $0x103eec,-0xc(%ebp)
    stab_end = __STAB_END__;
  100560:	c7 45 f0 34 b7 10 00 	movl   $0x10b734,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100567:	c7 45 ec 35 b7 10 00 	movl   $0x10b735,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  10056e:	c7 45 e8 73 d7 10 00 	movl   $0x10d773,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100575:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100578:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10057b:	76 0d                	jbe    10058a <debuginfo_eip+0x71>
  10057d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100580:	83 e8 01             	sub    $0x1,%eax
  100583:	0f b6 00             	movzbl (%eax),%eax
  100586:	84 c0                	test   %al,%al
  100588:	74 0a                	je     100594 <debuginfo_eip+0x7b>
        return -1;
  10058a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10058f:	e9 c0 02 00 00       	jmp    100854 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  100594:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  10059b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10059e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005a1:	29 c2                	sub    %eax,%edx
  1005a3:	89 d0                	mov    %edx,%eax
  1005a5:	c1 f8 02             	sar    $0x2,%eax
  1005a8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005ae:	83 e8 01             	sub    $0x1,%eax
  1005b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1005b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005bb:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005c2:	00 
  1005c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1005d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1005d4:	89 04 24             	mov    %eax,(%esp)
  1005d7:	e8 e7 fd ff ff       	call   1003c3 <stab_binsearch>
    if (lfile == 0)
  1005dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1005df:	85 c0                	test   %eax,%eax
  1005e1:	75 0a                	jne    1005ed <debuginfo_eip+0xd4>
        return -1;
  1005e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005e8:	e9 67 02 00 00       	jmp    100854 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1005ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1005f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1005f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1005f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1005f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1005fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  100600:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100607:	00 
  100608:	8d 45 d8             	lea    -0x28(%ebp),%eax
  10060b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10060f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100612:	89 44 24 04          	mov    %eax,0x4(%esp)
  100616:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100619:	89 04 24             	mov    %eax,(%esp)
  10061c:	e8 a2 fd ff ff       	call   1003c3 <stab_binsearch>

    if (lfun <= rfun) {
  100621:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100624:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100627:	39 c2                	cmp    %eax,%edx
  100629:	7f 7c                	jg     1006a7 <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10062b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10062e:	89 c2                	mov    %eax,%edx
  100630:	89 d0                	mov    %edx,%eax
  100632:	01 c0                	add    %eax,%eax
  100634:	01 d0                	add    %edx,%eax
  100636:	c1 e0 02             	shl    $0x2,%eax
  100639:	89 c2                	mov    %eax,%edx
  10063b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10063e:	01 d0                	add    %edx,%eax
  100640:	8b 10                	mov    (%eax),%edx
  100642:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100645:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100648:	29 c1                	sub    %eax,%ecx
  10064a:	89 c8                	mov    %ecx,%eax
  10064c:	39 c2                	cmp    %eax,%edx
  10064e:	73 22                	jae    100672 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100650:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100653:	89 c2                	mov    %eax,%edx
  100655:	89 d0                	mov    %edx,%eax
  100657:	01 c0                	add    %eax,%eax
  100659:	01 d0                	add    %edx,%eax
  10065b:	c1 e0 02             	shl    $0x2,%eax
  10065e:	89 c2                	mov    %eax,%edx
  100660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100663:	01 d0                	add    %edx,%eax
  100665:	8b 10                	mov    (%eax),%edx
  100667:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10066a:	01 c2                	add    %eax,%edx
  10066c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10066f:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100672:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100675:	89 c2                	mov    %eax,%edx
  100677:	89 d0                	mov    %edx,%eax
  100679:	01 c0                	add    %eax,%eax
  10067b:	01 d0                	add    %edx,%eax
  10067d:	c1 e0 02             	shl    $0x2,%eax
  100680:	89 c2                	mov    %eax,%edx
  100682:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100685:	01 d0                	add    %edx,%eax
  100687:	8b 50 08             	mov    0x8(%eax),%edx
  10068a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10068d:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100690:	8b 45 0c             	mov    0xc(%ebp),%eax
  100693:	8b 40 10             	mov    0x10(%eax),%eax
  100696:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  100699:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10069c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  10069f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006a5:	eb 15                	jmp    1006bc <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006aa:	8b 55 08             	mov    0x8(%ebp),%edx
  1006ad:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006bf:	8b 40 08             	mov    0x8(%eax),%eax
  1006c2:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006c9:	00 
  1006ca:	89 04 24             	mov    %eax,(%esp)
  1006cd:	e8 cd 2b 00 00       	call   10329f <strfind>
  1006d2:	89 c2                	mov    %eax,%edx
  1006d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006d7:	8b 40 08             	mov    0x8(%eax),%eax
  1006da:	29 c2                	sub    %eax,%edx
  1006dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006df:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1006e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1006e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006e9:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1006f0:	00 
  1006f1:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1006f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006f8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1006fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100702:	89 04 24             	mov    %eax,(%esp)
  100705:	e8 b9 fc ff ff       	call   1003c3 <stab_binsearch>
    if (lline <= rline) {
  10070a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10070d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100710:	39 c2                	cmp    %eax,%edx
  100712:	7f 24                	jg     100738 <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
  100714:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100717:	89 c2                	mov    %eax,%edx
  100719:	89 d0                	mov    %edx,%eax
  10071b:	01 c0                	add    %eax,%eax
  10071d:	01 d0                	add    %edx,%eax
  10071f:	c1 e0 02             	shl    $0x2,%eax
  100722:	89 c2                	mov    %eax,%edx
  100724:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100727:	01 d0                	add    %edx,%eax
  100729:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  10072d:	0f b7 d0             	movzwl %ax,%edx
  100730:	8b 45 0c             	mov    0xc(%ebp),%eax
  100733:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100736:	eb 13                	jmp    10074b <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  100738:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10073d:	e9 12 01 00 00       	jmp    100854 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100742:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100745:	83 e8 01             	sub    $0x1,%eax
  100748:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10074b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10074e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100751:	39 c2                	cmp    %eax,%edx
  100753:	7c 56                	jl     1007ab <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
  100755:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100758:	89 c2                	mov    %eax,%edx
  10075a:	89 d0                	mov    %edx,%eax
  10075c:	01 c0                	add    %eax,%eax
  10075e:	01 d0                	add    %edx,%eax
  100760:	c1 e0 02             	shl    $0x2,%eax
  100763:	89 c2                	mov    %eax,%edx
  100765:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100768:	01 d0                	add    %edx,%eax
  10076a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10076e:	3c 84                	cmp    $0x84,%al
  100770:	74 39                	je     1007ab <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100772:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100775:	89 c2                	mov    %eax,%edx
  100777:	89 d0                	mov    %edx,%eax
  100779:	01 c0                	add    %eax,%eax
  10077b:	01 d0                	add    %edx,%eax
  10077d:	c1 e0 02             	shl    $0x2,%eax
  100780:	89 c2                	mov    %eax,%edx
  100782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100785:	01 d0                	add    %edx,%eax
  100787:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10078b:	3c 64                	cmp    $0x64,%al
  10078d:	75 b3                	jne    100742 <debuginfo_eip+0x229>
  10078f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100792:	89 c2                	mov    %eax,%edx
  100794:	89 d0                	mov    %edx,%eax
  100796:	01 c0                	add    %eax,%eax
  100798:	01 d0                	add    %edx,%eax
  10079a:	c1 e0 02             	shl    $0x2,%eax
  10079d:	89 c2                	mov    %eax,%edx
  10079f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007a2:	01 d0                	add    %edx,%eax
  1007a4:	8b 40 08             	mov    0x8(%eax),%eax
  1007a7:	85 c0                	test   %eax,%eax
  1007a9:	74 97                	je     100742 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007ab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007b1:	39 c2                	cmp    %eax,%edx
  1007b3:	7c 46                	jl     1007fb <debuginfo_eip+0x2e2>
  1007b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007b8:	89 c2                	mov    %eax,%edx
  1007ba:	89 d0                	mov    %edx,%eax
  1007bc:	01 c0                	add    %eax,%eax
  1007be:	01 d0                	add    %edx,%eax
  1007c0:	c1 e0 02             	shl    $0x2,%eax
  1007c3:	89 c2                	mov    %eax,%edx
  1007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007c8:	01 d0                	add    %edx,%eax
  1007ca:	8b 10                	mov    (%eax),%edx
  1007cc:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1007cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007d2:	29 c1                	sub    %eax,%ecx
  1007d4:	89 c8                	mov    %ecx,%eax
  1007d6:	39 c2                	cmp    %eax,%edx
  1007d8:	73 21                	jae    1007fb <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1007da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007dd:	89 c2                	mov    %eax,%edx
  1007df:	89 d0                	mov    %edx,%eax
  1007e1:	01 c0                	add    %eax,%eax
  1007e3:	01 d0                	add    %edx,%eax
  1007e5:	c1 e0 02             	shl    $0x2,%eax
  1007e8:	89 c2                	mov    %eax,%edx
  1007ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ed:	01 d0                	add    %edx,%eax
  1007ef:	8b 10                	mov    (%eax),%edx
  1007f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007f4:	01 c2                	add    %eax,%edx
  1007f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007f9:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1007fb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1007fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100801:	39 c2                	cmp    %eax,%edx
  100803:	7d 4a                	jge    10084f <debuginfo_eip+0x336>
        for (lline = lfun + 1;
  100805:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100808:	83 c0 01             	add    $0x1,%eax
  10080b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  10080e:	eb 18                	jmp    100828 <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100810:	8b 45 0c             	mov    0xc(%ebp),%eax
  100813:	8b 40 14             	mov    0x14(%eax),%eax
  100816:	8d 50 01             	lea    0x1(%eax),%edx
  100819:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081c:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  10081f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100822:	83 c0 01             	add    $0x1,%eax
  100825:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100828:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10082b:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  10082e:	39 c2                	cmp    %eax,%edx
  100830:	7d 1d                	jge    10084f <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100832:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100835:	89 c2                	mov    %eax,%edx
  100837:	89 d0                	mov    %edx,%eax
  100839:	01 c0                	add    %eax,%eax
  10083b:	01 d0                	add    %edx,%eax
  10083d:	c1 e0 02             	shl    $0x2,%eax
  100840:	89 c2                	mov    %eax,%edx
  100842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100845:	01 d0                	add    %edx,%eax
  100847:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10084b:	3c a0                	cmp    $0xa0,%al
  10084d:	74 c1                	je     100810 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  10084f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100854:	c9                   	leave  
  100855:	c3                   	ret    

00100856 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100856:	55                   	push   %ebp
  100857:	89 e5                	mov    %esp,%ebp
  100859:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10085c:	c7 04 24 76 36 10 00 	movl   $0x103676,(%esp)
  100863:	e8 ba fa ff ff       	call   100322 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100868:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  10086f:	00 
  100870:	c7 04 24 8f 36 10 00 	movl   $0x10368f,(%esp)
  100877:	e8 a6 fa ff ff       	call   100322 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10087c:	c7 44 24 04 b4 35 10 	movl   $0x1035b4,0x4(%esp)
  100883:	00 
  100884:	c7 04 24 a7 36 10 00 	movl   $0x1036a7,(%esp)
  10088b:	e8 92 fa ff ff       	call   100322 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100890:	c7 44 24 04 16 ea 10 	movl   $0x10ea16,0x4(%esp)
  100897:	00 
  100898:	c7 04 24 bf 36 10 00 	movl   $0x1036bf,(%esp)
  10089f:	e8 7e fa ff ff       	call   100322 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008a4:	c7 44 24 04 80 fd 10 	movl   $0x10fd80,0x4(%esp)
  1008ab:	00 
  1008ac:	c7 04 24 d7 36 10 00 	movl   $0x1036d7,(%esp)
  1008b3:	e8 6a fa ff ff       	call   100322 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008b8:	b8 80 fd 10 00       	mov    $0x10fd80,%eax
  1008bd:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008c3:	b8 00 00 10 00       	mov    $0x100000,%eax
  1008c8:	29 c2                	sub    %eax,%edx
  1008ca:	89 d0                	mov    %edx,%eax
  1008cc:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008d2:	85 c0                	test   %eax,%eax
  1008d4:	0f 48 c2             	cmovs  %edx,%eax
  1008d7:	c1 f8 0a             	sar    $0xa,%eax
  1008da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008de:	c7 04 24 f0 36 10 00 	movl   $0x1036f0,(%esp)
  1008e5:	e8 38 fa ff ff       	call   100322 <cprintf>
}
  1008ea:	c9                   	leave  
  1008eb:	c3                   	ret    

001008ec <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1008ec:	55                   	push   %ebp
  1008ed:	89 e5                	mov    %esp,%ebp
  1008ef:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1008f5:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1008ff:	89 04 24             	mov    %eax,(%esp)
  100902:	e8 12 fc ff ff       	call   100519 <debuginfo_eip>
  100907:	85 c0                	test   %eax,%eax
  100909:	74 15                	je     100920 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  10090b:	8b 45 08             	mov    0x8(%ebp),%eax
  10090e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100912:	c7 04 24 1a 37 10 00 	movl   $0x10371a,(%esp)
  100919:	e8 04 fa ff ff       	call   100322 <cprintf>
  10091e:	eb 6d                	jmp    10098d <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100920:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100927:	eb 1c                	jmp    100945 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
  100929:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10092c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10092f:	01 d0                	add    %edx,%eax
  100931:	0f b6 00             	movzbl (%eax),%eax
  100934:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10093a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10093d:	01 ca                	add    %ecx,%edx
  10093f:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100941:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100945:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100948:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10094b:	7f dc                	jg     100929 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  10094d:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100953:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100956:	01 d0                	add    %edx,%eax
  100958:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  10095b:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  10095e:	8b 55 08             	mov    0x8(%ebp),%edx
  100961:	89 d1                	mov    %edx,%ecx
  100963:	29 c1                	sub    %eax,%ecx
  100965:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100968:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10096b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10096f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100975:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100979:	89 54 24 08          	mov    %edx,0x8(%esp)
  10097d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100981:	c7 04 24 36 37 10 00 	movl   $0x103736,(%esp)
  100988:	e8 95 f9 ff ff       	call   100322 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  10098d:	c9                   	leave  
  10098e:	c3                   	ret    

0010098f <read_eip>:

static __noinline uint32_t
read_eip(void) {
  10098f:	55                   	push   %ebp
  100990:	89 e5                	mov    %esp,%ebp
  100992:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100995:	8b 45 04             	mov    0x4(%ebp),%eax
  100998:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  10099b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10099e:	c9                   	leave  
  10099f:	c3                   	ret    

001009a0 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009a0:	55                   	push   %ebp
  1009a1:	89 e5                	mov    %esp,%ebp
  1009a3:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009a6:	89 e8                	mov    %ebp,%eax
  1009a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  1009ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp_curr=read_ebp(), eip_curr=read_eip();
  1009ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1009b1:	e8 d9 ff ff ff       	call   10098f <read_eip>
  1009b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int stack_level,num;
    	for(stack_level=0;stack_level<STACKFRAME_DEPTH&&ebp_curr!=0;stack_level++){
  1009b9:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009c0:	e9 88 00 00 00       	jmp    100a4d <print_stackframe+0xad>
     		cprintf("ebp:0x%08x eip:0x%08x args:",ebp_curr,eip_curr); 
  1009c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  1009cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009d3:	c7 04 24 48 37 10 00 	movl   $0x103748,(%esp)
  1009da:	e8 43 f9 ff ff       	call   100322 <cprintf>
        	uint32_t *args=(uint32_t *)ebp_curr+2;
  1009df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009e2:	83 c0 08             	add    $0x8,%eax
  1009e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        	for(num=0;num<4;num++){
  1009e8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  1009ef:	eb 25                	jmp    100a16 <print_stackframe+0x76>
            		cprintf("0x%08x ", args[num]);
  1009f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1009f4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1009fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1009fe:	01 d0                	add    %edx,%eax
  100a00:	8b 00                	mov    (%eax),%eax
  100a02:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a06:	c7 04 24 64 37 10 00 	movl   $0x103764,(%esp)
  100a0d:	e8 10 f9 ff ff       	call   100322 <cprintf>
	uint32_t ebp_curr=read_ebp(), eip_curr=read_eip();
	int stack_level,num;
    	for(stack_level=0;stack_level<STACKFRAME_DEPTH&&ebp_curr!=0;stack_level++){
     		cprintf("ebp:0x%08x eip:0x%08x args:",ebp_curr,eip_curr); 
        	uint32_t *args=(uint32_t *)ebp_curr+2;
        	for(num=0;num<4;num++){
  100a12:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
  100a16:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100a1a:	7e d5                	jle    1009f1 <print_stackframe+0x51>
            		cprintf("0x%08x ", args[num]);
        	}
        	cprintf("\n");
  100a1c:	c7 04 24 6c 37 10 00 	movl   $0x10376c,(%esp)
  100a23:	e8 fa f8 ff ff       	call   100322 <cprintf>
        	print_debuginfo(eip_curr-1);
  100a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a2b:	83 e8 01             	sub    $0x1,%eax
  100a2e:	89 04 24             	mov    %eax,(%esp)
  100a31:	e8 b6 fe ff ff       	call   1008ec <print_debuginfo>
        	eip_curr=((uint32_t *)ebp_curr)[1];
  100a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a39:	83 c0 04             	add    $0x4,%eax
  100a3c:	8b 00                	mov    (%eax),%eax
  100a3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        	ebp_curr=((uint32_t *)ebp_curr)[0];
  100a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a44:	8b 00                	mov    (%eax),%eax
  100a46:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
	uint32_t ebp_curr=read_ebp(), eip_curr=read_eip();
	int stack_level,num;
    	for(stack_level=0;stack_level<STACKFRAME_DEPTH&&ebp_curr!=0;stack_level++){
  100a49:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
  100a4d:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a51:	7f 0a                	jg     100a5d <print_stackframe+0xbd>
  100a53:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a57:	0f 85 68 ff ff ff    	jne    1009c5 <print_stackframe+0x25>
        	cprintf("\n");
        	print_debuginfo(eip_curr-1);
        	eip_curr=((uint32_t *)ebp_curr)[1];
        	ebp_curr=((uint32_t *)ebp_curr)[0];
	}
}
  100a5d:	c9                   	leave  
  100a5e:	c3                   	ret    

00100a5f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a5f:	55                   	push   %ebp
  100a60:	89 e5                	mov    %esp,%ebp
  100a62:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a6c:	eb 0c                	jmp    100a7a <parse+0x1b>
            *buf ++ = '\0';
  100a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  100a71:	8d 50 01             	lea    0x1(%eax),%edx
  100a74:	89 55 08             	mov    %edx,0x8(%ebp)
  100a77:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  100a7d:	0f b6 00             	movzbl (%eax),%eax
  100a80:	84 c0                	test   %al,%al
  100a82:	74 1d                	je     100aa1 <parse+0x42>
  100a84:	8b 45 08             	mov    0x8(%ebp),%eax
  100a87:	0f b6 00             	movzbl (%eax),%eax
  100a8a:	0f be c0             	movsbl %al,%eax
  100a8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a91:	c7 04 24 f0 37 10 00 	movl   $0x1037f0,(%esp)
  100a98:	e8 cf 27 00 00       	call   10326c <strchr>
  100a9d:	85 c0                	test   %eax,%eax
  100a9f:	75 cd                	jne    100a6e <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  100aa4:	0f b6 00             	movzbl (%eax),%eax
  100aa7:	84 c0                	test   %al,%al
  100aa9:	75 02                	jne    100aad <parse+0x4e>
            break;
  100aab:	eb 67                	jmp    100b14 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100aad:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100ab1:	75 14                	jne    100ac7 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ab3:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100aba:	00 
  100abb:	c7 04 24 f5 37 10 00 	movl   $0x1037f5,(%esp)
  100ac2:	e8 5b f8 ff ff       	call   100322 <cprintf>
        }
        argv[argc ++] = buf;
  100ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100aca:	8d 50 01             	lea    0x1(%eax),%edx
  100acd:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100ad0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100ad7:	8b 45 0c             	mov    0xc(%ebp),%eax
  100ada:	01 c2                	add    %eax,%edx
  100adc:	8b 45 08             	mov    0x8(%ebp),%eax
  100adf:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100ae1:	eb 04                	jmp    100ae7 <parse+0x88>
            buf ++;
  100ae3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  100aea:	0f b6 00             	movzbl (%eax),%eax
  100aed:	84 c0                	test   %al,%al
  100aef:	74 1d                	je     100b0e <parse+0xaf>
  100af1:	8b 45 08             	mov    0x8(%ebp),%eax
  100af4:	0f b6 00             	movzbl (%eax),%eax
  100af7:	0f be c0             	movsbl %al,%eax
  100afa:	89 44 24 04          	mov    %eax,0x4(%esp)
  100afe:	c7 04 24 f0 37 10 00 	movl   $0x1037f0,(%esp)
  100b05:	e8 62 27 00 00       	call   10326c <strchr>
  100b0a:	85 c0                	test   %eax,%eax
  100b0c:	74 d5                	je     100ae3 <parse+0x84>
            buf ++;
        }
    }
  100b0e:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b0f:	e9 66 ff ff ff       	jmp    100a7a <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b17:	c9                   	leave  
  100b18:	c3                   	ret    

00100b19 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b19:	55                   	push   %ebp
  100b1a:	89 e5                	mov    %esp,%ebp
  100b1c:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b1f:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b22:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b26:	8b 45 08             	mov    0x8(%ebp),%eax
  100b29:	89 04 24             	mov    %eax,(%esp)
  100b2c:	e8 2e ff ff ff       	call   100a5f <parse>
  100b31:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b34:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b38:	75 0a                	jne    100b44 <runcmd+0x2b>
        return 0;
  100b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  100b3f:	e9 85 00 00 00       	jmp    100bc9 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b44:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b4b:	eb 5c                	jmp    100ba9 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b4d:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100b50:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b53:	89 d0                	mov    %edx,%eax
  100b55:	01 c0                	add    %eax,%eax
  100b57:	01 d0                	add    %edx,%eax
  100b59:	c1 e0 02             	shl    $0x2,%eax
  100b5c:	05 00 e0 10 00       	add    $0x10e000,%eax
  100b61:	8b 00                	mov    (%eax),%eax
  100b63:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100b67:	89 04 24             	mov    %eax,(%esp)
  100b6a:	e8 5e 26 00 00       	call   1031cd <strcmp>
  100b6f:	85 c0                	test   %eax,%eax
  100b71:	75 32                	jne    100ba5 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100b73:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100b76:	89 d0                	mov    %edx,%eax
  100b78:	01 c0                	add    %eax,%eax
  100b7a:	01 d0                	add    %edx,%eax
  100b7c:	c1 e0 02             	shl    $0x2,%eax
  100b7f:	05 00 e0 10 00       	add    $0x10e000,%eax
  100b84:	8b 40 08             	mov    0x8(%eax),%eax
  100b87:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100b8a:	8d 4a ff             	lea    -0x1(%edx),%ecx
  100b8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  100b90:	89 54 24 08          	mov    %edx,0x8(%esp)
  100b94:	8d 55 b0             	lea    -0x50(%ebp),%edx
  100b97:	83 c2 04             	add    $0x4,%edx
  100b9a:	89 54 24 04          	mov    %edx,0x4(%esp)
  100b9e:	89 0c 24             	mov    %ecx,(%esp)
  100ba1:	ff d0                	call   *%eax
  100ba3:	eb 24                	jmp    100bc9 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100ba5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bac:	83 f8 02             	cmp    $0x2,%eax
  100baf:	76 9c                	jbe    100b4d <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100bb1:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bb8:	c7 04 24 13 38 10 00 	movl   $0x103813,(%esp)
  100bbf:	e8 5e f7 ff ff       	call   100322 <cprintf>
    return 0;
  100bc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bc9:	c9                   	leave  
  100bca:	c3                   	ret    

00100bcb <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100bcb:	55                   	push   %ebp
  100bcc:	89 e5                	mov    %esp,%ebp
  100bce:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100bd1:	c7 04 24 2c 38 10 00 	movl   $0x10382c,(%esp)
  100bd8:	e8 45 f7 ff ff       	call   100322 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100bdd:	c7 04 24 54 38 10 00 	movl   $0x103854,(%esp)
  100be4:	e8 39 f7 ff ff       	call   100322 <cprintf>

    if (tf != NULL) {
  100be9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100bed:	74 0b                	je     100bfa <kmonitor+0x2f>
        print_trapframe(tf);
  100bef:	8b 45 08             	mov    0x8(%ebp),%eax
  100bf2:	89 04 24             	mov    %eax,(%esp)
  100bf5:	e8 03 0e 00 00       	call   1019fd <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100bfa:	c7 04 24 79 38 10 00 	movl   $0x103879,(%esp)
  100c01:	e8 13 f6 ff ff       	call   100219 <readline>
  100c06:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c09:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c0d:	74 18                	je     100c27 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
  100c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  100c12:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c19:	89 04 24             	mov    %eax,(%esp)
  100c1c:	e8 f8 fe ff ff       	call   100b19 <runcmd>
  100c21:	85 c0                	test   %eax,%eax
  100c23:	79 02                	jns    100c27 <kmonitor+0x5c>
                break;
  100c25:	eb 02                	jmp    100c29 <kmonitor+0x5e>
            }
        }
    }
  100c27:	eb d1                	jmp    100bfa <kmonitor+0x2f>
}
  100c29:	c9                   	leave  
  100c2a:	c3                   	ret    

00100c2b <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c2b:	55                   	push   %ebp
  100c2c:	89 e5                	mov    %esp,%ebp
  100c2e:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c38:	eb 3f                	jmp    100c79 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c3d:	89 d0                	mov    %edx,%eax
  100c3f:	01 c0                	add    %eax,%eax
  100c41:	01 d0                	add    %edx,%eax
  100c43:	c1 e0 02             	shl    $0x2,%eax
  100c46:	05 00 e0 10 00       	add    $0x10e000,%eax
  100c4b:	8b 48 04             	mov    0x4(%eax),%ecx
  100c4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c51:	89 d0                	mov    %edx,%eax
  100c53:	01 c0                	add    %eax,%eax
  100c55:	01 d0                	add    %edx,%eax
  100c57:	c1 e0 02             	shl    $0x2,%eax
  100c5a:	05 00 e0 10 00       	add    $0x10e000,%eax
  100c5f:	8b 00                	mov    (%eax),%eax
  100c61:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c65:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c69:	c7 04 24 7d 38 10 00 	movl   $0x10387d,(%esp)
  100c70:	e8 ad f6 ff ff       	call   100322 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c75:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  100c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c7c:	83 f8 02             	cmp    $0x2,%eax
  100c7f:	76 b9                	jbe    100c3a <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100c81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c86:	c9                   	leave  
  100c87:	c3                   	ret    

00100c88 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100c88:	55                   	push   %ebp
  100c89:	89 e5                	mov    %esp,%ebp
  100c8b:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100c8e:	e8 c3 fb ff ff       	call   100856 <print_kerninfo>
    return 0;
  100c93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c98:	c9                   	leave  
  100c99:	c3                   	ret    

00100c9a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100c9a:	55                   	push   %ebp
  100c9b:	89 e5                	mov    %esp,%ebp
  100c9d:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100ca0:	e8 fb fc ff ff       	call   1009a0 <print_stackframe>
    return 0;
  100ca5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100caa:	c9                   	leave  
  100cab:	c3                   	ret    

00100cac <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100cac:	55                   	push   %ebp
  100cad:	89 e5                	mov    %esp,%ebp
  100caf:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100cb2:	a1 40 ee 10 00       	mov    0x10ee40,%eax
  100cb7:	85 c0                	test   %eax,%eax
  100cb9:	74 02                	je     100cbd <__panic+0x11>
        goto panic_dead;
  100cbb:	eb 59                	jmp    100d16 <__panic+0x6a>
    }
    is_panic = 1;
  100cbd:	c7 05 40 ee 10 00 01 	movl   $0x1,0x10ee40
  100cc4:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100cc7:	8d 45 14             	lea    0x14(%ebp),%eax
  100cca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100ccd:	8b 45 0c             	mov    0xc(%ebp),%eax
  100cd0:	89 44 24 08          	mov    %eax,0x8(%esp)
  100cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  100cd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cdb:	c7 04 24 86 38 10 00 	movl   $0x103886,(%esp)
  100ce2:	e8 3b f6 ff ff       	call   100322 <cprintf>
    vcprintf(fmt, ap);
  100ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cea:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cee:	8b 45 10             	mov    0x10(%ebp),%eax
  100cf1:	89 04 24             	mov    %eax,(%esp)
  100cf4:	e8 f6 f5 ff ff       	call   1002ef <vcprintf>
    cprintf("\n");
  100cf9:	c7 04 24 a2 38 10 00 	movl   $0x1038a2,(%esp)
  100d00:	e8 1d f6 ff ff       	call   100322 <cprintf>
    
    cprintf("stack trackback:\n");
  100d05:	c7 04 24 a4 38 10 00 	movl   $0x1038a4,(%esp)
  100d0c:	e8 11 f6 ff ff       	call   100322 <cprintf>
    print_stackframe();
  100d11:	e8 8a fc ff ff       	call   1009a0 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d16:	e8 22 09 00 00       	call   10163d <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d22:	e8 a4 fe ff ff       	call   100bcb <kmonitor>
    }
  100d27:	eb f2                	jmp    100d1b <__panic+0x6f>

00100d29 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d29:	55                   	push   %ebp
  100d2a:	89 e5                	mov    %esp,%ebp
  100d2c:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d2f:	8d 45 14             	lea    0x14(%ebp),%eax
  100d32:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d35:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d38:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  100d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d43:	c7 04 24 b6 38 10 00 	movl   $0x1038b6,(%esp)
  100d4a:	e8 d3 f5 ff ff       	call   100322 <cprintf>
    vcprintf(fmt, ap);
  100d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d52:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d56:	8b 45 10             	mov    0x10(%ebp),%eax
  100d59:	89 04 24             	mov    %eax,(%esp)
  100d5c:	e8 8e f5 ff ff       	call   1002ef <vcprintf>
    cprintf("\n");
  100d61:	c7 04 24 a2 38 10 00 	movl   $0x1038a2,(%esp)
  100d68:	e8 b5 f5 ff ff       	call   100322 <cprintf>
    va_end(ap);
}
  100d6d:	c9                   	leave  
  100d6e:	c3                   	ret    

00100d6f <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100d6f:	55                   	push   %ebp
  100d70:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100d72:	a1 40 ee 10 00       	mov    0x10ee40,%eax
}
  100d77:	5d                   	pop    %ebp
  100d78:	c3                   	ret    

00100d79 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d79:	55                   	push   %ebp
  100d7a:	89 e5                	mov    %esp,%ebp
  100d7c:	83 ec 28             	sub    $0x28,%esp
  100d7f:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100d85:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100d89:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100d8d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100d91:	ee                   	out    %al,(%dx)
  100d92:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100d98:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
  100d9c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100da0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100da4:	ee                   	out    %al,(%dx)
  100da5:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
  100dab:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
  100daf:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100db3:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100db7:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100db8:	c7 05 08 f9 10 00 00 	movl   $0x0,0x10f908
  100dbf:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dc2:	c7 04 24 d4 38 10 00 	movl   $0x1038d4,(%esp)
  100dc9:	e8 54 f5 ff ff       	call   100322 <cprintf>
    pic_enable(IRQ_TIMER);
  100dce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100dd5:	e8 c1 08 00 00       	call   10169b <pic_enable>
}
  100dda:	c9                   	leave  
  100ddb:	c3                   	ret    

00100ddc <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100ddc:	55                   	push   %ebp
  100ddd:	89 e5                	mov    %esp,%ebp
  100ddf:	83 ec 10             	sub    $0x10,%esp
  100de2:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100de8:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100dec:	89 c2                	mov    %eax,%edx
  100dee:	ec                   	in     (%dx),%al
  100def:	88 45 fd             	mov    %al,-0x3(%ebp)
  100df2:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100df8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100dfc:	89 c2                	mov    %eax,%edx
  100dfe:	ec                   	in     (%dx),%al
  100dff:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e02:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e08:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e0c:	89 c2                	mov    %eax,%edx
  100e0e:	ec                   	in     (%dx),%al
  100e0f:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e12:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
  100e18:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e1c:	89 c2                	mov    %eax,%edx
  100e1e:	ec                   	in     (%dx),%al
  100e1f:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e22:	c9                   	leave  
  100e23:	c3                   	ret    

00100e24 <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5 
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  100e24:	55                   	push   %ebp
  100e25:	89 e5                	mov    %esp,%ebp
  100e27:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  100e2a:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  100e31:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e34:	0f b7 00             	movzwl (%eax),%eax
  100e37:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  100e3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e3e:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  100e43:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e46:	0f b7 00             	movzwl (%eax),%eax
  100e49:	66 3d 5a a5          	cmp    $0xa55a,%ax
  100e4d:	74 12                	je     100e61 <cga_init+0x3d>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  100e4f:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  100e56:	66 c7 05 66 ee 10 00 	movw   $0x3b4,0x10ee66
  100e5d:	b4 03 
  100e5f:	eb 13                	jmp    100e74 <cga_init+0x50>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  100e61:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e64:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e68:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4 
  100e6b:	66 c7 05 66 ee 10 00 	movw   $0x3d4,0x10ee66
  100e72:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);                                        
  100e74:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e7b:	0f b7 c0             	movzwl %ax,%eax
  100e7e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  100e82:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e86:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100e8a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100e8e:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  100e8f:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100e96:	83 c0 01             	add    $0x1,%eax
  100e99:	0f b7 c0             	movzwl %ax,%eax
  100e9c:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ea0:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100ea4:	89 c2                	mov    %eax,%edx
  100ea6:	ec                   	in     (%dx),%al
  100ea7:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100eaa:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100eae:	0f b6 c0             	movzbl %al,%eax
  100eb1:	c1 e0 08             	shl    $0x8,%eax
  100eb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100eb7:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100ebe:	0f b7 c0             	movzwl %ax,%eax
  100ec1:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  100ec5:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100ec9:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100ecd:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100ed1:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  100ed2:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  100ed9:	83 c0 01             	add    $0x1,%eax
  100edc:	0f b7 c0             	movzwl %ax,%eax
  100edf:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ee3:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100ee7:	89 c2                	mov    %eax,%edx
  100ee9:	ec                   	in     (%dx),%al
  100eea:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
  100eed:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100ef1:	0f b6 c0             	movzbl %al,%eax
  100ef4:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  100ef7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100efa:	a3 60 ee 10 00       	mov    %eax,0x10ee60
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  100eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f02:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
}
  100f08:	c9                   	leave  
  100f09:	c3                   	ret    

00100f0a <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f0a:	55                   	push   %ebp
  100f0b:	89 e5                	mov    %esp,%ebp
  100f0d:	83 ec 48             	sub    $0x48,%esp
  100f10:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f16:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f1a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100f1e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f22:	ee                   	out    %al,(%dx)
  100f23:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
  100f29:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
  100f2d:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f31:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f35:	ee                   	out    %al,(%dx)
  100f36:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
  100f3c:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
  100f40:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f44:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f48:	ee                   	out    %al,(%dx)
  100f49:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100f4f:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
  100f53:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f57:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f5b:	ee                   	out    %al,(%dx)
  100f5c:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
  100f62:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
  100f66:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f6a:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f6e:	ee                   	out    %al,(%dx)
  100f6f:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
  100f75:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
  100f79:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100f7d:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100f81:	ee                   	out    %al,(%dx)
  100f82:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100f88:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
  100f8c:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f90:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100f94:	ee                   	out    %al,(%dx)
  100f95:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f9b:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
  100f9f:	89 c2                	mov    %eax,%edx
  100fa1:	ec                   	in     (%dx),%al
  100fa2:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
  100fa5:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100fa9:	3c ff                	cmp    $0xff,%al
  100fab:	0f 95 c0             	setne  %al
  100fae:	0f b6 c0             	movzbl %al,%eax
  100fb1:	a3 68 ee 10 00       	mov    %eax,0x10ee68
  100fb6:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100fbc:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
  100fc0:	89 c2                	mov    %eax,%edx
  100fc2:	ec                   	in     (%dx),%al
  100fc3:	88 45 d5             	mov    %al,-0x2b(%ebp)
  100fc6:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
  100fcc:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
  100fd0:	89 c2                	mov    %eax,%edx
  100fd2:	ec                   	in     (%dx),%al
  100fd3:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  100fd6:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  100fdb:	85 c0                	test   %eax,%eax
  100fdd:	74 0c                	je     100feb <serial_init+0xe1>
        pic_enable(IRQ_COM1);
  100fdf:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  100fe6:	e8 b0 06 00 00       	call   10169b <pic_enable>
    }
}
  100feb:	c9                   	leave  
  100fec:	c3                   	ret    

00100fed <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  100fed:	55                   	push   %ebp
  100fee:	89 e5                	mov    %esp,%ebp
  100ff0:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100ff3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  100ffa:	eb 09                	jmp    101005 <lpt_putc_sub+0x18>
        delay();
  100ffc:	e8 db fd ff ff       	call   100ddc <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101001:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101005:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  10100b:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10100f:	89 c2                	mov    %eax,%edx
  101011:	ec                   	in     (%dx),%al
  101012:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101015:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101019:	84 c0                	test   %al,%al
  10101b:	78 09                	js     101026 <lpt_putc_sub+0x39>
  10101d:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101024:	7e d6                	jle    100ffc <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  101026:	8b 45 08             	mov    0x8(%ebp),%eax
  101029:	0f b6 c0             	movzbl %al,%eax
  10102c:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
  101032:	88 45 f5             	mov    %al,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101035:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101039:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10103d:	ee                   	out    %al,(%dx)
  10103e:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  101044:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101048:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10104c:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101050:	ee                   	out    %al,(%dx)
  101051:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
  101057:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
  10105b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10105f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101063:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  101064:	c9                   	leave  
  101065:	c3                   	ret    

00101066 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  101066:	55                   	push   %ebp
  101067:	89 e5                	mov    %esp,%ebp
  101069:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10106c:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101070:	74 0d                	je     10107f <lpt_putc+0x19>
        lpt_putc_sub(c);
  101072:	8b 45 08             	mov    0x8(%ebp),%eax
  101075:	89 04 24             	mov    %eax,(%esp)
  101078:	e8 70 ff ff ff       	call   100fed <lpt_putc_sub>
  10107d:	eb 24                	jmp    1010a3 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
  10107f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101086:	e8 62 ff ff ff       	call   100fed <lpt_putc_sub>
        lpt_putc_sub(' ');
  10108b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101092:	e8 56 ff ff ff       	call   100fed <lpt_putc_sub>
        lpt_putc_sub('\b');
  101097:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10109e:	e8 4a ff ff ff       	call   100fed <lpt_putc_sub>
    }
}
  1010a3:	c9                   	leave  
  1010a4:	c3                   	ret    

001010a5 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1010a5:	55                   	push   %ebp
  1010a6:	89 e5                	mov    %esp,%ebp
  1010a8:	53                   	push   %ebx
  1010a9:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1010af:	b0 00                	mov    $0x0,%al
  1010b1:	85 c0                	test   %eax,%eax
  1010b3:	75 07                	jne    1010bc <cga_putc+0x17>
        c |= 0x0700;
  1010b5:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  1010bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1010bf:	0f b6 c0             	movzbl %al,%eax
  1010c2:	83 f8 0a             	cmp    $0xa,%eax
  1010c5:	74 4c                	je     101113 <cga_putc+0x6e>
  1010c7:	83 f8 0d             	cmp    $0xd,%eax
  1010ca:	74 57                	je     101123 <cga_putc+0x7e>
  1010cc:	83 f8 08             	cmp    $0x8,%eax
  1010cf:	0f 85 88 00 00 00    	jne    10115d <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
  1010d5:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010dc:	66 85 c0             	test   %ax,%ax
  1010df:	74 30                	je     101111 <cga_putc+0x6c>
            crt_pos --;
  1010e1:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1010e8:	83 e8 01             	sub    $0x1,%eax
  1010eb:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1010f1:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1010f6:	0f b7 15 64 ee 10 00 	movzwl 0x10ee64,%edx
  1010fd:	0f b7 d2             	movzwl %dx,%edx
  101100:	01 d2                	add    %edx,%edx
  101102:	01 c2                	add    %eax,%edx
  101104:	8b 45 08             	mov    0x8(%ebp),%eax
  101107:	b0 00                	mov    $0x0,%al
  101109:	83 c8 20             	or     $0x20,%eax
  10110c:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  10110f:	eb 72                	jmp    101183 <cga_putc+0xde>
  101111:	eb 70                	jmp    101183 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
  101113:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10111a:	83 c0 50             	add    $0x50,%eax
  10111d:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  101123:	0f b7 1d 64 ee 10 00 	movzwl 0x10ee64,%ebx
  10112a:	0f b7 0d 64 ee 10 00 	movzwl 0x10ee64,%ecx
  101131:	0f b7 c1             	movzwl %cx,%eax
  101134:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
  10113a:	c1 e8 10             	shr    $0x10,%eax
  10113d:	89 c2                	mov    %eax,%edx
  10113f:	66 c1 ea 06          	shr    $0x6,%dx
  101143:	89 d0                	mov    %edx,%eax
  101145:	c1 e0 02             	shl    $0x2,%eax
  101148:	01 d0                	add    %edx,%eax
  10114a:	c1 e0 04             	shl    $0x4,%eax
  10114d:	29 c1                	sub    %eax,%ecx
  10114f:	89 ca                	mov    %ecx,%edx
  101151:	89 d8                	mov    %ebx,%eax
  101153:	29 d0                	sub    %edx,%eax
  101155:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
        break;
  10115b:	eb 26                	jmp    101183 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  10115d:	8b 0d 60 ee 10 00    	mov    0x10ee60,%ecx
  101163:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10116a:	8d 50 01             	lea    0x1(%eax),%edx
  10116d:	66 89 15 64 ee 10 00 	mov    %dx,0x10ee64
  101174:	0f b7 c0             	movzwl %ax,%eax
  101177:	01 c0                	add    %eax,%eax
  101179:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  10117c:	8b 45 08             	mov    0x8(%ebp),%eax
  10117f:	66 89 02             	mov    %ax,(%edx)
        break;
  101182:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101183:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10118a:	66 3d cf 07          	cmp    $0x7cf,%ax
  10118e:	76 5b                	jbe    1011eb <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101190:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  101195:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  10119b:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011a0:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  1011a7:	00 
  1011a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  1011ac:	89 04 24             	mov    %eax,(%esp)
  1011af:	e8 b6 22 00 00       	call   10346a <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011b4:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  1011bb:	eb 15                	jmp    1011d2 <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
  1011bd:	a1 60 ee 10 00       	mov    0x10ee60,%eax
  1011c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1011c5:	01 d2                	add    %edx,%edx
  1011c7:	01 d0                	add    %edx,%eax
  1011c9:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011ce:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  1011d2:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1011d9:	7e e2                	jle    1011bd <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  1011db:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  1011e2:	83 e8 50             	sub    $0x50,%eax
  1011e5:	66 a3 64 ee 10 00    	mov    %ax,0x10ee64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1011eb:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  1011f2:	0f b7 c0             	movzwl %ax,%eax
  1011f5:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  1011f9:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
  1011fd:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101201:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101205:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101206:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  10120d:	66 c1 e8 08          	shr    $0x8,%ax
  101211:	0f b6 c0             	movzbl %al,%eax
  101214:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  10121b:	83 c2 01             	add    $0x1,%edx
  10121e:	0f b7 d2             	movzwl %dx,%edx
  101221:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
  101225:	88 45 ed             	mov    %al,-0x13(%ebp)
  101228:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10122c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101230:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101231:	0f b7 05 66 ee 10 00 	movzwl 0x10ee66,%eax
  101238:	0f b7 c0             	movzwl %ax,%eax
  10123b:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
  10123f:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
  101243:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101247:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10124b:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  10124c:	0f b7 05 64 ee 10 00 	movzwl 0x10ee64,%eax
  101253:	0f b6 c0             	movzbl %al,%eax
  101256:	0f b7 15 66 ee 10 00 	movzwl 0x10ee66,%edx
  10125d:	83 c2 01             	add    $0x1,%edx
  101260:	0f b7 d2             	movzwl %dx,%edx
  101263:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
  101267:	88 45 e5             	mov    %al,-0x1b(%ebp)
  10126a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  10126e:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101272:	ee                   	out    %al,(%dx)
}
  101273:	83 c4 34             	add    $0x34,%esp
  101276:	5b                   	pop    %ebx
  101277:	5d                   	pop    %ebp
  101278:	c3                   	ret    

00101279 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101279:	55                   	push   %ebp
  10127a:	89 e5                	mov    %esp,%ebp
  10127c:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10127f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101286:	eb 09                	jmp    101291 <serial_putc_sub+0x18>
        delay();
  101288:	e8 4f fb ff ff       	call   100ddc <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10128d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  101291:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101297:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10129b:	89 c2                	mov    %eax,%edx
  10129d:	ec                   	in     (%dx),%al
  10129e:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1012a1:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1012a5:	0f b6 c0             	movzbl %al,%eax
  1012a8:	83 e0 20             	and    $0x20,%eax
  1012ab:	85 c0                	test   %eax,%eax
  1012ad:	75 09                	jne    1012b8 <serial_putc_sub+0x3f>
  1012af:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1012b6:	7e d0                	jle    101288 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  1012b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1012bb:	0f b6 c0             	movzbl %al,%eax
  1012be:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  1012c4:	88 45 f5             	mov    %al,-0xb(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012c7:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1012cb:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1012cf:	ee                   	out    %al,(%dx)
}
  1012d0:	c9                   	leave  
  1012d1:	c3                   	ret    

001012d2 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1012d2:	55                   	push   %ebp
  1012d3:	89 e5                	mov    %esp,%ebp
  1012d5:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1012d8:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1012dc:	74 0d                	je     1012eb <serial_putc+0x19>
        serial_putc_sub(c);
  1012de:	8b 45 08             	mov    0x8(%ebp),%eax
  1012e1:	89 04 24             	mov    %eax,(%esp)
  1012e4:	e8 90 ff ff ff       	call   101279 <serial_putc_sub>
  1012e9:	eb 24                	jmp    10130f <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
  1012eb:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1012f2:	e8 82 ff ff ff       	call   101279 <serial_putc_sub>
        serial_putc_sub(' ');
  1012f7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1012fe:	e8 76 ff ff ff       	call   101279 <serial_putc_sub>
        serial_putc_sub('\b');
  101303:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10130a:	e8 6a ff ff ff       	call   101279 <serial_putc_sub>
    }
}
  10130f:	c9                   	leave  
  101310:	c3                   	ret    

00101311 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101311:	55                   	push   %ebp
  101312:	89 e5                	mov    %esp,%ebp
  101314:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101317:	eb 33                	jmp    10134c <cons_intr+0x3b>
        if (c != 0) {
  101319:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10131d:	74 2d                	je     10134c <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  10131f:	a1 84 f0 10 00       	mov    0x10f084,%eax
  101324:	8d 50 01             	lea    0x1(%eax),%edx
  101327:	89 15 84 f0 10 00    	mov    %edx,0x10f084
  10132d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101330:	88 90 80 ee 10 00    	mov    %dl,0x10ee80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101336:	a1 84 f0 10 00       	mov    0x10f084,%eax
  10133b:	3d 00 02 00 00       	cmp    $0x200,%eax
  101340:	75 0a                	jne    10134c <cons_intr+0x3b>
                cons.wpos = 0;
  101342:	c7 05 84 f0 10 00 00 	movl   $0x0,0x10f084
  101349:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  10134c:	8b 45 08             	mov    0x8(%ebp),%eax
  10134f:	ff d0                	call   *%eax
  101351:	89 45 f4             	mov    %eax,-0xc(%ebp)
  101354:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101358:	75 bf                	jne    101319 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  10135a:	c9                   	leave  
  10135b:	c3                   	ret    

0010135c <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  10135c:	55                   	push   %ebp
  10135d:	89 e5                	mov    %esp,%ebp
  10135f:	83 ec 10             	sub    $0x10,%esp
  101362:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101368:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10136c:	89 c2                	mov    %eax,%edx
  10136e:	ec                   	in     (%dx),%al
  10136f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101372:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  101376:	0f b6 c0             	movzbl %al,%eax
  101379:	83 e0 01             	and    $0x1,%eax
  10137c:	85 c0                	test   %eax,%eax
  10137e:	75 07                	jne    101387 <serial_proc_data+0x2b>
        return -1;
  101380:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101385:	eb 2a                	jmp    1013b1 <serial_proc_data+0x55>
  101387:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10138d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101391:	89 c2                	mov    %eax,%edx
  101393:	ec                   	in     (%dx),%al
  101394:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101397:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  10139b:	0f b6 c0             	movzbl %al,%eax
  10139e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1013a1:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  1013a5:	75 07                	jne    1013ae <serial_proc_data+0x52>
        c = '\b';
  1013a7:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  1013ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1013b1:	c9                   	leave  
  1013b2:	c3                   	ret    

001013b3 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  1013b3:	55                   	push   %ebp
  1013b4:	89 e5                	mov    %esp,%ebp
  1013b6:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  1013b9:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  1013be:	85 c0                	test   %eax,%eax
  1013c0:	74 0c                	je     1013ce <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  1013c2:	c7 04 24 5c 13 10 00 	movl   $0x10135c,(%esp)
  1013c9:	e8 43 ff ff ff       	call   101311 <cons_intr>
    }
}
  1013ce:	c9                   	leave  
  1013cf:	c3                   	ret    

001013d0 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  1013d0:	55                   	push   %ebp
  1013d1:	89 e5                	mov    %esp,%ebp
  1013d3:	83 ec 38             	sub    $0x38,%esp
  1013d6:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013dc:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1013e0:	89 c2                	mov    %eax,%edx
  1013e2:	ec                   	in     (%dx),%al
  1013e3:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  1013e6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1013ea:	0f b6 c0             	movzbl %al,%eax
  1013ed:	83 e0 01             	and    $0x1,%eax
  1013f0:	85 c0                	test   %eax,%eax
  1013f2:	75 0a                	jne    1013fe <kbd_proc_data+0x2e>
        return -1;
  1013f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013f9:	e9 59 01 00 00       	jmp    101557 <kbd_proc_data+0x187>
  1013fe:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101404:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101408:	89 c2                	mov    %eax,%edx
  10140a:	ec                   	in     (%dx),%al
  10140b:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  10140e:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101412:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  101415:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101419:	75 17                	jne    101432 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
  10141b:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101420:	83 c8 40             	or     $0x40,%eax
  101423:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101428:	b8 00 00 00 00       	mov    $0x0,%eax
  10142d:	e9 25 01 00 00       	jmp    101557 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  101432:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101436:	84 c0                	test   %al,%al
  101438:	79 47                	jns    101481 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  10143a:	a1 88 f0 10 00       	mov    0x10f088,%eax
  10143f:	83 e0 40             	and    $0x40,%eax
  101442:	85 c0                	test   %eax,%eax
  101444:	75 09                	jne    10144f <kbd_proc_data+0x7f>
  101446:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10144a:	83 e0 7f             	and    $0x7f,%eax
  10144d:	eb 04                	jmp    101453 <kbd_proc_data+0x83>
  10144f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101453:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101456:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10145a:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  101461:	83 c8 40             	or     $0x40,%eax
  101464:	0f b6 c0             	movzbl %al,%eax
  101467:	f7 d0                	not    %eax
  101469:	89 c2                	mov    %eax,%edx
  10146b:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101470:	21 d0                	and    %edx,%eax
  101472:	a3 88 f0 10 00       	mov    %eax,0x10f088
        return 0;
  101477:	b8 00 00 00 00       	mov    $0x0,%eax
  10147c:	e9 d6 00 00 00       	jmp    101557 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  101481:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101486:	83 e0 40             	and    $0x40,%eax
  101489:	85 c0                	test   %eax,%eax
  10148b:	74 11                	je     10149e <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  10148d:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101491:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101496:	83 e0 bf             	and    $0xffffffbf,%eax
  101499:	a3 88 f0 10 00       	mov    %eax,0x10f088
    }

    shift |= shiftcode[data];
  10149e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014a2:	0f b6 80 40 e0 10 00 	movzbl 0x10e040(%eax),%eax
  1014a9:	0f b6 d0             	movzbl %al,%edx
  1014ac:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014b1:	09 d0                	or     %edx,%eax
  1014b3:	a3 88 f0 10 00       	mov    %eax,0x10f088
    shift ^= togglecode[data];
  1014b8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014bc:	0f b6 80 40 e1 10 00 	movzbl 0x10e140(%eax),%eax
  1014c3:	0f b6 d0             	movzbl %al,%edx
  1014c6:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014cb:	31 d0                	xor    %edx,%eax
  1014cd:	a3 88 f0 10 00       	mov    %eax,0x10f088

    c = charcode[shift & (CTL | SHIFT)][data];
  1014d2:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014d7:	83 e0 03             	and    $0x3,%eax
  1014da:	8b 14 85 40 e5 10 00 	mov    0x10e540(,%eax,4),%edx
  1014e1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014e5:	01 d0                	add    %edx,%eax
  1014e7:	0f b6 00             	movzbl (%eax),%eax
  1014ea:	0f b6 c0             	movzbl %al,%eax
  1014ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1014f0:	a1 88 f0 10 00       	mov    0x10f088,%eax
  1014f5:	83 e0 08             	and    $0x8,%eax
  1014f8:	85 c0                	test   %eax,%eax
  1014fa:	74 22                	je     10151e <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  1014fc:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101500:	7e 0c                	jle    10150e <kbd_proc_data+0x13e>
  101502:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  101506:	7f 06                	jg     10150e <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  101508:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  10150c:	eb 10                	jmp    10151e <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  10150e:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101512:	7e 0a                	jle    10151e <kbd_proc_data+0x14e>
  101514:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101518:	7f 04                	jg     10151e <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  10151a:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  10151e:	a1 88 f0 10 00       	mov    0x10f088,%eax
  101523:	f7 d0                	not    %eax
  101525:	83 e0 06             	and    $0x6,%eax
  101528:	85 c0                	test   %eax,%eax
  10152a:	75 28                	jne    101554 <kbd_proc_data+0x184>
  10152c:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101533:	75 1f                	jne    101554 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  101535:	c7 04 24 ef 38 10 00 	movl   $0x1038ef,(%esp)
  10153c:	e8 e1 ed ff ff       	call   100322 <cprintf>
  101541:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101547:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10154b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  10154f:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
  101553:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101554:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101557:	c9                   	leave  
  101558:	c3                   	ret    

00101559 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  101559:	55                   	push   %ebp
  10155a:	89 e5                	mov    %esp,%ebp
  10155c:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  10155f:	c7 04 24 d0 13 10 00 	movl   $0x1013d0,(%esp)
  101566:	e8 a6 fd ff ff       	call   101311 <cons_intr>
}
  10156b:	c9                   	leave  
  10156c:	c3                   	ret    

0010156d <kbd_init>:

static void
kbd_init(void) {
  10156d:	55                   	push   %ebp
  10156e:	89 e5                	mov    %esp,%ebp
  101570:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  101573:	e8 e1 ff ff ff       	call   101559 <kbd_intr>
    pic_enable(IRQ_KBD);
  101578:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10157f:	e8 17 01 00 00       	call   10169b <pic_enable>
}
  101584:	c9                   	leave  
  101585:	c3                   	ret    

00101586 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  101586:	55                   	push   %ebp
  101587:	89 e5                	mov    %esp,%ebp
  101589:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  10158c:	e8 93 f8 ff ff       	call   100e24 <cga_init>
    serial_init();
  101591:	e8 74 f9 ff ff       	call   100f0a <serial_init>
    kbd_init();
  101596:	e8 d2 ff ff ff       	call   10156d <kbd_init>
    if (!serial_exists) {
  10159b:	a1 68 ee 10 00       	mov    0x10ee68,%eax
  1015a0:	85 c0                	test   %eax,%eax
  1015a2:	75 0c                	jne    1015b0 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  1015a4:	c7 04 24 fb 38 10 00 	movl   $0x1038fb,(%esp)
  1015ab:	e8 72 ed ff ff       	call   100322 <cprintf>
    }
}
  1015b0:	c9                   	leave  
  1015b1:	c3                   	ret    

001015b2 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  1015b2:	55                   	push   %ebp
  1015b3:	89 e5                	mov    %esp,%ebp
  1015b5:	83 ec 18             	sub    $0x18,%esp
    lpt_putc(c);
  1015b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1015bb:	89 04 24             	mov    %eax,(%esp)
  1015be:	e8 a3 fa ff ff       	call   101066 <lpt_putc>
    cga_putc(c);
  1015c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1015c6:	89 04 24             	mov    %eax,(%esp)
  1015c9:	e8 d7 fa ff ff       	call   1010a5 <cga_putc>
    serial_putc(c);
  1015ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1015d1:	89 04 24             	mov    %eax,(%esp)
  1015d4:	e8 f9 fc ff ff       	call   1012d2 <serial_putc>
}
  1015d9:	c9                   	leave  
  1015da:	c3                   	ret    

001015db <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1015db:	55                   	push   %ebp
  1015dc:	89 e5                	mov    %esp,%ebp
  1015de:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  1015e1:	e8 cd fd ff ff       	call   1013b3 <serial_intr>
    kbd_intr();
  1015e6:	e8 6e ff ff ff       	call   101559 <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  1015eb:	8b 15 80 f0 10 00    	mov    0x10f080,%edx
  1015f1:	a1 84 f0 10 00       	mov    0x10f084,%eax
  1015f6:	39 c2                	cmp    %eax,%edx
  1015f8:	74 36                	je     101630 <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  1015fa:	a1 80 f0 10 00       	mov    0x10f080,%eax
  1015ff:	8d 50 01             	lea    0x1(%eax),%edx
  101602:	89 15 80 f0 10 00    	mov    %edx,0x10f080
  101608:	0f b6 80 80 ee 10 00 	movzbl 0x10ee80(%eax),%eax
  10160f:	0f b6 c0             	movzbl %al,%eax
  101612:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  101615:	a1 80 f0 10 00       	mov    0x10f080,%eax
  10161a:	3d 00 02 00 00       	cmp    $0x200,%eax
  10161f:	75 0a                	jne    10162b <cons_getc+0x50>
            cons.rpos = 0;
  101621:	c7 05 80 f0 10 00 00 	movl   $0x0,0x10f080
  101628:	00 00 00 
        }
        return c;
  10162b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10162e:	eb 05                	jmp    101635 <cons_getc+0x5a>
    }
    return 0;
  101630:	b8 00 00 00 00       	mov    $0x0,%eax
}
  101635:	c9                   	leave  
  101636:	c3                   	ret    

00101637 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101637:	55                   	push   %ebp
  101638:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  10163a:	fb                   	sti    
    sti();
}
  10163b:	5d                   	pop    %ebp
  10163c:	c3                   	ret    

0010163d <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  10163d:	55                   	push   %ebp
  10163e:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli");
  101640:	fa                   	cli    
    cli();
}
  101641:	5d                   	pop    %ebp
  101642:	c3                   	ret    

00101643 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  101643:	55                   	push   %ebp
  101644:	89 e5                	mov    %esp,%ebp
  101646:	83 ec 14             	sub    $0x14,%esp
  101649:	8b 45 08             	mov    0x8(%ebp),%eax
  10164c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  101650:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101654:	66 a3 50 e5 10 00    	mov    %ax,0x10e550
    if (did_init) {
  10165a:	a1 8c f0 10 00       	mov    0x10f08c,%eax
  10165f:	85 c0                	test   %eax,%eax
  101661:	74 36                	je     101699 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
  101663:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101667:	0f b6 c0             	movzbl %al,%eax
  10166a:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101670:	88 45 fd             	mov    %al,-0x3(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101673:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101677:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10167b:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  10167c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101680:	66 c1 e8 08          	shr    $0x8,%ax
  101684:	0f b6 c0             	movzbl %al,%eax
  101687:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  10168d:	88 45 f9             	mov    %al,-0x7(%ebp)
  101690:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101694:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101698:	ee                   	out    %al,(%dx)
    }
}
  101699:	c9                   	leave  
  10169a:	c3                   	ret    

0010169b <pic_enable>:

void
pic_enable(unsigned int irq) {
  10169b:	55                   	push   %ebp
  10169c:	89 e5                	mov    %esp,%ebp
  10169e:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  1016a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1016a4:	ba 01 00 00 00       	mov    $0x1,%edx
  1016a9:	89 c1                	mov    %eax,%ecx
  1016ab:	d3 e2                	shl    %cl,%edx
  1016ad:	89 d0                	mov    %edx,%eax
  1016af:	f7 d0                	not    %eax
  1016b1:	89 c2                	mov    %eax,%edx
  1016b3:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1016ba:	21 d0                	and    %edx,%eax
  1016bc:	0f b7 c0             	movzwl %ax,%eax
  1016bf:	89 04 24             	mov    %eax,(%esp)
  1016c2:	e8 7c ff ff ff       	call   101643 <pic_setmask>
}
  1016c7:	c9                   	leave  
  1016c8:	c3                   	ret    

001016c9 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1016c9:	55                   	push   %ebp
  1016ca:	89 e5                	mov    %esp,%ebp
  1016cc:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  1016cf:	c7 05 8c f0 10 00 01 	movl   $0x1,0x10f08c
  1016d6:	00 00 00 
  1016d9:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016df:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
  1016e3:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1016e7:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016eb:	ee                   	out    %al,(%dx)
  1016ec:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
  1016f2:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
  1016f6:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1016fa:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1016fe:	ee                   	out    %al,(%dx)
  1016ff:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  101705:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
  101709:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10170d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101711:	ee                   	out    %al,(%dx)
  101712:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
  101718:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
  10171c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101720:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101724:	ee                   	out    %al,(%dx)
  101725:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
  10172b:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
  10172f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101733:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101737:	ee                   	out    %al,(%dx)
  101738:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
  10173e:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
  101742:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101746:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10174a:	ee                   	out    %al,(%dx)
  10174b:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  101751:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
  101755:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101759:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10175d:	ee                   	out    %al,(%dx)
  10175e:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
  101764:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
  101768:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  10176c:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101770:	ee                   	out    %al,(%dx)
  101771:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
  101777:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
  10177b:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  10177f:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101783:	ee                   	out    %al,(%dx)
  101784:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
  10178a:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
  10178e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101792:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101796:	ee                   	out    %al,(%dx)
  101797:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
  10179d:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
  1017a1:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  1017a5:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  1017a9:	ee                   	out    %al,(%dx)
  1017aa:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  1017b0:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
  1017b4:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  1017b8:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  1017bc:	ee                   	out    %al,(%dx)
  1017bd:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
  1017c3:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
  1017c7:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  1017cb:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  1017cf:	ee                   	out    %al,(%dx)
  1017d0:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
  1017d6:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
  1017da:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1017de:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1017e2:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1017e3:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017ea:	66 83 f8 ff          	cmp    $0xffff,%ax
  1017ee:	74 12                	je     101802 <pic_init+0x139>
        pic_setmask(irq_mask);
  1017f0:	0f b7 05 50 e5 10 00 	movzwl 0x10e550,%eax
  1017f7:	0f b7 c0             	movzwl %ax,%eax
  1017fa:	89 04 24             	mov    %eax,(%esp)
  1017fd:	e8 41 fe ff ff       	call   101643 <pic_setmask>
    }
}
  101802:	c9                   	leave  
  101803:	c3                   	ret    

00101804 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  101804:	55                   	push   %ebp
  101805:	89 e5                	mov    %esp,%ebp
  101807:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  10180a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  101811:	00 
  101812:	c7 04 24 20 39 10 00 	movl   $0x103920,(%esp)
  101819:	e8 04 eb ff ff       	call   100322 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  10181e:	c7 04 24 2a 39 10 00 	movl   $0x10392a,(%esp)
  101825:	e8 f8 ea ff ff       	call   100322 <cprintf>
    panic("EOT: kernel seems ok.");
  10182a:	c7 44 24 08 38 39 10 	movl   $0x103938,0x8(%esp)
  101831:	00 
  101832:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  101839:	00 
  10183a:	c7 04 24 4e 39 10 00 	movl   $0x10394e,(%esp)
  101841:	e8 66 f4 ff ff       	call   100cac <__panic>

00101846 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  101846:	55                   	push   %ebp
  101847:	89 e5                	mov    %esp,%ebp
  101849:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
    	int i;
    	for (i = 0; i < 256; i ++) {
  10184c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101853:	e9 c3 00 00 00       	jmp    10191b <idt_init+0xd5>
        	SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  101858:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10185b:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  101862:	89 c2                	mov    %eax,%edx
  101864:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101867:	66 89 14 c5 a0 f0 10 	mov    %dx,0x10f0a0(,%eax,8)
  10186e:	00 
  10186f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101872:	66 c7 04 c5 a2 f0 10 	movw   $0x8,0x10f0a2(,%eax,8)
  101879:	00 08 00 
  10187c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10187f:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  101886:	00 
  101887:	83 e2 e0             	and    $0xffffffe0,%edx
  10188a:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  101891:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101894:	0f b6 14 c5 a4 f0 10 	movzbl 0x10f0a4(,%eax,8),%edx
  10189b:	00 
  10189c:	83 e2 1f             	and    $0x1f,%edx
  10189f:	88 14 c5 a4 f0 10 00 	mov    %dl,0x10f0a4(,%eax,8)
  1018a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018a9:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018b0:	00 
  1018b1:	83 e2 f0             	and    $0xfffffff0,%edx
  1018b4:	83 ca 0e             	or     $0xe,%edx
  1018b7:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018be:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018c1:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018c8:	00 
  1018c9:	83 e2 ef             	and    $0xffffffef,%edx
  1018cc:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018d6:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018dd:	00 
  1018de:	83 e2 9f             	and    $0xffffff9f,%edx
  1018e1:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018eb:	0f b6 14 c5 a5 f0 10 	movzbl 0x10f0a5(,%eax,8),%edx
  1018f2:	00 
  1018f3:	83 ca 80             	or     $0xffffff80,%edx
  1018f6:	88 14 c5 a5 f0 10 00 	mov    %dl,0x10f0a5(,%eax,8)
  1018fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101900:	8b 04 85 e0 e5 10 00 	mov    0x10e5e0(,%eax,4),%eax
  101907:	c1 e8 10             	shr    $0x10,%eax
  10190a:	89 c2                	mov    %eax,%edx
  10190c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10190f:	66 89 14 c5 a6 f0 10 	mov    %dx,0x10f0a6(,%eax,8)
  101916:	00 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
	extern uintptr_t __vectors[];
    	int i;
    	for (i = 0; i < 256; i ++) {
  101917:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10191b:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  101922:	0f 8e 30 ff ff ff    	jle    101858 <idt_init+0x12>
        	SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    	}
    	SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  101928:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  10192d:	66 a3 68 f4 10 00    	mov    %ax,0x10f468
  101933:	66 c7 05 6a f4 10 00 	movw   $0x8,0x10f46a
  10193a:	08 00 
  10193c:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  101943:	83 e0 e0             	and    $0xffffffe0,%eax
  101946:	a2 6c f4 10 00       	mov    %al,0x10f46c
  10194b:	0f b6 05 6c f4 10 00 	movzbl 0x10f46c,%eax
  101952:	83 e0 1f             	and    $0x1f,%eax
  101955:	a2 6c f4 10 00       	mov    %al,0x10f46c
  10195a:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101961:	83 e0 f0             	and    $0xfffffff0,%eax
  101964:	83 c8 0e             	or     $0xe,%eax
  101967:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10196c:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101973:	83 e0 ef             	and    $0xffffffef,%eax
  101976:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10197b:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101982:	83 c8 60             	or     $0x60,%eax
  101985:	a2 6d f4 10 00       	mov    %al,0x10f46d
  10198a:	0f b6 05 6d f4 10 00 	movzbl 0x10f46d,%eax
  101991:	83 c8 80             	or     $0xffffff80,%eax
  101994:	a2 6d f4 10 00       	mov    %al,0x10f46d
  101999:	a1 c4 e7 10 00       	mov    0x10e7c4,%eax
  10199e:	c1 e8 10             	shr    $0x10,%eax
  1019a1:	66 a3 6e f4 10 00    	mov    %ax,0x10f46e
  1019a7:	c7 45 f8 60 e5 10 00 	movl   $0x10e560,-0x8(%ebp)
    return ebp;
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd));
  1019ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1019b1:	0f 01 18             	lidtl  (%eax)
    	lidt(&idt_pd);
}
  1019b4:	c9                   	leave  
  1019b5:	c3                   	ret    

001019b6 <trapname>:

static const char *
trapname(int trapno) {
  1019b6:	55                   	push   %ebp
  1019b7:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  1019b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1019bc:	83 f8 13             	cmp    $0x13,%eax
  1019bf:	77 0c                	ja     1019cd <trapname+0x17>
        return excnames[trapno];
  1019c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1019c4:	8b 04 85 a0 3c 10 00 	mov    0x103ca0(,%eax,4),%eax
  1019cb:	eb 18                	jmp    1019e5 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  1019cd:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  1019d1:	7e 0d                	jle    1019e0 <trapname+0x2a>
  1019d3:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  1019d7:	7f 07                	jg     1019e0 <trapname+0x2a>
        return "Hardware Interrupt";
  1019d9:	b8 5f 39 10 00       	mov    $0x10395f,%eax
  1019de:	eb 05                	jmp    1019e5 <trapname+0x2f>
    }
    return "(unknown trap)";
  1019e0:	b8 72 39 10 00       	mov    $0x103972,%eax
}
  1019e5:	5d                   	pop    %ebp
  1019e6:	c3                   	ret    

001019e7 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019e7:	55                   	push   %ebp
  1019e8:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  1019ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1019ed:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1019f1:	66 83 f8 08          	cmp    $0x8,%ax
  1019f5:	0f 94 c0             	sete   %al
  1019f8:	0f b6 c0             	movzbl %al,%eax
}
  1019fb:	5d                   	pop    %ebp
  1019fc:	c3                   	ret    

001019fd <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  1019fd:	55                   	push   %ebp
  1019fe:	89 e5                	mov    %esp,%ebp
  101a00:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a03:	8b 45 08             	mov    0x8(%ebp),%eax
  101a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a0a:	c7 04 24 b3 39 10 00 	movl   $0x1039b3,(%esp)
  101a11:	e8 0c e9 ff ff       	call   100322 <cprintf>
    print_regs(&tf->tf_regs);
  101a16:	8b 45 08             	mov    0x8(%ebp),%eax
  101a19:	89 04 24             	mov    %eax,(%esp)
  101a1c:	e8 a1 01 00 00       	call   101bc2 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a21:	8b 45 08             	mov    0x8(%ebp),%eax
  101a24:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a28:	0f b7 c0             	movzwl %ax,%eax
  101a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a2f:	c7 04 24 c4 39 10 00 	movl   $0x1039c4,(%esp)
  101a36:	e8 e7 e8 ff ff       	call   100322 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  101a3e:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a42:	0f b7 c0             	movzwl %ax,%eax
  101a45:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a49:	c7 04 24 d7 39 10 00 	movl   $0x1039d7,(%esp)
  101a50:	e8 cd e8 ff ff       	call   100322 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a55:	8b 45 08             	mov    0x8(%ebp),%eax
  101a58:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a5c:	0f b7 c0             	movzwl %ax,%eax
  101a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a63:	c7 04 24 ea 39 10 00 	movl   $0x1039ea,(%esp)
  101a6a:	e8 b3 e8 ff ff       	call   100322 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  101a72:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a76:	0f b7 c0             	movzwl %ax,%eax
  101a79:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a7d:	c7 04 24 fd 39 10 00 	movl   $0x1039fd,(%esp)
  101a84:	e8 99 e8 ff ff       	call   100322 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a89:	8b 45 08             	mov    0x8(%ebp),%eax
  101a8c:	8b 40 30             	mov    0x30(%eax),%eax
  101a8f:	89 04 24             	mov    %eax,(%esp)
  101a92:	e8 1f ff ff ff       	call   1019b6 <trapname>
  101a97:	8b 55 08             	mov    0x8(%ebp),%edx
  101a9a:	8b 52 30             	mov    0x30(%edx),%edx
  101a9d:	89 44 24 08          	mov    %eax,0x8(%esp)
  101aa1:	89 54 24 04          	mov    %edx,0x4(%esp)
  101aa5:	c7 04 24 10 3a 10 00 	movl   $0x103a10,(%esp)
  101aac:	e8 71 e8 ff ff       	call   100322 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ab4:	8b 40 34             	mov    0x34(%eax),%eax
  101ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101abb:	c7 04 24 22 3a 10 00 	movl   $0x103a22,(%esp)
  101ac2:	e8 5b e8 ff ff       	call   100322 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  101aca:	8b 40 38             	mov    0x38(%eax),%eax
  101acd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ad1:	c7 04 24 31 3a 10 00 	movl   $0x103a31,(%esp)
  101ad8:	e8 45 e8 ff ff       	call   100322 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101add:	8b 45 08             	mov    0x8(%ebp),%eax
  101ae0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ae4:	0f b7 c0             	movzwl %ax,%eax
  101ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101aeb:	c7 04 24 40 3a 10 00 	movl   $0x103a40,(%esp)
  101af2:	e8 2b e8 ff ff       	call   100322 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101af7:	8b 45 08             	mov    0x8(%ebp),%eax
  101afa:	8b 40 40             	mov    0x40(%eax),%eax
  101afd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b01:	c7 04 24 53 3a 10 00 	movl   $0x103a53,(%esp)
  101b08:	e8 15 e8 ff ff       	call   100322 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b0d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b14:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b1b:	eb 3e                	jmp    101b5b <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  101b20:	8b 50 40             	mov    0x40(%eax),%edx
  101b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b26:	21 d0                	and    %edx,%eax
  101b28:	85 c0                	test   %eax,%eax
  101b2a:	74 28                	je     101b54 <print_trapframe+0x157>
  101b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b2f:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b36:	85 c0                	test   %eax,%eax
  101b38:	74 1a                	je     101b54 <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
  101b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b3d:	8b 04 85 80 e5 10 00 	mov    0x10e580(,%eax,4),%eax
  101b44:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b48:	c7 04 24 62 3a 10 00 	movl   $0x103a62,(%esp)
  101b4f:	e8 ce e7 ff ff       	call   100322 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b54:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  101b58:	d1 65 f0             	shll   -0x10(%ebp)
  101b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b5e:	83 f8 17             	cmp    $0x17,%eax
  101b61:	76 ba                	jbe    101b1d <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b63:	8b 45 08             	mov    0x8(%ebp),%eax
  101b66:	8b 40 40             	mov    0x40(%eax),%eax
  101b69:	25 00 30 00 00       	and    $0x3000,%eax
  101b6e:	c1 e8 0c             	shr    $0xc,%eax
  101b71:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b75:	c7 04 24 66 3a 10 00 	movl   $0x103a66,(%esp)
  101b7c:	e8 a1 e7 ff ff       	call   100322 <cprintf>

    if (!trap_in_kernel(tf)) {
  101b81:	8b 45 08             	mov    0x8(%ebp),%eax
  101b84:	89 04 24             	mov    %eax,(%esp)
  101b87:	e8 5b fe ff ff       	call   1019e7 <trap_in_kernel>
  101b8c:	85 c0                	test   %eax,%eax
  101b8e:	75 30                	jne    101bc0 <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101b90:	8b 45 08             	mov    0x8(%ebp),%eax
  101b93:	8b 40 44             	mov    0x44(%eax),%eax
  101b96:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b9a:	c7 04 24 6f 3a 10 00 	movl   $0x103a6f,(%esp)
  101ba1:	e8 7c e7 ff ff       	call   100322 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba9:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101bad:	0f b7 c0             	movzwl %ax,%eax
  101bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bb4:	c7 04 24 7e 3a 10 00 	movl   $0x103a7e,(%esp)
  101bbb:	e8 62 e7 ff ff       	call   100322 <cprintf>
    }
}
  101bc0:	c9                   	leave  
  101bc1:	c3                   	ret    

00101bc2 <print_regs>:

struct trapframe switchk2u, *switchu2k;

void
print_regs(struct pushregs *regs) {
  101bc2:	55                   	push   %ebp
  101bc3:	89 e5                	mov    %esp,%ebp
  101bc5:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  101bcb:	8b 00                	mov    (%eax),%eax
  101bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd1:	c7 04 24 91 3a 10 00 	movl   $0x103a91,(%esp)
  101bd8:	e8 45 e7 ff ff       	call   100322 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
  101be0:	8b 40 04             	mov    0x4(%eax),%eax
  101be3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be7:	c7 04 24 a0 3a 10 00 	movl   $0x103aa0,(%esp)
  101bee:	e8 2f e7 ff ff       	call   100322 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf6:	8b 40 08             	mov    0x8(%eax),%eax
  101bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bfd:	c7 04 24 af 3a 10 00 	movl   $0x103aaf,(%esp)
  101c04:	e8 19 e7 ff ff       	call   100322 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101c09:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0c:	8b 40 0c             	mov    0xc(%eax),%eax
  101c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c13:	c7 04 24 be 3a 10 00 	movl   $0x103abe,(%esp)
  101c1a:	e8 03 e7 ff ff       	call   100322 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c22:	8b 40 10             	mov    0x10(%eax),%eax
  101c25:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c29:	c7 04 24 cd 3a 10 00 	movl   $0x103acd,(%esp)
  101c30:	e8 ed e6 ff ff       	call   100322 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c35:	8b 45 08             	mov    0x8(%ebp),%eax
  101c38:	8b 40 14             	mov    0x14(%eax),%eax
  101c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c3f:	c7 04 24 dc 3a 10 00 	movl   $0x103adc,(%esp)
  101c46:	e8 d7 e6 ff ff       	call   100322 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c4e:	8b 40 18             	mov    0x18(%eax),%eax
  101c51:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c55:	c7 04 24 eb 3a 10 00 	movl   $0x103aeb,(%esp)
  101c5c:	e8 c1 e6 ff ff       	call   100322 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c61:	8b 45 08             	mov    0x8(%ebp),%eax
  101c64:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c67:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c6b:	c7 04 24 fa 3a 10 00 	movl   $0x103afa,(%esp)
  101c72:	e8 ab e6 ff ff       	call   100322 <cprintf>
}
  101c77:	c9                   	leave  
  101c78:	c3                   	ret    

00101c79 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c79:	55                   	push   %ebp
  101c7a:	89 e5                	mov    %esp,%ebp
  101c7c:	57                   	push   %edi
  101c7d:	56                   	push   %esi
  101c7e:	53                   	push   %ebx
  101c7f:	83 ec 2c             	sub    $0x2c,%esp
    char c;

    switch (tf->tf_trapno) {
  101c82:	8b 45 08             	mov    0x8(%ebp),%eax
  101c85:	8b 40 30             	mov    0x30(%eax),%eax
  101c88:	83 f8 2f             	cmp    $0x2f,%eax
  101c8b:	77 21                	ja     101cae <trap_dispatch+0x35>
  101c8d:	83 f8 2e             	cmp    $0x2e,%eax
  101c90:	0f 83 f6 01 00 00    	jae    101e8c <trap_dispatch+0x213>
  101c96:	83 f8 21             	cmp    $0x21,%eax
  101c99:	0f 84 94 00 00 00    	je     101d33 <trap_dispatch+0xba>
  101c9f:	83 f8 24             	cmp    $0x24,%eax
  101ca2:	74 66                	je     101d0a <trap_dispatch+0x91>
  101ca4:	83 f8 20             	cmp    $0x20,%eax
  101ca7:	74 1c                	je     101cc5 <trap_dispatch+0x4c>
  101ca9:	e9 a6 01 00 00       	jmp    101e54 <trap_dispatch+0x1db>
  101cae:	83 f8 78             	cmp    $0x78,%eax
  101cb1:	0f 84 a5 00 00 00    	je     101d5c <trap_dispatch+0xe3>
  101cb7:	83 f8 79             	cmp    $0x79,%eax
  101cba:	0f 84 1b 01 00 00    	je     101ddb <trap_dispatch+0x162>
  101cc0:	e9 8f 01 00 00       	jmp    101e54 <trap_dispatch+0x1db>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
	ticks++;
  101cc5:	a1 08 f9 10 00       	mov    0x10f908,%eax
  101cca:	83 c0 01             	add    $0x1,%eax
  101ccd:	a3 08 f9 10 00       	mov    %eax,0x10f908
    	if(ticks%TICK_NUM == 0){
  101cd2:	8b 0d 08 f9 10 00    	mov    0x10f908,%ecx
  101cd8:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101cdd:	89 c8                	mov    %ecx,%eax
  101cdf:	f7 e2                	mul    %edx
  101ce1:	89 d0                	mov    %edx,%eax
  101ce3:	c1 e8 05             	shr    $0x5,%eax
  101ce6:	6b c0 64             	imul   $0x64,%eax,%eax
  101ce9:	29 c1                	sub    %eax,%ecx
  101ceb:	89 c8                	mov    %ecx,%eax
  101ced:	85 c0                	test   %eax,%eax
  101cef:	75 14                	jne    101d05 <trap_dispatch+0x8c>
		ticks=0;
  101cf1:	c7 05 08 f9 10 00 00 	movl   $0x0,0x10f908
  101cf8:	00 00 00 
    		print_ticks();
  101cfb:	e8 04 fb ff ff       	call   101804 <print_ticks>
	}

        break;
  101d00:	e9 88 01 00 00       	jmp    101e8d <trap_dispatch+0x214>
  101d05:	e9 83 01 00 00       	jmp    101e8d <trap_dispatch+0x214>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101d0a:	e8 cc f8 ff ff       	call   1015db <cons_getc>
  101d0f:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101d12:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101d16:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101d1a:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d22:	c7 04 24 09 3b 10 00 	movl   $0x103b09,(%esp)
  101d29:	e8 f4 e5 ff ff       	call   100322 <cprintf>
        break;
  101d2e:	e9 5a 01 00 00       	jmp    101e8d <trap_dispatch+0x214>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d33:	e8 a3 f8 ff ff       	call   1015db <cons_getc>
  101d38:	88 45 e7             	mov    %al,-0x19(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d3b:	0f be 55 e7          	movsbl -0x19(%ebp),%edx
  101d3f:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
  101d43:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d47:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d4b:	c7 04 24 1b 3b 10 00 	movl   $0x103b1b,(%esp)
  101d52:	e8 cb e5 ff ff       	call   100322 <cprintf>
        break;
  101d57:	e9 31 01 00 00       	jmp    101e8d <trap_dispatch+0x214>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
	if (tf->tf_cs != USER_CS) {
  101d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  101d5f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d63:	66 83 f8 1b          	cmp    $0x1b,%ax
  101d67:	74 6d                	je     101dd6 <trap_dispatch+0x15d>
            switchk2u = *tf;
  101d69:	8b 45 08             	mov    0x8(%ebp),%eax
  101d6c:	ba 20 f9 10 00       	mov    $0x10f920,%edx
  101d71:	89 c3                	mov    %eax,%ebx
  101d73:	b8 13 00 00 00       	mov    $0x13,%eax
  101d78:	89 d7                	mov    %edx,%edi
  101d7a:	89 de                	mov    %ebx,%esi
  101d7c:	89 c1                	mov    %eax,%ecx
  101d7e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
            switchk2u.tf_cs = USER_CS;
  101d80:	66 c7 05 5c f9 10 00 	movw   $0x1b,0x10f95c
  101d87:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  101d89:	66 c7 05 68 f9 10 00 	movw   $0x23,0x10f968
  101d90:	23 00 
  101d92:	0f b7 05 68 f9 10 00 	movzwl 0x10f968,%eax
  101d99:	66 a3 48 f9 10 00    	mov    %ax,0x10f948
  101d9f:	0f b7 05 48 f9 10 00 	movzwl 0x10f948,%eax
  101da6:	66 a3 4c f9 10 00    	mov    %ax,0x10f94c
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
  101dac:	8b 45 08             	mov    0x8(%ebp),%eax
  101daf:	83 c0 44             	add    $0x44,%eax
  101db2:	a3 64 f9 10 00       	mov    %eax,0x10f964
		
            switchk2u.tf_eflags |= FL_IOPL_MASK;
  101db7:	a1 60 f9 10 00       	mov    0x10f960,%eax
  101dbc:	80 cc 30             	or     $0x30,%ah
  101dbf:	a3 60 f9 10 00       	mov    %eax,0x10f960
		
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  101dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  101dc7:	8d 50 fc             	lea    -0x4(%eax),%edx
  101dca:	b8 20 f9 10 00       	mov    $0x10f920,%eax
  101dcf:	89 02                	mov    %eax,(%edx)
        }
        break;
  101dd1:	e9 b7 00 00 00       	jmp    101e8d <trap_dispatch+0x214>
  101dd6:	e9 b2 00 00 00       	jmp    101e8d <trap_dispatch+0x214>
    case T_SWITCH_TOK:
	if (tf->tf_cs != KERNEL_CS) {
  101ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  101dde:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101de2:	66 83 f8 08          	cmp    $0x8,%ax
  101de6:	74 6a                	je     101e52 <trap_dispatch+0x1d9>
            tf->tf_cs = KERNEL_CS;
  101de8:	8b 45 08             	mov    0x8(%ebp),%eax
  101deb:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
  101df1:	8b 45 08             	mov    0x8(%ebp),%eax
  101df4:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  101dfd:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101e01:	8b 45 08             	mov    0x8(%ebp),%eax
  101e04:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
  101e08:	8b 45 08             	mov    0x8(%ebp),%eax
  101e0b:	8b 40 40             	mov    0x40(%eax),%eax
  101e0e:	80 e4 cf             	and    $0xcf,%ah
  101e11:	89 c2                	mov    %eax,%edx
  101e13:	8b 45 08             	mov    0x8(%ebp),%eax
  101e16:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  101e19:	8b 45 08             	mov    0x8(%ebp),%eax
  101e1c:	8b 40 44             	mov    0x44(%eax),%eax
  101e1f:	83 e8 44             	sub    $0x44,%eax
  101e22:	a3 6c f9 10 00       	mov    %eax,0x10f96c
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  101e27:	a1 6c f9 10 00       	mov    0x10f96c,%eax
  101e2c:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  101e33:	00 
  101e34:	8b 55 08             	mov    0x8(%ebp),%edx
  101e37:	89 54 24 04          	mov    %edx,0x4(%esp)
  101e3b:	89 04 24             	mov    %eax,(%esp)
  101e3e:	e8 27 16 00 00       	call   10346a <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  101e43:	8b 45 08             	mov    0x8(%ebp),%eax
  101e46:	8d 50 fc             	lea    -0x4(%eax),%edx
  101e49:	a1 6c f9 10 00       	mov    0x10f96c,%eax
  101e4e:	89 02                	mov    %eax,(%edx)
        //panic("T_SWITCH_** ??\n");
        //break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101e50:	eb 3a                	jmp    101e8c <trap_dispatch+0x213>
  101e52:	eb 38                	jmp    101e8c <trap_dispatch+0x213>
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101e54:	8b 45 08             	mov    0x8(%ebp),%eax
  101e57:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e5b:	0f b7 c0             	movzwl %ax,%eax
  101e5e:	83 e0 03             	and    $0x3,%eax
  101e61:	85 c0                	test   %eax,%eax
  101e63:	75 28                	jne    101e8d <trap_dispatch+0x214>
            print_trapframe(tf);
  101e65:	8b 45 08             	mov    0x8(%ebp),%eax
  101e68:	89 04 24             	mov    %eax,(%esp)
  101e6b:	e8 8d fb ff ff       	call   1019fd <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101e70:	c7 44 24 08 2a 3b 10 	movl   $0x103b2a,0x8(%esp)
  101e77:	00 
  101e78:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
  101e7f:	00 
  101e80:	c7 04 24 4e 39 10 00 	movl   $0x10394e,(%esp)
  101e87:	e8 20 ee ff ff       	call   100cac <__panic>
        //panic("T_SWITCH_** ??\n");
        //break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101e8c:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101e8d:	83 c4 2c             	add    $0x2c,%esp
  101e90:	5b                   	pop    %ebx
  101e91:	5e                   	pop    %esi
  101e92:	5f                   	pop    %edi
  101e93:	5d                   	pop    %ebp
  101e94:	c3                   	ret    

00101e95 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101e95:	55                   	push   %ebp
  101e96:	89 e5                	mov    %esp,%ebp
  101e98:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  101e9e:	89 04 24             	mov    %eax,(%esp)
  101ea1:	e8 d3 fd ff ff       	call   101c79 <trap_dispatch>
}
  101ea6:	c9                   	leave  
  101ea7:	c3                   	ret    

00101ea8 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101ea8:	1e                   	push   %ds
    pushl %es
  101ea9:	06                   	push   %es
    pushl %fs
  101eaa:	0f a0                	push   %fs
    pushl %gs
  101eac:	0f a8                	push   %gs
    pushal
  101eae:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101eaf:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101eb4:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101eb6:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101eb8:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101eb9:	e8 d7 ff ff ff       	call   101e95 <trap>

    # pop the pushed stack pointer
    popl %esp
  101ebe:	5c                   	pop    %esp

00101ebf <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  101ebf:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  101ec0:	0f a9                	pop    %gs
    popl %fs
  101ec2:	0f a1                	pop    %fs
    popl %es
  101ec4:	07                   	pop    %es
    popl %ds
  101ec5:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  101ec6:	83 c4 08             	add    $0x8,%esp
    iret
  101ec9:	cf                   	iret   

00101eca <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101eca:	6a 00                	push   $0x0
  pushl $0
  101ecc:	6a 00                	push   $0x0
  jmp __alltraps
  101ece:	e9 d5 ff ff ff       	jmp    101ea8 <__alltraps>

00101ed3 <vector1>:
.globl vector1
vector1:
  pushl $0
  101ed3:	6a 00                	push   $0x0
  pushl $1
  101ed5:	6a 01                	push   $0x1
  jmp __alltraps
  101ed7:	e9 cc ff ff ff       	jmp    101ea8 <__alltraps>

00101edc <vector2>:
.globl vector2
vector2:
  pushl $0
  101edc:	6a 00                	push   $0x0
  pushl $2
  101ede:	6a 02                	push   $0x2
  jmp __alltraps
  101ee0:	e9 c3 ff ff ff       	jmp    101ea8 <__alltraps>

00101ee5 <vector3>:
.globl vector3
vector3:
  pushl $0
  101ee5:	6a 00                	push   $0x0
  pushl $3
  101ee7:	6a 03                	push   $0x3
  jmp __alltraps
  101ee9:	e9 ba ff ff ff       	jmp    101ea8 <__alltraps>

00101eee <vector4>:
.globl vector4
vector4:
  pushl $0
  101eee:	6a 00                	push   $0x0
  pushl $4
  101ef0:	6a 04                	push   $0x4
  jmp __alltraps
  101ef2:	e9 b1 ff ff ff       	jmp    101ea8 <__alltraps>

00101ef7 <vector5>:
.globl vector5
vector5:
  pushl $0
  101ef7:	6a 00                	push   $0x0
  pushl $5
  101ef9:	6a 05                	push   $0x5
  jmp __alltraps
  101efb:	e9 a8 ff ff ff       	jmp    101ea8 <__alltraps>

00101f00 <vector6>:
.globl vector6
vector6:
  pushl $0
  101f00:	6a 00                	push   $0x0
  pushl $6
  101f02:	6a 06                	push   $0x6
  jmp __alltraps
  101f04:	e9 9f ff ff ff       	jmp    101ea8 <__alltraps>

00101f09 <vector7>:
.globl vector7
vector7:
  pushl $0
  101f09:	6a 00                	push   $0x0
  pushl $7
  101f0b:	6a 07                	push   $0x7
  jmp __alltraps
  101f0d:	e9 96 ff ff ff       	jmp    101ea8 <__alltraps>

00101f12 <vector8>:
.globl vector8
vector8:
  pushl $8
  101f12:	6a 08                	push   $0x8
  jmp __alltraps
  101f14:	e9 8f ff ff ff       	jmp    101ea8 <__alltraps>

00101f19 <vector9>:
.globl vector9
vector9:
  pushl $0
  101f19:	6a 00                	push   $0x0
  pushl $9
  101f1b:	6a 09                	push   $0x9
  jmp __alltraps
  101f1d:	e9 86 ff ff ff       	jmp    101ea8 <__alltraps>

00101f22 <vector10>:
.globl vector10
vector10:
  pushl $10
  101f22:	6a 0a                	push   $0xa
  jmp __alltraps
  101f24:	e9 7f ff ff ff       	jmp    101ea8 <__alltraps>

00101f29 <vector11>:
.globl vector11
vector11:
  pushl $11
  101f29:	6a 0b                	push   $0xb
  jmp __alltraps
  101f2b:	e9 78 ff ff ff       	jmp    101ea8 <__alltraps>

00101f30 <vector12>:
.globl vector12
vector12:
  pushl $12
  101f30:	6a 0c                	push   $0xc
  jmp __alltraps
  101f32:	e9 71 ff ff ff       	jmp    101ea8 <__alltraps>

00101f37 <vector13>:
.globl vector13
vector13:
  pushl $13
  101f37:	6a 0d                	push   $0xd
  jmp __alltraps
  101f39:	e9 6a ff ff ff       	jmp    101ea8 <__alltraps>

00101f3e <vector14>:
.globl vector14
vector14:
  pushl $14
  101f3e:	6a 0e                	push   $0xe
  jmp __alltraps
  101f40:	e9 63 ff ff ff       	jmp    101ea8 <__alltraps>

00101f45 <vector15>:
.globl vector15
vector15:
  pushl $0
  101f45:	6a 00                	push   $0x0
  pushl $15
  101f47:	6a 0f                	push   $0xf
  jmp __alltraps
  101f49:	e9 5a ff ff ff       	jmp    101ea8 <__alltraps>

00101f4e <vector16>:
.globl vector16
vector16:
  pushl $0
  101f4e:	6a 00                	push   $0x0
  pushl $16
  101f50:	6a 10                	push   $0x10
  jmp __alltraps
  101f52:	e9 51 ff ff ff       	jmp    101ea8 <__alltraps>

00101f57 <vector17>:
.globl vector17
vector17:
  pushl $17
  101f57:	6a 11                	push   $0x11
  jmp __alltraps
  101f59:	e9 4a ff ff ff       	jmp    101ea8 <__alltraps>

00101f5e <vector18>:
.globl vector18
vector18:
  pushl $0
  101f5e:	6a 00                	push   $0x0
  pushl $18
  101f60:	6a 12                	push   $0x12
  jmp __alltraps
  101f62:	e9 41 ff ff ff       	jmp    101ea8 <__alltraps>

00101f67 <vector19>:
.globl vector19
vector19:
  pushl $0
  101f67:	6a 00                	push   $0x0
  pushl $19
  101f69:	6a 13                	push   $0x13
  jmp __alltraps
  101f6b:	e9 38 ff ff ff       	jmp    101ea8 <__alltraps>

00101f70 <vector20>:
.globl vector20
vector20:
  pushl $0
  101f70:	6a 00                	push   $0x0
  pushl $20
  101f72:	6a 14                	push   $0x14
  jmp __alltraps
  101f74:	e9 2f ff ff ff       	jmp    101ea8 <__alltraps>

00101f79 <vector21>:
.globl vector21
vector21:
  pushl $0
  101f79:	6a 00                	push   $0x0
  pushl $21
  101f7b:	6a 15                	push   $0x15
  jmp __alltraps
  101f7d:	e9 26 ff ff ff       	jmp    101ea8 <__alltraps>

00101f82 <vector22>:
.globl vector22
vector22:
  pushl $0
  101f82:	6a 00                	push   $0x0
  pushl $22
  101f84:	6a 16                	push   $0x16
  jmp __alltraps
  101f86:	e9 1d ff ff ff       	jmp    101ea8 <__alltraps>

00101f8b <vector23>:
.globl vector23
vector23:
  pushl $0
  101f8b:	6a 00                	push   $0x0
  pushl $23
  101f8d:	6a 17                	push   $0x17
  jmp __alltraps
  101f8f:	e9 14 ff ff ff       	jmp    101ea8 <__alltraps>

00101f94 <vector24>:
.globl vector24
vector24:
  pushl $0
  101f94:	6a 00                	push   $0x0
  pushl $24
  101f96:	6a 18                	push   $0x18
  jmp __alltraps
  101f98:	e9 0b ff ff ff       	jmp    101ea8 <__alltraps>

00101f9d <vector25>:
.globl vector25
vector25:
  pushl $0
  101f9d:	6a 00                	push   $0x0
  pushl $25
  101f9f:	6a 19                	push   $0x19
  jmp __alltraps
  101fa1:	e9 02 ff ff ff       	jmp    101ea8 <__alltraps>

00101fa6 <vector26>:
.globl vector26
vector26:
  pushl $0
  101fa6:	6a 00                	push   $0x0
  pushl $26
  101fa8:	6a 1a                	push   $0x1a
  jmp __alltraps
  101faa:	e9 f9 fe ff ff       	jmp    101ea8 <__alltraps>

00101faf <vector27>:
.globl vector27
vector27:
  pushl $0
  101faf:	6a 00                	push   $0x0
  pushl $27
  101fb1:	6a 1b                	push   $0x1b
  jmp __alltraps
  101fb3:	e9 f0 fe ff ff       	jmp    101ea8 <__alltraps>

00101fb8 <vector28>:
.globl vector28
vector28:
  pushl $0
  101fb8:	6a 00                	push   $0x0
  pushl $28
  101fba:	6a 1c                	push   $0x1c
  jmp __alltraps
  101fbc:	e9 e7 fe ff ff       	jmp    101ea8 <__alltraps>

00101fc1 <vector29>:
.globl vector29
vector29:
  pushl $0
  101fc1:	6a 00                	push   $0x0
  pushl $29
  101fc3:	6a 1d                	push   $0x1d
  jmp __alltraps
  101fc5:	e9 de fe ff ff       	jmp    101ea8 <__alltraps>

00101fca <vector30>:
.globl vector30
vector30:
  pushl $0
  101fca:	6a 00                	push   $0x0
  pushl $30
  101fcc:	6a 1e                	push   $0x1e
  jmp __alltraps
  101fce:	e9 d5 fe ff ff       	jmp    101ea8 <__alltraps>

00101fd3 <vector31>:
.globl vector31
vector31:
  pushl $0
  101fd3:	6a 00                	push   $0x0
  pushl $31
  101fd5:	6a 1f                	push   $0x1f
  jmp __alltraps
  101fd7:	e9 cc fe ff ff       	jmp    101ea8 <__alltraps>

00101fdc <vector32>:
.globl vector32
vector32:
  pushl $0
  101fdc:	6a 00                	push   $0x0
  pushl $32
  101fde:	6a 20                	push   $0x20
  jmp __alltraps
  101fe0:	e9 c3 fe ff ff       	jmp    101ea8 <__alltraps>

00101fe5 <vector33>:
.globl vector33
vector33:
  pushl $0
  101fe5:	6a 00                	push   $0x0
  pushl $33
  101fe7:	6a 21                	push   $0x21
  jmp __alltraps
  101fe9:	e9 ba fe ff ff       	jmp    101ea8 <__alltraps>

00101fee <vector34>:
.globl vector34
vector34:
  pushl $0
  101fee:	6a 00                	push   $0x0
  pushl $34
  101ff0:	6a 22                	push   $0x22
  jmp __alltraps
  101ff2:	e9 b1 fe ff ff       	jmp    101ea8 <__alltraps>

00101ff7 <vector35>:
.globl vector35
vector35:
  pushl $0
  101ff7:	6a 00                	push   $0x0
  pushl $35
  101ff9:	6a 23                	push   $0x23
  jmp __alltraps
  101ffb:	e9 a8 fe ff ff       	jmp    101ea8 <__alltraps>

00102000 <vector36>:
.globl vector36
vector36:
  pushl $0
  102000:	6a 00                	push   $0x0
  pushl $36
  102002:	6a 24                	push   $0x24
  jmp __alltraps
  102004:	e9 9f fe ff ff       	jmp    101ea8 <__alltraps>

00102009 <vector37>:
.globl vector37
vector37:
  pushl $0
  102009:	6a 00                	push   $0x0
  pushl $37
  10200b:	6a 25                	push   $0x25
  jmp __alltraps
  10200d:	e9 96 fe ff ff       	jmp    101ea8 <__alltraps>

00102012 <vector38>:
.globl vector38
vector38:
  pushl $0
  102012:	6a 00                	push   $0x0
  pushl $38
  102014:	6a 26                	push   $0x26
  jmp __alltraps
  102016:	e9 8d fe ff ff       	jmp    101ea8 <__alltraps>

0010201b <vector39>:
.globl vector39
vector39:
  pushl $0
  10201b:	6a 00                	push   $0x0
  pushl $39
  10201d:	6a 27                	push   $0x27
  jmp __alltraps
  10201f:	e9 84 fe ff ff       	jmp    101ea8 <__alltraps>

00102024 <vector40>:
.globl vector40
vector40:
  pushl $0
  102024:	6a 00                	push   $0x0
  pushl $40
  102026:	6a 28                	push   $0x28
  jmp __alltraps
  102028:	e9 7b fe ff ff       	jmp    101ea8 <__alltraps>

0010202d <vector41>:
.globl vector41
vector41:
  pushl $0
  10202d:	6a 00                	push   $0x0
  pushl $41
  10202f:	6a 29                	push   $0x29
  jmp __alltraps
  102031:	e9 72 fe ff ff       	jmp    101ea8 <__alltraps>

00102036 <vector42>:
.globl vector42
vector42:
  pushl $0
  102036:	6a 00                	push   $0x0
  pushl $42
  102038:	6a 2a                	push   $0x2a
  jmp __alltraps
  10203a:	e9 69 fe ff ff       	jmp    101ea8 <__alltraps>

0010203f <vector43>:
.globl vector43
vector43:
  pushl $0
  10203f:	6a 00                	push   $0x0
  pushl $43
  102041:	6a 2b                	push   $0x2b
  jmp __alltraps
  102043:	e9 60 fe ff ff       	jmp    101ea8 <__alltraps>

00102048 <vector44>:
.globl vector44
vector44:
  pushl $0
  102048:	6a 00                	push   $0x0
  pushl $44
  10204a:	6a 2c                	push   $0x2c
  jmp __alltraps
  10204c:	e9 57 fe ff ff       	jmp    101ea8 <__alltraps>

00102051 <vector45>:
.globl vector45
vector45:
  pushl $0
  102051:	6a 00                	push   $0x0
  pushl $45
  102053:	6a 2d                	push   $0x2d
  jmp __alltraps
  102055:	e9 4e fe ff ff       	jmp    101ea8 <__alltraps>

0010205a <vector46>:
.globl vector46
vector46:
  pushl $0
  10205a:	6a 00                	push   $0x0
  pushl $46
  10205c:	6a 2e                	push   $0x2e
  jmp __alltraps
  10205e:	e9 45 fe ff ff       	jmp    101ea8 <__alltraps>

00102063 <vector47>:
.globl vector47
vector47:
  pushl $0
  102063:	6a 00                	push   $0x0
  pushl $47
  102065:	6a 2f                	push   $0x2f
  jmp __alltraps
  102067:	e9 3c fe ff ff       	jmp    101ea8 <__alltraps>

0010206c <vector48>:
.globl vector48
vector48:
  pushl $0
  10206c:	6a 00                	push   $0x0
  pushl $48
  10206e:	6a 30                	push   $0x30
  jmp __alltraps
  102070:	e9 33 fe ff ff       	jmp    101ea8 <__alltraps>

00102075 <vector49>:
.globl vector49
vector49:
  pushl $0
  102075:	6a 00                	push   $0x0
  pushl $49
  102077:	6a 31                	push   $0x31
  jmp __alltraps
  102079:	e9 2a fe ff ff       	jmp    101ea8 <__alltraps>

0010207e <vector50>:
.globl vector50
vector50:
  pushl $0
  10207e:	6a 00                	push   $0x0
  pushl $50
  102080:	6a 32                	push   $0x32
  jmp __alltraps
  102082:	e9 21 fe ff ff       	jmp    101ea8 <__alltraps>

00102087 <vector51>:
.globl vector51
vector51:
  pushl $0
  102087:	6a 00                	push   $0x0
  pushl $51
  102089:	6a 33                	push   $0x33
  jmp __alltraps
  10208b:	e9 18 fe ff ff       	jmp    101ea8 <__alltraps>

00102090 <vector52>:
.globl vector52
vector52:
  pushl $0
  102090:	6a 00                	push   $0x0
  pushl $52
  102092:	6a 34                	push   $0x34
  jmp __alltraps
  102094:	e9 0f fe ff ff       	jmp    101ea8 <__alltraps>

00102099 <vector53>:
.globl vector53
vector53:
  pushl $0
  102099:	6a 00                	push   $0x0
  pushl $53
  10209b:	6a 35                	push   $0x35
  jmp __alltraps
  10209d:	e9 06 fe ff ff       	jmp    101ea8 <__alltraps>

001020a2 <vector54>:
.globl vector54
vector54:
  pushl $0
  1020a2:	6a 00                	push   $0x0
  pushl $54
  1020a4:	6a 36                	push   $0x36
  jmp __alltraps
  1020a6:	e9 fd fd ff ff       	jmp    101ea8 <__alltraps>

001020ab <vector55>:
.globl vector55
vector55:
  pushl $0
  1020ab:	6a 00                	push   $0x0
  pushl $55
  1020ad:	6a 37                	push   $0x37
  jmp __alltraps
  1020af:	e9 f4 fd ff ff       	jmp    101ea8 <__alltraps>

001020b4 <vector56>:
.globl vector56
vector56:
  pushl $0
  1020b4:	6a 00                	push   $0x0
  pushl $56
  1020b6:	6a 38                	push   $0x38
  jmp __alltraps
  1020b8:	e9 eb fd ff ff       	jmp    101ea8 <__alltraps>

001020bd <vector57>:
.globl vector57
vector57:
  pushl $0
  1020bd:	6a 00                	push   $0x0
  pushl $57
  1020bf:	6a 39                	push   $0x39
  jmp __alltraps
  1020c1:	e9 e2 fd ff ff       	jmp    101ea8 <__alltraps>

001020c6 <vector58>:
.globl vector58
vector58:
  pushl $0
  1020c6:	6a 00                	push   $0x0
  pushl $58
  1020c8:	6a 3a                	push   $0x3a
  jmp __alltraps
  1020ca:	e9 d9 fd ff ff       	jmp    101ea8 <__alltraps>

001020cf <vector59>:
.globl vector59
vector59:
  pushl $0
  1020cf:	6a 00                	push   $0x0
  pushl $59
  1020d1:	6a 3b                	push   $0x3b
  jmp __alltraps
  1020d3:	e9 d0 fd ff ff       	jmp    101ea8 <__alltraps>

001020d8 <vector60>:
.globl vector60
vector60:
  pushl $0
  1020d8:	6a 00                	push   $0x0
  pushl $60
  1020da:	6a 3c                	push   $0x3c
  jmp __alltraps
  1020dc:	e9 c7 fd ff ff       	jmp    101ea8 <__alltraps>

001020e1 <vector61>:
.globl vector61
vector61:
  pushl $0
  1020e1:	6a 00                	push   $0x0
  pushl $61
  1020e3:	6a 3d                	push   $0x3d
  jmp __alltraps
  1020e5:	e9 be fd ff ff       	jmp    101ea8 <__alltraps>

001020ea <vector62>:
.globl vector62
vector62:
  pushl $0
  1020ea:	6a 00                	push   $0x0
  pushl $62
  1020ec:	6a 3e                	push   $0x3e
  jmp __alltraps
  1020ee:	e9 b5 fd ff ff       	jmp    101ea8 <__alltraps>

001020f3 <vector63>:
.globl vector63
vector63:
  pushl $0
  1020f3:	6a 00                	push   $0x0
  pushl $63
  1020f5:	6a 3f                	push   $0x3f
  jmp __alltraps
  1020f7:	e9 ac fd ff ff       	jmp    101ea8 <__alltraps>

001020fc <vector64>:
.globl vector64
vector64:
  pushl $0
  1020fc:	6a 00                	push   $0x0
  pushl $64
  1020fe:	6a 40                	push   $0x40
  jmp __alltraps
  102100:	e9 a3 fd ff ff       	jmp    101ea8 <__alltraps>

00102105 <vector65>:
.globl vector65
vector65:
  pushl $0
  102105:	6a 00                	push   $0x0
  pushl $65
  102107:	6a 41                	push   $0x41
  jmp __alltraps
  102109:	e9 9a fd ff ff       	jmp    101ea8 <__alltraps>

0010210e <vector66>:
.globl vector66
vector66:
  pushl $0
  10210e:	6a 00                	push   $0x0
  pushl $66
  102110:	6a 42                	push   $0x42
  jmp __alltraps
  102112:	e9 91 fd ff ff       	jmp    101ea8 <__alltraps>

00102117 <vector67>:
.globl vector67
vector67:
  pushl $0
  102117:	6a 00                	push   $0x0
  pushl $67
  102119:	6a 43                	push   $0x43
  jmp __alltraps
  10211b:	e9 88 fd ff ff       	jmp    101ea8 <__alltraps>

00102120 <vector68>:
.globl vector68
vector68:
  pushl $0
  102120:	6a 00                	push   $0x0
  pushl $68
  102122:	6a 44                	push   $0x44
  jmp __alltraps
  102124:	e9 7f fd ff ff       	jmp    101ea8 <__alltraps>

00102129 <vector69>:
.globl vector69
vector69:
  pushl $0
  102129:	6a 00                	push   $0x0
  pushl $69
  10212b:	6a 45                	push   $0x45
  jmp __alltraps
  10212d:	e9 76 fd ff ff       	jmp    101ea8 <__alltraps>

00102132 <vector70>:
.globl vector70
vector70:
  pushl $0
  102132:	6a 00                	push   $0x0
  pushl $70
  102134:	6a 46                	push   $0x46
  jmp __alltraps
  102136:	e9 6d fd ff ff       	jmp    101ea8 <__alltraps>

0010213b <vector71>:
.globl vector71
vector71:
  pushl $0
  10213b:	6a 00                	push   $0x0
  pushl $71
  10213d:	6a 47                	push   $0x47
  jmp __alltraps
  10213f:	e9 64 fd ff ff       	jmp    101ea8 <__alltraps>

00102144 <vector72>:
.globl vector72
vector72:
  pushl $0
  102144:	6a 00                	push   $0x0
  pushl $72
  102146:	6a 48                	push   $0x48
  jmp __alltraps
  102148:	e9 5b fd ff ff       	jmp    101ea8 <__alltraps>

0010214d <vector73>:
.globl vector73
vector73:
  pushl $0
  10214d:	6a 00                	push   $0x0
  pushl $73
  10214f:	6a 49                	push   $0x49
  jmp __alltraps
  102151:	e9 52 fd ff ff       	jmp    101ea8 <__alltraps>

00102156 <vector74>:
.globl vector74
vector74:
  pushl $0
  102156:	6a 00                	push   $0x0
  pushl $74
  102158:	6a 4a                	push   $0x4a
  jmp __alltraps
  10215a:	e9 49 fd ff ff       	jmp    101ea8 <__alltraps>

0010215f <vector75>:
.globl vector75
vector75:
  pushl $0
  10215f:	6a 00                	push   $0x0
  pushl $75
  102161:	6a 4b                	push   $0x4b
  jmp __alltraps
  102163:	e9 40 fd ff ff       	jmp    101ea8 <__alltraps>

00102168 <vector76>:
.globl vector76
vector76:
  pushl $0
  102168:	6a 00                	push   $0x0
  pushl $76
  10216a:	6a 4c                	push   $0x4c
  jmp __alltraps
  10216c:	e9 37 fd ff ff       	jmp    101ea8 <__alltraps>

00102171 <vector77>:
.globl vector77
vector77:
  pushl $0
  102171:	6a 00                	push   $0x0
  pushl $77
  102173:	6a 4d                	push   $0x4d
  jmp __alltraps
  102175:	e9 2e fd ff ff       	jmp    101ea8 <__alltraps>

0010217a <vector78>:
.globl vector78
vector78:
  pushl $0
  10217a:	6a 00                	push   $0x0
  pushl $78
  10217c:	6a 4e                	push   $0x4e
  jmp __alltraps
  10217e:	e9 25 fd ff ff       	jmp    101ea8 <__alltraps>

00102183 <vector79>:
.globl vector79
vector79:
  pushl $0
  102183:	6a 00                	push   $0x0
  pushl $79
  102185:	6a 4f                	push   $0x4f
  jmp __alltraps
  102187:	e9 1c fd ff ff       	jmp    101ea8 <__alltraps>

0010218c <vector80>:
.globl vector80
vector80:
  pushl $0
  10218c:	6a 00                	push   $0x0
  pushl $80
  10218e:	6a 50                	push   $0x50
  jmp __alltraps
  102190:	e9 13 fd ff ff       	jmp    101ea8 <__alltraps>

00102195 <vector81>:
.globl vector81
vector81:
  pushl $0
  102195:	6a 00                	push   $0x0
  pushl $81
  102197:	6a 51                	push   $0x51
  jmp __alltraps
  102199:	e9 0a fd ff ff       	jmp    101ea8 <__alltraps>

0010219e <vector82>:
.globl vector82
vector82:
  pushl $0
  10219e:	6a 00                	push   $0x0
  pushl $82
  1021a0:	6a 52                	push   $0x52
  jmp __alltraps
  1021a2:	e9 01 fd ff ff       	jmp    101ea8 <__alltraps>

001021a7 <vector83>:
.globl vector83
vector83:
  pushl $0
  1021a7:	6a 00                	push   $0x0
  pushl $83
  1021a9:	6a 53                	push   $0x53
  jmp __alltraps
  1021ab:	e9 f8 fc ff ff       	jmp    101ea8 <__alltraps>

001021b0 <vector84>:
.globl vector84
vector84:
  pushl $0
  1021b0:	6a 00                	push   $0x0
  pushl $84
  1021b2:	6a 54                	push   $0x54
  jmp __alltraps
  1021b4:	e9 ef fc ff ff       	jmp    101ea8 <__alltraps>

001021b9 <vector85>:
.globl vector85
vector85:
  pushl $0
  1021b9:	6a 00                	push   $0x0
  pushl $85
  1021bb:	6a 55                	push   $0x55
  jmp __alltraps
  1021bd:	e9 e6 fc ff ff       	jmp    101ea8 <__alltraps>

001021c2 <vector86>:
.globl vector86
vector86:
  pushl $0
  1021c2:	6a 00                	push   $0x0
  pushl $86
  1021c4:	6a 56                	push   $0x56
  jmp __alltraps
  1021c6:	e9 dd fc ff ff       	jmp    101ea8 <__alltraps>

001021cb <vector87>:
.globl vector87
vector87:
  pushl $0
  1021cb:	6a 00                	push   $0x0
  pushl $87
  1021cd:	6a 57                	push   $0x57
  jmp __alltraps
  1021cf:	e9 d4 fc ff ff       	jmp    101ea8 <__alltraps>

001021d4 <vector88>:
.globl vector88
vector88:
  pushl $0
  1021d4:	6a 00                	push   $0x0
  pushl $88
  1021d6:	6a 58                	push   $0x58
  jmp __alltraps
  1021d8:	e9 cb fc ff ff       	jmp    101ea8 <__alltraps>

001021dd <vector89>:
.globl vector89
vector89:
  pushl $0
  1021dd:	6a 00                	push   $0x0
  pushl $89
  1021df:	6a 59                	push   $0x59
  jmp __alltraps
  1021e1:	e9 c2 fc ff ff       	jmp    101ea8 <__alltraps>

001021e6 <vector90>:
.globl vector90
vector90:
  pushl $0
  1021e6:	6a 00                	push   $0x0
  pushl $90
  1021e8:	6a 5a                	push   $0x5a
  jmp __alltraps
  1021ea:	e9 b9 fc ff ff       	jmp    101ea8 <__alltraps>

001021ef <vector91>:
.globl vector91
vector91:
  pushl $0
  1021ef:	6a 00                	push   $0x0
  pushl $91
  1021f1:	6a 5b                	push   $0x5b
  jmp __alltraps
  1021f3:	e9 b0 fc ff ff       	jmp    101ea8 <__alltraps>

001021f8 <vector92>:
.globl vector92
vector92:
  pushl $0
  1021f8:	6a 00                	push   $0x0
  pushl $92
  1021fa:	6a 5c                	push   $0x5c
  jmp __alltraps
  1021fc:	e9 a7 fc ff ff       	jmp    101ea8 <__alltraps>

00102201 <vector93>:
.globl vector93
vector93:
  pushl $0
  102201:	6a 00                	push   $0x0
  pushl $93
  102203:	6a 5d                	push   $0x5d
  jmp __alltraps
  102205:	e9 9e fc ff ff       	jmp    101ea8 <__alltraps>

0010220a <vector94>:
.globl vector94
vector94:
  pushl $0
  10220a:	6a 00                	push   $0x0
  pushl $94
  10220c:	6a 5e                	push   $0x5e
  jmp __alltraps
  10220e:	e9 95 fc ff ff       	jmp    101ea8 <__alltraps>

00102213 <vector95>:
.globl vector95
vector95:
  pushl $0
  102213:	6a 00                	push   $0x0
  pushl $95
  102215:	6a 5f                	push   $0x5f
  jmp __alltraps
  102217:	e9 8c fc ff ff       	jmp    101ea8 <__alltraps>

0010221c <vector96>:
.globl vector96
vector96:
  pushl $0
  10221c:	6a 00                	push   $0x0
  pushl $96
  10221e:	6a 60                	push   $0x60
  jmp __alltraps
  102220:	e9 83 fc ff ff       	jmp    101ea8 <__alltraps>

00102225 <vector97>:
.globl vector97
vector97:
  pushl $0
  102225:	6a 00                	push   $0x0
  pushl $97
  102227:	6a 61                	push   $0x61
  jmp __alltraps
  102229:	e9 7a fc ff ff       	jmp    101ea8 <__alltraps>

0010222e <vector98>:
.globl vector98
vector98:
  pushl $0
  10222e:	6a 00                	push   $0x0
  pushl $98
  102230:	6a 62                	push   $0x62
  jmp __alltraps
  102232:	e9 71 fc ff ff       	jmp    101ea8 <__alltraps>

00102237 <vector99>:
.globl vector99
vector99:
  pushl $0
  102237:	6a 00                	push   $0x0
  pushl $99
  102239:	6a 63                	push   $0x63
  jmp __alltraps
  10223b:	e9 68 fc ff ff       	jmp    101ea8 <__alltraps>

00102240 <vector100>:
.globl vector100
vector100:
  pushl $0
  102240:	6a 00                	push   $0x0
  pushl $100
  102242:	6a 64                	push   $0x64
  jmp __alltraps
  102244:	e9 5f fc ff ff       	jmp    101ea8 <__alltraps>

00102249 <vector101>:
.globl vector101
vector101:
  pushl $0
  102249:	6a 00                	push   $0x0
  pushl $101
  10224b:	6a 65                	push   $0x65
  jmp __alltraps
  10224d:	e9 56 fc ff ff       	jmp    101ea8 <__alltraps>

00102252 <vector102>:
.globl vector102
vector102:
  pushl $0
  102252:	6a 00                	push   $0x0
  pushl $102
  102254:	6a 66                	push   $0x66
  jmp __alltraps
  102256:	e9 4d fc ff ff       	jmp    101ea8 <__alltraps>

0010225b <vector103>:
.globl vector103
vector103:
  pushl $0
  10225b:	6a 00                	push   $0x0
  pushl $103
  10225d:	6a 67                	push   $0x67
  jmp __alltraps
  10225f:	e9 44 fc ff ff       	jmp    101ea8 <__alltraps>

00102264 <vector104>:
.globl vector104
vector104:
  pushl $0
  102264:	6a 00                	push   $0x0
  pushl $104
  102266:	6a 68                	push   $0x68
  jmp __alltraps
  102268:	e9 3b fc ff ff       	jmp    101ea8 <__alltraps>

0010226d <vector105>:
.globl vector105
vector105:
  pushl $0
  10226d:	6a 00                	push   $0x0
  pushl $105
  10226f:	6a 69                	push   $0x69
  jmp __alltraps
  102271:	e9 32 fc ff ff       	jmp    101ea8 <__alltraps>

00102276 <vector106>:
.globl vector106
vector106:
  pushl $0
  102276:	6a 00                	push   $0x0
  pushl $106
  102278:	6a 6a                	push   $0x6a
  jmp __alltraps
  10227a:	e9 29 fc ff ff       	jmp    101ea8 <__alltraps>

0010227f <vector107>:
.globl vector107
vector107:
  pushl $0
  10227f:	6a 00                	push   $0x0
  pushl $107
  102281:	6a 6b                	push   $0x6b
  jmp __alltraps
  102283:	e9 20 fc ff ff       	jmp    101ea8 <__alltraps>

00102288 <vector108>:
.globl vector108
vector108:
  pushl $0
  102288:	6a 00                	push   $0x0
  pushl $108
  10228a:	6a 6c                	push   $0x6c
  jmp __alltraps
  10228c:	e9 17 fc ff ff       	jmp    101ea8 <__alltraps>

00102291 <vector109>:
.globl vector109
vector109:
  pushl $0
  102291:	6a 00                	push   $0x0
  pushl $109
  102293:	6a 6d                	push   $0x6d
  jmp __alltraps
  102295:	e9 0e fc ff ff       	jmp    101ea8 <__alltraps>

0010229a <vector110>:
.globl vector110
vector110:
  pushl $0
  10229a:	6a 00                	push   $0x0
  pushl $110
  10229c:	6a 6e                	push   $0x6e
  jmp __alltraps
  10229e:	e9 05 fc ff ff       	jmp    101ea8 <__alltraps>

001022a3 <vector111>:
.globl vector111
vector111:
  pushl $0
  1022a3:	6a 00                	push   $0x0
  pushl $111
  1022a5:	6a 6f                	push   $0x6f
  jmp __alltraps
  1022a7:	e9 fc fb ff ff       	jmp    101ea8 <__alltraps>

001022ac <vector112>:
.globl vector112
vector112:
  pushl $0
  1022ac:	6a 00                	push   $0x0
  pushl $112
  1022ae:	6a 70                	push   $0x70
  jmp __alltraps
  1022b0:	e9 f3 fb ff ff       	jmp    101ea8 <__alltraps>

001022b5 <vector113>:
.globl vector113
vector113:
  pushl $0
  1022b5:	6a 00                	push   $0x0
  pushl $113
  1022b7:	6a 71                	push   $0x71
  jmp __alltraps
  1022b9:	e9 ea fb ff ff       	jmp    101ea8 <__alltraps>

001022be <vector114>:
.globl vector114
vector114:
  pushl $0
  1022be:	6a 00                	push   $0x0
  pushl $114
  1022c0:	6a 72                	push   $0x72
  jmp __alltraps
  1022c2:	e9 e1 fb ff ff       	jmp    101ea8 <__alltraps>

001022c7 <vector115>:
.globl vector115
vector115:
  pushl $0
  1022c7:	6a 00                	push   $0x0
  pushl $115
  1022c9:	6a 73                	push   $0x73
  jmp __alltraps
  1022cb:	e9 d8 fb ff ff       	jmp    101ea8 <__alltraps>

001022d0 <vector116>:
.globl vector116
vector116:
  pushl $0
  1022d0:	6a 00                	push   $0x0
  pushl $116
  1022d2:	6a 74                	push   $0x74
  jmp __alltraps
  1022d4:	e9 cf fb ff ff       	jmp    101ea8 <__alltraps>

001022d9 <vector117>:
.globl vector117
vector117:
  pushl $0
  1022d9:	6a 00                	push   $0x0
  pushl $117
  1022db:	6a 75                	push   $0x75
  jmp __alltraps
  1022dd:	e9 c6 fb ff ff       	jmp    101ea8 <__alltraps>

001022e2 <vector118>:
.globl vector118
vector118:
  pushl $0
  1022e2:	6a 00                	push   $0x0
  pushl $118
  1022e4:	6a 76                	push   $0x76
  jmp __alltraps
  1022e6:	e9 bd fb ff ff       	jmp    101ea8 <__alltraps>

001022eb <vector119>:
.globl vector119
vector119:
  pushl $0
  1022eb:	6a 00                	push   $0x0
  pushl $119
  1022ed:	6a 77                	push   $0x77
  jmp __alltraps
  1022ef:	e9 b4 fb ff ff       	jmp    101ea8 <__alltraps>

001022f4 <vector120>:
.globl vector120
vector120:
  pushl $0
  1022f4:	6a 00                	push   $0x0
  pushl $120
  1022f6:	6a 78                	push   $0x78
  jmp __alltraps
  1022f8:	e9 ab fb ff ff       	jmp    101ea8 <__alltraps>

001022fd <vector121>:
.globl vector121
vector121:
  pushl $0
  1022fd:	6a 00                	push   $0x0
  pushl $121
  1022ff:	6a 79                	push   $0x79
  jmp __alltraps
  102301:	e9 a2 fb ff ff       	jmp    101ea8 <__alltraps>

00102306 <vector122>:
.globl vector122
vector122:
  pushl $0
  102306:	6a 00                	push   $0x0
  pushl $122
  102308:	6a 7a                	push   $0x7a
  jmp __alltraps
  10230a:	e9 99 fb ff ff       	jmp    101ea8 <__alltraps>

0010230f <vector123>:
.globl vector123
vector123:
  pushl $0
  10230f:	6a 00                	push   $0x0
  pushl $123
  102311:	6a 7b                	push   $0x7b
  jmp __alltraps
  102313:	e9 90 fb ff ff       	jmp    101ea8 <__alltraps>

00102318 <vector124>:
.globl vector124
vector124:
  pushl $0
  102318:	6a 00                	push   $0x0
  pushl $124
  10231a:	6a 7c                	push   $0x7c
  jmp __alltraps
  10231c:	e9 87 fb ff ff       	jmp    101ea8 <__alltraps>

00102321 <vector125>:
.globl vector125
vector125:
  pushl $0
  102321:	6a 00                	push   $0x0
  pushl $125
  102323:	6a 7d                	push   $0x7d
  jmp __alltraps
  102325:	e9 7e fb ff ff       	jmp    101ea8 <__alltraps>

0010232a <vector126>:
.globl vector126
vector126:
  pushl $0
  10232a:	6a 00                	push   $0x0
  pushl $126
  10232c:	6a 7e                	push   $0x7e
  jmp __alltraps
  10232e:	e9 75 fb ff ff       	jmp    101ea8 <__alltraps>

00102333 <vector127>:
.globl vector127
vector127:
  pushl $0
  102333:	6a 00                	push   $0x0
  pushl $127
  102335:	6a 7f                	push   $0x7f
  jmp __alltraps
  102337:	e9 6c fb ff ff       	jmp    101ea8 <__alltraps>

0010233c <vector128>:
.globl vector128
vector128:
  pushl $0
  10233c:	6a 00                	push   $0x0
  pushl $128
  10233e:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102343:	e9 60 fb ff ff       	jmp    101ea8 <__alltraps>

00102348 <vector129>:
.globl vector129
vector129:
  pushl $0
  102348:	6a 00                	push   $0x0
  pushl $129
  10234a:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  10234f:	e9 54 fb ff ff       	jmp    101ea8 <__alltraps>

00102354 <vector130>:
.globl vector130
vector130:
  pushl $0
  102354:	6a 00                	push   $0x0
  pushl $130
  102356:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  10235b:	e9 48 fb ff ff       	jmp    101ea8 <__alltraps>

00102360 <vector131>:
.globl vector131
vector131:
  pushl $0
  102360:	6a 00                	push   $0x0
  pushl $131
  102362:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102367:	e9 3c fb ff ff       	jmp    101ea8 <__alltraps>

0010236c <vector132>:
.globl vector132
vector132:
  pushl $0
  10236c:	6a 00                	push   $0x0
  pushl $132
  10236e:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102373:	e9 30 fb ff ff       	jmp    101ea8 <__alltraps>

00102378 <vector133>:
.globl vector133
vector133:
  pushl $0
  102378:	6a 00                	push   $0x0
  pushl $133
  10237a:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  10237f:	e9 24 fb ff ff       	jmp    101ea8 <__alltraps>

00102384 <vector134>:
.globl vector134
vector134:
  pushl $0
  102384:	6a 00                	push   $0x0
  pushl $134
  102386:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  10238b:	e9 18 fb ff ff       	jmp    101ea8 <__alltraps>

00102390 <vector135>:
.globl vector135
vector135:
  pushl $0
  102390:	6a 00                	push   $0x0
  pushl $135
  102392:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102397:	e9 0c fb ff ff       	jmp    101ea8 <__alltraps>

0010239c <vector136>:
.globl vector136
vector136:
  pushl $0
  10239c:	6a 00                	push   $0x0
  pushl $136
  10239e:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1023a3:	e9 00 fb ff ff       	jmp    101ea8 <__alltraps>

001023a8 <vector137>:
.globl vector137
vector137:
  pushl $0
  1023a8:	6a 00                	push   $0x0
  pushl $137
  1023aa:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1023af:	e9 f4 fa ff ff       	jmp    101ea8 <__alltraps>

001023b4 <vector138>:
.globl vector138
vector138:
  pushl $0
  1023b4:	6a 00                	push   $0x0
  pushl $138
  1023b6:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1023bb:	e9 e8 fa ff ff       	jmp    101ea8 <__alltraps>

001023c0 <vector139>:
.globl vector139
vector139:
  pushl $0
  1023c0:	6a 00                	push   $0x0
  pushl $139
  1023c2:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1023c7:	e9 dc fa ff ff       	jmp    101ea8 <__alltraps>

001023cc <vector140>:
.globl vector140
vector140:
  pushl $0
  1023cc:	6a 00                	push   $0x0
  pushl $140
  1023ce:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1023d3:	e9 d0 fa ff ff       	jmp    101ea8 <__alltraps>

001023d8 <vector141>:
.globl vector141
vector141:
  pushl $0
  1023d8:	6a 00                	push   $0x0
  pushl $141
  1023da:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1023df:	e9 c4 fa ff ff       	jmp    101ea8 <__alltraps>

001023e4 <vector142>:
.globl vector142
vector142:
  pushl $0
  1023e4:	6a 00                	push   $0x0
  pushl $142
  1023e6:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1023eb:	e9 b8 fa ff ff       	jmp    101ea8 <__alltraps>

001023f0 <vector143>:
.globl vector143
vector143:
  pushl $0
  1023f0:	6a 00                	push   $0x0
  pushl $143
  1023f2:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1023f7:	e9 ac fa ff ff       	jmp    101ea8 <__alltraps>

001023fc <vector144>:
.globl vector144
vector144:
  pushl $0
  1023fc:	6a 00                	push   $0x0
  pushl $144
  1023fe:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102403:	e9 a0 fa ff ff       	jmp    101ea8 <__alltraps>

00102408 <vector145>:
.globl vector145
vector145:
  pushl $0
  102408:	6a 00                	push   $0x0
  pushl $145
  10240a:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  10240f:	e9 94 fa ff ff       	jmp    101ea8 <__alltraps>

00102414 <vector146>:
.globl vector146
vector146:
  pushl $0
  102414:	6a 00                	push   $0x0
  pushl $146
  102416:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  10241b:	e9 88 fa ff ff       	jmp    101ea8 <__alltraps>

00102420 <vector147>:
.globl vector147
vector147:
  pushl $0
  102420:	6a 00                	push   $0x0
  pushl $147
  102422:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102427:	e9 7c fa ff ff       	jmp    101ea8 <__alltraps>

0010242c <vector148>:
.globl vector148
vector148:
  pushl $0
  10242c:	6a 00                	push   $0x0
  pushl $148
  10242e:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102433:	e9 70 fa ff ff       	jmp    101ea8 <__alltraps>

00102438 <vector149>:
.globl vector149
vector149:
  pushl $0
  102438:	6a 00                	push   $0x0
  pushl $149
  10243a:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  10243f:	e9 64 fa ff ff       	jmp    101ea8 <__alltraps>

00102444 <vector150>:
.globl vector150
vector150:
  pushl $0
  102444:	6a 00                	push   $0x0
  pushl $150
  102446:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  10244b:	e9 58 fa ff ff       	jmp    101ea8 <__alltraps>

00102450 <vector151>:
.globl vector151
vector151:
  pushl $0
  102450:	6a 00                	push   $0x0
  pushl $151
  102452:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102457:	e9 4c fa ff ff       	jmp    101ea8 <__alltraps>

0010245c <vector152>:
.globl vector152
vector152:
  pushl $0
  10245c:	6a 00                	push   $0x0
  pushl $152
  10245e:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102463:	e9 40 fa ff ff       	jmp    101ea8 <__alltraps>

00102468 <vector153>:
.globl vector153
vector153:
  pushl $0
  102468:	6a 00                	push   $0x0
  pushl $153
  10246a:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  10246f:	e9 34 fa ff ff       	jmp    101ea8 <__alltraps>

00102474 <vector154>:
.globl vector154
vector154:
  pushl $0
  102474:	6a 00                	push   $0x0
  pushl $154
  102476:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  10247b:	e9 28 fa ff ff       	jmp    101ea8 <__alltraps>

00102480 <vector155>:
.globl vector155
vector155:
  pushl $0
  102480:	6a 00                	push   $0x0
  pushl $155
  102482:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102487:	e9 1c fa ff ff       	jmp    101ea8 <__alltraps>

0010248c <vector156>:
.globl vector156
vector156:
  pushl $0
  10248c:	6a 00                	push   $0x0
  pushl $156
  10248e:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102493:	e9 10 fa ff ff       	jmp    101ea8 <__alltraps>

00102498 <vector157>:
.globl vector157
vector157:
  pushl $0
  102498:	6a 00                	push   $0x0
  pushl $157
  10249a:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  10249f:	e9 04 fa ff ff       	jmp    101ea8 <__alltraps>

001024a4 <vector158>:
.globl vector158
vector158:
  pushl $0
  1024a4:	6a 00                	push   $0x0
  pushl $158
  1024a6:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1024ab:	e9 f8 f9 ff ff       	jmp    101ea8 <__alltraps>

001024b0 <vector159>:
.globl vector159
vector159:
  pushl $0
  1024b0:	6a 00                	push   $0x0
  pushl $159
  1024b2:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1024b7:	e9 ec f9 ff ff       	jmp    101ea8 <__alltraps>

001024bc <vector160>:
.globl vector160
vector160:
  pushl $0
  1024bc:	6a 00                	push   $0x0
  pushl $160
  1024be:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1024c3:	e9 e0 f9 ff ff       	jmp    101ea8 <__alltraps>

001024c8 <vector161>:
.globl vector161
vector161:
  pushl $0
  1024c8:	6a 00                	push   $0x0
  pushl $161
  1024ca:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1024cf:	e9 d4 f9 ff ff       	jmp    101ea8 <__alltraps>

001024d4 <vector162>:
.globl vector162
vector162:
  pushl $0
  1024d4:	6a 00                	push   $0x0
  pushl $162
  1024d6:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1024db:	e9 c8 f9 ff ff       	jmp    101ea8 <__alltraps>

001024e0 <vector163>:
.globl vector163
vector163:
  pushl $0
  1024e0:	6a 00                	push   $0x0
  pushl $163
  1024e2:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1024e7:	e9 bc f9 ff ff       	jmp    101ea8 <__alltraps>

001024ec <vector164>:
.globl vector164
vector164:
  pushl $0
  1024ec:	6a 00                	push   $0x0
  pushl $164
  1024ee:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1024f3:	e9 b0 f9 ff ff       	jmp    101ea8 <__alltraps>

001024f8 <vector165>:
.globl vector165
vector165:
  pushl $0
  1024f8:	6a 00                	push   $0x0
  pushl $165
  1024fa:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1024ff:	e9 a4 f9 ff ff       	jmp    101ea8 <__alltraps>

00102504 <vector166>:
.globl vector166
vector166:
  pushl $0
  102504:	6a 00                	push   $0x0
  pushl $166
  102506:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  10250b:	e9 98 f9 ff ff       	jmp    101ea8 <__alltraps>

00102510 <vector167>:
.globl vector167
vector167:
  pushl $0
  102510:	6a 00                	push   $0x0
  pushl $167
  102512:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102517:	e9 8c f9 ff ff       	jmp    101ea8 <__alltraps>

0010251c <vector168>:
.globl vector168
vector168:
  pushl $0
  10251c:	6a 00                	push   $0x0
  pushl $168
  10251e:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102523:	e9 80 f9 ff ff       	jmp    101ea8 <__alltraps>

00102528 <vector169>:
.globl vector169
vector169:
  pushl $0
  102528:	6a 00                	push   $0x0
  pushl $169
  10252a:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  10252f:	e9 74 f9 ff ff       	jmp    101ea8 <__alltraps>

00102534 <vector170>:
.globl vector170
vector170:
  pushl $0
  102534:	6a 00                	push   $0x0
  pushl $170
  102536:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  10253b:	e9 68 f9 ff ff       	jmp    101ea8 <__alltraps>

00102540 <vector171>:
.globl vector171
vector171:
  pushl $0
  102540:	6a 00                	push   $0x0
  pushl $171
  102542:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102547:	e9 5c f9 ff ff       	jmp    101ea8 <__alltraps>

0010254c <vector172>:
.globl vector172
vector172:
  pushl $0
  10254c:	6a 00                	push   $0x0
  pushl $172
  10254e:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102553:	e9 50 f9 ff ff       	jmp    101ea8 <__alltraps>

00102558 <vector173>:
.globl vector173
vector173:
  pushl $0
  102558:	6a 00                	push   $0x0
  pushl $173
  10255a:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  10255f:	e9 44 f9 ff ff       	jmp    101ea8 <__alltraps>

00102564 <vector174>:
.globl vector174
vector174:
  pushl $0
  102564:	6a 00                	push   $0x0
  pushl $174
  102566:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  10256b:	e9 38 f9 ff ff       	jmp    101ea8 <__alltraps>

00102570 <vector175>:
.globl vector175
vector175:
  pushl $0
  102570:	6a 00                	push   $0x0
  pushl $175
  102572:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102577:	e9 2c f9 ff ff       	jmp    101ea8 <__alltraps>

0010257c <vector176>:
.globl vector176
vector176:
  pushl $0
  10257c:	6a 00                	push   $0x0
  pushl $176
  10257e:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102583:	e9 20 f9 ff ff       	jmp    101ea8 <__alltraps>

00102588 <vector177>:
.globl vector177
vector177:
  pushl $0
  102588:	6a 00                	push   $0x0
  pushl $177
  10258a:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  10258f:	e9 14 f9 ff ff       	jmp    101ea8 <__alltraps>

00102594 <vector178>:
.globl vector178
vector178:
  pushl $0
  102594:	6a 00                	push   $0x0
  pushl $178
  102596:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  10259b:	e9 08 f9 ff ff       	jmp    101ea8 <__alltraps>

001025a0 <vector179>:
.globl vector179
vector179:
  pushl $0
  1025a0:	6a 00                	push   $0x0
  pushl $179
  1025a2:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1025a7:	e9 fc f8 ff ff       	jmp    101ea8 <__alltraps>

001025ac <vector180>:
.globl vector180
vector180:
  pushl $0
  1025ac:	6a 00                	push   $0x0
  pushl $180
  1025ae:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1025b3:	e9 f0 f8 ff ff       	jmp    101ea8 <__alltraps>

001025b8 <vector181>:
.globl vector181
vector181:
  pushl $0
  1025b8:	6a 00                	push   $0x0
  pushl $181
  1025ba:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1025bf:	e9 e4 f8 ff ff       	jmp    101ea8 <__alltraps>

001025c4 <vector182>:
.globl vector182
vector182:
  pushl $0
  1025c4:	6a 00                	push   $0x0
  pushl $182
  1025c6:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1025cb:	e9 d8 f8 ff ff       	jmp    101ea8 <__alltraps>

001025d0 <vector183>:
.globl vector183
vector183:
  pushl $0
  1025d0:	6a 00                	push   $0x0
  pushl $183
  1025d2:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1025d7:	e9 cc f8 ff ff       	jmp    101ea8 <__alltraps>

001025dc <vector184>:
.globl vector184
vector184:
  pushl $0
  1025dc:	6a 00                	push   $0x0
  pushl $184
  1025de:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1025e3:	e9 c0 f8 ff ff       	jmp    101ea8 <__alltraps>

001025e8 <vector185>:
.globl vector185
vector185:
  pushl $0
  1025e8:	6a 00                	push   $0x0
  pushl $185
  1025ea:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1025ef:	e9 b4 f8 ff ff       	jmp    101ea8 <__alltraps>

001025f4 <vector186>:
.globl vector186
vector186:
  pushl $0
  1025f4:	6a 00                	push   $0x0
  pushl $186
  1025f6:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1025fb:	e9 a8 f8 ff ff       	jmp    101ea8 <__alltraps>

00102600 <vector187>:
.globl vector187
vector187:
  pushl $0
  102600:	6a 00                	push   $0x0
  pushl $187
  102602:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102607:	e9 9c f8 ff ff       	jmp    101ea8 <__alltraps>

0010260c <vector188>:
.globl vector188
vector188:
  pushl $0
  10260c:	6a 00                	push   $0x0
  pushl $188
  10260e:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102613:	e9 90 f8 ff ff       	jmp    101ea8 <__alltraps>

00102618 <vector189>:
.globl vector189
vector189:
  pushl $0
  102618:	6a 00                	push   $0x0
  pushl $189
  10261a:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  10261f:	e9 84 f8 ff ff       	jmp    101ea8 <__alltraps>

00102624 <vector190>:
.globl vector190
vector190:
  pushl $0
  102624:	6a 00                	push   $0x0
  pushl $190
  102626:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  10262b:	e9 78 f8 ff ff       	jmp    101ea8 <__alltraps>

00102630 <vector191>:
.globl vector191
vector191:
  pushl $0
  102630:	6a 00                	push   $0x0
  pushl $191
  102632:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102637:	e9 6c f8 ff ff       	jmp    101ea8 <__alltraps>

0010263c <vector192>:
.globl vector192
vector192:
  pushl $0
  10263c:	6a 00                	push   $0x0
  pushl $192
  10263e:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102643:	e9 60 f8 ff ff       	jmp    101ea8 <__alltraps>

00102648 <vector193>:
.globl vector193
vector193:
  pushl $0
  102648:	6a 00                	push   $0x0
  pushl $193
  10264a:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  10264f:	e9 54 f8 ff ff       	jmp    101ea8 <__alltraps>

00102654 <vector194>:
.globl vector194
vector194:
  pushl $0
  102654:	6a 00                	push   $0x0
  pushl $194
  102656:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  10265b:	e9 48 f8 ff ff       	jmp    101ea8 <__alltraps>

00102660 <vector195>:
.globl vector195
vector195:
  pushl $0
  102660:	6a 00                	push   $0x0
  pushl $195
  102662:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102667:	e9 3c f8 ff ff       	jmp    101ea8 <__alltraps>

0010266c <vector196>:
.globl vector196
vector196:
  pushl $0
  10266c:	6a 00                	push   $0x0
  pushl $196
  10266e:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102673:	e9 30 f8 ff ff       	jmp    101ea8 <__alltraps>

00102678 <vector197>:
.globl vector197
vector197:
  pushl $0
  102678:	6a 00                	push   $0x0
  pushl $197
  10267a:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  10267f:	e9 24 f8 ff ff       	jmp    101ea8 <__alltraps>

00102684 <vector198>:
.globl vector198
vector198:
  pushl $0
  102684:	6a 00                	push   $0x0
  pushl $198
  102686:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  10268b:	e9 18 f8 ff ff       	jmp    101ea8 <__alltraps>

00102690 <vector199>:
.globl vector199
vector199:
  pushl $0
  102690:	6a 00                	push   $0x0
  pushl $199
  102692:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102697:	e9 0c f8 ff ff       	jmp    101ea8 <__alltraps>

0010269c <vector200>:
.globl vector200
vector200:
  pushl $0
  10269c:	6a 00                	push   $0x0
  pushl $200
  10269e:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1026a3:	e9 00 f8 ff ff       	jmp    101ea8 <__alltraps>

001026a8 <vector201>:
.globl vector201
vector201:
  pushl $0
  1026a8:	6a 00                	push   $0x0
  pushl $201
  1026aa:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1026af:	e9 f4 f7 ff ff       	jmp    101ea8 <__alltraps>

001026b4 <vector202>:
.globl vector202
vector202:
  pushl $0
  1026b4:	6a 00                	push   $0x0
  pushl $202
  1026b6:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1026bb:	e9 e8 f7 ff ff       	jmp    101ea8 <__alltraps>

001026c0 <vector203>:
.globl vector203
vector203:
  pushl $0
  1026c0:	6a 00                	push   $0x0
  pushl $203
  1026c2:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1026c7:	e9 dc f7 ff ff       	jmp    101ea8 <__alltraps>

001026cc <vector204>:
.globl vector204
vector204:
  pushl $0
  1026cc:	6a 00                	push   $0x0
  pushl $204
  1026ce:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1026d3:	e9 d0 f7 ff ff       	jmp    101ea8 <__alltraps>

001026d8 <vector205>:
.globl vector205
vector205:
  pushl $0
  1026d8:	6a 00                	push   $0x0
  pushl $205
  1026da:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1026df:	e9 c4 f7 ff ff       	jmp    101ea8 <__alltraps>

001026e4 <vector206>:
.globl vector206
vector206:
  pushl $0
  1026e4:	6a 00                	push   $0x0
  pushl $206
  1026e6:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1026eb:	e9 b8 f7 ff ff       	jmp    101ea8 <__alltraps>

001026f0 <vector207>:
.globl vector207
vector207:
  pushl $0
  1026f0:	6a 00                	push   $0x0
  pushl $207
  1026f2:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1026f7:	e9 ac f7 ff ff       	jmp    101ea8 <__alltraps>

001026fc <vector208>:
.globl vector208
vector208:
  pushl $0
  1026fc:	6a 00                	push   $0x0
  pushl $208
  1026fe:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102703:	e9 a0 f7 ff ff       	jmp    101ea8 <__alltraps>

00102708 <vector209>:
.globl vector209
vector209:
  pushl $0
  102708:	6a 00                	push   $0x0
  pushl $209
  10270a:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  10270f:	e9 94 f7 ff ff       	jmp    101ea8 <__alltraps>

00102714 <vector210>:
.globl vector210
vector210:
  pushl $0
  102714:	6a 00                	push   $0x0
  pushl $210
  102716:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  10271b:	e9 88 f7 ff ff       	jmp    101ea8 <__alltraps>

00102720 <vector211>:
.globl vector211
vector211:
  pushl $0
  102720:	6a 00                	push   $0x0
  pushl $211
  102722:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102727:	e9 7c f7 ff ff       	jmp    101ea8 <__alltraps>

0010272c <vector212>:
.globl vector212
vector212:
  pushl $0
  10272c:	6a 00                	push   $0x0
  pushl $212
  10272e:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102733:	e9 70 f7 ff ff       	jmp    101ea8 <__alltraps>

00102738 <vector213>:
.globl vector213
vector213:
  pushl $0
  102738:	6a 00                	push   $0x0
  pushl $213
  10273a:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  10273f:	e9 64 f7 ff ff       	jmp    101ea8 <__alltraps>

00102744 <vector214>:
.globl vector214
vector214:
  pushl $0
  102744:	6a 00                	push   $0x0
  pushl $214
  102746:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  10274b:	e9 58 f7 ff ff       	jmp    101ea8 <__alltraps>

00102750 <vector215>:
.globl vector215
vector215:
  pushl $0
  102750:	6a 00                	push   $0x0
  pushl $215
  102752:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102757:	e9 4c f7 ff ff       	jmp    101ea8 <__alltraps>

0010275c <vector216>:
.globl vector216
vector216:
  pushl $0
  10275c:	6a 00                	push   $0x0
  pushl $216
  10275e:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102763:	e9 40 f7 ff ff       	jmp    101ea8 <__alltraps>

00102768 <vector217>:
.globl vector217
vector217:
  pushl $0
  102768:	6a 00                	push   $0x0
  pushl $217
  10276a:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  10276f:	e9 34 f7 ff ff       	jmp    101ea8 <__alltraps>

00102774 <vector218>:
.globl vector218
vector218:
  pushl $0
  102774:	6a 00                	push   $0x0
  pushl $218
  102776:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  10277b:	e9 28 f7 ff ff       	jmp    101ea8 <__alltraps>

00102780 <vector219>:
.globl vector219
vector219:
  pushl $0
  102780:	6a 00                	push   $0x0
  pushl $219
  102782:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102787:	e9 1c f7 ff ff       	jmp    101ea8 <__alltraps>

0010278c <vector220>:
.globl vector220
vector220:
  pushl $0
  10278c:	6a 00                	push   $0x0
  pushl $220
  10278e:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102793:	e9 10 f7 ff ff       	jmp    101ea8 <__alltraps>

00102798 <vector221>:
.globl vector221
vector221:
  pushl $0
  102798:	6a 00                	push   $0x0
  pushl $221
  10279a:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  10279f:	e9 04 f7 ff ff       	jmp    101ea8 <__alltraps>

001027a4 <vector222>:
.globl vector222
vector222:
  pushl $0
  1027a4:	6a 00                	push   $0x0
  pushl $222
  1027a6:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1027ab:	e9 f8 f6 ff ff       	jmp    101ea8 <__alltraps>

001027b0 <vector223>:
.globl vector223
vector223:
  pushl $0
  1027b0:	6a 00                	push   $0x0
  pushl $223
  1027b2:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1027b7:	e9 ec f6 ff ff       	jmp    101ea8 <__alltraps>

001027bc <vector224>:
.globl vector224
vector224:
  pushl $0
  1027bc:	6a 00                	push   $0x0
  pushl $224
  1027be:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1027c3:	e9 e0 f6 ff ff       	jmp    101ea8 <__alltraps>

001027c8 <vector225>:
.globl vector225
vector225:
  pushl $0
  1027c8:	6a 00                	push   $0x0
  pushl $225
  1027ca:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1027cf:	e9 d4 f6 ff ff       	jmp    101ea8 <__alltraps>

001027d4 <vector226>:
.globl vector226
vector226:
  pushl $0
  1027d4:	6a 00                	push   $0x0
  pushl $226
  1027d6:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1027db:	e9 c8 f6 ff ff       	jmp    101ea8 <__alltraps>

001027e0 <vector227>:
.globl vector227
vector227:
  pushl $0
  1027e0:	6a 00                	push   $0x0
  pushl $227
  1027e2:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1027e7:	e9 bc f6 ff ff       	jmp    101ea8 <__alltraps>

001027ec <vector228>:
.globl vector228
vector228:
  pushl $0
  1027ec:	6a 00                	push   $0x0
  pushl $228
  1027ee:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1027f3:	e9 b0 f6 ff ff       	jmp    101ea8 <__alltraps>

001027f8 <vector229>:
.globl vector229
vector229:
  pushl $0
  1027f8:	6a 00                	push   $0x0
  pushl $229
  1027fa:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1027ff:	e9 a4 f6 ff ff       	jmp    101ea8 <__alltraps>

00102804 <vector230>:
.globl vector230
vector230:
  pushl $0
  102804:	6a 00                	push   $0x0
  pushl $230
  102806:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  10280b:	e9 98 f6 ff ff       	jmp    101ea8 <__alltraps>

00102810 <vector231>:
.globl vector231
vector231:
  pushl $0
  102810:	6a 00                	push   $0x0
  pushl $231
  102812:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102817:	e9 8c f6 ff ff       	jmp    101ea8 <__alltraps>

0010281c <vector232>:
.globl vector232
vector232:
  pushl $0
  10281c:	6a 00                	push   $0x0
  pushl $232
  10281e:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102823:	e9 80 f6 ff ff       	jmp    101ea8 <__alltraps>

00102828 <vector233>:
.globl vector233
vector233:
  pushl $0
  102828:	6a 00                	push   $0x0
  pushl $233
  10282a:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  10282f:	e9 74 f6 ff ff       	jmp    101ea8 <__alltraps>

00102834 <vector234>:
.globl vector234
vector234:
  pushl $0
  102834:	6a 00                	push   $0x0
  pushl $234
  102836:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  10283b:	e9 68 f6 ff ff       	jmp    101ea8 <__alltraps>

00102840 <vector235>:
.globl vector235
vector235:
  pushl $0
  102840:	6a 00                	push   $0x0
  pushl $235
  102842:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102847:	e9 5c f6 ff ff       	jmp    101ea8 <__alltraps>

0010284c <vector236>:
.globl vector236
vector236:
  pushl $0
  10284c:	6a 00                	push   $0x0
  pushl $236
  10284e:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102853:	e9 50 f6 ff ff       	jmp    101ea8 <__alltraps>

00102858 <vector237>:
.globl vector237
vector237:
  pushl $0
  102858:	6a 00                	push   $0x0
  pushl $237
  10285a:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  10285f:	e9 44 f6 ff ff       	jmp    101ea8 <__alltraps>

00102864 <vector238>:
.globl vector238
vector238:
  pushl $0
  102864:	6a 00                	push   $0x0
  pushl $238
  102866:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  10286b:	e9 38 f6 ff ff       	jmp    101ea8 <__alltraps>

00102870 <vector239>:
.globl vector239
vector239:
  pushl $0
  102870:	6a 00                	push   $0x0
  pushl $239
  102872:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102877:	e9 2c f6 ff ff       	jmp    101ea8 <__alltraps>

0010287c <vector240>:
.globl vector240
vector240:
  pushl $0
  10287c:	6a 00                	push   $0x0
  pushl $240
  10287e:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102883:	e9 20 f6 ff ff       	jmp    101ea8 <__alltraps>

00102888 <vector241>:
.globl vector241
vector241:
  pushl $0
  102888:	6a 00                	push   $0x0
  pushl $241
  10288a:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  10288f:	e9 14 f6 ff ff       	jmp    101ea8 <__alltraps>

00102894 <vector242>:
.globl vector242
vector242:
  pushl $0
  102894:	6a 00                	push   $0x0
  pushl $242
  102896:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  10289b:	e9 08 f6 ff ff       	jmp    101ea8 <__alltraps>

001028a0 <vector243>:
.globl vector243
vector243:
  pushl $0
  1028a0:	6a 00                	push   $0x0
  pushl $243
  1028a2:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1028a7:	e9 fc f5 ff ff       	jmp    101ea8 <__alltraps>

001028ac <vector244>:
.globl vector244
vector244:
  pushl $0
  1028ac:	6a 00                	push   $0x0
  pushl $244
  1028ae:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1028b3:	e9 f0 f5 ff ff       	jmp    101ea8 <__alltraps>

001028b8 <vector245>:
.globl vector245
vector245:
  pushl $0
  1028b8:	6a 00                	push   $0x0
  pushl $245
  1028ba:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1028bf:	e9 e4 f5 ff ff       	jmp    101ea8 <__alltraps>

001028c4 <vector246>:
.globl vector246
vector246:
  pushl $0
  1028c4:	6a 00                	push   $0x0
  pushl $246
  1028c6:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1028cb:	e9 d8 f5 ff ff       	jmp    101ea8 <__alltraps>

001028d0 <vector247>:
.globl vector247
vector247:
  pushl $0
  1028d0:	6a 00                	push   $0x0
  pushl $247
  1028d2:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1028d7:	e9 cc f5 ff ff       	jmp    101ea8 <__alltraps>

001028dc <vector248>:
.globl vector248
vector248:
  pushl $0
  1028dc:	6a 00                	push   $0x0
  pushl $248
  1028de:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1028e3:	e9 c0 f5 ff ff       	jmp    101ea8 <__alltraps>

001028e8 <vector249>:
.globl vector249
vector249:
  pushl $0
  1028e8:	6a 00                	push   $0x0
  pushl $249
  1028ea:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1028ef:	e9 b4 f5 ff ff       	jmp    101ea8 <__alltraps>

001028f4 <vector250>:
.globl vector250
vector250:
  pushl $0
  1028f4:	6a 00                	push   $0x0
  pushl $250
  1028f6:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1028fb:	e9 a8 f5 ff ff       	jmp    101ea8 <__alltraps>

00102900 <vector251>:
.globl vector251
vector251:
  pushl $0
  102900:	6a 00                	push   $0x0
  pushl $251
  102902:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102907:	e9 9c f5 ff ff       	jmp    101ea8 <__alltraps>

0010290c <vector252>:
.globl vector252
vector252:
  pushl $0
  10290c:	6a 00                	push   $0x0
  pushl $252
  10290e:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102913:	e9 90 f5 ff ff       	jmp    101ea8 <__alltraps>

00102918 <vector253>:
.globl vector253
vector253:
  pushl $0
  102918:	6a 00                	push   $0x0
  pushl $253
  10291a:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  10291f:	e9 84 f5 ff ff       	jmp    101ea8 <__alltraps>

00102924 <vector254>:
.globl vector254
vector254:
  pushl $0
  102924:	6a 00                	push   $0x0
  pushl $254
  102926:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  10292b:	e9 78 f5 ff ff       	jmp    101ea8 <__alltraps>

00102930 <vector255>:
.globl vector255
vector255:
  pushl $0
  102930:	6a 00                	push   $0x0
  pushl $255
  102932:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102937:	e9 6c f5 ff ff       	jmp    101ea8 <__alltraps>

0010293c <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  10293c:	55                   	push   %ebp
  10293d:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  10293f:	8b 45 08             	mov    0x8(%ebp),%eax
  102942:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102945:	b8 23 00 00 00       	mov    $0x23,%eax
  10294a:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  10294c:	b8 23 00 00 00       	mov    $0x23,%eax
  102951:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102953:	b8 10 00 00 00       	mov    $0x10,%eax
  102958:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  10295a:	b8 10 00 00 00       	mov    $0x10,%eax
  10295f:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102961:	b8 10 00 00 00       	mov    $0x10,%eax
  102966:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102968:	ea 6f 29 10 00 08 00 	ljmp   $0x8,$0x10296f
}
  10296f:	5d                   	pop    %ebp
  102970:	c3                   	ret    

00102971 <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102971:	55                   	push   %ebp
  102972:	89 e5                	mov    %esp,%ebp
  102974:	83 ec 14             	sub    $0x14,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  102977:	b8 80 f9 10 00       	mov    $0x10f980,%eax
  10297c:	05 00 04 00 00       	add    $0x400,%eax
  102981:	a3 a4 f8 10 00       	mov    %eax,0x10f8a4
    ts.ts_ss0 = KERNEL_DS;
  102986:	66 c7 05 a8 f8 10 00 	movw   $0x10,0x10f8a8
  10298d:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  10298f:	66 c7 05 08 ea 10 00 	movw   $0x68,0x10ea08
  102996:	68 00 
  102998:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  10299d:	66 a3 0a ea 10 00    	mov    %ax,0x10ea0a
  1029a3:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  1029a8:	c1 e8 10             	shr    $0x10,%eax
  1029ab:	a2 0c ea 10 00       	mov    %al,0x10ea0c
  1029b0:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029b7:	83 e0 f0             	and    $0xfffffff0,%eax
  1029ba:	83 c8 09             	or     $0x9,%eax
  1029bd:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029c2:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029c9:	83 c8 10             	or     $0x10,%eax
  1029cc:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029d1:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029d8:	83 e0 9f             	and    $0xffffff9f,%eax
  1029db:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029e0:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  1029e7:	83 c8 80             	or     $0xffffff80,%eax
  1029ea:	a2 0d ea 10 00       	mov    %al,0x10ea0d
  1029ef:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  1029f6:	83 e0 f0             	and    $0xfffffff0,%eax
  1029f9:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  1029fe:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a05:	83 e0 ef             	and    $0xffffffef,%eax
  102a08:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a0d:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a14:	83 e0 df             	and    $0xffffffdf,%eax
  102a17:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a1c:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a23:	83 c8 40             	or     $0x40,%eax
  102a26:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a2b:	0f b6 05 0e ea 10 00 	movzbl 0x10ea0e,%eax
  102a32:	83 e0 7f             	and    $0x7f,%eax
  102a35:	a2 0e ea 10 00       	mov    %al,0x10ea0e
  102a3a:	b8 a0 f8 10 00       	mov    $0x10f8a0,%eax
  102a3f:	c1 e8 18             	shr    $0x18,%eax
  102a42:	a2 0f ea 10 00       	mov    %al,0x10ea0f
    gdt[SEG_TSS].sd_s = 0;
  102a47:	0f b6 05 0d ea 10 00 	movzbl 0x10ea0d,%eax
  102a4e:	83 e0 ef             	and    $0xffffffef,%eax
  102a51:	a2 0d ea 10 00       	mov    %al,0x10ea0d

    // reload all segment registers
    lgdt(&gdt_pd);
  102a56:	c7 04 24 10 ea 10 00 	movl   $0x10ea10,(%esp)
  102a5d:	e8 da fe ff ff       	call   10293c <lgdt>
  102a62:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102a68:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102a6c:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102a6f:	c9                   	leave  
  102a70:	c3                   	ret    

00102a71 <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  102a71:	55                   	push   %ebp
  102a72:	89 e5                	mov    %esp,%ebp
    gdt_init();
  102a74:	e8 f8 fe ff ff       	call   102971 <gdt_init>
}
  102a79:	5d                   	pop    %ebp
  102a7a:	c3                   	ret    

00102a7b <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  102a7b:	55                   	push   %ebp
  102a7c:	89 e5                	mov    %esp,%ebp
  102a7e:	83 ec 58             	sub    $0x58,%esp
  102a81:	8b 45 10             	mov    0x10(%ebp),%eax
  102a84:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102a87:	8b 45 14             	mov    0x14(%ebp),%eax
  102a8a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  102a8d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102a90:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102a93:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102a96:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  102a99:	8b 45 18             	mov    0x18(%ebp),%eax
  102a9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102a9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102aa2:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102aa5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102aa8:	89 55 f0             	mov    %edx,-0x10(%ebp)
  102aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102aae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102ab1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  102ab5:	74 1c                	je     102ad3 <printnum+0x58>
  102ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102aba:	ba 00 00 00 00       	mov    $0x0,%edx
  102abf:	f7 75 e4             	divl   -0x1c(%ebp)
  102ac2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  102ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ac8:	ba 00 00 00 00       	mov    $0x0,%edx
  102acd:	f7 75 e4             	divl   -0x1c(%ebp)
  102ad0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ad3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ad6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102ad9:	f7 75 e4             	divl   -0x1c(%ebp)
  102adc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102adf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  102ae2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102ae5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102ae8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102aeb:	89 55 ec             	mov    %edx,-0x14(%ebp)
  102aee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102af1:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  102af4:	8b 45 18             	mov    0x18(%ebp),%eax
  102af7:	ba 00 00 00 00       	mov    $0x0,%edx
  102afc:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102aff:	77 56                	ja     102b57 <printnum+0xdc>
  102b01:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102b04:	72 05                	jb     102b0b <printnum+0x90>
  102b06:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102b09:	77 4c                	ja     102b57 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  102b0b:	8b 45 1c             	mov    0x1c(%ebp),%eax
  102b0e:	8d 50 ff             	lea    -0x1(%eax),%edx
  102b11:	8b 45 20             	mov    0x20(%ebp),%eax
  102b14:	89 44 24 18          	mov    %eax,0x18(%esp)
  102b18:	89 54 24 14          	mov    %edx,0x14(%esp)
  102b1c:	8b 45 18             	mov    0x18(%ebp),%eax
  102b1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  102b23:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102b26:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102b29:	89 44 24 08          	mov    %eax,0x8(%esp)
  102b2d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102b31:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b34:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b38:	8b 45 08             	mov    0x8(%ebp),%eax
  102b3b:	89 04 24             	mov    %eax,(%esp)
  102b3e:	e8 38 ff ff ff       	call   102a7b <printnum>
  102b43:	eb 1c                	jmp    102b61 <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  102b45:	8b 45 0c             	mov    0xc(%ebp),%eax
  102b48:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b4c:	8b 45 20             	mov    0x20(%ebp),%eax
  102b4f:	89 04 24             	mov    %eax,(%esp)
  102b52:	8b 45 08             	mov    0x8(%ebp),%eax
  102b55:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  102b57:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  102b5b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  102b5f:	7f e4                	jg     102b45 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  102b61:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102b64:	05 70 3d 10 00       	add    $0x103d70,%eax
  102b69:	0f b6 00             	movzbl (%eax),%eax
  102b6c:	0f be c0             	movsbl %al,%eax
  102b6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  102b72:	89 54 24 04          	mov    %edx,0x4(%esp)
  102b76:	89 04 24             	mov    %eax,(%esp)
  102b79:	8b 45 08             	mov    0x8(%ebp),%eax
  102b7c:	ff d0                	call   *%eax
}
  102b7e:	c9                   	leave  
  102b7f:	c3                   	ret    

00102b80 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  102b80:	55                   	push   %ebp
  102b81:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102b83:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102b87:	7e 14                	jle    102b9d <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  102b89:	8b 45 08             	mov    0x8(%ebp),%eax
  102b8c:	8b 00                	mov    (%eax),%eax
  102b8e:	8d 48 08             	lea    0x8(%eax),%ecx
  102b91:	8b 55 08             	mov    0x8(%ebp),%edx
  102b94:	89 0a                	mov    %ecx,(%edx)
  102b96:	8b 50 04             	mov    0x4(%eax),%edx
  102b99:	8b 00                	mov    (%eax),%eax
  102b9b:	eb 30                	jmp    102bcd <getuint+0x4d>
    }
    else if (lflag) {
  102b9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102ba1:	74 16                	je     102bb9 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  102ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  102ba6:	8b 00                	mov    (%eax),%eax
  102ba8:	8d 48 04             	lea    0x4(%eax),%ecx
  102bab:	8b 55 08             	mov    0x8(%ebp),%edx
  102bae:	89 0a                	mov    %ecx,(%edx)
  102bb0:	8b 00                	mov    (%eax),%eax
  102bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  102bb7:	eb 14                	jmp    102bcd <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  102bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  102bbc:	8b 00                	mov    (%eax),%eax
  102bbe:	8d 48 04             	lea    0x4(%eax),%ecx
  102bc1:	8b 55 08             	mov    0x8(%ebp),%edx
  102bc4:	89 0a                	mov    %ecx,(%edx)
  102bc6:	8b 00                	mov    (%eax),%eax
  102bc8:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  102bcd:	5d                   	pop    %ebp
  102bce:	c3                   	ret    

00102bcf <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  102bcf:	55                   	push   %ebp
  102bd0:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  102bd2:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  102bd6:	7e 14                	jle    102bec <getint+0x1d>
        return va_arg(*ap, long long);
  102bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  102bdb:	8b 00                	mov    (%eax),%eax
  102bdd:	8d 48 08             	lea    0x8(%eax),%ecx
  102be0:	8b 55 08             	mov    0x8(%ebp),%edx
  102be3:	89 0a                	mov    %ecx,(%edx)
  102be5:	8b 50 04             	mov    0x4(%eax),%edx
  102be8:	8b 00                	mov    (%eax),%eax
  102bea:	eb 28                	jmp    102c14 <getint+0x45>
    }
    else if (lflag) {
  102bec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102bf0:	74 12                	je     102c04 <getint+0x35>
        return va_arg(*ap, long);
  102bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  102bf5:	8b 00                	mov    (%eax),%eax
  102bf7:	8d 48 04             	lea    0x4(%eax),%ecx
  102bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  102bfd:	89 0a                	mov    %ecx,(%edx)
  102bff:	8b 00                	mov    (%eax),%eax
  102c01:	99                   	cltd   
  102c02:	eb 10                	jmp    102c14 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  102c04:	8b 45 08             	mov    0x8(%ebp),%eax
  102c07:	8b 00                	mov    (%eax),%eax
  102c09:	8d 48 04             	lea    0x4(%eax),%ecx
  102c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  102c0f:	89 0a                	mov    %ecx,(%edx)
  102c11:	8b 00                	mov    (%eax),%eax
  102c13:	99                   	cltd   
    }
}
  102c14:	5d                   	pop    %ebp
  102c15:	c3                   	ret    

00102c16 <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  102c16:	55                   	push   %ebp
  102c17:	89 e5                	mov    %esp,%ebp
  102c19:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  102c1c:	8d 45 14             	lea    0x14(%ebp),%eax
  102c1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  102c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102c25:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102c29:	8b 45 10             	mov    0x10(%ebp),%eax
  102c2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  102c30:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c33:	89 44 24 04          	mov    %eax,0x4(%esp)
  102c37:	8b 45 08             	mov    0x8(%ebp),%eax
  102c3a:	89 04 24             	mov    %eax,(%esp)
  102c3d:	e8 02 00 00 00       	call   102c44 <vprintfmt>
    va_end(ap);
}
  102c42:	c9                   	leave  
  102c43:	c3                   	ret    

00102c44 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  102c44:	55                   	push   %ebp
  102c45:	89 e5                	mov    %esp,%ebp
  102c47:	56                   	push   %esi
  102c48:	53                   	push   %ebx
  102c49:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102c4c:	eb 18                	jmp    102c66 <vprintfmt+0x22>
            if (ch == '\0') {
  102c4e:	85 db                	test   %ebx,%ebx
  102c50:	75 05                	jne    102c57 <vprintfmt+0x13>
                return;
  102c52:	e9 d1 03 00 00       	jmp    103028 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
  102c57:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  102c5e:	89 1c 24             	mov    %ebx,(%esp)
  102c61:	8b 45 08             	mov    0x8(%ebp),%eax
  102c64:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  102c66:	8b 45 10             	mov    0x10(%ebp),%eax
  102c69:	8d 50 01             	lea    0x1(%eax),%edx
  102c6c:	89 55 10             	mov    %edx,0x10(%ebp)
  102c6f:	0f b6 00             	movzbl (%eax),%eax
  102c72:	0f b6 d8             	movzbl %al,%ebx
  102c75:	83 fb 25             	cmp    $0x25,%ebx
  102c78:	75 d4                	jne    102c4e <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  102c7a:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  102c7e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  102c85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102c88:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  102c8b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102c92:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102c95:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  102c98:	8b 45 10             	mov    0x10(%ebp),%eax
  102c9b:	8d 50 01             	lea    0x1(%eax),%edx
  102c9e:	89 55 10             	mov    %edx,0x10(%ebp)
  102ca1:	0f b6 00             	movzbl (%eax),%eax
  102ca4:	0f b6 d8             	movzbl %al,%ebx
  102ca7:	8d 43 dd             	lea    -0x23(%ebx),%eax
  102caa:	83 f8 55             	cmp    $0x55,%eax
  102cad:	0f 87 44 03 00 00    	ja     102ff7 <vprintfmt+0x3b3>
  102cb3:	8b 04 85 94 3d 10 00 	mov    0x103d94(,%eax,4),%eax
  102cba:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  102cbc:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  102cc0:	eb d6                	jmp    102c98 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  102cc2:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  102cc6:	eb d0                	jmp    102c98 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  102cc8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  102ccf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102cd2:	89 d0                	mov    %edx,%eax
  102cd4:	c1 e0 02             	shl    $0x2,%eax
  102cd7:	01 d0                	add    %edx,%eax
  102cd9:	01 c0                	add    %eax,%eax
  102cdb:	01 d8                	add    %ebx,%eax
  102cdd:	83 e8 30             	sub    $0x30,%eax
  102ce0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  102ce3:	8b 45 10             	mov    0x10(%ebp),%eax
  102ce6:	0f b6 00             	movzbl (%eax),%eax
  102ce9:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  102cec:	83 fb 2f             	cmp    $0x2f,%ebx
  102cef:	7e 0b                	jle    102cfc <vprintfmt+0xb8>
  102cf1:	83 fb 39             	cmp    $0x39,%ebx
  102cf4:	7f 06                	jg     102cfc <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  102cf6:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  102cfa:	eb d3                	jmp    102ccf <vprintfmt+0x8b>
            goto process_precision;
  102cfc:	eb 33                	jmp    102d31 <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
  102cfe:	8b 45 14             	mov    0x14(%ebp),%eax
  102d01:	8d 50 04             	lea    0x4(%eax),%edx
  102d04:	89 55 14             	mov    %edx,0x14(%ebp)
  102d07:	8b 00                	mov    (%eax),%eax
  102d09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  102d0c:	eb 23                	jmp    102d31 <vprintfmt+0xed>

        case '.':
            if (width < 0)
  102d0e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102d12:	79 0c                	jns    102d20 <vprintfmt+0xdc>
                width = 0;
  102d14:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  102d1b:	e9 78 ff ff ff       	jmp    102c98 <vprintfmt+0x54>
  102d20:	e9 73 ff ff ff       	jmp    102c98 <vprintfmt+0x54>

        case '#':
            altflag = 1;
  102d25:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  102d2c:	e9 67 ff ff ff       	jmp    102c98 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
  102d31:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102d35:	79 12                	jns    102d49 <vprintfmt+0x105>
                width = precision, precision = -1;
  102d37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102d3a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102d3d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  102d44:	e9 4f ff ff ff       	jmp    102c98 <vprintfmt+0x54>
  102d49:	e9 4a ff ff ff       	jmp    102c98 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  102d4e:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
  102d52:	e9 41 ff ff ff       	jmp    102c98 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  102d57:	8b 45 14             	mov    0x14(%ebp),%eax
  102d5a:	8d 50 04             	lea    0x4(%eax),%edx
  102d5d:	89 55 14             	mov    %edx,0x14(%ebp)
  102d60:	8b 00                	mov    (%eax),%eax
  102d62:	8b 55 0c             	mov    0xc(%ebp),%edx
  102d65:	89 54 24 04          	mov    %edx,0x4(%esp)
  102d69:	89 04 24             	mov    %eax,(%esp)
  102d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  102d6f:	ff d0                	call   *%eax
            break;
  102d71:	e9 ac 02 00 00       	jmp    103022 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
  102d76:	8b 45 14             	mov    0x14(%ebp),%eax
  102d79:	8d 50 04             	lea    0x4(%eax),%edx
  102d7c:	89 55 14             	mov    %edx,0x14(%ebp)
  102d7f:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  102d81:	85 db                	test   %ebx,%ebx
  102d83:	79 02                	jns    102d87 <vprintfmt+0x143>
                err = -err;
  102d85:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  102d87:	83 fb 06             	cmp    $0x6,%ebx
  102d8a:	7f 0b                	jg     102d97 <vprintfmt+0x153>
  102d8c:	8b 34 9d 54 3d 10 00 	mov    0x103d54(,%ebx,4),%esi
  102d93:	85 f6                	test   %esi,%esi
  102d95:	75 23                	jne    102dba <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
  102d97:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  102d9b:	c7 44 24 08 81 3d 10 	movl   $0x103d81,0x8(%esp)
  102da2:	00 
  102da3:	8b 45 0c             	mov    0xc(%ebp),%eax
  102da6:	89 44 24 04          	mov    %eax,0x4(%esp)
  102daa:	8b 45 08             	mov    0x8(%ebp),%eax
  102dad:	89 04 24             	mov    %eax,(%esp)
  102db0:	e8 61 fe ff ff       	call   102c16 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  102db5:	e9 68 02 00 00       	jmp    103022 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  102dba:	89 74 24 0c          	mov    %esi,0xc(%esp)
  102dbe:	c7 44 24 08 8a 3d 10 	movl   $0x103d8a,0x8(%esp)
  102dc5:	00 
  102dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  102dc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  102dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  102dd0:	89 04 24             	mov    %eax,(%esp)
  102dd3:	e8 3e fe ff ff       	call   102c16 <printfmt>
            }
            break;
  102dd8:	e9 45 02 00 00       	jmp    103022 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  102ddd:	8b 45 14             	mov    0x14(%ebp),%eax
  102de0:	8d 50 04             	lea    0x4(%eax),%edx
  102de3:	89 55 14             	mov    %edx,0x14(%ebp)
  102de6:	8b 30                	mov    (%eax),%esi
  102de8:	85 f6                	test   %esi,%esi
  102dea:	75 05                	jne    102df1 <vprintfmt+0x1ad>
                p = "(null)";
  102dec:	be 8d 3d 10 00       	mov    $0x103d8d,%esi
            }
            if (width > 0 && padc != '-') {
  102df1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102df5:	7e 3e                	jle    102e35 <vprintfmt+0x1f1>
  102df7:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  102dfb:	74 38                	je     102e35 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  102dfd:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  102e00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102e03:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e07:	89 34 24             	mov    %esi,(%esp)
  102e0a:	e8 15 03 00 00       	call   103124 <strnlen>
  102e0f:	29 c3                	sub    %eax,%ebx
  102e11:	89 d8                	mov    %ebx,%eax
  102e13:	89 45 e8             	mov    %eax,-0x18(%ebp)
  102e16:	eb 17                	jmp    102e2f <vprintfmt+0x1eb>
                    putch(padc, putdat);
  102e18:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  102e1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e1f:	89 54 24 04          	mov    %edx,0x4(%esp)
  102e23:	89 04 24             	mov    %eax,(%esp)
  102e26:	8b 45 08             	mov    0x8(%ebp),%eax
  102e29:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  102e2b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  102e2f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102e33:	7f e3                	jg     102e18 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  102e35:	eb 38                	jmp    102e6f <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
  102e37:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  102e3b:	74 1f                	je     102e5c <vprintfmt+0x218>
  102e3d:	83 fb 1f             	cmp    $0x1f,%ebx
  102e40:	7e 05                	jle    102e47 <vprintfmt+0x203>
  102e42:	83 fb 7e             	cmp    $0x7e,%ebx
  102e45:	7e 15                	jle    102e5c <vprintfmt+0x218>
                    putch('?', putdat);
  102e47:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e4e:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  102e55:	8b 45 08             	mov    0x8(%ebp),%eax
  102e58:	ff d0                	call   *%eax
  102e5a:	eb 0f                	jmp    102e6b <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
  102e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e63:	89 1c 24             	mov    %ebx,(%esp)
  102e66:	8b 45 08             	mov    0x8(%ebp),%eax
  102e69:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  102e6b:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  102e6f:	89 f0                	mov    %esi,%eax
  102e71:	8d 70 01             	lea    0x1(%eax),%esi
  102e74:	0f b6 00             	movzbl (%eax),%eax
  102e77:	0f be d8             	movsbl %al,%ebx
  102e7a:	85 db                	test   %ebx,%ebx
  102e7c:	74 10                	je     102e8e <vprintfmt+0x24a>
  102e7e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102e82:	78 b3                	js     102e37 <vprintfmt+0x1f3>
  102e84:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  102e88:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102e8c:	79 a9                	jns    102e37 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  102e8e:	eb 17                	jmp    102ea7 <vprintfmt+0x263>
                putch(' ', putdat);
  102e90:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e93:	89 44 24 04          	mov    %eax,0x4(%esp)
  102e97:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  102e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  102ea1:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  102ea3:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
  102ea7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102eab:	7f e3                	jg     102e90 <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
  102ead:	e9 70 01 00 00       	jmp    103022 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  102eb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102eb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  102eb9:	8d 45 14             	lea    0x14(%ebp),%eax
  102ebc:	89 04 24             	mov    %eax,(%esp)
  102ebf:	e8 0b fd ff ff       	call   102bcf <getint>
  102ec4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ec7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  102eca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ecd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102ed0:	85 d2                	test   %edx,%edx
  102ed2:	79 26                	jns    102efa <vprintfmt+0x2b6>
                putch('-', putdat);
  102ed4:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ed7:	89 44 24 04          	mov    %eax,0x4(%esp)
  102edb:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  102ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  102ee5:	ff d0                	call   *%eax
                num = -(long long)num;
  102ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102eea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102eed:	f7 d8                	neg    %eax
  102eef:	83 d2 00             	adc    $0x0,%edx
  102ef2:	f7 da                	neg    %edx
  102ef4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ef7:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  102efa:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  102f01:	e9 a8 00 00 00       	jmp    102fae <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  102f06:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f09:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f0d:	8d 45 14             	lea    0x14(%ebp),%eax
  102f10:	89 04 24             	mov    %eax,(%esp)
  102f13:	e8 68 fc ff ff       	call   102b80 <getuint>
  102f18:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f1b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  102f1e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  102f25:	e9 84 00 00 00       	jmp    102fae <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  102f2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f31:	8d 45 14             	lea    0x14(%ebp),%eax
  102f34:	89 04 24             	mov    %eax,(%esp)
  102f37:	e8 44 fc ff ff       	call   102b80 <getuint>
  102f3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f3f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  102f42:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  102f49:	eb 63                	jmp    102fae <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
  102f4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f52:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  102f59:	8b 45 08             	mov    0x8(%ebp),%eax
  102f5c:	ff d0                	call   *%eax
            putch('x', putdat);
  102f5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f61:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f65:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  102f6c:	8b 45 08             	mov    0x8(%ebp),%eax
  102f6f:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  102f71:	8b 45 14             	mov    0x14(%ebp),%eax
  102f74:	8d 50 04             	lea    0x4(%eax),%edx
  102f77:	89 55 14             	mov    %edx,0x14(%ebp)
  102f7a:	8b 00                	mov    (%eax),%eax
  102f7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  102f86:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  102f8d:	eb 1f                	jmp    102fae <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  102f8f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f92:	89 44 24 04          	mov    %eax,0x4(%esp)
  102f96:	8d 45 14             	lea    0x14(%ebp),%eax
  102f99:	89 04 24             	mov    %eax,(%esp)
  102f9c:	e8 df fb ff ff       	call   102b80 <getuint>
  102fa1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102fa4:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  102fa7:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  102fae:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  102fb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102fb5:	89 54 24 18          	mov    %edx,0x18(%esp)
  102fb9:	8b 55 e8             	mov    -0x18(%ebp),%edx
  102fbc:	89 54 24 14          	mov    %edx,0x14(%esp)
  102fc0:	89 44 24 10          	mov    %eax,0x10(%esp)
  102fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102fc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102fca:	89 44 24 08          	mov    %eax,0x8(%esp)
  102fce:	89 54 24 0c          	mov    %edx,0xc(%esp)
  102fd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  102fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  102fdc:	89 04 24             	mov    %eax,(%esp)
  102fdf:	e8 97 fa ff ff       	call   102a7b <printnum>
            break;
  102fe4:	eb 3c                	jmp    103022 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  102fe6:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fe9:	89 44 24 04          	mov    %eax,0x4(%esp)
  102fed:	89 1c 24             	mov    %ebx,(%esp)
  102ff0:	8b 45 08             	mov    0x8(%ebp),%eax
  102ff3:	ff d0                	call   *%eax
            break;
  102ff5:	eb 2b                	jmp    103022 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  102ff7:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ffa:	89 44 24 04          	mov    %eax,0x4(%esp)
  102ffe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  103005:	8b 45 08             	mov    0x8(%ebp),%eax
  103008:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  10300a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10300e:	eb 04                	jmp    103014 <vprintfmt+0x3d0>
  103010:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  103014:	8b 45 10             	mov    0x10(%ebp),%eax
  103017:	83 e8 01             	sub    $0x1,%eax
  10301a:	0f b6 00             	movzbl (%eax),%eax
  10301d:	3c 25                	cmp    $0x25,%al
  10301f:	75 ef                	jne    103010 <vprintfmt+0x3cc>
                /* do nothing */;
            break;
  103021:	90                   	nop
        }
    }
  103022:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  103023:	e9 3e fc ff ff       	jmp    102c66 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  103028:	83 c4 40             	add    $0x40,%esp
  10302b:	5b                   	pop    %ebx
  10302c:	5e                   	pop    %esi
  10302d:	5d                   	pop    %ebp
  10302e:	c3                   	ret    

0010302f <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  10302f:	55                   	push   %ebp
  103030:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  103032:	8b 45 0c             	mov    0xc(%ebp),%eax
  103035:	8b 40 08             	mov    0x8(%eax),%eax
  103038:	8d 50 01             	lea    0x1(%eax),%edx
  10303b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10303e:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  103041:	8b 45 0c             	mov    0xc(%ebp),%eax
  103044:	8b 10                	mov    (%eax),%edx
  103046:	8b 45 0c             	mov    0xc(%ebp),%eax
  103049:	8b 40 04             	mov    0x4(%eax),%eax
  10304c:	39 c2                	cmp    %eax,%edx
  10304e:	73 12                	jae    103062 <sprintputch+0x33>
        *b->buf ++ = ch;
  103050:	8b 45 0c             	mov    0xc(%ebp),%eax
  103053:	8b 00                	mov    (%eax),%eax
  103055:	8d 48 01             	lea    0x1(%eax),%ecx
  103058:	8b 55 0c             	mov    0xc(%ebp),%edx
  10305b:	89 0a                	mov    %ecx,(%edx)
  10305d:	8b 55 08             	mov    0x8(%ebp),%edx
  103060:	88 10                	mov    %dl,(%eax)
    }
}
  103062:	5d                   	pop    %ebp
  103063:	c3                   	ret    

00103064 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  103064:	55                   	push   %ebp
  103065:	89 e5                	mov    %esp,%ebp
  103067:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10306a:	8d 45 14             	lea    0x14(%ebp),%eax
  10306d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  103070:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103073:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103077:	8b 45 10             	mov    0x10(%ebp),%eax
  10307a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10307e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103081:	89 44 24 04          	mov    %eax,0x4(%esp)
  103085:	8b 45 08             	mov    0x8(%ebp),%eax
  103088:	89 04 24             	mov    %eax,(%esp)
  10308b:	e8 08 00 00 00       	call   103098 <vsnprintf>
  103090:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  103093:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103096:	c9                   	leave  
  103097:	c3                   	ret    

00103098 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  103098:	55                   	push   %ebp
  103099:	89 e5                	mov    %esp,%ebp
  10309b:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  10309e:	8b 45 08             	mov    0x8(%ebp),%eax
  1030a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1030a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030a7:	8d 50 ff             	lea    -0x1(%eax),%edx
  1030aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1030ad:	01 d0                	add    %edx,%eax
  1030af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1030b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  1030b9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1030bd:	74 0a                	je     1030c9 <vsnprintf+0x31>
  1030bf:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1030c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030c5:	39 c2                	cmp    %eax,%edx
  1030c7:	76 07                	jbe    1030d0 <vsnprintf+0x38>
        return -E_INVAL;
  1030c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  1030ce:	eb 2a                	jmp    1030fa <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  1030d0:	8b 45 14             	mov    0x14(%ebp),%eax
  1030d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1030d7:	8b 45 10             	mov    0x10(%ebp),%eax
  1030da:	89 44 24 08          	mov    %eax,0x8(%esp)
  1030de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  1030e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030e5:	c7 04 24 2f 30 10 00 	movl   $0x10302f,(%esp)
  1030ec:	e8 53 fb ff ff       	call   102c44 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  1030f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030f4:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  1030f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1030fa:	c9                   	leave  
  1030fb:	c3                   	ret    

001030fc <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  1030fc:	55                   	push   %ebp
  1030fd:	89 e5                	mov    %esp,%ebp
  1030ff:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  103102:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  103109:	eb 04                	jmp    10310f <strlen+0x13>
        cnt ++;
  10310b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  10310f:	8b 45 08             	mov    0x8(%ebp),%eax
  103112:	8d 50 01             	lea    0x1(%eax),%edx
  103115:	89 55 08             	mov    %edx,0x8(%ebp)
  103118:	0f b6 00             	movzbl (%eax),%eax
  10311b:	84 c0                	test   %al,%al
  10311d:	75 ec                	jne    10310b <strlen+0xf>
        cnt ++;
    }
    return cnt;
  10311f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  103122:	c9                   	leave  
  103123:	c3                   	ret    

00103124 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  103124:	55                   	push   %ebp
  103125:	89 e5                	mov    %esp,%ebp
  103127:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  10312a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  103131:	eb 04                	jmp    103137 <strnlen+0x13>
        cnt ++;
  103133:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  103137:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10313a:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10313d:	73 10                	jae    10314f <strnlen+0x2b>
  10313f:	8b 45 08             	mov    0x8(%ebp),%eax
  103142:	8d 50 01             	lea    0x1(%eax),%edx
  103145:	89 55 08             	mov    %edx,0x8(%ebp)
  103148:	0f b6 00             	movzbl (%eax),%eax
  10314b:	84 c0                	test   %al,%al
  10314d:	75 e4                	jne    103133 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  10314f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  103152:	c9                   	leave  
  103153:	c3                   	ret    

00103154 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  103154:	55                   	push   %ebp
  103155:	89 e5                	mov    %esp,%ebp
  103157:	57                   	push   %edi
  103158:	56                   	push   %esi
  103159:	83 ec 20             	sub    $0x20,%esp
  10315c:	8b 45 08             	mov    0x8(%ebp),%eax
  10315f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103162:	8b 45 0c             	mov    0xc(%ebp),%eax
  103165:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  103168:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10316b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10316e:	89 d1                	mov    %edx,%ecx
  103170:	89 c2                	mov    %eax,%edx
  103172:	89 ce                	mov    %ecx,%esi
  103174:	89 d7                	mov    %edx,%edi
  103176:	ac                   	lods   %ds:(%esi),%al
  103177:	aa                   	stos   %al,%es:(%edi)
  103178:	84 c0                	test   %al,%al
  10317a:	75 fa                	jne    103176 <strcpy+0x22>
  10317c:	89 fa                	mov    %edi,%edx
  10317e:	89 f1                	mov    %esi,%ecx
  103180:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  103183:	89 55 e8             	mov    %edx,-0x18(%ebp)
  103186:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  103189:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  10318c:	83 c4 20             	add    $0x20,%esp
  10318f:	5e                   	pop    %esi
  103190:	5f                   	pop    %edi
  103191:	5d                   	pop    %ebp
  103192:	c3                   	ret    

00103193 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  103193:	55                   	push   %ebp
  103194:	89 e5                	mov    %esp,%ebp
  103196:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  103199:	8b 45 08             	mov    0x8(%ebp),%eax
  10319c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  10319f:	eb 21                	jmp    1031c2 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
  1031a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031a4:	0f b6 10             	movzbl (%eax),%edx
  1031a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1031aa:	88 10                	mov    %dl,(%eax)
  1031ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1031af:	0f b6 00             	movzbl (%eax),%eax
  1031b2:	84 c0                	test   %al,%al
  1031b4:	74 04                	je     1031ba <strncpy+0x27>
            src ++;
  1031b6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
  1031ba:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  1031be:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  1031c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1031c6:	75 d9                	jne    1031a1 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  1031c8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1031cb:	c9                   	leave  
  1031cc:	c3                   	ret    

001031cd <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  1031cd:	55                   	push   %ebp
  1031ce:	89 e5                	mov    %esp,%ebp
  1031d0:	57                   	push   %edi
  1031d1:	56                   	push   %esi
  1031d2:	83 ec 20             	sub    $0x20,%esp
  1031d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1031d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1031db:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031de:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  1031e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1031e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031e7:	89 d1                	mov    %edx,%ecx
  1031e9:	89 c2                	mov    %eax,%edx
  1031eb:	89 ce                	mov    %ecx,%esi
  1031ed:	89 d7                	mov    %edx,%edi
  1031ef:	ac                   	lods   %ds:(%esi),%al
  1031f0:	ae                   	scas   %es:(%edi),%al
  1031f1:	75 08                	jne    1031fb <strcmp+0x2e>
  1031f3:	84 c0                	test   %al,%al
  1031f5:	75 f8                	jne    1031ef <strcmp+0x22>
  1031f7:	31 c0                	xor    %eax,%eax
  1031f9:	eb 04                	jmp    1031ff <strcmp+0x32>
  1031fb:	19 c0                	sbb    %eax,%eax
  1031fd:	0c 01                	or     $0x1,%al
  1031ff:	89 fa                	mov    %edi,%edx
  103201:	89 f1                	mov    %esi,%ecx
  103203:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103206:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  103209:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            "orb $1, %%al;"
            "3:"
            : "=a" (ret), "=&S" (d0), "=&D" (d1)
            : "1" (s1), "2" (s2)
            : "memory");
    return ret;
  10320c:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  10320f:	83 c4 20             	add    $0x20,%esp
  103212:	5e                   	pop    %esi
  103213:	5f                   	pop    %edi
  103214:	5d                   	pop    %ebp
  103215:	c3                   	ret    

00103216 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  103216:	55                   	push   %ebp
  103217:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  103219:	eb 0c                	jmp    103227 <strncmp+0x11>
        n --, s1 ++, s2 ++;
  10321b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  10321f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  103223:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  103227:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10322b:	74 1a                	je     103247 <strncmp+0x31>
  10322d:	8b 45 08             	mov    0x8(%ebp),%eax
  103230:	0f b6 00             	movzbl (%eax),%eax
  103233:	84 c0                	test   %al,%al
  103235:	74 10                	je     103247 <strncmp+0x31>
  103237:	8b 45 08             	mov    0x8(%ebp),%eax
  10323a:	0f b6 10             	movzbl (%eax),%edx
  10323d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103240:	0f b6 00             	movzbl (%eax),%eax
  103243:	38 c2                	cmp    %al,%dl
  103245:	74 d4                	je     10321b <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  103247:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10324b:	74 18                	je     103265 <strncmp+0x4f>
  10324d:	8b 45 08             	mov    0x8(%ebp),%eax
  103250:	0f b6 00             	movzbl (%eax),%eax
  103253:	0f b6 d0             	movzbl %al,%edx
  103256:	8b 45 0c             	mov    0xc(%ebp),%eax
  103259:	0f b6 00             	movzbl (%eax),%eax
  10325c:	0f b6 c0             	movzbl %al,%eax
  10325f:	29 c2                	sub    %eax,%edx
  103261:	89 d0                	mov    %edx,%eax
  103263:	eb 05                	jmp    10326a <strncmp+0x54>
  103265:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10326a:	5d                   	pop    %ebp
  10326b:	c3                   	ret    

0010326c <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  10326c:	55                   	push   %ebp
  10326d:	89 e5                	mov    %esp,%ebp
  10326f:	83 ec 04             	sub    $0x4,%esp
  103272:	8b 45 0c             	mov    0xc(%ebp),%eax
  103275:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  103278:	eb 14                	jmp    10328e <strchr+0x22>
        if (*s == c) {
  10327a:	8b 45 08             	mov    0x8(%ebp),%eax
  10327d:	0f b6 00             	movzbl (%eax),%eax
  103280:	3a 45 fc             	cmp    -0x4(%ebp),%al
  103283:	75 05                	jne    10328a <strchr+0x1e>
            return (char *)s;
  103285:	8b 45 08             	mov    0x8(%ebp),%eax
  103288:	eb 13                	jmp    10329d <strchr+0x31>
        }
        s ++;
  10328a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  10328e:	8b 45 08             	mov    0x8(%ebp),%eax
  103291:	0f b6 00             	movzbl (%eax),%eax
  103294:	84 c0                	test   %al,%al
  103296:	75 e2                	jne    10327a <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  103298:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10329d:	c9                   	leave  
  10329e:	c3                   	ret    

0010329f <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  10329f:	55                   	push   %ebp
  1032a0:	89 e5                	mov    %esp,%ebp
  1032a2:	83 ec 04             	sub    $0x4,%esp
  1032a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032a8:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1032ab:	eb 11                	jmp    1032be <strfind+0x1f>
        if (*s == c) {
  1032ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1032b0:	0f b6 00             	movzbl (%eax),%eax
  1032b3:	3a 45 fc             	cmp    -0x4(%ebp),%al
  1032b6:	75 02                	jne    1032ba <strfind+0x1b>
            break;
  1032b8:	eb 0e                	jmp    1032c8 <strfind+0x29>
        }
        s ++;
  1032ba:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  1032be:	8b 45 08             	mov    0x8(%ebp),%eax
  1032c1:	0f b6 00             	movzbl (%eax),%eax
  1032c4:	84 c0                	test   %al,%al
  1032c6:	75 e5                	jne    1032ad <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
  1032c8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  1032cb:	c9                   	leave  
  1032cc:	c3                   	ret    

001032cd <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  1032cd:	55                   	push   %ebp
  1032ce:	89 e5                	mov    %esp,%ebp
  1032d0:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  1032d3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  1032da:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1032e1:	eb 04                	jmp    1032e7 <strtol+0x1a>
        s ++;
  1032e3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  1032e7:	8b 45 08             	mov    0x8(%ebp),%eax
  1032ea:	0f b6 00             	movzbl (%eax),%eax
  1032ed:	3c 20                	cmp    $0x20,%al
  1032ef:	74 f2                	je     1032e3 <strtol+0x16>
  1032f1:	8b 45 08             	mov    0x8(%ebp),%eax
  1032f4:	0f b6 00             	movzbl (%eax),%eax
  1032f7:	3c 09                	cmp    $0x9,%al
  1032f9:	74 e8                	je     1032e3 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  1032fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1032fe:	0f b6 00             	movzbl (%eax),%eax
  103301:	3c 2b                	cmp    $0x2b,%al
  103303:	75 06                	jne    10330b <strtol+0x3e>
        s ++;
  103305:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  103309:	eb 15                	jmp    103320 <strtol+0x53>
    }
    else if (*s == '-') {
  10330b:	8b 45 08             	mov    0x8(%ebp),%eax
  10330e:	0f b6 00             	movzbl (%eax),%eax
  103311:	3c 2d                	cmp    $0x2d,%al
  103313:	75 0b                	jne    103320 <strtol+0x53>
        s ++, neg = 1;
  103315:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  103319:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  103320:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103324:	74 06                	je     10332c <strtol+0x5f>
  103326:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  10332a:	75 24                	jne    103350 <strtol+0x83>
  10332c:	8b 45 08             	mov    0x8(%ebp),%eax
  10332f:	0f b6 00             	movzbl (%eax),%eax
  103332:	3c 30                	cmp    $0x30,%al
  103334:	75 1a                	jne    103350 <strtol+0x83>
  103336:	8b 45 08             	mov    0x8(%ebp),%eax
  103339:	83 c0 01             	add    $0x1,%eax
  10333c:	0f b6 00             	movzbl (%eax),%eax
  10333f:	3c 78                	cmp    $0x78,%al
  103341:	75 0d                	jne    103350 <strtol+0x83>
        s += 2, base = 16;
  103343:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  103347:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  10334e:	eb 2a                	jmp    10337a <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
  103350:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103354:	75 17                	jne    10336d <strtol+0xa0>
  103356:	8b 45 08             	mov    0x8(%ebp),%eax
  103359:	0f b6 00             	movzbl (%eax),%eax
  10335c:	3c 30                	cmp    $0x30,%al
  10335e:	75 0d                	jne    10336d <strtol+0xa0>
        s ++, base = 8;
  103360:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  103364:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  10336b:	eb 0d                	jmp    10337a <strtol+0xad>
    }
    else if (base == 0) {
  10336d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103371:	75 07                	jne    10337a <strtol+0xad>
        base = 10;
  103373:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  10337a:	8b 45 08             	mov    0x8(%ebp),%eax
  10337d:	0f b6 00             	movzbl (%eax),%eax
  103380:	3c 2f                	cmp    $0x2f,%al
  103382:	7e 1b                	jle    10339f <strtol+0xd2>
  103384:	8b 45 08             	mov    0x8(%ebp),%eax
  103387:	0f b6 00             	movzbl (%eax),%eax
  10338a:	3c 39                	cmp    $0x39,%al
  10338c:	7f 11                	jg     10339f <strtol+0xd2>
            dig = *s - '0';
  10338e:	8b 45 08             	mov    0x8(%ebp),%eax
  103391:	0f b6 00             	movzbl (%eax),%eax
  103394:	0f be c0             	movsbl %al,%eax
  103397:	83 e8 30             	sub    $0x30,%eax
  10339a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10339d:	eb 48                	jmp    1033e7 <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
  10339f:	8b 45 08             	mov    0x8(%ebp),%eax
  1033a2:	0f b6 00             	movzbl (%eax),%eax
  1033a5:	3c 60                	cmp    $0x60,%al
  1033a7:	7e 1b                	jle    1033c4 <strtol+0xf7>
  1033a9:	8b 45 08             	mov    0x8(%ebp),%eax
  1033ac:	0f b6 00             	movzbl (%eax),%eax
  1033af:	3c 7a                	cmp    $0x7a,%al
  1033b1:	7f 11                	jg     1033c4 <strtol+0xf7>
            dig = *s - 'a' + 10;
  1033b3:	8b 45 08             	mov    0x8(%ebp),%eax
  1033b6:	0f b6 00             	movzbl (%eax),%eax
  1033b9:	0f be c0             	movsbl %al,%eax
  1033bc:	83 e8 57             	sub    $0x57,%eax
  1033bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1033c2:	eb 23                	jmp    1033e7 <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  1033c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1033c7:	0f b6 00             	movzbl (%eax),%eax
  1033ca:	3c 40                	cmp    $0x40,%al
  1033cc:	7e 3d                	jle    10340b <strtol+0x13e>
  1033ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1033d1:	0f b6 00             	movzbl (%eax),%eax
  1033d4:	3c 5a                	cmp    $0x5a,%al
  1033d6:	7f 33                	jg     10340b <strtol+0x13e>
            dig = *s - 'A' + 10;
  1033d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1033db:	0f b6 00             	movzbl (%eax),%eax
  1033de:	0f be c0             	movsbl %al,%eax
  1033e1:	83 e8 37             	sub    $0x37,%eax
  1033e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  1033e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033ea:	3b 45 10             	cmp    0x10(%ebp),%eax
  1033ed:	7c 02                	jl     1033f1 <strtol+0x124>
            break;
  1033ef:	eb 1a                	jmp    10340b <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
  1033f1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  1033f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1033f8:	0f af 45 10          	imul   0x10(%ebp),%eax
  1033fc:	89 c2                	mov    %eax,%edx
  1033fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103401:	01 d0                	add    %edx,%eax
  103403:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  103406:	e9 6f ff ff ff       	jmp    10337a <strtol+0xad>

    if (endptr) {
  10340b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10340f:	74 08                	je     103419 <strtol+0x14c>
        *endptr = (char *) s;
  103411:	8b 45 0c             	mov    0xc(%ebp),%eax
  103414:	8b 55 08             	mov    0x8(%ebp),%edx
  103417:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  103419:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  10341d:	74 07                	je     103426 <strtol+0x159>
  10341f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103422:	f7 d8                	neg    %eax
  103424:	eb 03                	jmp    103429 <strtol+0x15c>
  103426:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  103429:	c9                   	leave  
  10342a:	c3                   	ret    

0010342b <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  10342b:	55                   	push   %ebp
  10342c:	89 e5                	mov    %esp,%ebp
  10342e:	57                   	push   %edi
  10342f:	83 ec 24             	sub    $0x24,%esp
  103432:	8b 45 0c             	mov    0xc(%ebp),%eax
  103435:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  103438:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  10343c:	8b 55 08             	mov    0x8(%ebp),%edx
  10343f:	89 55 f8             	mov    %edx,-0x8(%ebp)
  103442:	88 45 f7             	mov    %al,-0x9(%ebp)
  103445:	8b 45 10             	mov    0x10(%ebp),%eax
  103448:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  10344b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  10344e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  103452:	8b 55 f8             	mov    -0x8(%ebp),%edx
  103455:	89 d7                	mov    %edx,%edi
  103457:	f3 aa                	rep stos %al,%es:(%edi)
  103459:	89 fa                	mov    %edi,%edx
  10345b:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10345e:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  103461:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  103464:	83 c4 24             	add    $0x24,%esp
  103467:	5f                   	pop    %edi
  103468:	5d                   	pop    %ebp
  103469:	c3                   	ret    

0010346a <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  10346a:	55                   	push   %ebp
  10346b:	89 e5                	mov    %esp,%ebp
  10346d:	57                   	push   %edi
  10346e:	56                   	push   %esi
  10346f:	53                   	push   %ebx
  103470:	83 ec 30             	sub    $0x30,%esp
  103473:	8b 45 08             	mov    0x8(%ebp),%eax
  103476:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103479:	8b 45 0c             	mov    0xc(%ebp),%eax
  10347c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10347f:	8b 45 10             	mov    0x10(%ebp),%eax
  103482:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  103485:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103488:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10348b:	73 42                	jae    1034cf <memmove+0x65>
  10348d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103490:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103493:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103496:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103499:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10349c:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10349f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1034a2:	c1 e8 02             	shr    $0x2,%eax
  1034a5:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  1034a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1034aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1034ad:	89 d7                	mov    %edx,%edi
  1034af:	89 c6                	mov    %eax,%esi
  1034b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1034b3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1034b6:	83 e1 03             	and    $0x3,%ecx
  1034b9:	74 02                	je     1034bd <memmove+0x53>
  1034bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1034bd:	89 f0                	mov    %esi,%eax
  1034bf:	89 fa                	mov    %edi,%edx
  1034c1:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  1034c4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1034c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  1034ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1034cd:	eb 36                	jmp    103505 <memmove+0x9b>
    asm volatile (
            "std;"
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  1034cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1034d2:	8d 50 ff             	lea    -0x1(%eax),%edx
  1034d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1034d8:	01 c2                	add    %eax,%edx
  1034da:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1034dd:	8d 48 ff             	lea    -0x1(%eax),%ecx
  1034e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034e3:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  1034e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1034e9:	89 c1                	mov    %eax,%ecx
  1034eb:	89 d8                	mov    %ebx,%eax
  1034ed:	89 d6                	mov    %edx,%esi
  1034ef:	89 c7                	mov    %eax,%edi
  1034f1:	fd                   	std    
  1034f2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1034f4:	fc                   	cld    
  1034f5:	89 f8                	mov    %edi,%eax
  1034f7:	89 f2                	mov    %esi,%edx
  1034f9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  1034fc:	89 55 c8             	mov    %edx,-0x38(%ebp)
  1034ff:	89 45 c4             	mov    %eax,-0x3c(%ebp)
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
            : "memory");
    return dst;
  103502:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  103505:	83 c4 30             	add    $0x30,%esp
  103508:	5b                   	pop    %ebx
  103509:	5e                   	pop    %esi
  10350a:	5f                   	pop    %edi
  10350b:	5d                   	pop    %ebp
  10350c:	c3                   	ret    

0010350d <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  10350d:	55                   	push   %ebp
  10350e:	89 e5                	mov    %esp,%ebp
  103510:	57                   	push   %edi
  103511:	56                   	push   %esi
  103512:	83 ec 20             	sub    $0x20,%esp
  103515:	8b 45 08             	mov    0x8(%ebp),%eax
  103518:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10351b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10351e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103521:	8b 45 10             	mov    0x10(%ebp),%eax
  103524:	89 45 ec             	mov    %eax,-0x14(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  103527:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10352a:	c1 e8 02             	shr    $0x2,%eax
  10352d:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  10352f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103532:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103535:	89 d7                	mov    %edx,%edi
  103537:	89 c6                	mov    %eax,%esi
  103539:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  10353b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  10353e:	83 e1 03             	and    $0x3,%ecx
  103541:	74 02                	je     103545 <memcpy+0x38>
  103543:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  103545:	89 f0                	mov    %esi,%eax
  103547:	89 fa                	mov    %edi,%edx
  103549:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  10354c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  10354f:	89 45 e0             	mov    %eax,-0x20(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  103552:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  103555:	83 c4 20             	add    $0x20,%esp
  103558:	5e                   	pop    %esi
  103559:	5f                   	pop    %edi
  10355a:	5d                   	pop    %ebp
  10355b:	c3                   	ret    

0010355c <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  10355c:	55                   	push   %ebp
  10355d:	89 e5                	mov    %esp,%ebp
  10355f:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  103562:	8b 45 08             	mov    0x8(%ebp),%eax
  103565:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  103568:	8b 45 0c             	mov    0xc(%ebp),%eax
  10356b:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  10356e:	eb 30                	jmp    1035a0 <memcmp+0x44>
        if (*s1 != *s2) {
  103570:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103573:	0f b6 10             	movzbl (%eax),%edx
  103576:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103579:	0f b6 00             	movzbl (%eax),%eax
  10357c:	38 c2                	cmp    %al,%dl
  10357e:	74 18                	je     103598 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  103580:	8b 45 fc             	mov    -0x4(%ebp),%eax
  103583:	0f b6 00             	movzbl (%eax),%eax
  103586:	0f b6 d0             	movzbl %al,%edx
  103589:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10358c:	0f b6 00             	movzbl (%eax),%eax
  10358f:	0f b6 c0             	movzbl %al,%eax
  103592:	29 c2                	sub    %eax,%edx
  103594:	89 d0                	mov    %edx,%eax
  103596:	eb 1a                	jmp    1035b2 <memcmp+0x56>
        }
        s1 ++, s2 ++;
  103598:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  10359c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  1035a0:	8b 45 10             	mov    0x10(%ebp),%eax
  1035a3:	8d 50 ff             	lea    -0x1(%eax),%edx
  1035a6:	89 55 10             	mov    %edx,0x10(%ebp)
  1035a9:	85 c0                	test   %eax,%eax
  1035ab:	75 c3                	jne    103570 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  1035ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1035b2:	c9                   	leave  
  1035b3:	c3                   	ret    
