#Go 圣经
## 完成状态  

- [x] 编写中
- [ ] 已完成
- [ ] 维护中

## 基础概念   
* GO语言中`i++` 此种代码是语句不是表达式，所以无法使用`j = i++`这样的形式，并且不支持 `--i`这种形式
* go 赋值的几种形式  
    ```go 
    s := ""    
    var s string     
    var s = ""    
    var s string = ""   
    ```

* 一些特定的输入占位符  
    ```go
    %d      		十进制整数  
    %x,%o，%b   	十六进制，八进制， 二进制整数  
    %f,%g,%e		浮点数  
    %t				布尔  
    %c				字符  
    %s				字符串  
    %q				带双引号的字符串或者单引号的字符  
    %v				变量的自然形式 
    %T				变量的类型  
    %%				字面上的百分号标志(无操作数)
    ```  

* `&`可以返回一个变量的内存地址， `*` 可以获取指针指向的变量内容。Go语言没有指针运算，不能对指针进行加减操作   

* go 关键字  
    ```go  
    break		default	func	interface		select  
    case 		defer 		go 		map				struct  
    chan 		else		goto	package		switch  
    const		fallthrough   if 	range		type  
    continue	for			import	 return		var    
    內建常量：  
        true 		false		iota	nil  
    內建类型：  
        int 		int8		int16	int32	int64 
        float32	float64	complex128	complex64 
        bool	byte	rune	string 	error  
    內建函数：  
        make 	len		cap 	new 	append		copy	close		delete	 complex	real	imag	panic		recover  	
    ```  

* 变量可见性  
	变量在函数内定义，只能在函数内可见， 如果在函数外定义，在整个包中都可见， 如果名字以大写开头，那么在包外也可见   

* 类型声明  
	`var, const , type, func`   

* 变量声明  
	变量会进行类型推导， 进行默认值赋值，`slice, map, chan 函数，接口`对应的零值是nil； Go语言不存在没有初始化的变量   
	* 在包级别声明的变量会在main 入口函数执行前完成初始化， 局部比那两会在声明语句执行前完成初始化   
	* `:=` 默认是进行变量声明和初始化的，不过如果变量在当前作用域中生命过，那么久只有赋值特性;此操作必须要声明一个变量 
	 
		```go
		f, err = os.Open(infile)
		out, err = os.Create(outfile) 
		//第二句就是对 out 的声明，对err 的重赋值  
		
		f, err = os.Open(infile)
		f, err = os.Create(outfile)
		//此种形式就是错误的
		```
	* 简短变量声明语句只对已在同级作用域下的变量才是赋值操作等价，如果不是那么会在当前作用域下创建新的变量

* 指针   
	一个指针的值是另一个变量的地址。并不是每个值都有一个内存地址，但是每个变量必然有对应的内存地址 。 通过 `&x` 获取变量的地址，指针对应的数据类型是`*int`  
	通过指针结合 `flag`包实现命令行程序 
	 
	```go
	package main  
	
	var n = flag.Bool("n", flase, "提示信息")  
	var sep  = flag.String("s", " ", "separator")  
	func main(){
		flag.Parse()  
		fmt.Print(strings.Join(flag.Args(),*sep)) 
		if !*n{
			fmt.Println()
		}
	}
	
	```
	__必须在使用命令之前使用 `flag.Parse()`__ 以下方式使用:_`./echo -s / a bc def`_   

* __New__ 函数  
	new 函数返回的是一个指针， new可以创建任意类型变量`p := new(int)` 等，每次调用new 函数都会返回新的变量地址 __如果两个类型都是空的，类型大小为0(struct{}或者[]int)等，有可能返回相同的地址__, 尽量不要使用类型大小为o的，容易出现问题`runtime.SetFinalizer`   
	new 只是一个预定义的函数，不是一个关键字，所以可以shiyongnew重新定义为别的类型  
	`func delta(old , new int)int {return new - old}`


* 变量声明周期   
	对于在包一级声明的变量，声明周期和整个程序运行周期一致。  
	__换行写的时候，可以给末尾显示添加 `,`避免编译器自动添加换行符__ 
	  
	```go
	img.SetColorIndex(
			size+int(x * size + 0.5),
			size+int(y * size + 0.5),
			blackIndex,
		)
	```
	垃圾回收机制原理: 从每个包级变量和每个当前运行函数的局部变量开始，通过指针或引用的访问路径遍历是否可以找到该变量，如果不存在路径就对当前程序运行无影响    
	变量逃逸问题： go语言中将变量分配在堆或者栈上并不是通过new关键字来区分的，当函数运行完毕，其中局部变量有可能并不会释放，此种情况称为变量逃逸，这种变量一般在堆上创建。了解变量的生命周期对性能开发有很大帮助   

* 类型  
	一个类型声明语句声明一个新的类型，和现有类型具有相同的底层结构。新类型提供了一个方法，用来分割不同概念的类型。即使底层类型相同也是不兼容的  
	`type 类型名  底层类型`   

* 包  
	包的初始化首先是解决包级变量的依赖顺序，然后按照包级声明出现进行初始化
	针对复杂的初始化过程，可以通过`init`初始化函数来简化初始化工作，每个文件都可以包含多个init初始化函数   
	
