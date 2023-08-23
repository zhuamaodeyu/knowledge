# mybatis 源码分析------ XMLStatementBuilder 解析SQL   

## 完成状态  

- [x] 开发中
- [ ] 未完成
- [ ] 已完成
- [ ] 维护中


## 前言 
通过上节内容分析，针对`XMLStatementBuilder` 进行了简单介绍，不过由于其过于复杂以及牵扯甚多，所以本节单独针对其进行详细的解析  


## XMLStatementBuilder  
`XMLStatementBuilder` 是进行`XXXMapper.xml`文件中具体的内容解析的部分内容解析的，主要涉及的是`select,insert,delete,update` 等节点的SQL语句解析。此类继承自`BaseBuilder` 。下面将给出一个简单的`xml` 示例。 更直观的展现此类的作用  
```xml 
  <!-- select -->
<select id="selectByPrimaryKey" parameterType="java.lang.Integer" resultMap="BaseResultMap">
    select
    <include refid="Base_Column_List" />
    from t_question_favour
    where id = #{id,jdbcType=INTEGER}
  </select>
  <!-- delete -->
<delete id="deleteByPrimaryKey" parameterType="java.lang.Integer">
    delete from t_question_favour
    where id = #{id,jdbcType=INTEGER}
  </delete>
  <!-- insert -->
<insert id="insert" parameterType="com.catchcatfish.generator.question.entity.TQuestionFavour">
    <selectKey keyProperty="id" resultType="int" order="BEFORE">
      SELECT nextval('t_question_favour_id_seq'::regclass) as id
    </selectKey>
    insert into t_question_favour (id, favour_id, question_id,
      user_id, is_cancel, create_at,
      update_at)
    values (#{id,jdbcType=INTEGER}, #{favourId,jdbcType=VARCHAR}, #{questionId,jdbcType=VARCHAR},
      #{userId,jdbcType=VARCHAR}, #{isCancel,jdbcType=BIT}, NOW(),
      NOW())
  </insert>
  <!-- update -->
<update id="updateByPrimaryKeySelective" parameterType="com.catchcatfish.generator.question.entity.TQuestionFavour">
    update t_question_favour
    <set>
      <if test="favourId != null">
        favour_id = #{favourId,jdbcType=VARCHAR},
      </if>
      <if test="questionId != null">
        question_id = #{questionId,jdbcType=VARCHAR},
      </if>
      <if test="userId != null">
        user_id = #{userId,jdbcType=VARCHAR},
      </if>
      <if test="isCancel != null">
        is_cancel = #{isCancel,jdbcType=BIT},
      </if>
      <if test="createAt != null">
        create_at = #{createAt,jdbcType=TIMESTAMP},
      </if>
        update_at = NOW(),
    </set>
    where id = #{id,jdbcType=INTEGER}
  </update>
```  
此类遵循和其兄弟类(`XMLConfigBuilder`,`XMLMapperBuilder`等)相同的设计原则，并不在构造函数中进行任何的操作。其具体的操作在`parseStatementNode()` 中实现。 接下来将对其进行详细解析   
首先，在具体的分析解析代码之前，先看看本类的初始化构造函数：  
```java 
  public XMLStatementBuilder(Configuration configuration, MapperBuilderAssistant builderAssistant, XNode context, String databaseId) {
    super(configuration);
    this.builderAssistant = builderAssistant;
    this.context = context;
    this.requiredDatabaseId = databaseId;
  }
```  
本类的构造函数比较简单，其通过4个参数进行初始化， `configuration` 是项目解析配置构建的； `builderAssistant` 是对mapper 文件解析之时生成的辅助类对象; `context` 当前解析的SQL节点;`databaseId` 默认配置的数据库ID   

__本类之时对单个`update,insert,select,delete` 节点进行解析__

接下来介绍具体的解析实现方式：   

