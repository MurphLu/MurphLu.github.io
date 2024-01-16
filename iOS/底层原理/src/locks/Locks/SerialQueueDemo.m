//
//  SerialQueueDemo.m
//  TestRunLoop
//
//  Created by Murph on 2022/3/9.
//

#import "SerialQueueDemo.h"

@implementation SerialQueueDemo{
    dispatch_queue_t ticketQueue;
    dispatch_queue_t moneyQueue;
}


- (instancetype)init{
    if(self = [super init]) {
        ticketQueue = dispatch_queue_create("ticketQueue", DISPATCH_QUEUE_SERIAL);
        moneyQueue = dispatch_queue_create("ticketQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void) __saleTicket {
    dispatch_sync(ticketQueue, ^{
        [super __saleTicket];
    });
}


-(void) __saveMoney:(int) money {
    dispatch_sync(moneyQueue, ^{
        [super __saveMoney:money];
    });
    
}

-(void) __getMoney:(int) money {
    dispatch_sync(moneyQueue, ^{
        [super __getMoney: money];
    });
}

@end
