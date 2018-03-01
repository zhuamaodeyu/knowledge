在项目开发中遇到个比较特殊的需求，即一下图所显示的  
![](http://ozjlhf9e0.bkt.clouddn.com/20180301151989207821299.png)  

第一👁看到这样的图     
![](http://ozjlhf9e0.bkt.clouddn.com/20180301151989209420902.jpg)  
第一次沟通    
 
![](http://ozjlhf9e0.bkt.clouddn.com/20180301151989210472882.png)   

第二次--卒 

![](http://ozjlhf9e0.bkt.clouddn.com/20180301151989211454259.jpg)    


第三次   
![](http://ozjlhf9e0.bkt.clouddn.com/20180301151989212715892.jpg)


__缘由__  
设计师认为当前苹果的基于导航栏左侧返回的方式在大屏幕手机上操作，用户需要通过双手才能更好的操作，单手操作时并不能很好的从左边返回以及容易掉地上 ，啊哈哈  所以想打破传统的设计，设计了返回按钮在右边的方式(__😂开发__), 作为一个苦逼开发，争取无果后，那就只能 去实现喽 


###分析  
从表面上看，只是更改里系统导航控制器item按钮的位置  __但是。。。。。__  
###第一次尝试----修改顶部按钮位置  
当时想通过简单的修改按钮的位置来达到消息，但是。。。。控制器在push与pop操作时，应该如何修改顶部的按钮    

* 问题1 ： 如何保持返回按钮永远在控制器上，并且导航控制器的根控制器上不存在  
* 问题2 : 有些界面有更多按钮，有些界面无更多按钮，如何处理   

###第二次尝试----重写导航控制器  
既然以上方式无法达到功能，那么要不就重写一个导航控制器？  啊哈哈 说起来简单 但是做起来  导航控制器需要控制很多的细节，如果重写的话，那么主要是导航头，如何重写   

### 第三次尝试----利用runtime来实现  
1. 通过扩展`UIViewController`的方式来实现  
	需要添加利用runtime机制，添加两个属性  
	* 头文件定义  
	
	~~~
	@property(nonatomic,strong) UIColor *titleColor;

	@property(nonatomic,strong) NSString *subTitle;

	//设置带有图片的title并且图片添加事件  
	-(void)setTitle:(NSString *)title titleIcon:(UIImage *)image iconAction:(SEL)action;
	~~~
	
	* 实现  
	
~~~objectivec
-(void)setTitle:(NSString *)title
{
    if([self isKindOfClass:[UIAlertController class]]){
        [self setValue:title forKey:@"_title"];
        
        return;
    }
    UIView *customView =  self.navigationItem.leftBarButtonItem.customView;
    if (customView == nil) {
        UIButton *label = [[UIButton alloc]init];
        label.tag = 1;
//        [label setText:title];
        [label setTitle:title forState:UIControlStateNormal];
        
        UIFont *font = [UIFont fontWithName:@"PingFangSC-Medium" size:20];
        if (!font) {
            font = [UIFont boldSystemFontOfSize:20];
        }
        label.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [label.titleLabel setFont:font];
        [label sizeToFit];
        [label setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if(label.width > [UIScreen mainScreen].bounds.size.width *2 / 3)
        {
            label.width = [UIScreen mainScreen].bounds.size.width *1 / 3;
        }
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:label];
    }else if([customView isMemberOfClass:[UIButton class]])
    {
        UIButton *label = (UIButton *)customView;
//        [label setText:title];
        [label setTitle:title forState:UIControlStateNormal];
        [label.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [label sizeToFit];
        [label setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else
    {
        UIButton *label;
        for (UIView *subView in customView.subviews) {
            UIButton *subLabel = (UIButton *)subView;
            if (subLabel.tag  == 1) {
                label = subLabel;
            }
        }
//        [label setText:title];
        [label setTitle:title forState:UIControlStateNormal];
        [label setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
//     [self.navigationItem.leftBarButtonItem.customView setBackgroundColor:[UIColor randomColor]];
}

-(void)setTitle:(NSString *)title titleIcon:(UIImage *)image iconAction:(SEL)action
{
    [self setTitle:title];
    UIImage *newImage = nil;
    if (image.size.width > 35 || image.size.height > 35) {
        newImage =[image scaleImageWithSize:CGSizeMake(35, 35) isCircle:YES];
    }else
    {
        newImage = [image scaleImageWithSize:image.size isCircle:YES];
    }
    
    UIView *customView =  self.navigationItem.leftBarButtonItem.customView;
    if (customView != nil && [customView isMemberOfClass:[UIButton class]]) {
        UIButton *label = (UIButton *)customView;
        [label setImage:newImage forState:UIControlStateNormal];
        [label.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [label addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        [label sizeToFit];
        if (label.width > [UIScreen mainScreen].bounds.size.width *2 / 3) {
            label.width =  [UIScreen mainScreen].bounds.size.width *2 / 3;
             label.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
        }else
        {
             label.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15);
        }
    }
}
-(void)setTitleColor:(UIColor *)titleColor
{
    objc_setAssociatedObject(self, IndieBandNameKey, titleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UIView *view = self.navigationItem.leftBarButtonItem.customView;
    if ([view isMemberOfClass:[UIButton class]]) {
        UIButton *label = (UIButton *)view;
        [label.titleLabel setTextColor:titleColor];
    }else
    {
        UIButton *label;
        for (UIView *subView in view.subviews) {
            UIButton *subLabel = (UIButton *)subView;
            if (subLabel.tag  == 1) {
                label = subLabel;
            }
        }
        
        [label.titleLabel setTextColor:titleColor];

    }
//     [self.navigationItem.leftBarButtonItem.customView setBackgroundColor:[UIColor randomColor]];
}

-(UIColor *)titleColor
{
      return objc_getAssociatedObject(self,IndieBandNameKey);
}

-(void)setSubTitle:(NSString *)subTitle
{
    objc_setAssociatedObject(self,IndieBandNameSubTitleKey , subTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIView *view = self.navigationItem.leftBarButtonItem.customView;

    if ([view isMemberOfClass:[UIButton class]]) {
        UIView *backView = [[UIView alloc]init];
        
        UIButton *Label = (UIButton *)view;
        
        UIButton *titleLabel = [[UIButton alloc]init];
        titleLabel.tag = 1;
//        [titleLabel setText:Label.text];
        [titleLabel setTitle:Label.titleLabel.text forState:UIControlStateNormal];
        [titleLabel.titleLabel setFont:Label.titleLabel.font];
        [titleLabel sizeToFit];
        [titleLabel.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [titleLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if(titleLabel.width > [UIScreen mainScreen].bounds.size.width *2 / 3)
        {
            titleLabel.width = [UIScreen mainScreen].bounds.size.width *1 / 3;
        }
        
        UILabel *subTitleLabel = [[UILabel alloc]init];
        subTitleLabel.tag = 2;
         [subTitleLabel setText:subTitle];
        UIFont *font = [UIFont fontWithName:@"PingFangSC-Medium" size:10];
        if (!font) {
            font = [UIFont boldSystemFontOfSize:10];
        }
        
        [subTitleLabel setFont:font];
        [subTitleLabel sizeToFit];
        
        [backView addSubview:titleLabel];
        [backView addSubview:subTitleLabel];
        
        titleLabel.x = 0;
        subTitleLabel.x = titleLabel.width + 3;
        if (iPhone6Plus) {
             subTitleLabel.y = titleLabel.height - subTitleLabel.height - 10;
        }else if(iPhone6){
            subTitleLabel.y = titleLabel.height - subTitleLabel.height - 10;
        }else{
             subTitleLabel.y = titleLabel.height - subTitleLabel.height - 7;
        }
       
        
        backView.width =titleLabel.width + subTitleLabel.width + 5;
        backView.height = titleLabel.height;
        
//        [subTitleLabel setBackgroundColor:[UIColor randomColor]];
//        [backView setBackgroundColor:[UIColor randomColor]];
//        [titleLabel setBackgroundColor:[UIColor randomColor]];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backView];
    }
    else
    {
        UIButton *label;
        for (UIView *subView in view.subviews) {
            UIButton *subLabel = (UIButton *)subView;
            if (subLabel.tag  == 2) {
                label = subLabel;
            }
        }
        
        [label setTitle:subTitle forState:UIControlStateNormal];
        [label setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

-(NSString *)subTitle
{
    return objc_getAssociatedObject(self,IndieBandNameSubTitleKey);
}

~~~
	以上方式也不是很难， 就是一直在判断`navigationItem.leftBarButtonItem`以及修改其中子控件的过程
	
  
	



2. 在自定义的NavigationController中重写`pushViewController:animated:`方法， 在其中处理按钮的个数以及返回按钮是否显示的问题  

~~~objectivec
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //取消掉系统的back item
    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[UIView alloc]init]];
    
    //push操作  
    [super pushViewController:viewController animated:animated];
    //push 完成后处理
    if ([self.viewControllers count] > 1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(popButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"topbar_back_btn_n"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"topbar_back_btn_h"] forState:UIControlStateHighlighted];
        [button sizeToFit];
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
        item.tag = 10008;
        //说明本身就有item (比如：更多 item 等其他item )
        if (viewController.navigationItem.rightBarButtonItems.count > 0) {
            NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:viewController.navigationItem.rightBarButtonItems];
            [mutableArray insertObject:item atIndex:0];
            viewController.navigationItem.rightBarButtonItems = mutableArray.copy;
        }else
        {
            viewController.navigationItem.rightBarButtonItem = item;
        }
    }
}
~~~




虽然上边的方法解决的问题，但是又引入了新的问题：  
####1. 左滑手势的消失    
在自定义的导航控制器的`viewDidLoad`方法中通过以下方式添加左滑手势  

~~~objectivec
  id target = self.interactivePopGestureRecognizer.delegate;
    UIScreenEdgePanGestureRecognizer *GestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:target action:@selector(handleNavigationTransition:)];
    GestureRecognizer.edges = UIRectEdgeLeft;
    GestureRecognizer.delegate = self;
    // 给导航控制器的view添加全屏滑动手势
    [self.view addGestureRecognizer:GestureRecognizer];
    // 禁止使用系统自带的滑动手势
    self.interactivePopGestureRecognizer.enabled = NO;
    //隐藏back item
    self.navigationItem.hidesBackButton = YES;
~~~
同时实现代理方法，禁止在根控制器的时候再触发手势  

~~~objectivec
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.childViewControllers.count == 1) {
        return NO;
    }
    return YES;
}
~~~ 

####2. 多次跳转会出现多个返回按钮  
网上看到有人通过对`UIControl`进行扩展实现，虽然这种方式可以实现但是并不能通用，控制器的跳转是可以通过多种形式实现的，比如顶部item ，UIbutton ， UITableViewCell 等等方式实现，所以最好的方式是在导航控制器中实现处理  

在`- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated`方法中实现限制  

~~~objectivec
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
 {
   //此处代码可以不需要
   if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
      self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    //主要在此处代码,定义一个属性，当push 的时候判断是否为yes
    if (self.pushing) {
        return;  
    }
    
    //具体的处理业务  
    
    [super pushViewController:viewController animated:animated];
    self.pushing = yes;
}
~~~


需要在代码方法中在push动作完成后，将其设置为NO  

~~~objectivec
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    self.pushing = NO;   
}
~~~

### 总结  
以上就是解决方案了，如果有更好的方式实现，还希望能告知于我   
__项目赶得太紧，代码写的有点渣，喷请轻喷， 啊哈哈__