* 作用域  

	```go  
	var cwd string 
	func main(){
		cwd , err := os.Getwd() 
		if err != nil {
			
		}
	}
	```
	go语言要特别注意作用域的问题，比如边， cwd 这个变量根本就没有值，内部会创建相同的局部变量，所以要特别注意作用域的问题   
	__标识符首字母大写 `public`, 首字母小写包作用域`可见`__


* 序列化标签  
    ```go
    type Account struct {
        Id string `json:"id"`
        Name string `json:"name"`
    }
    ```
    __结构体采用标签后，对结构体通过`json.Marshal`之后，JSON 的 key 使用的是标签中指定的，否则是引用的是字段名称__  



------------------  
## 基础数据结构  
* 基础类型
	* 数字
	* 字符 
	* 布尔型 
* 复合类型
	* 数组 
		go语言的数组是一种值类型，虽然可以修改，但数组本身的赋值和函数传参都是以整个赋值方式处理
	* 结构体  
	* 字符串  
		字符串底层是对应的字节数组，但字符串赋值只是复制了数据地址和对应的长度。不会导致底层数据的赋值
* 引用类型 
	* 指针  
	* 切片 
		切片底层也是数据类型的数组，但是每个切片有独立的长度和容量信息，切片赋值和函数传参也是讲切片头信息部分按传值方式处理(切片头包含底层数据的指针，所以赋值也不会导致底层数据的复制)
	* 字典  
	* 函数  
	* 通道
* 接口类型

__除了闭包函数以引用的方式对外部变量访问之外， 其他赋值和函数传参都是以传值的方式处理。__  


### 数组     
* 数组的定义方式
    ```go 
    var a [3]int 					    //3个元素， 都为 0  
    var b = [...]int{1,2,3}				//3个元素，1， 2， 3  
    var c = [...]int{2:3,1:2}			//3个元素，第一个元素默认的 0 ，第二个元素 2， 第三个元素为3
    var d = [...]int{1,2,4:5,6}		//6个元素，1，2，0，0，5，6
    ```  
    数组可以定义 字符串数组， 结构体数组，函数数组，接口数组，管道数组  

* 空数组  
	空数组是不会分配内存的，虽然很少使用，但是可以用于强调某种特有类型的操作时避免分配二外的内存空间。  
	
	```go 
		//用于管道的同步操作
		c1 := make(chan[0]int) 
		go func(){
			c1<-[0]int{}//  
			c1<-struct{}{}		//一般采用无类型结构体代替空数组
		}()
		<- c1
	```
* 打印数组详细信息    
	`%T`			//打印类型  
	`%#v`			//打印详细信息 
	
### 字符串 
* `for range` 本身不支持非 UTF8 编码的字符串遍历(不过其内部进行了转换)  
* go 字符串底层结构使 `reflect.StringHeader`定义的  

### 切片  
* 切片内部数据结构使通过 `reflect.SliceHeader`定义的   
* 切片的多种定义方式：  
	
    ```go 
    a []int					//nil 切片，和 nil 相等，表示不存在的切片
    b = []int{}				//空切片
    c = []int{1,2,3}			//是哪个元素，len和cap 都为3  
    d = c[:2]					//两个元素，len为2. cap 为3 
    e = c[0:2:cap(c)]		//两个元素，len 为2， cap 为3
    f = c[:0]					//0个元素，len为 0， cap 为3
    g = make([]int, 3)		//三个元素，len和cap 都为 3 
    h = make([]int,2,3)		//2个元素，len为2， cap 为3
    i = make([]int, 0,3)	//0 个元素，len为0， cap 为3   // cap 表示容量
    ```

* 针对切片的赋值或参数传递操作，和数组指针的操作类似，只是复制切片头信息，并不会复制底层的数据  
* 在切片开头追加：  
	__开头追加会导致内从的重新分配，导致所有元素全部复制1次，性能差很多__  
        
    ```go 
    var a = []int{1,2,3}
    a = append([]int{0},a...)
    a = append([]int{-3,-2,-1},a...)

    ```

* 针对切片的删除可以通过 `append`或者 `copy`方法实现  
* 切片删除的内存管理问题  
	删除切片的内容需要特别注意内存的引用问题，可以先将对应的内存 = nil， 然后再转为新的切片  
	
	```go 
	var a []*int{...}  
	a[len(a)- 1] = nil 
	a = a[:len(a) - 1]  
	```
* 切片类型转换  

    ```go 
    var a = []float64{3,4,6,7,8,88}
    func SortFloat64FastV1(a []float64){
        //强制类型转换 
        var b[]int = ((*[1<<20]int)(unsafe.Pointer(&a[0])))[:len(a):cap(a)]
    }

    func SortFloat64FastV2(a []float64){
        //通过 更新切片头部信息实现转换  
        var c []int 
        aHdr := (*reflect.SliceHeader)(unsafe.Pointer(&a))
        cHdr := (*reflect.SliceHeader)(unsafe.Pointer(&c))
        *cHdr = *aHdr 
    }
    ```

* Go 中非0大小数组的长度不得超过2GB，需要针对数组元素的类型大小计算数组的最大长度范围(【】uint8最大2GB，[]uint16最大1GB，以此类推，[]struct{} 数组长度可以超过2GB)  



