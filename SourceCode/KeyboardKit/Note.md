# KeyboardKit 

## 简介 
[KeyboardKit](https://github.com/KeyboardKit/KeyboardKit)一个自定义键盘样式库   

### 应用 
1. 初始化  
```swift 
@StateObject
private var dictationContext = DictationContext(config: .app)

// TODO: 注意此处，必须是自定义keyboard 的 bundler identifier ，否则无法判断是否使用自定义键盘
@StateObject
private var keyboardState = KeyboardEnabledContext(
bundleId: "org.cocoapods.demo.keyboardkit.demo.*") 

```

2. `keyboardAppearance` 修改键盘样式 
```swift
TextEditor(text: $text)
                .frame(height: 100)
                .keyboardAppearance(appearance) // 设置键盘的 appearance, 只能设置应用内的，无法全局设置
                .environment(\.layoutDirection, isRtl ? .rightToLeft : .leftToRight)TextEditor(text: $text)
                .frame(height: 100)
                .keyboardAppearance(appearance) // 设置键盘的 appearance, 只能设置应用内的，无法全局设置
                .environment(\.layoutDirection, isRtl ? .rightToLeft : .leftToRight)

var isRtl: Bool {
    let keyboardId = keyboardState.activeKeyboardBundleIds.first
    return keyboardId?.hasSuffix("rtl") ?? false
}
```

3. 获取键盘的状态 
```swift 
    var stateSection: some View {
        Section(header: Text("Keyboard"), footer: footerText) {
            KeyboardEnabledLabel(
                isEnabled: keyboardState.isKeyboardActive, // 自定义⌨️是否激活
                enabledText: "Demo keyboard is active",
                disabledText: "Demo keyboard is not active"
            )
            KeyboardSettingsLink(addNavigationArrow: true) {
                KeyboardEnabledLabel(
                    isEnabled: keyboardState.isKeyboardEnabled, // 自定义⌨️是否开启了
                    enabledText: "Demo keyboard is enabled",
                    disabledText: "Demo keyboard not enabled"
                )
            }
            KeyboardSettingsLink(addNavigationArrow: true) {
                KeyboardEnabledLabel(
                    isEnabled: keyboardState.isFullAccessEnabled,// 是否开启全局访问 
                    enabledText: "Full Access is enabled",
                    disabledText: "Full Access is disabled"
                )
            }
        }
    }

```


## 源码分析 
### Custom 键盘状态获取 
1. 通过监听键盘通知刷新键盘状态 
```swift 

var activePublisher: NotificationCenter.Publisher {
    notificationCenter.publisher(for: UIApplication.didBecomeActiveNotification)
}

var textPublisher: NotificationCenter.Publisher {
    notificationCenter.publisher(for: UITextInputMode.currentInputModeDidChangeNotification)
}
```

2. 获取当前有效的键盘  
```swift 
    func enabledKeyboardBundleIds(
        defaults: UserDefaults = .standard
    ) -> [String] {
        let key = "AppleKeyboards" // TODO: 通过此 key 获取到当前系统中可用的键盘 identifier
        return defaults.object(forKey: key) as? [String] ?? []
    }

```
3. 获取所有活动键盘捆绑标识符的列表。  
```swift 
    // 当前活动的键盘 identifier     
    var activeKeyboardBundleIds: [String] {
        let modes = UITextInputMode.activeInputModes
        let displayed = modes.filter { $0.value(forKey: "isDisplayed") as? Int == 1 }
        let ids = displayed.compactMap { $0.value(forKey: "identifier") as? String }
        return ids
    }
```
4. 是否全局访问 
```swift 

UIInputViewController ----> hasFullAccess

```




