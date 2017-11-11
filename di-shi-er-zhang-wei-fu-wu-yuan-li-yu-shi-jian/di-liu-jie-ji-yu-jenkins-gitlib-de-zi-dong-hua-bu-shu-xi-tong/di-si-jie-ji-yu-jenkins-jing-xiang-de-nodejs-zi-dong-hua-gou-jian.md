# 第四节 基于Jenkins 镜像的nodejs 自动化构建   

不废话 ，直接开始  

## 插件  
默认状态下，Jenkins是不支持nodejs的构建的， 其需要安装插件来实现  

1. 安装插件  
`系统管理`---->`插件管理`----->`可选插件`  

![插件](http://omy43wh36.bkt.clouddn.com/Snip20171111_44.png)   

2. 配置插件  
	`系统管理`----->`Global Tool Configuration`------>`nodejs`  
	![配置插件](http://omy43wh36.bkt.clouddn.com/Snip20171111_46.png)  
	配置nodejs，让系统自动下载node 
	![](http://omy43wh36.bkt.clouddn.com/Snip20171111_43.png)  

## job  

1. 创建job  
	node 使用的是基本项目，在创建时只需要创建`构建一个自由风格的软件项目`。   

2. 配置项目  
	当前系统中，还并没有node 程序，需要通过配置，让系统在构建的时候自动下载安装nodejs程序。  
	![工程配置](http://omy43wh36.bkt.clouddn.com/Snip20171111_41.png)

3. 构建项目  
	项目创建成功后，直接构建项目，系统会自动下载安装node。如果顺利，那么就会安装成功  
	
## 总结  
虽然以上已经很好的可以完成项目构建了，but， 哈哈 ，这只是利息那个状态下 。以下是我在使用时出现的问题  

* SSL 问题  
	系统在下载node的时候，有可能会提示 SSL相关的错误，无法安装nodejs， 遇到此种问题， 重新构建一次试试，一般都会成功   

* npm not found   
	此种错误是在node安装时没有正确安装成功造成的。Jenkins虽然会自动下载安装node，但是有时候由于其他原因造成的无法安装成功。可以试试此种方式解决  
		* 查找是否下载成功  
			进入 `/var/jenkins_home/tools/jenkins.plugins.nodejs.tools.NodeJSInstallation`文件夹下是否有node文件夹。查看其中是否有关于node的文件  
		* 手动添加环境变量  
			修改构建配置，`构建`-----> `Execute shell` 添加环境变量  
			![添加环境变量](http://omy43wh36.bkt.clouddn.com/Snip20171111_47.png)  
			添加一下内容  
			
			~~~
			export PATH="$PATH:/var/jenkins_home/tools/jenkins.plugins.nodejs.tools.NodeJSInstallation/node/bin"
			~~~
			
		