## 复合数据结构  
__在main 函数没有执行之前，包的变量常量初始化以及init函数的执行等操作都是在同一个 goroutine中，如果 init 函数中使用 go 启动新的 goroutine，新的goroutine只有在 mian 函数之后才可能被执行到__  


## 函数
* go中函数可以保持在变量中，有匿名函数和具名函数之分。包级函数一般都是 具名函数  

    ```go
    //匿名函数
    var Add  = func(a,b int) int { 
        return a  + b
    }

    ```

* 函数形参不需要每个都写出参数类型，可以将相同类型的一起声明  

    ```go
    func f(i, j, m int, s, k string)   
    ```

* go语言是通过值传递的方式调用函数的，函数的形参是实参的拷贝
* 没有函数体实现的函数声明，此函数不是由go语言实现的 
* go实现可变栈，不用担心递归的栈溢出以及安全问题，大部分语言都是64kb-2M不等的调用栈大小      
* go的垃圾回收机制会自动回收不被使用的内存，不过不包括操作系统层面的，比如文件打开， 网络连接等   
*  在函数定义上，函数的所有返回值都显示的变量名，那么该函数return语句可以生角操作数  

    ```go
    func CountWordsAndImages(url string)(words,images int,err error){
        resp, err := http.Get(url)
        if err != nil {
            return 
        }
        
        words, images = countxxxx(resp.Body)
        return 
    }
    ```

* 一个良好的程序，永远不应该发生 panic异常   
* 针对函数错误，一般如果只有一个原因，放哪慧慧的最后一个值可以是bool类型，通常命名为 ok， 表示此函数运行成功失败；如果不是那么一般是error类型的   
* go语言中将error信息认为是一种预期的值而不是异常，go的异常只针对那种未被预料到的错误   

* go针对错误的常见5种处理方式
	* 传播错误   
		子函数将错误信息传播给父函数，错误向上传递，并不是所有的错误都可以向上传递，一些需要自己加工下再传递   通过`fmt.Errorf()`函数返回一个有意义的错误信息  
	* 重新尝试失败操作  
		针对部分偶然性或不可预知的问题错误，可以通过重试操作，不过要限制重试的时间间隔和重试次数  
	* 输出信息结束程序  
		如果错误导致程序无法基础进行，那么就输出错误信息，结束程序。一般应用于main中执行，针对库函数，需要将错误向上传递    
	* 只输出错误信息
		通过log包只输出错误信息   或者标准输出流输出错误信息  
		```go
		log.Printf("xxxxxxxx", err)
		fmt.Fprintf(os.Stderr, "xxdnkagnkgna", err)
		```
	* 直接忽略掉错误信息  
		对错误信息不进行任何处理   
		
	
* 文件结尾错误 EOF  
	针对文件操作io包保证文件结束引起的错误只有一个 `io.EOF` 
	 
	```go 
	in := bufio.NewReader(os.Stdin)  
	for{
		r,_,err := in.ReadRune()  
		if err == io.EOF {
			break
		}
		if err != nil {
			return fmt.Errorf("read failed:%v",err)
		}
	}
	```   

* 函数值  
	go 中函数可以作为返回值进行返回和作为参数，函数拥有类型，和其他值一样 操作   
	函数的零值是 `nil`, 调用 nil 的函数会引起 panic 错误   
	函数值可以和 nil 比较， 但是函数值之间是不能比较的，并且不能作为 map 的key 错在   

* 匿名函数  
	匿名函数的函数只能在包级语法块声明  
	在函数内部定义的内部函数可以引用该函数的变量   
	在函数内部定义的匿名函数，不仅仅是一串代码，其还记录了函数内部的状态， 可以操作函数内部的局部变量， 因此函数值是引用类型并且不能比较(记录了函数中的状态)   
	go 采用闭包的技术实现函数值， 函数值也可以叫闭包   

* 可变参数   
	在最后一个参数类型之前添加省略号 
	  
	```go
	func sum(vals ...int){
		
	}
	```
	实际是创建了一个数组，然后将参数复制到数组中，再讲一个切片传递给函数(可变参数就是传递了一个切片)   
	针对原始类型已经是一个切片传递参数的方式：  
	
	```go
	values := []int{1,2,4,5} 
	sum(values...)	//给参数后边添加省略号, 此操作会进行解包操作,相当于传入 1， 2， 3，	```  
	可变参数和切片参数的区别：  
	```go
	func f(...int){}  
	func g([]int){}
	```
	虽然可变参数内部实际传递的是一个切片，但是和直接传递切片是不同类型  

* defer  
   defer 语句之后的代码会被延迟执行，直到包含defer语句的函数执行完毕时，defer后的函数才会执行，可以在一个函数中执行多个defer语句，defer的执行顺序是反的  
   一般用于处理成对的操作，比如打开，关闭，连接，关闭链接等等成对操作
	* 获取函数执行时间  
	* 观察函数返回值  

* panic 
	一般程序遇到panic异常，程序会中断执行，并立即执行在该goroutine中被延迟的函数，随后，程序崩溃并输出日志信息  
	直接调用panci函数也会引发panic异常，此函数接收任意类型值参数 
	尽量少使用panic 机制，应该用错误机制代替panic机制

