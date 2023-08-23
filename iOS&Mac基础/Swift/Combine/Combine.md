Combine 作用是将异步事件通过组合事件处理操作符进行自定义处理

![](/i/97dcedce-bd30-4163-a4cd-9b865a5cd1f2.jpg)

__ Combine = Publishers + Operators + Subscribers__. 



## Publishers
发布者（Publisher）随着时间变化发送一系列的值给一个或者多个订阅者（Subscriber） 

一个发布者可以发布一个 value，Value 的类型为 Output，有两种状态：成功/失败。成功会发送 Value，失败就会产生 Failure，Failure 的类型为 Error。当然如果一个发布者永远不失败，那么失败就是 Never 类型。 

订阅者和发布者通过 `Subscribtion` 进行连接


### 内置 Publisher
![](/i/145f4c70-ade6-43da-8798-39788dd5b83b.jpg)
* Just
*  Future,
* Deferred, 
* Empty, 
* Fail, 
* Record, 
* Published 
* Share
* Multicast
* ObservableObject
* @Published
*  PassthroughSubject
*  CurrentValueSubject

__Published 实际上是用 propertyWrapper 封装的 Publisher，它可以将任意一个变量封装成一个 Publisher，并通过 projectedValue（影子变量）轻松实现 MVVM__ 


### Subject
一种特殊的发布者，它可以自己主动传送 Value 到 Combine 事件流中  
* PassthrougSubject
  __完成（completion）或者遇到 Error 后，后续将不再接收任何值__ 
* CurrentValueSubject
![](/i/6c9455ba-852d-459d-b3a7-5278efb4e85a.jpg)
sink 方法返回的是 Anycancellabel 对象，它表示一个发布者和订阅者的链接可取消，通过 store 方法将其保存在外部变量 setList 数组中，这样能保证订阅者不会被释放


## Subscribers
![](/i/3707a154-eabb-4ccf-ba58-01cc2996b98a.jpg)

使用 `sink` 方法和 `assign` 方法将在 Combine 内部`自动创建 subcribtion` 连接发布者和订阅者
一个匹配的发布者和订阅者会有 `Output==Input` 和 `Failure == Failure`


* Subscribers.Sink
* Subscriber.Assign


![](/i/6c4a3f13-3474-47c4-b057-0701b764c348.jpg)
> 版本1
* 创建了 Publisher，
* 创了 subscriber
* 通过 subscriber 方法连接， subcriber 方法会在内部创建 subcription 连接 Publisher 和 Subscriber
 
> 版本2
 * 简化版
> 版本3
* 更加简化版 



## Operators(处理信号之间的转换)
__响应式编程的核心其实是 Publishers 各种转换__
__将一个 Publisher 作为输入对象，通过 operator 产生另一个 Publisher__

定义在 Publisher 的各种 Extension 中. 




## Demo
![](/i/9c50f99d-0134-498e-922c-aa44ddd605b5.jpg)
1）我们定义了常见的网络请求的错误类型；



2）UserResponse 返回的是服务端的 json 数据 Model；



3）判断 URL 是否有误，如果异常，返回 PassthroughSubject 生成的订阅者，发送 unsupportUrl 的 Failure 告知外部事件流结束；



4）tryMap 的 Input 类型是 dataPublisher 返回的元组(data: Data, response: URLResponse)，我们判断 http 的 statusCode 是否异常，如果异常直接 thorw 错误，否则将元组的第一个元素 data 返回，所以对应的 Output 为 Data，Failure 为 CustomAPIError；



5）通过 decode 操作符将 data 转换为 UserResponse，decode 的失败 Failure 类型为 Error；



6）处理 tryMap 和 decode 产生的 Error，将其全部转换为 CustomAPIError；



7）最后通过 earseToAnyPublisher 将内部产生的 Publisher 类型擦除，因为外部关心的是 Publisher 携带的 UserResponse 和 CustomAPIError；



8）最终调用 sink 方法可以轻松的接送服务返回的数据。





## 生命周期
![](/i/f6a0d3fa-78ba-4e6f-84de-1399ebef0ced.jpg)
> 自定义 subscriber 
![](/i/2c7af141-4b3f-4227-a373-da45569a4829.jpg)
在 receive(subscription:)方法中最多请求接收 2 次 Value， 通过此种方式，控制请求次数 





## 参考
https://www.infoq.cn/article/eaq01u5jevuvqfghlqbs
https://medium.com/@anuj.rai2489/combine-framework-in-swift-b730ccde131
https://www.avanderlee.com/swift/combine/
https://nemocdz.github.io/post/apple-%E5%AE%98%E6%96%B9%E5%BC%82%E6%AD%A5%E7%BC%96%E7%A8%8B%E6%A1%86%E6%9E%B6swift-combine-%E5%BA%94%E7%94%A8/