# Go Web 表单处理    

Go里面对于form处理已经在Request里面的有专门的form处理，可以很方便的整合到Web开发里面      

关于表单处理需要解决的问题：  

* 如何对用户输入表单进行有效验证？      
* 如何辨别是否是同一个用户？？？  
* 如何保证表单的不重复提交？？？  
* 针对大文件上传？？   



进行表单验证需要先获取表单判断表单提交方式    

~~~  
func login(w http.ResponseWriter, r *http.Request) {
    fmt.Println("method:", r.Method) //获取请求的方法
    if r.Method == "GET" {
        t, _ := template.ParseFiles("login.gtpl")
        t.Execute(w, nil)
    } else {
        //请求的是登陆数据，那么执行登陆的逻辑判断
        r.ParseForm()		//默认不会解析form表单，除非加此句
        fmt.Println("username:", r.Form["username"])
        fmt.Println("password:", r.Form["password"])
    }
}

~~~    
针对处理方式，如果以get请求，那么久显示登录界面，如果是以post请求，进行数据处理    

`r.Form` 中包含所有请求参数，   

注意： 在使用的时候，如果POST 和Get请求的数据冲突了，那么会被保存问一个slice 的   


`request.Form` 是一个url.Values 类型。  存储的是键值对   

> Request本身提供了FormValue() 函数来获取用户提交的参数。调用r.FromValue时会自动调用r.ParseForm,所以不必提前调用。r.FormValue只会返回同名参数中的第一个，若参数不存在则返回空字符串。      

* 验证表单的输入   
	- 必填字段   
		可以通过判断字段的长度来判断字段是否为空    
		
		~~~  
		if len(r.Form["username"][0])==0{
    	//为空的处理
		}
		~~~    
		`r.Form` 对不同类型的表单元素的留空有不同的处理，对文本框、空文本区域、文件上传等元素的值为空值；针对单选复选框则根本不会再r.Form中产生相应条目，需要通过`r.Form.Get()` 来获取     
	- 数字   
		先转化为int类型   
		
		~~~  
		getint, err := strconv.Atoi(r.Form.Get("age"))    
		if err != nil{
			 //数字转化出错了，那么可能就不是数字
		}
		
		//使用正则实现   
		if m, _ := regexp.MatchString("^[0-9]+$", r.Form.Get("age")); !m{
			return false
		}
		~~~   
	- 针对中文验证   
		两种方式，正则和Unicode  
		
		~~~  
		func Is(rangeTab *RangeTable, r rune) bool    
		
		if m, _ := regexp.MatchString("^\\p{Han}+$",r.Form.Get("realname")); !m {
    return false
}
		~~~
	- 英文  
		
		~~~  
		if m, _ := regexp.MatchString("^[a-zA-Z]+$", r.Form.Get("engname")); !m {
    return false
    }
    ~~~   
	
	- 邮箱  
		
		~~~  
		if m, _ := regexp.MatchString(`^([\w\.\_]{2,10})@(\w{1,}).([a-z]{2,4})$`, r.Form.Get("email")); !m {
    fmt.Println("no")
}else{
    fmt.Println("yes")
}
		~~~    
		
	- 手机号  

		~~~  
		if m, _ := regexp.MatchString(`^(1[3|4|5|8][0-9]\d{4,8})$`, r.Form.Get("mobile")); !m {
    return false
}
		~~~   
	- 下拉菜单判断   

		~~~  
		slice:=[]string{"apple","pear","banane"}   
		for _, v := range slice {  
			  if v == r.Form.Get("fruit") {
			  	return true
			  }
		}
		return false  
		~~~    
	- 单选按钮   
		判断值是否是预期的值  
		
		~~~  
		slice:=[]int{1,2}  
		for _, v := range slice {
			 if v == r.Form.Get("gender") {  
			 	 return true
			 }
		}
		return false
		~~~   
	- 复选框    
		
		~~~  
		slice:=[]string{"football","basketball","tennis"} 
		a:=Slice_diff(r.Form["interest"],slice)
		if a == nil{
    		return true
		}
		return  false
		~~~   
	- 日期时间  
		
		~~~  
		t := time.Date(2009, time.November, 10, 23, 0, 0, 0, time.UTC)
		fmt.Printf("Go launched at %s\n", t.Local())
		~~~   
	- 身份证号码  
		
		~~~
		//验证15位身份证，15位的是全部数字 
		if m, _ := regexp.MatchString(`^(\d{15})$`, r.Form.Get("usercard")); !m {
		   return false
		}
		//验证18位身份证，18位前17位为数字，最后一位是校验位，可能为数字或字符X。
		if m, _ := regexp.MatchString(`^(\d{17})([0-9]|X)$`, r.Form.Get("usercard")); !m {
    		return false
		}
		~~~   

* 预防跨站脚本   
	两种方式： 
	- 验证所有输入数据,有效检测攻击   
	- 对所有输出数据进行适当的处理,以防止任何已成功注入的脚本在浏览器端运行。
	go语言针对此处做了转义操作  
	
	~~~  
	func HTMLEscape(w io.Writer, b []byte) //把b进行转义之后写到w
	func HTMLEscapeString(s string) string //转义s之后返回结果字符串
	func HTMLEscaper(args ...interface{}) string //支持多个参数一起转义,返回结果字符串
	~~~   
	
