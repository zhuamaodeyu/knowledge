# RunLoop 源码分析  


## 前言 
在刚接触iOS开发之时，常常有个疑为，为什么iOS的应用执行后不会退出，为什么和普通的应用不同，它到底是如何维持它一直运转下去并且还不会造成cpu 资源浪费的？ 接下来一起来探究下内部原理  

### Runloop 
RunLoop是与线程息息相关的基本基础结构的一部分。RunLoop是一个调度任务和处理任务的事件循环。RunLoop的目的是为了在有工作的时让线程忙起来，而在没工作时让线程进入睡眠状态。  

RunLoop管理并不是完全自动的。需要设计一个线程在合适的时机启动并响应传入的事件，您仍然必须设计线程的代码以在适当的时候启动运行循环并响应传入的事件。 Cocoa和Core Foundation都提供RunLoop对象，以帮助配置和管理线程的RunLoop。应用程序并不需要显式创建这些对象。每个线程（包括应用程序的主线程）都有一个关联的RunLoop对象。但是，在子线程中需要显式地运行RunLoop。在应用程序启动过程中，应用程序框架会自动在主线程上设置并运行RunLoop。

总结下： 
1. RunLoop和线程是绑定在一起的，每条线程都有唯一一个与之对应的RunLoop对象。  
2. 不能自己创建RunLoop对象，但是可以获取系统提供的RunLoop对象。  
3. 主线程的RunLoop对象是由系统自动创建好的，在应用程序启动的时候会自动完成启动，而子线程中的RunLoop对象需要我们手动获取并启动。  


## 源码解析(swift版)  
```swift

open class RunLoop: NSObject {
    internal var _cfRunLoop : CFRunLoop!
    internal static var _mainRunLoop : RunLoop = {
        return RunLoop(cfObject: CFRunLoopGetMain())
    }()

    internal init(cfObject : CFRunLoop) {
        _cfRunLoop = cfObject
    }

    open class var current: RunLoop {
        return _CFRunLoopGet2(CFRunLoopGetCurrent()) as! RunLoop
    }

    open class var main: RunLoop {
        return _CFRunLoopGet2(CFRunLoopGetMain()) as! RunLoop
    }

    open var currentMode: RunLoop.Mode? {
        if let mode = CFRunLoopCopyCurrentMode(_cfRunLoop) {
            return RunLoop.Mode(mode._swiftObject)
        } else {
            return nil
        }
    }
}
```
> runloop 在 foundation 层，其实是一个继承自 `NSObject` 的对象，其内部runloop核心部分还是对 Core Foundation 层的 `CFRunLoop` 的封装。   

既然 核心还是在`CFRunLoop`那么我们就直接找到 `CFRunLoop`， 以下是 `CFRunLoop` 的定义及相关内容和方法：  


```c
// 定义 各种类型
typedef CFStringRef CFRunLoopMode CF_EXTENSIBLE_STRING_ENUM;

typedef struct CF_BRIDGED_MUTABLE_TYPE(id) __CFRunLoop * CFRunLoopRef;

typedef struct CF_BRIDGED_MUTABLE_TYPE(id) __CFRunLoopSource * CFRunLoopSourceRef;

typedef struct CF_BRIDGED_MUTABLE_TYPE(id) __CFRunLoopObserver * CFRunLoopObserverRef;

typedef struct CF_BRIDGED_MUTABLE_TYPE(NSTimer) __CFRunLoopTimer * CFRunLoopTimerRef;

/* Reasons for CFRunLoopRunInMode() to Return */

// CFRunLoopInMode() 返回的原因
typedef CF_ENUM(SInt32, CFRunLoopRunResult) {
    kCFRunLoopRunFinished = 1,              //runloop中已经没有sources和timers
    kCFRunLoopRunStopped = 2,           //runloop通过 CFRunLoopStop(_:)方法停止
    kCFRunLoopRunTimedOut = 3,              //runloop设置的时间已到
    kCFRunLoopRunHandledSource = 4      // 当returnAfterSourceHandled值为ture时，一个source被执行完
};

/* Run Loop Observer Activities */
typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    kCFRunLoopEntry = (1UL << 0),           // 即将进入loop
    kCFRunLoopBeforeTimers = (1UL << 1),    // 即将处理Timer
    kCFRunLoopBeforeSources = (1UL << 2),   // 即将处理source
    kCFRunLoopBeforeWaiting = (1UL << 5),   // 即将进入休眠
    kCFRunLoopAfterWaiting = (1UL << 6),    // 从休眠中唤醒
    kCFRunLoopExit = (1UL << 7),            // 即将推出rloop
    kCFRunLoopAllActivities = 0x0FFFFFFFU
};

# pragma mark - runloop的mode
// extern
CF_EXPORT const CFRunLoopMode kCFRunLoopDefaultMode;                // C 语言此处只给出了两种模式   
CF_EXPORT const CFRunLoopMode kCFRunLoopCommonModes; //虚拟的   包括：kCFRunLoopDefaultMode + UITrackingRunLoopMode
// 获取runloop的唯一ID(此处ID 未公开，但是可以拿到)
CF_EXPORT CFTypeID CFRunLoopGetTypeID(void);


// 获取runloop
CF_EXPORT CFRunLoopRef CFRunLoopGetCurrent(void);
CF_EXPORT CFRunLoopRef CFRunLoopGetMain(void);

// 当前正在执行的 mode
CF_EXPORT CFRunLoopMode CFRunLoopCopyCurrentMode(CFRunLoopRef rl);

// 获取runloop支持的所有mode
CF_EXPORT CFArrayRef CFRunLoopCopyAllModes(CFRunLoopRef rl);

// 添加 Common 模式, 此处操作挺多的，详细看源码
CF_EXPORT void CFRunLoopAddCommonMode(CFRunLoopRef rl, CFRunLoopMode mode);

CF_EXPORT CFAbsoluteTime CFRunLoopGetNextTimerFireDate(CFRunLoopRef rl, CFRunLoopMode mode);


```

