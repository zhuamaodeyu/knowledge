# 异步/等待、组合、闭包：现代异步 Swift 指南 

## [原文](https://quickbirdstudios.com/blog/async-await-combine-closures/)  


通过 `async/await`, Apple 再次为swift中引入了另一种异步实现方式。 目前一种原生支持三种不同的异步实现方式： 
* `Completion handlers`: 异步block 回调  
* `Combine` 
* `async/await`  

同时还有例如： `RxSwift`, `ReactiveSwift` 等开源解决方案  


针对多种解决方案，我们应该改如何使用？是否某个方案有明显的优势？接下来一起讨论吧  

## 异步 swift 方法 
 本文通过一个常见的实例及 通过`URLSessionDataTask`从网络中检测数据来进行示例说明。   
通过检查其状态代码来进一步验证响应，如果状态代码不在 200 到 399 之间，则抛出错误。  

> 注意： 在生产环境中，应该以比此处介绍的方式更广泛地处理不成功的 http 响应，例如通过解析返回的数据以查找来自服务器的潜在错误消息。


## 闭包 
完成处理代码是作为参数以闭包的形式存在。这些闭包在方法的异步活动完成返回相应结果时执行
```swift 
func perform(_ request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
    let task = URLSession.shared.dataTask(for: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let data = data, 
              let httpResponse = response as? HTTPURLResponse, 
              (200..<400).contains(httpResponse.statusCode) else {
            completion(.failure(URLError(.badServerResponse)))
            return
        }
        completion(.success(data))
    }
    task.resume()
}

```
在上面的示例程序中，闭包作为最后一个参数传入到方法中， 当 `dataTask`完成时（无论成功与否），都要调用该闭包。   
向方法添加完成处理程序支持非常简单：向方法添加一个新的闭包输入参数，每当异步操作完成时就会调用该参数。  

#### 缺点
但是以上方式存在一些问题：  
1. 完成处理程序可以被调用任意多次。  
    编译器不会强制在每个可能的执行分支中调用闭包， 它也可以被调用两次。  
2. 一个接一个地调用异步操作是通过在其他操作的完成处理程序中嵌套操作来完成的。当许多操作链接在一起时，这很容易导致代码难以阅读(__回调地狱__) 例如： 
    ```swift 
    func processImageData(completionBlock: (Result<Image, Error>) -> Void) {
        loadWebResource("dataprofile.txt") { dataResourceResult in
            do {
                let dataResource = try dataResourceResult.get()
                loadWebResource("imagedata.dat") { imageResourceResult in
                    do {
                        let imageResource = try imageResourceResult.get()
                        decodeImage(dataResource, imageResource) { imageTmpResult in
                            do {
                                let imageTmp = try imageTmpResult.get()
                                dewarpAndCleanupImage(imageTmp) { imageResult in
                                    completionBlock(imageResult)
                                }
                            } catch {
                                completionBlock(.failure(error))
                            }
                        }
                    } catch {
                        completionBlock(.failure(error))
                    }
                }
            } catch {
                completionBlock(.failure(error))
            }
        }
    }
    ```



## Combine 
在反应式编程中，订阅是在发布者发出由订阅者接收的值之间创建的。发布者可以通过关闭订阅或因错误而失败来进一步完成订阅。订阅者也可以取消订阅。  
```swift 
func perform(_ request: URLRequest) -> AnyPublisher<Data, Error> {
    URLSession.shared.dataTaskPublisher(for: request)
        .tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<400).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            return data
        }
        .eraseToAnyPublisher()
}

```

在响应式编程中，可以通过将运算符应用于现有发布者来创建发布者, 在上面的例子中，我们首先有一个发布者，它返回类型（Data，URLResponse）的值，然后将其映射到单个 Data 对象。我们使用 tryMap 运算符，因为该操作涉及检查响应的状态代码，这可能会失败  
作为最后一步（主要与 Combine 相关，而不是一般的响应式编程），我们擦除发布者的类型，以便方法的签名不包含任何特定的发布者类型，而是我们希望使用 AnyPublisher 作为能够轻松更改方法的内容而无需修改其签名   

与闭包相反，发布者失败的错误已经融入了框架本身。但是，在 Combine 中，您经常需要在不同的错误类型（或非抛出和抛出发布者）之间转换发布者，从而创建额外的样板代码。  


