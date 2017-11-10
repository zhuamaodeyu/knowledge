# 基于Jenkins GitLab实现的自动化构建---Java  

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
    

##基于Jenkins下Maven 的Java项目构建  
1. 插件安装    

    Jenkins默认环境下有可能无法构建基于maven的项目的，需要安装插件实现  
    ![安装插件](http://omy43wh36.bkt.clouddn.com/Snip20171110_22.png)     
    搜索 `git plugin`, `GitHub plugin`,`maven Integration plugin`并安装  
    
2. 配置  
    * 配置JDK  
        设置个别名。查找到具体的安装路径配置`JAVA_HOME`就可以了 
    * 配置maven
          如果自己不知道自己本地有没有安装或者使用的docker运行的，可以勾线 自动安装  
          ![maven 配置](http://omy43wh36.bkt.clouddn.com/5999951-1be31e27361f4991.png)  
    * 配置Git  
        同maven配置类似  


