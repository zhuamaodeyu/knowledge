# Swift与Cocoa 开发



## 第三章

1.  iOS 后台运行任务

    ```
    func applicationDidEnterBackground() {
    	var backgroundTask: UIBackgroundTaskIdentifier = nil

    	//注册一个后台任务，并提供一个在时间耗尽时执行的代码块
    	backgroundTask = application.beginBackgroundTaskWithExpirationHandler() {
    		// 当时间耗尽时， 调用这个代码块
    		// 如果这里代码块返回之前，没有调用 endBackgroundTask， 应用程序将被终止
    		application.endBackgrdoundTask(backgroundTask)
    		backgroundTask = UIBackgroundTaskInvalid
    	}
    	let backgroundQueue = NSOperationQueue()
    	backgroundQueu.addOperationWithBlock(){
    		// 完成一些工作。大约有 10 分钟可以用来完成任务

    		application.endBackgrdoundTask(backgroundTask)
    		backgroundTask = UIBackgroundTaskInvalid
    	}
    }
    ```

    **注意： 这些执行任务的时间并不一定是连续的，可能会被分成多段，以延长电池寿命**

2.  后台任务运行方式
    * 后台获取  
       * 开启权限`Bacground Fetch`
       * 设置唤醒时间间隔，默认为永不唤醒`setMinimumBackgroundFetchInterval`  
        
		   ```
		   // 代码方法中 
		   func performFetchWithCompletionHandler { 
		   		// var error: NSError? = nil 
		   		let data = downloadSomeData(&error) 
		   		// 完成，告知OS 状态 
		   		if error != nil { 
		   			completionHander(.faild) return 
		   			} 
		   	}
		   	```  
		   	
    * 后台通知    
      允许应用程序在后台接收通知并进行处理。  
       * 开启远程通知权限`Remote Notifications`  
       * 处理远程通知的代理方法  
       
       ```
       func application(application: didReceiveRemoteNotification userInfo:[NSObject:AnyObject]) { 
       	// 此处进行具体代码实现 
       }
       ```
3.  后台运行特殊应用
    - 后台播放的音乐播放器
    - 后台跟踪用户位置
    - Skype 等网络电话应用(VoIP)

## 第四章

1. 创建 Mac 动画

   ```
   var colorAnim = CABasicAnimation(keyPath:"backgroundColor")
   colorAnim.fromValue = NSColor.red().CGColor
   colorAnim.toValue = NSColor.green().CGColor
   colorAnim.duration = 1.5

   // 获取图层
   var layer = view.layer!
   layer.addAnimation(colorAnim, forkey:"xxxxxxxx")

   // 设置动画执行完毕的最终值

   layer.backgroundColor = NSColor.green().CGColor
   ```

2. NSViewAnimation  
   **适合实现位移动画**

## 第六章 在视图上绘制图形

1. 路径处理  
   **默认情况下， 对一个路径描边时， 轮廓线是在路径的外围绘制的。如果边缘是视图大小 可能一部分会被裁剪**

   ```
   // 向内压 一个像素(上下左右都缩小1 像素)
   var pathRect = NSInertRect(self.bounds, 1,1)
   ```

## 第七章 SpriteKit

1. 概念

	- SKView: 视图
	- SKScene: 场景
	- SKNode: 节点

2. 场景    
	**场景必须包含在 视图中, 场景中显示具体的 Node 元素节点**

	```
	
	let scene = GameScene(size: bound.size)
	scene.scaleMode = .AspectFill
	scene.backgroundColor = .black
	
	// 显示场景
	skView.presentScene(scene)
	// 动画显示
	let transition = SKTransition.moveInWithDirection(SKTransitionDirection.Right, duration: 0.5)
	skView.presentScene(scene, transition: transition)
	
	```

3. 节点    
	节点本身不做任何事情； 所有节点都有父子化概念。**一个节点只能由一个父节点, 一个节点没有父节点，用户将无法看到**
	- SKSpriteNode: 显示一个图像或者一个彩色矩形。
	- SKLabelNode: 显示文本
	- SKShapeNode: 显示任意 UIBezierPath
	- SKEffectNode: 向其所有子节点应用图形特效， 比如模糊或色移等
	- 空 SKNode: 没有显示任何东西，但可以用户将 Node 划分组

