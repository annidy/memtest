//
//  ViewController.m
//  memtest
//
//  Created by annidy on 2021/10/27.
//

#import "ViewController.h"

static char bss[100];
const  char data[100];

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *stack = nil;
    void *heap = malloc(1024);
    
    // 栈的起始地址 0x000000016fb61b78，堆的其实地址 0x0000000105818c00，堆在栈的下面
    NSLog(@"0x%016lx => stack 0x%016lx => heap", (long)&stack, (long)heap);

    // 从低到高依次为 代码段、常量段、静态段
    IMP methodIMP = [self methodForSelector:@selector(viewDidLoad)];
    NSLog(@"0x%016lx => bss 0x%016lx => data 0x%016lx => code", (long)&bss, (long)&data, (long)methodIMP);

    
    // 比较小的对象从0x280ded280（栈的上方）开始，大对象在栈下面
    NSObject *oc_object = [[NSObject alloc] init];
    NSObject *oc_big_object = [[NSArray alloc] init];
    NSLog(@"oc_object => 0x%lx oc_big_object_address => 0x%lx", (long)oc_object, (long)oc_big_object);
    
    // 小对象的最大是是256字节，超过后分配到下方
    for (int i = 0; i < 100; i++) {
        void *c_object = malloc(4*i);
        NSLog(@"c_object_address %d => 0x%lx", 4*i, (long)c_object);
        free(c_object);
    }
    
    // 栈向下增长，堆向上增长.
    // 栈增长到 0x000000016ae263b8 （1M），会报栈溢出
//     [self allocDirTest];
    
    // 堆增长到是 0x000000016d94c000 (1.5G) 附近时, 会跳过栈的区域，从0x000000016df28000分配
    // 到了 0x000000017fe28000，又会跳过 *系统共享代码段* (image list)，继续从0x00000002a0000000开始分配 🤔
    // 分配到0x00000003d7f00000 （7G）就失败了（跟机器有关）
//    [self heapRangeTest];
}

- (void)allocDirTest {
    // 测试栈和堆的增长方向
    NSString *stack = nil;
    void *heap = malloc(1024);
    
    NSLog(@"0x%016lx => stack 0x%016lx => heap", (long)&stack, (long)heap);
    [self allocDirTest];
}

- (void)heapRangeTest {
    // 测试栈堆的分配区间
    int i = 0;
    while (true) {
        i++;
        int size = 1024*1024;
        void *heap = malloc(size);
        NSLog(@"%d size[%d] addr 0x%016lx", i, size*i, (long)heap);
    }
}


@end
