# AVFoundation 之元数据操作  
本节主要讲解AVFoundation中关于资源的元数据信息的操作  
##简介  
上一节主要针对 `AVFoundation`框架进行了总览概况，这是`AVFoundation` 框架详细讲解的第一节，此节主要讲解一些基本知识以及相关的操作，针对后续章节做铺垫作用。 在本章一下内容之前必须先明确一下几个问题  
  
1. 什么是元数据？  
	元数据可以理解为就是资源的基本描述数据， 比如一个视频文件或者音频文件，它的时间，频率，声道等等信息;其也可以表示更加详细的音视频流数据以及字幕等信息  
2. 元数据都包括那些东西？
	元数据个人理解可以分为两种：  
	* 基本元数据  
		基本元数据一般包括资源的时间，频率等基本信息
	* 详细元数据   
		包括资源内部关于容器格式的一些更加详细的信息，比如字幕，以及填写在容器格式内容的一些其他数据  
3. 元数据如何来的以及其作用是什么？   
	元数据最简单的用途就是了解资源文件的基本信息，比如时长， 格式， 图标等信息， 其更加详细的格式内数据确定编解码器以及资源版权等等信息   

在进行具体的元数据操作之前，需要先明确AVFoundation 框架中关于元数据的两个类：  


###AVAsset   
AVAsset 是`AVFoundation` 框架的核心类(此类是个抽象类，并不能进行实例化，其通过URL地址实例化的是它的子类`AVURLAsset`对象), 其框架的所有操作都是围绕此类来展开的。其将媒体资源模块化，对资源文件的信息进行抽象化，由于资源文件存在多种格式以及多种不同参数下的资源文件都存在很大差异，通过`AVAsset`进行封装，将资源文件进行标准化，让整个框架操作更加简洁明确    

####AVAsset 的好处  
1. 框架处理整体化  
2. 简洁化开发，用户不需要考虑多种编码器和容器格式的问题 
3. 隐藏文件的具体路径，通过URL进行初始化资源    


### AVAssetTrack  
AVAssetTrack 是更加详细的媒体元数据类，每一个AVAsset资源中可以对应多个用于描述其更加细致的元数据的`AVAssetTrack `对象 。AVAssetTrack 最常见的形态是音频和视频流，但是其也可以表示文本，副标题以及字幕等媒体类型   


### AVMetadataItem  
提供访问具体资源元数据，可以对存储在格式中的帧中元数据进行访问  

![](http://ozjlhf9e0.bkt.clouddn.com/20180301151989219310666.png)

## 基本操作  
###创建资源  
由于AVFoundation 是一个通用框架，其在iOS平台和Mac OS平台都可以使用，所以在获取资源时，不同的平台有不同的获取方式  

1. iOS Assets库资源  

~~~objectivec
-(void)initAsset
{
    //不过此框架在iOS 9 已经过时了，可以通过 PHPhotoLibrary 框架获取资源，将在后续的章节中可以会讲解
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        //过滤出所有的视频资源
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:0] options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                id representation = [result defaultRepresentation];
                NSURL *url = [representation URL];
                AVAsset *asset = [AVAsset assetWithURL:url];
                
            }
        }];
    } failureBlock:^(NSError *error) {
    }];
}
~~~

__注意:__ 以上方式虽然能实现资源的获取，但是其在iOS9 已经过期，新的系统将采用`PHPhotoLibrary`来进行媒体文件的管理，这个框架在以后会进行单独的讲解


###基本资源属性获取  
AVAsset 中基友多种有用的方法和属性，可以提供有关资源的信息。但是 __AVAsset 采用的是一种高效的设计方法，属性采用的是异步延迟载入资源属性，直到请求时才载入__ , 因为媒体资源的属性很多，这样可以加快创建资源的速度而不用加载很多几乎不会用到的资源属性； 虽然资源属性的回去采用的是异步的方式实现的，但是资源属性的访问却是同步发生的(__就是开发者该真没访问就怎么访问，只是内部数据处理上采用的延迟载入的，造成的结果就是访问速度变慢， 程序会阻塞__)   

