# iOS 常见面试题总结 

## IM  

1. socket是什么？
2. socket原理是什么？
3. socket的作用是什么？
4. 如何保证udp协议下的消息发送成功？  
5. 即时通讯中使用UDP 与TCP 的区别以及优缺点？    
6. TCP协议原理？  
7. TCP 协议是什么？  
8. HTTP原理？  
9. HTTP 是什么？  
10. 即时通讯中如何处理丢包的问题？  
11. 如何保证断线重连？  
12. 断线重连的几种不同机制以及其优缺点？？？
13. 如何保证消息的及时到达？   
14. 如何保证消息不重复发送？？？
15. 如何保证离线消息准时并及时不丢失的送达？？   


## block   

1. block的原理是什么？？  
2. block在Objective-c中的内部是什么组成样式？？？  
3. block的两种使用形式？？  
4. block与delegate的优缺点？？？  
5. 在什么情况下使用代理好以及在什么情况下使用block更优???   
6. block的实质是什么？一共有几种block？都是什么情况下生成的？
7. 为什么在默认情况下无法修改被block捕获的变量？ __block,__weak、__strong都做了什么？
8. 模拟一下循环引用的一个情况？block实现界面反向传值如何实现？



 
## 多线程  

1.  GCD 是什么？？？  
2.  GCD 原理是什么？？  
3.  GCD 主要是为了解决什么问题？？？  
4.  GCD 都有哪些特点？？？ 
5.  GCD 一般的几种典型的用途？？  
6.  iOS中多线程的几种解决方案？？  
7.  在进行多线程资源抢夺时，如果两个线程同事访问一个可变变量，加1 ，访问10000此，最后结果是多少？？  
8.  原子性与非原子性的区别？   
9.  iOS中如何保证线程安全以及线程安全的几种解决方案？？？  
10. 如何解决在字典等对象中插入nil的解决方案？？   
11. iOS 中如何保证程序的数据安全？？？？  
12. 多线程中同步方式有哪些？
13. 如何实现多任务的统一下载并合并处理？？？   
14. 进程和线程的区别？同步异步的区别？并行和并发的区别？
15. 线程间通信？
16. GCD的一些常用的函数？（group，barrier，信号量，线程同步）
17. 如何使用队列来避免资源抢夺？




## Objective-C 

1. 为什么说Objective-C是一门动态的语言？
2. KVO 的原理是什么？？如何自己动手实现KVO？？  
3.  如何解决iOS中的事件冲突问题？？？
4.  strong、weak、unsafe_unretained 这三个修饰符分别是什么？
5.  performSelector为什么会内存泄漏？
6.  如何对真机的crash日志进行分析？
7.  对象回收时Weak指针自动被置为nil的实现原理？
8.  常见的持久化实现方法？
9.  KVO的使用？实现原理？（为什么要创建子类来实现）
10. KVC的使用？实现原理？（KVC拿到key以后，是如何赋值的？知不知道集合操作符，能不能访问私有属性，能不能直接访问_ivar）
11. KVO 与 Notification的区别？？？  
12. 为什么代理要用weak？代理的delegate和dataSource有什么区别？block和代理的区别?
13. 属性的实质是什么？包括哪几个部分？属性默认的关键字都有哪些？@dynamic关键字和@synthesize关键字是用来做什么的？
14. 属性的默认关键字是什么？
15. NSString为什么要用copy关键字，如果用strong会有什么问题？
16. NSMutableArray 可不可以使用 copy 关键字修饰？？  
17. 如何令自己所写的对象具有拷贝功能?
18. 可变集合类 和 不可变集合类的 copy 和 mutablecopy有什么区别？如果是集合是内容复制的话，集合里面的元素也是内容复制么？
19. 为什么IBOutlet修饰的UIView也适用weak关键字？
20. nonatomic和atomic的区别？atomic是绝对的线程安全么？为什么？如果不是，那应该如何实现？
21. 分类和扩展的区别？有什么区别？   


## 内存管理

1. objc使用什么机制管理对象内存？


