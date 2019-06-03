#GO环境配置
##Go 安装    

##代码目录结构规划    
GOPATH 下的src目录是程序开发的主要目录， 所有的源码都放在此处， 一般的做法是在此目录下一个文件夹是一个项目。    

一般建议package 的名称和目录保持一致   

```Bash   
cd $GOPATH/src   
mkdir packagename  

package packagename  

```

* 编译安装(包)   
两种方式 ： 直接在对应的包目录下执行 `go install` ; 在任意目录执行`go install packagename`     
会生成一个 .a 文件，此文件就是应用包   

* 调用应用包     

```Go  
package main     

//导入包
import(
"" 
""
)

func main(){
	
}
```    

* 编译程序  
进入程序目录，执行 `go build`   
安装 ：进入该目录 执行`go install`, 在 `$GOPATH/bin` 会增加对应的文件，直接在命令行执行就OK      

* 获取 远程包  
`go get github.com/xxxx/xxxx` 
> -u  参数可以自动更新包，并且当go get 的时候会自动获取第三方的依赖包   
> 不同的代码管理托管平台采用不同的代码管理功能， 所以需要先安装对应的管理工具   

* 引入远程包  
`import "github.com/xxxx/xxx"`    

* 应用目录结构  

~~~  
bin/
    mathapp
pkg/
    平台名/ 如：darwin_amd64、linux_amd64
         mymath.a
         github.com/
              astaxie/
                   beedb.a
src/
    mathapp
          main.go
      mymath/
          sqrt.go
      github.com/
           astaxie/
                beedb/
                    beedb.go
                    util.go

~~~   

* go 基本命令   




------------------   
#Go 语言基础   

go 语言关键字 25 个

~~~  
break    default      func    interface    select
case     defer        go      map          struct
chan     else         goto    package      switch
const    fallthrough  if      range        type
continue for          import  return       var
~~~

```Go  
package main

import "fmt"  

func main(){
	fmt.Printf("Hello, world or 你好，世界 or καλημ ́ρα κóσμ or こんにちはせかい\n")
}

```   
__解释__：  
package <name> ：当前文件属于哪个包  
main 			: 表示是一个可运行包，编译会生成执行文件，除了mian包，其他包会生成 `.a` 文件，并放在`$GOPATH/pkg/$GOOS_$GOARCH`   
> 每一个可独立运行的go 程序， 都包含一个 `package main`， 在main包中必定包含一个入口函数`mian`, 此函数没有参数没有返回值   

> 包名和包所在的文件夹可以是不同的， 此处的<packageName> 即是通过 package <name> 声明的包名，并不是文件夹名    

__go 天生支持UTF-8， 并且可以额用UTF-8 任何字符作为标识符__    

* 定义变量  
使用`var`定义变量， 不过 __将变量类型放在变量名后__    
`var variableName type`   
`var vname1, vname2 type`   
`var varName = value`  
`var varname1, varname2 type = v1,v2`   

忽略变量类型：  
`var vname1,name2 = v1,v2`   

更加简洁版：  
`vname, vname2 := v1,v2`   
__:=__ 此符号只能用在函数内部，用在函数外将无法通过编译    
 
特殊变量：  

`_` 此变量任何赋予它的值都会被丢弃     
`_, b :=  34,35` //丢弃 34     

__Go会对已声明但是未使用的变量会在编译阶段报错__     

* 常量     
常量是在编译阶段定下来的值，在运行阶段不能改变其值，其可以定义为数值，布尔值，字符串等   

`const constantName = value`    

__go常量可以指定相当多的小数点位数， 若指定给float32 将自动缩短为 32bit，   

