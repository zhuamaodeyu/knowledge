# Swift 开发遇到的问题点 

## NSClassFromString 问题 
在进行Swift 的说明之前先看下 基于 OC 的版本  

__本例以通过字符串创建控制器的为功能要求__  

``` OC  
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