## Async/Await   
在 Swift 5.5 中，Apple 发布了结构化并发，包括 async/await、actor 概念、异步序列和任务支持。 
```swift 
func perform(_ request: URLRequest) async throws -> Data {
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse,
          (200..<400).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
    return data
}
```
虽然看起来与Combine代码非常相似，但它完全消除了一些代码开销。你有没有注意到缺少tryMap运算符以及它的闭包和eraseToAnyPublisher调用.  `Async/await`方法看起来与常规方法非常相似. 仅包含`async` 关键字的微小差异。将这些方法视为一种完全不同的方法，因为您无法从任何其他方法调用它们。__只能从另一个异步方法或任务中调用异步方法。__   

Async/await 允许开发人员编写看起来非常像同步代码的代码，但使用 async 和 await 关键字除外. 与反应式编程和闭包相比, 它进一步将样板代码压缩为单个关键字（主要是异步和等待）。 



## 特点 
现在我们已经了解了如何以这些不同的风格编写异步代码，让我们看看它们在需要更多功能的情况下的行为方式。具体来说，它们如何用于值流、如何处理失败事件、是否可以取消等等。   

## 1. 输出  
异步任务可以在操作完成时只有一个输出，也可以有多个输出。例如，当您想要通知操作的进度或值可能随时间变化时，例如定期更新的计时器或网络值。


#### 闭包 
闭包本身并不提供有关它们被调用次数的任何信息。对于值流，我们可以简单地随着时间的推移使用不同的值来调用闭包参数。   
```swift 
func doSomething(update: @escaping (Update) -> Void, completion: @escaping (FinalResult) -> Void) {
    // ...
}

```


示例方法包含两个闭包参数。每当给定操作有可用的更新（例如新进度）时，就会调用第一个参数更新，而在操作结束时调用完成。由于闭包参数通常仅在操作完成后调用，因此我们建议在方法的文档中添加注释，以阐明闭包参数可以多次调用。


#### Combine  
一些具体的发布者类型明确表示会发出特定数量的值:   
* `Future`: Future
* `Just`: 1
* `Empty`: 0
* `Fail`: an error

然而，一旦我们类型擦除方法的返回类型或使用许多运算符， 这些信息将丢失， 只能通过方法的签名或文档来推断。  因此，编译器无法确保根本不会有一个输出值，正好有一个或可能无限多个而不停止（重复计时器就是这种情况）
发布者还可以发出订阅结束的信号， 但无法添加任何进一步的信息（如最终结果）这可以通过包含最终结果的最终更新值或更复杂的解决方案来实现，该解决方案涉及更新传播的主题、订阅服务器或闭包以及单值发布者。  


#### Async/await  
将函数标记为异步将告诉编译器只有一个返回值，就像在同步函数中一样。
但是，通过使用 AsyncSequence 类型，我们可以创建类似于反应式发布者的值流。然后，我们可以使用 for-await-in-loop 来循环获取，如以下示例所示：
```swift 
let url: URL = // ...
for try await line in url.lines {
    print(line)
}
// when this line is executed, the file at the given url has been fully read.

```
> 上面的代码示例逐行读取给定 URL 上的文件，导致为每一行调用 for-await-in-loop 的代码   

与Combine类似，AsyncSequence会通知它们的完成情况，并且不允许添加最终结果。您可以使用 for-await-in-loop 自动侦听此事件，因为在观察到完成事件后，将执行循环后的代码。为了同时完成更新和完成机制，闭包可用于具有返回值的异步函数中的更新机制。


## 2. 失败 
就像同步操作一样，异步操作也可能会失败。例如，考虑网络调用、数据库访问或文件操作。那么，这些方法如何处理这个问题呢？  

特别是在低级代码中，您可能还想指定可以抛出的具体错误类型，那么这些方法也允许这样做吗？  


#### 闭包  
Objective-C 块或不太现代的 Swift 代码通常使用带有两个参数的完成处理程序闭包，其中一个参数是可选错误。
Swift 5 引入了 来Result type轻松明确要么返回一个值，要么失败，但两者兼而有之，也可能什么都没有，通过在结果类型中指定具体的 Failure，还可以限制可能的错误类型。   

```swift 
func doSomethingOld(completion: @escaping (Success?, Error?) -> Void) { ... }
func doSomethingNew(completion: @escaping (Result<Success, Error>) -> Void) { ... }
```

对于仅抛出单一错误类型的错误的更底层代码，可以将该类型指定为 的第二个通用约束Result。示例：`Result<String, URLError>`.  

#### Combine  