* 内置基础类型  
	- boolean    
	
	```Go    
	var isBool bool //全局声明
	var enabled,disabled = true ,false  //忽略类型声明   
	func test(){
		var abvknkng  bool //  
		valid := false  
		available = true   
	} 
	```
	
	- 数值类型    
	无符号和有五号两种。
	`rune`、`int8`、`int32`、`int64`、`byte`、`uint8`、`uint16`、`uint32`、`uint64`    
	其中 `rune` 是`int32` 的别称， `byte` 是`uint8` 的别称   
	__虽然是别称，但是这些变量之间不允许互相赋值__     
	- 浮点型    
	支持3种形式， `float32`、`fload64`、`complex128`(复数)    
	`complex64` (32位实数 + 32位虚数)， 复数形式为 `RE+IMi`  
	其中Re是实数部分， IM是虚数部分， i是虚数单位   
	`var c complex64 = 5 + 5i`    
	- 字符串  
	"" , '' 
	字符串是不可变的， 如果要改变字符串中的字符，字符串----> 字符数组----->字符串      
	
	~~~
	s := "xxxx"
	c := []byte(s)
	c[0] = 'c'
	s2 :=string(c)   
	
	对字符串进行切边   
	s = "c" + s[1:]
	~~~   
	
	- 开发小技巧  
	声明变量，导包可以分组进行   
	
	~~~   
	import (
		"fmt"
		"os"
	)
	
	const(
		i = 100
		pi = 3.1415
	)
	
	var(
		i int
		pi float32 
		prefix string
	)
	~~~   
	
	- iota 枚举  
	用来声明枚举值，const 中每增加一行加1    
	
	~~~  
	const(
		x = iota	//x == 0
		y = iota 	//y == 1
	)
	
	const v = iota //每次遇到construction关键字，iota就会重置   
	
	const(
		e,f,g = iota,iota,iota //同一行值相同   
	)
	~~~  
	> 除非显示设置为其他值， 每个const分组默认第一个值为0， 第二个及后续的常量被默认设置为它前面的那个常量的值，如果前面的值为iota， 它也被设置为iota。  
	
	- GO 的一些规范   
		* 大写字符开头的变量是可导出的，在其他包可以读取，公有变量  
		* 小写字母开头的是不可导出， 私有变量     
		* 大写字母开头的还是也一样，相当于public，公有函数  
		* 小写字母为private，私有函数   
	
	- array、slice、map   
		`var arr [n]type`    
		`var arr [100]int`   
		__数组不能改变长度， 并且数据赋值传入的是数组的副本，而不是指针__    
		`a := [3]int{1,2,3}`  
		`a := [...]int{1,3,4}` //根据元素个数计算长度       
		
		动态数组： `slice` 并不是真正意义上的动态数组，而是一个引用类型
		总是指向一个底层 `array`，可以像数组一样声明，只是不需要长度   
		`var fslice []int`   
		`var := []byte{'a','b'}`   
		`slice := []byte{'','',''}`    
		slice 可以从一个数组或一个已经存在的slice再次声明。    
		slice 通过array[i:j] 获取，其中i是开始，j是结束，但不包括 j    
		> slice 和数组区别：数组声明必须写数组长度或者自动计算， slice不需要  
		![](/assets/Snip20161209_17.png)     
		  
	`slice`简单操作：	        
		- slice 默认开始位置为0， `ar[:n]` 等价于`ar[0:n]`   
		- slice 第二个序列默认是数组长度， `ar[n:]` 等价于`ar[n:len(ar)]`   
		- 如果从一个数组里面直接获取`slice`, 可以这样`ar[:]`,默认第一个是序列0，第二个是数组长度`ar[0:len(ar)]`     
	内置函数  
		`len`,       
		`cap`：获得做大容量  
		`append`： 追加元素     
		`copy`: 返回复制的元素个数   
	__append 会改变slice所引用的数组内容，从而影响到引用同一数组的其他slice。但当slice没有剩余空间，此时将动态分配新的数组空间。返回slice数组指针指向这个空间，原数组的内容将保持不变，其他引用此数组的slice不受影响。__   
	
	
	__`map` 类型是线程不安全的__     
	
	- make , new 操作   
	make用于內建类型，的内存分配， new用于各种类型的内存分配     
	make 只能用于创建`slice`、`map`、`channel`并且返回一个有初始值的T类型。__这三种数据类型在指向数据结构的引用在使用事前必须被初始化。
	- 零值   
	并非是空值， 而是一张变量未填充钱的默认值，通常是0，   
	
	~~~  
	int 			0
	int8			0
	int32			0
	int64			0
	uint			0x0
	rune			0
	byte			0x0
	float32		0
	float64		0
	bool			false
	string			""
	~~~   

* 流程和函数    
Go语言分为3种：		
	- 条件判断   	
	- 循环控制  
	- 无条件跳转     
	go语言允许在条件判断语句中声明一个变量，这个变量作用于只能是该逻辑内    
		* __if__    
	
			~~~  
			if x := computedValue(); x > 10{
		
			}else{
		
			}
			~~~  
		* __goto__    
			用goto跳转到当前函数内定义的标签   
			
			~~~   
			func myFunc(){
				i := 0
			Hear:   
				println(i)  
				i++
				goto Hear			
			}	
			~~~   	
			> 标签名是大小写敏感的    

		* For 循环   
		当for 循环省略了第一个第三个参数时，就变成了while循环了  
		`break`: 		跳出当前循环   
		`continue`:	跳过本次循环    
		
			~~~  
			for k,v:= rang map{
			
			}
			
			for _,v := rang map
			{
			
			}  
			~~~   
		
		__go 支持多值返回，对于生命而未使用的变量编译器报错，可以通过 `_` 来丢弃不需要的返回值__      
	
		* switch   
			默认带有break效果，不会造成穿透效果，可以多个值同事匹配
			`fallthrough` 强制带有穿透效果     
    



