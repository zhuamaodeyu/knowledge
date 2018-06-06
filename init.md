# 开发环境搭建  

## 环境  
    * Ceontos 7  

### java  
### Maven  
### tomcat 
### zookeeper
1. download
2. 设置环境变量
    ```shell 
    #  ~/.bash_profile      用户环境变量 
    #  /etc/profile         系统环境变量  
    MAVEN_HOME=/opt/apache-maven-3.5.3
    MAIL=/var/spool/mail/vagrant
    export JAVA=/opt/jdk1.8.0_171/bin/java
    export PATH=$JAVA_HOME/bin:$JAVA_JRE/bin:$JAVA:$PATH
    # elasticsearch
    export ELASTICSEARCH_HOME=/opt/elasticsearch-6.2.4
    export PATH=$ELASTICSEARCH_HOME/bin:$PATH

    #tomcat
    export CATALINA_HOME=/opt/apache-tomcat-8.5.30
    export PATH=$CATALINA_HOME/bin:$PATH

    #zookeeper
    export ZOOKEEPER_HOME=/opt/zookeeper-3.4.12
    export PATH=$PATH:$ZOOKEEPER_HOME/bin

    # marathon
    export MARATHON_HOME=/opt/marathon-1.6
    export PATH=$PATH:$MARATHON_HOME/bin

    # Maven 环境变量
    export MAVEN_HOME=/opt/apache-maven-3.5.3
    export PATH=$MAVEN_HOME/bin:$PATH

    ```

### Docker
1. 查看内核 
    ```shell 
    uname -r 
    # 更新  
    sudo yum update 
    ```
2. 安装 
    ```shell 
    # remove old docker 
     sudo yum remove docker  docker-common docker-selinux docker-engine
    # 安装 
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2
    sudo yum-config-manager --add-repo 
    #  https://download.docker.com/linux/centos/docker-ce.repo

    # 查看版本 
    yum list docker-ce --showduplicates | sort -r 

    # 安装 
    sudo yum install docker-ce
    ```
3. 设置开机启动 
    ```shell 
    sudo systemctl start docker
    sudo systemctl enable docker
    ```


### gitlab 
1. 前期工作 
    ```shell
    sudo yum install curl policycoreutils policycoreutils-python openssh-server openssh-clients
    sudo systemctl enable sshd
    sudo systemctl start sshd

    sudo yum install postfix
    sudo systemctl enable postfix
    sudo systemctl start postfix

    sudo firewall-cmd --permanent --add-service=http
    sudo systemctl reload firewalld

    ```
2. download 
    ```shell
    # 下载  
    wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-8.0.0-ce.0.el7.x86_64.rpm
    # 解压 
    rpm -i gitlab-ce-8.0.0-ce.0.el7.x86_64.rpm

    # 方式2  
    curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash  
    sudo yum install gitlab-ce-10.1.0-ce.0.el7.x86_64
    ```
3. 配置 
    ```shell 
    vim  /etc/gitlab/gitlab.rb
    # 配置访问地址 
    external_url  '本机地址'  
    # 默认是80端口，如果80已经使用
    ```
4. 更新配置 
    ```shell
    gitlab-ctl reconfigure
    gitlab-ctl restart
    ```
5. 修改nginx(gitlab 默认有nginx)  
    ```shell 
    vi /etc/gitlab/gitlab.rb

    # 访问端口改为 8000
    # 此处还关闭了nginx 使用自己安装的nginx  
    nginx['listen_port'] = 80       # 默认80

    vi /var/opt/gitlab/nginx/conf/gitlab-http.conf
    listen *:82; #默认值listen *:80;

    vi /etc/gitlab/gitlab.rb
    unicorn['port'] = 8001 #原值unicorn['port'] = 8080

    vi /var/opt/gitlab/gitlab-rails/etc/
    listen "127.0.0.1:8082", :tcp_nopush => true
    #原值listen "127.0.0.1:8080", :tcp_nopush => true
    ```


### mysql



### nginx
1. download  
    ```shell 
         sudo yum install wget 
         # 根据自己需要下载版本 
         wget -c https://nginx.org/download/nginx-1.10.1.tar.gz   
         # ssl 功能需要openssl库
         wget https://www.openssl.org/source/openssl-1.1.0h.tar.gz  
         #  rewrite模块需要 pcre 库
         wget https://ftp.pcre.org/pub/pcre/pcre-8.02.tar.gz  
         # gzip模块需要 zlib 库
         wget http://www.zlib.net/zlib-1.2.11.tar.gz  
         #  fastdfs-nginx-module
         wget https://github.com/happyfish100/fastdfs-nginx-module/archive/master.zip
    ```
2. 解压  
    ```shell 
    #  unzip  xxx.zip  
    # tar -zxvf xxx.tar.gz
    ```
3. 编译  
    ```shell 
    # ssl 
    # pcre
    # gzip 
    cd /xxx  
    ./configure 
    make  
    # 安装到/usr/local/bin (可无) 
    make install 
    ```
