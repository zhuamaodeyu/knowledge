# Spring Boot  的JPA集成  

## JPA  
>JPA是Java Persistence API的简称，中文名Java持久层API，是JDK 5.0注解或XML描述对象－关系表的映射关系，并将运行期的实体对象持久化到数据库中,其具体实现参考了持久层ORM框架Hibernate实现  -------  百度百科   

#### hibernate 和 jpa 的关系  
hibernate是持久化实现技术，jpa是持久化的标准，hibernate是一种持久化的具体实现，jpa只是一种接口协议，可以通过实现jpa 接口协议实现不同的持久化技术，比如比较成熟的有 `Hibernate EntityManager`, `EclipseLink `, `OpenJPA` 等。本节主要内容 Spring Data JPA 是在hibernate 基础上的封装。接下来会验证这一点。    

## Spring Boot 集成 JPA  
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






