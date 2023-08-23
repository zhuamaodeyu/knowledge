## swift completion --->. async/await 
1. 传统写法
```swift 
// 传统写法

func helloAsync(onComplete: @escaping (Int) -> Void) {
    DispatchQueue.global().async {
        onComplete(Int(arc4random()))
    }
}
```

2. async 写法 
```swift 

func hello() async -> Int{
      
}

```

3. 将传统转换为 async 写法 
__关键点在于`withCheckedContinuation/withCheckedThrowingContinuation`函数__ 
```swift 
// 不带异常处理版本
func helloAsync() async -> Int {
    await withCheckedContinuation { continuation in
        DispatchQueue.global().async {
            continuation.resume(returning: Int(arc4random()))
        }
    }
}
// 带异常处理版本 
func helloAsyncThrows() async throws -> Int {
    try await withCheckedThrowingContinuation { continuation in
        DispatchQueue.global().async {
            do {
                let result = try doSomethingThrows() // 可能抛异常
                continuation.resume(returning: result)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
```
---------------------

## swift completion ----> swift Combine 
1. 用 Futures 替换 Completion-Handler 闭包
```swift 
// 原始 completion 闭包写法 
func performAsyncAction(completionHandler: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline:.now() + 2) {
        completionHandler()
    }
}

// futures 实现
func performAsyncActionAsFuture() -> Future <Void, Never> {
    return Future() { promise in
        DispatchQueue.main.asyncAfter(deadline:.now() + 2) {
            promise(Result.success(()))
        }
    }
}

// 掉用方式
cancellable = performAsyncActionAsFuture()
    .sink() { _ in print("Future succeeded.") }

```

2. 针对重复掉用的 completion 转换 
> 部分 completion 会在运行阶段重复掉用多次， 例如： download progress completion
```swift 
private lazy var myDoSomethingSubject = PassthroughSubject<Void, Never>()
lazy var doSomethingSubject = myDoSomethingSubject.eraseToAnyPublisher()

cancellable = vc.doSomethingSubject
    .sink() { print("Did something with Combine.") }
```







---------------
## swift combine. ----> async/await
__Async/Await 并不是要取代 Combine__ 

1. 基于 Combine 写法 
```swift 

struct API {
    let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!
    
    func loadTodo() -> AnyPublisher<Todo, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Todo.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

// 客户点消费 combine 
class Client1 {
    var cancellable: AnyCancellable?
    let api = API()
    
    func loadTodo() {
        cancellable = api.loadTodo()
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    print("finished")
                case .failure:
                    print("failed")
                }
            }, receiveValue: { todo in
                print(todo)
            })
    }
}
```

2. 基于 async/await 写法 
```swift 
struct API {
    let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!

    func loadTodo() async throws -> Todo {
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Todo.self, from: data)
    }
}

class Client1 {
    let api = API()
    
    func loadTodo() async {
        do {
            let todo = try await api.loadTodo()
            print(todo)
            print("finished")
        } catch {
            print("failed")
        }
    }
}
```
> 优点： 可读性更高，更容易理解； 不需要保留对 Cancellable 对象的引用


3. 扩展我们的 Combine API，实现 Async/Await，同时仍然支持遗留代码的旧 API, 然后再慢慢迭代 
```swift 
// 处理 有可能在没有发出值的情况下完成问题
enum AsyncError: Error {
    case finishedWithoutValue
}

extension AnyPublisher {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        if finishedWithoutValue {
                            continuation.resume(throwing: AsyncError.finishedWithoutValue)
                        }
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    finishedWithoutValue = false
                    continuation.resume(with: .success(value))
                }
        }
    }
}
```

> 使用方式 
```swift 

struct API {
    //TODO: 还是老的写法
    func loadTodo() -> AnyPublisher<Todo, Error> {
        //...
    }
}

class Client1 {
    // 1. Make function async
    func loadTodo() async {
        do {
            // 2. Call async() on AnyPublisher / 通过 async() 函数进行转换
            let todo = try await api.loadTodo().async()
            
            //...
        } catch {
           //...
        }
    }
}

```



## 总结 
1. withCheckedThrowingContinuation函数的使用 
这是Apple 提供的功能，可帮助将基于完成的功能桥接到 Async/Await。 
2. sinking 前先掉用  first()  
通过这种方式，我们保证在收到第一个值后终止流，这意味着receiveCompletion块被调用并允许Cancellable对象被释放。多次调用延续将导致致命错误。
