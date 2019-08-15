# spark 报错处理

## Exception in thread "main" java.lang.NoClassDefFoundError: org/slf4j/Logger
解决办法
```
在 spark-env.sh 中添加
export SPARK_DIST_CLASSPATH=$(${HADOOP_HOME}/bin/hadoop classpath)
```

## Exception in thread "main" java.lang.NoClassDefFoundError: com/fasterxml/jackson/databind/ObjectMapper
```
下载这三个 jar包 jackson-annotations-2.2.3.jar jackson-databind-2.2.3.jar jackson-core-2.2.3.jar 放入${SPARK_HOME}/lib
```