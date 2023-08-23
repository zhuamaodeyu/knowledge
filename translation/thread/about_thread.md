## 线程  

多年来， 计算机的性能主要受单核心CPU限制。然而，随着单核心CPU性能达到极致，芯片制造商转而采用多核设计，使计算机可以同时执行多项任务。 虽然操作系统可以利用这些核心来完成系统相关的任务，同时用户应用程序也可以通过线程技术来利用  

### 什么是线程？  
线程是在应用程序内部实现多路执行的轻量级方式。在系统层，程序并行运行，系统根据需将执行时间分配给每个程序。然而在应用程序内部，存在一个或多个执行线程，其可用于同时或几乎同时的方式执行不同任务。系统本身实际上管理这些线程，将它们合理的安排在可用CPU核心上运行，并根据需要中断以运行其他线程或继续执行这些线程     

![线程]()   
> 译者注： 此处其需要引申到进程的概念  

从技术角度看，线程是管理代码执行时所需的内核级与应用级数据结构的集合(线程用来管理内核级和应用级数据结构)    
内核级是协调事件到线程基于在一个可用内核上的线程调度；应用级包括用户存储线程调用的调用栈基于应用程序管理和操作线程属性以及状态    

在非并发应用程序中，只有一个执行线程(执行 main 函数线程)。相比之下，并发应用程序从一个线程开始，根据需要会添加其他执行线程。每个线程独立运行。应用多线程具有以下优势：   
* 多线程可以提高应用程序的响应能力  
* 多线程可以提高应用程序在多核系统上的性能    

如果一个应用程序只有一个线程，那么这个线程必须执行所有操作。必须响应事件、更新View,并执行应用程序所需的计算。 一个线程一次只能做一件事，想象下当一个计算任务需要很长事件时，会发生什么？ 当线程忙于计算时，它将无法响应用户事件以及更新View。 如果这个行为持续很长时间，用户可能会认为应用程序已经挂起并尝试强制退出。但是如果将耗时计算移到单独的线程去运行，那么将不会卡顿主线程，应用主线程也可以更及时的响应用户交互    

对于多核计算机，线程提供了提高应用性能的方式。执行不同任务的线程可在其他内核上执行，从而使应用可以更好的处理及时任务(例如： 用户交互)   

当然，线程并不是解决应用程序性能的灵丹妙药。线程的引入在提供了好处之外，也同时引入了潜在问题。应用程序中具有多个执行路径会给代码增加很大的复杂性。每个线程之间需要协调，以防止它破坏应用程序状态信息。由于单个应用程序中的线程共享相同的内存空间，因此，他们可以访问相同的数据。如果两个线程试图同时操作相同的数据结构，则一个线程可能以覆盖的方式更改数据结构以破坏数据结构的正确性。即使有适当的保护，也仍然需要注意编译器优化，这些优化可能会在代码中引入细微的错误   


> 在任意时间点上，线程是可结合或者分离的， 一个可结合的线程能够被其他线程收回其资源和杀死，在被其他线程回收资源之前，其堆栈是不会释放的。相反，一个分离线程是不能被其他线程回收或杀死的，它的资源在它终止时由系统释放。__线程的分离状态决定一个线程以什么样的方式来终止自己__  ---- 此部分引自别处 



### 术语说明  
在深入讨论线程及其支持技术之前，有必要定义一些基本术语。

注意: 在UNIX系统上，术语“任务”有时用于指代正在运行的进程。可能与本文档中定义不同  

* 线程： 只带代码单独执行路径  
* 进程： 只带正在运行的可执行文件，其可以包含多个线程  
* 任务： 用户指代需要执行的抽象工作   


### 线程替代品  
> 译者注： 此处指的只是概念上的，针对的是单独线程创建，其部分替代品的内部还是基于线程实现的。

线程是一种支持应用并发的相对低级且复杂的方式，自己创建线程会给代码增加不确定性。 如果针对线程设计并不很了解，则可能很冗余遇到同步等问题，其轻微的不同行为可能造成用户数据更改甚至应用程序崩溃等问题   


另一个考虑因数是是否需要多线程和并发。 在某些情况下，并不需要开启新的线程，线程的创建需要一定的CPU和内存开销，可能适得其反。   



