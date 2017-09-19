#Go 语言基础   

##Go 的特点  
* 并行    
Go 让函数很容易成为非常轻量的线程。这些线程在 Go 中被叫做 goroutines    
* 简洁  
* Channel    
这些 goroutines 之间的通讯由 channel[18, 25] 完成;   
* 快速  
* 安全      当转换一个类型到另一个类型的时候需要显式的转换并遵循严格的规则。Go 有 垃圾收集,在 Go 中无须 free(),语言会处理这一切;
* 标准格式化   
Go 程序可以被格式化为程序员希望的(几乎)任何形式,但是官方格式是存在 的。标准也非常简单:gofmt 的输出就是官方认可的格式;   
* 类型后置  
* UTF-8  
* 开源  

####编译运行  
`go build xxxx.go`   
`./xxxx`   

------------------------------------------------
##语言基础  
1. 变量、类型和关键字   
	Go语言中声明和赋值是两个过程,默认定义一个变量，系统会赋值此类型的null值。   
	
	~~~  
	var a int  
	var b bool  
	a = 15 
	b = true   
	
	a := 15
	b := false				//此种方式变量的类型是通过系统推断的  
	
	//成组声明  
	var (
		a int 
		b bool
	)
	
	//平行赋值 
	a , b :=  13, 25   
	
	//会被丢弃的值  
	_, b :=  12, 35   
	~~~

int 类型的值会根据系统硬件来决定， 32位系统为 32 位， 64 位系统为 64 位   

2. 常量以及枚举值的使用   
	常量在编译时被创建，只能是数字、字符串或者布尔值  
	
	~~~  
	const(
		a = iota  
		b = iota
	)
	~~~  
	其中`iota` 可用于生成枚举值， 其代表 0， 如果再次使用其值变为 1 ，(b 的值为 1)    
	


------------------------------------------------------  
##函数  














---------------------------------------------------
##包    
包是函数和数据的集合。用package 关键字定义一个包。文件名不需要与包名一致。包名的约定是使用小写字符。Go包可以由多个文件组成，但是使用相同的 package <name> 导包。

#### 创建包
	~~~
	package even  

	//可导出函数
	func Even(i int) bool {
		return i % 2 == 0
	}

	//私有函数
	func odd(i int) bool {
	
	}
	~~~
__名称以大写字母开头的是可导出的，可以在包外部调用__    

__公有函数以大写字母开头__  
__私有函数以小写字母开头__   
  

#### 构建包  
在 `$OGPATH` 下新建目录， 复制包文件到目录   

~~~ 
mkdir $GOPATH/src/even  
cp even.go $GOPATH/src/even  
go build  
go install     
~~~    


#### 测试包  
go语言的单元测试采用的是 `go  test` 命令进行测试， 此命令会执行所有的测试函数，   
测试文件在 包目录中， 被命名为 `*_test.go`    
每个测试函数都有相同的标识符，名字以 `Test`开头 ：  
`func TestXxxx(t * testing.T)`     

在测试过程中，测试需要告诉 go test 测试结果：  
	* 测试成功：
		可以直接返回  
	* 测试失败  
		1. `func (t *T) Fail()`     
			测试失败，但仍然继续执行    
		2. `func (t *T) FailNow()`   
			测试失败，中断执行，当前文件的剩余测试中断，执行下一个文件中的测试   
		3. 日志记录`func (t * T) Log(args ... interface{})`  
			Log 用默认格式对其参数进行格式化,并且记录文本到错误日志    
		4. `func (t *T) Fatal(args ...interface { })`  
			Fatal 等价于 Log() 后跟随 FailNow()。    

~~~  
package even  
import "testing"   

func TestEven(t *testing.T){
	if ! Even(2){
		t.Log("2 should be even !")
		t.Fail()
	}
}
~~~
	

### go 常用包  
go常用的默认包都在 `$GOPATH/src/pkg`目录下      

1. fmt  		  
	实现了格式化的I/O函数。   
	* %v    默认格式的值，使用 `%+v` 会增加字段名   
	* %#v   go样式值表达  
	* %T    带有类型的Go样式值表达
2. io    
	提供了原始的 I/O 操作界面      
3. bufio    
	这个包实现了缓冲的 I/O。它封装于 io.Reader 和 io.Writer 对象,创建了另 一个对象(Reader 和 Writer)在提供缓冲的同时实现了一些文本 I/O 的功能。
4. sort    
	sort 包提供了对数组和用户定义集合的原始的排序功能。     
5. strconv    
	strconv 包提供了将字符串转换成基本数据类型,或者从基本数据类型转换为字 符串的功能。
