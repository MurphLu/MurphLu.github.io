//
//  CADisplayLinkDemo.m
//  MemoryManagement
//
//  Created by Murph on 2022/3/10.
//

#import "CADisplayLinkDemo.h"
#import "ProxyObj.h"

@interface CADisplayLinkDemo()
@property(strong, nonatomic) CADisplayLink *link;
@property(strong, nonatomic) NSTimer *timer;
@end

@implementation CADisplayLinkDemo
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    // 直接使用 target 会产生循环引用，如果不手动停掉那么无法调用 dealloc，也就无法在 dealloc 中停掉，如果用 Proxy 类的话
    // Proxy 对于 self  是弱引用，计时器对 proxy 产生强引用，这是不会有循环引用，可以将停止计时器的方法写在 dealloc 中
    self.link = [CADisplayLink displayLinkWithTarget:[ProxyObj proxyWithObj:self] selector:@selector(testDisplayLink)];
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:[ProxyObj proxyWithObj:self] selector:@selector(testTimer) userInfo:nil repeats:YES];
}

-(void) testDisplayLink{
    NSLog(@"test display link");
}

-(void) testTimer{
    NSLog(@"test timer");
}

- (void)viewDidDisappear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    [self.link invalidate];
//    [self.timer invalidate];
}
- (void)dealloc {
    [self.link invalidate];
    [self.timer invalidate];
    NSLog(@"viewcontroller delloc");
}
@end
