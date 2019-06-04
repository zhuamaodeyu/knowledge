# Gitlab 与 gitlab-runner集成 

## 错误1 
Gitlab 配置错误引起的     
### 错误描述
```
Running with gitlab-runner 10.8.0 (079aad9e)
  on test 6cc28ce9
Using Shell executor...
Running on 88b5934b1e24...
Cloning repository...
Cloning into '/home/gitlab-runner/builds/6cc28ce9/0/root/test'...
fatal: unable to access 'http://gitlab-ci-token:xxxxxxxxxxxxxxxxxxxx@127.0.0.1:8000/root/test.git/': Failed to connect to 127.0.0.1 port 8000: Connection refused
ERROR: Job failed: exit status 1
```

### 解决方式   
修改 gitlab.rb 文件      
```ruby 
external_url 'http://192.168.33.13:8000' #此处默认是 127.0.0.1 ,但是如果是这个就会出现以上问题，所以尽量填服务器地址，并且其不止会出现以上问题，还会导致新建仓库地址是一个 本地的 localhost(127.0.0.1) 这样的域名， 用户提交代码也不方便  
```