要了解 Combine 中的错误处理，让我们看一下协议Publisher: 
```swift
protocol Publisher {
    associatedtype Output
    associatedtype Failure : Error
    func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input
}
```
从这个协议中我们可以看到，每个发布者都需要有一个关联的Failure类型。那么这是否意味着每个出版商都可能失败？不会。只要发布者不会失败，它就可以指定Never类型作为其Failure类型。
Never是一种任何对象都不能存在的类型。这几乎意味着它不存在也不可能存在。实际上，Never它是一个没有任何情况的枚举，因此应该很清楚为什么不可能创建该类型的任何值。   
许多发布者将其Failure类型作为通用约束：参见Future<Output, Failure>等等AnyPublisher<Output, Failure>。对于由操作员产生的发布者，故障类型通常由上游发布者和操作隐含。例如，一个tryMap操作创建一个具有关联的发布者Failure的类型Error，可以是任何符合Error协议的错误值。

总结一下：__Combine 不仅支持开箱即用的错误处理，您还可以进一步将错误类型限制为特定类型。__  

#### Aync/Await 
标记为async的函数也可以用关键字throws标记, 因此类似于同步方法可能会失败，异步方法也会失败！但是，它不支持专门的故障类型。这主要是由于该语言缺少对一般抛出函数的专门失败类型的支持。

AsyncSequence还可以抛出错误，导致值流完成。由于类似的语言限制，这里也无法进一步指定故障类型。  

总结： __可以抛出异常，但是无法指定具体的异常类型__  



## 3. 取消  
某些异步操作可能需要很长时间才能失败，甚至创建后无法完全自行完成（例如计时器）。在某些时候，用户可能不再对操作的完成感兴趣并打算取消它。我们如何通过闭包、反应式编程和 async/await 来实现这一点？  

#### 闭包 

__闭包一般不支持取消__  
当然，可以编写一种机制来引入对单个方法的取消支持，但目前没有（据我所知）标准化的方法来做到这一点。此概念的现有构造可以在类型中找到Timer，需要在代码中的某处强引用。  

#### Combine  
组合支持开箱即用的取消。只需在订阅发布者时返回的任何可取消对象上调用cancel（），操作就会停止，不再发出任何值


#### Async/await  
`Task`有一个`cancel()`函数，其工作原理与在Combine中取消订阅的方式非常相似。   
与每个运算符都可以检查取消的响应式编程相反，您需要自己手动取消, 否则，将进一步执行该操作。  
这允许更好地控制当操作停止时，但也可能会使人难以理解为什么方法的操作不断被执行，即使它已经被取消了

若要检查代码中的取消事件，请使用 `Task.checkCancel（）` 或 `Task.isCancel`。此外，还可以使用 `withTaskCancelHandler` 方法添加要在启动取消时准确调用的取消处理程序。  



## 4. 背压支持 
> 有一个带有滑块的用户界面，当用户与其交互时，滑块会发出值。它旁边有一个标签，应始终显示当前选定的值。现在，当用户滑动时，流会发出值。虽然第一个更新仍在计算新文本，但第三个更新已经可用。因此，我们可以安全地忽略更新 2，如果不立即丢弃它，那么计算其结果将是浪费资源。  

#### 闭包 
这需要通过其他方式实现，并没有默认实现方式 

#### Combine 
支持。这是Combine 与其他反应式编程库（例如 RxSwift 和 ReactiveSwift）的主要区别  

#### Async/Await 
支持。 当您迭代异步序列时，如果 for 循环体仍在使用流的先前值中，则中间值会自动丢弃。    



## 5. 多任务支持  
#### 闭包  
通过 `NSLock` or `DispatchSemaphore`实现，此外，如果不仔细考虑，涉及对来自不同执行上下文的变量进行非独占访问的问题很容易出现。  


#### Combine  
提供了一组开箱即用的运算符, 例如： `map`, `flatMap`, `reduce`等。并且多个发布者还可以以不同的方式组合， 例如： `marge`或者`combineLast`，`zip`等   
Combine 的运算符不如`RxSwift`或`ReactiveSwift`的丰富。如果您严重依赖需要以非常规方式操作和组合的异步数据流，您可能需要看看第三方组合扩展库或这些替代反应式编程库。
  

