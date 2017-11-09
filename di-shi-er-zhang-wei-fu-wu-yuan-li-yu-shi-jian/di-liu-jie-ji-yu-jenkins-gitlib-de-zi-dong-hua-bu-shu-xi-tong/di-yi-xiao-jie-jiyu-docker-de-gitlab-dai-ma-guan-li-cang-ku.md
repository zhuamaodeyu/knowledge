# 第一小节 基于Docker 化的GitLab 代码管理仓库  
    
   Gitlab 是一个基于Git的开源代码管理仓库，其实GitHub的开源版。功能上几乎没有任何区别，任何人都可基于gitlab创建自己私有的代码管理仓库，主要用于公司、团队管理内部的程序代码。  
     GitLab分为几个版本的，一般CE版针对个人使用，如果要搭建私有的GitLab， 直接去[GitLab](https://github.com/gitlabhq/gitlabhq.git)仓库下载源码运行就可以。具体的搭建方式请自行搜索      
     由于本系列文章主要讲解的是基于Docker实现的微服务架构，那么所有的理应都使用Docker化，GitLab也不例外，下面是如果实现基于Docker的GitLab   
     
 
 __以下所有操作基于Mac系统实现,并基于Kitematic操作__    
 
1. 获取GitLab-ce Docker镜像    

    Docker Hub搜索 GitLab-ce 通过命令下载镜像到本地并运行  

2.  注册用户  
    ![注册用户](http://omy43wh36.bkt.clouddn.com/Snip20171109_6.png)   

3. 创建项目  
    ![创建项目](http://omy43wh36.bkt.clouddn.com/Snip20171109_8.png)
    __

    
      
       
     
