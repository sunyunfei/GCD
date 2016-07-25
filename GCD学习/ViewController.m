//
//  ViewController.m
//  GCD学习
//
//  Created by 孙云 on 16/7/20.
//  Copyright © 2016年 haidai. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (IBAction)clickBtn:(id)sender;

- (IBAction)clickBtn2:(id)sender;
@property(nonatomic,strong)dispatch_semaphore_t semaphore;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self loadGCD1];
    //[self loadGCD2];
    //[self loadGCD3];
    //[self loadGCD4];
    //[self loadOperation];
    //[self loadOperation2];
    //[self loadOperation3];
    //[self loadOperation4];
    //[self loadOperation5];
    //[self loadOperation6];
    //[self loadOperation7];
    //[self loadDelay];
    [self loadSemphore];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -----线程阻塞代码块
- (void)loadGCD1{

    //输出什么
    NSLog(@"之前");
    dispatch_sync(dispatch_get_main_queue(), ^{
       
        NSLog(@"之中");
    });
    NSLog(@"之后");
    
    
}
/**
 *  县城阻塞
 */
- (void)loadGCD2{

    //输出什么
    dispatch_queue_t queue = dispatch_queue_create("1", DISPATCH_QUEUE_SERIAL);//穿行
    
    NSLog(@"111");
    dispatch_async(queue, ^{
        
        NSLog(@"222");
        dispatch_sync(queue, ^{
            
            NSLog(@"3333");
        });
        NSLog(@"4444");
    });
    NSLog(@"555");
}
#pragma mark -----gcd队列代码块
/**
 *  队列组可以将很多队列添加到一个组里，这样做的好处是，当这个组里所有的任务都执行完了，队列组会通过一个方法通知我们。下面是使用方法，这是一个很实用的功能。
 */
- (void)loadGCD3{

    //队列
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //多次使用队列组的方法执行任务, 只有异步方法
    dispatch_group_async(group, queue, ^{
        for(int i = 0; i < 3;i ++){
        
            NSLog(@"三次循环%i",i);
        }
    });
    
    dispatch_group_async(group, dispatch_get_main_queue(), ^{
       
        for(int i = 0;i < 8;i ++){
        
            NSLog(@"主队列循环%i",i);
        }
    });
    
    dispatch_group_async(group, queue, ^{
       
        for(int i = 0;i < 5;i ++){
        
            NSLog(@"最后循环%i",i);
        }
    });
    
    //结果通知
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
       
        NSLog(@"完成所有县城");
    });
    
    
}
#pragma mark -----barrier代码块
/**
 *  这个方法重点是你传入的 queue，当你传入的 queue 是通过 DISPATCH_QUEUE_CONCURRENT 参数自己创建的 queue 时，这个方法会阻塞这个 queue（注意是阻塞 queue ，而不是阻塞当前线程），一直等到这个 queue 中排在它前面的任务都执行完成后才会开始执行自己，自己执行完毕后，再会取消阻塞，使这个 queue 中排在它后面的任务继续执行.如果你传入的是其他的 queue, 那么它就和 dispatch_async 一样了。
 
 dispatch_barrier_sync(_ queue: dispatch_queue_t, _ block: dispatch_block_t):
 
 这个方法的使用和上一个一样，传入 自定义的并发队列（DISPATCH_QUEUE_CONCURRENT），它和上一个方法一样的阻塞 queue，不同的是 这个方法还会 阻塞当前线程。
 
 如果你传入的是其他的 queue, 那么它就和 dispatch_sync 一样了。
 */
