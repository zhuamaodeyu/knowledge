# Go Web 设计一个Web框架   

## 项目规划  

#### gopath以及项目设置  
首先需要设置好gopath路径，gopath 可以设置多个目录    
`export gopath=/home/xxxx/gopath`  

__必须保证gopath这个代码目录下面有三个目录pkg、bin、src__   
__项目的源码放置在src目录下__   

#### 应用流程图   
采用MVC架构  
![](../assets/gitbook/Snip20161217_1.png) 

1. main.go 作为应用入口,初始化一些运行博客所需要的基本资源,配置信息,监听端口。   
2.  路由功能检查HTTP请求,根据URL以及method来确定谁(控制层)来处理请求的转发资源。    
3. 如果缓存文件存在,它将绕过通常的流程执行,被直接发送给浏览器。    
4. 安全检测:应用程序控制器调用之前,HTTP请求和任一用户提交的数据将被过滤。    
5.  控制器装载模型、核心库、辅助函数,以及任何处理特定请求所需的其它资源,控制器主要负责处理业务逻 辑。   
6. 输出视图层中渲染好的即将发送到Web浏览器中的内容。如果开启缓存,视图首先被缓存,将用于以后的常规 请求。
   

#### 目录结构
~~~  
|——main.go 							入口文件      
|——conf 								配置文件和处理模块
|——controllers 						控制器入口    
|——models 							数据库处理模块
|——utils 								辅助函数库
|——static 							静态文件目录
|——views								视图库
~~~

#### 框架设计  
框架包括路由功能、支持REST的控 制器、自动化的模板渲染,日志系统、配置管理等。
        
## 具体实现
### 自定义路由设计   
HTTP路由组件负责将HTTP请求交到对应的函数处理      

* 默认的路由实现   

~~~  
func fooHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello, %q", html.EscapeString(r.URL.Path))
}
http.HandleFunc("/foo", fooHandler)
http.HandleFunc("/bar", func(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello, %q", html.EscapeString(r.URL.Path))
})
log.Fatal(http.ListenAndServe(":8080", nil))
~~~    

##### 路由实现思路： 
- 添加路由信息  
- 根据用户请求转发到要执行的函数    

Go默认的路由添加是通过函数  `http.Handle` 和 `http.HandleFunc`  等来添加,底层都是调用了`DefaultServeMux.Handle(pattern string, handler Handler)` ,这个函数会把路由信息存储在一个map信息中 `map[string] muxEntry`  ,这就
解决了上面说的第一点。

Go监听端口,然后接收到tcp连接会扔给Handler来处理,上面的例子默认nil即为   ,通过 D 函数来进行调度,遍历之前存储的map路由信息,和用户访问的URL进行匹配,以查询对
应注册的处理函数,这样就实现了上面所说的第二点。


##### 路由实现：  
Go自带的缺陷： 
 
1. 不支持参数设定,例如/user/:uid 这种泛类型匹配   
2. 无法很好的支持REST模式,无法限制访问的方法,例如上面的例子中,用户访问/foo,可以用GET、POST、DE LETE、HEAD等方式访问    
3. 一般网站的路由规则太多了,编写繁琐。我前面自己开发了一个API应用,路由规则有三十几条,这种路由多 了之后其实可以进一步简化,通过struct的方法进行一种简化    


##### 路由分类  
* 存储路由    
	根据以上路由的缺陷， 需要解决参数支持就需要用到正则， REST的方法对应到struct的方法中去,然后路由到struct而不是函数,这样在转发路由的时候就可以根据met hod来执行不同的方法。     
	根据上面的思路,我们设计了两个数据类型controllerInfo(保存路径和对应的struct,这里是一个reflect.Type 类型)和ControllerRegistor(routers是一个slice用来保存用户添加的路由信息,以及beego框架的应用信息)   
	
	~~~  
	type controllerInfo struct {
     regex          *regexp.Regexp
     params         map[int]string
     controllerType reflect.Type
	}
 	type ControllerRegistor struct {
     	routers     []*controllerInfo
     	Application *App
	}
	~~~   
	其中 `ControllerRegistor `对外的接口是如下形式  
	`func (p *ControllerRegistor) Add(pattern string, c ControllerInterface)`  
	
	~~~  
	 func (p *ControllerRegistor) Add(pattern string, c ControllerInterface) {
     parts := strings.Split(pattern, "/")
     j := 0
     params := make(map[int]string)
     for i, part := range parts {
         if strings.HasPrefix(part, ":") {
             expr := "([^/]+)"
//a user may choose to override the defult expression // similar to expressjs: ‘/user/:id([0-9]+)’
             if index := strings.Index(part, "("); index != -1 {
                 expr = part[index:]
                 part = part[:index]
             }
             params[j] = part
             parts[i] = expr
             j++
} }
 //recreate the url pattern, with parameters replaced
     //by regular expressions. then compile the regex
     pattern = strings.Join(parts, "/")
     regex, regexErr := regexp.Compile(pattern)
     if regexErr != nil {  
         //TODO add error handling here to avoid panic
         panic(regexErr)
         return
}
     //now create the Route
     t := reflect.Indirect(reflect.ValueOf(c)).Type()
     route := &controllerInfo{}
     route.regex = regex
     route.params = params
     route.controllerType = t
     p.routers = append(p.routers, route)
 }
 
	~~~
	
	1. 静态路由实现  
		Go的http包默认支持静态文件处理FileServer,由于我们实现了自定义的路由 器,那么静态文件也需要自己设定,beego的静态文件夹路径保存在全局变量StaticDir中,StaticDir是一个map 类型    
		
		~~~  
		 func (app *App) SetStaticPath(url string, path string) *App {
     			StaticDir[url] = path
     			return app
			}
		
		 beego.SetStaticPath("/img","/static/img")
		~~~
