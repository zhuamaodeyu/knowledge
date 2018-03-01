## AvoidCrash 分析

#框架介绍    
 __此框架是一个崩溃解决方法框架，旨在解决由于使用Cocoa框架中的基本数据类型，导致的崩溃问题__   

## 详细分析   
首先先贴张框架的类结构图吧   
![]()    

###框架简单使用   
1. appdelegate 方法中注册框架     
	
	~~~
		 //启动防止崩溃功能
    [AvoidCrash becomeEffective];   
    	//单独生效
    [NSArray avoidCrashExchangeMethod];
	~~~
2. 注册框架通知方法   
	
	~~~
	  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealwithCrashMessage:) name:AvoidCrashNotification object:nil];    
	~~~    
	
3. 监听通知    
	
	~~~  
	- (void)dealwithCrashMessage:(NSNotification *)note {
    //不论在哪个线程中导致的crash，这里都是在主线程
    
    //注意:所有的信息都在userInfo中
    //你可以在这里收集相应的崩溃信息进行相应的处理(比如传到自己服务器)
    	NSLog(@"\n\n在AppDelegate中 方法:dealwithCrashMessage打印\n\n\n\n\n%@\n\n\n\n",note.userInfo);
	}
	~~~   

###源码分析  
框架主要采用的是runtime的运行时方法交换，将系统的方法进行替换并在替换过后的方法中进行异常的捕获和处理,其核心代码主要在意 `AvoidCrash`类中，其他类的扩展主要是替换系统自带的方法   
  
 
1. `AvoidCrash`   
	此类是框架的主要根类，定义了一些宏定义以及注册方法和公用方法实现   
	其中主要有5 个方法   
	
	* `becomeEffective `  
		此方法采用单利的形式，注册了针对框架中所有的可处理的类，调用方法替换方法，将类中方法替换为自定义方法   
		
		~~~  
		+ (void)becomeEffective {
    		static dispatch_once_t onceToken;
    		dispatch_once(&onceToken, ^{
				[NSObject avoidCrashExchangeMethod];
        		[NSArray avoidCrashExchangeMethod];
        		[NSMutableArray avoidCrashExchangeMethod];
        		.......
			});
		}
		~~~
		
		     
	* 类方法的替换   
		
		~~~
		+ (void)exchangeClassMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel {
    			Method method1 = class_getClassMethod(anClass, method1Sel);
    			Method method2 = class_getClassMethod(anClass, method2Sel);
    			method_exchangeImplementations(method1, method2);
		}		
		~~~
	* 以及对象方法的替换
		
		~~~   
		+ (void)exchangeInstanceMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel {
    		Method originalMethod = class_getInstanceMethod(anClass, method1Sel);
    		Method swizzledMethod = class_getInstanceMethod(anClass, method2Sel);
    		BOOL didAddMethod =
    		class_addMethod(anClass,
                    method1Sel,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    		if (didAddMethod) {
        		class_replaceMethod(anClass,
                            method2Sel,
					method_getImplementation(originalMethod),
					method_getTypeEncoding(originalMethod));
    		}
    		else {
        		method_exchangeImplementations(originalMethod, swizzledMethod);
    		}   
		}
		~~~
	* 获取堆栈主要信息并进行处理     
		
		~~~  
		+ (NSString *)getMainCallStackSymbolMessageWithCallStackSymbols:(NSArray<NSString *> *)callStackSymbols {
    			//mainCallStackSymbolMsg的格式为   +[类名 方法名]  或者 -[类名 方法名]
    			__block NSString *mainCallStackSymbolMsg = nil;
    			//匹配出来的格式为 +[类名 方法名]  或者 -[类名 方法名]
    			NSString *regularExpStr = @"[-\\+]\\[.+\\]";
    			NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:regularExpStr options:NSRegularExpressionCaseInsensitive error:nil];
    			for (int index = 2; index < callStackSymbols.count; index++) {
        			NSString *callStackSymbol = callStackSymbols[index];
        
        			[regularExp enumerateMatchesInString:callStackSymbol options:NSMatchingReportProgress range:NSMakeRange(0, callStackSymbol.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            if (result) {
                NSString* tempCallStackSymbolMsg = [callStackSymbol substringWithRange:result.range];
                
                //get className
                NSString *className = [tempCallStackSymbolMsg componentsSeparatedByString:@" "].firstObject;
                className = [className componentsSeparatedByString:@"["].lastObject;
                
                NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(className)];
                
                //filter category and system class
                if (![className hasSuffix:@")"] && bundle == [NSBundle mainBundle]) {
                    mainCallStackSymbolMsg = tempCallStackSymbolMsg;
                    
                }
                *stop = YES;
            }
        }];
        
        if (mainCallStackSymbolMsg.length) {
            break;
        }
    }   
    return mainCallStackSymbolMsg;
}		
		~~~
		此方法的主要功能是对堆栈信息进行处理和匹配为可用的处理信息   
		
	* 崩溃信息的提示和通知   
		此方法是整个框架最核心的部分，主要就是实现内容的处理并发送通知  
		
		~~~
		+ (void)noteErrorWithException:(NSException *)exception defaultToDo:(NSString *)defaultToDo {
    //堆栈数据
    NSArray *callStackSymbolsArr = [NSThread callStackSymbols];
    //获取在哪个类的哪个方法中实例化的数组  字符串格式 -[类名 方法名]  或者 +[类名 方法名]
    NSString *mainCallStackSymbolMsg = [AvoidCrash getMainCallStackSymbolMessageWithCallStackSymbols:callStackSymbolsArr];
    if (mainCallStackSymbolMsg == nil) {    
        mainCallStackSymbolMsg = @"崩溃方法定位失败,请您查看函数调用栈来排查错误原因";   
    }
    NSString *errorName = exception.name;
    NSString *errorReason = exception.reason;
    //errorReason 可能为 -[__NSCFConstantString avoidCrashCharacterAtIndex:]: Range or index out of bounds
    //将avoidCrash去掉
    errorReason = [errorReason stringByReplacingOccurrencesOfString:@"avoidCrash" withString:@""];
    NSString *errorPlace = [NSString stringWithFormat:@"Error Place:%@",mainCallStackSymbolMsg];
    NSString *logErrorMessage = [NSString stringWithFormat:@"\n\n%@\n\n%@\n%@\n%@\n%@\n\n%@\n\n",AvoidCrashSeparatorWithFlag, errorName, errorReason, errorPlace, defaultToDo, AvoidCrashSeparator];
    AvoidCrashLog(@"%@",logErrorMessage);
    //请忽略下面的赋值，目的只是为了能顺利上传cocoapods
    logErrorMessage = logErrorMessage;
    NSDictionary *errorInfoDic = @{
                                   key_errorName        : errorName,
                                   key_errorReason      : errorReason,
                                   key_errorPlace       : errorPlace,
                                   key_defaultToDo      : defaultToDo,
                                   key_exception        : exception,
                                   key_callStackSymbols : callStackSymbolsArr
                                   };
    //将错误信息放在字典里，用通知的形式发送出去
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:AvoidCrashNotification object:nil userInfo:errorInfoDic];
    });   
}		
		~~~
	
	
	
