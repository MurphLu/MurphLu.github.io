//
//  SLPermenantThread.m
//  TestRunLoop
//
//  Created by Murph on 2022/3/7.
//

#import "SLPermenantThread.h"
@interface SLPermenantThread()
@property(strong, nonatomic) NSThread * thread;
@property(assign, nonatomic) BOOL stopped;
@end

@implementation SLPermenantThread

- (instancetype)init{
    if(self = [super init]){
        __weak typeof(self) weakSelf = self;
        
        self.thread = [[NSThread alloc] initWithBlock:^{
            // 线程保活
            [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
            while (weakSelf && !weakSelf.stopped) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:NSDate.distantFuture];
            }
            
            // 使用 C 语言 API
//            CFRunLoopSourceContext context = {0};
//            CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
//            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
//            // 最后一个参数可以设置在本次Runloop 执行完之后是否退出，如果设置为false,本次执行完会继续等待执行下一次，而不用像OC那样，要加一层循环来保证不会退出
//            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, false);
        }];
        [self.thread start];
    }
    return self;
}


- (void)dealloc{
    [self stop];
}

#pragma mark - public methods

- (void)run{
    if(!self.thread) return;
    [self.thread start];
}

- (void)executeTaskWithTarget:(id)target action:(SEL)action object:(id)object{
    if(!self.thread) return;
}

- (void)executeBlock:(SLPermenantThreadTask) task{
    if(!self.thread || !task) return;
    [self performSelector:@selector(__executeTask:) onThread:self.thread withObject:task waitUntilDone:NO];
}

- (void)stop{
    if(!self.thread) return;
    [self performSelector:@selector(__stopThread) onThread:self.thread withObject:nil waitUntilDone:YES];
}

#pragma mark - private methods

- (void)__stopThread{
    self.stopped = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.thread = nil;
}

- (void)__executeTask:(SLPermenantThreadTask) task{
    task();
}
@end
