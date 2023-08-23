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




































