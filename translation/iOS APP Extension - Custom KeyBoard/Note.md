# iOS APP Extension - Custom KeyBoard 

用户选择自定义键盘后，它将成为用户打开的每个应用程序的键盘。因此，您创建的键盘必须至少提供某些基本功能。最重要的是，您的键盘必须允许用户切换到另一个键盘。


## 了解用户对键盘的期望 
要了解用户对自定义键盘的期望，请研究系统键盘 - 它快速、响应灵敏且功能强大。它永远不会用信息或请求打断用户。__如果您提供需要用户交互的功能，请将它们添加到包含键盘的应用程序中，而不是添加到键盘中。__  


### iOS 用户期望的键盘功能 
iOS 用户期望并且每个自定义键盘都必须提供 一项功能：__切换到另一个键盘的方法__  
在系统键盘中，这个功能是由一个地球按钮的按键提供的。在iOS8及以后，系统提供了抓们的API来完成这个功能。 
__[Providing a Way to Switch to Another Keyboard.](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html#//apple_ref/doc/uid/TP40014214-CH16-SW4)  


系统键盘会基于当前文本输入对象的`UIKeyboardType`特性来呈现合适的键位和相应的布局。  
比如需要输入一个邮箱地址，系统键盘的句号按键就会改变：长按的时候能够提供多个顶级域名后缀选择。
> 设计你的自定义键盘的时候考虑一下这些特性。

iOS 用户还期望自动大写：在标准文本字段中，区分大小写的语言中句子的第一个字母会自动大写。  

更多这类功能如下： 
* 基于UIKeyboardType特性的键盘布局。
* 自动校正与建议
* 自动首字母大写 
* 两个空格后自动添加句号 
* 大写锁定支持
* 键帽美化
* 表意语言的多级输入


您可以决定是否实现此类功能；刚刚列出的任何功能都没有专用的 API，因此提供它们是一种竞争优势。  


### 一些系统键盘具备的功能不能在自定义键盘上实现  
* 您的自定义键盘无法访问“设置”应用程序（“设置”>“常规”>“键盘”）中的大多数常规键盘设置，例如自动大写和启用大写锁定。  
* 您的键盘也无法访问词典重置功能（设置 > 常规 > 重置 > 重置键盘词典）   
如要满足用户的灵活需求，请创建一个标准的设置选项，参考[Implementing an iOS Settings Bundle in Preferences and Settings Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UserDefaults/Introduction/Introduction.html#//apple_ref/doc/uid/10000059i)  
然后，您的自定义设置将显示在与您的键盘关联的“设置”的“键盘”区域中。  


有一些文本输入对象是自定义键盘没有权限进行输入访问的。首先是任何安全文本输入对象。这样的对象是通过其secureTextEntry属性被设置为来定义的YES，并且通过将键入的字符呈现为点来区分。

* 当用户在安全文本对象（比如密码框）输入时，系统会会临时的用系统键盘来替换你的自定义键盘。当用户在非安全输入对象输入的时候，你的自定义键盘就会恢复。  

* 自定义键盘同样不能用在拨号输入对象，比如通讯录中的号码输入框。这些输入对象专门用于由电信运营商指定的一组数字、字符，并由以下一个或者另外一个键盘类型来标示：
    * `UIKeyboardTypePhonePad` 
    * `UIKeyboardTypeNamePhonePad`

当用户点击电话键盘对象时，系统会暂时用适当的标准系统键盘替换您的键盘。当用户点击另一个通过其类型特征请求标准键盘的输入对象时，您的键盘会自动恢复。   


__应用程序开发人员可以选择拒绝在其应用程序中使用所有自定义键盘。__  
例如，银行应用程序的开发人员或必须符合美国 HIPAA 隐私规则的应用程序的开发人员可能会这样做。此类应用程序采用协议`application:shouldAllowExtensionPointIdentifier:`中的方法UIApplicationDelegate（返回值NO），因此始终使用系统键盘。 
```swift 
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        return false
    }

```

由于自定义键盘只能在 UIInputViewController对象的主视图内部进行绘制显示，所以它不能选择文本。  
文本的选择是由使用键盘的应用程序控制的。如果App提供了编辑菜单（比如复制、剪切和粘贴），键盘是没有权限访问的。自定义键盘是不能提供光标位置附近的inline自动校正功能。  


在iOS8.0中自定义键盘和其他应用程序扩展一样，不能访问设备话筒，因此不能实现语音输入。  

最后，自定义键盘按键长按显示额外键位信息的视图是不能超过自定义键盘原始视图的顶部，系统键盘却可以。   


## 自定义键盘API入门  

这一节内容让你快速了构建自定义键盘的APIs。下图展示了一些关于键盘运行中的一些比较重要的对象以及在标准开发流程中的位置。  
![](./images/keyboard_architecture_2x.png) 

`Custom Keyboard template`自定义键盘模板（__在iOS“Application Extension” target template group__）包含了一个 `UIInputViewController`的子类,这个子类作为你键盘的初始视图控制器。  

这个模板也包含了一个基本的按键实现“切换下一个键盘”，它调用了`UIInputViewController`的的 `advanceToNextInputMode`方法。  
将视图、控件和手势识别器等对象添加到输入视图控制器的主视图（在其 inputView 属性中）  

与其他应用扩展一样，`target`中没有`window`，因此本身也没有根视图控制器。

模板的info.plist文件中预先配置好了键盘的基本参数。查看在键盘target的info.plist文件下对应的`NSExtensionAttributeskey`键信息。
这些关于键盘配置信息的key请查看[Configuring the Info.plist file for a Custom Keyboard](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html#//apple_ref/doc/uid/TP40014214-CH16-SW18)  


默认情况下，__键盘是没有网络访问权限的__，也不能和它的容器App共享同一个缓存空间。  
如果需要实现这些功能，请在info.plist文件中设置`RequestsOpenAccess = YES`。在这之后，会扩展键盘的沙盒。参考 [Designing for User Trust](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html#//apple_ref/doc/uid/TP40014214-CH16-SW3)  



一个`input view controller`与`文本输入对象`内容的交互需要遵循多个协议:  
* 响应`touch events`的插入或者删除, 需要使用`UIKeyInput`协议方法`insertText:`和`deleteBackward`  
在输入视图控制器的`textDocumentProxy`属性上调用这些方法，该属性表示当前文本输入对象并符合协议`UITextDocumentProxy`.  
```swift 
[self.textDocumentProxy insertText:@"hello "]; // Inserts the string "hello " at the insertion point
[self.textDocumentProxy deleteBackward];       // Deletes the character to the left of the insertion point
[self.textDocumentProxy insertText:@"\n"];     // In a text view, inserts a newline character at the insertion point
```

* 当你调用`deleteBackward`这个方法时, 需要获取到当前的文本是否是你所需要的删除的, 通过`textDocumentProxy`属性的 `documentContextBeforeInput`属性可以拿到文本输入光标位置的文本内容。   
```swift 
NSString *precedingContext = self.textDocumentProxy.documentContextBeforeInput;
```
拿到文本内容之后，你就可以决定删除多少内容：比如单个字符、或者文本之后的全部空格。如果你想要删除整个的语义部分，例如一个单词、一个语句或者一个段落，参考 [CFStringTokenizer](https://developer.apple.com/documentation/corefoundation/cfstringtokenizer) 中描述的功能并参考相关文档。请注意，每种语言都有自己的标记化规则。

* 调用`UITextDocumentProxy`的协议方法`adjustTextPositionByCharacterOffset:`控制好光标插入位置，比如要删除更早之前输入的字符。 
```swift 
- (void) deleteForward {
    [self.textDocumentProxy adjustTextPositionByCharacterOffset: 1];
    [self.textDocumentProxy deleteBackward];
}

```

> 若要响应活动文本对象内容中的更改，或响应用户启动的插入点位置更改，请实现 UITextInputDelegate 协议的方法。  


通过`UIKeyboardType`属性，为当前文本输入对象展现合适的键盘布局。  为每种你所支持的特性，相应的对初始视图做出改变。  

要支持两种或者更多的语言，你有两个选择：  
1. 为每一种语言创建一个键盘，每个键盘单独的作为容器App的一个target。  
2. 创建一个多语言支持的键盘，根据需要动态的切换合适的语言。想要动态切换主语言，使用`UIInputViewController`类的`primaryLanguage`属性。  

> 使用哪种方式创建，取决于你支持的语言种类多少以及用户的实际体验。    


所有的自定义键盘都能通过UILexicon类来访问基本的自动校正词典(和`RequestsOpenAccess` 值没关系) 
请充分利用这个类以及你自己提供的自动校正词典来为用户输入文本提供建议和校正。     


`UILexicon`类的词汇来源包过： 
* 从用户地址簿获取的不成对的姓和名  
* 设置- 通用 - 键盘 - 自定义短语（Settings > General > Keyboard > Shortcuts list ）  
* 通用字典


可以 __使用自动布局来调整自定义键盘的主视图的高度__。__默认情况下，自定义键盘的尺寸大小是和系统键盘的大小一致__，都是根据屏幕尺寸和方向来决定。系统会把自定义键盘的宽度设置为当前屏幕的宽度。想调整键盘的高度，那就改变主视图的高度约束。

```objective-c  
CGFloat _expandedHeight = 500;
NSLayoutConstraint *_heightConstraint = 
    [NSLayoutConstraint constraintWithItem: self.view 
                                 attribute: NSLayoutAttributeHeight 
                                 relatedBy: NSLayoutRelationEqual 
                                    toItem: nil 
                                 attribute: NSLayoutAttributeNotAnAttribute 
                                multiplier: 0.0 
                                  constant: _expandedHeight];
[self.view addConstraint: _heightConstraint];

```

> 在iOS8.0之后当自定义键盘的主视图初始化之后，你可以在任意时候改变它的高度。   



## 自定义键盘开发的要点  
自定义键盘的时候需要注意： 
* `信任`: 你的自定义键盘能够让你访问用户的输入内容，所以信任是你和用户之间最重要的一点。
* `允许“切换下一个键盘”按钮 `:  让用户能够切换到下一个键盘是键盘的一个基本功能。你 __必须提供这个功能__。   


### 为用户信任而做设计  
创建一个自定义输入法优先考虑到的应该是如何建立和维持良好的用户信任，
这种信任处决于你对隐私政策理解的最佳做法并且知道如何去实现。

对于键盘，以下三个领域对于建立和维护用户信任尤为重要：  
* `键盘输入数据的安全性`: 用户希望他们通过键盘输入的数据写入文档或者文本输入框，而不是保存在某个服务器或者被用于用户不可知的地方。  
* `合理的并且最小化的使用用户数据`: 如果你的键盘使用了其他用户的数据比如定位服务、通讯录，那么你有责任需要向用户解释这样做给用户带来的好处。  
* `精准`: 输入事件转换为输入文本的准确性并不是用户隐私该做的，但是它对用户的信任产生影响：每一个文字的输入，都能让用户看到你代码的准确性。  



信任设计的过程中，首先要考虑的就是`open access`（完全访问权限）  
尽管对于自定键盘来说`open access`能够让你做到很多事情，这同时也意味着你要承担更多的责任。  
下表列出了标准和开启`open access`（开启网络访问）键盘对应的功能和隐私责任  

#### open access 
* 关闭(默认) 
    * 能力和限制 
        1. 自定义键盘拥有基本键盘的所有功能  
        2. 自定义键盘拥有基本键盘的所有功能 
        3. 访问settings中的短语列表 
        4. 与容器App没有共享缓存空间 
        5. 除了键盘自己的容器App以外没有文件访问权限 
        6. 除了键盘自己的容器App以外没有文件访问权限
    * 隐私注意事项 
        * 用户知道通过键盘输入的信息仅用于当前APP
* 开启  
    * 能力和限制 
        1. 拥有标准自定义键盘的所有功能  
        2. 用户允许的情况下访问定位服务和通讯录  
        3. 键盘和它的容器App拥有一个共享存储空间  
        4. 键盘能够发送键盘输入信息和其他输入时间给服务器端处理 
        5. 容器App能够为键盘的自定义自动校正词典提供编辑界面 
        6. 通过容器App，键盘能够使用iCloud来确保相关设置和自动校正词典能够更新到所有设备上  
        7. 通过容器App，键盘能够参与Game Center和App内购买  
        8. 如果键盘支持移动设备管理（DMD），那么键盘也能够与受控App协同工作
    * 隐私注意事项 
        * 如果键盘支持移动设备管理（DMD），那么键盘也能够与受控App协同工作  
        * 你必须遵守 `应用审核指南和iOS程序开发者协议中的联网键盘开发指导`，在App Review Support页面中可以找到。

如果你开发的键盘没有开启open access，那么系统就会确保在任何位置键盘的输入信息都不会被发送给你。如果你只是想提供一款基本功能的键盘，那么就使用标准自定义键盘。   
由于沙盒的限制，非联网功能的键盘能够让你在满足苹果的数据隐私准则和获取用户信任上取得领先。


如果你开启了完全访问（详情见[Configuring the Info.plist file for a Custom Keyboard](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html#//apple_ref/doc/uid/TP40014214-CH16-SW18)），更多的功能对你开放同样也意味着更多的责任需要你承担。


> 提交一个`完全访问权限`的第三方键盘到`App Store`，你必须遵守 App Review Support页面的所有相关准则。  

作为开发者，每个与`open access`有关系的键盘功能都有相对应的你需要承担的责任。最大程度的去尊重用户数据，并且不要把这些数据用于用户所不知道的地方。  

> 开放访问键盘用户权益和开发人员责任  

|  功能   | 用户示例  |    开发者的责任   |
|  ----  | -------- | ----------------- |      
| 与容器App共享存储空间 | 键盘的输入法自动校正词典的UI管理 | 考虑到自动校正数据属于用户隐私数据，请不要把发送到服务器用于任何用户所不知道的目的|
| 发送键盘输入数据到你的服务器  | 通过开发者的计算资源来增强触摸事件或者输入预测 |  除非有必要为用户提供服务，不要存储用户的音频数据或者键盘输入 | 
| 基于互联网支持的动态自动校正  | 人名、地点、热点事件等加入到自动校正词汇中  |  不要把用户的身份和相关的信息关联起来用于任何用户未知的目的  |  
| 通讯录访问    |   将通讯录中的人名、地点和电话号码等和用户有关的词汇加入到自动校正词典中  | 不要在用户不知道的情况下将通讯录中的数据用于任何目的  |  
| 访问定位服务  | 将地理位置附近相关的位置名词等加入到校正词汇中   |  不要在后台使用定位。不要在用户不知道的情况下发送定位数据到服务器   |



使用了`open access`的自定义键盘和它的容器App是能够将键盘输入数据发送到你的服务器，并且能让你使用自己的计算资源来实现诸如触摸事件处理和输入法预测等功能。如果你使用了这些功能，那么当你接收到的键盘、音频数据已经远超与你向用户提供的服务时你不应该存储这些数据。



### 提供切换到其他键盘的方式 
当有不止一个输入法可以使用的时候，系统键盘就会有一个小地球按键让用户切换输入法。你的自定义键盘也需要提供一个类似的切换按键。 
![](./images/globe_key_2x.png)  

若要确定自定义键盘是否需要显示“下一个键盘”键，请检查输入视图控制器上的 `needsInputModeSwitchKey`` 属性。如果为 `true`，则键盘应包含此键。

若要要求系统切换到另一个键盘，请调用 `UIInputViewController` 类的 `advanceToNextInputMode` 方法。
系统从启用用户的键盘列表中选择相应的“下一个”键盘;没有用于获取已启用键盘列表或选择要切换到的特定键盘的 API。  

Xcode的自定义键盘模板以及包含了调用`advanceToNextInputMode`方法的按钮。不过为了更好的体验，你最好把这个按钮替换为类似系统小地球按钮的按键。   



## 开始自定义键盘的开发  
在本节中，你将了解如何创建自定义键盘，根据您的目标对其进行配置，以及如何在 iOS 模拟器或设备上运行它。您还将了解更换系统键盘时要记住的一些 UI 因素。  

### 使用 Xcode 自定键盘模板  
创建一个自定义键盘和它的容器App会与创建其他应用程序扩展少有不同。 这一节会一步步创建并运行一个键盘。  

#### 在容器App中创建自定义键盘  
1. `Xcode`中选择 `File>New>Project`,在`iOS Application template group`中选择`Single View Application template`。  
2. 点击下一步  
3. 为项目命名（例如，“包含键盘应用”），然后单击“下一步”。  
4. 选择你要保存工程的位置，然后点击创建  
    到此，你已经创建了一个空的app项目，现在需要包含一个键盘target。  
5. 选择`Flie>New>Target`在`iOSApplication Extension target template group`选择`Custom Keyboard template`，然后点击下一步。   
6. 创建⌨️名称  
7. 确保`Project`和`Embed in Application`弹出菜单显示的是容器App的名字，然后点击完成。如果弹出激活新键盘，点击激活。



> 下表列出了容器App和自定义键盘可以在`Info.plist`中配置的UI字符串属性  

| iOS用户界面文字      | Info.plist 键 |   
| ----------- | ----------- |
| 系统settings键盘列表的键盘组名称	      | 容器App的info.plist的Bundle display name       |
| settings中显示的键盘名字在全局键盘列表中显示的名字   | 键盘target的Info.plist中的Bundle display name        |


> 注意：  
* 系统设置键盘列表中名称显示规则： 
    如果键盘的`info.plist`文件的`display name`和容器App的`info.plist`文件的`display name`不一致，那么`settings`列表的键盘的显示格式就是`keyboardName - hostAppName`
    反之，如果`display name`一致，那么`settings`列表键盘名称显示就是`display name`   


## 运行自定义键盘并连接到Xcode的调试器上  
1. 在Xcode中，在键盘VC的代码中设置好断点。  
2. 确认在Xcode工具栏上选择的当前`scheme`指定为键盘的方案并且选择了模拟器或者一个真机设备。  
3. 选择 Product > Run，或者点击Xcode项目窗口左上方播放按钮。Xcode让你选择一个host APP。选择一个可以输入文本段的应用，比如通讯录或者Safari浏览器。（这里只是对键盘进行调试，不一定必须用你的容器App，只要是能够提供本文输入弹出键盘的APP都可以用来调试自定义键盘）。
4. 点击Run
    Xcode 在指定的App上运行。如果你是第一次在你的模拟器或者真机上运行你的键盘扩展程序，使用下面步骤在settings中启用你的键盘： 
    * 在`Settings > General > Keyboard > Keyboards`  
    * 点击添加新的键盘。  
    * 在已购买键盘组中，点击你的键盘名，弹出一个模态视图来开启你的键盘。  
    * 点击开启键盘，弹出一个警告。  
    * 在警告视图中，点击天机键盘来完成新键盘的添加。最后点击完成。  

5. 在模拟器或者真机中，唤起你的自定义键盘。  
    在任意的有可以输入文本区域的App或者Spotlight中都可以唤起键盘，接下来就是切换到你的自定义键盘。   
    现在你能看到你的自定义键盘了，但是在调试器还没连接。从模板创建的标准系统键盘只有一个Next Keyboard button按钮，让你可以切换到上一个使用的输入法。   
6. 关闭键盘（这样在第8步能够在重新唤起键盘的时候调用viewDidLoad断点）  
7. 在Xcode中，选择`Debug>Attach to Process > By Process Identifier(PID) or Name`  
    在出现的输入框中，输入创建键盘时的键盘扩展的名称（包过空格）。默认这个名字一般都是App扩展在项目导航窗口的`group name`
8. 点击Attach  
9. 在任意模拟器或者你使用的真机中，点击文本输入框唤起键盘。  
    随着你的键盘的主视图的加载，Xcode的调试器连接到你的键盘并且激活断点。    

### 自定义键盘配置Info.plist文件   
`Info.plist`文件静态的声明自定义键盘的一些特性，包过主要语言、是否要求开启完全访问。

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>IsASCIICapable</key>
        <false/>
        <key>PrefersRightToLeft</key>
        <false/>
        <key>PrimaryLanguage</key>
        <string>en-US</string>
        <key>RequestsOpenAccess</key>
        <false/>
    </dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.keyboard-service</string>
    <key>NSExtensionPrincipalClass</key>
    <string>KeyboardViewController</string>
</dict>
```

> 参考[App Extension Keys](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/AppExtensionKeys.html#//apple_ref/doc/uid/TP40014212)

* `IsASCIICapable`: 
    默认为 `NO`, 描述了键盘能否在文档中插入`ASCII`字符, 如果键盘开启了`UIKeyboardTypeASCIICapable`这个功能，请把它设置为`YES`   
* `PrefersRightToLeft`: 
    默认是`NO`, 设置你的键盘支持从右至左的输入方式的语言   
* `PrimaryLanguage`: 
    默认是`en-US`, [语言和区域描述](http://www.opensource.apple.com/source/CF/CF-476.14/CFLocaleIdentifier.c)
* `RequestsOpenAccess`:   
    默认是`NO`, 描述了键盘是否能够扩展它的沙盒（和主App通讯的共享缓存空间）。开启共享缓存你的键盘能够获得更多的功能：  
    * 访问定位服务、通讯录数据、相机等，每一项第一次访问都需要用户统一。   
    * 和容器App共享数据缓存，能够做到比如在容器App中管理自定义词典UI这样的功能。  
    * 能够通过网络发送键盘输入数据或者其他输入事件和数据以进行服务器端处理。  
    * 能够使用 [UIPasteboard](https://developer.apple.com/documentation/uikit/uipasteboard)  
    * 通过`playInputClick`方法来播放击键声音。  
    * 访问icloud，根据用户来保存键盘相关的设置，自定义校正词典等。  
    * 访问Game Center和通过容器App使用内购。  
    * 支持移动设备管理（MDM），与被管理的apps协同工作。  

> 使用完全访问功能时，请详细阅读 [Designing for User Trust](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html#//apple_ref/doc/uid/TP40014214-CH16-SW3)中的注意事项，确保对用户数据的尊重和保护。


