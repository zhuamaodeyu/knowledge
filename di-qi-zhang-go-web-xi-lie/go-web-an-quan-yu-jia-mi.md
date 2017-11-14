# Go Web 安全与加密

**对于用户的输入数据,在对其进行 验证之前都应该将其视为不安全的数据**  
如果直接把这些不安全的数据输出到客户端,就可能造成跨站脚本攻 击\(XSS\)的问题

## 预防CSRF攻击

CSRF\(Cross-site request forgery\),中文名称:跨站请求伪造,也被称为:one click attack/session ridi ng,缩写为:CSRF/XSRF。

对终端用户的数据和操作指令构成严重的威胁;当受攻击的终端用户具有管理员帐户的 时候,CSRF攻击将危及整个Web应用程序。

完成此攻击需要满足的条件：  
1. 登录受信任网站A,并在本地生成Cookie 。  
2. 在不退出A的情况下,访问危险网站B。

防止方式：

1. 正确使用GET,POST和Cookie;     
    get 只用来读取， post用来操作数据      
2. 在非GET请求中增加伪随机数;    
   * 为每个用户生成一个唯一的cookie token， 所有表单都包含同一个伪随机值  
   * 每个请求使用验证码,这个方案是完美的,因为要多次输入验证码,所以用户友好性很差     
   * 不同的表单包含一个不同的伪随机值    

```go
 h := md5.New()
 io.WriteString(h, strconv.FormatInt(crutime, 10))
 io.WriteString(h, "ganraomaxxxxxxxxx")
 token := fmt.Sprintf("%x", h.Sum(nil))
 t, _ := template.ParseFiles("login.gtpl")
 t.Execute(w, token)


  r.ParseForm()
 token := r.Form.Get("token")
 if token != "" {
//验证token的合法性 } else {
//不存在token报错 }
```

## 确保输入过滤

通过对所有的输入数据进行过滤,可以避免恶 意数据在程序中被误信或误用

1. 识别数据,搞清楚需要过滤的数据来自于哪里  
   Go中对于用户输入的数据很好识别：Go通过`r.ParseForm`之后,把用户POST和GET的数据全部放在了`r.Form` 里面  
   `r.Header` 中的而很多数据是客户端操作的  
   最好的方式是将所有的数据看成是用户输入的

2. 过滤数据,弄明白我们需要什么样的数据  
   过滤数据的一些库：

   * `strconv`zi符串转化相关函数  
   * string  
   * regexp

区分过滤数据  
把所有经过过滤的数据放入一个 叫全局的Map变量中\(CleanMap\)。这时需要用两个重要的步骤来防止被污染数据的注入:

* 每个请求都要初始化C leanMap为一个空Map。 
* 加入检查及阻止来自外部数据源的变量命名为CleanMap。    

```
<form action="/whoami" method="POST"> 我是谁:
    <select name="name">
        <option value="astaxie">astaxie</option>
        <option value="herry">herry</option>
        <option value="marry">marry</option>
</select>
    <input type="submit" />
</form>

//白名单验证
r.ParseForm()
name := r.Form.Get("name")
CleanMap := make(map[string]interface{}, 0)
if name == "astaxie" || name == "herry" || name == "marry" {
    CleanMap["name"] = name
}

r.ParseForm()
 username := r.Form.Get("username")
 CleanMap := make(map[string]interface{}, 0)
 if ok, _ := regexp.MatchString("^[a-zA-Z0-9].$", username); ok {
     CleanMap["username"] = username
 }
```

1. 区分已过滤及被污染数据,如果存在攻击数据那么保证过滤之后可以让我们使用更安全的数据

## 避免XSS攻击

跨站脚本攻击\(Cross-Site Scripting\)  
XSS是一种常见的web安全漏洞,它允许攻击者将恶意代码植入到提供给其它 用户使用的页面中。  
XSS的攻击目标是为了盗取存储在客户端的cookie或者其他网站用于识别客户端身份的敏感信息。

* 一类是存储型XSS,主要出现在让用户输入数据,供其他浏览此页的用户进行查看的地 方,包括留言、评论、博客日志和各类表单等    
* 另一类是反射型XSS,主要做法是将脚本代码加入URL地址的 请求参数里,请求参数进入程序后在页面直接输出,用户点击类似的恶意链接就可能受到攻击。    

