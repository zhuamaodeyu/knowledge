# NSLayoutManager

协调文本字符布局和显示的对象， 协调布局和渲染字符，持有一个NSTextStorage。NSLayoutManager也负责把Unicode字符映射到相应的字形。

### 主要作用： 
1. 管理器侦听文本存储中的文本或属性更改通知，并在接收时触发布局过程。

2. 从文本存储提供的文本开始，它将所有字符转换为字形 

3. 生成字形后，管理器会咨询其文本容器以获取可用的文本区域。

4. 然后用线条逐步填充这些区域，再用字形逐步填充这些区域。填满一行后，开始下一行。

5. 对于每一行，布局管理器必须考虑换行行为（单词不适合必须移到下一行）、断字、内联图像附件等。

6. 布局完成后，文本视图的当前显示状态无效，布局管理器将之前设置的文本绘制到文本视图中。

## 访问文本存储
* `var textStorage: NSTextStorage?`
    包含要布局的内容的文本存储对象。
* `func replaceTextStorage(NSTextStorage)`
    将布局管理器的当前文本存储对象替换为指定对象。   

## 配置全局布局管理器选项
* `var allowsNonContiguousLayout: Bool`
    一个布尔值，指示布局管理器是否允许非连续布局。
* `var hasNonContiguousLayout: Bool`
    一个布尔值，指示布局管理器当前是否具有任何非连续布局区域。
* `var showsInvisibleCharacters: Bool`
    一个布尔值，指示是否用可见字形替换空格和其他通常不可见的字符。
* `var showsControlCharacters: Bool`
    一个布尔值，指示布局管理器是否用可见字形替换布局中的控制字符。
* `var usesFontLeading: Bool`
    一个布尔值，指示布局管理器是否使用字体的前导。
* `var backgroundLayoutEnabled: Bool`
    一个布尔值，指示布局管理器是否生成字形并在应用程序的运行循环空闲时对其进行布局。
* `var limitsLayoutForSuspiciousContents: Bool`
    一个布尔值，指示布局管理器是否避免布局异常长或可疑的输入。
* `var usesDefaultHyphenation: Bool`
    一个布尔值，指示布局管理器是否使用默认断字规则来换行。


## 管理文本容器

* `var textContainers: [NSTextContainer]`
    布局管理器的当前文本容器。
* `func addTextContainer(NSTextContainer)`
    将指定的文本容器附加到布局管理器排列文本的一系列文本容器中。
* `func insertTextContainer(NSTextContainer, at: Int)`
    在文本容器列表中的指定索引处插入一个文本容器。
* `func removeTextContainer(at: Int)`
    删除指定索引处的文本容器并根据需要使布局无效。
* `func setTextContainer(NSTextContainer, forGlyphRange: NSRange)`
    将文本容器与指定范围的字形相关联。
* `func textContainerChangedGeometry(NSTextContainer)`
    使指定文本容器和所有后续文本容器对象的布局信息和可能的字形无效。
* `func textContainerChangedTextView(NSTextContainer)`
    更新管理指定文本容器的文本视图对象所需的信息。
* `func textContainer(forGlyphAt: Int, effectiveRange: NSRangePointer?) -> NSTextContainer?`
    返回管理指定字形布局的文本容器，从而根据需要进行布局。
* `func textContainer(forGlyphAt: Int, effectiveRange: NSRangePointer?, withoutAdditionalLayout: Bool) -> NSTextContainer?`
    返回管理指定字形布局的文本容器。
* `func usedRect(for: NSTextContainer) -> CGRect`
    返回指定文本容器中字形的边界矩形。


## 使字形和布局无效 

* `func invalidateDisplay(forCharacterRange: NSRange)`
    使指定字符范围的显示无效。
* `func invalidateDisplay(forGlyphRange: NSRange)`
    使一系列字形无效，需要新的布局信息，并更新显示这些字形的任何文本视图的适当区域。
* `func invalidateGlyphs(forCharacterRange: NSRange, changeInLength: Int, actualCharacterRange: NSRangePointer?)`
    使指定字符范围内的字形无效并调整。
* `func invalidateLayout(forCharacterRange: NSRange, actualCharacterRange: NSRangePointer?)`
    使映射到指定字符范围的字形的布局信息无效。
* `func processEditing(for: NSTextStorage, edited: NSTextStorage.EditActions, range: NSRange, changeInLength: Int, invalidatedRange: NSRange)`
    当编辑操作更改其文本存储对象的内容时通知布局管理器。


## 字形生成和布局

* `func ensureGlyphs(forCharacterRange: NSRange)`
    如果尚未生成指定字符范围的字形，则强制布局管理器生成字形。
* `func ensureGlyphs(forGlyphRange: NSRange)`
    如果尚未生成指定字形范围的字形，则强制布局管理器生成字形。
