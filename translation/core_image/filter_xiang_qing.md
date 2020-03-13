# 内置 Filter 列表  

Core Image 提供了方法可以查询系统中内置过滤器及过滤器的名称，输入参数，参数类型，默认值等详细信息。如果应用支持让用户选择过滤器，可以应用查询系统函数   


## 获取Filters 和属性列表  
使用`filterNamesInCategory:`和`filterNamesInCategories:` 方法可以准确获取到可用过滤器列表。系统针对过滤器进行了分类，如果需要通过类别查询，则可以调用`filterNamesInCategory:`方法，通过下表列出的类别常量作为参数查询    

如果要查询系统中多个类别支持的过滤器，可以通过`filterNamesInCategories:` 方法获取。也可以通过传入参数 `nil` 来获取系统支持的所有过滤器    

过滤器大体可以通过一下方式进行分类：  
* 效果类型  
* 使用范围(静止图片，视频等)  
* 是否内置   


过滤器              | 作用
----                | ---
kCICategoryDistortionEffect | 失真效果，如凹凸，旋转 
kCICategoryGeometryAdjustment        |  几何调整，如仿射变换，裁剪，透视变换 
kCICategoryCompositeOperation          | 合成，例如source over，minimum，source atop，color dodge blend mode
kCICategoryHalftoneEffect         | 半色调效果，如屏幕，线条屏幕，阴影线
kCICategoryColorAdjustment | 颜色调整，如伽马调整，白点调整，曝光  
kCICategoryColorEffect     |    色彩效果，如色调调整，张贴  
kCICategoryTransition       | 图像之间的过渡，例如溶解，与面具分解，滑动  
kCICategoryTileEffect       | 平铺效果  
kCICategoryGenerator        | 图像生成器，如条纹，恒定颜色，棋盘格  
kCICategoryGradient         | 梯度，如轴向，径向，高斯  
kCICategoryStylize          | 风格化  
kCICategorySharpen          | 锐化，亮度 
kCICategoryBlur             | 模糊，如高斯，变焦，运动


> 效果类型  




过滤器              | 作用
----                | ---
kCICategoryStillImage | 可用于静止图像  
kCICategoryVideo        |  可用于视频
kCICategoryInterlaced          | 可用于各行扫描图像
kCICategoryNonSquarePixels      | 可用于非方形像素  
kCICategoryHighDynamicRange | 可用于高动态范围像素
   

> 使用范围  



过滤器              | 作用
----                | ---
kCICategoryBuiltIn | 内置
  

> 是否内置  

#### 获取过滤器属性   
```
CIFilter * myFilter = [CIFilter filterWithName：@“<＃Filter Name Here＃>”];
NSDictionary * myFilterAttributes = [myFilter attributes];  
```
> 属性包括名称，类别，最小值，最大值，默认值等  




## 构建过滤器属性字典 
如果应用程序提供了用户交互界面，则可以过滤词典以创建和更新用户界面。例如： 布尔值的过滤器属性需要一个单选框或类似控件，在一定范围内连续变化的属性可以使用UISlider控件等。默认属性设置作为用户交互界面的初始设置    

过滤器名称和属性列表提供了构建用户界面的额所有元素，允许用户选择过滤器并红纸其输入参数，过滤器的属性会提供过滤器有多少参数，参数名称，参数类型以及最大值，最小值和默认值等    
> 可以参考[IKFilterUIView](https://developer.apple.com/documentation/quartz/ikfilteruiview),此类提供了过滤器的输入参数视图示例

```
NSMutableDictionary * filtersByCategory = [NSMutableDictionary dictionary];
 
NSMutableArray * filterNames = [NSMutableArray array];
[filterNames addObjectsFromArray：
    [CIFilter filterNamesInCategory：kCICategoryGeometryAdjustment]];
[filterNames addObjectsFromArray：
    [CIFilter filterNamesInCategory：kCICategoryDistortionEffect]];
filtersByCategory [@“Distortion”] = [self buildFilterDictionary：filterNames];
 
[filterNames removeAllObjects];
[filterNames addObjectsFromArray：
    [CIFilter filterNamesInCategory：kCICategorySharpen]];
[filterNames addObjectsFromArray：
    [CIFilter filterNamesInCategory：kCICategoryBlur]];
filtersByCategory [@“Focus”] = [self buildFilterDictionary：filterNames];



```



以上示例代码展示了获取过滤器名称并按功能类别构建过滤器字典的功能。代码中获取了以下类别的过滤器kCICategoryGeometryAdjustment，kCICategoryDistortionEffect，kCICategorySharpen和kCICategoryBlur

```
- (NSMutableDictionary *)buildFilterDictionary:(NSArray *)filterClassNames  // 1  过滤器名称数组参数
{
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    for (NSString *className in filterClassNames) {                         // 2 迭代参数
        CIFilter *filter = [CIFilter filterWithName:className];             // 3 构建过滤器  
 
        if (filter) {
            filters[className] = [filter attributes];                       // 4 获取所有属性
        } else {
            NSLog(@"could not create '%@' filter", className);
        }
    }
    return filters;
}
```
> 按过滤器名称构建属性字典   