6. os  
	os 包提供了与平台无关的操作系统功能接口    
7. sync   
	sync 包提供了基本的同步原语,例如互斥锁。   
8. flag  
	flag 包实现了命令行解析   
9. encoding/json  
	encoding/json 包实现了编码与解码   
10. html/template  
	数据驱动的模板,用于生成文本输出,例如 HTML。   
11. net/http  
	net/http 实现了 HTTP 请求、响应和 URL 的解析,并且提供了可扩展的 HTTP 服 务和基本的 HTTP 客户端。    
12. unsafe  
	unsafe 包包含了 Go 程序中数据类型上所有不安全的操作   
13. reflect    
	reflect 包实现了运行时反射,允许程序通过抽象类型操作对象。通常用于处理静 态类型 interface{} 的值,并且通过 Typeof 解析出其动态类型信息,通常会返回 一个有接口类型 Type 的对象。    
14. os/exec  	
	os/exec 包执行外部命令。    
	

## 进阶   
__Go 有指针。然而却没有指针运算.在 Go 中调用函数的时候,得记得变量是值传递的__   
####创建指针  
`var p *int`  其指针默认值为 nil   
`p = & i`     p 指针指向 i 区域   
`* p = 8`     p 指针指向的区域赋值为 8    

__没有指针运算 * p ++ 操作为(*p) ++  , 是指针指向的值增加__   

####内存分配    

go中有两种形式进行内存分配,针对不同的类型，做不同的工作   
  
* new    
	分配了零值填充的T类型的内存空间，并返回其地址，一个 *T类型的值。可以用 new 创建一个数据结构的实例并且可以直接工作。

* make	  
	只能创建 slice,map 和 channel，并且返回一个有初始值(非零)的 T 类型,而不是 *T   
		  
			
		
		
	








--------------------------------------------------  
##并发   
__并行是关于性能的， 并发是关于程序设计的__    

####goroutine   
>叫做 goroutine 是因为已有的短语——线程、协程、进程等等——传递了不 准确的含义。goroutine 有简单的模型:它是与其他 goroutine 并行执行的, 有着相同地址空间的函数。。它是轻量的,仅比分配栈空间多一点点  。 而初始时栈是很小的,所以它们也是 价的,并且随着需要在堆空间上分 配(和释放)。

`goroutine` 是一个普通函数，只需要使用关键字 go 作为开头   

~~~    
ready()			普通函数调用   
go ready()		ready 作为 goroutine 运行   
~~~   

#####goroutine 引发的问题以及解决方式

~~~  
func ready(w string, sec int){
	time.Sleep(time.Duration(sec) * time.Second)
	fmt.Println(w, "is ready")
}

func main{
	go ready("tea", 2)
	go ready("coffee", 1)
	fmt.Println("i waiting")
	time.Sleep(5 * time.Second)
}  
I'm waitingCoffee is ready! 
Tea is ready!← 立刻 
← 1 秒后← 2 秒后
~~~  

__解释__: 如果没有time.Sleep 的等待，程序直接终止，任何正在执行的goroutine都会停止。为了修复此问题， 需要一种能够goroutine通讯的机制。 引入了 `channels`   

####channels   
channel 可以与 Unix sehll 中的双向管道做类比:可以 通过它发送或者接收值   
这些值只能是特定的类型:channel 类型    

* 定义一个 `channel` 时,也需要定义发送到 `channel` 的值的类型。注意,必须使用 make 创建 `channel`     

~~~  
ci := make(chan int)  
ci := make(chan string)  
ci := make(chan interface{})  
~~~ 
  
* 发送数据  
通过 `<-` 操作符来实现的   

~~~  
ci <- 1       发送整数1 到 channel ci  
<- ci 			 从channel ci 接收整数 
i := <- ci    从 channel ci 接收整数,并保存到 i 中

~~~















递归函数：  
~~~  
func rec(i int)
{
	if i == 10  return 
	rec(i + 1)  
	fmt.Printf("%d", i)
}
~~~   
  
* 作用域    
第一在函数外的是全局变量， 定义在函数内的是局部变量， 如果命名覆盖， 在函数执行的时候，局部变量会覆盖全局变量   
局部变量仅在执行定义它的函数时有效    

* 多值返回  
`func(file *File) Write(b [] byte)(n int , err error)`   
当 n ！= len(b) 时，返回非nil 的error   

* 命名返回值  
Go 函数的返回值或结果参数可以指定一个名字， 并且像原始变量那样使用， 如果对其命名， 在函数开始时， 他们会用其类型的零值初始化。



--------------------------------------------   