//
//  ProxyWithNSProxy.m
//  MemoryManagement
//
//  Created by Murph on 2022/3/10.
//

#import "ProxyWithNSProxy.h"

@implementation ProxyWithNSProxy
+(instancetype)proxyWithTarget:(id) target{
    ProxyWithNSProxy *proxy = [ProxyWithNSProxy alloc];
    proxy.target = target;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}

-(void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
}
@end
