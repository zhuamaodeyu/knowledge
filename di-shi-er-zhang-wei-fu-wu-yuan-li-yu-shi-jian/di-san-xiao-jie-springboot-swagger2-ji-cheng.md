#Spring Boot Swagger2 集成REST ful API 生成接口文档


### 完成状态
  
- [ ] 维护中
- [x] 未完成
- [ ] 已完成


### 说明
本文参考自一下文章: 

* [SPRING BOOT RESTFUL API DOCUMENTATION WITH SWAGGER 2](http://www.baeldung.com/swagger-2-documentation-for-spring-rest-api)
* [Setting Up Swagger 2 with a Spring REST API](https://springframework.guru/spring-boot-restful-api-documentation-with-swagger-2/)

## 简介   
由于Spring Boot 的特性，用来开发 REST ful 变得非常容易，并且结合 Swagger 来自动生成 REST ful API 文档变得方便快捷。 

Swagger 是一个简单但功能强大的API表达工具。几乎所有的语言都可以找到与之对应的Swagger 版本。使用Swagger生成API，我们可以得到交互式文档。听过Spring Boot 与Swagger 的结合，生成更加完备的REST ful API 文档。通过在源码中添加部分内容，系统生成文档，大大提高工作效率，不用再花费大量时间来创建文档，同时由于同时是通过代码开生成文档，大大降低了维护成本    
Swagger 不仅可以组织生成强大的 REST ful 文档，同时也提供了完备的测试功能，可以直接在文档页面测试接口功能。


接下来将基于 Spring Boot 与Swagger 2 搭建完整的API 文档系统。先来提前目睹下Swagger 生成的文档样式
	![](http://ozjlhf9e0.bkt.clouddn.com/20171117151088985683434.png)  
	
	
## 实践  
#### 创建Spring Boot 工程 
可以参考前文Spring Boot 初体验  
#### 在POM 文件中添加 Swagger2 包引用  

``` xml 
	<dependency>
		<groupId>io.springfox</groupId>
		<artifactId>springfox-swagger2</artifactId>
		<version>2.7.0</version>
	</dependency>
	<dependency>
		<groupId>io.springfox</groupId>
		<artifactId>springfox-swagger-ui</artifactId>
		<version>2.7.0</version>
	</dependency>
	
	//导入测试需要的库 
			<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-data-jpa</artifactId>
		</dependency>
		<dependency>
			<groupId>com.h2database</groupId>
			<artifactId>h2</artifactId>
			<version>1.4.196</version>
			<scope>runtime</scope>
		</dependency>
	
```
_本实例采用的是基于内存数据库H2 的JPA 形式_


#### 创建配置类    
通过以上方式只能导入 Swagger2 需要的jar包，但当前并不能运行(虽然Spring boot 支持自动化配置)  

```java
@Configuration
@EnableSwagger2
public class SwaggerConfig {

    @Bean
    public Docket api(){
        return  new Docket(DocumentationType.SWAGGER_2).select()
                .apis(RequestHandlerSelectors.basePackage("com.springboot.demo"))
                .paths(PathSelectors.any())
                .build()
                .apiInfo(apiInfo());
    }

    private ApiInfo apiInfo(){
        return new ApiInfoBuilder()
                .title("Spring Boot中使用Swagger2构建RESTful APIs")
                .description("spring boot , swagger2")
                .termsOfServiceUrl("http:github.com/zhuamaodeyu")
                .contact("抓🐱的🐟")
                .version("1.0")
                .build();
    }
}
```

__说明:__

1. `@Configuration`: 此注解是告诉 `Spring Boot` 这是一个配置类，需要在项目启动时加载该类  
2. `@EnableSwagger2`: `Swagger2` 是通过此注解来启动的  
3. 通过 `api`方法创建 Docket 对象，其中主要注意 `basePackage`配置以及私有方法 `apiInfo`方法创建的基本信息  
	通过指定扫描包来配置，以上配置 Swagger 会扫描整个项目工程


#### 创建实体和respository 

```java 
@Entity
@Table(name="user")
public class User implements Serializable {
//    @ApiModelProperty(notes = "id")
    @Id

    @GeneratedValue(strategy = GenerationType.AUTO)
    private  String id;
    @ApiModelProperty(notes = "uuid")
    private UUID uuid;
    @ApiModelProperty(notes = "用户名称")
    private  String name;
    private  String password;
    @ApiModelProperty(notes = "用户地址")
    private  String address;
    @ApiModelProperty(notes = "年龄")
    private  int age;
    @ApiModelProperty(notes = "邮箱地址")
    private  String email;
    @ApiModelProperty(notes = "描述")
    private  String desc;
	
	// getter/ setter 方法

}

@Repository
public interface UserRepository extends  CrudRepository<User,String> {

}


```

#### 测试controller  

``` java  
@RestController
@Api(value = "product 商品操作API")
@RequestMapping("/product")
public class IndexController {

    /**
     * 1. 获取列表
     * 2. 显示单个的信息
     * 3. 添加
     * 4. 更新
     * 5. 删除
     */

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/")
    @ApiOperation(value = "首页",notes = "测试代码")
    public  String index()
    {
        return  "index";
    }



    @GetMapping("/list")
    @ApiOperation(value = "获取全部数据列表", notes = "获取数据列表")
    public Iterable list(Model model)
    {
        return  userRepository.findAll();
    }

    @GetMapping("/get_user_message")
    @ApiOperation(value = "获取用户详情信息")
    @ApiImplicitParam(name = "userId",value = "用户ID",defaultValue = "",required = true,dataType = "String")
    public User getUserMessage(String userId)
    {
        return  userRepository.findOne(userId);
    }


    @PostMapping("/save")
    @ApiOperation(value = "保存用户数据")
    @ApiImplicitParam(name = "user", value = "用户对象",required = true, dataTypeClass = User.class)
    public String save(@RequestBody User user)
    {
        if (user == null)
        {
            return  "false";
        }

        userRepository.save(user);
        return  "true";
    }

    @PutMapping("/update/{userId}")
    @ApiOperation(value = "更新用户数据")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "userId", value = "用户的ID", required = true, dataTypeClass = String.class),
            @ApiImplicitParam(name = "user", value = "用户对象", required = true, dataTypeClass = User.class)
    })

    public ResponseEntity updateUserMessage(@PathVariable String userId, @RequestBody User user)
    {
        User user1 = userRepository.findOne(userId);
        user1.setAddress(user.getAddress());


        userRepository.save(user1);
        return  new ResponseEntity("更新数据成功", HttpStatus.OK);
    }

    @DeleteMapping("/delete/{userId}")
    @ApiOperation(value = "根据用户ID 删除用户数据")
    @ApiImplicitParam(name = "删除用户数据",value = "",required = true, dataType = "String")
    public  ResponseEntity deleteUser(@PathVariable String userId)
    {
        userRepository.delete(userId);
        return new ResponseEntity("删除用户数据", HttpStatus.OK);
    }
}
```




#### 测试 
实现以上代码，启动项目 直接访问[http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)
就能看到Swagger2 所生成的文档。可以操作每个请求，其下面是具体的描述和文档内容


##### 接口调试  
1. Swagger 集成测试  

	前文提到 Swagger 也提供了 接口调试功能， 可以直接根据接口要求在图中标记处填写接口参数
![调试](http://ozjlhf9e0.bkt.clouddn.com/20171117151089050469319.png)


2.  Postman 测试  
	通过以上方式可以得到接口文档，其包含了具体的内容，有了这些内容，就可以通过Postman 等专业的接口测试工具来进行接口的测试  
	![postman接口测试](http://ozjlhf9e0.bkt.clouddn.com/20171117151089058260832.png)



## Swagger2 常用配置详解  
* `@Api`  
	
	```java  
	@Api(value="onlinestore", description="当前控制器中的API 的描述信息")
	
	```
* `@ApiOperation`
	
	此注解是对当前 API 接口的描述，主要是名称，详细描述，返回值类型等信息 
	
	```java
	@ApiOperation(value = "首页",notes = "测试代码", tags = {"测试服务是否正常"}, response = String.class)
	```
	* value : API 的名称  
	* notes : API 详细描述信息  
	* response : 返回值类型  
	* tags : 默认的是以 类名为 标签的，此处可以自定义标签  
* `@ApiResponses`
* `@ApiResponse`  
	
	此注解是对API 返回的结果进行描述  
	
	``` java  
	   @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully"),
            @ApiResponse(code = 401, message = "You are not authorized to view the resource"),
            @ApiResponse(code = 403, message = "Accessing the resource you were trying to reach is forbidden"),
            @ApiResponse(code = 404, message = "The resource you were trying to reach is not found")
    }
    )
	
	```
* `@ApiImplicitParams`
* `@ApiImplicitParam`

	这两个注解是对API 请求参数的描述  
	
	```java  
	@ApiImplicitParams({
            @ApiImplicitParam(name = "userId", value = "用户的ID", required = true, dataTypeClass = String.class),
            @ApiImplicitParam(name = "user", value = "用户对象", required = true, dataTypeClass = User.class)
    })
	``` 
* `@ApiModelProperty`
	实体类属性添加描述信息，在接口文档中可针对类属性具体含义进行查看  
	
	```java
	@GeneratedValue(strategy = GenerationType.AUTO)
    private  String id;
    @ApiModelProperty(notes = "uuid")
    private UUID uuid;
    @ApiModelProperty(notes = "用户名称")
    private  String name;
    private  String password;
    @ApiModelProperty(notes = "用户地址")
    private  String address;
    @ApiModelProperty(notes = "年龄")
    private  int age;
    @ApiModelProperty(notes = "邮箱地址")
    private  String email;
    @ApiModelProperty(notes = "描述")
    private  String desc;
	```
	通过以上配置，可以文档中进行查看  
	![](http://ozjlhf9e0.bkt.clouddn.com/201711171510892551136.png)
	
	

__以下内容只作为扩展知识__    
---------------------------------------- 
#### Mock 系统  
在现如今的开发中，一个由于项目需求紧，开发周期短，通常涉及到后端以及前端协同工作；一个由于现在大多采用的是前后端分离的开发形式，前后端交互只是通过 REST ful 接口形式来实现的，前后端各自分工工作，所以就存在一个现象就是前端做的快，后端无法及时的给出接口实现并且开发阶段没有数据支撑而造成前端必须等待后端。  

现在可以通过先定义接口文档，生成 Mock 数据的形式来进行前后端分离开发。前端通过调用定义的 Mock 数据来进行前端调试和开发。不需要等待后端的数据   

接下来将通过集成 `easy-Mock` 系统来实现协同开发  

##### easy Mock  
[easy-mock](https://easy-mock.com/docs) 是大搜车公司开源的一套 mock 工具，是一个可视化，并且能快速生成 模拟数据 的持久化服务. 下面将 easy-mock 与 Swagger 结合进行协同工作

* 搭建easy-mock  
	* 下载源码  
		easy-mock是一套开源系统，其托管在 github 上,可以通过一下方式获取源码  
		`git clone https://github.com/easy-mock/easy-mock.git`  
	* 修改配置  
		easy-mock 是使用MongoDB数据的，所以需要配置数据库  
		进入 `config`文件夹，修改 `default.json`文件  
		
		```JavaScript
		{
  			"port": 7300,
  			"pageSize": 30,
  			"routerPrefix": {
    			"mock": "/mock",
    			"api": "/api"
  			},
  			"db": "mongodb://192.168.99.100:32773/easy-mock_",
  			"unsplashClientId": "",
		``` 

		修改 `db` 添加一个可以用的 数据库  
	* 启动  
		`npm run dev`  
		默认的监听 `7300` 端口，可以通过[localhost:7300](localhost:7300)访问系统  
		
* 导入 Swagger   
	进入系统创建项目并根据以下方式导入 Swagger  
	
	* 获取 Swagger 地址  
		![获取 Swagger 地址](http://ozjlhf9e0.bkt.clouddn.com/20171117151089071048027.png)
	* easy-mock创建项目  
		![创建项目](http://ozjlhf9e0.bkt.clouddn.com/20171117151089072139320.png)
	* 通过  
		![同步](http://ozjlhf9e0.bkt.clouddn.com/20171117151089107763700.png)