* 转发路由    
	转发路由是基于ControllerRegistor里的路由信息来进行转发的    
	
	~~~  
	// AutoRoute
 	func (p *ControllerRegistor) ServeHTTP(w http.ResponseWriter, r *http.Request) {
     	defer func() {
         	if err := recover(); err != nil {
             	if !RecoverPanic {
                 // go back to panic
                 	panic(err)
				} else {
				 Critical("Handler crashed with error", err)
            for i := 1; ; i += 1 {
                _, file, line, ok := runtime.Caller(i)
                if !ok {
					break }
                Critical(file, line)
            }
			} 
		}
	}()
	var started bool
	for prefix, staticDir := range StaticDir {
    	if strings.HasPrefix(r.URL.Path, prefix) {
        	file := staticDir + r.URL.Path[len(prefix):]
        	http.ServeFile(w, r, file)
        	started = true
        	return
		} 
	}
	requestPath := r.URL.Path
	
	//find a matching Route
	for _, route := range p.routers {
    	//check if Route pattern matches url
    	if !route.regex.MatchString(requestPath) {
			continue
		 }
	//get submatches (params)
    matches := route.regex.FindStringSubmatch(requestPath)   
    
    //double check that the Route matches the URL pattern.
    if len(matches[0]) != len(requestPath) {
			continue 
	}    
	
	 params := make(map[string]string)  
	 if len(route.params) > 0 {  
	 	//add url parameters to the query param map  
	 	 values := r.URL.Query()  
	 	  for i, match := range matches[1:] {  
	 	  		values.Add(route.params[i], match)
	 	  		params[route.params[i]] = match  
	 	  	}  
	 	  	 //reassemble query params and add to RawQuery  
	 	  	 r.URL.RawQuery = url.Values(values).Encode() + "&" + r.URL.RawQuery   
	 	  	 //r.URL.RawQuery = url.Values(values).Encode()  
	 	  	}	
	 	//Invoke the request handler
		vc := reflect.New(route.controllerType)
		init := vc.MethodByName("Init")
		in := make([]reflect.Value, 2)
		ct := &Context{ResponseWriter: w, Request: r, Params: params}
		in[0] = reflect.ValueOf(ct)
		in[1] = reflect.ValueOf(route.controllerType.Name())
		init.Call(in)
		in = make([]reflect.Value, 0)
		method := vc.MethodByName("Prepare")
		method.Call(in)    
		
		if r.Method == "GET" {
    		method = vc.MethodByName("Get")
    		method.Call(in)
		} else if r.Method == "POST" {
    		method = vc.MethodByName("Post")
    		method.Call(in)
		} else if r.Method == "HEAD" {
    		method = vc.MethodByName("Head")
    		method.Call(in)
		} else if r.Method == "DELETE" {
    		method = vc.MethodByName("Delete")
    		method.Call(in)
		} else if r.Method == "PUT" {
    		method = vc.MethodByName("Put")
    		method.Call(in)
		} else if r.Method == "PATCH" {
    		method = vc.MethodByName("Patch")
    		method.Call(in)
		} else if r.Method == "OPTIONS" {
    		method = vc.MethodByName("Options")
    		method.Call(in)
		}
		if AutoRender {
    		method = vc.MethodByName("Render")
    		method.Call(in)
		}
		method = vc.MethodByName("Finish")
		method.Call(in)   
		
		started = true
		break 
	}   
	
	//if no matches to url, throw a not found exception  
	if started == false {  
		http.NotFound(w, r)  
	}
}	
	~~~

##### 使用入门  
* 基本使用注册路由   
	`beego.BeeApp.RegisterController("/", &controllers.MainController{})`      
* 参数注册    
	`beego.BeeApp.RegisterController("/:param", &controllers.UserController{})`
* 正则匹配    
	`beego.BeeApp.RegisterController("/users/:uid([0-9]+)", &controllers.UserController{})`    


### controller 设计   
	
	
### 日志和配置设计   


### 实现博客的增删改  




















