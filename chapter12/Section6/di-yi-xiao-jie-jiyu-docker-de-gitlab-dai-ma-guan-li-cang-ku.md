# 第一小节 基于Docker 化的GitLab 代码管理仓库  

##完成状态  

- [x] 开发中
- [ ] 未完成
- [ ] 已完成
- [ ] 维护中   
  

Gitlab 是一个基于Git的开源代码管理仓库，其实GitHub的开源版。功能上几乎没有任何区别，任何人都可基于gitlab创建自己私有的代码管理仓库，主要用于公司、团队管理内部的程序代码。  
     GitLab分为几个版本的，一般CE版针对个人使用，如果要搭建私有的GitLab， 直接去[GitLab](https://github.com/gitlabhq/gitlabhq.git)仓库下载源码运行就可以。具体的搭建方式请自行搜索      
     由于本系列文章主要讲解的是基于Docker实现的微服务架构，那么所有的理应都使用Docker化，GitLab也不例外，下面是如果实现基于Docker的GitLab   
     
 
 __以下所有操作基于Mac系统实现,并基于Kitematic操作__    
 
1. 获取GitLab-ce Docker镜像    
    ![搜索镜像](http://ozjlhf9e0.bkt.clouddn.com/20171118151098030197139.png)
    Docker Hub搜索 GitLab-ce 通过命令下载镜像到本地并运行  
    __注意:__   
    
    在这里还是要强调一点， 在安装镜像时，首先先查找有没有Docker 官方发布的对应镜像,例如在 `Kitematic` 中就是带有一下标志的  
    ![官方镜像](http://ozjlhf9e0.bkt.clouddn.com/20171118151098038871137.png) 
    官方镜像在稳定性以及维护上都有很好的支持   
    如果对应的镜像没有官方镜像，那么就查找是否有对应的软件出品方制作的镜像例如 `gitLab` 出品的 `gitlab-ce` 镜像     
2.  注册用户  
    ![注册用户](http://omy43wh36.bkt.clouddn.com/Snip20171109_6.png)   

3. 创建项目  
    ![创建项目](http://omy43wh36.bkt.clouddn.com/Snip20171109_8.png)
    __注意：记住此处的`Project path` 的IP地址哦__  
    ![仓库创建](http://omy43wh36.bkt.clouddn.com/Snip20171109_5.png)
4. 推送代码到仓库    

    仓库创建成功后，底部就会有针对不同的情况如何将代码推送到仓库中哦，不过，仓库的地址中IP部分是一个随机的字符串，此处需要特别注意，在执行命令的时候要将这部分替换为步骤二让特别注意的部分哦 。或者通过一下方式查看IP地址  
    ![查看docker 映射地址](http://omy43wh36.bkt.clouddn.com/Snip20171109_7.png)
    

__基于 Docker for Mac 实现__  
第三步可以通过命令查看 宿主机和容器的映射端口，主要在这步有区别，其他都是相同的  

    
      
       
     
