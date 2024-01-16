//
//  PthreadrwlockDemo.m
//  TestRunLoop
//
//  Created by Murph on 2022/3/10.
//

#import "PthreadrwlockDemo.h"
#import <pthread.h>

@implementation PthreadrwlockDemo{
    pthread_rwlock_t lock;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        pthread_rwlock_init(&lock, NULL);
    }
    return self;
}

-(void)testRW{
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
    sleep(1);
    [[[NSThread alloc] initWithTarget:self selector:@selector(write) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(write) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(write) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(write) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(read) object:nil] start];
}

-(void)read{
    pthread_rwlock_rdlock(&lock);
    NSLog(@"read");
    sleep(random() % 10);
//    NSLog(@"%ld", random());
    NSLog(@"read end");
    pthread_rwlock_unlock(&lock);
}

-(void)write{
    pthread_rwlock_wrlock(&lock);
    NSLog(@"write");
    sleep(random() % 10);
    NSLog(@"write end");
    pthread_rwlock_unlock(&lock);
}

- (void)dealloc
{
    pthread_rwlock_destroy(&lock);
}

@end
