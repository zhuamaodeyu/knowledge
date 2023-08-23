## GPUImage 源码解析 

#### Core Image 区别 
* GPUImage 
	* 开源 
	* 都是基于 Open GL ES 实现  
	* 在视频滤镜上会处理的更好 
	* 自定义  
* Core Image
	* 支持CPU渲染  
	* 支持人脸识别  
	* 支持大图处理， GPU 纹理限制为 4096 * 4096， 超出部分会进行压缩处理，Core Image 会进行拆解小图处理  

	
#### GPUImage 特点  
1. 输入组件  
	* 图片  
	* 纹理  
	* 视频  
	* 二进制数据  
	* UI Element
2. 丰富的滤镜  
	* 颜色类： 亮度，饱和度， 色度， 对比度， 白平衡  
	* 图像： 仿射变换、裁剪、高斯模糊、毛玻璃  
	* 颜色混合类： 透明度混合、纹理混合  
	* 效果类： 素描、像素画、旋涡  
3. 丰富输出组件  
	* UIView  
	* 视频 
	* 纹理 
	* 二进制数据  

###源码组成  
#### Source  
1. GPUImageVideoCamera  
2. GPUImageStillCamera  
3. GPUImagePicture  
4. GPUImageMovie  
5. GPUImageMovieComposition  
6. GPUImageTextureInput(纹理)
7. GPUImageRawDataOutPut  （二进制数据）
8. GPUImageUIElement  （UIView）
9. GPUImageColorConversion

#### Pipeline  
* GPUImageFilterPipline

#### Filters
* GPUImageFilter，所有Filter父类
* GPUImageTwoInputFilter
* GPUImageThreeInputFilter
* GPUImageFourInputFilter
* GPUImageTwoPassFilter
* GPUImageTwoPassTextureSamplingFilter
* GPUImageFilterGroup
* GPUImage3x3TextureSamplingFilter
* GPUImageTwoInputCrossTextureSamplingFilter
* GPUImageBuffer

	
#### Output  
1. GPUImageView  
2. GPUImageMovieWriter 
3. GPUImageTextureOutput  
4. GPUImageRawDataOutput  


#### Other 
1. GLProgram : shader 管理、编译链接  
2. GPUImageContext: OpenGL Context 管理   
3. GPUImageFramebuffer 和 GPUImageFramebufferCache: buffer 管理     



##示例  
1. 原图 ----> GPUImagePicture ----->  XXXXX Filter ------> GPUImageView -----> Image





## 源码分析  
### Bases



### Sources   
滤镜链:  输入(图片、视频、纹理、二进制等) -------> 输出(视频，图片等)
#### GPUImageOutput 
* MovieWriter:  
	从帧缓冲中将渲染的结果纹理数据通过AVAssetWriter把每一帧保存到相应的路径   

* RawDataOutput  
	边录制边上传，获取处理滤镜中帧缓冲区的二进制数据上传到平台   

* TextureOutput    
	输出纹理， 渲染完成后得到的新纹理   

* GPUImageView  
	纹理输出到 Layer 上   







#### GPUImageInput
* Picture:  
	处理静态图片。 本质是解压图片  -----> 纹理 -----> 滤镜处理  

* RawDataInout:  
	二进制数据 -----> 纹理， 得到 `CVPixelFormat`  

* TextureInput:  
	纹理。  

* UIElement  
	UIView, CALayer。 通过 Core graphic 把要绘制的内容填充到上下文来获取图片数据->纹理, 用在：
	* 图片水印  
	* 文字水印 

* Movie  
	视频文件 ----> AVAssetReader逐帧读取 -----> 帧数据转化为纹理 -----> 滤镜处理  
	```AVAssetReaderOutput -> CMSampleBufferRef -> CVImageBufferRef -> CVOpenGLESTextureRef -> texture```  

* VideoCamera
	AVFoundation采集视频 ----> 回调方法```didOutputSampleBuffer-> CVImageBufferRef -> CVOpenGLESTextureRef -> texture```  

* StillCamera  
	GPUImagePicture的子类，拍图片，AVFoundation采集图片-> 回调方法 ```didOutputSampleBuffer-> CVImageBufferRef -> CVOpenGLESTextureRef -> texture```



#### 示例 
```
//2.选择需要的滤镜
    if (_disFilter == nil) {
        //只有在_disFilter为空时才创建滤镜，初始化
        _disFilter = [[GPUImageSaturationFilter alloc] init];
    }
    
    //设置饱和度的值，默认1.0
    _disFilter.saturation = 1.0;
    
    //设置滤镜处理的区域，图片的大小
    [_disFilter forceProcessingAtSize:_jingImage.size];
    
    [_disFilter useNextFrameForImageCapture];
    
    //根据slider调整滤镜的饱和度
    _disFilter.saturation = sender.value;
    
    //3.拿到数据源头-静态图片
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:_jingImage];
    
    //图片添加滤镜
    [stillImageSource addTarget:_disFilter];
    //处理图片
    [stillImageSource processImage];
    
    //4.获取处理后的图片
    UIImage *newImage = [_disFilter imageFromCurrentFramebuffer];
    
    //5.新图片放到imageView显示
    _jingImageView.image = newImage;
```




### Filters



### Outputs 



### Pipeline