
# TV 开发引导 


## 开发方式选择 
#### TVML Apps
这类应用是使用完整的新开发技术开发的，比如TVML、TVJS、TVMLKit, 采用的是 `Server-Client` 开发模式


从储存在您服务器上的 XML 模板、JavaScript 代码和其他内容动态构建您的 UI。如果您经常更新 App 的内容，这将尤其有用。例如，在每周更新当前影片排行的媒体 App 中，您就可以采取这种方式。您的 App 在运行时下载内容，并合成您的界面。 


* 关键技术 
    * TVML： 是一种XML格式，基于“Television Markup Language”。
    * TVJS： 是基于JavaScript APIs的脚本语言，它可以根据TVML中定义的内容展示应用。
    * TVMLKit： 是连接TVML、TVJS和原生tvOS应用的工具包。 

#### Custom Apps
这类应用是使用我们已经比较熟悉的开发技术进行开发的，比如大家熟知的一些iOS框架和特性，像Storyboard、UIKit、Auto Layout等
如果您的内容在不同版本之间没有显著变化，请利用 Apple tvOS 中的按钮、文本标签以及其他标准视图和控件构建您的 UI。自定控件的外观或创建全新的视图，以独特的方式展示您的内容。您的 UI 会保留在 Apple TV 本地，并将从本地或网络获取的数据填充到界面中。 


__两种方式没有孰优孰劣之分__ 

#### 完全绘制 
全面掌控您 App 的外观，亲自绘制屏幕上显示的一切。使用自定 2D 或 3D 环境，创建游戏或沉浸式体验。利用 Metal 等技术，以高帧率渲染您的内容并制作动画。




### 选择参考 
* __TVML App__： 如果你主要是通过tvOS应用展现一些内容，不论是音频、视频、文本、图片，并且你已经有服务器存储这些资源。那么使用TVML开发是不错的选择。

* __Custom App__: 如果你希望用户不只是被动的通过你的tvOS应用观看或收听内容，而是希望用户与应用有更多的交互，给用户高质量的用户体验。那么你应该选择使用iOS的相关技术开发自定义的应用。




## 挑选 App 构建技术

### SwiftUI 

SwiftUI 是首选的 App 构建器技术，因为它为构建 UI 和 App 基础架构提供了一种与平台无关的现代方法。通过使用 SwiftUI，您能够以编程方式指定界面，并让系统动态显示和更新这个界面


### TVML 和 TVMLKit 

TVML 和 TVMLKit 提供一种客户端加服务器模型来构建 App 的 UI。使用 TV 标记语言 (TVML)，将您的 UI 定义为一组 XML 模板页面。将这些页面和您用来创建 UI 的 JavaScript 代码储存到您的服务器上，并在运行时下载到您的 App 中。使用 TVMLKit 在屏幕上渲染这些页面，并使用 SwiftUI 或 UIKit 来实现 App 的其余基础架构

