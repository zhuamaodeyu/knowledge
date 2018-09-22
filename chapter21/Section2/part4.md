#mybatis 源码分析------ XMLStatementBuilder 解析SQL   

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
```java 
public void parseStatementNode() {
    // 获取ID
    String id = context.getStringAttribute("id");
    // 获取数据库ID
    String databaseId = context.getStringAttribute("databaseId");
    // 验证数据库是否正确
    if (!databaseIdMatchesCurrent(id, databaseId, this.requiredDatabaseId)) {
      return;
    }
    //1. 获取属性值
    Integer fetchSize = context.getIntAttribute("fetchSize");
    Integer timeout = context.getIntAttribute("timeout");
    String parameterMap = context.getStringAttribute("parameterMap");
    String parameterType = context.getStringAttribute("parameterType");
    Class<?> parameterTypeClass = resolveClass(parameterType);
    String resultMap = context.getStringAttribute("resultMap");
    String resultType = context.getStringAttribute("resultType");
    String lang = context.getStringAttribute("lang");
    //2. 此处没明白
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
    6. 
    // Include Fragments before parsing
    XMLIncludeTransformer includeParser = new XMLIncludeTransformer(configuration, builderAssistant);
    includeParser.applyIncludes(context.getNode());
    7. 
    // Parse selectKey after includes and remove them.
    processSelectKeyNodes(id, parameterTypeClass, langDriver);
    8. 
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
