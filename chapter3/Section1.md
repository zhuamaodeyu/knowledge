# swift cell 中UITextField 键盘遮挡问题  
当在TableView 的cell 中使用UITextField 等控件时，会存在cell 被键盘遮挡等问题。针对此种问题有多种解决方式，此处采用的是通过监听 键盘 通知实现  

### 1. 添加通知  
```
 NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHiden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

```

### 2. 通知代理方式实现 
```
@objc fileprivate func keyboardWillShow(notification: NSNotification) {
        print("show")
         let userInfo = (notification as NSNotification).userInfo!
            //键盘尺寸
        let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey]
                as! NSValue).cgRectValue
        var contentInsets:UIEdgeInsets
        //判断是横屏还是竖屏
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if UIInterfaceOrientationIsPortrait(statusBarOrientation) {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
        } else {
            contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
        }
        //tableview的contentview的底部大小
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    }
    @objc fileprivate func keyboardWillHiden(notification: NSNotification){
        print("will hide")
        //还原tableview的contentview大小
        let contentInsets:UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 0.0);
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }
```
