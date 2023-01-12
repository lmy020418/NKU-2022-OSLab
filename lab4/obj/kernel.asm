
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 90 12 00       	mov    $0x129000,%eax
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
c0100020:	a3 00 90 12 c0       	mov    %eax,0xc0129000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 80 12 c0       	mov    $0xc0128000,%esp
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
c010003c:	ba 78 e1 12 c0       	mov    $0xc012e178,%edx
c0100041:	b8 00 b0 12 c0       	mov    $0xc012b000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 b0 12 c0 	movl   $0xc012b000,(%esp)
c010005d:	e8 cf b1 00 00       	call   c010b231 <memset>

    cons_init();                // init the console
c0100062:	e8 1c 2a 00 00       	call   c0102a83 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 c0 b3 10 c0 	movl   $0xc010b3c0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 dc b3 10 c0 	movl   $0xc010b3dc,(%esp)
c010007c:	e8 61 17 00 00       	call   c01017e2 <cprintf>

    print_kerninfo();
c0100081:	e8 90 1c 00 00       	call   c0101d16 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 9d 00 00 00       	call   c0100128 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 c9 68 00 00       	call   c0106959 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 cc 33 00 00       	call   c0103461 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 44 35 00 00       	call   c01035de <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 e3 8f 00 00       	call   c0109082 <vmm_init>
    proc_init();                // init process table
c010009f:	e8 83 a3 00 00       	call   c010a427 <proc_init>
    
    ide_init();                 // init ide devices
c01000a4:	e8 0b 2b 00 00       	call   c0102bb4 <ide_init>
    swap_init();                // init swap
c01000a9:	e8 ed 7a 00 00       	call   c0107b9b <swap_init>

    clock_init();               // init clock interrupt
c01000ae:	e8 86 21 00 00       	call   c0102239 <clock_init>
    intr_enable();              // enable irq interrupt
c01000b3:	e8 17 33 00 00       	call   c01033cf <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
c01000b8:	e8 29 a5 00 00       	call   c010a5e6 <cpu_idle>

c01000bd <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000bd:	55                   	push   %ebp
c01000be:	89 e5                	mov    %esp,%ebp
c01000c0:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000ca:	00 
c01000cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000d2:	00 
c01000d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000da:	e8 7b 20 00 00       	call   c010215a <mon_backtrace>
}
c01000df:	c9                   	leave  
c01000e0:	c3                   	ret    

c01000e1 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000e1:	55                   	push   %ebp
c01000e2:	89 e5                	mov    %esp,%ebp
c01000e4:	53                   	push   %ebx
c01000e5:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e8:	8d 5d 0c             	lea    0xc(%ebp),%ebx
c01000eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c01000ee:	8d 55 08             	lea    0x8(%ebp),%edx
c01000f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01000f4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01000f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01000fc:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100100:	89 04 24             	mov    %eax,(%esp)
c0100103:	e8 b5 ff ff ff       	call   c01000bd <grade_backtrace2>
}
c0100108:	83 c4 14             	add    $0x14,%esp
c010010b:	5b                   	pop    %ebx
c010010c:	5d                   	pop    %ebp
c010010d:	c3                   	ret    

c010010e <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c010010e:	55                   	push   %ebp
c010010f:	89 e5                	mov    %esp,%ebp
c0100111:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100114:	8b 45 10             	mov    0x10(%ebp),%eax
c0100117:	89 44 24 04          	mov    %eax,0x4(%esp)
c010011b:	8b 45 08             	mov    0x8(%ebp),%eax
c010011e:	89 04 24             	mov    %eax,(%esp)
c0100121:	e8 bb ff ff ff       	call   c01000e1 <grade_backtrace1>
}
c0100126:	c9                   	leave  
c0100127:	c3                   	ret    

c0100128 <grade_backtrace>:

void
grade_backtrace(void) {
c0100128:	55                   	push   %ebp
c0100129:	89 e5                	mov    %esp,%ebp
c010012b:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010012e:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100133:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010013a:	ff 
c010013b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010013f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100146:	e8 c3 ff ff ff       	call   c010010e <grade_backtrace0>
}
c010014b:	c9                   	leave  
c010014c:	c3                   	ret    

c010014d <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010014d:	55                   	push   %ebp
c010014e:	89 e5                	mov    %esp,%ebp
c0100150:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100153:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100156:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100159:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010015c:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010015f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100163:	0f b7 c0             	movzwl %ax,%eax
c0100166:	83 e0 03             	and    $0x3,%eax
c0100169:	89 c2                	mov    %eax,%edx
c010016b:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c0100170:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100174:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100178:	c7 04 24 e1 b3 10 c0 	movl   $0xc010b3e1,(%esp)
c010017f:	e8 5e 16 00 00       	call   c01017e2 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100184:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100188:	0f b7 d0             	movzwl %ax,%edx
c010018b:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c0100190:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100194:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100198:	c7 04 24 ef b3 10 c0 	movl   $0xc010b3ef,(%esp)
c010019f:	e8 3e 16 00 00       	call   c01017e2 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a4:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a8:	0f b7 d0             	movzwl %ax,%edx
c01001ab:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c01001b0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b8:	c7 04 24 fd b3 10 c0 	movl   $0xc010b3fd,(%esp)
c01001bf:	e8 1e 16 00 00       	call   c01017e2 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c4:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c8:	0f b7 d0             	movzwl %ax,%edx
c01001cb:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c01001d0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d8:	c7 04 24 0b b4 10 c0 	movl   $0xc010b40b,(%esp)
c01001df:	e8 fe 15 00 00       	call   c01017e2 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e4:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e8:	0f b7 d0             	movzwl %ax,%edx
c01001eb:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c01001f0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f8:	c7 04 24 19 b4 10 c0 	movl   $0xc010b419,(%esp)
c01001ff:	e8 de 15 00 00       	call   c01017e2 <cprintf>
    round ++;
c0100204:	a1 00 b0 12 c0       	mov    0xc012b000,%eax
c0100209:	83 c0 01             	add    $0x1,%eax
c010020c:	a3 00 b0 12 c0       	mov    %eax,0xc012b000
}
c0100211:	c9                   	leave  
c0100212:	c3                   	ret    

c0100213 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100213:	55                   	push   %ebp
c0100214:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100216:	5d                   	pop    %ebp
c0100217:	c3                   	ret    

c0100218 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100218:	55                   	push   %ebp
c0100219:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c010021b:	5d                   	pop    %ebp
c010021c:	c3                   	ret    

c010021d <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010021d:	55                   	push   %ebp
c010021e:	89 e5                	mov    %esp,%ebp
c0100220:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100223:	e8 25 ff ff ff       	call   c010014d <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100228:	c7 04 24 28 b4 10 c0 	movl   $0xc010b428,(%esp)
c010022f:	e8 ae 15 00 00       	call   c01017e2 <cprintf>
    lab1_switch_to_user();
c0100234:	e8 da ff ff ff       	call   c0100213 <lab1_switch_to_user>
    lab1_print_cur_status();
c0100239:	e8 0f ff ff ff       	call   c010014d <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010023e:	c7 04 24 48 b4 10 c0 	movl   $0xc010b448,(%esp)
c0100245:	e8 98 15 00 00       	call   c01017e2 <cprintf>
    lab1_switch_to_kernel();
c010024a:	e8 c9 ff ff ff       	call   c0100218 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010024f:	e8 f9 fe ff ff       	call   c010014d <lab1_print_cur_status>
}
c0100254:	c9                   	leave  
c0100255:	c3                   	ret    

c0100256 <rb_node_create>:
#include <rb_tree.h>
#include <assert.h>

/* rb_node_create - create a new rb_node */
static inline rb_node *
rb_node_create(void) {
c0100256:	55                   	push   %ebp
c0100257:	89 e5                	mov    %esp,%ebp
c0100259:	83 ec 18             	sub    $0x18,%esp
    return kmalloc(sizeof(rb_node));
c010025c:	c7 04 24 10 00 00 00 	movl   $0x10,(%esp)
c0100263:	e8 62 5c 00 00       	call   c0105eca <kmalloc>
}
c0100268:	c9                   	leave  
c0100269:	c3                   	ret    

c010026a <rb_tree_empty>:

/* rb_tree_empty - tests if tree is empty */
static inline bool
rb_tree_empty(rb_tree *tree) {
c010026a:	55                   	push   %ebp
c010026b:	89 e5                	mov    %esp,%ebp
c010026d:	83 ec 10             	sub    $0x10,%esp
    rb_node *nil = tree->nil, *root = tree->root;
c0100270:	8b 45 08             	mov    0x8(%ebp),%eax
c0100273:	8b 40 04             	mov    0x4(%eax),%eax
c0100276:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100279:	8b 45 08             	mov    0x8(%ebp),%eax
c010027c:	8b 40 08             	mov    0x8(%eax),%eax
c010027f:	89 45 f8             	mov    %eax,-0x8(%ebp)
    return root->left == nil;
c0100282:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100285:	8b 40 08             	mov    0x8(%eax),%eax
c0100288:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010028b:	0f 94 c0             	sete   %al
c010028e:	0f b6 c0             	movzbl %al,%eax
}
c0100291:	c9                   	leave  
c0100292:	c3                   	ret    

c0100293 <rb_tree_create>:
 * Note that, root->left should always point to the node that is the root
 * of the tree. And nil points to a 'NULL' node which should always be
 * black and may have arbitrary children and parent node.
 * */
rb_tree *
rb_tree_create(int (*compare)(rb_node *node1, rb_node *node2)) {
c0100293:	55                   	push   %ebp
c0100294:	89 e5                	mov    %esp,%ebp
c0100296:	83 ec 28             	sub    $0x28,%esp
    assert(compare != NULL);
c0100299:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010029d:	75 24                	jne    c01002c3 <rb_tree_create+0x30>
c010029f:	c7 44 24 0c 68 b4 10 	movl   $0xc010b468,0xc(%esp)
c01002a6:	c0 
c01002a7:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c01002ae:	c0 
c01002af:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
c01002b6:	00 
c01002b7:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c01002be:	e8 a9 1e 00 00       	call   c010216c <__panic>

    rb_tree *tree;
    rb_node *nil, *root;

    if ((tree = kmalloc(sizeof(rb_tree))) == NULL) {
c01002c3:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c01002ca:	e8 fb 5b 00 00       	call   c0105eca <kmalloc>
c01002cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01002d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002d6:	75 05                	jne    c01002dd <rb_tree_create+0x4a>
        goto bad_tree;
c01002d8:	e9 ad 00 00 00       	jmp    c010038a <rb_tree_create+0xf7>
    }

    tree->compare = compare;
c01002dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002e0:	8b 55 08             	mov    0x8(%ebp),%edx
c01002e3:	89 10                	mov    %edx,(%eax)

    if ((nil = rb_node_create()) == NULL) {
c01002e5:	e8 6c ff ff ff       	call   c0100256 <rb_node_create>
c01002ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01002ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01002f1:	75 05                	jne    c01002f8 <rb_tree_create+0x65>
        goto bad_node_cleanup_tree;
c01002f3:	e9 87 00 00 00       	jmp    c010037f <rb_tree_create+0xec>
    }

    nil->parent = nil->left = nil->right = nil;
c01002f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002fe:	89 50 0c             	mov    %edx,0xc(%eax)
c0100301:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100304:	8b 50 0c             	mov    0xc(%eax),%edx
c0100307:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010030a:	89 50 08             	mov    %edx,0x8(%eax)
c010030d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100310:	8b 50 08             	mov    0x8(%eax),%edx
c0100313:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100316:	89 50 04             	mov    %edx,0x4(%eax)
    nil->red = 0;
c0100319:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010031c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tree->nil = nil;
c0100322:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100325:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100328:	89 50 04             	mov    %edx,0x4(%eax)

    if ((root = rb_node_create()) == NULL) {
c010032b:	e8 26 ff ff ff       	call   c0100256 <rb_node_create>
c0100330:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100333:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0100337:	75 0e                	jne    c0100347 <rb_tree_create+0xb4>
        goto bad_node_cleanup_nil;
c0100339:	90                   	nop
    root->red = 0;
    tree->root = root;
    return tree;

bad_node_cleanup_nil:
    kfree(nil);
c010033a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010033d:	89 04 24             	mov    %eax,(%esp)
c0100340:	e8 a0 5b 00 00       	call   c0105ee5 <kfree>
c0100345:	eb 38                	jmp    c010037f <rb_tree_create+0xec>

    if ((root = rb_node_create()) == NULL) {
        goto bad_node_cleanup_nil;
    }

    root->parent = root->left = root->right = nil;
c0100347:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010034a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010034d:	89 50 0c             	mov    %edx,0xc(%eax)
c0100350:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100353:	8b 50 0c             	mov    0xc(%eax),%edx
c0100356:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100359:	89 50 08             	mov    %edx,0x8(%eax)
c010035c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010035f:	8b 50 08             	mov    0x8(%eax),%edx
c0100362:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100365:	89 50 04             	mov    %edx,0x4(%eax)
    root->red = 0;
c0100368:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010036b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    tree->root = root;
c0100371:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100374:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100377:	89 50 08             	mov    %edx,0x8(%eax)
    return tree;
c010037a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010037d:	eb 10                	jmp    c010038f <rb_tree_create+0xfc>

bad_node_cleanup_nil:
    kfree(nil);
bad_node_cleanup_tree:
    kfree(tree);
c010037f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100382:	89 04 24             	mov    %eax,(%esp)
c0100385:	e8 5b 5b 00 00       	call   c0105ee5 <kfree>
bad_tree:
    return NULL;
c010038a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010038f:	c9                   	leave  
c0100390:	c3                   	ret    

c0100391 <rb_left_rotate>:
    y->_left = x;                                               \
    x->parent = y;                                              \
    assert(!(nil->red));                                        \
}

FUNC_ROTATE(rb_left_rotate, left, right);
c0100391:	55                   	push   %ebp
c0100392:	89 e5                	mov    %esp,%ebp
c0100394:	83 ec 28             	sub    $0x28,%esp
c0100397:	8b 45 08             	mov    0x8(%ebp),%eax
c010039a:	8b 40 04             	mov    0x4(%eax),%eax
c010039d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003a3:	8b 40 0c             	mov    0xc(%eax),%eax
c01003a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01003a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01003ac:	8b 40 08             	mov    0x8(%eax),%eax
c01003af:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01003b2:	74 10                	je     c01003c4 <rb_left_rotate+0x33>
c01003b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003b7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01003ba:	74 08                	je     c01003c4 <rb_left_rotate+0x33>
c01003bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003bf:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01003c2:	75 24                	jne    c01003e8 <rb_left_rotate+0x57>
c01003c4:	c7 44 24 0c a4 b4 10 	movl   $0xc010b4a4,0xc(%esp)
c01003cb:	c0 
c01003cc:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c01003d3:	c0 
c01003d4:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01003db:	00 
c01003dc:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c01003e3:	e8 84 1d 00 00       	call   c010216c <__panic>
c01003e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003eb:	8b 50 08             	mov    0x8(%eax),%edx
c01003ee:	8b 45 0c             	mov    0xc(%ebp),%eax
c01003f1:	89 50 0c             	mov    %edx,0xc(%eax)
c01003f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003f7:	8b 40 08             	mov    0x8(%eax),%eax
c01003fa:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01003fd:	74 0c                	je     c010040b <rb_left_rotate+0x7a>
c01003ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100402:	8b 40 08             	mov    0x8(%eax),%eax
c0100405:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100408:	89 50 04             	mov    %edx,0x4(%eax)
c010040b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010040e:	8b 50 04             	mov    0x4(%eax),%edx
c0100411:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100414:	89 50 04             	mov    %edx,0x4(%eax)
c0100417:	8b 45 0c             	mov    0xc(%ebp),%eax
c010041a:	8b 40 04             	mov    0x4(%eax),%eax
c010041d:	8b 40 08             	mov    0x8(%eax),%eax
c0100420:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0100423:	75 0e                	jne    c0100433 <rb_left_rotate+0xa2>
c0100425:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100428:	8b 40 04             	mov    0x4(%eax),%eax
c010042b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010042e:	89 50 08             	mov    %edx,0x8(%eax)
c0100431:	eb 0c                	jmp    c010043f <rb_left_rotate+0xae>
c0100433:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100436:	8b 40 04             	mov    0x4(%eax),%eax
c0100439:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010043c:	89 50 0c             	mov    %edx,0xc(%eax)
c010043f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100442:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100445:	89 50 08             	mov    %edx,0x8(%eax)
c0100448:	8b 45 0c             	mov    0xc(%ebp),%eax
c010044b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010044e:	89 50 04             	mov    %edx,0x4(%eax)
c0100451:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100454:	8b 00                	mov    (%eax),%eax
c0100456:	85 c0                	test   %eax,%eax
c0100458:	74 24                	je     c010047e <rb_left_rotate+0xed>
c010045a:	c7 44 24 0c cc b4 10 	movl   $0xc010b4cc,0xc(%esp)
c0100461:	c0 
c0100462:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0100469:	c0 
c010046a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0100471:	00 
c0100472:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c0100479:	e8 ee 1c 00 00       	call   c010216c <__panic>
c010047e:	c9                   	leave  
c010047f:	c3                   	ret    

c0100480 <rb_right_rotate>:
FUNC_ROTATE(rb_right_rotate, right, left);
c0100480:	55                   	push   %ebp
c0100481:	89 e5                	mov    %esp,%ebp
c0100483:	83 ec 28             	sub    $0x28,%esp
c0100486:	8b 45 08             	mov    0x8(%ebp),%eax
c0100489:	8b 40 04             	mov    0x4(%eax),%eax
c010048c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010048f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100492:	8b 40 08             	mov    0x8(%eax),%eax
c0100495:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100498:	8b 45 08             	mov    0x8(%ebp),%eax
c010049b:	8b 40 08             	mov    0x8(%eax),%eax
c010049e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01004a1:	74 10                	je     c01004b3 <rb_right_rotate+0x33>
c01004a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004a6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01004a9:	74 08                	je     c01004b3 <rb_right_rotate+0x33>
c01004ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004ae:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01004b1:	75 24                	jne    c01004d7 <rb_right_rotate+0x57>
c01004b3:	c7 44 24 0c a4 b4 10 	movl   $0xc010b4a4,0xc(%esp)
c01004ba:	c0 
c01004bb:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c01004c2:	c0 
c01004c3:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c01004ca:	00 
c01004cb:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c01004d2:	e8 95 1c 00 00       	call   c010216c <__panic>
c01004d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004da:	8b 50 0c             	mov    0xc(%eax),%edx
c01004dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004e0:	89 50 08             	mov    %edx,0x8(%eax)
c01004e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e6:	8b 40 0c             	mov    0xc(%eax),%eax
c01004e9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01004ec:	74 0c                	je     c01004fa <rb_right_rotate+0x7a>
c01004ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004f1:	8b 40 0c             	mov    0xc(%eax),%eax
c01004f4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01004f7:	89 50 04             	mov    %edx,0x4(%eax)
c01004fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004fd:	8b 50 04             	mov    0x4(%eax),%edx
c0100500:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100503:	89 50 04             	mov    %edx,0x4(%eax)
c0100506:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100509:	8b 40 04             	mov    0x4(%eax),%eax
c010050c:	8b 40 0c             	mov    0xc(%eax),%eax
c010050f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0100512:	75 0e                	jne    c0100522 <rb_right_rotate+0xa2>
c0100514:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100517:	8b 40 04             	mov    0x4(%eax),%eax
c010051a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010051d:	89 50 0c             	mov    %edx,0xc(%eax)
c0100520:	eb 0c                	jmp    c010052e <rb_right_rotate+0xae>
c0100522:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100525:	8b 40 04             	mov    0x4(%eax),%eax
c0100528:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010052b:	89 50 08             	mov    %edx,0x8(%eax)
c010052e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100531:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100534:	89 50 0c             	mov    %edx,0xc(%eax)
c0100537:	8b 45 0c             	mov    0xc(%ebp),%eax
c010053a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010053d:	89 50 04             	mov    %edx,0x4(%eax)
c0100540:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100543:	8b 00                	mov    (%eax),%eax
c0100545:	85 c0                	test   %eax,%eax
c0100547:	74 24                	je     c010056d <rb_right_rotate+0xed>
c0100549:	c7 44 24 0c cc b4 10 	movl   $0xc010b4cc,0xc(%esp)
c0100550:	c0 
c0100551:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0100558:	c0 
c0100559:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0100560:	00 
c0100561:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c0100568:	e8 ff 1b 00 00       	call   c010216c <__panic>
c010056d:	c9                   	leave  
c010056e:	c3                   	ret    

c010056f <rb_insert_binary>:
 * rb_insert_binary - insert @node to red-black @tree as if it were
 * a regular binary tree. This function is only intended to be called
 * by function rb_insert.
 * */
static inline void
rb_insert_binary(rb_tree *tree, rb_node *node) {
c010056f:	55                   	push   %ebp
c0100570:	89 e5                	mov    %esp,%ebp
c0100572:	83 ec 38             	sub    $0x38,%esp
    rb_node *x, *y, *z = node, *nil = tree->nil, *root = tree->root;
c0100575:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100578:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010057b:	8b 45 08             	mov    0x8(%ebp),%eax
c010057e:	8b 40 04             	mov    0x4(%eax),%eax
c0100581:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0100584:	8b 45 08             	mov    0x8(%ebp),%eax
c0100587:	8b 40 08             	mov    0x8(%eax),%eax
c010058a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    z->left = z->right = nil;
c010058d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100590:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100593:	89 50 0c             	mov    %edx,0xc(%eax)
c0100596:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100599:	8b 50 0c             	mov    0xc(%eax),%edx
c010059c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010059f:	89 50 08             	mov    %edx,0x8(%eax)
    y = root, x = y->left;
c01005a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01005a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01005a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005ab:	8b 40 08             	mov    0x8(%eax),%eax
c01005ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while (x != nil) {
c01005b1:	eb 2f                	jmp    c01005e2 <rb_insert_binary+0x73>
        y = x;
c01005b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
        x = (COMPARE(tree, x, node) > 0) ? x->left : x->right;
c01005b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01005bc:	8b 00                	mov    (%eax),%eax
c01005be:	8b 55 0c             	mov    0xc(%ebp),%edx
c01005c1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01005c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01005c8:	89 14 24             	mov    %edx,(%esp)
c01005cb:	ff d0                	call   *%eax
c01005cd:	85 c0                	test   %eax,%eax
c01005cf:	7e 08                	jle    c01005d9 <rb_insert_binary+0x6a>
c01005d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005d4:	8b 40 08             	mov    0x8(%eax),%eax
c01005d7:	eb 06                	jmp    c01005df <rb_insert_binary+0x70>
c01005d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005dc:	8b 40 0c             	mov    0xc(%eax),%eax
c01005df:	89 45 f4             	mov    %eax,-0xc(%ebp)
rb_insert_binary(rb_tree *tree, rb_node *node) {
    rb_node *x, *y, *z = node, *nil = tree->nil, *root = tree->root;

    z->left = z->right = nil;
    y = root, x = y->left;
    while (x != nil) {
c01005e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005e5:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c01005e8:	75 c9                	jne    c01005b3 <rb_insert_binary+0x44>
        y = x;
        x = (COMPARE(tree, x, node) > 0) ? x->left : x->right;
    }
    z->parent = y;
c01005ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01005ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005f0:	89 50 04             	mov    %edx,0x4(%eax)
    if (y == root || COMPARE(tree, y, z) > 0) {
c01005f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005f6:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
c01005f9:	74 18                	je     c0100613 <rb_insert_binary+0xa4>
c01005fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01005fe:	8b 00                	mov    (%eax),%eax
c0100600:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100603:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100607:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010060a:	89 14 24             	mov    %edx,(%esp)
c010060d:	ff d0                	call   *%eax
c010060f:	85 c0                	test   %eax,%eax
c0100611:	7e 0b                	jle    c010061e <rb_insert_binary+0xaf>
        y->left = z;
c0100613:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100616:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100619:	89 50 08             	mov    %edx,0x8(%eax)
c010061c:	eb 09                	jmp    c0100627 <rb_insert_binary+0xb8>
    }
    else {
        y->right = z;
c010061e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100621:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100624:	89 50 0c             	mov    %edx,0xc(%eax)
    }
}
c0100627:	c9                   	leave  
c0100628:	c3                   	ret    

c0100629 <rb_insert>:

/* rb_insert - insert a node to red-black tree */
void
rb_insert(rb_tree *tree, rb_node *node) {
c0100629:	55                   	push   %ebp
c010062a:	89 e5                	mov    %esp,%ebp
c010062c:	83 ec 28             	sub    $0x28,%esp
    rb_insert_binary(tree, node);
c010062f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100632:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100636:	8b 45 08             	mov    0x8(%ebp),%eax
c0100639:	89 04 24             	mov    %eax,(%esp)
c010063c:	e8 2e ff ff ff       	call   c010056f <rb_insert_binary>
    node->red = 1;
c0100641:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100644:	c7 00 01 00 00 00    	movl   $0x1,(%eax)

    rb_node *x = node, *y;
c010064a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010064d:	89 45 f4             	mov    %eax,-0xc(%ebp)
            x->parent->parent->red = 1;                         \
            rb_##_right##_rotate(tree, x->parent->parent);      \
        }                                                       \
    } while (0)

    while (x->parent->red) {
c0100650:	e9 6e 01 00 00       	jmp    c01007c3 <rb_insert+0x19a>
        if (x->parent == x->parent->parent->left) {
c0100655:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100658:	8b 50 04             	mov    0x4(%eax),%edx
c010065b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010065e:	8b 40 04             	mov    0x4(%eax),%eax
c0100661:	8b 40 04             	mov    0x4(%eax),%eax
c0100664:	8b 40 08             	mov    0x8(%eax),%eax
c0100667:	39 c2                	cmp    %eax,%edx
c0100669:	0f 85 ae 00 00 00    	jne    c010071d <rb_insert+0xf4>
            RB_INSERT_SUB(left, right);
c010066f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100672:	8b 40 04             	mov    0x4(%eax),%eax
c0100675:	8b 40 04             	mov    0x4(%eax),%eax
c0100678:	8b 40 0c             	mov    0xc(%eax),%eax
c010067b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010067e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100681:	8b 00                	mov    (%eax),%eax
c0100683:	85 c0                	test   %eax,%eax
c0100685:	74 35                	je     c01006bc <rb_insert+0x93>
c0100687:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010068a:	8b 40 04             	mov    0x4(%eax),%eax
c010068d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100693:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100696:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010069c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010069f:	8b 40 04             	mov    0x4(%eax),%eax
c01006a2:	8b 40 04             	mov    0x4(%eax),%eax
c01006a5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c01006ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006ae:	8b 40 04             	mov    0x4(%eax),%eax
c01006b1:	8b 40 04             	mov    0x4(%eax),%eax
c01006b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01006b7:	e9 07 01 00 00       	jmp    c01007c3 <rb_insert+0x19a>
c01006bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006bf:	8b 40 04             	mov    0x4(%eax),%eax
c01006c2:	8b 40 0c             	mov    0xc(%eax),%eax
c01006c5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01006c8:	75 1b                	jne    c01006e5 <rb_insert+0xbc>
c01006ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006cd:	8b 40 04             	mov    0x4(%eax),%eax
c01006d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01006d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006d6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006da:	8b 45 08             	mov    0x8(%ebp),%eax
c01006dd:	89 04 24             	mov    %eax,(%esp)
c01006e0:	e8 ac fc ff ff       	call   c0100391 <rb_left_rotate>
c01006e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006e8:	8b 40 04             	mov    0x4(%eax),%eax
c01006eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c01006f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006f4:	8b 40 04             	mov    0x4(%eax),%eax
c01006f7:	8b 40 04             	mov    0x4(%eax),%eax
c01006fa:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100700:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100703:	8b 40 04             	mov    0x4(%eax),%eax
c0100706:	8b 40 04             	mov    0x4(%eax),%eax
c0100709:	89 44 24 04          	mov    %eax,0x4(%esp)
c010070d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100710:	89 04 24             	mov    %eax,(%esp)
c0100713:	e8 68 fd ff ff       	call   c0100480 <rb_right_rotate>
c0100718:	e9 a6 00 00 00       	jmp    c01007c3 <rb_insert+0x19a>
        }
        else {
            RB_INSERT_SUB(right, left);
c010071d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100720:	8b 40 04             	mov    0x4(%eax),%eax
c0100723:	8b 40 04             	mov    0x4(%eax),%eax
c0100726:	8b 40 08             	mov    0x8(%eax),%eax
c0100729:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010072c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010072f:	8b 00                	mov    (%eax),%eax
c0100731:	85 c0                	test   %eax,%eax
c0100733:	74 32                	je     c0100767 <rb_insert+0x13e>
c0100735:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100738:	8b 40 04             	mov    0x4(%eax),%eax
c010073b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100741:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100744:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010074d:	8b 40 04             	mov    0x4(%eax),%eax
c0100750:	8b 40 04             	mov    0x4(%eax),%eax
c0100753:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100759:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075c:	8b 40 04             	mov    0x4(%eax),%eax
c010075f:	8b 40 04             	mov    0x4(%eax),%eax
c0100762:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100765:	eb 5c                	jmp    c01007c3 <rb_insert+0x19a>
c0100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010076a:	8b 40 04             	mov    0x4(%eax),%eax
c010076d:	8b 40 08             	mov    0x8(%eax),%eax
c0100770:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100773:	75 1b                	jne    c0100790 <rb_insert+0x167>
c0100775:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100778:	8b 40 04             	mov    0x4(%eax),%eax
c010077b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010077e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100781:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100785:	8b 45 08             	mov    0x8(%ebp),%eax
c0100788:	89 04 24             	mov    %eax,(%esp)
c010078b:	e8 f0 fc ff ff       	call   c0100480 <rb_right_rotate>
c0100790:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100793:	8b 40 04             	mov    0x4(%eax),%eax
c0100796:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c010079c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010079f:	8b 40 04             	mov    0x4(%eax),%eax
c01007a2:	8b 40 04             	mov    0x4(%eax),%eax
c01007a5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c01007ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ae:	8b 40 04             	mov    0x4(%eax),%eax
c01007b1:	8b 40 04             	mov    0x4(%eax),%eax
c01007b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01007bb:	89 04 24             	mov    %eax,(%esp)
c01007be:	e8 ce fb ff ff       	call   c0100391 <rb_left_rotate>
            x->parent->parent->red = 1;                         \
            rb_##_right##_rotate(tree, x->parent->parent);      \
        }                                                       \
    } while (0)

    while (x->parent->red) {
c01007c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c6:	8b 40 04             	mov    0x4(%eax),%eax
c01007c9:	8b 00                	mov    (%eax),%eax
c01007cb:	85 c0                	test   %eax,%eax
c01007cd:	0f 85 82 fe ff ff    	jne    c0100655 <rb_insert+0x2c>
        }
        else {
            RB_INSERT_SUB(right, left);
        }
    }
    tree->root->left->red = 0;
c01007d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01007d6:	8b 40 08             	mov    0x8(%eax),%eax
c01007d9:	8b 40 08             	mov    0x8(%eax),%eax
c01007dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    assert(!(tree->nil->red) && !(tree->root->red));
c01007e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01007e5:	8b 40 04             	mov    0x4(%eax),%eax
c01007e8:	8b 00                	mov    (%eax),%eax
c01007ea:	85 c0                	test   %eax,%eax
c01007ec:	75 0c                	jne    c01007fa <rb_insert+0x1d1>
c01007ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01007f1:	8b 40 08             	mov    0x8(%eax),%eax
c01007f4:	8b 00                	mov    (%eax),%eax
c01007f6:	85 c0                	test   %eax,%eax
c01007f8:	74 24                	je     c010081e <rb_insert+0x1f5>
c01007fa:	c7 44 24 0c d8 b4 10 	movl   $0xc010b4d8,0xc(%esp)
c0100801:	c0 
c0100802:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0100809:	c0 
c010080a:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c0100811:	00 
c0100812:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c0100819:	e8 4e 19 00 00       	call   c010216c <__panic>

#undef RB_INSERT_SUB
}
c010081e:	c9                   	leave  
c010081f:	c3                   	ret    

c0100820 <rb_tree_successor>:
 * rb_tree_successor - returns the successor of @node, or nil
 * if no successor exists. Make sure that @node must belong to @tree,
 * and this function should only be called by rb_node_prev.
 * */
static inline rb_node *
rb_tree_successor(rb_tree *tree, rb_node *node) {
c0100820:	55                   	push   %ebp
c0100821:	89 e5                	mov    %esp,%ebp
c0100823:	83 ec 10             	sub    $0x10,%esp
    rb_node *x = node, *y, *nil = tree->nil;
c0100826:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100829:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010082c:	8b 45 08             	mov    0x8(%ebp),%eax
c010082f:	8b 40 04             	mov    0x4(%eax),%eax
c0100832:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if ((y = x->right) != nil) {
c0100835:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100838:	8b 40 0c             	mov    0xc(%eax),%eax
c010083b:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010083e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100841:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100844:	74 1b                	je     c0100861 <rb_tree_successor+0x41>
        while (y->left != nil) {
c0100846:	eb 09                	jmp    c0100851 <rb_tree_successor+0x31>
            y = y->left;
c0100848:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010084b:	8b 40 08             	mov    0x8(%eax),%eax
c010084e:	89 45 f8             	mov    %eax,-0x8(%ebp)
static inline rb_node *
rb_tree_successor(rb_tree *tree, rb_node *node) {
    rb_node *x = node, *y, *nil = tree->nil;

    if ((y = x->right) != nil) {
        while (y->left != nil) {
c0100851:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100854:	8b 40 08             	mov    0x8(%eax),%eax
c0100857:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010085a:	75 ec                	jne    c0100848 <rb_tree_successor+0x28>
            y = y->left;
        }
        return y;
c010085c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010085f:	eb 38                	jmp    c0100899 <rb_tree_successor+0x79>
    }
    else {
        y = x->parent;
c0100861:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100864:	8b 40 04             	mov    0x4(%eax),%eax
c0100867:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->right) {
c010086a:	eb 0f                	jmp    c010087b <rb_tree_successor+0x5b>
            x = y, y = y->parent;
c010086c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010086f:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100872:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100875:	8b 40 04             	mov    0x4(%eax),%eax
c0100878:	89 45 f8             	mov    %eax,-0x8(%ebp)
        }
        return y;
    }
    else {
        y = x->parent;
        while (x == y->right) {
c010087b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010087e:	8b 40 0c             	mov    0xc(%eax),%eax
c0100881:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100884:	74 e6                	je     c010086c <rb_tree_successor+0x4c>
            x = y, y = y->parent;
        }
        if (y == tree->root) {
c0100886:	8b 45 08             	mov    0x8(%ebp),%eax
c0100889:	8b 40 08             	mov    0x8(%eax),%eax
c010088c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c010088f:	75 05                	jne    c0100896 <rb_tree_successor+0x76>
            return nil;
c0100891:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100894:	eb 03                	jmp    c0100899 <rb_tree_successor+0x79>
        }
        return y;
c0100896:	8b 45 f8             	mov    -0x8(%ebp),%eax
    }
}
c0100899:	c9                   	leave  
c010089a:	c3                   	ret    

c010089b <rb_tree_predecessor>:
/* *
 * rb_tree_predecessor - returns the predecessor of @node, or nil
 * if no predecessor exists, likes rb_tree_successor.
 * */
static inline rb_node *
rb_tree_predecessor(rb_tree *tree, rb_node *node) {
c010089b:	55                   	push   %ebp
c010089c:	89 e5                	mov    %esp,%ebp
c010089e:	83 ec 10             	sub    $0x10,%esp
    rb_node *x = node, *y, *nil = tree->nil;
c01008a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01008a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01008aa:	8b 40 04             	mov    0x4(%eax),%eax
c01008ad:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if ((y = x->left) != nil) {
c01008b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01008b3:	8b 40 08             	mov    0x8(%eax),%eax
c01008b6:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01008b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008bc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01008bf:	74 1b                	je     c01008dc <rb_tree_predecessor+0x41>
        while (y->right != nil) {
c01008c1:	eb 09                	jmp    c01008cc <rb_tree_predecessor+0x31>
            y = y->right;
c01008c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008c6:	8b 40 0c             	mov    0xc(%eax),%eax
c01008c9:	89 45 f8             	mov    %eax,-0x8(%ebp)
static inline rb_node *
rb_tree_predecessor(rb_tree *tree, rb_node *node) {
    rb_node *x = node, *y, *nil = tree->nil;

    if ((y = x->left) != nil) {
        while (y->right != nil) {
c01008cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008cf:	8b 40 0c             	mov    0xc(%eax),%eax
c01008d2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01008d5:	75 ec                	jne    c01008c3 <rb_tree_predecessor+0x28>
            y = y->right;
        }
        return y;
c01008d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008da:	eb 38                	jmp    c0100914 <rb_tree_predecessor+0x79>
    }
    else {
        y = x->parent;
c01008dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01008df:	8b 40 04             	mov    0x4(%eax),%eax
c01008e2:	89 45 f8             	mov    %eax,-0x8(%ebp)
        while (x == y->left) {
c01008e5:	eb 1f                	jmp    c0100906 <rb_tree_predecessor+0x6b>
            if (y == tree->root) {
c01008e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01008ea:	8b 40 08             	mov    0x8(%eax),%eax
c01008ed:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01008f0:	75 05                	jne    c01008f7 <rb_tree_predecessor+0x5c>
                return nil;
c01008f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008f5:	eb 1d                	jmp    c0100914 <rb_tree_predecessor+0x79>
            }
            x = y, y = y->parent;
c01008f7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01008fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01008fd:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100900:	8b 40 04             	mov    0x4(%eax),%eax
c0100903:	89 45 f8             	mov    %eax,-0x8(%ebp)
        }
        return y;
    }
    else {
        y = x->parent;
        while (x == y->left) {
c0100906:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100909:	8b 40 08             	mov    0x8(%eax),%eax
c010090c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010090f:	74 d6                	je     c01008e7 <rb_tree_predecessor+0x4c>
            if (y == tree->root) {
                return nil;
            }
            x = y, y = y->parent;
        }
        return y;
c0100911:	8b 45 f8             	mov    -0x8(%ebp),%eax
    }
}
c0100914:	c9                   	leave  
c0100915:	c3                   	ret    

c0100916 <rb_search>:
 * rb_search - returns a node with value 'equal' to @key (according to
 * function @compare). If there're multiple nodes with value 'equal' to @key,
 * the functions returns the one highest in the tree.
 * */
rb_node *
rb_search(rb_tree *tree, int (*compare)(rb_node *node, void *key), void *key) {
c0100916:	55                   	push   %ebp
c0100917:	89 e5                	mov    %esp,%ebp
c0100919:	83 ec 28             	sub    $0x28,%esp
    rb_node *nil = tree->nil, *node = tree->root->left;
c010091c:	8b 45 08             	mov    0x8(%ebp),%eax
c010091f:	8b 40 04             	mov    0x4(%eax),%eax
c0100922:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100925:	8b 45 08             	mov    0x8(%ebp),%eax
c0100928:	8b 40 08             	mov    0x8(%eax),%eax
c010092b:	8b 40 08             	mov    0x8(%eax),%eax
c010092e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int r;
    while (node != nil && (r = compare(node, key)) != 0) {
c0100931:	eb 17                	jmp    c010094a <rb_search+0x34>
        node = (r > 0) ? node->left : node->right;
c0100933:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0100937:	7e 08                	jle    c0100941 <rb_search+0x2b>
c0100939:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010093c:	8b 40 08             	mov    0x8(%eax),%eax
c010093f:	eb 06                	jmp    c0100947 <rb_search+0x31>
c0100941:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100944:	8b 40 0c             	mov    0xc(%eax),%eax
c0100947:	89 45 f4             	mov    %eax,-0xc(%ebp)
 * */
rb_node *
rb_search(rb_tree *tree, int (*compare)(rb_node *node, void *key), void *key) {
    rb_node *nil = tree->nil, *node = tree->root->left;
    int r;
    while (node != nil && (r = compare(node, key)) != 0) {
c010094a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010094d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100950:	74 1b                	je     c010096d <rb_search+0x57>
c0100952:	8b 45 10             	mov    0x10(%ebp),%eax
c0100955:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100959:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010095c:	89 04 24             	mov    %eax,(%esp)
c010095f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100962:	ff d0                	call   *%eax
c0100964:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100967:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010096b:	75 c6                	jne    c0100933 <rb_search+0x1d>
        node = (r > 0) ? node->left : node->right;
    }
    return (node != nil) ? node : NULL;
c010096d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100970:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100973:	74 05                	je     c010097a <rb_search+0x64>
c0100975:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100978:	eb 05                	jmp    c010097f <rb_search+0x69>
c010097a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010097f:	c9                   	leave  
c0100980:	c3                   	ret    

c0100981 <rb_delete_fixup>:
/* *
 * rb_delete_fixup - performs rotations and changes colors to restore
 * red-black properties after a node is deleted.
 * */
static void
rb_delete_fixup(rb_tree *tree, rb_node *node) {
c0100981:	55                   	push   %ebp
c0100982:	89 e5                	mov    %esp,%ebp
c0100984:	83 ec 28             	sub    $0x28,%esp
    rb_node *x = node, *w, *root = tree->root->left;
c0100987:	8b 45 0c             	mov    0xc(%ebp),%eax
c010098a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010098d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100990:	8b 40 08             	mov    0x8(%eax),%eax
c0100993:	8b 40 08             	mov    0x8(%eax),%eax
c0100996:	89 45 ec             	mov    %eax,-0x14(%ebp)
            rb_##_left##_rotate(tree, x->parent);               \
            x = root;                                           \
        }                                                       \
    } while (0)

    while (x != root && !x->red) {
c0100999:	e9 06 02 00 00       	jmp    c0100ba4 <rb_delete_fixup+0x223>
        if (x == x->parent->left) {
c010099e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009a1:	8b 40 04             	mov    0x4(%eax),%eax
c01009a4:	8b 40 08             	mov    0x8(%eax),%eax
c01009a7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01009aa:	0f 85 fe 00 00 00    	jne    c0100aae <rb_delete_fixup+0x12d>
            RB_DELETE_FIXUP_SUB(left, right);
c01009b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009b3:	8b 40 04             	mov    0x4(%eax),%eax
c01009b6:	8b 40 0c             	mov    0xc(%eax),%eax
c01009b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01009bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009bf:	8b 00                	mov    (%eax),%eax
c01009c1:	85 c0                	test   %eax,%eax
c01009c3:	74 36                	je     c01009fb <rb_delete_fixup+0x7a>
c01009c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009c8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c01009ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009d1:	8b 40 04             	mov    0x4(%eax),%eax
c01009d4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c01009da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009dd:	8b 40 04             	mov    0x4(%eax),%eax
c01009e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01009e7:	89 04 24             	mov    %eax,(%esp)
c01009ea:	e8 a2 f9 ff ff       	call   c0100391 <rb_left_rotate>
c01009ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009f2:	8b 40 04             	mov    0x4(%eax),%eax
c01009f5:	8b 40 0c             	mov    0xc(%eax),%eax
c01009f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01009fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009fe:	8b 40 08             	mov    0x8(%eax),%eax
c0100a01:	8b 00                	mov    (%eax),%eax
c0100a03:	85 c0                	test   %eax,%eax
c0100a05:	75 23                	jne    c0100a2a <rb_delete_fixup+0xa9>
c0100a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a0a:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a0d:	8b 00                	mov    (%eax),%eax
c0100a0f:	85 c0                	test   %eax,%eax
c0100a11:	75 17                	jne    c0100a2a <rb_delete_fixup+0xa9>
c0100a13:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a16:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a1f:	8b 40 04             	mov    0x4(%eax),%eax
c0100a22:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100a25:	e9 7a 01 00 00       	jmp    c0100ba4 <rb_delete_fixup+0x223>
c0100a2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a2d:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a30:	8b 00                	mov    (%eax),%eax
c0100a32:	85 c0                	test   %eax,%eax
c0100a34:	75 33                	jne    c0100a69 <rb_delete_fixup+0xe8>
c0100a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a39:	8b 40 08             	mov    0x8(%eax),%eax
c0100a3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a45:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a52:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a55:	89 04 24             	mov    %eax,(%esp)
c0100a58:	e8 23 fa ff ff       	call   c0100480 <rb_right_rotate>
c0100a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a60:	8b 40 04             	mov    0x4(%eax),%eax
c0100a63:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a66:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a6c:	8b 40 04             	mov    0x4(%eax),%eax
c0100a6f:	8b 10                	mov    (%eax),%edx
c0100a71:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a74:	89 10                	mov    %edx,(%eax)
c0100a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a79:	8b 40 04             	mov    0x4(%eax),%eax
c0100a7c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a85:	8b 40 0c             	mov    0xc(%eax),%eax
c0100a88:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a91:	8b 40 04             	mov    0x4(%eax),%eax
c0100a94:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a98:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a9b:	89 04 24             	mov    %eax,(%esp)
c0100a9e:	e8 ee f8 ff ff       	call   c0100391 <rb_left_rotate>
c0100aa3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100aa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100aa9:	e9 f6 00 00 00       	jmp    c0100ba4 <rb_delete_fixup+0x223>
        }
        else {
            RB_DELETE_FIXUP_SUB(right, left);
c0100aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ab1:	8b 40 04             	mov    0x4(%eax),%eax
c0100ab4:	8b 40 08             	mov    0x8(%eax),%eax
c0100ab7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100abd:	8b 00                	mov    (%eax),%eax
c0100abf:	85 c0                	test   %eax,%eax
c0100ac1:	74 36                	je     c0100af9 <rb_delete_fixup+0x178>
c0100ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ac6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100acf:	8b 40 04             	mov    0x4(%eax),%eax
c0100ad2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100adb:	8b 40 04             	mov    0x4(%eax),%eax
c0100ade:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ae2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ae5:	89 04 24             	mov    %eax,(%esp)
c0100ae8:	e8 93 f9 ff ff       	call   c0100480 <rb_right_rotate>
c0100aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100af0:	8b 40 04             	mov    0x4(%eax),%eax
c0100af3:	8b 40 08             	mov    0x8(%eax),%eax
c0100af6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100af9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100afc:	8b 40 0c             	mov    0xc(%eax),%eax
c0100aff:	8b 00                	mov    (%eax),%eax
c0100b01:	85 c0                	test   %eax,%eax
c0100b03:	75 20                	jne    c0100b25 <rb_delete_fixup+0x1a4>
c0100b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b08:	8b 40 08             	mov    0x8(%eax),%eax
c0100b0b:	8b 00                	mov    (%eax),%eax
c0100b0d:	85 c0                	test   %eax,%eax
c0100b0f:	75 14                	jne    c0100b25 <rb_delete_fixup+0x1a4>
c0100b11:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b14:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b1d:	8b 40 04             	mov    0x4(%eax),%eax
c0100b20:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100b23:	eb 7f                	jmp    c0100ba4 <rb_delete_fixup+0x223>
c0100b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b28:	8b 40 08             	mov    0x8(%eax),%eax
c0100b2b:	8b 00                	mov    (%eax),%eax
c0100b2d:	85 c0                	test   %eax,%eax
c0100b2f:	75 33                	jne    c0100b64 <rb_delete_fixup+0x1e3>
c0100b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b34:	8b 40 0c             	mov    0xc(%eax),%eax
c0100b37:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b40:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
c0100b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b49:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b50:	89 04 24             	mov    %eax,(%esp)
c0100b53:	e8 39 f8 ff ff       	call   c0100391 <rb_left_rotate>
c0100b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b5b:	8b 40 04             	mov    0x4(%eax),%eax
c0100b5e:	8b 40 08             	mov    0x8(%eax),%eax
c0100b61:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b67:	8b 40 04             	mov    0x4(%eax),%eax
c0100b6a:	8b 10                	mov    (%eax),%edx
c0100b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b6f:	89 10                	mov    %edx,(%eax)
c0100b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b74:	8b 40 04             	mov    0x4(%eax),%eax
c0100b77:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b80:	8b 40 08             	mov    0x8(%eax),%eax
c0100b83:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0100b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b8c:	8b 40 04             	mov    0x4(%eax),%eax
c0100b8f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b93:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b96:	89 04 24             	mov    %eax,(%esp)
c0100b99:	e8 e2 f8 ff ff       	call   c0100480 <rb_right_rotate>
c0100b9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100ba1:	89 45 f4             	mov    %eax,-0xc(%ebp)
            rb_##_left##_rotate(tree, x->parent);               \
            x = root;                                           \
        }                                                       \
    } while (0)

    while (x != root && !x->red) {
c0100ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ba7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100baa:	74 0d                	je     c0100bb9 <rb_delete_fixup+0x238>
c0100bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100baf:	8b 00                	mov    (%eax),%eax
c0100bb1:	85 c0                	test   %eax,%eax
c0100bb3:	0f 84 e5 fd ff ff    	je     c010099e <rb_delete_fixup+0x1d>
        }
        else {
            RB_DELETE_FIXUP_SUB(right, left);
        }
    }
    x->red = 0;
c0100bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bbc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

#undef RB_DELETE_FIXUP_SUB
}
c0100bc2:	c9                   	leave  
c0100bc3:	c3                   	ret    

c0100bc4 <rb_delete>:
/* *
 * rb_delete - deletes @node from @tree, and calls rb_delete_fixup to
 * restore red-black properties.
 * */
void
rb_delete(rb_tree *tree, rb_node *node) {
c0100bc4:	55                   	push   %ebp
c0100bc5:	89 e5                	mov    %esp,%ebp
c0100bc7:	83 ec 38             	sub    $0x38,%esp
    rb_node *x, *y, *z = node;
c0100bca:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    rb_node *nil = tree->nil, *root = tree->root;
c0100bd0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd3:	8b 40 04             	mov    0x4(%eax),%eax
c0100bd6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100bd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bdc:	8b 40 08             	mov    0x8(%eax),%eax
c0100bdf:	89 45 ec             	mov    %eax,-0x14(%ebp)

    y = (z->left == nil || z->right == nil) ? z : rb_tree_successor(tree, z);
c0100be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100be5:	8b 40 08             	mov    0x8(%eax),%eax
c0100be8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100beb:	74 1f                	je     c0100c0c <rb_delete+0x48>
c0100bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bf0:	8b 40 0c             	mov    0xc(%eax),%eax
c0100bf3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100bf6:	74 14                	je     c0100c0c <rb_delete+0x48>
c0100bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bfb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bff:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c02:	89 04 24             	mov    %eax,(%esp)
c0100c05:	e8 16 fc ff ff       	call   c0100820 <rb_tree_successor>
c0100c0a:	eb 03                	jmp    c0100c0f <rb_delete+0x4b>
c0100c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c0f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    x = (y->left != nil) ? y->left : y->right;
c0100c12:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c15:	8b 40 08             	mov    0x8(%eax),%eax
c0100c18:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100c1b:	74 08                	je     c0100c25 <rb_delete+0x61>
c0100c1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c20:	8b 40 08             	mov    0x8(%eax),%eax
c0100c23:	eb 06                	jmp    c0100c2b <rb_delete+0x67>
c0100c25:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c28:	8b 40 0c             	mov    0xc(%eax),%eax
c0100c2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    assert(y != root && y != nil);
c0100c2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c31:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100c34:	74 08                	je     c0100c3e <rb_delete+0x7a>
c0100c36:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c39:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100c3c:	75 24                	jne    c0100c62 <rb_delete+0x9e>
c0100c3e:	c7 44 24 0c 00 b5 10 	movl   $0xc010b500,0xc(%esp)
c0100c45:	c0 
c0100c46:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0100c4d:	c0 
c0100c4e:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
c0100c55:	00 
c0100c56:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c0100c5d:	e8 0a 15 00 00       	call   c010216c <__panic>

    x->parent = y->parent;
c0100c62:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c65:	8b 50 04             	mov    0x4(%eax),%edx
c0100c68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100c6b:	89 50 04             	mov    %edx,0x4(%eax)
    if (y == y->parent->left) {
c0100c6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c71:	8b 40 04             	mov    0x4(%eax),%eax
c0100c74:	8b 40 08             	mov    0x8(%eax),%eax
c0100c77:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0100c7a:	75 0e                	jne    c0100c8a <rb_delete+0xc6>
        y->parent->left = x;
c0100c7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c7f:	8b 40 04             	mov    0x4(%eax),%eax
c0100c82:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100c85:	89 50 08             	mov    %edx,0x8(%eax)
c0100c88:	eb 0c                	jmp    c0100c96 <rb_delete+0xd2>
    }
    else {
        y->parent->right = x;
c0100c8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c8d:	8b 40 04             	mov    0x4(%eax),%eax
c0100c90:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100c93:	89 50 0c             	mov    %edx,0xc(%eax)
    }

    bool need_fixup = !(y->red);
c0100c96:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100c99:	8b 00                	mov    (%eax),%eax
c0100c9b:	85 c0                	test   %eax,%eax
c0100c9d:	0f 94 c0             	sete   %al
c0100ca0:	0f b6 c0             	movzbl %al,%eax
c0100ca3:	89 45 e0             	mov    %eax,-0x20(%ebp)

    if (y != z) {
c0100ca6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ca9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100cac:	74 5c                	je     c0100d0a <rb_delete+0x146>
        if (z == z->parent->left) {
c0100cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cb1:	8b 40 04             	mov    0x4(%eax),%eax
c0100cb4:	8b 40 08             	mov    0x8(%eax),%eax
c0100cb7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100cba:	75 0e                	jne    c0100cca <rb_delete+0x106>
            z->parent->left = y;
c0100cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cbf:	8b 40 04             	mov    0x4(%eax),%eax
c0100cc2:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100cc5:	89 50 08             	mov    %edx,0x8(%eax)
c0100cc8:	eb 0c                	jmp    c0100cd6 <rb_delete+0x112>
        }
        else {
            z->parent->right = y;
c0100cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ccd:	8b 40 04             	mov    0x4(%eax),%eax
c0100cd0:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0100cd3:	89 50 0c             	mov    %edx,0xc(%eax)
        }
        z->left->parent = z->right->parent = y;
c0100cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cd9:	8b 50 08             	mov    0x8(%eax),%edx
c0100cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cdf:	8b 40 0c             	mov    0xc(%eax),%eax
c0100ce2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100ce5:	89 48 04             	mov    %ecx,0x4(%eax)
c0100ce8:	8b 40 04             	mov    0x4(%eax),%eax
c0100ceb:	89 42 04             	mov    %eax,0x4(%edx)
        *y = *z;
c0100cee:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100cf1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100cf4:	8b 0a                	mov    (%edx),%ecx
c0100cf6:	89 08                	mov    %ecx,(%eax)
c0100cf8:	8b 4a 04             	mov    0x4(%edx),%ecx
c0100cfb:	89 48 04             	mov    %ecx,0x4(%eax)
c0100cfe:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100d01:	89 48 08             	mov    %ecx,0x8(%eax)
c0100d04:	8b 52 0c             	mov    0xc(%edx),%edx
c0100d07:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    if (need_fixup) {
c0100d0a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0100d0e:	74 12                	je     c0100d22 <rb_delete+0x15e>
        rb_delete_fixup(tree, x);
c0100d10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100d13:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d17:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d1a:	89 04 24             	mov    %eax,(%esp)
c0100d1d:	e8 5f fc ff ff       	call   c0100981 <rb_delete_fixup>
    }
}
c0100d22:	c9                   	leave  
c0100d23:	c3                   	ret    

c0100d24 <rb_tree_destroy>:

/* rb_tree_destroy - destroy a tree and free memory */
void
rb_tree_destroy(rb_tree *tree) {
c0100d24:	55                   	push   %ebp
c0100d25:	89 e5                	mov    %esp,%ebp
c0100d27:	83 ec 18             	sub    $0x18,%esp
    kfree(tree->root);
c0100d2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d2d:	8b 40 08             	mov    0x8(%eax),%eax
c0100d30:	89 04 24             	mov    %eax,(%esp)
c0100d33:	e8 ad 51 00 00       	call   c0105ee5 <kfree>
    kfree(tree->nil);
c0100d38:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d3b:	8b 40 04             	mov    0x4(%eax),%eax
c0100d3e:	89 04 24             	mov    %eax,(%esp)
c0100d41:	e8 9f 51 00 00       	call   c0105ee5 <kfree>
    kfree(tree);
c0100d46:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d49:	89 04 24             	mov    %eax,(%esp)
c0100d4c:	e8 94 51 00 00       	call   c0105ee5 <kfree>
}
c0100d51:	c9                   	leave  
c0100d52:	c3                   	ret    

c0100d53 <rb_node_prev>:
/* *
 * rb_node_prev - returns the predecessor node of @node in @tree,
 * or 'NULL' if no predecessor exists.
 * */
rb_node *
rb_node_prev(rb_tree *tree, rb_node *node) {
c0100d53:	55                   	push   %ebp
c0100d54:	89 e5                	mov    %esp,%ebp
c0100d56:	83 ec 18             	sub    $0x18,%esp
    rb_node *prev = rb_tree_predecessor(tree, node);
c0100d59:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d5c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d60:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d63:	89 04 24             	mov    %eax,(%esp)
c0100d66:	e8 30 fb ff ff       	call   c010089b <rb_tree_predecessor>
c0100d6b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (prev != tree->nil) ? prev : NULL;
c0100d6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d71:	8b 40 04             	mov    0x4(%eax),%eax
c0100d74:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100d77:	74 05                	je     c0100d7e <rb_node_prev+0x2b>
c0100d79:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100d7c:	eb 05                	jmp    c0100d83 <rb_node_prev+0x30>
c0100d7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d83:	c9                   	leave  
c0100d84:	c3                   	ret    

c0100d85 <rb_node_next>:
/* *
 * rb_node_next - returns the successor node of @node in @tree,
 * or 'NULL' if no successor exists.
 * */
rb_node *
rb_node_next(rb_tree *tree, rb_node *node) {
c0100d85:	55                   	push   %ebp
c0100d86:	89 e5                	mov    %esp,%ebp
c0100d88:	83 ec 18             	sub    $0x18,%esp
    rb_node *next = rb_tree_successor(tree, node);
c0100d8b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d92:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d95:	89 04 24             	mov    %eax,(%esp)
c0100d98:	e8 83 fa ff ff       	call   c0100820 <rb_tree_successor>
c0100d9d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (next != tree->nil) ? next : NULL;
c0100da0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100da3:	8b 40 04             	mov    0x4(%eax),%eax
c0100da6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100da9:	74 05                	je     c0100db0 <rb_node_next+0x2b>
c0100dab:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dae:	eb 05                	jmp    c0100db5 <rb_node_next+0x30>
c0100db0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100db5:	c9                   	leave  
c0100db6:	c3                   	ret    

c0100db7 <rb_node_root>:

/* rb_node_root - returns the root node of a @tree, or 'NULL' if tree is empty */
rb_node *
rb_node_root(rb_tree *tree) {
c0100db7:	55                   	push   %ebp
c0100db8:	89 e5                	mov    %esp,%ebp
c0100dba:	83 ec 10             	sub    $0x10,%esp
    rb_node *node = tree->root->left;
c0100dbd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100dc0:	8b 40 08             	mov    0x8(%eax),%eax
c0100dc3:	8b 40 08             	mov    0x8(%eax),%eax
c0100dc6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (node != tree->nil) ? node : NULL;
c0100dc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100dcc:	8b 40 04             	mov    0x4(%eax),%eax
c0100dcf:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100dd2:	74 05                	je     c0100dd9 <rb_node_root+0x22>
c0100dd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dd7:	eb 05                	jmp    c0100dde <rb_node_root+0x27>
c0100dd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dde:	c9                   	leave  
c0100ddf:	c3                   	ret    

c0100de0 <rb_node_left>:

/* rb_node_left - gets the left child of @node, or 'NULL' if no such node */
rb_node *
rb_node_left(rb_tree *tree, rb_node *node) {
c0100de0:	55                   	push   %ebp
c0100de1:	89 e5                	mov    %esp,%ebp
c0100de3:	83 ec 10             	sub    $0x10,%esp
    rb_node *left = node->left;
c0100de6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100de9:	8b 40 08             	mov    0x8(%eax),%eax
c0100dec:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (left != tree->nil) ? left : NULL;
c0100def:	8b 45 08             	mov    0x8(%ebp),%eax
c0100df2:	8b 40 04             	mov    0x4(%eax),%eax
c0100df5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100df8:	74 05                	je     c0100dff <rb_node_left+0x1f>
c0100dfa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dfd:	eb 05                	jmp    c0100e04 <rb_node_left+0x24>
c0100dff:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e04:	c9                   	leave  
c0100e05:	c3                   	ret    

c0100e06 <rb_node_right>:

/* rb_node_right - gets the right child of @node, or 'NULL' if no such node */
rb_node *
rb_node_right(rb_tree *tree, rb_node *node) {
c0100e06:	55                   	push   %ebp
c0100e07:	89 e5                	mov    %esp,%ebp
c0100e09:	83 ec 10             	sub    $0x10,%esp
    rb_node *right = node->right;
c0100e0c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e0f:	8b 40 0c             	mov    0xc(%eax),%eax
c0100e12:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (right != tree->nil) ? right : NULL;
c0100e15:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e18:	8b 40 04             	mov    0x4(%eax),%eax
c0100e1b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100e1e:	74 05                	je     c0100e25 <rb_node_right+0x1f>
c0100e20:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e23:	eb 05                	jmp    c0100e2a <rb_node_right+0x24>
c0100e25:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e2a:	c9                   	leave  
c0100e2b:	c3                   	ret    

c0100e2c <check_tree>:

int
check_tree(rb_tree *tree, rb_node *node) {
c0100e2c:	55                   	push   %ebp
c0100e2d:	89 e5                	mov    %esp,%ebp
c0100e2f:	83 ec 28             	sub    $0x28,%esp
    rb_node *nil = tree->nil;
c0100e32:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e35:	8b 40 04             	mov    0x4(%eax),%eax
c0100e38:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (node == nil) {
c0100e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e3e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100e41:	75 37                	jne    c0100e7a <check_tree+0x4e>
        assert(!node->red);
c0100e43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e46:	8b 00                	mov    (%eax),%eax
c0100e48:	85 c0                	test   %eax,%eax
c0100e4a:	74 24                	je     c0100e70 <check_tree+0x44>
c0100e4c:	c7 44 24 0c 16 b5 10 	movl   $0xc010b516,0xc(%esp)
c0100e53:	c0 
c0100e54:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0100e5b:	c0 
c0100e5c:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
c0100e63:	00 
c0100e64:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c0100e6b:	e8 fc 12 00 00       	call   c010216c <__panic>
        return 1;
c0100e70:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e75:	e9 af 01 00 00       	jmp    c0101029 <check_tree+0x1fd>
    }
    if (node->left != nil) {
c0100e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100e7d:	8b 40 08             	mov    0x8(%eax),%eax
c0100e80:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100e83:	74 71                	je     c0100ef6 <check_tree+0xca>
        assert(COMPARE(tree, node, node->left) >= 0);
c0100e85:	8b 45 08             	mov    0x8(%ebp),%eax
c0100e88:	8b 00                	mov    (%eax),%eax
c0100e8a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100e8d:	8b 52 08             	mov    0x8(%edx),%edx
c0100e90:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100e94:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100e97:	89 14 24             	mov    %edx,(%esp)
c0100e9a:	ff d0                	call   *%eax
c0100e9c:	85 c0                	test   %eax,%eax
c0100e9e:	79 24                	jns    c0100ec4 <check_tree+0x98>
c0100ea0:	c7 44 24 0c 24 b5 10 	movl   $0xc010b524,0xc(%esp)
c0100ea7:	c0 
c0100ea8:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0100eaf:	c0 
c0100eb0:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
c0100eb7:	00 
c0100eb8:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c0100ebf:	e8 a8 12 00 00       	call   c010216c <__panic>
        assert(node->left->parent == node);
c0100ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ec7:	8b 40 08             	mov    0x8(%eax),%eax
c0100eca:	8b 40 04             	mov    0x4(%eax),%eax
c0100ecd:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0100ed0:	74 24                	je     c0100ef6 <check_tree+0xca>
c0100ed2:	c7 44 24 0c 49 b5 10 	movl   $0xc010b549,0xc(%esp)
c0100ed9:	c0 
c0100eda:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0100ee1:	c0 
c0100ee2:	c7 44 24 04 84 01 00 	movl   $0x184,0x4(%esp)
c0100ee9:	00 
c0100eea:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c0100ef1:	e8 76 12 00 00       	call   c010216c <__panic>
    }
    if (node->right != nil) {
c0100ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100ef9:	8b 40 0c             	mov    0xc(%eax),%eax
c0100efc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0100eff:	74 71                	je     c0100f72 <check_tree+0x146>
        assert(COMPARE(tree, node, node->right) <= 0);
c0100f01:	8b 45 08             	mov    0x8(%ebp),%eax
c0100f04:	8b 00                	mov    (%eax),%eax
c0100f06:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100f09:	8b 52 0c             	mov    0xc(%edx),%edx
c0100f0c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100f10:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100f13:	89 14 24             	mov    %edx,(%esp)
c0100f16:	ff d0                	call   *%eax
c0100f18:	85 c0                	test   %eax,%eax
c0100f1a:	7e 24                	jle    c0100f40 <check_tree+0x114>
c0100f1c:	c7 44 24 0c 64 b5 10 	movl   $0xc010b564,0xc(%esp)
c0100f23:	c0 
c0100f24:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0100f2b:	c0 
c0100f2c:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
c0100f33:	00 
c0100f34:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c0100f3b:	e8 2c 12 00 00       	call   c010216c <__panic>
        assert(node->right->parent == node);
c0100f40:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f43:	8b 40 0c             	mov    0xc(%eax),%eax
c0100f46:	8b 40 04             	mov    0x4(%eax),%eax
c0100f49:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0100f4c:	74 24                	je     c0100f72 <check_tree+0x146>
c0100f4e:	c7 44 24 0c 8a b5 10 	movl   $0xc010b58a,0xc(%esp)
c0100f55:	c0 
c0100f56:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0100f5d:	c0 
c0100f5e:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
c0100f65:	00 
c0100f66:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c0100f6d:	e8 fa 11 00 00       	call   c010216c <__panic>
    }
    if (node->red) {
c0100f72:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f75:	8b 00                	mov    (%eax),%eax
c0100f77:	85 c0                	test   %eax,%eax
c0100f79:	74 3c                	je     c0100fb7 <check_tree+0x18b>
        assert(!node->left->red && !node->right->red);
c0100f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f7e:	8b 40 08             	mov    0x8(%eax),%eax
c0100f81:	8b 00                	mov    (%eax),%eax
c0100f83:	85 c0                	test   %eax,%eax
c0100f85:	75 0c                	jne    c0100f93 <check_tree+0x167>
c0100f87:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100f8a:	8b 40 0c             	mov    0xc(%eax),%eax
c0100f8d:	8b 00                	mov    (%eax),%eax
c0100f8f:	85 c0                	test   %eax,%eax
c0100f91:	74 24                	je     c0100fb7 <check_tree+0x18b>
c0100f93:	c7 44 24 0c a8 b5 10 	movl   $0xc010b5a8,0xc(%esp)
c0100f9a:	c0 
c0100f9b:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0100fa2:	c0 
c0100fa3:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
c0100faa:	00 
c0100fab:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c0100fb2:	e8 b5 11 00 00       	call   c010216c <__panic>
    }
    int hb_left = check_tree(tree, node->left);
c0100fb7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100fba:	8b 40 08             	mov    0x8(%eax),%eax
c0100fbd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100fc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100fc4:	89 04 24             	mov    %eax,(%esp)
c0100fc7:	e8 60 fe ff ff       	call   c0100e2c <check_tree>
c0100fcc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    int hb_right = check_tree(tree, node->right);
c0100fcf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100fd2:	8b 40 0c             	mov    0xc(%eax),%eax
c0100fd5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100fd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100fdc:	89 04 24             	mov    %eax,(%esp)
c0100fdf:	e8 48 fe ff ff       	call   c0100e2c <check_tree>
c0100fe4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(hb_left == hb_right);
c0100fe7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100fea:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0100fed:	74 24                	je     c0101013 <check_tree+0x1e7>
c0100fef:	c7 44 24 0c ce b5 10 	movl   $0xc010b5ce,0xc(%esp)
c0100ff6:	c0 
c0100ff7:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0100ffe:	c0 
c0100fff:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
c0101006:	00 
c0101007:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c010100e:	e8 59 11 00 00       	call   c010216c <__panic>
    int hb = hb_left;
c0101013:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101016:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!node->red) {
c0101019:	8b 45 0c             	mov    0xc(%ebp),%eax
c010101c:	8b 00                	mov    (%eax),%eax
c010101e:	85 c0                	test   %eax,%eax
c0101020:	75 04                	jne    c0101026 <check_tree+0x1fa>
        hb ++;
c0101022:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    }
    return hb;
c0101026:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101029:	c9                   	leave  
c010102a:	c3                   	ret    

c010102b <check_safe_kmalloc>:

static void *
check_safe_kmalloc(size_t size) {
c010102b:	55                   	push   %ebp
c010102c:	89 e5                	mov    %esp,%ebp
c010102e:	83 ec 28             	sub    $0x28,%esp
    void *ret = kmalloc(size);
c0101031:	8b 45 08             	mov    0x8(%ebp),%eax
c0101034:	89 04 24             	mov    %eax,(%esp)
c0101037:	e8 8e 4e 00 00       	call   c0105eca <kmalloc>
c010103c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(ret != NULL);
c010103f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101043:	75 24                	jne    c0101069 <check_safe_kmalloc+0x3e>
c0101045:	c7 44 24 0c e2 b5 10 	movl   $0xc010b5e2,0xc(%esp)
c010104c:	c0 
c010104d:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0101054:	c0 
c0101055:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
c010105c:	00 
c010105d:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c0101064:	e8 03 11 00 00       	call   c010216c <__panic>
    return ret;
c0101069:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010106c:	c9                   	leave  
c010106d:	c3                   	ret    

c010106e <check_compare1>:

#define rbn2data(node)              \
    (to_struct(node, struct check_data, rb_link))

static inline int
check_compare1(rb_node *node1, rb_node *node2) {
c010106e:	55                   	push   %ebp
c010106f:	89 e5                	mov    %esp,%ebp
    return rbn2data(node1)->data - rbn2data(node2)->data;
c0101071:	8b 45 08             	mov    0x8(%ebp),%eax
c0101074:	83 e8 04             	sub    $0x4,%eax
c0101077:	8b 10                	mov    (%eax),%edx
c0101079:	8b 45 0c             	mov    0xc(%ebp),%eax
c010107c:	83 e8 04             	sub    $0x4,%eax
c010107f:	8b 00                	mov    (%eax),%eax
c0101081:	29 c2                	sub    %eax,%edx
c0101083:	89 d0                	mov    %edx,%eax
}
c0101085:	5d                   	pop    %ebp
c0101086:	c3                   	ret    

c0101087 <check_compare2>:

static inline int
check_compare2(rb_node *node, void *key) {
c0101087:	55                   	push   %ebp
c0101088:	89 e5                	mov    %esp,%ebp
    return rbn2data(node)->data - (long)key;
c010108a:	8b 45 08             	mov    0x8(%ebp),%eax
c010108d:	83 e8 04             	sub    $0x4,%eax
c0101090:	8b 10                	mov    (%eax),%edx
c0101092:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101095:	29 c2                	sub    %eax,%edx
c0101097:	89 d0                	mov    %edx,%eax
}
c0101099:	5d                   	pop    %ebp
c010109a:	c3                   	ret    

c010109b <check_rb_tree>:

void
check_rb_tree(void) {
c010109b:	55                   	push   %ebp
c010109c:	89 e5                	mov    %esp,%ebp
c010109e:	53                   	push   %ebx
c010109f:	83 ec 44             	sub    $0x44,%esp
    rb_tree *tree = rb_tree_create(check_compare1);
c01010a2:	c7 04 24 6e 10 10 c0 	movl   $0xc010106e,(%esp)
c01010a9:	e8 e5 f1 ff ff       	call   c0100293 <rb_tree_create>
c01010ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(tree != NULL);
c01010b1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01010b5:	75 24                	jne    c01010db <check_rb_tree+0x40>
c01010b7:	c7 44 24 0c ee b5 10 	movl   $0xc010b5ee,0xc(%esp)
c01010be:	c0 
c01010bf:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c01010c6:	c0 
c01010c7:	c7 44 24 04 b3 01 00 	movl   $0x1b3,0x4(%esp)
c01010ce:	00 
c01010cf:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c01010d6:	e8 91 10 00 00       	call   c010216c <__panic>

    rb_node *nil = tree->nil, *root = tree->root;
c01010db:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01010de:	8b 40 04             	mov    0x4(%eax),%eax
c01010e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01010e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01010e7:	8b 40 08             	mov    0x8(%eax),%eax
c01010ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(!nil->red && root->left == nil);
c01010ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01010f0:	8b 00                	mov    (%eax),%eax
c01010f2:	85 c0                	test   %eax,%eax
c01010f4:	75 0b                	jne    c0101101 <check_rb_tree+0x66>
c01010f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01010f9:	8b 40 08             	mov    0x8(%eax),%eax
c01010fc:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c01010ff:	74 24                	je     c0101125 <check_rb_tree+0x8a>
c0101101:	c7 44 24 0c fc b5 10 	movl   $0xc010b5fc,0xc(%esp)
c0101108:	c0 
c0101109:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0101110:	c0 
c0101111:	c7 44 24 04 b6 01 00 	movl   $0x1b6,0x4(%esp)
c0101118:	00 
c0101119:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c0101120:	e8 47 10 00 00       	call   c010216c <__panic>

    int total = 1000;
c0101125:	c7 45 e0 e8 03 00 00 	movl   $0x3e8,-0x20(%ebp)
    struct check_data **all = check_safe_kmalloc(sizeof(struct check_data *) * total);
c010112c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010112f:	c1 e0 02             	shl    $0x2,%eax
c0101132:	89 04 24             	mov    %eax,(%esp)
c0101135:	e8 f1 fe ff ff       	call   c010102b <check_safe_kmalloc>
c010113a:	89 45 dc             	mov    %eax,-0x24(%ebp)

    long i;
    for (i = 0; i < total; i ++) {
c010113d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101144:	eb 38                	jmp    c010117e <check_rb_tree+0xe3>
        all[i] = check_safe_kmalloc(sizeof(struct check_data));
c0101146:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101149:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101150:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101153:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
c0101156:	c7 04 24 14 00 00 00 	movl   $0x14,(%esp)
c010115d:	e8 c9 fe ff ff       	call   c010102b <check_safe_kmalloc>
c0101162:	89 03                	mov    %eax,(%ebx)
        all[i]->data = i;
c0101164:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101167:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010116e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101171:	01 d0                	add    %edx,%eax
c0101173:	8b 00                	mov    (%eax),%eax
c0101175:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101178:	89 10                	mov    %edx,(%eax)

    int total = 1000;
    struct check_data **all = check_safe_kmalloc(sizeof(struct check_data *) * total);

    long i;
    for (i = 0; i < total; i ++) {
c010117a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010117e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101181:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101184:	7c c0                	jl     c0101146 <check_rb_tree+0xab>
        all[i] = check_safe_kmalloc(sizeof(struct check_data));
        all[i]->data = i;
    }

    int *mark = check_safe_kmalloc(sizeof(int) * total);
c0101186:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101189:	c1 e0 02             	shl    $0x2,%eax
c010118c:	89 04 24             	mov    %eax,(%esp)
c010118f:	e8 97 fe ff ff       	call   c010102b <check_safe_kmalloc>
c0101194:	89 45 d8             	mov    %eax,-0x28(%ebp)
    memset(mark, 0, sizeof(int) * total);
c0101197:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010119a:	c1 e0 02             	shl    $0x2,%eax
c010119d:	89 44 24 08          	mov    %eax,0x8(%esp)
c01011a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01011a8:	00 
c01011a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01011ac:	89 04 24             	mov    %eax,(%esp)
c01011af:	e8 7d a0 00 00       	call   c010b231 <memset>

    for (i = 0; i < total; i ++) {
c01011b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01011bb:	eb 29                	jmp    c01011e6 <check_rb_tree+0x14b>
        mark[all[i]->data] = 1;
c01011bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01011c0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01011c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01011ca:	01 d0                	add    %edx,%eax
c01011cc:	8b 00                	mov    (%eax),%eax
c01011ce:	8b 00                	mov    (%eax),%eax
c01011d0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01011d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01011da:	01 d0                	add    %edx,%eax
c01011dc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    }

    int *mark = check_safe_kmalloc(sizeof(int) * total);
    memset(mark, 0, sizeof(int) * total);

    for (i = 0; i < total; i ++) {
c01011e2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01011e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01011e9:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01011ec:	7c cf                	jl     c01011bd <check_rb_tree+0x122>
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c01011ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01011f5:	eb 3e                	jmp    c0101235 <check_rb_tree+0x19a>
        assert(mark[i] == 1);
c01011f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01011fa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101201:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101204:	01 d0                	add    %edx,%eax
c0101206:	8b 00                	mov    (%eax),%eax
c0101208:	83 f8 01             	cmp    $0x1,%eax
c010120b:	74 24                	je     c0101231 <check_rb_tree+0x196>
c010120d:	c7 44 24 0c 1b b6 10 	movl   $0xc010b61b,0xc(%esp)
c0101214:	c0 
c0101215:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c010121c:	c0 
c010121d:	c7 44 24 04 c8 01 00 	movl   $0x1c8,0x4(%esp)
c0101224:	00 
c0101225:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c010122c:	e8 3b 0f 00 00       	call   c010216c <__panic>
    memset(mark, 0, sizeof(int) * total);

    for (i = 0; i < total; i ++) {
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c0101231:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101235:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101238:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010123b:	7c ba                	jl     c01011f7 <check_rb_tree+0x15c>
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c010123d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101244:	eb 66                	jmp    c01012ac <check_rb_tree+0x211>
        int j = (rand() % (total - i)) + i;
c0101246:	e8 df 9b 00 00       	call   c010ae2a <rand>
c010124b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010124e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0101251:	29 d1                	sub    %edx,%ecx
c0101253:	99                   	cltd   
c0101254:	f7 f9                	idiv   %ecx
c0101256:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101259:	01 d0                	add    %edx,%eax
c010125b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        struct check_data *z = all[i];
c010125e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101261:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101268:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010126b:	01 d0                	add    %edx,%eax
c010126d:	8b 00                	mov    (%eax),%eax
c010126f:	89 45 d0             	mov    %eax,-0x30(%ebp)
        all[i] = all[j];
c0101272:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101275:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010127c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010127f:	01 c2                	add    %eax,%edx
c0101281:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101284:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
c010128b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010128e:	01 c8                	add    %ecx,%eax
c0101290:	8b 00                	mov    (%eax),%eax
c0101292:	89 02                	mov    %eax,(%edx)
        all[j] = z;
c0101294:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101297:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010129e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01012a1:	01 c2                	add    %eax,%edx
c01012a3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01012a6:	89 02                	mov    %eax,(%edx)
    }
    for (i = 0; i < total; i ++) {
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c01012a8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01012ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012af:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01012b2:	7c 92                	jl     c0101246 <check_rb_tree+0x1ab>
        struct check_data *z = all[i];
        all[i] = all[j];
        all[j] = z;
    }

    memset(mark, 0, sizeof(int) * total);
c01012b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01012b7:	c1 e0 02             	shl    $0x2,%eax
c01012ba:	89 44 24 08          	mov    %eax,0x8(%esp)
c01012be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01012c5:	00 
c01012c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01012c9:	89 04 24             	mov    %eax,(%esp)
c01012cc:	e8 60 9f 00 00       	call   c010b231 <memset>
    for (i = 0; i < total; i ++) {
c01012d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01012d8:	eb 29                	jmp    c0101303 <check_rb_tree+0x268>
        mark[all[i]->data] = 1;
c01012da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01012dd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01012e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01012e7:	01 d0                	add    %edx,%eax
c01012e9:	8b 00                	mov    (%eax),%eax
c01012eb:	8b 00                	mov    (%eax),%eax
c01012ed:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01012f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01012f7:	01 d0                	add    %edx,%eax
c01012f9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
        all[i] = all[j];
        all[j] = z;
    }

    memset(mark, 0, sizeof(int) * total);
    for (i = 0; i < total; i ++) {
c01012ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101303:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101306:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101309:	7c cf                	jl     c01012da <check_rb_tree+0x23f>
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c010130b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101312:	eb 3e                	jmp    c0101352 <check_rb_tree+0x2b7>
        assert(mark[i] == 1);
c0101314:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101317:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010131e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101321:	01 d0                	add    %edx,%eax
c0101323:	8b 00                	mov    (%eax),%eax
c0101325:	83 f8 01             	cmp    $0x1,%eax
c0101328:	74 24                	je     c010134e <check_rb_tree+0x2b3>
c010132a:	c7 44 24 0c 1b b6 10 	movl   $0xc010b61b,0xc(%esp)
c0101331:	c0 
c0101332:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0101339:	c0 
c010133a:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
c0101341:	00 
c0101342:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c0101349:	e8 1e 0e 00 00       	call   c010216c <__panic>

    memset(mark, 0, sizeof(int) * total);
    for (i = 0; i < total; i ++) {
        mark[all[i]->data] = 1;
    }
    for (i = 0; i < total; i ++) {
c010134e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101352:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101355:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101358:	7c ba                	jl     c0101314 <check_rb_tree+0x279>
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c010135a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101361:	eb 3c                	jmp    c010139f <check_rb_tree+0x304>
        rb_insert(tree, &(all[i]->rb_link));
c0101363:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101366:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010136d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101370:	01 d0                	add    %edx,%eax
c0101372:	8b 00                	mov    (%eax),%eax
c0101374:	83 c0 04             	add    $0x4,%eax
c0101377:	89 44 24 04          	mov    %eax,0x4(%esp)
c010137b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010137e:	89 04 24             	mov    %eax,(%esp)
c0101381:	e8 a3 f2 ff ff       	call   c0100629 <rb_insert>
        check_tree(tree, root->left);
c0101386:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101389:	8b 40 08             	mov    0x8(%eax),%eax
c010138c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101390:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101393:	89 04 24             	mov    %eax,(%esp)
c0101396:	e8 91 fa ff ff       	call   c0100e2c <check_tree>
    }
    for (i = 0; i < total; i ++) {
        assert(mark[i] == 1);
    }

    for (i = 0; i < total; i ++) {
c010139b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010139f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01013a2:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01013a5:	7c bc                	jl     c0101363 <check_rb_tree+0x2c8>
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    rb_node *node;
    for (i = 0; i < total; i ++) {
c01013a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01013ae:	eb 74                	jmp    c0101424 <check_rb_tree+0x389>
        node = rb_search(tree, check_compare2, (void *)(all[i]->data));
c01013b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01013b3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01013ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01013bd:	01 d0                	add    %edx,%eax
c01013bf:	8b 00                	mov    (%eax),%eax
c01013c1:	8b 00                	mov    (%eax),%eax
c01013c3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01013c7:	c7 44 24 04 87 10 10 	movl   $0xc0101087,0x4(%esp)
c01013ce:	c0 
c01013cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01013d2:	89 04 24             	mov    %eax,(%esp)
c01013d5:	e8 3c f5 ff ff       	call   c0100916 <rb_search>
c01013da:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(node != NULL && node == &(all[i]->rb_link));
c01013dd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01013e1:	74 19                	je     c01013fc <check_rb_tree+0x361>
c01013e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01013e6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01013ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01013f0:	01 d0                	add    %edx,%eax
c01013f2:	8b 00                	mov    (%eax),%eax
c01013f4:	83 c0 04             	add    $0x4,%eax
c01013f7:	3b 45 cc             	cmp    -0x34(%ebp),%eax
c01013fa:	74 24                	je     c0101420 <check_rb_tree+0x385>
c01013fc:	c7 44 24 0c 28 b6 10 	movl   $0xc010b628,0xc(%esp)
c0101403:	c0 
c0101404:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c010140b:	c0 
c010140c:	c7 44 24 04 e2 01 00 	movl   $0x1e2,0x4(%esp)
c0101413:	00 
c0101414:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c010141b:	e8 4c 0d 00 00       	call   c010216c <__panic>
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    rb_node *node;
    for (i = 0; i < total; i ++) {
c0101420:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101424:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101427:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010142a:	7c 84                	jl     c01013b0 <check_rb_tree+0x315>
        node = rb_search(tree, check_compare2, (void *)(all[i]->data));
        assert(node != NULL && node == &(all[i]->rb_link));
    }

    for (i = 0; i < total; i ++) {
c010142c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101433:	eb 7f                	jmp    c01014b4 <check_rb_tree+0x419>
        node = rb_search(tree, check_compare2, (void *)i);
c0101435:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101438:	89 44 24 08          	mov    %eax,0x8(%esp)
c010143c:	c7 44 24 04 87 10 10 	movl   $0xc0101087,0x4(%esp)
c0101443:	c0 
c0101444:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101447:	89 04 24             	mov    %eax,(%esp)
c010144a:	e8 c7 f4 ff ff       	call   c0100916 <rb_search>
c010144f:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(node != NULL && rbn2data(node)->data == i);
c0101452:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0101456:	74 0d                	je     c0101465 <check_rb_tree+0x3ca>
c0101458:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010145b:	83 e8 04             	sub    $0x4,%eax
c010145e:	8b 00                	mov    (%eax),%eax
c0101460:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0101463:	74 24                	je     c0101489 <check_rb_tree+0x3ee>
c0101465:	c7 44 24 0c 54 b6 10 	movl   $0xc010b654,0xc(%esp)
c010146c:	c0 
c010146d:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0101474:	c0 
c0101475:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c010147c:	00 
c010147d:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c0101484:	e8 e3 0c 00 00       	call   c010216c <__panic>
        rb_delete(tree, node);
c0101489:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010148c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101490:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101493:	89 04 24             	mov    %eax,(%esp)
c0101496:	e8 29 f7 ff ff       	call   c0100bc4 <rb_delete>
        check_tree(tree, root->left);
c010149b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010149e:	8b 40 08             	mov    0x8(%eax),%eax
c01014a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01014a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01014a8:	89 04 24             	mov    %eax,(%esp)
c01014ab:	e8 7c f9 ff ff       	call   c0100e2c <check_tree>
    for (i = 0; i < total; i ++) {
        node = rb_search(tree, check_compare2, (void *)(all[i]->data));
        assert(node != NULL && node == &(all[i]->rb_link));
    }

    for (i = 0; i < total; i ++) {
c01014b0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01014b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01014b7:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01014ba:	0f 8c 75 ff ff ff    	jl     c0101435 <check_rb_tree+0x39a>
        assert(node != NULL && rbn2data(node)->data == i);
        rb_delete(tree, node);
        check_tree(tree, root->left);
    }

    assert(!nil->red && root->left == nil);
c01014c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01014c3:	8b 00                	mov    (%eax),%eax
c01014c5:	85 c0                	test   %eax,%eax
c01014c7:	75 0b                	jne    c01014d4 <check_rb_tree+0x439>
c01014c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01014cc:	8b 40 08             	mov    0x8(%eax),%eax
c01014cf:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c01014d2:	74 24                	je     c01014f8 <check_rb_tree+0x45d>
c01014d4:	c7 44 24 0c fc b5 10 	movl   $0xc010b5fc,0xc(%esp)
c01014db:	c0 
c01014dc:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c01014e3:	c0 
c01014e4:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c01014eb:	00 
c01014ec:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c01014f3:	e8 74 0c 00 00       	call   c010216c <__panic>

    long max = 32;
c01014f8:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
    if (max > total) {
c01014ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101502:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101505:	7e 06                	jle    c010150d <check_rb_tree+0x472>
        max = total;
c0101507:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010150a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }

    for (i = 0; i < max; i ++) {
c010150d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101514:	eb 52                	jmp    c0101568 <check_rb_tree+0x4cd>
        all[i]->data = max;
c0101516:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101519:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101520:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101523:	01 d0                	add    %edx,%eax
c0101525:	8b 00                	mov    (%eax),%eax
c0101527:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010152a:	89 10                	mov    %edx,(%eax)
        rb_insert(tree, &(all[i]->rb_link));
c010152c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010152f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101536:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101539:	01 d0                	add    %edx,%eax
c010153b:	8b 00                	mov    (%eax),%eax
c010153d:	83 c0 04             	add    $0x4,%eax
c0101540:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101544:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101547:	89 04 24             	mov    %eax,(%esp)
c010154a:	e8 da f0 ff ff       	call   c0100629 <rb_insert>
        check_tree(tree, root->left);
c010154f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101552:	8b 40 08             	mov    0x8(%eax),%eax
c0101555:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101559:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010155c:	89 04 24             	mov    %eax,(%esp)
c010155f:	e8 c8 f8 ff ff       	call   c0100e2c <check_tree>
    long max = 32;
    if (max > total) {
        max = total;
    }

    for (i = 0; i < max; i ++) {
c0101564:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101568:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010156b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010156e:	7c a6                	jl     c0101516 <check_rb_tree+0x47b>
        all[i]->data = max;
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    for (i = 0; i < max; i ++) {
c0101570:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101577:	eb 7f                	jmp    c01015f8 <check_rb_tree+0x55d>
        node = rb_search(tree, check_compare2, (void *)max);
c0101579:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010157c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101580:	c7 44 24 04 87 10 10 	movl   $0xc0101087,0x4(%esp)
c0101587:	c0 
c0101588:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010158b:	89 04 24             	mov    %eax,(%esp)
c010158e:	e8 83 f3 ff ff       	call   c0100916 <rb_search>
c0101593:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(node != NULL && rbn2data(node)->data == max);
c0101596:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010159a:	74 0d                	je     c01015a9 <check_rb_tree+0x50e>
c010159c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010159f:	83 e8 04             	sub    $0x4,%eax
c01015a2:	8b 00                	mov    (%eax),%eax
c01015a4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01015a7:	74 24                	je     c01015cd <check_rb_tree+0x532>
c01015a9:	c7 44 24 0c 80 b6 10 	movl   $0xc010b680,0xc(%esp)
c01015b0:	c0 
c01015b1:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c01015b8:	c0 
c01015b9:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c01015c0:	00 
c01015c1:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c01015c8:	e8 9f 0b 00 00       	call   c010216c <__panic>
        rb_delete(tree, node);
c01015cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01015d0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01015d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01015d7:	89 04 24             	mov    %eax,(%esp)
c01015da:	e8 e5 f5 ff ff       	call   c0100bc4 <rb_delete>
        check_tree(tree, root->left);
c01015df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01015e2:	8b 40 08             	mov    0x8(%eax),%eax
c01015e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01015e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01015ec:	89 04 24             	mov    %eax,(%esp)
c01015ef:	e8 38 f8 ff ff       	call   c0100e2c <check_tree>
        all[i]->data = max;
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    for (i = 0; i < max; i ++) {
c01015f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01015f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01015fb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01015fe:	0f 8c 75 ff ff ff    	jl     c0101579 <check_rb_tree+0x4de>
        assert(node != NULL && rbn2data(node)->data == max);
        rb_delete(tree, node);
        check_tree(tree, root->left);
    }

    assert(rb_tree_empty(tree));
c0101604:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101607:	89 04 24             	mov    %eax,(%esp)
c010160a:	e8 5b ec ff ff       	call   c010026a <rb_tree_empty>
c010160f:	85 c0                	test   %eax,%eax
c0101611:	75 24                	jne    c0101637 <check_rb_tree+0x59c>
c0101613:	c7 44 24 0c ac b6 10 	movl   $0xc010b6ac,0xc(%esp)
c010161a:	c0 
c010161b:	c7 44 24 08 78 b4 10 	movl   $0xc010b478,0x8(%esp)
c0101622:	c0 
c0101623:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c010162a:	00 
c010162b:	c7 04 24 8d b4 10 c0 	movl   $0xc010b48d,(%esp)
c0101632:	e8 35 0b 00 00       	call   c010216c <__panic>

    for (i = 0; i < total; i ++) {
c0101637:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010163e:	eb 3c                	jmp    c010167c <check_rb_tree+0x5e1>
        rb_insert(tree, &(all[i]->rb_link));
c0101640:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101643:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010164a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010164d:	01 d0                	add    %edx,%eax
c010164f:	8b 00                	mov    (%eax),%eax
c0101651:	83 c0 04             	add    $0x4,%eax
c0101654:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101658:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010165b:	89 04 24             	mov    %eax,(%esp)
c010165e:	e8 c6 ef ff ff       	call   c0100629 <rb_insert>
        check_tree(tree, root->left);
c0101663:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101666:	8b 40 08             	mov    0x8(%eax),%eax
c0101669:	89 44 24 04          	mov    %eax,0x4(%esp)
c010166d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101670:	89 04 24             	mov    %eax,(%esp)
c0101673:	e8 b4 f7 ff ff       	call   c0100e2c <check_tree>
        check_tree(tree, root->left);
    }

    assert(rb_tree_empty(tree));

    for (i = 0; i < total; i ++) {
c0101678:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010167c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010167f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0101682:	7c bc                	jl     c0101640 <check_rb_tree+0x5a5>
        rb_insert(tree, &(all[i]->rb_link));
        check_tree(tree, root->left);
    }

    rb_tree_destroy(tree);
c0101684:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101687:	89 04 24             	mov    %eax,(%esp)
c010168a:	e8 95 f6 ff ff       	call   c0100d24 <rb_tree_destroy>

    for (i = 0; i < total; i ++) {
c010168f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101696:	eb 1d                	jmp    c01016b5 <check_rb_tree+0x61a>
        kfree(all[i]);
c0101698:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010169b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01016a2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01016a5:	01 d0                	add    %edx,%eax
c01016a7:	8b 00                	mov    (%eax),%eax
c01016a9:	89 04 24             	mov    %eax,(%esp)
c01016ac:	e8 34 48 00 00       	call   c0105ee5 <kfree>
        check_tree(tree, root->left);
    }

    rb_tree_destroy(tree);

    for (i = 0; i < total; i ++) {
c01016b1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01016b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016b8:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01016bb:	7c db                	jl     c0101698 <check_rb_tree+0x5fd>
        kfree(all[i]);
    }

    kfree(mark);
c01016bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01016c0:	89 04 24             	mov    %eax,(%esp)
c01016c3:	e8 1d 48 00 00       	call   c0105ee5 <kfree>
    kfree(all);
c01016c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01016cb:	89 04 24             	mov    %eax,(%esp)
c01016ce:	e8 12 48 00 00       	call   c0105ee5 <kfree>
}
c01016d3:	83 c4 44             	add    $0x44,%esp
c01016d6:	5b                   	pop    %ebx
c01016d7:	5d                   	pop    %ebp
c01016d8:	c3                   	ret    

c01016d9 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c01016d9:	55                   	push   %ebp
c01016da:	89 e5                	mov    %esp,%ebp
c01016dc:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c01016df:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01016e3:	74 13                	je     c01016f8 <readline+0x1f>
        cprintf("%s", prompt);
c01016e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01016e8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01016ec:	c7 04 24 c0 b6 10 c0 	movl   $0xc010b6c0,(%esp)
c01016f3:	e8 ea 00 00 00       	call   c01017e2 <cprintf>
    }
    int i = 0, c;
c01016f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c01016ff:	e8 66 01 00 00       	call   c010186a <getchar>
c0101704:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0101707:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010170b:	79 07                	jns    c0101714 <readline+0x3b>
            return NULL;
c010170d:	b8 00 00 00 00       	mov    $0x0,%eax
c0101712:	eb 79                	jmp    c010178d <readline+0xb4>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0101714:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0101718:	7e 28                	jle    c0101742 <readline+0x69>
c010171a:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0101721:	7f 1f                	jg     c0101742 <readline+0x69>
            cputchar(c);
c0101723:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101726:	89 04 24             	mov    %eax,(%esp)
c0101729:	e8 da 00 00 00       	call   c0101808 <cputchar>
            buf[i ++] = c;
c010172e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101731:	8d 50 01             	lea    0x1(%eax),%edx
c0101734:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0101737:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010173a:	88 90 20 b0 12 c0    	mov    %dl,-0x3fed4fe0(%eax)
c0101740:	eb 46                	jmp    c0101788 <readline+0xaf>
        }
        else if (c == '\b' && i > 0) {
c0101742:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c0101746:	75 17                	jne    c010175f <readline+0x86>
c0101748:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010174c:	7e 11                	jle    c010175f <readline+0x86>
            cputchar(c);
c010174e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101751:	89 04 24             	mov    %eax,(%esp)
c0101754:	e8 af 00 00 00       	call   c0101808 <cputchar>
            i --;
c0101759:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010175d:	eb 29                	jmp    c0101788 <readline+0xaf>
        }
        else if (c == '\n' || c == '\r') {
c010175f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c0101763:	74 06                	je     c010176b <readline+0x92>
c0101765:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c0101769:	75 1d                	jne    c0101788 <readline+0xaf>
            cputchar(c);
c010176b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010176e:	89 04 24             	mov    %eax,(%esp)
c0101771:	e8 92 00 00 00       	call   c0101808 <cputchar>
            buf[i] = '\0';
c0101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101779:	05 20 b0 12 c0       	add    $0xc012b020,%eax
c010177e:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c0101781:	b8 20 b0 12 c0       	mov    $0xc012b020,%eax
c0101786:	eb 05                	jmp    c010178d <readline+0xb4>
        }
    }
c0101788:	e9 72 ff ff ff       	jmp    c01016ff <readline+0x26>
}
c010178d:	c9                   	leave  
c010178e:	c3                   	ret    

c010178f <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010178f:	55                   	push   %ebp
c0101790:	89 e5                	mov    %esp,%ebp
c0101792:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0101795:	8b 45 08             	mov    0x8(%ebp),%eax
c0101798:	89 04 24             	mov    %eax,(%esp)
c010179b:	e8 0f 13 00 00       	call   c0102aaf <cons_putc>
    (*cnt) ++;
c01017a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01017a3:	8b 00                	mov    (%eax),%eax
c01017a5:	8d 50 01             	lea    0x1(%eax),%edx
c01017a8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01017ab:	89 10                	mov    %edx,(%eax)
}
c01017ad:	c9                   	leave  
c01017ae:	c3                   	ret    

c01017af <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c01017af:	55                   	push   %ebp
c01017b0:	89 e5                	mov    %esp,%ebp
c01017b2:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01017b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c01017bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01017bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01017c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01017c6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01017ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
c01017cd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01017d1:	c7 04 24 8f 17 10 c0 	movl   $0xc010178f,(%esp)
c01017d8:	e8 95 91 00 00       	call   c010a972 <vprintfmt>
    return cnt;
c01017dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01017e0:	c9                   	leave  
c01017e1:	c3                   	ret    

c01017e2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01017e2:	55                   	push   %ebp
c01017e3:	89 e5                	mov    %esp,%ebp
c01017e5:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01017e8:	8d 45 0c             	lea    0xc(%ebp),%eax
c01017eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01017ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01017f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01017f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01017f8:	89 04 24             	mov    %eax,(%esp)
c01017fb:	e8 af ff ff ff       	call   c01017af <vcprintf>
c0101800:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0101803:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101806:	c9                   	leave  
c0101807:	c3                   	ret    

c0101808 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c0101808:	55                   	push   %ebp
c0101809:	89 e5                	mov    %esp,%ebp
c010180b:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010180e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101811:	89 04 24             	mov    %eax,(%esp)
c0101814:	e8 96 12 00 00       	call   c0102aaf <cons_putc>
}
c0101819:	c9                   	leave  
c010181a:	c3                   	ret    

c010181b <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c010181b:	55                   	push   %ebp
c010181c:	89 e5                	mov    %esp,%ebp
c010181e:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0101821:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c0101828:	eb 13                	jmp    c010183d <cputs+0x22>
        cputch(c, &cnt);
c010182a:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c010182e:	8d 55 f0             	lea    -0x10(%ebp),%edx
c0101831:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101835:	89 04 24             	mov    %eax,(%esp)
c0101838:	e8 52 ff ff ff       	call   c010178f <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c010183d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101840:	8d 50 01             	lea    0x1(%eax),%edx
c0101843:	89 55 08             	mov    %edx,0x8(%ebp)
c0101846:	0f b6 00             	movzbl (%eax),%eax
c0101849:	88 45 f7             	mov    %al,-0x9(%ebp)
c010184c:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0101850:	75 d8                	jne    c010182a <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c0101852:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0101855:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101859:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0101860:	e8 2a ff ff ff       	call   c010178f <cputch>
    return cnt;
c0101865:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0101868:	c9                   	leave  
c0101869:	c3                   	ret    

c010186a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010186a:	55                   	push   %ebp
c010186b:	89 e5                	mov    %esp,%ebp
c010186d:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0101870:	e8 76 12 00 00       	call   c0102aeb <cons_getc>
c0101875:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101878:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010187c:	74 f2                	je     c0101870 <getchar+0x6>
        /* do nothing */;
    return c;
c010187e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101881:	c9                   	leave  
c0101882:	c3                   	ret    

c0101883 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0101883:	55                   	push   %ebp
c0101884:	89 e5                	mov    %esp,%ebp
c0101886:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0101889:	8b 45 0c             	mov    0xc(%ebp),%eax
c010188c:	8b 00                	mov    (%eax),%eax
c010188e:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0101891:	8b 45 10             	mov    0x10(%ebp),%eax
c0101894:	8b 00                	mov    (%eax),%eax
c0101896:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0101899:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01018a0:	e9 d2 00 00 00       	jmp    c0101977 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c01018a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01018a8:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01018ab:	01 d0                	add    %edx,%eax
c01018ad:	89 c2                	mov    %eax,%edx
c01018af:	c1 ea 1f             	shr    $0x1f,%edx
c01018b2:	01 d0                	add    %edx,%eax
c01018b4:	d1 f8                	sar    %eax
c01018b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01018b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01018bc:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01018bf:	eb 04                	jmp    c01018c5 <stab_binsearch+0x42>
            m --;
c01018c1:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01018c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01018c8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01018cb:	7c 1f                	jl     c01018ec <stab_binsearch+0x69>
c01018cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01018d0:	89 d0                	mov    %edx,%eax
c01018d2:	01 c0                	add    %eax,%eax
c01018d4:	01 d0                	add    %edx,%eax
c01018d6:	c1 e0 02             	shl    $0x2,%eax
c01018d9:	89 c2                	mov    %eax,%edx
c01018db:	8b 45 08             	mov    0x8(%ebp),%eax
c01018de:	01 d0                	add    %edx,%eax
c01018e0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01018e4:	0f b6 c0             	movzbl %al,%eax
c01018e7:	3b 45 14             	cmp    0x14(%ebp),%eax
c01018ea:	75 d5                	jne    c01018c1 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c01018ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01018ef:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01018f2:	7d 0b                	jge    c01018ff <stab_binsearch+0x7c>
            l = true_m + 1;
c01018f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01018f7:	83 c0 01             	add    $0x1,%eax
c01018fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c01018fd:	eb 78                	jmp    c0101977 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c01018ff:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0101906:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101909:	89 d0                	mov    %edx,%eax
c010190b:	01 c0                	add    %eax,%eax
c010190d:	01 d0                	add    %edx,%eax
c010190f:	c1 e0 02             	shl    $0x2,%eax
c0101912:	89 c2                	mov    %eax,%edx
c0101914:	8b 45 08             	mov    0x8(%ebp),%eax
c0101917:	01 d0                	add    %edx,%eax
c0101919:	8b 40 08             	mov    0x8(%eax),%eax
c010191c:	3b 45 18             	cmp    0x18(%ebp),%eax
c010191f:	73 13                	jae    c0101934 <stab_binsearch+0xb1>
            *region_left = m;
c0101921:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101924:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101927:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0101929:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010192c:	83 c0 01             	add    $0x1,%eax
c010192f:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0101932:	eb 43                	jmp    c0101977 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c0101934:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101937:	89 d0                	mov    %edx,%eax
c0101939:	01 c0                	add    %eax,%eax
c010193b:	01 d0                	add    %edx,%eax
c010193d:	c1 e0 02             	shl    $0x2,%eax
c0101940:	89 c2                	mov    %eax,%edx
c0101942:	8b 45 08             	mov    0x8(%ebp),%eax
c0101945:	01 d0                	add    %edx,%eax
c0101947:	8b 40 08             	mov    0x8(%eax),%eax
c010194a:	3b 45 18             	cmp    0x18(%ebp),%eax
c010194d:	76 16                	jbe    c0101965 <stab_binsearch+0xe2>
            *region_right = m - 1;
c010194f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101952:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101955:	8b 45 10             	mov    0x10(%ebp),%eax
c0101958:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c010195a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010195d:	83 e8 01             	sub    $0x1,%eax
c0101960:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0101963:	eb 12                	jmp    c0101977 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c0101965:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101968:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010196b:	89 10                	mov    %edx,(%eax)
            l = m;
c010196d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101970:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c0101973:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c0101977:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010197a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c010197d:	0f 8e 22 ff ff ff    	jle    c01018a5 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c0101983:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101987:	75 0f                	jne    c0101998 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c0101989:	8b 45 0c             	mov    0xc(%ebp),%eax
c010198c:	8b 00                	mov    (%eax),%eax
c010198e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101991:	8b 45 10             	mov    0x10(%ebp),%eax
c0101994:	89 10                	mov    %edx,(%eax)
c0101996:	eb 3f                	jmp    c01019d7 <stab_binsearch+0x154>
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c0101998:	8b 45 10             	mov    0x10(%ebp),%eax
c010199b:	8b 00                	mov    (%eax),%eax
c010199d:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01019a0:	eb 04                	jmp    c01019a6 <stab_binsearch+0x123>
c01019a2:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c01019a6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019a9:	8b 00                	mov    (%eax),%eax
c01019ab:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01019ae:	7d 1f                	jge    c01019cf <stab_binsearch+0x14c>
c01019b0:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01019b3:	89 d0                	mov    %edx,%eax
c01019b5:	01 c0                	add    %eax,%eax
c01019b7:	01 d0                	add    %edx,%eax
c01019b9:	c1 e0 02             	shl    $0x2,%eax
c01019bc:	89 c2                	mov    %eax,%edx
c01019be:	8b 45 08             	mov    0x8(%ebp),%eax
c01019c1:	01 d0                	add    %edx,%eax
c01019c3:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01019c7:	0f b6 c0             	movzbl %al,%eax
c01019ca:	3b 45 14             	cmp    0x14(%ebp),%eax
c01019cd:	75 d3                	jne    c01019a2 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c01019cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019d2:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01019d5:	89 10                	mov    %edx,(%eax)
    }
}
c01019d7:	c9                   	leave  
c01019d8:	c3                   	ret    

c01019d9 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c01019d9:	55                   	push   %ebp
c01019da:	89 e5                	mov    %esp,%ebp
c01019dc:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c01019df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019e2:	c7 00 c4 b6 10 c0    	movl   $0xc010b6c4,(%eax)
    info->eip_line = 0;
c01019e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019eb:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c01019f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019f5:	c7 40 08 c4 b6 10 c0 	movl   $0xc010b6c4,0x8(%eax)
    info->eip_fn_namelen = 9;
c01019fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019ff:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0101a06:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101a09:	8b 55 08             	mov    0x8(%ebp),%edx
c0101a0c:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0101a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101a12:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0101a19:	c7 45 f4 2c d9 10 c0 	movl   $0xc010d92c,-0xc(%ebp)
    stab_end = __STAB_END__;
c0101a20:	c7 45 f0 70 06 12 c0 	movl   $0xc0120670,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0101a27:	c7 45 ec 71 06 12 c0 	movl   $0xc0120671,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0101a2e:	c7 45 e8 76 53 12 c0 	movl   $0xc0125376,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0101a35:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101a38:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0101a3b:	76 0d                	jbe    c0101a4a <debuginfo_eip+0x71>
c0101a3d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101a40:	83 e8 01             	sub    $0x1,%eax
c0101a43:	0f b6 00             	movzbl (%eax),%eax
c0101a46:	84 c0                	test   %al,%al
c0101a48:	74 0a                	je     c0101a54 <debuginfo_eip+0x7b>
        return -1;
c0101a4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101a4f:	e9 c0 02 00 00       	jmp    c0101d14 <debuginfo_eip+0x33b>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0101a54:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0101a5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101a61:	29 c2                	sub    %eax,%edx
c0101a63:	89 d0                	mov    %edx,%eax
c0101a65:	c1 f8 02             	sar    $0x2,%eax
c0101a68:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c0101a6e:	83 e8 01             	sub    $0x1,%eax
c0101a71:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c0101a74:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a77:	89 44 24 10          	mov    %eax,0x10(%esp)
c0101a7b:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0101a82:	00 
c0101a83:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0101a86:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101a8a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0101a8d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101a94:	89 04 24             	mov    %eax,(%esp)
c0101a97:	e8 e7 fd ff ff       	call   c0101883 <stab_binsearch>
    if (lfile == 0)
c0101a9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101a9f:	85 c0                	test   %eax,%eax
c0101aa1:	75 0a                	jne    c0101aad <debuginfo_eip+0xd4>
        return -1;
c0101aa3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101aa8:	e9 67 02 00 00       	jmp    c0101d14 <debuginfo_eip+0x33b>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0101aad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101ab0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0101ab3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101ab6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0101ab9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101abc:	89 44 24 10          	mov    %eax,0x10(%esp)
c0101ac0:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0101ac7:	00 
c0101ac8:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0101acb:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101acf:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0101ad2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ad9:	89 04 24             	mov    %eax,(%esp)
c0101adc:	e8 a2 fd ff ff       	call   c0101883 <stab_binsearch>

    if (lfun <= rfun) {
c0101ae1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101ae4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101ae7:	39 c2                	cmp    %eax,%edx
c0101ae9:	7f 7c                	jg     c0101b67 <debuginfo_eip+0x18e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0101aeb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101aee:	89 c2                	mov    %eax,%edx
c0101af0:	89 d0                	mov    %edx,%eax
c0101af2:	01 c0                	add    %eax,%eax
c0101af4:	01 d0                	add    %edx,%eax
c0101af6:	c1 e0 02             	shl    $0x2,%eax
c0101af9:	89 c2                	mov    %eax,%edx
c0101afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101afe:	01 d0                	add    %edx,%eax
c0101b00:	8b 10                	mov    (%eax),%edx
c0101b02:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0101b05:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101b08:	29 c1                	sub    %eax,%ecx
c0101b0a:	89 c8                	mov    %ecx,%eax
c0101b0c:	39 c2                	cmp    %eax,%edx
c0101b0e:	73 22                	jae    c0101b32 <debuginfo_eip+0x159>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0101b10:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101b13:	89 c2                	mov    %eax,%edx
c0101b15:	89 d0                	mov    %edx,%eax
c0101b17:	01 c0                	add    %eax,%eax
c0101b19:	01 d0                	add    %edx,%eax
c0101b1b:	c1 e0 02             	shl    $0x2,%eax
c0101b1e:	89 c2                	mov    %eax,%edx
c0101b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b23:	01 d0                	add    %edx,%eax
c0101b25:	8b 10                	mov    (%eax),%edx
c0101b27:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101b2a:	01 c2                	add    %eax,%edx
c0101b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b2f:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0101b32:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101b35:	89 c2                	mov    %eax,%edx
c0101b37:	89 d0                	mov    %edx,%eax
c0101b39:	01 c0                	add    %eax,%eax
c0101b3b:	01 d0                	add    %edx,%eax
c0101b3d:	c1 e0 02             	shl    $0x2,%eax
c0101b40:	89 c2                	mov    %eax,%edx
c0101b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b45:	01 d0                	add    %edx,%eax
c0101b47:	8b 50 08             	mov    0x8(%eax),%edx
c0101b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b4d:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0101b50:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b53:	8b 40 10             	mov    0x10(%eax),%eax
c0101b56:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0101b59:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101b5c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0101b5f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101b62:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0101b65:	eb 15                	jmp    c0101b7c <debuginfo_eip+0x1a3>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0101b67:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b6a:	8b 55 08             	mov    0x8(%ebp),%edx
c0101b6d:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0101b70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101b73:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c0101b76:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0101b79:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c0101b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b7f:	8b 40 08             	mov    0x8(%eax),%eax
c0101b82:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c0101b89:	00 
c0101b8a:	89 04 24             	mov    %eax,(%esp)
c0101b8d:	e8 13 95 00 00       	call   c010b0a5 <strfind>
c0101b92:	89 c2                	mov    %eax,%edx
c0101b94:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b97:	8b 40 08             	mov    0x8(%eax),%eax
c0101b9a:	29 c2                	sub    %eax,%edx
c0101b9c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101b9f:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0101ba2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ba5:	89 44 24 10          	mov    %eax,0x10(%esp)
c0101ba9:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0101bb0:	00 
c0101bb1:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0101bb4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101bb8:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0101bbb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101bc2:	89 04 24             	mov    %eax,(%esp)
c0101bc5:	e8 b9 fc ff ff       	call   c0101883 <stab_binsearch>
    if (lline <= rline) {
c0101bca:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101bcd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101bd0:	39 c2                	cmp    %eax,%edx
c0101bd2:	7f 24                	jg     c0101bf8 <debuginfo_eip+0x21f>
        info->eip_line = stabs[rline].n_desc;
c0101bd4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101bd7:	89 c2                	mov    %eax,%edx
c0101bd9:	89 d0                	mov    %edx,%eax
c0101bdb:	01 c0                	add    %eax,%eax
c0101bdd:	01 d0                	add    %edx,%eax
c0101bdf:	c1 e0 02             	shl    $0x2,%eax
c0101be2:	89 c2                	mov    %eax,%edx
c0101be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101be7:	01 d0                	add    %edx,%eax
c0101be9:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0101bed:	0f b7 d0             	movzwl %ax,%edx
c0101bf0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101bf3:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0101bf6:	eb 13                	jmp    c0101c0b <debuginfo_eip+0x232>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0101bf8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101bfd:	e9 12 01 00 00       	jmp    c0101d14 <debuginfo_eip+0x33b>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0101c02:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c05:	83 e8 01             	sub    $0x1,%eax
c0101c08:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0101c0b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101c0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101c11:	39 c2                	cmp    %eax,%edx
c0101c13:	7c 56                	jl     c0101c6b <debuginfo_eip+0x292>
           && stabs[lline].n_type != N_SOL
c0101c15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c18:	89 c2                	mov    %eax,%edx
c0101c1a:	89 d0                	mov    %edx,%eax
c0101c1c:	01 c0                	add    %eax,%eax
c0101c1e:	01 d0                	add    %edx,%eax
c0101c20:	c1 e0 02             	shl    $0x2,%eax
c0101c23:	89 c2                	mov    %eax,%edx
c0101c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c28:	01 d0                	add    %edx,%eax
c0101c2a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101c2e:	3c 84                	cmp    $0x84,%al
c0101c30:	74 39                	je     c0101c6b <debuginfo_eip+0x292>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0101c32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c35:	89 c2                	mov    %eax,%edx
c0101c37:	89 d0                	mov    %edx,%eax
c0101c39:	01 c0                	add    %eax,%eax
c0101c3b:	01 d0                	add    %edx,%eax
c0101c3d:	c1 e0 02             	shl    $0x2,%eax
c0101c40:	89 c2                	mov    %eax,%edx
c0101c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c45:	01 d0                	add    %edx,%eax
c0101c47:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101c4b:	3c 64                	cmp    $0x64,%al
c0101c4d:	75 b3                	jne    c0101c02 <debuginfo_eip+0x229>
c0101c4f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c52:	89 c2                	mov    %eax,%edx
c0101c54:	89 d0                	mov    %edx,%eax
c0101c56:	01 c0                	add    %eax,%eax
c0101c58:	01 d0                	add    %edx,%eax
c0101c5a:	c1 e0 02             	shl    $0x2,%eax
c0101c5d:	89 c2                	mov    %eax,%edx
c0101c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c62:	01 d0                	add    %edx,%eax
c0101c64:	8b 40 08             	mov    0x8(%eax),%eax
c0101c67:	85 c0                	test   %eax,%eax
c0101c69:	74 97                	je     c0101c02 <debuginfo_eip+0x229>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0101c6b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101c6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101c71:	39 c2                	cmp    %eax,%edx
c0101c73:	7c 46                	jl     c0101cbb <debuginfo_eip+0x2e2>
c0101c75:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c78:	89 c2                	mov    %eax,%edx
c0101c7a:	89 d0                	mov    %edx,%eax
c0101c7c:	01 c0                	add    %eax,%eax
c0101c7e:	01 d0                	add    %edx,%eax
c0101c80:	c1 e0 02             	shl    $0x2,%eax
c0101c83:	89 c2                	mov    %eax,%edx
c0101c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c88:	01 d0                	add    %edx,%eax
c0101c8a:	8b 10                	mov    (%eax),%edx
c0101c8c:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0101c8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101c92:	29 c1                	sub    %eax,%ecx
c0101c94:	89 c8                	mov    %ecx,%eax
c0101c96:	39 c2                	cmp    %eax,%edx
c0101c98:	73 21                	jae    c0101cbb <debuginfo_eip+0x2e2>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0101c9a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101c9d:	89 c2                	mov    %eax,%edx
c0101c9f:	89 d0                	mov    %edx,%eax
c0101ca1:	01 c0                	add    %eax,%eax
c0101ca3:	01 d0                	add    %edx,%eax
c0101ca5:	c1 e0 02             	shl    $0x2,%eax
c0101ca8:	89 c2                	mov    %eax,%edx
c0101caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101cad:	01 d0                	add    %edx,%eax
c0101caf:	8b 10                	mov    (%eax),%edx
c0101cb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101cb4:	01 c2                	add    %eax,%edx
c0101cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cb9:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0101cbb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0101cbe:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0101cc1:	39 c2                	cmp    %eax,%edx
c0101cc3:	7d 4a                	jge    c0101d0f <debuginfo_eip+0x336>
        for (lline = lfun + 1;
c0101cc5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101cc8:	83 c0 01             	add    $0x1,%eax
c0101ccb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0101cce:	eb 18                	jmp    c0101ce8 <debuginfo_eip+0x30f>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0101cd0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cd3:	8b 40 14             	mov    0x14(%eax),%eax
c0101cd6:	8d 50 01             	lea    0x1(%eax),%edx
c0101cd9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cdc:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0101cdf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101ce2:	83 c0 01             	add    $0x1,%eax
c0101ce5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0101ce8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101ceb:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0101cee:	39 c2                	cmp    %eax,%edx
c0101cf0:	7d 1d                	jge    c0101d0f <debuginfo_eip+0x336>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0101cf2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101cf5:	89 c2                	mov    %eax,%edx
c0101cf7:	89 d0                	mov    %edx,%eax
c0101cf9:	01 c0                	add    %eax,%eax
c0101cfb:	01 d0                	add    %edx,%eax
c0101cfd:	c1 e0 02             	shl    $0x2,%eax
c0101d00:	89 c2                	mov    %eax,%edx
c0101d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101d05:	01 d0                	add    %edx,%eax
c0101d07:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0101d0b:	3c a0                	cmp    $0xa0,%al
c0101d0d:	74 c1                	je     c0101cd0 <debuginfo_eip+0x2f7>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0101d0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101d14:	c9                   	leave  
c0101d15:	c3                   	ret    

c0101d16 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0101d16:	55                   	push   %ebp
c0101d17:	89 e5                	mov    %esp,%ebp
c0101d19:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0101d1c:	c7 04 24 ce b6 10 c0 	movl   $0xc010b6ce,(%esp)
c0101d23:	e8 ba fa ff ff       	call   c01017e2 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0101d28:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0101d2f:	c0 
c0101d30:	c7 04 24 e7 b6 10 c0 	movl   $0xc010b6e7,(%esp)
c0101d37:	e8 a6 fa ff ff       	call   c01017e2 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0101d3c:	c7 44 24 04 ba b3 10 	movl   $0xc010b3ba,0x4(%esp)
c0101d43:	c0 
c0101d44:	c7 04 24 ff b6 10 c0 	movl   $0xc010b6ff,(%esp)
c0101d4b:	e8 92 fa ff ff       	call   c01017e2 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0101d50:	c7 44 24 04 00 b0 12 	movl   $0xc012b000,0x4(%esp)
c0101d57:	c0 
c0101d58:	c7 04 24 17 b7 10 c0 	movl   $0xc010b717,(%esp)
c0101d5f:	e8 7e fa ff ff       	call   c01017e2 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0101d64:	c7 44 24 04 78 e1 12 	movl   $0xc012e178,0x4(%esp)
c0101d6b:	c0 
c0101d6c:	c7 04 24 2f b7 10 c0 	movl   $0xc010b72f,(%esp)
c0101d73:	e8 6a fa ff ff       	call   c01017e2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c0101d78:	b8 78 e1 12 c0       	mov    $0xc012e178,%eax
c0101d7d:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0101d83:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0101d88:	29 c2                	sub    %eax,%edx
c0101d8a:	89 d0                	mov    %edx,%eax
c0101d8c:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0101d92:	85 c0                	test   %eax,%eax
c0101d94:	0f 48 c2             	cmovs  %edx,%eax
c0101d97:	c1 f8 0a             	sar    $0xa,%eax
c0101d9a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d9e:	c7 04 24 48 b7 10 c0 	movl   $0xc010b748,(%esp)
c0101da5:	e8 38 fa ff ff       	call   c01017e2 <cprintf>
}
c0101daa:	c9                   	leave  
c0101dab:	c3                   	ret    

c0101dac <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0101dac:	55                   	push   %ebp
c0101dad:	89 e5                	mov    %esp,%ebp
c0101daf:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0101db5:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0101db8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dbf:	89 04 24             	mov    %eax,(%esp)
c0101dc2:	e8 12 fc ff ff       	call   c01019d9 <debuginfo_eip>
c0101dc7:	85 c0                	test   %eax,%eax
c0101dc9:	74 15                	je     c0101de0 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dce:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dd2:	c7 04 24 72 b7 10 c0 	movl   $0xc010b772,(%esp)
c0101dd9:	e8 04 fa ff ff       	call   c01017e2 <cprintf>
c0101dde:	eb 6d                	jmp    c0101e4d <print_debuginfo+0xa1>
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0101de0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101de7:	eb 1c                	jmp    c0101e05 <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c0101de9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0101dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101def:	01 d0                	add    %edx,%eax
c0101df1:	0f b6 00             	movzbl (%eax),%eax
c0101df4:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0101dfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101dfd:	01 ca                	add    %ecx,%edx
c0101dff:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0101e01:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0101e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101e08:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0101e0b:	7f dc                	jg     c0101de9 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0101e0d:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0101e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101e16:	01 d0                	add    %edx,%eax
c0101e18:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0101e1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0101e1e:	8b 55 08             	mov    0x8(%ebp),%edx
c0101e21:	89 d1                	mov    %edx,%ecx
c0101e23:	29 c1                	sub    %eax,%ecx
c0101e25:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0101e28:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0101e2b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0101e2f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0101e35:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0101e39:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101e3d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e41:	c7 04 24 8e b7 10 c0 	movl   $0xc010b78e,(%esp)
c0101e48:	e8 95 f9 ff ff       	call   c01017e2 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0101e4d:	c9                   	leave  
c0101e4e:	c3                   	ret    

c0101e4f <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0101e4f:	55                   	push   %ebp
c0101e50:	89 e5                	mov    %esp,%ebp
c0101e52:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0101e55:	8b 45 04             	mov    0x4(%ebp),%eax
c0101e58:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0101e5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101e5e:	c9                   	leave  
c0101e5f:	c3                   	ret    

c0101e60 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0101e60:	55                   	push   %ebp
c0101e61:	89 e5                	mov    %esp,%ebp
c0101e63:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0101e66:	89 e8                	mov    %ebp,%eax
c0101e68:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0101e6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0101e6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101e71:	e8 d9 ff ff ff       	call   c0101e4f <read_eip>
c0101e76:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0101e79:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101e80:	e9 88 00 00 00       	jmp    c0101f0d <print_stackframe+0xad>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0101e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101e88:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101e8f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e93:	c7 04 24 a0 b7 10 c0 	movl   $0xc010b7a0,(%esp)
c0101e9a:	e8 43 f9 ff ff       	call   c01017e2 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
c0101e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ea2:	83 c0 08             	add    $0x8,%eax
c0101ea5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0101ea8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0101eaf:	eb 25                	jmp    c0101ed6 <print_stackframe+0x76>
            cprintf("0x%08x ", args[j]);
c0101eb1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101eb4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101ebb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101ebe:	01 d0                	add    %edx,%eax
c0101ec0:	8b 00                	mov    (%eax),%eax
c0101ec2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ec6:	c7 04 24 bc b7 10 c0 	movl   $0xc010b7bc,(%esp)
c0101ecd:	e8 10 f9 ff ff       	call   c01017e2 <cprintf>

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
c0101ed2:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0101ed6:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0101eda:	7e d5                	jle    c0101eb1 <print_stackframe+0x51>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
c0101edc:	c7 04 24 c4 b7 10 c0 	movl   $0xc010b7c4,(%esp)
c0101ee3:	e8 fa f8 ff ff       	call   c01017e2 <cprintf>
        print_debuginfo(eip - 1);
c0101ee8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101eeb:	83 e8 01             	sub    $0x1,%eax
c0101eee:	89 04 24             	mov    %eax,(%esp)
c0101ef1:	e8 b6 fe ff ff       	call   c0101dac <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0101ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ef9:	83 c0 04             	add    $0x4,%eax
c0101efc:	8b 00                	mov    (%eax),%eax
c0101efe:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0101f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101f04:	8b 00                	mov    (%eax),%eax
c0101f06:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0101f09:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0101f0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101f11:	74 0a                	je     c0101f1d <print_stackframe+0xbd>
c0101f13:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0101f17:	0f 8e 68 ff ff ff    	jle    c0101e85 <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0101f1d:	c9                   	leave  
c0101f1e:	c3                   	ret    

c0101f1f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0101f1f:	55                   	push   %ebp
c0101f20:	89 e5                	mov    %esp,%ebp
c0101f22:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0101f25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0101f2c:	eb 0c                	jmp    c0101f3a <parse+0x1b>
            *buf ++ = '\0';
c0101f2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f31:	8d 50 01             	lea    0x1(%eax),%edx
c0101f34:	89 55 08             	mov    %edx,0x8(%ebp)
c0101f37:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0101f3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f3d:	0f b6 00             	movzbl (%eax),%eax
c0101f40:	84 c0                	test   %al,%al
c0101f42:	74 1d                	je     c0101f61 <parse+0x42>
c0101f44:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f47:	0f b6 00             	movzbl (%eax),%eax
c0101f4a:	0f be c0             	movsbl %al,%eax
c0101f4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101f51:	c7 04 24 48 b8 10 c0 	movl   $0xc010b848,(%esp)
c0101f58:	e8 15 91 00 00       	call   c010b072 <strchr>
c0101f5d:	85 c0                	test   %eax,%eax
c0101f5f:	75 cd                	jne    c0101f2e <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0101f61:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f64:	0f b6 00             	movzbl (%eax),%eax
c0101f67:	84 c0                	test   %al,%al
c0101f69:	75 02                	jne    c0101f6d <parse+0x4e>
            break;
c0101f6b:	eb 67                	jmp    c0101fd4 <parse+0xb5>
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0101f6d:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0101f71:	75 14                	jne    c0101f87 <parse+0x68>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0101f73:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0101f7a:	00 
c0101f7b:	c7 04 24 4d b8 10 c0 	movl   $0xc010b84d,(%esp)
c0101f82:	e8 5b f8 ff ff       	call   c01017e2 <cprintf>
        }
        argv[argc ++] = buf;
c0101f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101f8a:	8d 50 01             	lea    0x1(%eax),%edx
c0101f8d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0101f90:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101f97:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101f9a:	01 c2                	add    %eax,%edx
c0101f9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f9f:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0101fa1:	eb 04                	jmp    c0101fa7 <parse+0x88>
            buf ++;
c0101fa3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0101fa7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101faa:	0f b6 00             	movzbl (%eax),%eax
c0101fad:	84 c0                	test   %al,%al
c0101faf:	74 1d                	je     c0101fce <parse+0xaf>
c0101fb1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fb4:	0f b6 00             	movzbl (%eax),%eax
c0101fb7:	0f be c0             	movsbl %al,%eax
c0101fba:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101fbe:	c7 04 24 48 b8 10 c0 	movl   $0xc010b848,(%esp)
c0101fc5:	e8 a8 90 00 00       	call   c010b072 <strchr>
c0101fca:	85 c0                	test   %eax,%eax
c0101fcc:	74 d5                	je     c0101fa3 <parse+0x84>
            buf ++;
        }
    }
c0101fce:	90                   	nop
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0101fcf:	e9 66 ff ff ff       	jmp    c0101f3a <parse+0x1b>
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0101fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101fd7:	c9                   	leave  
c0101fd8:	c3                   	ret    

c0101fd9 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0101fd9:	55                   	push   %ebp
c0101fda:	89 e5                	mov    %esp,%ebp
c0101fdc:	83 ec 68             	sub    $0x68,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0101fdf:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0101fe2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101fe6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fe9:	89 04 24             	mov    %eax,(%esp)
c0101fec:	e8 2e ff ff ff       	call   c0101f1f <parse>
c0101ff1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0101ff4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0101ff8:	75 0a                	jne    c0102004 <runcmd+0x2b>
        return 0;
c0101ffa:	b8 00 00 00 00       	mov    $0x0,%eax
c0101fff:	e9 85 00 00 00       	jmp    c0102089 <runcmd+0xb0>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0102004:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010200b:	eb 5c                	jmp    c0102069 <runcmd+0x90>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c010200d:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0102010:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102013:	89 d0                	mov    %edx,%eax
c0102015:	01 c0                	add    %eax,%eax
c0102017:	01 d0                	add    %edx,%eax
c0102019:	c1 e0 02             	shl    $0x2,%eax
c010201c:	05 00 80 12 c0       	add    $0xc0128000,%eax
c0102021:	8b 00                	mov    (%eax),%eax
c0102023:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102027:	89 04 24             	mov    %eax,(%esp)
c010202a:	e8 a4 8f 00 00       	call   c010afd3 <strcmp>
c010202f:	85 c0                	test   %eax,%eax
c0102031:	75 32                	jne    c0102065 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0102033:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102036:	89 d0                	mov    %edx,%eax
c0102038:	01 c0                	add    %eax,%eax
c010203a:	01 d0                	add    %edx,%eax
c010203c:	c1 e0 02             	shl    $0x2,%eax
c010203f:	05 00 80 12 c0       	add    $0xc0128000,%eax
c0102044:	8b 40 08             	mov    0x8(%eax),%eax
c0102047:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010204a:	8d 4a ff             	lea    -0x1(%edx),%ecx
c010204d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102050:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102054:	8d 55 b0             	lea    -0x50(%ebp),%edx
c0102057:	83 c2 04             	add    $0x4,%edx
c010205a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010205e:	89 0c 24             	mov    %ecx,(%esp)
c0102061:	ff d0                	call   *%eax
c0102063:	eb 24                	jmp    c0102089 <runcmd+0xb0>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0102065:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102069:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010206c:	83 f8 02             	cmp    $0x2,%eax
c010206f:	76 9c                	jbe    c010200d <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0102071:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102074:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102078:	c7 04 24 6b b8 10 c0 	movl   $0xc010b86b,(%esp)
c010207f:	e8 5e f7 ff ff       	call   c01017e2 <cprintf>
    return 0;
c0102084:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102089:	c9                   	leave  
c010208a:	c3                   	ret    

c010208b <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c010208b:	55                   	push   %ebp
c010208c:	89 e5                	mov    %esp,%ebp
c010208e:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0102091:	c7 04 24 84 b8 10 c0 	movl   $0xc010b884,(%esp)
c0102098:	e8 45 f7 ff ff       	call   c01017e2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c010209d:	c7 04 24 ac b8 10 c0 	movl   $0xc010b8ac,(%esp)
c01020a4:	e8 39 f7 ff ff       	call   c01017e2 <cprintf>

    if (tf != NULL) {
c01020a9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01020ad:	74 0b                	je     c01020ba <kmonitor+0x2f>
        print_trapframe(tf);
c01020af:	8b 45 08             	mov    0x8(%ebp),%eax
c01020b2:	89 04 24             	mov    %eax,(%esp)
c01020b5:	e8 5d 16 00 00       	call   c0103717 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c01020ba:	c7 04 24 d1 b8 10 c0 	movl   $0xc010b8d1,(%esp)
c01020c1:	e8 13 f6 ff ff       	call   c01016d9 <readline>
c01020c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01020c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01020cd:	74 18                	je     c01020e7 <kmonitor+0x5c>
            if (runcmd(buf, tf) < 0) {
c01020cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01020d2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01020d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01020d9:	89 04 24             	mov    %eax,(%esp)
c01020dc:	e8 f8 fe ff ff       	call   c0101fd9 <runcmd>
c01020e1:	85 c0                	test   %eax,%eax
c01020e3:	79 02                	jns    c01020e7 <kmonitor+0x5c>
                break;
c01020e5:	eb 02                	jmp    c01020e9 <kmonitor+0x5e>
            }
        }
    }
c01020e7:	eb d1                	jmp    c01020ba <kmonitor+0x2f>
}
c01020e9:	c9                   	leave  
c01020ea:	c3                   	ret    

c01020eb <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c01020eb:	55                   	push   %ebp
c01020ec:	89 e5                	mov    %esp,%ebp
c01020ee:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c01020f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01020f8:	eb 3f                	jmp    c0102139 <mon_help+0x4e>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c01020fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01020fd:	89 d0                	mov    %edx,%eax
c01020ff:	01 c0                	add    %eax,%eax
c0102101:	01 d0                	add    %edx,%eax
c0102103:	c1 e0 02             	shl    $0x2,%eax
c0102106:	05 00 80 12 c0       	add    $0xc0128000,%eax
c010210b:	8b 48 04             	mov    0x4(%eax),%ecx
c010210e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102111:	89 d0                	mov    %edx,%eax
c0102113:	01 c0                	add    %eax,%eax
c0102115:	01 d0                	add    %edx,%eax
c0102117:	c1 e0 02             	shl    $0x2,%eax
c010211a:	05 00 80 12 c0       	add    $0xc0128000,%eax
c010211f:	8b 00                	mov    (%eax),%eax
c0102121:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0102125:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102129:	c7 04 24 d5 b8 10 c0 	movl   $0xc010b8d5,(%esp)
c0102130:	e8 ad f6 ff ff       	call   c01017e2 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0102135:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102139:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010213c:	83 f8 02             	cmp    $0x2,%eax
c010213f:	76 b9                	jbe    c01020fa <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0102141:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102146:	c9                   	leave  
c0102147:	c3                   	ret    

c0102148 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0102148:	55                   	push   %ebp
c0102149:	89 e5                	mov    %esp,%ebp
c010214b:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c010214e:	e8 c3 fb ff ff       	call   c0101d16 <print_kerninfo>
    return 0;
c0102153:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102158:	c9                   	leave  
c0102159:	c3                   	ret    

c010215a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c010215a:	55                   	push   %ebp
c010215b:	89 e5                	mov    %esp,%ebp
c010215d:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0102160:	e8 fb fc ff ff       	call   c0101e60 <print_stackframe>
    return 0;
c0102165:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010216a:	c9                   	leave  
c010216b:	c3                   	ret    

c010216c <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c010216c:	55                   	push   %ebp
c010216d:	89 e5                	mov    %esp,%ebp
c010216f:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0102172:	a1 20 b4 12 c0       	mov    0xc012b420,%eax
c0102177:	85 c0                	test   %eax,%eax
c0102179:	74 02                	je     c010217d <__panic+0x11>
        goto panic_dead;
c010217b:	eb 59                	jmp    c01021d6 <__panic+0x6a>
    }
    is_panic = 1;
c010217d:	c7 05 20 b4 12 c0 01 	movl   $0x1,0xc012b420
c0102184:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0102187:	8d 45 14             	lea    0x14(%ebp),%eax
c010218a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c010218d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102190:	89 44 24 08          	mov    %eax,0x8(%esp)
c0102194:	8b 45 08             	mov    0x8(%ebp),%eax
c0102197:	89 44 24 04          	mov    %eax,0x4(%esp)
c010219b:	c7 04 24 de b8 10 c0 	movl   $0xc010b8de,(%esp)
c01021a2:	e8 3b f6 ff ff       	call   c01017e2 <cprintf>
    vcprintf(fmt, ap);
c01021a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01021aa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01021ae:	8b 45 10             	mov    0x10(%ebp),%eax
c01021b1:	89 04 24             	mov    %eax,(%esp)
c01021b4:	e8 f6 f5 ff ff       	call   c01017af <vcprintf>
    cprintf("\n");
c01021b9:	c7 04 24 fa b8 10 c0 	movl   $0xc010b8fa,(%esp)
c01021c0:	e8 1d f6 ff ff       	call   c01017e2 <cprintf>
    
    cprintf("stack trackback:\n");
c01021c5:	c7 04 24 fc b8 10 c0 	movl   $0xc010b8fc,(%esp)
c01021cc:	e8 11 f6 ff ff       	call   c01017e2 <cprintf>
    print_stackframe();
c01021d1:	e8 8a fc ff ff       	call   c0101e60 <print_stackframe>
    
    va_end(ap);

panic_dead:
    intr_disable();
c01021d6:	e8 fa 11 00 00       	call   c01033d5 <intr_disable>
    while (1) {
        kmonitor(NULL);
c01021db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01021e2:	e8 a4 fe ff ff       	call   c010208b <kmonitor>
    }
c01021e7:	eb f2                	jmp    c01021db <__panic+0x6f>

c01021e9 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c01021e9:	55                   	push   %ebp
c01021ea:	89 e5                	mov    %esp,%ebp
c01021ec:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c01021ef:	8d 45 14             	lea    0x14(%ebp),%eax
c01021f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c01021f5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01021f8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01021fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01021ff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102203:	c7 04 24 0e b9 10 c0 	movl   $0xc010b90e,(%esp)
c010220a:	e8 d3 f5 ff ff       	call   c01017e2 <cprintf>
    vcprintf(fmt, ap);
c010220f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102212:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102216:	8b 45 10             	mov    0x10(%ebp),%eax
c0102219:	89 04 24             	mov    %eax,(%esp)
c010221c:	e8 8e f5 ff ff       	call   c01017af <vcprintf>
    cprintf("\n");
c0102221:	c7 04 24 fa b8 10 c0 	movl   $0xc010b8fa,(%esp)
c0102228:	e8 b5 f5 ff ff       	call   c01017e2 <cprintf>
    va_end(ap);
}
c010222d:	c9                   	leave  
c010222e:	c3                   	ret    

c010222f <is_kernel_panic>:

bool
is_kernel_panic(void) {
c010222f:	55                   	push   %ebp
c0102230:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0102232:	a1 20 b4 12 c0       	mov    0xc012b420,%eax
}
c0102237:	5d                   	pop    %ebp
c0102238:	c3                   	ret    

c0102239 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0102239:	55                   	push   %ebp
c010223a:	89 e5                	mov    %esp,%ebp
c010223c:	83 ec 28             	sub    $0x28,%esp
c010223f:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0102245:	c6 45 f5 34          	movb   $0x34,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102249:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010224d:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102251:	ee                   	out    %al,(%dx)
c0102252:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0102258:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
c010225c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102260:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102264:	ee                   	out    %al,(%dx)
c0102265:	66 c7 45 ee 40 00    	movw   $0x40,-0x12(%ebp)
c010226b:	c6 45 ed 2e          	movb   $0x2e,-0x13(%ebp)
c010226f:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102273:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102277:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0102278:	c7 05 74 e0 12 c0 00 	movl   $0x0,0xc012e074
c010227f:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0102282:	c7 04 24 2c b9 10 c0 	movl   $0xc010b92c,(%esp)
c0102289:	e8 54 f5 ff ff       	call   c01017e2 <cprintf>
    pic_enable(IRQ_TIMER);
c010228e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0102295:	e8 99 11 00 00       	call   c0103433 <pic_enable>
}
c010229a:	c9                   	leave  
c010229b:	c3                   	ret    

c010229c <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c010229c:	55                   	push   %ebp
c010229d:	89 e5                	mov    %esp,%ebp
c010229f:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01022a2:	9c                   	pushf  
c01022a3:	58                   	pop    %eax
c01022a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01022a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01022aa:	25 00 02 00 00       	and    $0x200,%eax
c01022af:	85 c0                	test   %eax,%eax
c01022b1:	74 0c                	je     c01022bf <__intr_save+0x23>
        intr_disable();
c01022b3:	e8 1d 11 00 00       	call   c01033d5 <intr_disable>
        return 1;
c01022b8:	b8 01 00 00 00       	mov    $0x1,%eax
c01022bd:	eb 05                	jmp    c01022c4 <__intr_save+0x28>
    }
    return 0;
c01022bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01022c4:	c9                   	leave  
c01022c5:	c3                   	ret    

c01022c6 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01022c6:	55                   	push   %ebp
c01022c7:	89 e5                	mov    %esp,%ebp
c01022c9:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01022cc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01022d0:	74 05                	je     c01022d7 <__intr_restore+0x11>
        intr_enable();
c01022d2:	e8 f8 10 00 00       	call   c01033cf <intr_enable>
    }
}
c01022d7:	c9                   	leave  
c01022d8:	c3                   	ret    

c01022d9 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c01022d9:	55                   	push   %ebp
c01022da:	89 e5                	mov    %esp,%ebp
c01022dc:	83 ec 10             	sub    $0x10,%esp
c01022df:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01022e5:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01022e9:	89 c2                	mov    %eax,%edx
c01022eb:	ec                   	in     (%dx),%al
c01022ec:	88 45 fd             	mov    %al,-0x3(%ebp)
c01022ef:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c01022f5:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01022f9:	89 c2                	mov    %eax,%edx
c01022fb:	ec                   	in     (%dx),%al
c01022fc:	88 45 f9             	mov    %al,-0x7(%ebp)
c01022ff:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0102305:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102309:	89 c2                	mov    %eax,%edx
c010230b:	ec                   	in     (%dx),%al
c010230c:	88 45 f5             	mov    %al,-0xb(%ebp)
c010230f:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
c0102315:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0102319:	89 c2                	mov    %eax,%edx
c010231b:	ec                   	in     (%dx),%al
c010231c:	88 45 f1             	mov    %al,-0xf(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c010231f:	c9                   	leave  
c0102320:	c3                   	ret    

c0102321 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0102321:	55                   	push   %ebp
c0102322:	89 e5                	mov    %esp,%ebp
c0102324:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0102327:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c010232e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102331:	0f b7 00             	movzwl (%eax),%eax
c0102334:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0102338:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010233b:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0102340:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102343:	0f b7 00             	movzwl (%eax),%eax
c0102346:	66 3d 5a a5          	cmp    $0xa55a,%ax
c010234a:	74 12                	je     c010235e <cga_init+0x3d>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c010234c:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0102353:	66 c7 05 46 b4 12 c0 	movw   $0x3b4,0xc012b446
c010235a:	b4 03 
c010235c:	eb 13                	jmp    c0102371 <cga_init+0x50>
    } else {
        *cp = was;
c010235e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102361:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0102365:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0102368:	66 c7 05 46 b4 12 c0 	movw   $0x3d4,0xc012b446
c010236f:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0102371:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c0102378:	0f b7 c0             	movzwl %ax,%eax
c010237b:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010237f:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102383:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102387:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010238b:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c010238c:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c0102393:	83 c0 01             	add    $0x1,%eax
c0102396:	0f b7 c0             	movzwl %ax,%eax
c0102399:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010239d:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c01023a1:	89 c2                	mov    %eax,%edx
c01023a3:	ec                   	in     (%dx),%al
c01023a4:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c01023a7:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01023ab:	0f b6 c0             	movzbl %al,%eax
c01023ae:	c1 e0 08             	shl    $0x8,%eax
c01023b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c01023b4:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c01023bb:	0f b7 c0             	movzwl %ax,%eax
c01023be:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01023c2:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01023c6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01023ca:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01023ce:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c01023cf:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c01023d6:	83 c0 01             	add    $0x1,%eax
c01023d9:	0f b7 c0             	movzwl %ax,%eax
c01023dc:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01023e0:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c01023e4:	89 c2                	mov    %eax,%edx
c01023e6:	ec                   	in     (%dx),%al
c01023e7:	88 45 e5             	mov    %al,-0x1b(%ebp)
    return data;
c01023ea:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01023ee:	0f b6 c0             	movzbl %al,%eax
c01023f1:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c01023f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01023f7:	a3 40 b4 12 c0       	mov    %eax,0xc012b440
    crt_pos = pos;
c01023fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01023ff:	66 a3 44 b4 12 c0    	mov    %ax,0xc012b444
}
c0102405:	c9                   	leave  
c0102406:	c3                   	ret    

c0102407 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0102407:	55                   	push   %ebp
c0102408:	89 e5                	mov    %esp,%ebp
c010240a:	83 ec 48             	sub    $0x48,%esp
c010240d:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0102413:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102417:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010241b:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010241f:	ee                   	out    %al,(%dx)
c0102420:	66 c7 45 f2 fb 03    	movw   $0x3fb,-0xe(%ebp)
c0102426:	c6 45 f1 80          	movb   $0x80,-0xf(%ebp)
c010242a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010242e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102432:	ee                   	out    %al,(%dx)
c0102433:	66 c7 45 ee f8 03    	movw   $0x3f8,-0x12(%ebp)
c0102439:	c6 45 ed 0c          	movb   $0xc,-0x13(%ebp)
c010243d:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102441:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102445:	ee                   	out    %al,(%dx)
c0102446:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c010244c:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c0102450:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102454:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102458:	ee                   	out    %al,(%dx)
c0102459:	66 c7 45 e6 fb 03    	movw   $0x3fb,-0x1a(%ebp)
c010245f:	c6 45 e5 03          	movb   $0x3,-0x1b(%ebp)
c0102463:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0102467:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010246b:	ee                   	out    %al,(%dx)
c010246c:	66 c7 45 e2 fc 03    	movw   $0x3fc,-0x1e(%ebp)
c0102472:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c0102476:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010247a:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010247e:	ee                   	out    %al,(%dx)
c010247f:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0102485:	c6 45 dd 01          	movb   $0x1,-0x23(%ebp)
c0102489:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010248d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0102491:	ee                   	out    %al,(%dx)
c0102492:	66 c7 45 da fd 03    	movw   $0x3fd,-0x26(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102498:	0f b7 45 da          	movzwl -0x26(%ebp),%eax
c010249c:	89 c2                	mov    %eax,%edx
c010249e:	ec                   	in     (%dx),%al
c010249f:	88 45 d9             	mov    %al,-0x27(%ebp)
    return data;
c01024a2:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c01024a6:	3c ff                	cmp    $0xff,%al
c01024a8:	0f 95 c0             	setne  %al
c01024ab:	0f b6 c0             	movzbl %al,%eax
c01024ae:	a3 48 b4 12 c0       	mov    %eax,0xc012b448
c01024b3:	66 c7 45 d6 fa 03    	movw   $0x3fa,-0x2a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01024b9:	0f b7 45 d6          	movzwl -0x2a(%ebp),%eax
c01024bd:	89 c2                	mov    %eax,%edx
c01024bf:	ec                   	in     (%dx),%al
c01024c0:	88 45 d5             	mov    %al,-0x2b(%ebp)
c01024c3:	66 c7 45 d2 f8 03    	movw   $0x3f8,-0x2e(%ebp)
c01024c9:	0f b7 45 d2          	movzwl -0x2e(%ebp),%eax
c01024cd:	89 c2                	mov    %eax,%edx
c01024cf:	ec                   	in     (%dx),%al
c01024d0:	88 45 d1             	mov    %al,-0x2f(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c01024d3:	a1 48 b4 12 c0       	mov    0xc012b448,%eax
c01024d8:	85 c0                	test   %eax,%eax
c01024da:	74 0c                	je     c01024e8 <serial_init+0xe1>
        pic_enable(IRQ_COM1);
c01024dc:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01024e3:	e8 4b 0f 00 00       	call   c0103433 <pic_enable>
    }
}
c01024e8:	c9                   	leave  
c01024e9:	c3                   	ret    

c01024ea <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01024ea:	55                   	push   %ebp
c01024eb:	89 e5                	mov    %esp,%ebp
c01024ed:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01024f0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01024f7:	eb 09                	jmp    c0102502 <lpt_putc_sub+0x18>
        delay();
c01024f9:	e8 db fd ff ff       	call   c01022d9 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01024fe:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102502:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c0102508:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010250c:	89 c2                	mov    %eax,%edx
c010250e:	ec                   	in     (%dx),%al
c010250f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0102512:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102516:	84 c0                	test   %al,%al
c0102518:	78 09                	js     c0102523 <lpt_putc_sub+0x39>
c010251a:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0102521:	7e d6                	jle    c01024f9 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0102523:	8b 45 08             	mov    0x8(%ebp),%eax
c0102526:	0f b6 c0             	movzbl %al,%eax
c0102529:	66 c7 45 f6 78 03    	movw   $0x378,-0xa(%ebp)
c010252f:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102532:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0102536:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010253a:	ee                   	out    %al,(%dx)
c010253b:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0102541:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0102545:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0102549:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010254d:	ee                   	out    %al,(%dx)
c010254e:	66 c7 45 ee 7a 03    	movw   $0x37a,-0x12(%ebp)
c0102554:	c6 45 ed 08          	movb   $0x8,-0x13(%ebp)
c0102558:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010255c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0102560:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0102561:	c9                   	leave  
c0102562:	c3                   	ret    

c0102563 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0102563:	55                   	push   %ebp
c0102564:	89 e5                	mov    %esp,%ebp
c0102566:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0102569:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010256d:	74 0d                	je     c010257c <lpt_putc+0x19>
        lpt_putc_sub(c);
c010256f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102572:	89 04 24             	mov    %eax,(%esp)
c0102575:	e8 70 ff ff ff       	call   c01024ea <lpt_putc_sub>
c010257a:	eb 24                	jmp    c01025a0 <lpt_putc+0x3d>
    }
    else {
        lpt_putc_sub('\b');
c010257c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0102583:	e8 62 ff ff ff       	call   c01024ea <lpt_putc_sub>
        lpt_putc_sub(' ');
c0102588:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010258f:	e8 56 ff ff ff       	call   c01024ea <lpt_putc_sub>
        lpt_putc_sub('\b');
c0102594:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010259b:	e8 4a ff ff ff       	call   c01024ea <lpt_putc_sub>
    }
}
c01025a0:	c9                   	leave  
c01025a1:	c3                   	ret    

c01025a2 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c01025a2:	55                   	push   %ebp
c01025a3:	89 e5                	mov    %esp,%ebp
c01025a5:	53                   	push   %ebx
c01025a6:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01025a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01025ac:	b0 00                	mov    $0x0,%al
c01025ae:	85 c0                	test   %eax,%eax
c01025b0:	75 07                	jne    c01025b9 <cga_putc+0x17>
        c |= 0x0700;
c01025b2:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c01025b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01025bc:	0f b6 c0             	movzbl %al,%eax
c01025bf:	83 f8 0a             	cmp    $0xa,%eax
c01025c2:	74 4c                	je     c0102610 <cga_putc+0x6e>
c01025c4:	83 f8 0d             	cmp    $0xd,%eax
c01025c7:	74 57                	je     c0102620 <cga_putc+0x7e>
c01025c9:	83 f8 08             	cmp    $0x8,%eax
c01025cc:	0f 85 88 00 00 00    	jne    c010265a <cga_putc+0xb8>
    case '\b':
        if (crt_pos > 0) {
c01025d2:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c01025d9:	66 85 c0             	test   %ax,%ax
c01025dc:	74 30                	je     c010260e <cga_putc+0x6c>
            crt_pos --;
c01025de:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c01025e5:	83 e8 01             	sub    $0x1,%eax
c01025e8:	66 a3 44 b4 12 c0    	mov    %ax,0xc012b444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01025ee:	a1 40 b4 12 c0       	mov    0xc012b440,%eax
c01025f3:	0f b7 15 44 b4 12 c0 	movzwl 0xc012b444,%edx
c01025fa:	0f b7 d2             	movzwl %dx,%edx
c01025fd:	01 d2                	add    %edx,%edx
c01025ff:	01 c2                	add    %eax,%edx
c0102601:	8b 45 08             	mov    0x8(%ebp),%eax
c0102604:	b0 00                	mov    $0x0,%al
c0102606:	83 c8 20             	or     $0x20,%eax
c0102609:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c010260c:	eb 72                	jmp    c0102680 <cga_putc+0xde>
c010260e:	eb 70                	jmp    c0102680 <cga_putc+0xde>
    case '\n':
        crt_pos += CRT_COLS;
c0102610:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c0102617:	83 c0 50             	add    $0x50,%eax
c010261a:	66 a3 44 b4 12 c0    	mov    %ax,0xc012b444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c0102620:	0f b7 1d 44 b4 12 c0 	movzwl 0xc012b444,%ebx
c0102627:	0f b7 0d 44 b4 12 c0 	movzwl 0xc012b444,%ecx
c010262e:	0f b7 c1             	movzwl %cx,%eax
c0102631:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
c0102637:	c1 e8 10             	shr    $0x10,%eax
c010263a:	89 c2                	mov    %eax,%edx
c010263c:	66 c1 ea 06          	shr    $0x6,%dx
c0102640:	89 d0                	mov    %edx,%eax
c0102642:	c1 e0 02             	shl    $0x2,%eax
c0102645:	01 d0                	add    %edx,%eax
c0102647:	c1 e0 04             	shl    $0x4,%eax
c010264a:	29 c1                	sub    %eax,%ecx
c010264c:	89 ca                	mov    %ecx,%edx
c010264e:	89 d8                	mov    %ebx,%eax
c0102650:	29 d0                	sub    %edx,%eax
c0102652:	66 a3 44 b4 12 c0    	mov    %ax,0xc012b444
        break;
c0102658:	eb 26                	jmp    c0102680 <cga_putc+0xde>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c010265a:	8b 0d 40 b4 12 c0    	mov    0xc012b440,%ecx
c0102660:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c0102667:	8d 50 01             	lea    0x1(%eax),%edx
c010266a:	66 89 15 44 b4 12 c0 	mov    %dx,0xc012b444
c0102671:	0f b7 c0             	movzwl %ax,%eax
c0102674:	01 c0                	add    %eax,%eax
c0102676:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0102679:	8b 45 08             	mov    0x8(%ebp),%eax
c010267c:	66 89 02             	mov    %ax,(%edx)
        break;
c010267f:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0102680:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c0102687:	66 3d cf 07          	cmp    $0x7cf,%ax
c010268b:	76 5b                	jbe    c01026e8 <cga_putc+0x146>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c010268d:	a1 40 b4 12 c0       	mov    0xc012b440,%eax
c0102692:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0102698:	a1 40 b4 12 c0       	mov    0xc012b440,%eax
c010269d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c01026a4:	00 
c01026a5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01026a9:	89 04 24             	mov    %eax,(%esp)
c01026ac:	e8 bf 8b 00 00       	call   c010b270 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01026b1:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c01026b8:	eb 15                	jmp    c01026cf <cga_putc+0x12d>
            crt_buf[i] = 0x0700 | ' ';
c01026ba:	a1 40 b4 12 c0       	mov    0xc012b440,%eax
c01026bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01026c2:	01 d2                	add    %edx,%edx
c01026c4:	01 d0                	add    %edx,%eax
c01026c6:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01026cb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01026cf:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c01026d6:	7e e2                	jle    c01026ba <cga_putc+0x118>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c01026d8:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c01026df:	83 e8 50             	sub    $0x50,%eax
c01026e2:	66 a3 44 b4 12 c0    	mov    %ax,0xc012b444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01026e8:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c01026ef:	0f b7 c0             	movzwl %ax,%eax
c01026f2:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c01026f6:	c6 45 f1 0e          	movb   $0xe,-0xf(%ebp)
c01026fa:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01026fe:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102702:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0102703:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c010270a:	66 c1 e8 08          	shr    $0x8,%ax
c010270e:	0f b6 c0             	movzbl %al,%eax
c0102711:	0f b7 15 46 b4 12 c0 	movzwl 0xc012b446,%edx
c0102718:	83 c2 01             	add    $0x1,%edx
c010271b:	0f b7 d2             	movzwl %dx,%edx
c010271e:	66 89 55 ee          	mov    %dx,-0x12(%ebp)
c0102722:	88 45 ed             	mov    %al,-0x13(%ebp)
c0102725:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0102729:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010272d:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c010272e:	0f b7 05 46 b4 12 c0 	movzwl 0xc012b446,%eax
c0102735:	0f b7 c0             	movzwl %ax,%eax
c0102738:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c010273c:	c6 45 e9 0f          	movb   $0xf,-0x17(%ebp)
c0102740:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0102744:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102748:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0102749:	0f b7 05 44 b4 12 c0 	movzwl 0xc012b444,%eax
c0102750:	0f b6 c0             	movzbl %al,%eax
c0102753:	0f b7 15 46 b4 12 c0 	movzwl 0xc012b446,%edx
c010275a:	83 c2 01             	add    $0x1,%edx
c010275d:	0f b7 d2             	movzwl %dx,%edx
c0102760:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0102764:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0102767:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010276b:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010276f:	ee                   	out    %al,(%dx)
}
c0102770:	83 c4 34             	add    $0x34,%esp
c0102773:	5b                   	pop    %ebx
c0102774:	5d                   	pop    %ebp
c0102775:	c3                   	ret    

c0102776 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0102776:	55                   	push   %ebp
c0102777:	89 e5                	mov    %esp,%ebp
c0102779:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010277c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102783:	eb 09                	jmp    c010278e <serial_putc_sub+0x18>
        delay();
c0102785:	e8 4f fb ff ff       	call   c01022d9 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010278a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010278e:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102794:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0102798:	89 c2                	mov    %eax,%edx
c010279a:	ec                   	in     (%dx),%al
c010279b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010279e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01027a2:	0f b6 c0             	movzbl %al,%eax
c01027a5:	83 e0 20             	and    $0x20,%eax
c01027a8:	85 c0                	test   %eax,%eax
c01027aa:	75 09                	jne    c01027b5 <serial_putc_sub+0x3f>
c01027ac:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01027b3:	7e d0                	jle    c0102785 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c01027b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01027b8:	0f b6 c0             	movzbl %al,%eax
c01027bb:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01027c1:	88 45 f5             	mov    %al,-0xb(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01027c4:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01027c8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01027cc:	ee                   	out    %al,(%dx)
}
c01027cd:	c9                   	leave  
c01027ce:	c3                   	ret    

c01027cf <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c01027cf:	55                   	push   %ebp
c01027d0:	89 e5                	mov    %esp,%ebp
c01027d2:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01027d5:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01027d9:	74 0d                	je     c01027e8 <serial_putc+0x19>
        serial_putc_sub(c);
c01027db:	8b 45 08             	mov    0x8(%ebp),%eax
c01027de:	89 04 24             	mov    %eax,(%esp)
c01027e1:	e8 90 ff ff ff       	call   c0102776 <serial_putc_sub>
c01027e6:	eb 24                	jmp    c010280c <serial_putc+0x3d>
    }
    else {
        serial_putc_sub('\b');
c01027e8:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01027ef:	e8 82 ff ff ff       	call   c0102776 <serial_putc_sub>
        serial_putc_sub(' ');
c01027f4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01027fb:	e8 76 ff ff ff       	call   c0102776 <serial_putc_sub>
        serial_putc_sub('\b');
c0102800:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0102807:	e8 6a ff ff ff       	call   c0102776 <serial_putc_sub>
    }
}
c010280c:	c9                   	leave  
c010280d:	c3                   	ret    

c010280e <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c010280e:	55                   	push   %ebp
c010280f:	89 e5                	mov    %esp,%ebp
c0102811:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0102814:	eb 33                	jmp    c0102849 <cons_intr+0x3b>
        if (c != 0) {
c0102816:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010281a:	74 2d                	je     c0102849 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c010281c:	a1 64 b6 12 c0       	mov    0xc012b664,%eax
c0102821:	8d 50 01             	lea    0x1(%eax),%edx
c0102824:	89 15 64 b6 12 c0    	mov    %edx,0xc012b664
c010282a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010282d:	88 90 60 b4 12 c0    	mov    %dl,-0x3fed4ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0102833:	a1 64 b6 12 c0       	mov    0xc012b664,%eax
c0102838:	3d 00 02 00 00       	cmp    $0x200,%eax
c010283d:	75 0a                	jne    c0102849 <cons_intr+0x3b>
                cons.wpos = 0;
c010283f:	c7 05 64 b6 12 c0 00 	movl   $0x0,0xc012b664
c0102846:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c0102849:	8b 45 08             	mov    0x8(%ebp),%eax
c010284c:	ff d0                	call   *%eax
c010284e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102851:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0102855:	75 bf                	jne    c0102816 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0102857:	c9                   	leave  
c0102858:	c3                   	ret    

c0102859 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0102859:	55                   	push   %ebp
c010285a:	89 e5                	mov    %esp,%ebp
c010285c:	83 ec 10             	sub    $0x10,%esp
c010285f:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102865:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0102869:	89 c2                	mov    %eax,%edx
c010286b:	ec                   	in     (%dx),%al
c010286c:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010286f:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0102873:	0f b6 c0             	movzbl %al,%eax
c0102876:	83 e0 01             	and    $0x1,%eax
c0102879:	85 c0                	test   %eax,%eax
c010287b:	75 07                	jne    c0102884 <serial_proc_data+0x2b>
        return -1;
c010287d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0102882:	eb 2a                	jmp    c01028ae <serial_proc_data+0x55>
c0102884:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010288a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010288e:	89 c2                	mov    %eax,%edx
c0102890:	ec                   	in     (%dx),%al
c0102891:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0102894:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0102898:	0f b6 c0             	movzbl %al,%eax
c010289b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c010289e:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01028a2:	75 07                	jne    c01028ab <serial_proc_data+0x52>
        c = '\b';
c01028a4:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c01028ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01028ae:	c9                   	leave  
c01028af:	c3                   	ret    

c01028b0 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c01028b0:	55                   	push   %ebp
c01028b1:	89 e5                	mov    %esp,%ebp
c01028b3:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c01028b6:	a1 48 b4 12 c0       	mov    0xc012b448,%eax
c01028bb:	85 c0                	test   %eax,%eax
c01028bd:	74 0c                	je     c01028cb <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c01028bf:	c7 04 24 59 28 10 c0 	movl   $0xc0102859,(%esp)
c01028c6:	e8 43 ff ff ff       	call   c010280e <cons_intr>
    }
}
c01028cb:	c9                   	leave  
c01028cc:	c3                   	ret    

c01028cd <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c01028cd:	55                   	push   %ebp
c01028ce:	89 e5                	mov    %esp,%ebp
c01028d0:	83 ec 38             	sub    $0x38,%esp
c01028d3:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01028d9:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01028dd:	89 c2                	mov    %eax,%edx
c01028df:	ec                   	in     (%dx),%al
c01028e0:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c01028e3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01028e7:	0f b6 c0             	movzbl %al,%eax
c01028ea:	83 e0 01             	and    $0x1,%eax
c01028ed:	85 c0                	test   %eax,%eax
c01028ef:	75 0a                	jne    c01028fb <kbd_proc_data+0x2e>
        return -1;
c01028f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01028f6:	e9 59 01 00 00       	jmp    c0102a54 <kbd_proc_data+0x187>
c01028fb:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102901:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102905:	89 c2                	mov    %eax,%edx
c0102907:	ec                   	in     (%dx),%al
c0102908:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010290b:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c010290f:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0102912:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0102916:	75 17                	jne    c010292f <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0102918:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c010291d:	83 c8 40             	or     $0x40,%eax
c0102920:	a3 68 b6 12 c0       	mov    %eax,0xc012b668
        return 0;
c0102925:	b8 00 00 00 00       	mov    $0x0,%eax
c010292a:	e9 25 01 00 00       	jmp    c0102a54 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c010292f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0102933:	84 c0                	test   %al,%al
c0102935:	79 47                	jns    c010297e <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0102937:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c010293c:	83 e0 40             	and    $0x40,%eax
c010293f:	85 c0                	test   %eax,%eax
c0102941:	75 09                	jne    c010294c <kbd_proc_data+0x7f>
c0102943:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0102947:	83 e0 7f             	and    $0x7f,%eax
c010294a:	eb 04                	jmp    c0102950 <kbd_proc_data+0x83>
c010294c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0102950:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0102953:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0102957:	0f b6 80 40 80 12 c0 	movzbl -0x3fed7fc0(%eax),%eax
c010295e:	83 c8 40             	or     $0x40,%eax
c0102961:	0f b6 c0             	movzbl %al,%eax
c0102964:	f7 d0                	not    %eax
c0102966:	89 c2                	mov    %eax,%edx
c0102968:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c010296d:	21 d0                	and    %edx,%eax
c010296f:	a3 68 b6 12 c0       	mov    %eax,0xc012b668
        return 0;
c0102974:	b8 00 00 00 00       	mov    $0x0,%eax
c0102979:	e9 d6 00 00 00       	jmp    c0102a54 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c010297e:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c0102983:	83 e0 40             	and    $0x40,%eax
c0102986:	85 c0                	test   %eax,%eax
c0102988:	74 11                	je     c010299b <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010298a:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c010298e:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c0102993:	83 e0 bf             	and    $0xffffffbf,%eax
c0102996:	a3 68 b6 12 c0       	mov    %eax,0xc012b668
    }

    shift |= shiftcode[data];
c010299b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010299f:	0f b6 80 40 80 12 c0 	movzbl -0x3fed7fc0(%eax),%eax
c01029a6:	0f b6 d0             	movzbl %al,%edx
c01029a9:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c01029ae:	09 d0                	or     %edx,%eax
c01029b0:	a3 68 b6 12 c0       	mov    %eax,0xc012b668
    shift ^= togglecode[data];
c01029b5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01029b9:	0f b6 80 40 81 12 c0 	movzbl -0x3fed7ec0(%eax),%eax
c01029c0:	0f b6 d0             	movzbl %al,%edx
c01029c3:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c01029c8:	31 d0                	xor    %edx,%eax
c01029ca:	a3 68 b6 12 c0       	mov    %eax,0xc012b668

    c = charcode[shift & (CTL | SHIFT)][data];
c01029cf:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c01029d4:	83 e0 03             	and    $0x3,%eax
c01029d7:	8b 14 85 40 85 12 c0 	mov    -0x3fed7ac0(,%eax,4),%edx
c01029de:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01029e2:	01 d0                	add    %edx,%eax
c01029e4:	0f b6 00             	movzbl (%eax),%eax
c01029e7:	0f b6 c0             	movzbl %al,%eax
c01029ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01029ed:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c01029f2:	83 e0 08             	and    $0x8,%eax
c01029f5:	85 c0                	test   %eax,%eax
c01029f7:	74 22                	je     c0102a1b <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c01029f9:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01029fd:	7e 0c                	jle    c0102a0b <kbd_proc_data+0x13e>
c01029ff:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0102a03:	7f 06                	jg     c0102a0b <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0102a05:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0102a09:	eb 10                	jmp    c0102a1b <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0102a0b:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0102a0f:	7e 0a                	jle    c0102a1b <kbd_proc_data+0x14e>
c0102a11:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0102a15:	7f 04                	jg     c0102a1b <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0102a17:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0102a1b:	a1 68 b6 12 c0       	mov    0xc012b668,%eax
c0102a20:	f7 d0                	not    %eax
c0102a22:	83 e0 06             	and    $0x6,%eax
c0102a25:	85 c0                	test   %eax,%eax
c0102a27:	75 28                	jne    c0102a51 <kbd_proc_data+0x184>
c0102a29:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0102a30:	75 1f                	jne    c0102a51 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c0102a32:	c7 04 24 47 b9 10 c0 	movl   $0xc010b947,(%esp)
c0102a39:	e8 a4 ed ff ff       	call   c01017e2 <cprintf>
c0102a3e:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0102a44:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102a48:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0102a4c:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c0102a50:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0102a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102a54:	c9                   	leave  
c0102a55:	c3                   	ret    

c0102a56 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0102a56:	55                   	push   %ebp
c0102a57:	89 e5                	mov    %esp,%ebp
c0102a59:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0102a5c:	c7 04 24 cd 28 10 c0 	movl   $0xc01028cd,(%esp)
c0102a63:	e8 a6 fd ff ff       	call   c010280e <cons_intr>
}
c0102a68:	c9                   	leave  
c0102a69:	c3                   	ret    

c0102a6a <kbd_init>:

static void
kbd_init(void) {
c0102a6a:	55                   	push   %ebp
c0102a6b:	89 e5                	mov    %esp,%ebp
c0102a6d:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0102a70:	e8 e1 ff ff ff       	call   c0102a56 <kbd_intr>
    pic_enable(IRQ_KBD);
c0102a75:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0102a7c:	e8 b2 09 00 00       	call   c0103433 <pic_enable>
}
c0102a81:	c9                   	leave  
c0102a82:	c3                   	ret    

c0102a83 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0102a83:	55                   	push   %ebp
c0102a84:	89 e5                	mov    %esp,%ebp
c0102a86:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0102a89:	e8 93 f8 ff ff       	call   c0102321 <cga_init>
    serial_init();
c0102a8e:	e8 74 f9 ff ff       	call   c0102407 <serial_init>
    kbd_init();
c0102a93:	e8 d2 ff ff ff       	call   c0102a6a <kbd_init>
    if (!serial_exists) {
c0102a98:	a1 48 b4 12 c0       	mov    0xc012b448,%eax
c0102a9d:	85 c0                	test   %eax,%eax
c0102a9f:	75 0c                	jne    c0102aad <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0102aa1:	c7 04 24 53 b9 10 c0 	movl   $0xc010b953,(%esp)
c0102aa8:	e8 35 ed ff ff       	call   c01017e2 <cprintf>
    }
}
c0102aad:	c9                   	leave  
c0102aae:	c3                   	ret    

c0102aaf <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0102aaf:	55                   	push   %ebp
c0102ab0:	89 e5                	mov    %esp,%ebp
c0102ab2:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102ab5:	e8 e2 f7 ff ff       	call   c010229c <__intr_save>
c0102aba:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0102abd:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ac0:	89 04 24             	mov    %eax,(%esp)
c0102ac3:	e8 9b fa ff ff       	call   c0102563 <lpt_putc>
        cga_putc(c);
c0102ac8:	8b 45 08             	mov    0x8(%ebp),%eax
c0102acb:	89 04 24             	mov    %eax,(%esp)
c0102ace:	e8 cf fa ff ff       	call   c01025a2 <cga_putc>
        serial_putc(c);
c0102ad3:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ad6:	89 04 24             	mov    %eax,(%esp)
c0102ad9:	e8 f1 fc ff ff       	call   c01027cf <serial_putc>
    }
    local_intr_restore(intr_flag);
c0102ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ae1:	89 04 24             	mov    %eax,(%esp)
c0102ae4:	e8 dd f7 ff ff       	call   c01022c6 <__intr_restore>
}
c0102ae9:	c9                   	leave  
c0102aea:	c3                   	ret    

c0102aeb <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0102aeb:	55                   	push   %ebp
c0102aec:	89 e5                	mov    %esp,%ebp
c0102aee:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0102af1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102af8:	e8 9f f7 ff ff       	call   c010229c <__intr_save>
c0102afd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0102b00:	e8 ab fd ff ff       	call   c01028b0 <serial_intr>
        kbd_intr();
c0102b05:	e8 4c ff ff ff       	call   c0102a56 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0102b0a:	8b 15 60 b6 12 c0    	mov    0xc012b660,%edx
c0102b10:	a1 64 b6 12 c0       	mov    0xc012b664,%eax
c0102b15:	39 c2                	cmp    %eax,%edx
c0102b17:	74 31                	je     c0102b4a <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0102b19:	a1 60 b6 12 c0       	mov    0xc012b660,%eax
c0102b1e:	8d 50 01             	lea    0x1(%eax),%edx
c0102b21:	89 15 60 b6 12 c0    	mov    %edx,0xc012b660
c0102b27:	0f b6 80 60 b4 12 c0 	movzbl -0x3fed4ba0(%eax),%eax
c0102b2e:	0f b6 c0             	movzbl %al,%eax
c0102b31:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0102b34:	a1 60 b6 12 c0       	mov    0xc012b660,%eax
c0102b39:	3d 00 02 00 00       	cmp    $0x200,%eax
c0102b3e:	75 0a                	jne    c0102b4a <cons_getc+0x5f>
                cons.rpos = 0;
c0102b40:	c7 05 60 b6 12 c0 00 	movl   $0x0,0xc012b660
c0102b47:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0102b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b4d:	89 04 24             	mov    %eax,(%esp)
c0102b50:	e8 71 f7 ff ff       	call   c01022c6 <__intr_restore>
    return c;
c0102b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102b58:	c9                   	leave  
c0102b59:	c3                   	ret    

c0102b5a <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0102b5a:	55                   	push   %ebp
c0102b5b:	89 e5                	mov    %esp,%ebp
c0102b5d:	83 ec 14             	sub    $0x14,%esp
c0102b60:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b63:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0102b67:	90                   	nop
c0102b68:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0102b6c:	83 c0 07             	add    $0x7,%eax
c0102b6f:	0f b7 c0             	movzwl %ax,%eax
c0102b72:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102b76:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0102b7a:	89 c2                	mov    %eax,%edx
c0102b7c:	ec                   	in     (%dx),%al
c0102b7d:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0102b80:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0102b84:	0f b6 c0             	movzbl %al,%eax
c0102b87:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0102b8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102b8d:	25 80 00 00 00       	and    $0x80,%eax
c0102b92:	85 c0                	test   %eax,%eax
c0102b94:	75 d2                	jne    c0102b68 <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0102b96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102b9a:	74 11                	je     c0102bad <ide_wait_ready+0x53>
c0102b9c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102b9f:	83 e0 21             	and    $0x21,%eax
c0102ba2:	85 c0                	test   %eax,%eax
c0102ba4:	74 07                	je     c0102bad <ide_wait_ready+0x53>
        return -1;
c0102ba6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0102bab:	eb 05                	jmp    c0102bb2 <ide_wait_ready+0x58>
    }
    return 0;
c0102bad:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102bb2:	c9                   	leave  
c0102bb3:	c3                   	ret    

c0102bb4 <ide_init>:

void
ide_init(void) {
c0102bb4:	55                   	push   %ebp
c0102bb5:	89 e5                	mov    %esp,%ebp
c0102bb7:	57                   	push   %edi
c0102bb8:	53                   	push   %ebx
c0102bb9:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0102bbf:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0102bc5:	e9 d6 02 00 00       	jmp    c0102ea0 <ide_init+0x2ec>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0102bca:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102bce:	c1 e0 03             	shl    $0x3,%eax
c0102bd1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102bd8:	29 c2                	sub    %eax,%edx
c0102bda:	8d 82 80 b6 12 c0    	lea    -0x3fed4980(%edx),%eax
c0102be0:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0102be3:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102be7:	66 d1 e8             	shr    %ax
c0102bea:	0f b7 c0             	movzwl %ax,%eax
c0102bed:	0f b7 04 85 74 b9 10 	movzwl -0x3fef468c(,%eax,4),%eax
c0102bf4:	c0 
c0102bf5:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0102bf9:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102bfd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102c04:	00 
c0102c05:	89 04 24             	mov    %eax,(%esp)
c0102c08:	e8 4d ff ff ff       	call   c0102b5a <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0102c0d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102c11:	83 e0 01             	and    $0x1,%eax
c0102c14:	c1 e0 04             	shl    $0x4,%eax
c0102c17:	83 c8 e0             	or     $0xffffffe0,%eax
c0102c1a:	0f b6 c0             	movzbl %al,%eax
c0102c1d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102c21:	83 c2 06             	add    $0x6,%edx
c0102c24:	0f b7 d2             	movzwl %dx,%edx
c0102c27:	66 89 55 d2          	mov    %dx,-0x2e(%ebp)
c0102c2b:	88 45 d1             	mov    %al,-0x2f(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0102c2e:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0102c32:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0102c36:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0102c37:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102c3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102c42:	00 
c0102c43:	89 04 24             	mov    %eax,(%esp)
c0102c46:	e8 0f ff ff ff       	call   c0102b5a <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0102c4b:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102c4f:	83 c0 07             	add    $0x7,%eax
c0102c52:	0f b7 c0             	movzwl %ax,%eax
c0102c55:	66 89 45 ce          	mov    %ax,-0x32(%ebp)
c0102c59:	c6 45 cd ec          	movb   $0xec,-0x33(%ebp)
c0102c5d:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0102c61:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0102c65:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0102c66:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102c6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102c71:	00 
c0102c72:	89 04 24             	mov    %eax,(%esp)
c0102c75:	e8 e0 fe ff ff       	call   c0102b5a <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0102c7a:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102c7e:	83 c0 07             	add    $0x7,%eax
c0102c81:	0f b7 c0             	movzwl %ax,%eax
c0102c84:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0102c88:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0102c8c:	89 c2                	mov    %eax,%edx
c0102c8e:	ec                   	in     (%dx),%al
c0102c8f:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0102c92:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0102c96:	84 c0                	test   %al,%al
c0102c98:	0f 84 f7 01 00 00    	je     c0102e95 <ide_init+0x2e1>
c0102c9e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102ca2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0102ca9:	00 
c0102caa:	89 04 24             	mov    %eax,(%esp)
c0102cad:	e8 a8 fe ff ff       	call   c0102b5a <ide_wait_ready>
c0102cb2:	85 c0                	test   %eax,%eax
c0102cb4:	0f 85 db 01 00 00    	jne    c0102e95 <ide_init+0x2e1>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0102cba:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102cbe:	c1 e0 03             	shl    $0x3,%eax
c0102cc1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102cc8:	29 c2                	sub    %eax,%edx
c0102cca:	8d 82 80 b6 12 c0    	lea    -0x3fed4980(%edx),%eax
c0102cd0:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0102cd3:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0102cd7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0102cda:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0102ce0:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0102ce3:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0102cea:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102ced:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0102cf0:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102cf3:	89 cb                	mov    %ecx,%ebx
c0102cf5:	89 df                	mov    %ebx,%edi
c0102cf7:	89 c1                	mov    %eax,%ecx
c0102cf9:	fc                   	cld    
c0102cfa:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0102cfc:	89 c8                	mov    %ecx,%eax
c0102cfe:	89 fb                	mov    %edi,%ebx
c0102d00:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0102d03:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0102d06:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0102d0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0102d0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102d12:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0102d18:	89 45 e0             	mov    %eax,-0x20(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0102d1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d1e:	25 00 00 00 04       	and    $0x4000000,%eax
c0102d23:	85 c0                	test   %eax,%eax
c0102d25:	74 0e                	je     c0102d35 <ide_init+0x181>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0102d27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102d2a:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0102d30:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102d33:	eb 09                	jmp    c0102d3e <ide_init+0x18a>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0102d35:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102d38:	8b 40 78             	mov    0x78(%eax),%eax
c0102d3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0102d3e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102d42:	c1 e0 03             	shl    $0x3,%eax
c0102d45:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102d4c:	29 c2                	sub    %eax,%edx
c0102d4e:	81 c2 80 b6 12 c0    	add    $0xc012b680,%edx
c0102d54:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d57:	89 42 04             	mov    %eax,0x4(%edx)
        ide_devices[ideno].size = sectors;
c0102d5a:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102d5e:	c1 e0 03             	shl    $0x3,%eax
c0102d61:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102d68:	29 c2                	sub    %eax,%edx
c0102d6a:	81 c2 80 b6 12 c0    	add    $0xc012b680,%edx
c0102d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d73:	89 42 08             	mov    %eax,0x8(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0102d76:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102d79:	83 c0 62             	add    $0x62,%eax
c0102d7c:	0f b7 00             	movzwl (%eax),%eax
c0102d7f:	0f b7 c0             	movzwl %ax,%eax
c0102d82:	25 00 02 00 00       	and    $0x200,%eax
c0102d87:	85 c0                	test   %eax,%eax
c0102d89:	75 24                	jne    c0102daf <ide_init+0x1fb>
c0102d8b:	c7 44 24 0c 7c b9 10 	movl   $0xc010b97c,0xc(%esp)
c0102d92:	c0 
c0102d93:	c7 44 24 08 bf b9 10 	movl   $0xc010b9bf,0x8(%esp)
c0102d9a:	c0 
c0102d9b:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0102da2:	00 
c0102da3:	c7 04 24 d4 b9 10 c0 	movl   $0xc010b9d4,(%esp)
c0102daa:	e8 bd f3 ff ff       	call   c010216c <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0102daf:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102db3:	c1 e0 03             	shl    $0x3,%eax
c0102db6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102dbd:	29 c2                	sub    %eax,%edx
c0102dbf:	8d 82 80 b6 12 c0    	lea    -0x3fed4980(%edx),%eax
c0102dc5:	83 c0 0c             	add    $0xc,%eax
c0102dc8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102dcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102dce:	83 c0 36             	add    $0x36,%eax
c0102dd1:	89 45 d8             	mov    %eax,-0x28(%ebp)
        unsigned int i, length = 40;
c0102dd4:	c7 45 d4 28 00 00 00 	movl   $0x28,-0x2c(%ebp)
        for (i = 0; i < length; i += 2) {
c0102ddb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102de2:	eb 34                	jmp    c0102e18 <ide_init+0x264>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0102de4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102de7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102dea:	01 c2                	add    %eax,%edx
c0102dec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102def:	8d 48 01             	lea    0x1(%eax),%ecx
c0102df2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102df5:	01 c8                	add    %ecx,%eax
c0102df7:	0f b6 00             	movzbl (%eax),%eax
c0102dfa:	88 02                	mov    %al,(%edx)
c0102dfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102dff:	8d 50 01             	lea    0x1(%eax),%edx
c0102e02:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102e05:	01 c2                	add    %eax,%edx
c0102e07:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102e0a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c0102e0d:	01 c8                	add    %ecx,%eax
c0102e0f:	0f b6 00             	movzbl (%eax),%eax
c0102e12:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c0102e14:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0102e18:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102e1b:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
c0102e1e:	72 c4                	jb     c0102de4 <ide_init+0x230>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c0102e20:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102e23:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e26:	01 d0                	add    %edx,%eax
c0102e28:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0102e2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102e2e:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102e31:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0102e34:	85 c0                	test   %eax,%eax
c0102e36:	74 0f                	je     c0102e47 <ide_init+0x293>
c0102e38:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102e3b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e3e:	01 d0                	add    %edx,%eax
c0102e40:	0f b6 00             	movzbl (%eax),%eax
c0102e43:	3c 20                	cmp    $0x20,%al
c0102e45:	74 d9                	je     c0102e20 <ide_init+0x26c>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0102e47:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102e4b:	c1 e0 03             	shl    $0x3,%eax
c0102e4e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102e55:	29 c2                	sub    %eax,%edx
c0102e57:	8d 82 80 b6 12 c0    	lea    -0x3fed4980(%edx),%eax
c0102e5d:	8d 48 0c             	lea    0xc(%eax),%ecx
c0102e60:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102e64:	c1 e0 03             	shl    $0x3,%eax
c0102e67:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102e6e:	29 c2                	sub    %eax,%edx
c0102e70:	8d 82 80 b6 12 c0    	lea    -0x3fed4980(%edx),%eax
c0102e76:	8b 50 08             	mov    0x8(%eax),%edx
c0102e79:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102e7d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0102e81:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102e85:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102e89:	c7 04 24 e6 b9 10 c0 	movl   $0xc010b9e6,(%esp)
c0102e90:	e8 4d e9 ff ff       	call   c01017e2 <cprintf>

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0102e95:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0102e99:	83 c0 01             	add    $0x1,%eax
c0102e9c:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0102ea0:	66 83 7d f6 03       	cmpw   $0x3,-0xa(%ebp)
c0102ea5:	0f 86 1f fd ff ff    	jbe    c0102bca <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c0102eab:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c0102eb2:	e8 7c 05 00 00       	call   c0103433 <pic_enable>
    pic_enable(IRQ_IDE2);
c0102eb7:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0102ebe:	e8 70 05 00 00       	call   c0103433 <pic_enable>
}
c0102ec3:	81 c4 50 02 00 00    	add    $0x250,%esp
c0102ec9:	5b                   	pop    %ebx
c0102eca:	5f                   	pop    %edi
c0102ecb:	5d                   	pop    %ebp
c0102ecc:	c3                   	ret    

c0102ecd <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0102ecd:	55                   	push   %ebp
c0102ece:	89 e5                	mov    %esp,%ebp
c0102ed0:	83 ec 04             	sub    $0x4,%esp
c0102ed3:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ed6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c0102eda:	66 83 7d fc 03       	cmpw   $0x3,-0x4(%ebp)
c0102edf:	77 24                	ja     c0102f05 <ide_device_valid+0x38>
c0102ee1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0102ee5:	c1 e0 03             	shl    $0x3,%eax
c0102ee8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102eef:	29 c2                	sub    %eax,%edx
c0102ef1:	8d 82 80 b6 12 c0    	lea    -0x3fed4980(%edx),%eax
c0102ef7:	0f b6 00             	movzbl (%eax),%eax
c0102efa:	84 c0                	test   %al,%al
c0102efc:	74 07                	je     c0102f05 <ide_device_valid+0x38>
c0102efe:	b8 01 00 00 00       	mov    $0x1,%eax
c0102f03:	eb 05                	jmp    c0102f0a <ide_device_valid+0x3d>
c0102f05:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102f0a:	c9                   	leave  
c0102f0b:	c3                   	ret    

c0102f0c <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0102f0c:	55                   	push   %ebp
c0102f0d:	89 e5                	mov    %esp,%ebp
c0102f0f:	83 ec 08             	sub    $0x8,%esp
c0102f12:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f15:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c0102f19:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0102f1d:	89 04 24             	mov    %eax,(%esp)
c0102f20:	e8 a8 ff ff ff       	call   c0102ecd <ide_device_valid>
c0102f25:	85 c0                	test   %eax,%eax
c0102f27:	74 1b                	je     c0102f44 <ide_device_size+0x38>
        return ide_devices[ideno].size;
c0102f29:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0102f2d:	c1 e0 03             	shl    $0x3,%eax
c0102f30:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102f37:	29 c2                	sub    %eax,%edx
c0102f39:	8d 82 80 b6 12 c0    	lea    -0x3fed4980(%edx),%eax
c0102f3f:	8b 40 08             	mov    0x8(%eax),%eax
c0102f42:	eb 05                	jmp    c0102f49 <ide_device_size+0x3d>
    }
    return 0;
c0102f44:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102f49:	c9                   	leave  
c0102f4a:	c3                   	ret    

c0102f4b <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0102f4b:	55                   	push   %ebp
c0102f4c:	89 e5                	mov    %esp,%ebp
c0102f4e:	57                   	push   %edi
c0102f4f:	53                   	push   %ebx
c0102f50:	83 ec 50             	sub    $0x50,%esp
c0102f53:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f56:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c0102f5a:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c0102f61:	77 24                	ja     c0102f87 <ide_read_secs+0x3c>
c0102f63:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c0102f68:	77 1d                	ja     c0102f87 <ide_read_secs+0x3c>
c0102f6a:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102f6e:	c1 e0 03             	shl    $0x3,%eax
c0102f71:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0102f78:	29 c2                	sub    %eax,%edx
c0102f7a:	8d 82 80 b6 12 c0    	lea    -0x3fed4980(%edx),%eax
c0102f80:	0f b6 00             	movzbl (%eax),%eax
c0102f83:	84 c0                	test   %al,%al
c0102f85:	75 24                	jne    c0102fab <ide_read_secs+0x60>
c0102f87:	c7 44 24 0c 04 ba 10 	movl   $0xc010ba04,0xc(%esp)
c0102f8e:	c0 
c0102f8f:	c7 44 24 08 bf b9 10 	movl   $0xc010b9bf,0x8(%esp)
c0102f96:	c0 
c0102f97:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c0102f9e:	00 
c0102f9f:	c7 04 24 d4 b9 10 c0 	movl   $0xc010b9d4,(%esp)
c0102fa6:	e8 c1 f1 ff ff       	call   c010216c <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0102fab:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0102fb2:	77 0f                	ja     c0102fc3 <ide_read_secs+0x78>
c0102fb4:	8b 45 14             	mov    0x14(%ebp),%eax
c0102fb7:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102fba:	01 d0                	add    %edx,%eax
c0102fbc:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0102fc1:	76 24                	jbe    c0102fe7 <ide_read_secs+0x9c>
c0102fc3:	c7 44 24 0c 2c ba 10 	movl   $0xc010ba2c,0xc(%esp)
c0102fca:	c0 
c0102fcb:	c7 44 24 08 bf b9 10 	movl   $0xc010b9bf,0x8(%esp)
c0102fd2:	c0 
c0102fd3:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0102fda:	00 
c0102fdb:	c7 04 24 d4 b9 10 c0 	movl   $0xc010b9d4,(%esp)
c0102fe2:	e8 85 f1 ff ff       	call   c010216c <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0102fe7:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0102feb:	66 d1 e8             	shr    %ax
c0102fee:	0f b7 c0             	movzwl %ax,%eax
c0102ff1:	0f b7 04 85 74 b9 10 	movzwl -0x3fef468c(,%eax,4),%eax
c0102ff8:	c0 
c0102ff9:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0102ffd:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0103001:	66 d1 e8             	shr    %ax
c0103004:	0f b7 c0             	movzwl %ax,%eax
c0103007:	0f b7 04 85 76 b9 10 	movzwl -0x3fef468a(,%eax,4),%eax
c010300e:	c0 
c010300f:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0103013:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0103017:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010301e:	00 
c010301f:	89 04 24             	mov    %eax,(%esp)
c0103022:	e8 33 fb ff ff       	call   c0102b5a <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0103027:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c010302b:	83 c0 02             	add    $0x2,%eax
c010302e:	0f b7 c0             	movzwl %ax,%eax
c0103031:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0103035:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0103039:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010303d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0103041:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0103042:	8b 45 14             	mov    0x14(%ebp),%eax
c0103045:	0f b6 c0             	movzbl %al,%eax
c0103048:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010304c:	83 c2 02             	add    $0x2,%edx
c010304f:	0f b7 d2             	movzwl %dx,%edx
c0103052:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0103056:	88 45 e9             	mov    %al,-0x17(%ebp)
c0103059:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010305d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0103061:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c0103062:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103065:	0f b6 c0             	movzbl %al,%eax
c0103068:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010306c:	83 c2 03             	add    $0x3,%edx
c010306f:	0f b7 d2             	movzwl %dx,%edx
c0103072:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c0103076:	88 45 e5             	mov    %al,-0x1b(%ebp)
c0103079:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010307d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0103081:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0103082:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103085:	c1 e8 08             	shr    $0x8,%eax
c0103088:	0f b6 c0             	movzbl %al,%eax
c010308b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010308f:	83 c2 04             	add    $0x4,%edx
c0103092:	0f b7 d2             	movzwl %dx,%edx
c0103095:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0103099:	88 45 e1             	mov    %al,-0x1f(%ebp)
c010309c:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01030a0:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01030a4:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01030a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030a8:	c1 e8 10             	shr    $0x10,%eax
c01030ab:	0f b6 c0             	movzbl %al,%eax
c01030ae:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01030b2:	83 c2 05             	add    $0x5,%edx
c01030b5:	0f b7 d2             	movzwl %dx,%edx
c01030b8:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c01030bc:	88 45 dd             	mov    %al,-0x23(%ebp)
c01030bf:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01030c3:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01030c7:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c01030c8:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01030cc:	83 e0 01             	and    $0x1,%eax
c01030cf:	c1 e0 04             	shl    $0x4,%eax
c01030d2:	89 c2                	mov    %eax,%edx
c01030d4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01030d7:	c1 e8 18             	shr    $0x18,%eax
c01030da:	83 e0 0f             	and    $0xf,%eax
c01030dd:	09 d0                	or     %edx,%eax
c01030df:	83 c8 e0             	or     $0xffffffe0,%eax
c01030e2:	0f b6 c0             	movzbl %al,%eax
c01030e5:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01030e9:	83 c2 06             	add    $0x6,%edx
c01030ec:	0f b7 d2             	movzwl %dx,%edx
c01030ef:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c01030f3:	88 45 d9             	mov    %al,-0x27(%ebp)
c01030f6:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01030fa:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01030fe:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c01030ff:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0103103:	83 c0 07             	add    $0x7,%eax
c0103106:	0f b7 c0             	movzwl %ax,%eax
c0103109:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c010310d:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
c0103111:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0103115:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0103119:	ee                   	out    %al,(%dx)

    int ret = 0;
c010311a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0103121:	eb 5a                	jmp    c010317d <ide_read_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0103123:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0103127:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010312e:	00 
c010312f:	89 04 24             	mov    %eax,(%esp)
c0103132:	e8 23 fa ff ff       	call   c0102b5a <ide_wait_ready>
c0103137:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010313a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010313e:	74 02                	je     c0103142 <ide_read_secs+0x1f7>
            goto out;
c0103140:	eb 41                	jmp    c0103183 <ide_read_secs+0x238>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c0103142:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0103146:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103149:	8b 45 10             	mov    0x10(%ebp),%eax
c010314c:	89 45 cc             	mov    %eax,-0x34(%ebp)
c010314f:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0103156:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103159:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c010315c:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010315f:	89 cb                	mov    %ecx,%ebx
c0103161:	89 df                	mov    %ebx,%edi
c0103163:	89 c1                	mov    %eax,%ecx
c0103165:	fc                   	cld    
c0103166:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0103168:	89 c8                	mov    %ecx,%eax
c010316a:	89 fb                	mov    %edi,%ebx
c010316c:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c010316f:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0103172:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c0103176:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c010317d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0103181:	75 a0                	jne    c0103123 <ide_read_secs+0x1d8>
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c0103183:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103186:	83 c4 50             	add    $0x50,%esp
c0103189:	5b                   	pop    %ebx
c010318a:	5f                   	pop    %edi
c010318b:	5d                   	pop    %ebp
c010318c:	c3                   	ret    

c010318d <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c010318d:	55                   	push   %ebp
c010318e:	89 e5                	mov    %esp,%ebp
c0103190:	56                   	push   %esi
c0103191:	53                   	push   %ebx
c0103192:	83 ec 50             	sub    $0x50,%esp
c0103195:	8b 45 08             	mov    0x8(%ebp),%eax
c0103198:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c010319c:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01031a3:	77 24                	ja     c01031c9 <ide_write_secs+0x3c>
c01031a5:	66 83 7d c4 03       	cmpw   $0x3,-0x3c(%ebp)
c01031aa:	77 1d                	ja     c01031c9 <ide_write_secs+0x3c>
c01031ac:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01031b0:	c1 e0 03             	shl    $0x3,%eax
c01031b3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01031ba:	29 c2                	sub    %eax,%edx
c01031bc:	8d 82 80 b6 12 c0    	lea    -0x3fed4980(%edx),%eax
c01031c2:	0f b6 00             	movzbl (%eax),%eax
c01031c5:	84 c0                	test   %al,%al
c01031c7:	75 24                	jne    c01031ed <ide_write_secs+0x60>
c01031c9:	c7 44 24 0c 04 ba 10 	movl   $0xc010ba04,0xc(%esp)
c01031d0:	c0 
c01031d1:	c7 44 24 08 bf b9 10 	movl   $0xc010b9bf,0x8(%esp)
c01031d8:	c0 
c01031d9:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c01031e0:	00 
c01031e1:	c7 04 24 d4 b9 10 c0 	movl   $0xc010b9d4,(%esp)
c01031e8:	e8 7f ef ff ff       	call   c010216c <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c01031ed:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c01031f4:	77 0f                	ja     c0103205 <ide_write_secs+0x78>
c01031f6:	8b 45 14             	mov    0x14(%ebp),%eax
c01031f9:	8b 55 0c             	mov    0xc(%ebp),%edx
c01031fc:	01 d0                	add    %edx,%eax
c01031fe:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0103203:	76 24                	jbe    c0103229 <ide_write_secs+0x9c>
c0103205:	c7 44 24 0c 2c ba 10 	movl   $0xc010ba2c,0xc(%esp)
c010320c:	c0 
c010320d:	c7 44 24 08 bf b9 10 	movl   $0xc010b9bf,0x8(%esp)
c0103214:	c0 
c0103215:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c010321c:	00 
c010321d:	c7 04 24 d4 b9 10 c0 	movl   $0xc010b9d4,(%esp)
c0103224:	e8 43 ef ff ff       	call   c010216c <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0103229:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010322d:	66 d1 e8             	shr    %ax
c0103230:	0f b7 c0             	movzwl %ax,%eax
c0103233:	0f b7 04 85 74 b9 10 	movzwl -0x3fef468c(,%eax,4),%eax
c010323a:	c0 
c010323b:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010323f:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0103243:	66 d1 e8             	shr    %ax
c0103246:	0f b7 c0             	movzwl %ax,%eax
c0103249:	0f b7 04 85 76 b9 10 	movzwl -0x3fef468a(,%eax,4),%eax
c0103250:	c0 
c0103251:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0103255:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0103259:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103260:	00 
c0103261:	89 04 24             	mov    %eax,(%esp)
c0103264:	e8 f1 f8 ff ff       	call   c0102b5a <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c0103269:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c010326d:	83 c0 02             	add    $0x2,%eax
c0103270:	0f b7 c0             	movzwl %ax,%eax
c0103273:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0103277:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010327b:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010327f:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0103283:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0103284:	8b 45 14             	mov    0x14(%ebp),%eax
c0103287:	0f b6 c0             	movzbl %al,%eax
c010328a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010328e:	83 c2 02             	add    $0x2,%edx
c0103291:	0f b7 d2             	movzwl %dx,%edx
c0103294:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0103298:	88 45 e9             	mov    %al,-0x17(%ebp)
c010329b:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010329f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01032a3:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01032a4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032a7:	0f b6 c0             	movzbl %al,%eax
c01032aa:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01032ae:	83 c2 03             	add    $0x3,%edx
c01032b1:	0f b7 d2             	movzwl %dx,%edx
c01032b4:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01032b8:	88 45 e5             	mov    %al,-0x1b(%ebp)
c01032bb:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01032bf:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01032c3:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01032c4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032c7:	c1 e8 08             	shr    $0x8,%eax
c01032ca:	0f b6 c0             	movzbl %al,%eax
c01032cd:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01032d1:	83 c2 04             	add    $0x4,%edx
c01032d4:	0f b7 d2             	movzwl %dx,%edx
c01032d7:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01032db:	88 45 e1             	mov    %al,-0x1f(%ebp)
c01032de:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01032e2:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01032e6:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01032e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032ea:	c1 e8 10             	shr    $0x10,%eax
c01032ed:	0f b6 c0             	movzbl %al,%eax
c01032f0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01032f4:	83 c2 05             	add    $0x5,%edx
c01032f7:	0f b7 d2             	movzwl %dx,%edx
c01032fa:	66 89 55 de          	mov    %dx,-0x22(%ebp)
c01032fe:	88 45 dd             	mov    %al,-0x23(%ebp)
c0103301:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0103305:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0103309:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010330a:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010330e:	83 e0 01             	and    $0x1,%eax
c0103311:	c1 e0 04             	shl    $0x4,%eax
c0103314:	89 c2                	mov    %eax,%edx
c0103316:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103319:	c1 e8 18             	shr    $0x18,%eax
c010331c:	83 e0 0f             	and    $0xf,%eax
c010331f:	09 d0                	or     %edx,%eax
c0103321:	83 c8 e0             	or     $0xffffffe0,%eax
c0103324:	0f b6 c0             	movzbl %al,%eax
c0103327:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010332b:	83 c2 06             	add    $0x6,%edx
c010332e:	0f b7 d2             	movzwl %dx,%edx
c0103331:	66 89 55 da          	mov    %dx,-0x26(%ebp)
c0103335:	88 45 d9             	mov    %al,-0x27(%ebp)
c0103338:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010333c:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0103340:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0103341:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0103345:	83 c0 07             	add    $0x7,%eax
c0103348:	0f b7 c0             	movzwl %ax,%eax
c010334b:	66 89 45 d6          	mov    %ax,-0x2a(%ebp)
c010334f:	c6 45 d5 30          	movb   $0x30,-0x2b(%ebp)
c0103353:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0103357:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010335b:	ee                   	out    %al,(%dx)

    int ret = 0;
c010335c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0103363:	eb 5a                	jmp    c01033bf <ide_write_secs+0x232>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0103365:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0103369:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103370:	00 
c0103371:	89 04 24             	mov    %eax,(%esp)
c0103374:	e8 e1 f7 ff ff       	call   c0102b5a <ide_wait_ready>
c0103379:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010337c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103380:	74 02                	je     c0103384 <ide_write_secs+0x1f7>
            goto out;
c0103382:	eb 41                	jmp    c01033c5 <ide_write_secs+0x238>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c0103384:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0103388:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010338b:	8b 45 10             	mov    0x10(%ebp),%eax
c010338e:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0103391:	c7 45 c8 80 00 00 00 	movl   $0x80,-0x38(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c0103398:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010339b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
c010339e:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01033a1:	89 cb                	mov    %ecx,%ebx
c01033a3:	89 de                	mov    %ebx,%esi
c01033a5:	89 c1                	mov    %eax,%ecx
c01033a7:	fc                   	cld    
c01033a8:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c01033aa:	89 c8                	mov    %ecx,%eax
c01033ac:	89 f3                	mov    %esi,%ebx
c01033ae:	89 5d cc             	mov    %ebx,-0x34(%ebp)
c01033b1:	89 45 c8             	mov    %eax,-0x38(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01033b4:	83 6d 14 01          	subl   $0x1,0x14(%ebp)
c01033b8:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01033bf:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01033c3:	75 a0                	jne    c0103365 <ide_write_secs+0x1d8>
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c01033c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01033c8:	83 c4 50             	add    $0x50,%esp
c01033cb:	5b                   	pop    %ebx
c01033cc:	5e                   	pop    %esi
c01033cd:	5d                   	pop    %ebp
c01033ce:	c3                   	ret    

c01033cf <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01033cf:	55                   	push   %ebp
c01033d0:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01033d2:	fb                   	sti    
    sti();
}
c01033d3:	5d                   	pop    %ebp
c01033d4:	c3                   	ret    

c01033d5 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01033d5:	55                   	push   %ebp
c01033d6:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01033d8:	fa                   	cli    
    cli();
}
c01033d9:	5d                   	pop    %ebp
c01033da:	c3                   	ret    

c01033db <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01033db:	55                   	push   %ebp
c01033dc:	89 e5                	mov    %esp,%ebp
c01033de:	83 ec 14             	sub    $0x14,%esp
c01033e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01033e4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01033e8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01033ec:	66 a3 50 85 12 c0    	mov    %ax,0xc0128550
    if (did_init) {
c01033f2:	a1 60 b7 12 c0       	mov    0xc012b760,%eax
c01033f7:	85 c0                	test   %eax,%eax
c01033f9:	74 36                	je     c0103431 <pic_setmask+0x56>
        outb(IO_PIC1 + 1, mask);
c01033fb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01033ff:	0f b6 c0             	movzbl %al,%eax
c0103402:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0103408:	88 45 fd             	mov    %al,-0x3(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010340b:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010340f:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0103413:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0103414:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0103418:	66 c1 e8 08          	shr    $0x8,%ax
c010341c:	0f b6 c0             	movzbl %al,%eax
c010341f:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c0103425:	88 45 f9             	mov    %al,-0x7(%ebp)
c0103428:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010342c:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0103430:	ee                   	out    %al,(%dx)
    }
}
c0103431:	c9                   	leave  
c0103432:	c3                   	ret    

c0103433 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0103433:	55                   	push   %ebp
c0103434:	89 e5                	mov    %esp,%ebp
c0103436:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0103439:	8b 45 08             	mov    0x8(%ebp),%eax
c010343c:	ba 01 00 00 00       	mov    $0x1,%edx
c0103441:	89 c1                	mov    %eax,%ecx
c0103443:	d3 e2                	shl    %cl,%edx
c0103445:	89 d0                	mov    %edx,%eax
c0103447:	f7 d0                	not    %eax
c0103449:	89 c2                	mov    %eax,%edx
c010344b:	0f b7 05 50 85 12 c0 	movzwl 0xc0128550,%eax
c0103452:	21 d0                	and    %edx,%eax
c0103454:	0f b7 c0             	movzwl %ax,%eax
c0103457:	89 04 24             	mov    %eax,(%esp)
c010345a:	e8 7c ff ff ff       	call   c01033db <pic_setmask>
}
c010345f:	c9                   	leave  
c0103460:	c3                   	ret    

c0103461 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0103461:	55                   	push   %ebp
c0103462:	89 e5                	mov    %esp,%ebp
c0103464:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c0103467:	c7 05 60 b7 12 c0 01 	movl   $0x1,0xc012b760
c010346e:	00 00 00 
c0103471:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0103477:	c6 45 fd ff          	movb   $0xff,-0x3(%ebp)
c010347b:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010347f:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0103483:	ee                   	out    %al,(%dx)
c0103484:	66 c7 45 fa a1 00    	movw   $0xa1,-0x6(%ebp)
c010348a:	c6 45 f9 ff          	movb   $0xff,-0x7(%ebp)
c010348e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0103492:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0103496:	ee                   	out    %al,(%dx)
c0103497:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c010349d:	c6 45 f5 11          	movb   $0x11,-0xb(%ebp)
c01034a1:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01034a5:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01034a9:	ee                   	out    %al,(%dx)
c01034aa:	66 c7 45 f2 21 00    	movw   $0x21,-0xe(%ebp)
c01034b0:	c6 45 f1 20          	movb   $0x20,-0xf(%ebp)
c01034b4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01034b8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01034bc:	ee                   	out    %al,(%dx)
c01034bd:	66 c7 45 ee 21 00    	movw   $0x21,-0x12(%ebp)
c01034c3:	c6 45 ed 04          	movb   $0x4,-0x13(%ebp)
c01034c7:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01034cb:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01034cf:	ee                   	out    %al,(%dx)
c01034d0:	66 c7 45 ea 21 00    	movw   $0x21,-0x16(%ebp)
c01034d6:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
c01034da:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01034de:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01034e2:	ee                   	out    %al,(%dx)
c01034e3:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01034e9:	c6 45 e5 11          	movb   $0x11,-0x1b(%ebp)
c01034ed:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01034f1:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01034f5:	ee                   	out    %al,(%dx)
c01034f6:	66 c7 45 e2 a1 00    	movw   $0xa1,-0x1e(%ebp)
c01034fc:	c6 45 e1 28          	movb   $0x28,-0x1f(%ebp)
c0103500:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0103504:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0103508:	ee                   	out    %al,(%dx)
c0103509:	66 c7 45 de a1 00    	movw   $0xa1,-0x22(%ebp)
c010350f:	c6 45 dd 02          	movb   $0x2,-0x23(%ebp)
c0103513:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0103517:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c010351b:	ee                   	out    %al,(%dx)
c010351c:	66 c7 45 da a1 00    	movw   $0xa1,-0x26(%ebp)
c0103522:	c6 45 d9 03          	movb   $0x3,-0x27(%ebp)
c0103526:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010352a:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010352e:	ee                   	out    %al,(%dx)
c010352f:	66 c7 45 d6 20 00    	movw   $0x20,-0x2a(%ebp)
c0103535:	c6 45 d5 68          	movb   $0x68,-0x2b(%ebp)
c0103539:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010353d:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0103541:	ee                   	out    %al,(%dx)
c0103542:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0103548:	c6 45 d1 0a          	movb   $0xa,-0x2f(%ebp)
c010354c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0103550:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0103554:	ee                   	out    %al,(%dx)
c0103555:	66 c7 45 ce a0 00    	movw   $0xa0,-0x32(%ebp)
c010355b:	c6 45 cd 68          	movb   $0x68,-0x33(%ebp)
c010355f:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0103563:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0103567:	ee                   	out    %al,(%dx)
c0103568:	66 c7 45 ca a0 00    	movw   $0xa0,-0x36(%ebp)
c010356e:	c6 45 c9 0a          	movb   $0xa,-0x37(%ebp)
c0103572:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0103576:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c010357a:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010357b:	0f b7 05 50 85 12 c0 	movzwl 0xc0128550,%eax
c0103582:	66 83 f8 ff          	cmp    $0xffff,%ax
c0103586:	74 12                	je     c010359a <pic_init+0x139>
        pic_setmask(irq_mask);
c0103588:	0f b7 05 50 85 12 c0 	movzwl 0xc0128550,%eax
c010358f:	0f b7 c0             	movzwl %ax,%eax
c0103592:	89 04 24             	mov    %eax,(%esp)
c0103595:	e8 41 fe ff ff       	call   c01033db <pic_setmask>
    }
}
c010359a:	c9                   	leave  
c010359b:	c3                   	ret    

c010359c <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c010359c:	55                   	push   %ebp
c010359d:	89 e5                	mov    %esp,%ebp
c010359f:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01035a2:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01035a9:	00 
c01035aa:	c7 04 24 80 ba 10 c0 	movl   $0xc010ba80,(%esp)
c01035b1:	e8 2c e2 ff ff       	call   c01017e2 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c01035b6:	c7 04 24 8a ba 10 c0 	movl   $0xc010ba8a,(%esp)
c01035bd:	e8 20 e2 ff ff       	call   c01017e2 <cprintf>
    panic("EOT: kernel seems ok.");
c01035c2:	c7 44 24 08 98 ba 10 	movl   $0xc010ba98,0x8(%esp)
c01035c9:	c0 
c01035ca:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c01035d1:	00 
c01035d2:	c7 04 24 ae ba 10 c0 	movl   $0xc010baae,(%esp)
c01035d9:	e8 8e eb ff ff       	call   c010216c <__panic>

c01035de <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01035de:	55                   	push   %ebp
c01035df:	89 e5                	mov    %esp,%ebp
c01035e1:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01035e4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01035eb:	e9 c3 00 00 00       	jmp    c01036b3 <idt_init+0xd5>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01035f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01035f3:	8b 04 85 e0 85 12 c0 	mov    -0x3fed7a20(,%eax,4),%eax
c01035fa:	89 c2                	mov    %eax,%edx
c01035fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01035ff:	66 89 14 c5 80 b7 12 	mov    %dx,-0x3fed4880(,%eax,8)
c0103606:	c0 
c0103607:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010360a:	66 c7 04 c5 82 b7 12 	movw   $0x8,-0x3fed487e(,%eax,8)
c0103611:	c0 08 00 
c0103614:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103617:	0f b6 14 c5 84 b7 12 	movzbl -0x3fed487c(,%eax,8),%edx
c010361e:	c0 
c010361f:	83 e2 e0             	and    $0xffffffe0,%edx
c0103622:	88 14 c5 84 b7 12 c0 	mov    %dl,-0x3fed487c(,%eax,8)
c0103629:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010362c:	0f b6 14 c5 84 b7 12 	movzbl -0x3fed487c(,%eax,8),%edx
c0103633:	c0 
c0103634:	83 e2 1f             	and    $0x1f,%edx
c0103637:	88 14 c5 84 b7 12 c0 	mov    %dl,-0x3fed487c(,%eax,8)
c010363e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103641:	0f b6 14 c5 85 b7 12 	movzbl -0x3fed487b(,%eax,8),%edx
c0103648:	c0 
c0103649:	83 e2 f0             	and    $0xfffffff0,%edx
c010364c:	83 ca 0e             	or     $0xe,%edx
c010364f:	88 14 c5 85 b7 12 c0 	mov    %dl,-0x3fed487b(,%eax,8)
c0103656:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103659:	0f b6 14 c5 85 b7 12 	movzbl -0x3fed487b(,%eax,8),%edx
c0103660:	c0 
c0103661:	83 e2 ef             	and    $0xffffffef,%edx
c0103664:	88 14 c5 85 b7 12 c0 	mov    %dl,-0x3fed487b(,%eax,8)
c010366b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010366e:	0f b6 14 c5 85 b7 12 	movzbl -0x3fed487b(,%eax,8),%edx
c0103675:	c0 
c0103676:	83 e2 9f             	and    $0xffffff9f,%edx
c0103679:	88 14 c5 85 b7 12 c0 	mov    %dl,-0x3fed487b(,%eax,8)
c0103680:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103683:	0f b6 14 c5 85 b7 12 	movzbl -0x3fed487b(,%eax,8),%edx
c010368a:	c0 
c010368b:	83 ca 80             	or     $0xffffff80,%edx
c010368e:	88 14 c5 85 b7 12 c0 	mov    %dl,-0x3fed487b(,%eax,8)
c0103695:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103698:	8b 04 85 e0 85 12 c0 	mov    -0x3fed7a20(,%eax,4),%eax
c010369f:	c1 e8 10             	shr    $0x10,%eax
c01036a2:	89 c2                	mov    %eax,%edx
c01036a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01036a7:	66 89 14 c5 86 b7 12 	mov    %dx,-0x3fed487a(,%eax,8)
c01036ae:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01036af:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c01036b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01036b6:	3d ff 00 00 00       	cmp    $0xff,%eax
c01036bb:	0f 86 2f ff ff ff    	jbe    c01035f0 <idt_init+0x12>
c01036c1:	c7 45 f8 60 85 12 c0 	movl   $0xc0128560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01036c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01036cb:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
c01036ce:	c9                   	leave  
c01036cf:	c3                   	ret    

c01036d0 <trapname>:

static const char *
trapname(int trapno) {
c01036d0:	55                   	push   %ebp
c01036d1:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01036d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01036d6:	83 f8 13             	cmp    $0x13,%eax
c01036d9:	77 0c                	ja     c01036e7 <trapname+0x17>
        return excnames[trapno];
c01036db:	8b 45 08             	mov    0x8(%ebp),%eax
c01036de:	8b 04 85 80 be 10 c0 	mov    -0x3fef4180(,%eax,4),%eax
c01036e5:	eb 18                	jmp    c01036ff <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01036e7:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01036eb:	7e 0d                	jle    c01036fa <trapname+0x2a>
c01036ed:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01036f1:	7f 07                	jg     c01036fa <trapname+0x2a>
        return "Hardware Interrupt";
c01036f3:	b8 bf ba 10 c0       	mov    $0xc010babf,%eax
c01036f8:	eb 05                	jmp    c01036ff <trapname+0x2f>
    }
    return "(unknown trap)";
c01036fa:	b8 d2 ba 10 c0       	mov    $0xc010bad2,%eax
}
c01036ff:	5d                   	pop    %ebp
c0103700:	c3                   	ret    

c0103701 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0103701:	55                   	push   %ebp
c0103702:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0103704:	8b 45 08             	mov    0x8(%ebp),%eax
c0103707:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010370b:	66 83 f8 08          	cmp    $0x8,%ax
c010370f:	0f 94 c0             	sete   %al
c0103712:	0f b6 c0             	movzbl %al,%eax
}
c0103715:	5d                   	pop    %ebp
c0103716:	c3                   	ret    

c0103717 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0103717:	55                   	push   %ebp
c0103718:	89 e5                	mov    %esp,%ebp
c010371a:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c010371d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103720:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103724:	c7 04 24 13 bb 10 c0 	movl   $0xc010bb13,(%esp)
c010372b:	e8 b2 e0 ff ff       	call   c01017e2 <cprintf>
    print_regs(&tf->tf_regs);
c0103730:	8b 45 08             	mov    0x8(%ebp),%eax
c0103733:	89 04 24             	mov    %eax,(%esp)
c0103736:	e8 a1 01 00 00       	call   c01038dc <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c010373b:	8b 45 08             	mov    0x8(%ebp),%eax
c010373e:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0103742:	0f b7 c0             	movzwl %ax,%eax
c0103745:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103749:	c7 04 24 24 bb 10 c0 	movl   $0xc010bb24,(%esp)
c0103750:	e8 8d e0 ff ff       	call   c01017e2 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0103755:	8b 45 08             	mov    0x8(%ebp),%eax
c0103758:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c010375c:	0f b7 c0             	movzwl %ax,%eax
c010375f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103763:	c7 04 24 37 bb 10 c0 	movl   $0xc010bb37,(%esp)
c010376a:	e8 73 e0 ff ff       	call   c01017e2 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c010376f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103772:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0103776:	0f b7 c0             	movzwl %ax,%eax
c0103779:	89 44 24 04          	mov    %eax,0x4(%esp)
c010377d:	c7 04 24 4a bb 10 c0 	movl   $0xc010bb4a,(%esp)
c0103784:	e8 59 e0 ff ff       	call   c01017e2 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0103789:	8b 45 08             	mov    0x8(%ebp),%eax
c010378c:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0103790:	0f b7 c0             	movzwl %ax,%eax
c0103793:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103797:	c7 04 24 5d bb 10 c0 	movl   $0xc010bb5d,(%esp)
c010379e:	e8 3f e0 ff ff       	call   c01017e2 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c01037a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01037a6:	8b 40 30             	mov    0x30(%eax),%eax
c01037a9:	89 04 24             	mov    %eax,(%esp)
c01037ac:	e8 1f ff ff ff       	call   c01036d0 <trapname>
c01037b1:	8b 55 08             	mov    0x8(%ebp),%edx
c01037b4:	8b 52 30             	mov    0x30(%edx),%edx
c01037b7:	89 44 24 08          	mov    %eax,0x8(%esp)
c01037bb:	89 54 24 04          	mov    %edx,0x4(%esp)
c01037bf:	c7 04 24 70 bb 10 c0 	movl   $0xc010bb70,(%esp)
c01037c6:	e8 17 e0 ff ff       	call   c01017e2 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01037cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01037ce:	8b 40 34             	mov    0x34(%eax),%eax
c01037d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01037d5:	c7 04 24 82 bb 10 c0 	movl   $0xc010bb82,(%esp)
c01037dc:	e8 01 e0 ff ff       	call   c01017e2 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c01037e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01037e4:	8b 40 38             	mov    0x38(%eax),%eax
c01037e7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01037eb:	c7 04 24 91 bb 10 c0 	movl   $0xc010bb91,(%esp)
c01037f2:	e8 eb df ff ff       	call   c01017e2 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c01037f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01037fa:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01037fe:	0f b7 c0             	movzwl %ax,%eax
c0103801:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103805:	c7 04 24 a0 bb 10 c0 	movl   $0xc010bba0,(%esp)
c010380c:	e8 d1 df ff ff       	call   c01017e2 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0103811:	8b 45 08             	mov    0x8(%ebp),%eax
c0103814:	8b 40 40             	mov    0x40(%eax),%eax
c0103817:	89 44 24 04          	mov    %eax,0x4(%esp)
c010381b:	c7 04 24 b3 bb 10 c0 	movl   $0xc010bbb3,(%esp)
c0103822:	e8 bb df ff ff       	call   c01017e2 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0103827:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010382e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0103835:	eb 3e                	jmp    c0103875 <print_trapframe+0x15e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0103837:	8b 45 08             	mov    0x8(%ebp),%eax
c010383a:	8b 50 40             	mov    0x40(%eax),%edx
c010383d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103840:	21 d0                	and    %edx,%eax
c0103842:	85 c0                	test   %eax,%eax
c0103844:	74 28                	je     c010386e <print_trapframe+0x157>
c0103846:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103849:	8b 04 85 80 85 12 c0 	mov    -0x3fed7a80(,%eax,4),%eax
c0103850:	85 c0                	test   %eax,%eax
c0103852:	74 1a                	je     c010386e <print_trapframe+0x157>
            cprintf("%s,", IA32flags[i]);
c0103854:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103857:	8b 04 85 80 85 12 c0 	mov    -0x3fed7a80(,%eax,4),%eax
c010385e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103862:	c7 04 24 c2 bb 10 c0 	movl   $0xc010bbc2,(%esp)
c0103869:	e8 74 df ff ff       	call   c01017e2 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c010386e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103872:	d1 65 f0             	shll   -0x10(%ebp)
c0103875:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103878:	83 f8 17             	cmp    $0x17,%eax
c010387b:	76 ba                	jbe    c0103837 <print_trapframe+0x120>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c010387d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103880:	8b 40 40             	mov    0x40(%eax),%eax
c0103883:	25 00 30 00 00       	and    $0x3000,%eax
c0103888:	c1 e8 0c             	shr    $0xc,%eax
c010388b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010388f:	c7 04 24 c6 bb 10 c0 	movl   $0xc010bbc6,(%esp)
c0103896:	e8 47 df ff ff       	call   c01017e2 <cprintf>

    if (!trap_in_kernel(tf)) {
c010389b:	8b 45 08             	mov    0x8(%ebp),%eax
c010389e:	89 04 24             	mov    %eax,(%esp)
c01038a1:	e8 5b fe ff ff       	call   c0103701 <trap_in_kernel>
c01038a6:	85 c0                	test   %eax,%eax
c01038a8:	75 30                	jne    c01038da <print_trapframe+0x1c3>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c01038aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01038ad:	8b 40 44             	mov    0x44(%eax),%eax
c01038b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01038b4:	c7 04 24 cf bb 10 c0 	movl   $0xc010bbcf,(%esp)
c01038bb:	e8 22 df ff ff       	call   c01017e2 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01038c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01038c3:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01038c7:	0f b7 c0             	movzwl %ax,%eax
c01038ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01038ce:	c7 04 24 de bb 10 c0 	movl   $0xc010bbde,(%esp)
c01038d5:	e8 08 df ff ff       	call   c01017e2 <cprintf>
    }
}
c01038da:	c9                   	leave  
c01038db:	c3                   	ret    

c01038dc <print_regs>:

void
print_regs(struct pushregs *regs) {
c01038dc:	55                   	push   %ebp
c01038dd:	89 e5                	mov    %esp,%ebp
c01038df:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c01038e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01038e5:	8b 00                	mov    (%eax),%eax
c01038e7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01038eb:	c7 04 24 f1 bb 10 c0 	movl   $0xc010bbf1,(%esp)
c01038f2:	e8 eb de ff ff       	call   c01017e2 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c01038f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01038fa:	8b 40 04             	mov    0x4(%eax),%eax
c01038fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103901:	c7 04 24 00 bc 10 c0 	movl   $0xc010bc00,(%esp)
c0103908:	e8 d5 de ff ff       	call   c01017e2 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c010390d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103910:	8b 40 08             	mov    0x8(%eax),%eax
c0103913:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103917:	c7 04 24 0f bc 10 c0 	movl   $0xc010bc0f,(%esp)
c010391e:	e8 bf de ff ff       	call   c01017e2 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0103923:	8b 45 08             	mov    0x8(%ebp),%eax
c0103926:	8b 40 0c             	mov    0xc(%eax),%eax
c0103929:	89 44 24 04          	mov    %eax,0x4(%esp)
c010392d:	c7 04 24 1e bc 10 c0 	movl   $0xc010bc1e,(%esp)
c0103934:	e8 a9 de ff ff       	call   c01017e2 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0103939:	8b 45 08             	mov    0x8(%ebp),%eax
c010393c:	8b 40 10             	mov    0x10(%eax),%eax
c010393f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103943:	c7 04 24 2d bc 10 c0 	movl   $0xc010bc2d,(%esp)
c010394a:	e8 93 de ff ff       	call   c01017e2 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c010394f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103952:	8b 40 14             	mov    0x14(%eax),%eax
c0103955:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103959:	c7 04 24 3c bc 10 c0 	movl   $0xc010bc3c,(%esp)
c0103960:	e8 7d de ff ff       	call   c01017e2 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0103965:	8b 45 08             	mov    0x8(%ebp),%eax
c0103968:	8b 40 18             	mov    0x18(%eax),%eax
c010396b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010396f:	c7 04 24 4b bc 10 c0 	movl   $0xc010bc4b,(%esp)
c0103976:	e8 67 de ff ff       	call   c01017e2 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c010397b:	8b 45 08             	mov    0x8(%ebp),%eax
c010397e:	8b 40 1c             	mov    0x1c(%eax),%eax
c0103981:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103985:	c7 04 24 5a bc 10 c0 	movl   $0xc010bc5a,(%esp)
c010398c:	e8 51 de ff ff       	call   c01017e2 <cprintf>
}
c0103991:	c9                   	leave  
c0103992:	c3                   	ret    

c0103993 <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c0103993:	55                   	push   %ebp
c0103994:	89 e5                	mov    %esp,%ebp
c0103996:	53                   	push   %ebx
c0103997:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c010399a:	8b 45 08             	mov    0x8(%ebp),%eax
c010399d:	8b 40 34             	mov    0x34(%eax),%eax
c01039a0:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01039a3:	85 c0                	test   %eax,%eax
c01039a5:	74 07                	je     c01039ae <print_pgfault+0x1b>
c01039a7:	b9 69 bc 10 c0       	mov    $0xc010bc69,%ecx
c01039ac:	eb 05                	jmp    c01039b3 <print_pgfault+0x20>
c01039ae:	b9 7a bc 10 c0       	mov    $0xc010bc7a,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c01039b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01039b6:	8b 40 34             	mov    0x34(%eax),%eax
c01039b9:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01039bc:	85 c0                	test   %eax,%eax
c01039be:	74 07                	je     c01039c7 <print_pgfault+0x34>
c01039c0:	ba 57 00 00 00       	mov    $0x57,%edx
c01039c5:	eb 05                	jmp    c01039cc <print_pgfault+0x39>
c01039c7:	ba 52 00 00 00       	mov    $0x52,%edx
            (tf->tf_err & 4) ? 'U' : 'K',
c01039cc:	8b 45 08             	mov    0x8(%ebp),%eax
c01039cf:	8b 40 34             	mov    0x34(%eax),%eax
c01039d2:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01039d5:	85 c0                	test   %eax,%eax
c01039d7:	74 07                	je     c01039e0 <print_pgfault+0x4d>
c01039d9:	b8 55 00 00 00       	mov    $0x55,%eax
c01039de:	eb 05                	jmp    c01039e5 <print_pgfault+0x52>
c01039e0:	b8 4b 00 00 00       	mov    $0x4b,%eax
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c01039e5:	0f 20 d3             	mov    %cr2,%ebx
c01039e8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
    return cr2;
c01039eb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
c01039ee:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c01039f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01039f6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01039fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01039fe:	c7 04 24 88 bc 10 c0 	movl   $0xc010bc88,(%esp)
c0103a05:	e8 d8 dd ff ff       	call   c01017e2 <cprintf>
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c0103a0a:	83 c4 34             	add    $0x34,%esp
c0103a0d:	5b                   	pop    %ebx
c0103a0e:	5d                   	pop    %ebp
c0103a0f:	c3                   	ret    

c0103a10 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c0103a10:	55                   	push   %ebp
c0103a11:	89 e5                	mov    %esp,%ebp
c0103a13:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c0103a16:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a19:	89 04 24             	mov    %eax,(%esp)
c0103a1c:	e8 72 ff ff ff       	call   c0103993 <print_pgfault>
    if (check_mm_struct != NULL) {
c0103a21:	a1 6c e1 12 c0       	mov    0xc012e16c,%eax
c0103a26:	85 c0                	test   %eax,%eax
c0103a28:	74 28                	je     c0103a52 <pgfault_handler+0x42>
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0103a2a:	0f 20 d0             	mov    %cr2,%eax
c0103a2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0103a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c0103a33:	89 c1                	mov    %eax,%ecx
c0103a35:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a38:	8b 50 34             	mov    0x34(%eax),%edx
c0103a3b:	a1 6c e1 12 c0       	mov    0xc012e16c,%eax
c0103a40:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0103a44:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103a48:	89 04 24             	mov    %eax,(%esp)
c0103a4b:	e8 43 5d 00 00       	call   c0109793 <do_pgfault>
c0103a50:	eb 1c                	jmp    c0103a6e <pgfault_handler+0x5e>
    }
    panic("unhandled page fault.\n");
c0103a52:	c7 44 24 08 ab bc 10 	movl   $0xc010bcab,0x8(%esp)
c0103a59:	c0 
c0103a5a:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
c0103a61:	00 
c0103a62:	c7 04 24 ae ba 10 c0 	movl   $0xc010baae,(%esp)
c0103a69:	e8 fe e6 ff ff       	call   c010216c <__panic>
}
c0103a6e:	c9                   	leave  
c0103a6f:	c3                   	ret    

c0103a70 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c0103a70:	55                   	push   %ebp
c0103a71:	89 e5                	mov    %esp,%ebp
c0103a73:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c0103a76:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a79:	8b 40 30             	mov    0x30(%eax),%eax
c0103a7c:	83 f8 24             	cmp    $0x24,%eax
c0103a7f:	0f 84 c2 00 00 00    	je     c0103b47 <trap_dispatch+0xd7>
c0103a85:	83 f8 24             	cmp    $0x24,%eax
c0103a88:	77 18                	ja     c0103aa2 <trap_dispatch+0x32>
c0103a8a:	83 f8 20             	cmp    $0x20,%eax
c0103a8d:	74 7d                	je     c0103b0c <trap_dispatch+0x9c>
c0103a8f:	83 f8 21             	cmp    $0x21,%eax
c0103a92:	0f 84 d5 00 00 00    	je     c0103b6d <trap_dispatch+0xfd>
c0103a98:	83 f8 0e             	cmp    $0xe,%eax
c0103a9b:	74 28                	je     c0103ac5 <trap_dispatch+0x55>
c0103a9d:	e9 0d 01 00 00       	jmp    c0103baf <trap_dispatch+0x13f>
c0103aa2:	83 f8 2e             	cmp    $0x2e,%eax
c0103aa5:	0f 82 04 01 00 00    	jb     c0103baf <trap_dispatch+0x13f>
c0103aab:	83 f8 2f             	cmp    $0x2f,%eax
c0103aae:	0f 86 33 01 00 00    	jbe    c0103be7 <trap_dispatch+0x177>
c0103ab4:	83 e8 78             	sub    $0x78,%eax
c0103ab7:	83 f8 01             	cmp    $0x1,%eax
c0103aba:	0f 87 ef 00 00 00    	ja     c0103baf <trap_dispatch+0x13f>
c0103ac0:	e9 ce 00 00 00       	jmp    c0103b93 <trap_dispatch+0x123>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c0103ac5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ac8:	89 04 24             	mov    %eax,(%esp)
c0103acb:	e8 40 ff ff ff       	call   c0103a10 <pgfault_handler>
c0103ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103ad3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103ad7:	74 2e                	je     c0103b07 <trap_dispatch+0x97>
            print_trapframe(tf);
c0103ad9:	8b 45 08             	mov    0x8(%ebp),%eax
c0103adc:	89 04 24             	mov    %eax,(%esp)
c0103adf:	e8 33 fc ff ff       	call   c0103717 <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c0103ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ae7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103aeb:	c7 44 24 08 c2 bc 10 	movl   $0xc010bcc2,0x8(%esp)
c0103af2:	c0 
c0103af3:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c0103afa:	00 
c0103afb:	c7 04 24 ae ba 10 c0 	movl   $0xc010baae,(%esp)
c0103b02:	e8 65 e6 ff ff       	call   c010216c <__panic>
        }
        break;
c0103b07:	e9 dc 00 00 00       	jmp    c0103be8 <trap_dispatch+0x178>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0103b0c:	a1 74 e0 12 c0       	mov    0xc012e074,%eax
c0103b11:	83 c0 01             	add    $0x1,%eax
c0103b14:	a3 74 e0 12 c0       	mov    %eax,0xc012e074
        if (ticks % TICK_NUM == 0) {
c0103b19:	8b 0d 74 e0 12 c0    	mov    0xc012e074,%ecx
c0103b1f:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0103b24:	89 c8                	mov    %ecx,%eax
c0103b26:	f7 e2                	mul    %edx
c0103b28:	89 d0                	mov    %edx,%eax
c0103b2a:	c1 e8 05             	shr    $0x5,%eax
c0103b2d:	6b c0 64             	imul   $0x64,%eax,%eax
c0103b30:	29 c1                	sub    %eax,%ecx
c0103b32:	89 c8                	mov    %ecx,%eax
c0103b34:	85 c0                	test   %eax,%eax
c0103b36:	75 0a                	jne    c0103b42 <trap_dispatch+0xd2>
            print_ticks();
c0103b38:	e8 5f fa ff ff       	call   c010359c <print_ticks>
        }
        break;
c0103b3d:	e9 a6 00 00 00       	jmp    c0103be8 <trap_dispatch+0x178>
c0103b42:	e9 a1 00 00 00       	jmp    c0103be8 <trap_dispatch+0x178>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0103b47:	e8 9f ef ff ff       	call   c0102aeb <cons_getc>
c0103b4c:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0103b4f:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0103b53:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0103b57:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103b5b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103b5f:	c7 04 24 dd bc 10 c0 	movl   $0xc010bcdd,(%esp)
c0103b66:	e8 77 dc ff ff       	call   c01017e2 <cprintf>
        break;
c0103b6b:	eb 7b                	jmp    c0103be8 <trap_dispatch+0x178>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0103b6d:	e8 79 ef ff ff       	call   c0102aeb <cons_getc>
c0103b72:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0103b75:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0103b79:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0103b7d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103b81:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103b85:	c7 04 24 ef bc 10 c0 	movl   $0xc010bcef,(%esp)
c0103b8c:	e8 51 dc ff ff       	call   c01017e2 <cprintf>
        break;
c0103b91:	eb 55                	jmp    c0103be8 <trap_dispatch+0x178>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0103b93:	c7 44 24 08 fe bc 10 	movl   $0xc010bcfe,0x8(%esp)
c0103b9a:	c0 
c0103b9b:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0103ba2:	00 
c0103ba3:	c7 04 24 ae ba 10 c0 	movl   $0xc010baae,(%esp)
c0103baa:	e8 bd e5 ff ff       	call   c010216c <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0103baf:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bb2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0103bb6:	0f b7 c0             	movzwl %ax,%eax
c0103bb9:	83 e0 03             	and    $0x3,%eax
c0103bbc:	85 c0                	test   %eax,%eax
c0103bbe:	75 28                	jne    c0103be8 <trap_dispatch+0x178>
            print_trapframe(tf);
c0103bc0:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bc3:	89 04 24             	mov    %eax,(%esp)
c0103bc6:	e8 4c fb ff ff       	call   c0103717 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0103bcb:	c7 44 24 08 0e bd 10 	movl   $0xc010bd0e,0x8(%esp)
c0103bd2:	c0 
c0103bd3:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0103bda:	00 
c0103bdb:	c7 04 24 ae ba 10 c0 	movl   $0xc010baae,(%esp)
c0103be2:	e8 85 e5 ff ff       	call   c010216c <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0103be7:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0103be8:	c9                   	leave  
c0103be9:	c3                   	ret    

c0103bea <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0103bea:	55                   	push   %ebp
c0103beb:	89 e5                	mov    %esp,%ebp
c0103bed:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0103bf0:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bf3:	89 04 24             	mov    %eax,(%esp)
c0103bf6:	e8 75 fe ff ff       	call   c0103a70 <trap_dispatch>
}
c0103bfb:	c9                   	leave  
c0103bfc:	c3                   	ret    

c0103bfd <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0103bfd:	1e                   	push   %ds
    pushl %es
c0103bfe:	06                   	push   %es
    pushl %fs
c0103bff:	0f a0                	push   %fs
    pushl %gs
c0103c01:	0f a8                	push   %gs
    pushal
c0103c03:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0103c04:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0103c09:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0103c0b:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0103c0d:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0103c0e:	e8 d7 ff ff ff       	call   c0103bea <trap>

    # pop the pushed stack pointer
    popl %esp
c0103c13:	5c                   	pop    %esp

c0103c14 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0103c14:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0103c15:	0f a9                	pop    %gs
    popl %fs
c0103c17:	0f a1                	pop    %fs
    popl %es
c0103c19:	07                   	pop    %es
    popl %ds
c0103c1a:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0103c1b:	83 c4 08             	add    $0x8,%esp
    iret
c0103c1e:	cf                   	iret   

c0103c1f <forkrets>:

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
c0103c1f:	8b 64 24 04          	mov    0x4(%esp),%esp
    jmp __trapret
c0103c23:	e9 ec ff ff ff       	jmp    c0103c14 <__trapret>

c0103c28 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0103c28:	6a 00                	push   $0x0
  pushl $0
c0103c2a:	6a 00                	push   $0x0
  jmp __alltraps
c0103c2c:	e9 cc ff ff ff       	jmp    c0103bfd <__alltraps>

c0103c31 <vector1>:
.globl vector1
vector1:
  pushl $0
c0103c31:	6a 00                	push   $0x0
  pushl $1
c0103c33:	6a 01                	push   $0x1
  jmp __alltraps
c0103c35:	e9 c3 ff ff ff       	jmp    c0103bfd <__alltraps>

c0103c3a <vector2>:
.globl vector2
vector2:
  pushl $0
c0103c3a:	6a 00                	push   $0x0
  pushl $2
c0103c3c:	6a 02                	push   $0x2
  jmp __alltraps
c0103c3e:	e9 ba ff ff ff       	jmp    c0103bfd <__alltraps>

c0103c43 <vector3>:
.globl vector3
vector3:
  pushl $0
c0103c43:	6a 00                	push   $0x0
  pushl $3
c0103c45:	6a 03                	push   $0x3
  jmp __alltraps
c0103c47:	e9 b1 ff ff ff       	jmp    c0103bfd <__alltraps>

c0103c4c <vector4>:
.globl vector4
vector4:
  pushl $0
c0103c4c:	6a 00                	push   $0x0
  pushl $4
c0103c4e:	6a 04                	push   $0x4
  jmp __alltraps
c0103c50:	e9 a8 ff ff ff       	jmp    c0103bfd <__alltraps>

c0103c55 <vector5>:
.globl vector5
vector5:
  pushl $0
c0103c55:	6a 00                	push   $0x0
  pushl $5
c0103c57:	6a 05                	push   $0x5
  jmp __alltraps
c0103c59:	e9 9f ff ff ff       	jmp    c0103bfd <__alltraps>

c0103c5e <vector6>:
.globl vector6
vector6:
  pushl $0
c0103c5e:	6a 00                	push   $0x0
  pushl $6
c0103c60:	6a 06                	push   $0x6
  jmp __alltraps
c0103c62:	e9 96 ff ff ff       	jmp    c0103bfd <__alltraps>

c0103c67 <vector7>:
.globl vector7
vector7:
  pushl $0
c0103c67:	6a 00                	push   $0x0
  pushl $7
c0103c69:	6a 07                	push   $0x7
  jmp __alltraps
c0103c6b:	e9 8d ff ff ff       	jmp    c0103bfd <__alltraps>

c0103c70 <vector8>:
.globl vector8
vector8:
  pushl $8
c0103c70:	6a 08                	push   $0x8
  jmp __alltraps
c0103c72:	e9 86 ff ff ff       	jmp    c0103bfd <__alltraps>

c0103c77 <vector9>:
.globl vector9
vector9:
  pushl $9
c0103c77:	6a 09                	push   $0x9
  jmp __alltraps
c0103c79:	e9 7f ff ff ff       	jmp    c0103bfd <__alltraps>

c0103c7e <vector10>:
.globl vector10
vector10:
  pushl $10
c0103c7e:	6a 0a                	push   $0xa
  jmp __alltraps
c0103c80:	e9 78 ff ff ff       	jmp    c0103bfd <__alltraps>

c0103c85 <vector11>:
.globl vector11
vector11:
  pushl $11
c0103c85:	6a 0b                	push   $0xb
  jmp __alltraps
c0103c87:	e9 71 ff ff ff       	jmp    c0103bfd <__alltraps>

c0103c8c <vector12>:
.globl vector12
vector12:
  pushl $12
c0103c8c:	6a 0c                	push   $0xc
  jmp __alltraps
c0103c8e:	e9 6a ff ff ff       	jmp    c0103bfd <__alltraps>

c0103c93 <vector13>:
.globl vector13
vector13:
  pushl $13
c0103c93:	6a 0d                	push   $0xd
  jmp __alltraps
c0103c95:	e9 63 ff ff ff       	jmp    c0103bfd <__alltraps>

c0103c9a <vector14>:
.globl vector14
vector14:
  pushl $14
c0103c9a:	6a 0e                	push   $0xe
  jmp __alltraps
c0103c9c:	e9 5c ff ff ff       	jmp    c0103bfd <__alltraps>

c0103ca1 <vector15>:
.globl vector15
vector15:
  pushl $0
c0103ca1:	6a 00                	push   $0x0
  pushl $15
c0103ca3:	6a 0f                	push   $0xf
  jmp __alltraps
c0103ca5:	e9 53 ff ff ff       	jmp    c0103bfd <__alltraps>

c0103caa <vector16>:
.globl vector16
vector16:
  pushl $0
c0103caa:	6a 00                	push   $0x0
  pushl $16
c0103cac:	6a 10                	push   $0x10
  jmp __alltraps
c0103cae:	e9 4a ff ff ff       	jmp    c0103bfd <__alltraps>

c0103cb3 <vector17>:
.globl vector17
vector17:
  pushl $17
c0103cb3:	6a 11                	push   $0x11
  jmp __alltraps
c0103cb5:	e9 43 ff ff ff       	jmp    c0103bfd <__alltraps>

c0103cba <vector18>:
.globl vector18
vector18:
  pushl $0
c0103cba:	6a 00                	push   $0x0
  pushl $18
c0103cbc:	6a 12                	push   $0x12
  jmp __alltraps
c0103cbe:	e9 3a ff ff ff       	jmp    c0103bfd <__alltraps>

c0103cc3 <vector19>:
.globl vector19
vector19:
  pushl $0
c0103cc3:	6a 00                	push   $0x0
  pushl $19
c0103cc5:	6a 13                	push   $0x13
  jmp __alltraps
c0103cc7:	e9 31 ff ff ff       	jmp    c0103bfd <__alltraps>

c0103ccc <vector20>:
.globl vector20
vector20:
  pushl $0
c0103ccc:	6a 00                	push   $0x0
  pushl $20
c0103cce:	6a 14                	push   $0x14
  jmp __alltraps
c0103cd0:	e9 28 ff ff ff       	jmp    c0103bfd <__alltraps>

c0103cd5 <vector21>:
.globl vector21
vector21:
  pushl $0
c0103cd5:	6a 00                	push   $0x0
  pushl $21
c0103cd7:	6a 15                	push   $0x15
  jmp __alltraps
c0103cd9:	e9 1f ff ff ff       	jmp    c0103bfd <__alltraps>

c0103cde <vector22>:
.globl vector22
vector22:
  pushl $0
c0103cde:	6a 00                	push   $0x0
  pushl $22
c0103ce0:	6a 16                	push   $0x16
  jmp __alltraps
c0103ce2:	e9 16 ff ff ff       	jmp    c0103bfd <__alltraps>

c0103ce7 <vector23>:
.globl vector23
vector23:
  pushl $0
c0103ce7:	6a 00                	push   $0x0
  pushl $23
c0103ce9:	6a 17                	push   $0x17
  jmp __alltraps
c0103ceb:	e9 0d ff ff ff       	jmp    c0103bfd <__alltraps>

c0103cf0 <vector24>:
.globl vector24
vector24:
  pushl $0
c0103cf0:	6a 00                	push   $0x0
  pushl $24
c0103cf2:	6a 18                	push   $0x18
  jmp __alltraps
c0103cf4:	e9 04 ff ff ff       	jmp    c0103bfd <__alltraps>

c0103cf9 <vector25>:
.globl vector25
vector25:
  pushl $0
c0103cf9:	6a 00                	push   $0x0
  pushl $25
c0103cfb:	6a 19                	push   $0x19
  jmp __alltraps
c0103cfd:	e9 fb fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d02 <vector26>:
.globl vector26
vector26:
  pushl $0
c0103d02:	6a 00                	push   $0x0
  pushl $26
c0103d04:	6a 1a                	push   $0x1a
  jmp __alltraps
c0103d06:	e9 f2 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d0b <vector27>:
.globl vector27
vector27:
  pushl $0
c0103d0b:	6a 00                	push   $0x0
  pushl $27
c0103d0d:	6a 1b                	push   $0x1b
  jmp __alltraps
c0103d0f:	e9 e9 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d14 <vector28>:
.globl vector28
vector28:
  pushl $0
c0103d14:	6a 00                	push   $0x0
  pushl $28
c0103d16:	6a 1c                	push   $0x1c
  jmp __alltraps
c0103d18:	e9 e0 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d1d <vector29>:
.globl vector29
vector29:
  pushl $0
c0103d1d:	6a 00                	push   $0x0
  pushl $29
c0103d1f:	6a 1d                	push   $0x1d
  jmp __alltraps
c0103d21:	e9 d7 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d26 <vector30>:
.globl vector30
vector30:
  pushl $0
c0103d26:	6a 00                	push   $0x0
  pushl $30
c0103d28:	6a 1e                	push   $0x1e
  jmp __alltraps
c0103d2a:	e9 ce fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d2f <vector31>:
.globl vector31
vector31:
  pushl $0
c0103d2f:	6a 00                	push   $0x0
  pushl $31
c0103d31:	6a 1f                	push   $0x1f
  jmp __alltraps
c0103d33:	e9 c5 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d38 <vector32>:
.globl vector32
vector32:
  pushl $0
c0103d38:	6a 00                	push   $0x0
  pushl $32
c0103d3a:	6a 20                	push   $0x20
  jmp __alltraps
c0103d3c:	e9 bc fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d41 <vector33>:
.globl vector33
vector33:
  pushl $0
c0103d41:	6a 00                	push   $0x0
  pushl $33
c0103d43:	6a 21                	push   $0x21
  jmp __alltraps
c0103d45:	e9 b3 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d4a <vector34>:
.globl vector34
vector34:
  pushl $0
c0103d4a:	6a 00                	push   $0x0
  pushl $34
c0103d4c:	6a 22                	push   $0x22
  jmp __alltraps
c0103d4e:	e9 aa fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d53 <vector35>:
.globl vector35
vector35:
  pushl $0
c0103d53:	6a 00                	push   $0x0
  pushl $35
c0103d55:	6a 23                	push   $0x23
  jmp __alltraps
c0103d57:	e9 a1 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d5c <vector36>:
.globl vector36
vector36:
  pushl $0
c0103d5c:	6a 00                	push   $0x0
  pushl $36
c0103d5e:	6a 24                	push   $0x24
  jmp __alltraps
c0103d60:	e9 98 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d65 <vector37>:
.globl vector37
vector37:
  pushl $0
c0103d65:	6a 00                	push   $0x0
  pushl $37
c0103d67:	6a 25                	push   $0x25
  jmp __alltraps
c0103d69:	e9 8f fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d6e <vector38>:
.globl vector38
vector38:
  pushl $0
c0103d6e:	6a 00                	push   $0x0
  pushl $38
c0103d70:	6a 26                	push   $0x26
  jmp __alltraps
c0103d72:	e9 86 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d77 <vector39>:
.globl vector39
vector39:
  pushl $0
c0103d77:	6a 00                	push   $0x0
  pushl $39
c0103d79:	6a 27                	push   $0x27
  jmp __alltraps
c0103d7b:	e9 7d fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d80 <vector40>:
.globl vector40
vector40:
  pushl $0
c0103d80:	6a 00                	push   $0x0
  pushl $40
c0103d82:	6a 28                	push   $0x28
  jmp __alltraps
c0103d84:	e9 74 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d89 <vector41>:
.globl vector41
vector41:
  pushl $0
c0103d89:	6a 00                	push   $0x0
  pushl $41
c0103d8b:	6a 29                	push   $0x29
  jmp __alltraps
c0103d8d:	e9 6b fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d92 <vector42>:
.globl vector42
vector42:
  pushl $0
c0103d92:	6a 00                	push   $0x0
  pushl $42
c0103d94:	6a 2a                	push   $0x2a
  jmp __alltraps
c0103d96:	e9 62 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103d9b <vector43>:
.globl vector43
vector43:
  pushl $0
c0103d9b:	6a 00                	push   $0x0
  pushl $43
c0103d9d:	6a 2b                	push   $0x2b
  jmp __alltraps
c0103d9f:	e9 59 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103da4 <vector44>:
.globl vector44
vector44:
  pushl $0
c0103da4:	6a 00                	push   $0x0
  pushl $44
c0103da6:	6a 2c                	push   $0x2c
  jmp __alltraps
c0103da8:	e9 50 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103dad <vector45>:
.globl vector45
vector45:
  pushl $0
c0103dad:	6a 00                	push   $0x0
  pushl $45
c0103daf:	6a 2d                	push   $0x2d
  jmp __alltraps
c0103db1:	e9 47 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103db6 <vector46>:
.globl vector46
vector46:
  pushl $0
c0103db6:	6a 00                	push   $0x0
  pushl $46
c0103db8:	6a 2e                	push   $0x2e
  jmp __alltraps
c0103dba:	e9 3e fe ff ff       	jmp    c0103bfd <__alltraps>

c0103dbf <vector47>:
.globl vector47
vector47:
  pushl $0
c0103dbf:	6a 00                	push   $0x0
  pushl $47
c0103dc1:	6a 2f                	push   $0x2f
  jmp __alltraps
c0103dc3:	e9 35 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103dc8 <vector48>:
.globl vector48
vector48:
  pushl $0
c0103dc8:	6a 00                	push   $0x0
  pushl $48
c0103dca:	6a 30                	push   $0x30
  jmp __alltraps
c0103dcc:	e9 2c fe ff ff       	jmp    c0103bfd <__alltraps>

c0103dd1 <vector49>:
.globl vector49
vector49:
  pushl $0
c0103dd1:	6a 00                	push   $0x0
  pushl $49
c0103dd3:	6a 31                	push   $0x31
  jmp __alltraps
c0103dd5:	e9 23 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103dda <vector50>:
.globl vector50
vector50:
  pushl $0
c0103dda:	6a 00                	push   $0x0
  pushl $50
c0103ddc:	6a 32                	push   $0x32
  jmp __alltraps
c0103dde:	e9 1a fe ff ff       	jmp    c0103bfd <__alltraps>

c0103de3 <vector51>:
.globl vector51
vector51:
  pushl $0
c0103de3:	6a 00                	push   $0x0
  pushl $51
c0103de5:	6a 33                	push   $0x33
  jmp __alltraps
c0103de7:	e9 11 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103dec <vector52>:
.globl vector52
vector52:
  pushl $0
c0103dec:	6a 00                	push   $0x0
  pushl $52
c0103dee:	6a 34                	push   $0x34
  jmp __alltraps
c0103df0:	e9 08 fe ff ff       	jmp    c0103bfd <__alltraps>

c0103df5 <vector53>:
.globl vector53
vector53:
  pushl $0
c0103df5:	6a 00                	push   $0x0
  pushl $53
c0103df7:	6a 35                	push   $0x35
  jmp __alltraps
c0103df9:	e9 ff fd ff ff       	jmp    c0103bfd <__alltraps>

c0103dfe <vector54>:
.globl vector54
vector54:
  pushl $0
c0103dfe:	6a 00                	push   $0x0
  pushl $54
c0103e00:	6a 36                	push   $0x36
  jmp __alltraps
c0103e02:	e9 f6 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e07 <vector55>:
.globl vector55
vector55:
  pushl $0
c0103e07:	6a 00                	push   $0x0
  pushl $55
c0103e09:	6a 37                	push   $0x37
  jmp __alltraps
c0103e0b:	e9 ed fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e10 <vector56>:
.globl vector56
vector56:
  pushl $0
c0103e10:	6a 00                	push   $0x0
  pushl $56
c0103e12:	6a 38                	push   $0x38
  jmp __alltraps
c0103e14:	e9 e4 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e19 <vector57>:
.globl vector57
vector57:
  pushl $0
c0103e19:	6a 00                	push   $0x0
  pushl $57
c0103e1b:	6a 39                	push   $0x39
  jmp __alltraps
c0103e1d:	e9 db fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e22 <vector58>:
.globl vector58
vector58:
  pushl $0
c0103e22:	6a 00                	push   $0x0
  pushl $58
c0103e24:	6a 3a                	push   $0x3a
  jmp __alltraps
c0103e26:	e9 d2 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e2b <vector59>:
.globl vector59
vector59:
  pushl $0
c0103e2b:	6a 00                	push   $0x0
  pushl $59
c0103e2d:	6a 3b                	push   $0x3b
  jmp __alltraps
c0103e2f:	e9 c9 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e34 <vector60>:
.globl vector60
vector60:
  pushl $0
c0103e34:	6a 00                	push   $0x0
  pushl $60
c0103e36:	6a 3c                	push   $0x3c
  jmp __alltraps
c0103e38:	e9 c0 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e3d <vector61>:
.globl vector61
vector61:
  pushl $0
c0103e3d:	6a 00                	push   $0x0
  pushl $61
c0103e3f:	6a 3d                	push   $0x3d
  jmp __alltraps
c0103e41:	e9 b7 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e46 <vector62>:
.globl vector62
vector62:
  pushl $0
c0103e46:	6a 00                	push   $0x0
  pushl $62
c0103e48:	6a 3e                	push   $0x3e
  jmp __alltraps
c0103e4a:	e9 ae fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e4f <vector63>:
.globl vector63
vector63:
  pushl $0
c0103e4f:	6a 00                	push   $0x0
  pushl $63
c0103e51:	6a 3f                	push   $0x3f
  jmp __alltraps
c0103e53:	e9 a5 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e58 <vector64>:
.globl vector64
vector64:
  pushl $0
c0103e58:	6a 00                	push   $0x0
  pushl $64
c0103e5a:	6a 40                	push   $0x40
  jmp __alltraps
c0103e5c:	e9 9c fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e61 <vector65>:
.globl vector65
vector65:
  pushl $0
c0103e61:	6a 00                	push   $0x0
  pushl $65
c0103e63:	6a 41                	push   $0x41
  jmp __alltraps
c0103e65:	e9 93 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e6a <vector66>:
.globl vector66
vector66:
  pushl $0
c0103e6a:	6a 00                	push   $0x0
  pushl $66
c0103e6c:	6a 42                	push   $0x42
  jmp __alltraps
c0103e6e:	e9 8a fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e73 <vector67>:
.globl vector67
vector67:
  pushl $0
c0103e73:	6a 00                	push   $0x0
  pushl $67
c0103e75:	6a 43                	push   $0x43
  jmp __alltraps
c0103e77:	e9 81 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e7c <vector68>:
.globl vector68
vector68:
  pushl $0
c0103e7c:	6a 00                	push   $0x0
  pushl $68
c0103e7e:	6a 44                	push   $0x44
  jmp __alltraps
c0103e80:	e9 78 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e85 <vector69>:
.globl vector69
vector69:
  pushl $0
c0103e85:	6a 00                	push   $0x0
  pushl $69
c0103e87:	6a 45                	push   $0x45
  jmp __alltraps
c0103e89:	e9 6f fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e8e <vector70>:
.globl vector70
vector70:
  pushl $0
c0103e8e:	6a 00                	push   $0x0
  pushl $70
c0103e90:	6a 46                	push   $0x46
  jmp __alltraps
c0103e92:	e9 66 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103e97 <vector71>:
.globl vector71
vector71:
  pushl $0
c0103e97:	6a 00                	push   $0x0
  pushl $71
c0103e99:	6a 47                	push   $0x47
  jmp __alltraps
c0103e9b:	e9 5d fd ff ff       	jmp    c0103bfd <__alltraps>

c0103ea0 <vector72>:
.globl vector72
vector72:
  pushl $0
c0103ea0:	6a 00                	push   $0x0
  pushl $72
c0103ea2:	6a 48                	push   $0x48
  jmp __alltraps
c0103ea4:	e9 54 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103ea9 <vector73>:
.globl vector73
vector73:
  pushl $0
c0103ea9:	6a 00                	push   $0x0
  pushl $73
c0103eab:	6a 49                	push   $0x49
  jmp __alltraps
c0103ead:	e9 4b fd ff ff       	jmp    c0103bfd <__alltraps>

c0103eb2 <vector74>:
.globl vector74
vector74:
  pushl $0
c0103eb2:	6a 00                	push   $0x0
  pushl $74
c0103eb4:	6a 4a                	push   $0x4a
  jmp __alltraps
c0103eb6:	e9 42 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103ebb <vector75>:
.globl vector75
vector75:
  pushl $0
c0103ebb:	6a 00                	push   $0x0
  pushl $75
c0103ebd:	6a 4b                	push   $0x4b
  jmp __alltraps
c0103ebf:	e9 39 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103ec4 <vector76>:
.globl vector76
vector76:
  pushl $0
c0103ec4:	6a 00                	push   $0x0
  pushl $76
c0103ec6:	6a 4c                	push   $0x4c
  jmp __alltraps
c0103ec8:	e9 30 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103ecd <vector77>:
.globl vector77
vector77:
  pushl $0
c0103ecd:	6a 00                	push   $0x0
  pushl $77
c0103ecf:	6a 4d                	push   $0x4d
  jmp __alltraps
c0103ed1:	e9 27 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103ed6 <vector78>:
.globl vector78
vector78:
  pushl $0
c0103ed6:	6a 00                	push   $0x0
  pushl $78
c0103ed8:	6a 4e                	push   $0x4e
  jmp __alltraps
c0103eda:	e9 1e fd ff ff       	jmp    c0103bfd <__alltraps>

c0103edf <vector79>:
.globl vector79
vector79:
  pushl $0
c0103edf:	6a 00                	push   $0x0
  pushl $79
c0103ee1:	6a 4f                	push   $0x4f
  jmp __alltraps
c0103ee3:	e9 15 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103ee8 <vector80>:
.globl vector80
vector80:
  pushl $0
c0103ee8:	6a 00                	push   $0x0
  pushl $80
c0103eea:	6a 50                	push   $0x50
  jmp __alltraps
c0103eec:	e9 0c fd ff ff       	jmp    c0103bfd <__alltraps>

c0103ef1 <vector81>:
.globl vector81
vector81:
  pushl $0
c0103ef1:	6a 00                	push   $0x0
  pushl $81
c0103ef3:	6a 51                	push   $0x51
  jmp __alltraps
c0103ef5:	e9 03 fd ff ff       	jmp    c0103bfd <__alltraps>

c0103efa <vector82>:
.globl vector82
vector82:
  pushl $0
c0103efa:	6a 00                	push   $0x0
  pushl $82
c0103efc:	6a 52                	push   $0x52
  jmp __alltraps
c0103efe:	e9 fa fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f03 <vector83>:
.globl vector83
vector83:
  pushl $0
c0103f03:	6a 00                	push   $0x0
  pushl $83
c0103f05:	6a 53                	push   $0x53
  jmp __alltraps
c0103f07:	e9 f1 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f0c <vector84>:
.globl vector84
vector84:
  pushl $0
c0103f0c:	6a 00                	push   $0x0
  pushl $84
c0103f0e:	6a 54                	push   $0x54
  jmp __alltraps
c0103f10:	e9 e8 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f15 <vector85>:
.globl vector85
vector85:
  pushl $0
c0103f15:	6a 00                	push   $0x0
  pushl $85
c0103f17:	6a 55                	push   $0x55
  jmp __alltraps
c0103f19:	e9 df fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f1e <vector86>:
.globl vector86
vector86:
  pushl $0
c0103f1e:	6a 00                	push   $0x0
  pushl $86
c0103f20:	6a 56                	push   $0x56
  jmp __alltraps
c0103f22:	e9 d6 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f27 <vector87>:
.globl vector87
vector87:
  pushl $0
c0103f27:	6a 00                	push   $0x0
  pushl $87
c0103f29:	6a 57                	push   $0x57
  jmp __alltraps
c0103f2b:	e9 cd fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f30 <vector88>:
.globl vector88
vector88:
  pushl $0
c0103f30:	6a 00                	push   $0x0
  pushl $88
c0103f32:	6a 58                	push   $0x58
  jmp __alltraps
c0103f34:	e9 c4 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f39 <vector89>:
.globl vector89
vector89:
  pushl $0
c0103f39:	6a 00                	push   $0x0
  pushl $89
c0103f3b:	6a 59                	push   $0x59
  jmp __alltraps
c0103f3d:	e9 bb fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f42 <vector90>:
.globl vector90
vector90:
  pushl $0
c0103f42:	6a 00                	push   $0x0
  pushl $90
c0103f44:	6a 5a                	push   $0x5a
  jmp __alltraps
c0103f46:	e9 b2 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f4b <vector91>:
.globl vector91
vector91:
  pushl $0
c0103f4b:	6a 00                	push   $0x0
  pushl $91
c0103f4d:	6a 5b                	push   $0x5b
  jmp __alltraps
c0103f4f:	e9 a9 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f54 <vector92>:
.globl vector92
vector92:
  pushl $0
c0103f54:	6a 00                	push   $0x0
  pushl $92
c0103f56:	6a 5c                	push   $0x5c
  jmp __alltraps
c0103f58:	e9 a0 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f5d <vector93>:
.globl vector93
vector93:
  pushl $0
c0103f5d:	6a 00                	push   $0x0
  pushl $93
c0103f5f:	6a 5d                	push   $0x5d
  jmp __alltraps
c0103f61:	e9 97 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f66 <vector94>:
.globl vector94
vector94:
  pushl $0
c0103f66:	6a 00                	push   $0x0
  pushl $94
c0103f68:	6a 5e                	push   $0x5e
  jmp __alltraps
c0103f6a:	e9 8e fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f6f <vector95>:
.globl vector95
vector95:
  pushl $0
c0103f6f:	6a 00                	push   $0x0
  pushl $95
c0103f71:	6a 5f                	push   $0x5f
  jmp __alltraps
c0103f73:	e9 85 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f78 <vector96>:
.globl vector96
vector96:
  pushl $0
c0103f78:	6a 00                	push   $0x0
  pushl $96
c0103f7a:	6a 60                	push   $0x60
  jmp __alltraps
c0103f7c:	e9 7c fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f81 <vector97>:
.globl vector97
vector97:
  pushl $0
c0103f81:	6a 00                	push   $0x0
  pushl $97
c0103f83:	6a 61                	push   $0x61
  jmp __alltraps
c0103f85:	e9 73 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f8a <vector98>:
.globl vector98
vector98:
  pushl $0
c0103f8a:	6a 00                	push   $0x0
  pushl $98
c0103f8c:	6a 62                	push   $0x62
  jmp __alltraps
c0103f8e:	e9 6a fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f93 <vector99>:
.globl vector99
vector99:
  pushl $0
c0103f93:	6a 00                	push   $0x0
  pushl $99
c0103f95:	6a 63                	push   $0x63
  jmp __alltraps
c0103f97:	e9 61 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103f9c <vector100>:
.globl vector100
vector100:
  pushl $0
c0103f9c:	6a 00                	push   $0x0
  pushl $100
c0103f9e:	6a 64                	push   $0x64
  jmp __alltraps
c0103fa0:	e9 58 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103fa5 <vector101>:
.globl vector101
vector101:
  pushl $0
c0103fa5:	6a 00                	push   $0x0
  pushl $101
c0103fa7:	6a 65                	push   $0x65
  jmp __alltraps
c0103fa9:	e9 4f fc ff ff       	jmp    c0103bfd <__alltraps>

c0103fae <vector102>:
.globl vector102
vector102:
  pushl $0
c0103fae:	6a 00                	push   $0x0
  pushl $102
c0103fb0:	6a 66                	push   $0x66
  jmp __alltraps
c0103fb2:	e9 46 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103fb7 <vector103>:
.globl vector103
vector103:
  pushl $0
c0103fb7:	6a 00                	push   $0x0
  pushl $103
c0103fb9:	6a 67                	push   $0x67
  jmp __alltraps
c0103fbb:	e9 3d fc ff ff       	jmp    c0103bfd <__alltraps>

c0103fc0 <vector104>:
.globl vector104
vector104:
  pushl $0
c0103fc0:	6a 00                	push   $0x0
  pushl $104
c0103fc2:	6a 68                	push   $0x68
  jmp __alltraps
c0103fc4:	e9 34 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103fc9 <vector105>:
.globl vector105
vector105:
  pushl $0
c0103fc9:	6a 00                	push   $0x0
  pushl $105
c0103fcb:	6a 69                	push   $0x69
  jmp __alltraps
c0103fcd:	e9 2b fc ff ff       	jmp    c0103bfd <__alltraps>

c0103fd2 <vector106>:
.globl vector106
vector106:
  pushl $0
c0103fd2:	6a 00                	push   $0x0
  pushl $106
c0103fd4:	6a 6a                	push   $0x6a
  jmp __alltraps
c0103fd6:	e9 22 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103fdb <vector107>:
.globl vector107
vector107:
  pushl $0
c0103fdb:	6a 00                	push   $0x0
  pushl $107
c0103fdd:	6a 6b                	push   $0x6b
  jmp __alltraps
c0103fdf:	e9 19 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103fe4 <vector108>:
.globl vector108
vector108:
  pushl $0
c0103fe4:	6a 00                	push   $0x0
  pushl $108
c0103fe6:	6a 6c                	push   $0x6c
  jmp __alltraps
c0103fe8:	e9 10 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103fed <vector109>:
.globl vector109
vector109:
  pushl $0
c0103fed:	6a 00                	push   $0x0
  pushl $109
c0103fef:	6a 6d                	push   $0x6d
  jmp __alltraps
c0103ff1:	e9 07 fc ff ff       	jmp    c0103bfd <__alltraps>

c0103ff6 <vector110>:
.globl vector110
vector110:
  pushl $0
c0103ff6:	6a 00                	push   $0x0
  pushl $110
c0103ff8:	6a 6e                	push   $0x6e
  jmp __alltraps
c0103ffa:	e9 fe fb ff ff       	jmp    c0103bfd <__alltraps>

c0103fff <vector111>:
.globl vector111
vector111:
  pushl $0
c0103fff:	6a 00                	push   $0x0
  pushl $111
c0104001:	6a 6f                	push   $0x6f
  jmp __alltraps
c0104003:	e9 f5 fb ff ff       	jmp    c0103bfd <__alltraps>

c0104008 <vector112>:
.globl vector112
vector112:
  pushl $0
c0104008:	6a 00                	push   $0x0
  pushl $112
c010400a:	6a 70                	push   $0x70
  jmp __alltraps
c010400c:	e9 ec fb ff ff       	jmp    c0103bfd <__alltraps>

c0104011 <vector113>:
.globl vector113
vector113:
  pushl $0
c0104011:	6a 00                	push   $0x0
  pushl $113
c0104013:	6a 71                	push   $0x71
  jmp __alltraps
c0104015:	e9 e3 fb ff ff       	jmp    c0103bfd <__alltraps>

c010401a <vector114>:
.globl vector114
vector114:
  pushl $0
c010401a:	6a 00                	push   $0x0
  pushl $114
c010401c:	6a 72                	push   $0x72
  jmp __alltraps
c010401e:	e9 da fb ff ff       	jmp    c0103bfd <__alltraps>

c0104023 <vector115>:
.globl vector115
vector115:
  pushl $0
c0104023:	6a 00                	push   $0x0
  pushl $115
c0104025:	6a 73                	push   $0x73
  jmp __alltraps
c0104027:	e9 d1 fb ff ff       	jmp    c0103bfd <__alltraps>

c010402c <vector116>:
.globl vector116
vector116:
  pushl $0
c010402c:	6a 00                	push   $0x0
  pushl $116
c010402e:	6a 74                	push   $0x74
  jmp __alltraps
c0104030:	e9 c8 fb ff ff       	jmp    c0103bfd <__alltraps>

c0104035 <vector117>:
.globl vector117
vector117:
  pushl $0
c0104035:	6a 00                	push   $0x0
  pushl $117
c0104037:	6a 75                	push   $0x75
  jmp __alltraps
c0104039:	e9 bf fb ff ff       	jmp    c0103bfd <__alltraps>

c010403e <vector118>:
.globl vector118
vector118:
  pushl $0
c010403e:	6a 00                	push   $0x0
  pushl $118
c0104040:	6a 76                	push   $0x76
  jmp __alltraps
c0104042:	e9 b6 fb ff ff       	jmp    c0103bfd <__alltraps>

c0104047 <vector119>:
.globl vector119
vector119:
  pushl $0
c0104047:	6a 00                	push   $0x0
  pushl $119
c0104049:	6a 77                	push   $0x77
  jmp __alltraps
c010404b:	e9 ad fb ff ff       	jmp    c0103bfd <__alltraps>

c0104050 <vector120>:
.globl vector120
vector120:
  pushl $0
c0104050:	6a 00                	push   $0x0
  pushl $120
c0104052:	6a 78                	push   $0x78
  jmp __alltraps
c0104054:	e9 a4 fb ff ff       	jmp    c0103bfd <__alltraps>

c0104059 <vector121>:
.globl vector121
vector121:
  pushl $0
c0104059:	6a 00                	push   $0x0
  pushl $121
c010405b:	6a 79                	push   $0x79
  jmp __alltraps
c010405d:	e9 9b fb ff ff       	jmp    c0103bfd <__alltraps>

c0104062 <vector122>:
.globl vector122
vector122:
  pushl $0
c0104062:	6a 00                	push   $0x0
  pushl $122
c0104064:	6a 7a                	push   $0x7a
  jmp __alltraps
c0104066:	e9 92 fb ff ff       	jmp    c0103bfd <__alltraps>

c010406b <vector123>:
.globl vector123
vector123:
  pushl $0
c010406b:	6a 00                	push   $0x0
  pushl $123
c010406d:	6a 7b                	push   $0x7b
  jmp __alltraps
c010406f:	e9 89 fb ff ff       	jmp    c0103bfd <__alltraps>

c0104074 <vector124>:
.globl vector124
vector124:
  pushl $0
c0104074:	6a 00                	push   $0x0
  pushl $124
c0104076:	6a 7c                	push   $0x7c
  jmp __alltraps
c0104078:	e9 80 fb ff ff       	jmp    c0103bfd <__alltraps>

c010407d <vector125>:
.globl vector125
vector125:
  pushl $0
c010407d:	6a 00                	push   $0x0
  pushl $125
c010407f:	6a 7d                	push   $0x7d
  jmp __alltraps
c0104081:	e9 77 fb ff ff       	jmp    c0103bfd <__alltraps>

c0104086 <vector126>:
.globl vector126
vector126:
  pushl $0
c0104086:	6a 00                	push   $0x0
  pushl $126
c0104088:	6a 7e                	push   $0x7e
  jmp __alltraps
c010408a:	e9 6e fb ff ff       	jmp    c0103bfd <__alltraps>

c010408f <vector127>:
.globl vector127
vector127:
  pushl $0
c010408f:	6a 00                	push   $0x0
  pushl $127
c0104091:	6a 7f                	push   $0x7f
  jmp __alltraps
c0104093:	e9 65 fb ff ff       	jmp    c0103bfd <__alltraps>

c0104098 <vector128>:
.globl vector128
vector128:
  pushl $0
c0104098:	6a 00                	push   $0x0
  pushl $128
c010409a:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c010409f:	e9 59 fb ff ff       	jmp    c0103bfd <__alltraps>

c01040a4 <vector129>:
.globl vector129
vector129:
  pushl $0
c01040a4:	6a 00                	push   $0x0
  pushl $129
c01040a6:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01040ab:	e9 4d fb ff ff       	jmp    c0103bfd <__alltraps>

c01040b0 <vector130>:
.globl vector130
vector130:
  pushl $0
c01040b0:	6a 00                	push   $0x0
  pushl $130
c01040b2:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01040b7:	e9 41 fb ff ff       	jmp    c0103bfd <__alltraps>

c01040bc <vector131>:
.globl vector131
vector131:
  pushl $0
c01040bc:	6a 00                	push   $0x0
  pushl $131
c01040be:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01040c3:	e9 35 fb ff ff       	jmp    c0103bfd <__alltraps>

c01040c8 <vector132>:
.globl vector132
vector132:
  pushl $0
c01040c8:	6a 00                	push   $0x0
  pushl $132
c01040ca:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01040cf:	e9 29 fb ff ff       	jmp    c0103bfd <__alltraps>

c01040d4 <vector133>:
.globl vector133
vector133:
  pushl $0
c01040d4:	6a 00                	push   $0x0
  pushl $133
c01040d6:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01040db:	e9 1d fb ff ff       	jmp    c0103bfd <__alltraps>

c01040e0 <vector134>:
.globl vector134
vector134:
  pushl $0
c01040e0:	6a 00                	push   $0x0
  pushl $134
c01040e2:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01040e7:	e9 11 fb ff ff       	jmp    c0103bfd <__alltraps>

c01040ec <vector135>:
.globl vector135
vector135:
  pushl $0
c01040ec:	6a 00                	push   $0x0
  pushl $135
c01040ee:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01040f3:	e9 05 fb ff ff       	jmp    c0103bfd <__alltraps>

c01040f8 <vector136>:
.globl vector136
vector136:
  pushl $0
c01040f8:	6a 00                	push   $0x0
  pushl $136
c01040fa:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01040ff:	e9 f9 fa ff ff       	jmp    c0103bfd <__alltraps>

c0104104 <vector137>:
.globl vector137
vector137:
  pushl $0
c0104104:	6a 00                	push   $0x0
  pushl $137
c0104106:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c010410b:	e9 ed fa ff ff       	jmp    c0103bfd <__alltraps>

c0104110 <vector138>:
.globl vector138
vector138:
  pushl $0
c0104110:	6a 00                	push   $0x0
  pushl $138
c0104112:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0104117:	e9 e1 fa ff ff       	jmp    c0103bfd <__alltraps>

c010411c <vector139>:
.globl vector139
vector139:
  pushl $0
c010411c:	6a 00                	push   $0x0
  pushl $139
c010411e:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0104123:	e9 d5 fa ff ff       	jmp    c0103bfd <__alltraps>

c0104128 <vector140>:
.globl vector140
vector140:
  pushl $0
c0104128:	6a 00                	push   $0x0
  pushl $140
c010412a:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c010412f:	e9 c9 fa ff ff       	jmp    c0103bfd <__alltraps>

c0104134 <vector141>:
.globl vector141
vector141:
  pushl $0
c0104134:	6a 00                	push   $0x0
  pushl $141
c0104136:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c010413b:	e9 bd fa ff ff       	jmp    c0103bfd <__alltraps>

c0104140 <vector142>:
.globl vector142
vector142:
  pushl $0
c0104140:	6a 00                	push   $0x0
  pushl $142
c0104142:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0104147:	e9 b1 fa ff ff       	jmp    c0103bfd <__alltraps>

c010414c <vector143>:
.globl vector143
vector143:
  pushl $0
c010414c:	6a 00                	push   $0x0
  pushl $143
c010414e:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0104153:	e9 a5 fa ff ff       	jmp    c0103bfd <__alltraps>

c0104158 <vector144>:
.globl vector144
vector144:
  pushl $0
c0104158:	6a 00                	push   $0x0
  pushl $144
c010415a:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c010415f:	e9 99 fa ff ff       	jmp    c0103bfd <__alltraps>

c0104164 <vector145>:
.globl vector145
vector145:
  pushl $0
c0104164:	6a 00                	push   $0x0
  pushl $145
c0104166:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c010416b:	e9 8d fa ff ff       	jmp    c0103bfd <__alltraps>

c0104170 <vector146>:
.globl vector146
vector146:
  pushl $0
c0104170:	6a 00                	push   $0x0
  pushl $146
c0104172:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0104177:	e9 81 fa ff ff       	jmp    c0103bfd <__alltraps>

c010417c <vector147>:
.globl vector147
vector147:
  pushl $0
c010417c:	6a 00                	push   $0x0
  pushl $147
c010417e:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0104183:	e9 75 fa ff ff       	jmp    c0103bfd <__alltraps>

c0104188 <vector148>:
.globl vector148
vector148:
  pushl $0
c0104188:	6a 00                	push   $0x0
  pushl $148
c010418a:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c010418f:	e9 69 fa ff ff       	jmp    c0103bfd <__alltraps>

c0104194 <vector149>:
.globl vector149
vector149:
  pushl $0
c0104194:	6a 00                	push   $0x0
  pushl $149
c0104196:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c010419b:	e9 5d fa ff ff       	jmp    c0103bfd <__alltraps>

c01041a0 <vector150>:
.globl vector150
vector150:
  pushl $0
c01041a0:	6a 00                	push   $0x0
  pushl $150
c01041a2:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01041a7:	e9 51 fa ff ff       	jmp    c0103bfd <__alltraps>

c01041ac <vector151>:
.globl vector151
vector151:
  pushl $0
c01041ac:	6a 00                	push   $0x0
  pushl $151
c01041ae:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01041b3:	e9 45 fa ff ff       	jmp    c0103bfd <__alltraps>

c01041b8 <vector152>:
.globl vector152
vector152:
  pushl $0
c01041b8:	6a 00                	push   $0x0
  pushl $152
c01041ba:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01041bf:	e9 39 fa ff ff       	jmp    c0103bfd <__alltraps>

c01041c4 <vector153>:
.globl vector153
vector153:
  pushl $0
c01041c4:	6a 00                	push   $0x0
  pushl $153
c01041c6:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01041cb:	e9 2d fa ff ff       	jmp    c0103bfd <__alltraps>

c01041d0 <vector154>:
.globl vector154
vector154:
  pushl $0
c01041d0:	6a 00                	push   $0x0
  pushl $154
c01041d2:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01041d7:	e9 21 fa ff ff       	jmp    c0103bfd <__alltraps>

c01041dc <vector155>:
.globl vector155
vector155:
  pushl $0
c01041dc:	6a 00                	push   $0x0
  pushl $155
c01041de:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01041e3:	e9 15 fa ff ff       	jmp    c0103bfd <__alltraps>

c01041e8 <vector156>:
.globl vector156
vector156:
  pushl $0
c01041e8:	6a 00                	push   $0x0
  pushl $156
c01041ea:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01041ef:	e9 09 fa ff ff       	jmp    c0103bfd <__alltraps>

c01041f4 <vector157>:
.globl vector157
vector157:
  pushl $0
c01041f4:	6a 00                	push   $0x0
  pushl $157
c01041f6:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01041fb:	e9 fd f9 ff ff       	jmp    c0103bfd <__alltraps>

c0104200 <vector158>:
.globl vector158
vector158:
  pushl $0
c0104200:	6a 00                	push   $0x0
  pushl $158
c0104202:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0104207:	e9 f1 f9 ff ff       	jmp    c0103bfd <__alltraps>

c010420c <vector159>:
.globl vector159
vector159:
  pushl $0
c010420c:	6a 00                	push   $0x0
  pushl $159
c010420e:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0104213:	e9 e5 f9 ff ff       	jmp    c0103bfd <__alltraps>

c0104218 <vector160>:
.globl vector160
vector160:
  pushl $0
c0104218:	6a 00                	push   $0x0
  pushl $160
c010421a:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010421f:	e9 d9 f9 ff ff       	jmp    c0103bfd <__alltraps>

c0104224 <vector161>:
.globl vector161
vector161:
  pushl $0
c0104224:	6a 00                	push   $0x0
  pushl $161
c0104226:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c010422b:	e9 cd f9 ff ff       	jmp    c0103bfd <__alltraps>

c0104230 <vector162>:
.globl vector162
vector162:
  pushl $0
c0104230:	6a 00                	push   $0x0
  pushl $162
c0104232:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0104237:	e9 c1 f9 ff ff       	jmp    c0103bfd <__alltraps>

c010423c <vector163>:
.globl vector163
vector163:
  pushl $0
c010423c:	6a 00                	push   $0x0
  pushl $163
c010423e:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0104243:	e9 b5 f9 ff ff       	jmp    c0103bfd <__alltraps>

c0104248 <vector164>:
.globl vector164
vector164:
  pushl $0
c0104248:	6a 00                	push   $0x0
  pushl $164
c010424a:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c010424f:	e9 a9 f9 ff ff       	jmp    c0103bfd <__alltraps>

c0104254 <vector165>:
.globl vector165
vector165:
  pushl $0
c0104254:	6a 00                	push   $0x0
  pushl $165
c0104256:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c010425b:	e9 9d f9 ff ff       	jmp    c0103bfd <__alltraps>

c0104260 <vector166>:
.globl vector166
vector166:
  pushl $0
c0104260:	6a 00                	push   $0x0
  pushl $166
c0104262:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0104267:	e9 91 f9 ff ff       	jmp    c0103bfd <__alltraps>

c010426c <vector167>:
.globl vector167
vector167:
  pushl $0
c010426c:	6a 00                	push   $0x0
  pushl $167
c010426e:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0104273:	e9 85 f9 ff ff       	jmp    c0103bfd <__alltraps>

c0104278 <vector168>:
.globl vector168
vector168:
  pushl $0
c0104278:	6a 00                	push   $0x0
  pushl $168
c010427a:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c010427f:	e9 79 f9 ff ff       	jmp    c0103bfd <__alltraps>

c0104284 <vector169>:
.globl vector169
vector169:
  pushl $0
c0104284:	6a 00                	push   $0x0
  pushl $169
c0104286:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c010428b:	e9 6d f9 ff ff       	jmp    c0103bfd <__alltraps>

c0104290 <vector170>:
.globl vector170
vector170:
  pushl $0
c0104290:	6a 00                	push   $0x0
  pushl $170
c0104292:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0104297:	e9 61 f9 ff ff       	jmp    c0103bfd <__alltraps>

c010429c <vector171>:
.globl vector171
vector171:
  pushl $0
c010429c:	6a 00                	push   $0x0
  pushl $171
c010429e:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01042a3:	e9 55 f9 ff ff       	jmp    c0103bfd <__alltraps>

c01042a8 <vector172>:
.globl vector172
vector172:
  pushl $0
c01042a8:	6a 00                	push   $0x0
  pushl $172
c01042aa:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01042af:	e9 49 f9 ff ff       	jmp    c0103bfd <__alltraps>

c01042b4 <vector173>:
.globl vector173
vector173:
  pushl $0
c01042b4:	6a 00                	push   $0x0
  pushl $173
c01042b6:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01042bb:	e9 3d f9 ff ff       	jmp    c0103bfd <__alltraps>

c01042c0 <vector174>:
.globl vector174
vector174:
  pushl $0
c01042c0:	6a 00                	push   $0x0
  pushl $174
c01042c2:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01042c7:	e9 31 f9 ff ff       	jmp    c0103bfd <__alltraps>

c01042cc <vector175>:
.globl vector175
vector175:
  pushl $0
c01042cc:	6a 00                	push   $0x0
  pushl $175
c01042ce:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01042d3:	e9 25 f9 ff ff       	jmp    c0103bfd <__alltraps>

c01042d8 <vector176>:
.globl vector176
vector176:
  pushl $0
c01042d8:	6a 00                	push   $0x0
  pushl $176
c01042da:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01042df:	e9 19 f9 ff ff       	jmp    c0103bfd <__alltraps>

c01042e4 <vector177>:
.globl vector177
vector177:
  pushl $0
c01042e4:	6a 00                	push   $0x0
  pushl $177
c01042e6:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c01042eb:	e9 0d f9 ff ff       	jmp    c0103bfd <__alltraps>

c01042f0 <vector178>:
.globl vector178
vector178:
  pushl $0
c01042f0:	6a 00                	push   $0x0
  pushl $178
c01042f2:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c01042f7:	e9 01 f9 ff ff       	jmp    c0103bfd <__alltraps>

c01042fc <vector179>:
.globl vector179
vector179:
  pushl $0
c01042fc:	6a 00                	push   $0x0
  pushl $179
c01042fe:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0104303:	e9 f5 f8 ff ff       	jmp    c0103bfd <__alltraps>

c0104308 <vector180>:
.globl vector180
vector180:
  pushl $0
c0104308:	6a 00                	push   $0x0
  pushl $180
c010430a:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010430f:	e9 e9 f8 ff ff       	jmp    c0103bfd <__alltraps>

c0104314 <vector181>:
.globl vector181
vector181:
  pushl $0
c0104314:	6a 00                	push   $0x0
  pushl $181
c0104316:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010431b:	e9 dd f8 ff ff       	jmp    c0103bfd <__alltraps>

c0104320 <vector182>:
.globl vector182
vector182:
  pushl $0
c0104320:	6a 00                	push   $0x0
  pushl $182
c0104322:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0104327:	e9 d1 f8 ff ff       	jmp    c0103bfd <__alltraps>

c010432c <vector183>:
.globl vector183
vector183:
  pushl $0
c010432c:	6a 00                	push   $0x0
  pushl $183
c010432e:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0104333:	e9 c5 f8 ff ff       	jmp    c0103bfd <__alltraps>

c0104338 <vector184>:
.globl vector184
vector184:
  pushl $0
c0104338:	6a 00                	push   $0x0
  pushl $184
c010433a:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c010433f:	e9 b9 f8 ff ff       	jmp    c0103bfd <__alltraps>

c0104344 <vector185>:
.globl vector185
vector185:
  pushl $0
c0104344:	6a 00                	push   $0x0
  pushl $185
c0104346:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c010434b:	e9 ad f8 ff ff       	jmp    c0103bfd <__alltraps>

c0104350 <vector186>:
.globl vector186
vector186:
  pushl $0
c0104350:	6a 00                	push   $0x0
  pushl $186
c0104352:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0104357:	e9 a1 f8 ff ff       	jmp    c0103bfd <__alltraps>

c010435c <vector187>:
.globl vector187
vector187:
  pushl $0
c010435c:	6a 00                	push   $0x0
  pushl $187
c010435e:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0104363:	e9 95 f8 ff ff       	jmp    c0103bfd <__alltraps>

c0104368 <vector188>:
.globl vector188
vector188:
  pushl $0
c0104368:	6a 00                	push   $0x0
  pushl $188
c010436a:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c010436f:	e9 89 f8 ff ff       	jmp    c0103bfd <__alltraps>

c0104374 <vector189>:
.globl vector189
vector189:
  pushl $0
c0104374:	6a 00                	push   $0x0
  pushl $189
c0104376:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c010437b:	e9 7d f8 ff ff       	jmp    c0103bfd <__alltraps>

c0104380 <vector190>:
.globl vector190
vector190:
  pushl $0
c0104380:	6a 00                	push   $0x0
  pushl $190
c0104382:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0104387:	e9 71 f8 ff ff       	jmp    c0103bfd <__alltraps>

c010438c <vector191>:
.globl vector191
vector191:
  pushl $0
c010438c:	6a 00                	push   $0x0
  pushl $191
c010438e:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0104393:	e9 65 f8 ff ff       	jmp    c0103bfd <__alltraps>

c0104398 <vector192>:
.globl vector192
vector192:
  pushl $0
c0104398:	6a 00                	push   $0x0
  pushl $192
c010439a:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c010439f:	e9 59 f8 ff ff       	jmp    c0103bfd <__alltraps>

c01043a4 <vector193>:
.globl vector193
vector193:
  pushl $0
c01043a4:	6a 00                	push   $0x0
  pushl $193
c01043a6:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01043ab:	e9 4d f8 ff ff       	jmp    c0103bfd <__alltraps>

c01043b0 <vector194>:
.globl vector194
vector194:
  pushl $0
c01043b0:	6a 00                	push   $0x0
  pushl $194
c01043b2:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01043b7:	e9 41 f8 ff ff       	jmp    c0103bfd <__alltraps>

c01043bc <vector195>:
.globl vector195
vector195:
  pushl $0
c01043bc:	6a 00                	push   $0x0
  pushl $195
c01043be:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01043c3:	e9 35 f8 ff ff       	jmp    c0103bfd <__alltraps>

c01043c8 <vector196>:
.globl vector196
vector196:
  pushl $0
c01043c8:	6a 00                	push   $0x0
  pushl $196
c01043ca:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01043cf:	e9 29 f8 ff ff       	jmp    c0103bfd <__alltraps>

c01043d4 <vector197>:
.globl vector197
vector197:
  pushl $0
c01043d4:	6a 00                	push   $0x0
  pushl $197
c01043d6:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01043db:	e9 1d f8 ff ff       	jmp    c0103bfd <__alltraps>

c01043e0 <vector198>:
.globl vector198
vector198:
  pushl $0
c01043e0:	6a 00                	push   $0x0
  pushl $198
c01043e2:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01043e7:	e9 11 f8 ff ff       	jmp    c0103bfd <__alltraps>

c01043ec <vector199>:
.globl vector199
vector199:
  pushl $0
c01043ec:	6a 00                	push   $0x0
  pushl $199
c01043ee:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01043f3:	e9 05 f8 ff ff       	jmp    c0103bfd <__alltraps>

c01043f8 <vector200>:
.globl vector200
vector200:
  pushl $0
c01043f8:	6a 00                	push   $0x0
  pushl $200
c01043fa:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01043ff:	e9 f9 f7 ff ff       	jmp    c0103bfd <__alltraps>

c0104404 <vector201>:
.globl vector201
vector201:
  pushl $0
c0104404:	6a 00                	push   $0x0
  pushl $201
c0104406:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010440b:	e9 ed f7 ff ff       	jmp    c0103bfd <__alltraps>

c0104410 <vector202>:
.globl vector202
vector202:
  pushl $0
c0104410:	6a 00                	push   $0x0
  pushl $202
c0104412:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0104417:	e9 e1 f7 ff ff       	jmp    c0103bfd <__alltraps>

c010441c <vector203>:
.globl vector203
vector203:
  pushl $0
c010441c:	6a 00                	push   $0x0
  pushl $203
c010441e:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0104423:	e9 d5 f7 ff ff       	jmp    c0103bfd <__alltraps>

c0104428 <vector204>:
.globl vector204
vector204:
  pushl $0
c0104428:	6a 00                	push   $0x0
  pushl $204
c010442a:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010442f:	e9 c9 f7 ff ff       	jmp    c0103bfd <__alltraps>

c0104434 <vector205>:
.globl vector205
vector205:
  pushl $0
c0104434:	6a 00                	push   $0x0
  pushl $205
c0104436:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c010443b:	e9 bd f7 ff ff       	jmp    c0103bfd <__alltraps>

c0104440 <vector206>:
.globl vector206
vector206:
  pushl $0
c0104440:	6a 00                	push   $0x0
  pushl $206
c0104442:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0104447:	e9 b1 f7 ff ff       	jmp    c0103bfd <__alltraps>

c010444c <vector207>:
.globl vector207
vector207:
  pushl $0
c010444c:	6a 00                	push   $0x0
  pushl $207
c010444e:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0104453:	e9 a5 f7 ff ff       	jmp    c0103bfd <__alltraps>

c0104458 <vector208>:
.globl vector208
vector208:
  pushl $0
c0104458:	6a 00                	push   $0x0
  pushl $208
c010445a:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c010445f:	e9 99 f7 ff ff       	jmp    c0103bfd <__alltraps>

c0104464 <vector209>:
.globl vector209
vector209:
  pushl $0
c0104464:	6a 00                	push   $0x0
  pushl $209
c0104466:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c010446b:	e9 8d f7 ff ff       	jmp    c0103bfd <__alltraps>

c0104470 <vector210>:
.globl vector210
vector210:
  pushl $0
c0104470:	6a 00                	push   $0x0
  pushl $210
c0104472:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0104477:	e9 81 f7 ff ff       	jmp    c0103bfd <__alltraps>

c010447c <vector211>:
.globl vector211
vector211:
  pushl $0
c010447c:	6a 00                	push   $0x0
  pushl $211
c010447e:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0104483:	e9 75 f7 ff ff       	jmp    c0103bfd <__alltraps>

c0104488 <vector212>:
.globl vector212
vector212:
  pushl $0
c0104488:	6a 00                	push   $0x0
  pushl $212
c010448a:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c010448f:	e9 69 f7 ff ff       	jmp    c0103bfd <__alltraps>

c0104494 <vector213>:
.globl vector213
vector213:
  pushl $0
c0104494:	6a 00                	push   $0x0
  pushl $213
c0104496:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c010449b:	e9 5d f7 ff ff       	jmp    c0103bfd <__alltraps>

c01044a0 <vector214>:
.globl vector214
vector214:
  pushl $0
c01044a0:	6a 00                	push   $0x0
  pushl $214
c01044a2:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01044a7:	e9 51 f7 ff ff       	jmp    c0103bfd <__alltraps>

c01044ac <vector215>:
.globl vector215
vector215:
  pushl $0
c01044ac:	6a 00                	push   $0x0
  pushl $215
c01044ae:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01044b3:	e9 45 f7 ff ff       	jmp    c0103bfd <__alltraps>

c01044b8 <vector216>:
.globl vector216
vector216:
  pushl $0
c01044b8:	6a 00                	push   $0x0
  pushl $216
c01044ba:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01044bf:	e9 39 f7 ff ff       	jmp    c0103bfd <__alltraps>

c01044c4 <vector217>:
.globl vector217
vector217:
  pushl $0
c01044c4:	6a 00                	push   $0x0
  pushl $217
c01044c6:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01044cb:	e9 2d f7 ff ff       	jmp    c0103bfd <__alltraps>

c01044d0 <vector218>:
.globl vector218
vector218:
  pushl $0
c01044d0:	6a 00                	push   $0x0
  pushl $218
c01044d2:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01044d7:	e9 21 f7 ff ff       	jmp    c0103bfd <__alltraps>

c01044dc <vector219>:
.globl vector219
vector219:
  pushl $0
c01044dc:	6a 00                	push   $0x0
  pushl $219
c01044de:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01044e3:	e9 15 f7 ff ff       	jmp    c0103bfd <__alltraps>

c01044e8 <vector220>:
.globl vector220
vector220:
  pushl $0
c01044e8:	6a 00                	push   $0x0
  pushl $220
c01044ea:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01044ef:	e9 09 f7 ff ff       	jmp    c0103bfd <__alltraps>

c01044f4 <vector221>:
.globl vector221
vector221:
  pushl $0
c01044f4:	6a 00                	push   $0x0
  pushl $221
c01044f6:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01044fb:	e9 fd f6 ff ff       	jmp    c0103bfd <__alltraps>

c0104500 <vector222>:
.globl vector222
vector222:
  pushl $0
c0104500:	6a 00                	push   $0x0
  pushl $222
c0104502:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0104507:	e9 f1 f6 ff ff       	jmp    c0103bfd <__alltraps>

c010450c <vector223>:
.globl vector223
vector223:
  pushl $0
c010450c:	6a 00                	push   $0x0
  pushl $223
c010450e:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0104513:	e9 e5 f6 ff ff       	jmp    c0103bfd <__alltraps>

c0104518 <vector224>:
.globl vector224
vector224:
  pushl $0
c0104518:	6a 00                	push   $0x0
  pushl $224
c010451a:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010451f:	e9 d9 f6 ff ff       	jmp    c0103bfd <__alltraps>

c0104524 <vector225>:
.globl vector225
vector225:
  pushl $0
c0104524:	6a 00                	push   $0x0
  pushl $225
c0104526:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010452b:	e9 cd f6 ff ff       	jmp    c0103bfd <__alltraps>

c0104530 <vector226>:
.globl vector226
vector226:
  pushl $0
c0104530:	6a 00                	push   $0x0
  pushl $226
c0104532:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0104537:	e9 c1 f6 ff ff       	jmp    c0103bfd <__alltraps>

c010453c <vector227>:
.globl vector227
vector227:
  pushl $0
c010453c:	6a 00                	push   $0x0
  pushl $227
c010453e:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0104543:	e9 b5 f6 ff ff       	jmp    c0103bfd <__alltraps>

c0104548 <vector228>:
.globl vector228
vector228:
  pushl $0
c0104548:	6a 00                	push   $0x0
  pushl $228
c010454a:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010454f:	e9 a9 f6 ff ff       	jmp    c0103bfd <__alltraps>

c0104554 <vector229>:
.globl vector229
vector229:
  pushl $0
c0104554:	6a 00                	push   $0x0
  pushl $229
c0104556:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c010455b:	e9 9d f6 ff ff       	jmp    c0103bfd <__alltraps>

c0104560 <vector230>:
.globl vector230
vector230:
  pushl $0
c0104560:	6a 00                	push   $0x0
  pushl $230
c0104562:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0104567:	e9 91 f6 ff ff       	jmp    c0103bfd <__alltraps>

c010456c <vector231>:
.globl vector231
vector231:
  pushl $0
c010456c:	6a 00                	push   $0x0
  pushl $231
c010456e:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0104573:	e9 85 f6 ff ff       	jmp    c0103bfd <__alltraps>

c0104578 <vector232>:
.globl vector232
vector232:
  pushl $0
c0104578:	6a 00                	push   $0x0
  pushl $232
c010457a:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c010457f:	e9 79 f6 ff ff       	jmp    c0103bfd <__alltraps>

c0104584 <vector233>:
.globl vector233
vector233:
  pushl $0
c0104584:	6a 00                	push   $0x0
  pushl $233
c0104586:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c010458b:	e9 6d f6 ff ff       	jmp    c0103bfd <__alltraps>

c0104590 <vector234>:
.globl vector234
vector234:
  pushl $0
c0104590:	6a 00                	push   $0x0
  pushl $234
c0104592:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0104597:	e9 61 f6 ff ff       	jmp    c0103bfd <__alltraps>

c010459c <vector235>:
.globl vector235
vector235:
  pushl $0
c010459c:	6a 00                	push   $0x0
  pushl $235
c010459e:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01045a3:	e9 55 f6 ff ff       	jmp    c0103bfd <__alltraps>

c01045a8 <vector236>:
.globl vector236
vector236:
  pushl $0
c01045a8:	6a 00                	push   $0x0
  pushl $236
c01045aa:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01045af:	e9 49 f6 ff ff       	jmp    c0103bfd <__alltraps>

c01045b4 <vector237>:
.globl vector237
vector237:
  pushl $0
c01045b4:	6a 00                	push   $0x0
  pushl $237
c01045b6:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01045bb:	e9 3d f6 ff ff       	jmp    c0103bfd <__alltraps>

c01045c0 <vector238>:
.globl vector238
vector238:
  pushl $0
c01045c0:	6a 00                	push   $0x0
  pushl $238
c01045c2:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01045c7:	e9 31 f6 ff ff       	jmp    c0103bfd <__alltraps>

c01045cc <vector239>:
.globl vector239
vector239:
  pushl $0
c01045cc:	6a 00                	push   $0x0
  pushl $239
c01045ce:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01045d3:	e9 25 f6 ff ff       	jmp    c0103bfd <__alltraps>

c01045d8 <vector240>:
.globl vector240
vector240:
  pushl $0
c01045d8:	6a 00                	push   $0x0
  pushl $240
c01045da:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01045df:	e9 19 f6 ff ff       	jmp    c0103bfd <__alltraps>

c01045e4 <vector241>:
.globl vector241
vector241:
  pushl $0
c01045e4:	6a 00                	push   $0x0
  pushl $241
c01045e6:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01045eb:	e9 0d f6 ff ff       	jmp    c0103bfd <__alltraps>

c01045f0 <vector242>:
.globl vector242
vector242:
  pushl $0
c01045f0:	6a 00                	push   $0x0
  pushl $242
c01045f2:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01045f7:	e9 01 f6 ff ff       	jmp    c0103bfd <__alltraps>

c01045fc <vector243>:
.globl vector243
vector243:
  pushl $0
c01045fc:	6a 00                	push   $0x0
  pushl $243
c01045fe:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0104603:	e9 f5 f5 ff ff       	jmp    c0103bfd <__alltraps>

c0104608 <vector244>:
.globl vector244
vector244:
  pushl $0
c0104608:	6a 00                	push   $0x0
  pushl $244
c010460a:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010460f:	e9 e9 f5 ff ff       	jmp    c0103bfd <__alltraps>

c0104614 <vector245>:
.globl vector245
vector245:
  pushl $0
c0104614:	6a 00                	push   $0x0
  pushl $245
c0104616:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c010461b:	e9 dd f5 ff ff       	jmp    c0103bfd <__alltraps>

c0104620 <vector246>:
.globl vector246
vector246:
  pushl $0
c0104620:	6a 00                	push   $0x0
  pushl $246
c0104622:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0104627:	e9 d1 f5 ff ff       	jmp    c0103bfd <__alltraps>

c010462c <vector247>:
.globl vector247
vector247:
  pushl $0
c010462c:	6a 00                	push   $0x0
  pushl $247
c010462e:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0104633:	e9 c5 f5 ff ff       	jmp    c0103bfd <__alltraps>

c0104638 <vector248>:
.globl vector248
vector248:
  pushl $0
c0104638:	6a 00                	push   $0x0
  pushl $248
c010463a:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010463f:	e9 b9 f5 ff ff       	jmp    c0103bfd <__alltraps>

c0104644 <vector249>:
.globl vector249
vector249:
  pushl $0
c0104644:	6a 00                	push   $0x0
  pushl $249
c0104646:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c010464b:	e9 ad f5 ff ff       	jmp    c0103bfd <__alltraps>

c0104650 <vector250>:
.globl vector250
vector250:
  pushl $0
c0104650:	6a 00                	push   $0x0
  pushl $250
c0104652:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0104657:	e9 a1 f5 ff ff       	jmp    c0103bfd <__alltraps>

c010465c <vector251>:
.globl vector251
vector251:
  pushl $0
c010465c:	6a 00                	push   $0x0
  pushl $251
c010465e:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0104663:	e9 95 f5 ff ff       	jmp    c0103bfd <__alltraps>

c0104668 <vector252>:
.globl vector252
vector252:
  pushl $0
c0104668:	6a 00                	push   $0x0
  pushl $252
c010466a:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c010466f:	e9 89 f5 ff ff       	jmp    c0103bfd <__alltraps>

c0104674 <vector253>:
.globl vector253
vector253:
  pushl $0
c0104674:	6a 00                	push   $0x0
  pushl $253
c0104676:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c010467b:	e9 7d f5 ff ff       	jmp    c0103bfd <__alltraps>

c0104680 <vector254>:
.globl vector254
vector254:
  pushl $0
c0104680:	6a 00                	push   $0x0
  pushl $254
c0104682:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0104687:	e9 71 f5 ff ff       	jmp    c0103bfd <__alltraps>

c010468c <vector255>:
.globl vector255
vector255:
  pushl $0
c010468c:	6a 00                	push   $0x0
  pushl $255
c010468e:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0104693:	e9 65 f5 ff ff       	jmp    c0103bfd <__alltraps>

c0104698 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104698:	55                   	push   %ebp
c0104699:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010469b:	8b 55 08             	mov    0x8(%ebp),%edx
c010469e:	a1 8c e0 12 c0       	mov    0xc012e08c,%eax
c01046a3:	29 c2                	sub    %eax,%edx
c01046a5:	89 d0                	mov    %edx,%eax
c01046a7:	c1 f8 02             	sar    $0x2,%eax
c01046aa:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c01046b0:	5d                   	pop    %ebp
c01046b1:	c3                   	ret    

c01046b2 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01046b2:	55                   	push   %ebp
c01046b3:	89 e5                	mov    %esp,%ebp
c01046b5:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01046b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01046bb:	89 04 24             	mov    %eax,(%esp)
c01046be:	e8 d5 ff ff ff       	call   c0104698 <page2ppn>
c01046c3:	c1 e0 0c             	shl    $0xc,%eax
}
c01046c6:	c9                   	leave  
c01046c7:	c3                   	ret    

c01046c8 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c01046c8:	55                   	push   %ebp
c01046c9:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01046cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01046ce:	8b 00                	mov    (%eax),%eax
}
c01046d0:	5d                   	pop    %ebp
c01046d1:	c3                   	ret    

c01046d2 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c01046d2:	55                   	push   %ebp
c01046d3:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01046d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01046d8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01046db:	89 10                	mov    %edx,(%eax)
}
c01046dd:	5d                   	pop    %ebp
c01046de:	c3                   	ret    

c01046df <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01046df:	55                   	push   %ebp
c01046e0:	89 e5                	mov    %esp,%ebp
c01046e2:	83 ec 10             	sub    $0x10,%esp
c01046e5:	c7 45 fc 78 e0 12 c0 	movl   $0xc012e078,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01046ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01046ef:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01046f2:	89 50 04             	mov    %edx,0x4(%eax)
c01046f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01046f8:	8b 50 04             	mov    0x4(%eax),%edx
c01046fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01046fe:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0104700:	c7 05 80 e0 12 c0 00 	movl   $0x0,0xc012e080
c0104707:	00 00 00 
}
c010470a:	c9                   	leave  
c010470b:	c3                   	ret    

c010470c <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c010470c:	55                   	push   %ebp
c010470d:	89 e5                	mov    %esp,%ebp
c010470f:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0104712:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104716:	75 24                	jne    c010473c <default_init_memmap+0x30>
c0104718:	c7 44 24 0c d0 be 10 	movl   $0xc010bed0,0xc(%esp)
c010471f:	c0 
c0104720:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0104727:	c0 
c0104728:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010472f:	00 
c0104730:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0104737:	e8 30 da ff ff       	call   c010216c <__panic>
    struct Page *p = base;
c010473c:	8b 45 08             	mov    0x8(%ebp),%eax
c010473f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104742:	eb 7d                	jmp    c01047c1 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0104744:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104747:	83 c0 04             	add    $0x4,%eax
c010474a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0104751:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104754:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104757:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010475a:	0f a3 10             	bt     %edx,(%eax)
c010475d:	19 c0                	sbb    %eax,%eax
c010475f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0104762:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104766:	0f 95 c0             	setne  %al
c0104769:	0f b6 c0             	movzbl %al,%eax
c010476c:	85 c0                	test   %eax,%eax
c010476e:	75 24                	jne    c0104794 <default_init_memmap+0x88>
c0104770:	c7 44 24 0c 01 bf 10 	movl   $0xc010bf01,0xc(%esp)
c0104777:	c0 
c0104778:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c010477f:	c0 
c0104780:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0104787:	00 
c0104788:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c010478f:	e8 d8 d9 ff ff       	call   c010216c <__panic>
        p->flags = p->property = 0;
c0104794:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104797:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010479e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047a1:	8b 50 08             	mov    0x8(%eax),%edx
c01047a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047a7:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c01047aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01047b1:	00 
c01047b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047b5:	89 04 24             	mov    %eax,(%esp)
c01047b8:	e8 15 ff ff ff       	call   c01046d2 <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01047bd:	83 45 f4 24          	addl   $0x24,-0xc(%ebp)
c01047c1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01047c4:	89 d0                	mov    %edx,%eax
c01047c6:	c1 e0 03             	shl    $0x3,%eax
c01047c9:	01 d0                	add    %edx,%eax
c01047cb:	c1 e0 02             	shl    $0x2,%eax
c01047ce:	89 c2                	mov    %eax,%edx
c01047d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01047d3:	01 d0                	add    %edx,%eax
c01047d5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01047d8:	0f 85 66 ff ff ff    	jne    c0104744 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c01047de:	8b 45 08             	mov    0x8(%ebp),%eax
c01047e1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01047e4:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c01047e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01047ea:	83 c0 04             	add    $0x4,%eax
c01047ed:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01047f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01047f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01047fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01047fd:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0104800:	8b 15 80 e0 12 c0    	mov    0xc012e080,%edx
c0104806:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104809:	01 d0                	add    %edx,%eax
c010480b:	a3 80 e0 12 c0       	mov    %eax,0xc012e080
    list_add_before(&free_list, &(base->page_link));
c0104810:	8b 45 08             	mov    0x8(%ebp),%eax
c0104813:	83 c0 10             	add    $0x10,%eax
c0104816:	c7 45 dc 78 e0 12 c0 	movl   $0xc012e078,-0x24(%ebp)
c010481d:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0104820:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104823:	8b 00                	mov    (%eax),%eax
c0104825:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104828:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010482b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010482e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104831:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104834:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104837:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010483a:	89 10                	mov    %edx,(%eax)
c010483c:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010483f:	8b 10                	mov    (%eax),%edx
c0104841:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104844:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104847:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010484a:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010484d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104850:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104853:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104856:	89 10                	mov    %edx,(%eax)
}
c0104858:	c9                   	leave  
c0104859:	c3                   	ret    

c010485a <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c010485a:	55                   	push   %ebp
c010485b:	89 e5                	mov    %esp,%ebp
c010485d:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0104860:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104864:	75 24                	jne    c010488a <default_alloc_pages+0x30>
c0104866:	c7 44 24 0c d0 be 10 	movl   $0xc010bed0,0xc(%esp)
c010486d:	c0 
c010486e:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0104875:	c0 
c0104876:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c010487d:	00 
c010487e:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0104885:	e8 e2 d8 ff ff       	call   c010216c <__panic>
    if (n > nr_free) {
c010488a:	a1 80 e0 12 c0       	mov    0xc012e080,%eax
c010488f:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104892:	73 0a                	jae    c010489e <default_alloc_pages+0x44>
        return NULL;
c0104894:	b8 00 00 00 00       	mov    $0x0,%eax
c0104899:	e9 3d 01 00 00       	jmp    c01049db <default_alloc_pages+0x181>
    }
    struct Page *page = NULL;
c010489e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c01048a5:	c7 45 f0 78 e0 12 c0 	movl   $0xc012e078,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c01048ac:	eb 1c                	jmp    c01048ca <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c01048ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048b1:	83 e8 10             	sub    $0x10,%eax
c01048b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c01048b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048ba:	8b 40 08             	mov    0x8(%eax),%eax
c01048bd:	3b 45 08             	cmp    0x8(%ebp),%eax
c01048c0:	72 08                	jb     c01048ca <default_alloc_pages+0x70>
            page = p;
c01048c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01048c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c01048c8:	eb 18                	jmp    c01048e2 <default_alloc_pages+0x88>
c01048ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01048cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01048d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01048d3:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c01048d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01048d9:	81 7d f0 78 e0 12 c0 	cmpl   $0xc012e078,-0x10(%ebp)
c01048e0:	75 cc                	jne    c01048ae <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c01048e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01048e6:	0f 84 ec 00 00 00    	je     c01049d8 <default_alloc_pages+0x17e>
        if (page->property > n) {
c01048ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048ef:	8b 40 08             	mov    0x8(%eax),%eax
c01048f2:	3b 45 08             	cmp    0x8(%ebp),%eax
c01048f5:	0f 86 8c 00 00 00    	jbe    c0104987 <default_alloc_pages+0x12d>
            struct Page *p = page + n;
c01048fb:	8b 55 08             	mov    0x8(%ebp),%edx
c01048fe:	89 d0                	mov    %edx,%eax
c0104900:	c1 e0 03             	shl    $0x3,%eax
c0104903:	01 d0                	add    %edx,%eax
c0104905:	c1 e0 02             	shl    $0x2,%eax
c0104908:	89 c2                	mov    %eax,%edx
c010490a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010490d:	01 d0                	add    %edx,%eax
c010490f:	89 45 e8             	mov    %eax,-0x18(%ebp)
            p->property = page->property - n;
c0104912:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104915:	8b 40 08             	mov    0x8(%eax),%eax
c0104918:	2b 45 08             	sub    0x8(%ebp),%eax
c010491b:	89 c2                	mov    %eax,%edx
c010491d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104920:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0104923:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104926:	83 c0 04             	add    $0x4,%eax
c0104929:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0104930:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0104933:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104936:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104939:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c010493c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010493f:	83 c0 10             	add    $0x10,%eax
c0104942:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104945:	83 c2 10             	add    $0x10,%edx
c0104948:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010494b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010494e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104951:	8b 40 04             	mov    0x4(%eax),%eax
c0104954:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104957:	89 55 d0             	mov    %edx,-0x30(%ebp)
c010495a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010495d:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0104960:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104963:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104966:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104969:	89 10                	mov    %edx,(%eax)
c010496b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010496e:	8b 10                	mov    (%eax),%edx
c0104970:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104973:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104976:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104979:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010497c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010497f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104982:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104985:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c0104987:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010498a:	83 c0 10             	add    $0x10,%eax
c010498d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0104990:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104993:	8b 40 04             	mov    0x4(%eax),%eax
c0104996:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104999:	8b 12                	mov    (%edx),%edx
c010499b:	89 55 c0             	mov    %edx,-0x40(%ebp)
c010499e:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01049a1:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01049a4:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01049a7:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01049aa:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01049ad:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01049b0:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c01049b2:	a1 80 e0 12 c0       	mov    0xc012e080,%eax
c01049b7:	2b 45 08             	sub    0x8(%ebp),%eax
c01049ba:	a3 80 e0 12 c0       	mov    %eax,0xc012e080
        ClearPageProperty(page);
c01049bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049c2:	83 c0 04             	add    $0x4,%eax
c01049c5:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c01049cc:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01049cf:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01049d2:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01049d5:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c01049d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01049db:	c9                   	leave  
c01049dc:	c3                   	ret    

c01049dd <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c01049dd:	55                   	push   %ebp
c01049de:	89 e5                	mov    %esp,%ebp
c01049e0:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c01049e6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01049ea:	75 24                	jne    c0104a10 <default_free_pages+0x33>
c01049ec:	c7 44 24 0c d0 be 10 	movl   $0xc010bed0,0xc(%esp)
c01049f3:	c0 
c01049f4:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c01049fb:	c0 
c01049fc:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0104a03:	00 
c0104a04:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0104a0b:	e8 5c d7 ff ff       	call   c010216c <__panic>
    struct Page *p = base;
c0104a10:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a13:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104a16:	e9 9d 00 00 00       	jmp    c0104ab8 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0104a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a1e:	83 c0 04             	add    $0x4,%eax
c0104a21:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0104a28:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104a2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104a2e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104a31:	0f a3 10             	bt     %edx,(%eax)
c0104a34:	19 c0                	sbb    %eax,%eax
c0104a36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0104a39:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104a3d:	0f 95 c0             	setne  %al
c0104a40:	0f b6 c0             	movzbl %al,%eax
c0104a43:	85 c0                	test   %eax,%eax
c0104a45:	75 2c                	jne    c0104a73 <default_free_pages+0x96>
c0104a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a4a:	83 c0 04             	add    $0x4,%eax
c0104a4d:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0104a54:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104a57:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104a5a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104a5d:	0f a3 10             	bt     %edx,(%eax)
c0104a60:	19 c0                	sbb    %eax,%eax
c0104a62:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0104a65:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0104a69:	0f 95 c0             	setne  %al
c0104a6c:	0f b6 c0             	movzbl %al,%eax
c0104a6f:	85 c0                	test   %eax,%eax
c0104a71:	74 24                	je     c0104a97 <default_free_pages+0xba>
c0104a73:	c7 44 24 0c 14 bf 10 	movl   $0xc010bf14,0xc(%esp)
c0104a7a:	c0 
c0104a7b:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0104a82:	c0 
c0104a83:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
c0104a8a:	00 
c0104a8b:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0104a92:	e8 d5 d6 ff ff       	call   c010216c <__panic>
        p->flags = 0;
c0104a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a9a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0104aa1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104aa8:	00 
c0104aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104aac:	89 04 24             	mov    %eax,(%esp)
c0104aaf:	e8 1e fc ff ff       	call   c01046d2 <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0104ab4:	83 45 f4 24          	addl   $0x24,-0xc(%ebp)
c0104ab8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104abb:	89 d0                	mov    %edx,%eax
c0104abd:	c1 e0 03             	shl    $0x3,%eax
c0104ac0:	01 d0                	add    %edx,%eax
c0104ac2:	c1 e0 02             	shl    $0x2,%eax
c0104ac5:	89 c2                	mov    %eax,%edx
c0104ac7:	8b 45 08             	mov    0x8(%ebp),%eax
c0104aca:	01 d0                	add    %edx,%eax
c0104acc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104acf:	0f 85 46 ff ff ff    	jne    c0104a1b <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0104ad5:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104adb:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104ade:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ae1:	83 c0 04             	add    $0x4,%eax
c0104ae4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0104aeb:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104aee:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104af1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104af4:	0f ab 10             	bts    %edx,(%eax)
c0104af7:	c7 45 cc 78 e0 12 c0 	movl   $0xc012e078,-0x34(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104afe:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104b01:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0104b04:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0104b07:	e9 08 01 00 00       	jmp    c0104c14 <default_free_pages+0x237>
        p = le2page(le, page_link);
c0104b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b0f:	83 e8 10             	sub    $0x10,%eax
c0104b12:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b18:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104b1b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104b1e:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0104b21:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c0104b24:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b27:	8b 50 08             	mov    0x8(%eax),%edx
c0104b2a:	89 d0                	mov    %edx,%eax
c0104b2c:	c1 e0 03             	shl    $0x3,%eax
c0104b2f:	01 d0                	add    %edx,%eax
c0104b31:	c1 e0 02             	shl    $0x2,%eax
c0104b34:	89 c2                	mov    %eax,%edx
c0104b36:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b39:	01 d0                	add    %edx,%eax
c0104b3b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104b3e:	75 5a                	jne    c0104b9a <default_free_pages+0x1bd>
            base->property += p->property;
c0104b40:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b43:	8b 50 08             	mov    0x8(%eax),%edx
c0104b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b49:	8b 40 08             	mov    0x8(%eax),%eax
c0104b4c:	01 c2                	add    %eax,%edx
c0104b4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b51:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0104b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b57:	83 c0 04             	add    $0x4,%eax
c0104b5a:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0104b61:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104b64:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104b67:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104b6a:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0104b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b70:	83 c0 10             	add    $0x10,%eax
c0104b73:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0104b76:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104b79:	8b 40 04             	mov    0x4(%eax),%eax
c0104b7c:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0104b7f:	8b 12                	mov    (%edx),%edx
c0104b81:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0104b84:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104b87:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104b8a:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104b8d:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104b90:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104b93:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0104b96:	89 10                	mov    %edx,(%eax)
c0104b98:	eb 7a                	jmp    c0104c14 <default_free_pages+0x237>
        }
        else if (p + p->property == base) {
c0104b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b9d:	8b 50 08             	mov    0x8(%eax),%edx
c0104ba0:	89 d0                	mov    %edx,%eax
c0104ba2:	c1 e0 03             	shl    $0x3,%eax
c0104ba5:	01 d0                	add    %edx,%eax
c0104ba7:	c1 e0 02             	shl    $0x2,%eax
c0104baa:	89 c2                	mov    %eax,%edx
c0104bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104baf:	01 d0                	add    %edx,%eax
c0104bb1:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104bb4:	75 5e                	jne    c0104c14 <default_free_pages+0x237>
            p->property += base->property;
c0104bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bb9:	8b 50 08             	mov    0x8(%eax),%edx
c0104bbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bbf:	8b 40 08             	mov    0x8(%eax),%eax
c0104bc2:	01 c2                	add    %eax,%edx
c0104bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bc7:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0104bca:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bcd:	83 c0 04             	add    $0x4,%eax
c0104bd0:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0104bd7:	89 45 ac             	mov    %eax,-0x54(%ebp)
c0104bda:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104bdd:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104be0:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0104be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104be6:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0104be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bec:	83 c0 10             	add    $0x10,%eax
c0104bef:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0104bf2:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104bf5:	8b 40 04             	mov    0x4(%eax),%eax
c0104bf8:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0104bfb:	8b 12                	mov    (%edx),%edx
c0104bfd:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0104c00:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104c03:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104c06:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0104c09:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104c0c:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104c0f:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104c12:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0104c14:	81 7d f0 78 e0 12 c0 	cmpl   $0xc012e078,-0x10(%ebp)
c0104c1b:	0f 85 eb fe ff ff    	jne    c0104b0c <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c0104c21:	8b 15 80 e0 12 c0    	mov    0xc012e080,%edx
c0104c27:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104c2a:	01 d0                	add    %edx,%eax
c0104c2c:	a3 80 e0 12 c0       	mov    %eax,0xc012e080
c0104c31:	c7 45 9c 78 e0 12 c0 	movl   $0xc012e078,-0x64(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104c38:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104c3b:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0104c3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0104c41:	eb 76                	jmp    c0104cb9 <default_free_pages+0x2dc>
        p = le2page(le, page_link);
c0104c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c46:	83 e8 10             	sub    $0x10,%eax
c0104c49:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0104c4c:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c4f:	8b 50 08             	mov    0x8(%eax),%edx
c0104c52:	89 d0                	mov    %edx,%eax
c0104c54:	c1 e0 03             	shl    $0x3,%eax
c0104c57:	01 d0                	add    %edx,%eax
c0104c59:	c1 e0 02             	shl    $0x2,%eax
c0104c5c:	89 c2                	mov    %eax,%edx
c0104c5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c61:	01 d0                	add    %edx,%eax
c0104c63:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104c66:	77 42                	ja     c0104caa <default_free_pages+0x2cd>
            assert(base + base->property != p);
c0104c68:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c6b:	8b 50 08             	mov    0x8(%eax),%edx
c0104c6e:	89 d0                	mov    %edx,%eax
c0104c70:	c1 e0 03             	shl    $0x3,%eax
c0104c73:	01 d0                	add    %edx,%eax
c0104c75:	c1 e0 02             	shl    $0x2,%eax
c0104c78:	89 c2                	mov    %eax,%edx
c0104c7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c7d:	01 d0                	add    %edx,%eax
c0104c7f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104c82:	75 24                	jne    c0104ca8 <default_free_pages+0x2cb>
c0104c84:	c7 44 24 0c 39 bf 10 	movl   $0xc010bf39,0xc(%esp)
c0104c8b:	c0 
c0104c8c:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0104c93:	c0 
c0104c94:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0104c9b:	00 
c0104c9c:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0104ca3:	e8 c4 d4 ff ff       	call   c010216c <__panic>
            break;
c0104ca8:	eb 18                	jmp    c0104cc2 <default_free_pages+0x2e5>
c0104caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cad:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104cb0:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104cb3:	8b 40 04             	mov    0x4(%eax),%eax
        }
        le = list_next(le);
c0104cb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c0104cb9:	81 7d f0 78 e0 12 c0 	cmpl   $0xc012e078,-0x10(%ebp)
c0104cc0:	75 81                	jne    c0104c43 <default_free_pages+0x266>
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c0104cc2:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cc5:	8d 50 10             	lea    0x10(%eax),%edx
c0104cc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ccb:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104cce:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0104cd1:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104cd4:	8b 00                	mov    (%eax),%eax
c0104cd6:	8b 55 90             	mov    -0x70(%ebp),%edx
c0104cd9:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0104cdc:	89 45 88             	mov    %eax,-0x78(%ebp)
c0104cdf:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104ce2:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104ce5:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104ce8:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0104ceb:	89 10                	mov    %edx,(%eax)
c0104ced:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104cf0:	8b 10                	mov    (%eax),%edx
c0104cf2:	8b 45 88             	mov    -0x78(%ebp),%eax
c0104cf5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104cf8:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104cfb:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104cfe:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104d01:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104d04:	8b 55 88             	mov    -0x78(%ebp),%edx
c0104d07:	89 10                	mov    %edx,(%eax)
}
c0104d09:	c9                   	leave  
c0104d0a:	c3                   	ret    

c0104d0b <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0104d0b:	55                   	push   %ebp
c0104d0c:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104d0e:	a1 80 e0 12 c0       	mov    0xc012e080,%eax
}
c0104d13:	5d                   	pop    %ebp
c0104d14:	c3                   	ret    

c0104d15 <basic_check>:

static void
basic_check(void) {
c0104d15:	55                   	push   %ebp
c0104d16:	89 e5                	mov    %esp,%ebp
c0104d18:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0104d1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d25:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104d2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104d35:	e8 15 16 00 00       	call   c010634f <alloc_pages>
c0104d3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104d3d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104d41:	75 24                	jne    c0104d67 <basic_check+0x52>
c0104d43:	c7 44 24 0c 54 bf 10 	movl   $0xc010bf54,0xc(%esp)
c0104d4a:	c0 
c0104d4b:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0104d52:	c0 
c0104d53:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0104d5a:	00 
c0104d5b:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0104d62:	e8 05 d4 ff ff       	call   c010216c <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104d67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104d6e:	e8 dc 15 00 00       	call   c010634f <alloc_pages>
c0104d73:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d76:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104d7a:	75 24                	jne    c0104da0 <basic_check+0x8b>
c0104d7c:	c7 44 24 0c 70 bf 10 	movl   $0xc010bf70,0xc(%esp)
c0104d83:	c0 
c0104d84:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0104d8b:	c0 
c0104d8c:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0104d93:	00 
c0104d94:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0104d9b:	e8 cc d3 ff ff       	call   c010216c <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104da0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104da7:	e8 a3 15 00 00       	call   c010634f <alloc_pages>
c0104dac:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104daf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104db3:	75 24                	jne    c0104dd9 <basic_check+0xc4>
c0104db5:	c7 44 24 0c 8c bf 10 	movl   $0xc010bf8c,0xc(%esp)
c0104dbc:	c0 
c0104dbd:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0104dc4:	c0 
c0104dc5:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0104dcc:	00 
c0104dcd:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0104dd4:	e8 93 d3 ff ff       	call   c010216c <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104dd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ddc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104ddf:	74 10                	je     c0104df1 <basic_check+0xdc>
c0104de1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104de4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104de7:	74 08                	je     c0104df1 <basic_check+0xdc>
c0104de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104def:	75 24                	jne    c0104e15 <basic_check+0x100>
c0104df1:	c7 44 24 0c a8 bf 10 	movl   $0xc010bfa8,0xc(%esp)
c0104df8:	c0 
c0104df9:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0104e00:	c0 
c0104e01:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0104e08:	00 
c0104e09:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0104e10:	e8 57 d3 ff ff       	call   c010216c <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0104e15:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e18:	89 04 24             	mov    %eax,(%esp)
c0104e1b:	e8 a8 f8 ff ff       	call   c01046c8 <page_ref>
c0104e20:	85 c0                	test   %eax,%eax
c0104e22:	75 1e                	jne    c0104e42 <basic_check+0x12d>
c0104e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e27:	89 04 24             	mov    %eax,(%esp)
c0104e2a:	e8 99 f8 ff ff       	call   c01046c8 <page_ref>
c0104e2f:	85 c0                	test   %eax,%eax
c0104e31:	75 0f                	jne    c0104e42 <basic_check+0x12d>
c0104e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e36:	89 04 24             	mov    %eax,(%esp)
c0104e39:	e8 8a f8 ff ff       	call   c01046c8 <page_ref>
c0104e3e:	85 c0                	test   %eax,%eax
c0104e40:	74 24                	je     c0104e66 <basic_check+0x151>
c0104e42:	c7 44 24 0c cc bf 10 	movl   $0xc010bfcc,0xc(%esp)
c0104e49:	c0 
c0104e4a:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0104e51:	c0 
c0104e52:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0104e59:	00 
c0104e5a:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0104e61:	e8 06 d3 ff ff       	call   c010216c <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0104e66:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e69:	89 04 24             	mov    %eax,(%esp)
c0104e6c:	e8 41 f8 ff ff       	call   c01046b2 <page2pa>
c0104e71:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0104e77:	c1 e2 0c             	shl    $0xc,%edx
c0104e7a:	39 d0                	cmp    %edx,%eax
c0104e7c:	72 24                	jb     c0104ea2 <basic_check+0x18d>
c0104e7e:	c7 44 24 0c 08 c0 10 	movl   $0xc010c008,0xc(%esp)
c0104e85:	c0 
c0104e86:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0104e8d:	c0 
c0104e8e:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0104e95:	00 
c0104e96:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0104e9d:	e8 ca d2 ff ff       	call   c010216c <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0104ea2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ea5:	89 04 24             	mov    %eax,(%esp)
c0104ea8:	e8 05 f8 ff ff       	call   c01046b2 <page2pa>
c0104ead:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0104eb3:	c1 e2 0c             	shl    $0xc,%edx
c0104eb6:	39 d0                	cmp    %edx,%eax
c0104eb8:	72 24                	jb     c0104ede <basic_check+0x1c9>
c0104eba:	c7 44 24 0c 25 c0 10 	movl   $0xc010c025,0xc(%esp)
c0104ec1:	c0 
c0104ec2:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0104ec9:	c0 
c0104eca:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0104ed1:	00 
c0104ed2:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0104ed9:	e8 8e d2 ff ff       	call   c010216c <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ee1:	89 04 24             	mov    %eax,(%esp)
c0104ee4:	e8 c9 f7 ff ff       	call   c01046b2 <page2pa>
c0104ee9:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0104eef:	c1 e2 0c             	shl    $0xc,%edx
c0104ef2:	39 d0                	cmp    %edx,%eax
c0104ef4:	72 24                	jb     c0104f1a <basic_check+0x205>
c0104ef6:	c7 44 24 0c 42 c0 10 	movl   $0xc010c042,0xc(%esp)
c0104efd:	c0 
c0104efe:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0104f05:	c0 
c0104f06:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0104f0d:	00 
c0104f0e:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0104f15:	e8 52 d2 ff ff       	call   c010216c <__panic>

    list_entry_t free_list_store = free_list;
c0104f1a:	a1 78 e0 12 c0       	mov    0xc012e078,%eax
c0104f1f:	8b 15 7c e0 12 c0    	mov    0xc012e07c,%edx
c0104f25:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104f28:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104f2b:	c7 45 e0 78 e0 12 c0 	movl   $0xc012e078,-0x20(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104f32:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f35:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104f38:	89 50 04             	mov    %edx,0x4(%eax)
c0104f3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f3e:	8b 50 04             	mov    0x4(%eax),%edx
c0104f41:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104f44:	89 10                	mov    %edx,(%eax)
c0104f46:	c7 45 dc 78 e0 12 c0 	movl   $0xc012e078,-0x24(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0104f4d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104f50:	8b 40 04             	mov    0x4(%eax),%eax
c0104f53:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104f56:	0f 94 c0             	sete   %al
c0104f59:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104f5c:	85 c0                	test   %eax,%eax
c0104f5e:	75 24                	jne    c0104f84 <basic_check+0x26f>
c0104f60:	c7 44 24 0c 5f c0 10 	movl   $0xc010c05f,0xc(%esp)
c0104f67:	c0 
c0104f68:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0104f6f:	c0 
c0104f70:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0104f77:	00 
c0104f78:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0104f7f:	e8 e8 d1 ff ff       	call   c010216c <__panic>

    unsigned int nr_free_store = nr_free;
c0104f84:	a1 80 e0 12 c0       	mov    0xc012e080,%eax
c0104f89:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0104f8c:	c7 05 80 e0 12 c0 00 	movl   $0x0,0xc012e080
c0104f93:	00 00 00 

    assert(alloc_page() == NULL);
c0104f96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f9d:	e8 ad 13 00 00       	call   c010634f <alloc_pages>
c0104fa2:	85 c0                	test   %eax,%eax
c0104fa4:	74 24                	je     c0104fca <basic_check+0x2b5>
c0104fa6:	c7 44 24 0c 76 c0 10 	movl   $0xc010c076,0xc(%esp)
c0104fad:	c0 
c0104fae:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0104fb5:	c0 
c0104fb6:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0104fbd:	00 
c0104fbe:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0104fc5:	e8 a2 d1 ff ff       	call   c010216c <__panic>

    free_page(p0);
c0104fca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104fd1:	00 
c0104fd2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104fd5:	89 04 24             	mov    %eax,(%esp)
c0104fd8:	e8 dd 13 00 00       	call   c01063ba <free_pages>
    free_page(p1);
c0104fdd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104fe4:	00 
c0104fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104fe8:	89 04 24             	mov    %eax,(%esp)
c0104feb:	e8 ca 13 00 00       	call   c01063ba <free_pages>
    free_page(p2);
c0104ff0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104ff7:	00 
c0104ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ffb:	89 04 24             	mov    %eax,(%esp)
c0104ffe:	e8 b7 13 00 00       	call   c01063ba <free_pages>
    assert(nr_free == 3);
c0105003:	a1 80 e0 12 c0       	mov    0xc012e080,%eax
c0105008:	83 f8 03             	cmp    $0x3,%eax
c010500b:	74 24                	je     c0105031 <basic_check+0x31c>
c010500d:	c7 44 24 0c 8b c0 10 	movl   $0xc010c08b,0xc(%esp)
c0105014:	c0 
c0105015:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c010501c:	c0 
c010501d:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0105024:	00 
c0105025:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c010502c:	e8 3b d1 ff ff       	call   c010216c <__panic>

    assert((p0 = alloc_page()) != NULL);
c0105031:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105038:	e8 12 13 00 00       	call   c010634f <alloc_pages>
c010503d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105040:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105044:	75 24                	jne    c010506a <basic_check+0x355>
c0105046:	c7 44 24 0c 54 bf 10 	movl   $0xc010bf54,0xc(%esp)
c010504d:	c0 
c010504e:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0105055:	c0 
c0105056:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c010505d:	00 
c010505e:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0105065:	e8 02 d1 ff ff       	call   c010216c <__panic>
    assert((p1 = alloc_page()) != NULL);
c010506a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105071:	e8 d9 12 00 00       	call   c010634f <alloc_pages>
c0105076:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105079:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010507d:	75 24                	jne    c01050a3 <basic_check+0x38e>
c010507f:	c7 44 24 0c 70 bf 10 	movl   $0xc010bf70,0xc(%esp)
c0105086:	c0 
c0105087:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c010508e:	c0 
c010508f:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c0105096:	00 
c0105097:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c010509e:	e8 c9 d0 ff ff       	call   c010216c <__panic>
    assert((p2 = alloc_page()) != NULL);
c01050a3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01050aa:	e8 a0 12 00 00       	call   c010634f <alloc_pages>
c01050af:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01050b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01050b6:	75 24                	jne    c01050dc <basic_check+0x3c7>
c01050b8:	c7 44 24 0c 8c bf 10 	movl   $0xc010bf8c,0xc(%esp)
c01050bf:	c0 
c01050c0:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c01050c7:	c0 
c01050c8:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c01050cf:	00 
c01050d0:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c01050d7:	e8 90 d0 ff ff       	call   c010216c <__panic>

    assert(alloc_page() == NULL);
c01050dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01050e3:	e8 67 12 00 00       	call   c010634f <alloc_pages>
c01050e8:	85 c0                	test   %eax,%eax
c01050ea:	74 24                	je     c0105110 <basic_check+0x3fb>
c01050ec:	c7 44 24 0c 76 c0 10 	movl   $0xc010c076,0xc(%esp)
c01050f3:	c0 
c01050f4:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c01050fb:	c0 
c01050fc:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0105103:	00 
c0105104:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c010510b:	e8 5c d0 ff ff       	call   c010216c <__panic>

    free_page(p0);
c0105110:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105117:	00 
c0105118:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010511b:	89 04 24             	mov    %eax,(%esp)
c010511e:	e8 97 12 00 00       	call   c01063ba <free_pages>
c0105123:	c7 45 d8 78 e0 12 c0 	movl   $0xc012e078,-0x28(%ebp)
c010512a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010512d:	8b 40 04             	mov    0x4(%eax),%eax
c0105130:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0105133:	0f 94 c0             	sete   %al
c0105136:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0105139:	85 c0                	test   %eax,%eax
c010513b:	74 24                	je     c0105161 <basic_check+0x44c>
c010513d:	c7 44 24 0c 98 c0 10 	movl   $0xc010c098,0xc(%esp)
c0105144:	c0 
c0105145:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c010514c:	c0 
c010514d:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0105154:	00 
c0105155:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c010515c:	e8 0b d0 ff ff       	call   c010216c <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0105161:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105168:	e8 e2 11 00 00       	call   c010634f <alloc_pages>
c010516d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105170:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105173:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105176:	74 24                	je     c010519c <basic_check+0x487>
c0105178:	c7 44 24 0c b0 c0 10 	movl   $0xc010c0b0,0xc(%esp)
c010517f:	c0 
c0105180:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0105187:	c0 
c0105188:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c010518f:	00 
c0105190:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0105197:	e8 d0 cf ff ff       	call   c010216c <__panic>
    assert(alloc_page() == NULL);
c010519c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01051a3:	e8 a7 11 00 00       	call   c010634f <alloc_pages>
c01051a8:	85 c0                	test   %eax,%eax
c01051aa:	74 24                	je     c01051d0 <basic_check+0x4bb>
c01051ac:	c7 44 24 0c 76 c0 10 	movl   $0xc010c076,0xc(%esp)
c01051b3:	c0 
c01051b4:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c01051bb:	c0 
c01051bc:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c01051c3:	00 
c01051c4:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c01051cb:	e8 9c cf ff ff       	call   c010216c <__panic>

    assert(nr_free == 0);
c01051d0:	a1 80 e0 12 c0       	mov    0xc012e080,%eax
c01051d5:	85 c0                	test   %eax,%eax
c01051d7:	74 24                	je     c01051fd <basic_check+0x4e8>
c01051d9:	c7 44 24 0c c9 c0 10 	movl   $0xc010c0c9,0xc(%esp)
c01051e0:	c0 
c01051e1:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c01051e8:	c0 
c01051e9:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c01051f0:	00 
c01051f1:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c01051f8:	e8 6f cf ff ff       	call   c010216c <__panic>
    free_list = free_list_store;
c01051fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105200:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105203:	a3 78 e0 12 c0       	mov    %eax,0xc012e078
c0105208:	89 15 7c e0 12 c0    	mov    %edx,0xc012e07c
    nr_free = nr_free_store;
c010520e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105211:	a3 80 e0 12 c0       	mov    %eax,0xc012e080

    free_page(p);
c0105216:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010521d:	00 
c010521e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105221:	89 04 24             	mov    %eax,(%esp)
c0105224:	e8 91 11 00 00       	call   c01063ba <free_pages>
    free_page(p1);
c0105229:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105230:	00 
c0105231:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105234:	89 04 24             	mov    %eax,(%esp)
c0105237:	e8 7e 11 00 00       	call   c01063ba <free_pages>
    free_page(p2);
c010523c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105243:	00 
c0105244:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105247:	89 04 24             	mov    %eax,(%esp)
c010524a:	e8 6b 11 00 00       	call   c01063ba <free_pages>
}
c010524f:	c9                   	leave  
c0105250:	c3                   	ret    

c0105251 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0105251:	55                   	push   %ebp
c0105252:	89 e5                	mov    %esp,%ebp
c0105254:	53                   	push   %ebx
c0105255:	81 ec 94 00 00 00    	sub    $0x94,%esp
    int count = 0, total = 0;
c010525b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105262:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0105269:	c7 45 ec 78 e0 12 c0 	movl   $0xc012e078,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105270:	eb 6b                	jmp    c01052dd <default_check+0x8c>
        struct Page *p = le2page(le, page_link);
c0105272:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105275:	83 e8 10             	sub    $0x10,%eax
c0105278:	89 45 e8             	mov    %eax,-0x18(%ebp)
        assert(PageProperty(p));
c010527b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010527e:	83 c0 04             	add    $0x4,%eax
c0105281:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0105288:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010528b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010528e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105291:	0f a3 10             	bt     %edx,(%eax)
c0105294:	19 c0                	sbb    %eax,%eax
c0105296:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0105299:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c010529d:	0f 95 c0             	setne  %al
c01052a0:	0f b6 c0             	movzbl %al,%eax
c01052a3:	85 c0                	test   %eax,%eax
c01052a5:	75 24                	jne    c01052cb <default_check+0x7a>
c01052a7:	c7 44 24 0c d6 c0 10 	movl   $0xc010c0d6,0xc(%esp)
c01052ae:	c0 
c01052af:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c01052b6:	c0 
c01052b7:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c01052be:	00 
c01052bf:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c01052c6:	e8 a1 ce ff ff       	call   c010216c <__panic>
        count ++, total += p->property;
c01052cb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01052cf:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01052d2:	8b 50 08             	mov    0x8(%eax),%edx
c01052d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052d8:	01 d0                	add    %edx,%eax
c01052da:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01052dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052e0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01052e3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01052e6:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01052e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01052ec:	81 7d ec 78 e0 12 c0 	cmpl   $0xc012e078,-0x14(%ebp)
c01052f3:	0f 85 79 ff ff ff    	jne    c0105272 <default_check+0x21>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c01052f9:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c01052fc:	e8 eb 10 00 00       	call   c01063ec <nr_free_pages>
c0105301:	39 c3                	cmp    %eax,%ebx
c0105303:	74 24                	je     c0105329 <default_check+0xd8>
c0105305:	c7 44 24 0c e6 c0 10 	movl   $0xc010c0e6,0xc(%esp)
c010530c:	c0 
c010530d:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0105314:	c0 
c0105315:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c010531c:	00 
c010531d:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0105324:	e8 43 ce ff ff       	call   c010216c <__panic>

    basic_check();
c0105329:	e8 e7 f9 ff ff       	call   c0104d15 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c010532e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105335:	e8 15 10 00 00       	call   c010634f <alloc_pages>
c010533a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(p0 != NULL);
c010533d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105341:	75 24                	jne    c0105367 <default_check+0x116>
c0105343:	c7 44 24 0c ff c0 10 	movl   $0xc010c0ff,0xc(%esp)
c010534a:	c0 
c010534b:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0105352:	c0 
c0105353:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c010535a:	00 
c010535b:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0105362:	e8 05 ce ff ff       	call   c010216c <__panic>
    assert(!PageProperty(p0));
c0105367:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010536a:	83 c0 04             	add    $0x4,%eax
c010536d:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0105374:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105377:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010537a:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010537d:	0f a3 10             	bt     %edx,(%eax)
c0105380:	19 c0                	sbb    %eax,%eax
c0105382:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0105385:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0105389:	0f 95 c0             	setne  %al
c010538c:	0f b6 c0             	movzbl %al,%eax
c010538f:	85 c0                	test   %eax,%eax
c0105391:	74 24                	je     c01053b7 <default_check+0x166>
c0105393:	c7 44 24 0c 0a c1 10 	movl   $0xc010c10a,0xc(%esp)
c010539a:	c0 
c010539b:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c01053a2:	c0 
c01053a3:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c01053aa:	00 
c01053ab:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c01053b2:	e8 b5 cd ff ff       	call   c010216c <__panic>

    list_entry_t free_list_store = free_list;
c01053b7:	a1 78 e0 12 c0       	mov    0xc012e078,%eax
c01053bc:	8b 15 7c e0 12 c0    	mov    0xc012e07c,%edx
c01053c2:	89 45 80             	mov    %eax,-0x80(%ebp)
c01053c5:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01053c8:	c7 45 b4 78 e0 12 c0 	movl   $0xc012e078,-0x4c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01053cf:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01053d2:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01053d5:	89 50 04             	mov    %edx,0x4(%eax)
c01053d8:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01053db:	8b 50 04             	mov    0x4(%eax),%edx
c01053de:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01053e1:	89 10                	mov    %edx,(%eax)
c01053e3:	c7 45 b0 78 e0 12 c0 	movl   $0xc012e078,-0x50(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01053ea:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01053ed:	8b 40 04             	mov    0x4(%eax),%eax
c01053f0:	39 45 b0             	cmp    %eax,-0x50(%ebp)
c01053f3:	0f 94 c0             	sete   %al
c01053f6:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01053f9:	85 c0                	test   %eax,%eax
c01053fb:	75 24                	jne    c0105421 <default_check+0x1d0>
c01053fd:	c7 44 24 0c 5f c0 10 	movl   $0xc010c05f,0xc(%esp)
c0105404:	c0 
c0105405:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c010540c:	c0 
c010540d:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0105414:	00 
c0105415:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c010541c:	e8 4b cd ff ff       	call   c010216c <__panic>
    assert(alloc_page() == NULL);
c0105421:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105428:	e8 22 0f 00 00       	call   c010634f <alloc_pages>
c010542d:	85 c0                	test   %eax,%eax
c010542f:	74 24                	je     c0105455 <default_check+0x204>
c0105431:	c7 44 24 0c 76 c0 10 	movl   $0xc010c076,0xc(%esp)
c0105438:	c0 
c0105439:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0105440:	c0 
c0105441:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0105448:	00 
c0105449:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0105450:	e8 17 cd ff ff       	call   c010216c <__panic>

    unsigned int nr_free_store = nr_free;
c0105455:	a1 80 e0 12 c0       	mov    0xc012e080,%eax
c010545a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c010545d:	c7 05 80 e0 12 c0 00 	movl   $0x0,0xc012e080
c0105464:	00 00 00 

    free_pages(p0 + 2, 3);
c0105467:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010546a:	83 c0 48             	add    $0x48,%eax
c010546d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105474:	00 
c0105475:	89 04 24             	mov    %eax,(%esp)
c0105478:	e8 3d 0f 00 00       	call   c01063ba <free_pages>
    assert(alloc_pages(4) == NULL);
c010547d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0105484:	e8 c6 0e 00 00       	call   c010634f <alloc_pages>
c0105489:	85 c0                	test   %eax,%eax
c010548b:	74 24                	je     c01054b1 <default_check+0x260>
c010548d:	c7 44 24 0c 1c c1 10 	movl   $0xc010c11c,0xc(%esp)
c0105494:	c0 
c0105495:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c010549c:	c0 
c010549d:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c01054a4:	00 
c01054a5:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c01054ac:	e8 bb cc ff ff       	call   c010216c <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01054b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054b4:	83 c0 48             	add    $0x48,%eax
c01054b7:	83 c0 04             	add    $0x4,%eax
c01054ba:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01054c1:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01054c4:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01054c7:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01054ca:	0f a3 10             	bt     %edx,(%eax)
c01054cd:	19 c0                	sbb    %eax,%eax
c01054cf:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01054d2:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01054d6:	0f 95 c0             	setne  %al
c01054d9:	0f b6 c0             	movzbl %al,%eax
c01054dc:	85 c0                	test   %eax,%eax
c01054de:	74 0e                	je     c01054ee <default_check+0x29d>
c01054e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01054e3:	83 c0 48             	add    $0x48,%eax
c01054e6:	8b 40 08             	mov    0x8(%eax),%eax
c01054e9:	83 f8 03             	cmp    $0x3,%eax
c01054ec:	74 24                	je     c0105512 <default_check+0x2c1>
c01054ee:	c7 44 24 0c 34 c1 10 	movl   $0xc010c134,0xc(%esp)
c01054f5:	c0 
c01054f6:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c01054fd:	c0 
c01054fe:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0105505:	00 
c0105506:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c010550d:	e8 5a cc ff ff       	call   c010216c <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0105512:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0105519:	e8 31 0e 00 00       	call   c010634f <alloc_pages>
c010551e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105521:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105525:	75 24                	jne    c010554b <default_check+0x2fa>
c0105527:	c7 44 24 0c 60 c1 10 	movl   $0xc010c160,0xc(%esp)
c010552e:	c0 
c010552f:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0105536:	c0 
c0105537:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c010553e:	00 
c010553f:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0105546:	e8 21 cc ff ff       	call   c010216c <__panic>
    assert(alloc_page() == NULL);
c010554b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105552:	e8 f8 0d 00 00       	call   c010634f <alloc_pages>
c0105557:	85 c0                	test   %eax,%eax
c0105559:	74 24                	je     c010557f <default_check+0x32e>
c010555b:	c7 44 24 0c 76 c0 10 	movl   $0xc010c076,0xc(%esp)
c0105562:	c0 
c0105563:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c010556a:	c0 
c010556b:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0105572:	00 
c0105573:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c010557a:	e8 ed cb ff ff       	call   c010216c <__panic>
    assert(p0 + 2 == p1);
c010557f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105582:	83 c0 48             	add    $0x48,%eax
c0105585:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0105588:	74 24                	je     c01055ae <default_check+0x35d>
c010558a:	c7 44 24 0c 7e c1 10 	movl   $0xc010c17e,0xc(%esp)
c0105591:	c0 
c0105592:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0105599:	c0 
c010559a:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c01055a1:	00 
c01055a2:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c01055a9:	e8 be cb ff ff       	call   c010216c <__panic>

    p2 = p0 + 1;
c01055ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01055b1:	83 c0 24             	add    $0x24,%eax
c01055b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
    free_page(p0);
c01055b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01055be:	00 
c01055bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01055c2:	89 04 24             	mov    %eax,(%esp)
c01055c5:	e8 f0 0d 00 00       	call   c01063ba <free_pages>
    free_pages(p1, 3);
c01055ca:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01055d1:	00 
c01055d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01055d5:	89 04 24             	mov    %eax,(%esp)
c01055d8:	e8 dd 0d 00 00       	call   c01063ba <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01055dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01055e0:	83 c0 04             	add    $0x4,%eax
c01055e3:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01055ea:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01055ed:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01055f0:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01055f3:	0f a3 10             	bt     %edx,(%eax)
c01055f6:	19 c0                	sbb    %eax,%eax
c01055f8:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01055fb:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01055ff:	0f 95 c0             	setne  %al
c0105602:	0f b6 c0             	movzbl %al,%eax
c0105605:	85 c0                	test   %eax,%eax
c0105607:	74 0b                	je     c0105614 <default_check+0x3c3>
c0105609:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010560c:	8b 40 08             	mov    0x8(%eax),%eax
c010560f:	83 f8 01             	cmp    $0x1,%eax
c0105612:	74 24                	je     c0105638 <default_check+0x3e7>
c0105614:	c7 44 24 0c 8c c1 10 	movl   $0xc010c18c,0xc(%esp)
c010561b:	c0 
c010561c:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0105623:	c0 
c0105624:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c010562b:	00 
c010562c:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0105633:	e8 34 cb ff ff       	call   c010216c <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0105638:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010563b:	83 c0 04             	add    $0x4,%eax
c010563e:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0105645:	89 45 90             	mov    %eax,-0x70(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105648:	8b 45 90             	mov    -0x70(%ebp),%eax
c010564b:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010564e:	0f a3 10             	bt     %edx,(%eax)
c0105651:	19 c0                	sbb    %eax,%eax
c0105653:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0105656:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c010565a:	0f 95 c0             	setne  %al
c010565d:	0f b6 c0             	movzbl %al,%eax
c0105660:	85 c0                	test   %eax,%eax
c0105662:	74 0b                	je     c010566f <default_check+0x41e>
c0105664:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105667:	8b 40 08             	mov    0x8(%eax),%eax
c010566a:	83 f8 03             	cmp    $0x3,%eax
c010566d:	74 24                	je     c0105693 <default_check+0x442>
c010566f:	c7 44 24 0c b4 c1 10 	movl   $0xc010c1b4,0xc(%esp)
c0105676:	c0 
c0105677:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c010567e:	c0 
c010567f:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0105686:	00 
c0105687:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c010568e:	e8 d9 ca ff ff       	call   c010216c <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0105693:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010569a:	e8 b0 0c 00 00       	call   c010634f <alloc_pages>
c010569f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01056a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01056a5:	83 e8 24             	sub    $0x24,%eax
c01056a8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01056ab:	74 24                	je     c01056d1 <default_check+0x480>
c01056ad:	c7 44 24 0c da c1 10 	movl   $0xc010c1da,0xc(%esp)
c01056b4:	c0 
c01056b5:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c01056bc:	c0 
c01056bd:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c01056c4:	00 
c01056c5:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c01056cc:	e8 9b ca ff ff       	call   c010216c <__panic>
    free_page(p0);
c01056d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01056d8:	00 
c01056d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01056dc:	89 04 24             	mov    %eax,(%esp)
c01056df:	e8 d6 0c 00 00       	call   c01063ba <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01056e4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01056eb:	e8 5f 0c 00 00       	call   c010634f <alloc_pages>
c01056f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01056f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01056f6:	83 c0 24             	add    $0x24,%eax
c01056f9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01056fc:	74 24                	je     c0105722 <default_check+0x4d1>
c01056fe:	c7 44 24 0c f8 c1 10 	movl   $0xc010c1f8,0xc(%esp)
c0105705:	c0 
c0105706:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c010570d:	c0 
c010570e:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0105715:	00 
c0105716:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c010571d:	e8 4a ca ff ff       	call   c010216c <__panic>

    free_pages(p0, 2);
c0105722:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0105729:	00 
c010572a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010572d:	89 04 24             	mov    %eax,(%esp)
c0105730:	e8 85 0c 00 00       	call   c01063ba <free_pages>
    free_page(p2);
c0105735:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010573c:	00 
c010573d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105740:	89 04 24             	mov    %eax,(%esp)
c0105743:	e8 72 0c 00 00       	call   c01063ba <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0105748:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010574f:	e8 fb 0b 00 00       	call   c010634f <alloc_pages>
c0105754:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105757:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010575b:	75 24                	jne    c0105781 <default_check+0x530>
c010575d:	c7 44 24 0c 18 c2 10 	movl   $0xc010c218,0xc(%esp)
c0105764:	c0 
c0105765:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c010576c:	c0 
c010576d:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0105774:	00 
c0105775:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c010577c:	e8 eb c9 ff ff       	call   c010216c <__panic>
    assert(alloc_page() == NULL);
c0105781:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105788:	e8 c2 0b 00 00       	call   c010634f <alloc_pages>
c010578d:	85 c0                	test   %eax,%eax
c010578f:	74 24                	je     c01057b5 <default_check+0x564>
c0105791:	c7 44 24 0c 76 c0 10 	movl   $0xc010c076,0xc(%esp)
c0105798:	c0 
c0105799:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c01057a0:	c0 
c01057a1:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c01057a8:	00 
c01057a9:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c01057b0:	e8 b7 c9 ff ff       	call   c010216c <__panic>

    assert(nr_free == 0);
c01057b5:	a1 80 e0 12 c0       	mov    0xc012e080,%eax
c01057ba:	85 c0                	test   %eax,%eax
c01057bc:	74 24                	je     c01057e2 <default_check+0x591>
c01057be:	c7 44 24 0c c9 c0 10 	movl   $0xc010c0c9,0xc(%esp)
c01057c5:	c0 
c01057c6:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c01057cd:	c0 
c01057ce:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c01057d5:	00 
c01057d6:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c01057dd:	e8 8a c9 ff ff       	call   c010216c <__panic>
    nr_free = nr_free_store;
c01057e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01057e5:	a3 80 e0 12 c0       	mov    %eax,0xc012e080

    free_list = free_list_store;
c01057ea:	8b 45 80             	mov    -0x80(%ebp),%eax
c01057ed:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01057f0:	a3 78 e0 12 c0       	mov    %eax,0xc012e078
c01057f5:	89 15 7c e0 12 c0    	mov    %edx,0xc012e07c
    free_pages(p0, 5);
c01057fb:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0105802:	00 
c0105803:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105806:	89 04 24             	mov    %eax,(%esp)
c0105809:	e8 ac 0b 00 00       	call   c01063ba <free_pages>

    le = &free_list;
c010580e:	c7 45 ec 78 e0 12 c0 	movl   $0xc012e078,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105815:	eb 1d                	jmp    c0105834 <default_check+0x5e3>
        struct Page *p = le2page(le, page_link);
c0105817:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010581a:	83 e8 10             	sub    $0x10,%eax
c010581d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        count --, total -= p->property;
c0105820:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0105824:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105827:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010582a:	8b 40 08             	mov    0x8(%eax),%eax
c010582d:	29 c2                	sub    %eax,%edx
c010582f:	89 d0                	mov    %edx,%eax
c0105831:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105834:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105837:	89 45 88             	mov    %eax,-0x78(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010583a:	8b 45 88             	mov    -0x78(%ebp),%eax
c010583d:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0105840:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105843:	81 7d ec 78 e0 12 c0 	cmpl   $0xc012e078,-0x14(%ebp)
c010584a:	75 cb                	jne    c0105817 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c010584c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105850:	74 24                	je     c0105876 <default_check+0x625>
c0105852:	c7 44 24 0c 36 c2 10 	movl   $0xc010c236,0xc(%esp)
c0105859:	c0 
c010585a:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c0105861:	c0 
c0105862:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c0105869:	00 
c010586a:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c0105871:	e8 f6 c8 ff ff       	call   c010216c <__panic>
    assert(total == 0);
c0105876:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010587a:	74 24                	je     c01058a0 <default_check+0x64f>
c010587c:	c7 44 24 0c 41 c2 10 	movl   $0xc010c241,0xc(%esp)
c0105883:	c0 
c0105884:	c7 44 24 08 d6 be 10 	movl   $0xc010bed6,0x8(%esp)
c010588b:	c0 
c010588c:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c0105893:	00 
c0105894:	c7 04 24 eb be 10 c0 	movl   $0xc010beeb,(%esp)
c010589b:	e8 cc c8 ff ff       	call   c010216c <__panic>
}
c01058a0:	81 c4 94 00 00 00    	add    $0x94,%esp
c01058a6:	5b                   	pop    %ebx
c01058a7:	5d                   	pop    %ebp
c01058a8:	c3                   	ret    

c01058a9 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c01058a9:	55                   	push   %ebp
c01058aa:	89 e5                	mov    %esp,%ebp
c01058ac:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01058af:	9c                   	pushf  
c01058b0:	58                   	pop    %eax
c01058b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01058b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01058b7:	25 00 02 00 00       	and    $0x200,%eax
c01058bc:	85 c0                	test   %eax,%eax
c01058be:	74 0c                	je     c01058cc <__intr_save+0x23>
        intr_disable();
c01058c0:	e8 10 db ff ff       	call   c01033d5 <intr_disable>
        return 1;
c01058c5:	b8 01 00 00 00       	mov    $0x1,%eax
c01058ca:	eb 05                	jmp    c01058d1 <__intr_save+0x28>
    }
    return 0;
c01058cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01058d1:	c9                   	leave  
c01058d2:	c3                   	ret    

c01058d3 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01058d3:	55                   	push   %ebp
c01058d4:	89 e5                	mov    %esp,%ebp
c01058d6:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01058d9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01058dd:	74 05                	je     c01058e4 <__intr_restore+0x11>
        intr_enable();
c01058df:	e8 eb da ff ff       	call   c01033cf <intr_enable>
    }
}
c01058e4:	c9                   	leave  
c01058e5:	c3                   	ret    

c01058e6 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01058e6:	55                   	push   %ebp
c01058e7:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01058e9:	8b 55 08             	mov    0x8(%ebp),%edx
c01058ec:	a1 8c e0 12 c0       	mov    0xc012e08c,%eax
c01058f1:	29 c2                	sub    %eax,%edx
c01058f3:	89 d0                	mov    %edx,%eax
c01058f5:	c1 f8 02             	sar    $0x2,%eax
c01058f8:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c01058fe:	5d                   	pop    %ebp
c01058ff:	c3                   	ret    

c0105900 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0105900:	55                   	push   %ebp
c0105901:	89 e5                	mov    %esp,%ebp
c0105903:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0105906:	8b 45 08             	mov    0x8(%ebp),%eax
c0105909:	89 04 24             	mov    %eax,(%esp)
c010590c:	e8 d5 ff ff ff       	call   c01058e6 <page2ppn>
c0105911:	c1 e0 0c             	shl    $0xc,%eax
}
c0105914:	c9                   	leave  
c0105915:	c3                   	ret    

c0105916 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0105916:	55                   	push   %ebp
c0105917:	89 e5                	mov    %esp,%ebp
c0105919:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c010591c:	8b 45 08             	mov    0x8(%ebp),%eax
c010591f:	c1 e8 0c             	shr    $0xc,%eax
c0105922:	89 c2                	mov    %eax,%edx
c0105924:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c0105929:	39 c2                	cmp    %eax,%edx
c010592b:	72 1c                	jb     c0105949 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c010592d:	c7 44 24 08 7c c2 10 	movl   $0xc010c27c,0x8(%esp)
c0105934:	c0 
c0105935:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c010593c:	00 
c010593d:	c7 04 24 9b c2 10 c0 	movl   $0xc010c29b,(%esp)
c0105944:	e8 23 c8 ff ff       	call   c010216c <__panic>
    }
    return &pages[PPN(pa)];
c0105949:	8b 0d 8c e0 12 c0    	mov    0xc012e08c,%ecx
c010594f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105952:	c1 e8 0c             	shr    $0xc,%eax
c0105955:	89 c2                	mov    %eax,%edx
c0105957:	89 d0                	mov    %edx,%eax
c0105959:	c1 e0 03             	shl    $0x3,%eax
c010595c:	01 d0                	add    %edx,%eax
c010595e:	c1 e0 02             	shl    $0x2,%eax
c0105961:	01 c8                	add    %ecx,%eax
}
c0105963:	c9                   	leave  
c0105964:	c3                   	ret    

c0105965 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0105965:	55                   	push   %ebp
c0105966:	89 e5                	mov    %esp,%ebp
c0105968:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010596b:	8b 45 08             	mov    0x8(%ebp),%eax
c010596e:	89 04 24             	mov    %eax,(%esp)
c0105971:	e8 8a ff ff ff       	call   c0105900 <page2pa>
c0105976:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105979:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010597c:	c1 e8 0c             	shr    $0xc,%eax
c010597f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105982:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c0105987:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010598a:	72 23                	jb     c01059af <page2kva+0x4a>
c010598c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010598f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105993:	c7 44 24 08 ac c2 10 	movl   $0xc010c2ac,0x8(%esp)
c010599a:	c0 
c010599b:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c01059a2:	00 
c01059a3:	c7 04 24 9b c2 10 c0 	movl   $0xc010c29b,(%esp)
c01059aa:	e8 bd c7 ff ff       	call   c010216c <__panic>
c01059af:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059b2:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01059b7:	c9                   	leave  
c01059b8:	c3                   	ret    

c01059b9 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c01059b9:	55                   	push   %ebp
c01059ba:	89 e5                	mov    %esp,%ebp
c01059bc:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c01059bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01059c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01059c5:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01059cc:	77 23                	ja     c01059f1 <kva2page+0x38>
c01059ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01059d5:	c7 44 24 08 d0 c2 10 	movl   $0xc010c2d0,0x8(%esp)
c01059dc:	c0 
c01059dd:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c01059e4:	00 
c01059e5:	c7 04 24 9b c2 10 c0 	movl   $0xc010c29b,(%esp)
c01059ec:	e8 7b c7 ff ff       	call   c010216c <__panic>
c01059f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059f4:	05 00 00 00 40       	add    $0x40000000,%eax
c01059f9:	89 04 24             	mov    %eax,(%esp)
c01059fc:	e8 15 ff ff ff       	call   c0105916 <pa2page>
}
c0105a01:	c9                   	leave  
c0105a02:	c3                   	ret    

c0105a03 <__slob_get_free_pages>:
static slob_t *slobfree = &arena;
static bigblock_t *bigblocks;


static void* __slob_get_free_pages(gfp_t gfp, int order)
{
c0105a03:	55                   	push   %ebp
c0105a04:	89 e5                	mov    %esp,%ebp
c0105a06:	83 ec 28             	sub    $0x28,%esp
  struct Page * page = alloc_pages(1 << order);
c0105a09:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a0c:	ba 01 00 00 00       	mov    $0x1,%edx
c0105a11:	89 c1                	mov    %eax,%ecx
c0105a13:	d3 e2                	shl    %cl,%edx
c0105a15:	89 d0                	mov    %edx,%eax
c0105a17:	89 04 24             	mov    %eax,(%esp)
c0105a1a:	e8 30 09 00 00       	call   c010634f <alloc_pages>
c0105a1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!page)
c0105a22:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105a26:	75 07                	jne    c0105a2f <__slob_get_free_pages+0x2c>
    return NULL;
c0105a28:	b8 00 00 00 00       	mov    $0x0,%eax
c0105a2d:	eb 0b                	jmp    c0105a3a <__slob_get_free_pages+0x37>
  return page2kva(page);
c0105a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105a32:	89 04 24             	mov    %eax,(%esp)
c0105a35:	e8 2b ff ff ff       	call   c0105965 <page2kva>
}
c0105a3a:	c9                   	leave  
c0105a3b:	c3                   	ret    

c0105a3c <__slob_free_pages>:

#define __slob_get_free_page(gfp) __slob_get_free_pages(gfp, 0)

static inline void __slob_free_pages(unsigned long kva, int order)
{
c0105a3c:	55                   	push   %ebp
c0105a3d:	89 e5                	mov    %esp,%ebp
c0105a3f:	53                   	push   %ebx
c0105a40:	83 ec 14             	sub    $0x14,%esp
  free_pages(kva2page(kva), 1 << order);
c0105a43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a46:	ba 01 00 00 00       	mov    $0x1,%edx
c0105a4b:	89 c1                	mov    %eax,%ecx
c0105a4d:	d3 e2                	shl    %cl,%edx
c0105a4f:	89 d0                	mov    %edx,%eax
c0105a51:	89 c3                	mov    %eax,%ebx
c0105a53:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a56:	89 04 24             	mov    %eax,(%esp)
c0105a59:	e8 5b ff ff ff       	call   c01059b9 <kva2page>
c0105a5e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0105a62:	89 04 24             	mov    %eax,(%esp)
c0105a65:	e8 50 09 00 00       	call   c01063ba <free_pages>
}
c0105a6a:	83 c4 14             	add    $0x14,%esp
c0105a6d:	5b                   	pop    %ebx
c0105a6e:	5d                   	pop    %ebp
c0105a6f:	c3                   	ret    

c0105a70 <slob_alloc>:

static void slob_free(void *b, int size);

static void *slob_alloc(size_t size, gfp_t gfp, int align)
{
c0105a70:	55                   	push   %ebp
c0105a71:	89 e5                	mov    %esp,%ebp
c0105a73:	83 ec 38             	sub    $0x38,%esp
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
c0105a76:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a79:	83 c0 08             	add    $0x8,%eax
c0105a7c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c0105a81:	76 24                	jbe    c0105aa7 <slob_alloc+0x37>
c0105a83:	c7 44 24 0c f4 c2 10 	movl   $0xc010c2f4,0xc(%esp)
c0105a8a:	c0 
c0105a8b:	c7 44 24 08 13 c3 10 	movl   $0xc010c313,0x8(%esp)
c0105a92:	c0 
c0105a93:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0105a9a:	00 
c0105a9b:	c7 04 24 28 c3 10 c0 	movl   $0xc010c328,(%esp)
c0105aa2:	e8 c5 c6 ff ff       	call   c010216c <__panic>

	slob_t *prev, *cur, *aligned = 0;
c0105aa7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
c0105aae:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0105ab5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ab8:	83 c0 07             	add    $0x7,%eax
c0105abb:	c1 e8 03             	shr    $0x3,%eax
c0105abe:	89 45 e0             	mov    %eax,-0x20(%ebp)
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
c0105ac1:	e8 e3 fd ff ff       	call   c01058a9 <__intr_save>
c0105ac6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	prev = slobfree;
c0105ac9:	a1 e8 89 12 c0       	mov    0xc01289e8,%eax
c0105ace:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0105ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ad4:	8b 40 04             	mov    0x4(%eax),%eax
c0105ad7:	89 45 f0             	mov    %eax,-0x10(%ebp)
		if (align) {
c0105ada:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105ade:	74 25                	je     c0105b05 <slob_alloc+0x95>
			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
c0105ae0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105ae3:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ae6:	01 d0                	add    %edx,%eax
c0105ae8:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105aeb:	8b 45 10             	mov    0x10(%ebp),%eax
c0105aee:	f7 d8                	neg    %eax
c0105af0:	21 d0                	and    %edx,%eax
c0105af2:	89 45 ec             	mov    %eax,-0x14(%ebp)
			delta = aligned - cur;
c0105af5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105af8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105afb:	29 c2                	sub    %eax,%edx
c0105afd:	89 d0                	mov    %edx,%eax
c0105aff:	c1 f8 03             	sar    $0x3,%eax
c0105b02:	89 45 e8             	mov    %eax,-0x18(%ebp)
		}
		if (cur->units >= units + delta) { /* room enough? */
c0105b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b08:	8b 00                	mov    (%eax),%eax
c0105b0a:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105b0d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0105b10:	01 ca                	add    %ecx,%edx
c0105b12:	39 d0                	cmp    %edx,%eax
c0105b14:	0f 8c aa 00 00 00    	jl     c0105bc4 <slob_alloc+0x154>
			if (delta) { /* need to fragment head to align? */
c0105b1a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105b1e:	74 38                	je     c0105b58 <slob_alloc+0xe8>
				aligned->units = cur->units - delta;
c0105b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b23:	8b 00                	mov    (%eax),%eax
c0105b25:	2b 45 e8             	sub    -0x18(%ebp),%eax
c0105b28:	89 c2                	mov    %eax,%edx
c0105b2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b2d:	89 10                	mov    %edx,(%eax)
				aligned->next = cur->next;
c0105b2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b32:	8b 50 04             	mov    0x4(%eax),%edx
c0105b35:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b38:	89 50 04             	mov    %edx,0x4(%eax)
				cur->next = aligned;
c0105b3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b3e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105b41:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = delta;
c0105b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b47:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105b4a:	89 10                	mov    %edx,(%eax)
				prev = cur;
c0105b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
				cur = aligned;
c0105b52:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105b55:	89 45 f0             	mov    %eax,-0x10(%ebp)
			}

			if (cur->units == units) /* exact fit? */
c0105b58:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b5b:	8b 00                	mov    (%eax),%eax
c0105b5d:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0105b60:	75 0e                	jne    c0105b70 <slob_alloc+0x100>
				prev->next = cur->next; /* unlink */
c0105b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b65:	8b 50 04             	mov    0x4(%eax),%edx
c0105b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b6b:	89 50 04             	mov    %edx,0x4(%eax)
c0105b6e:	eb 3c                	jmp    c0105bac <slob_alloc+0x13c>
			else { /* fragment */
				prev->next = cur + units;
c0105b70:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b73:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0105b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b7d:	01 c2                	add    %eax,%edx
c0105b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b82:	89 50 04             	mov    %edx,0x4(%eax)
				prev->next->units = cur->units - units;
c0105b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b88:	8b 40 04             	mov    0x4(%eax),%eax
c0105b8b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105b8e:	8b 12                	mov    (%edx),%edx
c0105b90:	2b 55 e0             	sub    -0x20(%ebp),%edx
c0105b93:	89 10                	mov    %edx,(%eax)
				prev->next->next = cur->next;
c0105b95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105b98:	8b 40 04             	mov    0x4(%eax),%eax
c0105b9b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105b9e:	8b 52 04             	mov    0x4(%edx),%edx
c0105ba1:	89 50 04             	mov    %edx,0x4(%eax)
				cur->units = units;
c0105ba4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ba7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105baa:	89 10                	mov    %edx,(%eax)
			}

			slobfree = prev;
c0105bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105baf:	a3 e8 89 12 c0       	mov    %eax,0xc01289e8
			spin_unlock_irqrestore(&slob_lock, flags);
c0105bb4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105bb7:	89 04 24             	mov    %eax,(%esp)
c0105bba:	e8 14 fd ff ff       	call   c01058d3 <__intr_restore>
			return cur;
c0105bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bc2:	eb 7f                	jmp    c0105c43 <slob_alloc+0x1d3>
		}
		if (cur == slobfree) {
c0105bc4:	a1 e8 89 12 c0       	mov    0xc01289e8,%eax
c0105bc9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0105bcc:	75 61                	jne    c0105c2f <slob_alloc+0x1bf>
			spin_unlock_irqrestore(&slob_lock, flags);
c0105bce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105bd1:	89 04 24             	mov    %eax,(%esp)
c0105bd4:	e8 fa fc ff ff       	call   c01058d3 <__intr_restore>

			if (size == PAGE_SIZE) /* trying to shrink arena? */
c0105bd9:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0105be0:	75 07                	jne    c0105be9 <slob_alloc+0x179>
				return 0;
c0105be2:	b8 00 00 00 00       	mov    $0x0,%eax
c0105be7:	eb 5a                	jmp    c0105c43 <slob_alloc+0x1d3>

			cur = (slob_t *)__slob_get_free_page(gfp);
c0105be9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105bf0:	00 
c0105bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bf4:	89 04 24             	mov    %eax,(%esp)
c0105bf7:	e8 07 fe ff ff       	call   c0105a03 <__slob_get_free_pages>
c0105bfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
			if (!cur)
c0105bff:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105c03:	75 07                	jne    c0105c0c <slob_alloc+0x19c>
				return 0;
c0105c05:	b8 00 00 00 00       	mov    $0x0,%eax
c0105c0a:	eb 37                	jmp    c0105c43 <slob_alloc+0x1d3>

			slob_free(cur, PAGE_SIZE);
c0105c0c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105c13:	00 
c0105c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c17:	89 04 24             	mov    %eax,(%esp)
c0105c1a:	e8 26 00 00 00       	call   c0105c45 <slob_free>
			spin_lock_irqsave(&slob_lock, flags);
c0105c1f:	e8 85 fc ff ff       	call   c01058a9 <__intr_save>
c0105c24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			cur = slobfree;
c0105c27:	a1 e8 89 12 c0       	mov    0xc01289e8,%eax
c0105c2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int delta = 0, units = SLOB_UNITS(size);
	unsigned long flags;

	spin_lock_irqsave(&slob_lock, flags);
	prev = slobfree;
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
c0105c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c32:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c38:	8b 40 04             	mov    0x4(%eax),%eax
c0105c3b:	89 45 f0             	mov    %eax,-0x10(%ebp)

			slob_free(cur, PAGE_SIZE);
			spin_lock_irqsave(&slob_lock, flags);
			cur = slobfree;
		}
	}
c0105c3e:	e9 97 fe ff ff       	jmp    c0105ada <slob_alloc+0x6a>
}
c0105c43:	c9                   	leave  
c0105c44:	c3                   	ret    

c0105c45 <slob_free>:

static void slob_free(void *block, int size)
{
c0105c45:	55                   	push   %ebp
c0105c46:	89 e5                	mov    %esp,%ebp
c0105c48:	83 ec 28             	sub    $0x28,%esp
	slob_t *cur, *b = (slob_t *)block;
c0105c4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0105c51:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105c55:	75 05                	jne    c0105c5c <slob_free+0x17>
		return;
c0105c57:	e9 ff 00 00 00       	jmp    c0105d5b <slob_free+0x116>

	if (size)
c0105c5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105c60:	74 10                	je     c0105c72 <slob_free+0x2d>
		b->units = SLOB_UNITS(size);
c0105c62:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c65:	83 c0 07             	add    $0x7,%eax
c0105c68:	c1 e8 03             	shr    $0x3,%eax
c0105c6b:	89 c2                	mov    %eax,%edx
c0105c6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c70:	89 10                	mov    %edx,(%eax)

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
c0105c72:	e8 32 fc ff ff       	call   c01058a9 <__intr_save>
c0105c77:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0105c7a:	a1 e8 89 12 c0       	mov    0xc01289e8,%eax
c0105c7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c82:	eb 27                	jmp    c0105cab <slob_free+0x66>
		if (cur >= cur->next && (b > cur || b < cur->next))
c0105c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c87:	8b 40 04             	mov    0x4(%eax),%eax
c0105c8a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105c8d:	77 13                	ja     c0105ca2 <slob_free+0x5d>
c0105c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c92:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105c95:	77 27                	ja     c0105cbe <slob_free+0x79>
c0105c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c9a:	8b 40 04             	mov    0x4(%eax),%eax
c0105c9d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105ca0:	77 1c                	ja     c0105cbe <slob_free+0x79>
	if (size)
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
c0105ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ca5:	8b 40 04             	mov    0x4(%eax),%eax
c0105ca8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cae:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105cb1:	76 d1                	jbe    c0105c84 <slob_free+0x3f>
c0105cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cb6:	8b 40 04             	mov    0x4(%eax),%eax
c0105cb9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105cbc:	76 c6                	jbe    c0105c84 <slob_free+0x3f>
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;

	if (b + b->units == cur->next) {
c0105cbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cc1:	8b 00                	mov    (%eax),%eax
c0105cc3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0105cca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ccd:	01 c2                	add    %eax,%edx
c0105ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cd2:	8b 40 04             	mov    0x4(%eax),%eax
c0105cd5:	39 c2                	cmp    %eax,%edx
c0105cd7:	75 25                	jne    c0105cfe <slob_free+0xb9>
		b->units += cur->next->units;
c0105cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cdc:	8b 10                	mov    (%eax),%edx
c0105cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ce1:	8b 40 04             	mov    0x4(%eax),%eax
c0105ce4:	8b 00                	mov    (%eax),%eax
c0105ce6:	01 c2                	add    %eax,%edx
c0105ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ceb:	89 10                	mov    %edx,(%eax)
		b->next = cur->next->next;
c0105ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105cf0:	8b 40 04             	mov    0x4(%eax),%eax
c0105cf3:	8b 50 04             	mov    0x4(%eax),%edx
c0105cf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cf9:	89 50 04             	mov    %edx,0x4(%eax)
c0105cfc:	eb 0c                	jmp    c0105d0a <slob_free+0xc5>
	} else
		b->next = cur->next;
c0105cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d01:	8b 50 04             	mov    0x4(%eax),%edx
c0105d04:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d07:	89 50 04             	mov    %edx,0x4(%eax)

	if (cur + cur->units == b) {
c0105d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d0d:	8b 00                	mov    (%eax),%eax
c0105d0f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0105d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d19:	01 d0                	add    %edx,%eax
c0105d1b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0105d1e:	75 1f                	jne    c0105d3f <slob_free+0xfa>
		cur->units += b->units;
c0105d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d23:	8b 10                	mov    (%eax),%edx
c0105d25:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d28:	8b 00                	mov    (%eax),%eax
c0105d2a:	01 c2                	add    %eax,%edx
c0105d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d2f:	89 10                	mov    %edx,(%eax)
		cur->next = b->next;
c0105d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d34:	8b 50 04             	mov    0x4(%eax),%edx
c0105d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d3a:	89 50 04             	mov    %edx,0x4(%eax)
c0105d3d:	eb 09                	jmp    c0105d48 <slob_free+0x103>
	} else
		cur->next = b;
c0105d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d42:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105d45:	89 50 04             	mov    %edx,0x4(%eax)

	slobfree = cur;
c0105d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d4b:	a3 e8 89 12 c0       	mov    %eax,0xc01289e8

	spin_unlock_irqrestore(&slob_lock, flags);
c0105d50:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d53:	89 04 24             	mov    %eax,(%esp)
c0105d56:	e8 78 fb ff ff       	call   c01058d3 <__intr_restore>
}
c0105d5b:	c9                   	leave  
c0105d5c:	c3                   	ret    

c0105d5d <check_slab>:



void check_slab(void) {
c0105d5d:	55                   	push   %ebp
c0105d5e:	89 e5                	mov    %esp,%ebp
c0105d60:	83 ec 18             	sub    $0x18,%esp
  cprintf("check_slab() success\n");
c0105d63:	c7 04 24 3a c3 10 c0 	movl   $0xc010c33a,(%esp)
c0105d6a:	e8 73 ba ff ff       	call   c01017e2 <cprintf>
}
c0105d6f:	c9                   	leave  
c0105d70:	c3                   	ret    

c0105d71 <slab_init>:

void
slab_init(void) {
c0105d71:	55                   	push   %ebp
c0105d72:	89 e5                	mov    %esp,%ebp
c0105d74:	83 ec 18             	sub    $0x18,%esp
  cprintf("use SLOB allocator\n");
c0105d77:	c7 04 24 50 c3 10 c0 	movl   $0xc010c350,(%esp)
c0105d7e:	e8 5f ba ff ff       	call   c01017e2 <cprintf>
  check_slab();
c0105d83:	e8 d5 ff ff ff       	call   c0105d5d <check_slab>
}
c0105d88:	c9                   	leave  
c0105d89:	c3                   	ret    

c0105d8a <kmalloc_init>:

inline void 
kmalloc_init(void) {
c0105d8a:	55                   	push   %ebp
c0105d8b:	89 e5                	mov    %esp,%ebp
c0105d8d:	83 ec 18             	sub    $0x18,%esp
    slab_init();
c0105d90:	e8 dc ff ff ff       	call   c0105d71 <slab_init>
    cprintf("kmalloc_init() succeeded!\n");
c0105d95:	c7 04 24 64 c3 10 c0 	movl   $0xc010c364,(%esp)
c0105d9c:	e8 41 ba ff ff       	call   c01017e2 <cprintf>
}
c0105da1:	c9                   	leave  
c0105da2:	c3                   	ret    

c0105da3 <slab_allocated>:

size_t
slab_allocated(void) {
c0105da3:	55                   	push   %ebp
c0105da4:	89 e5                	mov    %esp,%ebp
  return 0;
c0105da6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105dab:	5d                   	pop    %ebp
c0105dac:	c3                   	ret    

c0105dad <kallocated>:

size_t
kallocated(void) {
c0105dad:	55                   	push   %ebp
c0105dae:	89 e5                	mov    %esp,%ebp
   return slab_allocated();
c0105db0:	e8 ee ff ff ff       	call   c0105da3 <slab_allocated>
}
c0105db5:	5d                   	pop    %ebp
c0105db6:	c3                   	ret    

c0105db7 <find_order>:

static int find_order(int size)
{
c0105db7:	55                   	push   %ebp
c0105db8:	89 e5                	mov    %esp,%ebp
c0105dba:	83 ec 10             	sub    $0x10,%esp
	int order = 0;
c0105dbd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for ( ; size > 4096 ; size >>=1)
c0105dc4:	eb 07                	jmp    c0105dcd <find_order+0x16>
		order++;
c0105dc6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
}

static int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)
c0105dca:	d1 7d 08             	sarl   0x8(%ebp)
c0105dcd:	81 7d 08 00 10 00 00 	cmpl   $0x1000,0x8(%ebp)
c0105dd4:	7f f0                	jg     c0105dc6 <find_order+0xf>
		order++;
	return order;
c0105dd6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105dd9:	c9                   	leave  
c0105dda:	c3                   	ret    

c0105ddb <__kmalloc>:

static void *__kmalloc(size_t size, gfp_t gfp)
{
c0105ddb:	55                   	push   %ebp
c0105ddc:	89 e5                	mov    %esp,%ebp
c0105dde:	83 ec 28             	sub    $0x28,%esp
	slob_t *m;
	bigblock_t *bb;
	unsigned long flags;

	if (size < PAGE_SIZE - SLOB_UNIT) {
c0105de1:	81 7d 08 f7 0f 00 00 	cmpl   $0xff7,0x8(%ebp)
c0105de8:	77 38                	ja     c0105e22 <__kmalloc+0x47>
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
c0105dea:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ded:	8d 50 08             	lea    0x8(%eax),%edx
c0105df0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105df7:	00 
c0105df8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dfb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105dff:	89 14 24             	mov    %edx,(%esp)
c0105e02:	e8 69 fc ff ff       	call   c0105a70 <slob_alloc>
c0105e07:	89 45 f4             	mov    %eax,-0xc(%ebp)
		return m ? (void *)(m + 1) : 0;
c0105e0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105e0e:	74 08                	je     c0105e18 <__kmalloc+0x3d>
c0105e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e13:	83 c0 08             	add    $0x8,%eax
c0105e16:	eb 05                	jmp    c0105e1d <__kmalloc+0x42>
c0105e18:	b8 00 00 00 00       	mov    $0x0,%eax
c0105e1d:	e9 a6 00 00 00       	jmp    c0105ec8 <__kmalloc+0xed>
	}

	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
c0105e22:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105e29:	00 
c0105e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e2d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e31:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
c0105e38:	e8 33 fc ff ff       	call   c0105a70 <slob_alloc>
c0105e3d:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (!bb)
c0105e40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105e44:	75 07                	jne    c0105e4d <__kmalloc+0x72>
		return 0;
c0105e46:	b8 00 00 00 00       	mov    $0x0,%eax
c0105e4b:	eb 7b                	jmp    c0105ec8 <__kmalloc+0xed>

	bb->order = find_order(size);
c0105e4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e50:	89 04 24             	mov    %eax,(%esp)
c0105e53:	e8 5f ff ff ff       	call   c0105db7 <find_order>
c0105e58:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105e5b:	89 02                	mov    %eax,(%edx)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
c0105e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e60:	8b 00                	mov    (%eax),%eax
c0105e62:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e66:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e69:	89 04 24             	mov    %eax,(%esp)
c0105e6c:	e8 92 fb ff ff       	call   c0105a03 <__slob_get_free_pages>
c0105e71:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105e74:	89 42 04             	mov    %eax,0x4(%edx)

	if (bb->pages) {
c0105e77:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e7a:	8b 40 04             	mov    0x4(%eax),%eax
c0105e7d:	85 c0                	test   %eax,%eax
c0105e7f:	74 2f                	je     c0105eb0 <__kmalloc+0xd5>
		spin_lock_irqsave(&block_lock, flags);
c0105e81:	e8 23 fa ff ff       	call   c01058a9 <__intr_save>
c0105e86:	89 45 ec             	mov    %eax,-0x14(%ebp)
		bb->next = bigblocks;
c0105e89:	8b 15 84 bf 12 c0    	mov    0xc012bf84,%edx
c0105e8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e92:	89 50 08             	mov    %edx,0x8(%eax)
		bigblocks = bb;
c0105e95:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e98:	a3 84 bf 12 c0       	mov    %eax,0xc012bf84
		spin_unlock_irqrestore(&block_lock, flags);
c0105e9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ea0:	89 04 24             	mov    %eax,(%esp)
c0105ea3:	e8 2b fa ff ff       	call   c01058d3 <__intr_restore>
		return bb->pages;
c0105ea8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105eab:	8b 40 04             	mov    0x4(%eax),%eax
c0105eae:	eb 18                	jmp    c0105ec8 <__kmalloc+0xed>
	}

	slob_free(bb, sizeof(bigblock_t));
c0105eb0:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0105eb7:	00 
c0105eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ebb:	89 04 24             	mov    %eax,(%esp)
c0105ebe:	e8 82 fd ff ff       	call   c0105c45 <slob_free>
	return 0;
c0105ec3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ec8:	c9                   	leave  
c0105ec9:	c3                   	ret    

c0105eca <kmalloc>:

void *
kmalloc(size_t size)
{
c0105eca:	55                   	push   %ebp
c0105ecb:	89 e5                	mov    %esp,%ebp
c0105ecd:	83 ec 18             	sub    $0x18,%esp
  return __kmalloc(size, 0);
c0105ed0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105ed7:	00 
c0105ed8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105edb:	89 04 24             	mov    %eax,(%esp)
c0105ede:	e8 f8 fe ff ff       	call   c0105ddb <__kmalloc>
}
c0105ee3:	c9                   	leave  
c0105ee4:	c3                   	ret    

c0105ee5 <kfree>:


void kfree(void *block)
{
c0105ee5:	55                   	push   %ebp
c0105ee6:	89 e5                	mov    %esp,%ebp
c0105ee8:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb, **last = &bigblocks;
c0105eeb:	c7 45 f0 84 bf 12 c0 	movl   $0xc012bf84,-0x10(%ebp)
	unsigned long flags;

	if (!block)
c0105ef2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105ef6:	75 05                	jne    c0105efd <kfree+0x18>
		return;
c0105ef8:	e9 a2 00 00 00       	jmp    c0105f9f <kfree+0xba>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0105efd:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f00:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105f05:	85 c0                	test   %eax,%eax
c0105f07:	75 7f                	jne    c0105f88 <kfree+0xa3>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
c0105f09:	e8 9b f9 ff ff       	call   c01058a9 <__intr_save>
c0105f0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0105f11:	a1 84 bf 12 c0       	mov    0xc012bf84,%eax
c0105f16:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105f19:	eb 5c                	jmp    c0105f77 <kfree+0x92>
			if (bb->pages == block) {
c0105f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f1e:	8b 40 04             	mov    0x4(%eax),%eax
c0105f21:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105f24:	75 3f                	jne    c0105f65 <kfree+0x80>
				*last = bb->next;
c0105f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f29:	8b 50 08             	mov    0x8(%eax),%edx
c0105f2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f2f:	89 10                	mov    %edx,(%eax)
				spin_unlock_irqrestore(&block_lock, flags);
c0105f31:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f34:	89 04 24             	mov    %eax,(%esp)
c0105f37:	e8 97 f9 ff ff       	call   c01058d3 <__intr_restore>
				__slob_free_pages((unsigned long)block, bb->order);
c0105f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f3f:	8b 10                	mov    (%eax),%edx
c0105f41:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f44:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105f48:	89 04 24             	mov    %eax,(%esp)
c0105f4b:	e8 ec fa ff ff       	call   c0105a3c <__slob_free_pages>
				slob_free(bb, sizeof(bigblock_t));
c0105f50:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
c0105f57:	00 
c0105f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f5b:	89 04 24             	mov    %eax,(%esp)
c0105f5e:	e8 e2 fc ff ff       	call   c0105c45 <slob_free>
				return;
c0105f63:	eb 3a                	jmp    c0105f9f <kfree+0xba>
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
c0105f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f68:	83 c0 08             	add    $0x8,%eax
c0105f6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105f71:	8b 40 08             	mov    0x8(%eax),%eax
c0105f74:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105f77:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105f7b:	75 9e                	jne    c0105f1b <kfree+0x36>
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
		}
		spin_unlock_irqrestore(&block_lock, flags);
c0105f7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105f80:	89 04 24             	mov    %eax,(%esp)
c0105f83:	e8 4b f9 ff ff       	call   c01058d3 <__intr_restore>
	}

	slob_free((slob_t *)block - 1, 0);
c0105f88:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f8b:	83 e8 08             	sub    $0x8,%eax
c0105f8e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105f95:	00 
c0105f96:	89 04 24             	mov    %eax,(%esp)
c0105f99:	e8 a7 fc ff ff       	call   c0105c45 <slob_free>
	return;
c0105f9e:	90                   	nop
}
c0105f9f:	c9                   	leave  
c0105fa0:	c3                   	ret    

c0105fa1 <ksize>:


unsigned int ksize(const void *block)
{
c0105fa1:	55                   	push   %ebp
c0105fa2:	89 e5                	mov    %esp,%ebp
c0105fa4:	83 ec 28             	sub    $0x28,%esp
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
c0105fa7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105fab:	75 07                	jne    c0105fb4 <ksize+0x13>
		return 0;
c0105fad:	b8 00 00 00 00       	mov    $0x0,%eax
c0105fb2:	eb 6b                	jmp    c010601f <ksize+0x7e>

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
c0105fb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fb7:	25 ff 0f 00 00       	and    $0xfff,%eax
c0105fbc:	85 c0                	test   %eax,%eax
c0105fbe:	75 54                	jne    c0106014 <ksize+0x73>
		spin_lock_irqsave(&block_lock, flags);
c0105fc0:	e8 e4 f8 ff ff       	call   c01058a9 <__intr_save>
c0105fc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for (bb = bigblocks; bb; bb = bb->next)
c0105fc8:	a1 84 bf 12 c0       	mov    0xc012bf84,%eax
c0105fcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105fd0:	eb 31                	jmp    c0106003 <ksize+0x62>
			if (bb->pages == block) {
c0105fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fd5:	8b 40 04             	mov    0x4(%eax),%eax
c0105fd8:	3b 45 08             	cmp    0x8(%ebp),%eax
c0105fdb:	75 1d                	jne    c0105ffa <ksize+0x59>
				spin_unlock_irqrestore(&slob_lock, flags);
c0105fdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fe0:	89 04 24             	mov    %eax,(%esp)
c0105fe3:	e8 eb f8 ff ff       	call   c01058d3 <__intr_restore>
				return PAGE_SIZE << bb->order;
c0105fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105feb:	8b 00                	mov    (%eax),%eax
c0105fed:	ba 00 10 00 00       	mov    $0x1000,%edx
c0105ff2:	89 c1                	mov    %eax,%ecx
c0105ff4:	d3 e2                	shl    %cl,%edx
c0105ff6:	89 d0                	mov    %edx,%eax
c0105ff8:	eb 25                	jmp    c010601f <ksize+0x7e>
	if (!block)
		return 0;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; bb = bb->next)
c0105ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ffd:	8b 40 08             	mov    0x8(%eax),%eax
c0106000:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106003:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106007:	75 c9                	jne    c0105fd2 <ksize+0x31>
			if (bb->pages == block) {
				spin_unlock_irqrestore(&slob_lock, flags);
				return PAGE_SIZE << bb->order;
			}
		spin_unlock_irqrestore(&block_lock, flags);
c0106009:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010600c:	89 04 24             	mov    %eax,(%esp)
c010600f:	e8 bf f8 ff ff       	call   c01058d3 <__intr_restore>
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;
c0106014:	8b 45 08             	mov    0x8(%ebp),%eax
c0106017:	83 e8 08             	sub    $0x8,%eax
c010601a:	8b 00                	mov    (%eax),%eax
c010601c:	c1 e0 03             	shl    $0x3,%eax
}
c010601f:	c9                   	leave  
c0106020:	c3                   	ret    

c0106021 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0106021:	55                   	push   %ebp
c0106022:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0106024:	8b 55 08             	mov    0x8(%ebp),%edx
c0106027:	a1 8c e0 12 c0       	mov    0xc012e08c,%eax
c010602c:	29 c2                	sub    %eax,%edx
c010602e:	89 d0                	mov    %edx,%eax
c0106030:	c1 f8 02             	sar    $0x2,%eax
c0106033:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0106039:	5d                   	pop    %ebp
c010603a:	c3                   	ret    

c010603b <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010603b:	55                   	push   %ebp
c010603c:	89 e5                	mov    %esp,%ebp
c010603e:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0106041:	8b 45 08             	mov    0x8(%ebp),%eax
c0106044:	89 04 24             	mov    %eax,(%esp)
c0106047:	e8 d5 ff ff ff       	call   c0106021 <page2ppn>
c010604c:	c1 e0 0c             	shl    $0xc,%eax
}
c010604f:	c9                   	leave  
c0106050:	c3                   	ret    

c0106051 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0106051:	55                   	push   %ebp
c0106052:	89 e5                	mov    %esp,%ebp
c0106054:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0106057:	8b 45 08             	mov    0x8(%ebp),%eax
c010605a:	c1 e8 0c             	shr    $0xc,%eax
c010605d:	89 c2                	mov    %eax,%edx
c010605f:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c0106064:	39 c2                	cmp    %eax,%edx
c0106066:	72 1c                	jb     c0106084 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0106068:	c7 44 24 08 80 c3 10 	movl   $0xc010c380,0x8(%esp)
c010606f:	c0 
c0106070:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0106077:	00 
c0106078:	c7 04 24 9f c3 10 c0 	movl   $0xc010c39f,(%esp)
c010607f:	e8 e8 c0 ff ff       	call   c010216c <__panic>
    }
    return &pages[PPN(pa)];
c0106084:	8b 0d 8c e0 12 c0    	mov    0xc012e08c,%ecx
c010608a:	8b 45 08             	mov    0x8(%ebp),%eax
c010608d:	c1 e8 0c             	shr    $0xc,%eax
c0106090:	89 c2                	mov    %eax,%edx
c0106092:	89 d0                	mov    %edx,%eax
c0106094:	c1 e0 03             	shl    $0x3,%eax
c0106097:	01 d0                	add    %edx,%eax
c0106099:	c1 e0 02             	shl    $0x2,%eax
c010609c:	01 c8                	add    %ecx,%eax
}
c010609e:	c9                   	leave  
c010609f:	c3                   	ret    

c01060a0 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01060a0:	55                   	push   %ebp
c01060a1:	89 e5                	mov    %esp,%ebp
c01060a3:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01060a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01060a9:	89 04 24             	mov    %eax,(%esp)
c01060ac:	e8 8a ff ff ff       	call   c010603b <page2pa>
c01060b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01060b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060b7:	c1 e8 0c             	shr    $0xc,%eax
c01060ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01060bd:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c01060c2:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01060c5:	72 23                	jb     c01060ea <page2kva+0x4a>
c01060c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01060ce:	c7 44 24 08 b0 c3 10 	movl   $0xc010c3b0,0x8(%esp)
c01060d5:	c0 
c01060d6:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c01060dd:	00 
c01060de:	c7 04 24 9f c3 10 c0 	movl   $0xc010c39f,(%esp)
c01060e5:	e8 82 c0 ff ff       	call   c010216c <__panic>
c01060ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01060ed:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01060f2:	c9                   	leave  
c01060f3:	c3                   	ret    

c01060f4 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c01060f4:	55                   	push   %ebp
c01060f5:	89 e5                	mov    %esp,%ebp
c01060f7:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01060fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01060fd:	83 e0 01             	and    $0x1,%eax
c0106100:	85 c0                	test   %eax,%eax
c0106102:	75 1c                	jne    c0106120 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0106104:	c7 44 24 08 d4 c3 10 	movl   $0xc010c3d4,0x8(%esp)
c010610b:	c0 
c010610c:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0106113:	00 
c0106114:	c7 04 24 9f c3 10 c0 	movl   $0xc010c39f,(%esp)
c010611b:	e8 4c c0 ff ff       	call   c010216c <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0106120:	8b 45 08             	mov    0x8(%ebp),%eax
c0106123:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106128:	89 04 24             	mov    %eax,(%esp)
c010612b:	e8 21 ff ff ff       	call   c0106051 <pa2page>
}
c0106130:	c9                   	leave  
c0106131:	c3                   	ret    

c0106132 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0106132:	55                   	push   %ebp
c0106133:	89 e5                	mov    %esp,%ebp
c0106135:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0106138:	8b 45 08             	mov    0x8(%ebp),%eax
c010613b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106140:	89 04 24             	mov    %eax,(%esp)
c0106143:	e8 09 ff ff ff       	call   c0106051 <pa2page>
}
c0106148:	c9                   	leave  
c0106149:	c3                   	ret    

c010614a <page_ref>:

static inline int
page_ref(struct Page *page) {
c010614a:	55                   	push   %ebp
c010614b:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010614d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106150:	8b 00                	mov    (%eax),%eax
}
c0106152:	5d                   	pop    %ebp
c0106153:	c3                   	ret    

c0106154 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0106154:	55                   	push   %ebp
c0106155:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0106157:	8b 45 08             	mov    0x8(%ebp),%eax
c010615a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010615d:	89 10                	mov    %edx,(%eax)
}
c010615f:	5d                   	pop    %ebp
c0106160:	c3                   	ret    

c0106161 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0106161:	55                   	push   %ebp
c0106162:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0106164:	8b 45 08             	mov    0x8(%ebp),%eax
c0106167:	8b 00                	mov    (%eax),%eax
c0106169:	8d 50 01             	lea    0x1(%eax),%edx
c010616c:	8b 45 08             	mov    0x8(%ebp),%eax
c010616f:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0106171:	8b 45 08             	mov    0x8(%ebp),%eax
c0106174:	8b 00                	mov    (%eax),%eax
}
c0106176:	5d                   	pop    %ebp
c0106177:	c3                   	ret    

c0106178 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0106178:	55                   	push   %ebp
c0106179:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c010617b:	8b 45 08             	mov    0x8(%ebp),%eax
c010617e:	8b 00                	mov    (%eax),%eax
c0106180:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106183:	8b 45 08             	mov    0x8(%ebp),%eax
c0106186:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0106188:	8b 45 08             	mov    0x8(%ebp),%eax
c010618b:	8b 00                	mov    (%eax),%eax
}
c010618d:	5d                   	pop    %ebp
c010618e:	c3                   	ret    

c010618f <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c010618f:	55                   	push   %ebp
c0106190:	89 e5                	mov    %esp,%ebp
c0106192:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0106195:	9c                   	pushf  
c0106196:	58                   	pop    %eax
c0106197:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010619a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010619d:	25 00 02 00 00       	and    $0x200,%eax
c01061a2:	85 c0                	test   %eax,%eax
c01061a4:	74 0c                	je     c01061b2 <__intr_save+0x23>
        intr_disable();
c01061a6:	e8 2a d2 ff ff       	call   c01033d5 <intr_disable>
        return 1;
c01061ab:	b8 01 00 00 00       	mov    $0x1,%eax
c01061b0:	eb 05                	jmp    c01061b7 <__intr_save+0x28>
    }
    return 0;
c01061b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01061b7:	c9                   	leave  
c01061b8:	c3                   	ret    

c01061b9 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01061b9:	55                   	push   %ebp
c01061ba:	89 e5                	mov    %esp,%ebp
c01061bc:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01061bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01061c3:	74 05                	je     c01061ca <__intr_restore+0x11>
        intr_enable();
c01061c5:	e8 05 d2 ff ff       	call   c01033cf <intr_enable>
    }
}
c01061ca:	c9                   	leave  
c01061cb:	c3                   	ret    

c01061cc <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01061cc:	55                   	push   %ebp
c01061cd:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01061cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01061d2:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01061d5:	b8 23 00 00 00       	mov    $0x23,%eax
c01061da:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01061dc:	b8 23 00 00 00       	mov    $0x23,%eax
c01061e1:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c01061e3:	b8 10 00 00 00       	mov    $0x10,%eax
c01061e8:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c01061ea:	b8 10 00 00 00       	mov    $0x10,%eax
c01061ef:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c01061f1:	b8 10 00 00 00       	mov    $0x10,%eax
c01061f6:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c01061f8:	ea ff 61 10 c0 08 00 	ljmp   $0x8,$0xc01061ff
}
c01061ff:	5d                   	pop    %ebp
c0106200:	c3                   	ret    

c0106201 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0106201:	55                   	push   %ebp
c0106202:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0106204:	8b 45 08             	mov    0x8(%ebp),%eax
c0106207:	a3 c4 bf 12 c0       	mov    %eax,0xc012bfc4
}
c010620c:	5d                   	pop    %ebp
c010620d:	c3                   	ret    

c010620e <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c010620e:	55                   	push   %ebp
c010620f:	89 e5                	mov    %esp,%ebp
c0106211:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0106214:	b8 00 80 12 c0       	mov    $0xc0128000,%eax
c0106219:	89 04 24             	mov    %eax,(%esp)
c010621c:	e8 e0 ff ff ff       	call   c0106201 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0106221:	66 c7 05 c8 bf 12 c0 	movw   $0x10,0xc012bfc8
c0106228:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c010622a:	66 c7 05 48 8a 12 c0 	movw   $0x68,0xc0128a48
c0106231:	68 00 
c0106233:	b8 c0 bf 12 c0       	mov    $0xc012bfc0,%eax
c0106238:	66 a3 4a 8a 12 c0    	mov    %ax,0xc0128a4a
c010623e:	b8 c0 bf 12 c0       	mov    $0xc012bfc0,%eax
c0106243:	c1 e8 10             	shr    $0x10,%eax
c0106246:	a2 4c 8a 12 c0       	mov    %al,0xc0128a4c
c010624b:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c0106252:	83 e0 f0             	and    $0xfffffff0,%eax
c0106255:	83 c8 09             	or     $0x9,%eax
c0106258:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c010625d:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c0106264:	83 e0 ef             	and    $0xffffffef,%eax
c0106267:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c010626c:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c0106273:	83 e0 9f             	and    $0xffffff9f,%eax
c0106276:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c010627b:	0f b6 05 4d 8a 12 c0 	movzbl 0xc0128a4d,%eax
c0106282:	83 c8 80             	or     $0xffffff80,%eax
c0106285:	a2 4d 8a 12 c0       	mov    %al,0xc0128a4d
c010628a:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c0106291:	83 e0 f0             	and    $0xfffffff0,%eax
c0106294:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c0106299:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c01062a0:	83 e0 ef             	and    $0xffffffef,%eax
c01062a3:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c01062a8:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c01062af:	83 e0 df             	and    $0xffffffdf,%eax
c01062b2:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c01062b7:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c01062be:	83 c8 40             	or     $0x40,%eax
c01062c1:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c01062c6:	0f b6 05 4e 8a 12 c0 	movzbl 0xc0128a4e,%eax
c01062cd:	83 e0 7f             	and    $0x7f,%eax
c01062d0:	a2 4e 8a 12 c0       	mov    %al,0xc0128a4e
c01062d5:	b8 c0 bf 12 c0       	mov    $0xc012bfc0,%eax
c01062da:	c1 e8 18             	shr    $0x18,%eax
c01062dd:	a2 4f 8a 12 c0       	mov    %al,0xc0128a4f

    // reload all segment registers
    lgdt(&gdt_pd);
c01062e2:	c7 04 24 50 8a 12 c0 	movl   $0xc0128a50,(%esp)
c01062e9:	e8 de fe ff ff       	call   c01061cc <lgdt>
c01062ee:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c01062f4:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01062f8:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c01062fb:	c9                   	leave  
c01062fc:	c3                   	ret    

c01062fd <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c01062fd:	55                   	push   %ebp
c01062fe:	89 e5                	mov    %esp,%ebp
c0106300:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0106303:	c7 05 84 e0 12 c0 60 	movl   $0xc010c260,0xc012e084
c010630a:	c2 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c010630d:	a1 84 e0 12 c0       	mov    0xc012e084,%eax
c0106312:	8b 00                	mov    (%eax),%eax
c0106314:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106318:	c7 04 24 00 c4 10 c0 	movl   $0xc010c400,(%esp)
c010631f:	e8 be b4 ff ff       	call   c01017e2 <cprintf>
    pmm_manager->init();
c0106324:	a1 84 e0 12 c0       	mov    0xc012e084,%eax
c0106329:	8b 40 04             	mov    0x4(%eax),%eax
c010632c:	ff d0                	call   *%eax
}
c010632e:	c9                   	leave  
c010632f:	c3                   	ret    

c0106330 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0106330:	55                   	push   %ebp
c0106331:	89 e5                	mov    %esp,%ebp
c0106333:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0106336:	a1 84 e0 12 c0       	mov    0xc012e084,%eax
c010633b:	8b 40 08             	mov    0x8(%eax),%eax
c010633e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106341:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106345:	8b 55 08             	mov    0x8(%ebp),%edx
c0106348:	89 14 24             	mov    %edx,(%esp)
c010634b:	ff d0                	call   *%eax
}
c010634d:	c9                   	leave  
c010634e:	c3                   	ret    

c010634f <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c010634f:	55                   	push   %ebp
c0106350:	89 e5                	mov    %esp,%ebp
c0106352:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0106355:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c010635c:	e8 2e fe ff ff       	call   c010618f <__intr_save>
c0106361:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0106364:	a1 84 e0 12 c0       	mov    0xc012e084,%eax
c0106369:	8b 40 0c             	mov    0xc(%eax),%eax
c010636c:	8b 55 08             	mov    0x8(%ebp),%edx
c010636f:	89 14 24             	mov    %edx,(%esp)
c0106372:	ff d0                	call   *%eax
c0106374:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0106377:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010637a:	89 04 24             	mov    %eax,(%esp)
c010637d:	e8 37 fe ff ff       	call   c01061b9 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0106382:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106386:	75 2d                	jne    c01063b5 <alloc_pages+0x66>
c0106388:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c010638c:	77 27                	ja     c01063b5 <alloc_pages+0x66>
c010638e:	a1 2c c0 12 c0       	mov    0xc012c02c,%eax
c0106393:	85 c0                	test   %eax,%eax
c0106395:	74 1e                	je     c01063b5 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0106397:	8b 55 08             	mov    0x8(%ebp),%edx
c010639a:	a1 6c e1 12 c0       	mov    0xc012e16c,%eax
c010639f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01063a6:	00 
c01063a7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01063ab:	89 04 24             	mov    %eax,(%esp)
c01063ae:	e8 f4 18 00 00       	call   c0107ca7 <swap_out>
    }
c01063b3:	eb a7                	jmp    c010635c <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c01063b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01063b8:	c9                   	leave  
c01063b9:	c3                   	ret    

c01063ba <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c01063ba:	55                   	push   %ebp
c01063bb:	89 e5                	mov    %esp,%ebp
c01063bd:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01063c0:	e8 ca fd ff ff       	call   c010618f <__intr_save>
c01063c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01063c8:	a1 84 e0 12 c0       	mov    0xc012e084,%eax
c01063cd:	8b 40 10             	mov    0x10(%eax),%eax
c01063d0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01063d3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01063d7:	8b 55 08             	mov    0x8(%ebp),%edx
c01063da:	89 14 24             	mov    %edx,(%esp)
c01063dd:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c01063df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01063e2:	89 04 24             	mov    %eax,(%esp)
c01063e5:	e8 cf fd ff ff       	call   c01061b9 <__intr_restore>
}
c01063ea:	c9                   	leave  
c01063eb:	c3                   	ret    

c01063ec <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c01063ec:	55                   	push   %ebp
c01063ed:	89 e5                	mov    %esp,%ebp
c01063ef:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01063f2:	e8 98 fd ff ff       	call   c010618f <__intr_save>
c01063f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01063fa:	a1 84 e0 12 c0       	mov    0xc012e084,%eax
c01063ff:	8b 40 14             	mov    0x14(%eax),%eax
c0106402:	ff d0                	call   *%eax
c0106404:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0106407:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010640a:	89 04 24             	mov    %eax,(%esp)
c010640d:	e8 a7 fd ff ff       	call   c01061b9 <__intr_restore>
    return ret;
c0106412:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0106415:	c9                   	leave  
c0106416:	c3                   	ret    

c0106417 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0106417:	55                   	push   %ebp
c0106418:	89 e5                	mov    %esp,%ebp
c010641a:	57                   	push   %edi
c010641b:	56                   	push   %esi
c010641c:	53                   	push   %ebx
c010641d:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0106423:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c010642a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0106431:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0106438:	c7 04 24 17 c4 10 c0 	movl   $0xc010c417,(%esp)
c010643f:	e8 9e b3 ff ff       	call   c01017e2 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0106444:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010644b:	e9 15 01 00 00       	jmp    c0106565 <page_init+0x14e>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0106450:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106453:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106456:	89 d0                	mov    %edx,%eax
c0106458:	c1 e0 02             	shl    $0x2,%eax
c010645b:	01 d0                	add    %edx,%eax
c010645d:	c1 e0 02             	shl    $0x2,%eax
c0106460:	01 c8                	add    %ecx,%eax
c0106462:	8b 50 08             	mov    0x8(%eax),%edx
c0106465:	8b 40 04             	mov    0x4(%eax),%eax
c0106468:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010646b:	89 55 bc             	mov    %edx,-0x44(%ebp)
c010646e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106471:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106474:	89 d0                	mov    %edx,%eax
c0106476:	c1 e0 02             	shl    $0x2,%eax
c0106479:	01 d0                	add    %edx,%eax
c010647b:	c1 e0 02             	shl    $0x2,%eax
c010647e:	01 c8                	add    %ecx,%eax
c0106480:	8b 48 0c             	mov    0xc(%eax),%ecx
c0106483:	8b 58 10             	mov    0x10(%eax),%ebx
c0106486:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106489:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010648c:	01 c8                	add    %ecx,%eax
c010648e:	11 da                	adc    %ebx,%edx
c0106490:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0106493:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0106496:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106499:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010649c:	89 d0                	mov    %edx,%eax
c010649e:	c1 e0 02             	shl    $0x2,%eax
c01064a1:	01 d0                	add    %edx,%eax
c01064a3:	c1 e0 02             	shl    $0x2,%eax
c01064a6:	01 c8                	add    %ecx,%eax
c01064a8:	83 c0 14             	add    $0x14,%eax
c01064ab:	8b 00                	mov    (%eax),%eax
c01064ad:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c01064b3:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01064b6:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c01064b9:	83 c0 ff             	add    $0xffffffff,%eax
c01064bc:	83 d2 ff             	adc    $0xffffffff,%edx
c01064bf:	89 c6                	mov    %eax,%esi
c01064c1:	89 d7                	mov    %edx,%edi
c01064c3:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01064c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01064c9:	89 d0                	mov    %edx,%eax
c01064cb:	c1 e0 02             	shl    $0x2,%eax
c01064ce:	01 d0                	add    %edx,%eax
c01064d0:	c1 e0 02             	shl    $0x2,%eax
c01064d3:	01 c8                	add    %ecx,%eax
c01064d5:	8b 48 0c             	mov    0xc(%eax),%ecx
c01064d8:	8b 58 10             	mov    0x10(%eax),%ebx
c01064db:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c01064e1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c01064e5:	89 74 24 14          	mov    %esi,0x14(%esp)
c01064e9:	89 7c 24 18          	mov    %edi,0x18(%esp)
c01064ed:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01064f0:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01064f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01064f7:	89 54 24 10          	mov    %edx,0x10(%esp)
c01064fb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01064ff:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0106503:	c7 04 24 24 c4 10 c0 	movl   $0xc010c424,(%esp)
c010650a:	e8 d3 b2 ff ff       	call   c01017e2 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c010650f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0106512:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106515:	89 d0                	mov    %edx,%eax
c0106517:	c1 e0 02             	shl    $0x2,%eax
c010651a:	01 d0                	add    %edx,%eax
c010651c:	c1 e0 02             	shl    $0x2,%eax
c010651f:	01 c8                	add    %ecx,%eax
c0106521:	83 c0 14             	add    $0x14,%eax
c0106524:	8b 00                	mov    (%eax),%eax
c0106526:	83 f8 01             	cmp    $0x1,%eax
c0106529:	75 36                	jne    c0106561 <page_init+0x14a>
            if (maxpa < end && begin < KMEMSIZE) {
c010652b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010652e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106531:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0106534:	77 2b                	ja     c0106561 <page_init+0x14a>
c0106536:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0106539:	72 05                	jb     c0106540 <page_init+0x129>
c010653b:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c010653e:	73 21                	jae    c0106561 <page_init+0x14a>
c0106540:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0106544:	77 1b                	ja     c0106561 <page_init+0x14a>
c0106546:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010654a:	72 09                	jb     c0106555 <page_init+0x13e>
c010654c:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0106553:	77 0c                	ja     c0106561 <page_init+0x14a>
                maxpa = end;
c0106555:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0106558:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c010655b:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010655e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0106561:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0106565:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106568:	8b 00                	mov    (%eax),%eax
c010656a:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010656d:	0f 8f dd fe ff ff    	jg     c0106450 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0106573:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106577:	72 1d                	jb     c0106596 <page_init+0x17f>
c0106579:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010657d:	77 09                	ja     c0106588 <page_init+0x171>
c010657f:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0106586:	76 0e                	jbe    c0106596 <page_init+0x17f>
        maxpa = KMEMSIZE;
c0106588:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c010658f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0106596:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106599:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010659c:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01065a0:	c1 ea 0c             	shr    $0xc,%edx
c01065a3:	a3 a0 bf 12 c0       	mov    %eax,0xc012bfa0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c01065a8:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c01065af:	b8 78 e1 12 c0       	mov    $0xc012e178,%eax
c01065b4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01065b7:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01065ba:	01 d0                	add    %edx,%eax
c01065bc:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01065bf:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01065c2:	ba 00 00 00 00       	mov    $0x0,%edx
c01065c7:	f7 75 ac             	divl   -0x54(%ebp)
c01065ca:	89 d0                	mov    %edx,%eax
c01065cc:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01065cf:	29 c2                	sub    %eax,%edx
c01065d1:	89 d0                	mov    %edx,%eax
c01065d3:	a3 8c e0 12 c0       	mov    %eax,0xc012e08c

    for (i = 0; i < npage; i ++) {
c01065d8:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01065df:	eb 2f                	jmp    c0106610 <page_init+0x1f9>
        SetPageReserved(pages + i);
c01065e1:	8b 0d 8c e0 12 c0    	mov    0xc012e08c,%ecx
c01065e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01065ea:	89 d0                	mov    %edx,%eax
c01065ec:	c1 e0 03             	shl    $0x3,%eax
c01065ef:	01 d0                	add    %edx,%eax
c01065f1:	c1 e0 02             	shl    $0x2,%eax
c01065f4:	01 c8                	add    %ecx,%eax
c01065f6:	83 c0 04             	add    $0x4,%eax
c01065f9:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0106600:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106603:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0106606:	8b 55 90             	mov    -0x70(%ebp),%edx
c0106609:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c010660c:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c0106610:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106613:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c0106618:	39 c2                	cmp    %eax,%edx
c010661a:	72 c5                	jb     c01065e1 <page_init+0x1ca>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c010661c:	8b 15 a0 bf 12 c0    	mov    0xc012bfa0,%edx
c0106622:	89 d0                	mov    %edx,%eax
c0106624:	c1 e0 03             	shl    $0x3,%eax
c0106627:	01 d0                	add    %edx,%eax
c0106629:	c1 e0 02             	shl    $0x2,%eax
c010662c:	89 c2                	mov    %eax,%edx
c010662e:	a1 8c e0 12 c0       	mov    0xc012e08c,%eax
c0106633:	01 d0                	add    %edx,%eax
c0106635:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0106638:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c010663f:	77 23                	ja     c0106664 <page_init+0x24d>
c0106641:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106644:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106648:	c7 44 24 08 54 c4 10 	movl   $0xc010c454,0x8(%esp)
c010664f:	c0 
c0106650:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0106657:	00 
c0106658:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c010665f:	e8 08 bb ff ff       	call   c010216c <__panic>
c0106664:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106667:	05 00 00 00 40       	add    $0x40000000,%eax
c010666c:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c010666f:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0106676:	e9 74 01 00 00       	jmp    c01067ef <page_init+0x3d8>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010667b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010667e:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106681:	89 d0                	mov    %edx,%eax
c0106683:	c1 e0 02             	shl    $0x2,%eax
c0106686:	01 d0                	add    %edx,%eax
c0106688:	c1 e0 02             	shl    $0x2,%eax
c010668b:	01 c8                	add    %ecx,%eax
c010668d:	8b 50 08             	mov    0x8(%eax),%edx
c0106690:	8b 40 04             	mov    0x4(%eax),%eax
c0106693:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106696:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106699:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010669c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010669f:	89 d0                	mov    %edx,%eax
c01066a1:	c1 e0 02             	shl    $0x2,%eax
c01066a4:	01 d0                	add    %edx,%eax
c01066a6:	c1 e0 02             	shl    $0x2,%eax
c01066a9:	01 c8                	add    %ecx,%eax
c01066ab:	8b 48 0c             	mov    0xc(%eax),%ecx
c01066ae:	8b 58 10             	mov    0x10(%eax),%ebx
c01066b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01066b4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01066b7:	01 c8                	add    %ecx,%eax
c01066b9:	11 da                	adc    %ebx,%edx
c01066bb:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01066be:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01066c1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01066c4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01066c7:	89 d0                	mov    %edx,%eax
c01066c9:	c1 e0 02             	shl    $0x2,%eax
c01066cc:	01 d0                	add    %edx,%eax
c01066ce:	c1 e0 02             	shl    $0x2,%eax
c01066d1:	01 c8                	add    %ecx,%eax
c01066d3:	83 c0 14             	add    $0x14,%eax
c01066d6:	8b 00                	mov    (%eax),%eax
c01066d8:	83 f8 01             	cmp    $0x1,%eax
c01066db:	0f 85 0a 01 00 00    	jne    c01067eb <page_init+0x3d4>
            if (begin < freemem) {
c01066e1:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01066e4:	ba 00 00 00 00       	mov    $0x0,%edx
c01066e9:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01066ec:	72 17                	jb     c0106705 <page_init+0x2ee>
c01066ee:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01066f1:	77 05                	ja     c01066f8 <page_init+0x2e1>
c01066f3:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01066f6:	76 0d                	jbe    c0106705 <page_init+0x2ee>
                begin = freemem;
c01066f8:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01066fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01066fe:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0106705:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0106709:	72 1d                	jb     c0106728 <page_init+0x311>
c010670b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010670f:	77 09                	ja     c010671a <page_init+0x303>
c0106711:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0106718:	76 0e                	jbe    c0106728 <page_init+0x311>
                end = KMEMSIZE;
c010671a:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0106721:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0106728:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010672b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010672e:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0106731:	0f 87 b4 00 00 00    	ja     c01067eb <page_init+0x3d4>
c0106737:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010673a:	72 09                	jb     c0106745 <page_init+0x32e>
c010673c:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010673f:	0f 83 a6 00 00 00    	jae    c01067eb <page_init+0x3d4>
                begin = ROUNDUP(begin, PGSIZE);
c0106745:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c010674c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010674f:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0106752:	01 d0                	add    %edx,%eax
c0106754:	83 e8 01             	sub    $0x1,%eax
c0106757:	89 45 98             	mov    %eax,-0x68(%ebp)
c010675a:	8b 45 98             	mov    -0x68(%ebp),%eax
c010675d:	ba 00 00 00 00       	mov    $0x0,%edx
c0106762:	f7 75 9c             	divl   -0x64(%ebp)
c0106765:	89 d0                	mov    %edx,%eax
c0106767:	8b 55 98             	mov    -0x68(%ebp),%edx
c010676a:	29 c2                	sub    %eax,%edx
c010676c:	89 d0                	mov    %edx,%eax
c010676e:	ba 00 00 00 00       	mov    $0x0,%edx
c0106773:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0106776:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0106779:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010677c:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010677f:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0106782:	ba 00 00 00 00       	mov    $0x0,%edx
c0106787:	89 c7                	mov    %eax,%edi
c0106789:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c010678f:	89 7d 80             	mov    %edi,-0x80(%ebp)
c0106792:	89 d0                	mov    %edx,%eax
c0106794:	83 e0 00             	and    $0x0,%eax
c0106797:	89 45 84             	mov    %eax,-0x7c(%ebp)
c010679a:	8b 45 80             	mov    -0x80(%ebp),%eax
c010679d:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01067a0:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01067a3:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c01067a6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01067a9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01067ac:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01067af:	77 3a                	ja     c01067eb <page_init+0x3d4>
c01067b1:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c01067b4:	72 05                	jb     c01067bb <page_init+0x3a4>
c01067b6:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01067b9:	73 30                	jae    c01067eb <page_init+0x3d4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01067bb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01067be:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
c01067c1:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01067c4:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01067c7:	29 c8                	sub    %ecx,%eax
c01067c9:	19 da                	sbb    %ebx,%edx
c01067cb:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01067cf:	c1 ea 0c             	shr    $0xc,%edx
c01067d2:	89 c3                	mov    %eax,%ebx
c01067d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01067d7:	89 04 24             	mov    %eax,(%esp)
c01067da:	e8 72 f8 ff ff       	call   c0106051 <pa2page>
c01067df:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01067e3:	89 04 24             	mov    %eax,(%esp)
c01067e6:	e8 45 fb ff ff       	call   c0106330 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c01067eb:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
c01067ef:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01067f2:	8b 00                	mov    (%eax),%eax
c01067f4:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01067f7:	0f 8f 7e fe ff ff    	jg     c010667b <page_init+0x264>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c01067fd:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0106803:	5b                   	pop    %ebx
c0106804:	5e                   	pop    %esi
c0106805:	5f                   	pop    %edi
c0106806:	5d                   	pop    %ebp
c0106807:	c3                   	ret    

c0106808 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0106808:	55                   	push   %ebp
c0106809:	89 e5                	mov    %esp,%ebp
c010680b:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c010680e:	8b 45 14             	mov    0x14(%ebp),%eax
c0106811:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106814:	31 d0                	xor    %edx,%eax
c0106816:	25 ff 0f 00 00       	and    $0xfff,%eax
c010681b:	85 c0                	test   %eax,%eax
c010681d:	74 24                	je     c0106843 <boot_map_segment+0x3b>
c010681f:	c7 44 24 0c 86 c4 10 	movl   $0xc010c486,0xc(%esp)
c0106826:	c0 
c0106827:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c010682e:	c0 
c010682f:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0106836:	00 
c0106837:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c010683e:	e8 29 b9 ff ff       	call   c010216c <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0106843:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c010684a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010684d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106852:	89 c2                	mov    %eax,%edx
c0106854:	8b 45 10             	mov    0x10(%ebp),%eax
c0106857:	01 c2                	add    %eax,%edx
c0106859:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010685c:	01 d0                	add    %edx,%eax
c010685e:	83 e8 01             	sub    $0x1,%eax
c0106861:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106864:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106867:	ba 00 00 00 00       	mov    $0x0,%edx
c010686c:	f7 75 f0             	divl   -0x10(%ebp)
c010686f:	89 d0                	mov    %edx,%eax
c0106871:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106874:	29 c2                	sub    %eax,%edx
c0106876:	89 d0                	mov    %edx,%eax
c0106878:	c1 e8 0c             	shr    $0xc,%eax
c010687b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010687e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106881:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106884:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106887:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010688c:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c010688f:	8b 45 14             	mov    0x14(%ebp),%eax
c0106892:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106895:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106898:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010689d:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01068a0:	eb 6b                	jmp    c010690d <boot_map_segment+0x105>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01068a2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01068a9:	00 
c01068aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068ad:	89 44 24 04          	mov    %eax,0x4(%esp)
c01068b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01068b4:	89 04 24             	mov    %eax,(%esp)
c01068b7:	e8 87 01 00 00       	call   c0106a43 <get_pte>
c01068bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01068bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01068c3:	75 24                	jne    c01068e9 <boot_map_segment+0xe1>
c01068c5:	c7 44 24 0c b2 c4 10 	movl   $0xc010c4b2,0xc(%esp)
c01068cc:	c0 
c01068cd:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c01068d4:	c0 
c01068d5:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c01068dc:	00 
c01068dd:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c01068e4:	e8 83 b8 ff ff       	call   c010216c <__panic>
        *ptep = pa | PTE_P | perm;
c01068e9:	8b 45 18             	mov    0x18(%ebp),%eax
c01068ec:	8b 55 14             	mov    0x14(%ebp),%edx
c01068ef:	09 d0                	or     %edx,%eax
c01068f1:	83 c8 01             	or     $0x1,%eax
c01068f4:	89 c2                	mov    %eax,%edx
c01068f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01068f9:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01068fb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01068ff:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0106906:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c010690d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106911:	75 8f                	jne    c01068a2 <boot_map_segment+0x9a>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0106913:	c9                   	leave  
c0106914:	c3                   	ret    

c0106915 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0106915:	55                   	push   %ebp
c0106916:	89 e5                	mov    %esp,%ebp
c0106918:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c010691b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106922:	e8 28 fa ff ff       	call   c010634f <alloc_pages>
c0106927:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c010692a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010692e:	75 1c                	jne    c010694c <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0106930:	c7 44 24 08 bf c4 10 	movl   $0xc010c4bf,0x8(%esp)
c0106937:	c0 
c0106938:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c010693f:	00 
c0106940:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0106947:	e8 20 b8 ff ff       	call   c010216c <__panic>
    }
    return page2kva(p);
c010694c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010694f:	89 04 24             	mov    %eax,(%esp)
c0106952:	e8 49 f7 ff ff       	call   c01060a0 <page2kva>
}
c0106957:	c9                   	leave  
c0106958:	c3                   	ret    

c0106959 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0106959:	55                   	push   %ebp
c010695a:	89 e5                	mov    %esp,%ebp
c010695c:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c010695f:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0106964:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106967:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010696e:	77 23                	ja     c0106993 <pmm_init+0x3a>
c0106970:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106973:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106977:	c7 44 24 08 54 c4 10 	movl   $0xc010c454,0x8(%esp)
c010697e:	c0 
c010697f:	c7 44 24 04 24 01 00 	movl   $0x124,0x4(%esp)
c0106986:	00 
c0106987:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c010698e:	e8 d9 b7 ff ff       	call   c010216c <__panic>
c0106993:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106996:	05 00 00 00 40       	add    $0x40000000,%eax
c010699b:	a3 88 e0 12 c0       	mov    %eax,0xc012e088
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01069a0:	e8 58 f9 ff ff       	call   c01062fd <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01069a5:	e8 6d fa ff ff       	call   c0106417 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01069aa:	e8 ab 04 00 00       	call   c0106e5a <check_alloc_page>

    check_pgdir();
c01069af:	e8 c4 04 00 00       	call   c0106e78 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01069b4:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01069b9:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c01069bf:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01069c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01069c7:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01069ce:	77 23                	ja     c01069f3 <pmm_init+0x9a>
c01069d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01069d7:	c7 44 24 08 54 c4 10 	movl   $0xc010c454,0x8(%esp)
c01069de:	c0 
c01069df:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c01069e6:	00 
c01069e7:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c01069ee:	e8 79 b7 ff ff       	call   c010216c <__panic>
c01069f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01069f6:	05 00 00 00 40       	add    $0x40000000,%eax
c01069fb:	83 c8 03             	or     $0x3,%eax
c01069fe:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0106a00:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0106a05:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0106a0c:	00 
c0106a0d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106a14:	00 
c0106a15:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0106a1c:	38 
c0106a1d:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0106a24:	c0 
c0106a25:	89 04 24             	mov    %eax,(%esp)
c0106a28:	e8 db fd ff ff       	call   c0106808 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0106a2d:	e8 dc f7 ff ff       	call   c010620e <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0106a32:	e8 dc 0a 00 00       	call   c0107513 <check_boot_pgdir>

    print_pgdir();
c0106a37:	e8 64 0f 00 00       	call   c01079a0 <print_pgdir>
    
    kmalloc_init();
c0106a3c:	e8 49 f3 ff ff       	call   c0105d8a <kmalloc_init>

}
c0106a41:	c9                   	leave  
c0106a42:	c3                   	ret    

c0106a43 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0106a43:	55                   	push   %ebp
c0106a44:	89 e5                	mov    %esp,%ebp
c0106a46:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0106a49:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a4c:	c1 e8 16             	shr    $0x16,%eax
c0106a4f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0106a56:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a59:	01 d0                	add    %edx,%eax
c0106a5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c0106a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106a61:	8b 00                	mov    (%eax),%eax
c0106a63:	83 e0 01             	and    $0x1,%eax
c0106a66:	85 c0                	test   %eax,%eax
c0106a68:	0f 85 af 00 00 00    	jne    c0106b1d <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c0106a6e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106a72:	74 15                	je     c0106a89 <get_pte+0x46>
c0106a74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106a7b:	e8 cf f8 ff ff       	call   c010634f <alloc_pages>
c0106a80:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106a83:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106a87:	75 0a                	jne    c0106a93 <get_pte+0x50>
            return NULL;
c0106a89:	b8 00 00 00 00       	mov    $0x0,%eax
c0106a8e:	e9 e6 00 00 00       	jmp    c0106b79 <get_pte+0x136>
        }
        set_page_ref(page, 1);
c0106a93:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106a9a:	00 
c0106a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106a9e:	89 04 24             	mov    %eax,(%esp)
c0106aa1:	e8 ae f6 ff ff       	call   c0106154 <set_page_ref>
        uintptr_t pa = page2pa(page);
c0106aa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106aa9:	89 04 24             	mov    %eax,(%esp)
c0106aac:	e8 8a f5 ff ff       	call   c010603b <page2pa>
c0106ab1:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0106ab4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106ab7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106aba:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106abd:	c1 e8 0c             	shr    $0xc,%eax
c0106ac0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106ac3:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c0106ac8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0106acb:	72 23                	jb     c0106af0 <get_pte+0xad>
c0106acd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106ad0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106ad4:	c7 44 24 08 b0 c3 10 	movl   $0xc010c3b0,0x8(%esp)
c0106adb:	c0 
c0106adc:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
c0106ae3:	00 
c0106ae4:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0106aeb:	e8 7c b6 ff ff       	call   c010216c <__panic>
c0106af0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106af3:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106af8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0106aff:	00 
c0106b00:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106b07:	00 
c0106b08:	89 04 24             	mov    %eax,(%esp)
c0106b0b:	e8 21 47 00 00       	call   c010b231 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0106b10:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106b13:	83 c8 07             	or     $0x7,%eax
c0106b16:	89 c2                	mov    %eax,%edx
c0106b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b1b:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0106b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106b20:	8b 00                	mov    (%eax),%eax
c0106b22:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0106b27:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106b2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b2d:	c1 e8 0c             	shr    $0xc,%eax
c0106b30:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0106b33:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c0106b38:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106b3b:	72 23                	jb     c0106b60 <get_pte+0x11d>
c0106b3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b40:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106b44:	c7 44 24 08 b0 c3 10 	movl   $0xc010c3b0,0x8(%esp)
c0106b4b:	c0 
c0106b4c:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
c0106b53:	00 
c0106b54:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0106b5b:	e8 0c b6 ff ff       	call   c010216c <__panic>
c0106b60:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b63:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0106b68:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106b6b:	c1 ea 0c             	shr    $0xc,%edx
c0106b6e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
c0106b74:	c1 e2 02             	shl    $0x2,%edx
c0106b77:	01 d0                	add    %edx,%eax
}
c0106b79:	c9                   	leave  
c0106b7a:	c3                   	ret    

c0106b7b <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0106b7b:	55                   	push   %ebp
c0106b7c:	89 e5                	mov    %esp,%ebp
c0106b7e:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0106b81:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106b88:	00 
c0106b89:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b8c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b90:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b93:	89 04 24             	mov    %eax,(%esp)
c0106b96:	e8 a8 fe ff ff       	call   c0106a43 <get_pte>
c0106b9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0106b9e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106ba2:	74 08                	je     c0106bac <get_page+0x31>
        *ptep_store = ptep;
c0106ba4:	8b 45 10             	mov    0x10(%ebp),%eax
c0106ba7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106baa:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0106bac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106bb0:	74 1b                	je     c0106bcd <get_page+0x52>
c0106bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106bb5:	8b 00                	mov    (%eax),%eax
c0106bb7:	83 e0 01             	and    $0x1,%eax
c0106bba:	85 c0                	test   %eax,%eax
c0106bbc:	74 0f                	je     c0106bcd <get_page+0x52>
        return pte2page(*ptep);
c0106bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106bc1:	8b 00                	mov    (%eax),%eax
c0106bc3:	89 04 24             	mov    %eax,(%esp)
c0106bc6:	e8 29 f5 ff ff       	call   c01060f4 <pte2page>
c0106bcb:	eb 05                	jmp    c0106bd2 <get_page+0x57>
    }
    return NULL;
c0106bcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106bd2:	c9                   	leave  
c0106bd3:	c3                   	ret    

c0106bd4 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0106bd4:	55                   	push   %ebp
c0106bd5:	89 e5                	mov    %esp,%ebp
c0106bd7:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c0106bda:	8b 45 10             	mov    0x10(%ebp),%eax
c0106bdd:	8b 00                	mov    (%eax),%eax
c0106bdf:	83 e0 01             	and    $0x1,%eax
c0106be2:	85 c0                	test   %eax,%eax
c0106be4:	74 4d                	je     c0106c33 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0106be6:	8b 45 10             	mov    0x10(%ebp),%eax
c0106be9:	8b 00                	mov    (%eax),%eax
c0106beb:	89 04 24             	mov    %eax,(%esp)
c0106bee:	e8 01 f5 ff ff       	call   c01060f4 <pte2page>
c0106bf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0106bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106bf9:	89 04 24             	mov    %eax,(%esp)
c0106bfc:	e8 77 f5 ff ff       	call   c0106178 <page_ref_dec>
c0106c01:	85 c0                	test   %eax,%eax
c0106c03:	75 13                	jne    c0106c18 <page_remove_pte+0x44>
            free_page(page);
c0106c05:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106c0c:	00 
c0106c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c10:	89 04 24             	mov    %eax,(%esp)
c0106c13:	e8 a2 f7 ff ff       	call   c01063ba <free_pages>
        }
        *ptep = 0;
c0106c18:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c1b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0106c21:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c24:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c28:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c2b:	89 04 24             	mov    %eax,(%esp)
c0106c2e:	e8 ff 00 00 00       	call   c0106d32 <tlb_invalidate>
    }
}
c0106c33:	c9                   	leave  
c0106c34:	c3                   	ret    

c0106c35 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0106c35:	55                   	push   %ebp
c0106c36:	89 e5                	mov    %esp,%ebp
c0106c38:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0106c3b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106c42:	00 
c0106c43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c46:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c4d:	89 04 24             	mov    %eax,(%esp)
c0106c50:	e8 ee fd ff ff       	call   c0106a43 <get_pte>
c0106c55:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0106c58:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106c5c:	74 19                	je     c0106c77 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0106c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106c61:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106c65:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c68:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c6f:	89 04 24             	mov    %eax,(%esp)
c0106c72:	e8 5d ff ff ff       	call   c0106bd4 <page_remove_pte>
    }
}
c0106c77:	c9                   	leave  
c0106c78:	c3                   	ret    

c0106c79 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0106c79:	55                   	push   %ebp
c0106c7a:	89 e5                	mov    %esp,%ebp
c0106c7c:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0106c7f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0106c86:	00 
c0106c87:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c91:	89 04 24             	mov    %eax,(%esp)
c0106c94:	e8 aa fd ff ff       	call   c0106a43 <get_pte>
c0106c99:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0106c9c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106ca0:	75 0a                	jne    c0106cac <page_insert+0x33>
        return -E_NO_MEM;
c0106ca2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0106ca7:	e9 84 00 00 00       	jmp    c0106d30 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0106cac:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106caf:	89 04 24             	mov    %eax,(%esp)
c0106cb2:	e8 aa f4 ff ff       	call   c0106161 <page_ref_inc>
    if (*ptep & PTE_P) {
c0106cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cba:	8b 00                	mov    (%eax),%eax
c0106cbc:	83 e0 01             	and    $0x1,%eax
c0106cbf:	85 c0                	test   %eax,%eax
c0106cc1:	74 3e                	je     c0106d01 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0106cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106cc6:	8b 00                	mov    (%eax),%eax
c0106cc8:	89 04 24             	mov    %eax,(%esp)
c0106ccb:	e8 24 f4 ff ff       	call   c01060f4 <pte2page>
c0106cd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0106cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106cd6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0106cd9:	75 0d                	jne    c0106ce8 <page_insert+0x6f>
            page_ref_dec(page);
c0106cdb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106cde:	89 04 24             	mov    %eax,(%esp)
c0106ce1:	e8 92 f4 ff ff       	call   c0106178 <page_ref_dec>
c0106ce6:	eb 19                	jmp    c0106d01 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0106ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ceb:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106cef:	8b 45 10             	mov    0x10(%ebp),%eax
c0106cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106cf6:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cf9:	89 04 24             	mov    %eax,(%esp)
c0106cfc:	e8 d3 fe ff ff       	call   c0106bd4 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0106d01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d04:	89 04 24             	mov    %eax,(%esp)
c0106d07:	e8 2f f3 ff ff       	call   c010603b <page2pa>
c0106d0c:	0b 45 14             	or     0x14(%ebp),%eax
c0106d0f:	83 c8 01             	or     $0x1,%eax
c0106d12:	89 c2                	mov    %eax,%edx
c0106d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d17:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0106d19:	8b 45 10             	mov    0x10(%ebp),%eax
c0106d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106d20:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d23:	89 04 24             	mov    %eax,(%esp)
c0106d26:	e8 07 00 00 00       	call   c0106d32 <tlb_invalidate>
    return 0;
c0106d2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106d30:	c9                   	leave  
c0106d31:	c3                   	ret    

c0106d32 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0106d32:	55                   	push   %ebp
c0106d33:	89 e5                	mov    %esp,%ebp
c0106d35:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0106d38:	0f 20 d8             	mov    %cr3,%eax
c0106d3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c0106d3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    if (rcr3() == PADDR(pgdir)) {
c0106d41:	89 c2                	mov    %eax,%edx
c0106d43:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d46:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106d49:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0106d50:	77 23                	ja     c0106d75 <tlb_invalidate+0x43>
c0106d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d55:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106d59:	c7 44 24 08 54 c4 10 	movl   $0xc010c454,0x8(%esp)
c0106d60:	c0 
c0106d61:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c0106d68:	00 
c0106d69:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0106d70:	e8 f7 b3 ff ff       	call   c010216c <__panic>
c0106d75:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d78:	05 00 00 00 40       	add    $0x40000000,%eax
c0106d7d:	39 c2                	cmp    %eax,%edx
c0106d7f:	75 0c                	jne    c0106d8d <tlb_invalidate+0x5b>
        invlpg((void *)la);
c0106d81:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d84:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0106d87:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d8a:	0f 01 38             	invlpg (%eax)
    }
}
c0106d8d:	c9                   	leave  
c0106d8e:	c3                   	ret    

c0106d8f <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0106d8f:	55                   	push   %ebp
c0106d90:	89 e5                	mov    %esp,%ebp
c0106d92:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0106d95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106d9c:	e8 ae f5 ff ff       	call   c010634f <alloc_pages>
c0106da1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0106da4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106da8:	0f 84 a7 00 00 00    	je     c0106e55 <pgdir_alloc_page+0xc6>
        if (page_insert(pgdir, page, la, perm) != 0) {
c0106dae:	8b 45 10             	mov    0x10(%ebp),%eax
c0106db1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106db5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106db8:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106dbf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106dc3:	8b 45 08             	mov    0x8(%ebp),%eax
c0106dc6:	89 04 24             	mov    %eax,(%esp)
c0106dc9:	e8 ab fe ff ff       	call   c0106c79 <page_insert>
c0106dce:	85 c0                	test   %eax,%eax
c0106dd0:	74 1a                	je     c0106dec <pgdir_alloc_page+0x5d>
            free_page(page);
c0106dd2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106dd9:	00 
c0106dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ddd:	89 04 24             	mov    %eax,(%esp)
c0106de0:	e8 d5 f5 ff ff       	call   c01063ba <free_pages>
            return NULL;
c0106de5:	b8 00 00 00 00       	mov    $0x0,%eax
c0106dea:	eb 6c                	jmp    c0106e58 <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c0106dec:	a1 2c c0 12 c0       	mov    0xc012c02c,%eax
c0106df1:	85 c0                	test   %eax,%eax
c0106df3:	74 60                	je     c0106e55 <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0106df5:	a1 6c e1 12 c0       	mov    0xc012e16c,%eax
c0106dfa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106e01:	00 
c0106e02:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106e05:	89 54 24 08          	mov    %edx,0x8(%esp)
c0106e09:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106e0c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106e10:	89 04 24             	mov    %eax,(%esp)
c0106e13:	e8 43 0e 00 00       	call   c0107c5b <swap_map_swappable>
            page->pra_vaddr=la;
c0106e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e1b:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106e1e:	89 50 20             	mov    %edx,0x20(%eax)
            assert(page_ref(page) == 1);
c0106e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106e24:	89 04 24             	mov    %eax,(%esp)
c0106e27:	e8 1e f3 ff ff       	call   c010614a <page_ref>
c0106e2c:	83 f8 01             	cmp    $0x1,%eax
c0106e2f:	74 24                	je     c0106e55 <pgdir_alloc_page+0xc6>
c0106e31:	c7 44 24 0c d8 c4 10 	movl   $0xc010c4d8,0xc(%esp)
c0106e38:	c0 
c0106e39:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0106e40:	c0 
c0106e41:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0106e48:	00 
c0106e49:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0106e50:	e8 17 b3 ff ff       	call   c010216c <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c0106e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106e58:	c9                   	leave  
c0106e59:	c3                   	ret    

c0106e5a <check_alloc_page>:

static void
check_alloc_page(void) {
c0106e5a:	55                   	push   %ebp
c0106e5b:	89 e5                	mov    %esp,%ebp
c0106e5d:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0106e60:	a1 84 e0 12 c0       	mov    0xc012e084,%eax
c0106e65:	8b 40 18             	mov    0x18(%eax),%eax
c0106e68:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0106e6a:	c7 04 24 ec c4 10 c0 	movl   $0xc010c4ec,(%esp)
c0106e71:	e8 6c a9 ff ff       	call   c01017e2 <cprintf>
}
c0106e76:	c9                   	leave  
c0106e77:	c3                   	ret    

c0106e78 <check_pgdir>:

static void
check_pgdir(void) {
c0106e78:	55                   	push   %ebp
c0106e79:	89 e5                	mov    %esp,%ebp
c0106e7b:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0106e7e:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c0106e83:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0106e88:	76 24                	jbe    c0106eae <check_pgdir+0x36>
c0106e8a:	c7 44 24 0c 0b c5 10 	movl   $0xc010c50b,0xc(%esp)
c0106e91:	c0 
c0106e92:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0106e99:	c0 
c0106e9a:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0106ea1:	00 
c0106ea2:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0106ea9:	e8 be b2 ff ff       	call   c010216c <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0106eae:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0106eb3:	85 c0                	test   %eax,%eax
c0106eb5:	74 0e                	je     c0106ec5 <check_pgdir+0x4d>
c0106eb7:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0106ebc:	25 ff 0f 00 00       	and    $0xfff,%eax
c0106ec1:	85 c0                	test   %eax,%eax
c0106ec3:	74 24                	je     c0106ee9 <check_pgdir+0x71>
c0106ec5:	c7 44 24 0c 28 c5 10 	movl   $0xc010c528,0xc(%esp)
c0106ecc:	c0 
c0106ecd:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0106ed4:	c0 
c0106ed5:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0106edc:	00 
c0106edd:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0106ee4:	e8 83 b2 ff ff       	call   c010216c <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0106ee9:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0106eee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106ef5:	00 
c0106ef6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106efd:	00 
c0106efe:	89 04 24             	mov    %eax,(%esp)
c0106f01:	e8 75 fc ff ff       	call   c0106b7b <get_page>
c0106f06:	85 c0                	test   %eax,%eax
c0106f08:	74 24                	je     c0106f2e <check_pgdir+0xb6>
c0106f0a:	c7 44 24 0c 60 c5 10 	movl   $0xc010c560,0xc(%esp)
c0106f11:	c0 
c0106f12:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0106f19:	c0 
c0106f1a:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0106f21:	00 
c0106f22:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0106f29:	e8 3e b2 ff ff       	call   c010216c <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0106f2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0106f35:	e8 15 f4 ff ff       	call   c010634f <alloc_pages>
c0106f3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0106f3d:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0106f42:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0106f49:	00 
c0106f4a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106f51:	00 
c0106f52:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106f55:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106f59:	89 04 24             	mov    %eax,(%esp)
c0106f5c:	e8 18 fd ff ff       	call   c0106c79 <page_insert>
c0106f61:	85 c0                	test   %eax,%eax
c0106f63:	74 24                	je     c0106f89 <check_pgdir+0x111>
c0106f65:	c7 44 24 0c 88 c5 10 	movl   $0xc010c588,0xc(%esp)
c0106f6c:	c0 
c0106f6d:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0106f74:	c0 
c0106f75:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c0106f7c:	00 
c0106f7d:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0106f84:	e8 e3 b1 ff ff       	call   c010216c <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0106f89:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0106f8e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0106f95:	00 
c0106f96:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106f9d:	00 
c0106f9e:	89 04 24             	mov    %eax,(%esp)
c0106fa1:	e8 9d fa ff ff       	call   c0106a43 <get_pte>
c0106fa6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106fa9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106fad:	75 24                	jne    c0106fd3 <check_pgdir+0x15b>
c0106faf:	c7 44 24 0c b4 c5 10 	movl   $0xc010c5b4,0xc(%esp)
c0106fb6:	c0 
c0106fb7:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0106fbe:	c0 
c0106fbf:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0106fc6:	00 
c0106fc7:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0106fce:	e8 99 b1 ff ff       	call   c010216c <__panic>
    assert(pte2page(*ptep) == p1);
c0106fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106fd6:	8b 00                	mov    (%eax),%eax
c0106fd8:	89 04 24             	mov    %eax,(%esp)
c0106fdb:	e8 14 f1 ff ff       	call   c01060f4 <pte2page>
c0106fe0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106fe3:	74 24                	je     c0107009 <check_pgdir+0x191>
c0106fe5:	c7 44 24 0c e1 c5 10 	movl   $0xc010c5e1,0xc(%esp)
c0106fec:	c0 
c0106fed:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0106ff4:	c0 
c0106ff5:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0106ffc:	00 
c0106ffd:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0107004:	e8 63 b1 ff ff       	call   c010216c <__panic>
    assert(page_ref(p1) == 1);
c0107009:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010700c:	89 04 24             	mov    %eax,(%esp)
c010700f:	e8 36 f1 ff ff       	call   c010614a <page_ref>
c0107014:	83 f8 01             	cmp    $0x1,%eax
c0107017:	74 24                	je     c010703d <check_pgdir+0x1c5>
c0107019:	c7 44 24 0c f7 c5 10 	movl   $0xc010c5f7,0xc(%esp)
c0107020:	c0 
c0107021:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0107028:	c0 
c0107029:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0107030:	00 
c0107031:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0107038:	e8 2f b1 ff ff       	call   c010216c <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c010703d:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0107042:	8b 00                	mov    (%eax),%eax
c0107044:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107049:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010704c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010704f:	c1 e8 0c             	shr    $0xc,%eax
c0107052:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107055:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c010705a:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010705d:	72 23                	jb     c0107082 <check_pgdir+0x20a>
c010705f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107062:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107066:	c7 44 24 08 b0 c3 10 	movl   $0xc010c3b0,0x8(%esp)
c010706d:	c0 
c010706e:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0107075:	00 
c0107076:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c010707d:	e8 ea b0 ff ff       	call   c010216c <__panic>
c0107082:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107085:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010708a:	83 c0 04             	add    $0x4,%eax
c010708d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0107090:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0107095:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010709c:	00 
c010709d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01070a4:	00 
c01070a5:	89 04 24             	mov    %eax,(%esp)
c01070a8:	e8 96 f9 ff ff       	call   c0106a43 <get_pte>
c01070ad:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01070b0:	74 24                	je     c01070d6 <check_pgdir+0x25e>
c01070b2:	c7 44 24 0c 0c c6 10 	movl   $0xc010c60c,0xc(%esp)
c01070b9:	c0 
c01070ba:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c01070c1:	c0 
c01070c2:	c7 44 24 04 19 02 00 	movl   $0x219,0x4(%esp)
c01070c9:	00 
c01070ca:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c01070d1:	e8 96 b0 ff ff       	call   c010216c <__panic>

    p2 = alloc_page();
c01070d6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01070dd:	e8 6d f2 ff ff       	call   c010634f <alloc_pages>
c01070e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01070e5:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01070ea:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01070f1:	00 
c01070f2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01070f9:	00 
c01070fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01070fd:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107101:	89 04 24             	mov    %eax,(%esp)
c0107104:	e8 70 fb ff ff       	call   c0106c79 <page_insert>
c0107109:	85 c0                	test   %eax,%eax
c010710b:	74 24                	je     c0107131 <check_pgdir+0x2b9>
c010710d:	c7 44 24 0c 34 c6 10 	movl   $0xc010c634,0xc(%esp)
c0107114:	c0 
c0107115:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c010711c:	c0 
c010711d:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c0107124:	00 
c0107125:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c010712c:	e8 3b b0 ff ff       	call   c010216c <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0107131:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0107136:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010713d:	00 
c010713e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107145:	00 
c0107146:	89 04 24             	mov    %eax,(%esp)
c0107149:	e8 f5 f8 ff ff       	call   c0106a43 <get_pte>
c010714e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107151:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107155:	75 24                	jne    c010717b <check_pgdir+0x303>
c0107157:	c7 44 24 0c 6c c6 10 	movl   $0xc010c66c,0xc(%esp)
c010715e:	c0 
c010715f:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0107166:	c0 
c0107167:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c010716e:	00 
c010716f:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0107176:	e8 f1 af ff ff       	call   c010216c <__panic>
    assert(*ptep & PTE_U);
c010717b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010717e:	8b 00                	mov    (%eax),%eax
c0107180:	83 e0 04             	and    $0x4,%eax
c0107183:	85 c0                	test   %eax,%eax
c0107185:	75 24                	jne    c01071ab <check_pgdir+0x333>
c0107187:	c7 44 24 0c 9c c6 10 	movl   $0xc010c69c,0xc(%esp)
c010718e:	c0 
c010718f:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0107196:	c0 
c0107197:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c010719e:	00 
c010719f:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c01071a6:	e8 c1 af ff ff       	call   c010216c <__panic>
    assert(*ptep & PTE_W);
c01071ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01071ae:	8b 00                	mov    (%eax),%eax
c01071b0:	83 e0 02             	and    $0x2,%eax
c01071b3:	85 c0                	test   %eax,%eax
c01071b5:	75 24                	jne    c01071db <check_pgdir+0x363>
c01071b7:	c7 44 24 0c aa c6 10 	movl   $0xc010c6aa,0xc(%esp)
c01071be:	c0 
c01071bf:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c01071c6:	c0 
c01071c7:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c01071ce:	00 
c01071cf:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c01071d6:	e8 91 af ff ff       	call   c010216c <__panic>
    assert(boot_pgdir[0] & PTE_U);
c01071db:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01071e0:	8b 00                	mov    (%eax),%eax
c01071e2:	83 e0 04             	and    $0x4,%eax
c01071e5:	85 c0                	test   %eax,%eax
c01071e7:	75 24                	jne    c010720d <check_pgdir+0x395>
c01071e9:	c7 44 24 0c b8 c6 10 	movl   $0xc010c6b8,0xc(%esp)
c01071f0:	c0 
c01071f1:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c01071f8:	c0 
c01071f9:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0107200:	00 
c0107201:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0107208:	e8 5f af ff ff       	call   c010216c <__panic>
    assert(page_ref(p2) == 1);
c010720d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107210:	89 04 24             	mov    %eax,(%esp)
c0107213:	e8 32 ef ff ff       	call   c010614a <page_ref>
c0107218:	83 f8 01             	cmp    $0x1,%eax
c010721b:	74 24                	je     c0107241 <check_pgdir+0x3c9>
c010721d:	c7 44 24 0c ce c6 10 	movl   $0xc010c6ce,0xc(%esp)
c0107224:	c0 
c0107225:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c010722c:	c0 
c010722d:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c0107234:	00 
c0107235:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c010723c:	e8 2b af ff ff       	call   c010216c <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0107241:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0107246:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010724d:	00 
c010724e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0107255:	00 
c0107256:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107259:	89 54 24 04          	mov    %edx,0x4(%esp)
c010725d:	89 04 24             	mov    %eax,(%esp)
c0107260:	e8 14 fa ff ff       	call   c0106c79 <page_insert>
c0107265:	85 c0                	test   %eax,%eax
c0107267:	74 24                	je     c010728d <check_pgdir+0x415>
c0107269:	c7 44 24 0c e0 c6 10 	movl   $0xc010c6e0,0xc(%esp)
c0107270:	c0 
c0107271:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0107278:	c0 
c0107279:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c0107280:	00 
c0107281:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0107288:	e8 df ae ff ff       	call   c010216c <__panic>
    assert(page_ref(p1) == 2);
c010728d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107290:	89 04 24             	mov    %eax,(%esp)
c0107293:	e8 b2 ee ff ff       	call   c010614a <page_ref>
c0107298:	83 f8 02             	cmp    $0x2,%eax
c010729b:	74 24                	je     c01072c1 <check_pgdir+0x449>
c010729d:	c7 44 24 0c 0c c7 10 	movl   $0xc010c70c,0xc(%esp)
c01072a4:	c0 
c01072a5:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c01072ac:	c0 
c01072ad:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c01072b4:	00 
c01072b5:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c01072bc:	e8 ab ae ff ff       	call   c010216c <__panic>
    assert(page_ref(p2) == 0);
c01072c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01072c4:	89 04 24             	mov    %eax,(%esp)
c01072c7:	e8 7e ee ff ff       	call   c010614a <page_ref>
c01072cc:	85 c0                	test   %eax,%eax
c01072ce:	74 24                	je     c01072f4 <check_pgdir+0x47c>
c01072d0:	c7 44 24 0c 1e c7 10 	movl   $0xc010c71e,0xc(%esp)
c01072d7:	c0 
c01072d8:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c01072df:	c0 
c01072e0:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c01072e7:	00 
c01072e8:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c01072ef:	e8 78 ae ff ff       	call   c010216c <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01072f4:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01072f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107300:	00 
c0107301:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0107308:	00 
c0107309:	89 04 24             	mov    %eax,(%esp)
c010730c:	e8 32 f7 ff ff       	call   c0106a43 <get_pte>
c0107311:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107314:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107318:	75 24                	jne    c010733e <check_pgdir+0x4c6>
c010731a:	c7 44 24 0c 6c c6 10 	movl   $0xc010c66c,0xc(%esp)
c0107321:	c0 
c0107322:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0107329:	c0 
c010732a:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
c0107331:	00 
c0107332:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0107339:	e8 2e ae ff ff       	call   c010216c <__panic>
    assert(pte2page(*ptep) == p1);
c010733e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107341:	8b 00                	mov    (%eax),%eax
c0107343:	89 04 24             	mov    %eax,(%esp)
c0107346:	e8 a9 ed ff ff       	call   c01060f4 <pte2page>
c010734b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010734e:	74 24                	je     c0107374 <check_pgdir+0x4fc>
c0107350:	c7 44 24 0c e1 c5 10 	movl   $0xc010c5e1,0xc(%esp)
c0107357:	c0 
c0107358:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c010735f:	c0 
c0107360:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c0107367:	00 
c0107368:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c010736f:	e8 f8 ad ff ff       	call   c010216c <__panic>
    assert((*ptep & PTE_U) == 0);
c0107374:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107377:	8b 00                	mov    (%eax),%eax
c0107379:	83 e0 04             	and    $0x4,%eax
c010737c:	85 c0                	test   %eax,%eax
c010737e:	74 24                	je     c01073a4 <check_pgdir+0x52c>
c0107380:	c7 44 24 0c 30 c7 10 	movl   $0xc010c730,0xc(%esp)
c0107387:	c0 
c0107388:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c010738f:	c0 
c0107390:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
c0107397:	00 
c0107398:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c010739f:	e8 c8 ad ff ff       	call   c010216c <__panic>

    page_remove(boot_pgdir, 0x0);
c01073a4:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01073a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01073b0:	00 
c01073b1:	89 04 24             	mov    %eax,(%esp)
c01073b4:	e8 7c f8 ff ff       	call   c0106c35 <page_remove>
    assert(page_ref(p1) == 1);
c01073b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01073bc:	89 04 24             	mov    %eax,(%esp)
c01073bf:	e8 86 ed ff ff       	call   c010614a <page_ref>
c01073c4:	83 f8 01             	cmp    $0x1,%eax
c01073c7:	74 24                	je     c01073ed <check_pgdir+0x575>
c01073c9:	c7 44 24 0c f7 c5 10 	movl   $0xc010c5f7,0xc(%esp)
c01073d0:	c0 
c01073d1:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c01073d8:	c0 
c01073d9:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c01073e0:	00 
c01073e1:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c01073e8:	e8 7f ad ff ff       	call   c010216c <__panic>
    assert(page_ref(p2) == 0);
c01073ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01073f0:	89 04 24             	mov    %eax,(%esp)
c01073f3:	e8 52 ed ff ff       	call   c010614a <page_ref>
c01073f8:	85 c0                	test   %eax,%eax
c01073fa:	74 24                	je     c0107420 <check_pgdir+0x5a8>
c01073fc:	c7 44 24 0c 1e c7 10 	movl   $0xc010c71e,0xc(%esp)
c0107403:	c0 
c0107404:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c010740b:	c0 
c010740c:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c0107413:	00 
c0107414:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c010741b:	e8 4c ad ff ff       	call   c010216c <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0107420:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0107425:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010742c:	00 
c010742d:	89 04 24             	mov    %eax,(%esp)
c0107430:	e8 00 f8 ff ff       	call   c0106c35 <page_remove>
    assert(page_ref(p1) == 0);
c0107435:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107438:	89 04 24             	mov    %eax,(%esp)
c010743b:	e8 0a ed ff ff       	call   c010614a <page_ref>
c0107440:	85 c0                	test   %eax,%eax
c0107442:	74 24                	je     c0107468 <check_pgdir+0x5f0>
c0107444:	c7 44 24 0c 45 c7 10 	movl   $0xc010c745,0xc(%esp)
c010744b:	c0 
c010744c:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0107453:	c0 
c0107454:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c010745b:	00 
c010745c:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0107463:	e8 04 ad ff ff       	call   c010216c <__panic>
    assert(page_ref(p2) == 0);
c0107468:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010746b:	89 04 24             	mov    %eax,(%esp)
c010746e:	e8 d7 ec ff ff       	call   c010614a <page_ref>
c0107473:	85 c0                	test   %eax,%eax
c0107475:	74 24                	je     c010749b <check_pgdir+0x623>
c0107477:	c7 44 24 0c 1e c7 10 	movl   $0xc010c71e,0xc(%esp)
c010747e:	c0 
c010747f:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0107486:	c0 
c0107487:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c010748e:	00 
c010748f:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0107496:	e8 d1 ac ff ff       	call   c010216c <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c010749b:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01074a0:	8b 00                	mov    (%eax),%eax
c01074a2:	89 04 24             	mov    %eax,(%esp)
c01074a5:	e8 88 ec ff ff       	call   c0106132 <pde2page>
c01074aa:	89 04 24             	mov    %eax,(%esp)
c01074ad:	e8 98 ec ff ff       	call   c010614a <page_ref>
c01074b2:	83 f8 01             	cmp    $0x1,%eax
c01074b5:	74 24                	je     c01074db <check_pgdir+0x663>
c01074b7:	c7 44 24 0c 58 c7 10 	movl   $0xc010c758,0xc(%esp)
c01074be:	c0 
c01074bf:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c01074c6:	c0 
c01074c7:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
c01074ce:	00 
c01074cf:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c01074d6:	e8 91 ac ff ff       	call   c010216c <__panic>
    free_page(pde2page(boot_pgdir[0]));
c01074db:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01074e0:	8b 00                	mov    (%eax),%eax
c01074e2:	89 04 24             	mov    %eax,(%esp)
c01074e5:	e8 48 ec ff ff       	call   c0106132 <pde2page>
c01074ea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01074f1:	00 
c01074f2:	89 04 24             	mov    %eax,(%esp)
c01074f5:	e8 c0 ee ff ff       	call   c01063ba <free_pages>
    boot_pgdir[0] = 0;
c01074fa:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01074ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0107505:	c7 04 24 7f c7 10 c0 	movl   $0xc010c77f,(%esp)
c010750c:	e8 d1 a2 ff ff       	call   c01017e2 <cprintf>
}
c0107511:	c9                   	leave  
c0107512:	c3                   	ret    

c0107513 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0107513:	55                   	push   %ebp
c0107514:	89 e5                	mov    %esp,%ebp
c0107516:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0107519:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107520:	e9 ca 00 00 00       	jmp    c01075ef <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0107525:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107528:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010752b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010752e:	c1 e8 0c             	shr    $0xc,%eax
c0107531:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107534:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c0107539:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c010753c:	72 23                	jb     c0107561 <check_boot_pgdir+0x4e>
c010753e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107541:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107545:	c7 44 24 08 b0 c3 10 	movl   $0xc010c3b0,0x8(%esp)
c010754c:	c0 
c010754d:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
c0107554:	00 
c0107555:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c010755c:	e8 0b ac ff ff       	call   c010216c <__panic>
c0107561:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107564:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0107569:	89 c2                	mov    %eax,%edx
c010756b:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0107570:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107577:	00 
c0107578:	89 54 24 04          	mov    %edx,0x4(%esp)
c010757c:	89 04 24             	mov    %eax,(%esp)
c010757f:	e8 bf f4 ff ff       	call   c0106a43 <get_pte>
c0107584:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0107587:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010758b:	75 24                	jne    c01075b1 <check_boot_pgdir+0x9e>
c010758d:	c7 44 24 0c 9c c7 10 	movl   $0xc010c79c,0xc(%esp)
c0107594:	c0 
c0107595:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c010759c:	c0 
c010759d:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
c01075a4:	00 
c01075a5:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c01075ac:	e8 bb ab ff ff       	call   c010216c <__panic>
        assert(PTE_ADDR(*ptep) == i);
c01075b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01075b4:	8b 00                	mov    (%eax),%eax
c01075b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01075bb:	89 c2                	mov    %eax,%edx
c01075bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01075c0:	39 c2                	cmp    %eax,%edx
c01075c2:	74 24                	je     c01075e8 <check_boot_pgdir+0xd5>
c01075c4:	c7 44 24 0c d9 c7 10 	movl   $0xc010c7d9,0xc(%esp)
c01075cb:	c0 
c01075cc:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c01075d3:	c0 
c01075d4:	c7 44 24 04 3f 02 00 	movl   $0x23f,0x4(%esp)
c01075db:	00 
c01075dc:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c01075e3:	e8 84 ab ff ff       	call   c010216c <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01075e8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01075ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01075f2:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c01075f7:	39 c2                	cmp    %eax,%edx
c01075f9:	0f 82 26 ff ff ff    	jb     c0107525 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01075ff:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0107604:	05 ac 0f 00 00       	add    $0xfac,%eax
c0107609:	8b 00                	mov    (%eax),%eax
c010760b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107610:	89 c2                	mov    %eax,%edx
c0107612:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0107617:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010761a:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0107621:	77 23                	ja     c0107646 <check_boot_pgdir+0x133>
c0107623:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107626:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010762a:	c7 44 24 08 54 c4 10 	movl   $0xc010c454,0x8(%esp)
c0107631:	c0 
c0107632:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c0107639:	00 
c010763a:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0107641:	e8 26 ab ff ff       	call   c010216c <__panic>
c0107646:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107649:	05 00 00 00 40       	add    $0x40000000,%eax
c010764e:	39 c2                	cmp    %eax,%edx
c0107650:	74 24                	je     c0107676 <check_boot_pgdir+0x163>
c0107652:	c7 44 24 0c f0 c7 10 	movl   $0xc010c7f0,0xc(%esp)
c0107659:	c0 
c010765a:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0107661:	c0 
c0107662:	c7 44 24 04 42 02 00 	movl   $0x242,0x4(%esp)
c0107669:	00 
c010766a:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0107671:	e8 f6 aa ff ff       	call   c010216c <__panic>

    assert(boot_pgdir[0] == 0);
c0107676:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c010767b:	8b 00                	mov    (%eax),%eax
c010767d:	85 c0                	test   %eax,%eax
c010767f:	74 24                	je     c01076a5 <check_boot_pgdir+0x192>
c0107681:	c7 44 24 0c 24 c8 10 	movl   $0xc010c824,0xc(%esp)
c0107688:	c0 
c0107689:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c0107690:	c0 
c0107691:	c7 44 24 04 44 02 00 	movl   $0x244,0x4(%esp)
c0107698:	00 
c0107699:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c01076a0:	e8 c7 aa ff ff       	call   c010216c <__panic>

    struct Page *p;
    p = alloc_page();
c01076a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01076ac:	e8 9e ec ff ff       	call   c010634f <alloc_pages>
c01076b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c01076b4:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c01076b9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01076c0:	00 
c01076c1:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c01076c8:	00 
c01076c9:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01076cc:	89 54 24 04          	mov    %edx,0x4(%esp)
c01076d0:	89 04 24             	mov    %eax,(%esp)
c01076d3:	e8 a1 f5 ff ff       	call   c0106c79 <page_insert>
c01076d8:	85 c0                	test   %eax,%eax
c01076da:	74 24                	je     c0107700 <check_boot_pgdir+0x1ed>
c01076dc:	c7 44 24 0c 38 c8 10 	movl   $0xc010c838,0xc(%esp)
c01076e3:	c0 
c01076e4:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c01076eb:	c0 
c01076ec:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c01076f3:	00 
c01076f4:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c01076fb:	e8 6c aa ff ff       	call   c010216c <__panic>
    assert(page_ref(p) == 1);
c0107700:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107703:	89 04 24             	mov    %eax,(%esp)
c0107706:	e8 3f ea ff ff       	call   c010614a <page_ref>
c010770b:	83 f8 01             	cmp    $0x1,%eax
c010770e:	74 24                	je     c0107734 <check_boot_pgdir+0x221>
c0107710:	c7 44 24 0c 66 c8 10 	movl   $0xc010c866,0xc(%esp)
c0107717:	c0 
c0107718:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c010771f:	c0 
c0107720:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
c0107727:	00 
c0107728:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c010772f:	e8 38 aa ff ff       	call   c010216c <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0107734:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0107739:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0107740:	00 
c0107741:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0107748:	00 
c0107749:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010774c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107750:	89 04 24             	mov    %eax,(%esp)
c0107753:	e8 21 f5 ff ff       	call   c0106c79 <page_insert>
c0107758:	85 c0                	test   %eax,%eax
c010775a:	74 24                	je     c0107780 <check_boot_pgdir+0x26d>
c010775c:	c7 44 24 0c 78 c8 10 	movl   $0xc010c878,0xc(%esp)
c0107763:	c0 
c0107764:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c010776b:	c0 
c010776c:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
c0107773:	00 
c0107774:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c010777b:	e8 ec a9 ff ff       	call   c010216c <__panic>
    assert(page_ref(p) == 2);
c0107780:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107783:	89 04 24             	mov    %eax,(%esp)
c0107786:	e8 bf e9 ff ff       	call   c010614a <page_ref>
c010778b:	83 f8 02             	cmp    $0x2,%eax
c010778e:	74 24                	je     c01077b4 <check_boot_pgdir+0x2a1>
c0107790:	c7 44 24 0c af c8 10 	movl   $0xc010c8af,0xc(%esp)
c0107797:	c0 
c0107798:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c010779f:	c0 
c01077a0:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
c01077a7:	00 
c01077a8:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c01077af:	e8 b8 a9 ff ff       	call   c010216c <__panic>

    const char *str = "ucore: Hello world!!";
c01077b4:	c7 45 dc c0 c8 10 c0 	movl   $0xc010c8c0,-0x24(%ebp)
    strcpy((void *)0x100, str);
c01077bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01077be:	89 44 24 04          	mov    %eax,0x4(%esp)
c01077c2:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01077c9:	e8 8c 37 00 00       	call   c010af5a <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c01077ce:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c01077d5:	00 
c01077d6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01077dd:	e8 f1 37 00 00       	call   c010afd3 <strcmp>
c01077e2:	85 c0                	test   %eax,%eax
c01077e4:	74 24                	je     c010780a <check_boot_pgdir+0x2f7>
c01077e6:	c7 44 24 0c d8 c8 10 	movl   $0xc010c8d8,0xc(%esp)
c01077ed:	c0 
c01077ee:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c01077f5:	c0 
c01077f6:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
c01077fd:	00 
c01077fe:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c0107805:	e8 62 a9 ff ff       	call   c010216c <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c010780a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010780d:	89 04 24             	mov    %eax,(%esp)
c0107810:	e8 8b e8 ff ff       	call   c01060a0 <page2kva>
c0107815:	05 00 01 00 00       	add    $0x100,%eax
c010781a:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c010781d:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0107824:	e8 d9 36 00 00       	call   c010af02 <strlen>
c0107829:	85 c0                	test   %eax,%eax
c010782b:	74 24                	je     c0107851 <check_boot_pgdir+0x33e>
c010782d:	c7 44 24 0c 10 c9 10 	movl   $0xc010c910,0xc(%esp)
c0107834:	c0 
c0107835:	c7 44 24 08 9d c4 10 	movl   $0xc010c49d,0x8(%esp)
c010783c:	c0 
c010783d:	c7 44 24 04 52 02 00 	movl   $0x252,0x4(%esp)
c0107844:	00 
c0107845:	c7 04 24 78 c4 10 c0 	movl   $0xc010c478,(%esp)
c010784c:	e8 1b a9 ff ff       	call   c010216c <__panic>

    free_page(p);
c0107851:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107858:	00 
c0107859:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010785c:	89 04 24             	mov    %eax,(%esp)
c010785f:	e8 56 eb ff ff       	call   c01063ba <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0107864:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0107869:	8b 00                	mov    (%eax),%eax
c010786b:	89 04 24             	mov    %eax,(%esp)
c010786e:	e8 bf e8 ff ff       	call   c0106132 <pde2page>
c0107873:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010787a:	00 
c010787b:	89 04 24             	mov    %eax,(%esp)
c010787e:	e8 37 eb ff ff       	call   c01063ba <free_pages>
    boot_pgdir[0] = 0;
c0107883:	a1 00 8a 12 c0       	mov    0xc0128a00,%eax
c0107888:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c010788e:	c7 04 24 34 c9 10 c0 	movl   $0xc010c934,(%esp)
c0107895:	e8 48 9f ff ff       	call   c01017e2 <cprintf>
}
c010789a:	c9                   	leave  
c010789b:	c3                   	ret    

c010789c <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c010789c:	55                   	push   %ebp
c010789d:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c010789f:	8b 45 08             	mov    0x8(%ebp),%eax
c01078a2:	83 e0 04             	and    $0x4,%eax
c01078a5:	85 c0                	test   %eax,%eax
c01078a7:	74 07                	je     c01078b0 <perm2str+0x14>
c01078a9:	b8 75 00 00 00       	mov    $0x75,%eax
c01078ae:	eb 05                	jmp    c01078b5 <perm2str+0x19>
c01078b0:	b8 2d 00 00 00       	mov    $0x2d,%eax
c01078b5:	a2 28 c0 12 c0       	mov    %al,0xc012c028
    str[1] = 'r';
c01078ba:	c6 05 29 c0 12 c0 72 	movb   $0x72,0xc012c029
    str[2] = (perm & PTE_W) ? 'w' : '-';
c01078c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01078c4:	83 e0 02             	and    $0x2,%eax
c01078c7:	85 c0                	test   %eax,%eax
c01078c9:	74 07                	je     c01078d2 <perm2str+0x36>
c01078cb:	b8 77 00 00 00       	mov    $0x77,%eax
c01078d0:	eb 05                	jmp    c01078d7 <perm2str+0x3b>
c01078d2:	b8 2d 00 00 00       	mov    $0x2d,%eax
c01078d7:	a2 2a c0 12 c0       	mov    %al,0xc012c02a
    str[3] = '\0';
c01078dc:	c6 05 2b c0 12 c0 00 	movb   $0x0,0xc012c02b
    return str;
c01078e3:	b8 28 c0 12 c0       	mov    $0xc012c028,%eax
}
c01078e8:	5d                   	pop    %ebp
c01078e9:	c3                   	ret    

c01078ea <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01078ea:	55                   	push   %ebp
c01078eb:	89 e5                	mov    %esp,%ebp
c01078ed:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01078f0:	8b 45 10             	mov    0x10(%ebp),%eax
c01078f3:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01078f6:	72 0a                	jb     c0107902 <get_pgtable_items+0x18>
        return 0;
c01078f8:	b8 00 00 00 00       	mov    $0x0,%eax
c01078fd:	e9 9c 00 00 00       	jmp    c010799e <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
c0107902:	eb 04                	jmp    c0107908 <get_pgtable_items+0x1e>
        start ++;
c0107904:	83 45 10 01          	addl   $0x1,0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0107908:	8b 45 10             	mov    0x10(%ebp),%eax
c010790b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010790e:	73 18                	jae    c0107928 <get_pgtable_items+0x3e>
c0107910:	8b 45 10             	mov    0x10(%ebp),%eax
c0107913:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010791a:	8b 45 14             	mov    0x14(%ebp),%eax
c010791d:	01 d0                	add    %edx,%eax
c010791f:	8b 00                	mov    (%eax),%eax
c0107921:	83 e0 01             	and    $0x1,%eax
c0107924:	85 c0                	test   %eax,%eax
c0107926:	74 dc                	je     c0107904 <get_pgtable_items+0x1a>
        start ++;
    }
    if (start < right) {
c0107928:	8b 45 10             	mov    0x10(%ebp),%eax
c010792b:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010792e:	73 69                	jae    c0107999 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c0107930:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0107934:	74 08                	je     c010793e <get_pgtable_items+0x54>
            *left_store = start;
c0107936:	8b 45 18             	mov    0x18(%ebp),%eax
c0107939:	8b 55 10             	mov    0x10(%ebp),%edx
c010793c:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c010793e:	8b 45 10             	mov    0x10(%ebp),%eax
c0107941:	8d 50 01             	lea    0x1(%eax),%edx
c0107944:	89 55 10             	mov    %edx,0x10(%ebp)
c0107947:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010794e:	8b 45 14             	mov    0x14(%ebp),%eax
c0107951:	01 d0                	add    %edx,%eax
c0107953:	8b 00                	mov    (%eax),%eax
c0107955:	83 e0 07             	and    $0x7,%eax
c0107958:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c010795b:	eb 04                	jmp    c0107961 <get_pgtable_items+0x77>
            start ++;
c010795d:	83 45 10 01          	addl   $0x1,0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0107961:	8b 45 10             	mov    0x10(%ebp),%eax
c0107964:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107967:	73 1d                	jae    c0107986 <get_pgtable_items+0x9c>
c0107969:	8b 45 10             	mov    0x10(%ebp),%eax
c010796c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0107973:	8b 45 14             	mov    0x14(%ebp),%eax
c0107976:	01 d0                	add    %edx,%eax
c0107978:	8b 00                	mov    (%eax),%eax
c010797a:	83 e0 07             	and    $0x7,%eax
c010797d:	89 c2                	mov    %eax,%edx
c010797f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107982:	39 c2                	cmp    %eax,%edx
c0107984:	74 d7                	je     c010795d <get_pgtable_items+0x73>
            start ++;
        }
        if (right_store != NULL) {
c0107986:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010798a:	74 08                	je     c0107994 <get_pgtable_items+0xaa>
            *right_store = start;
c010798c:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010798f:	8b 55 10             	mov    0x10(%ebp),%edx
c0107992:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0107994:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107997:	eb 05                	jmp    c010799e <get_pgtable_items+0xb4>
    }
    return 0;
c0107999:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010799e:	c9                   	leave  
c010799f:	c3                   	ret    

c01079a0 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c01079a0:	55                   	push   %ebp
c01079a1:	89 e5                	mov    %esp,%ebp
c01079a3:	57                   	push   %edi
c01079a4:	56                   	push   %esi
c01079a5:	53                   	push   %ebx
c01079a6:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c01079a9:	c7 04 24 54 c9 10 c0 	movl   $0xc010c954,(%esp)
c01079b0:	e8 2d 9e ff ff       	call   c01017e2 <cprintf>
    size_t left, right = 0, perm;
c01079b5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01079bc:	e9 fa 00 00 00       	jmp    c0107abb <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01079c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01079c4:	89 04 24             	mov    %eax,(%esp)
c01079c7:	e8 d0 fe ff ff       	call   c010789c <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c01079cc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01079cf:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01079d2:	29 d1                	sub    %edx,%ecx
c01079d4:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01079d6:	89 d6                	mov    %edx,%esi
c01079d8:	c1 e6 16             	shl    $0x16,%esi
c01079db:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01079de:	89 d3                	mov    %edx,%ebx
c01079e0:	c1 e3 16             	shl    $0x16,%ebx
c01079e3:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01079e6:	89 d1                	mov    %edx,%ecx
c01079e8:	c1 e1 16             	shl    $0x16,%ecx
c01079eb:	8b 7d dc             	mov    -0x24(%ebp),%edi
c01079ee:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01079f1:	29 d7                	sub    %edx,%edi
c01079f3:	89 fa                	mov    %edi,%edx
c01079f5:	89 44 24 14          	mov    %eax,0x14(%esp)
c01079f9:	89 74 24 10          	mov    %esi,0x10(%esp)
c01079fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0107a01:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0107a05:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107a09:	c7 04 24 85 c9 10 c0 	movl   $0xc010c985,(%esp)
c0107a10:	e8 cd 9d ff ff       	call   c01017e2 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0107a15:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107a18:	c1 e0 0a             	shl    $0xa,%eax
c0107a1b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0107a1e:	eb 54                	jmp    c0107a74 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0107a20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107a23:	89 04 24             	mov    %eax,(%esp)
c0107a26:	e8 71 fe ff ff       	call   c010789c <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0107a2b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0107a2e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107a31:	29 d1                	sub    %edx,%ecx
c0107a33:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0107a35:	89 d6                	mov    %edx,%esi
c0107a37:	c1 e6 0c             	shl    $0xc,%esi
c0107a3a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107a3d:	89 d3                	mov    %edx,%ebx
c0107a3f:	c1 e3 0c             	shl    $0xc,%ebx
c0107a42:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107a45:	c1 e2 0c             	shl    $0xc,%edx
c0107a48:	89 d1                	mov    %edx,%ecx
c0107a4a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0107a4d:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107a50:	29 d7                	sub    %edx,%edi
c0107a52:	89 fa                	mov    %edi,%edx
c0107a54:	89 44 24 14          	mov    %eax,0x14(%esp)
c0107a58:	89 74 24 10          	mov    %esi,0x10(%esp)
c0107a5c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0107a60:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0107a64:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107a68:	c7 04 24 a4 c9 10 c0 	movl   $0xc010c9a4,(%esp)
c0107a6f:	e8 6e 9d ff ff       	call   c01017e2 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0107a74:	ba 00 00 c0 fa       	mov    $0xfac00000,%edx
c0107a79:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107a7c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0107a7f:	89 ce                	mov    %ecx,%esi
c0107a81:	c1 e6 0a             	shl    $0xa,%esi
c0107a84:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0107a87:	89 cb                	mov    %ecx,%ebx
c0107a89:	c1 e3 0a             	shl    $0xa,%ebx
c0107a8c:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
c0107a8f:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0107a93:	8d 4d d8             	lea    -0x28(%ebp),%ecx
c0107a96:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0107a9a:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107a9e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107aa2:	89 74 24 04          	mov    %esi,0x4(%esp)
c0107aa6:	89 1c 24             	mov    %ebx,(%esp)
c0107aa9:	e8 3c fe ff ff       	call   c01078ea <get_pgtable_items>
c0107aae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107ab1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107ab5:	0f 85 65 ff ff ff    	jne    c0107a20 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0107abb:	ba 00 b0 fe fa       	mov    $0xfafeb000,%edx
c0107ac0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107ac3:	8d 4d dc             	lea    -0x24(%ebp),%ecx
c0107ac6:	89 4c 24 14          	mov    %ecx,0x14(%esp)
c0107aca:	8d 4d e0             	lea    -0x20(%ebp),%ecx
c0107acd:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0107ad1:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107ad5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107ad9:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0107ae0:	00 
c0107ae1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0107ae8:	e8 fd fd ff ff       	call   c01078ea <get_pgtable_items>
c0107aed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107af0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0107af4:	0f 85 c7 fe ff ff    	jne    c01079c1 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0107afa:	c7 04 24 c8 c9 10 c0 	movl   $0xc010c9c8,(%esp)
c0107b01:	e8 dc 9c ff ff       	call   c01017e2 <cprintf>
}
c0107b06:	83 c4 4c             	add    $0x4c,%esp
c0107b09:	5b                   	pop    %ebx
c0107b0a:	5e                   	pop    %esi
c0107b0b:	5f                   	pop    %edi
c0107b0c:	5d                   	pop    %ebp
c0107b0d:	c3                   	ret    

c0107b0e <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0107b0e:	55                   	push   %ebp
c0107b0f:	89 e5                	mov    %esp,%ebp
c0107b11:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0107b14:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b17:	c1 e8 0c             	shr    $0xc,%eax
c0107b1a:	89 c2                	mov    %eax,%edx
c0107b1c:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c0107b21:	39 c2                	cmp    %eax,%edx
c0107b23:	72 1c                	jb     c0107b41 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0107b25:	c7 44 24 08 fc c9 10 	movl   $0xc010c9fc,0x8(%esp)
c0107b2c:	c0 
c0107b2d:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0107b34:	00 
c0107b35:	c7 04 24 1b ca 10 c0 	movl   $0xc010ca1b,(%esp)
c0107b3c:	e8 2b a6 ff ff       	call   c010216c <__panic>
    }
    return &pages[PPN(pa)];
c0107b41:	8b 0d 8c e0 12 c0    	mov    0xc012e08c,%ecx
c0107b47:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b4a:	c1 e8 0c             	shr    $0xc,%eax
c0107b4d:	89 c2                	mov    %eax,%edx
c0107b4f:	89 d0                	mov    %edx,%eax
c0107b51:	c1 e0 03             	shl    $0x3,%eax
c0107b54:	01 d0                	add    %edx,%eax
c0107b56:	c1 e0 02             	shl    $0x2,%eax
c0107b59:	01 c8                	add    %ecx,%eax
}
c0107b5b:	c9                   	leave  
c0107b5c:	c3                   	ret    

c0107b5d <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0107b5d:	55                   	push   %ebp
c0107b5e:	89 e5                	mov    %esp,%ebp
c0107b60:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0107b63:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b66:	83 e0 01             	and    $0x1,%eax
c0107b69:	85 c0                	test   %eax,%eax
c0107b6b:	75 1c                	jne    c0107b89 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0107b6d:	c7 44 24 08 2c ca 10 	movl   $0xc010ca2c,0x8(%esp)
c0107b74:	c0 
c0107b75:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0107b7c:	00 
c0107b7d:	c7 04 24 1b ca 10 c0 	movl   $0xc010ca1b,(%esp)
c0107b84:	e8 e3 a5 ff ff       	call   c010216c <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0107b89:	8b 45 08             	mov    0x8(%ebp),%eax
c0107b8c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0107b91:	89 04 24             	mov    %eax,(%esp)
c0107b94:	e8 75 ff ff ff       	call   c0107b0e <pa2page>
}
c0107b99:	c9                   	leave  
c0107b9a:	c3                   	ret    

c0107b9b <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0107b9b:	55                   	push   %ebp
c0107b9c:	89 e5                	mov    %esp,%ebp
c0107b9e:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0107ba1:	e8 89 1e 00 00       	call   c0109a2f <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0107ba6:	a1 3c e1 12 c0       	mov    0xc012e13c,%eax
c0107bab:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0107bb0:	76 0c                	jbe    c0107bbe <swap_init+0x23>
c0107bb2:	a1 3c e1 12 c0       	mov    0xc012e13c,%eax
c0107bb7:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0107bbc:	76 25                	jbe    c0107be3 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0107bbe:	a1 3c e1 12 c0       	mov    0xc012e13c,%eax
c0107bc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107bc7:	c7 44 24 08 4d ca 10 	movl   $0xc010ca4d,0x8(%esp)
c0107bce:	c0 
c0107bcf:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
c0107bd6:	00 
c0107bd7:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c0107bde:	e8 89 a5 ff ff       	call   c010216c <__panic>
     }
     

     sm = &swap_manager_fifo;
c0107be3:	c7 05 34 c0 12 c0 60 	movl   $0xc0128a60,0xc012c034
c0107bea:	8a 12 c0 
     int r = sm->init();
c0107bed:	a1 34 c0 12 c0       	mov    0xc012c034,%eax
c0107bf2:	8b 40 04             	mov    0x4(%eax),%eax
c0107bf5:	ff d0                	call   *%eax
c0107bf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0107bfa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107bfe:	75 26                	jne    c0107c26 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0107c00:	c7 05 2c c0 12 c0 01 	movl   $0x1,0xc012c02c
c0107c07:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0107c0a:	a1 34 c0 12 c0       	mov    0xc012c034,%eax
c0107c0f:	8b 00                	mov    (%eax),%eax
c0107c11:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107c15:	c7 04 24 77 ca 10 c0 	movl   $0xc010ca77,(%esp)
c0107c1c:	e8 c1 9b ff ff       	call   c01017e2 <cprintf>
          check_swap();
c0107c21:	e8 a4 04 00 00       	call   c01080ca <check_swap>
     }

     return r;
c0107c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107c29:	c9                   	leave  
c0107c2a:	c3                   	ret    

c0107c2b <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0107c2b:	55                   	push   %ebp
c0107c2c:	89 e5                	mov    %esp,%ebp
c0107c2e:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0107c31:	a1 34 c0 12 c0       	mov    0xc012c034,%eax
c0107c36:	8b 40 08             	mov    0x8(%eax),%eax
c0107c39:	8b 55 08             	mov    0x8(%ebp),%edx
c0107c3c:	89 14 24             	mov    %edx,(%esp)
c0107c3f:	ff d0                	call   *%eax
}
c0107c41:	c9                   	leave  
c0107c42:	c3                   	ret    

c0107c43 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0107c43:	55                   	push   %ebp
c0107c44:	89 e5                	mov    %esp,%ebp
c0107c46:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0107c49:	a1 34 c0 12 c0       	mov    0xc012c034,%eax
c0107c4e:	8b 40 0c             	mov    0xc(%eax),%eax
c0107c51:	8b 55 08             	mov    0x8(%ebp),%edx
c0107c54:	89 14 24             	mov    %edx,(%esp)
c0107c57:	ff d0                	call   *%eax
}
c0107c59:	c9                   	leave  
c0107c5a:	c3                   	ret    

c0107c5b <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0107c5b:	55                   	push   %ebp
c0107c5c:	89 e5                	mov    %esp,%ebp
c0107c5e:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0107c61:	a1 34 c0 12 c0       	mov    0xc012c034,%eax
c0107c66:	8b 40 10             	mov    0x10(%eax),%eax
c0107c69:	8b 55 14             	mov    0x14(%ebp),%edx
c0107c6c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0107c70:	8b 55 10             	mov    0x10(%ebp),%edx
c0107c73:	89 54 24 08          	mov    %edx,0x8(%esp)
c0107c77:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107c7a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107c7e:	8b 55 08             	mov    0x8(%ebp),%edx
c0107c81:	89 14 24             	mov    %edx,(%esp)
c0107c84:	ff d0                	call   *%eax
}
c0107c86:	c9                   	leave  
c0107c87:	c3                   	ret    

c0107c88 <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0107c88:	55                   	push   %ebp
c0107c89:	89 e5                	mov    %esp,%ebp
c0107c8b:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0107c8e:	a1 34 c0 12 c0       	mov    0xc012c034,%eax
c0107c93:	8b 40 14             	mov    0x14(%eax),%eax
c0107c96:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107c99:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107c9d:	8b 55 08             	mov    0x8(%ebp),%edx
c0107ca0:	89 14 24             	mov    %edx,(%esp)
c0107ca3:	ff d0                	call   *%eax
}
c0107ca5:	c9                   	leave  
c0107ca6:	c3                   	ret    

c0107ca7 <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0107ca7:	55                   	push   %ebp
c0107ca8:	89 e5                	mov    %esp,%ebp
c0107caa:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0107cad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107cb4:	e9 5a 01 00 00       	jmp    c0107e13 <swap_out+0x16c>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0107cb9:	a1 34 c0 12 c0       	mov    0xc012c034,%eax
c0107cbe:	8b 40 18             	mov    0x18(%eax),%eax
c0107cc1:	8b 55 10             	mov    0x10(%ebp),%edx
c0107cc4:	89 54 24 08          	mov    %edx,0x8(%esp)
c0107cc8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0107ccb:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107ccf:	8b 55 08             	mov    0x8(%ebp),%edx
c0107cd2:	89 14 24             	mov    %edx,(%esp)
c0107cd5:	ff d0                	call   *%eax
c0107cd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0107cda:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107cde:	74 18                	je     c0107cf8 <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0107ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107ce3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107ce7:	c7 04 24 8c ca 10 c0 	movl   $0xc010ca8c,(%esp)
c0107cee:	e8 ef 9a ff ff       	call   c01017e2 <cprintf>
c0107cf3:	e9 27 01 00 00       	jmp    c0107e1f <swap_out+0x178>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0107cf8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107cfb:	8b 40 20             	mov    0x20(%eax),%eax
c0107cfe:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0107d01:	8b 45 08             	mov    0x8(%ebp),%eax
c0107d04:	8b 40 0c             	mov    0xc(%eax),%eax
c0107d07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107d0e:	00 
c0107d0f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107d12:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107d16:	89 04 24             	mov    %eax,(%esp)
c0107d19:	e8 25 ed ff ff       	call   c0106a43 <get_pte>
c0107d1e:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0107d21:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107d24:	8b 00                	mov    (%eax),%eax
c0107d26:	83 e0 01             	and    $0x1,%eax
c0107d29:	85 c0                	test   %eax,%eax
c0107d2b:	75 24                	jne    c0107d51 <swap_out+0xaa>
c0107d2d:	c7 44 24 0c b9 ca 10 	movl   $0xc010cab9,0xc(%esp)
c0107d34:	c0 
c0107d35:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0107d3c:	c0 
c0107d3d:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
c0107d44:	00 
c0107d45:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c0107d4c:	e8 1b a4 ff ff       	call   c010216c <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0107d51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107d54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107d57:	8b 52 20             	mov    0x20(%edx),%edx
c0107d5a:	c1 ea 0c             	shr    $0xc,%edx
c0107d5d:	83 c2 01             	add    $0x1,%edx
c0107d60:	c1 e2 08             	shl    $0x8,%edx
c0107d63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107d67:	89 14 24             	mov    %edx,(%esp)
c0107d6a:	e8 7a 1d 00 00       	call   c0109ae9 <swapfs_write>
c0107d6f:	85 c0                	test   %eax,%eax
c0107d71:	74 34                	je     c0107da7 <swap_out+0x100>
                    cprintf("SWAP: failed to save\n");
c0107d73:	c7 04 24 e3 ca 10 c0 	movl   $0xc010cae3,(%esp)
c0107d7a:	e8 63 9a ff ff       	call   c01017e2 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0107d7f:	a1 34 c0 12 c0       	mov    0xc012c034,%eax
c0107d84:	8b 40 10             	mov    0x10(%eax),%eax
c0107d87:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107d8a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0107d91:	00 
c0107d92:	89 54 24 08          	mov    %edx,0x8(%esp)
c0107d96:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107d99:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107d9d:	8b 55 08             	mov    0x8(%ebp),%edx
c0107da0:	89 14 24             	mov    %edx,(%esp)
c0107da3:	ff d0                	call   *%eax
c0107da5:	eb 68                	jmp    c0107e0f <swap_out+0x168>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0107da7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107daa:	8b 40 20             	mov    0x20(%eax),%eax
c0107dad:	c1 e8 0c             	shr    $0xc,%eax
c0107db0:	83 c0 01             	add    $0x1,%eax
c0107db3:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0107db7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107dba:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107dc1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0107dc5:	c7 04 24 fc ca 10 c0 	movl   $0xc010cafc,(%esp)
c0107dcc:	e8 11 9a ff ff       	call   c01017e2 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0107dd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107dd4:	8b 40 20             	mov    0x20(%eax),%eax
c0107dd7:	c1 e8 0c             	shr    $0xc,%eax
c0107dda:	83 c0 01             	add    $0x1,%eax
c0107ddd:	c1 e0 08             	shl    $0x8,%eax
c0107de0:	89 c2                	mov    %eax,%edx
c0107de2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107de5:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0107de7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107dea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107df1:	00 
c0107df2:	89 04 24             	mov    %eax,(%esp)
c0107df5:	e8 c0 e5 ff ff       	call   c01063ba <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0107dfa:	8b 45 08             	mov    0x8(%ebp),%eax
c0107dfd:	8b 40 0c             	mov    0xc(%eax),%eax
c0107e00:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0107e03:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107e07:	89 04 24             	mov    %eax,(%esp)
c0107e0a:	e8 23 ef ff ff       	call   c0106d32 <tlb_invalidate>

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c0107e0f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0107e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107e16:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0107e19:	0f 85 9a fe ff ff    	jne    c0107cb9 <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c0107e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0107e22:	c9                   	leave  
c0107e23:	c3                   	ret    

c0107e24 <swap_in>:

int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0107e24:	55                   	push   %ebp
c0107e25:	89 e5                	mov    %esp,%ebp
c0107e27:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0107e2a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107e31:	e8 19 e5 ff ff       	call   c010634f <alloc_pages>
c0107e36:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0107e39:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107e3d:	75 24                	jne    c0107e63 <swap_in+0x3f>
c0107e3f:	c7 44 24 0c 3c cb 10 	movl   $0xc010cb3c,0xc(%esp)
c0107e46:	c0 
c0107e47:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0107e4e:	c0 
c0107e4f:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
c0107e56:	00 
c0107e57:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c0107e5e:	e8 09 a3 ff ff       	call   c010216c <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0107e63:	8b 45 08             	mov    0x8(%ebp),%eax
c0107e66:	8b 40 0c             	mov    0xc(%eax),%eax
c0107e69:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107e70:	00 
c0107e71:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107e74:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107e78:	89 04 24             	mov    %eax,(%esp)
c0107e7b:	e8 c3 eb ff ff       	call   c0106a43 <get_pte>
c0107e80:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0107e83:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107e86:	8b 00                	mov    (%eax),%eax
c0107e88:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107e8b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107e8f:	89 04 24             	mov    %eax,(%esp)
c0107e92:	e8 e0 1b 00 00       	call   c0109a77 <swapfs_read>
c0107e97:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107e9a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107e9e:	74 2a                	je     c0107eca <swap_in+0xa6>
     {
        assert(r!=0);
c0107ea0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107ea4:	75 24                	jne    c0107eca <swap_in+0xa6>
c0107ea6:	c7 44 24 0c 49 cb 10 	movl   $0xc010cb49,0xc(%esp)
c0107ead:	c0 
c0107eae:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0107eb5:	c0 
c0107eb6:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
c0107ebd:	00 
c0107ebe:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c0107ec5:	e8 a2 a2 ff ff       	call   c010216c <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0107eca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107ecd:	8b 00                	mov    (%eax),%eax
c0107ecf:	c1 e8 08             	shr    $0x8,%eax
c0107ed2:	89 c2                	mov    %eax,%edx
c0107ed4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107ed7:	89 44 24 08          	mov    %eax,0x8(%esp)
c0107edb:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107edf:	c7 04 24 50 cb 10 c0 	movl   $0xc010cb50,(%esp)
c0107ee6:	e8 f7 98 ff ff       	call   c01017e2 <cprintf>
     *ptr_result=result;
c0107eeb:	8b 45 10             	mov    0x10(%ebp),%eax
c0107eee:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0107ef1:	89 10                	mov    %edx,(%eax)
     return 0;
c0107ef3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107ef8:	c9                   	leave  
c0107ef9:	c3                   	ret    

c0107efa <check_content_set>:



static inline void
check_content_set(void)
{
c0107efa:	55                   	push   %ebp
c0107efb:	89 e5                	mov    %esp,%ebp
c0107efd:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0107f00:	b8 00 10 00 00       	mov    $0x1000,%eax
c0107f05:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0107f08:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0107f0d:	83 f8 01             	cmp    $0x1,%eax
c0107f10:	74 24                	je     c0107f36 <check_content_set+0x3c>
c0107f12:	c7 44 24 0c 8e cb 10 	movl   $0xc010cb8e,0xc(%esp)
c0107f19:	c0 
c0107f1a:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0107f21:	c0 
c0107f22:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
c0107f29:	00 
c0107f2a:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c0107f31:	e8 36 a2 ff ff       	call   c010216c <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0107f36:	b8 10 10 00 00       	mov    $0x1010,%eax
c0107f3b:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0107f3e:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0107f43:	83 f8 01             	cmp    $0x1,%eax
c0107f46:	74 24                	je     c0107f6c <check_content_set+0x72>
c0107f48:	c7 44 24 0c 8e cb 10 	movl   $0xc010cb8e,0xc(%esp)
c0107f4f:	c0 
c0107f50:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0107f57:	c0 
c0107f58:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0107f5f:	00 
c0107f60:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c0107f67:	e8 00 a2 ff ff       	call   c010216c <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0107f6c:	b8 00 20 00 00       	mov    $0x2000,%eax
c0107f71:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0107f74:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0107f79:	83 f8 02             	cmp    $0x2,%eax
c0107f7c:	74 24                	je     c0107fa2 <check_content_set+0xa8>
c0107f7e:	c7 44 24 0c 9d cb 10 	movl   $0xc010cb9d,0xc(%esp)
c0107f85:	c0 
c0107f86:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0107f8d:	c0 
c0107f8e:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0107f95:	00 
c0107f96:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c0107f9d:	e8 ca a1 ff ff       	call   c010216c <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c0107fa2:	b8 10 20 00 00       	mov    $0x2010,%eax
c0107fa7:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0107faa:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0107faf:	83 f8 02             	cmp    $0x2,%eax
c0107fb2:	74 24                	je     c0107fd8 <check_content_set+0xde>
c0107fb4:	c7 44 24 0c 9d cb 10 	movl   $0xc010cb9d,0xc(%esp)
c0107fbb:	c0 
c0107fbc:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0107fc3:	c0 
c0107fc4:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0107fcb:	00 
c0107fcc:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c0107fd3:	e8 94 a1 ff ff       	call   c010216c <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0107fd8:	b8 00 30 00 00       	mov    $0x3000,%eax
c0107fdd:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0107fe0:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0107fe5:	83 f8 03             	cmp    $0x3,%eax
c0107fe8:	74 24                	je     c010800e <check_content_set+0x114>
c0107fea:	c7 44 24 0c ac cb 10 	movl   $0xc010cbac,0xc(%esp)
c0107ff1:	c0 
c0107ff2:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0107ff9:	c0 
c0107ffa:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0108001:	00 
c0108002:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c0108009:	e8 5e a1 ff ff       	call   c010216c <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c010800e:	b8 10 30 00 00       	mov    $0x3010,%eax
c0108013:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0108016:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c010801b:	83 f8 03             	cmp    $0x3,%eax
c010801e:	74 24                	je     c0108044 <check_content_set+0x14a>
c0108020:	c7 44 24 0c ac cb 10 	movl   $0xc010cbac,0xc(%esp)
c0108027:	c0 
c0108028:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c010802f:	c0 
c0108030:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0108037:	00 
c0108038:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c010803f:	e8 28 a1 ff ff       	call   c010216c <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c0108044:	b8 00 40 00 00       	mov    $0x4000,%eax
c0108049:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c010804c:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0108051:	83 f8 04             	cmp    $0x4,%eax
c0108054:	74 24                	je     c010807a <check_content_set+0x180>
c0108056:	c7 44 24 0c bb cb 10 	movl   $0xc010cbbb,0xc(%esp)
c010805d:	c0 
c010805e:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0108065:	c0 
c0108066:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c010806d:	00 
c010806e:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c0108075:	e8 f2 a0 ff ff       	call   c010216c <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c010807a:	b8 10 40 00 00       	mov    $0x4010,%eax
c010807f:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c0108082:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0108087:	83 f8 04             	cmp    $0x4,%eax
c010808a:	74 24                	je     c01080b0 <check_content_set+0x1b6>
c010808c:	c7 44 24 0c bb cb 10 	movl   $0xc010cbbb,0xc(%esp)
c0108093:	c0 
c0108094:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c010809b:	c0 
c010809c:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c01080a3:	00 
c01080a4:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c01080ab:	e8 bc a0 ff ff       	call   c010216c <__panic>
}
c01080b0:	c9                   	leave  
c01080b1:	c3                   	ret    

c01080b2 <check_content_access>:

static inline int
check_content_access(void)
{
c01080b2:	55                   	push   %ebp
c01080b3:	89 e5                	mov    %esp,%ebp
c01080b5:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c01080b8:	a1 34 c0 12 c0       	mov    0xc012c034,%eax
c01080bd:	8b 40 1c             	mov    0x1c(%eax),%eax
c01080c0:	ff d0                	call   *%eax
c01080c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c01080c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01080c8:	c9                   	leave  
c01080c9:	c3                   	ret    

c01080ca <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c01080ca:	55                   	push   %ebp
c01080cb:	89 e5                	mov    %esp,%ebp
c01080cd:	53                   	push   %ebx
c01080ce:	83 ec 74             	sub    $0x74,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c01080d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01080d8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c01080df:	c7 45 e8 78 e0 12 c0 	movl   $0xc012e078,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c01080e6:	eb 6b                	jmp    c0108153 <check_swap+0x89>
        struct Page *p = le2page(le, page_link);
c01080e8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01080eb:	83 e8 10             	sub    $0x10,%eax
c01080ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c01080f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01080f4:	83 c0 04             	add    $0x4,%eax
c01080f7:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c01080fe:	89 45 c0             	mov    %eax,-0x40(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0108101:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0108104:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0108107:	0f a3 10             	bt     %edx,(%eax)
c010810a:	19 c0                	sbb    %eax,%eax
c010810c:	89 45 bc             	mov    %eax,-0x44(%ebp)
    return oldbit != 0;
c010810f:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0108113:	0f 95 c0             	setne  %al
c0108116:	0f b6 c0             	movzbl %al,%eax
c0108119:	85 c0                	test   %eax,%eax
c010811b:	75 24                	jne    c0108141 <check_swap+0x77>
c010811d:	c7 44 24 0c ca cb 10 	movl   $0xc010cbca,0xc(%esp)
c0108124:	c0 
c0108125:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c010812c:	c0 
c010812d:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c0108134:	00 
c0108135:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c010813c:	e8 2b a0 ff ff       	call   c010216c <__panic>
        count ++, total += p->property;
c0108141:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0108145:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108148:	8b 50 08             	mov    0x8(%eax),%edx
c010814b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010814e:	01 d0                	add    %edx,%eax
c0108150:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108153:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108156:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0108159:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010815c:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c010815f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108162:	81 7d e8 78 e0 12 c0 	cmpl   $0xc012e078,-0x18(%ebp)
c0108169:	0f 85 79 ff ff ff    	jne    c01080e8 <check_swap+0x1e>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c010816f:	8b 5d f0             	mov    -0x10(%ebp),%ebx
c0108172:	e8 75 e2 ff ff       	call   c01063ec <nr_free_pages>
c0108177:	39 c3                	cmp    %eax,%ebx
c0108179:	74 24                	je     c010819f <check_swap+0xd5>
c010817b:	c7 44 24 0c da cb 10 	movl   $0xc010cbda,0xc(%esp)
c0108182:	c0 
c0108183:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c010818a:	c0 
c010818b:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0108192:	00 
c0108193:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c010819a:	e8 cd 9f ff ff       	call   c010216c <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c010819f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01081a2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01081a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01081a9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01081ad:	c7 04 24 f4 cb 10 c0 	movl   $0xc010cbf4,(%esp)
c01081b4:	e8 29 96 ff ff       	call   c01017e2 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c01081b9:	e8 1d 0b 00 00       	call   c0108cdb <mm_create>
c01081be:	89 45 e0             	mov    %eax,-0x20(%ebp)
     assert(mm != NULL);
c01081c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01081c5:	75 24                	jne    c01081eb <check_swap+0x121>
c01081c7:	c7 44 24 0c 1a cc 10 	movl   $0xc010cc1a,0xc(%esp)
c01081ce:	c0 
c01081cf:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c01081d6:	c0 
c01081d7:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c01081de:	00 
c01081df:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c01081e6:	e8 81 9f ff ff       	call   c010216c <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c01081eb:	a1 6c e1 12 c0       	mov    0xc012e16c,%eax
c01081f0:	85 c0                	test   %eax,%eax
c01081f2:	74 24                	je     c0108218 <check_swap+0x14e>
c01081f4:	c7 44 24 0c 25 cc 10 	movl   $0xc010cc25,0xc(%esp)
c01081fb:	c0 
c01081fc:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0108203:	c0 
c0108204:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
c010820b:	00 
c010820c:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c0108213:	e8 54 9f ff ff       	call   c010216c <__panic>

     check_mm_struct = mm;
c0108218:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010821b:	a3 6c e1 12 c0       	mov    %eax,0xc012e16c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c0108220:	8b 15 00 8a 12 c0    	mov    0xc0128a00,%edx
c0108226:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108229:	89 50 0c             	mov    %edx,0xc(%eax)
c010822c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010822f:	8b 40 0c             	mov    0xc(%eax),%eax
c0108232:	89 45 dc             	mov    %eax,-0x24(%ebp)
     assert(pgdir[0] == 0);
c0108235:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108238:	8b 00                	mov    (%eax),%eax
c010823a:	85 c0                	test   %eax,%eax
c010823c:	74 24                	je     c0108262 <check_swap+0x198>
c010823e:	c7 44 24 0c 3d cc 10 	movl   $0xc010cc3d,0xc(%esp)
c0108245:	c0 
c0108246:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c010824d:	c0 
c010824e:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0108255:	00 
c0108256:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c010825d:	e8 0a 9f ff ff       	call   c010216c <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c0108262:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c0108269:	00 
c010826a:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c0108271:	00 
c0108272:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c0108279:	e8 d5 0a 00 00       	call   c0108d53 <vma_create>
c010827e:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(vma != NULL);
c0108281:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0108285:	75 24                	jne    c01082ab <check_swap+0x1e1>
c0108287:	c7 44 24 0c 4b cc 10 	movl   $0xc010cc4b,0xc(%esp)
c010828e:	c0 
c010828f:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0108296:	c0 
c0108297:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c010829e:	00 
c010829f:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c01082a6:	e8 c1 9e ff ff       	call   c010216c <__panic>

     insert_vma_struct(mm, vma);
c01082ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01082ae:	89 44 24 04          	mov    %eax,0x4(%esp)
c01082b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01082b5:	89 04 24             	mov    %eax,(%esp)
c01082b8:	e8 26 0c 00 00       	call   c0108ee3 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c01082bd:	c7 04 24 58 cc 10 c0 	movl   $0xc010cc58,(%esp)
c01082c4:	e8 19 95 ff ff       	call   c01017e2 <cprintf>
     pte_t *temp_ptep=NULL;
c01082c9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c01082d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01082d3:	8b 40 0c             	mov    0xc(%eax),%eax
c01082d6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01082dd:	00 
c01082de:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01082e5:	00 
c01082e6:	89 04 24             	mov    %eax,(%esp)
c01082e9:	e8 55 e7 ff ff       	call   c0106a43 <get_pte>
c01082ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(temp_ptep!= NULL);
c01082f1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c01082f5:	75 24                	jne    c010831b <check_swap+0x251>
c01082f7:	c7 44 24 0c 8c cc 10 	movl   $0xc010cc8c,0xc(%esp)
c01082fe:	c0 
c01082ff:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0108306:	c0 
c0108307:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c010830e:	00 
c010830f:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c0108316:	e8 51 9e ff ff       	call   c010216c <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c010831b:	c7 04 24 a0 cc 10 c0 	movl   $0xc010cca0,(%esp)
c0108322:	e8 bb 94 ff ff       	call   c01017e2 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0108327:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010832e:	e9 a3 00 00 00       	jmp    c01083d6 <check_swap+0x30c>
          check_rp[i] = alloc_page();
c0108333:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010833a:	e8 10 e0 ff ff       	call   c010634f <alloc_pages>
c010833f:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108342:	89 04 95 a0 e0 12 c0 	mov    %eax,-0x3fed1f60(,%edx,4)
          assert(check_rp[i] != NULL );
c0108349:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010834c:	8b 04 85 a0 e0 12 c0 	mov    -0x3fed1f60(,%eax,4),%eax
c0108353:	85 c0                	test   %eax,%eax
c0108355:	75 24                	jne    c010837b <check_swap+0x2b1>
c0108357:	c7 44 24 0c c4 cc 10 	movl   $0xc010ccc4,0xc(%esp)
c010835e:	c0 
c010835f:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0108366:	c0 
c0108367:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c010836e:	00 
c010836f:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c0108376:	e8 f1 9d ff ff       	call   c010216c <__panic>
          assert(!PageProperty(check_rp[i]));
c010837b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010837e:	8b 04 85 a0 e0 12 c0 	mov    -0x3fed1f60(,%eax,4),%eax
c0108385:	83 c0 04             	add    $0x4,%eax
c0108388:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
c010838f:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0108392:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0108395:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0108398:	0f a3 10             	bt     %edx,(%eax)
c010839b:	19 c0                	sbb    %eax,%eax
c010839d:	89 45 ac             	mov    %eax,-0x54(%ebp)
    return oldbit != 0;
c01083a0:	83 7d ac 00          	cmpl   $0x0,-0x54(%ebp)
c01083a4:	0f 95 c0             	setne  %al
c01083a7:	0f b6 c0             	movzbl %al,%eax
c01083aa:	85 c0                	test   %eax,%eax
c01083ac:	74 24                	je     c01083d2 <check_swap+0x308>
c01083ae:	c7 44 24 0c d8 cc 10 	movl   $0xc010ccd8,0xc(%esp)
c01083b5:	c0 
c01083b6:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c01083bd:	c0 
c01083be:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c01083c5:	00 
c01083c6:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c01083cd:	e8 9a 9d ff ff       	call   c010216c <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01083d2:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01083d6:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01083da:	0f 8e 53 ff ff ff    	jle    c0108333 <check_swap+0x269>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c01083e0:	a1 78 e0 12 c0       	mov    0xc012e078,%eax
c01083e5:	8b 15 7c e0 12 c0    	mov    0xc012e07c,%edx
c01083eb:	89 45 98             	mov    %eax,-0x68(%ebp)
c01083ee:	89 55 9c             	mov    %edx,-0x64(%ebp)
c01083f1:	c7 45 a8 78 e0 12 c0 	movl   $0xc012e078,-0x58(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01083f8:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01083fb:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01083fe:	89 50 04             	mov    %edx,0x4(%eax)
c0108401:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0108404:	8b 50 04             	mov    0x4(%eax),%edx
c0108407:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010840a:	89 10                	mov    %edx,(%eax)
c010840c:	c7 45 a4 78 e0 12 c0 	movl   $0xc012e078,-0x5c(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0108413:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0108416:	8b 40 04             	mov    0x4(%eax),%eax
c0108419:	39 45 a4             	cmp    %eax,-0x5c(%ebp)
c010841c:	0f 94 c0             	sete   %al
c010841f:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0108422:	85 c0                	test   %eax,%eax
c0108424:	75 24                	jne    c010844a <check_swap+0x380>
c0108426:	c7 44 24 0c f3 cc 10 	movl   $0xc010ccf3,0xc(%esp)
c010842d:	c0 
c010842e:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0108435:	c0 
c0108436:	c7 44 24 04 de 00 00 	movl   $0xde,0x4(%esp)
c010843d:	00 
c010843e:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c0108445:	e8 22 9d ff ff       	call   c010216c <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c010844a:	a1 80 e0 12 c0       	mov    0xc012e080,%eax
c010844f:	89 45 d0             	mov    %eax,-0x30(%ebp)
     nr_free = 0;
c0108452:	c7 05 80 e0 12 c0 00 	movl   $0x0,0xc012e080
c0108459:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010845c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0108463:	eb 1e                	jmp    c0108483 <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c0108465:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108468:	8b 04 85 a0 e0 12 c0 	mov    -0x3fed1f60(,%eax,4),%eax
c010846f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0108476:	00 
c0108477:	89 04 24             	mov    %eax,(%esp)
c010847a:	e8 3b df ff ff       	call   c01063ba <free_pages>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c010847f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c0108483:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0108487:	7e dc                	jle    c0108465 <check_swap+0x39b>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c0108489:	a1 80 e0 12 c0       	mov    0xc012e080,%eax
c010848e:	83 f8 04             	cmp    $0x4,%eax
c0108491:	74 24                	je     c01084b7 <check_swap+0x3ed>
c0108493:	c7 44 24 0c 0c cd 10 	movl   $0xc010cd0c,0xc(%esp)
c010849a:	c0 
c010849b:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c01084a2:	c0 
c01084a3:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c01084aa:	00 
c01084ab:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c01084b2:	e8 b5 9c ff ff       	call   c010216c <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c01084b7:	c7 04 24 30 cd 10 c0 	movl   $0xc010cd30,(%esp)
c01084be:	e8 1f 93 ff ff       	call   c01017e2 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c01084c3:	c7 05 38 c0 12 c0 00 	movl   $0x0,0xc012c038
c01084ca:	00 00 00 
     
     check_content_set();
c01084cd:	e8 28 fa ff ff       	call   c0107efa <check_content_set>
     assert( nr_free == 0);         
c01084d2:	a1 80 e0 12 c0       	mov    0xc012e080,%eax
c01084d7:	85 c0                	test   %eax,%eax
c01084d9:	74 24                	je     c01084ff <check_swap+0x435>
c01084db:	c7 44 24 0c 57 cd 10 	movl   $0xc010cd57,0xc(%esp)
c01084e2:	c0 
c01084e3:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c01084ea:	c0 
c01084eb:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c01084f2:	00 
c01084f3:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c01084fa:	e8 6d 9c ff ff       	call   c010216c <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c01084ff:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0108506:	eb 26                	jmp    c010852e <check_swap+0x464>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0108508:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010850b:	c7 04 85 c0 e0 12 c0 	movl   $0xffffffff,-0x3fed1f40(,%eax,4)
c0108512:	ff ff ff ff 
c0108516:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108519:	8b 14 85 c0 e0 12 c0 	mov    -0x3fed1f40(,%eax,4),%edx
c0108520:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108523:	89 14 85 00 e1 12 c0 	mov    %edx,-0x3fed1f00(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c010852a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c010852e:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c0108532:	7e d4                	jle    c0108508 <check_swap+0x43e>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0108534:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010853b:	e9 eb 00 00 00       	jmp    c010862b <check_swap+0x561>
         check_ptep[i]=0;
c0108540:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108543:	c7 04 85 54 e1 12 c0 	movl   $0x0,-0x3fed1eac(,%eax,4)
c010854a:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c010854e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108551:	83 c0 01             	add    $0x1,%eax
c0108554:	c1 e0 0c             	shl    $0xc,%eax
c0108557:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010855e:	00 
c010855f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108563:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108566:	89 04 24             	mov    %eax,(%esp)
c0108569:	e8 d5 e4 ff ff       	call   c0106a43 <get_pte>
c010856e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108571:	89 04 95 54 e1 12 c0 	mov    %eax,-0x3fed1eac(,%edx,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c0108578:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010857b:	8b 04 85 54 e1 12 c0 	mov    -0x3fed1eac(,%eax,4),%eax
c0108582:	85 c0                	test   %eax,%eax
c0108584:	75 24                	jne    c01085aa <check_swap+0x4e0>
c0108586:	c7 44 24 0c 64 cd 10 	movl   $0xc010cd64,0xc(%esp)
c010858d:	c0 
c010858e:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0108595:	c0 
c0108596:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c010859d:	00 
c010859e:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c01085a5:	e8 c2 9b ff ff       	call   c010216c <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c01085aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085ad:	8b 04 85 54 e1 12 c0 	mov    -0x3fed1eac(,%eax,4),%eax
c01085b4:	8b 00                	mov    (%eax),%eax
c01085b6:	89 04 24             	mov    %eax,(%esp)
c01085b9:	e8 9f f5 ff ff       	call   c0107b5d <pte2page>
c01085be:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01085c1:	8b 14 95 a0 e0 12 c0 	mov    -0x3fed1f60(,%edx,4),%edx
c01085c8:	39 d0                	cmp    %edx,%eax
c01085ca:	74 24                	je     c01085f0 <check_swap+0x526>
c01085cc:	c7 44 24 0c 7c cd 10 	movl   $0xc010cd7c,0xc(%esp)
c01085d3:	c0 
c01085d4:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c01085db:	c0 
c01085dc:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c01085e3:	00 
c01085e4:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c01085eb:	e8 7c 9b ff ff       	call   c010216c <__panic>
         assert((*check_ptep[i] & PTE_P));          
c01085f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01085f3:	8b 04 85 54 e1 12 c0 	mov    -0x3fed1eac(,%eax,4),%eax
c01085fa:	8b 00                	mov    (%eax),%eax
c01085fc:	83 e0 01             	and    $0x1,%eax
c01085ff:	85 c0                	test   %eax,%eax
c0108601:	75 24                	jne    c0108627 <check_swap+0x55d>
c0108603:	c7 44 24 0c a4 cd 10 	movl   $0xc010cda4,0xc(%esp)
c010860a:	c0 
c010860b:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c0108612:	c0 
c0108613:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c010861a:	00 
c010861b:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c0108622:	e8 45 9b ff ff       	call   c010216c <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0108627:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c010862b:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010862f:	0f 8e 0b ff ff ff    	jle    c0108540 <check_swap+0x476>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c0108635:	c7 04 24 c0 cd 10 c0 	movl   $0xc010cdc0,(%esp)
c010863c:	e8 a1 91 ff ff       	call   c01017e2 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c0108641:	e8 6c fa ff ff       	call   c01080b2 <check_content_access>
c0108646:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(ret==0);
c0108649:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c010864d:	74 24                	je     c0108673 <check_swap+0x5a9>
c010864f:	c7 44 24 0c e6 cd 10 	movl   $0xc010cde6,0xc(%esp)
c0108656:	c0 
c0108657:	c7 44 24 08 ce ca 10 	movl   $0xc010cace,0x8(%esp)
c010865e:	c0 
c010865f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0108666:	00 
c0108667:	c7 04 24 68 ca 10 c0 	movl   $0xc010ca68,(%esp)
c010866e:	e8 f9 9a ff ff       	call   c010216c <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0108673:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010867a:	eb 1e                	jmp    c010869a <check_swap+0x5d0>
         free_pages(check_rp[i],1);
c010867c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010867f:	8b 04 85 a0 e0 12 c0 	mov    -0x3fed1f60(,%eax,4),%eax
c0108686:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010868d:	00 
c010868e:	89 04 24             	mov    %eax,(%esp)
c0108691:	e8 24 dd ff ff       	call   c01063ba <free_pages>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0108696:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c010869a:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010869e:	7e dc                	jle    c010867c <check_swap+0x5b2>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c01086a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01086a3:	89 04 24             	mov    %eax,(%esp)
c01086a6:	e8 68 09 00 00       	call   c0109013 <mm_destroy>
         
     nr_free = nr_free_store;
c01086ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01086ae:	a3 80 e0 12 c0       	mov    %eax,0xc012e080
     free_list = free_list_store;
c01086b3:	8b 45 98             	mov    -0x68(%ebp),%eax
c01086b6:	8b 55 9c             	mov    -0x64(%ebp),%edx
c01086b9:	a3 78 e0 12 c0       	mov    %eax,0xc012e078
c01086be:	89 15 7c e0 12 c0    	mov    %edx,0xc012e07c

     
     le = &free_list;
c01086c4:	c7 45 e8 78 e0 12 c0 	movl   $0xc012e078,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c01086cb:	eb 1d                	jmp    c01086ea <check_swap+0x620>
         struct Page *p = le2page(le, page_link);
c01086cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01086d0:	83 e8 10             	sub    $0x10,%eax
c01086d3:	89 45 c8             	mov    %eax,-0x38(%ebp)
         count --, total -= p->property;
c01086d6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c01086da:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01086dd:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01086e0:	8b 40 08             	mov    0x8(%eax),%eax
c01086e3:	29 c2                	sub    %eax,%edx
c01086e5:	89 d0                	mov    %edx,%eax
c01086e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01086ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01086ed:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01086f0:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01086f3:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c01086f6:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01086f9:	81 7d e8 78 e0 12 c0 	cmpl   $0xc012e078,-0x18(%ebp)
c0108700:	75 cb                	jne    c01086cd <check_swap+0x603>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c0108702:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108705:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108709:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010870c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108710:	c7 04 24 ed cd 10 c0 	movl   $0xc010cded,(%esp)
c0108717:	e8 c6 90 ff ff       	call   c01017e2 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c010871c:	c7 04 24 07 ce 10 c0 	movl   $0xc010ce07,(%esp)
c0108723:	e8 ba 90 ff ff       	call   c01017e2 <cprintf>
}
c0108728:	83 c4 74             	add    $0x74,%esp
c010872b:	5b                   	pop    %ebx
c010872c:	5d                   	pop    %ebp
c010872d:	c3                   	ret    

c010872e <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c010872e:	55                   	push   %ebp
c010872f:	89 e5                	mov    %esp,%ebp
c0108731:	83 ec 10             	sub    $0x10,%esp
c0108734:	c7 45 fc 64 e1 12 c0 	movl   $0xc012e164,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010873b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010873e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0108741:	89 50 04             	mov    %edx,0x4(%eax)
c0108744:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108747:	8b 50 04             	mov    0x4(%eax),%edx
c010874a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010874d:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c010874f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108752:	c7 40 14 64 e1 12 c0 	movl   $0xc012e164,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c0108759:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010875e:	c9                   	leave  
c010875f:	c3                   	ret    

c0108760 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0108760:	55                   	push   %ebp
c0108761:	89 e5                	mov    %esp,%ebp
c0108763:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0108766:	8b 45 08             	mov    0x8(%ebp),%eax
c0108769:	8b 40 14             	mov    0x14(%eax),%eax
c010876c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c010876f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108772:	83 c0 18             	add    $0x18,%eax
c0108775:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0108778:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010877c:	74 06                	je     c0108784 <_fifo_map_swappable+0x24>
c010877e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108782:	75 24                	jne    c01087a8 <_fifo_map_swappable+0x48>
c0108784:	c7 44 24 0c 20 ce 10 	movl   $0xc010ce20,0xc(%esp)
c010878b:	c0 
c010878c:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c0108793:	c0 
c0108794:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c010879b:	00 
c010879c:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c01087a3:	e8 c4 99 ff ff       	call   c010216c <__panic>
c01087a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01087ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01087ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01087b1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01087b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01087b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01087ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01087bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01087c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01087c3:	8b 40 04             	mov    0x4(%eax),%eax
c01087c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01087c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
c01087cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01087cf:	89 55 d8             	mov    %edx,-0x28(%ebp)
c01087d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01087d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01087d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01087db:	89 10                	mov    %edx,(%eax)
c01087dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01087e0:	8b 10                	mov    (%eax),%edx
c01087e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01087e5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01087e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01087eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01087ee:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01087f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01087f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01087f7:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c01087f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01087fe:	c9                   	leave  
c01087ff:	c3                   	ret    

c0108800 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0108800:	55                   	push   %ebp
c0108801:	89 e5                	mov    %esp,%ebp
c0108803:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0108806:	8b 45 08             	mov    0x8(%ebp),%eax
c0108809:	8b 40 14             	mov    0x14(%eax),%eax
c010880c:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c010880f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108813:	75 24                	jne    c0108839 <_fifo_swap_out_victim+0x39>
c0108815:	c7 44 24 0c 67 ce 10 	movl   $0xc010ce67,0xc(%esp)
c010881c:	c0 
c010881d:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c0108824:	c0 
c0108825:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c010882c:	00 
c010882d:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c0108834:	e8 33 99 ff ff       	call   c010216c <__panic>
     assert(in_tick==0);
c0108839:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010883d:	74 24                	je     c0108863 <_fifo_swap_out_victim+0x63>
c010883f:	c7 44 24 0c 74 ce 10 	movl   $0xc010ce74,0xc(%esp)
c0108846:	c0 
c0108847:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c010884e:	c0 
c010884f:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c0108856:	00 
c0108857:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c010885e:	e8 09 99 ff ff       	call   c010216c <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  assign the value of *ptr_page to the addr of this page
     /* Select the tail */
     list_entry_t *le = head->prev;
c0108863:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108866:	8b 00                	mov    (%eax),%eax
c0108868:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c010886b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010886e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108871:	75 24                	jne    c0108897 <_fifo_swap_out_victim+0x97>
c0108873:	c7 44 24 0c 7f ce 10 	movl   $0xc010ce7f,0xc(%esp)
c010887a:	c0 
c010887b:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c0108882:	c0 
c0108883:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
c010888a:	00 
c010888b:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c0108892:	e8 d5 98 ff ff       	call   c010216c <__panic>
     struct Page *p = le2page(le, pra_page_link);
c0108897:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010889a:	83 e8 18             	sub    $0x18,%eax
c010889d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01088a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01088a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01088a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01088a9:	8b 40 04             	mov    0x4(%eax),%eax
c01088ac:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01088af:	8b 12                	mov    (%edx),%edx
c01088b1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01088b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01088b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01088ba:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01088bd:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01088c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01088c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01088c6:	89 10                	mov    %edx,(%eax)
     list_del(le);
     assert(p !=NULL);
c01088c8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01088cc:	75 24                	jne    c01088f2 <_fifo_swap_out_victim+0xf2>
c01088ce:	c7 44 24 0c 88 ce 10 	movl   $0xc010ce88,0xc(%esp)
c01088d5:	c0 
c01088d6:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c01088dd:	c0 
c01088de:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
c01088e5:	00 
c01088e6:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c01088ed:	e8 7a 98 ff ff       	call   c010216c <__panic>
     *ptr_page = p;
c01088f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01088f5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01088f8:	89 10                	mov    %edx,(%eax)
     return 0;
c01088fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01088ff:	c9                   	leave  
c0108900:	c3                   	ret    

c0108901 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0108901:	55                   	push   %ebp
c0108902:	89 e5                	mov    %esp,%ebp
c0108904:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c0108907:	c7 04 24 94 ce 10 c0 	movl   $0xc010ce94,(%esp)
c010890e:	e8 cf 8e ff ff       	call   c01017e2 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0108913:	b8 00 30 00 00       	mov    $0x3000,%eax
c0108918:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c010891b:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0108920:	83 f8 04             	cmp    $0x4,%eax
c0108923:	74 24                	je     c0108949 <_fifo_check_swap+0x48>
c0108925:	c7 44 24 0c ba ce 10 	movl   $0xc010ceba,0xc(%esp)
c010892c:	c0 
c010892d:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c0108934:	c0 
c0108935:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
c010893c:	00 
c010893d:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c0108944:	e8 23 98 ff ff       	call   c010216c <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0108949:	c7 04 24 cc ce 10 c0 	movl   $0xc010cecc,(%esp)
c0108950:	e8 8d 8e ff ff       	call   c01017e2 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0108955:	b8 00 10 00 00       	mov    $0x1000,%eax
c010895a:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c010895d:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0108962:	83 f8 04             	cmp    $0x4,%eax
c0108965:	74 24                	je     c010898b <_fifo_check_swap+0x8a>
c0108967:	c7 44 24 0c ba ce 10 	movl   $0xc010ceba,0xc(%esp)
c010896e:	c0 
c010896f:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c0108976:	c0 
c0108977:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
c010897e:	00 
c010897f:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c0108986:	e8 e1 97 ff ff       	call   c010216c <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c010898b:	c7 04 24 f4 ce 10 c0 	movl   $0xc010cef4,(%esp)
c0108992:	e8 4b 8e ff ff       	call   c01017e2 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0108997:	b8 00 40 00 00       	mov    $0x4000,%eax
c010899c:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c010899f:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c01089a4:	83 f8 04             	cmp    $0x4,%eax
c01089a7:	74 24                	je     c01089cd <_fifo_check_swap+0xcc>
c01089a9:	c7 44 24 0c ba ce 10 	movl   $0xc010ceba,0xc(%esp)
c01089b0:	c0 
c01089b1:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c01089b8:	c0 
c01089b9:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c01089c0:	00 
c01089c1:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c01089c8:	e8 9f 97 ff ff       	call   c010216c <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c01089cd:	c7 04 24 1c cf 10 c0 	movl   $0xc010cf1c,(%esp)
c01089d4:	e8 09 8e ff ff       	call   c01017e2 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c01089d9:	b8 00 20 00 00       	mov    $0x2000,%eax
c01089de:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c01089e1:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c01089e6:	83 f8 04             	cmp    $0x4,%eax
c01089e9:	74 24                	je     c0108a0f <_fifo_check_swap+0x10e>
c01089eb:	c7 44 24 0c ba ce 10 	movl   $0xc010ceba,0xc(%esp)
c01089f2:	c0 
c01089f3:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c01089fa:	c0 
c01089fb:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0108a02:	00 
c0108a03:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c0108a0a:	e8 5d 97 ff ff       	call   c010216c <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0108a0f:	c7 04 24 44 cf 10 c0 	movl   $0xc010cf44,(%esp)
c0108a16:	e8 c7 8d ff ff       	call   c01017e2 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0108a1b:	b8 00 50 00 00       	mov    $0x5000,%eax
c0108a20:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0108a23:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0108a28:	83 f8 05             	cmp    $0x5,%eax
c0108a2b:	74 24                	je     c0108a51 <_fifo_check_swap+0x150>
c0108a2d:	c7 44 24 0c 6a cf 10 	movl   $0xc010cf6a,0xc(%esp)
c0108a34:	c0 
c0108a35:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c0108a3c:	c0 
c0108a3d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0108a44:	00 
c0108a45:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c0108a4c:	e8 1b 97 ff ff       	call   c010216c <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0108a51:	c7 04 24 1c cf 10 c0 	movl   $0xc010cf1c,(%esp)
c0108a58:	e8 85 8d ff ff       	call   c01017e2 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0108a5d:	b8 00 20 00 00       	mov    $0x2000,%eax
c0108a62:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0108a65:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0108a6a:	83 f8 05             	cmp    $0x5,%eax
c0108a6d:	74 24                	je     c0108a93 <_fifo_check_swap+0x192>
c0108a6f:	c7 44 24 0c 6a cf 10 	movl   $0xc010cf6a,0xc(%esp)
c0108a76:	c0 
c0108a77:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c0108a7e:	c0 
c0108a7f:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0108a86:	00 
c0108a87:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c0108a8e:	e8 d9 96 ff ff       	call   c010216c <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0108a93:	c7 04 24 cc ce 10 c0 	movl   $0xc010cecc,(%esp)
c0108a9a:	e8 43 8d ff ff       	call   c01017e2 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0108a9f:	b8 00 10 00 00       	mov    $0x1000,%eax
c0108aa4:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0108aa7:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0108aac:	83 f8 06             	cmp    $0x6,%eax
c0108aaf:	74 24                	je     c0108ad5 <_fifo_check_swap+0x1d4>
c0108ab1:	c7 44 24 0c 79 cf 10 	movl   $0xc010cf79,0xc(%esp)
c0108ab8:	c0 
c0108ab9:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c0108ac0:	c0 
c0108ac1:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0108ac8:	00 
c0108ac9:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c0108ad0:	e8 97 96 ff ff       	call   c010216c <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0108ad5:	c7 04 24 1c cf 10 c0 	movl   $0xc010cf1c,(%esp)
c0108adc:	e8 01 8d ff ff       	call   c01017e2 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0108ae1:	b8 00 20 00 00       	mov    $0x2000,%eax
c0108ae6:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0108ae9:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0108aee:	83 f8 07             	cmp    $0x7,%eax
c0108af1:	74 24                	je     c0108b17 <_fifo_check_swap+0x216>
c0108af3:	c7 44 24 0c 88 cf 10 	movl   $0xc010cf88,0xc(%esp)
c0108afa:	c0 
c0108afb:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c0108b02:	c0 
c0108b03:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0108b0a:	00 
c0108b0b:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c0108b12:	e8 55 96 ff ff       	call   c010216c <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0108b17:	c7 04 24 94 ce 10 c0 	movl   $0xc010ce94,(%esp)
c0108b1e:	e8 bf 8c ff ff       	call   c01017e2 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0108b23:	b8 00 30 00 00       	mov    $0x3000,%eax
c0108b28:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0108b2b:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0108b30:	83 f8 08             	cmp    $0x8,%eax
c0108b33:	74 24                	je     c0108b59 <_fifo_check_swap+0x258>
c0108b35:	c7 44 24 0c 97 cf 10 	movl   $0xc010cf97,0xc(%esp)
c0108b3c:	c0 
c0108b3d:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c0108b44:	c0 
c0108b45:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0108b4c:	00 
c0108b4d:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c0108b54:	e8 13 96 ff ff       	call   c010216c <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0108b59:	c7 04 24 f4 ce 10 c0 	movl   $0xc010cef4,(%esp)
c0108b60:	e8 7d 8c ff ff       	call   c01017e2 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0108b65:	b8 00 40 00 00       	mov    $0x4000,%eax
c0108b6a:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0108b6d:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0108b72:	83 f8 09             	cmp    $0x9,%eax
c0108b75:	74 24                	je     c0108b9b <_fifo_check_swap+0x29a>
c0108b77:	c7 44 24 0c a6 cf 10 	movl   $0xc010cfa6,0xc(%esp)
c0108b7e:	c0 
c0108b7f:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c0108b86:	c0 
c0108b87:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0108b8e:	00 
c0108b8f:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c0108b96:	e8 d1 95 ff ff       	call   c010216c <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0108b9b:	c7 04 24 44 cf 10 c0 	movl   $0xc010cf44,(%esp)
c0108ba2:	e8 3b 8c ff ff       	call   c01017e2 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0108ba7:	b8 00 50 00 00       	mov    $0x5000,%eax
c0108bac:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0108baf:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0108bb4:	83 f8 0a             	cmp    $0xa,%eax
c0108bb7:	74 24                	je     c0108bdd <_fifo_check_swap+0x2dc>
c0108bb9:	c7 44 24 0c b5 cf 10 	movl   $0xc010cfb5,0xc(%esp)
c0108bc0:	c0 
c0108bc1:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c0108bc8:	c0 
c0108bc9:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c0108bd0:	00 
c0108bd1:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c0108bd8:	e8 8f 95 ff ff       	call   c010216c <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0108bdd:	c7 04 24 cc ce 10 c0 	movl   $0xc010cecc,(%esp)
c0108be4:	e8 f9 8b ff ff       	call   c01017e2 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0108be9:	b8 00 10 00 00       	mov    $0x1000,%eax
c0108bee:	0f b6 00             	movzbl (%eax),%eax
c0108bf1:	3c 0a                	cmp    $0xa,%al
c0108bf3:	74 24                	je     c0108c19 <_fifo_check_swap+0x318>
c0108bf5:	c7 44 24 0c c8 cf 10 	movl   $0xc010cfc8,0xc(%esp)
c0108bfc:	c0 
c0108bfd:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c0108c04:	c0 
c0108c05:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
c0108c0c:	00 
c0108c0d:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c0108c14:	e8 53 95 ff ff       	call   c010216c <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0108c19:	b8 00 10 00 00       	mov    $0x1000,%eax
c0108c1e:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0108c21:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c0108c26:	83 f8 0b             	cmp    $0xb,%eax
c0108c29:	74 24                	je     c0108c4f <_fifo_check_swap+0x34e>
c0108c2b:	c7 44 24 0c e9 cf 10 	movl   $0xc010cfe9,0xc(%esp)
c0108c32:	c0 
c0108c33:	c7 44 24 08 3e ce 10 	movl   $0xc010ce3e,0x8(%esp)
c0108c3a:	c0 
c0108c3b:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
c0108c42:	00 
c0108c43:	c7 04 24 53 ce 10 c0 	movl   $0xc010ce53,(%esp)
c0108c4a:	e8 1d 95 ff ff       	call   c010216c <__panic>
    return 0;
c0108c4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108c54:	c9                   	leave  
c0108c55:	c3                   	ret    

c0108c56 <_fifo_init>:


static int
_fifo_init(void)
{
c0108c56:	55                   	push   %ebp
c0108c57:	89 e5                	mov    %esp,%ebp
    return 0;
c0108c59:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108c5e:	5d                   	pop    %ebp
c0108c5f:	c3                   	ret    

c0108c60 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0108c60:	55                   	push   %ebp
c0108c61:	89 e5                	mov    %esp,%ebp
    return 0;
c0108c63:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108c68:	5d                   	pop    %ebp
c0108c69:	c3                   	ret    

c0108c6a <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0108c6a:	55                   	push   %ebp
c0108c6b:	89 e5                	mov    %esp,%ebp
c0108c6d:	b8 00 00 00 00       	mov    $0x0,%eax
c0108c72:	5d                   	pop    %ebp
c0108c73:	c3                   	ret    

c0108c74 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0108c74:	55                   	push   %ebp
c0108c75:	89 e5                	mov    %esp,%ebp
c0108c77:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0108c7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c7d:	c1 e8 0c             	shr    $0xc,%eax
c0108c80:	89 c2                	mov    %eax,%edx
c0108c82:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c0108c87:	39 c2                	cmp    %eax,%edx
c0108c89:	72 1c                	jb     c0108ca7 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0108c8b:	c7 44 24 08 0c d0 10 	movl   $0xc010d00c,0x8(%esp)
c0108c92:	c0 
c0108c93:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0108c9a:	00 
c0108c9b:	c7 04 24 2b d0 10 c0 	movl   $0xc010d02b,(%esp)
c0108ca2:	e8 c5 94 ff ff       	call   c010216c <__panic>
    }
    return &pages[PPN(pa)];
c0108ca7:	8b 0d 8c e0 12 c0    	mov    0xc012e08c,%ecx
c0108cad:	8b 45 08             	mov    0x8(%ebp),%eax
c0108cb0:	c1 e8 0c             	shr    $0xc,%eax
c0108cb3:	89 c2                	mov    %eax,%edx
c0108cb5:	89 d0                	mov    %edx,%eax
c0108cb7:	c1 e0 03             	shl    $0x3,%eax
c0108cba:	01 d0                	add    %edx,%eax
c0108cbc:	c1 e0 02             	shl    $0x2,%eax
c0108cbf:	01 c8                	add    %ecx,%eax
}
c0108cc1:	c9                   	leave  
c0108cc2:	c3                   	ret    

c0108cc3 <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c0108cc3:	55                   	push   %ebp
c0108cc4:	89 e5                	mov    %esp,%ebp
c0108cc6:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0108cc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ccc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0108cd1:	89 04 24             	mov    %eax,(%esp)
c0108cd4:	e8 9b ff ff ff       	call   c0108c74 <pa2page>
}
c0108cd9:	c9                   	leave  
c0108cda:	c3                   	ret    

c0108cdb <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0108cdb:	55                   	push   %ebp
c0108cdc:	89 e5                	mov    %esp,%ebp
c0108cde:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0108ce1:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0108ce8:	e8 dd d1 ff ff       	call   c0105eca <kmalloc>
c0108ced:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0108cf0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108cf4:	74 58                	je     c0108d4e <mm_create+0x73>
        list_init(&(mm->mmap_list));
c0108cf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108cf9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0108cfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108cff:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108d02:	89 50 04             	mov    %edx,0x4(%eax)
c0108d05:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d08:	8b 50 04             	mov    0x4(%eax),%edx
c0108d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108d0e:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0108d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d13:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0108d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d1d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0108d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d27:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0108d2e:	a1 2c c0 12 c0       	mov    0xc012c02c,%eax
c0108d33:	85 c0                	test   %eax,%eax
c0108d35:	74 0d                	je     c0108d44 <mm_create+0x69>
c0108d37:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d3a:	89 04 24             	mov    %eax,(%esp)
c0108d3d:	e8 e9 ee ff ff       	call   c0107c2b <swap_init_mm>
c0108d42:	eb 0a                	jmp    c0108d4e <mm_create+0x73>
        else mm->sm_priv = NULL;
c0108d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d47:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0108d4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108d51:	c9                   	leave  
c0108d52:	c3                   	ret    

c0108d53 <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0108d53:	55                   	push   %ebp
c0108d54:	89 e5                	mov    %esp,%ebp
c0108d56:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0108d59:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0108d60:	e8 65 d1 ff ff       	call   c0105eca <kmalloc>
c0108d65:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0108d68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108d6c:	74 1b                	je     c0108d89 <vma_create+0x36>
        vma->vm_start = vm_start;
c0108d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d71:	8b 55 08             	mov    0x8(%ebp),%edx
c0108d74:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0108d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d7a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108d7d:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0108d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108d83:	8b 55 10             	mov    0x10(%ebp),%edx
c0108d86:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0108d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0108d8c:	c9                   	leave  
c0108d8d:	c3                   	ret    

c0108d8e <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0108d8e:	55                   	push   %ebp
c0108d8f:	89 e5                	mov    %esp,%ebp
c0108d91:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0108d94:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0108d9b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0108d9f:	0f 84 95 00 00 00    	je     c0108e3a <find_vma+0xac>
        vma = mm->mmap_cache;
c0108da5:	8b 45 08             	mov    0x8(%ebp),%eax
c0108da8:	8b 40 08             	mov    0x8(%eax),%eax
c0108dab:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0108dae:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108db2:	74 16                	je     c0108dca <find_vma+0x3c>
c0108db4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108db7:	8b 40 04             	mov    0x4(%eax),%eax
c0108dba:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108dbd:	77 0b                	ja     c0108dca <find_vma+0x3c>
c0108dbf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108dc2:	8b 40 08             	mov    0x8(%eax),%eax
c0108dc5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108dc8:	77 61                	ja     c0108e2b <find_vma+0x9d>
                bool found = 0;
c0108dca:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0108dd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108dd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108dda:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0108ddd:	eb 28                	jmp    c0108e07 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0108ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108de2:	83 e8 10             	sub    $0x10,%eax
c0108de5:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0108de8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108deb:	8b 40 04             	mov    0x4(%eax),%eax
c0108dee:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108df1:	77 14                	ja     c0108e07 <find_vma+0x79>
c0108df3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108df6:	8b 40 08             	mov    0x8(%eax),%eax
c0108df9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108dfc:	76 09                	jbe    c0108e07 <find_vma+0x79>
                        found = 1;
c0108dfe:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0108e05:	eb 17                	jmp    c0108e1e <find_vma+0x90>
c0108e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108e0a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0108e0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108e10:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c0108e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108e19:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108e1c:	75 c1                	jne    c0108ddf <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c0108e1e:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0108e22:	75 07                	jne    c0108e2b <find_vma+0x9d>
                    vma = NULL;
c0108e24:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0108e2b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0108e2f:	74 09                	je     c0108e3a <find_vma+0xac>
            mm->mmap_cache = vma;
c0108e31:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e34:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0108e37:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0108e3a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0108e3d:	c9                   	leave  
c0108e3e:	c3                   	ret    

c0108e3f <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0108e3f:	55                   	push   %ebp
c0108e40:	89 e5                	mov    %esp,%ebp
c0108e42:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0108e45:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e48:	8b 50 04             	mov    0x4(%eax),%edx
c0108e4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e4e:	8b 40 08             	mov    0x8(%eax),%eax
c0108e51:	39 c2                	cmp    %eax,%edx
c0108e53:	72 24                	jb     c0108e79 <check_vma_overlap+0x3a>
c0108e55:	c7 44 24 0c 39 d0 10 	movl   $0xc010d039,0xc(%esp)
c0108e5c:	c0 
c0108e5d:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c0108e64:	c0 
c0108e65:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0108e6c:	00 
c0108e6d:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c0108e74:	e8 f3 92 ff ff       	call   c010216c <__panic>
    assert(prev->vm_end <= next->vm_start);
c0108e79:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e7c:	8b 50 08             	mov    0x8(%eax),%edx
c0108e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e82:	8b 40 04             	mov    0x4(%eax),%eax
c0108e85:	39 c2                	cmp    %eax,%edx
c0108e87:	76 24                	jbe    c0108ead <check_vma_overlap+0x6e>
c0108e89:	c7 44 24 0c 7c d0 10 	movl   $0xc010d07c,0xc(%esp)
c0108e90:	c0 
c0108e91:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c0108e98:	c0 
c0108e99:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c0108ea0:	00 
c0108ea1:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c0108ea8:	e8 bf 92 ff ff       	call   c010216c <__panic>
    assert(next->vm_start < next->vm_end);
c0108ead:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108eb0:	8b 50 04             	mov    0x4(%eax),%edx
c0108eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108eb6:	8b 40 08             	mov    0x8(%eax),%eax
c0108eb9:	39 c2                	cmp    %eax,%edx
c0108ebb:	72 24                	jb     c0108ee1 <check_vma_overlap+0xa2>
c0108ebd:	c7 44 24 0c 9b d0 10 	movl   $0xc010d09b,0xc(%esp)
c0108ec4:	c0 
c0108ec5:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c0108ecc:	c0 
c0108ecd:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0108ed4:	00 
c0108ed5:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c0108edc:	e8 8b 92 ff ff       	call   c010216c <__panic>
}
c0108ee1:	c9                   	leave  
c0108ee2:	c3                   	ret    

c0108ee3 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c0108ee3:	55                   	push   %ebp
c0108ee4:	89 e5                	mov    %esp,%ebp
c0108ee6:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0108ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108eec:	8b 50 04             	mov    0x4(%eax),%edx
c0108eef:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ef2:	8b 40 08             	mov    0x8(%eax),%eax
c0108ef5:	39 c2                	cmp    %eax,%edx
c0108ef7:	72 24                	jb     c0108f1d <insert_vma_struct+0x3a>
c0108ef9:	c7 44 24 0c b9 d0 10 	movl   $0xc010d0b9,0xc(%esp)
c0108f00:	c0 
c0108f01:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c0108f08:	c0 
c0108f09:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
c0108f10:	00 
c0108f11:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c0108f18:	e8 4f 92 ff ff       	call   c010216c <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0108f1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f20:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c0108f23:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108f26:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c0108f29:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108f2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c0108f2f:	eb 21                	jmp    c0108f52 <insert_vma_struct+0x6f>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c0108f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108f34:	83 e8 10             	sub    $0x10,%eax
c0108f37:	89 45 e8             	mov    %eax,-0x18(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c0108f3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108f3d:	8b 50 04             	mov    0x4(%eax),%edx
c0108f40:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108f43:	8b 40 04             	mov    0x4(%eax),%eax
c0108f46:	39 c2                	cmp    %eax,%edx
c0108f48:	76 02                	jbe    c0108f4c <insert_vma_struct+0x69>
                break;
c0108f4a:	eb 1d                	jmp    c0108f69 <insert_vma_struct+0x86>
            }
            le_prev = le;
c0108f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108f4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108f52:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108f55:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108f58:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108f5b:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c0108f5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108f64:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108f67:	75 c8                	jne    c0108f31 <insert_vma_struct+0x4e>
c0108f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108f6c:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0108f6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108f72:	8b 40 04             	mov    0x4(%eax),%eax
                break;
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c0108f75:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    /* check overlap */
    if (le_prev != list) {
c0108f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108f7b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108f7e:	74 15                	je     c0108f95 <insert_vma_struct+0xb2>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c0108f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108f83:	8d 50 f0             	lea    -0x10(%eax),%edx
c0108f86:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108f89:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f8d:	89 14 24             	mov    %edx,(%esp)
c0108f90:	e8 aa fe ff ff       	call   c0108e3f <check_vma_overlap>
    }
    if (le_next != list) {
c0108f95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108f98:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0108f9b:	74 15                	je     c0108fb2 <insert_vma_struct+0xcf>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0108f9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108fa0:	83 e8 10             	sub    $0x10,%eax
c0108fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108fa7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108faa:	89 04 24             	mov    %eax,(%esp)
c0108fad:	e8 8d fe ff ff       	call   c0108e3f <check_vma_overlap>
    }

    vma->vm_mm = mm;
c0108fb2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108fb5:	8b 55 08             	mov    0x8(%ebp),%edx
c0108fb8:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0108fba:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108fbd:	8d 50 10             	lea    0x10(%eax),%edx
c0108fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108fc3:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0108fc6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0108fc9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108fcc:	8b 40 04             	mov    0x4(%eax),%eax
c0108fcf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108fd2:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0108fd5:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0108fd8:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0108fdb:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0108fde:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108fe1:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0108fe4:	89 10                	mov    %edx,(%eax)
c0108fe6:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0108fe9:	8b 10                	mov    (%eax),%edx
c0108feb:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0108fee:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0108ff1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108ff4:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0108ff7:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0108ffa:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108ffd:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0109000:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c0109002:	8b 45 08             	mov    0x8(%ebp),%eax
c0109005:	8b 40 10             	mov    0x10(%eax),%eax
c0109008:	8d 50 01             	lea    0x1(%eax),%edx
c010900b:	8b 45 08             	mov    0x8(%ebp),%eax
c010900e:	89 50 10             	mov    %edx,0x10(%eax)
}
c0109011:	c9                   	leave  
c0109012:	c3                   	ret    

c0109013 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c0109013:	55                   	push   %ebp
c0109014:	89 e5                	mov    %esp,%ebp
c0109016:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c0109019:	8b 45 08             	mov    0x8(%ebp),%eax
c010901c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c010901f:	eb 36                	jmp    c0109057 <mm_destroy+0x44>
c0109021:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109024:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0109027:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010902a:	8b 40 04             	mov    0x4(%eax),%eax
c010902d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109030:	8b 12                	mov    (%edx),%edx
c0109032:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109035:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0109038:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010903b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010903e:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0109041:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109044:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109047:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
c0109049:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010904c:	83 e8 10             	sub    $0x10,%eax
c010904f:	89 04 24             	mov    %eax,(%esp)
c0109052:	e8 8e ce ff ff       	call   c0105ee5 <kfree>
c0109057:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010905a:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010905d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109060:	8b 40 04             	mov    0x4(%eax),%eax
// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c0109063:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109066:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109069:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010906c:	75 b3                	jne    c0109021 <mm_destroy+0xe>
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
    }
    kfree(mm); //kfree mm
c010906e:	8b 45 08             	mov    0x8(%ebp),%eax
c0109071:	89 04 24             	mov    %eax,(%esp)
c0109074:	e8 6c ce ff ff       	call   c0105ee5 <kfree>
    mm=NULL;
c0109079:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c0109080:	c9                   	leave  
c0109081:	c3                   	ret    

c0109082 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c0109082:	55                   	push   %ebp
c0109083:	89 e5                	mov    %esp,%ebp
c0109085:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0109088:	e8 02 00 00 00       	call   c010908f <check_vmm>
}
c010908d:	c9                   	leave  
c010908e:	c3                   	ret    

c010908f <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c010908f:	55                   	push   %ebp
c0109090:	89 e5                	mov    %esp,%ebp
c0109092:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0109095:	e8 52 d3 ff ff       	call   c01063ec <nr_free_pages>
c010909a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c010909d:	e8 13 00 00 00       	call   c01090b5 <check_vma_struct>
    check_pgfault();
c01090a2:	e8 a7 04 00 00       	call   c010954e <check_pgfault>

 //   assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vmm() succeeded.\n");
c01090a7:	c7 04 24 d5 d0 10 c0 	movl   $0xc010d0d5,(%esp)
c01090ae:	e8 2f 87 ff ff       	call   c01017e2 <cprintf>
}
c01090b3:	c9                   	leave  
c01090b4:	c3                   	ret    

c01090b5 <check_vma_struct>:

static void
check_vma_struct(void) {
c01090b5:	55                   	push   %ebp
c01090b6:	89 e5                	mov    %esp,%ebp
c01090b8:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c01090bb:	e8 2c d3 ff ff       	call   c01063ec <nr_free_pages>
c01090c0:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c01090c3:	e8 13 fc ff ff       	call   c0108cdb <mm_create>
c01090c8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c01090cb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01090cf:	75 24                	jne    c01090f5 <check_vma_struct+0x40>
c01090d1:	c7 44 24 0c ed d0 10 	movl   $0xc010d0ed,0xc(%esp)
c01090d8:	c0 
c01090d9:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c01090e0:	c0 
c01090e1:	c7 44 24 04 b4 00 00 	movl   $0xb4,0x4(%esp)
c01090e8:	00 
c01090e9:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c01090f0:	e8 77 90 ff ff       	call   c010216c <__panic>

    int step1 = 10, step2 = step1 * 10;
c01090f5:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c01090fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01090ff:	89 d0                	mov    %edx,%eax
c0109101:	c1 e0 02             	shl    $0x2,%eax
c0109104:	01 d0                	add    %edx,%eax
c0109106:	01 c0                	add    %eax,%eax
c0109108:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c010910b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010910e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109111:	eb 70                	jmp    c0109183 <check_vma_struct+0xce>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0109113:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109116:	89 d0                	mov    %edx,%eax
c0109118:	c1 e0 02             	shl    $0x2,%eax
c010911b:	01 d0                	add    %edx,%eax
c010911d:	83 c0 02             	add    $0x2,%eax
c0109120:	89 c1                	mov    %eax,%ecx
c0109122:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109125:	89 d0                	mov    %edx,%eax
c0109127:	c1 e0 02             	shl    $0x2,%eax
c010912a:	01 d0                	add    %edx,%eax
c010912c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0109133:	00 
c0109134:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0109138:	89 04 24             	mov    %eax,(%esp)
c010913b:	e8 13 fc ff ff       	call   c0108d53 <vma_create>
c0109140:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c0109143:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0109147:	75 24                	jne    c010916d <check_vma_struct+0xb8>
c0109149:	c7 44 24 0c f8 d0 10 	movl   $0xc010d0f8,0xc(%esp)
c0109150:	c0 
c0109151:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c0109158:	c0 
c0109159:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c0109160:	00 
c0109161:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c0109168:	e8 ff 8f ff ff       	call   c010216c <__panic>
        insert_vma_struct(mm, vma);
c010916d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109170:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109174:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109177:	89 04 24             	mov    %eax,(%esp)
c010917a:	e8 64 fd ff ff       	call   c0108ee3 <insert_vma_struct>
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c010917f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0109183:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109187:	7f 8a                	jg     c0109113 <check_vma_struct+0x5e>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0109189:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010918c:	83 c0 01             	add    $0x1,%eax
c010918f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109192:	eb 70                	jmp    c0109204 <check_vma_struct+0x14f>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c0109194:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109197:	89 d0                	mov    %edx,%eax
c0109199:	c1 e0 02             	shl    $0x2,%eax
c010919c:	01 d0                	add    %edx,%eax
c010919e:	83 c0 02             	add    $0x2,%eax
c01091a1:	89 c1                	mov    %eax,%ecx
c01091a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01091a6:	89 d0                	mov    %edx,%eax
c01091a8:	c1 e0 02             	shl    $0x2,%eax
c01091ab:	01 d0                	add    %edx,%eax
c01091ad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01091b4:	00 
c01091b5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01091b9:	89 04 24             	mov    %eax,(%esp)
c01091bc:	e8 92 fb ff ff       	call   c0108d53 <vma_create>
c01091c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c01091c4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01091c8:	75 24                	jne    c01091ee <check_vma_struct+0x139>
c01091ca:	c7 44 24 0c f8 d0 10 	movl   $0xc010d0f8,0xc(%esp)
c01091d1:	c0 
c01091d2:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c01091d9:	c0 
c01091da:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
c01091e1:	00 
c01091e2:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c01091e9:	e8 7e 8f ff ff       	call   c010216c <__panic>
        insert_vma_struct(mm, vma);
c01091ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01091f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01091f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01091f8:	89 04 24             	mov    %eax,(%esp)
c01091fb:	e8 e3 fc ff ff       	call   c0108ee3 <insert_vma_struct>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0109200:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0109204:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109207:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010920a:	7e 88                	jle    c0109194 <check_vma_struct+0xdf>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c010920c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010920f:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0109212:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0109215:	8b 40 04             	mov    0x4(%eax),%eax
c0109218:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c010921b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c0109222:	e9 97 00 00 00       	jmp    c01092be <check_vma_struct+0x209>
        assert(le != &(mm->mmap_list));
c0109227:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010922a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010922d:	75 24                	jne    c0109253 <check_vma_struct+0x19e>
c010922f:	c7 44 24 0c 04 d1 10 	movl   $0xc010d104,0xc(%esp)
c0109236:	c0 
c0109237:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c010923e:	c0 
c010923f:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0109246:	00 
c0109247:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c010924e:	e8 19 8f ff ff       	call   c010216c <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c0109253:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109256:	83 e8 10             	sub    $0x10,%eax
c0109259:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c010925c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010925f:	8b 48 04             	mov    0x4(%eax),%ecx
c0109262:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109265:	89 d0                	mov    %edx,%eax
c0109267:	c1 e0 02             	shl    $0x2,%eax
c010926a:	01 d0                	add    %edx,%eax
c010926c:	39 c1                	cmp    %eax,%ecx
c010926e:	75 17                	jne    c0109287 <check_vma_struct+0x1d2>
c0109270:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0109273:	8b 48 08             	mov    0x8(%eax),%ecx
c0109276:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109279:	89 d0                	mov    %edx,%eax
c010927b:	c1 e0 02             	shl    $0x2,%eax
c010927e:	01 d0                	add    %edx,%eax
c0109280:	83 c0 02             	add    $0x2,%eax
c0109283:	39 c1                	cmp    %eax,%ecx
c0109285:	74 24                	je     c01092ab <check_vma_struct+0x1f6>
c0109287:	c7 44 24 0c 1c d1 10 	movl   $0xc010d11c,0xc(%esp)
c010928e:	c0 
c010928f:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c0109296:	c0 
c0109297:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c010929e:	00 
c010929f:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c01092a6:	e8 c1 8e ff ff       	call   c010216c <__panic>
c01092ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01092ae:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01092b1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01092b4:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c01092b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c01092ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01092be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01092c1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01092c4:	0f 8e 5d ff ff ff    	jle    c0109227 <check_vma_struct+0x172>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c01092ca:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c01092d1:	e9 cd 01 00 00       	jmp    c01094a3 <check_vma_struct+0x3ee>
        struct vma_struct *vma1 = find_vma(mm, i);
c01092d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01092d9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01092dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01092e0:	89 04 24             	mov    %eax,(%esp)
c01092e3:	e8 a6 fa ff ff       	call   c0108d8e <find_vma>
c01092e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(vma1 != NULL);
c01092eb:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01092ef:	75 24                	jne    c0109315 <check_vma_struct+0x260>
c01092f1:	c7 44 24 0c 51 d1 10 	movl   $0xc010d151,0xc(%esp)
c01092f8:	c0 
c01092f9:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c0109300:	c0 
c0109301:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0109308:	00 
c0109309:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c0109310:	e8 57 8e ff ff       	call   c010216c <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c0109315:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109318:	83 c0 01             	add    $0x1,%eax
c010931b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010931f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109322:	89 04 24             	mov    %eax,(%esp)
c0109325:	e8 64 fa ff ff       	call   c0108d8e <find_vma>
c010932a:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma2 != NULL);
c010932d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0109331:	75 24                	jne    c0109357 <check_vma_struct+0x2a2>
c0109333:	c7 44 24 0c 5e d1 10 	movl   $0xc010d15e,0xc(%esp)
c010933a:	c0 
c010933b:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c0109342:	c0 
c0109343:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c010934a:	00 
c010934b:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c0109352:	e8 15 8e ff ff       	call   c010216c <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c0109357:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010935a:	83 c0 02             	add    $0x2,%eax
c010935d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109361:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109364:	89 04 24             	mov    %eax,(%esp)
c0109367:	e8 22 fa ff ff       	call   c0108d8e <find_vma>
c010936c:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma3 == NULL);
c010936f:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0109373:	74 24                	je     c0109399 <check_vma_struct+0x2e4>
c0109375:	c7 44 24 0c 6b d1 10 	movl   $0xc010d16b,0xc(%esp)
c010937c:	c0 
c010937d:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c0109384:	c0 
c0109385:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
c010938c:	00 
c010938d:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c0109394:	e8 d3 8d ff ff       	call   c010216c <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c0109399:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010939c:	83 c0 03             	add    $0x3,%eax
c010939f:	89 44 24 04          	mov    %eax,0x4(%esp)
c01093a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01093a6:	89 04 24             	mov    %eax,(%esp)
c01093a9:	e8 e0 f9 ff ff       	call   c0108d8e <find_vma>
c01093ae:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma4 == NULL);
c01093b1:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c01093b5:	74 24                	je     c01093db <check_vma_struct+0x326>
c01093b7:	c7 44 24 0c 78 d1 10 	movl   $0xc010d178,0xc(%esp)
c01093be:	c0 
c01093bf:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c01093c6:	c0 
c01093c7:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c01093ce:	00 
c01093cf:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c01093d6:	e8 91 8d ff ff       	call   c010216c <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c01093db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01093de:	83 c0 04             	add    $0x4,%eax
c01093e1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01093e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01093e8:	89 04 24             	mov    %eax,(%esp)
c01093eb:	e8 9e f9 ff ff       	call   c0108d8e <find_vma>
c01093f0:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma5 == NULL);
c01093f3:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c01093f7:	74 24                	je     c010941d <check_vma_struct+0x368>
c01093f9:	c7 44 24 0c 85 d1 10 	movl   $0xc010d185,0xc(%esp)
c0109400:	c0 
c0109401:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c0109408:	c0 
c0109409:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
c0109410:	00 
c0109411:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c0109418:	e8 4f 8d ff ff       	call   c010216c <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c010941d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0109420:	8b 50 04             	mov    0x4(%eax),%edx
c0109423:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109426:	39 c2                	cmp    %eax,%edx
c0109428:	75 10                	jne    c010943a <check_vma_struct+0x385>
c010942a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010942d:	8b 50 08             	mov    0x8(%eax),%edx
c0109430:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109433:	83 c0 02             	add    $0x2,%eax
c0109436:	39 c2                	cmp    %eax,%edx
c0109438:	74 24                	je     c010945e <check_vma_struct+0x3a9>
c010943a:	c7 44 24 0c 94 d1 10 	movl   $0xc010d194,0xc(%esp)
c0109441:	c0 
c0109442:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c0109449:	c0 
c010944a:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0109451:	00 
c0109452:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c0109459:	e8 0e 8d ff ff       	call   c010216c <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c010945e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0109461:	8b 50 04             	mov    0x4(%eax),%edx
c0109464:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109467:	39 c2                	cmp    %eax,%edx
c0109469:	75 10                	jne    c010947b <check_vma_struct+0x3c6>
c010946b:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010946e:	8b 50 08             	mov    0x8(%eax),%edx
c0109471:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109474:	83 c0 02             	add    $0x2,%eax
c0109477:	39 c2                	cmp    %eax,%edx
c0109479:	74 24                	je     c010949f <check_vma_struct+0x3ea>
c010947b:	c7 44 24 0c c4 d1 10 	movl   $0xc010d1c4,0xc(%esp)
c0109482:	c0 
c0109483:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c010948a:	c0 
c010948b:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c0109492:	00 
c0109493:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c010949a:	e8 cd 8c ff ff       	call   c010216c <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c010949f:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c01094a3:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01094a6:	89 d0                	mov    %edx,%eax
c01094a8:	c1 e0 02             	shl    $0x2,%eax
c01094ab:	01 d0                	add    %edx,%eax
c01094ad:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01094b0:	0f 8d 20 fe ff ff    	jge    c01092d6 <check_vma_struct+0x221>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c01094b6:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c01094bd:	eb 70                	jmp    c010952f <check_vma_struct+0x47a>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c01094bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094c2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01094c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01094c9:	89 04 24             	mov    %eax,(%esp)
c01094cc:	e8 bd f8 ff ff       	call   c0108d8e <find_vma>
c01094d1:	89 45 bc             	mov    %eax,-0x44(%ebp)
        if (vma_below_5 != NULL ) {
c01094d4:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01094d8:	74 27                	je     c0109501 <check_vma_struct+0x44c>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c01094da:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01094dd:	8b 50 08             	mov    0x8(%eax),%edx
c01094e0:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01094e3:	8b 40 04             	mov    0x4(%eax),%eax
c01094e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01094ea:	89 44 24 08          	mov    %eax,0x8(%esp)
c01094ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01094f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01094f5:	c7 04 24 f4 d1 10 c0 	movl   $0xc010d1f4,(%esp)
c01094fc:	e8 e1 82 ff ff       	call   c01017e2 <cprintf>
        }
        assert(vma_below_5 == NULL);
c0109501:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0109505:	74 24                	je     c010952b <check_vma_struct+0x476>
c0109507:	c7 44 24 0c 19 d2 10 	movl   $0xc010d219,0xc(%esp)
c010950e:	c0 
c010950f:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c0109516:	c0 
c0109517:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c010951e:	00 
c010951f:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c0109526:	e8 41 8c ff ff       	call   c010216c <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c010952b:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c010952f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109533:	79 8a                	jns    c01094bf <check_vma_struct+0x40a>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c0109535:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109538:	89 04 24             	mov    %eax,(%esp)
c010953b:	e8 d3 fa ff ff       	call   c0109013 <mm_destroy>

//    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vma_struct() succeeded!\n");
c0109540:	c7 04 24 30 d2 10 c0 	movl   $0xc010d230,(%esp)
c0109547:	e8 96 82 ff ff       	call   c01017e2 <cprintf>
}
c010954c:	c9                   	leave  
c010954d:	c3                   	ret    

c010954e <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c010954e:	55                   	push   %ebp
c010954f:	89 e5                	mov    %esp,%ebp
c0109551:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0109554:	e8 93 ce ff ff       	call   c01063ec <nr_free_pages>
c0109559:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c010955c:	e8 7a f7 ff ff       	call   c0108cdb <mm_create>
c0109561:	a3 6c e1 12 c0       	mov    %eax,0xc012e16c
    assert(check_mm_struct != NULL);
c0109566:	a1 6c e1 12 c0       	mov    0xc012e16c,%eax
c010956b:	85 c0                	test   %eax,%eax
c010956d:	75 24                	jne    c0109593 <check_pgfault+0x45>
c010956f:	c7 44 24 0c 4f d2 10 	movl   $0xc010d24f,0xc(%esp)
c0109576:	c0 
c0109577:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c010957e:	c0 
c010957f:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
c0109586:	00 
c0109587:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c010958e:	e8 d9 8b ff ff       	call   c010216c <__panic>

    struct mm_struct *mm = check_mm_struct;
c0109593:	a1 6c e1 12 c0       	mov    0xc012e16c,%eax
c0109598:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c010959b:	8b 15 00 8a 12 c0    	mov    0xc0128a00,%edx
c01095a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01095a4:	89 50 0c             	mov    %edx,0xc(%eax)
c01095a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01095aa:	8b 40 0c             	mov    0xc(%eax),%eax
c01095ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c01095b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01095b3:	8b 00                	mov    (%eax),%eax
c01095b5:	85 c0                	test   %eax,%eax
c01095b7:	74 24                	je     c01095dd <check_pgfault+0x8f>
c01095b9:	c7 44 24 0c 67 d2 10 	movl   $0xc010d267,0xc(%esp)
c01095c0:	c0 
c01095c1:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c01095c8:	c0 
c01095c9:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c01095d0:	00 
c01095d1:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c01095d8:	e8 8f 8b ff ff       	call   c010216c <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c01095dd:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c01095e4:	00 
c01095e5:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c01095ec:	00 
c01095ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01095f4:	e8 5a f7 ff ff       	call   c0108d53 <vma_create>
c01095f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c01095fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0109600:	75 24                	jne    c0109626 <check_pgfault+0xd8>
c0109602:	c7 44 24 0c f8 d0 10 	movl   $0xc010d0f8,0xc(%esp)
c0109609:	c0 
c010960a:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c0109611:	c0 
c0109612:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0109619:	00 
c010961a:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c0109621:	e8 46 8b ff ff       	call   c010216c <__panic>

    insert_vma_struct(mm, vma);
c0109626:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109629:	89 44 24 04          	mov    %eax,0x4(%esp)
c010962d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109630:	89 04 24             	mov    %eax,(%esp)
c0109633:	e8 ab f8 ff ff       	call   c0108ee3 <insert_vma_struct>

    uintptr_t addr = 0x100;
c0109638:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c010963f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109642:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109646:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109649:	89 04 24             	mov    %eax,(%esp)
c010964c:	e8 3d f7 ff ff       	call   c0108d8e <find_vma>
c0109651:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0109654:	74 24                	je     c010967a <check_pgfault+0x12c>
c0109656:	c7 44 24 0c 75 d2 10 	movl   $0xc010d275,0xc(%esp)
c010965d:	c0 
c010965e:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c0109665:	c0 
c0109666:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c010966d:	00 
c010966e:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c0109675:	e8 f2 8a ff ff       	call   c010216c <__panic>

    int i, sum = 0;
c010967a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0109681:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0109688:	eb 17                	jmp    c01096a1 <check_pgfault+0x153>
        *(char *)(addr + i) = i;
c010968a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010968d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109690:	01 d0                	add    %edx,%eax
c0109692:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109695:	88 10                	mov    %dl,(%eax)
        sum += i;
c0109697:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010969a:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c010969d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01096a1:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01096a5:	7e e3                	jle    c010968a <check_pgfault+0x13c>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c01096a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01096ae:	eb 15                	jmp    c01096c5 <check_pgfault+0x177>
        sum -= *(char *)(addr + i);
c01096b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01096b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01096b6:	01 d0                	add    %edx,%eax
c01096b8:	0f b6 00             	movzbl (%eax),%eax
c01096bb:	0f be c0             	movsbl %al,%eax
c01096be:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c01096c1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01096c5:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01096c9:	7e e5                	jle    c01096b0 <check_pgfault+0x162>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c01096cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01096cf:	74 24                	je     c01096f5 <check_pgfault+0x1a7>
c01096d1:	c7 44 24 0c 8f d2 10 	movl   $0xc010d28f,0xc(%esp)
c01096d8:	c0 
c01096d9:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c01096e0:	c0 
c01096e1:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c01096e8:	00 
c01096e9:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c01096f0:	e8 77 8a ff ff       	call   c010216c <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c01096f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01096f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01096fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01096fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0109703:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109707:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010970a:	89 04 24             	mov    %eax,(%esp)
c010970d:	e8 23 d5 ff ff       	call   c0106c35 <page_remove>
    free_page(pde2page(pgdir[0]));
c0109712:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109715:	8b 00                	mov    (%eax),%eax
c0109717:	89 04 24             	mov    %eax,(%esp)
c010971a:	e8 a4 f5 ff ff       	call   c0108cc3 <pde2page>
c010971f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0109726:	00 
c0109727:	89 04 24             	mov    %eax,(%esp)
c010972a:	e8 8b cc ff ff       	call   c01063ba <free_pages>
    pgdir[0] = 0;
c010972f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109732:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c0109738:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010973b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0109742:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109745:	89 04 24             	mov    %eax,(%esp)
c0109748:	e8 c6 f8 ff ff       	call   c0109013 <mm_destroy>
    check_mm_struct = NULL;
c010974d:	c7 05 6c e1 12 c0 00 	movl   $0x0,0xc012e16c
c0109754:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0109757:	e8 90 cc ff ff       	call   c01063ec <nr_free_pages>
c010975c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010975f:	74 24                	je     c0109785 <check_pgfault+0x237>
c0109761:	c7 44 24 0c 98 d2 10 	movl   $0xc010d298,0xc(%esp)
c0109768:	c0 
c0109769:	c7 44 24 08 57 d0 10 	movl   $0xc010d057,0x8(%esp)
c0109770:	c0 
c0109771:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0109778:	00 
c0109779:	c7 04 24 6c d0 10 c0 	movl   $0xc010d06c,(%esp)
c0109780:	e8 e7 89 ff ff       	call   c010216c <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0109785:	c7 04 24 bf d2 10 c0 	movl   $0xc010d2bf,(%esp)
c010978c:	e8 51 80 ff ff       	call   c01017e2 <cprintf>
}
c0109791:	c9                   	leave  
c0109792:	c3                   	ret    

c0109793 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0109793:	55                   	push   %ebp
c0109794:	89 e5                	mov    %esp,%ebp
c0109796:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c0109799:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c01097a0:	8b 45 10             	mov    0x10(%ebp),%eax
c01097a3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01097a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01097aa:	89 04 24             	mov    %eax,(%esp)
c01097ad:	e8 dc f5 ff ff       	call   c0108d8e <find_vma>
c01097b2:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c01097b5:	a1 38 c0 12 c0       	mov    0xc012c038,%eax
c01097ba:	83 c0 01             	add    $0x1,%eax
c01097bd:	a3 38 c0 12 c0       	mov    %eax,0xc012c038
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
c01097c2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01097c6:	74 0b                	je     c01097d3 <do_pgfault+0x40>
c01097c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01097cb:	8b 40 04             	mov    0x4(%eax),%eax
c01097ce:	3b 45 10             	cmp    0x10(%ebp),%eax
c01097d1:	76 18                	jbe    c01097eb <do_pgfault+0x58>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c01097d3:	8b 45 10             	mov    0x10(%ebp),%eax
c01097d6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01097da:	c7 04 24 dc d2 10 c0 	movl   $0xc010d2dc,(%esp)
c01097e1:	e8 fc 7f ff ff       	call   c01017e2 <cprintf>
        goto failed;
c01097e6:	e9 bb 01 00 00       	jmp    c01099a6 <do_pgfault+0x213>
    }
    //check the error_code
    switch (error_code & 3) {
c01097eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01097ee:	83 e0 03             	and    $0x3,%eax
c01097f1:	85 c0                	test   %eax,%eax
c01097f3:	74 36                	je     c010982b <do_pgfault+0x98>
c01097f5:	83 f8 01             	cmp    $0x1,%eax
c01097f8:	74 20                	je     c010981a <do_pgfault+0x87>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        if (!(vma->vm_flags & VM_WRITE)) {
c01097fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01097fd:	8b 40 0c             	mov    0xc(%eax),%eax
c0109800:	83 e0 02             	and    $0x2,%eax
c0109803:	85 c0                	test   %eax,%eax
c0109805:	75 11                	jne    c0109818 <do_pgfault+0x85>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c0109807:	c7 04 24 0c d3 10 c0 	movl   $0xc010d30c,(%esp)
c010980e:	e8 cf 7f ff ff       	call   c01017e2 <cprintf>
            goto failed;
c0109813:	e9 8e 01 00 00       	jmp    c01099a6 <do_pgfault+0x213>
        }
        break;
c0109818:	eb 2f                	jmp    c0109849 <do_pgfault+0xb6>
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c010981a:	c7 04 24 6c d3 10 c0 	movl   $0xc010d36c,(%esp)
c0109821:	e8 bc 7f ff ff       	call   c01017e2 <cprintf>
        goto failed;
c0109826:	e9 7b 01 00 00       	jmp    c01099a6 <do_pgfault+0x213>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c010982b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010982e:	8b 40 0c             	mov    0xc(%eax),%eax
c0109831:	83 e0 05             	and    $0x5,%eax
c0109834:	85 c0                	test   %eax,%eax
c0109836:	75 11                	jne    c0109849 <do_pgfault+0xb6>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0109838:	c7 04 24 a4 d3 10 c0 	movl   $0xc010d3a4,(%esp)
c010983f:	e8 9e 7f ff ff       	call   c01017e2 <cprintf>
            goto failed;
c0109844:	e9 5d 01 00 00       	jmp    c01099a6 <do_pgfault+0x213>
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
c0109849:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0109850:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109853:	8b 40 0c             	mov    0xc(%eax),%eax
c0109856:	83 e0 02             	and    $0x2,%eax
c0109859:	85 c0                	test   %eax,%eax
c010985b:	74 04                	je     c0109861 <do_pgfault+0xce>
        perm |= PTE_W;
c010985d:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    addr = ROUNDDOWN(addr, PGSIZE);
c0109861:	8b 45 10             	mov    0x10(%ebp),%eax
c0109864:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0109867:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010986a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010986f:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0109872:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0109879:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        }
   }
#endif
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0109880:	8b 45 08             	mov    0x8(%ebp),%eax
c0109883:	8b 40 0c             	mov    0xc(%eax),%eax
c0109886:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010988d:	00 
c010988e:	8b 55 10             	mov    0x10(%ebp),%edx
c0109891:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109895:	89 04 24             	mov    %eax,(%esp)
c0109898:	e8 a6 d1 ff ff       	call   c0106a43 <get_pte>
c010989d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01098a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01098a4:	75 11                	jne    c01098b7 <do_pgfault+0x124>
        cprintf("get_pte in do_pgfault failed\n");
c01098a6:	c7 04 24 07 d4 10 c0 	movl   $0xc010d407,(%esp)
c01098ad:	e8 30 7f ff ff       	call   c01017e2 <cprintf>
        goto failed;
c01098b2:	e9 ef 00 00 00       	jmp    c01099a6 <do_pgfault+0x213>
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c01098b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01098ba:	8b 00                	mov    (%eax),%eax
c01098bc:	85 c0                	test   %eax,%eax
c01098be:	75 35                	jne    c01098f5 <do_pgfault+0x162>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c01098c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01098c3:	8b 40 0c             	mov    0xc(%eax),%eax
c01098c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01098c9:	89 54 24 08          	mov    %edx,0x8(%esp)
c01098cd:	8b 55 10             	mov    0x10(%ebp),%edx
c01098d0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01098d4:	89 04 24             	mov    %eax,(%esp)
c01098d7:	e8 b3 d4 ff ff       	call   c0106d8f <pgdir_alloc_page>
c01098dc:	85 c0                	test   %eax,%eax
c01098de:	0f 85 bb 00 00 00    	jne    c010999f <do_pgfault+0x20c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c01098e4:	c7 04 24 28 d4 10 c0 	movl   $0xc010d428,(%esp)
c01098eb:	e8 f2 7e ff ff       	call   c01017e2 <cprintf>
            goto failed;
c01098f0:	e9 b1 00 00 00       	jmp    c01099a6 <do_pgfault+0x213>
        }
    }
    else { // if this pte is a swap entry, then load data from disk to a page with phy addr
           // and call page_insert to map the phy addr with logical addr
        if(swap_init_ok) {
c01098f5:	a1 2c c0 12 c0       	mov    0xc012c02c,%eax
c01098fa:	85 c0                	test   %eax,%eax
c01098fc:	0f 84 86 00 00 00    	je     c0109988 <do_pgfault+0x1f5>
            struct Page *page=NULL;
c0109902:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c0109909:	8d 45 e0             	lea    -0x20(%ebp),%eax
c010990c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109910:	8b 45 10             	mov    0x10(%ebp),%eax
c0109913:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109917:	8b 45 08             	mov    0x8(%ebp),%eax
c010991a:	89 04 24             	mov    %eax,(%esp)
c010991d:	e8 02 e5 ff ff       	call   c0107e24 <swap_in>
c0109922:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109925:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109929:	74 0e                	je     c0109939 <do_pgfault+0x1a6>
                cprintf("swap_in in do_pgfault failed\n");
c010992b:	c7 04 24 4f d4 10 c0 	movl   $0xc010d44f,(%esp)
c0109932:	e8 ab 7e ff ff       	call   c01017e2 <cprintf>
c0109937:	eb 6d                	jmp    c01099a6 <do_pgfault+0x213>
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
c0109939:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010993c:	8b 45 08             	mov    0x8(%ebp),%eax
c010993f:	8b 40 0c             	mov    0xc(%eax),%eax
c0109942:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0109945:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0109949:	8b 4d 10             	mov    0x10(%ebp),%ecx
c010994c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0109950:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109954:	89 04 24             	mov    %eax,(%esp)
c0109957:	e8 1d d3 ff ff       	call   c0106c79 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
c010995c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010995f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0109966:	00 
c0109967:	89 44 24 08          	mov    %eax,0x8(%esp)
c010996b:	8b 45 10             	mov    0x10(%ebp),%eax
c010996e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109972:	8b 45 08             	mov    0x8(%ebp),%eax
c0109975:	89 04 24             	mov    %eax,(%esp)
c0109978:	e8 de e2 ff ff       	call   c0107c5b <swap_map_swappable>
            page->pra_vaddr = addr;
c010997d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109980:	8b 55 10             	mov    0x10(%ebp),%edx
c0109983:	89 50 20             	mov    %edx,0x20(%eax)
c0109986:	eb 17                	jmp    c010999f <do_pgfault+0x20c>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0109988:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010998b:	8b 00                	mov    (%eax),%eax
c010998d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109991:	c7 04 24 70 d4 10 c0 	movl   $0xc010d470,(%esp)
c0109998:	e8 45 7e ff ff       	call   c01017e2 <cprintf>
            goto failed;
c010999d:	eb 07                	jmp    c01099a6 <do_pgfault+0x213>
        }
   }
   ret = 0;
c010999f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c01099a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01099a9:	c9                   	leave  
c01099aa:	c3                   	ret    

c01099ab <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01099ab:	55                   	push   %ebp
c01099ac:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01099ae:	8b 55 08             	mov    0x8(%ebp),%edx
c01099b1:	a1 8c e0 12 c0       	mov    0xc012e08c,%eax
c01099b6:	29 c2                	sub    %eax,%edx
c01099b8:	89 d0                	mov    %edx,%eax
c01099ba:	c1 f8 02             	sar    $0x2,%eax
c01099bd:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c01099c3:	5d                   	pop    %ebp
c01099c4:	c3                   	ret    

c01099c5 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01099c5:	55                   	push   %ebp
c01099c6:	89 e5                	mov    %esp,%ebp
c01099c8:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01099cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01099ce:	89 04 24             	mov    %eax,(%esp)
c01099d1:	e8 d5 ff ff ff       	call   c01099ab <page2ppn>
c01099d6:	c1 e0 0c             	shl    $0xc,%eax
}
c01099d9:	c9                   	leave  
c01099da:	c3                   	ret    

c01099db <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c01099db:	55                   	push   %ebp
c01099dc:	89 e5                	mov    %esp,%ebp
c01099de:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01099e1:	8b 45 08             	mov    0x8(%ebp),%eax
c01099e4:	89 04 24             	mov    %eax,(%esp)
c01099e7:	e8 d9 ff ff ff       	call   c01099c5 <page2pa>
c01099ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01099ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01099f2:	c1 e8 0c             	shr    $0xc,%eax
c01099f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01099f8:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c01099fd:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109a00:	72 23                	jb     c0109a25 <page2kva+0x4a>
c0109a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a05:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109a09:	c7 44 24 08 98 d4 10 	movl   $0xc010d498,0x8(%esp)
c0109a10:	c0 
c0109a11:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0109a18:	00 
c0109a19:	c7 04 24 bb d4 10 c0 	movl   $0xc010d4bb,(%esp)
c0109a20:	e8 47 87 ff ff       	call   c010216c <__panic>
c0109a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109a28:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0109a2d:	c9                   	leave  
c0109a2e:	c3                   	ret    

c0109a2f <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c0109a2f:	55                   	push   %ebp
c0109a30:	89 e5                	mov    %esp,%ebp
c0109a32:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c0109a35:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109a3c:	e8 8c 94 ff ff       	call   c0102ecd <ide_device_valid>
c0109a41:	85 c0                	test   %eax,%eax
c0109a43:	75 1c                	jne    c0109a61 <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c0109a45:	c7 44 24 08 c9 d4 10 	movl   $0xc010d4c9,0x8(%esp)
c0109a4c:	c0 
c0109a4d:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c0109a54:	00 
c0109a55:	c7 04 24 e3 d4 10 c0 	movl   $0xc010d4e3,(%esp)
c0109a5c:	e8 0b 87 ff ff       	call   c010216c <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c0109a61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109a68:	e8 9f 94 ff ff       	call   c0102f0c <ide_device_size>
c0109a6d:	c1 e8 03             	shr    $0x3,%eax
c0109a70:	a3 3c e1 12 c0       	mov    %eax,0xc012e13c
}
c0109a75:	c9                   	leave  
c0109a76:	c3                   	ret    

c0109a77 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c0109a77:	55                   	push   %ebp
c0109a78:	89 e5                	mov    %esp,%ebp
c0109a7a:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0109a7d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109a80:	89 04 24             	mov    %eax,(%esp)
c0109a83:	e8 53 ff ff ff       	call   c01099db <page2kva>
c0109a88:	8b 55 08             	mov    0x8(%ebp),%edx
c0109a8b:	c1 ea 08             	shr    $0x8,%edx
c0109a8e:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109a91:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109a95:	74 0b                	je     c0109aa2 <swapfs_read+0x2b>
c0109a97:	8b 15 3c e1 12 c0    	mov    0xc012e13c,%edx
c0109a9d:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109aa0:	72 23                	jb     c0109ac5 <swapfs_read+0x4e>
c0109aa2:	8b 45 08             	mov    0x8(%ebp),%eax
c0109aa5:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109aa9:	c7 44 24 08 f4 d4 10 	movl   $0xc010d4f4,0x8(%esp)
c0109ab0:	c0 
c0109ab1:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0109ab8:	00 
c0109ab9:	c7 04 24 e3 d4 10 c0 	movl   $0xc010d4e3,(%esp)
c0109ac0:	e8 a7 86 ff ff       	call   c010216c <__panic>
c0109ac5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109ac8:	c1 e2 03             	shl    $0x3,%edx
c0109acb:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0109ad2:	00 
c0109ad3:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109ad7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109adb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109ae2:	e8 64 94 ff ff       	call   c0102f4b <ide_read_secs>
}
c0109ae7:	c9                   	leave  
c0109ae8:	c3                   	ret    

c0109ae9 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0109ae9:	55                   	push   %ebp
c0109aea:	89 e5                	mov    %esp,%ebp
c0109aec:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c0109aef:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109af2:	89 04 24             	mov    %eax,(%esp)
c0109af5:	e8 e1 fe ff ff       	call   c01099db <page2kva>
c0109afa:	8b 55 08             	mov    0x8(%ebp),%edx
c0109afd:	c1 ea 08             	shr    $0x8,%edx
c0109b00:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0109b03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109b07:	74 0b                	je     c0109b14 <swapfs_write+0x2b>
c0109b09:	8b 15 3c e1 12 c0    	mov    0xc012e13c,%edx
c0109b0f:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0109b12:	72 23                	jb     c0109b37 <swapfs_write+0x4e>
c0109b14:	8b 45 08             	mov    0x8(%ebp),%eax
c0109b17:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109b1b:	c7 44 24 08 f4 d4 10 	movl   $0xc010d4f4,0x8(%esp)
c0109b22:	c0 
c0109b23:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c0109b2a:	00 
c0109b2b:	c7 04 24 e3 d4 10 c0 	movl   $0xc010d4e3,(%esp)
c0109b32:	e8 35 86 ff ff       	call   c010216c <__panic>
c0109b37:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0109b3a:	c1 e2 03             	shl    $0x3,%edx
c0109b3d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0109b44:	00 
c0109b45:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109b49:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109b4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0109b54:	e8 34 96 ff ff       	call   c010318d <ide_write_secs>
}
c0109b59:	c9                   	leave  
c0109b5a:	c3                   	ret    

c0109b5b <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

    pushl %edx              # push arg
c0109b5b:	52                   	push   %edx
    call *%ebx              # call fn
c0109b5c:	ff d3                	call   *%ebx

    pushl %eax              # save the return value of fn(arg)
c0109b5e:	50                   	push   %eax
    call do_exit            # call do_exit to terminate current thread
c0109b5f:	e8 4b 08 00 00       	call   c010a3af <do_exit>

c0109b64 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0109b64:	55                   	push   %ebp
c0109b65:	89 e5                	mov    %esp,%ebp
c0109b67:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0109b6a:	9c                   	pushf  
c0109b6b:	58                   	pop    %eax
c0109b6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0109b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0109b72:	25 00 02 00 00       	and    $0x200,%eax
c0109b77:	85 c0                	test   %eax,%eax
c0109b79:	74 0c                	je     c0109b87 <__intr_save+0x23>
        intr_disable();
c0109b7b:	e8 55 98 ff ff       	call   c01033d5 <intr_disable>
        return 1;
c0109b80:	b8 01 00 00 00       	mov    $0x1,%eax
c0109b85:	eb 05                	jmp    c0109b8c <__intr_save+0x28>
    }
    return 0;
c0109b87:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0109b8c:	c9                   	leave  
c0109b8d:	c3                   	ret    

c0109b8e <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0109b8e:	55                   	push   %ebp
c0109b8f:	89 e5                	mov    %esp,%ebp
c0109b91:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0109b94:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0109b98:	74 05                	je     c0109b9f <__intr_restore+0x11>
        intr_enable();
c0109b9a:	e8 30 98 ff ff       	call   c01033cf <intr_enable>
    }
}
c0109b9f:	c9                   	leave  
c0109ba0:	c3                   	ret    

c0109ba1 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0109ba1:	55                   	push   %ebp
c0109ba2:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0109ba4:	8b 55 08             	mov    0x8(%ebp),%edx
c0109ba7:	a1 8c e0 12 c0       	mov    0xc012e08c,%eax
c0109bac:	29 c2                	sub    %eax,%edx
c0109bae:	89 d0                	mov    %edx,%eax
c0109bb0:	c1 f8 02             	sar    $0x2,%eax
c0109bb3:	69 c0 39 8e e3 38    	imul   $0x38e38e39,%eax,%eax
}
c0109bb9:	5d                   	pop    %ebp
c0109bba:	c3                   	ret    

c0109bbb <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0109bbb:	55                   	push   %ebp
c0109bbc:	89 e5                	mov    %esp,%ebp
c0109bbe:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0109bc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bc4:	89 04 24             	mov    %eax,(%esp)
c0109bc7:	e8 d5 ff ff ff       	call   c0109ba1 <page2ppn>
c0109bcc:	c1 e0 0c             	shl    $0xc,%eax
}
c0109bcf:	c9                   	leave  
c0109bd0:	c3                   	ret    

c0109bd1 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0109bd1:	55                   	push   %ebp
c0109bd2:	89 e5                	mov    %esp,%ebp
c0109bd4:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0109bd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109bda:	c1 e8 0c             	shr    $0xc,%eax
c0109bdd:	89 c2                	mov    %eax,%edx
c0109bdf:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c0109be4:	39 c2                	cmp    %eax,%edx
c0109be6:	72 1c                	jb     c0109c04 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0109be8:	c7 44 24 08 14 d5 10 	movl   $0xc010d514,0x8(%esp)
c0109bef:	c0 
c0109bf0:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
c0109bf7:	00 
c0109bf8:	c7 04 24 33 d5 10 c0 	movl   $0xc010d533,(%esp)
c0109bff:	e8 68 85 ff ff       	call   c010216c <__panic>
    }
    return &pages[PPN(pa)];
c0109c04:	8b 0d 8c e0 12 c0    	mov    0xc012e08c,%ecx
c0109c0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c0d:	c1 e8 0c             	shr    $0xc,%eax
c0109c10:	89 c2                	mov    %eax,%edx
c0109c12:	89 d0                	mov    %edx,%eax
c0109c14:	c1 e0 03             	shl    $0x3,%eax
c0109c17:	01 d0                	add    %edx,%eax
c0109c19:	c1 e0 02             	shl    $0x2,%eax
c0109c1c:	01 c8                	add    %ecx,%eax
}
c0109c1e:	c9                   	leave  
c0109c1f:	c3                   	ret    

c0109c20 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0109c20:	55                   	push   %ebp
c0109c21:	89 e5                	mov    %esp,%ebp
c0109c23:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0109c26:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c29:	89 04 24             	mov    %eax,(%esp)
c0109c2c:	e8 8a ff ff ff       	call   c0109bbb <page2pa>
c0109c31:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c37:	c1 e8 0c             	shr    $0xc,%eax
c0109c3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109c3d:	a1 a0 bf 12 c0       	mov    0xc012bfa0,%eax
c0109c42:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0109c45:	72 23                	jb     c0109c6a <page2kva+0x4a>
c0109c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109c4e:	c7 44 24 08 44 d5 10 	movl   $0xc010d544,0x8(%esp)
c0109c55:	c0 
c0109c56:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0109c5d:	00 
c0109c5e:	c7 04 24 33 d5 10 c0 	movl   $0xc010d533,(%esp)
c0109c65:	e8 02 85 ff ff       	call   c010216c <__panic>
c0109c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c6d:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0109c72:	c9                   	leave  
c0109c73:	c3                   	ret    

c0109c74 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0109c74:	55                   	push   %ebp
c0109c75:	89 e5                	mov    %esp,%ebp
c0109c77:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c0109c7a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109c7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109c80:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0109c87:	77 23                	ja     c0109cac <kva2page+0x38>
c0109c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109c8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0109c90:	c7 44 24 08 68 d5 10 	movl   $0xc010d568,0x8(%esp)
c0109c97:	c0 
c0109c98:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
c0109c9f:	00 
c0109ca0:	c7 04 24 33 d5 10 c0 	movl   $0xc010d533,(%esp)
c0109ca7:	e8 c0 84 ff ff       	call   c010216c <__panic>
c0109cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109caf:	05 00 00 00 40       	add    $0x40000000,%eax
c0109cb4:	89 04 24             	mov    %eax,(%esp)
c0109cb7:	e8 15 ff ff ff       	call   c0109bd1 <pa2page>
}
c0109cbc:	c9                   	leave  
c0109cbd:	c3                   	ret    

c0109cbe <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
c0109cbe:	55                   	push   %ebp
c0109cbf:	89 e5                	mov    %esp,%ebp
c0109cc1:	83 ec 28             	sub    $0x28,%esp
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
c0109cc4:	c7 04 24 68 00 00 00 	movl   $0x68,(%esp)
c0109ccb:	e8 fa c1 ff ff       	call   c0105eca <kmalloc>
c0109cd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (proc != NULL) {
c0109cd3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0109cd7:	0f 84 a1 00 00 00    	je     c0109d7e <alloc_proc+0xc0>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
c0109cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ce0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        proc->pid = -1;
c0109ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ce9:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
        proc->runs = 0;
c0109cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cf3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        proc->kstack = 0;
c0109cfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109cfd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        proc->need_resched = 0;
c0109d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d07:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        proc->parent = NULL;
c0109d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d11:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        proc->mm = NULL;
c0109d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d1b:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        memset(&(proc->context), 0, sizeof(struct context));
c0109d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d25:	83 c0 1c             	add    $0x1c,%eax
c0109d28:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
c0109d2f:	00 
c0109d30:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109d37:	00 
c0109d38:	89 04 24             	mov    %eax,(%esp)
c0109d3b:	e8 f1 14 00 00       	call   c010b231 <memset>
        proc->tf = NULL;
c0109d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d43:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
        proc->cr3 = boot_cr3;
c0109d4a:	8b 15 88 e0 12 c0    	mov    0xc012e088,%edx
c0109d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d53:	89 50 40             	mov    %edx,0x40(%eax)
        proc->flags = 0;
c0109d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d59:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
        memset(proc->name, 0, PROC_NAME_LEN);
c0109d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109d63:	83 c0 48             	add    $0x48,%eax
c0109d66:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0109d6d:	00 
c0109d6e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109d75:	00 
c0109d76:	89 04 24             	mov    %eax,(%esp)
c0109d79:	e8 b3 14 00 00       	call   c010b231 <memset>
    }
    return proc;
c0109d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0109d81:	c9                   	leave  
c0109d82:	c3                   	ret    

c0109d83 <set_proc_name>:

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
c0109d83:	55                   	push   %ebp
c0109d84:	89 e5                	mov    %esp,%ebp
c0109d86:	83 ec 18             	sub    $0x18,%esp
    memset(proc->name, 0, sizeof(proc->name));
c0109d89:	8b 45 08             	mov    0x8(%ebp),%eax
c0109d8c:	83 c0 48             	add    $0x48,%eax
c0109d8f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0109d96:	00 
c0109d97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109d9e:	00 
c0109d9f:	89 04 24             	mov    %eax,(%esp)
c0109da2:	e8 8a 14 00 00       	call   c010b231 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
c0109da7:	8b 45 08             	mov    0x8(%ebp),%eax
c0109daa:	8d 50 48             	lea    0x48(%eax),%edx
c0109dad:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0109db4:	00 
c0109db5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109db8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109dbc:	89 14 24             	mov    %edx,(%esp)
c0109dbf:	e8 4f 15 00 00       	call   c010b313 <memcpy>
}
c0109dc4:	c9                   	leave  
c0109dc5:	c3                   	ret    

c0109dc6 <get_proc_name>:

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
c0109dc6:	55                   	push   %ebp
c0109dc7:	89 e5                	mov    %esp,%ebp
c0109dc9:	83 ec 18             	sub    $0x18,%esp
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
c0109dcc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
c0109dd3:	00 
c0109dd4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0109ddb:	00 
c0109ddc:	c7 04 24 64 e0 12 c0 	movl   $0xc012e064,(%esp)
c0109de3:	e8 49 14 00 00       	call   c010b231 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
c0109de8:	8b 45 08             	mov    0x8(%ebp),%eax
c0109deb:	83 c0 48             	add    $0x48,%eax
c0109dee:	c7 44 24 08 0f 00 00 	movl   $0xf,0x8(%esp)
c0109df5:	00 
c0109df6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0109dfa:	c7 04 24 64 e0 12 c0 	movl   $0xc012e064,(%esp)
c0109e01:	e8 0d 15 00 00       	call   c010b313 <memcpy>
}
c0109e06:	c9                   	leave  
c0109e07:	c3                   	ret    

c0109e08 <get_pid>:

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
c0109e08:	55                   	push   %ebp
c0109e09:	89 e5                	mov    %esp,%ebp
c0109e0b:	83 ec 10             	sub    $0x10,%esp
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
c0109e0e:	c7 45 f8 70 e1 12 c0 	movl   $0xc012e170,-0x8(%ebp)
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
c0109e15:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0109e1a:	83 c0 01             	add    $0x1,%eax
c0109e1d:	a3 80 8a 12 c0       	mov    %eax,0xc0128a80
c0109e22:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0109e27:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109e2c:	7e 0c                	jle    c0109e3a <get_pid+0x32>
        last_pid = 1;
c0109e2e:	c7 05 80 8a 12 c0 01 	movl   $0x1,0xc0128a80
c0109e35:	00 00 00 
        goto inside;
c0109e38:	eb 13                	jmp    c0109e4d <get_pid+0x45>
    }
    if (last_pid >= next_safe) {
c0109e3a:	8b 15 80 8a 12 c0    	mov    0xc0128a80,%edx
c0109e40:	a1 84 8a 12 c0       	mov    0xc0128a84,%eax
c0109e45:	39 c2                	cmp    %eax,%edx
c0109e47:	0f 8c ac 00 00 00    	jl     c0109ef9 <get_pid+0xf1>
    inside:
        next_safe = MAX_PID;
c0109e4d:	c7 05 84 8a 12 c0 00 	movl   $0x2000,0xc0128a84
c0109e54:	20 00 00 
    repeat:
        le = list;
c0109e57:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0109e5a:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while ((le = list_next(le)) != list) {
c0109e5d:	eb 7f                	jmp    c0109ede <get_pid+0xd6>
            proc = le2proc(le, list_link);
c0109e5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109e62:	83 e8 58             	sub    $0x58,%eax
c0109e65:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (proc->pid == last_pid) {
c0109e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109e6b:	8b 50 04             	mov    0x4(%eax),%edx
c0109e6e:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0109e73:	39 c2                	cmp    %eax,%edx
c0109e75:	75 3e                	jne    c0109eb5 <get_pid+0xad>
                if (++ last_pid >= next_safe) {
c0109e77:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0109e7c:	83 c0 01             	add    $0x1,%eax
c0109e7f:	a3 80 8a 12 c0       	mov    %eax,0xc0128a80
c0109e84:	8b 15 80 8a 12 c0    	mov    0xc0128a80,%edx
c0109e8a:	a1 84 8a 12 c0       	mov    0xc0128a84,%eax
c0109e8f:	39 c2                	cmp    %eax,%edx
c0109e91:	7c 4b                	jl     c0109ede <get_pid+0xd6>
                    if (last_pid >= MAX_PID) {
c0109e93:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0109e98:	3d ff 1f 00 00       	cmp    $0x1fff,%eax
c0109e9d:	7e 0a                	jle    c0109ea9 <get_pid+0xa1>
                        last_pid = 1;
c0109e9f:	c7 05 80 8a 12 c0 01 	movl   $0x1,0xc0128a80
c0109ea6:	00 00 00 
                    }
                    next_safe = MAX_PID;
c0109ea9:	c7 05 84 8a 12 c0 00 	movl   $0x2000,0xc0128a84
c0109eb0:	20 00 00 
                    goto repeat;
c0109eb3:	eb a2                	jmp    c0109e57 <get_pid+0x4f>
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
c0109eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109eb8:	8b 50 04             	mov    0x4(%eax),%edx
c0109ebb:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
c0109ec0:	39 c2                	cmp    %eax,%edx
c0109ec2:	7e 1a                	jle    c0109ede <get_pid+0xd6>
c0109ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ec7:	8b 50 04             	mov    0x4(%eax),%edx
c0109eca:	a1 84 8a 12 c0       	mov    0xc0128a84,%eax
c0109ecf:	39 c2                	cmp    %eax,%edx
c0109ed1:	7d 0b                	jge    c0109ede <get_pid+0xd6>
                next_safe = proc->pid;
c0109ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109ed6:	8b 40 04             	mov    0x4(%eax),%eax
c0109ed9:	a3 84 8a 12 c0       	mov    %eax,0xc0128a84
c0109ede:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109ee1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0109ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109ee7:	8b 40 04             	mov    0x4(%eax),%eax
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
c0109eea:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0109eed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0109ef0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0109ef3:	0f 85 66 ff ff ff    	jne    c0109e5f <get_pid+0x57>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
c0109ef9:	a1 80 8a 12 c0       	mov    0xc0128a80,%eax
}
c0109efe:	c9                   	leave  
c0109eff:	c3                   	ret    

c0109f00 <proc_run>:

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
c0109f00:	55                   	push   %ebp
c0109f01:	89 e5                	mov    %esp,%ebp
c0109f03:	83 ec 28             	sub    $0x28,%esp
    if (proc != current) {
c0109f06:	a1 48 c0 12 c0       	mov    0xc012c048,%eax
c0109f0b:	39 45 08             	cmp    %eax,0x8(%ebp)
c0109f0e:	74 63                	je     c0109f73 <proc_run+0x73>
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
c0109f10:	a1 48 c0 12 c0       	mov    0xc012c048,%eax
c0109f15:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109f18:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        local_intr_save(intr_flag);
c0109f1e:	e8 41 fc ff ff       	call   c0109b64 <__intr_save>
c0109f23:	89 45 ec             	mov    %eax,-0x14(%ebp)
        {
            current = proc;
c0109f26:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f29:	a3 48 c0 12 c0       	mov    %eax,0xc012c048
            load_esp0(next->kstack + KSTACKSIZE);
c0109f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f31:	8b 40 0c             	mov    0xc(%eax),%eax
c0109f34:	05 00 20 00 00       	add    $0x2000,%eax
c0109f39:	89 04 24             	mov    %eax,(%esp)
c0109f3c:	e8 c0 c2 ff ff       	call   c0106201 <load_esp0>
            lcr3(next->cr3);
c0109f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f44:	8b 40 40             	mov    0x40(%eax),%eax
c0109f47:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("mov %0, %%cr0" :: "r" (cr0) : "memory");
}

static inline void
lcr3(uintptr_t cr3) {
    asm volatile ("mov %0, %%cr3" :: "r" (cr3) : "memory");
c0109f4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109f4d:	0f 22 d8             	mov    %eax,%cr3
            switch_to(&(prev->context), &(next->context));
c0109f50:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109f53:	8d 50 1c             	lea    0x1c(%eax),%edx
c0109f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109f59:	83 c0 1c             	add    $0x1c,%eax
c0109f5c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0109f60:	89 04 24             	mov    %eax,(%esp)
c0109f63:	e8 99 06 00 00       	call   c010a601 <switch_to>
        }
        local_intr_restore(intr_flag);
c0109f68:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109f6b:	89 04 24             	mov    %eax,(%esp)
c0109f6e:	e8 1b fc ff ff       	call   c0109b8e <__intr_restore>
    }
}
c0109f73:	c9                   	leave  
c0109f74:	c3                   	ret    

c0109f75 <forkret>:

// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
c0109f75:	55                   	push   %ebp
c0109f76:	89 e5                	mov    %esp,%ebp
c0109f78:	83 ec 18             	sub    $0x18,%esp
    forkrets(current->tf);
c0109f7b:	a1 48 c0 12 c0       	mov    0xc012c048,%eax
c0109f80:	8b 40 3c             	mov    0x3c(%eax),%eax
c0109f83:	89 04 24             	mov    %eax,(%esp)
c0109f86:	e8 94 9c ff ff       	call   c0103c1f <forkrets>
}
c0109f8b:	c9                   	leave  
c0109f8c:	c3                   	ret    

c0109f8d <hash_proc>:

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
c0109f8d:	55                   	push   %ebp
c0109f8e:	89 e5                	mov    %esp,%ebp
c0109f90:	53                   	push   %ebx
c0109f91:	83 ec 34             	sub    $0x34,%esp
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
c0109f94:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f97:	8d 58 60             	lea    0x60(%eax),%ebx
c0109f9a:	8b 45 08             	mov    0x8(%ebp),%eax
c0109f9d:	8b 40 04             	mov    0x4(%eax),%eax
c0109fa0:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c0109fa7:	00 
c0109fa8:	89 04 24             	mov    %eax,(%esp)
c0109fab:	e8 d4 07 00 00       	call   c010a784 <hash32>
c0109fb0:	c1 e0 03             	shl    $0x3,%eax
c0109fb3:	05 60 c0 12 c0       	add    $0xc012c060,%eax
c0109fb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0109fbb:	89 5d f0             	mov    %ebx,-0x10(%ebp)
c0109fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0109fc1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0109fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0109fc7:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0109fca:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0109fcd:	8b 40 04             	mov    0x4(%eax),%eax
c0109fd0:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0109fd3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0109fd6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109fd9:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0109fdc:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0109fdf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109fe2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0109fe5:	89 10                	mov    %edx,(%eax)
c0109fe7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0109fea:	8b 10                	mov    (%eax),%edx
c0109fec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0109fef:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0109ff2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109ff5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0109ff8:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0109ffb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0109ffe:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010a001:	89 10                	mov    %edx,(%eax)
}
c010a003:	83 c4 34             	add    $0x34,%esp
c010a006:	5b                   	pop    %ebx
c010a007:	5d                   	pop    %ebp
c010a008:	c3                   	ret    

c010a009 <find_proc>:

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
c010a009:	55                   	push   %ebp
c010a00a:	89 e5                	mov    %esp,%ebp
c010a00c:	83 ec 28             	sub    $0x28,%esp
    if (0 < pid && pid < MAX_PID) {
c010a00f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010a013:	7e 5f                	jle    c010a074 <find_proc+0x6b>
c010a015:	81 7d 08 ff 1f 00 00 	cmpl   $0x1fff,0x8(%ebp)
c010a01c:	7f 56                	jg     c010a074 <find_proc+0x6b>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
c010a01e:	8b 45 08             	mov    0x8(%ebp),%eax
c010a021:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
c010a028:	00 
c010a029:	89 04 24             	mov    %eax,(%esp)
c010a02c:	e8 53 07 00 00       	call   c010a784 <hash32>
c010a031:	c1 e0 03             	shl    $0x3,%eax
c010a034:	05 60 c0 12 c0       	add    $0xc012c060,%eax
c010a039:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a03c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a03f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        while ((le = list_next(le)) != list) {
c010a042:	eb 19                	jmp    c010a05d <find_proc+0x54>
            struct proc_struct *proc = le2proc(le, hash_link);
c010a044:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a047:	83 e8 60             	sub    $0x60,%eax
c010a04a:	89 45 ec             	mov    %eax,-0x14(%ebp)
            if (proc->pid == pid) {
c010a04d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a050:	8b 40 04             	mov    0x4(%eax),%eax
c010a053:	3b 45 08             	cmp    0x8(%ebp),%eax
c010a056:	75 05                	jne    c010a05d <find_proc+0x54>
                return proc;
c010a058:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a05b:	eb 1c                	jmp    c010a079 <find_proc+0x70>
c010a05d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a060:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010a063:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a066:	8b 40 04             	mov    0x4(%eax),%eax
// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
c010a069:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a06c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a06f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010a072:	75 d0                	jne    c010a044 <find_proc+0x3b>
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
c010a074:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a079:	c9                   	leave  
c010a07a:	c3                   	ret    

c010a07b <kernel_thread>:

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
c010a07b:	55                   	push   %ebp
c010a07c:	89 e5                	mov    %esp,%ebp
c010a07e:	83 ec 68             	sub    $0x68,%esp
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
c010a081:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
c010a088:	00 
c010a089:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a090:	00 
c010a091:	8d 45 ac             	lea    -0x54(%ebp),%eax
c010a094:	89 04 24             	mov    %eax,(%esp)
c010a097:	e8 95 11 00 00       	call   c010b231 <memset>
    tf.tf_cs = KERNEL_CS;
c010a09c:	66 c7 45 e8 08 00    	movw   $0x8,-0x18(%ebp)
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
c010a0a2:	66 c7 45 f4 10 00    	movw   $0x10,-0xc(%ebp)
c010a0a8:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c010a0ac:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
c010a0b0:	0f b7 45 d4          	movzwl -0x2c(%ebp),%eax
c010a0b4:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    tf.tf_regs.reg_ebx = (uint32_t)fn;
c010a0b8:	8b 45 08             	mov    0x8(%ebp),%eax
c010a0bb:	89 45 bc             	mov    %eax,-0x44(%ebp)
    tf.tf_regs.reg_edx = (uint32_t)arg;
c010a0be:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a0c1:	89 45 c0             	mov    %eax,-0x40(%ebp)
    tf.tf_eip = (uint32_t)kernel_thread_entry;
c010a0c4:	b8 5b 9b 10 c0       	mov    $0xc0109b5b,%eax
c010a0c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
c010a0cc:	8b 45 10             	mov    0x10(%ebp),%eax
c010a0cf:	80 cc 01             	or     $0x1,%ah
c010a0d2:	89 c2                	mov    %eax,%edx
c010a0d4:	8d 45 ac             	lea    -0x54(%ebp),%eax
c010a0d7:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a0db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010a0e2:	00 
c010a0e3:	89 14 24             	mov    %edx,(%esp)
c010a0e6:	e8 79 01 00 00       	call   c010a264 <do_fork>
}
c010a0eb:	c9                   	leave  
c010a0ec:	c3                   	ret    

c010a0ed <setup_kstack>:

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
c010a0ed:	55                   	push   %ebp
c010a0ee:	89 e5                	mov    %esp,%ebp
c010a0f0:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_pages(KSTACKPAGE);
c010a0f3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010a0fa:	e8 50 c2 ff ff       	call   c010634f <alloc_pages>
c010a0ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c010a102:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010a106:	74 1a                	je     c010a122 <setup_kstack+0x35>
        proc->kstack = (uintptr_t)page2kva(page);
c010a108:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a10b:	89 04 24             	mov    %eax,(%esp)
c010a10e:	e8 0d fb ff ff       	call   c0109c20 <page2kva>
c010a113:	89 c2                	mov    %eax,%edx
c010a115:	8b 45 08             	mov    0x8(%ebp),%eax
c010a118:	89 50 0c             	mov    %edx,0xc(%eax)
        return 0;
c010a11b:	b8 00 00 00 00       	mov    $0x0,%eax
c010a120:	eb 05                	jmp    c010a127 <setup_kstack+0x3a>
    }
    return -E_NO_MEM;
c010a122:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
c010a127:	c9                   	leave  
c010a128:	c3                   	ret    

c010a129 <put_kstack>:

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
c010a129:	55                   	push   %ebp
c010a12a:	89 e5                	mov    %esp,%ebp
c010a12c:	83 ec 18             	sub    $0x18,%esp
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
c010a12f:	8b 45 08             	mov    0x8(%ebp),%eax
c010a132:	8b 40 0c             	mov    0xc(%eax),%eax
c010a135:	89 04 24             	mov    %eax,(%esp)
c010a138:	e8 37 fb ff ff       	call   c0109c74 <kva2page>
c010a13d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c010a144:	00 
c010a145:	89 04 24             	mov    %eax,(%esp)
c010a148:	e8 6d c2 ff ff       	call   c01063ba <free_pages>
}
c010a14d:	c9                   	leave  
c010a14e:	c3                   	ret    

c010a14f <copy_mm>:

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
c010a14f:	55                   	push   %ebp
c010a150:	89 e5                	mov    %esp,%ebp
c010a152:	83 ec 18             	sub    $0x18,%esp
    assert(current->mm == NULL);
c010a155:	a1 48 c0 12 c0       	mov    0xc012c048,%eax
c010a15a:	8b 40 18             	mov    0x18(%eax),%eax
c010a15d:	85 c0                	test   %eax,%eax
c010a15f:	74 24                	je     c010a185 <copy_mm+0x36>
c010a161:	c7 44 24 0c 8c d5 10 	movl   $0xc010d58c,0xc(%esp)
c010a168:	c0 
c010a169:	c7 44 24 08 a0 d5 10 	movl   $0xc010d5a0,0x8(%esp)
c010a170:	c0 
c010a171:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c010a178:	00 
c010a179:	c7 04 24 b5 d5 10 c0 	movl   $0xc010d5b5,(%esp)
c010a180:	e8 e7 7f ff ff       	call   c010216c <__panic>
    /* do nothing in this project */
    return 0;
c010a185:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a18a:	c9                   	leave  
c010a18b:	c3                   	ret    

c010a18c <copy_thread>:

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
c010a18c:	55                   	push   %ebp
c010a18d:	89 e5                	mov    %esp,%ebp
c010a18f:	57                   	push   %edi
c010a190:	56                   	push   %esi
c010a191:	53                   	push   %ebx
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
c010a192:	8b 45 08             	mov    0x8(%ebp),%eax
c010a195:	8b 40 0c             	mov    0xc(%eax),%eax
c010a198:	05 b4 1f 00 00       	add    $0x1fb4,%eax
c010a19d:	89 c2                	mov    %eax,%edx
c010a19f:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1a2:	89 50 3c             	mov    %edx,0x3c(%eax)
    *(proc->tf) = *tf;
c010a1a5:	8b 45 08             	mov    0x8(%ebp),%eax
c010a1a8:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a1ab:	8b 55 10             	mov    0x10(%ebp),%edx
c010a1ae:	bb 4c 00 00 00       	mov    $0x4c,%ebx
c010a1b3:	89 c1                	mov    %eax,%ecx
c010a1b5:	83 e1 01             	and    $0x1,%ecx
c010a1b8:	85 c9                	test   %ecx,%ecx
c010a1ba:	74 0e                	je     c010a1ca <copy_thread+0x3e>
c010a1bc:	0f b6 0a             	movzbl (%edx),%ecx
c010a1bf:	88 08                	mov    %cl,(%eax)
c010a1c1:	83 c0 01             	add    $0x1,%eax
c010a1c4:	83 c2 01             	add    $0x1,%edx
c010a1c7:	83 eb 01             	sub    $0x1,%ebx
c010a1ca:	89 c1                	mov    %eax,%ecx
c010a1cc:	83 e1 02             	and    $0x2,%ecx
c010a1cf:	85 c9                	test   %ecx,%ecx
c010a1d1:	74 0f                	je     c010a1e2 <copy_thread+0x56>
c010a1d3:	0f b7 0a             	movzwl (%edx),%ecx
c010a1d6:	66 89 08             	mov    %cx,(%eax)
c010a1d9:	83 c0 02             	add    $0x2,%eax
c010a1dc:	83 c2 02             	add    $0x2,%edx
c010a1df:	83 eb 02             	sub    $0x2,%ebx
c010a1e2:	89 d9                	mov    %ebx,%ecx
c010a1e4:	c1 e9 02             	shr    $0x2,%ecx
c010a1e7:	89 c7                	mov    %eax,%edi
c010a1e9:	89 d6                	mov    %edx,%esi
c010a1eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010a1ed:	89 f2                	mov    %esi,%edx
c010a1ef:	89 f8                	mov    %edi,%eax
c010a1f1:	b9 00 00 00 00       	mov    $0x0,%ecx
c010a1f6:	89 de                	mov    %ebx,%esi
c010a1f8:	83 e6 02             	and    $0x2,%esi
c010a1fb:	85 f6                	test   %esi,%esi
c010a1fd:	74 0b                	je     c010a20a <copy_thread+0x7e>
c010a1ff:	0f b7 34 0a          	movzwl (%edx,%ecx,1),%esi
c010a203:	66 89 34 08          	mov    %si,(%eax,%ecx,1)
c010a207:	83 c1 02             	add    $0x2,%ecx
c010a20a:	83 e3 01             	and    $0x1,%ebx
c010a20d:	85 db                	test   %ebx,%ebx
c010a20f:	74 07                	je     c010a218 <copy_thread+0x8c>
c010a211:	0f b6 14 0a          	movzbl (%edx,%ecx,1),%edx
c010a215:	88 14 08             	mov    %dl,(%eax,%ecx,1)
    proc->tf->tf_regs.reg_eax = 0;
c010a218:	8b 45 08             	mov    0x8(%ebp),%eax
c010a21b:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a21e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    proc->tf->tf_esp = esp;
c010a225:	8b 45 08             	mov    0x8(%ebp),%eax
c010a228:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a22b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a22e:	89 50 44             	mov    %edx,0x44(%eax)
    proc->tf->tf_eflags |= FL_IF;
c010a231:	8b 45 08             	mov    0x8(%ebp),%eax
c010a234:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a237:	8b 55 08             	mov    0x8(%ebp),%edx
c010a23a:	8b 52 3c             	mov    0x3c(%edx),%edx
c010a23d:	8b 52 40             	mov    0x40(%edx),%edx
c010a240:	80 ce 02             	or     $0x2,%dh
c010a243:	89 50 40             	mov    %edx,0x40(%eax)

    proc->context.eip = (uintptr_t)forkret;
c010a246:	ba 75 9f 10 c0       	mov    $0xc0109f75,%edx
c010a24b:	8b 45 08             	mov    0x8(%ebp),%eax
c010a24e:	89 50 1c             	mov    %edx,0x1c(%eax)
    proc->context.esp = (uintptr_t)(proc->tf);
c010a251:	8b 45 08             	mov    0x8(%ebp),%eax
c010a254:	8b 40 3c             	mov    0x3c(%eax),%eax
c010a257:	89 c2                	mov    %eax,%edx
c010a259:	8b 45 08             	mov    0x8(%ebp),%eax
c010a25c:	89 50 20             	mov    %edx,0x20(%eax)
}
c010a25f:	5b                   	pop    %ebx
c010a260:	5e                   	pop    %esi
c010a261:	5f                   	pop    %edi
c010a262:	5d                   	pop    %ebp
c010a263:	c3                   	ret    

c010a264 <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
c010a264:	55                   	push   %ebp
c010a265:	89 e5                	mov    %esp,%ebp
c010a267:	83 ec 48             	sub    $0x48,%esp
    int ret = -E_NO_FREE_PROC;
c010a26a:	c7 45 f4 fb ff ff ff 	movl   $0xfffffffb,-0xc(%ebp)
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
c010a271:	a1 60 e0 12 c0       	mov    0xc012e060,%eax
c010a276:	3d ff 0f 00 00       	cmp    $0xfff,%eax
c010a27b:	7e 05                	jle    c010a282 <do_fork+0x1e>
        goto fork_out;
c010a27d:	e9 19 01 00 00       	jmp    c010a39b <do_fork+0x137>
    }
    ret = -E_NO_MEM;
c010a282:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL) {
c010a289:	e8 30 fa ff ff       	call   c0109cbe <alloc_proc>
c010a28e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a291:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a295:	75 05                	jne    c010a29c <do_fork+0x38>
        goto fork_out;
c010a297:	e9 ff 00 00 00       	jmp    c010a39b <do_fork+0x137>
    }

    proc->parent = current;
c010a29c:	8b 15 48 c0 12 c0    	mov    0xc012c048,%edx
c010a2a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a2a5:	89 50 14             	mov    %edx,0x14(%eax)

    if (setup_kstack(proc) != 0) {
c010a2a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a2ab:	89 04 24             	mov    %eax,(%esp)
c010a2ae:	e8 3a fe ff ff       	call   c010a0ed <setup_kstack>
c010a2b3:	85 c0                	test   %eax,%eax
c010a2b5:	74 05                	je     c010a2bc <do_fork+0x58>
        goto bad_fork_cleanup_proc;
c010a2b7:	e9 e4 00 00 00       	jmp    c010a3a0 <do_fork+0x13c>
    }
    if (copy_mm(clone_flags, proc) != 0) {
c010a2bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a2bf:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a2c3:	8b 45 08             	mov    0x8(%ebp),%eax
c010a2c6:	89 04 24             	mov    %eax,(%esp)
c010a2c9:	e8 81 fe ff ff       	call   c010a14f <copy_mm>
c010a2ce:	85 c0                	test   %eax,%eax
c010a2d0:	74 11                	je     c010a2e3 <do_fork+0x7f>
        goto bad_fork_cleanup_kstack;
c010a2d2:	90                   	nop
    ret = proc->pid;
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
c010a2d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a2d6:	89 04 24             	mov    %eax,(%esp)
c010a2d9:	e8 4b fe ff ff       	call   c010a129 <put_kstack>
c010a2de:	e9 bd 00 00 00       	jmp    c010a3a0 <do_fork+0x13c>
        goto bad_fork_cleanup_proc;
    }
    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc, stack, tf);
c010a2e3:	8b 45 10             	mov    0x10(%ebp),%eax
c010a2e6:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a2ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a2ed:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a2f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a2f4:	89 04 24             	mov    %eax,(%esp)
c010a2f7:	e8 90 fe ff ff       	call   c010a18c <copy_thread>

    bool intr_flag;
    local_intr_save(intr_flag);
c010a2fc:	e8 63 f8 ff ff       	call   c0109b64 <__intr_save>
c010a301:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        proc->pid = get_pid();
c010a304:	e8 ff fa ff ff       	call   c0109e08 <get_pid>
c010a309:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010a30c:	89 42 04             	mov    %eax,0x4(%edx)
        hash_proc(proc);
c010a30f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a312:	89 04 24             	mov    %eax,(%esp)
c010a315:	e8 73 fc ff ff       	call   c0109f8d <hash_proc>
        list_add(&proc_list, &(proc->list_link));
c010a31a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a31d:	83 c0 58             	add    $0x58,%eax
c010a320:	c7 45 e8 70 e1 12 c0 	movl   $0xc012e170,-0x18(%ebp)
c010a327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010a32a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a32d:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a330:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a333:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010a336:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a339:	8b 40 04             	mov    0x4(%eax),%eax
c010a33c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010a33f:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010a342:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010a345:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010a348:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010a34b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a34e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010a351:	89 10                	mov    %edx,(%eax)
c010a353:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a356:	8b 10                	mov    (%eax),%edx
c010a358:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010a35b:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010a35e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a361:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010a364:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010a367:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a36a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a36d:	89 10                	mov    %edx,(%eax)
        nr_process ++;
c010a36f:	a1 60 e0 12 c0       	mov    0xc012e060,%eax
c010a374:	83 c0 01             	add    $0x1,%eax
c010a377:	a3 60 e0 12 c0       	mov    %eax,0xc012e060
    }
    local_intr_restore(intr_flag);
c010a37c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a37f:	89 04 24             	mov    %eax,(%esp)
c010a382:	e8 07 f8 ff ff       	call   c0109b8e <__intr_restore>

    wakeup_proc(proc);
c010a387:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a38a:	89 04 24             	mov    %eax,(%esp)
c010a38d:	e8 e3 02 00 00       	call   c010a675 <wakeup_proc>

    ret = proc->pid;
c010a392:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a395:	8b 40 04             	mov    0x4(%eax),%eax
c010a398:	89 45 f4             	mov    %eax,-0xc(%ebp)
fork_out:
    return ret;
c010a39b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a39e:	eb 0d                	jmp    c010a3ad <do_fork+0x149>

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
c010a3a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a3a3:	89 04 24             	mov    %eax,(%esp)
c010a3a6:	e8 3a bb ff ff       	call   c0105ee5 <kfree>
    goto fork_out;
c010a3ab:	eb ee                	jmp    c010a39b <do_fork+0x137>
}
c010a3ad:	c9                   	leave  
c010a3ae:	c3                   	ret    

c010a3af <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int
do_exit(int error_code) {
c010a3af:	55                   	push   %ebp
c010a3b0:	89 e5                	mov    %esp,%ebp
c010a3b2:	83 ec 18             	sub    $0x18,%esp
    panic("process exit!!.\n");
c010a3b5:	c7 44 24 08 c9 d5 10 	movl   $0xc010d5c9,0x8(%esp)
c010a3bc:	c0 
c010a3bd:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
c010a3c4:	00 
c010a3c5:	c7 04 24 b5 d5 10 c0 	movl   $0xc010d5b5,(%esp)
c010a3cc:	e8 9b 7d ff ff       	call   c010216c <__panic>

c010a3d1 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
c010a3d1:	55                   	push   %ebp
c010a3d2:	89 e5                	mov    %esp,%ebp
c010a3d4:	83 ec 18             	sub    $0x18,%esp
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
c010a3d7:	a1 48 c0 12 c0       	mov    0xc012c048,%eax
c010a3dc:	89 04 24             	mov    %eax,(%esp)
c010a3df:	e8 e2 f9 ff ff       	call   c0109dc6 <get_proc_name>
c010a3e4:	8b 15 48 c0 12 c0    	mov    0xc012c048,%edx
c010a3ea:	8b 52 04             	mov    0x4(%edx),%edx
c010a3ed:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a3f1:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a3f5:	c7 04 24 dc d5 10 c0 	movl   $0xc010d5dc,(%esp)
c010a3fc:	e8 e1 73 ff ff       	call   c01017e2 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
c010a401:	8b 45 08             	mov    0x8(%ebp),%eax
c010a404:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a408:	c7 04 24 02 d6 10 c0 	movl   $0xc010d602,(%esp)
c010a40f:	e8 ce 73 ff ff       	call   c01017e2 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
c010a414:	c7 04 24 0f d6 10 c0 	movl   $0xc010d60f,(%esp)
c010a41b:	e8 c2 73 ff ff       	call   c01017e2 <cprintf>
    return 0;
c010a420:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a425:	c9                   	leave  
c010a426:	c3                   	ret    

c010a427 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
c010a427:	55                   	push   %ebp
c010a428:	89 e5                	mov    %esp,%ebp
c010a42a:	83 ec 28             	sub    $0x28,%esp
c010a42d:	c7 45 ec 70 e1 12 c0 	movl   $0xc012e170,-0x14(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010a434:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a437:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a43a:	89 50 04             	mov    %edx,0x4(%eax)
c010a43d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a440:	8b 50 04             	mov    0x4(%eax),%edx
c010a443:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a446:	89 10                	mov    %edx,(%eax)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010a448:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010a44f:	eb 26                	jmp    c010a477 <proc_init+0x50>
        list_init(hash_list + i);
c010a451:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a454:	c1 e0 03             	shl    $0x3,%eax
c010a457:	05 60 c0 12 c0       	add    $0xc012c060,%eax
c010a45c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a45f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a462:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010a465:	89 50 04             	mov    %edx,0x4(%eax)
c010a468:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a46b:	8b 50 04             	mov    0x4(%eax),%edx
c010a46e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a471:	89 10                	mov    %edx,(%eax)
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
c010a473:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010a477:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
c010a47e:	7e d1                	jle    c010a451 <proc_init+0x2a>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
c010a480:	e8 39 f8 ff ff       	call   c0109cbe <alloc_proc>
c010a485:	a3 40 c0 12 c0       	mov    %eax,0xc012c040
c010a48a:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c010a48f:	85 c0                	test   %eax,%eax
c010a491:	75 1c                	jne    c010a4af <proc_init+0x88>
        panic("cannot alloc idleproc.\n");
c010a493:	c7 44 24 08 2b d6 10 	movl   $0xc010d62b,0x8(%esp)
c010a49a:	c0 
c010a49b:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
c010a4a2:	00 
c010a4a3:	c7 04 24 b5 d5 10 c0 	movl   $0xc010d5b5,(%esp)
c010a4aa:	e8 bd 7c ff ff       	call   c010216c <__panic>
    }

    idleproc->pid = 0;
c010a4af:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c010a4b4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    idleproc->state = PROC_RUNNABLE;
c010a4bb:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c010a4c0:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
    idleproc->kstack = (uintptr_t)bootstack;
c010a4c6:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c010a4cb:	ba 00 60 12 c0       	mov    $0xc0126000,%edx
c010a4d0:	89 50 0c             	mov    %edx,0xc(%eax)
    idleproc->need_resched = 1;
c010a4d3:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c010a4d8:	c7 40 10 01 00 00 00 	movl   $0x1,0x10(%eax)
    set_proc_name(idleproc, "idle");
c010a4df:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c010a4e4:	c7 44 24 04 43 d6 10 	movl   $0xc010d643,0x4(%esp)
c010a4eb:	c0 
c010a4ec:	89 04 24             	mov    %eax,(%esp)
c010a4ef:	e8 8f f8 ff ff       	call   c0109d83 <set_proc_name>
    nr_process ++;
c010a4f4:	a1 60 e0 12 c0       	mov    0xc012e060,%eax
c010a4f9:	83 c0 01             	add    $0x1,%eax
c010a4fc:	a3 60 e0 12 c0       	mov    %eax,0xc012e060

    current = idleproc;
c010a501:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c010a506:	a3 48 c0 12 c0       	mov    %eax,0xc012c048

    int pid = kernel_thread(init_main, "Hello world!!", 0);
c010a50b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010a512:	00 
c010a513:	c7 44 24 04 48 d6 10 	movl   $0xc010d648,0x4(%esp)
c010a51a:	c0 
c010a51b:	c7 04 24 d1 a3 10 c0 	movl   $0xc010a3d1,(%esp)
c010a522:	e8 54 fb ff ff       	call   c010a07b <kernel_thread>
c010a527:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (pid <= 0) {
c010a52a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a52e:	7f 1c                	jg     c010a54c <proc_init+0x125>
        panic("create init_main failed.\n");
c010a530:	c7 44 24 08 56 d6 10 	movl   $0xc010d656,0x8(%esp)
c010a537:	c0 
c010a538:	c7 44 24 04 88 01 00 	movl   $0x188,0x4(%esp)
c010a53f:	00 
c010a540:	c7 04 24 b5 d5 10 c0 	movl   $0xc010d5b5,(%esp)
c010a547:	e8 20 7c ff ff       	call   c010216c <__panic>
    }

    initproc = find_proc(pid);
c010a54c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a54f:	89 04 24             	mov    %eax,(%esp)
c010a552:	e8 b2 fa ff ff       	call   c010a009 <find_proc>
c010a557:	a3 44 c0 12 c0       	mov    %eax,0xc012c044
    set_proc_name(initproc, "init");
c010a55c:	a1 44 c0 12 c0       	mov    0xc012c044,%eax
c010a561:	c7 44 24 04 70 d6 10 	movl   $0xc010d670,0x4(%esp)
c010a568:	c0 
c010a569:	89 04 24             	mov    %eax,(%esp)
c010a56c:	e8 12 f8 ff ff       	call   c0109d83 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
c010a571:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c010a576:	85 c0                	test   %eax,%eax
c010a578:	74 0c                	je     c010a586 <proc_init+0x15f>
c010a57a:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c010a57f:	8b 40 04             	mov    0x4(%eax),%eax
c010a582:	85 c0                	test   %eax,%eax
c010a584:	74 24                	je     c010a5aa <proc_init+0x183>
c010a586:	c7 44 24 0c 78 d6 10 	movl   $0xc010d678,0xc(%esp)
c010a58d:	c0 
c010a58e:	c7 44 24 08 a0 d5 10 	movl   $0xc010d5a0,0x8(%esp)
c010a595:	c0 
c010a596:	c7 44 24 04 8e 01 00 	movl   $0x18e,0x4(%esp)
c010a59d:	00 
c010a59e:	c7 04 24 b5 d5 10 c0 	movl   $0xc010d5b5,(%esp)
c010a5a5:	e8 c2 7b ff ff       	call   c010216c <__panic>
    assert(initproc != NULL && initproc->pid == 1);
c010a5aa:	a1 44 c0 12 c0       	mov    0xc012c044,%eax
c010a5af:	85 c0                	test   %eax,%eax
c010a5b1:	74 0d                	je     c010a5c0 <proc_init+0x199>
c010a5b3:	a1 44 c0 12 c0       	mov    0xc012c044,%eax
c010a5b8:	8b 40 04             	mov    0x4(%eax),%eax
c010a5bb:	83 f8 01             	cmp    $0x1,%eax
c010a5be:	74 24                	je     c010a5e4 <proc_init+0x1bd>
c010a5c0:	c7 44 24 0c a0 d6 10 	movl   $0xc010d6a0,0xc(%esp)
c010a5c7:	c0 
c010a5c8:	c7 44 24 08 a0 d5 10 	movl   $0xc010d5a0,0x8(%esp)
c010a5cf:	c0 
c010a5d0:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
c010a5d7:	00 
c010a5d8:	c7 04 24 b5 d5 10 c0 	movl   $0xc010d5b5,(%esp)
c010a5df:	e8 88 7b ff ff       	call   c010216c <__panic>
}
c010a5e4:	c9                   	leave  
c010a5e5:	c3                   	ret    

c010a5e6 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
c010a5e6:	55                   	push   %ebp
c010a5e7:	89 e5                	mov    %esp,%ebp
c010a5e9:	83 ec 08             	sub    $0x8,%esp
    while (1) {
        if (current->need_resched) {
c010a5ec:	a1 48 c0 12 c0       	mov    0xc012c048,%eax
c010a5f1:	8b 40 10             	mov    0x10(%eax),%eax
c010a5f4:	85 c0                	test   %eax,%eax
c010a5f6:	74 07                	je     c010a5ff <cpu_idle+0x19>
            schedule();
c010a5f8:	e8 c1 00 00 00       	call   c010a6be <schedule>
        }
    }
c010a5fd:	eb ed                	jmp    c010a5ec <cpu_idle+0x6>
c010a5ff:	eb eb                	jmp    c010a5ec <cpu_idle+0x6>

c010a601 <switch_to>:
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
c010a601:	8b 44 24 04          	mov    0x4(%esp),%eax
    popl 0(%eax)                # save eip !popl
c010a605:	8f 00                	popl   (%eax)
    movl %esp, 4(%eax)
c010a607:	89 60 04             	mov    %esp,0x4(%eax)
    movl %ebx, 8(%eax)
c010a60a:	89 58 08             	mov    %ebx,0x8(%eax)
    movl %ecx, 12(%eax)
c010a60d:	89 48 0c             	mov    %ecx,0xc(%eax)
    movl %edx, 16(%eax)
c010a610:	89 50 10             	mov    %edx,0x10(%eax)
    movl %esi, 20(%eax)
c010a613:	89 70 14             	mov    %esi,0x14(%eax)
    movl %edi, 24(%eax)
c010a616:	89 78 18             	mov    %edi,0x18(%eax)
    movl %ebp, 28(%eax)
c010a619:	89 68 1c             	mov    %ebp,0x1c(%eax)

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
c010a61c:	8b 44 24 04          	mov    0x4(%esp),%eax
                                # eax now points to to
    movl 28(%eax), %ebp
c010a620:	8b 68 1c             	mov    0x1c(%eax),%ebp
    movl 24(%eax), %edi
c010a623:	8b 78 18             	mov    0x18(%eax),%edi
    movl 20(%eax), %esi
c010a626:	8b 70 14             	mov    0x14(%eax),%esi
    movl 16(%eax), %edx
c010a629:	8b 50 10             	mov    0x10(%eax),%edx
    movl 12(%eax), %ecx
c010a62c:	8b 48 0c             	mov    0xc(%eax),%ecx
    movl 8(%eax), %ebx
c010a62f:	8b 58 08             	mov    0x8(%eax),%ebx
    movl 4(%eax), %esp
c010a632:	8b 60 04             	mov    0x4(%eax),%esp

    pushl 0(%eax)               # push eip
c010a635:	ff 30                	pushl  (%eax)

    ret
c010a637:	c3                   	ret    

c010a638 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c010a638:	55                   	push   %ebp
c010a639:	89 e5                	mov    %esp,%ebp
c010a63b:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010a63e:	9c                   	pushf  
c010a63f:	58                   	pop    %eax
c010a640:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010a643:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010a646:	25 00 02 00 00       	and    $0x200,%eax
c010a64b:	85 c0                	test   %eax,%eax
c010a64d:	74 0c                	je     c010a65b <__intr_save+0x23>
        intr_disable();
c010a64f:	e8 81 8d ff ff       	call   c01033d5 <intr_disable>
        return 1;
c010a654:	b8 01 00 00 00       	mov    $0x1,%eax
c010a659:	eb 05                	jmp    c010a660 <__intr_save+0x28>
    }
    return 0;
c010a65b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010a660:	c9                   	leave  
c010a661:	c3                   	ret    

c010a662 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c010a662:	55                   	push   %ebp
c010a663:	89 e5                	mov    %esp,%ebp
c010a665:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010a668:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010a66c:	74 05                	je     c010a673 <__intr_restore+0x11>
        intr_enable();
c010a66e:	e8 5c 8d ff ff       	call   c01033cf <intr_enable>
    }
}
c010a673:	c9                   	leave  
c010a674:	c3                   	ret    

c010a675 <wakeup_proc>:
#include <proc.h>
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
c010a675:	55                   	push   %ebp
c010a676:	89 e5                	mov    %esp,%ebp
c010a678:	83 ec 18             	sub    $0x18,%esp
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
c010a67b:	8b 45 08             	mov    0x8(%ebp),%eax
c010a67e:	8b 00                	mov    (%eax),%eax
c010a680:	83 f8 03             	cmp    $0x3,%eax
c010a683:	74 0a                	je     c010a68f <wakeup_proc+0x1a>
c010a685:	8b 45 08             	mov    0x8(%ebp),%eax
c010a688:	8b 00                	mov    (%eax),%eax
c010a68a:	83 f8 02             	cmp    $0x2,%eax
c010a68d:	75 24                	jne    c010a6b3 <wakeup_proc+0x3e>
c010a68f:	c7 44 24 0c c8 d6 10 	movl   $0xc010d6c8,0xc(%esp)
c010a696:	c0 
c010a697:	c7 44 24 08 03 d7 10 	movl   $0xc010d703,0x8(%esp)
c010a69e:	c0 
c010a69f:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
c010a6a6:	00 
c010a6a7:	c7 04 24 18 d7 10 c0 	movl   $0xc010d718,(%esp)
c010a6ae:	e8 b9 7a ff ff       	call   c010216c <__panic>
    proc->state = PROC_RUNNABLE;
c010a6b3:	8b 45 08             	mov    0x8(%ebp),%eax
c010a6b6:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
}
c010a6bc:	c9                   	leave  
c010a6bd:	c3                   	ret    

c010a6be <schedule>:

void
schedule(void) {
c010a6be:	55                   	push   %ebp
c010a6bf:	89 e5                	mov    %esp,%ebp
c010a6c1:	83 ec 38             	sub    $0x38,%esp
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
c010a6c4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    local_intr_save(intr_flag);
c010a6cb:	e8 68 ff ff ff       	call   c010a638 <__intr_save>
c010a6d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    {
        current->need_resched = 0;
c010a6d3:	a1 48 c0 12 c0       	mov    0xc012c048,%eax
c010a6d8:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
c010a6df:	8b 15 48 c0 12 c0    	mov    0xc012c048,%edx
c010a6e5:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c010a6ea:	39 c2                	cmp    %eax,%edx
c010a6ec:	74 0a                	je     c010a6f8 <schedule+0x3a>
c010a6ee:	a1 48 c0 12 c0       	mov    0xc012c048,%eax
c010a6f3:	83 c0 58             	add    $0x58,%eax
c010a6f6:	eb 05                	jmp    c010a6fd <schedule+0x3f>
c010a6f8:	b8 70 e1 12 c0       	mov    $0xc012e170,%eax
c010a6fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
        le = last;
c010a700:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a703:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a706:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a709:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010a70c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a70f:	8b 40 04             	mov    0x4(%eax),%eax
        do {
            if ((le = list_next(le)) != &proc_list) {
c010a712:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a715:	81 7d f4 70 e1 12 c0 	cmpl   $0xc012e170,-0xc(%ebp)
c010a71c:	74 15                	je     c010a733 <schedule+0x75>
                next = le2proc(le, list_link);
c010a71e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a721:	83 e8 58             	sub    $0x58,%eax
c010a724:	89 45 f0             	mov    %eax,-0x10(%ebp)
                if (next->state == PROC_RUNNABLE) {
c010a727:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a72a:	8b 00                	mov    (%eax),%eax
c010a72c:	83 f8 02             	cmp    $0x2,%eax
c010a72f:	75 02                	jne    c010a733 <schedule+0x75>
                    break;
c010a731:	eb 08                	jmp    c010a73b <schedule+0x7d>
                }
            }
        } while (le != last);
c010a733:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a736:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c010a739:	75 cb                	jne    c010a706 <schedule+0x48>
        if (next == NULL || next->state != PROC_RUNNABLE) {
c010a73b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a73f:	74 0a                	je     c010a74b <schedule+0x8d>
c010a741:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a744:	8b 00                	mov    (%eax),%eax
c010a746:	83 f8 02             	cmp    $0x2,%eax
c010a749:	74 08                	je     c010a753 <schedule+0x95>
            next = idleproc;
c010a74b:	a1 40 c0 12 c0       	mov    0xc012c040,%eax
c010a750:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        next->runs ++;
c010a753:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a756:	8b 40 08             	mov    0x8(%eax),%eax
c010a759:	8d 50 01             	lea    0x1(%eax),%edx
c010a75c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a75f:	89 50 08             	mov    %edx,0x8(%eax)
        if (next != current) {
c010a762:	a1 48 c0 12 c0       	mov    0xc012c048,%eax
c010a767:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010a76a:	74 0b                	je     c010a777 <schedule+0xb9>
            proc_run(next);
c010a76c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a76f:	89 04 24             	mov    %eax,(%esp)
c010a772:	e8 89 f7 ff ff       	call   c0109f00 <proc_run>
        }
    }
    local_intr_restore(intr_flag);
c010a777:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010a77a:	89 04 24             	mov    %eax,(%esp)
c010a77d:	e8 e0 fe ff ff       	call   c010a662 <__intr_restore>
}
c010a782:	c9                   	leave  
c010a783:	c3                   	ret    

c010a784 <hash32>:
 * @bits:   the number of bits in a return value
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
c010a784:	55                   	push   %ebp
c010a785:	89 e5                	mov    %esp,%ebp
c010a787:	83 ec 10             	sub    $0x10,%esp
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
c010a78a:	8b 45 08             	mov    0x8(%ebp),%eax
c010a78d:	69 c0 01 00 37 9e    	imul   $0x9e370001,%eax,%eax
c010a793:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return (hash >> (32 - bits));
c010a796:	b8 20 00 00 00       	mov    $0x20,%eax
c010a79b:	2b 45 0c             	sub    0xc(%ebp),%eax
c010a79e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010a7a1:	89 c1                	mov    %eax,%ecx
c010a7a3:	d3 ea                	shr    %cl,%edx
c010a7a5:	89 d0                	mov    %edx,%eax
}
c010a7a7:	c9                   	leave  
c010a7a8:	c3                   	ret    

c010a7a9 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c010a7a9:	55                   	push   %ebp
c010a7aa:	89 e5                	mov    %esp,%ebp
c010a7ac:	83 ec 58             	sub    $0x58,%esp
c010a7af:	8b 45 10             	mov    0x10(%ebp),%eax
c010a7b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010a7b5:	8b 45 14             	mov    0x14(%ebp),%eax
c010a7b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c010a7bb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010a7be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010a7c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a7c4:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c010a7c7:	8b 45 18             	mov    0x18(%ebp),%eax
c010a7ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010a7cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a7d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a7d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a7d6:	89 55 f0             	mov    %edx,-0x10(%ebp)
c010a7d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a7dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010a7df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010a7e3:	74 1c                	je     c010a801 <printnum+0x58>
c010a7e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a7e8:	ba 00 00 00 00       	mov    $0x0,%edx
c010a7ed:	f7 75 e4             	divl   -0x1c(%ebp)
c010a7f0:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010a7f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010a7f6:	ba 00 00 00 00       	mov    $0x0,%edx
c010a7fb:	f7 75 e4             	divl   -0x1c(%ebp)
c010a7fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010a801:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a804:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010a807:	f7 75 e4             	divl   -0x1c(%ebp)
c010a80a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010a80d:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010a810:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010a813:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010a816:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010a819:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010a81c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a81f:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010a822:	8b 45 18             	mov    0x18(%ebp),%eax
c010a825:	ba 00 00 00 00       	mov    $0x0,%edx
c010a82a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010a82d:	77 56                	ja     c010a885 <printnum+0xdc>
c010a82f:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010a832:	72 05                	jb     c010a839 <printnum+0x90>
c010a834:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c010a837:	77 4c                	ja     c010a885 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c010a839:	8b 45 1c             	mov    0x1c(%ebp),%eax
c010a83c:	8d 50 ff             	lea    -0x1(%eax),%edx
c010a83f:	8b 45 20             	mov    0x20(%ebp),%eax
c010a842:	89 44 24 18          	mov    %eax,0x18(%esp)
c010a846:	89 54 24 14          	mov    %edx,0x14(%esp)
c010a84a:	8b 45 18             	mov    0x18(%ebp),%eax
c010a84d:	89 44 24 10          	mov    %eax,0x10(%esp)
c010a851:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010a854:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010a857:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a85b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010a85f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a862:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a866:	8b 45 08             	mov    0x8(%ebp),%eax
c010a869:	89 04 24             	mov    %eax,(%esp)
c010a86c:	e8 38 ff ff ff       	call   c010a7a9 <printnum>
c010a871:	eb 1c                	jmp    c010a88f <printnum+0xe6>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c010a873:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a876:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a87a:	8b 45 20             	mov    0x20(%ebp),%eax
c010a87d:	89 04 24             	mov    %eax,(%esp)
c010a880:	8b 45 08             	mov    0x8(%ebp),%eax
c010a883:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c010a885:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c010a889:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010a88d:	7f e4                	jg     c010a873 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c010a88f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010a892:	05 b0 d7 10 c0       	add    $0xc010d7b0,%eax
c010a897:	0f b6 00             	movzbl (%eax),%eax
c010a89a:	0f be c0             	movsbl %al,%eax
c010a89d:	8b 55 0c             	mov    0xc(%ebp),%edx
c010a8a0:	89 54 24 04          	mov    %edx,0x4(%esp)
c010a8a4:	89 04 24             	mov    %eax,(%esp)
c010a8a7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a8aa:	ff d0                	call   *%eax
}
c010a8ac:	c9                   	leave  
c010a8ad:	c3                   	ret    

c010a8ae <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c010a8ae:	55                   	push   %ebp
c010a8af:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010a8b1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010a8b5:	7e 14                	jle    c010a8cb <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c010a8b7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a8ba:	8b 00                	mov    (%eax),%eax
c010a8bc:	8d 48 08             	lea    0x8(%eax),%ecx
c010a8bf:	8b 55 08             	mov    0x8(%ebp),%edx
c010a8c2:	89 0a                	mov    %ecx,(%edx)
c010a8c4:	8b 50 04             	mov    0x4(%eax),%edx
c010a8c7:	8b 00                	mov    (%eax),%eax
c010a8c9:	eb 30                	jmp    c010a8fb <getuint+0x4d>
    }
    else if (lflag) {
c010a8cb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a8cf:	74 16                	je     c010a8e7 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010a8d1:	8b 45 08             	mov    0x8(%ebp),%eax
c010a8d4:	8b 00                	mov    (%eax),%eax
c010a8d6:	8d 48 04             	lea    0x4(%eax),%ecx
c010a8d9:	8b 55 08             	mov    0x8(%ebp),%edx
c010a8dc:	89 0a                	mov    %ecx,(%edx)
c010a8de:	8b 00                	mov    (%eax),%eax
c010a8e0:	ba 00 00 00 00       	mov    $0x0,%edx
c010a8e5:	eb 14                	jmp    c010a8fb <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010a8e7:	8b 45 08             	mov    0x8(%ebp),%eax
c010a8ea:	8b 00                	mov    (%eax),%eax
c010a8ec:	8d 48 04             	lea    0x4(%eax),%ecx
c010a8ef:	8b 55 08             	mov    0x8(%ebp),%edx
c010a8f2:	89 0a                	mov    %ecx,(%edx)
c010a8f4:	8b 00                	mov    (%eax),%eax
c010a8f6:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c010a8fb:	5d                   	pop    %ebp
c010a8fc:	c3                   	ret    

c010a8fd <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c010a8fd:	55                   	push   %ebp
c010a8fe:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010a900:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010a904:	7e 14                	jle    c010a91a <getint+0x1d>
        return va_arg(*ap, long long);
c010a906:	8b 45 08             	mov    0x8(%ebp),%eax
c010a909:	8b 00                	mov    (%eax),%eax
c010a90b:	8d 48 08             	lea    0x8(%eax),%ecx
c010a90e:	8b 55 08             	mov    0x8(%ebp),%edx
c010a911:	89 0a                	mov    %ecx,(%edx)
c010a913:	8b 50 04             	mov    0x4(%eax),%edx
c010a916:	8b 00                	mov    (%eax),%eax
c010a918:	eb 28                	jmp    c010a942 <getint+0x45>
    }
    else if (lflag) {
c010a91a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010a91e:	74 12                	je     c010a932 <getint+0x35>
        return va_arg(*ap, long);
c010a920:	8b 45 08             	mov    0x8(%ebp),%eax
c010a923:	8b 00                	mov    (%eax),%eax
c010a925:	8d 48 04             	lea    0x4(%eax),%ecx
c010a928:	8b 55 08             	mov    0x8(%ebp),%edx
c010a92b:	89 0a                	mov    %ecx,(%edx)
c010a92d:	8b 00                	mov    (%eax),%eax
c010a92f:	99                   	cltd   
c010a930:	eb 10                	jmp    c010a942 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010a932:	8b 45 08             	mov    0x8(%ebp),%eax
c010a935:	8b 00                	mov    (%eax),%eax
c010a937:	8d 48 04             	lea    0x4(%eax),%ecx
c010a93a:	8b 55 08             	mov    0x8(%ebp),%edx
c010a93d:	89 0a                	mov    %ecx,(%edx)
c010a93f:	8b 00                	mov    (%eax),%eax
c010a941:	99                   	cltd   
    }
}
c010a942:	5d                   	pop    %ebp
c010a943:	c3                   	ret    

c010a944 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010a944:	55                   	push   %ebp
c010a945:	89 e5                	mov    %esp,%ebp
c010a947:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c010a94a:	8d 45 14             	lea    0x14(%ebp),%eax
c010a94d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010a950:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010a953:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010a957:	8b 45 10             	mov    0x10(%ebp),%eax
c010a95a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010a95e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a961:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a965:	8b 45 08             	mov    0x8(%ebp),%eax
c010a968:	89 04 24             	mov    %eax,(%esp)
c010a96b:	e8 02 00 00 00       	call   c010a972 <vprintfmt>
    va_end(ap);
}
c010a970:	c9                   	leave  
c010a971:	c3                   	ret    

c010a972 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010a972:	55                   	push   %ebp
c010a973:	89 e5                	mov    %esp,%ebp
c010a975:	56                   	push   %esi
c010a976:	53                   	push   %ebx
c010a977:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010a97a:	eb 18                	jmp    c010a994 <vprintfmt+0x22>
            if (ch == '\0') {
c010a97c:	85 db                	test   %ebx,%ebx
c010a97e:	75 05                	jne    c010a985 <vprintfmt+0x13>
                return;
c010a980:	e9 d1 03 00 00       	jmp    c010ad56 <vprintfmt+0x3e4>
            }
            putch(ch, putdat);
c010a985:	8b 45 0c             	mov    0xc(%ebp),%eax
c010a988:	89 44 24 04          	mov    %eax,0x4(%esp)
c010a98c:	89 1c 24             	mov    %ebx,(%esp)
c010a98f:	8b 45 08             	mov    0x8(%ebp),%eax
c010a992:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010a994:	8b 45 10             	mov    0x10(%ebp),%eax
c010a997:	8d 50 01             	lea    0x1(%eax),%edx
c010a99a:	89 55 10             	mov    %edx,0x10(%ebp)
c010a99d:	0f b6 00             	movzbl (%eax),%eax
c010a9a0:	0f b6 d8             	movzbl %al,%ebx
c010a9a3:	83 fb 25             	cmp    $0x25,%ebx
c010a9a6:	75 d4                	jne    c010a97c <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c010a9a8:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c010a9ac:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010a9b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010a9b6:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c010a9b9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010a9c0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010a9c3:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c010a9c6:	8b 45 10             	mov    0x10(%ebp),%eax
c010a9c9:	8d 50 01             	lea    0x1(%eax),%edx
c010a9cc:	89 55 10             	mov    %edx,0x10(%ebp)
c010a9cf:	0f b6 00             	movzbl (%eax),%eax
c010a9d2:	0f b6 d8             	movzbl %al,%ebx
c010a9d5:	8d 43 dd             	lea    -0x23(%ebx),%eax
c010a9d8:	83 f8 55             	cmp    $0x55,%eax
c010a9db:	0f 87 44 03 00 00    	ja     c010ad25 <vprintfmt+0x3b3>
c010a9e1:	8b 04 85 d4 d7 10 c0 	mov    -0x3fef282c(,%eax,4),%eax
c010a9e8:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c010a9ea:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010a9ee:	eb d6                	jmp    c010a9c6 <vprintfmt+0x54>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010a9f0:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010a9f4:	eb d0                	jmp    c010a9c6 <vprintfmt+0x54>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010a9f6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c010a9fd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010aa00:	89 d0                	mov    %edx,%eax
c010aa02:	c1 e0 02             	shl    $0x2,%eax
c010aa05:	01 d0                	add    %edx,%eax
c010aa07:	01 c0                	add    %eax,%eax
c010aa09:	01 d8                	add    %ebx,%eax
c010aa0b:	83 e8 30             	sub    $0x30,%eax
c010aa0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010aa11:	8b 45 10             	mov    0x10(%ebp),%eax
c010aa14:	0f b6 00             	movzbl (%eax),%eax
c010aa17:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c010aa1a:	83 fb 2f             	cmp    $0x2f,%ebx
c010aa1d:	7e 0b                	jle    c010aa2a <vprintfmt+0xb8>
c010aa1f:	83 fb 39             	cmp    $0x39,%ebx
c010aa22:	7f 06                	jg     c010aa2a <vprintfmt+0xb8>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010aa24:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c010aa28:	eb d3                	jmp    c010a9fd <vprintfmt+0x8b>
            goto process_precision;
c010aa2a:	eb 33                	jmp    c010aa5f <vprintfmt+0xed>

        case '*':
            precision = va_arg(ap, int);
c010aa2c:	8b 45 14             	mov    0x14(%ebp),%eax
c010aa2f:	8d 50 04             	lea    0x4(%eax),%edx
c010aa32:	89 55 14             	mov    %edx,0x14(%ebp)
c010aa35:	8b 00                	mov    (%eax),%eax
c010aa37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c010aa3a:	eb 23                	jmp    c010aa5f <vprintfmt+0xed>

        case '.':
            if (width < 0)
c010aa3c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010aa40:	79 0c                	jns    c010aa4e <vprintfmt+0xdc>
                width = 0;
c010aa42:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010aa49:	e9 78 ff ff ff       	jmp    c010a9c6 <vprintfmt+0x54>
c010aa4e:	e9 73 ff ff ff       	jmp    c010a9c6 <vprintfmt+0x54>

        case '#':
            altflag = 1;
c010aa53:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010aa5a:	e9 67 ff ff ff       	jmp    c010a9c6 <vprintfmt+0x54>

        process_precision:
            if (width < 0)
c010aa5f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010aa63:	79 12                	jns    c010aa77 <vprintfmt+0x105>
                width = precision, precision = -1;
c010aa65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010aa68:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010aa6b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c010aa72:	e9 4f ff ff ff       	jmp    c010a9c6 <vprintfmt+0x54>
c010aa77:	e9 4a ff ff ff       	jmp    c010a9c6 <vprintfmt+0x54>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010aa7c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c010aa80:	e9 41 ff ff ff       	jmp    c010a9c6 <vprintfmt+0x54>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c010aa85:	8b 45 14             	mov    0x14(%ebp),%eax
c010aa88:	8d 50 04             	lea    0x4(%eax),%edx
c010aa8b:	89 55 14             	mov    %edx,0x14(%ebp)
c010aa8e:	8b 00                	mov    (%eax),%eax
c010aa90:	8b 55 0c             	mov    0xc(%ebp),%edx
c010aa93:	89 54 24 04          	mov    %edx,0x4(%esp)
c010aa97:	89 04 24             	mov    %eax,(%esp)
c010aa9a:	8b 45 08             	mov    0x8(%ebp),%eax
c010aa9d:	ff d0                	call   *%eax
            break;
c010aa9f:	e9 ac 02 00 00       	jmp    c010ad50 <vprintfmt+0x3de>

        // error message
        case 'e':
            err = va_arg(ap, int);
c010aaa4:	8b 45 14             	mov    0x14(%ebp),%eax
c010aaa7:	8d 50 04             	lea    0x4(%eax),%edx
c010aaaa:	89 55 14             	mov    %edx,0x14(%ebp)
c010aaad:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c010aaaf:	85 db                	test   %ebx,%ebx
c010aab1:	79 02                	jns    c010aab5 <vprintfmt+0x143>
                err = -err;
c010aab3:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c010aab5:	83 fb 06             	cmp    $0x6,%ebx
c010aab8:	7f 0b                	jg     c010aac5 <vprintfmt+0x153>
c010aaba:	8b 34 9d 94 d7 10 c0 	mov    -0x3fef286c(,%ebx,4),%esi
c010aac1:	85 f6                	test   %esi,%esi
c010aac3:	75 23                	jne    c010aae8 <vprintfmt+0x176>
                printfmt(putch, putdat, "error %d", err);
c010aac5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010aac9:	c7 44 24 08 c1 d7 10 	movl   $0xc010d7c1,0x8(%esp)
c010aad0:	c0 
c010aad1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aad4:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aad8:	8b 45 08             	mov    0x8(%ebp),%eax
c010aadb:	89 04 24             	mov    %eax,(%esp)
c010aade:	e8 61 fe ff ff       	call   c010a944 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c010aae3:	e9 68 02 00 00       	jmp    c010ad50 <vprintfmt+0x3de>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c010aae8:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010aaec:	c7 44 24 08 ca d7 10 	movl   $0xc010d7ca,0x8(%esp)
c010aaf3:	c0 
c010aaf4:	8b 45 0c             	mov    0xc(%ebp),%eax
c010aaf7:	89 44 24 04          	mov    %eax,0x4(%esp)
c010aafb:	8b 45 08             	mov    0x8(%ebp),%eax
c010aafe:	89 04 24             	mov    %eax,(%esp)
c010ab01:	e8 3e fe ff ff       	call   c010a944 <printfmt>
            }
            break;
c010ab06:	e9 45 02 00 00       	jmp    c010ad50 <vprintfmt+0x3de>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010ab0b:	8b 45 14             	mov    0x14(%ebp),%eax
c010ab0e:	8d 50 04             	lea    0x4(%eax),%edx
c010ab11:	89 55 14             	mov    %edx,0x14(%ebp)
c010ab14:	8b 30                	mov    (%eax),%esi
c010ab16:	85 f6                	test   %esi,%esi
c010ab18:	75 05                	jne    c010ab1f <vprintfmt+0x1ad>
                p = "(null)";
c010ab1a:	be cd d7 10 c0       	mov    $0xc010d7cd,%esi
            }
            if (width > 0 && padc != '-') {
c010ab1f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010ab23:	7e 3e                	jle    c010ab63 <vprintfmt+0x1f1>
c010ab25:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010ab29:	74 38                	je     c010ab63 <vprintfmt+0x1f1>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010ab2b:	8b 5d e8             	mov    -0x18(%ebp),%ebx
c010ab2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010ab31:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ab35:	89 34 24             	mov    %esi,(%esp)
c010ab38:	e8 ed 03 00 00       	call   c010af2a <strnlen>
c010ab3d:	29 c3                	sub    %eax,%ebx
c010ab3f:	89 d8                	mov    %ebx,%eax
c010ab41:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010ab44:	eb 17                	jmp    c010ab5d <vprintfmt+0x1eb>
                    putch(padc, putdat);
c010ab46:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010ab4a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010ab4d:	89 54 24 04          	mov    %edx,0x4(%esp)
c010ab51:	89 04 24             	mov    %eax,(%esp)
c010ab54:	8b 45 08             	mov    0x8(%ebp),%eax
c010ab57:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c010ab59:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010ab5d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010ab61:	7f e3                	jg     c010ab46 <vprintfmt+0x1d4>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010ab63:	eb 38                	jmp    c010ab9d <vprintfmt+0x22b>
                if (altflag && (ch < ' ' || ch > '~')) {
c010ab65:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c010ab69:	74 1f                	je     c010ab8a <vprintfmt+0x218>
c010ab6b:	83 fb 1f             	cmp    $0x1f,%ebx
c010ab6e:	7e 05                	jle    c010ab75 <vprintfmt+0x203>
c010ab70:	83 fb 7e             	cmp    $0x7e,%ebx
c010ab73:	7e 15                	jle    c010ab8a <vprintfmt+0x218>
                    putch('?', putdat);
c010ab75:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ab78:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ab7c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c010ab83:	8b 45 08             	mov    0x8(%ebp),%eax
c010ab86:	ff d0                	call   *%eax
c010ab88:	eb 0f                	jmp    c010ab99 <vprintfmt+0x227>
                }
                else {
                    putch(ch, putdat);
c010ab8a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ab8d:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ab91:	89 1c 24             	mov    %ebx,(%esp)
c010ab94:	8b 45 08             	mov    0x8(%ebp),%eax
c010ab97:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c010ab99:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010ab9d:	89 f0                	mov    %esi,%eax
c010ab9f:	8d 70 01             	lea    0x1(%eax),%esi
c010aba2:	0f b6 00             	movzbl (%eax),%eax
c010aba5:	0f be d8             	movsbl %al,%ebx
c010aba8:	85 db                	test   %ebx,%ebx
c010abaa:	74 10                	je     c010abbc <vprintfmt+0x24a>
c010abac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010abb0:	78 b3                	js     c010ab65 <vprintfmt+0x1f3>
c010abb2:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c010abb6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010abba:	79 a9                	jns    c010ab65 <vprintfmt+0x1f3>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010abbc:	eb 17                	jmp    c010abd5 <vprintfmt+0x263>
                putch(' ', putdat);
c010abbe:	8b 45 0c             	mov    0xc(%ebp),%eax
c010abc1:	89 44 24 04          	mov    %eax,0x4(%esp)
c010abc5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010abcc:	8b 45 08             	mov    0x8(%ebp),%eax
c010abcf:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010abd1:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c010abd5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010abd9:	7f e3                	jg     c010abbe <vprintfmt+0x24c>
                putch(' ', putdat);
            }
            break;
c010abdb:	e9 70 01 00 00       	jmp    c010ad50 <vprintfmt+0x3de>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010abe0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010abe3:	89 44 24 04          	mov    %eax,0x4(%esp)
c010abe7:	8d 45 14             	lea    0x14(%ebp),%eax
c010abea:	89 04 24             	mov    %eax,(%esp)
c010abed:	e8 0b fd ff ff       	call   c010a8fd <getint>
c010abf2:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010abf5:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c010abf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010abfb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010abfe:	85 d2                	test   %edx,%edx
c010ac00:	79 26                	jns    c010ac28 <vprintfmt+0x2b6>
                putch('-', putdat);
c010ac02:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ac05:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ac09:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010ac10:	8b 45 08             	mov    0x8(%ebp),%eax
c010ac13:	ff d0                	call   *%eax
                num = -(long long)num;
c010ac15:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ac18:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010ac1b:	f7 d8                	neg    %eax
c010ac1d:	83 d2 00             	adc    $0x0,%edx
c010ac20:	f7 da                	neg    %edx
c010ac22:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ac25:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c010ac28:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010ac2f:	e9 a8 00 00 00       	jmp    c010acdc <vprintfmt+0x36a>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c010ac34:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010ac37:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ac3b:	8d 45 14             	lea    0x14(%ebp),%eax
c010ac3e:	89 04 24             	mov    %eax,(%esp)
c010ac41:	e8 68 fc ff ff       	call   c010a8ae <getuint>
c010ac46:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ac49:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010ac4c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010ac53:	e9 84 00 00 00       	jmp    c010acdc <vprintfmt+0x36a>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c010ac58:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010ac5b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ac5f:	8d 45 14             	lea    0x14(%ebp),%eax
c010ac62:	89 04 24             	mov    %eax,(%esp)
c010ac65:	e8 44 fc ff ff       	call   c010a8ae <getuint>
c010ac6a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ac6d:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c010ac70:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c010ac77:	eb 63                	jmp    c010acdc <vprintfmt+0x36a>

        // pointer
        case 'p':
            putch('0', putdat);
c010ac79:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ac7c:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ac80:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c010ac87:	8b 45 08             	mov    0x8(%ebp),%eax
c010ac8a:	ff d0                	call   *%eax
            putch('x', putdat);
c010ac8c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ac8f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ac93:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010ac9a:	8b 45 08             	mov    0x8(%ebp),%eax
c010ac9d:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c010ac9f:	8b 45 14             	mov    0x14(%ebp),%eax
c010aca2:	8d 50 04             	lea    0x4(%eax),%edx
c010aca5:	89 55 14             	mov    %edx,0x14(%ebp)
c010aca8:	8b 00                	mov    (%eax),%eax
c010acaa:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010acad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c010acb4:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010acbb:	eb 1f                	jmp    c010acdc <vprintfmt+0x36a>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010acbd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010acc0:	89 44 24 04          	mov    %eax,0x4(%esp)
c010acc4:	8d 45 14             	lea    0x14(%ebp),%eax
c010acc7:	89 04 24             	mov    %eax,(%esp)
c010acca:	e8 df fb ff ff       	call   c010a8ae <getuint>
c010accf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010acd2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c010acd5:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010acdc:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010ace0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ace3:	89 54 24 18          	mov    %edx,0x18(%esp)
c010ace7:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010acea:	89 54 24 14          	mov    %edx,0x14(%esp)
c010acee:	89 44 24 10          	mov    %eax,0x10(%esp)
c010acf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010acf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010acf8:	89 44 24 08          	mov    %eax,0x8(%esp)
c010acfc:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010ad00:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ad03:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ad07:	8b 45 08             	mov    0x8(%ebp),%eax
c010ad0a:	89 04 24             	mov    %eax,(%esp)
c010ad0d:	e8 97 fa ff ff       	call   c010a7a9 <printnum>
            break;
c010ad12:	eb 3c                	jmp    c010ad50 <vprintfmt+0x3de>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c010ad14:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ad17:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ad1b:	89 1c 24             	mov    %ebx,(%esp)
c010ad1e:	8b 45 08             	mov    0x8(%ebp),%eax
c010ad21:	ff d0                	call   *%eax
            break;
c010ad23:	eb 2b                	jmp    c010ad50 <vprintfmt+0x3de>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c010ad25:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ad28:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ad2c:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c010ad33:	8b 45 08             	mov    0x8(%ebp),%eax
c010ad36:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c010ad38:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010ad3c:	eb 04                	jmp    c010ad42 <vprintfmt+0x3d0>
c010ad3e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010ad42:	8b 45 10             	mov    0x10(%ebp),%eax
c010ad45:	83 e8 01             	sub    $0x1,%eax
c010ad48:	0f b6 00             	movzbl (%eax),%eax
c010ad4b:	3c 25                	cmp    $0x25,%al
c010ad4d:	75 ef                	jne    c010ad3e <vprintfmt+0x3cc>
                /* do nothing */;
            break;
c010ad4f:	90                   	nop
        }
    }
c010ad50:	90                   	nop
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c010ad51:	e9 3e fc ff ff       	jmp    c010a994 <vprintfmt+0x22>
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c010ad56:	83 c4 40             	add    $0x40,%esp
c010ad59:	5b                   	pop    %ebx
c010ad5a:	5e                   	pop    %esi
c010ad5b:	5d                   	pop    %ebp
c010ad5c:	c3                   	ret    

c010ad5d <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010ad5d:	55                   	push   %ebp
c010ad5e:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c010ad60:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ad63:	8b 40 08             	mov    0x8(%eax),%eax
c010ad66:	8d 50 01             	lea    0x1(%eax),%edx
c010ad69:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ad6c:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c010ad6f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ad72:	8b 10                	mov    (%eax),%edx
c010ad74:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ad77:	8b 40 04             	mov    0x4(%eax),%eax
c010ad7a:	39 c2                	cmp    %eax,%edx
c010ad7c:	73 12                	jae    c010ad90 <sprintputch+0x33>
        *b->buf ++ = ch;
c010ad7e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010ad81:	8b 00                	mov    (%eax),%eax
c010ad83:	8d 48 01             	lea    0x1(%eax),%ecx
c010ad86:	8b 55 0c             	mov    0xc(%ebp),%edx
c010ad89:	89 0a                	mov    %ecx,(%edx)
c010ad8b:	8b 55 08             	mov    0x8(%ebp),%edx
c010ad8e:	88 10                	mov    %dl,(%eax)
    }
}
c010ad90:	5d                   	pop    %ebp
c010ad91:	c3                   	ret    

c010ad92 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010ad92:	55                   	push   %ebp
c010ad93:	89 e5                	mov    %esp,%ebp
c010ad95:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010ad98:	8d 45 14             	lea    0x14(%ebp),%eax
c010ad9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c010ad9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010ada1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010ada5:	8b 45 10             	mov    0x10(%ebp),%eax
c010ada8:	89 44 24 08          	mov    %eax,0x8(%esp)
c010adac:	8b 45 0c             	mov    0xc(%ebp),%eax
c010adaf:	89 44 24 04          	mov    %eax,0x4(%esp)
c010adb3:	8b 45 08             	mov    0x8(%ebp),%eax
c010adb6:	89 04 24             	mov    %eax,(%esp)
c010adb9:	e8 08 00 00 00       	call   c010adc6 <vsnprintf>
c010adbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010adc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010adc4:	c9                   	leave  
c010adc5:	c3                   	ret    

c010adc6 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010adc6:	55                   	push   %ebp
c010adc7:	89 e5                	mov    %esp,%ebp
c010adc9:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c010adcc:	8b 45 08             	mov    0x8(%ebp),%eax
c010adcf:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010add2:	8b 45 0c             	mov    0xc(%ebp),%eax
c010add5:	8d 50 ff             	lea    -0x1(%eax),%edx
c010add8:	8b 45 08             	mov    0x8(%ebp),%eax
c010addb:	01 d0                	add    %edx,%eax
c010addd:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010ade0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c010ade7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010adeb:	74 0a                	je     c010adf7 <vsnprintf+0x31>
c010aded:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010adf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010adf3:	39 c2                	cmp    %eax,%edx
c010adf5:	76 07                	jbe    c010adfe <vsnprintf+0x38>
        return -E_INVAL;
c010adf7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c010adfc:	eb 2a                	jmp    c010ae28 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c010adfe:	8b 45 14             	mov    0x14(%ebp),%eax
c010ae01:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010ae05:	8b 45 10             	mov    0x10(%ebp),%eax
c010ae08:	89 44 24 08          	mov    %eax,0x8(%esp)
c010ae0c:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010ae0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c010ae13:	c7 04 24 5d ad 10 c0 	movl   $0xc010ad5d,(%esp)
c010ae1a:	e8 53 fb ff ff       	call   c010a972 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010ae1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010ae22:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c010ae25:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010ae28:	c9                   	leave  
c010ae29:	c3                   	ret    

c010ae2a <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c010ae2a:	55                   	push   %ebp
c010ae2b:	89 e5                	mov    %esp,%ebp
c010ae2d:	57                   	push   %edi
c010ae2e:	56                   	push   %esi
c010ae2f:	53                   	push   %ebx
c010ae30:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c010ae33:	a1 88 8a 12 c0       	mov    0xc0128a88,%eax
c010ae38:	8b 15 8c 8a 12 c0    	mov    0xc0128a8c,%edx
c010ae3e:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010ae44:	6b f0 05             	imul   $0x5,%eax,%esi
c010ae47:	01 f7                	add    %esi,%edi
c010ae49:	be 6d e6 ec de       	mov    $0xdeece66d,%esi
c010ae4e:	f7 e6                	mul    %esi
c010ae50:	8d 34 17             	lea    (%edi,%edx,1),%esi
c010ae53:	89 f2                	mov    %esi,%edx
c010ae55:	83 c0 0b             	add    $0xb,%eax
c010ae58:	83 d2 00             	adc    $0x0,%edx
c010ae5b:	89 c7                	mov    %eax,%edi
c010ae5d:	83 e7 ff             	and    $0xffffffff,%edi
c010ae60:	89 f9                	mov    %edi,%ecx
c010ae62:	0f b7 da             	movzwl %dx,%ebx
c010ae65:	89 0d 88 8a 12 c0    	mov    %ecx,0xc0128a88
c010ae6b:	89 1d 8c 8a 12 c0    	mov    %ebx,0xc0128a8c
    unsigned long long result = (next >> 12);
c010ae71:	a1 88 8a 12 c0       	mov    0xc0128a88,%eax
c010ae76:	8b 15 8c 8a 12 c0    	mov    0xc0128a8c,%edx
c010ae7c:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010ae80:	c1 ea 0c             	shr    $0xc,%edx
c010ae83:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010ae86:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c010ae89:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c010ae90:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010ae93:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010ae96:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010ae99:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010ae9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010ae9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010aea2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010aea6:	74 1c                	je     c010aec4 <rand+0x9a>
c010aea8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010aeab:	ba 00 00 00 00       	mov    $0x0,%edx
c010aeb0:	f7 75 dc             	divl   -0x24(%ebp)
c010aeb3:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010aeb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010aeb9:	ba 00 00 00 00       	mov    $0x0,%edx
c010aebe:	f7 75 dc             	divl   -0x24(%ebp)
c010aec1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010aec4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010aec7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010aeca:	f7 75 dc             	divl   -0x24(%ebp)
c010aecd:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010aed0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010aed3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010aed6:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010aed9:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010aedc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010aedf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c010aee2:	83 c4 24             	add    $0x24,%esp
c010aee5:	5b                   	pop    %ebx
c010aee6:	5e                   	pop    %esi
c010aee7:	5f                   	pop    %edi
c010aee8:	5d                   	pop    %ebp
c010aee9:	c3                   	ret    

c010aeea <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c010aeea:	55                   	push   %ebp
c010aeeb:	89 e5                	mov    %esp,%ebp
    next = seed;
c010aeed:	8b 45 08             	mov    0x8(%ebp),%eax
c010aef0:	ba 00 00 00 00       	mov    $0x0,%edx
c010aef5:	a3 88 8a 12 c0       	mov    %eax,0xc0128a88
c010aefa:	89 15 8c 8a 12 c0    	mov    %edx,0xc0128a8c
}
c010af00:	5d                   	pop    %ebp
c010af01:	c3                   	ret    

c010af02 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010af02:	55                   	push   %ebp
c010af03:	89 e5                	mov    %esp,%ebp
c010af05:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010af08:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010af0f:	eb 04                	jmp    c010af15 <strlen+0x13>
        cnt ++;
c010af11:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c010af15:	8b 45 08             	mov    0x8(%ebp),%eax
c010af18:	8d 50 01             	lea    0x1(%eax),%edx
c010af1b:	89 55 08             	mov    %edx,0x8(%ebp)
c010af1e:	0f b6 00             	movzbl (%eax),%eax
c010af21:	84 c0                	test   %al,%al
c010af23:	75 ec                	jne    c010af11 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c010af25:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010af28:	c9                   	leave  
c010af29:	c3                   	ret    

c010af2a <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c010af2a:	55                   	push   %ebp
c010af2b:	89 e5                	mov    %esp,%ebp
c010af2d:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010af30:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010af37:	eb 04                	jmp    c010af3d <strnlen+0x13>
        cnt ++;
c010af39:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c010af3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010af40:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010af43:	73 10                	jae    c010af55 <strnlen+0x2b>
c010af45:	8b 45 08             	mov    0x8(%ebp),%eax
c010af48:	8d 50 01             	lea    0x1(%eax),%edx
c010af4b:	89 55 08             	mov    %edx,0x8(%ebp)
c010af4e:	0f b6 00             	movzbl (%eax),%eax
c010af51:	84 c0                	test   %al,%al
c010af53:	75 e4                	jne    c010af39 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c010af55:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010af58:	c9                   	leave  
c010af59:	c3                   	ret    

c010af5a <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c010af5a:	55                   	push   %ebp
c010af5b:	89 e5                	mov    %esp,%ebp
c010af5d:	57                   	push   %edi
c010af5e:	56                   	push   %esi
c010af5f:	83 ec 20             	sub    $0x20,%esp
c010af62:	8b 45 08             	mov    0x8(%ebp),%eax
c010af65:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010af68:	8b 45 0c             	mov    0xc(%ebp),%eax
c010af6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c010af6e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010af71:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010af74:	89 d1                	mov    %edx,%ecx
c010af76:	89 c2                	mov    %eax,%edx
c010af78:	89 ce                	mov    %ecx,%esi
c010af7a:	89 d7                	mov    %edx,%edi
c010af7c:	ac                   	lods   %ds:(%esi),%al
c010af7d:	aa                   	stos   %al,%es:(%edi)
c010af7e:	84 c0                	test   %al,%al
c010af80:	75 fa                	jne    c010af7c <strcpy+0x22>
c010af82:	89 fa                	mov    %edi,%edx
c010af84:	89 f1                	mov    %esi,%ecx
c010af86:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010af89:	89 55 e8             	mov    %edx,-0x18(%ebp)
c010af8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c010af8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c010af92:	83 c4 20             	add    $0x20,%esp
c010af95:	5e                   	pop    %esi
c010af96:	5f                   	pop    %edi
c010af97:	5d                   	pop    %ebp
c010af98:	c3                   	ret    

c010af99 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010af99:	55                   	push   %ebp
c010af9a:	89 e5                	mov    %esp,%ebp
c010af9c:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c010af9f:	8b 45 08             	mov    0x8(%ebp),%eax
c010afa2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010afa5:	eb 21                	jmp    c010afc8 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c010afa7:	8b 45 0c             	mov    0xc(%ebp),%eax
c010afaa:	0f b6 10             	movzbl (%eax),%edx
c010afad:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010afb0:	88 10                	mov    %dl,(%eax)
c010afb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010afb5:	0f b6 00             	movzbl (%eax),%eax
c010afb8:	84 c0                	test   %al,%al
c010afba:	74 04                	je     c010afc0 <strncpy+0x27>
            src ++;
c010afbc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c010afc0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010afc4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c010afc8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010afcc:	75 d9                	jne    c010afa7 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c010afce:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010afd1:	c9                   	leave  
c010afd2:	c3                   	ret    

c010afd3 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010afd3:	55                   	push   %ebp
c010afd4:	89 e5                	mov    %esp,%ebp
c010afd6:	57                   	push   %edi
c010afd7:	56                   	push   %esi
c010afd8:	83 ec 20             	sub    $0x20,%esp
c010afdb:	8b 45 08             	mov    0x8(%ebp),%eax
c010afde:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010afe1:	8b 45 0c             	mov    0xc(%ebp),%eax
c010afe4:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c010afe7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010afea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010afed:	89 d1                	mov    %edx,%ecx
c010afef:	89 c2                	mov    %eax,%edx
c010aff1:	89 ce                	mov    %ecx,%esi
c010aff3:	89 d7                	mov    %edx,%edi
c010aff5:	ac                   	lods   %ds:(%esi),%al
c010aff6:	ae                   	scas   %es:(%edi),%al
c010aff7:	75 08                	jne    c010b001 <strcmp+0x2e>
c010aff9:	84 c0                	test   %al,%al
c010affb:	75 f8                	jne    c010aff5 <strcmp+0x22>
c010affd:	31 c0                	xor    %eax,%eax
c010afff:	eb 04                	jmp    c010b005 <strcmp+0x32>
c010b001:	19 c0                	sbb    %eax,%eax
c010b003:	0c 01                	or     $0x1,%al
c010b005:	89 fa                	mov    %edi,%edx
c010b007:	89 f1                	mov    %esi,%ecx
c010b009:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b00c:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010b00f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c010b012:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010b015:	83 c4 20             	add    $0x20,%esp
c010b018:	5e                   	pop    %esi
c010b019:	5f                   	pop    %edi
c010b01a:	5d                   	pop    %ebp
c010b01b:	c3                   	ret    

c010b01c <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010b01c:	55                   	push   %ebp
c010b01d:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b01f:	eb 0c                	jmp    c010b02d <strncmp+0x11>
        n --, s1 ++, s2 ++;
c010b021:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010b025:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b029:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010b02d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b031:	74 1a                	je     c010b04d <strncmp+0x31>
c010b033:	8b 45 08             	mov    0x8(%ebp),%eax
c010b036:	0f b6 00             	movzbl (%eax),%eax
c010b039:	84 c0                	test   %al,%al
c010b03b:	74 10                	je     c010b04d <strncmp+0x31>
c010b03d:	8b 45 08             	mov    0x8(%ebp),%eax
c010b040:	0f b6 10             	movzbl (%eax),%edx
c010b043:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b046:	0f b6 00             	movzbl (%eax),%eax
c010b049:	38 c2                	cmp    %al,%dl
c010b04b:	74 d4                	je     c010b021 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010b04d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b051:	74 18                	je     c010b06b <strncmp+0x4f>
c010b053:	8b 45 08             	mov    0x8(%ebp),%eax
c010b056:	0f b6 00             	movzbl (%eax),%eax
c010b059:	0f b6 d0             	movzbl %al,%edx
c010b05c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b05f:	0f b6 00             	movzbl (%eax),%eax
c010b062:	0f b6 c0             	movzbl %al,%eax
c010b065:	29 c2                	sub    %eax,%edx
c010b067:	89 d0                	mov    %edx,%eax
c010b069:	eb 05                	jmp    c010b070 <strncmp+0x54>
c010b06b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b070:	5d                   	pop    %ebp
c010b071:	c3                   	ret    

c010b072 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010b072:	55                   	push   %ebp
c010b073:	89 e5                	mov    %esp,%ebp
c010b075:	83 ec 04             	sub    $0x4,%esp
c010b078:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b07b:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b07e:	eb 14                	jmp    c010b094 <strchr+0x22>
        if (*s == c) {
c010b080:	8b 45 08             	mov    0x8(%ebp),%eax
c010b083:	0f b6 00             	movzbl (%eax),%eax
c010b086:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010b089:	75 05                	jne    c010b090 <strchr+0x1e>
            return (char *)s;
c010b08b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b08e:	eb 13                	jmp    c010b0a3 <strchr+0x31>
        }
        s ++;
c010b090:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c010b094:	8b 45 08             	mov    0x8(%ebp),%eax
c010b097:	0f b6 00             	movzbl (%eax),%eax
c010b09a:	84 c0                	test   %al,%al
c010b09c:	75 e2                	jne    c010b080 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c010b09e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b0a3:	c9                   	leave  
c010b0a4:	c3                   	ret    

c010b0a5 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c010b0a5:	55                   	push   %ebp
c010b0a6:	89 e5                	mov    %esp,%ebp
c010b0a8:	83 ec 04             	sub    $0x4,%esp
c010b0ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b0ae:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010b0b1:	eb 11                	jmp    c010b0c4 <strfind+0x1f>
        if (*s == c) {
c010b0b3:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0b6:	0f b6 00             	movzbl (%eax),%eax
c010b0b9:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010b0bc:	75 02                	jne    c010b0c0 <strfind+0x1b>
            break;
c010b0be:	eb 0e                	jmp    c010b0ce <strfind+0x29>
        }
        s ++;
c010b0c0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c010b0c4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0c7:	0f b6 00             	movzbl (%eax),%eax
c010b0ca:	84 c0                	test   %al,%al
c010b0cc:	75 e5                	jne    c010b0b3 <strfind+0xe>
        if (*s == c) {
            break;
        }
        s ++;
    }
    return (char *)s;
c010b0ce:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010b0d1:	c9                   	leave  
c010b0d2:	c3                   	ret    

c010b0d3 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c010b0d3:	55                   	push   %ebp
c010b0d4:	89 e5                	mov    %esp,%ebp
c010b0d6:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010b0d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c010b0e0:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010b0e7:	eb 04                	jmp    c010b0ed <strtol+0x1a>
        s ++;
c010b0e9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010b0ed:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0f0:	0f b6 00             	movzbl (%eax),%eax
c010b0f3:	3c 20                	cmp    $0x20,%al
c010b0f5:	74 f2                	je     c010b0e9 <strtol+0x16>
c010b0f7:	8b 45 08             	mov    0x8(%ebp),%eax
c010b0fa:	0f b6 00             	movzbl (%eax),%eax
c010b0fd:	3c 09                	cmp    $0x9,%al
c010b0ff:	74 e8                	je     c010b0e9 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c010b101:	8b 45 08             	mov    0x8(%ebp),%eax
c010b104:	0f b6 00             	movzbl (%eax),%eax
c010b107:	3c 2b                	cmp    $0x2b,%al
c010b109:	75 06                	jne    c010b111 <strtol+0x3e>
        s ++;
c010b10b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b10f:	eb 15                	jmp    c010b126 <strtol+0x53>
    }
    else if (*s == '-') {
c010b111:	8b 45 08             	mov    0x8(%ebp),%eax
c010b114:	0f b6 00             	movzbl (%eax),%eax
c010b117:	3c 2d                	cmp    $0x2d,%al
c010b119:	75 0b                	jne    c010b126 <strtol+0x53>
        s ++, neg = 1;
c010b11b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b11f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c010b126:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b12a:	74 06                	je     c010b132 <strtol+0x5f>
c010b12c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c010b130:	75 24                	jne    c010b156 <strtol+0x83>
c010b132:	8b 45 08             	mov    0x8(%ebp),%eax
c010b135:	0f b6 00             	movzbl (%eax),%eax
c010b138:	3c 30                	cmp    $0x30,%al
c010b13a:	75 1a                	jne    c010b156 <strtol+0x83>
c010b13c:	8b 45 08             	mov    0x8(%ebp),%eax
c010b13f:	83 c0 01             	add    $0x1,%eax
c010b142:	0f b6 00             	movzbl (%eax),%eax
c010b145:	3c 78                	cmp    $0x78,%al
c010b147:	75 0d                	jne    c010b156 <strtol+0x83>
        s += 2, base = 16;
c010b149:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010b14d:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c010b154:	eb 2a                	jmp    c010b180 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c010b156:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b15a:	75 17                	jne    c010b173 <strtol+0xa0>
c010b15c:	8b 45 08             	mov    0x8(%ebp),%eax
c010b15f:	0f b6 00             	movzbl (%eax),%eax
c010b162:	3c 30                	cmp    $0x30,%al
c010b164:	75 0d                	jne    c010b173 <strtol+0xa0>
        s ++, base = 8;
c010b166:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b16a:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010b171:	eb 0d                	jmp    c010b180 <strtol+0xad>
    }
    else if (base == 0) {
c010b173:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010b177:	75 07                	jne    c010b180 <strtol+0xad>
        base = 10;
c010b179:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010b180:	8b 45 08             	mov    0x8(%ebp),%eax
c010b183:	0f b6 00             	movzbl (%eax),%eax
c010b186:	3c 2f                	cmp    $0x2f,%al
c010b188:	7e 1b                	jle    c010b1a5 <strtol+0xd2>
c010b18a:	8b 45 08             	mov    0x8(%ebp),%eax
c010b18d:	0f b6 00             	movzbl (%eax),%eax
c010b190:	3c 39                	cmp    $0x39,%al
c010b192:	7f 11                	jg     c010b1a5 <strtol+0xd2>
            dig = *s - '0';
c010b194:	8b 45 08             	mov    0x8(%ebp),%eax
c010b197:	0f b6 00             	movzbl (%eax),%eax
c010b19a:	0f be c0             	movsbl %al,%eax
c010b19d:	83 e8 30             	sub    $0x30,%eax
c010b1a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b1a3:	eb 48                	jmp    c010b1ed <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c010b1a5:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1a8:	0f b6 00             	movzbl (%eax),%eax
c010b1ab:	3c 60                	cmp    $0x60,%al
c010b1ad:	7e 1b                	jle    c010b1ca <strtol+0xf7>
c010b1af:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1b2:	0f b6 00             	movzbl (%eax),%eax
c010b1b5:	3c 7a                	cmp    $0x7a,%al
c010b1b7:	7f 11                	jg     c010b1ca <strtol+0xf7>
            dig = *s - 'a' + 10;
c010b1b9:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1bc:	0f b6 00             	movzbl (%eax),%eax
c010b1bf:	0f be c0             	movsbl %al,%eax
c010b1c2:	83 e8 57             	sub    $0x57,%eax
c010b1c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b1c8:	eb 23                	jmp    c010b1ed <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010b1ca:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1cd:	0f b6 00             	movzbl (%eax),%eax
c010b1d0:	3c 40                	cmp    $0x40,%al
c010b1d2:	7e 3d                	jle    c010b211 <strtol+0x13e>
c010b1d4:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1d7:	0f b6 00             	movzbl (%eax),%eax
c010b1da:	3c 5a                	cmp    $0x5a,%al
c010b1dc:	7f 33                	jg     c010b211 <strtol+0x13e>
            dig = *s - 'A' + 10;
c010b1de:	8b 45 08             	mov    0x8(%ebp),%eax
c010b1e1:	0f b6 00             	movzbl (%eax),%eax
c010b1e4:	0f be c0             	movsbl %al,%eax
c010b1e7:	83 e8 37             	sub    $0x37,%eax
c010b1ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010b1ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b1f0:	3b 45 10             	cmp    0x10(%ebp),%eax
c010b1f3:	7c 02                	jl     c010b1f7 <strtol+0x124>
            break;
c010b1f5:	eb 1a                	jmp    c010b211 <strtol+0x13e>
        }
        s ++, val = (val * base) + dig;
c010b1f7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010b1fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b1fe:	0f af 45 10          	imul   0x10(%ebp),%eax
c010b202:	89 c2                	mov    %eax,%edx
c010b204:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010b207:	01 d0                	add    %edx,%eax
c010b209:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010b20c:	e9 6f ff ff ff       	jmp    c010b180 <strtol+0xad>

    if (endptr) {
c010b211:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010b215:	74 08                	je     c010b21f <strtol+0x14c>
        *endptr = (char *) s;
c010b217:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b21a:	8b 55 08             	mov    0x8(%ebp),%edx
c010b21d:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010b21f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010b223:	74 07                	je     c010b22c <strtol+0x159>
c010b225:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b228:	f7 d8                	neg    %eax
c010b22a:	eb 03                	jmp    c010b22f <strtol+0x15c>
c010b22c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010b22f:	c9                   	leave  
c010b230:	c3                   	ret    

c010b231 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010b231:	55                   	push   %ebp
c010b232:	89 e5                	mov    %esp,%ebp
c010b234:	57                   	push   %edi
c010b235:	83 ec 24             	sub    $0x24,%esp
c010b238:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b23b:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010b23e:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010b242:	8b 55 08             	mov    0x8(%ebp),%edx
c010b245:	89 55 f8             	mov    %edx,-0x8(%ebp)
c010b248:	88 45 f7             	mov    %al,-0x9(%ebp)
c010b24b:	8b 45 10             	mov    0x10(%ebp),%eax
c010b24e:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010b251:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010b254:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010b258:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010b25b:	89 d7                	mov    %edx,%edi
c010b25d:	f3 aa                	rep stos %al,%es:(%edi)
c010b25f:	89 fa                	mov    %edi,%edx
c010b261:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010b264:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c010b267:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c010b26a:	83 c4 24             	add    $0x24,%esp
c010b26d:	5f                   	pop    %edi
c010b26e:	5d                   	pop    %ebp
c010b26f:	c3                   	ret    

c010b270 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010b270:	55                   	push   %ebp
c010b271:	89 e5                	mov    %esp,%ebp
c010b273:	57                   	push   %edi
c010b274:	56                   	push   %esi
c010b275:	53                   	push   %ebx
c010b276:	83 ec 30             	sub    $0x30,%esp
c010b279:	8b 45 08             	mov    0x8(%ebp),%eax
c010b27c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b27f:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b282:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010b285:	8b 45 10             	mov    0x10(%ebp),%eax
c010b288:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c010b28b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b28e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010b291:	73 42                	jae    c010b2d5 <memmove+0x65>
c010b293:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b296:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010b299:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b29c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010b29f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b2a2:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010b2a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010b2a8:	c1 e8 02             	shr    $0x2,%eax
c010b2ab:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010b2ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010b2b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010b2b3:	89 d7                	mov    %edx,%edi
c010b2b5:	89 c6                	mov    %eax,%esi
c010b2b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010b2b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010b2bc:	83 e1 03             	and    $0x3,%ecx
c010b2bf:	74 02                	je     c010b2c3 <memmove+0x53>
c010b2c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b2c3:	89 f0                	mov    %esi,%eax
c010b2c5:	89 fa                	mov    %edi,%edx
c010b2c7:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010b2ca:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010b2cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010b2d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010b2d3:	eb 36                	jmp    c010b30b <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010b2d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b2d8:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b2db:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b2de:	01 c2                	add    %eax,%edx
c010b2e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b2e3:	8d 48 ff             	lea    -0x1(%eax),%ecx
c010b2e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b2e9:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c010b2ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010b2ef:	89 c1                	mov    %eax,%ecx
c010b2f1:	89 d8                	mov    %ebx,%eax
c010b2f3:	89 d6                	mov    %edx,%esi
c010b2f5:	89 c7                	mov    %eax,%edi
c010b2f7:	fd                   	std    
c010b2f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b2fa:	fc                   	cld    
c010b2fb:	89 f8                	mov    %edi,%eax
c010b2fd:	89 f2                	mov    %esi,%edx
c010b2ff:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010b302:	89 55 c8             	mov    %edx,-0x38(%ebp)
c010b305:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c010b308:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010b30b:	83 c4 30             	add    $0x30,%esp
c010b30e:	5b                   	pop    %ebx
c010b30f:	5e                   	pop    %esi
c010b310:	5f                   	pop    %edi
c010b311:	5d                   	pop    %ebp
c010b312:	c3                   	ret    

c010b313 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010b313:	55                   	push   %ebp
c010b314:	89 e5                	mov    %esp,%ebp
c010b316:	57                   	push   %edi
c010b317:	56                   	push   %esi
c010b318:	83 ec 20             	sub    $0x20,%esp
c010b31b:	8b 45 08             	mov    0x8(%ebp),%eax
c010b31e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010b321:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b324:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010b327:	8b 45 10             	mov    0x10(%ebp),%eax
c010b32a:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010b32d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010b330:	c1 e8 02             	shr    $0x2,%eax
c010b333:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c010b335:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010b338:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010b33b:	89 d7                	mov    %edx,%edi
c010b33d:	89 c6                	mov    %eax,%esi
c010b33f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010b341:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c010b344:	83 e1 03             	and    $0x3,%ecx
c010b347:	74 02                	je     c010b34b <memcpy+0x38>
c010b349:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010b34b:	89 f0                	mov    %esi,%eax
c010b34d:	89 fa                	mov    %edi,%edx
c010b34f:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010b352:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010b355:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010b358:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010b35b:	83 c4 20             	add    $0x20,%esp
c010b35e:	5e                   	pop    %esi
c010b35f:	5f                   	pop    %edi
c010b360:	5d                   	pop    %ebp
c010b361:	c3                   	ret    

c010b362 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010b362:	55                   	push   %ebp
c010b363:	89 e5                	mov    %esp,%ebp
c010b365:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c010b368:	8b 45 08             	mov    0x8(%ebp),%eax
c010b36b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010b36e:	8b 45 0c             	mov    0xc(%ebp),%eax
c010b371:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c010b374:	eb 30                	jmp    c010b3a6 <memcmp+0x44>
        if (*s1 != *s2) {
c010b376:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b379:	0f b6 10             	movzbl (%eax),%edx
c010b37c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b37f:	0f b6 00             	movzbl (%eax),%eax
c010b382:	38 c2                	cmp    %al,%dl
c010b384:	74 18                	je     c010b39e <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c010b386:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010b389:	0f b6 00             	movzbl (%eax),%eax
c010b38c:	0f b6 d0             	movzbl %al,%edx
c010b38f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010b392:	0f b6 00             	movzbl (%eax),%eax
c010b395:	0f b6 c0             	movzbl %al,%eax
c010b398:	29 c2                	sub    %eax,%edx
c010b39a:	89 d0                	mov    %edx,%eax
c010b39c:	eb 1a                	jmp    c010b3b8 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c010b39e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010b3a2:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c010b3a6:	8b 45 10             	mov    0x10(%ebp),%eax
c010b3a9:	8d 50 ff             	lea    -0x1(%eax),%edx
c010b3ac:	89 55 10             	mov    %edx,0x10(%ebp)
c010b3af:	85 c0                	test   %eax,%eax
c010b3b1:	75 c3                	jne    c010b376 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c010b3b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010b3b8:	c9                   	leave  
c010b3b9:	c3                   	ret    