**攻击目的和手段**：

• 盗用cookie,获取敏感信息。  
• 利用植入Flash,通过crossdomain 限设置进一步获取更高 限;或者利用Java等得到类似的操作。  
• 利用iframe、frame、XMLHttpRequest或上述Flash等方式,以\(被攻击者\)用户的身份执行一些管理动 作,或执行一些如:发微博、加好友、发私信等常规操作,前段时间新浪微博就遭遇过一次XSS。  
• 利用可被攻击的域受到其他域信任的特点,以受信任来源的身份请求一些平时不允许的操作,如进行不当的 投票活动。  
• 在访问量极大的一些页面上的XSS可以攻击一些小型网站,实现DDoS攻击的效果

**防止手段**：

• 过滤特殊字符  
避免XSS的方法之一主要是将用户所提供的内容进行过滤,Go语言提供了HTML的过滤函数:  
text/template包下面的HTMLEscapeString、JSEscapeString等函数  
• 使用HTTP头指定类型  
这样就可以让浏览器解析javascript代码,而不会是html输出。

## 避免SQL注入

可以用它来从数据库获取 敏感信息,或者利用数据库的特性执行添加用户,导出文件等一系列恶意操作,甚至有可能获取数据库乃至系统 用户最高 限。

**原因**： 是因为程序没有有效过滤用户的输入,使攻击者成功的向服务器提交恶意的SQL查询代 码,程序在接收后错误的将攻击者的输入作为查询语句的一部分执行,导致原始的查询逻辑被改变,额外的执行 了攻击者精心构造的恶意代码。

```go
username:=r.Form.Get("username")
password:=r.Form.Get("password")
sql:="SELECT * FROM user WHERE username='"+username+"' AND password='"+password+"'"   

如果用户输入的是一下用户名  
myuser' or 'foo' = 'foo' --   
SELECT * FROM user WHERE username='myuser' or 'foo'=='foo' --'' AND password='xxx'  

 -- 是注释标记,所以查询语句会在此中断
```

**预防SQL注入**

