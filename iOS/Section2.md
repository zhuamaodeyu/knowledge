# Swift 开发遇到的问题点 

## NSClassFromString 问题 
在进行Swift 的说明之前先看下 基于 OC 的版本  

__本例以通过字符串创建控制器的为功能要求__  

```  
NSString *name = self.dataSource[indexPath.row];
UIViewController *vc = [NSClassFromString(name) init];
```  

由于Swift 的强类型性，所哟不需要更多的判断操作  

```swift 
        // 由于dataSouce Any 类型数组，需要进行转型，不然下边无法进行字符串拼接操作 
        let name = dataSource[indexPath.row] as! String
        //swift 需要跟上项目名才可以  
        let classes = NSClassFromString("Swift_UI_Demo." + name) as? NSObject.Type
        let vc = classes?.init()
        self.navigationController?.pushViewController(vc as! UIViewController, animated: true)
```

#### 注意点/问题点  
1. swift  需要特别注意类型操作 通过 `as!`，`as?`, `as` 等操作进行转型  
2. 在 `NSClassFromString` 使用时，需要拼接上包名才可以(单独项目就是项目名)，不然无法创建  



## Swiift 获取 keywindow  
```swift 
    class func viewToShow() -> UIView {
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindowLevelNormal {
            let windowArray = UIApplication.shared.windows
            for tempWin in windowArray {
                window = tempWin
                break
            }
        }
        return window!
    }
```

## 关于枚举的使用  
再枚举使用之前。尽量不要使用系统给定的方式去实现，系统给定的额再枚举是可选值时会再`switch 进行强制解包` 这样会造成崩溃的问题  

```
let type = enumType ?? .none  
switch type {

}
```
__在枚举使用之前针对枚举进行解包判断给定一个默认值，这样在 switch 中不会因为强解包造成崩溃__  

## UITableView /UICollectionView 针对代理的处理  
在代理方法中涉及到数据源的问题时， 通过给定默认值或者 `guard ` 提前判断进行避免崩溃问题出现 
```
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let item = self.items?[indexPath.row] else {return UITableViewCell()}
}
func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = self.items?[indexPath.row] else {return 44}
}
 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = self.items?[indexPath.row] else {return}
 }
```

## swift 中关于字典操作  
```
// 字典定义 
let dic = [String:AnyObject]()  

// 获取所有的key  
let keys = Array(dic.keys) 

```  

## swift 针对通知的处理  
在 swift中使用通知时， 通知的 `userInfo` 类型是一个`[AnyHashable : Any]?` 此处只是一个占位符，针对此处需要做特定的处理才能获取到具体的值类型  

```swift
// 1. 知道具体类型 
// 验证
guard let userInfo = usertification.userInfo {
        return 
}
// 直接强转
 let userInfo = (notification as NSNotification).userInfo!  

let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]
                as! NSValue).cgRectValue

//2. 知道具体的值类型  
guard let userInfo = usertification.userInfo,
        let message = userInfo["message"] as? Data, 
        let status = userInfo["status"] as? Int else {
                return 
        }

```

## UITableView tableHeaderView 通过约束来实现 遮盖cell 的问题  
具体问题： 在使用自动布局时，如果针对 `UITableView` 的 headerView 采用自动布局方式来实现。如果直接设置，具体显示的headerView 会覆盖 cell 部分内容。具体原因是其自动布局时延迟设置的，控件在设置只是暂时是没有frame的。所以cell 是紧贴着uitableView 显示的，之后界面才会设置headerView的frame 的，这样就造成了覆盖问题  

解决办法  
```

 self.view.addSubview(tableView)
        tableView.delegate  = self
        tableView.dataSource = self
        tableView.tableHeaderView = headerView
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        headerView.snp.makeConstraints { (make) in
            make.width.equalTo(tableView)
            make.height.equalTo(200)
        }
        // 主要在这句， 刷新布局就好了
        tableView.layoutIfNeeded()

```
__此种方式只能解决 headerView 问题，并不能解决 footerView__    


## 过滤一个字典数组，过滤出其中符合条件的元素  





## 关于富文本 链接 文字样式修改  
默认情况下，富文本链接样式的文字是 蓝色的并且具有蓝色下划线的。不过可以通过修改来实现  

```swift 

        self.textField.text = textFieldText
        let attributeString = NSMutableAttributedString(string: desc!)
        attributeString.append(NSAttributedString(string: "  "))
        
        let string = NSMutableAttributedString(string: "Detial", attributes: nil)
        string.addAttribute(NSAttributedStringKey.link, value: "CustomTapEvents://", range: NSRange(location: 0, length: string.length))
        attributeString.append(string)
        
        self.descLabel.attributedText = attributeString
        let linkAttributes: [String : Any] = [
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.withHex(hexString: "#ff8b2c"),
            NSAttributedStringKey.underlineColor.rawValue: UIColor.withHex(hexString: "#ff8b2c"),
            NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue
        ]
        self.descLabel.linkTextAttributes = linkAttributes


``` 
## 记一次 for in array iOS 9.0 下崩溃问题  
