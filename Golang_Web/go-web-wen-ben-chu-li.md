# Go Web 文本处理   
文本处理设计到的有  XML ， JSON , 正则表达式， template    

## XML 处理  

XML 解析    

~~~  
package main
import (
   "encoding/xml"
	"fmt"
	"io/ioutil"
	"os" 
	)
	
 type Recurlyservers struct {
     XMLName     xml.Name `xml:"servers"`
     Version     string   `xml:"version,attr"`
     Svs         []server `xml:"server"`
     Description string   `xml:",innerxml"`
}
 type server struct {
     XMLName    xml.Name `xml:"server"`
     ServerName string   `xml:"serverName"`
     ServerIP   string   `xml:"serverIP"`
}
 func main() {
     file, err := os.Open("servers.xml") // For read access.
     if err != nil {
         fmt.Printf("error: %v", err)
return }
     defer file.Close()
     data, err := ioutil.ReadAll(file)
     if err != nil {
         fmt.Printf("error: %v", err)
return }
     v := Recurlyservers{}
     err = xml.Unmarshal(data, &v)
     if err != nil {
         fmt.Printf("error: %v", err)
return }
    fmt.Println(v)
    }

~~~
代码解析：   
XML的解析是通过`xml.Unmarshal` 函数来完成的    
`xml:"serverName"` : 此部分是struct的特性，被称为struct tag， 用来辅助反射     
此函数可以讲XML映射为 struct、slice、string 类型   
在解析XML的时候，首选读取struct tag， 如果没有，对应字段名

> 为了正确解析,go语言的xml包要求struct定义中的所有字段必须是可导出的(即首字母大写)
     

#### 生成XML    

~~~  
func Marshal(v interface{}) ([]byte, error)
func MarshalIndent(v interface{}, prefix, indent string) ([]byte, error)
~~~   

关于生成XML的规则：   

* 如果V 是array或者slice, 那么输出每个元素   
* 如果v是指针，那么会Marshal指针指向的内容， 如果指针为空， 什么都不输出   
* 如果v是interface， 那么久处理interface所包含的数据   
* 如果v是其他数据类型， 就会输出这个数据类型所拥有的字段信息   

   
     
     
     
## JSON 处理  

## 正则处理   

## 模板处理   

## 文件操作   

## 字符串处理   


