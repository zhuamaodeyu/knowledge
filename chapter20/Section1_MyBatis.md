# 第一章 mybatis 简介  
### 简介   
`mybatis`: 是一个简化和实现了Java数据持久层的开源框架爱，抽象和大量的jdbc冗余代码，提供简单的API和数据库加护  
#### mybatis优点  
1. 消除大量的JDBC冗余代码  
2. 低的学习曲线  
3. 很好的域传统数据库协作  
4. 接收SQL语句 
5. 提供Spring框架集成  
6. 提供第三方缓存类库集成  
7. 引入更好的性能  

#### mybatis简单使用  
0. mybatis 配置  
	
	~~~xml
	<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN" "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
  <typeAliases>
    <typeAlias alias="Student" type="com.mybatis3.domain.Student" />
  </typeAliases>
  <environments default="development">
    <environment id="development">
      <transactionManager type="JDBC" />
      <dataSource type="POOLED">
        <property name="driver" value="com.mysql.jdbc.Driver" />
        <property name="url" value="jdbc:mysql://localhost:3306/test" />
        <property name="username" value="root" />
        <property name="password" value="admin" />
      </dataSource>
    </environment>
  </environments>
  <mappers>
    <mapper resource="com/mybatis3/mappers/StudentMapper.xml" />
  </mappers>
</configuration>
	
	~~~

01. 创建session Factory 类  
	
	~~~java 
	package com.mybatis3.util;
    import java.io.*;
    import org.apache.ibatis.io.Resources;
    import org.apache.ibatis.session.*;
    public class MyBatisSqlSessionFactory
    {
        private static SqlSessionFactory sqlSessionFactory;
        public static SqlSessionFactory getSqlSessionFactory()
        {
            if(sqlSessionFactory == null)
            {
                InputStream inputStream;
    try
                {
                    inputStream = Resources.
                                getResourceAsStream("mybatis-config.xml");
                    sqlSessionFactory = new
                    SqlSessionFactoryBuilder().build(inputStream);
                }
                catch (IOException e)
                {
                    throw new RuntimeException(e.getCause());
                }
            }
            return sqlSessionFactory;
        }
        public static SqlSession openSession()
        {
            return getSqlSessionFactory().openSession();
        }
    }
	~~~


