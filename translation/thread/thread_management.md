## 线程管理  
OSX 或 iOS 中每个进程由一个或多个线程组成，每个线程代表应用程序中代码的一条执行路径。每个应用程序都以main线程开始，应用可以生成其他线程，每个线程都执行特定函数的代码。   
当应用程序创建一个新线程时，该线程将成为应用程序进程空间中的独立个体。每个线程都有自己独立的堆栈，并由内核单独调度。线程可以和其他线程和其他进程通信，执行 I/O 操作，并执行可能需要执行的任何操作(注：子线程不能执行UI操作)。 由于它们位于同一进程空间，因此单个应用程序中的所有线程共享相同的虚拟内存空间，并具有与进程相同的访问权限    


### 成本  
在操作系统和应用程序层面，线程的创建和使用都是在内存和性能方面有一定的成本消耗的。每个线程都需要在内核内存空间和程序内存空间中分配内存。 管理和调度线程所需的核心结构是存储在内核内存中的。线程的堆栈空间和每条线程所需的数据结构存储在应用程序的内存空间。大多数这些结构都是在创建线程时创建和初始化的，由于需要与内核进行交互，所以整个过程是相对昂贵的   
下表中量化了创建线程所需的大致成本， 其中一些成本是可配置的。 例如为线程分配的堆栈空间大小。创建线程的时间成本是一个近视值，根据计算机速度，处理器负载以及可用系统和程序存储，线程创建时间可能会有很大差异    


| 名称    | 近视值      | 描述   |  
|--------|-------------|-------|   
| 内核数据结构 | 大约 1kb  | 该内存用于存储线程数据结构和属性，该内存分配在有线内存上(内核内存)，并且不能交换到磁盘上    |   
|  堆栈空间  | 512kb普通线程 <br/>  8 MB OS X主线程 <br/> 1 MB iOS 主线程  |   普通线程允许的最小堆栈大小为16 KB，堆栈大小必须是4 KB的倍数。在创建线程时，在进程空间会留出此内存空间，but the actual pages associated with that memory are not created until they are needed   |  
| 创建时间 | 大约90微秒 | 此值反应的是创建线程的初始化和线程入口函数开始执行之间的事件，这些数据是通过分析在基于Intel 2 GHz Core Duo处理器和运行OS X v10.5 1 GB RAM的iMac上创建线程时生成的平均值和中值来确定的。 |

> 注意：由于系统内核的支持，Operation 通常可以更快速的创建线程。他们不是每次都从头开始创建线程，而是使用已驻留在系统内核中的线程池来节省创建时间   


编写线程代码还需要考虑的一个成本是生产成本。设计多线程应用程序有时可能需要对应用程序数据结构的进行根本性更改。 这些更改可能是必须的，需要避免同步操作，这本身可能会对设计不佳的应用程序造成巨大的性能损失。更改设计这些数据结构和调试多线程代码会增加开发时间。避免在运行时花费大量的事件在等待锁或什么也不做造成的运行时问题。   


