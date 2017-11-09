#Docker 加速  
由于不可抗拒的因素(你懂得)，在国内访问 Docker registry 服务器非常慢的。需要通过其他途径对其进行加速访问。如何多起进行加速是个技术活(尴尬脸)  

__以下操作都是基于Mac的__  
Mac上安装Docker如今又两种形式：一种是通过 Docker for Mac 安装，一种是通过Dokcer Toolbox 形式安装，两种形式的加速方式是不同的  

* Docker for Mac    
    * GUI操作
        通过顶部的图标找到docker，然后按照以下操作实现  
        ![](http://omy43wh36.bkt.clouddn.com/Snip20171109_12.png)  
        ![](http://omy43wh36.bkt.clouddn.com/Snip20171109_13.png)  

    * 通过命令行操作
        Docker 的操作会映射到一个`daemon.json` 文件上  
        在Mac系统下，此文件会路径在`vim /Users/xxx/.docker/daemon.json`  
        打开文件将文件修改为以下内容  
        ~~~
        {
            "insecure-registries" : [
                "registry.mirrors.aliyuncs.com"
              ],
            "debug" : true,
            "experimental" : true,
            "registry-mirrors" : [
                    "https://registry.docker-cn.com",
                    "https://docker.mirrors.ustc.edu.cn",
            "https://ttjg6kp3.mirror.aliyuncs.com"
  ]
}
        
        ~~~
*  Docker Toolbox   
   * 进入默认的环境  
       `docker-machine  ssh default`  
   * 修改profile文件  
       
       ~~~
       vi /var/lib/boot2docker/profile
       //添加一下内容到EXTRA_ARGS 中,地址为自己的阿里云地址  
       --registry-mirror=https://xxx.mirror.aliyuncs.com
       ~~~
       
   * 重启生效
       `sudo /etc/init.d/docker restart`

