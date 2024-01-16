//
//  NSLockDemo.m
//  TestRunLoop
//
//  Created by Murph on 2022/3/9.
//

#import "NSLockDemo.h"

@implementation NSLockDemo{
    NSLock *_moneyLock;
    NSLock *_ticketLock;
}


- (instancetype)init{
    if(self = [super init]) {
        _moneyLock = [[NSLock alloc] init];
        _ticketLock = [[NSLock alloc] init];
    }
    return self;
}

-(void) __saleTicket {
    [_ticketLock lock];
    [super __saleTicket];
    [_ticketLock unlock];
}


-(void) __saveMoney:(int) money {
    [_moneyLock lock];
    [super __saveMoney:money];
    [_moneyLock unlock];
}

-(void) __getMoney:(int) money {
    [_moneyLock lock];
    [super __getMoney: money];
    [_moneyLock unlock];
}

@end
