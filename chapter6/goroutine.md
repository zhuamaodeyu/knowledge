# Go Goroutine 

Goroutine 是Go语言特有的并发体(线程)，其是Go语言中的一大亮点，是一种轻量级的线程。通过 `go`关键字来启动。

### 系统线程  
系统线程在这里只是指系统级的线程。 每一个系统级的线程都会有一个固定大小的栈(一般默认的是 2MB 左右)，用来保存函数递归调用时的参数和局部变量， 所以一般创建线程是有代价的，有一定的内存消耗， 这也就是不能无限创建线程的原因。这样带来了编程以及程序运上的好处，但是同时也引入了另外的问题： 1、对于很多的线程，其实不需要这么大的内存的，这就造成了很大的浪费，在运行内存还很有限的今天，这很大程度上有时候限制了系统的性能；2、在一些特殊的线程下，固定的栈内存大小，有时候却很容易造成栈溢出的问题，比如在深层次的递归操作中，就可能会引发此种问题(也不是必须的，只有达到一定的量才会引起溢出问题,这个也是由于递归算法的特性造成的)。所以一个浪费，一个又因为太小的原因，无法达到平衡

## Goroutine
goroutine 是线程却也不是线程。 说是线程是 在 Go语言中可以代表线程操作，不是线程是因为其还是和系统线程有一定的区别的。在Go语言中，一个 goroutine 启动只需要很小的栈内存启动，当需要栈内存不足时(比如深层次递归)，goroutine 会根据需要动态伸缩栈的大小，这就是goroutine 的魔力所在，在go 语言中，可以轻松启动成千上万个 独立的goroutine。其创建个数远远大于在同等内存大小下系统线程的创建个数。 goroutine 如此优秀，创建如此多个，那么又引出了新的问题，goroutine如何在有限的系统线程下运行？？？ 

#### 远大于系统线程可创建个数的goroutine如何在有限系统线程下运行？   
Go 运行时中包含一个自己的轻量级的调度器。其可以在n 个系统线程上调度m 个goroutine，通过这个轻量级的调度器，巧妙的解决了线程运行的问题     

goroutine 非常的优秀，但同时它也存在一些问题，用户无法轻易的结束一个 goroutine， 因为 groutine 只是通过 `go`关键字来启动，其语言层面没有提供其他方法等来查看goroutine的运行状态和关闭一个 gortoutine， goroutine 是无状态的，当其运行起来后我们无法很容易的停止它(__根据Go语言的规范，main 函数退出程序结束，不会等待任何后台线程__), 最典型的问题就是 程序进程已经停止，但其可能还有goroutine 在运行 ，例如：  

```go 
func main() {
	fmt.Println("--------")
	go func() {
		fmt.Println("测试")
	}()
	fmt.Println("--------")
}
```  

运行以上代码，你会发现 _测试_ 的打印是随机的,有可能会打印出来，但是很大程度上是无法看到的，因为在其打印的时候，可能 main goroutine(main 函数启动后会运行的 goroutine) 已经结束. 针对此种问题，以下内容将专门针对如何控制多个goroutine进行介绍说明    


以上内容针对 goroutine 进行了简单介绍，不过在正式内容开始之前，需要先了解下其他概念，比如：原子操作，锁操作等   

#### 原子操作  
原子操作是并发编程中“最小切不可并行化”的操作，简单理解就是 一个变量 如果是原子操作，那么此变量在同一时刻不能被两个线程所操作，原子操作在多线程环境下保证了共享资源的完整性，其保证共享变量在多线程环境下和在单线程环境下有相同的状态。在goroutine中可以通过`sync.Mutex` 通过互斥锁来进行原子操作模拟

```go  
func sync_mutex() {
	var mu sync.Mutex
	mu.Lock()
	go func() {
		println("你好，Go")
		mu.Unlock()
	}()
	mu.Lock()
}
```
__原理__  
通过 `sync.Mutex` 双层加锁来实现，在 goroutine 启动之前进行加锁操作， 在 goroutine 中的操作之后进行解锁操作，在 goroutine 启动后再次进行加锁操作，此时加锁，goroutine 还没有进行解锁操作，所以此处会进行等待，等待解锁才可能在此对相同的对象进行加锁操作(运用了互斥锁)，而如果这里进行加锁成功，那么久说明 goroutine中的执行已经全部完成并进行解锁了，所以此处保证了 groutine 的正常退出

虽然可以通过互斥锁进行原子操作的实现，不过加锁/解锁的过程代价是极大的并且效率低下，在 go 中提供了专门针对原子操作的实现 `sync/atomic` 此包是专门针对原子操作的实现  