* 函数    
	通过`func` 声明，  可以返回多个值   
	
	~~~  
	func funcName(input type1, input2 type2)(output1 type1, output2 type2){
	
	return value1, value2
	}
	~~~    	
	
	- 可有有多个参数  
	- 函数可以返回多个值  
	- 可以不需要返回值名，直接使用类型   
	- 如果只有一个返回值，且不声明返回值变量，可以省略返回值的括号等   
	- 如果有返回值，必须要return返回   
	
__变参__    
	`func myfunc(arg ...int){}`      
	接收不定的参数，并且类型为int	

__传值与传指针__    
一般传值穿的是这个值得copy，  

传指针   

~~~  
func add(a *int){
	*a = *a +1
}   
//使用   
x1 := add(&x)   //传入指针

~~~   

__关于go语言中指针的使用__：
1. 传指针使得多个函数能操作同一个对象     
2. 传指针比较轻量级(8bytes),只传内存地址，可以用来传体积大的结构体， 节省时间和内存    
3. go语言中的`channel`, `slice` , `map` 三种实现机制类似于指针， 可以直接传递，不用取地址传递。( __若函数需要改变slice的长度， 则仍需要取地址传递指针__)

* defer    

延迟语句， 当函数执行到最后时， 这些defer语句会按照逆序执行，最后该函数返回     

~~~  
func ReadFile() bool
{
	file.Open("file")
	defer file.Close()  
	
	if failureX{
		return false 
	}
	
	return true
}

~~~  
如果多处调用 defer ，defer采用的是__后进先出__模式

* 函数作为值，类型   

`type typeName func(input1 input1Type, )()`    


* Panic Recover   

Go 语言没有异常机制， 不能抛出异常，使用的是 `Panic` 和 `Recover` 机制。__一般尽量写没有此机制的代码__   

`Panic` 是一个內建函数， 可以终端原有的流程， 函数中的延迟函数会正常执行，然后返回到调用它的地方。直到发生painc的goroutine中所有调用函数返回    
`Recover` 是一个內建函数， 可以让仅需恐慌的流程回复过来。recover仅在延迟函数中有效， 正常函数调用会返回 nil    

* main 和  init 函数   
init 可以额用在所有的包， mian只能用在main包。函数定义时不能有任何参数和返回值 。
go 程序会自动调用这两个方法。不需要再任何地方调用这两个函数。  
一个包只会导入一次，不论几个文件导入

* 导包的几种方式  
	- 常用方式    
	`import ("" "")`  
	- 绝对路径，相对路径   
	- 点操作   
		`import (."fmt")`  
		点的含义就是在调用此包的函数时，不需要写前缀包名   
	- 别名
		`import ( f "fmt")`   
	- _操作   
		`import(_ "github.com/xxx/xxx/xxx")`    
		此操作的含义是引入该报，而不直接使用其中的函数，调用该包的init函数



* struct  结构体  

~~~   
type person struct{
	name string
	age int
}

~~~  
结构体赋值：  

~~~
var P person   
P.name = ""   

P := person{"",25}
P := person{name:"", age:25}   
根据new 分配一个指针   
P := new(person)		//P 类型为*person  

~~~


匿名字段：  
Go支持只提供类型， 而不懈字段名的方式， 匿名字段， 嵌入字段    
当匿名字段是一个struct的时候， 那么这个struct所拥有的全部字段都被隐式引入到当前定义的这个struct中

   

__注意__: 针对父struct中属性与子struct中属性冲突， 父优先级高    



###面向对象   
* method    
是复数在一个给定的类型上的， 语法和函数的声明语法一帮。只是在func 后面增加`receiver` (method 所依赖的主体)     

`func (r ReceiverType) funcName(parameters)(results)`   

有一下几点需要注意的：   
	* method的名字可能一样，但是接受者不同，method就不同   
	* method里边可以访问接受者的字段  
	* 调用method 通过`.` 访问， 就像struct里面访问字段一样   



    








   



----------------    
难点： 异常的处理，原理是什么， 





