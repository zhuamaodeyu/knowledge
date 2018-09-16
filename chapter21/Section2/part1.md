#myabtis 源码分析 ----- 调试环境搭建   
## 完成状态  

- [ ] 开发中
- [ ] 未完成
- [ ] 已完成
- [x] 维护中
## 简介
`mybatis`: 是一个简化和实现了Java数据持久层的开源框架爱，抽象和大量的jdbc冗余代码，提供简单的API和数据库交互，本系列文章主要针对mybatis进行源码分析，通过阅读源码了解其内部实现原理，进行更加深入的学习。针对mybatis 使用学习，可以参考其他文章    


### 依赖环境  
* Maven  
* JDK  
* IDEA 

### 获取源码 
在进行第三方库分析时，我们应该fork出自己的仓库，这样更有利于针对源码的注解添加等。 从官方仓库[mybatis](https://github.com/mybatis/mybatis-3.git) fork 出自己的仓库并通过IDEA 打开项目构建测试环境    

### 测试环境  
0. 创建数据库表 
    ![20180913153684051437963.png](http://ozjlhf9e0.bkt.clouddn.com/20180913153684051437963.png)   

1. 用户类    
    创建测试用户类
    ```java 

    public class User {

        private  long  id;
        private  String name;
        private  String address;
        private  int age;
        // get/set 方法
    }
    ```   

2. 用户mapper接口类    
    创建测试Mapper 接口类  
    ```java  
    public interface UserMapper {
        List<User> selectUserList();
    }
    ```

3. 用户mapper xml      
    创建测试mapper.xml 
    ```xml
    <?xml version="1.0" encoding="UTF-8" ?>
    <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >

    <mapper namespace="test.mapper.UserMapper">
        <select id="selectUserList" resultType="test.entity.User">
            select * from t_user
        </select>
    </mapper>
    ```   
4. mybatis 配置类     
    配置mybatis     
    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE configuration
            PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
            "http://mybatis.org/dtd/mybatis-3-config.dtd">
    <configuration>
        <properties resource="db.properties">
            <!--<property name="username" value="dev_user"/>-->
            <!--<property name="password" value="F2Fa3!33TYyg"/>-->
        </properties>

        <environments default="development">
            <environment id="development">
                <transactionManager type="JDBC"/>
                <dataSource type="POOLED">
                    <property name="driver" value="${driver}"/>
                    <property name="url" value="${url}"/>
                    <property name="username" value="${username}"/>
                    <property name="password" value="${password}"/>
                </dataSource>
            </environment>
        </environments>
        <mappers>
            <mapper resource="test/mapper/UserMapper.xml"/>
        </mappers>
    </configuration>
    ```   
    数据库配置    
    ```properties    
    driver=com.mysql.jdbc.Driver
    url=jdbc:mysql://127.0.0.1:33060/test?useUnicode=true&ssl=false&characterEncoding=utf8
    username=root
    password=root
    ```   

5. 测试代码     
    测试代码
    ```java
    public class Main {
        public static void main(String[] args) throws IOException {
            System.out.println("==============测试mybatis");

            // 加载配置
            String resource = "mybatis.xml";
            // 读取配置
            InputStream inputStream = Resources.getResourceAsStream( resource );

            SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
            // 获取session
            SqlSession session = sqlSessionFactory.openSession();
            try {
                // 执行查询操作
                UserMapper productMapper = session.getMapper(UserMapper.class);
                List<User> users = productMapper.selectUserList();
                for (User user : users) {
                    System.out.printf(user.toString());
                }
            } finally {
                session.close();
            }

        }
    }
    ```    

通过以上代码实现了mybatis的测试代码，接下来的章节中将对mybatis源码进行深入分析  
