# 如何编写最佳的Dockfile  
Dockfile 是构建image的自动化脚本文件，其可以通过编写脚本让docker自动的去下载需要的文件或程序等内容，构建完成一个可使用的image。 虽然Dockerfile 的语法很简单，然而如何加快镜像的构建速度，如何减少docker镜像的大小却是需要积累更多的工作经验的。    

__本文是对![How to write excellent Dockerfiles](https://rock-it.pl/how-to-write-excellent-dockerfiles/) 的总结__  

优化的方式总结有以下几点：
  
    1. 编写`.dockerignore`文件  
    2. 容器只运行单个应用  
    3. 将多个RUN 指令合并为一个  
    4. 基础镜像标签不要用latest 
    5. 每个RUN 指令后删除多余文件  
    6. 选择合适的基础镜像（alpine版）  
    7. 设置 WORKDIR 和 CMD  
    8. 使用 ENTRYPOINT  
    9. 在entrypoint 脚本中使用 exec 
    10. copy与ADD 优先使用COPY  
    11. 合理使用COPY 和RUN 的顺序  
    12. 设置默认环境变量，映射端口和数据卷  
    13. 使用LABEL 设置镜像元数据  
    14. 添加HEALTHCHECK  
    
## 操作实例  
示例Dockerfile  

~~~
FROM ubuntu
ADD . /app
RUN apt-get update  
RUN apt-get upgrade -y  
RUN apt-get install -y nodejs ssh mysql  
RUN cd /app && npm install
# this should start three processes, mysql and ssh
# in the background and node app in foreground
# isn't it beautifully terrible? <3
CMD mysql & sshd & npm start

~~~
构建镜像：  
`docker build -t xxx .`   

1.  第一步  编写`.dockerignore`文件   

      构建镜像之前，docker会先准备context，将需要的文件收集进进程。默认的context是包括Dockerfile目录下的所有文件，不过有时候由于项目的管理以及Dockerfile存放的位置等问题，或多或少都会有其他文件，比如 `.git`等文件。这些文件并没有必要使用，所以可以需要将此部分内容忽略掉。通过编写类似`.gitignore`等文件可以忽略掉部分内容，加快镜像构建时间，减少大小。  
      
      ~~~
      .git/
      node_modules/
      
      ~~~
      
2. 第二步  容器单一职责  
    容器单一职责就是一个容器只运行一个需要的程序，比如：在LAMP环境下，需要Apache，MySQL ，PHP 等程序，不要将所有的程序运行在一个image中，将其抽成3个镜像。每个镜像负责不同的部分
    
    ~~~
    //实例内容删除后面内容
    RUN apt-get install -y nodejs     
    ~~~

3. 将多个RUN 合并为一个  
    Docker 镜像是分层的，Dockerfile 的每一个指令都会创建一个新的镜像层，镜像层会被缓存和复用；每个命令的更改都会导致一个镜像和之后的镜像失效;__镜像层是不可变的，如果在某层添加文件后在下层删除文件，此文件还会包含在镜像中，只是不可见__  
    
    ~~~
    RUN apt-get update \ 
    && apt-get install -y nodejs  
    && cd /app \
    && npm install  
    
    ~~~

4. 