* printStack 
	输出堆栈信息，可以在main中延迟输出堆栈信息
	  
	```go
	func main(){
		defer printStack() 
		xxxxxx
	}
	func printStack(){
		var buf [4096]byte  
		n := runtime.Stack(buf[:], false) 
		os.Stdout.Write(buf[:])
	}
	```
	__GO语言中panic机制中，延迟函数的调用在释放堆栈信息之前__  

* Recover   
	一般是不对panic异常做任何处理的，不过有时候也需要从异常中回复，至少可以在崩溃之前做一些操作。    
	recover会使程序从panic中恢复，并返回 panic value。导致panic异常的函数不会继续运行，但能正常返回  
	在未发生panic时调用recover， recover会返回nil  
	
	```go
		func Parse (intput string) (s * Syntax, err error){
			defer func (){
				if p := recover(); p != nil{
					err = fmt.Errorf("", p)
				}
			}()
			/// ......  
		}
	```
* 由于Go语言的特性，其函数栈是动态的，不会造成栈溢出等问题。Go语言中指针的地址是会变的，关于指针的操作，系统会全部搞定，所以GO 中特意没有去说明栈和堆的概念   




## 方法  
#### 函数与方法的区别：  
函数和方法没有本质上的区别，都是对代码块的封装，在定义函数时在函数名前添加变量就变为了方法   

```go
//函数   
func Distance(p, q Point) float64 {
	
}
//方法
func (p Paint)Distance(p, q Point) float64{

}
```
方法需要一个调用者，这个参数叫方法的接收器，go语言中不会使用this或self作为接收器。可以使用任意名字，不过一般采用类型的首字母小写   

__注意__  
在Go中，结构体的字段和方法时会造成冲突的，如果名称一样的话 `p.X` 字段如果还有一个同名的`X`方法， 在调用时就会出现错误   

* go 定义类型方法必须和类型在同一个包中，并且每个方法的名字是唯一的，方法和函数不支持重载      
* go 可以给任意类型定义方法(除开指针和interface)  
* go 中在包外调用函数，需要带上包名，通过包名调用   
* go 函数会对每一个参数进行拷贝，可以通过指针避免这种默认拷贝操作 
 
	```go 
	//更新接收者的属性值  
	func (p * Point)ScaleBy(factor float64){
		p.X *= factor
	}
	```
* __一般如果一个类或结构体有一个指针作为接收器的方法，那么所有的方法都应该是是指针接收器的(定义应该统一)__  
* 如果一个类型本身就是一个指针，是不允许出现在接收器中的  

	```go  
	type P *int 
	func (P) f(){}			//这种方式是错的  
	
	```
* __总结__  
	* 不论method的 receiver是指针类型还是非指针类型，都可以通过指针/非指针类型进行调用，编译器会进行类型转换  
	* 在声明method的receiver是指针还是非指针需要考虑两点：  
		* 这个对象是不是很大，如果很大，建议使用指针类型  
		* 如果使用指针类型，一定要注意copy的问题(copy 的将是地址)

* 可以通过方法表达式将方法还原为普通的函数  

```go 
var CloseFile = (*File).Close 

f, _ := OpenFile("foo.dat")  
CloseFile(f)
```


### Nil 的处理  

### 通过嵌入结构体扩展类型

```go
type Point struct{X, Y float64}
type ColoredPoint struct{
	Point 
	Color color.RGBA
}
```
__针对方法的继承，其内部会在编译器进行展开，方法的调用还是具体的类型__   


* 通过结构体嵌套，可以直接访问嵌套内的属性  
* 可以通过外部结构体实例访问内部结构体的方法   

```go  
func (p ColoredPoint) Distance(q Point) float64 {
	return p.Point.Distance(q)
}
```

* 如果结构体中是一个指针字段，那么这个指针的内容只能通过指针去取(指针取指针指向的对象中的属性)   

### 方法值和方法表达式  
#### 方法值
方法调用`p.Distance()` 其实可以分为两步的 1, 获取方法值 `dis := p.Distance`; 2, 通过方法值调用方法 `dis()`  

```go  
time.AfterFunc(10 * time.Second, func (){
	r.Launch()
})

//通过方法值调用  
time.AfterFunc(10 * time.Second, r.Launch)  
```

#### 方法表达式  
方法表达式得到的方法调用会比实际的方法调用多一个参数，方法表达式会将第一个参数作为方法接收者  

```go
p := Point{1, 2}
q := Point{4, 6}  
distance := Point.Distance  
//Distance 定义 
 func (p Point) Distance(q Point) float64 {
   
distance(p,q)   
```
在通过变量调用同一个类型的不同方法时很有用  

```go 
type Point struct {
	X, Y float64
}

func (p Point) Add(q Point) Point {
	return Point{p.X + q.X, p.Y + q.Y}
}
func (p Point) Sub(q Point) Point {
	return Point{p.X - q.X, p.Y - q.Y}
}

type Path []Point

func (path Path) TranslateBy(offset Point, add bool) {
	var op func(p, q Point) Point
	if add {
		op = Point.Add
	} else {
		op = Point.Sub
	}
	for i := range path {
		path[i] = op(path[i], offset)
	}
}
```

