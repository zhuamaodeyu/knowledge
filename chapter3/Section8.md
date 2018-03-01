# iOS系统九宫格下代理方法调用多次解决办法  

## 问题
在项目开发中，遇到个很奇怪的问题， 在iOS系统自带的九宫格键盘下，`UITextView` 控件的`- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text`代理方法会调用多次  

###1. 需求背景  
在做IM 及时通讯开发中，针对群聊功能 中，必不可少的一个就是 @ 功能的实现，在实现细节上就是通过实时监测系统输入，当检测到输入的单个字符是`@` 时，跳出@Controller 的控制器，进行@ 人员的选择， 然后选中后又跳回界面

###2. 问题原因设想  
问题原因可能是由于九宫格下，输入的第一个字符不是`@`字符，当再次选择`@`符号时，会再次调用代理方法，将第一次输入的替换掉(__注意，此问题暂时只在九宫格键盘模式下出现,猜测应该是九宫格的一键多用导致的__)  

#####测试代码以及测试结果：  

~~~objectivec
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	NSLog(@"%@", text);
	return yes;
}

~~~
__步骤:__   
	切换到九宫格键盘侠，输入内容需要时`@`符 
 
__测试结果:__  
![](http://ozjlhf9e0.bkt.clouddn.com/2018030115198923675676.png)    

__注意:__此问题在第三方比如输入法搜狗以及系统的全键盘下都不会出现此问题， 只有在系统九宫格下才会出现此问题

###3. 问题解决办法  
既然系统没有做这种判断，那只能自己来做喽。 我采用的办法就是借助一个boolean值 `_view_show`，当为`_view_show`为 false 并且输入的字符是`@`的时候，进行跳转，当为true的时候不做任何处理，当跳转进界面后设置为true， 当再次回到这个界面时设置为false
  
__满足条件__  

* 输入的字符必须是 `@`  
* `_view_show` 必须为false  

__伪代码__  

~~~
-(void) viewDidAppear{
	[super viewDidAppear];
	_show_view = false;
}

//代理方法中的判断逻辑  
if ([text isEqualToString:@"@"] && _view_show == false) {
	//具体的条换逻辑操作  
	_view_show = true;
}
~~~

__项目具体实现代码__  

~~~
//为了解决代理方法调用多次的问题
-(void)chatView:(ALNChatView *)chatView replacementTextWithAtText:(NSString *)text
{
    if(_conversation.conversationType != ConversationType_GROUP) return;
    
    if ([text isEqualToString:@"@"] && _view_show == false) {
        __weak __typeof(self) weakSelf = self;
        ViewController *selectedVC = [[ViewController alloc]init];
        selectedVC.dataSourceArray = _groupMemberListArray;
        selectedVC.saveButtonActionBlock = ^(NSArray *arr){
           	//block  操作后的， 与此处问题无关
          }
        };
        //关键步骤
        _view_show = true;
        [self.navigationController pushViewController:selectedVC animated:YES];
        
    }
}
~~~















		