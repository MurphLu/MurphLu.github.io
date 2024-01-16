//
//  DispatchBarrierDemo.m
//  TestRunLoop
//
//  Created by Murph on 2022/3/10.
//

#import "DispatchBarrierDemo.h"

@implementation DispatchBarrierDemo{
    dispatch_queue_t queue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 如果使用 barrier,那么必须是自己创建的 并发队列
        queue = dispatch_queue_create("iw_queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

-(void)testRW{
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
    sleep(1);
    [[[NSThread alloc] initWithTarget:self selector:@selector(write) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(write) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(write) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(write) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
}

-(void)read{
    dispatch_async(queue, ^{
        NSLog(@"read");
        sleep(random() % 10);
    //    NSLog(@"%ld", random());
        NSLog(@"read end");
    });
    
}

-(void)write{
    dispatch_barrier_async(queue, ^{
        NSLog(@"write");
        sleep(random() % 10);
        NSLog(@"write end");
    });
}
@end