### Bit 数组  
一个bit数组通常会用一个无符号数或者称之为 "字"的slice来表示   
### 封装  
* go中大写字母开头的都是可以被导出的，小写字母开头的都是封装的内容  
* go语言中如果要封装一个对象，必须将其定义为一个struct  

	```go  
	type IntSet struct{
		words []uint64
	}
	tyoe IntSet []uint64  
	
	```
	以上两中方式效果相同，但是第二种会导出在所有的包中，第一种只有在SintSet中的words，所以一般推荐后一种  


## 接口  
接口类型是一个抽象类型，不会暴露内部值的结构等，只会展示自己的方法     
#### 接口类型  
接口类型的定义，go 中单方法的接口定义是以方法名的结合来的， 比如：  

```go  
type Reader interface {
	Read(p []bypte)(n int, err error)
}
type Closer interface {
	Close() error  
}

//接口内嵌  
type ReadWriter interface {
	Reader 
	Writer
}
```
#### 接口条件  
拥有接口所需要的所有方法，就实现了这个接口  

#### 接口与实现实例的关系 
接口可以用来代理实现实例，不过在实例上调用方法时，只能调用接口上定义的方法，不能调用本身的方法和其他接口的方法  

```go  
os.Stdout.Write([]byte("xxx"))  
os.Stdout.Close()  

var w io.Writer 
w = os.Stdout 

w.Wirte([]byte("xxxx"))
w.Close()				//不能，因为 w 是一个接口实例，虽然实现了Close接口，但是不能调用 Close 方法  

```
#### 接口值 
* 接口值由两部分组成: 具体的类型， 那个类型的值 (接口的动态类型和动态值) 由于go语言是静态语言，类型是编译期的概念，因此一个类型不是一个值   
* 接口的 零值 就是 它的类型和值都是 nil   

```go 
var w io.Writer 
w = os.Stdout 					//调用了一个具体类型到接口类型的隐式转换
w = new(bytes.Buffer)  
w = nil  
```
 
* 接口值 可以通过 `== nil`或者 `!= nil` 进行判断; __调用一个空接口值会产生panic__
* 一个接口值可以持有任意大的动态值(具体的还是运行时才确定的)   
* 接口值可以进行比较。 需要其具体动态类型 == 才相等。
* 接口值的比较是根据具体的类型确定的。如果具体的类型不支持比较(切片，映射类型，函数)，那么接口值进行比较将panic    
* 可以通过 `%T` 获得具体的类型名称  
	`fmt.Printf("%T\n", w)`

* __一个包含nil指针的接口不是nil 接口，其和不好汉任何值的nil 接口值不同__  

```go 
const debug  = false
func main() {
	var buf *bytes.Buffer 
	if debug {
		buf = new (bytes.Buffer)
	}
	f(buf)
	if debug {
		fmt.Printf("测试")
	}
}
func f(out io.Writer)  {
	if out != nil {
		out.Write([]byte("done!\n"))
	}
}

//默认系统会初始化 buf 为nil值， 但是在调用方法时，out是一个 类型为 bytes.Buffer 类型的nil(是一个包含空指针的非空接口)，所以判断还是为 true  
动态分配机制依然判断 Write 方法可以调用，不过这里的接收者是个nil, 对于一些类型，nil 是有效值，不过有些确不是，所以此处会panic  
如果将 buf 改为 io.Writer 就可以了
```

### 常用接口类型  
#### sort.Interface   
go 语言中的排序与具体的数据类型是没有关联的，如果要一个自定义类型支持排序操作，只需要其实现 `sort.Interface`接口就可以

```go   
type Interface interface {
	Len() int 					//序列长度
	Less(i , j int) bool 		//表示两个元素比较的结果
	Swap(i, j int)				//一种交换两个元素的方式
}

type  StringSlice [] string  //针对此类型实现接口


```
### 基于类型断言区别错误类型  
### 基于类型断言进行行为操作 
可以通过类型断言，执行必要的操作  

```go 

//通过类型断言，来判断是否执行某些操作
func writeString(w io.Writer,s string) (n int, err error)  {
	type stringWriter interface {
		WriteString(string) (n int, err error)
	}
	if sw, ok := w.(stringWriter); ok {
		return sw.WriteString(s)
	}
	return w.Write([]byte(s))
}
```  
### 类型开关  
接口的两种使用方式：  
	* 第一种就是普通的实现接口方法，重点在于方法，而不在于具体的类型上  
	* 利用接口值可以持有各种具体类型值的能力(__类似Java的面向接口编程__),利用断言用来动态区别这些类型

针对多种类型判断的简洁写法  ：

```go  
	if x == nil {
		return "NULL"
	}else if _, ok := x.(int); ok  {
		return fmt.Sprintf("%d",x)
	}  
	// xxxxxxxxxxx
	switch x.(type){
	case nil:
	case int, uint:
	case bool:
	case string:
	default:
	}

	switch x := x.(type){
		//有个变量是判断后的值
		case bool: 
			if x {
				return "TRUE"
			}
			return "FALSE"
	}
```

* Go的接口类型是延迟绑定的，可以实现类似虚函数的多态功能   




## Goroutines Channels 
Goroutine 和信通看线程不是等价的。Goroutine 的调用栈是动态的，系统线程的是固定的，一般默认为 2M，  
Go的运行时还包含一个自己的调度器。这个调度器使用了一些技术手段，可以在n个系统线程上多工调度m个 goroutine。只有在当前 goroutine发生阻塞时才会导致调度。同时发生在用户态，只保存必要的寄存器`runtime.GOMAXPROCS`用于控制当前非阻塞goroutine的系统线程数目   

 
__go 语言中的并发编程支持两种方式实现：传统方式，和channels方式__  

