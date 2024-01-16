//
//  GCDTimer.m
//  MemoryManagement
//
//  Created by Murph on 2022/3/10.
//

#import "GCDTimer.h"

@interface GCDTimer()
@end
@implementation GCDTimer

static NSMutableDictionary *timers;
static int i = 0;
static dispatch_semaphore_t semphore;

+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timers = [NSMutableDictionary dictionary];
        semphore = dispatch_semaphore_create(1);
    });
}
+ (NSString *)execTask:(GCDTimerTask)task after:(NSTimeInterval)after interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async {
    
    if(!task || after < 0 || interval <= 0) return nil;
    i += 1;
    NSString *identify = [NSString stringWithFormat:@"gcdtimer-%d", i];
    // 创建队列
    dispatch_queue_t queue = async ? dispatch_get_global_queue(0, 0) : dispatch_get_main_queue();
    
    // 创建定时器
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_semaphore_wait(semphore, DISPATCH_TIME_FOREVER);
    timers[identify] = timer;
    dispatch_semaphore_signal(semphore);
    // 设置时间
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    
    // 设置回调
    dispatch_source_set_event_handler(timer , ^{
        task();
        if(!repeats) {
            [self stopTask:identify];
        }
    });
    // 启动定时器
    dispatch_resume(timer);
    return identify;
}

+ (void)stopTask:(NSString *)identify{
    if(!identify) return;
    dispatch_semaphore_wait(semphore, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = timers[identify];
    if(timer){
        dispatch_source_cancel(timer);
        [timers removeObjectForKey:identify];
    }
    dispatch_semaphore_signal(semphore);
}
@end
