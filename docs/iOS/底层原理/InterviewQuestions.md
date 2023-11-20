### 一个 NSObject 对象占多少内存

- 系统分配了 16 个字节给 NSObject 对象（通过 `malloc_size` 函数获得）
- 但是 NSObject 对象内部只使用了 8 个字节的空间用来存储 isa 指针(64bit 环境下，通过 `class_getInstanceSize` 函数获得)

### 对象的 isa 指针指向在哪里

>实例 （instance）、类（class）、元类（meta-class）
>class对象、meta-class对象 在内存中只有一份

- instance 对象的 isa 指针指向 class 对象
- class 对象的 isa 指针指向 meta-class 对象
- meta-class 对象的 isa 指针指向基类的 meta-class 对象

### 类信息存放在哪里

- 属性值存放在 instance 对象中
- 对象方法、属性、成员变量、协议 信息存放在 class 对象中
- 类方法存放在 meta-class 对象中

### iOS 用什么方法实现一个对象的 KVO（KVO 的本质是什么）

- 利用 RuntimeAPI 动态生成一个子类，并且让 instance 对象的 isa 指向这个全新的子类
- 当修改 instance 对象的属性时，会调用 Foundation 的 _NSSetXXXValueAndNotify 函数
- - willChangeValueForKey:
- - 父类原来的 setter
- - didChangeValueForKey: (该方法在`NSObject(NSKeyValueObserverNotification)`中实现了对 观察者 监听方法的调用，如果子类有重写该方法并且未调用super，那么观察者的监听方法就无法被调用)

### 如何手动触发 KVO

```Objective-C
[self.person1 willChangeValueForKey:@"age"];
// didChangeValueForKey 中会有判断是否调用了 willChangeValueForKey，所以如果想触发 KVO 那么需要将两个方法一起调用才可以
[self.person1 didChangeValueForKey:@"age"];
```

### 直接修改成员变量会触发 KVO 么？

肯定不会，直接修改成员变量的值并不会调用 set 方法，也不会走 KVO 的流程。。。
如果想触发，那么需要手动触发

```Objective-C
[self.person1 willChangeValueForKey:@"age"];
self.person1->_age
[self.person1 didChangeValueForKey:@"age"];
```

### 通过 KVC 修改属性的时候会不会触发 KVO

- 可以，即使没有属性只有成员变量，只要能保证 KVC 的正常调用就能触发 KVO

### KVC 的赋值和取值的过程是怎么样的，原理是什么

[请参见](05-KCV.md)

## Category

### Category 的使用场合是什么

### Category 的实现原理是什么

- 底层结构是 struct category_t, 里面存储着分类的对象方法、类方法、属性、协议信息
- 在程序运行的时候，runtime 会将 Category 的数据，合并到类中（类对象，元类对象中）

### Category 和 Class Extension 的区别是什么

- Class Extension 在编译时，它的数据就已经包含在类信息中
- 而 Category 是在运行时，才会将数据合并到类信息中

### Category 中有 load 方法么？load 方法是什么时候调用的，load 方法能继承么

- 有
- 在runtime 在加载 类和分类的时候调用的
- - 先调用类的 +load （按照编译先后顺序调用，先编译先调用，调用子类的 load 之前会先调用父类的 load）
- - 在调用分类的 load（同样按照编译先后顺序调用）

- 可以继承，但是一般不会主动调用 load 方法，load 是供系统来调用的

### load、initialize 的方法区别是什么？它们在 Category 中的调用顺序，以及出现继承时他们之间的调用过程

1. 调用方式
- `+load` 根据函数地址直接调用， `+initialize` 通过 `objc_msgSend` 调用

2. 调用时刻
- load 是 runtime 加载 类、分类的时候调用，只调用一次
- initialize 是类第一次收到消息的时候调用，每个类只会 initialize 一次（父类的 initialize 方法可能会被调用多次，但是调用者为未实现 initialize 方法的子类，其目的是 initialize 子类）