4. 纹理    
	* SKTexture： 单个纹理图片
	* SKTextureAtlas: 纹理贴图集合
	   1. 创建 `.atlas` 文件夹
	   2. 将纹理图片放入其中
	   3. 系统编译期生成对应文件,通过 `SKTextureAtlas` 进行加载
5. 动画(`SKAction`)
6. 形状节点
	
	```
	
	let shapeNode = SKShapeNode(rectOfSize: CGSize(width: 50.0, height: 50.0))
	
	```

7. 图像特效节点

	```
	
	let blurFilter = CIFilter(name: "CIGaussianBlur")
	blurFilter.setDefaults()
	blurFilter.setValue(5.0, forKey:"inputRadius")
	
	let nodde = SKEffectNode()
	node.filter = blurFilter
	node.shouldEnableEffects = true // 默认情况需要设置，否则图像特效节点不会应用 filter
	self.addChild(node)
	
	```

8. 物理属性

## 第十章 iCloud

1. 沙盒下访问文件系统    
	**通过书签的形式获取权限**

	```
	
	// 创建书签
	// documentURL 是通过 NSFileManager 询问用户的文档文件夹确定
	
	var bookmarkStorageURL = documentURL.URLByAppendingPathCommponent("savedbookmark.bookmark")
	
	// selectURL 是用户通过 NSOpenPanel 选择的 URL
	let bookmarkData = selectedURL.bookmarkDataWithOpentions(
	NSURLBookmarkCreationOptions.withSecurityScope,
	includingResourceValuesForKeys:nil,
	relativeToURL: nil,
	error: nil
	)
	
	// 保存书签
	bookmarkData.writeToURL(bookStorageURL, automically: true)
	```

2. iCloud 应用
	* 文件存储
	* 待办事项列表等
	* 最近打开的文档等(键值对存储)

3.  配置 iCloud
 * `Capabilities` 找到 `iCloud`
 * 打开 `Key-value Storage` 和 `iCloud documents` 选择
4.  测试 iCloud 配置

 ```
 // applicationDidFinishLaunching 中添加

 let backgroundQueue = NSOperationQueue()

 backgroundQueue.addOperationWithBlock() {
 	// 向这个方法传送 nil, 将得到这个APP的授权文件中列出的第一个 iCloud 容器 的URL
 	let ubiquityContainerURL = NSFilerManager.defaultManager()
 	.URLForUbiquityContainerIdentifier(nil)
 	if let url =  ubiquityContainerURL {
 		print("配置没有问题")
 	}
 }
 ```

5. 处理键值对

 ```

     // 存储
     NSUbiquitousKeyValueStore.default.set("", forKey: "")
     NSUbiquitousKeyValueStore.default.synchronize()

     // 获取
     NSUbiquitousKeyValueStore.default.string(forKey: "")
 ```

6.  处理外部修改
 系统发送`NSUbiquitousKeyValueStoreDidChangeExternallyNotification`通知

