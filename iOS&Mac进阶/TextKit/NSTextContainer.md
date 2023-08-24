# NSTextContainer 

NSLayoutManager 使用 NSTextContainer 来确定换行位置,布置部分文本，依此类推. NSTextContainer 对象通常定义矩形区域，但您可以在文本容器内定义排除路径，以创建文本不覆盖的区域。 还可以创建子类以创建具有非矩形区域的文本容器。例如圆形区域、带孔的区域或与图形一起覆盖的区域

可以从主线程以外的线程访问 NSTextContainer、NSLayoutManager 和 NSTextStorage 类的实例，只要应用保证一次只能从一个线程进行访问即可。

负责提供文本排版的区域，这个区域的意思是显示文本的区域，比如他能够提供一个形状，在这个形状之内显示文本，或者提供一组不会显示文本的区域。

## 创建文本容器
* `init(size: CGSize)`
    使用指定的边界矩形初始化文本容器。
* `init(coder: NSCoder)`
    从反归档器中的数据创建文本容器。

## 管理文本组件

* `var layoutManager: NSLayoutManager?`
    文本容器的布局管理器。
* `var textLayoutManager: NSTextLayoutManager?`
* `func replaceLayoutManager(NSLayoutManager)`
    替换包含文本容器的文本系统对象组的布局管理器。
* `var textView: NSTextView?`
    文本容器的文本视图。



## 定义容器形状
* `var size: CGSize`
    文本容器的矩形的大小。
* `var exclusionPaths: [UIBezierPath]`
    表示文本不显示在文本容器中的区域的路径对象数组。(排出路径数组)
* `var lineBreakMode: NSLineBreakMode`
    文本容器内最后一行的行为。
* `var widthTracksTextView: Bool`
    一个布尔值，用于控制文本容器在其文本视图调整大小时是否调整其边界矩形的宽度。
* `var heightTracksTextView: Bool`
    一个布尔值，用于控制文本容器在其文本视图调整大小时是否调整其边界矩形的高度。



## 约束文本布局
* `var maximumNumberOfLines: Int`
    文本容器可以存储的最大行数。
* `var lineFragmentPadding: CGFloat`
    线片段矩形内的文本插入值。
* `func lineFragmentRect(forProposedRect: CGRect, at: Int, writingDirection: NSWritingDirection, remaining: UnsafeMutablePointer<CGRect>?) -> CGRect`
    返回建议矩形的文本容器内的线片段矩形的边界。
* `var isSimpleRectangularTextContainer: Bool`
    一个布尔值，指示文本容器的区域是否为没有孔或间隙的矩形，其边缘是否平行于文本视图的坐标系轴。

