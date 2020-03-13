## Threading Programming Guide  

## 简介  
线程是在单个应用程序中同时执行多个段代码的方式之一。虽然 `Operation`与 `GCD`提供了更加先进的高效的方式。但OSX和iOS也同时提供了用于创建和管理线程的方式  
> 译者注：其实 GCD 等都是基于线程来实现的  

本文介绍了系统中可用的线程方式以及多线程操作和线程同步之间的结束    
> 译者注： 此部分比较基础，介绍线程基本概念，是接下来的并发编程基础  

## 目录  
* 线程编程
    介绍线程概念以及其在应用程序中的作用  
* 线程管理
    提供了OS X 中的线程技术以及使用方式  
* RunLoops 
    提供管理线程的事件循环处理功能  
* 同步  
    线程同步以及导致的问题  
* 线程安全 
    线程安全的实现以及关键框架介绍 


## 参考 
* 并发编程   


## 说明  
本文档将不是直译源文档，如果感觉不合理的地方，建议查看原文  
* [Threading Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/AboutThreads/AboutThreads.html)
