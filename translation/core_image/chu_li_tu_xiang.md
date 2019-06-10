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