### 创建线程  
创建低级线程相对简单。 必须具有一个函数或方法来充当线程的入口点，并且必须使用一个可用的线程来启动线程。以下部分显示了常用的不同方式创建线程过程。使用这些方式创建的线程会继承一组默认属性，这些属性由采用的创建方式来决定。具体关于线程配置部分可以参阅[配置线程属性](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/CreatingThreads/CreatingThreads.html#//apple_ref/doc/uid/10000057i-CH15-SW8)


#### 使用 NSThread  
使用 `NSThread` 创建线程有两种方式：  

* 使用 `detachNewThreadSelector:toTarget:withObject:` 类方法生成新的线程  
* 创建一个新 `NSThread` 对象并调用其`start` 方法

两种方式都会创建一个分离线程，分离线程意味着线程退出时系统会自动回收线程资源。
要分离新线程，只需提供要用作线程入口点的方法名称（选择器），定义该方法的对象以及要在启动时传递给线程的数据。以下示例显示了此方法的基本调用，该方法使用当前对象的自定义方法生成线程。   

```
[NSThread detachNewThreadSelector：@selector（myThreadMainMethod :) toTarget：self withObject：nil];
```

在 OS X 10.5 之前，主要使用NSThread类来生成线程。虽然你可以获得一个NSThread对象并访问一些线程属性，但只能在线程运行后从线程本身执行。在 10.5 中，添加了创建 `NSThread` 对象的支持，而不会立即生成相应的新线程。此方式支持在启动线程之前获取和设置各种线程属性。它还支持以后使用该线程对象引用正在运行的线程    

`NSThread` 在在OS X v10.5及更高版本中可以通过`initWithTarget:selector:object:`初始化对象.此方法与 `detachNewThreadSelector:toTarget:withObject:` 方法需要完全相同的信息初始化实例。但是，它不会启动该线程， 要启动该线程，需要通过 `start` 启动  

```
NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                        selector:@selector(myThreadMainMethod:)
                                        object:nil];
[myThread start];  // Actually create the thread
```

如果有一个当前正在运行的线程，可以通过`performSelector:onThread:withObject:waitUntilDone:`方法将消息发送到该线程。在 OSX 10.5 中引入了再线程上执行Selector 的支持(主线程除外),这是在线程之间通信的便捷方式。使用此方式发送的消息，由其他线程执行，作为其正常运行处理的一部分。(但此种方式需要线程开启Runloop才可以).当采用此种方式进行通信，可能仍然需要某种形式的线程同步，但它比在线程之间设置通信端口更简单。   

> 注意： 尽管`performSelector:onThread:withObject:waitUntilDone:`可以实现线程通信，但不应该频繁使用

#### 使用 POSIX   
OS X 和 iOS 提供了基于C 语言实现的 POSIX 支持。该技术实际上可以用于任何应用的支持。如果编写跨平台应用，可能会更加方便。通过`pthread_create`方法恰当的创建一个 POSIX 线程   

以下代码中展示了POSIX线程创建。 该`LaunchThread`函数创建一个新的线程，其主程序在`PosixThreadMainRoutine`函数中实现。__默认情况下POSIX将线程创建为可连接__，所以此示例更改线程的属性以创建分离线程。将线程标记为已分离使系统有机会在退出时立即回收该线程的资源。

```C
#include <assert.h>
#include <pthread.h>
 
void* PosixThreadMainRoutine(void* data)
{
    // Do some work here.
 
    return NULL;
}
 
void LaunchThread()
{
    // Create the thread using POSIX routines.
    pthread_attr_t  attr;
    pthread_t       posixThreadID;
    int             returnVal;
 
    returnVal = pthread_attr_init(&attr);
    assert(!returnVal);
    returnVal = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    assert(!returnVal);
 
    int     threadError = pthread_create(&posixThreadID, &attr, &PosixThreadMainRoutine, NULL);
 
    returnVal = pthread_attr_destroy(&attr);
    assert(!returnVal);
    if (threadError != 0)
    {
         // Report an error.
    }
}


```
如果将以上代码添加到一个源文件并调用`LaunchThread`函数，将在应用程序中创建一个新的分离线程. 但是，使用此代码创建的新线程不会做任何有用的事情。线程启动并立即终止。
可以通过`pthread_create`函数的最后一个参数给线程传递数据指针，以指明线程可以处理的具体数据任务   

要将新创建的线程处理过后的数据传递回主线程，需要在目标线程之间建立通信通道。对于基于C 实现的应用程序，有多种方式可以实现线程之间通信(端口，共享内存，conditions)。对于长期存在的线程，需要设置一种线程之间通信方式以便随时查看线程状态以及主线程退出时能够安全的关闭线程   

有关`pthread`更多详细信息，请参考[POSIX pthread](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/pthread.3.html#//apple_ref/doc/man/3/pthread)

#### 使用 NSObject生成  
在iOS5 和 OSX 10.5 及更高的版本中，所有对象都可以直接生成新线程并使用它来执行一个任务方法。`performSelectorInBackground:withObject:` 方法创建一个新的线程，并使用指定的方法作为新线程的入口。 例如：  

```
[myObj performSelectorInBackground：@selector（doSomething）withObject：nil];

```  
相同的方法，参数，对象与通过`NSThread` 的 `detachNewThreadSelector:toTarget:withObject:` 方法效果是一样的。都会使用默认参数立即生成新的线程并运行指定方法。在方法内部，需要像其他线程处理方式一样配置线程。例如：设置自动释放池以及设置 runloop 等  

更多配置信息请参考[配置线程属性](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/CreatingThreads/CreatingThreads.html#//apple_ref/doc/uid/10000057i-CH15-SW8)



#### 在Cocoa应用程序中使用POSIX线程
尽管`NSThread` 是在Cocoa 中线程的主要主要使用方式。但同时也可以自由使用 `POSIX`线程，如果你觉得更加方便的话。例如： 你已经有相应的代码并准备从写它，则可以使用`POSIX`线程(总之，就是没有限制，不过首选推荐使用 `NSThread`)。 如果计划在cocoa应用中使用 POSIX 线程，那么需要了解 Cocoa 和线程之间的交互，并遵守以下准则。   

##### 警惕Cocoa 框架  
对于多线程应用程序，Cocoa框架会使用锁和其他方式进行内部同步以确保线程行为正确。但是为了防止这些锁在单线程情况下降低性能， 默认情况下 Cocoa 是不会创建他们，直到应用程序使用 NSThread 创建一个其他线程的时候才创建。如果使用 POSIX 线程创建线程，Cocoa 不会收到应用变为多线程应用的通知， 当发生这种情况的时候，涉及到 Cocoa 框架的操作就可能变为不稳定或崩溃   

为了让Cocoa 知道当前应用打算采用多线程， 可以通过`NSThread` 创建一个新的线程并立即退出(线程不做任何事情)。只要产生通过 NSThread 创建线程的这个行为，Cocoa 会创建对应锁   

如果不确定 Cocoa 是否已经确定应用程序时多线程的。 可以检查`NSThread` 的`isMultiThreaded` 方法以确定   

##### POSIX/Cocoa 锁交叉  
在同一个应用程序中混合使用 POSIX 和 Cocoa 锁是安全的。 Cocoa 锁和 conditions 本质是对 POSIX 锁和条件的包装， 但是， 对于给定的锁，必须始终使用相同的方式来操作。 比如， 不能使用 Cocoa 的`NSLock` 操作由`pthread_mutex_init` 创建的锁， 反之亦然。   

##### 总结  
1. 在 Cocoa 中使用 POSIX 需要创建一个 `NSThread` 空任务线程  
2. 锁独立，不能交叉使用  





### 配置线程属性  
在创建线程之前，可能希望配置线程环境，以下就介绍了线程可修改部分属性   


#### 配置线程堆栈大小  
对于创建的每个线程，系统都会在进程空间中分配特定大小的内存，以充当该线程的的堆栈。堆栈管理堆栈帧，是声明线程局部变量的地方。  

如果要更改给定线程的堆栈大小，必须在创建线程之前进行此操作。虽然`NSThread` 在 iOS和OSX 10.5 之后才提供了此功能。不过所有的线程技术都提供了设置堆栈大小的方法  

|      技术   |     实现方式   |  
|------------|---------------|  
|  Cocoa    | 在 iOS 和 OSX10.5 之后才提供，在调用 `start` 之前使用`setStackSize` 方法设置堆栈大小(`detachNewThreadSelector:toTarget:withObject:` 方式不支持)  |  
| POSIX     | 创建一个新的`pthread_attr_t`结构体并使用 `pthread_attr_setstacksize`函数进行更改堆栈大小。在`pthread_create` 方法创建线程时作为参数传入|   
|  Multiprocessing Services |  在`MPCreateTask` 创建线程时，将合适的堆栈大小传入  | 

> MPCreateTask 此种方式 10.7 已经弃用,可以不考虑  

#### 配置线程本地存储 
每个线程都维护一个键值对字典， 可以在线程的任意位置访问。 可以使用此字典存储要在整个线程执行期间保留的信息。例如： 可以使用它来存储要通过线程运行循环的多次迭代持久化的状态信息




#### 设置线程分离状态  



#### 设置线程优先级 



### 编写线程入口函数  


#### 创建自动释放池 


#### 设置异常处理  


#### 设置 Runloop  


### 终止线程  