* CSP ： 通过值在多个不同的实例中进行传递  
* 传统模型： 多线程共享内存()
* Channels 支持“顺序通信进程”-----CSP  

### Goroutines  
go 语言中，每一个并发的执行单元叫做 goroutines. 线性调用时顺序的，并发编程两个不同的任务可能在同一时间被调用  
__goroutines 可以简单的类比为一个线程__  

* 当程序启动时， 主函数在一个单独的goroutine中运行----- main goroutine  
* 新的 goroutine 使用 `go` 语言来创建(`go f()`)
* 主函数返回时， 所有的goroutine 会被打断，程序退出 
* 除了从主函数退出或者终止程序，_没有其他方式让一个goroutine打断另一个的执行_  
* 可以通过 goroutine之间的通信来让一个 goroutine 请求其他的goroutine， 并被请求的goroutine自行结束执行  

### Channels  

* channel 是 goroutine 之间的通信机制  
* __每个channel都有一个特殊的类型，可以发送特殊数据类型__  
* channel 使用 make 函数创建, 默认值 为 nil  
	`ch := make(chan int)`      
	`ch := make(chan int, 3)` 
* 两个相同类型的 channel 可以使用 `==` 比较  
* 数据的接收和发送  
	
	```go 
	ch <- x 			//发送  
	x = <- ch			//接收 
	<- ch				// 不适用接收值
	```
* __已经关闭的channel 可以接收值，但是不能发送值，发送将 panic__  
* 在同一个 goroutine 执行 channel 的接收和发送操作将造成死锁  
* 若从一个 关闭的 channel 上接收值 将收到该 channel 返回的零值 (__注意：此处和在发送之前接收操作造成阻塞是两个概念__)

#### 阻塞 channel  
* __无缓存的channel，发送操作将导致发送者 goroutine 阻塞，直到另一个接收操作后才可以继续进行__  
* 无缓存的 不管是先接收 还是先发送 都将阻塞，直到另一方接收或者发送后才将继续执行
* __当使用 goroutine时， 需要注意main 需要在保证其他完成时才推出，不然会造成无法推出的问题，可以通过 channel保证  

```go 
done := make(chan struct{}) go func() {
io.Copy(os.Stdout, conn) // NOTE: ignoring errors log.Println("done")
done <- struct{}{} // signal the main goroutine
}()
mustCopy(conn, os.Stdin)
conn.Close()
<-done // wait for background goroutine to finish
```	

#### 串联 channel   
* channel 可以将多个 goroutine 连接在一起，一个channel 的输出作为下一个 channel 输入(__管道__)  
* 当一个channel 关闭后，其之后的接收操作将不会阻塞  
	`X, ok := <- chan` //通过此种方式判断channel是否关闭  
* 重复关闭一个 channel 将导致 panic， 关闭一个 nil 也将导致 panic

 	
#### 单方向的 channel  
如果通过正常的关系传递的 channel ， 无法保证其在函数内部的操作，可能会给一个只接收的channel进行数据传入了  
通过单向 channel 定义   
`func text(out chan<- int, in <-chan int)` out 可输入， in 输出	
#### 带缓存的 channel  
内部持有一个元素队列。如果内部缓存满了将阻塞，直到另一个 goroutine接收后释放  

* 使用 `cap(ch)` 获取 channel 缓存大小  
* 使用 `len(ch)` 获取 channel 内部有效元素大小
	
### 并发循环 

```go 
// 统计次数
func makeThumbnails3(filenames [] string) int64  {
	sizes := make(chan int64)
	var wg sync.WaitGroup
	for f := range filenames {
		wg.Add(1)

		go func (f string)  {
			defer wg.Done()
			thumb , err := thubmnail.ImageFile(f)
			if err != nil {
				return
			}
			info, _ := os.Stat(thumb)
			sizes <- info.Size()
		}(f)
	}

	go func ()  {
		wg.Wait()
		close(sizes)
	}()

	var total int64
	for size  := range sizes {
		total += size
	}
	return total
}

```

### Select 实现多路复用  
```go  
selec {
	case <- ch1:  
	case x := <- ch2: 
	case ch3 <- y:  
	default: 	
}
```

* 每一个 case 都是一个通信操作  
* select 会等待case中能够执行的case 时去执行   
* 一个没有任何 case 的 select 语句写为 select{}， 会永远的等待下去  
* 多个 case 同时就绪， select会随机选择一个执行  
* 对一个 nil 的 channel 进行数据发送和接收将永远阻塞，在select中操作nil 的channel，永远都不会被select到   



## 基于共享变量的并发  
* 导出包级别的函数一般情况下都是并发安全的。由于package级的变量没法被限制在单一的goroutine， 所以修改这些变量 "必须"使用互斥条件


* __数据竞争：会在两个以上的 goroutine并发访问相同的变量且至少其中一个为写操作时繁盛__     
	* 避免从多个goroutine 访问变量  
	* 不要去写变量  
	* 允许多goroutine 访问变量，但是在同一时刻最多只有一个 goroutine 访问  

