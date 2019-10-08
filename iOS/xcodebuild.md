## Xcode 背后元首 ---- xcodebuild  

### 前言  



## xcodebuild 
`xcodebuild` 是一个命令行工具，可以从命令行对Xcode 项目进行构建、查询、分析、测试以及归档等操作。`xcodebuild`提供了多种命令以支持以上等操作。  
##### 概念简介  
1. workspace   
    `xcodebuild -list -workspace <您的工作区名称> .xcworkspace`

2. scheme    
    `xcodebuild -list -project <您的项目名称> .xcodeproj`

3. target  
    ` xcodebuild -scheme <您的计划名称> build`


### 单元测试  
1. 从名两行构建并执行单元测试 
```
xcodebuild test [-workspace <your_workspace_name>]
                [-project <your_project_name>]
                -scheme <your_scheme_name>
                -destination <destination-specifier>
                [-only-testing:<test-identifier>]
                [-skip-testing:<test-identifier>]
```
2. 构建单元测试，但不从命令行运行  
```
xcodebuild build-for-testing [-workspace <your_workspace_name>]
                             [-project <your_project_name>]
                             -scheme <your_scheme_name>
                             -destination <destination-specifier>
```

3. 运行单元测试，但不从命令行构建  
```
xcodebuild test-without-building [-workspace <your_workspace_name>]
                                 [-project <your_project_name>]
                                 -scheme <your_scheme_name>
                                 -destination <destination-specifier>
                                 [-only-testing:<test-identifier>]
                                 [-skip-testing:<test-identifier>]


xcodebuild test-without-building -xctestrun <your_xctestrun_name>.xctestrun
                                 -destination <destination-specifier>
                                 [-only-testing:<test-identifier>]
                                 [-skip-testing:<test-identifier>]

```  
4. 

```
xcodebuild test -scheme macOS -destination'platform = macOS，arch = x86_64'  


xcodebuild test -workspace MyApplication.xcworkspace -scheme iOSApp -destination'platform = iOS，id = 965058a1c30d845d0dcec81cd6b908650a0d701c'  

xcodebuild test -workspace MyApplication.xcworkspace -scheme iOSApp -destination'platform = iOS，name = iPhone'  

# 不执行 
xcodebuild test -workspace MyApplication.xcworkspace -scheme iOSApp -destination'platform = iOS，name = iPhone'-skip-testing：iOSAppUITests


# 测试某各类
xcodebuild test -workspace MyApplication.xcworkspace -scheme iOSApp -destination'platform = iOS，name = iPhone'-仅测试：iOSAppTests / SecondTestClass / testExampleB
```