# MACOS软件安全与逆向分析  



## 第2章 系统安全架构  
#### 系统架构   
1. User Experience  
	用户体验层  
2. Application Framework  
	应用架构层，包括 Cocoa, 用于OSX 系统上应用的开发  
3. Graphics and Media  
	图形和媒体层，   
4. Darwin  
	系统核心层，包括系统内核和shell环境   
#### 针对开发人员的架构  
1. Cocoa Layer:  
	Cocoa 框架层  
2. Foundation Layer  
	基础框架层，同基础的部分功能  
3. Media Layer  
	媒体层， 提供了图像，声音、视频、动画等开发接口  
4. Core Service Layer  
	核心服务层， 提供系统安全、底层、内部数据访问及存储结构  
5. Core OS Layer  
	核心系统层，包括加速器、蓝牙
	异常处理等   
6. Kernel & Driver Layer   
	内核与驱动层   


#### 文件权限  
默认提供了`r 读`, `w 写`, `x 执行` 权限     
提供了 `staff`,`wheel`,`admin`3个用户组      

* staff： 创建用户都属于这个组   
* wheel: 是root用户组，只有 uid 为 0 的root用户才属于这个组  
* admin: 此组用户允许通过 sudo 切换到 root用户



#### 进程间通信  
进程间通信方式： __socket, 管道， 消息队列， 通知，共享内存__  ,其Mac特有的： __mach 端口， 分布式通知， NSConnection, XPC__     

* Mach端口  
	依赖于内核  ， 提供了 `CFMachPort`和`NSMachPort` 进行封装    
	* 消息发送: `mach_msg_send`，参数中指定发送端口号，消息内容及类型   
	* 消息接收: `mach_msg_receive`, 

* 分布式通知     
	接收通知的进程在通知中心注册一个观察者`NSDistributedNotificationCenter` , 被观察的进程发出通知。 __此种方式非常消耗系统资源， 如果需要频繁进行通信，考虑其他方式__     
	
* NSConnection     
	f负责接收处理数据的进程注册一个特定名字的NSConnection, 发送方使用NSConnection类的`rootProxyForConnectionWIthRegisteredName()` 方法找到注册的观察者类，然后通过`performSelector()` 调用该类的数据处理方法 。依赖于OC运行库工作机制  
	

* XPC  
	将APP拆分成多个进程，实现代码逻辑的解耦， 容易开发出插件式的应用。`NSXPCConnection`对象创建XPC 连接，通过`remoteObject` 进行通信； 通过 `NSXPCListener`对象来监听传入的请求

#### 系统安全  
1. CommonCrypto 加密库  
	* 调用`SecEncodeTransformCreate()` 指定加密算法   
	* 调用`SecTransformSetAttribute()` 传入需要处理的数据  
	* 调用`SecTransformExecute()`执行，返回加密后数据  

	```
	CFDataRef dataToEncode = CFDataCreate(
		kCFAllocatorDefault,
		"" 
		strlen("")+ 1
	)
	
	SecTransformRef ref = SecEncodeTransformCreate(kSecBase64Encoding, &error) 
	SecTransformSetAttribute(ref, kSecTransformInputAttributeName, dataToEncode, &error) 
	
	CFDataRef data = SecTransformExecute(ref, & error)
	
	
	```

2. Keychain  
	系统在默认为每个用户创建一个对应的`login.keychain`， 应用程序在创建Keychain 项时，不指定具体的keychain，默认存储在 `login.keychain`中     
	读取keychain中存储的敏感信息  
	`security find-internet-password -a name -s git.oschina.net -g`   
	
	* 存储密码  
		```
		NSMutableDictionary * atts = [NSMutableDictionary dictionary]; 
		
		[atts setObject: kSecClassGenericPassword forKey: kSecClass]; 
		[atts setObject: @"Axxxxx" ForKey: kSecAttrAccount]; 
		[atts setObject: password forKey: kSecValueData]; 
		
		OSStatus error = SecItemAdd(attrs, NULL)
		
		```
		  
	* 读取密码
		
		```
		NSMutableDictionary * atts = [NSMutableDictionary dictionary]; 
		[atts setObject: kSecClassGenericPassword forKey: kSecClass]; 
		[atts setObject@"Axxxxx" forKey: kSecAttrAccount]
		
		OSSTatus error = SecItemCopyMatching(atts, & password)
		```
	
	