3. 调用顺序
- load 先调用类的 load，再调用分类的 load（编译顺序），先编译的类先调用 load，但是调用子类 load 之前会先调用 父类的 load（在调用load之前会在编译顺序的基础上重排类，将父类放在前面）
- initialize 先初始化父类，再初始化子类

### Category 能否添加成员变量？如果可以，如何添加

- Category 不可以直接添加成员变量，但是可以通过间接方式实现

```C++
// 设置关联对象
objc_setAssociatedObject(id _Nonnull object, const void * _Nonnull key,
                         id _Nullable value, objc_AssociationPolicy policy)
// 获取关联对象
objc_getAssociatedObject(id _Nonnull object, const void * _Nonnull key)
```

## Block

### block 的原理是怎样的？本质是什么

封装了函数调用及调用环境的OC对象

### _block 的作用是什么？有什么使用注意点

将修饰的 auto 变量包装成一个对象，用来保证block中引用的基本类型变量不会被系统回收，也可以在 block 中修改 block 外的变量


### block 的属性修饰词为什么是 copy ？使用 block 有哪些需要注意的

调用 copy 之后就将 block 复制到堆上了，保证其不会被系统回收掉，注意循环引用
### block 在修改 NSMutableArray 时，需不需要加 _block？

不需要，只有修改 NSMutableArray 指针本身时需要加 __block，修改对象中的内容是不需要的


## runtime

### OC 消息机制，

OC 中的方法调用最终都是转成 objc_msgSend 函数的调用，给 receiver(方法调用者)发送了一条消息（selector 方法名）
三个阶段
- 消息发送
- 动态方法解析 `resolveInstanceMethod` 动态添加实现
- 消息转发


### 消息转发机制流程

### 什么是 runtime，项目中的使用

- OC 是一门动态性比较强的变成语言，允许很多操作推迟到程序运行时再进行，OC 的动态性就是由 runtime 来支撑和实现的，runtime是一套 C 语言 API 封装了很多动态性相关的函数，平时写的 OC 代码，底层都是转换成 runtime API 进行调用


- 利用关联对象（associatedObject）给分类添加属性
- 遍历类所有成员变量(访问私有成员变量，自动归档解档，字典转模型)
- 交换方法实现（交换系统自带的方法，hook 一些系统动作，在特定动作下执行特定操作，比如按钮点击，viewcontroller 显示之类的）
- 利用消息转发解决方法找不到的问题


## RunLoop

### RunLoop  在项目中的使用
- 解决 NSTimer 在滑动时停止工作的问题
- 监控应用卡顿
- 性能优化
### RunLoop 内部实现

### RunLoop 和线程的关系

- 每条线程都有唯一一个与之对应的 RunLoop 对象
- RunLoop 保存在一个全局的 Dictionary 里，线程作为 Key，RunLoop 作为 Value
- 创建线程时，没有 RunLoop，RunLoop会在第一次获取它时创建
- RunLoop 会在线程结束时销毁
- 主线程的RunLoop已将自动获取（创建），子线程默认没有开启 RunLoop

### timer 和 RunLoop 的关系

一个RunLoop 包含若干个Mode，每个Mode又包含若干个 Source0/Sources1/Observer/Timer
Timer可以唤醒 RunLoop 来执行 Timer 中的任务
### 程序中添加每 3 秒响应一次的 NSTimer，当拖动 tableView  时 timer 可能无法响应要怎么解决

将 Timer 添加到RunLoop的 commonMode 中，commonMode 并不是指一个特殊的 mode，而是一个特殊的标签，用来表示 RunLoopMode 中的 commonModes 列表中存储的所有 mode，也就表明了该 Timer 在 当前 RunLoop 的任何一个 mode 都可以执行

### RunLoop 如何响应用户操作，具体流程

比如点击事件，用户触摸屏幕，屏幕事件会包装成 event，event 由系统通知 source1，source1 唤醒 RunLoop，然后将事件交由 source0 来处理，然后检查是否有其他要执行的任务，有则执行，没有就睡眠

### RunLoop 的 mode 作用

