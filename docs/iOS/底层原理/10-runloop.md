## Runloop

运行循环，在程序运行过程中循环做一些事情

应用范畴： 定时器（Timer），PerformSelector，GCD Async Main Queue，事件响应，手势识别，界面刷新，网络请求，AutoreleasePool

没有 RunLoop 程序执行完就会退出

iOS 中有两套 API 来访问和使用 RunLoop

Foundation: NSRunloop

Core Foundation: CFRunLoopRef

这两个都代表着RunLoop对象

NSRunloop 是基于 CFRunLoopRef 的一层 OC 包装

[CoreFundation 源码地址](https://opensource.apple.com/tarballs/CF/)

runloop 伪代码
```C++
int main(int argc, char * argv[]){
    @autoreleasepool {
        int retVal = 0
        do{
            int message = sleep_and_wait();
            retVal = process_message(message);
        } while (0==retVal);
        return 0;
    }
}
```

- RunLoop 的基本作用
- - 保持程序的持续运行
- - 处理 APP 中的各种事件，比如触摸，定时器等
- - 节省 CPU 资源，提高程序性能：有事做事，没事睡觉


### RunLoop 与线程

- 每条线程都有唯一一个与之对应的 RunLoop 对象
- RunLoop 保存在一个全局的 Dictionary 里，线程作为 Key，RunLoop 作为 Value
- 创建线程时，没有 RunLoop，RunLoop会在第一次获取它时创建
- RunLoop 会在线程结束时销毁
- 主线程的RunLoop已将自动获取（创建），子线程默认没有开启 RunLoop

RunLoop 相关的类，
Core Foundation 中关于 RunLoop 的 5 个类
- CFRunLoopRef
- CFRunLoopModeRef
- CFRunLoopSourceRef
- CFRunLoopTimerRef
- CFRunLoopObserverRef

```C
struct __CFRunLoop {
    pthread_t _pthread;
    CFMutableSetRef _commonModes;
    CFMutableSetRef _commonModeItems;
    CFRunLoopModeRef _currentMode;
    CFMutableSetRef _modes;
};

struct __CFRunLoopMode {
    CFStringRef _name;
    CFMutableSetRef _sources0;
    CFMutableSetRef _sources1;
    CFMutableArrayRef _observers;
    CFMutableArrayRef _timers;
};
```

- CFRunLoopModeRef 代表 RunLoop 的运行模式
- 一个RunLoop 包含若干个Mode，每个Mode又包含若干个 Source0/Sources1/Observer/Timer
- RunLoop 启动时只能选择其中一个 Mode，作为 CurrentMode
- 如果需要切换 Mode，只能退出当前 Loop，再重新选择一个 Mode 进入
- - 不同组的 Source0/Sources1/Observer/Timer 能够分隔开来，互不影响
- - 如果 mode 中没有任何 Source0/Sources1/Observer/Timer，RunLoop会立马退出

常见的两种 mode

- kCFRunLoopDefaultMode(NSDefaultRunLoopMode)，App默认Mode，通常主线程是在这个Mode 下运行
- UITrackingRunLoopMode：界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响

### 事件处理

llvdb `bt`命令，打印函数调用栈

Source0（应用层事件）
- 触摸事件处理
- performSelector:onThread:

Source1（处理系统，内核事件）
- 基于Port的线程间通信
- 系统事件捕捉

Timers
- NSTimer
- performSelector:withObject:afterDelay:

Observers
- 用于监听 RunLoop 的状态
- UI 刷新 （BeforeWaiting）
- @autoreleasepool（BeforeWaiting）

```C
/* Run Loop Observer Activities */
typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    kCFRunLoopEntry = (1UL << 0),           // 即将进入 Loop
    kCFRunLoopBeforeTimers = (1UL << 1),    // 即将处理 Timer
    kCFRunLoopBeforeSources = (1UL << 2),   // 即将处理 Source
    kCFRunLoopBeforeWaiting = (1UL << 5),   // 即将进入休眠
    kCFRunLoopAfterWaiting = (1UL << 6),    // 刚从休眠中唤醒
    kCFRunLoopExit = (1UL << 7),            // 即将退出 Loop
    kCFRunLoopAllActivities = 0x0FFFFFFFU
};

struct __CFRunLoopObserver {
    CFRuntimeBase _base;
    pthread_mutex_t _lock;
    CFRunLoopRef _runLoop;
    CFIndex _rlCount;
    CFOptionFlags _activities;		/* immutable */
    CFIndex _order;			/* immutable */
    CFRunLoopObserverCallBack _callout;	/* immutable */
    CFRunLoopObserverContext _context;	/* immutable, except invalidation */
};
```

添加 Obverser 监听 RunLoop 的所有状态

```C++
void observerRunLoopAct(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    switch (activity) {
        case kCFRunLoopEntry:
            NSLog(@"进入RunLoop");
            NSLog(@"%@ %lu", observer, activity);
            break;
        case kCFRunLoopBeforeSources:
            NSLog(@"即将处理 Source");
            NSLog(@"%@ %lu", observer, activity);
            break;
        case kCFRunLoopBeforeTimers:
            NSLog(@"即将处理 Timer");
            NSLog(@"%@ %lu", observer, activity);
            break;
        case kCFRunLoopBeforeWaiting:
            NSLog(@"即将进入休眠");
            NSLog(@"%@ %lu", observer, activity);
            break;
        case kCFRunLoopAfterWaiting:
            NSLog(@"即将唤醒");
            NSLog(@"%@ %lu", observer, activity);
            break;
        case kCFRunLoopExit:
            NSLog(@"即将退出 runloop");
            NSLog(@"%@ %lu", observer, activity);
        default:
            break;
    }
    
}

CFRunLoopObserverRef ref = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, observerRunLoopAct, NULL);
CFRunLoopAddObserver(CFRunLoopGetMain(), ref, kCFRunLoopCommonModes);
    CFRelease(ref);

```

### RunLoop 的运行逻辑

```C
sInt32 CFRunLoopRunSpecific(CFRunLoopRef rl, CFStringRef modeName, CFTimeInterval seconds, Boolean returnAfterSourceHandled) {     /* DOES CALLOUT */
    // 检查当前RunLoop mode 是否为 进入 RunLoop，如果是，就通知 observer 进入 RunLoop 
    if (currentMode->_observerMask & kCFRunLoopEntry ) __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopEntry);
    // 开始执行 RunLoop
	result = __CFRunLoopRun(rl, currentMode, seconds, returnAfterSourceHandled, previousMode);
    // 执行完之后判断是否要退出 RunLoop，如果要退出，那么通知 observer 要退出 RunLoop  
	if (currentMode->_observerMask & kCFRunLoopExit ) __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopExit);
}

/* rl, rlm are locked on entrance and exit */
static int32_t __CFRunLoopRun(CFRunLoopRef rl, CFRunLoopModeRef rlm, CFTimeInterval seconds, Boolean stopAfterHandle, CFRunLoopModeRef previousMode) {
    do {
        // 判断并通知 observer 即将处理 timers
        __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeTimers);
        // 判断并通知 observer 即将处理 sources
        __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeSources);
        // 处理 blocks
	    __CFRunLoopDoBlocks(rl, rlm);
        // 处理 sources0，并根据结果判断是否要再处理 blocks
        if (__CFRunLoopDoSources0(rl, rlm, stopAfterHandle)) {
            __CFRunLoopDoBlocks(rl, rlm);
	    }

        Boolean poll = sourceHandledThisLoop || (0ULL == timeout_context->termTSR);

        // 第一次不会执行因为第一次 didDispatchPortLastTime 为true，dispatchPort 在主线程才会赋值，只有主线程下才会走到里面
        // 查到的livePort 在handle_msg 中会根据条件做对应处理
        if (MACH_PORT_NULL != dispatchPort && !didDispatchPortLastTime) {
            msg = (mach_msg_header_t *)msg_buffer;
            if (__CFRunLoopServiceMachPort(dispatchPort, &msg, sizeof(msg_buffer), &livePort, 0, &voucherState, NULL)) {
                // 有就跳转到 handle_msg
                goto handle_msg;
            }
        }

        didDispatchPortLastTime = false;
        // 判断并通知 observer 即将 休眠
        __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeWaiting);
        __CFRunLoopSetSleeping(rl);
        // do not do any user callouts after this point (after notifying of sleeping)


        CFAbsoluteTime sleepStart = poll ? 0.0 : CFAbsoluteTimeGetCurrent();
        do {           
            // 等待别的消息来唤醒当前线程，不会执行任何指令，调用了 mach_msg 内核态控制线程休眠，不做任何事情，当内核收到消息之后再来唤醒线程继续处理
            __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort, poll ? 0 : TIMEOUT_INFINITY, &voucherState, &voucherCopy);
            
        } while (1);
        
	    __CFRunLoopUnsetSleeping(rl);
        // 判断并通知 observer 结束休眠
	    if (!poll && (rlm->_observerMask & kCFRunLoopAfterWaiting)) __CFRunLoopDoObservers(rl, rlm, kCFRunLoopAfterWaiting);

handle_msg:;
        if (weak_up_for_timer) {
            CFRUNLOOP_WAKEUP_FOR_TIMER();
            // 处理timer
            if (!__CFRunLoopDoTimers(rl, rlm, mach_absolute_time())) {
                // Re-arm the next timer
                __CFArmNextTimerInMode(rlm, rl);
            }
        } else if (weak_up_for_GCD) {
            CFRUNLOOP_WAKEUP_FOR_DISPATCH();
            // 处理 GCD
            __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg);
        } else { // 被 source1 唤醒
            CFRUNLOOP_WAKEUP_FOR_SOURCE();
           
            if (__CFRunLoopModeFindSourceForMachPort(rl, rlm, livePort)) {
                // 处理 source1
		        sourceHandledThisLoop = __CFRunLoopDoSource1(rl, rlm, rls, msg, msg->msgh_size, &reply) || sourceHandledThisLoop;
	        }
        } 
        if (msg && msg != (mach_msg_header_t *)msg_buffer) free(msg);
        
        // 处理 bolcks
	    __CFRunLoopDoBlocks(rl, rlm);
        
        // 拿到 RunLoop 本轮执行结果，如果等于 0，那么进行下一轮循环，如果不等于 0，跳出循环，返回
	    if (sourceHandledThisLoop && stopAfterHandle) {
	        retVal = kCFRunLoopRunHandledSource;
        } else if (timeout_context->termTSR < mach_absolute_time()) {
            retVal = kCFRunLoopRunTimedOut;
	    } else if (__CFRunLoopIsStopped(rl)) {
            __CFRunLoopUnsetStopped(rl);
	        retVal = kCFRunLoopRunStopped;
	    } else if (rlm->_stopped) {
	        rlm->_stopped = false;
	        retVal = kCFRunLoopRunStopped;
	    } else if (__CFRunLoopModeIsEmpty(rl, rlm, previousMode)) {
	        retVal = kCFRunLoopRunFinished;
	    }
    } while (0 == retVal);

    if (timeout_timer) {
        dispatch_source_cancel(timeout_timer);
        dispatch_release(timeout_timer);
    } else {
        free(timeout_context);
    }

    return retVal;
}
```

GCD 从子线程做完操作回到主线程会依赖 RunLoop，但是其他情况不一定会依赖 RunLoop

### 实际应用

- 控制线程生命周期（线程保活，AFNetworking）
- 解决 NSTimer 在滑动时停止工作的问题
- 监控应用卡顿
- 性能优化


#### NSTimer 失效

```Objective-C
NSTimer * timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
    NSLog(@"");
}];
// NSDefaultRunLoopMode,UITrackingRunLoopMode 是真实存在的mode
// NSRunLoopCommonModes 并不是一个真正的模式，只是一个标记
// 标记 timer 能在 _commonModes 数组中存放的模式下工作
[NSRunLoop.currentRunLoop addTimer:timer forMode:NSRunLoopCommonModes];

// 这种写法只会将 timer 添加到 NSDefaultRunLoopMode 下，如果页面有滑动等操作，就会暂停
[NSTimer scheduledTimerWithTimeInterval:3 repeats:NO block:^(NSTimer * _Nonnull timer) {
            NSLog(@"aaa");
        }];
```

#### 线程保活


```Objective-C

#import "ViewController.h"
#import "TestThread.h"

@interface ViewController ()
@property(strong, nonatomic) TestThread * thread;
@property(assign, nonatomic) BOOL stopped;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    self.thread = [[TestThread alloc] initWithBlock:^{
        NSLog(@"%s -----start -----", __func__);
        // 往 RunLoop 里面添加Source/Timer/Port
        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
//        [[NSRunLoop currentRunLoop] run]; // run 方法是无法停止的，它内部会循环调用[currentRunLoop runMode:beforeDate:]专门用于开启一个永不销毁的线程
        while (weakSelf && !weakSelf.stopped) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        NSLog(@"%s -----end -----", __func__);
    }];
//    self.thread = [[TestThread alloc] initWithTarget:self selector:@selector(run) object:nil]; // 这种方式会对 self 有一个强引用，会导致循环引用
    [self.thread start];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"touch");
    if(!self.thread) return;

    [self performSelector:@selector(testRunOnThread) onThread:self.thread withObject:nil waitUntilDone:NO];
}

-(void) testRunOnThread{
    NSLog(@"%s %@", __func__, [NSThread currentThread]);
}

-(void)stopRunloop {
    self.stopped = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
    NSLog(@"%s, %@", __func__, [NSThread currentThread]);
    self.thread = nil;
}

-(void) stop {
    if(!self.thread) return;
    // waitUntilDone 一定要设置为 YES，要等到子线程代码执行完再返回并继续往下执行
    // 如果为 NO，那在 dealloc 中调用的时候在实际执行的时候 viewController 就已经死掉了，后续调用也就会有问题
    [self performSelector:@selector(stopRunloop) onThread:self.thread withObject:nil waitUntilDone:YES];
}

- (void)dealloc {
    [self stop];
}
```

#### 线程封装 


#### GCD 与 RunLoop

GCD 只负责开启线程，不负责保活，RunLoop用来对线程保活