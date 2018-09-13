#Status Bar  
![20180726153259393652234.png](http://ozjlhf9e0.bkt.clouddn.com/20180726153259393652234.png)
状态栏是Mac系统中很重要的部分，其和window系统底部状态栏意义相同。此部分一直是各种APP必争之地。虽然看似占比不大，但是确实系统不可或缺的一部分。通常，每个应用程序都可在status创建一个属于自己的item来给予用户便捷操作。虽然statusbar 意义重大，但在系统中与此相关的类却不多。只有一下三个类：`NSStatusBar`, `NSStatusItem`,`NSStatusBarButton`   


## NSStatusBar  
`NSStatusBar` 状态栏，此对象时一个单利对象，只能通过`systemStatusBar`方法来获取。此对象非常简单，只有两个方法以及两个只读属性：  
* `statusItemWithLength:`通过此方法来获取一个`NSStatusItem`对象  
* `removeStatusItem`: 将一个item从`NSStatusBar`中删除  
* `vertical`: 此只读属相代表了`NSStatusBar` 的方向，默认是NO, 水平方向的  
* `thickness`: Mac系统中 `NSStatusBar` 的高度是固定的， 此值就是高度，默认是 20   

## NSStatusItem  
此类是显示在 状态栏中的每个元素


## NSStatusBarButton  
此类是一个继承自`NSButton`的类，是一个普通的button类，主要负责 item 在状态栏中的样式以及事件行为。  