* `func ensureLayout(forBoundingRect: CGRect, in: NSTextContainer)`
    强制布局管理器为指定文本容器中的指定区域执行布局（如果尚未执行）。
* `func ensureLayout(forCharacterRange: NSRange)`
    强制布局管理器为指定的字符范围执行布局（如果尚未执行）。
* `func ensureLayout(forGlyphRange: NSRange)`
    强制布局管理器为指定的字形范围执行布局（如果尚未执行）。
* `func ensureLayout(for: NSTextContainer)`
    强制布局管理器为指定的文本容器执行布局（如果尚未执行）。
* `var glyphGenerator: NSGlyphGenerator`
    布局管理器使用的字形生成器。

## 访问字形 

* `func getGlyphs(in: NSRange, glyphs: UnsafeMutablePointer<CGGlyph>?, properties: UnsafeMutablePointer<NSLayoutManager.GlyphProperty>?, characterIndexes: UnsafeMutablePointer<Int>?, bidiLevels: UnsafeMutablePointer<UInt8>?) -> Int`
    用一系列字形填充传入的缓冲区。
* `func cgGlyph(at: Int) -> CGGlyph`
    返回指定索引处的字形。
* `func cgGlyph(at: Int, isValidIndex: UnsafeMutablePointer<ObjCBool>?) -> CGGlyph`
    返回指定索引处的字形以及有关字形索引是否有效的信息。
* `func setGlyphs(UnsafePointer<CGGlyph>, properties: UnsafePointer<NSLayoutManager.GlyphProperty>, characterIndexes: UnsafePointer<Int>, font: UIFont, forGlyphRange: NSRange)`
    存储字符范围的初始字形和字形属性。
* `func characterIndexForGlyph(at: Int) -> Int`
    返回指定字形的第一个字符在文本存储中的索引。
* `func glyphIndexForCharacter(at: Int) -> Int`
    返回指定索引处字符的第一个字形的索引。
* `func isValidGlyphIndex(Int) -> Bool`
    指示指定的索引是否引用有效的字形。
* `var numberOfGlyphs: Int`
    布局管理器中的字形数量。
* `func propertyForGlyph(at: Int) -> NSLayoutManager.GlyphProperty`
    返回指定索引处的字形的字形属性。
* `struct NSLayoutManager.GlyphProperty`
    字形属性。



## 设置布局信息

* `func setAttachmentSize(CGSize, forGlyphRange: NSRange)`
    设置在绘制表示附件的字形时使用的大小。
* `func setDrawsOutsideLineFragment(Bool, forGlyphAt: Int)`
    指示指定的字形是否超出其布局的线段边界。
* `func setExtraLineFragmentRect(CGRect, usedRect: CGRect, textContainer: NSTextContainer)`
    为额外的线片段设置边界和容器。
* `func setLineFragmentRect(CGRect, forGlyphRange: NSRange, usedRect: CGRect)`
    关联指定字形范围的线段边界。
* `func setLocation(CGPoint, forStartOfGlyphRange: NSRange)`
    设置指定范围内第一个字形的位置。
* `func setNotShownAttribute(Bool, forGlyphAt: Int)`
    设置字形在指定索引处的可见性。


##  获取布局信息

* `func attachmentSize(forGlyphAt: Int) -> CGSize`
    返回指定索引处附件字形的大小。
* `func drawsOutsideLineFragment(forGlyphAt: Int) -> Bool`
    指示字形是否在其线片段矩形之外绘制。
* `var extraLineFragmentRect: CGRect`
    文档末尾的额外行片段的矩形。
* `var extraLineFragmentTextContainer: NSTextContainer?`
    额外线片段矩形的文本容器。
* `var extraLineFragmentUsedRect: CGRect`
    在额外的线片段矩形中包围插入点的矩形。
* `func firstUnlaidCharacterIndex() -> Int`
    返回布局管理器中不在布局中的第一个字符的索引。
* `func firstUnlaidGlyphIndex() -> Int`
    返回布局管理器中不在布局中的第一个字形的索引。
* `func getFirstUnlaidCharacterIndex(UnsafeMutablePointer<Int>?, glyphIndex: UnsafeMutablePointer<Int>?)`
    返回具有无效布局信息的第一个字符和字形的索引。
* `func lineFragmentRect(forGlyphAt: Int, effectiveRange: NSRangePointer?) -> CGRect`
    返回字形所在的行片段的矩形和（可选）通过引用，该片段中的整个字形范围。
* `func lineFragmentRect(forGlyphAt: Int, effectiveRange: NSRangePointer?, withoutAdditionalLayout: Bool) -> CGRect`
    返回包含指定字形索引处的字形的线片段矩形。
