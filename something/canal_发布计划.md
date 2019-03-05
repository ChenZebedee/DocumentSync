# canal-操作手册

## 1. 环境安装

### 1.1 Java 安装

## 2. canal server 配置
1. 解压 canal.deployer-1.1.3-SNAPSHOT.tar.gz 压缩文件
    ```
    tar zxf canal.deployer-1.1.3-SNAPSHOT.tar.gz -C ${canal_path}
    ```
2. 修改 config 目录下的 canal.properties 文件
    ```
    1. 修改 canal.serverMode 为 kafka 即 canal.serverMode = kafka
    2. 修改 canal.destinations ,添加 各个数据库的 instance 一个数据库一个名字，以 canal_ 开头后面跟上数据库名
    3. 修改 canal.mq.servers 为线下 kafka 地址 即 canal.mq.servers = 192.168.1.84:9092
    ```
3. 各个 instance 配置