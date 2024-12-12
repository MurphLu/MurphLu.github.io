//
//  ProxyObj.m
//  MemoryManagement
//
//  Created by Murph on 2022/3/10.
//

#import "ProxyObj.h"

@implementation ProxyObj
+(instancetype)proxyWithObj:(id)obj{
    ProxyObj *proxy = [[ProxyObj alloc] init];
    proxy.target = obj;
    return proxy;
}
-(id)forwardingTargetForSelector:(SEL)aSelector{
    return self.target;
}
@end