#### Async/Await 
`AsyncSequences`有许多可用的 Swift 常见序列运算符（包括`map``,`flatMap`和`reduce`等）  


## 6. 上下文切换  
有些操作只需要在主线程上执行，而更多计算密集型任务需要在后台线程上运行。如何确保代码使用闭包、Combine 或 async/await 在特定的执行上下文中执行？  

#### 闭包 
通过`DispatchQueue`中的`sync`和`async` 在不同的上下文中执行 

```swift 
func doSomething(completion: @escaping (Result<String, Error>) -> Void) {
    DispatchQueue.global(qos: .background).async {
        doAnotherThing { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}

```

#### Combine  
` receive(on:) ` 允许切换上下文执行
```swift 
func doSomethingPublisher() -> AnyPublisher<String, Error> {
    doAnotherThingPublisher()
        .subscribe(on: DispatchQueue.global(qos: .background))
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}
```


#### Async/await  
更改为后台线程是通过创建具有适当优先级（或根本没有）的新任务来完成的，当切换到主线程是使用 `MainActor.run` 完成的，可通过标记方法及属性为`@MainActor`来直接切换到主线程执行  
```swift 
func doSomething() async throws -> String {
    let task = Task(priority: .background) {
        let returnValue = try await doAnotherThing()
        
        // This makes sure that the return value is returned on the main thread.
        // In many cases, it might, however make more sense to mark variables 
        // that should only be set on the main thread with `@MainActor`.
        return await MainActor.run { returnValue } 
    }
    return try await task.value
}
```


## 转换  

我们已经查看了所有功能，您可能想尝试一种新方法。但是重写整个应用程序需要大量工作，并且可能会引入新的错误。因此，让我们看看如何使用一种样式仅编写应用的一部分，直接转换使用来自其他样式之一的应用。我们从如何转换闭包或合并发布商以在异步/等待上下文中使用开始。有关所有可能的方法及其最优雅转换的完整列表，请查看我们的要点：[这里](https://gist.github.com/quickbirdstudios-eng/86ecd59f14e2d6f8c1c6d5a7df95b588)



#### Async/await  
将基于闭包的操作转换为 async/await 是使用以下四种机制完成的： 
1. Single-Value Non-Throwing:  
```swift
await withCheckedContinuation { continuation in
    doSomething { value in
        continuation.resume(returning: value)
    }
}

```

2. 单值有异常抛出：
```swift 
await withCheckedContinuation { continuation in
    doSomething { result in
        continuation.resume(with: result) 
    }
}

```
3. 多值不抛出 
```swift 
AsyncStream { continuation in
    doSomething { update in
        continuation.yield(update)
        // you might want to call `continuation.finish()` at some point!
    }
}

```
4. 多值有异常抛出 
```swift
AsyncThrowingStream { continuation in
    doSomething { value in
        switch value {
        case let .success(success):
            continuation.yield(success)
        case let .failure(error):
            continuation.yield(with: .failure(error))
        }
    }
}

```



#### To Closures  
1. async/await    
    通过` MainActor.run { ... } ` 在不同的时期调用回调   
```swift 
func doSomething(handler: @escaping (Result<Value, Error>) -> Void) {
    Task {
        do {
            // this could of course also be a for-await-in-loop
            let value = try await doSomething() 
            await MainActor.run { handler(.success(value)) }
        } catch { 
            await MainActor.run { handler(.failure(error)) }
        }
    }  
}

```

2. Combine  
    可以通过` sink(receiveCompletion:receiveValue:) ` 订阅任意发布者  
    由于 Combine 订阅已取消，因此当该方法的结果（其可取消）被解除分配时，您需要确保在订阅完成之前保留对它的引用。  
    ```swift 
    func doSomething(handler: @escaping (Result<Value, Error>) -> Void) {
    var cancellable: Cancellable?
    cancellable = doSomethingPublisher()
            .sink { completion in
                    switch completion {
                case let .failure(error):
                    handler(.failure(error))
                case .finished:
                    break
                }
                /* this is simply to ignore Swift's warning `Variable 'cancellable' was written to, but never read` */  
                _ = cancellable 
                cancellable = nil
            } receiveValue: { value in
                handler(.success(value))
            }   
    }   
    ```
    > 当订阅的可取消未在任何地方引用时（与 RxSwift 不同），订阅将被取消。因此，请记住保留接收器呼叫中的可取消功能。



## 总结 
1. 回调的方式很容易使代码难以阅读和维护，不提供取消支持，并且组合多个数据流非常困难。   
2. 响应式编程提供了上述所有功能，同时还添加了一些样板代码。真正开始编写反应式代码并理解某些运算符的差异需要相当长的学习曲线。  
3. Async/await 是一个新事物， 它使代码非常易于阅读并减少了样板代码。








```swift 
import _Concurrency
import Combine
import Dispatch
import Foundation

// MARK: General
struct SomeError: Error {}

extension AnyPublisher {

    init(builder: @escaping (AnySubscriber<Output, Failure>) -> Cancellable?) {
        self.init(
            Deferred<Publishers.HandleEvents<PassthroughSubject<Output, Failure>>> {
                let subject = PassthroughSubject<Output, Failure>()
                var cancellable: Cancellable?
                cancellable = builder(AnySubscriber(subject))
                return subject
                    .handleEvents(
                        receiveCancel: {
                            cancellable?.cancel()
                            cancellable = nil
                        }
                    )
            }
        )
    }

}

extension Task: Cancellable {}

// MARK: Original Methods
enum AsyncAwait {

    static func doSomething() async -> String {
        String()
    }

    static func doSomethingThrowing() async throws -> String {
        String()
    }

    static func doSomethingMore() -> AsyncStream<String> {
        AsyncStream { continuation in
            continuation.yield(String())
            continuation.yield(String())
            continuation.finish()
        }
    }

    static func doSomethingMoreThrowing() -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(String())
            continuation.finish(throwing: SomeError())
        }
    }

}

