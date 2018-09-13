# iOS 避免多级跳转  
有时候在点击cell 的时候，由于点击的太快，导致系统没反应过来，多次点击后，系统跳转多次     

一般针对此种问题，通常有一下几种方式：  

1. 设置一个变量记录此操作，如果用户同时点击的是同一个按钮或者cell，那么就将执行不可操作代码   
2. 再次点击之前取消上次的事件   

~~~objectivec
-(void)buttonAction:(id)sender
{
   //首先先取消上次操作
   [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(buttonAction:) object:sender];
   //执行这次操作
   [self performSelector:@selector(buttonClicked:)withObject:sender afterDelay:0.2f];
}

~~~


3. 点击后将控件设置为不可点击状态   
	此种方式针对button等控件比较好操作些  
	
~~~objectivec
-(void)buttonAction:(id)sender
{
	self.button.enabled = NO;
	//通过延迟执行方法
	[self performSelector:@selector(changeButtonStatus) withObject:nil afterDelay:1.0f];//防止用户重复点击
}

-(void)changeButtonStatus{
    self.button.enabled = YES;
}
~~~

4. 通过重写 `UINavigationController` 代理方式实现  
	1. 实现继承自 `UINavigationController ` 的控制器并实现代理  
	2. 添加属性记录是否可push   
	3. 重写push 方法  
	
	~~~objectivec
	// 重写父类方法
	- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
	{
    //~下面代码是解决页面的多次 push 使用~
    if (self.pushing ==  YES) {
         NSLog(@"被拦截");
        return;
    }else{
         NSLog(@"被push");
        self.pushing = YES;
    }
    ~~~
    
    4. 实现代理方法   

    ~~~objectivec
    //导航控制器的代理方法的实现（为了解决页面 的多次 push 的问题）
	-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    	self.pushing = NO;
    
	}
	~~~
	
5. 提供一个HUD 禁止用户再次操作   
	此种方式一般针对button这样的方便，但是如果程序处理快，HUD会一闪而过 ，所以用户体验并不是很好    
	主要针对在事件中有网络请求等耗时操作的时候，使用此种方式是比较合理和人性化的   
	