```go   
var work uint64

func workered(w *sync.WaitGroup) {
	defer w.Done()
	var i uint64
	for i = 0; i < 100; i++ {
		atomic.AddUint64(&work, i)
	}
}

func main() {
	var w sync.WaitGroup
	w.Add(2)
	go workered(w)
	go workered(w)
	w.Wait()
}
```
通过 `sync.atomic` 包下的专门针对原子操作的方法,其从根本上保证了原子操作的正确性， 通过原子操作和互斥锁的结合这也是实现单例模式的高效方式。关于此种方式实现的单例模式会在其单独的关于单利的部分进行说明

虽然以上的两种方式可以保证线程之间的数据交互实现，并且控制线程的正常退出关系，但是通过以上的原子操作，无法解决顺序一致性的问题，无法确定两个原子操作之间的顺序关系，所以并没有很好的解决问题。


#### channel   
`channel`通信是 goroutine 之间进行同步通的主要方法。在无缓存的 channel 上的每次发送操作都必须有之对应的接收操作，并且 __发送和接收操作通常一般都发生在不同的goroutine上__，在通一个 goroutine 上操作发送和接收很容易造成死锁的。无缓存的发送操作总是在接收操作之前完成，不然接收操作只能等待发送操作的完成   
不过 __注意:__ 一般都是在 `go` 启动 goroutine 的线程上进行接收操作，在子 goroutine 上进行发送操作，虽然两者可以交换，但是这样是非常危险的(goroutine的不确定性，导致其很危险，如果发送了 异步的goroutine异常无法接收那将阻塞，如果提前发送了将阻塞主goroutine， 所以一般在异步的goroutine 中发送，可以通过 `defer` 来保证无论异常与否都一定会发送，并且如果是缓冲的 `channel`，那将更复杂)      

#### 并发  
Go 语言內建并发支持。在目前绝大多数语言中，都是通过锁等线程同步方案来解决共享资源的正确访问问题。不过Go 语言其独特的采用了将共享资源通过信道进行传递，在任意给定时刻，只有一个 goroutine 能够拥有该资源。其从根本上杜绝了共享资源竞争的问题。通过信道来更优雅的解决共享资源竞态问题


## Goroutine 控制的方式  
由于其 goroutine 的特殊性，所以在并发编程中，虽然可以通过原子性以及锁模型来解决线程之间的简单控制问题以及线程之间数据同步，但是并发编程中，很重要的一点就是必须满足 __顺序一致性内存模型__，Go语言中，在同一个goroutine中顺序一致性内存模型是可以保证的。但是在不同goroutine之间，并不满足，需要通过明确定义的同步事件来作为同步参考。

* `sync.Mutex`
    ```go
    func sync_mutex() {
        var mu sync.Mutex
        mu.Lock()
        go func() {
            println("你好，Go")
            mu.Unlock()
        }()
        mu.Lock()
    }
    ```
    __原理在原子操作部分进行了说明__   
    虽然此种方式能实现需要，但是由于采用的是互斥锁的特性，其效率低下，并不适合在实际项目中使用。并且此种方式是采用阻塞式的，必须等待另一个 goroutine 结束才能继续往下执行   
* `sync.WaitGroup`  

    ```go 
    func workered(w *sync.WaitGroup) {
        defer w.Done()
       // working 
    }

    func main() {
        var w sync.WaitGroup
        w.Add(2)
        go workered(w)
        go workered(w)
        w.Wait()
    }
    ```
    通过`sync.WaitGroup`等待来实现等待一组事件，其中 `Add` 操作与`Done`曹锁是相对应的， `Wait` 是阻塞 main 线程，等待多个 后台线程完成。其中 `Add`操作时增加等待事件个数，必须在 后台线程启动之前执行，`Done` 是完成一个事件，必须在后台任务执行完毕才能调用，不然提前调用将不能保证后台任务正确执行完毕  


* `channel`  
    * 无缓存的 channel 
        ```go 
        func main() {
            done := make(chan int)  
            go func(){
                println("你好")
                done <-1  
            }()
            <- done
        }
        ```
        此处使用了无缓冲`channel`,无缓冲`channel`的特性就是 数据接收必须在数据发送之后完成，并且在同一个 goroutine中满足顺序一致性模型， 所以 输出你好 必须在数据发送之前完成， 而数据的接收在main goroutine 中，虽然它会被先执行到，不过数据没有发送，它只能处于等待状态，阻塞main goroutine，只有在发送数据后才会接收到数据往后执行，所以程序是正常执行打印任务的   
    * 带缓存的 channel  
        ```go  
        func main() {
            done := make(chan int, 10)
            for i := 0; i < cap(done); i++ {
                go func(i int) {
                    fmt.Println("你好", i)
                    done <- 1
                }(i)
            }

            for i := 0; i < cap(done); i++ {
                <-done
            }
        }
        ```
        对于带缓存的 `channel`其 K个接收完成操作必须发生在第K + C 个发送操作完成之前，C 是 channel的缓存大小，(简单理解就是带有缓存可以进行缓存大小的发送操作而不用先进行接收，channel 会将数据进行缓存，不过当缓存满了后如果还没有进行接收操作，那么还是会阻塞的, 如果在发送的同时又对应的接收，那么久不会存储到缓存中)， 这里涉及到一个效率问题：  当接收与发送同步的时候以及接收慢于发送或者发送慢于接收时的不同情况？？？？  