4. 编译 nginx  

    ```shell 
    cd nginx/  
     sudo ./configure  --prefix=/opt/nginx-1.14.0/bin --with-http_stub_status_module --with-http_ssl_module --with-ipv6  --with-openssl=/opt/nginx-1.14.0/openssl-1.1.0h --with-pcre=/opt/nginx-1.14.0/pcre-8.42 --with-zlib=/opt/nginx-1.14.0/zlib-1.2.11 --add-module=/opt/nginx-1.14.0/fastdfs-nginx-module/src
     # 安装  
    make && make install
    ```


### runner  
1. 安装 
    ```shell 
    sudo yum install gitlab-ci-multi-runner
    ```
2. 注册 
    ```shell 
    sudo gitlab-ci-multi-runner register
    ```
__具体注册内容，请查看具体的`gitlab`文章部分__  





### FastDFS  
1. download  
    ```shell 
    # libfastcommon
    wget https://github.com/happyfish100/libfastcommon/archive/master.zip 
    # FastDFS 
    wget https://github.com/happyfish100/fastdfs/archive/master.zip 
    ```
2. make  
    ```shell 
    # libfastcommon  
    # FastDFS
    unzip master.zip 
    cd /xxxx  
    ./make.sh && make.sh install
    ```
3. 配置  
    * 配置 Tracker  服务 
        ```shell 
        cd /etc/fdfs 
        cp tracker.conf.sample tracker.conf  
        vi tracker.conf    
        
        # 修改一下内容
        # the base path to store data and log files 数据存放地址  
        base_path=/data/fastdfs
        # HTTP port on this tracker server
        http.server_port=80


        # 启动 
        /usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf start
        # 软连接 
        ln -s /usr/bin/fdfs_trackerd /usr/local/bin
        ln -s /usr/bin/stop.sh /usr/local/bin
        ln -s /usr/bin/restart.sh /usr/local/bin

        # service 服务启动形式
        service fdfs_trackerd start
        # 查看监听
        netstat -unltp|grep fdfs

        ```
    * 配置Storage 服务 
        ```shell 
        cp storage.conf.sample storage.conf
        vim storage.conf

        # the base path to store data and log files
        base_path=/data/fastdfs/storage
        # store_path#, based 0, if store_path0 not exists, it's value is base_path
        # the paths must be exist
        store_path0=/data/fastdfs/storage
        #store_path1=/home/yuqing/fastdfs2
        # tracker_server can ocur more than once, and tracker_server format is
        #  "host:port", host can be hostname or ip address
        # 地址如果是本地环境，就是本地机器地址  
        tracker_server=192.168.198.129:22122

        # 软连接 
        ln -s /usr/bin/fdfs_storaged /usr/local/bin
        service fdfs_storaged start
        ```
    
    * 验证服务  
        ```shell 
        netstat -unltp|grep fdfs

        /usr/bin/fdfs_monitor /etc/fdfs/storage.conf
        ```
        __注意： 有时候却验证不通过，这时候就需要查看日志信息 看看日志信息是否有错误，如果没有错误那么久没问题__  
    * 修改 NGINX 模块  
        ```shell 
        # mod-fastdfs.conf
        tracker_server=192.168.198.129:22122
        url_have_group_name = true  
        store_path0=/data/fastdfs/storage  
        # 以上三个属性配置成自己的地址和 存放地址  

        ```
    * 修改NGINX 配置 
        ``` 
        添加以下内容
        location /group1/M00 {
            root /data/fastdfs/storage/;
            ngx_fastdfs_module;
        }
        ```
    * 创建软连接等 
        ```shell
        mkdir /data/fastdfs/storage/data/group1
        ln -s /data/fastdfs/storage/data /data/fastdfs/storage/data/group1/M00
        ```
    * 重启NGINX 
    * 配置 client.conf
        ```shell
        cp /usr/fdfs/client.conf.sample client.conf  

        # 修改一下内容 
        base_path = 
        tracker_server = 

        ```
    * 测试上传  
        ```shell 
        cd /usr/bin

        /usr/bin/fdfs_test /etc/fdfs/client.conf upload /usr/bin/test.txt
        ```
        ![20180606152827315464159.png](http://ozjlhf9e0.bkt.clouddn.com/20180606152827315464159.png)  
        出现以上内容代表上传成功  
        



-------------------------  
## 安装服务及访问地址 
1. elasticsearch  
    ```shell
    ./elasticsearch -Xms512m -Xmx512m
    ./elasticsearch -d -Xms512m -Xmx512m

    ```
2. gitlab 
    ```shell 
    gitlab-ctl restart
    ```
    访问地址__http://192.168.33.13:8000/__   

3. nginx  





##### 查看端口  
```shell 
# 查看所有端口 
netstat -ntlp  

# 查看端口占用进程 
netstat -lnp|grep 88


# 查看文件占用情况  
du -sh *


# 查看是否启动 
ps aux|grep elasticsearch
ps –ef|grep nginx

# kill 
kill -QUIT 主进程号
```

