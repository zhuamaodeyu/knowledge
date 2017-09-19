#Go Web 访问数据库   
Go没有内置的驱动支持任何的数据库,但是Go定义了database/sql接口,用户可以基于驱动接口开发相应数据库 的驱动     

##database /sql 接口   
* sql.Register    
	此函数用来注册数据库驱动

~~~
//https://github.com/mattn/go-sqlite3驱动 func init() {    sql.Register("sqlite3", &SQLiteDriver{})}//https://github.com/mikespook/mymysql驱动// Driver automatically registered in database/sql var d = Driver{proto: "tcp", raddr: "127.0.0.1:3306"} func init() {    Register("SET NAMES utf8")    sql.Register("mymysql", &d)}
~~~   
其内部是通过一个map 来进行数据存储的， 可以定义多个驱动  
`var drivers = make(map[string]driver.Driver)`  只要不重复    

>  _ 的意思是引入后面的包名 而不直接使用这个包中定义的函数,变量等资源。  
> 包在引入的时候会自动调用包的init函数以完成 对包的初始化    

* driver.Driver   
是一个数据库驱动的接口，定义了一个 `method: Open(name string)` 返回一个数据库的Conn接口  

~~~  
type Driver interface {    Open(name string) (Conn, error)}
~~~  
__注意__： 返回的Conn只能用来进行一次goroutine操作， 不能用于多个   

* driver.Conn  
是一个数据库连接的接口定义，定义了一系列方法。    

~~~  
type Conn interface {    Prepare(query string) (Stmt, error)    Close() error
    Begin() (Tx, error)
}     
~~~   
Prepare函数返回与当前连接相关的执行Sql语句的准备状态,可以进行查询、删除等操作。     
Close函数关闭当前的连接,执行释放连接拥有的资源等清理工作。因为驱动实现了database/sql里面建议的conn pool,所以你不用再去实现缓存conn之类的,这样会容易引起问题。     Begin函数返回一个代表事务处理的Tx,通过它你可以进行查询,更新等操作,或者对事务进行回滚、递交。    

* driver.Stmt   
Stmt是一种准备好的状态,和Conn相关联,而且只能应用于一个goroutine中,不能应用于多个goroutine。    

~~~  
type Stmt interface {    Close() error    NumInput() int    Exec(args []Value) (Result, error)    Query(args []Value) (Rows, error)}
~~~    
Close函数关闭当前的链接状态,但是如果当前正在执行query,query还是有效返回rows数据。    
NumInput函数返回当前预留参数的个数,当返回>=0时数据库驱动就会智能检查调用者的参数。当数据库驱动包不 知道预留参数的时候,返回-1。   
Exec函数执行Prepare准备好的sql,传入参数执行update/insert等操作,返回Result数据     
Query函数执行Prepare准备好的sql,传入需要的参数执行select操作,返回Rows结果集      


* driver.Tx   
事务处理一般就两个过程,递交或者回滚。数据库驱动里面也只需要实现这两个函数就可以    

~~~  
type Tx interface {    Commit() error    Rollback() error}
~~~  

* driver.Execer   
是一个Conn可选实现接口     

~~~  
type Execer interface {    Exec(query string, args []Value) (Result, error)}
~~~   
如果这个接口没有定义,那么在调用DB.Exec,就会首先调用Prepare返回Stmt,然后执行Stmt的Exec,然后关闭St mt。     

* driver.Result    
是执行Update/Insert 等操作返回的结果接口定义    

~~~  
type Result interface {    LastInsertId() (int64, error)    RowsAffected() (int64, error)}
~~~   
LastInsertId函数返回由数据库执行插入操作得到的自增ID号。    RowsAffected函数返回query操作影响的数据条目数。     

* driver.Rows    
Rows是执行查询返回的结果集接口定义    

~~~  
type Rows interface {    Columns() []string    Close() error    Next(dest []Value) error}
~~~  
Columns函数返回查询数据库表的字段信息,这个返回的slice和sql查询的字段一一对应,而不是返回整个表的所 有字段。      
Close函数用来关闭Rows迭代器。     
Next函数用来返回下一条数据,把数据赋值给dest。dest里面的元素必须是driver.Value的值除了string,返回 __的数据里面所有的string都必须要转换成[]byte__。如果最后没数据了,Next函数最后返回io.EOF。      

* driver.RowsAffected     
RowsAffected其实就是一个int64的别名,但是他实现了Result接口,用来底层实现Result的表示方式      

