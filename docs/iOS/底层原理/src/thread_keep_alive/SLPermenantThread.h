//
//  SLPermenantThread.h
//  TestRunLoop
//
//  Created by Murph on 2022/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^SLPermenantThreadTask)(void);

@interface SLPermenantThread : NSObject

/// 开启一个线程
-(void)run;

/// 执行任务
/// @param target 执行任务的对象
/// @param action 执行任务的方法
/// @param object 参数
-(void)executeTaskWithTarget:(id)target action:(SEL)action object:(id)object;

/// 通过 block 执行任务
-(void)executeBlock:(SLPermenantThreadTask) task;

/// 结束一个线程
-(void)stop;
@end

NS_ASSUME_NONNULL_END