7.  文件存储

 * 初始化文档目录

       	```
       	// 获取iCloud 文档文件夹
       	// 注意： 无处不在的容器是一个文件夹， 其中要同步的文档需要放在内部的一个 Documents 文件夹中
       	let documentDirectory = NSFileManager.default().URLForUbiquityContainerIdentifier(nil)?.
       	URLByAppendingPathComponent("Documents",isDirectory: true)

       	```
       	__放在此文件夹中的内容，用户可以删除文件夹以进行内存释放，放在外部的内容，用户需要删除整个iCloud 容器才能删除__

 * 初始化查询器(获取内容，并持续运行监控通知)

	  ```
	  // appDeleagte 文件中添加 
	  var metadataQuery: NSMutadataQuery! 
	  var metadataQueryDidUpdateObserver: AnyObject? 
	  var metadataQueryDidFinishGatheringObserver: AnyObject? 
	  // didFinishLaunching 中添加 
	  metadataQuery = NSMutadataQuery() 
	  // 添加限制条件 
	  metadataQuery.searchScopes = [NSMutadataQueryUbiquitousDocumentsScope] 
	  // 针对查找的内容进行限制， 此处是所有文件 
	  metadataQuery.predicate = NSPredicate(formate:"%K LINK '*'", NSMetadataItemFSNameKey) 
	  // 发生改变内容时通知 self. metadataQueryDidUpdateObserver = NSNotificationCenter,default.addObserverForaName(.didUpdateNotification, ) { 
	  // 更新查询 
	  		self.queryDidUpdate() 
	  } 
	  // 完成扫描 
	  self. metadataQueryDidFinishGatheringObserver = NSNotificationCenter,default.addObserverForaName(NSMetadataQueryDidFinishGatheringNotification) { 
	  		self.queryDidUpdate(); 
	  } 
	  
	  metadataQuery.startQuery()
	  ```
 * `queryDidUpdate` 实现

	   ```
	   func queryDidUpdate() { 
	   		var urls: [NSURL] = [] 
	   		for item in metadataQuery.results { 
	   				if let metatadaItem = item as? NSMetadataItem { 
	   						let url = metadataItem.valueForAttribute(NSMetadataItemURLKey) as? URL 							urls.append(url) 
	   				} 
	   		} 
	   		self.filesinCloudStorage = urls 
	   	}
	   ```
 * 移动文件到 iCloud 中
    **如果是复制文件，需要复制一个副本，将副本移动到 iCloud 中**

       	```
       	@objc private func addFile() {
       		let panel = NSOpenPanel()
       		panel.beginSheetModelForWindow(self.window) {(result) in
       			// 获取容器URL
       			let containerURL = NSFileManager.default.URLForUbiquityContainerIdentifier(nil)?
       			.URLByAppendingPathComponent("Documents", isDirectory: true)

       			// 选择了文件
       			if(let sourceURL = panel.URL) {
       				let destinationURL = containerURL?.URLByAppendingPathComponent(sourceURL.lastPathComponent)
       				var error: NSError?
       				// 将文件移动到iCloud中
       				NSFileManager.default.setUbiquitous(true,
       				itemAtURL: sourceURL,
       				destinationURL: destinationURL,
       				error: &error)
       			}
       		}
       	}
       	```
       	
	* 判断文件是否完全可用(大文件只显示占位状态，使用时才下载)   
		
		```
		// metadataItem 是 NSMetadataItem  
		// 描述了容器中的一个项目  
		var downloadStatus = metadataItem.valueForAttribute(NSMetadataUbiquitousItemDownloadStatusKey) as String 
		if downloadStatus == NSMutadataUbiquitousItemDownloadingStatusDownloaded {
			// 已经下载了
		}
		
		```
8. iOS 上文档选择器(UIDocumentPickerViewController)
	* 类型  
	* 模式
		* 打开 
		* 移动 
		* 导入  
		* 导出  

	```
	func documentPicker(controller: xxxx didPickDocumentURL: url: NSURL) {
		
		// 让系统知道准备开始使用  
		// 它可能在某个APP的容器中， 需要系统临时获取权限  
		
		url.startAccessingSecurityScopedResource()  
		
		let fileName = url.lastPathComponent
		// 复制到临时位置  
		let tempraryURL = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true)?.URLByAppendingxxx(filename)  
		
		// 复制文件 
		NSFilemanage.default.copyItemAtURL(url toURL: tempraryURL!, error: & error)
		
		// 告诉系统不再需要访问权限 
		url.stopAccessSecurityScopedResource()  
		
		// 将文件移动到 iCloud中  
		let destaintionURL = FileManager.default.URLForUbiquityContainerIdentifiy(nil)?.
		URLByAppendingPathComponent("Documents")
		. URLByAppendingPathComponent(filename)
		
		Filemaneger.default.setUbiquitous(true,
		itemAtURL: tempraryURL!,
		desctationURL: destaintionURL,
		error:&error )
		
	}
	```



## 第十二章 表格试图和集合视图  

1. NSTableView 排序  
	
	```
	func tableview(tableView: NSTableView!, sortDescriptorDidChange oldDescriptors:[AnyObjects]) {
		// 按照逆序进行排序  
		
		for sortDescriptor in tableView.sortDescriptors.reverse() as [NSSortDescriptor] {
			songs.sort() {(item1, item2) in 
				return sortDescriptor.compareObject(item1, item2) == .orderedAscending
			}
		}
		tableView.reloadData()
	}
	```

