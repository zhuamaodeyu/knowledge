# Java篇  
Java篇是一个以Java语言为实现语言，其微服务的全部功能都依赖于Java的技术栈，主要包括了 spring boot 和 Spring Cloud ，通过这两个专为微服务服务的框架来实现微服务化，针对服务中独特点都将采用Spring Cloud 中的继承组件来实现   

本篇将实现以及基本的投票系统，通过微服务docker化的方式实现  

## 系统需求  
构建一个用户查看活动、 报名活动、接收通知的系统  

###包含功能  
* 
### 服务划分  

###服务定义  

###服务支撑  
* Spring  Boot     

  提供基础工程模板以及功能实现
* Spring Cloud Config  

  提供集中化的配置信息管理功能  
* Zuul    

  提供服务的网关服务  
* Hystrix   

  提供熔断机制   
  
* Spring Cloud Security    

  提供用户的授权和认证   
  
* Eureka Server     

  提供服务的注册发现机制  
  

###基础设施  
* Jenkins    

 提供持续交付流水线  
* Docker    

 提供服务打包和发布  
* Rancher   

 提供轻量级Docker 管理方案  
* 日志聚合服务  
  * ElasticSearch   
   
    提供搜索服务  
  *  LogStash     
  
    log处理机制  
  *  Kibana
     
    日志展示工具  
    
###技术选型  
* Java  
* Maven  
* Spring Boot 
* Spring Cloud 
   * zuul  
* MongoDB  
* Redis  
* easy-mock  
* REST ful  
* JVM-Pact  
