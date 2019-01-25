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


## 11. ASDisplayKit(Texture)ASCollectionNode 隐藏滚动条问题 
本次开发，由于项目需要在cell 中进行复杂布局，处于性能考虑以及个人也想尝试下ASDisplayKit 框架，在针对ASCollectionNode 隐藏滚动条时遇到了问题比如：  

```objectivec  
  self.collectionNode.view.showsVerticalScrollIndicator = NO;
  // 通过以上方式来隐藏滚动条
        self.collectionNode.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubnode:self.collectionNode];
```
按理说，以上方式是可以实现的，虽然ASDisplayKit 提供的是可以异步刷新view， 但是我通过直接修改view的属性的方式是没有问题的。但是在此处，通过此种方式，程序会crash掉  

```
2018-03-12 10:41:11.612039+0800 LiveTeach-iPhone[31807:17295610] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'This method must be called on the main thread'
*** First throw call stack:
(
	0   CoreFoundation                      0x00000001074e012b __exceptionPreprocess + 171
	1   libobjc.A.dylib                     0x0000000109d19f41 objc_exception_throw + 48
	2   CoreFoundation                      0x00000001074e52f2 +[NSException raise:format:arguments:] + 98
	3   Foundation                          0x0000000108336d69 -[NSAssertionHandler handleFailureInMethod:object:file:lineNumber:description:] + 193
	4   LiveTeach-iPhone                    0x000000010601ab41 -[ASDisplayNode view] + 1009
	5   LiveTeach-iPhone                    0x0000000105f9aa46 -[ASCollectionNode view] + 54
	6   LiveTeach-iPhone                    0x0000000105dc0526 -[LTProcessCellView initWithModel:] + 2758
	7   LiveTeach-iPhone                    0x0000000105da8867 __64-[LTProcessViewContro2018-03-12 10:41:11.612215+0800 LiveTeach-iPhone[31807:17295094] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'This method must be called on the main thread'
*** First throw call stack:
(
	0   CoreFoundation                      0x00000001074e012b __exceptionPreprocess + 171
	1   libobjc.A.dylib                     0x0000000109d19f41 objc_exception_throw + 48
	2   CoreFoundation                      0x00000001074e52f2 +[NSException raise:format:arguments:] + 98
	3   Foundation                          0x0000000108336d69 -[NSAssertionHandler handleFailureInMethod:object:file:lineNumber:description:] + 193
	4   LiveTeach-iPhone                    0x000000010601ab41 -[ASDisplayNode view] + 1009
	5   LiveTeach-iPhone                    0x0000000105f9aa46 -[ASCollectionNode view] + 54
	6   LiveTeach-iPhone                    0x0000000105dc0526 -[LTProcessCellView initWithModel:] + 2758
	7   LiveTeach-iPhone                    0x0000000105da8867 __64-[LTProcessViewContro2018-03-12 10:41:11.612153+0800 LiveTeach-iPhone[31807:17295302] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'This method must be called on the main thread'

```  
以上堆栈信息显示的大致意思就是 有某个方法需要在主线程上调用。通过调试，我可以确定就是`self.collectionNode.view.showsVerticalScrollIndicator = NO;`这句话引起的crash。但是我通过GCD 让其同步的在主线程上执行

```
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.collectionNode.view.showsVerticalScrollIndicator = NO;
            self.collectionNode.view.showsHorizontalScrollIndicator = NO;
        });
```

but, 同样会crash， 以下是堆栈信息  