enum Combine {

    static func doSomething() -> AnyPublisher<String, Never> {
        Just(String()).eraseToAnyPublisher()
    }

    static func doSomethingThrowing() -> AnyPublisher<String, SomeError> {
        Just(String()).setFailureType(to: SomeError.self).eraseToAnyPublisher()
    }

    static func doSomethingMore() -> AnyPublisher<String, Never> {
        Just(String()).eraseToAnyPublisher()
    }

    static func doSomethingMoreThrowing() -> AnyPublisher<String, SomeError> {
        Just(String()).setFailureType(to: SomeError.self).eraseToAnyPublisher()
    }

}

enum Closures {

    static func doSomething(completion: @escaping (String) -> Void) {
        completion(String())
    }

    static func doSomethingThrowing(completion: @escaping (Result<String, SomeError>) -> Void) {
        completion(.success(String()))
    }

    static func doSomethingMore(update: @escaping (String) -> Void) {
        update(String())
        update(String())
    }

    static func doSomethingMoreThrowing(update: @escaping (Result<String, SomeError>) -> Void) {
        update(.success(String()))
        update(.failure(SomeError()))
    }

}

// MARK: Async/Await to Combine
enum AsyncAwaitToCombine {

    static func doSomething() -> AnyPublisher<String, Never> {
        AnyPublisher { subscriber in
            Task {
                let result = await AsyncAwait.doSomething()
                subscriber.receive(result)
                subscriber.receive(completion: .finished)
            }
        }
    }

    static func doSomethingThrowing() -> AnyPublisher<String, Error> {
        AnyPublisher { subscriber in
            Task {
                do {
                    let result = try await AsyncAwait.doSomethingThrowing()
                    subscriber.receive(result)
                    subscriber.receive(completion: .finished)
                } catch {
                    subscriber.receive(completion: .failure(error))
                }
            }
        }
    }

    static func doSomethingMore() -> AnyPublisher<String, Never> {
        AsyncAwait.doSomethingMore().publisher
    }

    static func doSomethingMoreThrowing() -> AnyPublisher<String, Error> {
        AsyncAwait.doSomethingMoreThrowing().publisher
    }

}

extension AsyncSequence {

    var publisher: AnyPublisher<Element, Error> {
        AnyPublisher { subscriber in
            Task {
                do {
                    for try await value in self {
                        subscriber.receive(value)
                    }
                    subscriber.receive(completion: .finished)
                } catch {
                    subscriber.receive(completion: .failure(error))
                }
            }
        }
    }

}

extension AsyncStream {

    var publisher: AnyPublisher<Element, Never> {
        AnyPublisher { subscriber in
            Task {
                for await value in self {
                    subscriber.receive(value)
                }
                subscriber.receive(completion: .finished)
            }
        }
    }

}

// MARK: Async/Await to Closures
enum AsyncAwaitToClosures {

    static func doSomething(completion: @escaping (String) -> Void) {
        Task {
            let result = await AsyncAwait.doSomething()
            completion(result)
        }
    }

