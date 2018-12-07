




```
1. 创建远程仓库  
2. 添加仓库  
    pod repo add xxxSpecs https://xxxxxxx   
2.1 查看本地仓库  
    pod repo 
3. 创建对应的组件 
    pod lib create xxxxx 
4. 提交组件代码 
5. 设置对应tag  
    git tag '0.1.0' 
    git push --tags 
6. 校验 spec文件 
    pod lib lint  本地校验  --allow-warnings  去除warn 参数
    pod spec lint  远程校验  --allow-warnings
7. push 到版本仓库 
    pod repo push tkSpecs XXX.podspec --allow-warnings
```

常见错误 
1.    [!] DemoPodSpecs did not pass validation, due to 2 warnings (but you can use --allow-warnings to ignore them).
You can use the --no-clean option to inspect any issue.


用 pod lib lint --allow-warnings 命令  

2. [!] The validator for Swift projects uses Swift 3.0 by default, if you are using a different version of swift you can use a .swift-version file to set the version for your Pod. For example to use Swift 2.3, run: echo "2.3" > .swift-version

解决办法：运行 echo 3.0 > .swift-version

3. The name.podspec specification does not validate.  
解决办法：pod repo push DemoPodSpecs DemoPodSpecs.podspec --verbose --use-libraries --allow-warnings
4.   /usr/bin/git -C /Users/.cocoapods/repos/DemoPodSpecs -C
/Users/.cocoapods/repos/DemoPodSpecs push origin master
fatal: repository '' not found

解决办法：到 /Users/.cocoapods/目录下查看私有pod库是否存在

 git tag -a 1.0.0 -m 'v1.0.2'
 git push --tags






