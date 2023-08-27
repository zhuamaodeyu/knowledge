
- [x] 开发中
- [ ] 未完成
- [ ] 已完成
- [ ] 维护中



* [OpenGL ES](https://www.jianshu.com/nb/2135411)
* [Core Image]()




# 技能树  
![](./assets/gitbook/2018030115198902488513.png)




<!-- chapter11 -->
# 第十一章 Docker   
- [x] 开发中
- [ ] 未完成
- [ ] 已完成
- [ ] 维护中

## 前言  
Docker 是一个机遇Google推出的Go语言开发的新兴的虚拟化技术。其与传统的虚拟化技术不同在于属于操作系统层面的虚拟化技术。由于隔离的进程独立于宿主和其它的隔离的进程，因此也称其为容器。Docker 在容器的基础上，进行了进一步的封装，从文件系统、网络互联到进程隔离等等，极大的简化了容器的创建和维护。使得 Docker 技术比虚拟机技术更为轻便、快捷。   
   本章主要包含Docker的一些操作以及自己学习
和运用中遇到的问题和解决办法  


<!-- chapter12 -->
#第十二章 微服务架构篇  
## 前言说明
本章主要的内容都是关于微服务架构原理以及实现上的知识点，全部内容是自己在学习微服务相关知识时的笔记以及掺杂着个人对于微服务的粗浅的个人理解   


## 1.加在dockicon. 

```
var im = NSImage.init()
let appDockTile = NSApplication.shared.dockTile
if #available(OSX 10.12, *) {
    appDockTile.contentView = NSImageView(image: im)
}
appDockTile.display()

```

## 2. 不显示dockicon  

```

    let transformState = ProcessApplicationTransformState(kProcessTransformToUIElementApplication)
    var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
    TransformProcessType(&psn, transformState)

    NSApp.setActivationPolicy(.accessory)

```


## 3. iCloud. 

```

        #if CLOUDKIT
        if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").standardized {
            
            if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
                do {
                    try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Home directory creation: \(error)")
                }
            }
        }
        #endif


```

## 4. 重启app 

```
    private func restartApp() {
        guard let resourcePath = Bundle.main.resourcePath else { return }
        
        let url = URL(fileURLWithPath: resourcePath)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task = Process()
        
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        
        exit(0)
    }


```


## 5. 设置快捷键  


```

 let rtf = NSMenuItem(title: NSLocalizedString("New RTF", comment: ""), action: #selector(AppDelegate.newRTF(_:)), keyEquivalent: "n")
    var modifier = NSEvent.modifierFlags
    modifier.insert(.command)
    modifier.insert(.shift)
    rtf.keyEquivalentModifierMask = modifier
    menu.addItem(rtf)


```




1. swift 依赖注入  
2. oc 与c++汇编  
eventloop 源码研究 
3. swift 正则表达式  
4. swift 编译优化  