1. 创建xml映射  
	
	~~~xml
	<select id="findStudentById" parameterType="int" resultType="Student">
    SELECT STUD_ID AS studId, NAME, EMAIL, DOB
        FROM STUDENTS WHERE STUD_ID=#{Id}
	</select>
	<insert id="insertStudent" parameterType="Student">
    INSERT INTO STUDENTS(STUD_ID,NAME,EMAIL,DOB)
        VALUES(#{studId},#{name},#{email},#{dob})
	</insert>
	~~~
2. 创建mapper接口  
	
	~~~java 
	public interface StudentMapper
	{
    	Student findStudentById(Integer id);
    	void insertStudent(Student student);
	}
	~~~
3. 创建会话使用接口  
	
	~~~java 
	SqlSession session = getSqlSessionFactory().openSession();
	StudentMapper mapper = session.getMapper(StudentMapper.class);
	// Select Student by Id
	Student student = mapper.selectStudentById(1);
	//To insert a Student record
	mapper.insertStudent(student);
	~~~



# 第二章 mybatis 配置  
## 使用XML配置  

~~~xml
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN" "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
	//加载properties文件
  <properties resource="application.properties">
    <property name="username" value="db_user" />
    <property name="password" value="verysecurepwd" />
  </properties>
  //开启缓存
  <settings>
    <setting name="cacheEnabled" value="true" />
  </settings>
  
  //别名
  <typeAliases>
    <typeAlias alias="Tutor" type="com.mybatis3.domain.Tutor" />
    <package name="com.mybatis3.domain" />
  </typeAliases>  
  
  //类型处理器，注册自定义类型
  <typeHandlers>
    <typeHandler handler="com.mybatis3.typehandlers.PhoneTypeHandler" />
    <package name="com.mybatis3.typehandlers" />
  </typeHandlers>
  
  //支持配置多个数据源,设置默认环境为开发环境
  <environments default="development">
    <environment id="development">
      <transactionManager type="JDBC" />
      <dataSource type="POOLED">
        <property name="driver" value="${jdbc.driverClassName}" />
        <property name="url" value="${jdbc.url}" />
        <property name="username" value="${jdbc.username}" />
        <property name="password" value="${jdbc.password}" />
      </dataSource>
    </environment>
     <environment id="production">
      <transactionManager type="MANAGED" />
      <dataSource type="JNDI">
        <property name="data_source" value="java:comp/jdbc/MyBatisDemoDS" />
      </dataSource>
    </environment>
  </environments>
  <mappers>
    <mapper resource="com/mybatis3/mappers/StudentMapper.xml" />
    <mapper url="file:///D:/mybatisdemo/mappers/TutorMapper.xml" />
    <mapper class="com.mybatis3.mappers.TutorMapper" />
  </mappers>
</configuration>
~~~

以上是一个简单的基于XML的配置  
通过以上XML可以到所有的配置：  

1. 加载properties 文件  
	* 直接默认值 
		
		~~~xml
		<properties resource="application.properties">
  			<property name="jdbc.username" value="db_user" />
  			<property name="jdbc.password" value="verysecurepwd" />
		</properties>
		~~~

		__如果文件中定义了`jdbc.username`，以上配置中的默认值会被覆盖掉__   
	* 通过占位符  

		~~~xml
		<property name="driver" value="${jdbc.driverClassName}" />
  		<property name="url" value="${jdbc.url}" />
		~~~

2. 开启缓存  
3. 配置`environments default="development"` 实现默认环境 ，可以配置不同环境   
4. 配置多数据库实现    
5. 针对不同的数据库创建不同sessionFactory  
	
	~~~java
	InputStream inputStream = Resources.getResourceAsStream("mybatis-config.xml");
	SqlSessionFactory defaultSqlSessionFactory = new SqlSessionFactoryBuilder().
	build(inputStream);
	SqlSessionFactory cartSqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStre
        am, "shoppingcart");
	reportSqlSessionFactory = new SqlSessionFactoryBuilder().
	build(inputStream, "reports");
	~~~
	__如果不指定环境id，则使用默认的环境创建__  

6. 数据库类型配置  
	* `UNPOOLED`
		mybatis会为每个数据库创建错误一个新的连接，并关闭它。__只适用于小闺蜜数据并发__
	* `POOLED`
		mybatis创建一个数据库连接池，__开发环境经常使用__  
		默认的数据库连接池实现是通过`org.apache.ibatis.datasource.pooled.PooledDataSource`
	* `JNDI`  
		mybatis从应用服务器配置好的JNDI数据源获取数据库连接  
7. 事务管理  
	* `JDBC`
		是由JDBC事务管理器管理事务。 内部将通过JDBCTransactionFactory创建事务管理  
	* `MANAGED`  
		应用服务器负责管理数据库连接生命周期使用。内部使用`ManagedTranscationFactory`类来创建事务管理器

8. 设置别名  
	由于在`* mapper.xml` 文件中`resultType`和`parameterType`属性设置要使用全限定名，可以使用别名的形式简化   

	~~~xml
	<typeAliases>
  		<typeAlias alias="Student" type="com.mybatis3.domain.Student" />
  		<typeAlias alias="Tutor" type="com.mybatis3.domain.Tutor" />
  		<package name="com.mybatis3.domain" />
	</typeAliases>
	~~~
	__也可以不用直接设定别名，可以设定包，然后系统自动扫描设置一个以类首字母小写的别名__  
	__通过实体类添加注解形式实现__  
	
	~~~java 
	@Alias("")
	public class Student{
	
	}
	~~~  

9. 类型处理器  
	mubatis对一下类型实现內建处理器 ：  
	* 所有基本数据类型
	* 基本类型的包裹类型(装箱操作对象类型)  
	* byte[]  
	* java.util.Date
	* java.sql.Date 
	* java.sql.Time  
	* java.sql.Timestamp  
	* java枚举类型  
	
	__创建自定义的类型处理器，处理自定义类型__  
	
	~~~java 
	//PhoneNumber 自定义的类
	public class PhoneTypeHandler extends BaseTypeHandler<PhoneNumber>
	{
		 @Override
    public void setNonNullParameter(PreparedStatement ps, int i,
                                    PhoneNumber parameter, JdbcType jdbcType) throws SQLException
    {
        ps.setString(i, parameter.getAsString());
    }
    
    public PhoneNumber getNullableResult(ResultSet rs, String columnName)  throws SQLException
    {
    	 return new PhoneNumber(rs.getString(columnName));
    }
    
    public PhoneNumber getNullableResult(ResultSet rs, int columnIndex) throws SQLException
    {
    	 return new PhoneNumber(rs.getString(columnIndex));
    }
	}
	~~~
	__别忘了注册__   

