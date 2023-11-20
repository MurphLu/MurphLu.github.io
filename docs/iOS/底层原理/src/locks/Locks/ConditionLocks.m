//
//  ConditionLocks.m
//  TestRunLoop
//
//  Created by Murph on 2022/3/9.
//

#import "ConditionLocks.h"
#import <pthread.h>

@implementation ConditionLocks{
    pthread_mutex_t mutex;
    pthread_cond_t cont;
    NSCondition *condition;
    NSConditionLock *conditionLock;
}

- (instancetype)init{
    if(self = [super init]){
        [self generateMutex: &mutex];
        pthread_cond_init(&cont, NULL);
        condition = [[NSCondition alloc] init];
        conditionLock = [[NSConditionLock alloc] initWithCondition:0];
    }
    return self;
}

-(void)generateMutex:(pthread_mutex_t *)mutex{
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
    pthread_mutex_init(mutex, &attr);
    pthread_mutexattr_destroy(&attr);
}

-(void) textCondition {
    [[[NSThread alloc] initWithTarget:self selector:@selector(mutexConditionSleep) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(mutexConditionWakeup) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(nsContSleep) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(nsContWakeup) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(conditionLock) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(conditionLock1) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(conditionLock2) object:nil] start];
}

-(void) mutexConditionSleep {
    pthread_mutex_lock(&mutex);
    NSLog(@"mutex before sleep");
    if(true){
        pthread_cond_wait(&cont, &mutex);
    }
    NSLog(@"mutex after sleep");
    pthread_mutex_unlock(&mutex);
}

-(void) mutexConditionWakeup {
    pthread_mutex_lock(&mutex);
    sleep(1);
    NSLog(@"mutex before wakeup");
    pthread_cond_signal(&cont);
    NSLog(@"mutex after wakeup");
    pthread_mutex_unlock(&mutex);
}

-(void)nsContSleep{
    [condition lock];
    NSLog(@"nscont before sleep");
    [condition wait];
    NSLog(@"nscont after sleep");
    [condition unlock];
}

-(void)nsContWakeup {
    [condition lock];
    sleep(1);
    NSLog(@"nscont before wakeup");
    [condition signal];
    NSLog(@"nscont after wakeup");
    [condition unlock];
}

-(void)conditionLock {
    sleep(3);
    [conditionLock lock];
    
    NSLog(@"conditionLock init");
    NSLog(@"conditionLock unlock with condition 1");
    [conditionLock unlockWithCondition:1];
}

-(void)conditionLock1 {
    [conditionLock lockWhenCondition:1];
    sleep(1);
    NSLog(@"conditionLock 1");
    NSLog(@"conditionLock unlock with condition 2");
    [conditionLock unlockWithCondition:2];
}

-(void)conditionLock2 {
    [conditionLock lockWhenCondition:2];
    sleep(1);
    NSLog(@"conditionLock 2");
    NSLog(@"conditionLock unlock with condition 3");
    [conditionLock unlockWithCondition:3];
}

- (void)dealloc
{
    pthread_cond_destroy(&cont);
    pthread_mutex_destroy(&mutex);
}

@end
