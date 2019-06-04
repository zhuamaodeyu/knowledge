# 3D Touch  
Apple 自iPhone  6s起支持3D Touch 功能。一个很棒的功能。但其需要借助硬件支持，所有 6s下的手机都不能实现。呼呼 。作为一名开发者怎么能被这个难住呢。在实现3D Touch 的学习之前先让我们的模拟器支持此功能吧，呼呼   

## 3D Touch 实现  

3D Touch支持3种模式：  

1. peek and pop     
	在消息列表页面按压会话，则会弹出这个邮件或会话的阅览，如果继续施加压力按压，则会push出具体的界面实现
2. Home Screen Quick Actions    
	通过主屏幕的应用Icon，用3D Touch呼出一个菜单，进行快速定位到应用功能模块相关功能触发相关功能    
3. Force Properties   


### peek and pop  
此种模式是分为peek 和 pop 两步的。具体的实现根据用户的力度不同会分为以下几步：   
  
1. 首先表明内容可以被预览  
2. 展示预览图  (peek模式)
3. 预览视图出现导航视图 (pop 模式)   


#### 具体实现步骤   
1. 首先需要检测 3D Touch 的可用性    

```
// 检测3D Touch可用性
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) { 
    [self registerForPreviewingWithDelegate:self sourceView:cell]; 
    } 
```
2. 控制器遵守UIViewControllerPreviewingDelegate协议并实现代理方法   
刺代理只存在两个代理方法。需要实现这两个方法才能实现功能   

```
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    //将触摸点的坐标转化为tableView坐标系上的坐标点
    CGPoint locationBaseTableView = [self.tableView convertPoint:location fromView:[previewingContext sourceView]];
    //根据触摸点获取当前触摸的cell的indexPath
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    //根据indexPath配置当前需要弹出的控制器，并返回   
    
    return VC;
}

```
此处系统会对其余部分做虚化处理，可以在以上代理中通过添加一下代码实现对虚化部分的控制  

``` 
//    调整不被虚化的范围，按压的那个cell不被虚化（轻轻按压时周边会被虚化，再少用力展示预览，再加力跳页至设定界面）
//    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width,40);
//    previewingContext.sourceRect = rect;
    
```   

``` 
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
     commitViewController:(UIViewController *)viewControllerToCommit
{
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
}
```   

以上步骤只是实现了pop和 week 模式，如果需要实现week Action ,那么需要在被pop控制器中实现一下方法，并返回事件列表   

```  
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems{
    
    UIPreviewAction *action = [UIPreviewAction actionWithTitle:@"action" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"action1");
    }];
    
    UIPreviewAction * action2 = [UIPreviewAction actionWithTitle:@"action2" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"action2");
    }];
    
    return @[action, action2];
}

```  
通过touch事件获取压力值    

```
//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSArray *arrayTouch = [touches allObjects];
//    UITouch *touch = (UITouch *)[arrayTouch lastObject];
		touch.force;
//}
```




























### Home Screen Quick Actions 实现  
此种模式的实现一般有两种方式添加标签：  
	1. 通过plist文件进行添加   
		程序启动起来就可以看到，简单、直接、明了
	2. 通过代码进行添加  
		程序必须运行一次才可以看到，需要通过代码添加(代码必须执行一次才可以)    
		

#### 1. 静态添加入口标签   
```  
UIApplicationShortcutitems			Array    
	item 0								Distionary 
	item 1  
	item 2   

```   

每一个item 可以包含以下属性：   

1. `UIApplicationShortcutItemType `      
	* 设置一个标识符字符串，用来标识用户根据那个标签进入程序   
	* 必有项  

2. `UIApplicationShortcutItemTitle `  
	* 标签的标题  
	* 必有项

3. `UIApplicationShortcutItemSubtitle `  
	* 副标题  

4. `UIApplicationShortcutItemIconType `   
	* 设置图标的样式，使用系统自带的  

5. `UIApplicationShortcutItemIconFile `   
	* 自定义标签图标文件路径  

6. `UIApplicationShortcutItemUserInfo `  
	



#### 2. 代码实现添加标签  

```objectivec
-(void) addShortcutItem {
    //使用系统提供的ShortcutIcon类型,
    UIApplicationShortcutIcon *addOneIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeAdd];
    UIApplicationShortcutItem *addOneItem = [[UIApplicationShortcutItem alloc] initWithType:@"one" localizedTitle:@"第一个" localizedSubtitle:nil icon:addOneIcon userInfo:nil];
    
    //自定义ShortcutIcon
    // 如果设置了自定义的icon，那么系统自带的就不生效
    UIApplicationShortcutIcon *myIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"myImage"];
    UIApplicationShortcutItem *myItem = [[UIApplicationShortcutItem alloc] initWithType:@"two" localizedTitle:@"第二个" localizedSubtitle:nil icon:myIcon userInfo:nil];
    [UIApplication sharedApplication].shortcutItems = @[addOneItem, myItem];
}

```

####3. 事件处理   

```
#pragma mark 3D Touch
-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
 //此种方式是通过 type 进行区分， 还可以通过titile  进行区分，一般的title都是不相同的
    if ([shortcutItem.type isEqualToString:@"UIApplicationShortcutItemType"]) {
        
    }else if([shortcutItem.type isEqualToString:@""]){
    
    }else {
        
    }
}
```

####参考
1. [跟着官方文档学习3D Touch](http://ios.jobbole.com/84905/)
2. [官方文档]()








