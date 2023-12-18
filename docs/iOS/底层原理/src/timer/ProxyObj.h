//
//  ProxyObj.h
//  MemoryManagement
//
//  Created by Murph on 2022/3/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProxyObj : NSObject
@property(weak, nonatomic) id target;

+(instancetype)proxyWithObj:(id)obj;
@end

NS_ASSUME_NONNULL_END