* `func lineFragmentUsedRect(forGlyphAt: Int, effectiveRange: NSRangePointer?) -> CGRect`
    返回线片段的使用矩形，并（可选）返回该片段中的整个字形范围。
* `func lineFragmentUsedRect(forGlyphAt: Int, effectiveRange: NSRangePointer?, withoutAdditionalLayout: Bool) -> CGRect`
    返回线片段的使用矩形，并（可选）返回该片段中的整个字形范围。
* `func location(forGlyphAt: Int) -> CGPoint`
    返回指定字形在其行片段中的位置。
* `func notShownAttribute(forGlyphAt: Int) -> Bool`
    指示指定索引处的字形是否具有可见表示。
* `func truncatedGlyphRange(inLineFragmentForGlyphAt: Int) -> NSRange`
    返回包含指定索引的行片段的截断字形范围。



## 执行高级布局查询
* `func boundingRect(forGlyphRange: NSRange, in: NSTextContainer) -> CGRect`
    返回容器中指定字形的边界矩形。
* `func characterIndex(for: CGPoint, in: NSTextContainer, fractionOfDistanceBetweenInsertionPoints: UnsafeMutablePointer<CGFloat>?) -> Int`
    使用指定容器的坐标系返回位于指定点下方的字符的索引。
* `func characterRange(forGlyphRange: NSRange, actualGlyphRange: NSRangePointer?) -> NSRange`
    返回与指定字形范围内的字形相对应的字符范围。
* `func enumerateEnclosingRects(forGlyphRange: NSRange, withinSelectedGlyphRange: NSRange, in: NSTextContainer, using: (CGRect, UnsafeMutablePointer<ObjCBool>) -> Void)`
    枚举文本容器中指定字形范围的封闭矩形。
* `func enumerateLineFragments(forGlyphRange: NSRange, using: (CGRect, CGRect, NSTextContainer, NSRange, UnsafeMutablePointer<ObjCBool>) -> Void)`
    枚举与指定字形范围相交的行片段。
* `func fractionOfDistanceThroughGlyph(for: CGPoint, in: NSTextContainer) -> CGFloat`
    返回指定点的字形与下一个字形之间的距离的分数。
* `func getLineFragmentInsertionPoints(forCharacterAt: Int, alternatePositions: Bool, inDisplayOrder: Bool, positions: UnsafeMutablePointer<CGFloat>?, characterIndexes: UnsafeMutablePointer<Int>?) -> Int`
    批量返回指定行片段的插入点。
* `func glyphIndex(for: CGPoint, in: NSTextContainer) -> Int`
    返回文本容器中指定位置的字形索引。
* `func glyphIndex(for: CGPoint, in: NSTextContainer, fractionOfDistanceThroughGlyph: UnsafeMutablePointer<CGFloat>?) -> Int`
    使用容器的坐标系返回指定点处的字形索引。
* `func glyphRange(forBoundingRect: CGRect, in: NSTextContainer) -> NSRange`
    返回完全或部分位于文本容器的指定矩形内的字形的最小连续范围。
* `func glyphRange(forBoundingRectWithoutAdditionalLayout: CGRect, in: NSTextContainer) -> NSRange`
    返回完全或部分位于文本容器的指定矩形内的字形的最小连续范围。
* `func glyphRange(for: NSTextContainer) -> NSRange`
    返回位于指定文本容器内的字形范围。
* `func glyphRange(forCharacterRange: NSRange, actualCharacterRange: NSRangePointer?) -> NSRange`
    返回指定字符范围生成的字形范围。
* `func range(ofNominallySpacedGlyphsContaining: Int) -> NSRange`
    返回围绕指定索引处的字形的可显示字形的范围。


## 绘制 

* `func drawBackground(forGlyphRange: NSRange, at: CGPoint)`
    为指定的字形绘制背景标记，它必须完全位于单个文本容器中。
* `func drawGlyphs(forGlyphRange: NSRange, at: CGPoint)`
    绘制必须完全位于单个文本容器中的指定字形。
* `func drawStrikethrough(forGlyphRange: NSRange, strikethroughType: NSUnderlineStyle, baselineOffset: CGFloat, lineFragmentRect: CGRect, lineFragmentGlyphRange: NSRange, containerOrigin: CGPoint)`
    为指定的字形绘制删除线。
* `func drawUnderline(forGlyphRange: NSRange, underlineType: NSUnderlineStyle, baselineOffset: CGFloat, lineFragmentRect: CGRect, lineFragmentGlyphRange: NSRange, containerOrigin: CGPoint)`
    为指定范围内的字形绘制下划线。
* `func fillBackgroundRectArray(UnsafePointer<CGRect>, count: Int, forCharacterRange: NSRange, color: UIColor)`
    用颜色填充背景矩形。