* 二元信号量: 只能为 0 或 1 的信号量。  
* 临界区： Lock 与 Unlock 之间的代码为临界区  ,goroutine 在结束后释放锁是必须的 ， 可以通过 defer 来调用 Unlock 解锁   
* Go 语言没有重入锁，无法对一个已上锁的mutex 来在此上锁，将导致程序死锁   
* Go 通过 `sync.RWMutex` 类似是吸纳多读单写锁(读并发，但是写会完全互斥)     
* RWMutex 只有当获取锁的大部分goroutine 都是读操作，而锁在竞争条件下，也就是说，goroutine 们必须等待才能获取锁的时候，RWMutex才是最好的。RWMutex 需要更复杂的内部记录，所以比一把的无竞争锁的mutex 慢一些(简单理解就是读无🔐，写有🔐)
* 通过`sync.Once` 来执行一次性代码，原理就是通过一个 互斥量 mutex 和 boolean 变量几率初始化是否完成；互斥量用来保护boolean 变量和客户端数据结构 
* 通过添加 `-race` 运行参数，运行go 竞争检查器 ，针对共享变量进行检测 

### Goroutine 和线程  
* 每一个 OS 线程都有一个固定大小的内存块作为 栈(2M)
* 一个goroutine 是以一个 2kb 的栈开始的，但是其是动态的，最大可以为 1G   
* OS 是通过系统内核进行线程调度，每几毫秒， 硬件计时器会中断处理器，调用`scheduler`内核函数
* go 采用的是自己的调度器，使用 m:n 调度，在n 个操作系统线程上调度 m 个goroutine。
* go 采用的不是硬件定时器，而是根据语言本身进行调度，比如: 调用 time.Sleep 或者 channel 调用或mutex 阻塞等。调度器使其停止并运行下一个 goroutine(不需要内核上下文切换)  
* go 调度器使用 `GOMAXPROCS` 参数来决定需要多少个系统线程(__默认为CPU核心数__)  
* __I/O 或 系统调用 或 调用非 GO 语言函数，需要一个单独的系统线程 不计入 `GOMAXPROCS` 中__   
* goroutine 没有ID  


## 包和工具  
* 查看标准包的数量  
	`go list std | wc -l`  
* 包路径可以通过组织或者互联网域名作为前缀，可以有效的避免冲突  
* 包名不包含版本后缀   
* 可以在导入包时自定义包名避免包名重复的问题   
* 通过包 匿名导入 避免编译器报错(`import _ "image/png"`)  

### 工具  
* `GOOS` 用于指定目标操作系统  
* `GOARCH` 用于指定处理器类型   
* `go install` 保存每个包的编译成果  
* 通过添加注释来实现目标编译： `// +build linux darwin`  
* 包注释可以放在单独的文件中，`doc.go`   
* 一个 包含 internal 字段的路径会被做特殊处理， __一个internal包只能被和 internal 目录在同一个父目录的包所导入__   
* `go list ` 查询包  

```go 
	go list ... //查询当前目录下的所有可用包  
	go list xxx/...  查询特定目录下的所有包  
	go list ...xml... 查询带有特定字符串的包    
	go list -json hash  查询包的元数据信息  	
```
## 测试  
* go 语言的测试通过 `go test` 命令来实现  
* 所有的执行测试代码的go源文件都是以 `*_test.go` 结尾的   
* 一般的测试分为三种函数： `测试函数`，`基准测试函数`,`示例函数`   
* 测试函数： 以 `Test` 为函数前缀的(用于测试函数逻辑)  
* 基准测试函数： 以 `Benchmark` 为函数前缀(衡量函数的性能)    
* 示例函数： 以 `Example` 为函数前缀(提供保证正确的示例文档)     

###测试代码  
* 测试函数  

```go
func TestName(t *testing.T){}

```

  
## 反射  
__在运行时更新变量，检测值，调用方法等一个编译时不知道具体类型的变量__  

* 将具体的类型转变为接口形式后一个隐式转换过程，会创建一个包含两个信息的接口值： 操作的动态类型和动态值   
* `reflect.Type`  类型   
* `reflect.Value` 获得值  
* 通过 `%T` 可以快速打印一个 对象的 类型  
`fmt.Printf("%T\n", 3)   //  int`
* 通过 `%v` 可以快速打印 数值   

```go
v := reflect.ValueOf(3)			
fmt.Println(v)			"3"
fmt.Println("%v\n", v)	"3"  
fmt.Println(v.String())	"<int Value>"		//由于本身不是字符串，所以打印类型

```

* `reflect.Type`和`reflect.Value` 都实现了`fmt.Stringer` 接口，除非Value 等持有的是字符串，一般都是返回具体的类型
* 通过 `reflect.ValueOf(x)` 返回的 reflect.Value 都是不可取地址的  
* 通过 `reflect.ValueOf(&x).Elem()` 来获取任意变量x 对应的可取地址的Value  
* 通过`reflect.Value`的 `CanAddr` 方法来判断是否可以被取地址  
	`a.CanAddr()`  
