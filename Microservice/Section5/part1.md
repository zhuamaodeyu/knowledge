# 基于Docker 实现微服务的封装-----Spring Boot  
微服务化的方式有很多种，具体的技术选型根据不同的需求可能会使用不同的框架甚至不同的语言来实现， 本小节主要是通过 Docker  化 基于 Spring Boot 的实现的web服务。 不多说 直接开始  

1. 创建项目    

    项目是通过Idea 创建，可以直接创建Spring Boot 项目  
    ![第一步](../../assets/gitbook/Snip20171108_2.png) 
    ![第二步](../../assets/gitbook/Snip20171108_3.png)
    ![第三步](../../assets/gitbook/Snip20171108_4.png)
    选中 web 就可以了，然后一直下一步，这就是一个简单的的 基于 Spring ，Spring MVC的web 项目    

2. 修改 `pom.xml` 文件,以支持Docker  
    项目是基于 Maven 构建的，所有的maven配置都在此文件中，添加库等等操作都在此处。具体的不赘述maven操作。请自行查看具体的章节或者百度    
    在pom.xml 文件中添加一下内容   
    
    ```xml
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
    
    ```  
    
   __说明:__   
   此时可以构建项目，不过推送会推送到 `hub registry`上，如果需要推送到自己搭建的 docker registry中去 需要执行以下步骤：  
   * 添加自定义属性   
      `<docker.registry>ip:port</docker.registry>`  
     
   * 修改第二步中 `imageName` 标签的内容
     `<imageName>${docker.registry}/${project.groupId}/${project.artifactId}:${project.version}</imageName>
`  

3. 实现 Dockerfile 
   在项目的 resources 目录下创建 Dockerfile 文件并实现内容(具体的Dockerfile书写规则自行查找，以下为简介版) 
   
   
    ```Docker
    
     FROM java
     # 作者名称和邮箱
     MAINTAINER "name"<xxxx@gmail.com>

    ADD @project.build.finalName@.jar app.jar

    #ADD demo-0.0.1-SNAPSHOT.jar app.jar
    # 此导出端口尽量和项目server端口相同
    EXPOSE 8081

    CMD java -jar app.jar
    ```



4 . 构建与推送  
   通过一下命令实现构建  
   
   `mvn docker:build`  
   通过一下命令推送    
   
   `mvn docker:push`
  
5 . 运行docker 并访问  
  
  通过一下命令运行docker 镜像  
  ` docker run -p 18080:8080 7c59ebe232ee`  
  * -p 18080:8080  通过将宿主机的18080 映射到容器的8080 端口，在宿主机中通过 18080 端口就可以访问到容器中的8080 端口  
  
   测试访问   
   `localhost:18080` 测试访问是否成功
  
    

