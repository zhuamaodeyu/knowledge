# Spring Boot *Template 集成  
### 完成状态
  
- [x] 编写中
- [ ] 已完成
- [ ] 维护中

通过以上两篇文章[Spring Boot 整合Mybaits](part4.md), [Spring Boot  的JPA集成](part5.md)介绍了 Spring Boot 针对数据库访问的两种完备的方式，虽然两种方式功能强大，但同样的学习成本也高，本文将介绍更加简洁的方式: Spring 基于JDBC 的封装 `jdbcTemplate` 的使用，通过`jdbcTemplate`对数据库进行访问和操作  

## jdbcTemplate  
`jdbcTemplate` 是存在`org.springframework.jdbc.core` 包中的类，可以看出，其属于Spring jdbc 的核心部分。它简化了JDBC 的操作，避免出现一些常见的模板性的错误。此类相对来说很简单，其实对JDBC 的封装，没有很多复杂的操作。使用此类，只需要实现必要的回调接口就好

## MongoTemplate  


## RedisTemplate 





## jdbcTemplate 示例  
1.  数据源配置  
本例是通过`jdbcTemplate`对MySQL数据库的操作，需要引入必要的MySQL支持包，由于`jdbcTemplate`是对 JDBC 的封装，所以也需要JDBC 的支持包  

```xml  
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-jdbc</artifactId>
</dependency>
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <scope>runtime</scope>
</dependency>
``` 

2. 配置  
```properties 
spring.datasource.url=jdbc:mysql://localhost:3306/test
spring.datasource.username=root
spring.datasource.password=
spring.datasource.driver-class-name=com.mysql.jdbc.Driver
```