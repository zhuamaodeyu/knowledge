#Idea 通过Maven 集成 Docker unix://localhost:80 no search file or directory

在通过Maven 集成 插件`d` 运行命令 `mvn docker:build`实现docker化的时候，比较常见的错误：

* `unix://localhost:80 no search file or directory`
此报错，在网上大多数搜出来的都是无非一下两种结果：
    * 添加环境变量      
   
        `export DOCKER_HOST=unix:///private/var/tmp/docker.sock`
    * 添加环境变量    
    
        `export DOCKER_HOST=tcp://127.0.0.1:2376`   
        
以上两种方式验证了，都是有问题，思路是没错，但是在Mac上如果通过直接复制两种命令直接使用时有错误的，会报以下错误：  
![5a02a30ce63ce.png](https://i.loli.net/2017/11/08/5a02a30ce63ce.png)   

## 解决方式  
首先肯定以上的方式一的思路正确的，只不过内容出错了。 在Mac系统下为例：
1. 跳转到跟目录，不是用户目录  
2. 执行 `sudo find / -name 'docker*'`搜索，然后找到 `docker.sock`文件的路径   
3. 在`.bash_profile` 中添加环境变量  
    `export DOCKER_HOST=unix:///private/var/run/docker.sock`

 
