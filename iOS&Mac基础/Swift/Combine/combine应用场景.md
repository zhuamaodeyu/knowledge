## 对应用程序的异步代码使用 Combine
> 参见 `swift completion/ swift Combine -----> async/await`. 


## 路由通知以合并订阅者 
> 使用通知中心的发布者向订阅者发送通知。  

```swift 

var notificationToken: NSObjectProtocol?
override func viewDidLoad() {
    super.viewDidLoad()
    notificationToken = NotificationCenter.default
        .addObserver(forName: UIDevice.orientationDidChangeNotification,
                     object: nil,
                     queue: nil) { _ in
                        if UIDevice.current.orientation == .portrait {
                            print ("Orientation changed to portrait.")
                        }
    }
}

```

> Combine 形式的 

```swift 
var cancellable: Cancellable?
override func viewDidLoad() {
    super.viewDidLoad()
    cancellable = NotificationCenter.default
        .publisher(for: UIDevice.orientationDidChangeNotification)
        .filter() { _ in UIDevice.current.orientation == .portrait }
        .sink() { _ in print ("Orientation changed to portrait.") }
}
```

## 定时器(Timers with Timer Publishers) 
> 原始写法 
```swift 
var timer: Timer?
override func viewDidLoad() {
    super.viewDidLoad()
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
        self.myDispatchQueue.async() {
            self.myDataModel.lastUpdated = Date()
        }
    }
}
```


> Combine 写法

```swift 
var cancellable: Cancellable?
override func viewDidLoad() {
    super.viewDidLoad()
    cancellable = Timer.publish(every: 1, on: .main, in: .default)
        .autoconnect()
        .receive(on: myDispatchQueue)
        .assign(to: \.lastUpdated, on: myDataModel)
}
```

## KVO 

> 原始写法
```swift 
class UserInfo: NSObject {
    @objc dynamic var lastLogin: Date = Date(timeIntervalSince1970: 0)
}
@objc var userInfo = UserInfo()
var observation: NSKeyValueObservation?

override func viewDidLoad() {
    super.viewDidLoad()
    observation = observe(\.userInfo.lastLogin, options: [.new]) { object, change in
        print ("lastLogin now \(change.newValue!).")
    }
}

override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    userInfo.lastLogin = Date()
}
```

> Combine 写法 

```swift 
class UserInfo: NSObject {
    @objc dynamic var lastLogin: Date = Date(timeIntervalSince1970: 0)
}
@objc var userInfo = UserInfo()
var cancellable: Cancellable?

override func viewDidLoad() {
    super.viewDidLoad()
    cancellable = userInfo.publisher(for: \.lastLogin)
        .sink() { date in print ("lastLogin now \(date).") }
}

override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    userInfo.lastLogin = Date()
}
```



