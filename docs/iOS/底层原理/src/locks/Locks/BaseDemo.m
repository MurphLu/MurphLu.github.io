//
//  BaseDemo.m
//  TestRunLoop
//
//  Created by Murph on 2022/3/9.
//

#import "BaseDemo.h"
@interface BaseDemo()

@end

@implementation BaseDemo
- (instancetype)init{
    if (self = [super init]){
        self.ticketCount = 20;
        self.money = 500;
    }
    return self;
}
- (void) saleTicket {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        for (int i = 0; i<5; i++) {
            [self __saleTicket];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i<5; i++) {
            [self __saleTicket];
        }
    });
}

-(void) testMoney {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        for (int i = 0; i<5; i++) {
            [self __saveMoney:50];
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i<5; i++) {
            [self __getMoney:100];
        }
    });
}

-(void) __saleTicket {
    int ticket = self.ticketCount;
    sleep(1);
    ticket -= 1;
    self.ticketCount = ticket;
    NSLog(@"ticket remain: %d", self.ticketCount);
}


-(void) __saveMoney:(int) money {
    int innermoney = self.money;
    sleep(1);
    innermoney += money;
    self.money = innermoney;
    NSLog(@"save money remain: %d", self.money);
}

-(void) __getMoney:(int) money {
    int innermoney = self.money;
    sleep(1);
    innermoney -= money;
    self.money = innermoney;
    NSLog(@"get money remain: %d", self.money);
}

@end
