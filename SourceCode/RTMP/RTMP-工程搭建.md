# RTMP 源码分析  


## 示例工程 
1. 创建 cocoa demo 工程  
2. 下载 RTMP dump 将其中的librtmp 拖入示例工程   
3. 添加 openssl到工程  
    * 自己编译   
        
    * pod 
        `pod 'OpenSSL-Universal', '1.0.2.20'`

4. swift 工程(需要操作此步骤，OC 略过)  
    *  创建 module.modulemap 文件  
        ```
        module librtmp {
            header "librtmp/rtmp.h"
            export *
        }
        ```
    * 修改 swift inport search path 路径 





## 测试 
1. 安装 `Local RTMP server` 
2. ffmpeg 推流到地址 
    `ffmpeg -re -i /Users/caolongjian/Desktop/CCVideo.mp4  -vcodec copy -f flv rtmp://localhost:1935/abcs/room`


3. 搭建 livego 服务器 
```shell 
docker run -p 1935:1935 -p 7001:7001 -p 7002:7002 -p 8090:8090 -d gwuhaolin/livego  
```
> 8090: http 管理访问监听地址 
> 1935: rtmp 服务坚听地址 
> 7001: HTTP-FLV 服务坚听地址 
> 7002: HLS 服务监听地址 

* 默认推流地址 
    `rtmp://localhost:1935/live` 
* 获取默认的推流 channel key 
    `http://localhost:8090/control/get?room=movie`





## 参考 
* [玩转直播系列之从 0 到 1 构建简单直播系统（1）](https://mp.weixin.qq.com/s?__biz=MzI4NjY4MTU5Nw==&mid=2247490988&idx=1&sn=35cd2857ca03bfe11c6727760f1609ad&chksm=ebd86d3edcafe42842ab31f5ea60e477677d618234482564f4d846454821f6845e2ef602389b&scene=178&cur_album_id=1612326847164284932#rd)  