10. 全局参数设定(一下是默认的，)   
	
	~~~xml
	<settings>
               <setting name="cacheEnabled" value="true" />
               <setting name="lazyLoadingEnabled" value="true" />
               <setting name="multipleResultSetsEnabled" value="true" />
               <setting name="useColumnLabel" value="true" />
               <setting name="useGeneratedKeys" value="false" />
               <setting name="autoMappingBehavior" value="PARTIAL" />
               <setting name="defaultExecutorType" value="SIMPLE" />
               <setting name="defaultStatementTimeout" value="25000" />
               <setting name="safeRowBoundsEnabled" value="false" />
               <setting name="mapUnderscoreToCamelCase" value="false" />
               <setting name="localCacheScope" value="SESSION" />
				  <setting name="jdbcTypeForNull" value="OTHER" />
				  <setting name="lazyLoadTriggerMethods" value="equals,clone,hashCode ,toString" />
	</settings>
	~~~
	
11. 配置mappers映射xml文件路径  
	多种配置形式  
	
	~~~xml
	<mappers>
		<mapper resource="com/mybatis3/mappers/StudentMapper.xml" /> 
		<mapper url="file:///D:/mybatisdemo/app/mappers/TutorMapper.xml" /> 
		<mapper class="com.mybatis3.mappers.TutorMapper" />
		<package name="com.mybatis3.mappers" />
	</mappers>
	~~~
## 使用Java 配置  
通过XML配置形式了解了mybatis中的各个配置属性， 通过Java API 的配置形式也可以实现  

~~~java 
public class MybatisConfig{
	public static SqlSessionFactory getSqlSessionFactory()
	{
	  SqlSessionFactory sqlSessionFactory = null;
	try
    {
        DataSource dataSource = DataSourceFactory.getDataSource();
        TransactionFactory transactionFactory = new
        JdbcTransactionFactory();
        Environment environment = new Environment("development",
                transactionFactory, dataSource);
        Configuration configuration = new Configuration(environment);
        configuration.getTypeAliasRegistry().registerAlias("student",
                Student.class);
        configuration.getTypeHandlerRegistry().register(PhoneNumber.
                class, PhoneTypeHandler.class);
        configuration.addMapper(StudentMapper.class);
        //创建
        sqlSessionFactory = new SqlSessionFactoryBuilder().
        build(configuration);
    }
    catch (Exception e)
    {
        throw new RuntimeException(e);
    }
    return sqlSessionFactory;
}
}
~~~

创建datasource   

~~~java 
public class DataSourceFactory
{
    public static DataSource getDataSource(){
	   String driver = "com.mysql.jdbc.Driver";
		String url = "jdbc:mysql://localhost:3306/mybatisdemo";
		String username = "root";
		String password = "admin";
		PooledDataSource dataSource = new PooledDataSource(driver, url,
        username, password);
		return dataSource;
	}
	
	//通过JNDI创建  
	public static DataSource getDataSource(){
		String jndiName = "java:comp/env/jdbc/MyBatisDemoDS";
		try{
			 	InitialContext ctx = new InitialContext();
    			DataSource dataSource = (DataSource) ctx.lookup(jndiName);
    			return dataSource;
		}catch(NamingException e){
			throw new RuntimeException(e);
		}
	}
	
	 
}
~~~


## 自定义mybatis日志 
###mybatis 日志支持   
mybatis中针对日志支持的优先级：  

* SLF4J  
* Apache Commons Logging  
* Log4j 2  
* Log4j  
* JDK logging

