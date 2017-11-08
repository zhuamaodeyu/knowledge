#Idea 通过Maven 集成 Docker unix://localhost:80 no search file or directory

在通过Maven 集成 插件`d` 运行命令 `mvn docker:build`实现docker化的时候，比较常见的错误：

* `unix://localhost:80 no search file or directory`
此报错，在网上大多数搜出来的都是无非一下两种结果：
    * 添加环境变量  
    * 添加环境变量  
以上两种方式验证了，都是有问题，思路是没错，但是在Mac上如果通过直接复制两种命令直接使用时有错误的，会报以下错误：  

 