```
2018-03-12 10:44:57.867918+0800 LiveTeach-iPhone[32029:17313512] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Incorrect display node thread affinity - this method should not be called off the main thread after the ASDisplayNode's view or layer have been created'
*** First throw call stack:
(
	0   CoreFoundation                      0x0000000107b6c12b __exceptionPreprocess + 171
	1   libobjc.A.dylib                     0x000000010c8caf41 objc_exception_throw + 48
	2   CoreFoundation                      0x0000000107b712f2 +[NSException raise:format:arguments:] + 98
	3   Foundation                          0x00000001089c2d69 -[NSAssertionHandler handleFailureInMethod:object:file:lineNumber:description:] + 193
	4   LiveTeach-iPhone                    0x00000001066bab0c -[ASDisplayNode _removeFromSupernode] + 332
	5   LiveTeach-iPhone                    0x00000001066b4dde -[ASDisplayNode _insertSubnode:atSubnodeIndex:sublayerIndex:andRemoveSubnode:] + 2830
	6   LiveTeach-iPhone                    0x00000001066b62f1 -[ASDisplayNode _addSubnode:] + 1297
	7   LiveTeach-iPhone                    0x00000001066b5d9c -[ASDisplayNode addSubnode:] + 60
	8   LiveTeach-iPhone                    0x000000010644b47d -[LTProcessCellView initWithModel:] + 3021
	9   LiveTeach-iPhone                    0x00000001064336b7 __64-[LTProcessViewController tableNode:nodeBlockForRowAtIndexPath:]_block_invoke + 71
	10  LiveTeach-iPhone                    0x000000010679e738 __51-[ASTableView dataController:nodeBlockAtIndexPath:]_block_invoke_2 + 104
	11  LiveTeach-iPhone                    0x000000010660f98f -[ASCollectionElement node] + 127
	12  LiveTeach-iPhone                    0x000000010665d5fa __58-[ASDataController _allocateNodesFromElements:completion:]_block_invoke + 154
	13  LiveTeach-iPhone                    0x000000010666f59d __ASDispatchApply_block_invoke + 93
	14  libdispatch.dylib                   0x000000010e31c2f7 _dispatch_call_block_and_release + 12
	15  libdispatch.dylib                   0x000000010e31d33d _dispatch_client_callout + 8
	16  libdispatch.dylib                   0x000000010e322406 _dispatch_queue_override_invoke + 1895
	17  libdispatch.dylib                   0x000000010e329102 _dispatch_root_queue_drain + 772
	18  libdispatch.dylib                   0x000000010e328da0 _dispatch_worker_thread3 + 132
	19  libsystem_pthread.dylib             0x000000010e7971ca _pthread_wqthread + 1387
	20  libsystem_pthread.dylib             0x000000010e796c4d start_wqthread + 13
)
2018-03-12 10:44:57.867915+0800 LiveTeach-iPhone[32029:17313411] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Incorrect display node thread affinity - this method should not be called off the main thread after the ASDisplayNode's view or layer have been created’  

```  
以上crash信息表示的是 “此处提示的是什么方法不需要在main 线程调用”。为什么通过同步的主线程方式还是会crash呢？ 接下来我又通过了异步的方式实现，are you kidding me？  

```
        dispatch_async(dispatch_get_main_queue(), ^{
            self.collectionNode.view.showsVerticalScrollIndicator = NO;
            self.collectionNode.view.showsHorizontalScrollIndicator = NO;
        });
```
只能通过以上方式来实现   。 虽然现在不知道原因，在此记录下   

## 12. UIScrollView 滚动结束监测  
UIScrollView 在滚动时， 会实时触发 `scrollViewDidScrollView` 方法， 但是却没有一个很好的方式监测滚动是否停止， 其中可以查看到的代理方法`- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView` 但是这个方法有点不靠谱。偶尔会不调用  

通过对UIScrollVeiw 的分析，其中与滚动相关的 3个参数 `tracking`, `dragging`, `decelerating`, 在滚动和滚动结束这三个属性的值是不相同的。 可以通过监听这些值来实现监测滚动结束方式   

```swift 
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.tableView.isUserInteractionEnabled = false
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let  scrollToScrollStop = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if (scrollToScrollStop) {
            self.scrollViewDidEndScroll()
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            let  dragToDragStop = scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
            if (dragToDragStop) {
                self.scrollViewDidEndScroll()
            }
        }
    }
    
    fileprivate func scrollViewDidEndScroll() {
        
    }

```
> 以上方式在某种情况下还是无法正确实现 

### 方式2  
通过主动去调用 `scrollViewDidEndScrollingAnimation`方法  
```swift 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:)), with: nil, afterDelay: 0.3)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.tableView.isUserInteractionEnabled = true
    }
```
__原理:__ scrollView 只要滚动就会调用 `scrollViewDidScroll` 方法，可以再次方法中创建一个异步调用，等待某些时间调用 `scrollViewDidEndScrollingAnimation` 代理方法。由于 `scrollViewDidScroll`会不断被调用，再次出发时会取消上一次的异步调用任务，等到最后一次`scrollViewDidScroll`调用时，取消了上次的异步任务，又添加了新的异步任务，最后添加的这个新的会执行任务任务 调用`scrollViewDidEndScrollingAnimation`代码   