## swift
1. swift 与oc 的区别？ 为什么说swift 更安全
2. swift 实现 方法交换的方式？   




## 图像以及动画  

1. 动画中的图层树、逻辑树、动画树、显示树分别是什么？
2. GPUImage的滤镜链优化



## 架构  

1. iOS开发中典型的几种架构是什么？？？以及其优缺点？？？ 
2. iOS开发中如何实现组件化开发???
3. APP的生命周期（应用程序的状态）有哪些？ 
2. 讲一下MVC和MVVM，MVP？
19. NSCache优于NSDictionary的几点？



## UI

11. UICollectionView自定义layout如何实现？
12. 用StoryBoard开发界面有什么弊端？如何避免？






17. 数据持久化的几个方案（fmdb用没用过）
18. 说一下AppDelegate的几个方法？从后台到前台调用了哪些方法？第一次启动调用了哪些方法？从前台到后台调用了哪些方法？
20. 知不知道Designated Initializer？使用它的时候有什么需要注意的问题？
21. 实现description方法能取到什么效果？



## Runtime 

1. iOS中的Method Swizzling 和 AOP ？？？ 
2. iOS runtime的一些典型应用是什么？？
3. objc在向一个对象发送消息时，发生了什么？
4. 什么时候会报unrecognized selector错误？iOS有哪些机制来避免走到这一步？
5. 能否向编译后得到的类中增加实例变量？能否向运行时创建的类中添加实例变量？为什么？
6. runtime如何实现weak变量的自动置nil？
7. 给类添加一个属性后，在类结构体里哪些元素会发生变化？

## RunLoop 

1. 对RunLoop的理解？  
2. runloop和线程有什么关系？主线程默认开启了runloop么？子线程呢？
3. runloop在开发中的使用？如何开启一个runloop？  
4. runloop实现原理是什么？？  源码解析实现原理是什么？？？  
5. runloop的mode是用来做什么的？有几种mode？
6. 为什么把NSTimer对象以NSDefaultRunLoopMode（kCFRunLoopDefaultMode）添加到主运行循环以后，滑动scrollview的时候NSTimer却不动了？
7. 苹果是如何实现Autorelease Pool的？


## 类结构   

35. isa指针？（对象的isa，类对象的isa，元类的isa都要说）
36. 类方法和实例方法有什么区别？
37. 介绍一下分类，能用分类做什么？内部是如何实现的？它为什么会覆盖掉原来的方法？
38. 运行时能增加成员变量么？能增加属性么？如果能，如何增加？如果不能，为什么？
39. objc中向一个nil对象发送消息将会发生什么？（返回值是对象，是标量，结构体）




## 性能优化  

40. UITableview的优化方法（缓存高度，异步绘制，减少层级，hide，避免离屏渲染）
41. 有没有用过运行时，用它都能做什么？（交换方法，创建类，给新创建的类增加方法，改变isa指针）
42. 看过哪些第三方框架的源码？都是如何实现的？（如果没有，问一下多图下载的设计）
43. SDWebImage的缓存策略？
44. AFN为什么添加一条常驻线程？
11. 如何对程序进行优化？？？  
12. 解决离屏渲染的几种方式 ？？？  
10. 如何统计线上的卡顿问题？？  
9.  如何捕捉崩溃信息？？？  
15. 代码质量以及内存泄露排查
  
16. UITableView性能优化几种方式以及其优缺点和实现原理？？   







## 性能优化单独模块    

1. 如何检测内存泄漏？？  
2. 如何检测循环引用？？？  
3. 如何监测动画执行效率？？？ 
4. 如何检测内存使用情况？？？  
5. 如何检测网络环境，以及在若网络下的使用？？？  
6. 如何检测代码执行效率？？？  

## 单独模块   

1. iOS的runtime
2. 性能优化
3. 动画树
4. 图形学
5. 算法
6. OpenGL ES
7. GPUImage
8. leetcode算法题目
9. 网络原理
10. 多线程






## 免责声明  
以上部分问题及答案来自网络，因长期收集， 先整理时已无法找到原作者， 此处如有侵权，望告知