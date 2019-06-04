#Go Web  国际化    

## 设置默认区域  
####Locale 
Locale是一组描述世界上某一特定区域文本格式和语言习惯的设置的集合。  
1. 是一个强制性的,表示语言的缩写   
2. 跟在一个下划线之 后,是一个可选的国家说明符,用于区分讲同一种语言的不同国家   
3. 跟在一个句点之后,是可选的字符集说明符.例如"zh_CN.gb2312"表示中国使用gb2312 字符集。   

* 设置Locale   
	1. 通过域名设置Locale    
		• 通过URL就可以很明显的识别     
		• 用户可以通过域名很直观的知道将访问那种语言的站点      
		• 在Go程序中实现非常的简单方便,通过一个map就可以实现     
		• 有利于搜索引擎抓取,能够提高站点的SEO     
		
		```  
		 if r.Host == "www.asta.com" {
     		i18n.SetLocale("en")
 		  } else if r.Host == "www.asta.cn" {
     		i18n.SetLocale("zh-CN")
         } else if r.Host == "www.asta.tw" {
     		i18n.SetLocale("zh-TW")
		  }
		  //通过子域名实现  
		  prefix := strings.Split(r.Host,".")
 			if prefix[0] == "en" {
     			i18n.SetLocale("en")
 			} else if prefix[0] == "cn" {
     			i18n.SetLocale("zh-CN")
 			} else if prefix[0] == "tw" {
     			i18n.SetLocale("zh-TW")
			}
		```

	2. 通过参数实现   
	3. 客户端设置   
		`Accept-Language`  
		
		```  
		AL := r.Header.Get("Accept-Language")
		if AL == "en" {
     		i18n.SetLocale("en")
 		} else if AL == "zh-CN" {
     		i18n.SetLocale("zh-CN")
 		} else if AL == "zh-TW" {
     		i18n.SetLocale("zh-TW")
 		}
		```

##本地化资源   
Go语言中将本地化格式信息存储子啊json中， 然后通过核实的方式展现出来    

* 本地化文本消息   
	建立需要的语言的map来维护一个key-value的关系   
	
	```  
	import "fmt"
		var locales map[string]map[string]string
		func main() {
			locales = make(map[string]map[string]string, 2) en := 			make(map[string]string, 10)
			en["pea"] = "pea"
			en["bean"] = "bean"
			locales["en"] = en
			cn := make(map[string]string, 10)
			cn["pea"] = "豌豆"
			cn["bean"] = "毛豆"
			locales["zh-CN"] = cn
			lang := "zh-CN"
			fmt.Println(msg(lang, "pea")) fmt.Println(msg(lang, "bean"))
		}
		
		func msg(locale, key string) string {
    		if v, ok := locales[locale]; ok {
        		if v2, ok := v[key]; ok {
            		return v2
				}
			}
			return ""
		}
	```

* 本地化日期和时间   
	本地化日期时间需要考虑两个问题：  
		- 时区问题  
		- 格式问题   
	在go语言中，`$GOROOT/lib/time` 中的timeinfo.zip 包含有locale对应的时区定义   
	为了获得对应于当前locale的时间,我们 应首先使用 `time.LoadLocation(name string)` 获取相应于地区的locale  ，然后再利用此信息与调用 `time.Now` 获得的Time对象协作来获得最终的时间     
	
	```  
	en["time_zone"]="America/Chicago"
	cn["time_zone"]="Asia/Shanghai"
	loc,_:=time.LoadLocation(msg(lang,"time_zone"))
	t:=time.Now()
	t = t.In(loc)
	fmt.Println(t.Format(time.RFC3339))
	```

* 本地化视图资源  
	
	将文件进行locale区分    
	
	```
	s1, _ := template.ParseFiles("views"+lang+"index.tpl")   
	VV.Lang=lang   
	s1.Execute(os.Stdout, VV)    
	
	// js文件
	<script type="text/javascript" src="views/{{VV.Lang}}/js/jquery/jquery-1.8.0.min.js"></script>    
	<link href="views/{{VV.Lang}}/css/bootstrap-responsive.min.css" rel="stylesheet">     
	<img src="views/{{VV.Lang}}/images/btn.png"> 
	```

##国际化站点  

为了支持国际化,在此我们使用了一个国际化相关的包——go-i18n   
首先我们向go-i18n包注册config/locales 这个目录,以加载所有的locale文件   

```  
Tr:=i18n.NewLocale()
Tr.LoadPath("config/locales")    

//测试
fmt.Println(Tr.Translate("submit")) //输出Submit
Tr.SetLocale("zn")
fmt.Println(Tr.Translate("submit")) //输出“递交”

```



* 自动加载本地包    

``` 
//加载默认配置文件,这些文件都放在go-i18n/locales下面
//文件命名zh.json、en-json、en-US.json等,可以不断的扩展支持更多的语言
func (il *IL) loadDefaultTranslations(dirPath string) error {
    dir, err := os.Open(dirPath)
    if err != nil {
return err }
    defer dir.Close()
    names, err := dir.Readdirnames(-1)
    if err != nil {
return err }
    for _, name := range names {
        fullPath := path.Join(dirPath, name)
        fi, err := os.Stat(fullPath)
        if err != nil {
return err 
}
 if fi.IsDir() {
            if err := il.loadTranslations(fullPath); err != nil {
return err }
        } else if locale := il.matchingLocaleFromFileName(name); locale != "" {
            file, err := os.Open(fullPath)
            if err != nil {
return err }
            defer file.Close()
            if err := il.loadTranslation(file, locale); err != nil {
			return err 
			}
		}
 	}
return nil 
}
```

通过上面的方法加载配置信息到默认的文件,这样我们就可以在我们没有自定义时间信息的时候执行如下的代码   

```
//locale=zh的情况下,执行如下代码:
fmt.Println(Tr.Time(time.Now())) //输出:2009年1月08日 星期四 20:37:58 CST
fmt.Println(Tr.Time(time.Now(),"long")) //输出:2009年1月08日
fmt.Println(Tr.Money(11.11)) //输出:¥11.11   
```


* template mapfunc   
Go语言的模板支持自定义模板函数,下面是我们实现的方便操作的mapfunc:    

	- 文本信息  

	```  
	func I18nT(args ...interface{}) string {
    ok := false
    var s string
    if len(args) == 1 {
        s, ok = args[0].(string)
    }
    if !ok {
        s = fmt.Sprint(args...)
	}
	return Tr.Translate(s)
 	}
	```

	注册函数 ：  
	`t.Funcs(template.FuncMap{"T": I18nT})`  
	模板使用：  
	`{{.V.Submit | T}}`    
	
	- 时间日期  
	
	```  
	 func I18nTimeDate(args ...interface{}) string {
     ok := false
     var s string
     if len(args) == 1 {
         s, ok = args[0].(string)
     }
     if !ok {
         s = fmt.Sprint(args...)
}
     return Tr.Time(s)
 }
	```
	
	注册函数：  
	`t.Funcs(template.FuncMap{"TD": I18nTimeDate})`    
	模板使用：  
	`{{.V.Now | TD}}`    
	
	- 货币信息  
		
	``` 
	 func I18nMoney(args ...interface{}) string {
     ok := false
     var s string
     if len(args) == 1 {
         s, ok = args[0].(string)
     }
     if !ok {
         s = fmt.Sprint(args...)
         }
     return Tr.Money(s)
 	}
	``` 

	注册函数：  
	`t.Funcs(template.FuncMap{"M": I18nMoney})`   
	模板使用：  
	`{{.V.Money | M}}`   
	














