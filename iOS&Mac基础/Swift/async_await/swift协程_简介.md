## 参考
https://www.kodeco.com/books/modern-concurrency-in-swift/v1.0/chapters/2-getting-started-with-async-await
https://onevcat.com/2021/07/swift-concurrency/
https://gist.github.com/yxztj/7744e97eaf8031d673338027d89eea76
https://www.bennyhuo.com/2022/01/28/swift-coroutines-05-cancellation/
## 核心
* async
* await
* Task 



## 使用 异步操作的缺点 
1. 错误处理隐藏在回调函数的参数中，无法用 throw 的方式明确地告知并强制调用侧去进行错误处理。 
2. 对回调函数的调用没有编译器保证，开发者可能会忘记调用 completion，或者多次调用 completion。 
3. 通过 DispatchQueue 进行线程调度很快会使代码复杂化。特别是如果线程调度的操作被隐藏在被调用的方法中的时候，不查看源码的话，在 (调用侧的) 回调函数中，几乎无法确定代码当前运行的线程状态。 
4. 对于正在执行的任务，没有很好的取消机制。

> 1. 线程激增：创建太多并发线程需要在活动的线程之间不断切换。这最终会减慢应用程序。 
> 2. 优先级反转：当任意低优先级任务阻止在同一队列中等待的高优先级任务执行时。
> 3. 缺少执行层次结构：异步代码块缺少执行层次结构，这意味着每个任务都是独立管理的。这使得取消或访问正在运行的任务变得困难。这也使得任务向调用者返回结果变得复杂。