* __异步加载实现__  

 AVAsset 和 AVAssetTrack 都实现了异步键值获取协议`AVAsynchronousKeyValueLoading`, 此协议中定义了两个方法  
 
 	~~~objectivec
 	//方法一
 	- (AVKeyValueStatus)statusOfValueForKey:(NSString *)key error:(NSError * _Nullable *)outError;

	//方法二
 	- (void)loadValuesAsynchronouslyForKeys:(NSArray<NSString *> *)keys completionHandler:(void (^)(void))handler;
 	~~~
	__说明:__  
 		* 方法1会返回一个状态，标识当前属性所处的状态, 从状态名和定义上可以看出只有在是`AVKeyValueStatusLoaded`时才可以直接使用，否则都将造成延迟      
 		* 方法二就是异步获取属性的定义方法，通过给定keys来获取对应的值  

 	~~~objectivec
 	    NSArray *keys = @[@"tracks"];
    __weak __typeof(self) weakSelf = self;
    [self.asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSError *error = nil;
        
      AVKeyValueStatus status =  [weakSelf.asset statusOfValueForKey:@"tracks" error:&error];
        switch (status) {
            case AVKeyValueStatusFailed:
            case AVKeyValueStatusUnknown:
            case AVKeyValueStatusCancelled:
            case AVKeyValueStatusLoading:
                NSLog(@"值获取异常或者还没有获取，此时操作将造成延迟");
                break;
            case AVKeyValueStatusLoaded:
                NSLog(@"值已经获取完毕，可以直接使用");
                break;
            default:
                break;
        }
    }];
 	~~~
 	__说明:__  
 	* 注意其中的keys 数组，其中放的是`AVAsset`对象中属性名称，当获取多个属性时，需要针对每个属性进行单独验证状态(block中的代码需要些多份)   
 	* block会在任意队列进行调用，如果要更新UI的话，必须要回到主队列上   
 	
 	> 这里有一个简洁的方式获取属性值，从开始处可以找到AVAsset是一个抽象类，其创建的是一个子类	AVURLAsset类，此类的初始化方法带有一个options属性，可以通过此种方式实现   
 	> NSDictionary *dic = @{
    >                AVURLAssetPreferPreciseDurationAndTimingKey: @(YES),
    >                AVURLAssetReferenceRestrictionsKey:@(1)
                          };
	> AVAsset *asset = [AVURLAsset URLAssetWithURL:nil options:dic];  


###元数据  
#### 元数据的格式以及其特点  
元数据的格式存在多种多样的，但是在Apple环境下，一般存在以下4种： 
 
* QuickTime  
	是苹果自己的开发的媒体架构，跨平台，文件格式为 `.mov` 格式，采用的是atoms的数据结构组成  
	可以通过十六进制编辑器打开此种文件查看器内容,可以使用官方程序`Atom Inspector`来查看  
	![利用QuickTime录制视频的信息](http://ozjlhf9e0.bkt.clouddn.com/20180301151989223272311.png)  
	如果想对这些数据更加细致的了解的，请查看苹果官方文档关于此内容的部分  
* MPEG-4 音视频 (这个是两种哦)
	* MPEG-4 video  
	* MPEG-4 audio
   此文件格式与 QuickTime 相类似，因为它基于QuickTime来的。 此种文件存在多种文件后缀m4v,m4a,m4p,m4b等格式
* MP3   
	MP3使用的是音频编码的形式，不是使用容器格式。一些元数据位于文件的头部  
	注意: AVFoundation 支持数据的读，但不支持写操作(MP3版权问题)  
	
#### 元数据的获取  
在进行元数据获取时， 实现了更加精准的获取，对元数据进行了分类。当获取比如歌手，插图信息等资源时，可以通过`commonMetadata`属性获取，但是当获取指定格式的元数据时可以通过`metadataForformat`方法获取   

~~~objectivec
 NSArray *keys = @[@"availableMetadataFormats"];
    __weak __typeof(self) weakSelf = self;
    [self.asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSMutableArray *metadata = @[].mutableCopy;
        for (NSString *formate in weakSelf.asset.availableMetadataFormats) {
            //此处获取的是一个 AVMetadataItem 数组
            [metadata addObjectsFromArray:[weakSelf.asset metadataForFormat:formate]];
        }
    }];
