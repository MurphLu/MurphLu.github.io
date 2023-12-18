//
//  NSRecursiveLockDemo.m
//  TestRunLoop
//
//  Created by Murph on 2022/3/9.
//

#import "NSRecursiveLockDemo.h"
#import <pthread.h>

@implementation NSRecursiveLockDemo{
    NSLock *nslock;
    NSRecursiveLock *lock;
    pthread_mutex_t mutex;
}

- (instancetype)init{
    if(self = [super init]){
        nslock = [[NSLock alloc] init];
        lock = [[NSRecursiveLock alloc] init];
        [self generateMutex:&mutex];
    }
    return self;
}

-(void)generateMutex:(pthread_mutex_t *)mutex{
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(mutex, &attr);
    pthread_mutexattr_destroy(&attr);
}

-(void)testRecursiveLock{
    [lock lock];
    NSLog(@"recursiveLock lock");
    static int count = 0;
    if(count<10){
        count++;
        [self testRecursiveLock];
    }
    [lock unlock];
    NSLog(@"recursiveLock unlock");
}

-(void)testRecursiceMutex {
    pthread_mutex_lock(&mutex);
    NSLog(@"mutex recursiveLock lock");
    static int count2 = 0;
    if(count2<10){
        count2++;
        [self testRecursiceMutex];
    }
    pthread_mutex_unlock(&mutex);
    NSLog(@"mutex recursiveLock unlock");
}

// 死锁，普通 lock 不支持递归调用，只有递归锁可以
-(void) testNormalLock{
    [nslock lock];
    NSLog(@"nslock lock");
    static int count = 0;
    if(count<10){
        count++;
        [self testNormalLock];
    }
    [nslock unlock];
    NSLog(@"nslock unlock");
}

- (void)dealloc
{
    pthread_mutex_destroy(&mutex);
}
@end
