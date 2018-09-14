#mybatis 源码分析------Mapper 文件解析  
## 前言 
上一节中主要介绍了 mybatis 配置文件的解析，其中涉及到`<mappers>` 节点解析时，并引申出了关于`mapper`配置文件解析。本节主要围绕上节介绍，更加深入的分析 `mapper`文件解析  


### Mapper.xml 解析  
从上节内容了解到 Mapper 文件解析是通过`XMLMapperBuilder`类来实现的，`MapperBuilderAssistant`类给予辅助工作  
```java
  private XMLMapperBuilder(XPathParser parser, Configuration configuration, String resource, Map<String, XNode> sqlFragments) {
      // 将上个对象中的configuration传入父类中
    super(configuration);
    this.builderAssistant = new MapperBuilderAssistant(configuration, resource);
    this.parser = parser;
    this.sqlFragments = sqlFragments;
    this.resource = resource;
  }
```
> 以上是 `XMLMapperBuilder` 构造函数    

具体的解析工作和 `XMLConfigBuilder`相似，并不在构造函数中进行，而在`parse`方法中进行  
```java 
  public void parse() {
    // 1. 判断当前 resource 对应的xml 文件是否被加载过(也就是解析过)
    if (!configuration.isResourceLoaded(resource)) {
      // 2. 解析 mapper
      configurationElement(parser.evalNode("/mapper"));
      // 3. 缓存起来
      configuration.addLoadedResource(resource);
      // 4. 
      bindMapperForNamespace();
    }
    // 5. 
    parsePendingResultMaps();
    parsePendingCacheRefs();
    parsePendingStatements();
  }
```
> 以上是mapper 具体解析过程   

1. 验证    
    由于此处的内容是用户输入的，可能存在多次输入相同配置，那么在此处需要经过验证将已经解析过的配置过滤掉。`configuration`对象中将已经解析过的`mapper`文件进行了缓存，当再次遇到相同的文件时不进行解析。 此处引申出一个问题: 根据上文内容了解到，mapper 此处的配置分为多种形式，那么此处是如何判断当前这个mapper.xml 已经被加载过????   
    * 验证以上问题  
        ```xml
        <mappers>
                <mapper resource="test/mapper/UserMapper.xml"/>
                <mapper url="file:///Users/niezi/Desktop/Source/mybatis-3-master/src/main/java/test/mapper/UserMapper.xml"/>
            </mappers>
        ```
        具体的验证 
        ```java
        //loadedResources 是一个Set 结构
        public void addLoadedResource(String resource) {
            loadedResources.add(resource);
        }

        public boolean isResourceLoaded(String resource) {
            return loadedResources.contains(resource);
        }
        ```
        通过对此处代码分析，其验证的根据是`resource`资源的访问路径，根据以上配置，通过`resoource`和`url`的形式配置，其虽然两属性可以同时指向一个文件，但是其并不能避免这个文件被解析多次，因为`resoource`和`url` 的值是不同的，所以Set验证是可以通过的，文件还是被解析。不过其内部还是更深层次的针对文件内容进行验证的。此处的结论:__文件还是会被解析，但由于两个路径指向的是同一个文件，内容相同，更深层次的文件内容验证不会通过，所以此处还是会报异常__    
2. 解析    
    ```java
    private void configurationElement(XNode context) {
        try {
        // 命名空间
        String namespace = context.getStringAttribute("namespace");
        // 验证命名空间
        if (namespace == null || namespace.equals("")) {
            throw new BuilderException("Mapper's namespace cannot be empty");
        }
        // 赋值namespace
        builderAssistant.setCurrentNamespace(namespace);
        // 解析<cache-ref>节点
        cacheRefElement(context.evalNode("cache-ref"));
        // 解析<cache> 节点
        cacheElement(context.evalNode("cache"));
        // 解析 parameterMap 节点
        parameterMapElement(context.evalNodes("/mapper/parameterMap"));
        resultMapElements(context.evalNodes("/mapper/resultMap"));
        // 解析SQL节点
        sqlElement(context.evalNodes("/mapper/sql"));
        // 解析sql语句
        buildStatementFromContext(context.evalNodes("select|insert|update|delete"));
        } catch (Exception e) {
        throw new BuilderException("Error parsing Mapper XML. The XML location is '" + resource + "'. Cause: " + e, e);
        }
    }
    ```
    以上是具体的解析过程，针对不同的节点进行解析,通过以上内容可以反推出此处支持的配置节点  
    * 解析`<cache-ref>`节点    
    * 解析`<cache>` 节点  
    * 解析 `<parameterMap>` 节点  
    * 解析`<sql>`节点  
    通过以上方式，解析了XML节点，但是其中还是有很重要的一点，那就是解析SQL语句  
    * __解析SQL语句__

3. 缓存     
    在每次解析之前都会验证此文件是否已经被解析过了，此处解析已经完毕，需要将此文件进行缓存以标记已解析   

