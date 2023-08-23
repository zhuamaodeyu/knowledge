# About Metal  

Metal 框架支持GPU加速，3D图形渲染以及以及数据并行计算。  Matel 提供了现代化来的API接口， 用来简单化操作图形处理以及进行并行计算任务，并且针对其相关数据和资源进行管理。Metal 主要目标就是最大化利用GPU，最小化利用CPU 。  




## 前言 
本文主要描述了Metal 的基本概念： 命令提交模型， 内存管理模型以及图形着色器和数据并行计算功能(给出示例代码)。该文档详细说明了如何使用 Metal API 编写应用程序。主要包含以下几部分： 
* `Fundamental Metal Concepts` : 简要描述了Metal 的主要特征  
* `Command Organization and Execution Model` : 介绍了如何创建命令并将其提交到 GPU 执行
* `Resource Objects: Buffers and Textures` : 介绍了内存管理，包括 GPU 内存缓冲区和纹理对象  
* `Functions and Libraries` : 介绍了如何在metal程序中编写 Metal 着色语言代码，以及如何将其加载到GPU 上并运行  
* `Graphics Rendering: Render Command Encoder` : 描述了如何渲染3D图形，包括如何多个线程图形操作。
* `Data-Parallel Compute Processing: Compute Command Encoder ` : 介绍了数据并行处理。
* `Buffer and Texture Operations: Blit Command Encoder` : 介绍了纹理和缓冲区之间数据复制。
* `Metal Tools` : 列出了可用的自定义和改进开发工作流程的工具。
* `Metal Feature Set Tables` : 列出了每个Metal功能点详细介绍
* `What's New in iOS and OS X` : 总结了对应系统引入的新功能
* `` : 
* `Tessellation` : describes the Metal tessellation pipeline used to tessellate a patch, including the use of a compute kernel, tessellator, and post-tessellation vertex function
* `Resource Heaps` : 描述了如何从内存分配资源，并进行内存跟踪    

### 要求 
应该熟悉Objective-C语言，并且熟悉OpenGL，Op​​enCL或类似API的编程


## 简介  
Metal 为图形和数据并行计算提供简单，统一的接口。Metal 可以更有效的集成图形和计算任务，无需使用单独的API和着色器语言     
Metal 主要提供一下内容： 
* 高效接口：Metal旨在消除“隐藏”性能瓶颈，例如隐式状态验证。可以支持 GPU 的异步操作，实现多线程并行创建和提交命令运行   
* 内存和资源管理：描述了缓冲和纹理对象代表了GPU的内存分配。纹理对象有特定的像素格式，并可用于纹理图像或附件对象    
* 图形和计算操作： Metal为图形和并行计算创建了统一的数据结构和资源对象(例如：缓冲区，纹理，命令队列)。Metal着色语言支持图形和计算功能。Metal框架允许在runtime，图形着色器和计算功能之间共享资源。
* 预编译着色器： 在编译期进行程序代码以及 着色器代码编译， 在运行时加载运行。 (_支持着色器代码运行时编译_)  


__Metal 应用程序无法在后台执行Metal命令，并且系统会终止尝试此操作的Metal应用程序。__   

## 其他参考  
* [Metal Framework Reference](https://developer.apple.com/documentation/metal)
    描述了Metal框架中的接口 
* [Metal Shading Language Specification](https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf) 
    着色器语言  