### mybatis 设置日志  
调用一下方式实现
~~~java 
org.apache.ibatis.logging.LogFactory.useSlf4jLogging(); 
org.apache.ibatis.logging.LogFactory.useLog4JLogging();
org.apache.ibatis.logging.LogFactory.useLog4J2Logging(); 
org.apache.ibatis.logging.LogFactory.useJdkLogging();
org.apache.ibatis.logging.LogFactory.useCommonsLogging(); 
org.apache.ibatis.logging.LogFactory.useStdOutLogging();
~~~


# 第三章 XML配置SQL映射器  
通过xml的形式映射有两种形式：  

* 只有XML映射  
	* 定义xml映射文件  
		
		~~~xml  
		<?xml version="1.0" encoding="utf-8"?>
		<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-mapper.dtd">
		<mapper namespace="com.mybatis3.mappers.StudentMapper">
			<select id="findStudentById" parameterType="int" resultType="Student"> select stud_id as studId, name, email, dob
from Students where stud_id=#{studId}
  			</select>
		</mapper>
		
		~~~

	* 调用       

	~~~java  
		public Student = findStudentById(Integer id){
			SqlSession session = MybatisUtil.geSqlSession();
			try{
				//通过字符串的形式调用
				Student student = sqlSession.selectOne("com.mybatis3.mappers.StudentMapper.findStudentById",id);
			}
		}	
	~~~
	

* 带有mapper接口类形式  
	需要注意的点： __其名空间namespace 应该跟StudentMapper接口的完全限定名保持一至__, __ id,parameterType,returnType 应该分别和 StudentMapper 接口中的方法名, 参数类型,返回值相对应__



## mybatis 提供的的映射语句  
mybatis 提供多种不同的映射语句:  

* INSERT  
	* `useGeneratedKeys`: 设置自增长  
	* `keyProperty`: 主键属性
* SELECT 
* UPDATE  
* DELETE 