Mode 用来对任务进行隔离，保证每个mode下的任务不会相互干扰，保证系统的流畅运行，比如滑动的时候会切换到 UITrackingMode，来保证滑动的流畅，滑动完之后又会切换到 defaultMode，来正常执行其他任务


## 多线程

### 你理解的多线程

### iOS 的多线程方案有哪几种？更倾向于哪一种

### 项目中是否用到过 GCD

### GCD 队列类型
同步队列，异步队列
### 说一下 OperationQueue 和 GCD 的区别，以及各自的优势
OperationQueue 是对 GCD 的 OC 封装
### 线程安全的处理手段有哪些
加锁
### OC的锁有哪些，二次提问
#### 自旋锁与互斥锁的对比
#### 注意点
#### C/OC/C++，任选其一，实现自旋锁和互斥锁，口述


## 内存管理

### 使用 CADisplayLink。NSTimer 有什么注意点
 循环引用，依赖 runloop 不准

### 介绍一下内存的几大区域

### 对 iOS 内存管理的理解

### autorelease 的对象在什么时机会被 release
1. 在对象所在的 @autorelease{} 作用域结束时会被释放
2. iOS main runloop 中会在runloop 睡眠之前或者退出之前释放

### 方法里有局部对象，出了方法后会立即释放么
ARC 是，如果是 MRC autorelease,那么就不一定了
### ARC 都帮我们做了什么

LLVM 编译器（自动添加 release 及 retain） + Runtime (弱引用)

### weak 指针实现原理
sidetable存储弱引用变量指针，对象释放时会从sidetable的弱引用表中找到弱引用该对象的变量并置空

## 优化

### 项目中的内存优化方式

### 从哪几方面着手

### 列表卡顿的原因有哪些，怎么优化的

### tableView 卡顿的原因


### LGTeacher 继承自 LGPerson 以下代码打印结果
```Objective-C
LGTeacher *t = [[LGTeacher alloc] init];

- (instancetype)init{
    self = [super init];
    if (self) {
        NSLog(@"%@ - %@",[self class],[super class]);
    }
    return self;
}
// output "LGTeacher - LGTeacher"
// 因为无论是 self 调用 class，还是 super 调用 class，最终都是走到 OC 的消息发送机制
// objc_msgSend 中会传入消息接收者，也就是实例本身
// 在 objc_msgSendSuper 中会传入一个 __rw_objc_super 的结构体，包含消息接收者以及父类对象
// 接收者都是实例对象本身，只是在方法查找的时候 super 会从父类开始寻找方法实现。由于 class 方法的实现是在基类 NSObject 中实现的，所以不管是从哪里开始查找调用的，最终都会返回实例对象的实际类型，也就是 LGTeacher
```


### 以下代码能否正常输出

```
@interface LGPerson : NSObject
  @property (nonatomic, retain) NSString *kc_name;
  - (void)saySomething;
  @end
  @implementation LGPerson
  - (void)saySomething{
      NSLog(@"%s - %@",__func__,self.kc_name);
  }
@end

- (void)viewDidLoad { 
    [super viewDidLoad];
    Class cls = [LGPerson class];
    void  *kc = &cls;
    [(__bridge id)kc saySomething];
}
// 答案可以
// LGPerson *person = [[LGPerson alloc] init];
// 最终的结构为 person 的 isa 指针指向 LGPerson 的类对象
// 又因为 isa 指针为 person 对象的第一个成员，所以 isa 指针实际上就等于 person 指针
// person 存储着 person 实例对象的地址，person对象中第一个成员 isa 又指向 LGPerson 的类对象
// person -> isa(person 实例对象) -> [LGPerson class]
// 然后看例子中的结构
// kc 中存储了 cls 的地址，cls 又指向 LGPerson 类对象，结果如下
// kc -> cls -> [LGPerson class]
// 可以看到例子中的结构同普通实例变量最终的结构是一样的
// 在调用 saySomething 进行消息发送时，先找到实例对象，然后通过实例对象的 isa 指针拿到类对象，进行方法查找，找到之后进行调用。
// 例子中的 cls 实际就相当于 isa 指针，只是在打印 kc_name 时，如果把 cls 当成实例对象的话，那么查找 kc_name 就会在 cls 指针的基础上向下移动 8 位，拿到内容，打印。
// 栈分配方式为从低到高进行分配，而 [super viewDidLoad] 调用过程中会创建一个 __rw_objc_super 的结构体，并且 viewController 为第一成员，所以，cls 向下移 8 位 找到的就是 viewController，打印出来就是当前的 viewcontroller，假如在 cls 之前定义其他实例变量吗，最终打印结果就是距离 cls 最近的一个实例对象
```

