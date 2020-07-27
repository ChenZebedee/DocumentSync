# 说明
由于HBase没有提供索引已经对于指定列查询非常不友好，所以，现在要结合 ElasticSearch 进行整合使用

# 单机模式
## 下载
[ElasticSearch 6.7.2](https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.7.2.tar.gz)

在linux下可以直接输入如下命令进行安装
```
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.7.2.tar.gz
```

## 解压

```
tar -xzf elasticsearch-6.7.2.tar.gz
```

## 配置
配置自动创建 x-pack 目录

Enable automatic creation of X-Pack indices

在 `elasticsearch.yml` 添加如下配置
```yml
action.auto_create_index: .monitoring*,.watches,.triggered_watches,.watcher-history*,.ml*
```

## 运行
```
本地运行：
./bin/elasticsearch
后台运行：
./bin/elasticsearch -d -p pid
关闭
pkill 9 -F pid
```

# 集群搭建
## 系统配置修改
1. ulimit 修改同 HBase
2. 修改 vm.max_map_count -修改配置文件 `/etc/sysctl.conf`
    > max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
    ```s
    添加
    vm.max_map_count=2048000
    ```
    一次修改：```sysctl -w vm.max_map_count=2048000```
3. 修改 `elasticsearch.yml` 文件
    > system call filters failed to install; check the logs and fix your configuration or disable system call filters at your own risk
    ```yml
    bootstrap.memory_lock: false
    bootstrap.system_call_filter: false
    ```

