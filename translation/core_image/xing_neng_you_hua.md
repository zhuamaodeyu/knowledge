# 性能优化  

Core Image 提供了多种用于创建图像，上下文和渲染的方式。可以根据不同的需求进行区别创建，例如:  
* 应用是否需要长时间执行任务  
* 应用适用于静态还是视频图像  
* 是否需要支持实时处理或分析  
* 是否需要高色彩保证度    

## 最佳实践   
通过遵守以下方式可以达到最佳性能：  

* 不要在每次渲染都创建 `CIContext` 对象
    上下文存储了大量信息，应该重复使用   
* 应用是否需要色彩管理，除非必须，否则不要使用它(色彩管理参见后续内容)   
* 使用 GPU 上下文渲染 CIImage 对象时,避免使用核心动画动画。
    如果需要同时使用，则可以将其设置为CPU支持  
* 确保图像不超过 CPU 和 GPU 限制。
    `CIContext`处理图像大小因使用CPU或者GPU而不同，可以通过`inputImageMaximumSize`和`outputImageMaximumSize`检查       
* 尽可能使用较小的图像  
    像素数量越多性能越低。您可以将Core Image输入(`CIImage`)渲染为较小的视图，纹理或帧缓冲区。 Allow Core Animation to upscale to display size.   
    使用`Core Graphics`或`Image I / O`函数进行裁剪或降低分辨率，例如函数`CGImageCreateWithImageInRect`或`CGImageSourceCreateThumbnailAtIndex`。
* `UIImageView` 类最适合静态图像  
    如果APP需要更高性能，可以使用底层API实现  
* 避免CPU 和 GPU 之间不必要的数据转换(纹理)  
* 在渲染具体图像像素之前，创建相同大小的矩形  
* 考虑使用简单的过滤器实现相同的效果  
    例如： `CIColorCube`可以产生类似于`CISepiaTone`的效果，并且可以更高效地完成处理。  
* 利用iOS 6.0及更高版本中对YUV图像的支持。
    相机像素缓冲器本身是YUV，但大多数图像处理算法都需要RBGA数据。在两者之间进行转换需要付出一定的性能代价。 Core Image支持从`CVPixelBuffer`对象读取YUB并应用适当的颜色转换。   
    ```
    options = @{ (id)kCVPixelBufferPixelFormatTypeKey :
                @(kCVPixelFormatType_420YpCbCr88iPlanarFullRange) };
    ```



### 色彩管理  
默认情况下，Core Image 会在线性颜色空间应用所有滤镜，   


转换为sRGB 和从sRGB 转换会增加过滤器的复杂性，并需要应用以下公式:  
```
rgb = mix（rgb.0.0774，pow（rgb * 0.9479 + 0.05213,2.4），step（0.04045，rgb））
rgb = mix（rgb12.92，pow（rgb * 0.4167）* 1.055  -  0.055，step（0.00313，rgb））
```   

在以下情况下，考虑禁用颜色管理：  
* 应用需要绝对的高性能  
* 操作后，用户看不到明显的差别   

要禁用颜色管理，将`kCIImageColorSpace`设置为null。如果使用EAGL上下文,则在创建EAGL上下文时也将上下文颜色空间设置为null。[请参阅使用核心映像上下文构建自己的工作流](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_tasks/ci_tasks.html#//apple_ref/doc/uid/TP30001185-CH3-SW5)   