~~~
通过以上方式获取所有的元数据  
以下是我获取的一个MP3格式的歌曲的信息 
![资源文件类型](http://ozjlhf9e0.bkt.clouddn.com/20180301151989225051143.png)  
![基本AVMetadataItem元数据](http://ozjlhf9e0.bkt.clouddn.com/20180301151989226069702.png)
![全部AVMetadataItem元数据](http://ozjlhf9e0.bkt.clouddn.com/2018030115198922726594.png) 


#### 查找对应的元数据  
虽然通过以上的方式获取到了元数据，如何查找到自己需要的元数据?  
通过以上的查找可以确定查找出来的元素都是`AVMetadataItem`类型的对象，那么获取就在这个里边啦 ，查看头文件发现这个类也实现了`AVAsynchronousKeyValueLoading`异步获取。哈哈 怪不得上图中看到有些属性的值为 null 呢  

在`AVMetadataItem`头文件中可以找到答案. Apple已经对常用的Languages以及ID 做了指定的方法，其他的就可以通过`AVMetadataItemFilter`类的`+ (NSArray<AVMetadataItem *> *)metadataItemsFromArray:(NSArray<AVMetadataItem *> *)metadataItems withKey:(nullable id)key keySpace:(nullable NSString *)keySpace;`方法可以实现， 但是 ， 啊哈哈 其中的参数从哪里来的 ，好像没有说清楚(有哪位同仁知道的麻烦告知下，在这里先谢过了)。不过这里提示可以使用`+ (NSArray<AVMetadataItem *> *)metadataItemsFromArray:(NSArray<AVMetadataItem *> *)metadataItems filteredByIdentifier:(NSString *)identifier`方法  
   
> 补充： 此处的参数可以在`AVMetadataFormat.h`头文件中找到  


#### 修改元数据  
修改元数据使用`AVMetadataItem`对应的一个可变类`AVMutableMetadataItem`来实现   




#### 保存元数据  
虽然通过以上的方式可以实现元数据的修改和查找，但是保存就比较特殊， 保存并不是保存元数据，而是需要将整个 `AVAsset`资源重置一份， 因为此类是一个不可变类，不能通过简单的方式实现， AVFoundation框架谓词提供了一个专门的类 `AVAssetExportSession` 用于从一个 AVAsset资源到另一个 AVAsset资源的转变  

![](http://ozjlhf9e0.bkt.clouddn.com/20180301151989228427649.png)  

~~~objectivec
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:self.asset presetName:AVAssetExportPresetPassthrough];
    session.outputURL = @"";			//输出地址
    session.outputFileType = @"";		//输出的类型
    session.metadata = @[];			//metadata元数据数组
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus  status = session.status;			//导出状态
        switch (status) {
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"导出成功");
                break;
                
            default:
                break;
        }
    }];
~~~
__说明:__
	通过以上的方式可以实现AVAsset资源到另一个 AVAsset资源的转变， 可以实现修改元数据， 转码等等操作  
	特别注意的是`presetName`参数的值，值不同，可进行操作的权限就不同，此处采用的值确实允许修改一些元数据，但是不能添加新的元数据(使用转码预设值来实现添加)  




## 总结   
通过以上的学习，可以多 AVFoundation框架又一个大致的了解， 以上只是对资源对象的简单介绍，其各种不同资源类型还有更多的详细内容和具体的代表含义，这个需要对不同类型格式进行更加详细的学习，不在系列文章学习范围内，如果想学，可以自己查找对应格式的详细说明手册 。  

   
再一个针对元数据的说明：  
个人理解就是所有的和资源文件相关的比如时间,icon,发行商，版权等等信息都可以统称为元数据，元数据可以理解为是一个抽象概念，并不是一个具体的概念，在此处元数据可以指`AVAsset`对象中的部分属性以及`AVAssetTrack`对象和`AVMetadataItem`的数据    

__以上内容只是个人针对这块的一些拙见，如果有不对的地方，还请指出.__       
###可以通过以下邮箱联系我`playtomandjerry@gmail.com`

#     共勉  学习   

