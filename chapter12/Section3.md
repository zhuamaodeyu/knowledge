# 基于Java的微服务集成开发框架 Spring Cloud  

Spring Cloud是一个基于Spring Boot实现的云应用开发工具，它为基于JVM的云应用开发中的配置管理、服务发现、断路器、智能路由、微代理、控制总线、全局锁、决策竞选、分布式会话和集群状态管理等操作提供了一种简单的开发方式。   

注意__Spring Cloud 严格意义来讲，并不是一个框架，而是一个工具集，应用于分布式微服务的工具集__    



## 微服务化概念  
1. __注册中心__  
    在微服务架构中，由于服务的粒度更细，所以在大型系统中，往往服务的个数非常多，所以在服务的管理上尤为重要。可以将注册中心理解为微服务的中控中心，只有在注册中心注册过的服务才可以正常的使用。所以在针对注册中心服务中有几点尤为重要的基本要求：简单易用;高可用; 一个简单的服务注册中心可以大大降低服务的注册以及使用等工作，一定程度上提升了服务的稳定性。一个高可用的服务中心，可以在分布式系统中有效的保证服务的正常使用。这两点是最为重要的。还有一点就是跨语言；在微服务架构下，开发不再局限于一种语言，充分的发挥的语言上的优势。所以这也是一个基本的需求    

2. __网关__




##Spring Cloud 组件  
Spring Cloud 包含了丰富的组件，本节内容将不全部一一介绍，而只介绍其中可能在之后章节内容中用到的组件。如果需要了解其他组件，可通过访问[
Spring Cloud](http://projects.spring.io/spring-cloud/)来查看     


1. __Spring Cloud Config__     
    Spring Cloud Config是为分布式系统中的外部化配置提供统一服务器和客户端支持。通过服务端，可以集中性的管理外部配置属性
    当应用在不同环境之间切换时，可以统一的进行管理。其服务器端是基于Git进行管理的，可以轻松的进行版本控制。
2. __Spring Cloud Netflix__     
    Spring Cloud Netflix 通过自动化配置的方式为Spring boot应用提供Netflix OSS 组件集成支持。仅仅通过一些简单的注解，就可以快速集成Netflix 组件，构建大型的分布式系统。Netflix 中主要包括服务发现(Eureka)， 断路器(Hystrix)，智能路由(Zuul)，客户端负载均衡(Ribbon)等等内容    
    * Eureka: 服务注册中心     
    * Hystrix: 断路器和资源隔离    
    * Feign: 声明式HTTP REST请求客户端    
    * Ribbon: 与Eureka结合实现软负载均衡    
    * Zuul: API请求路由，即Api Gateway    

3. __Spring Cloud Bus__     
4. __Spring Cloud Cluster__    
5. __Spring Cloud Consul__   
6. __Spring Cloud Security__   
7. __Spring Cloud Sleuth__   
8. __Spring Cloud Zookeeper__   
9. __Spring Cloud CLI__  
10. __Spring Cloud Gateway__   
11. __Spring Cloud OpenFeign__   




#### 说明 
此部分内容全部基于 2.0 来实现   