接下来我们一步一步剖析
上文说到，Runloop 不需要显示的去创建对象，每个线程（包括应用程序的主线程）都有一个关联的RunLoop对象。那到底如何获取这个runloop 对象呢？ 

1. 获取runloop 对象

```c

// 获取主线程的RunLoop
CFRunLoopRef CFRunLoopGetMain(void) {
    CHECK_FOR_FORK();
    static CFRunLoopRef __main = NULL; // no retain needed  主runloop 是一个静态变量，
    if (!__main) __main = _CFRunLoopGet0(pthread_main_thread_np()); // no CAS needed
    return __main;
}

// 获取当前线程 RunLoop
CFRunLoopRef CFRunLoopGetCurrent(void) {
    CHECK_FOR_FORK();
    CFRunLoopRef rl = (CFRunLoopRef)_CFGetTSD(__CFTSDKeyRunLoop);
    if (rl) return rl;
    return _CFRunLoopGet0(pthread_self());
}
```
通过 `CFRunLoopGetMain` 和 `CFRunLoopGetCurrent` 分别获取住线程和当前线程的 runloop 对象， 其内部是通过`_CFRunLoopGet0`进行获取的  
```c
// 只能由Foundation 框架调用
// t== 0 始终有效，代表主线程(默认主线程是开启了runloop的)
CF_EXPORT CFRunLoopRef _CFRunLoopGet0(_CFThreadRef t) {
    // 判断线程是否为空，为空就直接 t= 主线程
    if (pthread_equal(t, kNilPthreadT)) {
	t = pthread_main_thread_np();
    }
    // 加锁
    __CFLock(&loopsLock);
    // 如果全局变量__CFRunLoops 没有初始化，那么此处就进行初始化， 并将 main runloop 先加入进去
    if (!__CFRunLoops) {
	CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, NULL, &kCFTypeDictionaryValueCallBacks);
    //创建 runloop 对象
	CFRunLoopRef mainLoop = __CFRunLoopCreate(pthread_main_thread_np());
    // key = 线程ID  value = runloop
	CFDictionarySetValue(dict, pthreadPointer(pthread_main_thread_np()), mainLoop);
	if (!OSAtomicCompareAndSwapPtrBarrier(NULL, dict, (void * volatile *)&__CFRunLoops)) {
	    CFRelease(dict);
	}
	CFRelease(mainLoop);
    }
    // 通过线程去字典中获取对应的runloop
    CFRunLoopRef newLoop = NULL;
    CFRunLoopRef loop = (CFRunLoopRef)CFDictionaryGetValue(__CFRunLoops, pthreadPointer(t));
    // 判断是否获取到，没有就创建
    if (!loop) {
	newLoop = __CFRunLoopCreate(t);
        CFDictionarySetValue(__CFRunLoops, pthreadPointer(t), newLoop);
        loop = newLoop;
    }
    __CFUnlock(&loopsLock);
    // don't release run loops inside the loopsLock, because CFRunLoopDeallocate may end up taking it
    if (newLoop) { CFRelease(newLoop); }
    
    /**
     __CFTSDTable的data数组用来保存私有数据，destructors数组用来保存析构函数，destructorCount用来记录析构函数的个数。
     _CFGetTSD的作用就是获取__CFTSDTable的data数据，并返回slot对应的值。
     _CFSetTSD的作用就是给__CFTSDTable里设置data[slot]和destructors[slot]位置的值。

     */
     //如果传入的线程就是当前的线程
    if (pthread_equal(t, pthread_self())) {
        _CFSetTSD(__CFTSDKeyRunLoop, (void *)loop, NULL);
        if (0 == _CFGetTSD(__CFTSDKeyRunLoopCntr)) {
            // 注册一个回调，当当前线程销毁时销毁对应的runloop 
#if _POSIX_THREADS
            _CFSetTSD(__CFTSDKeyRunLoopCntr, (void *)(PTHREAD_DESTRUCTOR_ITERATIONS-1), (void (*)(void *))__CFFinalizeRunLoop);
#else
            _CFSetTSD(__CFTSDKeyRunLoopCntr, 0, &__CFFinalizeRunLoop);
#endif
        }
    }
    return loop;
}


```

