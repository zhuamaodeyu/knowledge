## 参考 
https://zhuanlan.zhihu.com/p/352413799

## 核心
1. `Publisher` 用于发送数据 
2. `Operators` 处理数据,返回`Publisher` 
3. Subscribers 数据流的末端,处理数据和completion事件(__默认两个`Sink` 和 `Assign`)

> Publisher ------> Operator -------> Operator -------> Subscriber 
__如果一个`Publisher` 没有`Subscriber` ，它将不会发送数据__. 



## Publisher & Subscribers 
1. Just(单次)
```swift 
Just("Hello World!").sink(receiveCompletion: { (completion) in
    print("Receive completion:", completion)
}) { (value) in
    print("Receive value:", value)
}

```

2. `assign(to:on:)`
```swift 
class TestObject {
    var value: String = "" {
        didSet {
            print(value)
        }
    }
}

["Hello", "World"].publisher.assign(to: \.value, on: TestObject())
```

3. `Future` 
```swift 
var set = Set<AnyCancellable>()

let future = Future<Int, Never>.init { (promise) in
    DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
        promise(.success(5))
    }
}

future.sink(receiveCompletion: {
    print($0)
}) {
    print($0)
}.store(in: &set)
```

4. `PassthroughSubject` 
> 也是Publisher，可以通过send方法发送数据,可以在数据流中插入subject 
```swift 
enum MyError: Error {
    case test
}
// 自定义StringSubscriber
final class StringSubscriber: Subscriber {
    
    typealias Input = String
    typealias Failure = MyError
    
    func receive(subscription: Subscription) {
        subscription.request(.max(2))
    }

    func receive(_ input: String) -> Subscribers.Demand {
        print("Receive value", input)

        return input == "World" ? .max(1) : .none
    }

    func receive(completion: Subscribers.Completion<MyError>) {
        print("Receive completion", completion)
    }
}

let subscriber = StringSubscriber()
let subject = PassthroughSubject<String, MyError>()

//第一个订阅
subject.subscribe(subscriber)

//第二个订阅
let subscription = subject.sink(receiveCompletion: { (completion) in
    print("Received completion (sink)", completion)
}) { (value) in
    print("Received value (sink)", value)
}

//通过send发送数据
subject.send("Hello")
subject.send("World")

//取消第二个订阅
subscription.cancel()

subject.send("Still there?")

subject.send(completion: .finished)


```


5. `CurrentValueSubject` 
> （Publisher） 可以读取当前数据 
```swift 
let _ = {
    //会自动取消所有加入set的subscriptions
    var subscriptions = Set<AnyCancellable>()

    //CurrentValueSubject 有初始值，当CurrentValueSubject被订阅时，订阅者马上会收到当前值
    let subject = CurrentValueSubject<Int, Never>(0)

    subject
        .sink(receiveValue: {print($0)})
        .store(in: &subscriptions)

    subject.send(1)
    subject.send(2)

    subject.value = 3

    //可以使用print operator 查看数据流
    subject
    .print()
    .sink(receiveValue: {print("Second:",$0)})
    .store(in: &subscriptions)
    
    //completion event只能通过send发送
    //subject.send(completion: .finished)

}() 
```