#### mybatis 不同映射语句实例：  
1. INSERT  
	* 通过自增长设置主键  
		
		~~~xml
		<insert id="insertStudent" parameterType="Student" useGeneratedKeys="true" keyProperty="studId">
    		INSERT INTO STUDENTS(NAME, EMAIL, PHONE)
    		VALUES(#{name},#{email},#{phone})
		</insert>
		~~~
	
	* 针对支持序列生成主键值    
		
		~~~xml
		<insert id="insertStudent" parameterType="Student">
    		<selectKey keyProperty="studId" resultType="int" order="BEFORE">
        		SELECT ELEARNING.STUD_ID_SEQ.NEXTVAL FROM DUAL
    		</selectKey>
    		INSERT INTO STUDENTS(STUD_ID,NAME,EMAIL, PHONE)
        	VALUES(#{studId},#{name},#{email},#{phone})
		</insert>
		
		//使用触发器  
		<insert id="insertStudent" parameterType="Student">
    		INSERT INTO STUDENTS(NAME,EMAIL, PHONE)
        	VALUES(#{name},#{email},#{phone})
    		<selectKey keyProperty="studId" resultType="int" order="AFTER">
        		SELECT ELEARNING.STUD_ID_SEQ.CURRVAL FROM DUAL
    		</selectKey>
		</insert>
		~~~

####mybatis结果集映射规则：  
* 对于 List, Collection, Iterable类型，返回 java.util.ArrayList  
* 对于Map 类型，返回 java.util.HashMap   
* 对于Set 类型： 返回 java.util.HashSet  
* 对于SortedSet类型： 返回java.util.TreeSet  


## mybatis 映射关系 
### 一对一映射  
* 方式1： 使用点语法进行映射  

~~~java 
public class Student
{
   private Integer studId;
   private String name;
   private String email;
   private Address address;		//一个地址对象， 每个学生对应一个地址  
}
~~~

~~~xml
<resultMap type="Student" id="StudentWithAddressResult">
  <id property="studId" column="stud_id" />
  <result property="name" column="name" />
  <result property="email" column="email" />
  <result property="phone" column="phone" />
  <result property="address.addrId" column="addr_id" />
  <result property="address.street" column="street" />
  <result property="address.city" column="city" />
  <result property="address.state" column="state" />
  <result property="address.zip" column="zip" />
  <result property="address.country" column="country" />
</resultMap>
<select id="selectStudentWithAddress" parameterType="int"
resultMap="StudentWithAddressResult">
    SELECT STUD_ID, NAME, EMAIL, A.ADDR_ID, STREET, CITY, STATE,
        ZIP, COUNTRY
FROM STUDENTS S LEFT OUTER JOIN ADDRESSES A ON S.ADDR_ID=A.ADDR_ID
    WHERE STUD_ID=#{studId}
</select>
//使用了左外连接来查询
~~~

* 方式2： 使用嵌套结果 `ResultMap`进行映射   
	* 引入其他文件定义的`ResultMap`
		__使用标签`association` 引入__  

		~~~xml
		<resultMap type="Address" id="AddressResult">
  			<id property="addrId" column="addr_id" />
  			<result property="street" column="street" />
  			<result property="city" column="city" />
		</resultMap>
		<resultMap type="Student" id="StudentWithAddressResult">
  			<id property="studId" column="stud_id" />
  			<result property="name" column="name" />
  			<result property="email" column="email" />
  			<association property="address" resultMap="AddressResult" />
		</resultMap>
		~~~

		查询语句  

		~~~xml
		<select id="findStudentWithAddress" parameterType="int"
		resultMap="StudentWithAddressResult">
			SELECT STUD_ID, NAME, EMAIL, A.ADDR_ID, STREET, CITY, STATE, ZIP, COUNTRY
			FROM STUDENTS S LEFT OUTER JOIN ADDRESSES A ON S.ADDR_ID=A.ADDR_ID
    		WHERE STUD_ID=#{studId}
		</select>
		~~~
		
	* 本身内部嵌套 

		~~~xml 
		<resultMap type="Student" id="StudentWithAddressResult">
  			<id property="studId" column="stud_id" />
  			<result property="name" column="name" />
  			<result property="email" column="email" />
  			<association property="address" javaType="Address">
			    <id property="addrId" column="addr_id" />
    			<result property="street" column="street" />
    			<result property="city" column="city" />
    			<result property="state" column="state" />
    			<result property="zip" column="zip" />
    			<result property="country" column="country" />
  			</association>
		</resultMap>
		~~~
* 方式3： 使用其那套select查询语句  
 	每一个对应的对象实现自己的查询语句   
 	
 	~~~xml 
 	<resultMap type="Address" id="AddressResult">
  		<id property="addrId" column="addr_id" />
  		<result property="street" column="street" />
	</resultMap>
	
	//查询语句
 	<select id="findAddressById" parameterType="int"
resultMap="AddressResult">
    SELECT * FROM ADDRESSES WHERE ADDR_ID=#{id}
</select>

	<resultMap type="Student" id="StudentWithAddressResult">
  		<id property="studId" column="stud_id" />
 		<association property="address" column="addr_id" select="findAddressById" />
 	</resultMap>
 	<select id="findStudentWithAddress" parameterType="int"
		resultMap="StudentWithAddressResult">
    		SELECT * FROM STUDENTS WHERE STUD_ID=#{Id}
	</select>
 	~~~
 	
 	__注意嵌套查询:通过`association` 将另一个对象的查询语句嵌套进入, 并且此标签好像只能用于查询__  
 	
 
 一对一查询中内部的对象在数据库中对应的都是一个Id或者唯一标识值，所以此处底部的嵌套xml中的值都是id属性的  
 
 
### 一对多映射  
__使用`<collection>`元素将 一对多类型的结果 映射到 一个对象集合上__   

1. 使用嵌套对象形式显示

~~~java 
public class Tutor
{
    private Integer tutorId;
    private String name;
    private String email;
    private Address address;
    private List<Course> courses;
    / setters & getters
}
<resultMap type="Tutor" id="TutorResult">
  <id column="tutor_id" property="tutorId" />
  <result column="tutor_name" property="name" />
  <result column="email" property="email" />
  <collection property="courses" resultMap="CourseResult" />
</resultMap>


<select id="findTutorById" parameterType="int"
resultMap="TutorResult">
SELECT T.TUTOR_ID, T.NAME AS TUTOR_NAME, EMAIL, C.COURSE_ID,
C.NAME, DESCRIPTION, START_DATE, END_DATE
FROM TUTORS T LEFT OUTER JOIN ADDRESSES A ON T.ADDR_ID=A.ADDR_ID
LEFT OUTER JOIN COURSES C ON T.TUTOR_ID=C.TUTOR_ID
WHERE T.TUTOR_ID=#{tutorId}
</select>


~~~

2. 使用嵌套语句实现  
	
~~~xml 
<resultMap type="Tutor" id="TutorResult">
  <id column="tutor_id" property="tutorId" />
  <result column="tutor_name" property="name" />
  <result column="email" property="email" />
  <association property="address" resultMap="AddressResult" />
  <collection property="courses" column="tutor_id" select="findCoursesByTutor" />
</resultMap>



<select id="findTutorById" parameterType="int" resultMap="TutorResult">
    SELECT T.TUTOR_ID, T.NAME AS TUTOR_NAME, EMAIL
    FROM TUTORS T WHERE T.TUTOR_ID=#{tutorId}
</select>
<select id="findCoursesByTutor" parameterType="int" resultMap="CourseResult">
  SELECT * FROM COURSES WHERE TUTOR_ID=#{tutorId}
</select>

~~~  

__注意:__ 嵌套 Select 语句查询会导致 N+1 选择问. 首先,主查询将会执行(1 次),对于主 查询返回的每一行,另外一个查询将会被执行(主查询 N 行,则此查询 N 次)。对于 大型数据库而言,这会导致很差的性能问题。   

## 动态SQL  
mybatis 提供: `<if>`,`<choose>`,`<where>`,`<foreach>`,`<trim>` 进行构造动态SQL   

### 1. if  

~~~xml 
<select id="searchCourses" parameterType="hashmap" resultMap="CourseResult"></select>
    SELECT * FROM COURSES
        WHERE TUTOR_ID= #{tutorId}
    <if test="courseName != null">
    AND NAME LIKE #{courseName}
    </if>
</select>
~~~
当if中test条件成立时， 才会添加if中的内容到SQL语句中  

### choose, when, otherwise  

~~~xml  
<select id="searchCourses" parameterType="hashmap" resultMap="CourseResult">
    SELECT * FROM COURSES
    <choose>
        <when test="searchBy == 'Tutor'">
            WHERE TUTOR_ID= #{tutorId}
        </when>
        <when test="searchBy == 'CourseName'">
            WHERE name like #{courseName}
        </when>
        <otherwise>
            WHERE TUTOR start_date >= now()
        </otherwise>
    </choose>
</select>
~~~  
__mybatis计算`<choose>` 测试条件的值，且使用第一个值为true的子句， 如果没有条件为true，则使用<otherwise> 内的子句。


### where  

~~~xml 
<select id="searchCourses" parameterType="hashmap"
resultMap="CourseResult">
    SELECT * FROM COURSES
    <where>
        <if test=" tutorId != null ">
            TUTOR_ID= #{tutorId}
        </if>
        <if test="courseName != null">
            AND name like #{courseName}
        </if>
        <if test="startDate != null">
            AND start_date >= #{startDate}
        </if>
        <if test="endDate != null">
            AND end_date <= #{endDate}
        </if>
    </where>
</select>
~~~  

###  trim  

~~~
<select id="searchCourses" parameterType="hashmap" resultMap="CourseResult">
 	SELECT * FROM COURSES
<trim prefix="WHERE" prefixOverrides="AND | OR"> 
	 <if test=" tutorId != null ">
	 	TUTOR_ID= #{tutorId}
	 </if>  
	 <if test="courseName != null">
		AND name like #{courseName}
	 </if>
	</trim>
</select>

~~~

### foreach  

~~~xml   
<select id="searchCoursesByTutors" parameterType="map"
resultMap="CourseResult">
SELECT * FROM COURSES
<if test="tutorIds != null">
<where>
<foreach item="tutorId" collection="tutorIds">
OR tutor_id=#{tutorId}
</foreach>
</where>
</if>
</select>
~~~


## mybatis Other  
### 处理枚举  
1. 存储枚举名  
	默认情况下mybatis支持开箱方式持久化枚举类型属性， 其通过`EnumTypeHandler`来处理枚举类型与Java类型对应  
	默认是使用字符串进行存储的，数据表中对应的是枚举对应的字符串  

2. 存储枚举对应的int类型值  
	需要将枚举对应的handler修改为以下类  
	
	~~~
	<typeHandler
	handler="org.apache.ibatis.type.EnumOrdinalTypeHandler"
	javaType="com.mybatis3.domain.Gender"/>
	~~~
	__还是建议使用默认的形式的，使用顺序的如果改变了枚举对应的顺序，数据库中值就无法对应上了__  

### 处理 blob类型  
默认情况下，mybatis将CLOB类型的列映射到 `java.lang.String`类型上，
将BLOB 映射到`byte[]`类型上  

### 多个参数  
1. 使用map形式引入  
	
	~~~xml 
	<select id="findAllStudentsByNameEmail" resultMap="StudentResult" parameterType="map">
    select stud_id, name,email, phone from Students
        where name=#{name} and email=#{email}
	</select>
	
	~~~
  
2. 使用参数替代 

	~~~xml 
	<select id="findAllStudentsByNameEmail" resultMap="StudentResult">
    select stud_id, name,email, phone from Students
        where name=#{param1} and email=#{param2}
	</select>
	~~~


### 缓存  
默认情况下，mybatis开启一级缓存，对select进行缓存支持。 可以通过`<cache>`开启二级缓存   
开启耳机缓存的同时引发的问题：  
* 所有在映射语句文件定义的 `<select>` 语句的查询结果都会被缓存  
* 所有的在映射语句文件定义的<insert>,<update> 和<delete>语句将会刷新缓存  
* 缓存根据最近最少被使用(Least Recently Used,LRU)算法管理  
* 缓存不会被任何形式的基于时间表的刷新(没有刷新时间间隔),即不支持定时刷新机制  
* 缓存将存储1024个 查询方法返回的列表或者对象的引用  
* 缓存会被当作一个读/写缓存。这是指检索出的对象不会被共享,并且可以被调用者安全地修改,不会其他潜 在的调用者或者线程的潜在修改干扰。(即,缓存是线程安全的)
  
  
~~~xml 
<cache eviction="FIFO" flushInterval="60000" size="512"
readOnly="true"/>
~~~

__说明:__
* eviction  
	* LRU  : 最近很少使用  
	* FIFO : 先进先出  
	* SOFT : 软引用
	* WEAK : 若引用  
* flushInterval(定义刷新时间)  
* size 大小 
* readOnly 只读


# 第四章 注解配置SQL映射器  
1. 基于注解的一些内容：  
	* `INSERT`
	* `UPDATE`
	* `SELECT`
	* `DELETE`  

2. 基本使用  
	
	~~~java 
	@Insert("INSERT INTO STUDENTS(NAME,EMAIL,ADDR_ID, PHONE)
        VALUES(#{name},#{email},#{address.addrId},#{phone})")
  	//通过以下注解实现主键 
  	@Options(useGeneratedKeys = true, keyProperty = "studId")
	//通过此注解为任意SQL语句指定主键值(使用此注解生成主键)
	@SelectKey(statement="SELECT STUD_ID_SEQ.NEXTVAL FROM DUAL",
	keyProperty="studId", resultType=int.class, before=true)
	//使用触发器生成
	@SelectKey(statement="SELECT STUD_ID_SEQ.CURRVAL FROM DUAL",
	keyProperty="studId", resultType=int.class, before=false)
	//结果集映射  
	@Results(
    {
        @Result(id = true, column = "stud_id", property = "studId"),
        @Result(column = "name", property = "name"),
        @Result(column = "email", property = "email"),
        @Result(column = "addr_id", property = "address.addrId")
	})
	~~~
	
	* 一对一映射   
		* 嵌套sql语句形式 
		
		~~~java 
		//使用嵌套select 语句实现
		@Results(
		{
        @Result(id = true, column = "stud_id", property = "studId"),
        @Result(column = "name", property = "name"),
        @Result(column = "email", property = "email"),
        @Result(property = "address", column = "addr_id",
        one = @One(select = "com.mybatis3.mappers.StudentMapper.
        findAddressById"))
    	})
		~~~
		
		* 嵌套对象  
			此种方式并没有注解形式的实现 ，可以通过在XML中定义映射`resultMap`集，然后通过`@ResultMap`进行映射  
			
			~~~java 
			@ResultMap("com.mybatis3.mappers.StudentMapper.
                           StudentWithAddressResult")
			~~~
	* 一对多映射  
		同样的只有嵌套SQL的形式  
		
		~~~java 
		 @Result(property = "courses", column = "tutor_id",
        many = @Many(select = "com.mybatis3.mappers.TutorMapper.
        findCoursesByTutorId"))
		~~~
	
		

3. 遇到的问题  
	* 结果集不能重用，因为无法赋予id， 所以无法重用，哪怕相同都必须重写写  
		可以通过一个xml进行映射  
		
		~~~xml 
		<mapper namespace="com.mybatis3.mappers.StudentMapper">
          <resultMap type="Student" id="StudentResult">
            <id property="studId" column="stud_id" />
            <result property="name" column="name" />
            <result property="email" column="email" />
            <result property="phone" column="phone" />
          </resultMap>
        </mapper>

        	//通过此种方式解决无法重用的问题
         @Select("SELECT * FROM STUDENTS WHERE STUD_ID=#{studId}")
   	 	  @ResultMap("com.mybatis3.mappers.StudentMapper.StudentResult")
		~~~
	* 针对动态SQL通过工具类的方式生成SQL语句  

		~~~xml 
		return new SQL()
        {
            {
                SELECT("tutor_id as tutorId, name, email");
                FROM("tutors");
                 WHERE("tutor_id=" + tutorId);
              }
        } .toString();
    	}		
		~~~
	


4. 动态SQL映射  
	* 创建动态SQL映射类  
		
		~~~java 
		public class TutorDynaSqlProvider
		{
    		public String findTutorByIdSql(int tutorId)
    		{
				return "SELECT TUTOR_ID AS tutorId, NAME, EMAIL FROM TUTORS
       WHERE TUTOR_ID=" + tutorId;
			} 
		}
		public String findTutorByNameAndEmailSql(Map<String, Object> map)
		{
    		String name = (String) map.get("param1");
    		String email = (String) map.get("param2");
    		//you can also get those values using 0,1 keys
    		//String name = (String) map.get("0");
    		//String email = (String) map.get("1");
    		return new SQL()
    		{
        		{
            		SELECT("tutor_id as tutorId, name, email");
            		FROM("tutors");
            		WHERE("name=#{name} AND email=#{email}");
        		}
    		} .toString();
		}
		~~~
	
	* 添加动态SQL注解到方法上  
		
		~~~java 
		@SelectProvider(type=TutorDynaSqlProvider.class, method="findTutorByIdSql")
		Tutor findTutorById(int tutorId);
		~~~
	
	
# 第五章 spring 集成  
1. 配置mybatis beans  
	`applicationContext.xml` 中添加  
	
~~~xml  
<beans>
  <bean id="dataSource" class="org.springframework.jdbc.datasource. DriverManagerDataSource">
    <property name="driverClassName" value="com.mysql.jdbc.Driver" />
    <property name="url" value="jdbc:mysql://localhost:3306/elearning" />
    <property name="username" value="root" />
    <property name="password" value="admin" />
  </bean>
  <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
<property name="dataSource" ref="dataSource" />
<property name="typeAliases" value="com.mybatis3.domain.Student, com.mybatis3.domain.Tutor" /> <property name="typeAliasesPackage" value="com.mybatis3.domain" />
<property name="typeHandlers" value="com.mybatis3.typehandlers.PhoneTypeHandler" />
<property name="typeHandlersPackage" value="com.mybatis3.typehandlers" />
<property name="mapperLocations" value="classpath*:com/mybatis3/**/*.xml" />
<property name="configLocation" value="WEB-INF/mybatisconfig.xml" />
  </bean>
</beans>

<bean id="sqlSession" class="org.mybatis.spring.SqlSessionTemplate">
  <constructor-arg index="0" ref="sqlSessionFactory" />
</bean>
~~~	
通过此种方式配置就可以引用sqlSession   

~~~xml 
<bean class="org.mybatis.spring.mapper.MapperScannerConfigurer"> 
	<property name="basePackage" value="com.mybatis3.mappers" />
</bean>
~~~
通过以上的方式扫描包中的映射器Mapper接口， 并自动注册   

mybatis关于mapper扫描有两种方式  ：  
	* 使用XML形式  
		` <mybatis:scan base-package="com.mybatis3.mappers" />`
	* 使用`@MapperScan`注解  
		
	



























