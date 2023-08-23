# Apple TV 用户交互 

## Focus Engine
tvOS 采用一种独特的交互引擎 `Focus Engine`, 它在整个tvOS中有且只有一个. 该引擎负责响应当用户使用遥控器上的手势操作或按键操作对菜单或内容进行上下左右的选择。

Focus Engine会自动根据用户的选择决定要聚焦或展示的视图，你不需要在代码中做任何类似选中或导航的处理。比如说，此时展示的界面是你已经在Storyboard中设计好的视图布局，其中有一个视图是当前聚焦状态，那么当用户通过手势往右滑动时，Focus Engine会自动根据当前聚焦的视图找到与之相邻的左边的视图，并将其选中和聚焦。


















## 参考 
* [ Supporting Focus Within Your App](https://developer.apple.com/library/prerelease/tvos/documentation/General/Conceptual/AppleTV_PG/WorkingwiththeAppleTVRemote.html#//apple_ref/doc/uid/TP40015241-CH5-SW14) . 