```java 
public void parseStatementNode() {
    // 获取ID
    String id = context.getStringAttribute("id");
    // 获取数据库ID
    String databaseId = context.getStringAttribute("databaseId");
    //1. 验证数据库是否正确
    if (!databaseIdMatchesCurrent(id, databaseId, this.requiredDatabaseId)) {
      return;
    }
    //2. 获取属性值
    Integer fetchSize = context.getIntAttribute("fetchSize");
    Integer timeout = context.getIntAttribute("timeout");
    String parameterMap = context.getStringAttribute("parameterMap");
    String parameterType = context.getStringAttribute("parameterType");
    Class<?> parameterTypeClass = resolveClass(parameterType);
    String resultMap = context.getStringAttribute("resultMap");
    String resultType = context.getStringAttribute("resultType");
    String lang = context.getStringAttribute("lang");
    // 此处没明白
    LanguageDriver langDriver = getLanguageDriver(lang);
    // 返回类型
    Class<?> resultTypeClass = resolveClass(resultType);
    String resultSetType = context.getStringAttribute("resultSetType");
    // 3. 参数类型 statement , prepared , callable
    StatementType statementType = StatementType.valueOf(context.getStringAttribute("statementType", StatementType.PREPARED.toString()));
    //4. 
    ResultSetType resultSetTypeEnum = resolveResultSetType(resultSetType);
    // 节点名称 此处为select
    String nodeName = context.getNode().getNodeName();
    //5.获取命令  将节点转大写
    SqlCommandType sqlCommandType = SqlCommandType.valueOf(nodeName.toUpperCase(Locale.ENGLISH));

    boolean isSelect = sqlCommandType == SqlCommandType.SELECT;
    //缓存操作
    boolean flushCache = context.getBooleanAttribute("flushCache", !isSelect);
    boolean useCache = context.getBooleanAttribute("useCache", isSelect);
    boolean resultOrdered = context.getBooleanAttribute("resultOrdered", false);
    //6. 
    // Include Fragments before parsing
    XMLIncludeTransformer includeParser = new XMLIncludeTransformer(configuration, builderAssistant);
    includeParser.applyIncludes(context.getNode());
    //7. 
    // Parse selectKey after includes and remove them.
    processSelectKeyNodes(id, parameterTypeClass, langDriver);
    //8. 
    // Parse the SQL (pre: <selectKey> and <include> were parsed and removed)
    SqlSource sqlSource = langDriver.createSqlSource(configuration, context, parameterTypeClass);
    String resultSets = context.getStringAttribute("resultSets");
    String keyProperty = context.getStringAttribute("keyProperty");
    String keyColumn = context.getStringAttribute("keyColumn");
    KeyGenerator keyGenerator;
    String keyStatementId = id + SelectKeyGenerator.SELECT_KEY_SUFFIX;
    keyStatementId = builderAssistant.applyCurrentNamespace(keyStatementId, true);
    if (configuration.hasKeyGenerator(keyStatementId)) {
      keyGenerator = configuration.getKeyGenerator(keyStatementId);
    } else {
      keyGenerator = context.getBooleanAttribute("useGeneratedKeys",
          configuration.isUseGeneratedKeys() && SqlCommandType.INSERT.equals(sqlCommandType))
          ? Jdbc3KeyGenerator.INSTANCE : NoKeyGenerator.INSTANCE;
    }

    builderAssistant.addMappedStatement(id, sqlSource, statementType, sqlCommandType,
        fetchSize, timeout, parameterMap, parameterTypeClass, resultMap, resultTypeClass,
        resultSetTypeEnum, flushCache, useCache, resultOrdered,
        keyGenerator, keyProperty, keyColumn, databaseId, langDriver, resultSets);
  }
```

1. 数据库验证  
  ```java 
  private boolean databaseIdMatchesCurrent(String id, String databaseId, String requiredDatabaseId) {
    // 默认配置判断 
    if (requiredDatabaseId != null) {
      if (!requiredDatabaseId.equals(databaseId)) {
        return false;
      }
    } else {
      if (databaseId != null) {
        return false;
      }
      // skip this statement if there is a previous one with a not null databaseId  
      // 生成新的ID 
      id = builderAssistant.applyCurrentNamespace(id, false);
      if (this.configuration.hasStatement(id, false)) {
        MappedStatement previous = this.configuration.getMappedStatement(id, false); // issue #2
        if (previous.getDatabaseId() != null) {
          return false;
        }
      }
    }
    return true;
  }
  ```  
注意看这里。由于mybatis支持配置不同的数据库。所以部分配置需要在指定的数据库下才会有效，此处通过对`databaseId`进行操作验证是否对节点进行解析。主要包含以下几步：  
* 首先验证是否指定了全局配置ID。如果指定，需要与当前配置ID 进行比较，如果不相同，说明当前节点在全局指定的`databaseId`下是无效的，本次不需要解析此节点   
*  全局指定ID 与当前ID 验证通过，针对当前解析节点以及其命名空间进行处理，生成一个全局唯一的新的节点ID   
* 验证是否已经对当前节点进行缓存，并从缓存中取出再次对ID进行校验   

__注意，此处遗留一个问题，就是在验证ID 是否缓存时对某些属性的验证__   

