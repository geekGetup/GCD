//
//  ViewController.m
//  GCD01
//
//  Created by 乐家 on 2018/1/17.
//  Copyright © 2018年 lejiakeji. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) dispatch_source_t gcdTimer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configDispatch_apply];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
//    [self GCDTimer];
}

- (void)setupGCD {
    /*
     GCD 中两个核心概念:
     1.任务
     放入GCD中的操作,一般以Block的方式进行,执行任务的操作有两种
     a.同步执行:不会开启新的线程,在当前线程中执行,表现为同步函数sync
     b.异步执行:拥有开启新线程执行任务的能力,变现为异步函数async
     2.队列
     任务队列,用来存放任务的队列.采用先进先出的原则,队列也分为两种
     a.串行队列:队列中的任务一个接一个的执行,不会开启新的线程
     b.并发队列:在异步函数中会开启多条线程,同时执行任务
     */
    // 创建串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create("mySerialQueue", DISPATCH_QUEUE_SERIAL);
    // 主队列,也为一个串行队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    // 创建并发队列,获取全局并发队列
    dispatch_queue_t concurrentQueue = dispatch_queue_create("myConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    
    // 创建同步执行的任务
    // 同步函数+串行队列
    dispatch_sync(serialQueue, ^{
        // 不会开启新的线程
        NSLog(@"%@",[NSThread currentThread]);
    });
    // 同步函数+主队列
    dispatch_sync(mainQueue, ^{
        // 不会开启新的线程
        NSLog(@"%@",[NSThread currentThread]);
    });
    // 同步函数+并发队列
    dispatch_sync(concurrentQueue, ^{
        // 不会开启新的线程
        NSLog(@"%@",[NSThread currentThread]);
    });
    
    // 创建异步执行的任务
    // 异步函数+并发队列
    dispatch_async(concurrentQueue, ^{
        // 开启新的线程
        NSLog(@"%@",[NSThread currentThread]);
    });
    // 异步函数+串行队列
    dispatch_async(serialQueue, ^{
        // 开启一条后台线程,串行执行任务
        NSLog(@"%@",[NSThread currentThread]);
    });
    // 异步函数+主队列
    dispatch_async(mainQueue, ^{
        // 不开起新的线程
        NSLog(@"%@",[NSThread currentThread]);
    });

}
#pragma mark - 串行队列+同步函数
- (void)configSyncSerialQueue {
    NSLog(@"开始执行");
    NSArray *titleArray = @[@"第一个任务",@"第二个任务",@"第三个任务"];
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue""", DISPATCH_QUEUE_SERIAL);
    for (NSString *str in titleArray) {
        dispatch_sync(serialQueue, ^{
            NSLog(@"串行队列+同步函数:%@--%@",str,[NSThread currentThread]);
        });
    }
    
    for (NSString *str in titleArray) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"主队列+同步函数:%@--%@",str,[NSThread currentThread]);
        });
    }
}

#pragma mark - 串行队列+异步函数
- (void)configAsyncSerialQueue {
    NSLog(@"开始执行");
    NSArray *titleArray = @[@"第一个任务",@"第二个任务",@"第三个任务"];
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue""", DISPATCH_QUEUE_SERIAL);
    for (NSString *str in titleArray) {
        dispatch_async(serialQueue, ^{
            NSLog(@"串行队列+异步函数:%@--%@",str,[NSThread currentThread]);
        });
    }
    
    for (NSString *str in titleArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"主队列+异步函数:%@--%@",str,[NSThread currentThread]);
        });
    }
}

#pragma mark - 并发队列+同步函数
- (void)configSyncConcurrentQueue {
    NSLog(@"开始执行");
    NSArray *titleArray = @[@"第一个任务",@"第二个任务",@"第三个任务"];
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue""", DISPATCH_QUEUE_CONCURRENT);
    for (NSString *str in titleArray) {
        dispatch_sync(concurrentQueue, ^{
            NSLog(@"并发队列+同步函数:%@--%@",str,[NSThread currentThread]);
        });
    }
    
    for (NSString *str in titleArray) {
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"全局并发队列+同步函数:%@--%@",str,[NSThread currentThread]);
        });
    }
}

#pragma mark - 并发队列+异步函数
- (void)configAsyncConcurrentQueue {
    NSLog(@"开始执行");
    NSArray *titleArray = @[@"第一个任务",@"第二个任务",@"第三个任务"];
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue""", DISPATCH_QUEUE_CONCURRENT);
    for (NSString *str in titleArray) {
        dispatch_async(concurrentQueue, ^{
            NSLog(@"并发队列+异步函数:%@--%@",str,[NSThread currentThread]);
        });
    }
    
    for (NSString *str in titleArray) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"全局并发队列+异步函数:%@--%@",str,[NSThread currentThread]);
        });
    }
}

