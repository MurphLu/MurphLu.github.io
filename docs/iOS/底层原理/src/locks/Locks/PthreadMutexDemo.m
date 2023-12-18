//
//  PthreadMutexDemo.m
//  TestRunLoop
//
//  Created by Murph on 2022/3/9.
//

#import "PthreadMutexDemo.h"
#import <pthread.h>

@implementation PthreadMutexDemo{
    pthread_mutex_t moneyMutex;
    pthread_mutex_t ticketMutex;
}

- (instancetype)init{
    if(self = [super init]) {
        [self generateMutex:&moneyMutex];
        [self generateMutex:&ticketMutex];
    }
    return self;
}

-(void)generateMutex:(pthread_mutex_t *)mutex{
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_DEFAULT);
    pthread_mutex_init(mutex, &attr);
    pthread_mutexattr_destroy(&attr);
}

-(void) __saleTicket {
    pthread_mutex_lock(&ticketMutex);
    [super __saleTicket];
    pthread_mutex_unlock(&ticketMutex);
}


-(void) __saveMoney:(int) money {
    pthread_mutex_lock(&moneyMutex);
    [super __saveMoney:money];
    pthread_mutex_unlock(&moneyMutex);
}

-(void) __getMoney:(int) money {
    pthread_mutex_lock(&moneyMutex);
    [super __getMoney: money];
    pthread_mutex_unlock(&moneyMutex);
}
-(void)dealloc{
    pthread_mutex_destroy(&moneyMutex);
    pthread_mutex_destroy(&ticketMutex);
}
@end