* `select`  
    用于处理多个管道的发送或接收操作，在`select`有多个可选操作时，其会随机选择一个可用的管道，如果没有就使用`defalut` ,否则一直处于阻塞状态  

    ```go 
        select {
            case v:= <-in :
                // 
            case <- time.After(time.Second):
                return 
        }
    ```
    通过其与`channel`的配合下，完美高效的解决问题

#### goroutine 安全退出  
通过以上内容，针对 goroutine已经有了了解，在 goroutine 的处理过程中，还有一个很重要的问题需要解决，就是如何安全的退出 goroutine，因为 Go语言本身没有提供这两的方法，如果使用不当的方式处理，将倒是 goroutine之间的共享变量可能落在未定义的状态上。合理安全的goroutine 还是很重要的。 可以通过 `channel` 和 `select` 以及 `sync.WaitGroup`合理的配合来解决此问题  

```go 
func workers(w *sync.WaitGroup, cancel chan bool) {
	defer w.Done()
	for {
		select {
		case ws := <-cancel:
			println(ws)
			return
		}
	}
}

func main() {
	cancel := make(chan bool)
	var w sync.WaitGroup
	for i := 0; i < 10; i++ {
		w.Add(1)
		go workers(&w, cancel)
	}
	close(cancel)
	// cancel <- true 
	w.Wait()
}
```
通过以上方式，可以完美的结束任意多的线程。其中有借个细节点需要说明下， 
* `close(cancel)` 通过关闭 channel 来通知更多线程而不是通过 `cancel<-true`来结束，在整个channel 关闭后，所有的接收操作都会接收到一个 false 或者一个可选的错误值，在通道关闭后，还是可以从其中接受值，只不过再也不能发送值，发送将导致 `panic`错误，这与 通道的发送和接收相对应不冲突，__channel 只有在正常情况下，发送与接收成对出现，否则将阻塞goroutine，如果channel 关闭，将还可以接收值，不能发送__  
* `sync.WaitGroup` 的引入，因为如果直接结束 goroutine 后，其还是会执行一些对资源的回收等收尾操作，并不是当结束就马上结束，这里使用 `sync.WaitGroup`是为了避免在 所有的后台groutine 还没有处理完毕而main  goroutine 却退出了导致其后台goroutine 无法正确结束造成资源的浪费。


## Question And Answer 
#### Question 1  
带缓存的 channel  当接收与发送同步的时候以及接收慢于发送或者发送慢于接收时的不同情况？？？？  

#### Answer  
在并发编程中，虽然系统给予了我们无限的可能，但是必过不是并发越大就越好。相反，某些情况下，并发越大反而会降低系统性能。我们也需要适当的控制并发程度，也给其他程序留出必要的生存空间。  
通过带缓存 `channel `的发送和接收规则来实现最大并发的阻塞控制。在go 中并发通常会遇到以下几种情况：  
* 发送大于接收 
    当发送大于接收操作，接收操作处理不过来，`channel` 的缓存很大程度上可能处于满状态，进而阻塞整个的发送状态 goroutine ，造成资源的浪费
* 发送小于接收  
    当发送小于接收效率时，整个`channel`的都可能处于空状态处于一个饥饿状态，而接收操作必须发生在其发送操作之后，所以没有发送接收只能处于等待状态，进而阻塞了 接收所在 的goroutine，造成资源的浪费
* 发送等于接收  
    这种情况是最理想的情况，由于 `channel`的特性，其只要发送后有对应的接收操作，其不会占用缓存空间， 所以当发送和接收几乎相等时，缓存不会处于满状态进而阻塞 整个`channel`造成 goroutine的阻塞，所以这是最理想的状态

总的来说就是并不是越多越好，过而不及，合理的利用并发才是关键   





## 扩展  
 * 如何阻塞 main goroutine   
    * `select{}`   
    * `for{}`  
    * `<-make(chan int)`   
* 退出mian  goroutine   
    * `os.Exit(0)`  
    * `Ctrl + C`  
        ```
        sign := make(chan os.Signal, 1) 
        signal.Notify(sig, syscall.SIGINT,syscall.SIGTERM)
        fmt.Print("quit (%v)\n",<-sign)
        ```

## 总结  
以上就是关于 goroutine 的一些简单介绍，其中还有很多很多的细节没有介绍到位，我后续会尽量将其完善  