~~~  
type RowsAffected int64func (RowsAffected) LastInsertId() (int64, error)func (v RowsAffected) RowsAffected() (int64, error)
~~~  

* driver.Value   
是一个空接口，可以容纳任何的数据     
drive的value必须是驱动能够操作的Value，要么是nil, 要么是下面的任意一种    

~~~  
int64float64bool[]bytestring [*]除了Rows.Next返回的不能是string. time.Time
~~~   

* driver.ValueConverter   
ValueConverter接口定义了如何把一个普通的值转化成driver.Value的接口   

~~~  
type ValueConverter interface {    ConvertValue(v interface{}) (Value, error)}
~~~   

好处：  
1. 转化driver.value到数据库表相应的字段,例如int64的数据如何转化成数据库表uint16字段     
2.  把数据库查询结果转化成driver.Value值    
3. 在scan函数里面如何把driver.Value值转化成用户定义的值* driver.Valuer    
Valuer接口定义了返回一个driver.Value的方式     

~~~  
type Valuer interface {    Value() (Value, error)}
~~~   

很多类型都实现了这个Value方法,用来自身与driver.Value的转化。 
* database/sql   
database/sql在database/sql/driver提供的接口基础上定义了一些更高阶的方法,用以简化数据库操作,同时内 部还建议性地实现一个conn pool。    

~~~  
type DB struct {    driver	driver.Driver    dsn		string    mu			sync.Mutex    freeConn []driver.Conn    closed   bool}
~~~
我们可以看到Open函数返回的是DB对象,里面有一个freeConn,它就是那个简易的连接池。它的实现相当简单或 者说简陋,就是当执行Db.prepare的时候会 defer db.putConn(ci, err) ,也就是把这个连接放入连接池,每次调 用conn的时候会先判断freeConn的长度是否大于0,大于0说明有可以复用的conn,直接拿出来用就是了,如果不 大于0,则创建一个conn,然后再返回之。    




## mysql 使用    

~~~  
CREATE TABLE `userinfo` (    `uid` INT(10) NOT NULL AUTO_INCREMENT,    `username` VARCHAR(64) NULL DEFAULT NULL,    `departname` VARCHAR(64) NULL DEFAULT NULL,    `created` DATE NULL DEFAULT NULL,    PRIMARY KEY (`uid`))CREATE TABLE `userdetail` (    `uid` INT(10) NOT NULL DEFAULT '0',
     `intro` TEXT NULL,    `profile` TEXT NULL,    PRIMARY KEY (`uid`))

~~~   

