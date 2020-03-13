# 处理图像 

## 完成状态  

- [x] 开发中
- [ ] 未完成
- [ ] 已完成
- [ ] 维护中


通过过滤器，针对图像的每个像素点进行具体的算法操作后转化为一个新的图像。在 Core Image 中，图像处理依赖于 `CIFilter` 和 `CIImage` 类，提供了过滤器以及图像的输入和输出功能。可以通过 Core Image 或其他系统框架的结合或者通过创建`CIContext`类来创建自己的渲染工作流来应用过滤器并获取处理结果。本章主要通过这些类来实现过滤器的使用和获取渲染结果


## 简介  
在应用中可以通过多种方式使用 `Core Image` 进行图像处理  

```swift
import CoreImage  
// 1
let contenxt = CIContext() 

// 2
let filter = CIFilter(name: "CISepiaTone")  
filter.setValue(0.8, forKey:"kCIInoutIntensityKey") 

// 3
let image = CIImage(contentOFURL:imageUrl)  
filter.setValue(image, forKey:kCIInoutImageKey) 

// 4 
let result = filter.outputImage!  

// 5
let cgImage = context.createCGImage(result,form:result.extent)


```  
> 基于 CIContext 创建工作流实现

以上是一个 过滤器的简单应用示例， 整个操作过程分为5步执行： 
*  创建一个 `CIContext` 对象(此处使用系统默认设置),但并不是必须创建，可以通过其他系统框架上下文来实现。通过自己创建的上下文对象，可以更加精确的控制渲染过程和渲染所涉及到的系统资源。上下文对象是一个重量级对象，因此在创建过后，请尽早的使用并尽量重复使用。    
* 实例化`CIFilter`,创建一个过滤器对象，并为其设置参数  
* 创建一个`CIImage` 对象，将其作为过滤器参数。  
* 获取过滤器处理过的输出对象，类型为 `CIImage`。此时尚未执行过滤器  
* 将输出图像渲染为一个可以显示或者保存到文件的 Core Graphics 图像  

## 过滤器的输入和输出  
过滤器的输入和输出对象都是 `CIImage` 对象。 CIImage 实例表示图像的一个不可变对象。这些对象并不直接表示位图数据(并不是一个具体的图像)，而是图像的一个载体(一个代表)。例如上例中给出： 一个代表从文件加载图像； 一个代表了过滤器的输出。只有在请求渲染图像以用来显示或输出时，Core Image 才会执行真个过程   
__设置过滤器并不是实时执行的，只有在最后需要获取直接结果时，才会执行整个过程__   


要使用过滤器，需要创建一个或多个 CIImage 对象， 并将它们分配给过滤器的输入参数(例如：`kCIIputImageKey`), 可以从任何图像数据源创建 CIImage 对象：  
* 通过图像文件URL或者NSData 对象创建图像  
* Quartz2D,UIKit或者AppKit 中表示图像的对象(例如：`CGImageRef`, `UIImage` , `NSBitmapImageRep`)  
* Metal ,OpenGL 或者 OpenGL ES 纹理  
* `CoreVideo`图像或者像素缓冲区(`CVImageBufferRef` 或 `CVPixelBufferRef`)  
* `IOSurfaceRef`: 在进程间共享图形数据的对象  
* 内存中的图像位图数据(指向此类数据的指针，或 `CIImageProvider`)

> 具体的创建 CIImage 对象，请参考具体的 CIImage 类定义   

因为  `CIImage` 对象只是图像的一个描述对象(并不包含图像数据)。当访问`CIFilter`对象的`outputImage` 属性时.Core Image 仅识别并存储执行过滤器所需的步骤。只有当请求渲染图像用来实现或者输出时，才会执行这些步骤。可以通过`render` 或者`draw`方法触发显示请求，或者通过与Core Image 相结合的众多系统框架来间接触发显示请求   

延迟处理使得 Core Image 的处理快速高效。在渲染的过程中，Core Image 可以查看是否需要将多个滤镜应用到图像上，如果是需要，它将自动组合个步骤以消除冗余操作， 这样每个像素只需要处理一次就可以，并不需要处理多次   

## 图像处理效果描述---->CIFilter  
`CIFilter`该类的实例是用来描述和操作图像处理效果对象。要使用过滤器，可以创建一个 `CIFilter` 对象，通过设置其输入参数，然后就可访问输出图像。通过`filterWithName:`方法使用系统内置的过滤器名称初始化过滤器对象   

大多数过滤器都有一个或多个输入参数，用来控制处理方式和效果。每个输入参数都有一个属性，用来指定具体的数据类型。输入参数可以选择其他值，例如默认值，允许的最大值或最小值。例如： `CIColorMonochrome` 滤镜有是哪个输入参数(要处理的图像，颜色和颜色强度)


过滤器参数采用的是键值对的形式，要使用参数，需要通过`valueForKey:`和`setValue:forKey:`设置参数，键是一个标识属性的常量，值是与键关联的设置值  

Core Image 通常使用的几种值类型：  

类型名      | 类型
----        | ---
字符串      | NSString
浮点         |  NSNumber 
矢量        | CIVector 
颜色        | CIColor 
图片        | CIImage 
Transforms  | NSData, NSAffineTransform    


> __重要说明：__ `CIFilter`对象时可变的，因此无法在多线程之间安全共享。但是每个 CIFilter 对象的输入和输出`CIImage` 对象是不可变的，可以在多线程之间共享    



## 过滤器链   
每个 过滤器的输出都是一个 `CIImage` 对象，因此可以将此对象用作另一个 过滤器的输入。例如：颜色滤镜---> 锐化滤镜-----> 裁剪滤镜
![](../assets/translation/Snip20190611_12.png)  
> 图片来自官方文档



