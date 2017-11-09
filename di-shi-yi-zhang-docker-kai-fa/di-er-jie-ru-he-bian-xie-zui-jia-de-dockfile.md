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


