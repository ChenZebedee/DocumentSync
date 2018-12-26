# HADOOP 操作

## hive 权限控制
```sql
create role query;
grant SELECT,SHOW_DATABASE on database rme to role query;
grant role query to user fengkong with admin option;

show grant role query;

grant ALL on database fengkong to user hadoop;
revoke ALL on database fengkong from user hadoop;
```
### 需要有建库权限
```sql
--赋权超级权限
grant all to user hadoop;
```
即可正常建库

## hive 中文乱码

1. 在 `${HIVE_HOME}/conf` 下的 `hive-env.sh` 文件里添加
    ```shell
        export HADOOP_OPTS="$HADOOP_OPTS -Dfile.encoding=UTF-8"
    ```
2. 在 MySQL 中修改 `COLUMNS_V2,TABLE_PARAMS,PARTITION_PARAMS,PARTITION_KEYS,INDEX_PARAMS` 5张表的字符集
    ```
        alter table COLUMNS_V2 modify column COMMENT varchar(256) character set utf8;
        alter table TABLE_PARAMS modify column PARAM_VALUE varchar(4000) character set utf8;
        alter table PARTITION_PARAMS modify column PARAM_VALUE varchar(4000) character set utf8 ;
        alter table PARTITION_KEYS modify column PKEY_COMMENT varchar(4000) character set utf8;
        alter table INDEX_PARAMS modify column PARAM_VALUE varchar(4000) character set utf8;
    ```
3. 在 `hive-site.xml` 中的 jdbc 连接后面添加 `&amp;useSSL=false&amp;useUnicode=true&amp;characterEncoding=UTF-8`
4. 重启 hive 


## tez cdh 打包 （针对 centos7）

**假设已经安装了 maven 和 java 了**

### 1. 源码包下载
官网下载源码包：[tez 下载页面](http://tez.apache.org/releases/index.html)

并通过 tar 命令解压

### 2. protobuf-2.5.0 安装

去 [rpm.pbone.net](http://rpm.pbone.net/) 选择系统相应版本，之后搜索 `protobuf-2.5.0` 和 `protobuf-compiler-2.5.0` 包，下载到服务器上后进行 yum 安装。安装命令：
```
yum localinstall /opt/protobuf-2.5.0-8.el7.x86_64.rpm -y
yum localinstall /opt/protobuf-compiler-2.5.0-8.el7.x86_64.rpm -y
```

### 3. 修改 tez 的 pom.xml 文件

#### 添加 cdh 源
在 `repository` 添加
```
  <repository>
    <id>cloudera</id>
    <url>https://repository.cloudera.com/artifactory/cloudera-repos/</url>
    <name>Cloudera Repositories</name>
    <snapshots>
      <enabled>false</enabled>
    </snapshots>
  </repository>
```
在 `pluginRepositories` 添加
```
  <pluginRepository>
    <id>cloudera</id>
    <name>Cloudera Repositories</name>
    <url>https://repository.cloudera.com/artifactory/cloudera-repos/</url>
  </pluginRepository>
```

#### 修改 hadoop 版本
将 `<hadoop.version>2.6.0</hadoop.version>` 修改为 `<hadoop.version>2.6.0-cdh5.15.1</hadoop.version>`

注释 `tez-ext-service-tests` `tez-ui` `tez-ui2` 三大模块

#### 修改 JobContextImpl.java
路径：`/src/main/java/org/apache/tez/mapreduce/hadoop/mapreduce/JobContextImpl.java`

最后添加
```java
/**
 * Get the boolean value for the property that specifies which classpath
 * takes precedence when tasks are launched. True - user's classes takes
 * precedence. False - system's classes takes precedence.
 * @return true if user's classes should take precedence
 */
 @Override
public boolean userClassesTakesPrecedence() {
  return getJobConf().getBoolean(MRJobConfig.MAPREDUCE_JOB_USER_CLASSPATH_FIRST, false);
}
```

#### 最后编译

```shell
mvn clean package -DskipTests=true -Dmaven.javadoc.skip=true
```
最终要用的文件为 `${TEZ_HOME}/tez-dist/target/tez-0.8.5.tar.gz`

#### 在 hadoop 中配置 tez
在 `${HADOOP_HOME}/etc/hadoop/` 添加 `tez-site.xml`

tez-site.xml 内容
```
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
        <property>
                <name>tez.lib.uris</name>
                <value>${fs.defaultFS}/apps/tez-0.5.3.tar.gz</value>
        </property>
</configuration>
```

将 tez-0.8.5.tar.gz 解压
```
tar zxf tez-0.8.5.tar.gz 
```

在 `/etc/profile` 和 `hive-enc.sh` 中添加
```
echo "export TEZ_JARS=/opt/bigdata/tez-0.8.5" >> /etc/profile
echo "export TEZ_CONF_DIR=\${HADOOP_HOME}/etc/hadoop" >> /etc/profile
echo "export HADOOP_CLASSPATH=\${HADOOP_CLASSPATH}:\${TEZ_CONF_DIR}:\${TEZ_JARS}/*:\${TEZ_JARS}/lib/*" >> /etc/profile
```

在 hdfs 上添加 tez 的压缩包
```
hadoop fs -mkdir /apps
hadoop fs -copyFromLocal tez-0.5.3.tar.gz /apps/
```

