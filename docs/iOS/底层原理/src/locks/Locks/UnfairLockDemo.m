//
//  UnfairLockDemo.m
//  TestRunLoop
//
//  Created by Murph on 2022/3/9.
//

#import "UnfairLockDemo.h"
#import <os/lock.h>

@implementation UnfairLockDemo{
    os_unfair_lock _moneyLock;
    os_unfair_lock _ticketLock;
}

- (instancetype)init{
    if(self = [super init]) {
        _moneyLock = OS_UNFAIR_LOCK_INIT;
        _ticketLock = OS_UNFAIR_LOCK_INIT;
    }
    return self;
}

-(void) __saleTicket {
    os_unfair_lock_lock(&_ticketLock);
    int ticket = self.ticketCount;
    sleep(1);
    ticket -= 1;
    self.ticketCount = ticket;
    NSLog(@"ticket remain: %d", self.ticketCount);
    os_unfair_lock_unlock(&_ticketLock);
}


-(void) __saveMoney:(int) money {
    os_unfair_lock_lock(&_moneyLock);
    int innermoney = self.money;
    sleep(1);
    innermoney += money;
    self.money = innermoney;
    NSLog(@"save money remain: %d", self.money);
    os_unfair_lock_unlock(&_moneyLock);

}

-(void) __getMoney:(int) money {
    os_unfair_lock_lock(&_moneyLock);
    int innermoney = self.money;
    sleep(1);
    innermoney -= money;
    self.money = innermoney;
    NSLog(@"get money remain: %d", self.money);
    os_unfair_lock_unlock(&_moneyLock);
}
@end
