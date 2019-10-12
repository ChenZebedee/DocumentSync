# Hive_ON_HBase
Hive 和 HBase 结合使用
## 前置准备
将 `${HIVE_HOME}/lib/hive-hbase-handler-*.jar` 文件复制到 hbase 的lib目录下
```
cp ${HIVE_HOME}/lib/hive-hbase-handler-*.jar ${HBASE_HOME}/lib
```

## 以 hive 为主导
通过 hive 创建内部表，并关联到 HBase 上，HBase 会自动创建表。但是不能先创建 HBase 上的表，再通过 Hive 创建内部表。
创建语句如下：
```sql
create table t_student(id int,name string) stored by 'org.apache.hadoop.hive.hbase.HBaseStorageHandler' with serdeproperties("hbase.columns.mapping"=":key,st1:name") tblproperties("hbase.table.name"="t_student","hbase.mapred.output.outputtable" = "t_student");
```
解释说明：

1. 前面部分和普通创建语句相同
2. stored by 表示调用的jar包的方法，默认调用 `hive-hbase-handler-*.jar` 这个jar 包
3. serdeproperties 配置列的映射
4. tblproperties 配置 hbase 对应表名和 mapreduce 输出结果的表

## 以 HBase 为主导
必须先创建 HBase 表，再通过 hive sql 创建 hive 中的外部表。sql如下：
```sql
create external table t_student_info(id int,age int,sex string) stored by 'org.apache.hadoop.hive.hbase.HBaseStorageHandler' with serdeproperties("hbase.columns.mapping"=":key,st1:age,st2:sex") tblproperties("hbase.table.name"="t_student_info");
```
解释同上唯一不同的是创建时加上 `external` 这个条件，表明外部表。