### 下面代码执行输出什么结果
```Objective-C
NSObject *objc = [NSObject new];
NSLog(@"%ld",CFGetRetainCount((__bridge CFTypeRef)(objc)));
void(^block1)(void) = ^{
    NSLog(@"---%ld",CFGetRetainCount((__bridge CFTypeRef)(objc)));
}; 
block1();

void(^__weak block2)(void) = ^{
    NSLog(@"---%ld",CFGetRetainCount((__bridge CFTypeRef)(objc)));
};
block2();

void(^block3)(void) = [block2 copy];
block3();
__block NSObject *obj = [NSObject new];
void(^block4)(void) = ^{
    NSLog(@"---%ld",CFGetRetainCount((__bridge CFTypeRef)(obj)));
};
block4();

// 在 ARC 环境下，编译器会根据情况自动将栈中的 block 复制到堆上
// - block 作为返回值时
// block 赋值给 __strong 指针时
// block 作为 Cocoa API 中方法名含有 usingBlock 方法参数时

// 有上面的说明我们来分析
// block1 作为强指针指向了 block 对象，block 对象先在栈上创建，block1 指向它之后有复制到了堆上一份，所以此处的引用计数会 +2，栈上一份，堆上一份，又因为 NSObject 实例化的时候就有一个强引用了，所以 block1 中打印的为 1+2=3
// block2 中为弱指针，不会将 block copy 到堆上，此处只会产生一份 block，对 objc 的引用计数也只会 + 1，此处为4
// block3 将 block2 copy 了一份，此时会将 block2 复制到堆上一份，引用计数 + 1，此处为 5
// __block 修饰的变量实际是将其包装成了一个对象，block 中引用的实际为 包装之后的对象，而该对象只有一份，只会对 obj 产生一个强引用，由于 底层屏蔽了这部分的实现，我们使用时访问到的还是原对象本身，所以 block 的引用增加引用计数，也只是对包装后的对象有影响，而对原对象没有影响
```


### 下面代码执行，控制台输出结果是什么

```Objective-C
- (void)MTDemo{
    while (self.num < 5) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.num++;
        });
    }
    NSLog(@"KC : %d",self.num);
}
// 本例中以 self.num 为限制条件，并且while中异步执行函数，最终结果肯定会大于等于5
// 循环执行次至少为 5

- (void)KSDemo{
     for (int i= 0; i<10000; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            self.num++;
        });
    }
    NSLog(@"Cooci : %d",self.num);
}
// 本例中以 i 为限制条件，for 循环只执行 100000 次，由于异步函数，最终接过一定小于10000
```


### 下面代码执行，控制台输出结果是什么
```Objective-C
- (void)textDemo2{
    dispatch_queue_t queue = dispatch_queue_create("cooci", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"1");
    // 异步任务，先执行完当前任务在执行该任务
    dispatch_async(queue, ^{
        NSLog(@"2");
        // 同步任务，需要先执行完才能继续往下走
        dispatch_sync(queue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}
// 1 5 2 3 4
// 例子中使用的队列为并发队列，任务进出队列的顺序不是固定的，所以，及时异步任务中嵌套有同步任务，同步任务也能正常拿到并执行

- (void)textDemo1{
    // 创建队列不传类型，默认为同步队列
    dispatch_queue_t queue = dispatch_queue_create("cooci", NULL);
    // 1。 正常打印
    NSLog(@"1");
    // 由于为异步任务，所以先执行下面的代码
    dispatch_async(queue, ^{
        // 3、 正常打印，
        NSLog(@"2");
        // 4. 死锁，由于队列为同步队列， 所以在当前任务执行之前下面的同步任务拿不到，无法执行
        // 而任务又是同步的，必须执行完才能往下走，然后就造成了死锁
        dispatch_sync(queue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    // 2。正常打印
    NSLog(@"5");
}
// 所以，打印 1 5 2 然后死锁崩溃
```

