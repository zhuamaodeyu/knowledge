# 基于Docker 实现微服务的封装-----Spring Boot  
微服务化的方式有很多种，具体的技术选型根据不同的需求可能会使用不同的框架甚至不同的语言来实现， 本小节主要是通过 Docker  化 基于 Spring Boot 的实现的web服务。 不多说 直接开始  

1. 创建项目    

    项目是通过Idea 创建，可以直接创建Spring Boot 项目  
    ![第一步](http://omy43wh36.bkt.clouddn.com/Snip20171108_2.png)     
    ![第二步](http://omy43wh36.bkt.clouddn.com/Snip20171108_3.png)
    ![第三步](http://omy43wh36.bkt.clouddn.com/Snip20171108_4.png)
    选中 web 就可以了，然后一直下一步，这就是一个简单的的 基于 Spring ，Spring MVC的web 项目    

2. 修改 `pom.xml` 文件,以支持Docker  
    项目是基于 Maven 构建的，所有的maven配置都在此文件中，添加库等等操作都在此处。具体的不赘述maven操作。请自行查看具体的章节或者百度    
    在pom.xml 文件中添加一下内容   
    
    ~~~
      	<plugin>
				<groupId>com.spotify</groupId>
				<artifactId>docker-maven-plugin</artifactId>
				<version>0.4.10</version>
				<configuration>
					<imageName>${project.groupId}/${project.artifactId}:${project.version}</imageName>
					<dockerDirectory>${project.build.outputDirectory}</dockerDirectory>
					<resources>
						<resource>
							<directory>${project.build.directory}</directory>
							<include>${project.build.finalName}.jar</include>
						</resource>
					</resources>
				</configuration>
			</plugin>      
    
    ~~~  
    
   __说明:__   
   此时可以构建项目，不过推送会推送到 ``
    

    
    
