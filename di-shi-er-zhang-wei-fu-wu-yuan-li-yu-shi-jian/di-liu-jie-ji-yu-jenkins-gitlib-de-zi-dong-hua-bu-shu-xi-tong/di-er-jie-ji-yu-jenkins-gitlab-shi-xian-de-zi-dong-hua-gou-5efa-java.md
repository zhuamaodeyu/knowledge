# 基于Jenkins GitLab实现的自动化构建---Java  
## 完成状态  

- [ ] 开发中
- [x] 未完成
- [ ] 已完成
- [ ] 维护中


上篇介绍了如何基于Docker运行GitLab实现一个自定义的Git代码管理仓库，这边在上篇的基础上实现了基于Jenkins的基于Maven的Java项目的自动化构建实现   

__关键词:Maven , Jenkins , GitLab, Java__    
##Jenkins   
Jenkins是一个开源的持续集成工具，应用Jenkins搭建持续集成环境，可以进行自动构建、自动编译和部署。  

1. 部署Jenkins  
    * 本地部署
      
        [Jenkins](http://jenkins-ci.org/) 下载jenkins.war的war包，直接放在Tomcat或者其他容器中就可以   
    * docker部署  
        
        在Docker hub 搜索Jenkins就会找到官方的images，下载运行就可以了  

2. 访问  
    使用本地安装方式默认访问的是8080端口，如果使用docker安装的，需要自己根据配置访问配置的端口。  
    默认在第一次访问的时候会有一自个需要输入默认密码的步骤  
    ![默认密码](http://omy43wh36.bkt.clouddn.com/Snip20171109_15.png)  
    需要根据上面提示的路径找到文件并复制其中代码   
    ![docker 下的路径](http://omy43wh36.bkt.clouddn.com/Snip20171109_16.png)  

3. 插件安装    

    Jenkins默认环境下有可能无法构建基于maven的项目的，需要安装插件实现  
    ![安装插件](http://omy43wh36.bkt.clouddn.com/Snip20171110_22.png)     
    搜索 `git plugin`, `GitHub plugin`,`maven Integration plugin`并安装  
    
4. 配置  
    * 配置JDK    
    
        设置个别名。查找到具体的安装路径配置`JAVA_HOME`就可以了 
    * 配置maven  
    
      如果自己不知道自己本地有没有安装或者使用的docker运行的，可以勾线 自动安装  
        ![maven 配置](http://omy43wh36.bkt.clouddn.com/5999951-1be31e27361f4991.png)  
    * 配置Git   
     
        同maven配置类似    
    * 配置邮件服务  
        * 使用Jenkins自带的基础邮件服务  
            



##基于Jenkins下Maven 的Java项目构建  
1. 创建项目  
    ![创建项目](http://omy43wh36.bkt.clouddn.com/Snip20171109_21.png)
2. 配置项目  
    * 源码管理
      
        本实例的源码管理采用的Git来进行管理的(源码存放在gitlab上)， 需要配置Git仓库  
        ![配置](http://omy43wh36.bkt.clouddn.com/Snip20171110_25.png)  
        需要注意，在配置Git的时候有可能遇到以下两种常见错误：  
        * 权限问题  
            ![访问权限](http://omy43wh36.bkt.clouddn.com/Snip20171109_17.png)
            __解决方式:__ 通过 `add` 按钮，添加用户名和密码，或者通过SSH 登录，添加秘钥  
        * 地址无法访问  
            ![无法访问](http://omy43wh36.bkt.clouddn.com/Snip20171110_26.png)  
            __解决方式：__ 
            * 如果是自己搭建的服务器，可以通过问题一解决方案截图中的，通过IP代理地址访问，直接通过IP映射  
            * 通过修改`/etc/hosts`文件，添加IP与地址的映射管理实现  
            * 如果是通过docker搭建的，还可以通过启动docker时添加参数实现  
                
            ``` Bash
                docker run -d -p 8080:8080 -v ~/jenkins:/var/jenkins_home --link 
        gitlab:gitlab.xxx.com   
        --name jenkins jenkinsci/jenkins
            ```  
                
    * 构建触发器配置      
        ![构建触发器](http://omy43wh36.bkt.clouddn.com/Snip20171110_28.png)
        构建触发器配置是是什么条件下触发构建，默认是依照代码仓库更新就构建， 比如`poll SCM`配置的是固件的时间，通常有一下几种配置():  
        * `*/60****`: 每隔60秒构建一次  
        * `H/5****` : 每隔5分钟构建一次  

    * Build配置   
      
        配置pom文件所在位置，如果不是在根目录下，那么久需要指定未见所在目录，不然构建是会失败的。   
        Goals and options 是构建时需要执行的命令 这里使用的是`clean install` , 这些命令是maven命令  
        
        ![](http://omy43wh36.bkt.clouddn.com/Snip20171110_29.png)
    * 构建后操作    
     
        配置构建需要执行的操作，此步骤会在构建成功后执行，配置构建成功后导包，将构建结果导出到特定位置，比如: `target/` 目录下配置 `**/target/*.jar`
        ![](http://omy43wh36.bkt.clouddn.com/Snip20171110_30.png)


 3. 开始构建    
    ![构建项目](http://omy43wh36.bkt.clouddn.com/Snip20171110_31.png)

    如果构建失败，可以通过点击上图中失败的构建，然后通过一下方式查看构建失败的原因，修改构建过程配置或者代码，重新构建  
    ![构建日志查询](http://omy43wh36.bkt.clouddn.com/Snip20171110_32.png)








