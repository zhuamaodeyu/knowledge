#Go Web session和数据存储    

Web里面经典的解决方案是cookie和session,cookie机制是一种客户端机制,把用户数据保存在客户端,而s ession机制是一种服务器端的机制,服务器使用一种类似于散列表的结构来保存信息,每一个网站访客都会被分 配给一个唯一的标志符,即sessionID,它的存放形式无非两种:要么经过url传递,要么保存在客户端的cookies 里.当然,你也可以将Session保存到数据库里,这样会更安全,但效率方面会有所下降。   
##本章解决的问题：   
1. session 和cookie的区别     
2. Go 实现session  
3. 如何防止session被劫持，保护session    
4. 实现session是存储在内存中的，实现应用session共享  


--------------            
cookie： 在本地计算机白村一些用户操作的历史信息。并在用户再次访问该 站点时浏览器通过HTTP协议将本地cookie内容发送给服务器,从而完成验证     

* 会话cookie   
	不设置过期时间， 关闭浏览器就消失  

* 持久cookie    
	设置过期时间， 浏览器保存期到硬盘上

####设置cookie   
`http.SetCookie(w ResponseWriter, cookie *Cookie)   `


~~~  
type Cookie struct {    Name       string    Value      string    Path       string    Domain     string    Expires    time.Time    RawExpires string// MaxAge=0 means no 'Max-Age' attribute specified.// MaxAge<0 means delete cookie now, equivalently 'Max-Age: 0'// MaxAge>0 means Max-Age attribute present and given in seconds    MaxAge   int    Secure   bool    HttpOnly bool    Raw      string    Unparsed []string // Raw text of unparsed attribute-value pairs}
~~~    

设置cookie    
~~~  
expiration := time.Now()expiration = expiration.AddDate(1, 0, 0)cookie := http.Cookie{Name: "username", Value: "astaxie", Expires: expiration}http.SetCookie(w, &cookie)
~~~

####读取cookie    

~~~  
cookie, _ := r.Cookie("username")fmt.Fprint(w, cookie)

for _, cookie := range r.Cookies() {    fmt.Fprint(w, cookie.Name)}

~~~   
session：简而言之就是在服务器上保存用户操作的历史信息。服务器使用session id来标识session,session i d由服务器负责产生,保证随机性与唯一性,相当于一个随机密钥,避免在握手或传输中暴露用户真实密码。但该 方式下,仍然需要将发送请求的客户端与session进行对应,所以可以借助cookie机制来获取客户端的标识(即se ssion id),也可以通过GET方式将id提交给服务器。


session机制是一种服务器端的机制,服务器使用一种类似于散列表的结构(也可能就是使用散列表)来保存信息。     

程序需要为某个客户端的请求创建一个session， 服务器先检查这个客户端的请求中是否包含了一个sessionID， 如果已经包含，说明已经存在session， 服务器就按照sessionID，查找到session， 如果不包含则



##session     
go标准包没有做对session的支持     
session的基本原理是由服务器为每个会话维护一份信息数据,客户端和服务端依靠一个全局唯一的标识来访问这 份数据,以达到交互的目的     
创建session   ：  

* 生成全局唯一标识符  
* 开辟数据存储空间,也可以进行存储   
* 将session 的去哪聚唯一标识符发送给客户端   

  
HTTP协议一般讲数据存储在3个地方：   

1. 请求行  
2. 头域    
3. body   

一般有两种方式实现： cookie， URL重写   

cookie 通过set-Cookie 将session标识符传送给客户端 ，客户端每次请求带回sessionID   
URL 重写：返回给用户的页面里的所有URL后面追加session标识符(如果客户端禁用cookie， 使用此种方式最好)     

###go 实现session管理    

- 全局session管理器  
- 保证sessionID的全局唯一性  
- 为每个客户关联一个session   
- session 的存储   
- session过期处理   

定义全局session管理器   

~~~   
 type Manager struct {     cookieName  string     //private cookiename     lock        sync.Mutex // protects session     provider    Provider     maxlifetime int64} func NewManager(provideName, cookieName string, maxlifetime int64) (*Manager, error) {     provider, ok := provides[provideName]     if !ok {         return nil, fmt.Errorf("session: unknown provide %q (forgotten import?)", provideName)     }     return &Manager{provider: provider, cookieName: cookieName, maxlifetime: maxlifetime}, nil }~~~
在main 包中创建一个全局的session管理器  

~~~  
var globalSessions *session.Manager //然后在init函数中初始化func init() {     globalSessions, _ = NewManager("memory","gosessionid",3600) }
~~~

实现一个接口用来管理session   

~~~  
type Provider interface {     SessionInit(sid string) (Session, error)  //初始化     SessionRead(sid string) (Session, error)  //读取     SessionDestroy(sid string) error     SessionGC(maxLifeTime int64)}
~~~   

• SessionInit函数实现Session的初始化,操作成功则返回此新的Session变量• SessionRead函数返回sid所代表的Session变量,如果不存在,那么将以sid为参数调用SessionInit函数创建 并返回一个新的Session变量• SessionDestroy函数用来销毁sid对应的Session变量• SessionGC根据maxLifeTime来删除过期的数据

~~~  
 type Session interface {     Set(key, value interface{}) error //set session value     Get(key interface{}) interface{}  //get session value     Delete(key interface{}) error     //delete session value     SessionID() string                //back current sessionID}
~~~

~~~  
var provides = make(map[string]Provider) // Register makes a session provide available by the provided name. // If Register is called twice with the same name or if driver is nil, // it panics. func Register(name string, provider Provider) {     if provider == nil {         panic("session: Register provide is nil")     }     if _, dup := provides[name]; dup {         panic("session: Register called twice for provide " + name)     }     provides[name] = provider }
~~~   

~~~  
func (manager *Manager) sessionId() string {     b := make([]byte, 32)     if _, err := io.ReadFull(rand.Reader, b); err != nil {return "" }     return base64.URLEncoding.EncodeToString(b) }
~~~


session创建  

~~~   
 func (manager *Manager) SessionStart(w http.ResponseWriter, r *http.Request) (session Session) {     manager.lock.Lock()     defer manager.lock.Unlock()     cookie, err := r.Cookie(manager.cookieName)     if err != nil || cookie.Value == "" {         sid := manager.sessionId()         session, _ = manager.provider.SessionInit(sid)         cookie := http.Cookie{Name: manager.cookieName, Value: url.QueryEscape(sid), Path: "/", HttpOnly:         http.SetCookie(w, &cookie)     } else {         sid, _ := url.QueryUnescape(cookie.Value)         session, _ = manager.provider.SessionRead(sid)}return }
~~~   

session使用：  

~~~  
func login(w http.ResponseWriter, r *http.Request) {     sess := globalSessions.SessionStart(w, r)     r.ParseForm()     if r.Method == "GET" {         t, _ := template.ParseFiles("login.gtpl")         w.Header().Set("Content-Type", "text/html")
          t.Execute(w, sess.Get("username"))     } else {         sess.Set("username", r.Form["username"])         http.Redirect(w, r, "/", 302)     }}

~~~    

设置、读取、删除     

~~~    
 func count(w http.ResponseWriter, r *http.Request) {     sess := globalSessions.SessionStart(w, r)     createtime := sess.Get("createtime")     if createtime == nil {         sess.Set("createtime", time.Now().Unix())     } else if (createtime.(int64) + 360) < (time.Now().Unix()) {         globalSessions.SessionDestroy(w, r)         sess = globalSessions.SessionStart(w, r)     }     ct := sess.Get("countnum")     if ct == nil {         sess.Set("countnum", 1)     } else {         sess.Set("countnum", (ct.(int) + 1))     }     t, _ := template.ParseFiles("count.gtpl")     w.Header().Set("Content-Type", "text/html")     t.Execute(w, sess.Get("countnum"))}

~~~

session 有过期改变，所以需要定义GC操作，当符合条件的时候引发GC     

~~~  
//Destroy sessionid func (manager *Manager) SessionDestroy(w http.ResponseWriter, r *http.Request){     cookie, err := r.Cookie(manager.cookieName)     if err != nil || cookie.Value == "" {         return     } else {         manager.lock.Lock()         defer manager.lock.Unlock()         manager.provider.SessionDestroy(cookie.Value)         expiration := time.Now()         cookie := http.Cookie{Name: manager.cookieName, Path: "/", HttpOnly: true, Expires: expiration, MaxAge: -1}         http.SetCookie(w, &cookie)} }
~~~    

~~~
func init() {     go globalSessions.GC()} func (manager *Manager) GC() {     manager.lock.Lock()     defer manager.lock.Unlock()     manager.provider.SessionGC(manager.maxlifetime)     time.AfterFunc(time.Duration(manager.maxlifetime), func() { manager.GC() })}
~~~   



###基于内存的session存储   

~~~   
package memoryimport (    "container/list"    "github.com/astaxie/session"    "sync"    "time")var pder = &Provider{list: list.New()}type SessionStore struct {sid stringtimeAccessed time.Timevalue map[interface{}]interface{} //session里面存储的值}func (st *SessionStore) Set(key, value interface{}) error {    st.value[key] = value    pder.SessionUpdate(st.sid)    return nil}func (st *SessionStore) Get(key interface{}) interface{} {    pder.SessionUpdate(st.sid)    if v, ok := st.value[key]; ok {        return v    } else {return nil }return nil }func (st *SessionStore) Delete(key interface{}) error {    delete(st.value, key)    pder.SessionUpdate(st.sid)    return nil}//session id唯一标示 //最后访问时间
第 6 章 6 session和数据存储 | 216 func (st *SessionStore) SessionID() string {    return st.sid}type Provider struct {lock sync.Mutex //用来锁 sessions map[string]*list.Element //用来存储在内存 list *list.List //用来做gc}func (pder *Provider) SessionInit(sid string) (session.Session, error) {    pder.lock.Lock()    defer pder.lock.Unlock()    v := make(map[interface{}]interface{}, 0)    newsess := &SessionStore{sid: sid, timeAccessed: time.Now(), value: v}    element := pder.list.PushBack(newsess)    pder.sessions[sid] = element    return newsess, nil}func (pder *Provider) SessionRead(sid string) (session.Session, error) {    if element, ok := pder.sessions[sid]; ok {        return element.Value.(*SessionStore), nil    } else {        sess, err := pder.SessionInit(sid)        return sess, err    }    return nil, nil}func (pder *Provider) SessionDestroy(sid string) error {    if element, ok := pder.sessions[sid]; ok {        delete(pder.sessions, sid)        pder.list.Remove(element)        return nil}return nil }func (pder *Provider) SessionGC(maxlifetime int64) {    pder.lock.Lock()    defer pder.lock.Unlock()for {
第 6 章 6 session和数据存储 | 217element := pder.list.Back()         if element == nil {break }         if (element.Value.(*SessionStore).timeAccessed.Unix() + maxlifetime) < time.Now().Unix() {             pder.list.Remove(element)             delete(pder.sessions, element.Value.(*SessionStore).sid)} else { break} }} func (pder *Provider) SessionUpdate(sid string) error {     pder.lock.Lock()     defer pder.lock.Unlock()     if element, ok := pder.sessions[sid]; ok {         element.Value.(*SessionStore).timeAccessed = time.Now()         pder.list.MoveToFront(element)         return nil}return nil } func init() {     pder.sessions = make(map[string]*list.Element, 0)     session.Register("memory", pder)}
~~~    

初始化一个session管理器   

~~~   
import (     "github.com/astaxie/session"     _ "github.com/astaxie/session/providers/memory") var globalSessions *session.Manager//然后在init函数中初始化 func init() {globalSessions, _ = session.NewManager("memory", "gosessionid", 3600)
  go globalSessions.GC()
 }
~~~    
 

