1. 严格限制Web应用的数据库的操作 限,给此用户提供仅仅能够满足其工作的最低 限,从而最大限度的减少 注入攻击对数据库的危害。
2. 检查输入的数据是否具有所期望的数据格式,严格限制变量的类型,例如使用regexp包进行一些匹配处 理,或者使用strconv包对字符串转化成其他基本类型的数据进行判断。
3. 对进入数据库的特殊字符\('"\尖括号&\*;等\)进行转义处理,或编码转换。Go 的 text/template 包里面的 HT MLEscapeString 函数可以对字符串进行转义处理。
4. 所有的查询语句建议使用数据库提供的参数化查询接口,参数化的语句使用参数而不是将用户输入变量嵌入 到SQL语句中,即不要直接拼接SQL语句。例如使用 database/sql 里面的查询函数 Prepare 和 Query ,或者 E xec\(query string, args ...interface{}\) 。
5. 在应用发布之前建议使用专业的SQL注入检测工具进行检测,以及时修补被发现的SQL注入漏洞。网上有很多 这方面的开源工具,例如sqlmap、SQLninja等。
6. 避免网站打印出SQL错误信息,比如类型错误、字段不匹配等,把代码里的SQL语句暴露出来,以防止攻击者 利用这些错误信息进行SQL注入。

## 存储密码

1. 单向hash算法    
   常用的有HA-256, SHA-1, MD5等   

```go
//import "crypto/sha256"
h := sha256.New()
io.WriteString(h, "His money is twice tainted: 'taint yours and 'taint mine.")
fmt.Printf("% x", h.Sum(nil))
//import "crypto/sha1"
h := sha1.New()
io.WriteString(h, "His money is twice tainted: 'taint yours and 'taint mine.")
fmt.Printf("% x", h.Sum(nil))
//import "crypto/md5"
h := md5.New()
io.WriteString(h, "需要加密的密码") fmt.Printf("%x", h.Sum(nil))
```

加盐hash算法

```go
//import "crypto/md5" //假设用户名abc,密码123456
h := md5.New()
io.WriteString(h, "需要加密的密码")
//pwmd5等于e10adc3949ba59abbe56e057f20f883e pwmd5 :=fmt.Sprintf("%x", h.Sum(nil))
//指定两个 salt: salt1 = @#$% salt1 := "@#$%"
salt2 := "^&*()"
//salt1+用户名+salt2+MD5拼接 io.WriteString(h, salt1) io.WriteString(h, "abc") io.WriteString(h, salt2) io.WriteString(h, pwmd5)
salt2 = ^&*()
last :=fmt.Sprintf("%x", h.Sum(nil))
```

1. 故意增加密码计算所需耗费的资 源和时间
   故意增加密码计算所需耗费的资 源和时间,使得任何人都不可获得足够的资源建立所需的 rainbow table 。     
   `scrypt`:scrypt是由著名的FreeBSD黑客Colin Percival为他的备份服务Tarsnap开发的   

`http://code.google.com/p/go/source/browse?repo=crypto#hg%2Fscrypt`

`dk := scrypt.Key([]byte("some password"), []byte(salt), 16384, 8, 1, 32)`

1. 简单数据 ---- base64 加密   

```go
package main
import (
    "encoding/base64"
    "fmt"
)
func base64Encode(src []byte) []byte {
    return []byte(base64.StdEncoding.EncodeToString(src))
}
func base64Decode(src []byte) ([]byte, error) {
    return base64.StdEncoding.DecodeString(string(src))
}
func main() {
    // encode
hello := "你好,世界! hello world" debyte := base64Encode([]byte(hello)) fmt.Println(debyte)
// decode
    enbyte, err := base64Decode(debyte)
    if err != nil {
        fmt.Println(err.Error())
    }
    if hello != string(enbyte) {
        fmt.Println("hello is not equal to enbyte")
    }
    fmt.Println(string(enbyte))
}
```

1. 高级加密    

Go语言的 crypto 里面支持对称加密的高级加解密包有:

1. crypto/aes 包:AES\(Advanced Encryption Standard\),又称Rijndael加密法,是美国联邦政府采用的一种 区块加密标准。     
2. crypto/des 包:DES\(Data Encryption Standard\),是一种对称加密标准,是目前使用最广泛的密钥系 统,特别是在保护金融数据的安全中。曾是美国联邦政府的加密标准,但现已被AES所替代。     

```go
package main
import (
    "crypto/aes"
    "crypto/cipher"
    "fmt"
    "os"
)
var commonIV = []byte{0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d,0x0e, 0x0f}
func main() {
//需要去加密的字符串
plaintext := []byte("My name is Astaxie") //如果传入加密串的话,plaint就是传入的字符串 if len(os.Args) > 1 {
        plaintext = []byte(os.Args[1])
    }
    //aes的加密字符串
key_text := "astaxie12798akljzmknm.ahkjkljl;k" if len(os.Args) > 2 {
        key_text = os.Args[2]
    }
    fmt.Println(len(key_text))
// 创建加密算法aes
c, err := aes.NewCipher([]byte(key_text))
0x0e, 0x0f}   

  if err != nil {
         fmt.Printf("Error: NewCipher(%d bytes) = %s", len(key_text), err)
         os.Exit(-1)
}
//加密字符串
cfb := cipher.NewCFBEncrypter(c, commonIV) ciphertext := make([]byte, len(plaintext)) cfb.XORKeyStream(ciphertext, plaintext) fmt.Printf("%s=>%x\n", plaintext, ciphertext)
// 解密字符串
cfbdec := cipher.NewCFBDecrypter(c, commonIV) plaintextCopy := make([]byte, len(plaintext)) cfbdec.XORKeyStream(plaintextCopy, ciphertext) fmt.Printf("%x=>%s\n", ciphertext, plaintextCopy)
}
```

通过调用函数 aes.NewCipher \(参数key必须是16、24或者32位的\[\]byte,分别对应AES-128, AES-192或AES-2  
56算法\),返回了一个 cipher.Block 接口

```go
type Block interface {
     // BlockSize returns the cipher's block size.
     BlockSize() int
     // Encrypt encrypts the first block in src into dst.
     // Dst and src may point at the same memory.
     Encrypt(dst, src []byte)
     // Decrypt decrypts the first block in src into dst.
     // Dst and src may point at the same memory.
     Decrypt(dst, src []byte)
}
```



