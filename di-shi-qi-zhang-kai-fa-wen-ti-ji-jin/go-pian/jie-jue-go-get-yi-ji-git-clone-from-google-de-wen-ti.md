# go get 以及 Git clone from google 问题
由于某些不可抗拒因素(其实就是ZFW)的原因，造成Google的代码无法现在，典型的两个问题就是  

* go get 无法下载    
	`go get golang.org/x/crypto`	
	虽然获取代码是以上这句，其实服务器会进行转发，所以最终还是使用git获取代码(此问题是由于go 的特性造成的)  go get 命令其内部是通过 git 这样的代码管理程序来获取代码的   
	
	__解决办法:__   
	
	* 首先要有一个梯子  
		自己根据自己需要获取VPN 等翻墙程序  
	* 自行下载 `proxifier` 程序     
		我使用的是`Shadowsocks`, 其只提供了 SOCKET5 代理，默认的代理端口是 1080 ，根据这些内容配置 `proxifier` (__具体的端口和代理类型需要根据自己的梯子自行配置__)  
		![](http://omy43wh36.bkt.clouddn.com/Snip20171113_1.png)  
		配置需要走代理的程序，此处由于是针对 go 的，需要让go 走代理  
		 ![](http://omy43wh36.bkt.clouddn.com/Snip20171113_2.png)  
		 ![](http://omy43wh36.bkt.clouddn.com/Snip20171113_4.png)  
		
		__重启终端__  
		根据以上配置， 只是让go 可以连接到Google的服务器，此时并不能下载下来代码， 执行`go get golang.org/x/crypto` 会转到 git clone 代码， 只是让go 支持了服务器解析地址的功能， 下一步还需要让git 可以支持代理  
	
	
	
* git 无法clone google 的仓库代码    
	由于 `Shadowsocks` 只支持 socket 5 代理， git 走的是 https/http 代理，此处需要将 socket5 代理转换为 https/http 代理。 可以通过 `privoxy` 程序来实现  
	__解决办法__  
		
	* 下载安装 `privoxy`  
	* 配置 `privoxy`  
		默认配置文件存放在 `/usr/local/etc/privoxy` (Mac 系统中)
		如果无法找到 可以通过`find / -name "privoxy"` 进行搜索查找  
	* 添加配置  
		打开 config 文件，在后面添加  
		`forward-socks5 / 127.0.0.1:1080 .`  
		重启程序生效  
		`/etc/init.d/privoxy restart`  
__大功告成啦__  

	
	