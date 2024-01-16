//
//  SemaphoreDemo.m
//  TestRunLoop
//
//  Created by Murph on 2022/3/9.
//

#import "SemaphoreDemo.h"

@implementation SemaphoreDemo{
    dispatch_semaphore_t semaphore;
    dispatch_semaphore_t moneySemaphore;
    dispatch_semaphore_t tickeySemaphore;
}

- (instancetype)init{
    if(self=[super init]){
        semaphore = dispatch_semaphore_create(5);
        moneySemaphore = dispatch_semaphore_create(1);
        tickeySemaphore = dispatch_semaphore_create(1);
    }
    return self;
}
-(void)test{
    for (int i = 0; i<40; i++) {
        [[[NSThread alloc] initWithTarget:self selector:@selector(otherTest) object:nil] start];
    }
}

-(void)otherTest{
    // 如果信号量的值 > 0，那么信号量值减1，继续执行下面代码
    // 如果信号量的值 <=0，那么休眠等待， DISPATCH_TIME_FOREVER 来控制等待时间，一直到信号量的值变成 >0，继续执行下面代码
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    sleep(2);
    NSLog(@"test - %@", [NSThread currentThread]);
    
    // 信号量值 +1
    dispatch_semaphore_signal(semaphore);
}


-(void) __saleTicket {
    dispatch_semaphore_wait(tickeySemaphore, DISPATCH_TIME_FOREVER);
    [super __saleTicket];
    dispatch_semaphore_signal(tickeySemaphore);
}


-(void) __saveMoney:(int) money {
    dispatch_semaphore_wait(moneySemaphore, DISPATCH_TIME_FOREVER);
    [super __saveMoney:money];
    dispatch_semaphore_signal(moneySemaphore);
}

-(void) __getMoney:(int) money {
    dispatch_semaphore_wait(moneySemaphore, DISPATCH_TIME_FOREVER);
    [super __getMoney: money];
    dispatch_semaphore_signal(moneySemaphore);
}
@end
