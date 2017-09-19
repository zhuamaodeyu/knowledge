##Socket   
socket来源于 Unix， 一切皆文件 ，  "打开----》读写-----》关闭"    

常用的socket类型：  

* 流式Socket   
* 数据报式Socket    

流式是一种面向连接 的Socket,针对于面向连接的TCP服务应用;
数据报式Socket是一种无连接的Socket,对应于无连接的UDP服务应用。  


Go语言支持的IP 类型：  
`ParseIP(s string) IP `  会将一个IP4或者IP6地址转化为IP类型   

~~~  
package main import (     "net"     "os"     "fmt" ) func main() {     if len(os.Args) != 2 {         fmt.Fprintf(os.Stderr, "Usage: %s ip-addr\n", os.Args[0])         os.Exit(1)     }     name := os.Args[1]     addr := net.ParseIP(name)     if addr == nil {         fmt.Println("Invalid address")     } else {         fmt.Println("The address is ", addr.String())     }os.Exit(0) }
~~~  


TCP Socket      

~~~  
func (c *TCPConn) Write(b []byte) (n int, err os.Error)func (c *TCPConn) Read(b []byte) (n int, err os.Error)
~~~ 
此函数存在于`TCPConn` 中， 用来在客户端和服务器端读写数据     

`func ResolveTCPAddr(net, addr string) (*TCPAddr, os.Error)`    

Go语言中通过`DialTCP` 函数来建立一个TCP连接 ，并且返回一个`TCPConn`类型的对象。

` func DialTCP(net string, laddr, raddr *TCPAddr) (c *TCPConn, err os.Error)`  
使用此函数建立连接    


~~~    
package main import (     "fmt"     "io/ioutil"     "net"     "os") func main() {     if len(os.Args) != 2 {         fmt.Fprintf(os.Stderr, "Usage: %s host:port ", os.Args[0])os.Exit(1) }     service := os.Args[1]     tcpAddr, err := net.ResolveTCPAddr("tcp4", service)     checkError(err)     conn, err := net.DialTCP("tcp", nil, tcpAddr)     checkError(err)     _, err = conn.Write([]byte("HEAD / HTTP/1.0\r\n\r\n"))     checkError(err)
      result, err := ioutil.ReadAll(conn)     checkError(err)     fmt.Println(string(result))     os.Exit(0) } func checkError(err error) {     if err != nil {         fmt.Fprintf(os.Stderr, "Fatal error: %s", err.Error())         os.Exit(1)} }
~~~     
首先程序将用户的输入作为参数 service 传入 net.ResolveTCPAddr 获取一个tcpAd dr,然后把tcpAddr传入DialTCP后创建了一个TCP连接 conn ,通过 conn 来发送请求信息,最后通过 ioutil.ReadA ll 从 conn 中读取全部的文本,也就是服务端响应反馈的信息。     



































