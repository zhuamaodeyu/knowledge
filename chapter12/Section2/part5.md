# Spring Boot  的 集成 Spring Data (JPA)  
### 完成状态

- [x] 编写中
- [ ] 已完成
- [ ] 维护中

### JPA  
>JPA是Java Persistence API的简称，中文名Java持久层API，是JDK 5.0注解或XML描述对象－关系表的映射关系，并将运行期的实体对象持久化到数据库中,其具体实现参考了持久层ORM框架Hibernate实现  -------  百度百科   

#### hibernate 和 jpa 的关系  
hibernate是持久化实现技术，jpa是持久化的标准，hibernate是一种持久化的具体实现，jpa只是一种接口协议，可以通过实现jpa 接口协议实现不同的持久化技术，比如比较成熟的有 `Hibernate EntityManager`, `EclipseLink `, `OpenJPA` 等。本节主要内容 Spring Data JPA 是在hibernate 基础上的封装。接下来会验证这一点。    

#### Spring  Data JPA 
Spring Data JPA 是基于ORM 框架hibernate针对JPA 规范的实现。是hibernate的扩展级。Spring  Data JPA 是 Spring Data 大家族中的一份子。通过Spring Data JPA 可以使开发者使用极简的代码实现对数据的访问和操作。包括常用的增删改查，排序等等的常用的数据库操作， 极大地提高了开发效率。  

#### Spring Data 与 Spring Data JPA 的关系  
Spring Data JPA 是 Spring Data 的一个子集。Spring Data 包含的内容比较多，其中包含了针对不同数据库的访问，比如SQL数据库(Orcale, Mysql等)；NoSQL(Mongodb, redis等)数据库的访问。 JPA 只是其中实现了 JPS 规范的一部分内容。JPA 的使用必须依赖于 Spring Data 的内容。   



本章将基于 Spring Data以及其 JPA 部分进行数据库访问，针对Spring Data 以及 JPA 进行详细的说明与讲解， 本文将包含以下内容： 
* Spring Data 功能特点说明    
* Spring Data JPA 功能特点说明 
* Spring Data JPA 与 Spring Boot 整合 
* Spring Data JPA 基本使用  
* Spring Data JPA 实体详解  
* Spring Data JPA JPQL 

