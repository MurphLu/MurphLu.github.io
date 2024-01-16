//
//  ProxyWithNSProxy.h
//  MemoryManagement
//
//  Created by Murph on 2022/3/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProxyWithNSProxy : NSProxy
@property(weak, nonatomic) id target;

+(instancetype)proxyWithTarget:(id) target;
@end

NS_ASSUME_NONNULL_END
