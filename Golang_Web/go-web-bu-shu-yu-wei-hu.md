#Go Web 部署与维护     
1. 应用日志  
2. 网站错误处理  
3. 应用部署  
4. 备份和恢复   


## 应用日志   
虽然Go语言本身标准库中提供了log日志的功能，不过其并不能像log4j这样强大的日志处理能力。    

可以使用第三方的日志系统[seelog](https://github.com/cihub/seelog)       
  
###seelog   
它提供了一些简单的函数来实现复 的日志分配、过滤和格式化

#####特点：  
* XML的动态配置,可以不用重新编译程序而动态的加载配置信息    
* 支持热更新,能够动态改变配置而不需要重启应用    
* 支持多输出流,能够同时把日志输出到多种流中、例如文件流、网络流等   
* 支持不同的日志输出   
	*  命令行输出  
	*  文件输出  
	*  缓存输出 
	*  支持 log rotate  
	*  SMTP邮件  

#####简单使用：  

* 安装  

~~~  
//安装   
go get -u github.com/cihub/seelog  

package main 

import log "github.com/cihub/seelog"  

func main(){
	defer log.Flush();  
	log.Info("Hello from Seelog!")   
}

~~~   

* 自定义日志处理   

~~~  
package logsimport (    "errors"    "fmt"    seelog "github.com/cihub/seelog"    "io")var Logger seelog.LoggerInterfacefunc loadAppConfig() {    appConfig := `<seelog minlevel="warn">    <outputs formatid="common">        <rollingfile type="size" filename="/data/logs/roll.log" maxsize="100000" maxrolls="5"/>        <filter levels="critical">            <file path="/data/logs/critical.log" formatid="critical"/>            <smtp formatid="criticalemail" senderaddress="astaxie@gmail.com" sendername="ShortUrl API" hostname="smtp.                <recipient address="xiemengjun@gmail.com"/>            </smtp>        </filter>    </outputs>    <formats>        <format id="common" format="%Date/%Time [%LEV] %Msg%n" />        <format id="critical" format="%File %FullPath %Func %Msg%n" />        <format id="criticalemail" format="Critical error on our server!\n %Time %Date %RelFile %Func %Msg \nSent b></format>    </formats></seelog>


     logger, err := seelog.LoggerFromConfigAsBytes([]byte(appConfig))     if err != nil {         fmt.Println(err)return }     UseLogger(logger) } func init() {     DisableLog()     loadAppConfig() } // DisableLog disables all library log output func DisableLog() {     Logger = seelog.Disabled } // UseLogger uses a specified seelog.LoggerInterface to output library log. // Use this func if you are using Seelog logging system in your app. func UseLogger(newLogger seelog.LoggerInterface) {     Logger = newLogger }~~~
解析:    

* DisableLog    
初始化全局变量 Logger 为seelog的禁用状态， 主要为了防止Logger被多次初始化   
* loadAppConfig  
配置文件初始化seelog的配置信息    

* UserLogger   
设置当前的日志器为相应的日志处理

~~~  
package main import (     "net/http"     "project/logs"     "project/configs"     "project/routes") func main() {     addr, _ := configs.MainConfig.String("server", "addr")     logs.Logger.Info("Start server at:%v", addr)     err := http.ListenAndServe(addr, routes.NewMux())     logs.Logger.Critical("Server err:%v", err)}~~~    


### 网站错误处理    
日常运行可能出现的错误：   

* 数据库错误   
	* 连接错误  
	* 查询错误 
	* 数据错误   
* 运行时错误   
	* 文件系统和权限   
	* 第三方应用   

* HTTP 错误  
* 操作系统错误  
* 网络错误  