## Spring Data 功能   
### 类接口介绍  
由于Spring Data JPA 是 Spring  Data 的一份子，所以基础功能含在Spring Data 包中。不过Spring Data JPA 也有一个具体的扩展包。以下是Spring Data 核心包和 JPA 的具体位置以及类结构：  
![Spring Data包](http://ozjlhf9e0.bkt.clouddn.com/20171130151200688924794.png)
![Spring Data JPA包](http://ozjlhf9e0.bkt.clouddn.com/20171130151200718299023.png)

其中最常用的就是以下几个类：   

* `Repository` : 此类是一个空的接口，是最顶层的一个接口(Spring Data中心接口)，其没有任何方法和操作，目的就是为了统一所有的Repository类型   
* `CrudRepository`: 此接口是`Repository` 的子接口，其从名字就可以看出来 此接口提供的是 CURD(增删改查) 操作
* `PagingAndSortingRepository`: 此接口是`CrudRepository` 的子接口，提供了分页和排序的功能   
* `JpaRepository`: 此接口是`PagingAndSortingRepository`的子接口，此接口和以上三个接口没有在同一个包中，此接口在 `org.springframework.data.jpa.repository`(Spring Data JPA)包中，以上三个都是存在`org.springframework.data.repository`(Spring Data)包中   

通过以上的几个类，大致已经满足所有常用的基础数据库操作，不过有时候由于需求，需要使用到动态SQL等操作时，以上几个类 就不能满足需要了，需要引入下面这个接口  

* `JpaSpecificationExecutor`: 这个接口主要就是用来做复杂查询，和以上几个接口不存在任何关系，是一个单独存在的接口  

以上只是介绍了几个通用的操作接口，其还有更加具体的持久化技术抽象接口，比如:`JpaRepository`, `MongoRepository`,`RedisRepository`等等，针对不同的数据库存在的不同的抽象化技术

### 方法定义 
Spring Data 提供了从方法名映射出特定的查询语句。通过对方法名的解析，支持按照规范的方法名查询。直接给定合乎规范的方法名，系统会根据方法名生成正确的查询等操作实现,不需要对方法进行实现，会自动生成需要的代码   
在自定义方法时，必须按照一定的规则才可以正确解析，其中有一些特定的单词发挥着特定的功能，也许它对最后生成具体代码没有具体的作用，但可以让代码更容易阅读。以下列出用于查询的特定的前缀以及连接词 ：  
查询: `find...By`,`read...By`,`query...By`,`count...By`,`get...By`   
连接: `And`, `Or`  
自定义方法必须符合以下规则：  
__查询前缀 + 全局修饰 + 实体属性名称 + 限定词 + 连接词 + ... +  OrderBy + 排序属性 + 排序方向__  
``` java  
	List<Person> findByEmailAddressAndLastname(EmailAddress emailAddress, String lastname);
 	List<Person> findDistinctPeopleByLastnameOrFirstname(String lastname, String firstname);
  	List<Person> findPeopleDistinctByLastnameOrFirstname(String lastname, String firstname);
 	List<Person> findByLastnameIgnoreCase(String lastname);
```
我对以上方法根据规则进行了以下划分：  
``` java   
	List<Person> findBy EmailAddress And Lastname(EmailAddress emailAddress, String lastname);
 	List<Person> find Distinct People By Lastname Or Firstname(String lastname, String firstname);
  	List<Person> find People Distinct By Lastname Or Firstname(String lastname, String firstname);
 	List<Person> find By Lastname IgnoreCase(String lastname);
```
下面给出更加全面的关键词列表：  
	
|  全局修饰  |   关键词    | 排序方向 | 连接词 | 限定词 |
| --------- | ---------- | ------ | ----- | ----- |
| Distinct  |isNull,isNotNull,like,notLike,Containing, in,notIn,ignoreCase, between, equals,Lessthan,graterThan,after,Before | asc, desc | and , or | first(fitst+number),top(top + number)|  

更加详细的关键词表通过连接可以查看[Query creation Keyword](https://docs.spring.io/spring-data/jpa/docs/2.0.2.RELEASE/reference/html/#jpa.query-methods)


根据以上内容，可以实现大部分的功能了，不过 Spring Data还给出了更加全面的功能。下面进行一一列举：  
* 嵌套方法命名规则  
	针对多级嵌套，提供了另外种更加直观的查询方式。通过下划线分割更加清晰明了  
	
```java   
	public User{
		private String name;
		private Address address;
	}
	public Address{
		private String name;
		private int code;
	}
```
针对需要通过 `code` 来查询用户的操作，如果按照以上已经给出的方式我们可能会实现出如下的方法名  
```java   
	List<User> find By Address Code(int Code) 
```
但这样并不直观，通过嵌套方法命名规则，可以通过一下方式实现
```java  
	List<User> find By Address_Code(int Code) 
```  
* 分页排序处理  
	JPA 针对排序和分页提供了两种方式处理，一种是直接通过定义方法名实现，一种是通过传递参数实现   
	* 通过方法名添加限定词来映射实现  
	```java  
		List<User> findByLastnameOrderByAsc(String lastname)
		List<User> findTop2ByLastnameOrderByAsc(String lastname)
		User findFirstByOrderByLastnameAsc();
		User findTopByOrderByAgeDesc();
		Page<User> queryFirst10ByLastname(String lastname, Pageablepageable);
	```
	* 通过参数实现  
	``` java  
		Page<User> findByLastname(String lastname, Pageable pageable);

		Slice<User> findByLastname(String lastname, Pageable pageable);

		List<User> findByLastname(String lastname, Sort sort);
		
		List<User> findByLastname(String lastname, Pageable pageable);
	```
	__此处我个人还是推荐使用 参数的形式实现，此种形式更加方便，不需要写太复杂的方法名，降低复杂度，可控度更改__   

* 流式查询  
	可以通过`Java8`提供的`Steam<T>`来实现结果返回,此处并不是简单的将结果包装在`Stream`中，而是通过特定的方式执行  
```java
	@Query("select u from User u")
	Stream<User> findAllByCustomQueryAndStream();

	Stream<User> readAllByFirstnameNotNull();

	@Query("select u from User u")
	Stream<User> streamAllPaged(Pageable pageable);
```  
	__注意__在使用流时，需要注意以下两点：  
	*  `Stream`在使用之后需要关闭的，可以通过 `str-with-resources block `的方式关闭或者`close()`方法来关闭。
	```java  
		try (Stream<User> stream = 	repository.findAllByCustomQueryAndStream()) {
  stream.forEach(…);
		}
	```
	* 并不是所有的数据模型都支持`Stream<T>`模式的

* 异步查询  
	同时支持异步查询。  
```java  
	@Async
	Future<User> findByFirstname(String firstname);               

	@Async
	CompletableFuture<User> findOneByFirstname(String firstname); 

	@Async
	ListenableFuture<User> findOneByLastname(String lastname);    	
```

以上的内容，如果需要更加详细的了解，可以通过访问官方文档地址查询[Defining query methods](https://docs.spring.io/spring-data/jpa/docs/2.0.2.RELEASE/reference/html/#repositories.query-methods.details)

### Spring Data 配置以及部分原理  
虽然通过一下简单的集成可以直接使用 JPA , 不过由于我们使用的是 Spring  Boot ,其自动化的已经帮我们实现了很多配置，但是自动化的配置并不能完全的满足我们的需求，有时候我们还是需要针对其进行自动化的配置。很好的理解Spring Data如何配置以及如何实现能更加的帮助我们使用Spring Data(JPA)。   


#### Spring Data 配置  
每一个Spring Data模块都包含repositories元素能够让你简单的基于base-package定义来进行Spring扫描。我们可以通过 XML 以及 Java 两种配置的形式来配置  

* xml 配置  
```xml  
<?xml version="1.0" encoding="UTF-8"?>
<beans:beans xmlns:beans="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns="http://www.springframework.org/schema/data/jpa"
  xsi:schemaLocation="http://www.springframework.org/schema/beans
    http://www.springframework.org/schema/beans/spring-beans.xsd
    http://www.springframework.org/schema/data/jpa
    http://www.springframework.org/schema/data/jpa/spring-jpa.xsd">

  <repositories base-package="com.acme.repositories">
 		<context:exclude-filter type="regex" expression=".*SomeRepository" />
  </repositories>
</beans:beans>
```  
* java 配置  
```java   
@Configuration
@EnableJpaRepositories("com.acme.repositories")
class ApplicationConfiguration {

  @Bean
  public EntityManagerFactory entityManagerFactory() {
    // …
  }
}
```
__通过`@Enable${store}Repositories`注解来开启不同的支持，比如`@EnableJpaRepositories`用来开`JPA`支持 ， `EnableMongoRepositories`来开启`Mongodb`的支持__  

通过以上方式可以针对 `Spring Data` 进行自定义化的配置，针对不同的需求进行不同的配置。比如一个项目中同时使用多种数据库，(Spring Data 针对每个模块有单独的配置实现),可以通过针对性的配置实现不同的支持。同时还可以通过过滤等配置针对对应的模块过滤性的加载 registory   


#### Spring Data Registroy   
Spring  Data 使用通过接口化实现，项目在运行时通过接口自动化生成对应的实现类，通过Spring 的bean管理机制，生成与类名相同的key(类名的第一个首字母小写)对bean进行对应存储。利用工厂方法通过类来获取对应的实例  
```java   
RepositoryFactorySupport factory = … // Instantiate factory here
UserRepository repository = factory.getRepository(UserRepository.class);
```
通过以上方式，可以获取系统自动生成的对应的接口实例。 不过有时候，针对一些不同的需求要求，我们并不能很好的通过Spring Data 的方法名映射出合适的方法实现，此时需要我们自己实现`Spring Data repositories`,此处就需要自定义实现    
* 定义接口定义方法  
``` java   
interface CustomizedUserRepository {
  void someCustomMethod(User user);
}
```
* 自定义方法实现  
```java   
class CustomizedUserRepositoryImpl implements CustomizedUserRepository {

  public void someCustomMethod(User user) {
    // Your custom implementation
  }
}
```
__类名需要按照 `{接口名}Impl` 来实现哦__   

* 将其扩展到` repository interface`  
```java  
interface UserRepository extends CrudRepository<User, Long>, CustomizedUserRepository {

  // Declare query methods here
}
```
通过以上方式实现，即实现了自定义的方法实现，系统也不会再聪明的自动生成对应的方法实现

以上给出了Spring Data 的简单介绍，如果需要更加详细的学习请查询官方文档[官方文档](https://docs.spring.io/spring-data/jpa/docs/2.0.2.RELEASE/reference/html/#jpa.query-methods)


## Spring Data JPA 功能特点说明   




## Spring Data JPA 与 Spring Boot 整合 
1. 引入需要的jar包    
    本次采用的数据库是 MySQL， 所以也需要引入MySQL驱动包  
	```xml  
			<dependency>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-starter-data-jpa</artifactId>
			</dependency>
		<dependency>
				<groupId>mysql</groupId>
				<artifactId>mysql-connector-java</artifactId>
				<scope>runtime</scope>
			</dependency>
	```

2. JPA 配置说明  
	```properties  
	spring.jpa.database=
	spring.jpa.database-platform=
	spring.jpa.generate-ddl=
	spring.jpa.hibernate.ddl-auto=
	spring.jpa.hibernate.naming-strategy=
	spring.jpa.hibernate.naming.physical-strategy=
	spring.jpa.hibernate.naming.strategy=
	spring.jpa.hibernate.use-new-id-generator-mappings=  
	spring.jpa.open-in-view=
	spring.jpa.properties=
	spring.jpa.show-sql=
	spring.data.jpa.repositories.enabled=
	``` 
	以上是Spring Boot 默认支持关于JPA 的设置，其中会发现包含hibernate的配置部分，说明Spring Data JPA 和 hibernate是有关联的。 其中在使用的时候，并不需要全部配置，只需要配置关键部分就可以   
3. Spring Boot 集成配置  





## Spring Data JPA 基本使用    
正常情况下，通过Spring 来进行Spring Data JAP 操作，一般是需要4步的， 不过如果通过Spring Boot 来进行Spring Data JPA操作，可以将其缩减为2步就可轻松完成。接下来是基于Spring Boot 的实现，如果需要了解具体的Spring 集成操作，那么可以通过一下地址访问官方文档查看 [Spring Data JPA 集成](https://docs.spring.io/spring-data/jpa/docs/2.0.2.RELEASE/reference/html/#repositories.query-methods)
 
1. 提供一个接口类并扩展自`Repository`接口或者其子接口(就是以上说名的几个`CrudRepository`,`PagingAndSortingRepository`以及`JpaRepository`)并提供其需要处理的实体类和ID 类型  
	```java  
	public interface UserRepository extends CrudRepository<User,Long> {

	}
	```
2. 在接口中声明查询方法  
	``` java  
		List<User> findByLastname(String lastname);
		List<User> findByAddress(String address);
	```
	__强烈建议使用IDEA 集成环境来开发，其对Spring 以及其他支持堪称完美，此处在定义查询方法时会给出一定的提示__   

3. 调用  
	此处调用，可以直接在 `Controller`层调用，也可以在`Service`层调用，具体需要根据自己项目架构需求来进行调用实现   

	``` java  
		@Autowired
		private UserRepository userRepository;

		@GetMapping("/get_user_by_address/{address}")
		public ResponseEntity getUserByAddress(@PathVariable String address) {
			return new ResponseEntity(userRepository.findByAddress(address), HttpStatus.OK);
		}
	```

### 详细说明以及疑点解惑
通过以上方式，可以满足简单的数据库操作。不过其中有几点需要注意或者迷惑的地方，接下来将逐点进行说明：   

1. 提供一个接口类并扩展自`Repository`接口  
	本步并不是必须的，如果系统提供的几个接口以及其中提供的方法完全满足项目需求，那么可以不需要提供单独的接口类，不过为了项目的可维护性等，还是建议提供单独的接口类    
2. 为什么就提供一个接口就可以实现功能   
	虽然开发阶段不需要提供具体的代码实现，不过在项目运行阶段，并不是直有接口，而是系统会根据接口信息，自动生成一些模板代码，系统自动生成了接口的实现。不需要开发人员去编写这些具有模板性的代码，大大提高了开发效率  
3. 自定义的操作方法系统如何处理  
	Spring Data JPA 支持自定义操作方法，但并不是随便来写的，Spring Data JPA针对方法名有一些限定说明。只有遵循此规定的，系统才会生成正确的实现代码。本节会有部分内容专门讲解此处的实现。如何实现正确的方法定义需要根据此部分内容来详细了解   
	__此处推荐IDEA集成环境开发，它会按照规范给定提示，可以书写标准的自定义方法__  

4. 如果不需要暴露部分操作接口该怎么办？比如删除操作等  
	此种需要可以通过自定义接口，比如不需要删除操作，但是又需要排序等操作，可以通过将`CrudRepository`中了曾，改，查操作的方法复制到自定义的接口中，然后将`PagingAndSortingRepository`将其中排序的方法复制到自定义的接口中。当然，如果需要其他的操作，那么可以通过自定义接口类实现  

	```java  
	@NoRepositoryBean
	interface MyBaseRepository<T, ID extends Serializable> extends Repository<T, ID> {
  	Optional<T> findById(ID id);
  	<S extends T> S save(S entity);
	}

	public interface ProductRepository extends MyBaseRepository<Product, Long> {

	}
	```    
	此内容可以在Spring  Data JPA 官方文档找到[Defining repository interfaces
](https://docs.spring.io/spring-data/jpa/docs/2.0.2.RELEASE/reference/html/#repositories.definition)  
	通过以上方式实现的，虽然看似使用的是一个自定的接口类实现的，不过内部还是会映射到 `CrudRepository`接口上，只不过没有提供那么多接口以供开发调用(__此内容没有经过验证，根据文档介绍是如何__)


## Spring Data JPA 实体详解  




## Spring Data JPA JPQL




## 参考文献  
* [Spring Data JPA - Reference Documentation](https://docs.spring.io/spring-data/jpa/docs/2.0.2.RELEASE/reference/html/)