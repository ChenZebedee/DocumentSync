# HBASE 操作指南
## CREATE 操作
```
create '表名'， '列族1'，'列族2'，'列族n'
例：create '3rdapi:bqs','bqsOut','cf'
```

## PUT 数据入 HBASE
```
put '表名'，'行名称(rowKey)' ，'列族1：列名'，'value值'
put '表名'，'行名称(rowKey)' ，'列族2：列名'，'value值'
例：
put '3rdapi:bqs','xxxx','bqsOut:name','陈绍迪'
put '3rdapi:bqs','xxxx','cf:name','陈绍迪'
```

## GET 获取数据
```
get '表名'，'行名称'
get '表名'，'行名称' ，'列族：列名'
get '表名'，'行名称' ，'列族'
get '表名', '行名称' , {COLUMN=>'列族：列名',VERSIONS=>2} //两个版本的值
```

## scan 扫描全表数据
```
scan '表名',{LIMIT=>整形值}
scan '表名',{COLUMNS=>'列族名'}
scan '表名',{COLUMN=>'列族名：列名'}
scan '表名' 
```

## count 查看表总记录数
```
count '表名'
```

## delete 删除一条数据
```
delete '表名','行名称' ，'列族：列名'
```

## drop 删除表
```
先禁用表，再删除表
disable '表名'
drop '表名' 
```

## truncate 清除表中所有数据
```
truncate '表名'
```

## 批量获取程序使用
程序在 71 上的 /home/hadoop/conding/MapReduce 目录下

使用方法为：
```shell
数据量小的时候：
yarn jar target/mapreduce-1.0-SNAPSHOT-jar-with-dependencies.jar com.mnw.GetData /home/hadoop/data/get/mlp_sb 3rdapi:mlpBqs table-info.properties bqs_out /home/hadoop/data/get/mlp_bqs_out
数据量大的时候：
split -l 1000 ../sn_test -d -a 2 sn_ | for file_name in $(ls /home/hadoop/data/get/split1/);do yarn jar /home/hadoop/conding/MapReduce/target/mapreduce-1.0-SNAPSHOT-jar-with-dependencies.jar com.mnw.GetData /home/hadoop/data/get/split1/${file_name} 3rdapi:bqs table-info.properties bqs_out /home/hadoop/data/get/bqs_out_test;done
```
>topic: 上面数据量大的时候获取也可以用多线程的形式，可以用shell的多线程，java 代码多线程没有做

命令解释：

|                                       命令                                                     |         解释           |
|:-----------------------------------------------------------------------------------------------|:----------------------|
|$(ls /home/hadoop/data/get/split1/)                                                             | 获取文件名             |
|yarn jar /home/hadoop/conding/MapReduce/target/mapreduce-1.0-SNAPSHOT-jar-with-dependencies.jar | 用 yarn 运行这个 jar 包|
|com.mnw.GetData                                                                                 | 选择这个类             |
|/home/hadoop/data/get/split1/${file_name}                                                       | 输入的 order_sn 文件   |
|3rdapi:bqs                                                                                      | 对应要查询的表         |
|table-info.properties                                                                           | 输出字段配置文件        |
|bqs_out                                                                                         | 列簇名                 |
|/home/hadoop/data/get/bqs_out_test                                                              | 输出的文件名           |
