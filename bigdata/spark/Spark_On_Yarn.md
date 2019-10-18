# Sark on Yarn
## 准备
### 1.软件下载
1. [jdk 1.8](https://download.oracle.com/otn/java/jdk/8u231-b11/5b13a193868b4bf28bcb45c792fce896/jdk-8u231-linux-x64.tar.gz)
2. [scala 2.12.x](https://downloads.lightbend.com/scala/2.12.10/scala-2.12.10.tgz)
3. [zookeeper 3.4.14](https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz)
4. [hadoop 2.7.7](https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz)
5. [spark 2.3.4-hadoop2.7](http://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-2.3.4/spark-2.3.4-bin-hadoop2.7.tgz)

### 2. 服务器准备
1. 重命名hadoop01,hadoop02,hadoop03
2. 关闭防火墙
3. 关闭selinux
4. 各个hosts添加各个服务器
5. 配置免密登陆 `ssh-copy-id hadoop@hadoop0{1,2,3}`

## jdk安装
1. 下载到jdk的 tar.gz 包之后通过`tar -zxf jdkxxxxxxx.tar.gz`命令解压
2. 在 `/etc/profile` 中添加 jdk 配置
    ```
    JAVA_HOME=/xxxx/xxxx/xxx
    PATH=${PATH}:${JAVA_HOME}/bin
    ```

## scala安装
1. 下载 scala 的 tgz 包，用 `tar xf scalaxxxxxx.tgz`解压
2. 配置 `/etc/profile`
    ```
    SCALA_HOME=/xxx/xxx/xx
    PATH=${PATH}:${SCALA_HOME}/bin
    ```
## zookeeper 配置
1. 下载解压 `wget xxxx`,`tar zxf zookeeper-3.4.14.tar.gz`
2. 软连接到统一目录，方便升级管理 `ln -s /home/hadoop/zookeeper-3.4.14 /opt/bigdata/zookeeper`
3. 复制 `conf` 目录下的 `zoo-sample.cfg` 文件，重命名为 `zoo.cfg`,并配置
    ```
    1. 修改数据存储目录
    dataDir=/opt/bigdata/zookeeper/data
    2. 配置集群，添加如下
    server.1=hadoop01:2888:3888
    server.2=hadoop02:2888:3888
    server.3=hadoop03:2888:3888
    ```
4. 通过 `scp -r /home/hadoop/zookeeper-3.4.14 hadoop@hadoop{1,2,3}:/home/hadoop` 复制到各个服务器上
5. 在各个服务器的`dataDir`目录添加 `myid` 文件，内容为，服务器编号，如下
    ```
    hadoop01> echo "1" > myid
    hadoop02> echo "2" > myid
    hadoop03> echo "3" > myid
    ```
6. 启动，每台机器运行 `zkServer.sh start`

## hadoop HA 搭建
参照之前文档: [Hadoop HA 配置](https://github.com/ChenZebedee/DocumentSync/blob/master/bigdata/Hadoop/HADOOP_HA.md)

## spark 配置

