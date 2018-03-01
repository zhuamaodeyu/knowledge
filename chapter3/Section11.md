##1. init /initWithFrame方法的调用  
系统会调用



##2. 第三方库重复   
###问题表现  
~~~
duplicate symbol _OBJC_METACLASS_$_JKSerializer in:
    /Users/tony/Desktop/XXXProject/Lib/libMiPushSDK.a(JSONKit.o)
    /Users/tony/Library/Developer/Xcode/DerivedData/XXXProject-boqkajmzatzxohbyrrhklfiuknic/Build/Products/Debug-iphoneos/libPods.a(JSONKit.o)
ld: 24 duplicate symbols for architecture armv7
clang: error: linker command failed with exit code 1 (use -v to see invocation)
~~~

### 解决方式  
1. 找到第三方库     
2. 进行复制副本  
3. 查看包信息    
	`lipo -info libx.a`  
	针对多平台需要逐一做解包重打包操作   
4. 创建临时文件夹，用于存放armv7平台解压后的.o文件：`mkdir armv7`   
5. 取出armv7平台的包：`lipo libx.a -thin armv7 -output armv7/libx-armv7.a `   
6. 查看库中所包含的文件列表：`ar -t armv7/libx-armv7.a`   
7. 解压出object file（即.o后缀文件）：`cd armv7 && ar xv libx-armv7.a`  
8. 找到冲突的包（JSONKit），删除掉`rm JSONKit.o`  
9. 重新打包object file：`cd .. && ar rcs libx-armv7.a armv7/*.o`，可以再次使用[2]中命令确认是否已成功将文件去除  
10. 将其他几个平台(armv7s, i386)包逐一做上述[1-6]操作   
11. 重新合并为fat file的.a文件：  
	`lipo -create libx-armv7.a libx-armv7s.a libx-i386.a -output libMiPushSDK-new.a`  
12. 拷贝到项目中覆盖源文件：  
	`cp libMiPushSDK-new.a /Users/xxx/Desktop/XXXProject/Lib/libMiPushSDK.a`  
	


## 3. 在使用UITableView 或者CollectionView 经常会出现由于cell个数与数据源不等crash   

这种问题主要出在cell 刷新次数频繁的操作中，例如聊天界面接收与发送消息等操作  


### 解决方式 
1. 通过一个数组，先接收数据，然后再讲此数组添加到数据源中，刷新界面   

~~~
 [self.collectionView performBatchUpdates:^{
 			//将临时数组添加到数据源中
          [self.messsagesSource addObjectsFromArray:_subMessageDataSource];

          NSMutableArray *indexPaths = @[].mutableCopy;
          for (NSInteger i = _subMessageDataSource.count; i > 0 ; i--) {
              NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.messsagesSource.count - i) inSection:0];
              [indexPaths addObject:indexPath];
          }
           [self.collectionView insertItemsAtIndexPaths:indexPaths];
            } completion:^(BOOL finished) {
                if (finished) {
                    [_subMessageDataSource removeAllObjects];
                }
            }];
~~~


## 4. 关于 NSTimer 造成无法释放问题  

1. 通过若引用来引用timer  
	
	~~~objectivec
	__weak id weakSelf = self;
 	timer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:weakSelf 	selector:@selector(tick) userInfo:nil repeats:YES];
	~~~
2. 通过GCD 创建定时器 
	
	~~~objectivec
	__weak typeof(self) weakSelf = self;
	double delayInSeconds = 2.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)	(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[weakSelf doSomethingRepeatedly];
	});
	}
	~~~

3. 通过  
	
	~~~objectivec
	- (void)timer2 {
    
    NSMethodSignature *method = [ViewController instanceMethodSignatureForSelector:@selector(invocationTimeRun:)];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:method];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 invocation:invocation repeats:YES];
    
    // 设置方法调用者
    invocation.target = self;
    
    // 这里的SEL需要和NSMethodSignature中的一致
    invocation.selector = @selector(invocationTimeRun:);
    
    // 设置参数
    // //这里的Index要从2开始，以为0跟1已经被占据了，分别是self（target）,selector(_cmd)
    // 如果有多个参数, 可依次设置3 4 5 ...
    [invocation setArgument:&timer atIndex:2];
    
    [invocation invoke];
    
    NSLog(@"start");
}
	~~~
	
