## 将回调改写成 async 函数
> 原理 
```swift 
// 负责回调，传递异步结果
@frozen public struct UnsafeContinuation<T, E> where E : Error {

    public func resume(returning value: T) where E == Never

    public func resume(returning value: T)

    public func resume(throwing error: E)
}

// 封装 
public func withCheckedContinuation<T>(
    function: String = #function, 
    _ body: (CheckedContinuation<T, Never>) -> Void
) async -> T

public func withCheckedThrowingContinuation<T>(
    function: String = #function, 
    _ body: (CheckedContinuation<T, Error>) -> Void
) async throws -> T

// 示例
func helloAsync() async -> Int {
    await withCheckedContinuation { continuation in
        DispatchQueue.global().async {
            continuation.resume(returning: Int(arc4random()))
        }
    }
}
```


