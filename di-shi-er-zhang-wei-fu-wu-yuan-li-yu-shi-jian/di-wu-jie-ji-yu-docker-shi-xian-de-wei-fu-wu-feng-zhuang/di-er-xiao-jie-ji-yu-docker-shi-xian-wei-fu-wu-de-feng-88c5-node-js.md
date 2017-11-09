# 第二小节 基于Docker 实现微服务的封装--Node.js  

本章主要讲解的是基于Nodejs 创建微服务程序的Docker 化实现  

## 框架简介

在微服务架构中，最大的特点之一就是 技术选型的多元性，针对不同的项目需求可以选择不同的语言以及框架来实现，通过语言层次来做针对性的优化    


### Nodejs    

> Node.js 是一个基于 Chrome V8 引擎的 JavaScript 运行时。 Node.js 使用高效、轻量级的事件驱动、非阻塞 I/O 模型。 

以上是Node.js 官网对其的简短有力的简介说明。充分说明了Node.js的最大特点。 
通常在对于高并发的问题上，一般采用的都是多线程技术来解决。不过此种方式需要创建大量的线程l来处理更多的请求。但是创建并管理线程是一个非常耗费内存的事情，也会造成大量的上下文切换，在开发中，上下文切换是一个非常耗时的操作。Node.js 采用独特的事件驱动以及异步I/O 的形式独辟蹊径的解决了高并发的问题。 不过Node.js在针对计算频分的情况下就显得有些乏力了，简而言之，Node.js适合I/O密集型操作，并不适合计算密集型操作。   

### Express  
Express 是一个基于Node.js 实现的 Web 框架。是一个快速、简洁、高效的web开发框架。  


## 基于Express Docker 化实践   

###创建项目   

__前提安装Nodejs环境__  
创建 express 项目的两种方式  
    
1. 自动化创建工具    
    * 安装generator  
        `npm install express-generator -g`  
    * 创建项目  
        `express -e myapp`  
        基于以上方式创建的项目，是一个基于express的模板型项目  
        
        ~~~
        .
        ├── LICENSE
        ├── README.md
        ├── app.js
        ├── bin
        │   └── www
        ├── package.json
        ├── public
        │   ├── images
        │   ├── javascripts
        │   └── stylesheets
        │       └── style.css
        ├── routes
        │   ├── index.js
        │   └── users.js
        └── views
            ├── error.ejs
            └── index.ejs
        7 directories, 10 files
        ~~~  
    * 安装项目依赖库  
        `npm install `  
    * 启动项目  
        `npm start` 或者  
        `node ./bin/www`

2. 手动创建  

    * . 安装Express 
    
        Express 项目创建非常简介，在Express 官网主页上就可以看到，很简洁的npm 命令来安装  
    
        ~~~
        mkdir projectName  
        cd projectName  
    
        npm install express --save
    
        //初始化项目  
        npm init 
        ~~~
  
    * . 创建启动文件 app.js  

        ~~~
        var express = require('express') ;  
        var app = express();

        app.get('/',function (req, res) {
            res.send('Hello World');
        });

        app.listen(3000, function () {
               console.log('example app listening on port 3000!'); 
        });
        ~~~  
    * 启动项目   
     
        `node app.js`  
        
    
以上就是创建一个基于Express 的 web项目的基本步骤。  不过更推荐第一种方式创建项目  


### Docker 化    
__在创建Dockerfile文件之前，请先阅读前文[如何编写最佳Dockerfile]__  

1. 通过第一种方式创建项目  

    * Dockerfile   
        在项目根目录同级目录下创建Dockerfile文件  
        
        ~~~
        //基础镜像 
        FROM  node:9.1.0-alpine 
        //工作目录
        WORKDIR /src  
        //复制项目目录
        COPY express-docker-test /src 
        //暴露端口 
        EXPOSE 3000 
        //安装依赖模块 
        RUN  cd /src &&  npm install
        CMD npm start
        ~~~
    * 构建镜像   
     
        `docker build -t xxx/xxxx:tag .`  
    * 测试  
    
        `docker run -p 13000:300 imageId`  
 
  
* . 通过第二种方式创建项目
 
    * Dockerfile  
        项目根目录下创建Dockfile文件  
        
        ~~~
        FROM  node:7-alpine
        # 工作目录  
        WORKDIR /src   
        # 复制项目到目录下  
        COPY ../nodejs /src   
        # 导出端口  
        EXPOSE 3000  
        # 执行命令
        # CMD [ "npm" ,"install" ]    
        RUN  npm install 
        CMD node /src/app.js  
        # CMD [ "node","/src/nodejs/app.js" ]          
        ~~~