| 名称  | 描述  | 
|---|---|
| Operation Object  | 通常在辅助线程上执行的任务包装器。隐藏了任务执行的线程方面管理，让开发人员更专注于任务本身。通常可以和操作队列结合，该队列管理一个或多个线程上的操作对象执行  |  
| GCD  | 是另外一种替代方案，可以更专注于任务本身，而不是线程管理。使用GCD， 可以定义任务并将其添加到工作队列中，该队列在适当的线程中执行任务。工作队列会结合等资源更高效的执行任务  |  
| Idle-time notifications  | 对于任务所需时间较短或优先级较低的任务，可以通过空闲时间通知在应用程序不忙的时候执行任务。通过`NSNotificationQueue`实现，并指定通知模式为`NSPostWhenIdle`。队列延迟通知的传递，直到Runloop空闲  |  
| Asynchronous functions  | 系统提供了部分异步函数，这些API可以使用系统守护进程，或创建自定义线程来执行任务并返回结果。  |  
| Timers | 可以再应用程序的主线程上使用定时器来定时执行任务，注意这些任务需要是简单的，可以不需要线程，但需要定期维护的(长时间的可能会阻塞主线程)  |  
| Separate processes  |  比线程更重量级，在任务仅与应用程序若关联的情况下，创建单独的进程可能很有用。如果任务需要大量内存或必须使用root权限执行，则可以使用进程。例如，您可以使用64位服务器进程计算大型数据集，而32位应用程序将结果显示给用户。 |  


> **[warning] Warning**   
> 
> 使用fork函数启动单独的进程时，必须始终通过调用exec或类似的函数来调用fork。依赖于Core Foundation，Cocoa或Core Data框架（显式或隐式）的应用程序必须对exec函数进行后续调用，否则这些框架可能表现不正常。  
> When launching separate processes using the `fork` function, you must always follow a call to `fork` with a call to `exec` or a similar function. Applications that depend on the Core Foundation, Cocoa, or Core Data frameworks (either explicitly or implicitly) must make a subsequent call to an `exec` function or those frameworks may behave improperly.


### 线程支持  
系统提供了几种在程序中创建线程的方式。同时支持管理和同步线程状态。   


#### 创建方式 
虽然线程的底层实现方式是 `Mach` 线程。但在工作中，几乎不会直接使用到 `Mach`级的线程操作。通常使用的是更方便的 `POSIX` 或其衍生产品。`Mach`实现提供了线程的所有功能， 包括任务执行等级一级线程调度功能    



