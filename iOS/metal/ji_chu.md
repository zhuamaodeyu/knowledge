# Metal 基础  






## GPU 操作  
Metal 主要利用 GPU 的计算能力，整个 Metal 都围绕在 GPU 上实现。要使用 Metal 框架，首先需要获取到GPU设备。Metal 中使用 `MTLDevice` 协议来代表 GPU设备。在整个应用运行的过程中，与 Metal 交互的所有内容都来自于运行时获取的 `MTLDevice` 。 在 iOS 和 TVOS设备上，只有一个可用的GPU 设备，可以通过以下方式获取：  

```swift 
guard let device = MTLCreateSystemDefaultDevice() else { 
    fatalError( "Failed to get the system's default Metal device." ) 
}
```  
不过在多GPU 设备中(例如： Macbook， iMac)，系统默认使用的是独立 GPU，如果需要操作其他 GPU 