- (void)loadGCD4{

    dispatch_queue_t queue = dispatch_queue_create("2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"之前");
    });
    
    dispatch_async(queue, ^{
        
        for(int i = 0;i < 2;i ++){
            
           NSLog(@"应该不被阻塞");
        }
    });
    
    dispatch_barrier_async(queue, ^{
        for(int i = 0;i < 2;i ++){
            
            NSLog(@"阻塞当前县城");
        }
    });
    
    dispatch_async(queue, ^{
       
        for(int i = 0;i < 2;i ++){
            
            NSLog(@"应该被阻塞的");
        }
    });
    
    NSLog(@"完成");
}
#pragma mark -----operation基本使用
/**
 *  队列组可以将很多队列添加到一个组里，这样做的好处是，当这个组里所有的任务都执行完了，队列组会通过一个方法通知我们。下面是使用方法，这是一个很实用的功能。
 将要执行的任务封装到一个 NSOperation 对象中。
 将此任务添加到一个 NSOperationQueue 对象中
 NSOperation 只是一个抽象类，所以不能封装任务。但它有 2 个子类用于封装任务。分别是：NSInvocationOperation 和 NSBlockOperation 。创建一个 Operation 后，需要调用 start 方法来启动任务，它会 默认在当前队列同步执行。当然你也可以在中途取消一个任务，只需要调用其 cancel 方法即可
 NSInvocationOperation : 需要传入一个方法名。
 
 在 Swift 构建的和谐社会里，是容不下 NSInvocationOperation 这种不是类型安全的败类的。
 */
- (void)loadOperation{

    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(run1) object:nil];
    [operation start];
}
- (void)run1{

    NSLog(@"NSInvocationOperation");
}
/**
 *  NSBlockOperation
 *
 */
- (void)loadOperation2{

    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"NSBlockOperation");
    }];
    //开始
    [operation start];
}
#pragma mark -----添加多个并发任务
/**
 *  之前说过这样的任务，默认会在当前线程执行。但是 NSBlockOperation 还有一个方法：addExecutionBlock: ，通过这个方法可以给 Operation 添加多个执行 Block。这样 Operation 中的任务 会并发执行，它会 在主线程和其它的多个线程 执行这些任务
 addExecutionBlock 方法必须在 start() 方法之前执行，否则就会报错
 */
- (void)loadOperation3{

    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"开始");
    }];
    //添加多个block
    for(int i = 0;i < 4;i ++){
    
        [operation addExecutionBlock:^{
           
            NSLog(@"block+%i",i);
        }];
    }
    [operation start];
}
#pragma mark -----队列块
/**
 *  看过上面的内容就知道，我们可以调用一个 NSOperation 对象的 start() 方法来启动这个任务，但是这样做他们默认是 同步执行 的。就算是 addExecutionBlock 方法，也会在 当前线程和其他线程 中执行，也就是说还是会占用当前线程。这是就要用到队列 NSOperationQueue 了。而且，按类型来说的话一共有两种类型：主队列、其他队列。只要添加到队列，会自动调用任务的 start() 方法
 */

- (void)loadOperation4{

    NSOperationQueue *queue = [[NSOperationQueue alloc]init];//队列
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1");
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"2");
    }];
    
    [queue addOperations:@[op1,op2] waitUntilFinished:NO];
}
#pragma mark -----执行数
/**
 * 这时应该发问了，大家将 NSOperationQueue 与 GCD的队列 相比较就会发现，这里没有并行队列，那如果我想要10个任务在其他线程串行的执行怎么办？
 
 这就是苹果封装的妙处，你不用管串行、并行、同步、异步这些名词。NSOperationQueue 有一个参数 maxConcurrentOperationCount 最大并发数，用来设置最多可以让多少个任务同时执行。当你把它设置为 1 的时候，他不就是串行了嘛！
 
 NSOperationQueue 还有一个添加任务的方法，- (void)addOperationWithBlock:(void (^)(void))block; ，这是不是和 GCD 差不多？这样就可以添加一个任务到队列中了，十分方便。
 */
- (void)loadOperation5{

    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 2;//同时能进行的县城数
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for(int i = 0;i < 10;i ++)
        {
        
            NSLog(@"op1 %i",i);
        }
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for(int i = 0;i < 10;i ++)
        {
            
            NSLog(@"op2 %i",i);
        }
    }];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"op3");
    }];
    
    [queue addOperations:@[op1,op2,op3] waitUntilFinished:NO];
}
#pragma mark -----执行顺序
/**
 *  NSOperation 有一个非常实用的功能，那就是添加依赖。比如有 3 个任务：A: 从服务器上下载一张图片，B：给这张图片加个水印，C：把图片返回给服务器。这时就可以用到依赖了
 *注意：不能添加相互依赖，会死锁，比如 A依赖B，B依赖A。
 可以使用 removeDependency 来解除依赖关系
 可以在不同的队列之间依赖，反正就是这个依赖是添加到任务身上的，和队列没关系
 */
