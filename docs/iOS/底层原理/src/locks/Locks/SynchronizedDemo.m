//
//  SynchronizedDemo.m
//  TestRunLoop
//
//  Created by Murph on 2022/3/9.
//

#import "SynchronizedDemo.h"

@implementation SynchronizedDemo

-(void) __saleTicket {
    @synchronized (@"ticket") {
        [super __saleTicket];
    }
}

-(void) __saveMoney:(int) money {
    @synchronized (@"money") {
        [super __saveMoney:money];
    }
}

-(void) __getMoney:(int) money {
    @synchronized (@"money") {
        [super __getMoney: money];
    }
}
@end