2. 针对各个类的扩展  
	其扩展中的方法大体就是大同小异的，都是对系统方法的替换，类方法和对象方法    
	其中主要有三种形式：  
		1. 有返回值    
		2. 没有返回值   
		3. 类方法创建对象   
	
	1. 无返回值的  
		
		~~~
		- (void)avoidCrashSetObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    			@try {
        			[self avoidCrashSetObject:obj atIndexedSubscript:idx];
    			}
    			@catch (NSException *exception) {
        			[AvoidCrash noteErrorWithException:exception defaultToDo:AvoidCrashDefaultIgnore];
    			}
    			@finally {       
    			}
		}		
		~~~
	2. 有返回值的对象方法   
		
		~~~
		- (id)avoidCrashObjectAtIndex:(NSUInteger)index {
    		id object = nil;
    		@try {
        		object = [self avoidCrashObjectAtIndex:index];
    		}
    		@catch (NSException *exception) {
        		NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        		[AvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    		}
    		@finally {
        		return object;
    		}
		}
		~~~
	3. 类方法   
		
		~~~    
		+ (instancetype)AvoidCrashArrayWithObjects:(const id  _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt {
    		id instance = nil;
    		@try {
        		instance = [self AvoidCrashArrayWithObjects:objects count:cnt];
    		}
    		@catch (NSException *exception) {
        		NSString *defaultToDo = @"This framework default is to remove nil object and instance a array.";
        		[AvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        		//以下是对错误数据的处理，把为nil的数据去掉,然后初始化数组
        		NSInteger newObjsIndex = 0;
        		//创建新的数组，用来存放
        		id  _Nonnull __unsafe_unretained newObjects[cnt];
        		for (int i = 0; i < cnt; i++) {
            		if (objects[i] != nil) {
                		newObjects[newObjsIndex] = objects[i];
                		newObjsIndex++;
            		}
        		}
        		instance = [self AvoidCrashArrayWithObjects:newObjects count:newObjsIndex];
    		}
    		@finally {
        		return instance;
    		}
		}		
		~~~
	
	
	
	
	 

























