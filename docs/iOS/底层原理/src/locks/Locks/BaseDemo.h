//
//  BaseDemo.h
//  TestRunLoop
//
//  Created by Murph on 2022/3/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseDemo : NSObject
@property(assign, nonatomic)int ticketCount;
@property(assign, nonatomic)int money;

-(void) testMoney;
- (void) saleTicket;


-(void) __saleTicket;
-(void) __saveMoney:(int) money;
-(void) __getMoney:(int) money;
@end

NS_ASSUME_NONNULL_END
