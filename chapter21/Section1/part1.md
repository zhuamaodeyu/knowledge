# Gin Guide

## Gin 

Gin 是一个 Go 语言实现的高性能的 web 框架，基于Httprouter 实现。本文将主要介绍 Gin 的基本使用，后续文章将继续深挖Gin 的高性能背后是如何实现的。  

### Gin 特性 

- 快： 路由使用基数树，低内存消耗，不使用反射   
- 中间件: 通过注册中间件以及系统自带中间件对请求进行处理直到最后的action处理  
- 崩溃处理：具有崩溃处理机制，捕获 panic 使应用可以正常运行  
- JSON校验： 将请求数据转换为JSON 并对其进行校验  
- 路由组： 通过路由组更好的组织和管理路由，无限制嵌套而不影响性能  
- 错误管理： 收集所有的错误  

## Start   

Gin 提供了两种方式来实现安装：   

### go 原始安装  

1. Download  

   `go get github.com/gin-gonic/gin`  

2. import  

   `import "github.com/gin-gonic/gin"`  

### 集成安装工具 [govendor](https://github.com/kardianos/govendor)  

1. Go  get govendor  

   `go get github.com/kardianos/govendor`  

2. 创建项目   

   `mkdir -p $GOPATH/src/github.com/xxxx/project && cd "$_"`  

3. 初始化项目并安装gin  

   ```
   govendor init  
   govendor fetch github.com/gin-gonic/gin@v1.2  
   ```

4. （可选的） 创建一个测试模板程序  

   `curl https://raw.githubusercontent.com/gin-gonic/gin/master/examples/basic/main.go > main.go`  

5. （可选的） 运行程序  

   `go run main.go`  

## API Examples   

Gin 实现了标准的REST ful 接口规范，其可以使用`GET`,`POST`,`PUT`,`PATCH`,`DELETE`,`OPTIONS`  等  

```go  
package main

import "github.com/gin-gonic/gin"

func main() {
	// 获取一个 gin 实例  
    r := gin.Default()
  	// 添加 get 请求通过回调的方式实现请求处理  
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})    
  	// 运行服务，默认是在本地的 8080 端口上   
  r.Run(":8080") // listen and serve on 0.0.0.0:8080
}
```

通过以上方式就可以简单的启动一个 gin 实例， 并且还具备了 `logger` 以及 `recovery`功能但是一般在正常的web项目中很少会这样写router， 一般会将其进行组合进行模块化代码  

```go   
router := gin.Default()    
router.GET("/someGet", getting)
router.POST("/somePost", posting)
router.PUT("/somePut", putting)
router.DELETE("/someDelete", deleting)
router.PATCH("/somePatch", patching)
router.HEAD("/someHead", head)
router.OPTIONS("/someOptions", options)
```

以上只是提供了没有参数的router类型，其gin还具备丰富的参数获取功能  

```go 
// 路径参数
router.GET("/user/:name", func(c *gin.Context) {
		name := c.Param("name")
		c.String(http.StatusOK, "Hello %s", name)
	})
// 路径参数
router.GET("/user/:name/*action", func(c *gin.Context) {
		name := c.Param("name")
		action := c.Param("action")
		message := name + " is " + action
		c.String(http.StatusOK, message)
	})
// get 获取参数
router.GET("/welcome", func(c *gin.Context) {
		firstname := c.DefaultQuery("firstname", "Guest")
		lastname := c.Query("lastname") 

		c.String(http.StatusOK, "Hello %s %s", firstname, lastname)
	})
//post 获取参数
router.POST("/form_post", func(c *gin.Context) {
		message := c.PostForm("message")
		nick := c.DefaultPostForm("nick", "anonymous")

		c.JSON(200, gin.H{
			"status":  "posted",
			"message": message,
			"nick":    nick,
		})
	})
```

同时还提供了文件上传功能   

```go   
//单文件上传
router.POST("/upload", func(c *gin.Context) {
		// single file
		file, _ := c.FormFile("file")
        log.Println(file.Filename)
        
		c.SaveUploadedFile(file, dst)

		c.String(http.StatusOK, fmt.Sprintf("'%s' uploaded!", file.Filename))
	})
// 多文件上传
router.POST("/upload", func(c *gin.Context) {
		// Multipart form
		form, _ := c.MultipartForm()
		files := form.File["upload[]"]

		for _, file := range files {
			log.Println(file.Filename)
			c.SaveUploadedFile(file, dst)
		}
		c.String(http.StatusOK, fmt.Sprintf("%d files uploaded!", len(files)))
	})
```

以上针对gin 作为一个 web 框架最基本的路由以及请求和文件上传功能的介绍，不过作为一个丰富的，强大的web 框架，只有这些基本功能还是不行了，其还提供了一些辅助性的功能。

- routes Group  

  ```go  
  v1 := router.Group("/v1")
  	{
  		v1.POST("/login", loginEndpoint)
  		v1.POST("/submit", submitEndpoint)
  		v1.POST("/read", readEndpoint)
      }
      
  	v2 := router.Group("/v2")
  	{
  		v2.POST("/login", loginEndpoint)
  		v2.POST("/submit", submitEndpoint)
  		v2.POST("/read", readEndpoint)
  	}
  ```

  这样有助于项目的分版本运行， 针对不同的版本，运行不同的router 就可以了  

- 中间件(middleware)  

  ```go  
  r := gin.New()
  r.Use(gin.Logger())
  r.Use(gin.Recovery())
  r.GET("/benchmark", MyBenchLogger(), benchEndpoint)
  authorized := r.Group("/")
  	authorized.Use(AuthRequired())
  	{
  		authorized.POST("/login", loginEndpoint)
  		authorized.POST("/submit", submitEndpoint)
  		testing := authorized.Group("testing")
  		testing.GET("/analytics", analyticsEndpoint)
  	}
  
  ```

- 日志处理  

  ```go  
  gin.DisableConsoleColor()
  f, _ := os.Create("gin.log")
  gin.DefaultWriter = io.MultiWriter(f)
  ```

  以上就是 `Gin` 以及功能简单介绍。 接下来将在后几篇针对 Gin 的源码进行深入剖析。查看其深层次的实现   

  ​





 





