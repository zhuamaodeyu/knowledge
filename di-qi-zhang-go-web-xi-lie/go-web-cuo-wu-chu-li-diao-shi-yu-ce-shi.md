#Go Web 错误处理调试和测试    

##错误处理   
Go语言主要的设计准则是:简洁、明白,简洁是指语法和C类似,相当的简单,明白是指任何语句都是很明显 的,不含有任何隐含的东西,在错误处理方案的设计中也贯彻了这一思想    
Go 语言通过定义一个error类型，显示的表达错误。在使用时通过吧返回的error与nil做对比， 如果不相等就索命操作失败  

####error 类型  
是一个接口， 一般使用的是接口的实现对象`errorString`   

~~~  
// errorString is a trivial implementation of error.type errorString struct {s string }func (e *errorString) Error() string {    return e.s}  

// New returns an error that formats as the given text. func New(text string) error {     return &errorString{text} }

~~~    








##使用GDB调试  






##Go 测试用例  