* `func showCGGlyphs(UnsafePointer<CGGlyph>, positions: UnsafePointer<CGPoint>, count: Int, font: UIFont, textMatrix: CGAffineTransform, attributes: [NSAttributedString.Key : Any], in: CGContext)`
    使用指定的属性在指定位置渲染字形。
* `func strikethroughGlyphRange(NSRange, strikethroughType: NSUnderlineStyle, lineFragmentRect: CGRect, lineFragmentGlyphRange: NSRange, containerOrigin: CGPoint)`
    计算并绘制指定字形的删除线。
* `func underlineGlyphRange(NSRange, underlineType: NSUnderlineStyle, lineFragmentRect: CGRect, lineFragmentGlyphRange: NSRange, containerOrigin: CGPoint)`
    计算指定字形的下划线子范围，并根据需要绘制下划线。


## 处理文本块的布局
* `func setLayoutRect(NSRect, for: NSTextBlock, glyphRange: NSRange)`
    设置包围指定文本块和字形范围的布局矩形。
* `func layoutRect(for: NSTextBlock, glyphRange: NSRange) -> NSRect`
    返回指定文本块和字形范围布局的矩形。
* `func setBoundsRect(NSRect, for: NSTextBlock, glyphRange: NSRange)`
    设置包围指定文本块和字形范围的边界矩形。
* `func boundsRect(for: NSTextBlock, glyphRange: NSRange) -> NSRect`
    返回包围指定文本块和字形范围的边界矩形。
* `func layoutRect(for: NSTextBlock, at: Int, effectiveRange: NSRangePointer?) -> NSRect`
    返回指定文本块和字形布局的矩形。
* `func boundsRect(for: NSTextBlock, at: Int, effectiveRange: NSRangePointer?) -> NSRect`
    返回指定文本块和字形的边界矩形。



## NSLayoutManagerDelegate  

### 使字形和布局无效
* `func layoutManagerDidInvalidateLayout(NSLayoutManager)`
    当指定的布局管理器使布局信息（不是字形信息）无效时通知委托。
* `func layoutManager(NSLayoutManager, shouldGenerateGlyphs: UnsafePointer<CGGlyph>, properties: UnsafePointer<NSLayoutManager.GlyphProperty>, characterIndexes: UnsafePointer<Int>, font: UIFont, forGlyphRange: NSRange) -> Int`
    启用初始字形生成过程的自定义。
* `func layoutManager(NSLayoutManager, shouldUse: NSLayoutManager.ControlCharacterAction, forControlCharacterAt: Int) -> NSLayoutManager.ControlCharacterAction`
    返回指定字符索引处控制字符的控制字符操作。

### 响应文本容器布局
* `func layoutManager(NSLayoutManager, didCompleteLayoutFor: NSTextContainer?, atEnd: Bool)`
    当布局管理器在指定的文本容器中完成文本布局时通知委托。
* `func layoutManager(NSLayoutManager, textContainer: NSTextContainer, didChangeGeometryFrom: CGSize)`
    当布局管理器由于指定文本容器的几何形状发生变化而使布局无效时通知代理。

### 处理线段

* `func layoutManager(NSLayoutManager, shouldBreakLineByHyphenatingBeforeCharacterAt: Int) -> Bool`
    询问代理是否在指定字符处换行。
* `func layoutManager(NSLayoutManager, shouldBreakLineByWordBeforeCharacterAt: Int) -> Bool`
    询问代理是否在指定单词处换行。
* `func layoutManager(NSLayoutManager, lineSpacingAfterGlyphAt: Int, withProposedLineFragmentRect: CGRect) -> CGFloat`
    返回要添加到行尾的空间量,(相当于行间距了)
* `func layoutManager(NSLayoutManager, paragraphSpacingAfterGlyphAt: Int, withProposedLineFragmentRect: CGRect) -> CGFloat`
    返回要在段落末尾添加的空间量. (段落末尾的空白区域)
* `func layoutManager(NSLayoutManager, paragraphSpacingBeforeGlyphAt: Int, withProposedLineFragmentRect: CGRect) -> CGFloat`
    返回要在段落开头添加的空间量。(段落头部的空白区域，首行锁进)
* `func layoutManager(NSLayoutManager, boundingBoxForControlGlyphAt: Int, for: NSTextContainer, proposedLineFragment: CGRect, glyphPosition: CGPoint, characterIndex: Int) -> CGRect`
    返回具有指定参数的指定控制字形的边界矩形。
* `func layoutManager(NSLayoutManager, shouldSetLineFragmentRect: UnsafeMutablePointer<CGRect>, lineFragmentUsedRect: UnsafeMutablePointer<CGRect>, baselineOffset: UnsafeMutablePointer<CGFloat>, in: NSTextContainer, forGlyphRange: NSRange) -> Bool`
    在将线片段几何提交到布局缓存之前对其进行自定义。