### 下面代码执行，控制台输出结果是什么

```Objective-C
 @property (nonatomic, strong) NSMutableArray      *mArray;
- (NSMutableArray *)mArray{
    if (!_mArray) _mArray = [NSMutableArray arrayWithCapacity:1];
    return _mArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 创建数组对象
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"1",@"2", nil];
    // 将 arr 赋值给当前实例对象
    self.mArray = arr;

    void (^kcBlock)(void) = ^{
        // block 对象中会对 arr 强引用，虽然后边 arr 变量置nil，但是 block 中引用的数组对象还在
        [arr addObject:@"3"];
        // block 对象中会对 self 强引用
        [self.mArray addObject:@"a"];
        NSLog(@"KC %@",arr);
        NSLog(@"Cooci: %@",self.mArray);
    };
    // arr = [@"1", @"2", @"4"]
    [arr addObject:@"4"];
    // // arr = [@"1", @"2", @"4", @"5"]
    [self.mArray addObject:@"5"];
    arr = nil;
    self.mArray 置空
    self.mArray = nil;
    // block 中通过self 拿到的mArray 为重新初始化的 添加完元素之后只有一个在block中添加的 @“a”
    // 但是 arr 由于数组实例还在，所以 arr 中的内容实际为 [@"1", @"2", @"4", @"5", @"3"]
    kcBlock(); 
}
// 最终打印 [@"1", @"2", @"4", @"5", @"3"] [@"a"】
```

### 可变数组是线程安全的 ❎
### 主队列搭配同步函数就会产生死锁 ❎ （要看队列是什么队列）

### 下面代码执行不会报错 ✅
```Objective-C
int a = 0;
void(^ __weak weakBlock)(void) = ^{ // 当前block 在栈上
    NSLog(@"-----%d", a);
};
struct _LGBlock *blc = (__bridge struct _LGBlock *)weakBlock; // blc 指向栈上的 block
 
id __strong strongBlock = [weakBlock copy]; // 由于栈上的block 调用了copy,所以 strongBlock 在堆上
blc->invoke = nil; // 栈上的 block 实现置空
void(^strongBlock1)(void) = strongBlock;
strongBlock1(); // 由于堆上的block没有任何改动，所以调用堆上的 block 一定不会报错
```

### 下面代码执行不会报错 ❎
```Objective-C
NSObject *a = [NSObject alloc];
// block1 为弱指针
void(^__weak block1)(void) = nil;
{
    // block2 为强指针
    void(^block2)(void) = ^{
        NSLog(@"---%@", a);
    };
    block1 = block2;
    NSLog(@"1 - %@ - %@",block1,block2);
}
// 出了上面作用域之后，由于 block2 不再有强指针引用，所以就释放掉了，此时调用 block1 会报错
block1();
```


### 下面代码没问题 ❎
```Objective-C
- (void)demo3{
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(0, 0);
    for (int i = 0; i<5000; i++) {
        dispatch_async(concurrentQueue, ^{
            NSString *imageName = [NSString stringWithFormat:@"%d.jpg", (i % 10)];
            NSURL *url = [[NSBundle mainBundle] URLForResource:imageName withExtension:nil];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:data];
            // 如果使用 barrier,那么必须是自己创建的并发队列，
            // 如果不是自己创建的并发队列，那么 dispatch_barrier_async 执行任务就同 dispatch_async 没什么区别

            dispatch_barrier_async(concurrentQueue, ^{
                [self.mArray addObject:image];
            });
        });
    }
}
```