## 第十三章 网络  
1. Bonjour 服务的发现  
	
	```
	let browser = NSNetServiceBrowser() 
	var services = [NSNetService]() 
	
	browser.delegate = self 
	
	// 默认域中查找使用TCP 的 DAAP 服务 
	browser,searchServicesOfType("_daap._tcp", inDomain: "") 
	
	```
2. Multipeer Connectivity  

## 第十五章  
1. App Nap  
	不影响APP响应速度的前提下，延长电池寿命    
	* app 不可见   
	* APP没有发出任何噪音  
	* APP没有禁用自动终止   
	* APP没有进行任何电源管理设定  
	
	```
	func applicationDidChangeOcclusionState(notification:NSNotification) {
		if (NSApp.occlusionState & NSApplicationOcclusionState.Visible != nil) {
			//在前台
		}
	}
	```
2. 用户活动  
	
	```
	let queue = NSOperationQueue.mainQueue() 
	
	var token = NSProcessInfo.processInfo() 
	token.beginActivityWithOptions(.UserInitiated, reasion:"xxxxxx")  
	
	queue.add
	
	
	NSProcessInfo.processInfo().endActivity(token)
	```
3. Handoff  
	
	```
	activity = NSUserActivity("com.xxxx.Handoff.xxx") 
	activity.userInfo = dic  
	activity.title = "xxxx" 
	activity.delegate = self 
	
	// 会向周围所有拥有相同iCloud的设备广播此操作   
	activity.becomeCurrent()
	
	
	```
	* 接收操作   
	
	```
	application(_, continueUserActivity:)
	// 
	if let rootC = self.window.rootViewController {
		restorationHandler([rootC]) 
		return true 
	}	
	
	```
	__默认系统会调用`restoreUserActivitiyState`方法。以恢复状态__  


## 第十六章 Event Kit  

	
	


## 第十八章   共享与通知  
1. 共享  

	```
	var text = "" 
	var share = NSSharingServicePicker(items:[text]) 
	
	share.showRelativeToRect(view.bounds, ofView: view, preferredEdge: 2) 
	
	```
2. 通知处理  
	
	```
	applicationDidFinishLaunching  
	
	if let noti = notification.userInfo[NSApplicationLaunchRemoteNotificationKey] {
		
	}
	```
## 第十九章  非标准APP  
1. 偏好设置窗口  
	此部分开发会显示在偏好设置中。  
	使用的 bundleID 是偏好设置的    
	NSUserDefaults 使用的时 `persistentDomainForName` 实现的   
	```
	let domainName = "com.xxxxx.xxxxxx" 
	var preferences = NSUserDefaults.standardUserDefaults().persistentDomainForName(domainName)   
	
	//修改 
	preferences["isChecked"] = true 
	
	// 更新 
	NSUserDefaults.standardUserDefaults().setPersistentDomain(preferences, forName: domainName)
	
	```
2. 自定义偏好设置界面  
	* 创建`System Plug-in` 应用  
	* 在界面加载完成时，进行设置加载  
		```
		func mainViewDidLoad() {
			// 上边的偏好加载，并且将偏好映射到对应的控件上  
		}
		
		```
	* 添加窗口关闭时保存设置  
		创库设置关闭，可能是用户点击了退出, back, forward, show all 等  
		```
		func didUnselect() {
			// 进行空间状态 ----> NSUserDefaults
		}
		```
	
3. 状态栏项目   

4. iOS 多屏幕应用  
	
	```
	didFinishLaunchingWithOptions  
	
	var notificationCenter = NSNotificationCenter.defaultCenter() 
	notificationCenter.addObserver(self, selector: name: UIScreenDidConnectNotification, object: nil)
	notificationCenter.addObserver(self, selector: name: UIScreenDidDisconnectNotification, object: nil)
	
	// 如果系统有多个屏幕，则显示第二个  
	if UIScreen.screens().count >= 2 {
		var screen = // 获取第二个屏幕  
		setupScreen(screen)
	}
	
	func setupScreen(screen: UIScreen) {
		if self.secondWindow != nil {
			return 
		}
		self.secondWindow = UIWindow();
		self.secondWindow.screen = screen 
		self.secondWindow.hidden = false 
		
		self.secondWindow.rootViewController = viewController 
	}
	```
	






























	
