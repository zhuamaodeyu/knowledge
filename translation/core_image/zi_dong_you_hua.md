# 自动优化图像  

Core Image 自动检测功能可以分析图像的直方图,面部区域和元数据信息，然后，给出一个 `CIFilter`数组,其输入参数已经自动设置为可改善分析图像的值。    


## 自动优化支持滤镜   

过滤器              | 作用
----                | ---
CIRedEyeCorrection | 修复由相机闪光灯导致的红眼，琥珀眼，白眼等  
CIFaceBalance        |  调整面部颜色，使肤色更光滑明亮  
CIVibrance          | 增强色彩饱和度  
CIToneCurve         | 调整对比度  
CIHighlightShadowAdjust | 阴影处理   



## 使用自动优化过滤器  
自动优化主要涉及两个API 方法`autoAdjustmentFilters` 和 `autoAdjustmentFiltersWithOptions:`,一般需要提供字典参数   

可以配置一下设置项： 
* 图像方向， 对于 `CIRedEyeCorrection` 和 `CIFaceBalance` 滤镜很重要，Core Image 需要准确找到面部   
* 是否应用红眼校正 (`kCIImageAutoAdjustEnhance`参数为 false)   
* 是否应用出红颜外的所有滤镜效果(设置`kCIImageAutoAdjustRedEye` 为 false)

`autoAdjustmentFiltersWithOptions:`方法返回一个过滤器数组，可以将这些过滤器应用在现有的过滤器链上     

```
// 1
NSDictionary * options = @ {CIDetectorImageOrientation：
                 [[image properties] valueForKey：kCGImagePropertyOrientation]};
// 2
NSArray * adjustment = [myImage autoAdjustmentFiltersWithOptions：options];
// 3
for（CIFilter  *filter in adjustments）{
     [filter setValue：myImage forKey：kCIInputImageKey];
     myImage = filter.outputImage;
}
```

Core Image 自动设置了最佳参数，此处可以不必立即应用这些过滤器，可以将这些过滤器名称和参数保存起来以供日后使用，保存这些过滤器可以稍后执行优化，不需要再次针对图像进行分析     

## 总结  
1. `autoAdjustmentFilters` 方法返回所有可应用的自动优化过滤器  
2. `autoAdjustmentFiltersWithOptions`返回应用过后的过滤器列表，带有最佳优化值   





