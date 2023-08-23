## Task 
__Task是一种代表顶级异步任务的类型__  
> 任何时候你想从同步上下文运行异步代码，你都需要一个新的Task
__无论您是否保留对它的引用，任务都会运行。但是，如果您放弃对任务的引用，您将放弃等待该任务结果或取消该任务的能力。__  
__必须保存 task 才能取消任务__   

### 创建方式 
*  init 创建
* detached 创建 

> 两种创建方式异同 
> 1. 都是顶级任务，没有父任务
> 2. 通过 init 创建的任务，都会外界状态有感知，Task.detached 创建的任务无感知 
__推荐使用 `init`创建任务，一般情况下不要使用`detached`来创建__ 



### 结构化并发/非结构化并发 
* 通过 `Task` 创建的任务，是`非结构化并发`, 顶级任务的状态管理都只与自己有关
* 添加到`TaskGroup` 中的任务，是`结构化并发`， 会随着整个 TaskGroup 的取消而取消




## Task 结果及异常
```swift 
let task = Task {
    await helloAsync()
}
print(try await task.value)
```
> Task 内部抛出的任何异常都与外部无关, Task 内部抛出的任何异常都与外部无关, value 可能是结果也可能是异常

```swift 
func taskWithError() async throws {
    let task = Task {
        try await errorThrown()
    }

    do {
        try await task.value
    } catch {
        print(error)
    }
}
```


## Demo 
```swift 
class Work {
    var task: Task <(), Never >?  

      func getSteps() -> AsyncStream<Int> {
            return .init { continutation in
            continutation.onTermination = { @Sendable _ in
                self.task?.cancel()
            }
            task = Task {
                var step: Int = 0
                for _ in 0..<1000 {
                continutation.yield(step)
                try? await Task.sleep(nanoseconds: 100000000)
                step += 1
                }
            }
            }
        }
}

class TaskViewController : UIViewController  {
    var task: Task <(), Never >? 
    let worker =  Worker ()  


    func doWork() {
        print("Task began")
        task = Task {
            for await step in worker.getSteps() {
                guard  let  self  =  self  else { return } 
                print(step)
            }
        }
    }
    deinit {
        task?.cancel()
        print("deinit called")
    }
}
```






---------------------------------------------------------------------- 
# TaskGroup 
> 用于处理存在关联关系的异步任务

## 特点 
1. 会等待所有的异步Task 执行完毕再返回 

## 在 body 当中就提前等待子 Task 的执行结果 
1. 如果只关心子 Task 是否执行完，可以调用 TaskGroup 的` waitForAll` 函数。 
2. 更常见的情况是获取子 Task 的结果，这时候我们可以直接迭代 TaskGroup，或者调用 TaskGroup 的 next 函数来获取下一个已完成的子 Task 的结果(获取的结果的顺序取决于子 Task 完成的顺序，而不是它们添加到 TaskGroup 当中的顺序。). 

```swift 
// 定义一个计算 [min, max) 范围内整数的和的闭包，注意前闭后开
let add = { (min: Int, max: Int) -> Int in
    var sum = 0
    for i in min..<max {
        sum += i
    }
    return sum
}

let seg = 10 // 分段大小
let n = Int(arc4random_uniform(10000)) // 产生一个随机数，下面计算 [0, n] 内的整数和

let result = await withTaskGroup(of: Int.self, returning: Int.self) { group -> Int in
    // 计算分段和
    for i in 1...(n / seg) {
        group.addTask { add(seg * (i - 1), seg * i) }
    }

    // 如果 n 不能被 seg 整除，计算剩余部分的和
    if n % seg > 0 {
        group.addTask {
            add(n - n % seg, n + 1)
        }
    }

    // 迭代 group 的子任务结果，汇总
    var totalSum = 0
    for await result in group {
        totalSum += result
    }

    return totalSum
}

print(n)
print(result)
```


## 注意点
1. 不要把 TaskGroup 的实例泄漏到外部 
    会在所有任务结束后被销毁。  
2. 不要在子 Task 当中修改 TaskGroup





## async let 
```swift 
func getUser(name: String) async -> User {
    async let info = getUserInfo(name)
    async let followers = getFollowers(name)
    async let projects = getProjects(name)

    return User(name: name, info: await info, followers: await followers, projects: await projects)
}
```
`async let`会创建一个子 Task 来完成后面的调用，并且把结果绑定到对应的变量当中