Core Image 内部会对此类过滤器链进行优化，以更加有效快速的处理。每个 CIImage 对象在过滤链中都不是渲染过后的图像，而只是用于渲染的标记。Core Image 不需要单独渲染每个过滤链生成中间像素存放在缓冲区中，因为这些缓冲区永远不会被看到，这样操作只会浪费时间和内存资源。Core Image 会将过滤器链中的多个过滤器组合成一个操作，并且有可能会对过滤器链进行重组以不同的顺序进行处理，从而更加有效的生成相同的结果。如图所示： 将过滤器链优化为单个操作  

![](../assets/translation/Snip20190611_13.png)  
> 图片来自官方文档  

说明: 当前操作已经将裁剪从最后一个移动到第一个，这样会先对原始图像应用裁剪操作，并将结果输入给接下来的操作。这样无需对需要裁剪的部分(废弃部分)进行颜色以及锐化滤镜操作。通过首先执行裁剪操作，Core Image 确保接下来的操作仅适用于最终输出可见像素    

```swift 
func applyFilterChain(to image: CIImage) -> CIImage {
    // 过滤器 1
    let colorFilter = CIFilter(name: "CIPhotoEffectProcess", withInputParameters:
        [kCIInputImageKey: image])!
    
    // 过滤器2
    // 将颜色过滤器的结果传递给Bloom过滤器
    let bloomImage = colorFilter.outputImage!.applyingFilter("CIBloom",
                                                             withInputParameters: [
                                                                kCIInputRadiusKey: 10.0,
                                                                kCIInputIntensityKey: 1.0
        ])
    
    // image cropping to rect 是一种快速创建 CICrop filter 的方式
    // 此处并没有显示的常见一个 CICrop filter 对象，而是通过 cropping 方法隐式创建
    let cropRect = CGRect(x: 350, y: 350, width: 150, height: 150)
    let croppedImage = bloomImage.cropping(to: cropRect)
    
    return croppedImage
}

```
> 创建过滤器链   

##### 说明：  
此处示例代码中就给出了 3 种创建filter的方式    
* `name:` 初始化方式创建filter, 一般应用在过滤器链的第一个   
* `outputImage!.applyingFilter`: 通过此种方式直接拼接一个过滤器，一般用在过滤器链中，连接多个过滤器，上个过滤器的输入作为下个过滤器的输入   
* `cropping`: 通过`CIImage` 的部分方法隐式创建过滤器，例如： 裁剪，坐标转换等方法   



### 特殊过滤器实现丰富操作  





## 与其他框架集成  
Core Image 可以与 iOS， Mac OS，tvOS 中的其他几种框架进行联合操作。由于这种无缝连接特性，可以在应用程序中通过Core Image 轻松的为游戏，视频，图像添加各种视觉效果而无需构建复杂的渲染代码。以下介绍了Core Image 的几种常用方法，以及与系统框架的集成    

### 在UIKit / AppKit 中处理静态图像  
UIkit/AppKit 提供了简单的方式 实现Core Image 针对静态图片的处理。例如： 
* 旅行应用科恩给你会在列表中显示目的地图像，然后针对这些图像做滤镜处理，以便在每个目的地的详细信息页面实现特色背景    
* 社交应用可以对用户头像做滤镜处理体现用户对每个帖子不一样的态度  
* 相机应用可以针对用户的拍摄添加不同的滤镜效果，或针对用户现有图片实现滤镜效果     

__注意:__ 请不要使用 Core Image 针对UI 实现模糊效果，虽然可以实现(例如，半透明侧边栏，工具栏等)。此种效果可以通过`NSVisualEffectView(macOS)`和`UIVisualEffectView(iOS/tvOS)` 实现。这些类自动匹配系统UI效果并提供高效的实时渲染     

在iOS 和 tvOS 中，可以针对 `UIImage` 对象添加 Core Image 滤镜效果。

```swift 
class ViewController: UIViewController {
    let filter = CIFilter(name: "CISepiaTone",
                          withInputParameters: [kCIInputIntensityKey: 0.5])!
    @IBOutlet var imageView: UIImageView!
    
    func displayFilteredImage(image: UIImage) {

        // 将 UIImage   ----> CIImage
        let inputImage = CIImage(image: image)!
        // 设置 inputImage为过滤器的输入源 
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        // 将 filter的输出源转化为 UIImage 对象
        imageView.image = UIImage(CIImage: filter.outputImage!)
    }
}

```  

在 macOS 中，通过`initWithBitmapImageRep:`方法从`NSBitmapImageRep`对象或者`Bitmap data(位图数据)` 创建一个`CIImage` 对象  

### 在 AVFoundation 中处理视频  
AVFoundation 框架提供了许多处理视频和音频的API。其中`AVVideoComposition` 可可以实现将视频和音频轨道进行组合或编辑拆分操作。可以在`AVVideoComposition`类针对视频的处理期间将 Core Image 的滤镜应用于视频的每一帧    

```swift  

let filter = CIFilter(name: "CIGaussianBlur")!
let composition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
    
    // Clamp to avoid blurring transparent pixels at the image edges
    let source = request.sourceImage.clampingToExtent()
    filter.setValue(source, forKey: kCIInputImageKey)
    
    // Vary filter parameters based on video timing
    let seconds = CMTimeGetSeconds(request.compositionTime)
    filter.setValue(seconds * 10.0, forKey: kCIInputRadiusKey)
    
    // Crop the blurred output to the bounds of the original image
    let output = filter.outputImage!.cropping(to: request.sourceImage.extent)
    
    // Provide the filter output to the composition
    request.finish(with: output, context: nil)
})

```


