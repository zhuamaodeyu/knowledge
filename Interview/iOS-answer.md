

## Objective-C   
1. 为什么说Objective-C是一门动态的语言？  
    oc 是c 语言的超集， 在c 上添加了面向对象支持，并且添加了runtime运行时机制为其提供动态性，其可以再程序运行时进行动态添加变量，方法，类以及方法调用等,oc 的动态性主要体现在3个方面： 
    * 动态类型：ID类型，可以再运行期再决定具体的类型  
    * 动态绑定：代码在编译器并不知道具体的要调用的方法， oc 是采用发送消息的方法实现方法调用的，并不是在编译器进行链接  
    * 动态载入：在运行期加载代码模块和资源。比如运行期添加属性，方法等  

2. KVO 的原理是什么？？如何自己动手实现KVO？？    
    KVO: 是一种观察模式的实现，通过KVO实现对一个属性的监听。






## RunLoop  
1. 对 RunLoop 的理解？    
    一般来说，一个线程只能执行一个任务，当任务执行完毕的时候，线程就会被销毁掉。可以通过一种方式来使线程执行完毕但并不会被销毁，而是出于休眠状态以保持线程存活的同时降低性能消耗。RunLoop 是oc 中的实现方式，其主要功能关键点在于： 如果管理事件/消息？ 如果在没有消息处理的时候让线程出于休眠状态以降低资源占用？ 如果在有消息来的时候唤醒？RunLoop 其实是一个对象，主要负责处理事件和消息
2. runloop和线程有什么关系？主线程默认开启了runloop么？子线程呢？
     在iOS开发中，由于其内核等历史原因， 可以遇到两种线程， `pthread_t`,`NSThread`, CFRunLoop 是基于 pthread 来管理的, 在iOS中每个线程都有一个 RunLoop 对象，主要用来实现以上功能，主线程的RunLoop 是默认开启的，用来处理UI 事件或系统事件，子线程默认是不开启的，可以在需要使用的时候手动开启  
3. runloop在开发中的使用？如何开启一个runloop？    
    ```
        // 创建线程
       self.thread = Thread.init(target: self, selector: #selector(runloopAction), object: nil)
        self.thread?.name = "upload_data"
        self.thread?.start()  

        // 开启 runloop
        @objc fileprivate func runloopAction() {
        autoreleasepool {
            let runloop = RunLoop.current
            runloop.add(NSMachPort.init(), forMode: RunLoopMode.commonModes)
            runloop.run()
        }   

        // 执行任务
        if let t = self.thread {
             self.perform(#selector(threadAction), on: t, with: nil, waitUntilDone: false)
        }  
    ```

4. runloop实现原理是什么？？  源码解析实现原理是什么？？？



5. runloop的mode是用来做什么的？有几种mode？