2. 获取配置属性  
  通常情况下，我们只需要关注可配置属性中部分属性即可。比如：`parameterType`, 针对参数的配置以及`resultMap`,`resultType`，`resultSetType`针对结果的配置。   
  > mybatis 官方文档对其详细参数进行了说明，详情请查看mybatis官方文档    

  此处需要注意，获取`parameterType`,`resultType`后，此处对其进行了校验  
  ```java 
  protected <T> Class<? extends T> resolveAlias(String alias) {
    return typeAliasRegistry.resolveAlias(alias);
  }
  public <T> Class<T> resolveAlias(String string) {
    try {
      if (string == null) {
        return null;
      }
      // issue #748
      String key = string.toLowerCase(Locale.ENGLISH);
      Class<T> value;

      if (TYPE_ALIASES.containsKey(key)) {
        value = (Class<T>) TYPE_ALIASES.get(key);
      } else {
        value = (Class<T>) Resources.classForName(string);
      }
      return value;
    } catch (ClassNotFoundException e) {
      throw new TypeException("Could not resolve type alias '" + string + "'.  Cause: " + e, e);
    }
  }
  ```
  以上具体的操作是在`TypeAliasRegistry`类中进行的，此类是针对可能存在的数据类型与Java数据类型类进行对应关系建立和缓存操作。此处通过此种方式，__验证给定的配置属性参数是否合法,以避免后续出现不必要的错误__   

6. `XMLIncludeTransformer`  
  此类是针对SQL内容的解析操作，由于mybatis丰富的SQL语句配置形式，其并不是直接进行SQL语句编写，其中可能进行各种复杂的嵌套等形式，比如：  
  ```xml  
  <insert id="insert" parameterType="com.catchcatfish.generator.question.entity.TQuestionFavour">
    <selectKey keyProperty="id" resultType="int" order="BEFORE">
      SELECT nextval('t_question_favour_id_seq'::regclass) as id
    </selectKey>
    <!-- sql -->
  </insert>
  <select id = "countAll" resultType="int"> 
    select count(1) from(
                   select 
                        stud_id as studId
                        , name, email
                        , dob
                        , phone
                    from students
                <sql id="studentProperties">
                    select 
                        stud_id as studId
                        , name, email
                        , dob
                        , phone
                    from students
                </sql>
        ) tmp
    )
  </select>
  ```
  > 以上部分代码来自网络，如有侵权请告知。   

  此类就是应付此类复杂配置，针对其进行解析而存在的，通过解析将其合并成可执行的SQL代码 ，接下来将针对解析其内部具体实现   
  * 初始化过程  
    ```java 
    XMLIncludeTransformer includeParser = new XMLIncludeTransformer(configuration, builderAssistant);
    includeParser.applyIncludes(context.getNode());
    ```   
    通过传入当前配置以及解析辅助对象`builderAssistant`来进行初始化 。并调用`applyIncludes`方法传入当前需要解析的节点进行解析  
  * 解析  
    ```java 
    public void applyIncludes(Node source) {
      // 获取配置并合并已存在配置(此处是数据库配置)
        Properties variablesContext = new Properties();
        Properties configurationVariables = configuration.getVariables();
        if (configurationVariables != null) {
          variablesContext.putAll(configurationVariables);
        }
        applyIncludes(source, variablesContext, false);
      }
    private void applyIncludes(Node source, final Properties variablesContext, boolean included) {
        if (source.getNodeName().equals("include")) {
          Node toInclude = findSqlFragment(getStringAttribute(source, "refid"), variablesContext);
          Properties toIncludeContext = getVariablesContext(source, variablesContext);
          applyIncludes(toInclude, toIncludeContext, true);
          if (toInclude.getOwnerDocument() != source.getOwnerDocument()) {
            toInclude = source.getOwnerDocument().importNode(toInclude, true);
          }
          source.getParentNode().replaceChild(toInclude, source);
          while (toInclude.hasChildNodes()) {
            toInclude.getParentNode().insertBefore(toInclude.getFirstChild(), toInclude);
          }
          toInclude.getParentNode().removeChild(toInclude);
        } else if (source.getNodeType() == Node.ELEMENT_NODE) {
          if (included && !variablesContext.isEmpty()) {
            // replace variables in attribute values
            NamedNodeMap attributes = source.getAttributes();
            for (int i = 0; i < attributes.getLength(); i++) {
              Node attr = attributes.item(i);
              attr.setNodeValue(PropertyParser.parse(attr.getNodeValue(), variablesContext));
            }
          }
          NodeList children = source.getChildNodes();
          for (int i = 0; i < children.getLength(); i++) {
            applyIncludes(children.item(i), variablesContext, included);
          }
        } else if (included && source.getNodeType() == Node.TEXT_NODE
            && !variablesContext.isEmpty()) {
          // replace variables in text node
          source.setNodeValue(PropertyParser.parse(source.getNodeValue(), variablesContext));
        }
      }

    ```




## 总结  



## Question And Answer  
### Question 1 


### Answer 1  
