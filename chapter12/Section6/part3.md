 
# 基于Jenkins docker化 

## 完成状态  

- [ ] 开发中
- [ ] 未完成
- [ ] 已完成
- [x] 维护中

自动化构建并不是终点。
本节主要实现的是如何通过Jenkins自动化构建出的结果，docker化镜像并推送到仓库等待部署   
由于Jenkins 本身采用的是docker的镜像，我们需要实现的是在docker镜像中构建docker镜像。

__说明__  
本文内容参考了[tfss](https://tfssweb.github.io/2017/11/08/Docker%E6%90%AD%E5%BB%BAJenkins%E7%8E%AF%E5%A2%83.html) 在此说明，非常感谢tfss的文章  


### 构建可用docker镜像
1. 创建Dockerfile   

	```Docker
	FROM jenkins:alpine
	# 下载安装Docker CLI
	USER root
	RUN curl -O https://get.docker.com/builds/Linux/x86_64/	docker-latest.tgz \
    	&& tar zxvf docker-latest.tgz \
    	&& cp docker/docker /usr/local/bin/ \
    	&& rm -rf docker docker-latest.tgz

	# 设置基本环境变量  
	ENV DOCKER_VERSION 1.0 

	# 添加数据卷  
	VOLUME [ "/data" ]   

	USER jenkins  

	#RUN usermod -aG docker jenkins
	#RUN groupadd -r jenkins && useradd -r -g jenkins jenkins
	# 进入容器时工作目录  
	WORKDIR /the/workdir/path 

	# 将 `jenkins` 用户的组 ID 改为宿主 	`docker` 组的组ID，从而具有执行 	`docker` 命令的权限。
	ARG DOCKER_GID=999  

	USER root:${DOCKER_GID}
	```

2. 构建镜像  
	`docker build -t jenkins-docker .`  
3. 启动容器  
	
	```Docker
	docker run --name jenkins \
    -d \
    -p 8080:8080 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    jenkins-docker
	```

	__注意__  
		由于docker最近几个版本的更改为通过socket通信(其实是懒得查那个版本改的), 所以 。。。。 不管了 反正就是这个命令运行  
	
	
### 构建镜像 
__以maven项目为例__   
在Jenkins中创建maven 风格的job 时，其中有两个内容  `Pre Steps` 设置构建前执行的脚本； `Post Steps` 设置构建后执行的脚本  

1. 更改 `Post Steps` 类型为 第一个  只有在成功后才执行脚本  
2. 脚本内容  
	
	```Bash
	# 定义变量  
	API_NAME="spring-docker-test"  
	API_VERSION="0.0.1"  
	API_PORT=58080  
	IMAGE_NAME="192.168.99.100:32781/playtomandjerry/java-	docker-test:$BUILD_NUMBER"  
	CONTAINER_NAME=$API_NAME-$API_VERSION  

	# 进入target 目录 复制dockerfiler  
	cd $WORKSPACE/target  
	cp classes/Dockerfile  .

	echo ---------------------
	echo $IMAGE_NAME
	echo $CONTAINER_NAME
	echo $WORKSPACE
	echo ---------------------

	#启动服务  
	sudo docker start
	#构建镜像  
	docker build -t $IMAGE_NAME .  
	# 推送镜像  
	#docker push $IMAGE_NAME .  

	echo '构建成功'

	#删除 Docker 容器 
	#cid = ${docker ps | grep "$CONTAINER_NAME" | awk '{print $1}'}
	#if ["$cid" !=""]; then  
	#	docker rm -f $cid 
	#fi  
	# 运行docker
	#docker run -d -p $API_PORT:8080 --name $CONTAINER_NAME $IMAGE_NAME

	#删除 Dockerfile 文件  
	rm -f Dockerfile
	```


__本实例还有很多不完善的地方，之后会进行慢慢完善__   

	