4. 通过GCD 实现  
	* 实现延迟执行  
		
		~~~
		dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
		 dispatch_after(delayTime, dispatch_get_main_queue(), ^(void){
		 	NSLog(@"延迟2s后执行");
		 
		 });
		~~~

	* 基于延迟执行实现  
		`void
dispatch_source_set_timer(dispatch_source_t source,
    dispatch_time_t start,
    uint64_t interval,
    uint64_t leeway)` 主要是此方法  
    
        ~~~
                // 重复执行的定时器
            - (void)gcdTimer1 {
                
                // 获取全局队列
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                // 创建定时器
                dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
                
                // 开始时间
                dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
                
            //    dispatch_time_t start = dispatch_walltime(NULL, 0);
                
                // 重复间隔
                uint64_t interval = (uint64_t)(1.0 * NSEC_PER_SEC);
                
                // 设置定时器
                dispatch_source_set_timer(_timer, start, interval, 0);
                
                // 设置需要执行的事件
                dispatch_source_set_event_handler(_timer, ^{
                    
                    //在这里执行事件
                    static NSInteger num = 0;
                    
                    NSLog(@"%ld", (long)num);
                    num++;
                    
                    if (num > 4) {
                        
                        NSLog(@"end");
                        
                        // 关闭定时器
                        dispatch_source_cancel(_timer);
                    }
                });
                // 开启定时器
                dispatch_resume(_timer);
                
                NSLog(@"start");
            }
        ~~~
	

## 5. 关于通话状态界面向下移的问题   
方式1： 通过监听statusbar高度的变换，更新UI  
	
~~~
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutControllerSubViews) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];

// 重新布局
- (void)layoutControllerSubViews
{
    // 对需要的UI重新适配Frame
} 	
~~~

方法2： 在系统的`viewDidLayoutSubviews`方法中重新设置值  

~~~
-(void) viewDidLayoutSubviews {
	[super viewDidLayoutSubviews]; 
	self.view.y = 0;
	self.view.height = ScreenHeght;
}
~~~
	
## 6. UISearchController 搜索框不见的原因  

~~~
self.definesPresentationContext = YES;
~~~

## 7. 自定义相机照片截取特定区域  
可能拍摄的照片与看到的照片是不同的  
![来自简书]()
~~~
//_cameraView为相机视图，即拍摄时看到图片的区域
CGFloat scale = image.size.width / _cameraView.width;//计算出缩放的比例
CGFloat showImageH = image.size.height / scale;//缩放后图片的高度
CGFloat offsetY = (showImageH - _cameraView.height) * 0.5;//上下超出的部分是相等的，所以*0.5得出上面超过的部分

CGRect rect = CGRectMake(x, y, width,height);
CGImageRef tailorImageRef = CGImageCreateWithImageInRect(photo.CGImage, rect);
UIImage *tailorImage = [UIImage imageWithCGImage:tailorImageRef];
~~~  

## 8. 判断当前设备是iPhone还是iPad   
可以通过系统给定的属性进行判断  

~~~
 if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //iPhone, present activity view controller as is
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else
    {
        //iPad, present the view controller inside a popover
        if (![self.activityPopover isPopoverVisible]) {
            self.activityPopover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
            [self.activityPopover presentPopoverFromBarButtonItem:self.shareItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            //Dismiss if the button is tapped while pop over is visible
            [self.activityPopover dismissPopoverAnimated:YES];
        }
    }
~~~

## 9.iOS中可变对象的线程不安全问题  
iOS开发中 (Objective-C) 中，可变对象普遍都是线程不安全的， 这样在操作是就容易造成一些莫名其妙的问题出现 ， 比如: UICollectionView的cell与数据源不同步啊等问题  

~~~
	
    //添加锁机制
    @synchronized(arrayM)
    {
        [arrayM addObject:profile];
    }
    
     @synchronized(arrayM) {
            [arrayM removeObject:profile];
    }
~~~

## 10. 针对需要传入多个枚举值的处理以及获取传入枚举值  
在开发中往往有时候需要往方法中传入多个枚举值，但是只有一个参数， 需要通过__或运算__进行传入，当需要获取传入的枚举值时，需要通过__与运算__获取      

~~~
//或运算
int interestSet = SelectionKey.OP_READ | Selection.OP_WRITE;   

//与运算获取值
boolean isInterestedInRead = interestSet & SelectionKey.OP_READ;

~~~

