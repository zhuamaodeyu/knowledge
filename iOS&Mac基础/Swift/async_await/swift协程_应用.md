
## 并发应用
1. 并发函数  
   ```swift 
     // 定义 
       func myFunction() async throws -> String {} 
     // 调用
       let myVar = try await myFunction()
    ```
    * async 关键字的作用
      * 它允许我们在函数体内部使用 await 关键字；
      * 它要求其他人在调用这个函数时，使用 await 关键字。
2. 并发属性 
   ```swift 
     // 定义
       var myProperty: String {
          get async {
            ...
          }
        }
       // 调用 
       print(await myProperty)
    ```
3. 并发闭包
  ```swift 
     // 定义
       func myFunction(worker: (Int) async -> Int) -> Int { } 
         // 调用
       myFunction {
          return await computeNumbers($0)
      }
  ```



## 优化 
1. 异步任务的异步执行
   ```swift 
     // 此种写法，两个任务将按照顺序执行，针对这种两个没有任何以来关系的异步任务 我们可以异步执行，两个任务将同时开始执行
     files = try await model.availableFiles()
      status = try await model.status()
   ```
   > 优化方式：
    将异步任务编组 
    ```swift 

      do {
        async let files = try model.availableFiles()
        async let status = try model.status()
      } catch {
        lastErrorMessage = error.localizedDescription
      }

      // 此处使用的是元祖， 也可以使用数组 

      let (filesResult, statusResult) = try await (files, status)


    ```
  > 优化方式2 ----- __任务组__  
    ```swift 
    Task {
        group.addTask {
          try await self.loadResultRemotely()
        }
        group.addTask(priority: .low) {
          try await self.processFromScratch()
        }    
    }
    ```



## 异步 main 
```swift 
@main
struct App {
    static func main() async throws {
        // 此处可以掉用异步函数
    }
}
```


## 针对异步任务存在关联关系
> TaskGroup
     
     
