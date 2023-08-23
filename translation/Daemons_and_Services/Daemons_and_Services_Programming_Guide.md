#### 关于守护进程和服务  

## 原文
[Daemons and Services Programming Guide](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/Introduction.html#//apple_ref/doc/uid/10000172i)

在后台运行的继承可以有效高速的处理许多不需要用户交互的任务，可以使用守护进程或服务执行一下操作：   

* 提供服务器功能， 例如网页服务。 
* 协调对共享资源的访问(例如数据库)。  
* 执行前台程序的任务，例如文件系统访问。 

> __服务__： 以某种方式支持完整gui应用程序的后台进程。    
> __守护程序__： 引用所有其他类型的后台进程，尤其是那些不提供任何类型用户界面的后台进程。   



 
## 设计守护进程和服务   
创建后台进程时需要考虑的两个重要的设计原色时如何运行以及和其他进程之间的通信。   
这两个因素相互影响， 不同类型的后台进程具有不同的通信形式。   


### 后台进程的类型  

OS X 中有四种类型的后台进程，每种之间有细微的差别。 要选择适当的后台进程类型，通过以下原则：   
1. 是否对当前登录油壶或所有用户起作用   
2. 它蒋被单个应用程序使用还是被多个应用程序使用   
3. 它是否需要显示用户界面或启动GPU程序   


| Type      | Managed by launchd? |   Run in which context?(运行上下文)  | Can present UI?(是否会显示UI) |
| ----------------- | ----------- | ------------------------------| ----------------|    
| login items       |  否         |    用户                        ｜   是              ｜
| XPC               |  是         |    用户                        ｜   否(除非使用 IOSurface的方式)   ｜
|  Launch Daemons   |  是         ｜   系统                         ｜  否              ｜
| Launch Agents     |  是         ｜   用户                         ｜  不建议          ｜   


> Login Item 是根据每个用户的 launchd启动的， 但是 launchd 不回管理它们   



####  登录项 (Login items) 
在用户登录的时候启动没， 并继续运行直到用户注销或者手动退出它们。其主要的目的是允许用户自动打开经常使用的应用程序，但页可以由应用程序开发人员使用，例如： 登录项可用于额外注册显示菜单， 或注册全局热键。  

例如， 需要待办事项应用程序使用一个登录项， 该登录项侦听全局热键并显示和一个最小的UI, 允许 用户输入新任务，登录项通常还用于显示用户界面程序，例如： 计时器，或在菜单栏中显示图标。  


另一个示例是日历应用程序，其中启动了作为登录项的帮助程序应用程序。帮助器应用程序在后台运行，并在适当时启动主GUI应用程序，以提醒用户即将到来的约会。   




#### xpc 服务(XPC Services)  

XPC服务由`launchd`管理并为单个应用程序提供服务。它们通常用于蒋应用程序分为较小的部分。 如果进程崩溃，可以通过限制影响来提高可靠性， 如果应用受损， 可以通过限制影响来提高安全性。   


对于传统的单一可执行应用程序，如果程序的任意部分崩溃，则整个应用程序蒋终止。通过将应用程序重组为主进程和xpc服务，服务崩溃的影响将大大降低。
用户可以继续工作， 崩溃的服务将重新启动。例如： 电子邮件程序可以通过XPC 服务来处理与邮件服务器的通信。即使服务崩溃， 暂时中断与服务器的通信， 应用程序的其余部分仍将可用。   

沙箱可以可让你指定正常运行 期间执行的权限列表， 操作系统强制执行该列表，。以限制攻击者可能造成的损害。例如： 文本编辑器，可能需要编辑用户已打开的磁盘文件， 但可能不需要打开其他位置的任意文件或通过网络进行通信。  

可以将沙盒和XPC 服务结合使用。以将复杂的应用程序， 工具或守护进程拆分为任意有明确意义功能小块提供权限分离。由于每个组件的权限不同，攻击者无法充分利用任何缺陷：没有一个组件可以发挥用户所有功能。例如： 管理和编辑照片的应用通常不需要网络访问。但是，如果它还允许用户将照片上传到网上，则可以将该功能实现为XPC 服务。


#### 守护进程(Launch Daemons)  
启动进程是通过在系统上下文中代表操作系统启动的`launchd` 来管理， 这意味者它们不了解登录到系统的用户，守护进程无法直接主动与用户进程通信， 它只能被动响应用户进程的请求。因为它们不了解用户，因此无法访问窗口服务，因此无法发布可视界面或启动GUI应用程序。守护程序严格来说是响应低级请求的后台进程。   



大多数守护程序在系统的系统上下文中运行-也就是说，它们在系统的最低级别上运行，并使它们的服务可用于所有用户会话。  即使没有用户登录系统，此级别的守护程序仍继续运行，因此该守护程序程序应该没有用户的概念。
而且，守护程序必须等待用户程序与之联系并发出请求。作为该请求的一部分，用户程序通常告诉守护程序如何返回结果。   



#### 启动代理(Launch Agents)
由代表当前用户的`launchd`进行管理。可以在同一用户会话中与 其他进程通信。也可以在系统上下文中与系统范围的守护程序通信。他们可以显示可视界面，但是不建议这样做。    
如果您的代码同时提供了特定于用户的信息 和用户无关的服务，您可能要同时创建一个守护程序和一个代理。守护程序将在系统上下文中运行，并提供与用户无关的服务，而代理的实例将在每个用户会话中运行。代理将与守护程序协调以向每个用户提供服务。    



### 与守护进程通信的协议  
守护程序及其客户端之间通常使用四种主要的通信机制：  
* XPC  
* 传统的客户端-服务器通信（包括Apple事件，TCP / IP，UDP，其他套接字和管道机制）   
* 远程过程调用（包括Mach RPC，Sun RPC，和分布式对象）  
* 内存映射（在Core Graphics API中使用，以及其他）   


__XPC 是启动和与守护进程通信的最简单的方式__  

跨安全域边界进行通信时，应避免使用诸如分布式对象之类的其他RPC（远程过程调用）机制，例如，用户进程与系统级守护程序进行通信，因为这会带来安全风险。仅当您可以确定所涉及的两个进程具有相同的特权级别时，它们才适用。

在大多数其他情况下，应使用传统的客户端-服务器通信API。与RPC或内存映射设计相比，基于这些API的代码往往更易于理解，调试和维护。与基于RPC的代码相比，它也更易于移植到其他平台。   

内存映射需要复杂的管理，并且如果您对共享的内存页不小心或未充分验证共享数据，则会带来安全风险。仅当客户端和守护程序需要大量的共享状态且延迟时间很短（例如实时传递音频或视频）时，才应使用内存映射。




## 守护程序的生命周期  
OS X上的根进程为`launchd`（它替换了`mach_init` 和 `init` OS X早期版本和许多传统Unix系统中使用的进程）。 除了初始化系统外， `launchd`进程有序地协调系统守护程序的启动。与`inetd`过程类似，`launchd`按需启动守护程序。以这种方式启动的守护程序可以在不活动期间关闭，并根据需要重新启动。收到服务请求时，如果守护程序未运行，则`launchd`自动启动守护程序以处理请求。   

按需启动守护程序可以释放与守护程序相关的内存和其他资源，如果守护程序很可能长时间闲置，则这是值得的。但是，更重要的是，这保证了守护程序之间的运行时相关性得到满足，而无需手动列出相关性。(More importantly, however, this guarantees that runtime dependencies between daemons are satisfied without the need for manual lists of dependencies.)   


作为系统初始化的最后一部分，launchd启动loginwindow。该loginwindow程序控制用户会话的多个方面，并协调登录窗口的显示和用户身份验证。    


### 验证用户  
OS X 要求用户在访问系统之前进行身份验证。该`loginwindow`程序协调登录过程的可视部分（如用户输入名称和密码信息的窗口所示）和安全部分（处理用户身份验证）。用户通过身份验证后，`loginwindow`便开始设置用户环境。    

在两种关键情况下， `loginwindow`会绕过登录提示并立即开始用户会话：   
1. 当系统管理员将计算机配置为以指定用户身份自动登录时   
2. 在软件安装过程中，当重启后立即启动安装程序时   

### 配置用户会话  

用户成功通过身份验证后，立即loginwindow设置用户环境并记录有关登录的信息。  作为此过程的一部分，它执行以下任务：   
* 保护登录会话免受未经授权的远程访问。   
* 将登录记录在系统utmp和utmpx数据库中。  
* 设置控制台终端的所有者和权限。  
* 重置用户的首选项以包括全局系统默认值。  
* 使用用户的首选项配置鼠标，键盘和系统声音。  
* 设置用户的组权限（gid）。  
* 从目录服务中检索用户记录，并将该信息应用于会话。  
* 加载用户的计算环境（包括首选项，环境变量，设备和文件许可权，钥匙串访问等）。  
* 启动Dock，Finder和SystemUIServer。  
* 为用户启动登录项。  



一旦用户会话启动并运行，loginwindow就可以通过以下方式监视会话和用户应用程序：   
* 它管理注销，重新启动和关闭过程。  
* 它管理“强制退出”窗口，其中包括监视当前活动的应用程序以及响应用户请求以强制退出应用程序并重新启动Finder。



### 注销职责  
注销，重新启动系统或关闭系统的过程相似。典型的注销/重启/关机如下：  
1. 用户从Apple菜单中选择“注销”，“重新启动”或“关机”。  
2. 前台应用程序通过将Apple事件发送给来启动用户请求loginwindow。  
3. 该loginwindow程序向用户显示警报，要求确认操作。   
4. 如果用户确认该操作，则loginwindow退出每个前台和后台用户进程。  
5. 一旦退出所有进程，loginwindow结束用户会话并执行注销，重新启动或关闭。
    

### 终止流程  
作为注销、重新启动或关闭程序的一部分， `loginwindow`尝试终止所有前台和后台用户进程。   
您的进程应支持突然终止，以获得最佳用户体验。[NSProcessInfo Class Reference](https://developer.apple.com/documentation/foundation/processinfo)了解更多。如果您的进程支持突然终止，则只发送一个SIGKILL信号。如果您暂时禁用了突然终止，则 应用正常流程   
对于Cocoa应用程序，终止部分由应用程序框架处理，调用`applicationShouldTerminate:`委托方法。要禁止终止操作，需要实现此方法并返回`NSTerminateCancel`; 否则，您的应用程序正常终止。   

非cocoa应用程序收到 "退出应用" apple 事件(`kAEQuitApplication`),如果需要用户确认（例如，如果有未保存的文档），则该过程应立即终止或发布警报对话框。如果用户决定中止终止流程（例如，通过单击“保存”对话框中的“取消”），则应用程序应通过返回`userCanceledErr`错误（-128）来响应事件。   

如果前台应用程序在45秒后未能回复或自行终止，则`loginwindow`自动终止终止操作。此保护措施是为了在各种情况下保护数据，例如，当应用程序将大文件保存到磁盘并且无法在指定的时间内终止时。如果前台应用程序无响应且未执行任何操作，则用户必须使用“强制退出”窗口将其退出，然后再继续。    

对于后台进程，程序有所不同。该loginwindow程序通过向其发送Quit Application Apple事件（kAEQuitApplication）来通知进程即将终止。但是，与前台进程不同，loginwindow它不等待答复。无论是否返回任何错误，它都会通过发送`SIGKILL`信号来终止任何打开的后台进程。    


* 前台程序收到终止信号，会等待， 如果超时，不会终止  
* 后台进程收到终止信号， 不会等待，直接终止  

如果系统正在关闭或重新启动，它将向所有守护程序发送`SIGTERM`信号，然后在几秒钟后发出`SIGKILL`信号   





### 注销，重新启动或关闭


要以编程方式启动注销，重新启动或关闭序列，前台应用程序必须将适当的Apple事件发送到`loginwindow`, 收到事件后，`loginwindow`将开始关闭用户会话的过程。    
下表显示了注销，重新启动和关闭过程的首选Apple事件。这些事件没有必需的参数。   

* kAELogOut   
* kAEShowRestartDialog  
* kAEShowShutdownDialog    

除了首选的Apple事件外，还有两个其他事件告诉loginwindow您立即以重新启动或关闭：  

* kAERestart  
* kAEShutDown  


> 如果您将这些事件之一发送给loginwindow，则用户将没有机会取消该操作，并且未保存的数据可能会丢失。如果可以的话，尽量避免使用这些事件。   




## 添加登录项  
有两种添加登录项的方式：  
* 使用服务管理框架     
    使用此种方式安装的登录项在“系统偏好设置”中不可见， 并且只能由安装它们的应用程序删除   

* 使用共享文件列表   
    使用此种方式安装的登录项， 在“系统偏好设置”中可见，用户可以直接控制它们。 如果使用此API。则用户可以禁用您的登录项，因此与之通信的任何其他应用程序都应具有合理的后备行为，以防登录项被禁用。  

### 使用服务管理框架添加登录项   
应用程序可以将帮助程序作为完整的应用程序包，存储在`/Contents/Library/LoginItems` 目录中。    
在帮助程序的·`Info.plist`文件中设置`LSUIElement`或`LSBackgroundOnly`键。      
使用`SMLoginItemSetEnabled`功能来设置开机自启操作，它有两个参数， 一个是`CFStringRef`类型的应用程序 bundle id, 另一个是bool 类型，指定所需的状态。传递`true`以立即启动应用程序，并指示每次用户登录时应将其启动.传递`false`以终止应用程序，并指示在用户登录时不再启动该应用程序。此功能可用于管理任意数量的应用程序。   



### 使用共享文件列表添加登录启动项   
此方式在 10.5 和更高的版本可用。 详细可[Launch Services Reference.](https://developer.apple.com/documentation/coreservices/launch_services)      




#### 过期   API  
在OS X的早期版本中，可以通过`CFPreferences API`发送Apple事件以及手动编辑属性列表文件来添加登录项。这些方法已被弃用。   
如果您需要保持与v10.5之前的OS X版本的兼容性，则首选方法是使用Apple事件。 详细的可参考[LoginItemsAE](https://developer.apple.com/library/archive/samplecode/LoginItemsAE/Introduction/Intro.html#//apple_ref/doc/uid/DTS10003788)   
不应该在任何版本的OS X上直接编辑属性列表文件。    



## 创建 XPC 服务  
XPSystems API是libSystem的一部分， 基于 GCD 和 launchd 提供了一种轻量级的进程间通信技术。XPC Services API允许您创建称为XPC服务的轻量级帮助程序，它​​们可以代表您的应用程序执行工作。

使用XPC服务的主要原因有两个：特权分离和稳定性  

#### 特权分离  




#### 稳定性  





## 创建守护进程和代理 
如果要开发 OSX 上运行的守护进程， 强烈建议设计基于 launchd 标准的守护进程。 使用launchd可以为守护程序提供更好的性能和灵活性。它还提高了管理员管理在给定系统上运行的守护程序的能力。   

要为 OS X 上每个用户创建后台进程， launchd则也是启动这些进程的首选方法。这些个用户进程称为用户代理。用户代理在本质上与守护程序相同，但特定于给定的登录用户，并且仅在该用户登录时执行。   


除非另有说明，在本章中，术语“守护程序”和“代理”可以互换使用。本节中通常使用术语“守护程序”来涵盖系统级守护程序和用户代理。   

`launchd`有四种方法可以启动守护进程, 首选方式是按需启动，但是launchd可以启动连续运行的守护程序，并且可以替换inetd来启动inetd样式的守护程序另外， launchd 可以启动定时任务   

尽管 launchd 支持非按需启动守护程序， 但不建议这样使用。Launchd守护程序旨在消除守护程序之间的依赖关系。如果不让守护程序按需启动，则必须以其他方式（例如，使用旧版启动项机制）处理这些依赖项。


### 使用launchd启动自定义守护程序  
随着 launchd 在 OS X 10.4 中推出，努力改进了启动和维护守护程序所需的步骤。launchd 提供了 根据需要启动守护程序 的功能。对于客户端程序，代表守护程序服务的端口始终可用，并可以处理请求。实际上，守护程序可能正在运行或可能未运行。  
当客户端向端口发送请求时，launchd可能必须启动守护程序才能使其处理请求。启动后，守护程序可以继续运行或自行关闭以释放其所持有的内存和资源。如果守护程序自身关闭，launchd则根据需要再次重新启动它以处理请求。



除了按需启动功能之外，launchd还为守护程序开发人员提供了以下好处：
* 通过封装与守护程序相关的许多标准操作，简化了创建守护程序的过程   
* 为系统管理员提供集中位置来管理系统上的守护程序。   
* 支持inetd-style守护程序。  
* 取消了以root 身份运行守护进程，launchd是以root身份运行的，它可以创建低等级的 TCP/IP Socket并将其交给其他守护进程   
* 简化了后台程序之间通信的错误处理和依赖性管理。守护程序是按需启动的，所以如果守护程序未启动，则通信请求不会失败，延迟到守护进程可以启动和处理它们为止       

### 启动过程  
引导系统并运行内核后， launchd 运行以完成系统初始化。 作为该初始化的一部分， 它需要执行以下步骤：  
1. 从`/System/Labrary/LaunchDaemons/`和 `/Labrary/LaunchDaemons/`中找到启动守护进程的参数   
2. 注册守护进程使用的socket 和文件描述符   
3. 启动所有一直要求运行的守护程序   
4. 当特定服务的请求到达时，它将启动相应的守护程序并将请求传递给它。   
5. 当系统关闭时，它将向启动的所有守护程序发送`SIGTERM`信号。   



每个用户代理的过程类似， 用户登录是，launchd 按用户启动，将执行以下步骤：  
1. 从`/System/Library/LaunchAgents`, `/Library/LaunchAgents`和个人的 `Library/LaunchAgents` 目录中找到启动守护进程的参数   
2. 注册守护进程使用的socket 和文件描述符      
3. 它启动所有一直要求运行的用户代理。   
4. 当对特定服务的请求到达时，它将启动相应的用户代理并将请求传递给它。  
5. 当用户注销时，它将向启动的所有守护程序发送`SIGTERM`信号。      

因为 launchd 在启动所有守护进程之前，注册了应用到的所有socket 和文件描述符，所以可以按照任意启动顺序启动。如果收到尚未运行的守护进程请求， 则请求将会被挂起，直到目标守护进程完成启动作出响应。   

如果守护程序在特定时间段内未收到任何请求， 则它可以选择关闭自身并释放其所拥有的资源。发生这种情况时， launchd 会记下，将来的请求到达时，在此启动守护进程。  

> 如果守护程序在启动后关闭的太快， launchd 可能认为它已经崩溃。则此守护进程将会被挂起，并且在以后的请求到来时，不会再次启动。 为避免此现象， 启动后吧至少 10 秒钟请勿关闭。




### 创建启动 plist 文件  
要基于 launchd启动， 必须为守护进程提供一个配置文件。该文件包含有关守护程序的信息，包括用于处理请求的套接字或文件描述符的列表。通过在属性列表文件中指定此信息，launchd可以注册相应的文件描述符，并仅在对当前守护程序请求到达后启动守护程序。   

守护程序和代理的属性列表文件的结构相同。通过放置的目录不同来指定它是代理还是守护进程。__守护进程的属性列表文件安装在`/Library/LaunchDaemons`中，代理的属性列表文件安装在单个用户的` /Library/LaunchAgents` 目录或 单个用户的`Library`目录下的`LaunchAgents` 的子目录下。  



__必须和推荐的属性列表键__  

| type | 描述 |
| --- | ----------- |
| label | 包含一个唯一字符串，该字符串将 launchd 通过此字符串识别守护进程(必须) |
| ProgramArguments | 用于启动守护程序的参数。（需要） |    
| inetdCompatibility | | 
|  KeepAlive        | 此项指定守护程序是按需启动还是必须始终运行。建议您将守护程序设计为按需启动。|


> 有关key 的完整列表， 参考[lalunchd.plist]()   
> `/System/Library/LaunchDaemons/`:这些文件用于配置许多的OS X上运行的守护程序   



### 示例  

```xml 
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.hello</string>
    <key>ProgramArguments</key>
    <array>
        <string>hello</string>
        <string>world</string>
    </array>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>

```

### 监听socket  
还可以在配置属性列表文件中包括其他键。例如，如果守护程序监视一个知名端口(`/etc/services`端口之一)添加一个Sockets条目，如下所示：  

```xml
<key>Sockets</key>
<dict>
    <key>Listeners</key>
    <dict>
        <key>SockServiceName</key>
        <string>bootps</string>
        <key>SockType</key>
        <string>dgram</string>
        <key>SockFamily</key>
        <string>IPv4</string>
    </dict>
</dict>

```

SockServiceName 字符串通常来自 `/etc/services`。这个 `SockType` 的值是 dgram (UDP) 或 stream (TCP/IP)。如果您需要传递未在知名端口列表中列出的端口号，则格式是相同的，只是字符串包含数字而不是名称. 例如：  

```xml 
<key>SockServiceName</key>
<string>23</string>
```  



### 调试启动任务  
有些选项可用于调试已启动的守护进程  

以下示例启用核心转储，将标准输出和错误设置为进入日志文件，并指示launchd临时增加其日志记录的调试级别 (记得相应的调整 syslog.conf)    

```xml 
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.sleep</string>
    <key>ProgramArguments</key>
    <array>
        <string>sleep</string>
        <string>100</string>
    </array>
    <key>StandardOutPath</key>
    <string>/var/log/myjob.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/myjob.log</string>
    <key>Debug</key>
    <true/>
    <key>SoftResourceLimits</key>
    <dict>
        <key>Core</key>
        <integer>9223372036854775807</integer>
    </dict>
    <key>HardResourceLimits</key>
    <dict>
        <key>Core</key>
        <integer>9223372036854775807</integer>
    </dict>
</dict>
</plist>

```



### 启动一个定时任务  
以下示例创建一个每五分钟（300秒）运行一次的作业：  

```xml  
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.touchsomefile</string>
    <key>ProgramArguments</key>
    <array>
        <string>touch</string>
        <string>/tmp/helloworld</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
</dict>
</plist>


```

或者，可以指定基于日历的间隔。下示例在每月的7号13:45（下午1:45）开始工作。像Unix cron子系统一样，`StartCalendarInterval`字典中所有省略的键都被视为通配符-在这种情况下，省略了月份，因此该job每月运行一次。   

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.touchsomefile</string>
    <key>ProgramArguments</key>
    <array>
        <string>touch</string>
        <string>/tmp/helloworld</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Minute</key>
        <integer>45</integer>
        <key>Hour</key>
        <integer>13</integer>
        <key>Day</key>
        <integer>7</integer>
    </dict>
</dict>
</plist>

```


### 监控目录  
以下示例在目录发生变化，便开始工作  

```xml 
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.watchhostconfig</string>
    <key>ProgramArguments</key>
    <array>
        <string>syslog</string>
        <string>-s</string>
        <string>-l</string>
        <string>notice</string>
        <string>somebody touched /etc/hostconfig</string>
    </array>
    <key>WatchPaths</key>
    <array>
        <string>/etc/hostconfig</string>
    </array>
</dict>
</plist>
```

只要给定目录为非空目录，launchd守护程序就会启动job，保持为运行状态    

```xml 

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.mailpush</string>
    <key>ProgramArguments</key>
    <array>
        <string>my_custom_mail_push_tool</string>
    </array>
    <key>QueueDirectories</key>
    <array>
        <string>/var/spool/mymailqdir</string>
    </array>
</dict>
</plist>



```
