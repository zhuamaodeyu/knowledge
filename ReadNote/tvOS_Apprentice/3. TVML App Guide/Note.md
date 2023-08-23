# 构建 TVML 应用 


1. 创建对应的 TV Project 
2. 根据开发方式调整模版文件 
    * TVML 方式
        * 删除 `Info.plist`文件的 `Main storybaord file base name`, 添加 `App Transport Security Settings`,并设置 `Allow Arbitrary Loads = YES`


3. 加载 TVML 
    * 使`AppDelegate`遵循`TVApplicationControllerDelegate`协议 
        ```swift 

        import UIKit
        import TVMLKit
        
        @UIApplicationMain
        class AppDelegate: UIResponder, UIApplicationDelegate, TVApplicationControllerDelegate {
        
        var window: UIWindow?
        
        }

        ```

    * 创建 `TVApplicationController`, 负责与 服务器交互 
        ```swift 

            var appController: TVApplicationController?
            static let TVBaseURL = "http://localhost:9001/"
            static let TVBootURL = "\(AppDelegate.TVBaseURL)js/application.js"

        ```

    
    * 设置 `TVApplicationController` 
        ```swift
        func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
            window = UIWindow(frame: UIScreen.mainScreen().bounds)
            // 1 
            let appControllerContext = TVApplicationControllerContext()
            
            // 2
            guard let javaScriptURL = NSURL(string: AppDelegate.TVBootURL) else {
                fatalError("unable to create NSURL")
            }
            
            appControllerContext.javaScriptApplicationURL = javaScriptURL
            appControllerContext.launchOptions["BASEURL"] = AppDelegate.TVBaseURL
            
            // 3
            appController = TVApplicationController(context: appControllerContext, window: window, delegate: self)
            return true
        }

        ```
        * 建了一个应用上下文`TVApplicationControllerContext`的实例，用于稍后初始化`TVApplicationController`
        * 给应用上下文这个对象实例设置了两个简单的属性：主JavaScript文件的路径和服务器的地址 
        * 通过刚才设置好的应用上下文初始化`TVApplicationController`

    * JavaScript
        在客户端-服务端这类的tvOS应用中，JavaScript文件通常在应用连接的服务器中

    * 服务器 
        * 构建 application.js  文件
            ```js
            // App.onLaunch是处理JavaScript文件的入口方法。之前在 AppDelegate.swift 中已经初始化好的TVApplicationController会将TVApplicationControllerContext传到这
            App.onLaunch = function(options) {
            // 1
            var alert = createAlert("Hello World", ""); //第二个参数传入空字符串
            navigationDocument.presentModal(alert);
            }
            
            // 2
            var createAlert = function(title, description) {
            var alertString = `<?xml version="1.0" encoding="UTF-8" ?>
                <document>
                <alertTemplate>
                    <title>${title}</title>
                    <description>${description}</description>
                </alertTemplate>
                </document>`
                var parser = new DOMParser();
                var alertDoc = parser.parseFromString(alertString, "application/xml");
                return alertDoc
            }

            ```
        * 配置服务器 
            ```shell
                cd ~/Desktop/client
                python -m SimpleHTTPServer 9001 
            ```
    * Build & Test

    * 完善 JavaScript
        在 client/js 文件夹中新建一个JavaScript文件，名为 `Presenter.js` 
        ```js
        
        var Presenter = {
        // 1 DOMParser 以将TVML字符串转换为可用于展示的TVML模板对象
        makeDocument: function(resource) {
            if (!Presenter.parser) {
            Presenter.parser = new DOMParser();
            }
            var doc = Presenter.parser.parseFromString(resource, "application/xml");
            return doc;
        },
        // 2 modalDialogPresenter方法通过传入的TVML模板文件，将其模态的展现在屏幕上。
        modalDialogPresenter: function(xml) {
            navigationDocument.presentModal(xml);
        },
        
        // 3 pushDocument方法是在导航栈中推送一个TVML模板文件，相当于在iOS中push出一个界面。
        pushDocument: function(xml) {
            navigationDocument.pushDocument(xml);
        },
        }

         ```
        优化 `App.onLaunch` . 
        ```js 
        App.onLaunch = function(options) {
        // 1
        var javascriptFiles = [
            `${options.BASEURL}js/Presenter.js`
        ];
        // 2
        evaluateScripts(javascriptFiles, function(success) {
            if(success) {
                var alert = createAlert("Hello World!", "");
                Presenter.modalDialogPresenter(alert);
            } else {
            // 3 Handle the error CHALLENGE!//inside else statement of evaluateScripts. 
            //将这两行代码插入evaluateScripts的else代码块中. 
                var errorDoc = createAlert("Evaluate Scripts Error", "Error attempting to evaluate external JavaScript files.");
                navigationDocument.presentModal(errorDoc);
            }
        });
        }

        ```
    * Template 模版应用   
        * 创建模版 RWDevConTemplate.xml.js 
            ```js 
            var Template = function() { return `<?xml version="1.0" encoding="UTF-8" ?>
            <document>
                <catalogTemplate>
                <banner>
                    <title>RWDevConHighlights</title>
                </banner>
                </catalogTemplate>
            </document>`
            }

            ```
        * `ResourceLoader` 用以加载模版 
            ```js 

            function ResourceLoader(baseurl) {
            this.BASEURL = baseurl;
            }
            
            ResourceLoader.prototype.loadResource = function(resource, callback) {
            var self = this;
            evaluateScripts([resource], function(success) {
                if(success) {
                var resource = Template.call(self);
                callback.call(self, resource);
                } else {
                var title = "Resource Loader Error",
                    description = `Error loading resource '${resource}'. \n\n Try again later.`,
                    alert = createAlert(title, description);
                navigationDocument.presentModal(alert);
                }
            }); 
            }

            ```
        * 应用模版 
            ```js 
            // 1
            var resourceLoader;
            
            App.onLaunch = function(options) {
            // 2
            var javascriptFiles = [
                `${options.BASEURL}js/ResourceLoader.js`, 
                `${options.BASEURL}js/Presenter.js`
            ];
            
            evaluateScripts(javascriptFiles, function(success) {
                if(success) {
                // 3
                resourceLoader = new ResourceLoader(options.BASEURL);
                resourceLoader.loadResource(`${options.BASEURL}templates/RWDevConTemplate.xml.js`, function(resource) {
                    var doc = Presenter.makeDocument(resource);
                    Presenter.pushDocument(doc);
                });
                } else {
                var errorDoc = createAlert("Evaluate Scripts Error", "Error attempting to evaluate external JavaScript files.");
                navigationDocument.presentModal(errorDoc);
                }
            });
            }
            ```
    * 事件处理  
        * 事件处理 
            ```js

            load: function(event) {
            //1
            var self = this,
            ele = event.target,
            videoURL = ele.getAttribute("videoURL")
            if(videoURL) {
                //2
                var player = new Player();
                var playlist = new Playlist();
                var mediaItem = new MediaItem("video", videoURL);
            
                player.playlist = playlist;
                player.playlist.push(mediaItem);
                player.present();
            }
            },

            ```

            load函数用来处理视频选择事件。它相当于iOS中的@IBAction，该函数的event参数相当于sender参数。每个event都有一个target，每个target关联着模板中的lockup元素。
            播放视频非常简单。Player是 TVJS 框架提供的一个类，负责所有视频播放的相关功能。你们所要做的只是添加一个播放列表playlist，然后将要播放的项目mediaItem添加到播放列表里。最后通过player.present()方法就可以播放视频了。

        * 选中事件关联 
            ```js 
            App.onLaunch = function(options) {
            //...
            //在resourceLoader.loadResource中...
            var doc = Presenter.makeDocument(resource);
            doc.addEventListener("select", Presenter.load.bind(Presenter)); //add this line
            Presenter.pushDocument(doc);
            //...
            }

            ```
    * 网络方式开始加载 模版 
        ```js 

            function getDocument(url) {
            var templateXHR = new XMLHttpRequest();
            templateXHR.responseType = "document";
            templateXHR.addEventListener("load", function() {pushDoc(templateXHR.responseXML);}, false);
            templateXHR.open("GET", url, true);
            templateXHR.send();
            return templateXHR;
            }
            
            function pushDoc(document) {
            navigationDocument.pushDocument(document);
            }
            
            App.onLaunch = function(options) {
            var templateURL = 'http://localhost:8000/hello.tvml';
            getDocument(templateURL);
            }
            
            App.onExit = function() {
            console.log('App finished');
            }

        //  hello.tvml
        <document>
            <alertTemplate>
                <title>Hello tvOS!</title>
            </alertTemplate>
        </document>

        ```



## 脚本 
* `evaluateScripts`
    TVJS 提供了一个evaluateScripts()函数，它接受一个 JavaScript 文件的 URL 数组和一个回调 
    该函数依次读取每个 URL，尝试对其进行解析并将任何包含的函数和对象定义添加到上下文的全局对象中 



## TVML template 

### 信息 
向用户显示少量信息，并可选择请求用户输入
* alertTemplate 


* loadingTemplate  



### Data Entry
用于进行用户数据输入的 

* searchTemplate 



* ratingTemplate 



### Single Item 

* productTemplate  
    ![图 2](images/92ea805e47b79acc60fa56eee3394b2428d9495414eefbc630f4c8445c6b6462.png)  



* oneupTemplate


* compilationTemplate 


* showcaseTemplate



### Collections 
集合类的 

* stackTemplate


* listTemplate 


* productBundle


### Other 

* menuBarTemplate 


* divTemplate








## 重点 
1. server 启动的位置，必须在项目根目录，也就是 application.js 存放位置
2. 方式2: 在 app 内部，通过 `GCDWebServers` 等框架，启动一个内部的 server 




## Other 
* 查看端口占用情况 
`sudo lsof -i :1080` 
* 杀死进程 
`sudo kill -9 66231(pid)`
