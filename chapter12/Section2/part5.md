# Spring Boot  的 JPA 集成  

### JPA  
>JPA是Java Persistence API的简称，中文名Java持久层API，是JDK 5.0注解或XML描述对象－关系表的映射关系，并将运行期的实体对象持久化到数据库中,其具体实现参考了持久层ORM框架Hibernate实现  -------  百度百科   

#### hibernate 和 jpa 的关系  
hibernate是持久化实现技术，jpa是持久化的标准，hibernate是一种持久化的具体实现，jpa只是一种接口协议，可以通过实现jpa 接口协议实现不同的持久化技术，比如比较成熟的有 `Hibernate EntityManager`, `EclipseLink `, `OpenJPA` 等。本节主要内容 Spring Data JPA 是在hibernate 基础上的封装。接下来会验证这一点。    

#### Spring  Data JPA 


本章将基于 Spring Data JPA 进行数据库访问，本文将包含以下内容： 

* Spring Data JPA 与 Spring Boot 整合 
* Spring Data JPA 基本使用  
* Spring Data JPA 实体详解  
* Spring Data JPA JPQL 

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
2. JPA 配置  

```yml  
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
以上是Spring Boot 默认支持关于JPA 的设置，其中会发现包含hibernate的配置部分，说明Spring Data JPA 和 hibernate是有关联的。



## Spring Data JPA 基本使用    

## Spring Data JPA 实体详解  

## Spring Data JPA JPQL





