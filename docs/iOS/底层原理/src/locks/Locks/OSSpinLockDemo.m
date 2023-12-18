//
//  OSSpinLockDemo.m
//  TestRunLoop
//
//  Created by Murph on 2022/3/9.
//

#import "OSSpinLockDemo.h"
#import <libkern/OSAtomic.h>
@interface OSSpinLockDemo()
@end

@implementation OSSpinLockDemo {
    OSSpinLock _moneyLock;
    OSSpinLock _ticketLock;
}
- (instancetype)init{
    if(self = [super init]) {
        _moneyLock = OS_SPINLOCK_INIT;
        _ticketLock = OS_SPINLOCK_INIT;
    }
    return self;
}

-(void) __saleTicket {
    OSSpinLockLock(&_ticketLock);
    int ticket = self.ticketCount;
    sleep(1);
    ticket -= 1;
    self.ticketCount = ticket;
    NSLog(@"ticket remain: %d", self.ticketCount);
    OSSpinLockUnlock(&_ticketLock);
}


-(void) __saveMoney:(int) money {
    OSSpinLockLock(&_moneyLock);
    int innermoney = self.money;
    sleep(1);
    innermoney += money;
    self.money = innermoney;
    NSLog(@"save money remain: %d", self.money);
    OSSpinLockUnlock(&_moneyLock);

}

-(void) __getMoney:(int) money {
    OSSpinLockLock(&_moneyLock);
    int innermoney = self.money;
    sleep(1);
    innermoney -= money;
    NSLog(@"get money remain: %d", self.money);
    OSSpinLockUnlock(&_moneyLock);
}

@end