这里需要注意， 首先获取 `Runloop`通过的是线程，当传入的线程是ID是 0 的时候，默认是主线程；  
这里采用了一个全局静态变量 `__CFRunLoops`用来存储，所有线程对应的 `Runloop`对象， 这个对象是一个字典，其key 是对应线程 ID， 其value 是 对应创建的 `CFRunLoopRef`对象  
主线程的runloop会在初始化全局字典的时候创建  
子线程的runloop 会在第一次获取的时候创建  
当线程销毁时，对应的runloop 也会销毁  


> `CFRunLoopGetMain/CFRunLoopGetCurrent` ---> `_CFRunLoopGet0` ----> `__CFRunLoopCreate` 创建runloop 


2. 创建runloop  

```c
/**
 创建Runloop
 */
static CFRunLoopRef __CFRunLoopCreate(_CFThreadRef t) {
    CFRunLoopRef loop = NULL;
    CFRunLoopModeRef rlm;
    // 获取内存大小
    uint32_t size = sizeof(struct __CFRunLoop) - sizeof(CFRuntimeBase);
    //初始化runloop
    loop = (CFRunLoopRef)_CFRuntimeCreateInstance(kCFAllocatorSystemDefault, CFRunLoopGetTypeID(), size, NULL);
    if (NULL == loop) {
        return NULL;
    }
    // 初始化其变量值
    (void)__CFRunLoopPushPerRunData(loop);
    // 创建递归锁
    _CFRecursiveMutexCreate(&loop->_lock);
    // 设置唤醒runloop的 port
    loop->_wakeUpPort = __CFPortAllocate((uintptr_t)loop);
    if (CFPORT_NULL == loop->_wakeUpPort) HALT;
    __CFRunLoopSetIgnoreWakeUps(loop);
    loop->_commonModes = CFSetCreateMutable(kCFAllocatorSystemDefault, 0, &kCFTypeSetCallBacks);
    
    // 注意： 此处首先先将 kCFRunLoopDefaultMode mode添加了，足以说明了其是默认的
    
    CFSetAddValue(loop->_commonModes, kCFRunLoopDefaultMode);
    loop->_commonModeItems = NULL;
    loop->_currentMode = NULL;
    loop->_modes = CFSetCreateMutable(kCFAllocatorSystemDefault, 0, &kCFTypeSetCallBacks);
    loop->_blocks_head = NULL;
    loop->_blocks_tail = NULL;
    loop->_counterpart = NULL;
    loop->_pthread = t;
    loop->_fromTSD = 0;
    loop->_timerTSRLock = CFLockInit;
#if TARGET_OS_WIN32
    loop->_winthread = GetCurrentThreadId();
#else
    loop->_winthread = 0;
#endif
    // 此处调用了查找 对应 mode 的方法， 如果查找不到，就会直接创建一个新的
    rlm = __CFRunLoopFindMode(loop, kCFRunLoopDefaultMode, true);
    // 这里不能锁住
    if (NULL != rlm) __CFRunLoopModeUnlock(rlm);
    return loop;
}



```