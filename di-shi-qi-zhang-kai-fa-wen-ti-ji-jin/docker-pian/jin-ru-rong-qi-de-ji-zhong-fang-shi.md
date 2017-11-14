# 进入容器的几种方式  
刚开始使用docker的时候，使用的是 Kitematic,使用此种方式不用关心很多参数以及操作，都提供了图形化的界面。但是有时候有些操作是它所不能完成的。 比如在启动容器的时候指定参数   

通过命令行启动docker，比较关心的就是如何进入容器。进入docker有以下几种方式：  
    * docker attach  
        `sudo docker attach bb189a596c04`  
        __使用此命令会进行多个窗口同步，如果一个窗口阻塞，那么都会阻塞__  
    * SSH  
        
    * nsenter  
        nsenter 可以访问另一个进程的名称空间。 此程序是安装在`宿主机`的  
        
        * 安装  
        
        ~~~
        wget https://www.kernel.org/pub/linux/utils/util-linux/v2.24/util-linux-2.24.tar.gz  
        tar -xzvf util-linux-2.24.tar.gz  
        cd util-linux-2.24/  
        ./configure --without-ncurses  
        make nsenter  
        sudo cp nsenter /usr/local/bin  
        ~~~
        
        * 获取进程空间  
            `sudo docker inspect id`  
            使用以上命令查看容器的详细信息  
            
        
    * exec  
    