- (void)loadOperation6{

    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 3;//同时能进行的县城数
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for(int i = 0;i < 10;i ++)
        {
            
            NSLog(@"op1 %i",i);
        }
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for(int i = 0;i < 10;i ++)
        {
            
            NSLog(@"op2 %i",i);
        }
    }];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"op3");
    }];
    
    //依赖关系
    [op2 addDependency:op1];
    [op3 addDependency:op2];
    //[op3 removeDependency:op2];//删除依赖
    [queue addOperations:@[op1,op2,op3] waitUntilFinished:NO];
}
/**
 *  NSOperation
 BOOL executing; //判断任务是否正在执行
 BOOL finished; //判断任务是否完成
 void (^completionBlock)(void); //用来设置完成后需要执行的操作
 - (void)cancel; //取消任务
 - (void)waitUntilFinished; //阻塞当前线程直到此任务执行完毕
 
 NSOperationQueue
 NSUInteger operationCount; //获取队列的任务数
 - (void)cancelAllOperations; //取消队列中所有的任务
 - (void)waitUntilAllOperationsAreFinished; //阻塞当前线程直到此队列中的所有任务执行完毕
 [queue setSuspended:YES]; // 暂停queue
 [queue setSuspended:NO]; // 继续queue
 *
 */
#pragma mark -----互斥锁
/**
 *  互斥锁 ：给需要同步的代码块加一个互斥锁，就可以保证每次只有一个线程访问此代码块。
 */
- (void)loadOperation7{

    __block typeof(self)weakSelf = self;
    dispatch_async(dispatch_queue_create("1", DISPATCH_QUEUE_CONCURRENT), ^{
       
        [weakSelf synchronizedMethod:@"one"];
    });
    
    dispatch_async(dispatch_queue_create("2", DISPATCH_QUEUE_CONCURRENT), ^{
       
        [weakSelf synchronizedMethod:@"two"];
    });
}
/**
 *  互斥方法
 *
 */
- (void)synchronizedMethod:(NSString *)name{

    @synchronized (self) {
        for(int i = 0;i < 10;i ++){
        
            NSLog(@"%@ %i",name,i);
        }
    }
}
#pragma mark -----延迟加载
/**
 *  延迟执行
 *
 */
- (void)loadDelay{

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //延迟时间
    double delay = 3;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), queue, ^{
       
        NSLog(@"延迟执行");
    });
}
#pragma mark -----单例模式
/**
 *  单例模式
 *
 */
+ (instancetype)loadShare{

    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        if (_instance == nil) {
            _instance = [[self alloc]init];
        }
        
    });
    return _instance;
}
#pragma mark------心好凉
/**
 *    简单来说就是控制访问资源的数量，比如系统有两个资源可以被利用，同时有三个线程要访问，只能允许两个线程访问，第三个应当等待资源被释放后再访问。
 注意：再GCD中，只有调度的线程在信号量不足的时候才会进入内核态进行线程阻塞
  dispatch_semaphore_signal 提高信号量
 dispatch_semaphore_wait 降低信号量
 注意，正常的使用顺序是先降低然后再提高，这两个函数通常成对使用。
 */
- (void)loadSemphore{

    _semaphore = dispatch_semaphore_create(1);
    NSLog(@"信号量创建完毕，可以使用");
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"开始等待");
}

/**
 *  按钮事件
 *
 *  @param sender <#sender description#>
 */
- (IBAction)clickBtn:(id)sender {
    NSLog(@"启动信号量");
    dispatch_semaphore_signal(_semaphore);
}

- (IBAction)clickBtn2:(id)sender {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"消耗信号量");
    });
    
}
@end
