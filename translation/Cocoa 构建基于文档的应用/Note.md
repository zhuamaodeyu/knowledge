# 构建基于 Document 的文档应用程序  

## 核心 NSDocument 和 NSDocumentController

1. 基于文档应用需要创建对应的 `NSDocument` 子类

```swift
 
class MarkdownDocument: NSDocument {

}


```


在一个普通的 AppKit 应用程序中，该Info.plist文件具有指定应用程序支持哪种类型的文档、哪些类名属于哪些文档类型等的条目。 
在没有 Info.plist 配置时，需要创建对应的NSDocumentController 提供具体的设置信息 


2. 创建对应的`NSDocumentController`  


``` swift 
class MarkdownDocumentController: NSDocumentController {
    override var documentClassNames: [String] {
        return ["MarkdownDocument"]
    }
}


```

__针对支持多种文档类型的，可以在 `documentClassNames` 中返回多种对应的 `NSDocument` 子类名__ 


还必须告诉 Objective-C 运行时我们的文档类使用哪个名称： 

```swift 

@objc(MarkdownDocument)
class MarkdownDocument: NSDocument {}

```


通过定义默认文档类型并返回给定类型名称的文档类来完成文档控制器的设置：  

```swift  
// 设置默认支持的文档类型及处理类
class MarkdownDocumentController: NSDocumentController {
    // ...
    override var defaultType: String? {
        return "MarkdownDocument"
    }
    
    override func documentClass(forType typeName: String) -> AnyClass? {
        return MarkdownDocument.self
    }
}


```



为了使自定义 `NSDocumentController` 生效，需要在app 启动之前将其初始化，并自动注入， 默认会注入系统自带的 `NSDocumentController` 对象 

```swift 

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        // First instance becomes the shared document controller
        // TODO: 此处可以在 init 方法中进行初始化
        _ = MarkdownDocumentController()
    }
}


```

## 使设置生效 
默认情况下，此种设置后，会对应解析对应文件，如果需要显示对应的创建，需要重写`makeWindowControllers` 方法来生成对应的文档窗口 

```swift  

override func makeWindowControllers() {
        let window = NSWindow(contentViewController: contentViewController)
        window.setContentSize(NSSize(width: 800, height: 600))
        let wc = NSWindowController(window: window)
        wc.contentViewController = contentViewController
        addWindowController(wc)
        window.makeKeyAndOrderFront(nil)
    }
}


```

为了使窗口出现在我们的记录区域内，我们为窗口设置了框架自动保存名称，它告诉系统记住窗口的框架并使窗口重新出现在我们关闭它时的相同位置： 

```swift 


 window.setFrameAutosaveName("windowFrame")
window.makeKeyAndOrderFront(nil)


```




## 打开文档 
以上，已经实现了文档与对象类型进行匹配，并打开对应的 view 展示  

接下来，主要实现能够保存文档并从磁盘加载文档。


#### 我们必须告诉 AppKit 我们能够读取哪些类型的文档  
```swift 

class MarkdownDocument: NSDocument {
    // ...
    override class var readableTypes: [String] {
        return ["public.text"]
    }
    // ...
}

```
类型名称“public.text”是 UTI 层次结构中的高级类型，Markdown 是它的子类型。通过使用这种类型，我们说我们基本上可以打开任何文本文件。  


#### 实现read 方法， 从磁盘读取数据后交给我们的数据来实现 

```swift


  override func read(from data: Data, ofType typeName: String) throws {
        guard let str = String(data: data, encoding: .utf8) else { return }
        contentViewController.editor.string = str
    }

```


## 保存文档 
```swift 
class MarkdownDocument: NSDocument {
    // ...
    override func data(ofType typeName: String) throws -> Data {
        return contentViewController.editor.string.data(using: .utf8)!
    }
    // ...
}


```

#### 要实现的是isNativeType方法，我们用它告诉 AppKit 我们能够读取和写入我们的文档类型  

```swift 

class MarkdownDocument: NSDocument {
    // ...
    override class func isNativeType(_ name: String) -> Bool {
        return true
    }
    // ...
}

```

### 辅助功能 
1. 当我们在保存后继续编辑时，我们希望窗口指示我们有未保存的更改（通过灰显文件名并在关闭按钮中显示一个点）。我们要求系统在编码数据以保存的方法中使用一行代码来执行此操作  

```swift


class MarkdownDocument: NSDocument {
    // ...
    override func data(ofType typeName: String) throws -> Data {
        // TODO: 主体在这一行
        contentViewController.editor.breakUndoCoalescing()
        return contentViewController.editor.string.data(using: .utf8)!
    }
    // ...
}

```




2. `ShouldOpenUntitledFile` 时的处理 

```swift

class AppDelegate: NSObject, NSApplicationDelegate {
    var applicationHasStarted = false
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        // the first instance of `NSDocumentController` becomes the shared controller...
        _ = MarkdownDocumentController()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        applicationHasStarted = true
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        guard !applicationHasStarted else { return true }
        let controller = NSDocumentController.shared
        guard let recent = controller.recentDocumentURLs.first else { return true }
        controller.openDocument(withContentsOf: recent, display: true, completionHandler: { _, _, _ in () })
        return false
    }
}


```






## 扩展 
1. 执行代码片段 
    Org 模式让我们可以像在 Markdown 中一样编写代码片段，并且一个复杂的快捷方式可以通过将代码粘贴到 REPL 中来执行其中一个片段。当我们运行另一个片段时，它会被添加到同一个 REPL 中，因此每个片段都可以构建在之前的片段之上。 






## 参考

[Markdown Playgrounds](https://talk.objc.io/episodes/S01E145-setting-up-a-document-based-app)