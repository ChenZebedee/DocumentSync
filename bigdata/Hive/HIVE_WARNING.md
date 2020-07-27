# hive 遇到的坑

## beeline 不能使用 tez
hive 中添加了 tez 后，beeline 带上 ip 地址就不能使用了

如果 beeline 使用 tez 时报错

对于我个人而言，是因为添加了
```xml
<property>
  <name>hive.fetch.task.conversion</name>
  <value>more</value>
  <description>
    Some select queries can be converted to single FETCH task 
    minimizing latency.Currently the query should be single 
    sourced not having any subquery and should not have
    any aggregations or distincts (which incurrs RS), 
    lateral views and joins.
    1. minimal : SELECT STAR, FILTER on partition columns, LIMIT only
    2. more    : SELECT, FILTER, LIMIT only (+TABLESAMPLE, virtual columns)
  </description>
</property>
```
删掉或注释了这个配置，即可使用远程正常使用 tez。