    static func doSomethingThrowing(completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                let result = try await AsyncAwait.doSomethingThrowing()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    static func doSomethingMore(completion: @escaping (String) -> Void) {
        Task {
            for await value in AsyncAwait.doSomethingMore() {
                completion(value)
            }
        }
    }

    static func doSomethingMoreThrowing(completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                for try await value in AsyncAwait.doSomethingMoreThrowing() {
                    completion(.success(value))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

}

// MARK: Combine to Async/Await
enum CombineToAsyncAwait {

    static func doSomething() async -> String {
        await Combine.doSomething().values.first(where: { _ in true })!
    }

    static func doSomethingThrowing() async throws -> String {
        try await Combine.doSomethingThrowing().values.first(where: { _ in true })!
    }

    static func doSomethingMore() -> AsyncPublisher<AnyPublisher<String, Never>> {
        Combine.doSomethingMore().values
    }

    static func doSomethingMoreThrowing() -> AsyncThrowingPublisher<AnyPublisher<String, SomeError>> {
        Combine.doSomethingThrowing().values
    }

}

// MARK: Combine to Closures
enum CombineToClosures {

    static func doSomething(completion: @escaping (String) -> Void) {
        var cancellable: AnyCancellable?
        cancellable = Combine.doSomething()
            .sink { value in
                completion(value)
                _ = cancellable // this is simply to ignore Swift's warning `Variable 'cancellable' was written to, but never read`
                cancellable = nil
            }
    }

    static func doSomethingThrowing(completion: @escaping (Result<String, SomeError>) -> Void) {
        var cancellable: AnyCancellable?
        cancellable = Combine.doSomethingThrowing()
            .sink { subscriptionCompletion in
                switch subscriptionCompletion {
                case let .failure(error):
                    completion(.failure(error))
                case .finished:
                    break
                }
                _ = cancellable // this is simply to ignore Swift's warning `Variable 'cancellable' was written to, but never read`
                cancellable = nil
            } receiveValue: { value in
                completion(.success(value))
            }
    }

    static func doSomethingMore(completion: @escaping (String) -> Void) {
        var cancellable: AnyCancellable?
        cancellable = Combine.doSomethingMore()
            .sink { _ in // since the subscription's completion cannot contain an error, it can only be `.finished` and therefore is irrelevant here
                _ = cancellable // this is simply to ignore Swift's warning `Variable 'cancellable' was written to, but never read`
                cancellable = nil
            } receiveValue: { value in
                completion(value)
            }
    }


    static func doSomethingMoreThrowing(completion: @escaping (Result<String, SomeError>) -> Void) {
        var cancellable: AnyCancellable?
        cancellable = Combine.doSomethingThrowing()
            .sink { subscriptionCompletion in
                switch subscriptionCompletion {
                case let .failure(error):
                    completion(.failure(error))
                case .finished:
                    break
                }
                _ = cancellable // this is simply to ignore Swift's warning `Variable 'cancellable' was written to, but never read`
                cancellable = nil
            } receiveValue: { value in
                completion(.success(value))
            }
    }

}

// MARK: Closures to Async/Await
enum ClosuresToAsyncAwait {

    static func doSomething() async -> String {
        await withCheckedContinuation { continuation in
            Closures.doSomething {
                continuation.resume(returning: $0)
            }
        }
    }

    static func doSomethingThrowing() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            Closures.doSomethingThrowing {
                continuation.resume(with: $0)
            }
        }
    }

    static func doSomethingMore() -> AsyncStream<String> {
        AsyncStream { continuation in
            Closures.doSomethingMore { value in
                continuation.yield(value)
            }
        }
    }

    static func doSomethingMoreThrowing() -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Closures.doSomethingMoreThrowing { value in
                switch value {
                case let .success(success):
                    continuation.yield(success)
                case let .failure(error):
                    continuation.yield(with: .failure(error))
                }
            }
        }
    }

}

// MARK: Closures to Combine
enum ClosuresToCombine {

    static func doSomething() -> Future<String, Never> {
        Future { promise in
            Closures.doSomething {
                promise(.success($0))
            }
        }
    }

    static func doSomethingThrowing() -> Future<String, SomeError> {
        Future { promise in
            Closures.doSomethingThrowing {
                promise($0)
            }
        }
    }

    static func doSomethingMore() -> AnyPublisher<String, Never> {
        AnyPublisher { subscriber in
            Closures.doSomethingMore {
                _ = subscriber.receive($0)
            }
            return nil
        }
    }

    static func doSomethingMoreThrowing() -> AnyPublisher<String, SomeError> {
        AnyPublisher { subscriber in
            Closures.doSomethingMoreThrowing { value in
                switch value {
                case let .success(success):
                    subscriber.receive(success)
                case let .failure(error):
                    subscriber.receive(completion: .failure(error))
                }
            }
            return nil
        }
    }

}

RunLoop.main.run()
```