#pragma mark - 死锁案例
- (void)deadLock {
    NSLog(@"任务1");
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"任务2");
    });
    NSLog(@"任务3");
}

#pragma mark - 线程间通信
- (void)GCDCommunication {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 全局并发队列中异步请求数据
        NSArray *dataArray = @[@"我是第1条数据",@"我是第2条数据",@"我是第3条数据"];
        for (NSString *dataStr in dataArray) {
            NSLog(@"%@---我当前的线程是:%@",dataStr,[NSThread currentThread]);
        }
        // 请求数据完成,回到主线程刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"我当前的线程是:%@",[NSThread currentThread]);
        });
    });
}

int count = 0;
- (void)GCDTimer {
    self.gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC); // 从现在开始两秒后执行
    dispatch_source_set_timer(self.gcdTimer, startTime, (int64_t)(2.0 * NSEC_PER_SEC), 0); // 每两秒执行一次
    // 定时器回调
    dispatch_source_set_event_handler(self.gcdTimer, ^{
        NSLog(@"CGD定时器-----%@",[NSThread currentThread]);
        count++;
        if (count == 5) { // 执行5次,让定时器取消
            dispatch_cancel(self.gcdTimer);
            self.gcdTimer = nil;
        }
        
    });
    // 启动定时器: GCD定时器默认是暂停的
    dispatch_resume(self.gcdTimer);
}
#pragma mark - configDispatch_group
- (void)configDispatch_group {
    dispatch_group_t gcdGroup = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_async(gcdGroup, queue, ^{
        NSLog(@"执行第一个任务");
    });
    dispatch_group_async(gcdGroup, queue, ^{
        NSLog(@"执行第二个任务");
    });
    dispatch_group_async(gcdGroup, queue, ^{
        NSLog(@"执行第三个任务");
    });
    dispatch_group_notify(gcdGroup, dispatch_get_main_queue(), ^{
        NSLog(@"回到了主线程");
    });
}

#pragma mark - dispatch_barrier
- (void)configDispatch_barrier {
//    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"执行第一个任务--%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"执行第二个任务--%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"执行第三个任务--%@",[NSThread currentThread]);
    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"我是栅栏,前边的任务都执行完了,在执行下边的任务--%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"执行第四个任务--%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"执行第五个任务--%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"执行第六个任务--%@",[NSThread currentThread]);
    });
}

#pragma mark - 信号量
- (void)configDispatch_semaphore {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    // 创建信号量
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    NSArray *titleArray = @[@(1),@(1),@(1),@(0),@(1)];
    for (int i = 0; i<titleArray.count; i++) {
        int number = [titleArray[i] intValue];
        dispatch_async(queue, ^{
            //信号量为0是则阻塞当前线程,不为0则减1继续执行当前线程
            dispatch_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (number) {
                NSLog(@"%d--当前线程:%@",i,[NSThread currentThread]);
                dispatch_semaphore_signal(semaphore);
            } else {
                NSLog(@"%d--当前线程:%@",i,[NSThread currentThread]);
                dispatch_semaphore_signal(semaphore);
            }
        });
    }
}

#pragma mark - GCD延时函数
- (void)configDispatch_after {
    NSLog(@"开始执行");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"两秒后我执行了");
    });
}

#pragma mark - GCD一次性代码
- (void)configDispatch_once {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 这里写只需要执行一次的代码,默认线程安全
    });
}

- (void)configDispatch_apply {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
//    dispatch_queue_t queue = dispatch_get_main_queue();
//    dispatch_queue_t queue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_apply(15, queue, ^(size_t index) {
        NSLog(@"执行第%ld个任务,当前线程为%@",index,[NSThread currentThread]);
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