* 通过指针间接的获取的 reflect.Value 都是可取地址的，即使开始时不是可取地址的 Value   
* 通过变量对应的可取地址的 reflect.Value 访问变量：  
	* 调用 `Addr()` 方法,返回一个 Value，保存了指向变量的指针
	* 在 Value 上调用 Interface() , 返回一个 Interface{} ,
	* 使用类型断言机制，得到interface{} 类型的接口强制转为普通的类型指针  
	
	```go 
	x := 2  
	d := reflect.ValueOf(&x).Elem()  		// 
	
	px := d.Addr().Interface().(* int)  	//断言 px := &x
	*px = 3    //通过指针修改其值   
	//或者 
	d.Set(reflect.ValueOf(4))
  	
	```
* 在通过反射进行值修改时， 必须数据类型相对应，不然会 panic 的  
* 通过对一个不可取地址的 reflect.Value 调用Set 方法也会导致 panic 异常  
* SetInt 等方法会尽量的去完成任务，只要底层的数据类型对应就可以，不过__对于一个引用interface{}类型的 reflect.Value 调用Setxx 会导致panic, 即使那个 interface {} 变量对应整数类型也不行  
* 利用反射机制可以查看结构中未导出的成员，但是不能修改未导出的成员    
	```go
	stdout := reflect.ValueOf(os.Stdout).Elem()  
	fmt.Println(stdout.Type())  
	fd :=stdout.FieldByName("fd")  
	fmt.Println(fd.Int())  
	fd.SetInt(2)
	```
* 通过`reflect.CanSet` 检测是否可取地址并被修改      
* 通过 `defer` 中定义 recover 实现 函数中 panic 的捕获  
	```go 
	defer func(){
		if x := recover(); x != nil {
			err = fmt.Errorf("error at %s:%v", lex.Scan.Position, x)
		}
	}()
	```

####获取结构体字段信息  
* `reflect.Type.Field` 方法返回一个 `reflect.StructField` ，包含每个成员的名字、类型和可选的成员标签等信息  
* 成员标签对应`reflect.StructTag` 类型字符串，通过 Get 方法进行解析     
* 通过 `reflect.Value.Method` 获取任意值的方法，通过 `Type` 获取任意值的类型  
* 通过`reflect.Value.Call` 调用一个 Func 类型的 Value   



## 高级  
* `unsafe.Sizeof` 返回操作数在内存中的字节大小，可以是任意类型表达式  
* `unsafe.Alignof` 返回对应参数的类型需要对其的倍数， 通常情况下布尔和数字类型需要对其到他们本身的大小(最多8字节)，其他类型对其到机器字大小   
* `unsafe.Offsetof` 返回`x.f` 字段对于 `x` 的偏移量   
* `unsafe.Pointer` 是一个指针类型， 可以包含任意类型的地址，也可以比较并支持nil 等比较操作 ， 可以和具体的指针类型进行转化  





## Go 与 C/C++ 编程  
### Go 和 C 
go语言通过 CGO 可以和 C 语言保持交互。 CGO 通过导入一个虚拟的“C” 包来访问C语言中的函数   

```go
package main 

import "C" 
import "unsafe" 

func main() {
	msg := C.CString("Hello, world")		//将go语言字符串专为C 
	defer C.free(unsafe.Pointer(msg))
	
	C.fputs(msg, C.stdout)
}
``` 
### SWIG   
通过 SWIG 可以与C++ 进行交互。 通过此种方式，需要三个文件在同级目录下。 c++文件， SWIG文件， Go文件  

```go
#include <iostream>

void SayHello(){
	std::out << "Hello , world" << std::endl;
}

//  SWIG    hello.swigcxx  

%module  main 

%inline %{
	extern void SayHello();
%}

// Go  
package main 
import (
	hello "."
)
func main(){
	hello.SayHello()
}


```  


---------------------------------------- 
## 数据类型的创建方式以及基本操作  
#### 通过 make 创建  
* channel  
	`ch := make(chan int)`  
* map  
	`map := make(map[string]int)`


## 引用操作  
* channel  





## 并发问题的原因  
* 死锁   
* 活锁  
* 饿死 

__并发的问题都可以用一致的、简单的既定的模式来规避。可能的话讲变量限定在 goroutine内部， 如果是多个 goroutine 都需要访问的变量，使用 互斥条件来访问__   


#### sync.Mutex 和 sync.RWMutex 区别：  
sync.Mutex 是互斥锁，只要添加锁，它的读写都会获取锁等操作  
sync.RWMutex 是读写锁， 其只有在写的时候才会是互斥锁，读不会进行锁操作，所以并发更快   



__现代编译器可能会处于性能的考虑或者其他原因针对可能的代码进行顺序执行的交换等操作__  
比如：   

```go   
func (){
	x = 1 
	fmt.Println("y = ", y)
}
```
由于两者没有关系，编译器可能会在执行时交换两者的顺序

### OS 线程与 Goroutine   
* 每一个 OS 线程有一个固定大小的内存栈(2M)  
* goroutine 一般初始只有 2kb 
* OS 线程会被操作系统内核调度，每几毫秒  
* go 调度器通过 `GOMAXPROCS` 来决定操作系统线程的个数，默认为CPU核心数  
* 在休眠中或者通信中被阻塞的goroutine是不需要一个对应的线程来做调度的。在I/O或系统调用或调用非GO 函数时，需要一个对应的操作系统线程，但是其不在 `GOMAXPROCS `考虑中  
* goroutine 是没有ID 的 






  
