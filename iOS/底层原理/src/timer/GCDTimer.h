//
//  GCDTimer.h
//  MemoryManagement
//
//  Created by Murph on 2022/3/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^GCDTimerTask)(void);

@interface GCDTimer : NSObject
+ (NSString *) execTask: (GCDTimerTask) task
           after:(NSTimeInterval)after
        interval:(NSTimeInterval) interval
         repeats:(BOOL)repeats
           async:(BOOL)async;

+ (void)stopTask:(NSString *)identify;
@end

NS_ASSUME_NONNULL_END