~~~   
package mainimport (    _ "github.com/go-sql-driver/mysql"    "database/sql"    "fmt"    //"time")func main() {    db, err := sql.Open("mysql", "astaxie:astaxie@/test?charset=utf8")    checkErr(err)//插入数据stmt, err := db.Prepare("INSERT userinfo SET username=?,departname=?,created=?") checkErr(err)res, err := stmt.Exec("astaxie", "研发部门", "2012-12-09") checkErr(err)    id, err := res.LastInsertId()    checkErr(err)fmt.Println(id)//更新数据stmt, err = db.Prepare("update userinfo set username=? where uid=?") checkErr(err)    res, err = stmt.Exec("astaxieupdate", id)    checkErr(err)    affect, err := res.RowsAffected()    checkErr(err)    fmt.Println(affect)//查询数据rows, err := db.Query("SELECT * FROM userinfo") checkErr(err)
第 5 章 5 访问数据库 | 180for rows.Next() {        var uid int        var username string        var department string        var created string        err = rows.Scan(&uid, &username, &department, &created)        checkErr(err)        fmt.Println(uid)        fmt.Println(username)        fmt.Println(department)        fmt.Println(created)}//删除数据stmt, err = db.Prepare("delete from userinfo where uid=?") checkErr(err)    res, err = stmt.Exec(id)    checkErr(err)    affect, err = res.RowsAffected()    checkErr(err)    fmt.Println(affect)db.Close() }func checkErr(err error) {    if err != nil {panic(err) }}
~~~  

代码解释：  
`sql.Open()`: 用来打开一个注册过的数据库驱动    
`db.Prepare()`: 用来返回准备要执行的sql操作,然后返回准备完毕的执行状态。      
`db.Query()`: 用来直接执行Sql返回Rows结果。    
`stmt.Exec()`: 用来执行stmt准备好的SQL语句         


##PostgreSQL    
开源数据库    
 
~~~  
CREATE TABLE userinfo(    uid serial NOT NULL,    username character varying(100) NOT NULL,    departname character varying(500) NOT NULL,    Created date,    CONSTRAINT userinfo_pkey PRIMARY KEY (uid))WITH (OIDS=FALSE);CREATE TABLE userdeatail(
 	uid integer,    intro character varying(100),    profile character varying(100))WITH(OIDS=FALSE);

~~~   

~~~  
import (    "database/sql""fmt"    _ "https://github.com/lib/pq")func main() {    db, err := sql.Open("postgres", "user=astaxie password=astaxie dbname=test sslmode=disable")    checkErr(err)//插入数据stmt, err := db.Prepare("INSERT INTO userinfo(username,departname,created) VALUES($1,$2,$3) RETURNING checkErr(err)res, err := stmt.Exec("astaxie", "研发部门", "2012-12-09") checkErr(err)//pg不支持这个函数,因为他没有类似MySQL的自增ID id, err := res.LastInsertId()checkErr(err)    fmt.Println(id)//更新数据stmt, err = db.Prepare("update userinfo set username=$1 where uid=$2") checkErr(err)    res, err = stmt.Exec("astaxieupdate", 1)    checkErr(err)    affect, err := res.RowsAffected()    checkErr(err)fmt.Println(affect) //查询数据uid")
第 5 章 5 访问数据库 | 187rows, err := db.Query("SELECT * FROM userinfo")    checkErr(err)    for rows.Next() {        var uid int        var username string        var department string        var created string        err = rows.Scan(&uid, &username, &department, &created)        checkErr(err)        fmt.Println(uid)        fmt.Println(username)        fmt.Println(department)        fmt.Println(created)}//删除数据stmt, err = db.Prepare("delete from userinfo where uid=$1") checkErr(err)    res, err = stmt.Exec(1)    checkErr(err)    affect, err = res.RowsAffected()    checkErr(err)    fmt.Println(affect)db.Close() }func checkErr(err error) {    if err != nil {panic(err) }}
~~~      
使用的是`$1` 方式制定要传递的参数，不是使用的`?`    
sql.Open 中的dsn信息的格式与MySQL驱动中的dsn格式不一样     
pg 不支持 LastInsertId函数， 所以没有自增ID 返回    


--------------------------   
##beeDB ORM 开发    
* 安装   
	`go get github.com/astaxie/beedb`    
* 初始化   
	
	~~~   
	import (    "database/sql"    "github.com/astaxie/beedb"    _ "github.com/ziutek/mymysql/godrv"	)
	~~~   
* 打开数据库并创建beedb对象    

	~~~ 
	db, err := sql.Open("mymysql", "test/xiemengjun/123456")	if err != nil {		panic(err) }	orm := beedb.New(db)
	~~~   
	new方法其实有两个参数，第一个是标准接口db， 第二个是数据库引擎    
	`beedb.OnDebug=true`    

* 建立相应的struct    
	
	~~~   
	type Userinfo struct {		Uid int `PK` //如果表的主键不是id,那么需要加上pk注释,显式的说这个字段是主键 Username string		Departname string		Created time.Time	}  
	~~~   
	> beedb针对驼峰命名会自动帮你转化成下划线字段,例如你定义了Struct名字为 UserInfo ,那么转化 成底层实现的时候是 user_info ,字段命名也遵循该规则。    

* 插入数据    
	
	~~~   
	var saveone Userinfo	saveone.Username = "Test Add User"	saveone.Departname = "Test Add Departname"	saveone.Created = time.Now()	orm.Save(&saveone)
	~~~   
	
	通过map 进行数据插入    
	
	~~~  
	add := make(map[string]interface{})	add["username"] = "astaxie"	add["departname"] = "cloud develop"	add["created"] = "2012-12-02"	orm.SetTable("userinfo").Insert(add)  
	~~~   
	
	插入多条数据   
	
	~~~  
	addslice := make([]map[string]interface{}, 0)	add:=make(map[string]interface{})	add2:=make(map[string]interface{})	add["username"] = "astaxie"	add["departname"] = "cloud develop"	add["created"] = "2012-12-02"	add2["username"] = "astaxie2"	add2["departname"] = "cloud develop2"	add2["created"] = "2012-12-02"	addslice =append(addslice, add, add2)	orm.SetTable("userinfo").InsertBatch(addslice)
	~~~   

* 更新数据   
	
	~~~  
	saveone.Username = "Update Username"	saveone.Departname = "Update Departname"	saveone.Created = time.Now()	orm.Save(&saveone) //现在saveone有了主键值,就执行更新操作
	~~~   
	
	使用map更新数据   
	
	~~~  
	t := make(map[string]interface{})	t["username"] = "astaxie"	orm.SetTable("userinfo").SetPK("uid").Where(2).Update(t)
	~~~   
	SetPK:显式的告诉ORM,数据库表 userinfo 的主键是 uid 。    
	Where:用来设置条件,支持多个参数,第一个参数如果为整数,相当于调用了Where("主键=?",值)。 Updata函数 接收map类型的数据,执行更新数据。     

* 查询   
	
	~~~  
	var user Userinfo //Where接受两个参数,支持整形参数 	orm.Where("uid=?", 27).Find(&user)
	
	var user2 Userinfo	orm.Where(3).Find(&user2) // 这是上面版本的缩写版,可以省略主键
	
	var user3 Userinfo //Where接受两个参数,支持字符型的参数 	orm.Where("name = ?", "john").Find(&user3)
	
	//条件查询  
	var user4 Userinfo	//Where支持三个参数	orm.Where("name = ? and age < ?", "john", 88).Find(&user4)
	
	//获取10条从 20 条开始
	var allusers []Userinfo	err := orm.Where("id > ?", 		"3").Limit(10,20).FindAll(&allusers)
	
	//获取10 条
	var tenusers []Userinfo	err := orm.Where("id > ?", "3").Limit(10).FindAll(&tenusers)   
	
	//获取全部
	var everyone []Userinfo	err := orm.OrderBy("uid desc,username asc").FindAll(&everyone)
	~~~

	获取数据到map中   
	`a, _ := orm.SetTable("userinfo").SetPK("uid").Where(2).Select("uid,username").FindMap()`    
	

* 删除数据   
	
	~~~
	//saveone就是上面示例中的那个saveone 
	orm.Delete(&saveone)   
	
	//alluser就是上面定义的获取多条数据的slice 	orm.DeleteAll(&alluser)   
	
	rm.SetTable("userinfo").Where("uid>?", 3).DeleteRow()   
	~~~   
	
* 关联查询     
	
	~~~    
	a, _ := orm.SetTable("userinfo").Join("LEFT", "userdeatail", "userinfo.uid=userdeatail.uid").Where("userinfo.uid=?", 1)    
	第一个参数可以是INNER, LEFT, OUTER, CROSS等
	第二个表示连接的表  
	第三个参数表示连接的条件  
	~~~   
	
* Group By 和 Having     
`a, _ := orm.SetTable("userinfo").GroupBy("username").Having("username='astaxie'").FindMap()`    



##NOSQL 数据库    
* redis   

	~~~  
	package main	import (	    "github.com/astaxie/goredis"    	"fmt"	)	func main() {		var client goredis.Client		// 设置端口为redis默认端口 client.Addr = "127.0.0.1:6379"		//字符串操作
		第 5 章 5 访问数据库 | 196		client.Set("a", []byte("hello"))    		val, _ := client.Get("a")    		fmt.Println(string(val))    		client.Del("a")		//list操作		vals := []string{"a", "b", "c", "d", "e"} for _, v := range vals {        	client.Rpush("l", []byte(v))    	}    	dbvals,_ := client.Lrange("l", 0, 4)    	for i, v := range dbvals {        	println(i,":",string(v))    	}    	client.Del("l")	}
	~~~

* mongDB   
	![](/Users/wenliao/Library/Mobile Documents/com~apple~CloudDocs/Mou/📒Note/Go web/Resource/Snip20161211_20.png)    
	
	~~~  
	package main	import (    	"fmt"    	"labix.org/v2/mgo"    	"labix.org/v2/mgo/bson"	)
	type Person struct {    	Name string    	Phone string	}	func main() {    	session, err := mgo.Dial("server1.example.com,server2.example.com")
	 	if err != nil {        	panic(err)    	}    	defer session.Close()    	session.SetMode(mgo.Monotonic, true)    	c := session.DB("test").C("people")    	err = c.Insert(&Person{"Ale", "+55 53 8116 9639"},        &Person{"Cla", "+55 53 8402 8510"})    	if err != nil {panic(err) }    	result := Person{}    	err = c.Find(bson.M{"name": "Ale"}).One(&result)    	if err != nil {panic(err) }    	fmt.Println("Phone:", result.Phone)	}
	~~~