3. HTTPS  
	* 预备会话  
		1. 调用`SSLNewContext()`或者`SSLCreateContext()`创建一个加密会话上下文   
		2. 调用`SSLSetIOFuncs()`设置`SSLWrite()`为IO写方法， `SSLRead()`为IO读方法   
		3. 使用CFNetwork, BSD Sockets或Open Transport创建一个连接， 然后调用`SSLSetConnection()` 为连接指定第一步创建的加密会话上下文   
		4. 调用`SSLSetPeerDomainName()`指定端口域名  
		5. 调用`SSLSetCertificate()`指定验证时需要使用的证书， 服务端为必须， 客户端为可选   

	* 开始会话    
		1. 调用`SSLHandshake()`执行SSL的握手与连接    
	* 操作会话  
		安全套接字建立后， 可以传输数据。 可以调用`SSLWrite()`向服务器写数据， 或者调用`SSLRead()`从服务器读取数据   
	* 结束会话  
		1. 调用`SSLClose()`结束安全会话  
		2. 关闭连接并释放连接引用  
		3. 如果使用`SSLNewContext()`创建，调用`SSLDisposeContext()`来销毁连接，如果使用`SSLCreateContext()`则调用`CFRelease()`来释放连接    
		4. 调用`SSLGetPeerCertificates()`获取过任何证书，需要调用`CFRelease()`俩释放  

4. 磁盘加密 File Vault  
	* 旁路攻击  
		目标主体不是磁盘文件，而是操作系统   
	* 内存攻击  
		由于磁盘加密的秘钥存放在系统内核的一块只读区域中， 可以直接从内存中搜索出秘钥   
	* 物理攻击  
		通过特制的硬件设备，直接在开机时攻击磁盘，拿到秘钥  
	

5. 代码签名  
6. ASLR/kASLR  
	* 编译器关闭  
		`xcode ----> Generate Position-Dependent Executable`  
		开启和关闭的区别， 在二进制文件的头信息中会有 `PIE` 标志   
		`otool -hV xxxxx/xxxx/mach_path`
	* 代码关闭     
	
		```
		int main() {
			struct mach_header currentHeader; 
			FILE *fp;  
			
			// 读取文件
			if((fp = fopen(argv[1], "rb+")) == NULL) {
			
			}
			
			// 读取内容
			if(0 == fread(& currentHeader, sizeof(currentHeader),1,fp)) {
			
			}
			
			if(currentHeader.magic == MH_MAGIC || currentHeader.magic == MH_MAGIC_64) {
				currentHeader.flags &= ~MH_PIE;  
				
				fseek(fp, 0, SEEK_SET); 
				if((fwrite(&currentHeader, sizeof(currentHeader),1,fp)) != sizeof(currentHeader)) {
				
				}
				fclose(fp);
				return SUCCESS;
			}
		
		}
		```
	
7. 沙盒  
	* 读取已经签名的沙盒权限`entitlements`信息  
		`codesign -d --entitlements - xxxx.app`

	* 沙盒目录在`~/Library/Containers`， 每个程序有个单独的目录，其中以软连接的形式映射了部分系统目录   
	
	
	
	
	
	
	
## 第四章 软件内幕  
### Mach-O   
1. mach-O文件主要组成部分  
	* mach header  
		基本信息， CPU架构，文件类型以及加载命令等信息  
	* load command  
		描述了文件中数据的具体组织结构，不同的数据类型使用不同的加载命令标识   
	* data
		数据段  

####1. Header  
```
struct mach_header {
	magic 
	cputype 
	cpusubtype 
	filetype 
	ncmds 			// 文件中加载命令的数量  
	sizeofcmds 		// 加载命令所占字节大小  
	flags			// 标识，指明一些标志信息   
}  

struct mach_header_64 {
	magic 
	cputype 
	cpusubtype 
	filetype 
	ncmds 			// 文件中加载命令的数量  
	sizeofcmds 		// 加载命令所占字节大小  
	flags			// 标识，指明一些标志信息    
	reserved			// 系统保留字段  
}  

```

####2. 加载命令   
```
struct load_command {
	cmd 		// 不同类型的加载命令会在此结构体后面加上一个或多个字段来标识特定的结构体信息   
	cmdsize 
}
```

1. 常见的加载命令  
	* LC_SEGMENT  
		段加载命令，需要将它加载到对应的进程空间中       
	* LC_LOAD_DYLIB  
		需要动态加载的链接库 ，结构体如下：  
		
		```
		struct dylib_command {
			cmd; 
			cmdsize;
			struct dylib dylib;
		}
		```  
		当cmd类型为`LC_ID_DYLIB`,`LC_LOAD_DYLIB`,`LC_LOAD_WEAK_DYLIB`,`LC_REEXPORT_DYLIB`统一使用此结构体    		
	* LC_MAIN
		此加载命令记录了可执行文件的`main()` 的位置. 使用 `entry_point_command` 结构体表示   
		
		```
		struct entry_point_command {
			cmd;
			cmdsize;
			entryoff;		// 指定mian 函数的文件偏移 
			stracksize	// 指定了初始堆栈大小  
		}
		```
	* LC_CODE_SIGNATURE  
		代码签名加载命令，描述了代码签名信息，属于链接信息，使用一下结构体标识   
		
		```
		struct linkedit_data_command {
			cmd;
			cmdsize;
			dataoff; 				// 指明了相对于 `__LINKEDIT`段的文件偏移位置  
			datasize;			// 指明了数据的大小  
		}
		```
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	





  