[利用 TVMLKit 实现混合型 TV App](https://developer.apple.com/documentation/tvmlkit/implementing_a_hybrid_tv_app_with_tvmlkit)

### TVUIKit 和 UIKit

TVUIKit 和 UIKit 提供一个对象库，供您用于构建 App 的 UI 和基础架构。利用 Storyboard 以可视化方式或在代码中以编程方式，合成您在屏幕上显示的视图以及不同视图集合之间的导航. TVUIKit 提供了 Apple tvOS 专用视图，而 UIKit 则提供了按钮和标签等通用视图，以及 App 的其余基础架构

[利用全屏布局打造引人入胜的体验](https://developer.apple.com/documentation/tvuikit/creating_immersive_experiences_using_a_fullscreen_layout)


## TVServices 
TVServices的主要作用是描述你的应用的内容，以便tvOS在首页的顶部栏位显示。在首页顶部栏位显示的应用都是用户自己设置的，用户可以将他们认为最为常用的或最为重要的应用放在首页顶部栏位，便于快速打开或浏览其中主要信息。应用可以在用户不进入应用的情况下，向用户提供简短的、感兴趣的信息，这就会使你的应用有了额外价值，使用TVServices无疑是提高你的应用下载量的绝佳手段。比如一个游戏应用，通过TVServices显示游戏存档，那么用户就可以直接从首页通过游戏存档进入游戏。如果是一个社交应用，那么就可以在首页显示社交动态信息，如果是一个照片分享应用，那么就可以显示近期朋友和家人分享的照片。  


## Parallax Images 

当移动聚焦视图时，你需要向左或向右滑动，但如果你只滑动了一点，Apple会对当前聚焦的视图做一个轻微的旋转处理，目的是让用户知道现在正在作以操作（但是还需要继续滑动来改变聚焦视图）。这是一个着眼于细节但又非常有用的特性。

[Creating Parallax Artwork](https://developer.apple.com/library/prerelease/tvos/documentation/General/Conceptual/AppleTV_PG/CreatingParallaxArtwork.html#//apple_ref/doc/uid/TP40015241-CH19-SW1)


## Controllers 
* 玻璃触控板：位于遥控器的顶部，可以让用户在其上面进行一些手势操作，比如滑动、轻拍、点击。
* 麦克风：可以让用户通过遥控器访问Siri（Siri有使用国家的限制）以及可以通过语音控制电视的音量 
* 陀螺仪：结合动作传感器可以为用户提供非常棒的游戏体验。用户可以通过倾斜遥控器在游戏中控制方向盘开车，或者控制英雄奔跑穿越山洞。 


[Nimbus Steelseries Controller](https://steelseries.com/gaming-controllers/nimbus)
[Working with Game Controllers](https://developer.apple.com/library/prerelease/tvos/documentation/General/Conceptual/AppleTV_PG/WorkingwithGameControllers.html#//apple_ref/doc/uid/TP40015241-CH18-SW1)




## tvOS and Games

Zombie Conga



## Limitations

###  Local Storage 
关于本地存储，基本确定是没有！如果你的应用需要持久化用户的数据，那么你需要使用iCloud、CloudKit或者自己的备份服务去实现。任何试图存在Apple TV中的数据都不保证在下次打开应用时还嫩存在。如果你想同步不同设置之间的数据，那么你就需要将数据线存在某个地方，但绝不是Apple TV中。


* 如果你需要存储的数据量小于1MB，iCloud的key-value存储方式是一个可以选择的方案。但是要切记，iCloud KVS严格限制了只能有所属者才可以访问数据，并且不能共享给其他用户。
* 如果你需要分享事件或者数据给其他用户，CloudKit是一个不错的选择方案。
* 如果你开发的是一个跨平台的应用或者有特殊的需求，你就得使用你自己的备份服务了。

### Limitation: App Size
关于应用大小的限制，规定不能超过200MB。 


`On-Demand Resources`




## 更进一步
### 简化 App 的登录过程 

采用[系统登录界面](https://developer.apple.com/videos/play/wwdc2021/10279/)，允许用户使用关联了同一 Apple ID 的 iPhone 或 iPad 来登录您的 Apple tvOS App。通过采用[多用户支持](https://developer.apple.com/documentation/tvservices/mapping_apple_tv_users_to_app_profiles) 来简化选择 App 相关用户个人资料的过程，让用户更快看到他们的内容。


### 允许用户从其他设备连接 
允许用户从 iPhone、iPad 或 Apple Watch 与您的 Apple tvOS App 交互。利用 [DeviceDiscoveryUI](https://developer.apple.com/documentation/devicediscoveryui) 在运行您的 App 的两台设备之间创建安全网络连接，并使用这个连接来交换数据。例如，您可以允许用户使用 iPhone 上的触控输入来控制您的 Apple tvOS App。


### 在 Top Shelf 中展示您的内容 
在 Apple TV 主屏幕中，App 的顶行可以在紧邻其上方的横幅区域中显示更多内容。利用 Top Shelf App 扩展将这些内容提供给系统，它是您可以包含到 App 中的独立可执行文件。利用您的扩展来突出显示新鲜或精选内容，或者显示用户收藏的节目。如需有关如何创建这一扩展的信息，请查看[TV 服务](https://developer.apple.com/documentation/tvservices)。



### 允许用户利用“同播共享”来共享活动 
同播共享”可邀请用户通过 FaceTime 通话来共享您 App 的活动。通过这一功能，在您的流媒体视频 App 中实现观影之夜，或将比赛之夜转变为可供观赏的体育赛事。定义您想要通过 [Group Activities](https://developer.apple.com/cn/documentation/GroupActivities) 共享的活动。利用 [AVFoundation](https://developer.apple.com/documentation/avfoundation) 同步媒体播放。



### 采集实时音视频进行广播 

分享内容还有一种方式，即采集实时音视频并储存为录像/录音或进行现场直播。为游戏或其他 App 添加这一支持，方便用户通过电子邮件、信息或社交媒体分享他们的体验。如需更多信息，请查看 [ReplayKit](https://developer.apple.com/documentation/replaykit)。



### 简化查找相关内容的过程 

思考用户会如何使用您的 App，想办法快速呈现重要的内容。使用日期与时间信息来突出显示新的或当前的内容。使用机器学习分析数据，提供更优秀的解决方案。动态调整您的界面布局，让常用内容更加便于访问。

 


### 支持 App 内容的通用链接 

如果您的网站和 App 提供类似的内容，请给您的 App 添加通用链接支持。借助通用链接，您不必为打开 App 中的内容而创建单独的 URL。只需一个 URL，就能打开您的 App (若已安装) 或您的网站 (若未安装 App)。如需更多信息，请查看“允许 App 和网站链接您的内容”。


## 参考 
* [Beginning tvOS Development with TVML Tutorial](http://www.raywenderlich.com/114886/beginning-tvos-development-with-tvml-tutorial)
* [为 Apple TV 开发 tvOS App](https://swift.gg/2015/09/14/developing-tvos-apps-for-apple-tv-with-swift/) 
* [詹姆森奎夫](https://jamesonquave.com/blog/)
* [规划您的 Apple tvOS App](https://developer.apple.com/cn/tvos/planning/)