4. `bindMapperForNamespace()`  
    通过以上的方式完成了XML的解析工作。  
    ```java 
        private void bindMapperForNamespace() {
            // 获取当前映射文件对应的DAO接口全限定名称(parse方法填入的命名空间)
            String namespace = builderAssistant.getCurrentNamespace();
            if (namespace != null) {
            Class<?> boundType = null;
            try {
                // 解析成Class对象
                boundType = Resources.classForName(namespace);
            } catch (ClassNotFoundException e) {
                //ignore, bound type is not required
            }
            if (boundType != null) {
                if (!configuration.hasMapper(boundType)) {
                // Spring may not know the real resource name so we set a flag
                // to prevent loading again this resource from the mapper interface
                // look at MapperAnnotationBuilder#loadXmlResource
                // 标记当前加载资源
                configuration.addLoadedResource("namespace:" + namespace);
                // 将DAO接口的Class对象注册进configuration中
                configuration.addMapper(boundType);
                }
            }
            }
        }
    ```
    此方法的作用就是注册Mpper 对应接口类，其中需要注意的地方是`configuration.addLoadedResource("namespace:" + namespace);`  此处为什么会再次进行标记呢？   
    由于mapper 可以通过多种形式进行解析，一个mapper 文件对应一个 `Mapper interface`接口类，之前`parse` 中标记的是以XML路径的形式进行标记的，此种方式可以避免一个mapper 配置文件被多次加载，通过此处再次标记，可以避免mapper 通过 interface的形式再次被注册。双重过滤    
    * configuration 中 mapper 注册存储  
        以上代码中通过`configuration.addMapper(boundType);`方法将mapper 接口类进行注册。其内部是通过一个`MapperRegistry`类实现存储的，并且在存储的过程中，通过给定义的接口类名为其生成一个代理对象工厂`MapperProxyFactory`       
        ```java 
        public <T> void addMapper(Class<T> type) {
            // 验证当前传进来的是 不是接口类型 Mapper 都是接口类
            if (type.isInterface()) {
            // 判断是否已经存在
            if (hasMapper(type)) {
                throw new BindingException("Type " + type + " is already known to the MapperRegistry.");
            }
            //
            boolean loadCompleted = false;
            try {
                //创建一个代理对象
                knownMappers.put(type, new MapperProxyFactory<T>(type));
                // It's important that the type is added before the parser is run
                // otherwise the binding may automatically be attempted by the
                // mapper parser. If the type is already known, it won't try.
                 // 解析注解 如果注解解析失败 那么就删除 type
                MapperAnnotationBuilder parser = new MapperAnnotationBuilder(config, type);
                parser.parse();
                loadCompleted = true;
            } finally {
                if (!loadCompleted) {
                knownMappers.remove(type);
                }
            }
            }
        }

        ```   
        注意: 存储的形式是hashMap 结构的，`type  = new MapperProxyFactory<T>(type)`   
        那么此处为什么要生成一个代理工厂类对象并对其进行存储??  
        __此处内容会涉及到下一节 `SqlSession` 的操作部分，此处暂且略过，下一节进行详细说明(和Mapper的获取有关)__      
        * `MapperProxyFactory` 类  
            ```java 
            public class MapperProxyFactory<T> {
            // 创建时传入的Class 对象
            private final Class<T> mapperInterface;
            // 缓存当前
            private final Map<Method, MapperMethod> methodCache = new ConcurrentHashMap<Method, MapperMethod>();

            public MapperProxyFactory(Class<T> mapperInterface) {
                this.mapperInterface = mapperInterface;
            }

            public Class<T> getMapperInterface() {
                return mapperInterface;
            }

            public Map<Method, MapperMethod> getMethodCache() {
                return methodCache;
            }
            // 生成代理对象， 
            @SuppressWarnings("unchecked")
            protected T newInstance(MapperProxy<T> mapperProxy) {
                return (T) Proxy.newProxyInstance(mapperInterface.getClassLoader(), new Class[] { mapperInterface }, mapperProxy);
            }
            
            public T newInstance(SqlSession sqlSession) {
                final MapperProxy<T> mapperProxy = new MapperProxy<T>(sqlSession, mapperInterface, methodCache);
                return newInstance(mapperProxy);
            }

            }
            ```
            从内容上来看，此类并不复杂，但其在下一节中的Session 操作起着至关重要的功能，此处只是简单介绍其功能，下一届中再详细介绍其作用和操作过程  



## 总结 
自此，整个mybatis的初始化工作已经完毕。
通过以上两篇内容，详细说名了XML文件的解析过程，其映射到示例代码中是 
```java 
        String resource = "mybatis.xml";
        InputStream inputStream = Resources.getResourceAsStream( resource );
        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
```
整个项目的初始化工作即将完成，接下来将详细介绍`SqlSession` 的工作原理及源码分析  