|  名称    |   描述    |  
| --------| ---------| 
| Cocoa层  | Cocoa使用 `NSThread`实现线程功能，Cocoa还提供了通过`NSObject`生成新线程和在已运行的线程上执行任务的能力 [NSObjct生成线程](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/CreatingThreads/CreatingThreads.html#//apple_ref/doc/uid/10000057i-CH15-SW13) [NSThread](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/CreatingThreads/CreatingThreads.html#//apple_ref/doc/uid/10000057i-CH15-SW11) |  
| POSIX   | POSIX提供了创建线程的C接口。如果实现的应用程序与Cocoa无关，可以通过此方式俩实现线程功能。POSIX功能相对简单，并提供了线程灵活配置 [POSIX线程](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/CreatingThreads/CreatingThreads.html#//apple_ref/doc/uid/10000057i-CH15-SW12) |  
| Multiprocessing Services | 是从旧版Mac OS 转换的应用使用的基于C的接口。不建议使用此方式创建线程。推荐使用以上两种方式  |   


在应用程序层，线程的所有行为方式与其他平台基本相同。启动线程后，线程以以下三种状态之一运行:`running`,`ready`,`blocked`。如果一个线程当前没有在运行，那么它将处于 `blocked`或者 等待输入 或者已经准备好，但还未开始运行(`ready`状态)。 线程将在以上几种状态之间进行切换，直到线程运行完毕终止  

当创建一个新的线程时， 必须给当前线程指定一个入口点函数。 此入口函数由需要线程完成的任务代码组成。当函数执行完毕返回，或者显示的终止线程，线程将永久停止并由系统回收。由于线程创建在内存和时间方面的成本相对较高，因此建议执行大量工作或设置运行循环以允许执行重复工作  


#### Runloop  
Runloop 是一个用于管理异步到达线程的事件的基础结构。Runloop 通过检测一个或多个事件源。当事件到达时，系统唤醒线程并将事件调度到Runloop 上，Runloop 将事件指派到指定的具体处理. 如果没有事件到达或准备处理，Runloop 将使线程进入休眠状态   




#### 线程同步  
线程编程的一个危险操作是线程之间的资源竞争。如果多个线程尝试同时使用或修改同一资源，则很有可能会出问题。解决此问题的一种方式是完全消除共享资源。确保每个线程操作自己独有的资源。但是，维护完全线程独立的资源并不很现实(会造成资源浪费等因素，还有资源同步等问题)。所以可能需要通过 `lock`,`conditions`,`automic操作`或者其他方式来解决同步资源访问。   

锁 为资源提供了强力保护， 一次只能由一个线程操作。最常见的锁类型是互斥🔐。当一个线程视图获取当前由另一个线程持有的互斥锁时，会被阻塞，直到另一个线程释放该锁。多个系统框架提供了互斥锁的支持，尽管他们都是基于相同的底层实现。此外，Cocoa提供了互斥锁的几种变种，以支持不同类型行为，例如 递归。

除了锁外，系统还提供了对 `conditions`支持。以确保应用程序中任务的正确顺序。`conditions`充当守门员，阻塞给定的线程，直到`conditions`变为真。当 `conditions`为 `true` 时， `conditions`允许线程继续执行。 `posix`和 `Foundation`层都提供了支持。(如果使用的是 operation,则可以配置 `operation` 之间的以来关系以对任务执行进行顺序，此种方式与条件行为非常类似)  


虽然锁和条件操作在并发中是非常常见的。 但原子操作是保护和同步数据的另外一种方式。在对变量数据执行数学或逻辑上操作运算时，原子操作提供了轻量级锁操作。原子操作使用特殊的硬件指令来确保在其他线程访问之前对其进行更改。   


#### 线程间通信  
虽然良好的设计可以很大程度上减少线程之间的通信，但确实不可避免的。线程可能需要处理新的任务或将其进度报告给应用程序的主线程，在这种情况下，需要有一种方式，在一个线程中获取另外一个线程的信息。幸运的是，线程之间共享相同的进程空间这一事实意味着可以有有很多通信方式  

线程之间有很多种通信方式，每种方式都有其优点和缺点。下表中列出了可在线程之间通信的多种方式。此表按照复杂程度递增的方式排列：  

|  方式     | 描述        | iOS       | OS X   |   
|----------|-------------|-----------|--------|   
|Direct messaging | Cocoa 程序支持






### 开发技巧  
以下，列举出了部分开发技巧，以确保能够正确的使用线程   

##### 避免显示创建线程  
手动创建线程是很繁琐和容易出错的， 应该避免这种情况出现。OS X和iOS通过其他API提供对并发的隐式支持。不要自己创建线程， 优先考虑使用 异步 API， GCD 或 Operation 的方式实现。这些技术在内部做了线程相关的工作，并确保线程正确执行。GCD 和 Operations 等技术通过结合系统负载调整线程数量可以更有效的控制线程，提高代码性能。 详情请参考 __[编发编程](https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008091)__    

##### 保持线程合理运行  
线程的创建和运行都会占用一定的系统资源，如果决定自己创建和管理线程，应该尽力保证分配给线程的任务都是合理或可发挥线程性能的(不要是简单的，这样适得其反)。 与此同时，针对使用过后并且空闲的线程应该及时的释放掉。线程会占用大量内存，因此释放空闲线程有助于减少应用程序的内存占用，还可以释放更多物理内存给其他进程使用    


##### 避免使用共享数据结构   
避免线程中资源竞争的最简单的方式是给每个线程提供单独的数据副本。当最小化线程之间的通信和资源竞争时，并行性能最高  

创建多线程应用程序很困难，即使非常小心的在代码中针对所有共享数据结构进行锁定，但代码仍然可能存在语义上的不安全。 例如，如果希望以特定顺序修改共享数据结构，则代码可能会遇到问题。将代码更改为基于事务的方式进行实现则可能会抵消多线程的性能优势。 __首先应该避免资源竞争，常常会使设计简单，性能更高__  


##### UI   
如果应用程序有图形界面，建议从主线程接收与用户相关的事件并更新UI。此方式避免在处理用户事件与UI同步的问题。但注意： 有些情况下，从其他线程操作图形是有利的，例如，可以使用辅助线程创建和处理图像，并执行与图像相关的其他计算，使用辅助线程可以大大的提高性能。如果不确定特定的图形操作，还是建议从主线程执行。 [Cocoa绘图指南](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CocoaDrawingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40003290)  

##### 线程退出  
当所有线程都退出时，进程才会退出。默认情况下，只将应用程序的主线程创建为`non-detached`,也可以通过这种方式创建其他线程。 当用户退出应用程序时，通常会立即终止所有的子线程，因为子线程完成的任务被认为是可选的。如果应用程序使用后台线程将数据保存到磁盘或执行其他关键工作。可能希望将这些线程创建为`non-detached`的，以防止在应用程序退出时丢失数据。   
将线程创建为 `non-detached` 需要做一些额外工作。由于大多数高级线程技术默认情况下是不能创建这种，必须使用 `POSIX API`来创建线程，此外，必须在主线程中添加代码，以便在退出时与主线程进行连接。 更多详细信息可参考[ Setting the Detached State of a Thread](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/CreatingThreads/CreatingThreads.html#//apple_ref/doc/uid/10000057i-CH15-SW3)   

如果是 Cocoa 应用程序，可以使用 `applicationShouldTerminate:` 代理方法将应用程序的终止延迟或取消终止。延迟后，需要在应用程序等待的关键线程完成时，调用 `replyToApplicationShouldTerminate:` 指定是否需要终止   




##### 异常处理  
 异常处理机制是当前调用堆栈在抛出异常时执行一些必要的清理。因为每个线程都有自己的调用堆栈，所以每个线程都负责捕获自己的异常。 子线程与主线程抛出异常都将有相同的结果： 进程终止。 不能将未捕获的异常抛出给其他线程进行处理   

 如果需要将当前线程的异常通知给另一个线程，需要先在当前线程进行简单的捕获处理，并向另一个线程发送消息。根据不同的情况决定，当发生异常时，是否需要继续处理，等待操作，还是直接退出   

> 注意： 在 Cocoa中，`NSException` 对象是一个字包含的对象，一旦被捕获就可以从一个线程传递给另一个线程

在某些情况下，可能会自动创建异常处理。例如: `@synchronized`， 会创建一个隐式异常处理   


##### 线程终止  
线程终止的最佳方式是到达线程入口的末尾，虽然有立即终止线程的函数，但这些函数仅作为最终手段使用。 在线程到达自然终止点之前显示终止线程(调用终止函数),线程将不能自动清理。如果线程已经分配了内存， 打开文件或获取其他系统资源，则代码将可能无法回收这些资源，从而导致内存泄漏或其他潜在风险。 [终止线程](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/CreatingThreads/CreatingThreads.html#//apple_ref/doc/uid/10000057i-CH15-SW10)

##### Libraries 中线程安全 
虽然应用程序开发人员可以控制应用程序是否使用多线程执行，但是库开发人员却没有。 所以必须假设调用库的应用程序时多线程的，或者随时可以切换为多线程。 因此，应该始终对关键代码段使用锁。   
对于库开发人员，仅在应用变为多线程的才创建锁是不明智的。 如果需要在某个时刻使用锁，请在使用库的早期就创建锁对象。 最好是在某种显示调用中初始化库。虽然可以使用静态库初始化函数来创建此类锁，但只有在没有其他方式的时候才尝试这样做。执行初始化函数会增加库加载所需时间，并可能对性能有所影响。   

如果使用 Cocoa 开发程序， 可以监听 `NSWillBecomeMultiThreadedNotification`通知，以便在应用变为多线程时做出回调。__但不应该过度依赖此通知回调，其可能会在调用库代码之前触发__   


#### 总结  
本章主要介绍了线程的概念，创建，同步以及部分优化使用方式等。  





## 参考  
* [线程管理](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/CreatingThreads/CreatingThreads.html#//apple_ref/doc/uid/10000057i-CH15-SW2)  
* [Runloop](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html#//apple_ref/doc/uid/10000057i-CH16-SW1)  
* [锁](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/ThreadSafety/ThreadSafety.html#//apple_ref/doc/uid/10000057i-CH8-126320)  
* [同步](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/ThreadSafety/ThreadSafety.html#//apple_ref/doc/uid/10000057i-CH8-124887)