# Java篇  
Java篇是一个以Java语言为实现语言，其微服务的全部功能都依赖于Java的技术栈，主要包括了 spring boot 和 Spring Cloud ，通过这两个专为微服务服务的框架来实现微服务化，针对服务中独特点都将采用Spring Cloud 中的继承组件来实现   

本篇将实现以及基本的投票系统，通过微服务docker化的方式实现  

## 系统需求  
构建一个社交软件的API后台部分系统服务，系统采用REST ful 接口规范提供API 服务。  

###包含功能  
* 注册登录模块  
* 内容列表展示模块
* 内容详情展示模块    
* 用户个人信息模块  
* 评论模块 
* 内容发布模块
* 文件上传模块  
* 通知系统  
* 推荐系统  

### 服务划分  
服务的划分主要分为一下两种形式： 根据业务对象划分服务； 针对业务行为划分服务。本次采用的是针对业务对象划分服务形式。其在以上包含的功能模块下会酌情进行更加细粒度的拆分。


__说明:__  

  当前定义的模块总共以上内容，会根据具体的开发情况，会删减模块功能  
  
  
###服务定义  
* ServiceCenterPeerA 
* ServiceCenterPeerB  
  服务调度中心服务，主要提供服务之间的调度
* GatewayService  
  网关服务，提供整个程序的入口以及服务安全把控  
* CustomService  
  体用整个系统的基础服务功能  
* ApiService  
  提供API服务模块
* RegisterService  
  主要提供注册登录服务模块，单一注册以及第三方注册等功能  
* QuestionService  
  内容模块
* CommentService  
  评论功能，主要提供评论发布以及查询功能  
  



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
