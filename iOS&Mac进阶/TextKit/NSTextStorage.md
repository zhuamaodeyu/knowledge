
# NSTextStorage

TextKit 的基本存储机制，其中包含由系统管理的文本。


NSTextStorage 是 NSMutableAttributedString 的一个半具体的子类，它添加了用于管理一组 NSLayoutManager 对象的行为。文本存储对象通知其布局管理员其字符或属性的更改， 这允许布局管理器根据需要重新显示文本 


__可以从应用的任何线程访问文本存储对象__, 但应用必须保证一次只能从一个线程进行访问。  
在 macOS 中，此类还定义了用于获取和设置 NSTextStorage 对象的可编写脚本的属性,除非您正在处理脚本可操作性，否则不应直接访问这些属性, 特别是，使用字符、单词或段落属性是操作文本存储的低效方法,因为访问这些属性涉及创建许多对象. 相反，请使用由 NSMutableAttributedString、NSAttributedString、NSMutableString 和 NSString 定义的文本访问方法来执行字符级操作.  

NSTextStorage 类通过 beginEditing（） 和 endEditing（） 方法实现更改管理, 属性验证、委托处理和布局管理通知.它没有实现的一个方面是管理实际的属性字符串存储，子类通过覆盖两个 NSAttributedString 基元来管理这些存储：

* string 
* attributes(at:effectiveRange:)

子类还必须重写两个 NSMutableAttributedString 原始方法：

* replaceCharacters(in:with:)  
* setAttributes(_:range:)  

这些原始方法执行更改，然后调用 `edited（_：range：changeInLength：）`让父类知道有更改.   





## 访问布局管理器
* `var layoutManagers: [NSLayoutManager]`
    文本存储对象的布局管理器。
* `func addLayoutManager(NSLayoutManager)`
    将布局管理器添加到文本存储对象的布局管理器集中。
* `func removeLayoutManager(NSLayoutManager)`
    从文本存储对象的布局管理器集中移除一个布局管理器。


## 管理编辑
* `func edited(NSTextStorage.EditActions, range: NSRange, changeInLength: Int)`
    跟踪对文本存储对象所做的更改，允许文本存储 记录更改的范围。
* `func processEditing()`
    清理对文本存储对象的更改，并将更改通知其委托和布局管理器。


## 修复字符串属性
* `func invalidateAttributes(in: NSRange)`
    使指定范围内的属性无效。
* `func ensureAttributesAreFixed(in: NSRange)`
    确保属性修复发生在指定范围内。
* `var fixesAttributesLazily: Bool`
    一个布尔值，指示文本存储对象是否延迟修复属性。  



## 变化部分
* `var editedMask: NSTextStorage.EditActions`
    描述文本存储对象的待处理编辑类型的掩码。
* `var editedRange: NSRange`
    包含更改的文本范围。
* `var changeInLength: Int`
    已编辑范围的当前长度与其编辑前的长度之间的差异。


## 访问可编写脚本的属性
* `var attributeRuns: [NSTextStorage]`
    文本存储内容作为属性数组运行。
* `var paragraphs: [NSTextStorage]`
    文本存储内容为段落数组。
* `var words: [NSTextStorage]`
    文本存储内容为单词数组。
* `var characters: [NSTextStorage]`
    文本存储内容为字符数组。
* `var font: NSFont?`
    文本存储的字体。
* `var foregroundColor: NSColor?`
    文本的颜色。




## NSTextStorageDelegate  

* `func textStorage(NSTextStorage, willProcessEditing: NSTextStorage.EditActions, range: NSRange, changeInLength: Int)`
    当文本存储对象即将处理编辑时框架调用的方法。
* `func textStorage(NSTextStorage, didProcessEditing: NSTextStorage.EditActions, range: NSRange, changeInLength: Int)`
    当文本存储对象完成处理编辑时框架调用的方法。  

