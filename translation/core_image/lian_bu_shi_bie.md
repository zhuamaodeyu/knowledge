# 脸部识别

Core Image 课时分析和查找图像中的人脸。它只能执行面部检测，不能进行识别。人脸检测和人脸识别有本质区别：   

`人脸检测`: 是包含人脸特征的矩形识别。  
`人脸识别`: 是识别出图像中的人脸属于哪个人，例如： 约翰，玛丽     

Core Image 检测到面部后，它还可以提供有关面部特征的部分信息，例如眼睛和嘴巴位置。同时可以实时跟踪视频中已识别面部位置    


![](../../assets/translation/face_detection_2x.png)
> 人脸检测(图片来自官方文档)


通过获取图像的位置，可以方便的进行例如裁剪或调整脸部图片质量(色调，红眼校正)等操作。并且还可以进行更加有趣的操作：  
* 面部添加滤镜，仅将滤镜应用在面部  
* 脸部添加部分小插图   


## 检测人脸   
使用 `CIDetector` 来实现脸部检测  

```
//1 
CIContext * contenxt = [CIContext context];
// 2
NSDictionary * opts = @{CIDetectorAccuracy: CIDetectorAccuracyHigh}  

//3
CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace  contenxt:contenxt options:opts];  

//4
opts = @{CIDetectorImageOrientation : [image_object propeties] valueForKey:kCGImagePropertyOrientation};

// 5
NSArray * features = [detector featuresInImage:image_object options: ops];
```
说明：    
1. 使用默认配置创建上下文，可也以使用前文所说的几种方式创建  
2. 创建字典参数，用来约束检测器的准确度。可以指定准确度为低或高，当精确度低时，处理速度会快，当精确度高时，处理速度会较慢   
3. 创建检测器  
4. 设置用来检测人脸的字典类型参数，主要是让Core Image 能够清楚当前检测对象图片的方向，这样它可以清楚的知道从哪里找到正面。大多数情况下，可以直接从图片读取方向并直接存储到字典传输给检测器    
5. 使用检测器开始检测，__检测对象必须是一个 `CIImage` 对象。__ Core Image 将返回一个 `CIFeature` 对象数组，每个对象代表一个人脸    

通过获取人脸后，可以找出面部特征，例如眼睛和嘴巴的位置等   


## 获取面部特征和边界  
面部特征包括:  
* 左眼和右眼的位置  
* 嘴巴的位置  
* 跟踪帧，Core Image 可用于跟踪视频中的脸部

从 `CIDetector` 对象获取面部特征数组后，可以遍历数组获取每个人脸的边界和面部特征   
> CIDetector: 对象属性提供有关面部眼睛和嘴巴的信息。视频中的面部对象还可以具有跟踪时间跟踪ID和帧计数的位置的属性。

```
for (CIFaceFeature *f in features){
    // 1
    NSLog(@"%@",NSStringFormRect(f.bounds))

    // 2
    if (f.hasLeftEyePosition){
         NSLog（@“左眼％g％g”，f.leftEyePosition.x，f.leftEyePosition.y）;
    } 
    if（f.hasRightEyePosition）{
        NSLog（@“右眼％g％g”，f.rightEyePosition.x，f.rightEyePosition.y;
    }

    if（f.hasMouthPosition）{
        NSLog（@“口％g％g”，f.mouthPosition.x，f.mouthPosition.y）;
    }
}
```

`CIDetector`主要提供以下功能：  
* bounds: 面部位置  
* hasFaceAngle: 是否旋转(是否歪头)  
* hasLeftEyePosition: 是否检测到左眼 
* hasRightEyePosition: 是否有右眼 
* hasMouthPosition:  是否有嘴巴  
* hasSmile: 是否检测到笑脸   
* leftEyePosition: 左眼坐标 
* rightEyePosition: 右眼坐标  
* trackingID： 跟踪ID，当应用在视频中时，Core Image 会为检测到的每个人脸设置一个ID用来标记, 当人脸移除检测区域再次进入时，系统会分配另外一个ID  
* trackingFrameCount: 面部出现的帧数   