* 防止多次提交表单     
在表单中添加一个带有唯一值得隐藏字段。验证时，先检查带有唯一值得表单是否提交过了
此处采用的是MD5 时间戳，存储到session中暂存   

~~~  
func login(w http.ResponseWriter, r *http.Request) { fmt.Println("method:", r.Method) //获取请求的方法 if r.Method == "GET" {
        crutime := time.Now().Unix()
        h := md5.New()
        io.WriteString(h, strconv.FormatInt(crutime, 10))
        token := fmt.Sprintf("%x", h.Sum(nil))
        t, _ := template.ParseFiles("login.gtpl")
        t.Execute(w, token)
    } else {
//请求的是登陆数据,那么执行登陆的逻辑判断 r.ParseForm()
token := r.Form.Get("token")
if token != "" {
//验证token的合法性
} else { //不存在token报错
}
fmt.Println("username length:", len(r.Form["username"][0]))
fmt.Println("username:", template.HTMLEscapeString(r.Form.Get("username"))) //输出到服务器端 fmt.Println("password:", template.HTMLEscapeString(r.Form.Get("password"))) template.HTMLEscape(w, []byte(r.Form.Get("username"))) //输出到客户端
} }
~~~      

* 文件上传      
表单上传文件需要添加`enctype`属性   
	- application/x-www-form-urlencoded 表示在发送前编码所有字符(默认)  
	- multipart/form-data 不对字符编码。在使用包含文件上传控件的表单时,必须使用该值。  
	- text/plain 空格转换为 "+" 加号,但不对特殊字符编码。    

~~~  
<html>
<head>
<title>上传文件</title> </head>
<body>
<form enctype="multipart/form-data" action="http://127.0.0.1:9090/upload" method="post">
  <input type="file" name="uploadfile" />
  <input type="hidden" name="token" value="{{.}}"/>
  <input type="submit" value="upload" />
</form>
</body>
</html>
~~~

~~~  
http.HandleFunc("/upload", upload)
// 处理/upload 逻辑
func upload(w http.ResponseWriter, r *http.Request) {
fmt.Println("method:", r.Method) //获取请求的方法 
if r.Method == "GET" {
        crutime := time.Now().Unix()
        h := md5.New()
        io.WriteString(h, strconv.FormatInt(crutime, 10))
        token := fmt.Sprintf("%x", h.Sum(nil))
        t, _ := template.ParseFiles("upload.gtpl")
        t.Execute(w, token)
    } else {
		r.ParseMultipartForm(32 << 20)
        file, handler, err := r.FormFile("uploadfile")
        if err != nil {
            fmt.Println(err)
return }
        defer file.Close()
        fmt.Fprintf(w, "%v", handler.Header)
        f, err := os.OpenFile("./test/"+handler.Filename, os.O_WRONLY|os.O_CREATE, 0666)
        if err != nil {
            fmt.Println(err)
return }
        defer f.Close()
        io.Copy(f, file)
    }
}
~~~  
处理文件上传我们需要调用 `r.ParseMultipartForm `里面的参数表示 `maxMemory` ,调 用 ParseMultipartForm 之后,上传的文件存储在 maxMemory 大小的内存里面,如果文件大小超过了 maxMemory ,那么剩下的部分将存储在系统的临时文件中    
我们可以通过 `r.FormFile` 获取上面的文件句柄,然后实例中使 用了 `io.Copy` 来存储文件。    	

>获取其他非文件字段信息的时候就不需要调用 r.ParseForm ,因为在需要的时候Go自动会去调用。而且 tipartForm 调用一次之后,后面再次调用不会再有效果。      

文件上传步骤：  
	1. 表单中增加enctype="multipart/form-data"   
	2.  服务端调用 r.ParseMultipartForm ,把上传的文件存储在内存和临时文件中   
	3. 使用 r.FormFile 获取文件句柄,然后对文件进行存储等处理。   


文件handler 中的信息  
文件handler是multipart.FileHeader    

~~~
type FileHeader struct {
    Filename string
    Header   textproto.MIMEHeader
    // contains filtered or unexported fields
}
~~~   

__模拟客户端上传文件__   

~~~  
package main
import (
    "bytes"
    "fmt"
    "io"
    "io/ioutil"
    "mime/multipart"
    "net/http"
"os" )
func postFile(filename string, targetUrl string) error {
    bodyBuf := &bytes.Buffer{}
    bodyWriter := multipart.NewWriter(bodyBuf)
//关键的一步操作
fileWriter, err := bodyWriter.CreateFormFile("uploadfile", filename) if err != nil {
        fmt.Println("error writing to buffer")
return err }
//打开文件句柄操作
fh, err := os.Open(filename) if err != nil {
        fmt.Println("error opening file")
return err }
    defer fh.Close()
    //iocopy
    _, err = io.Copy(fileWriter, fh)
    if err != nil {
return err }
    contentType := bodyWriter.FormDataContentType()
    bodyWriter.Close()
    resp, err := http.Post(targetUrl, contentType, bodyBuf)
    if err != nil {
return err }
    defer resp.Body.Close()
    resp_body, err := ioutil.ReadAll(resp.Body)
    if err != nil {
return err }
    fmt.Println(resp.Status)
    fmt.Println(string(resp_body))
    return nil
}
// sample usage
func main() {
    target_url := "http://localhost:9090/upload"
    filename := "./astaxie.pdf"
    postFile(filename, target_url)
}
~~~   

可以调用multipart的WriteField方法写很多 其他类似的字段。    




