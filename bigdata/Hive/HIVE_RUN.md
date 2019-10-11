# HIVE 搭建记录
## mysql 和 hive 下载
### MYSQL
[centos6](https://dev.mysql.com/downloads/file/?id=484921)

[centos7](https://dev.mysql.com/downloads/file/?id=484922)
### HIVE
[2.3.6](https://mirrors.tuna.tsinghua.edu.cn/apache/hive/hive-2.3.6/apache-hive-2.3.6-bin.tar.gz)

[1.2.2](https://mirrors.tuna.tsinghua.edu.cn/apache/hive/hive-1.2.2/apache-hive-1.2.2-bin.tar.gz)

[3.1.2](https://mirrors.tuna.tsinghua.edu.cn/apache/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz)

## mysql搭建
以下命令都要用 root 用户运行
1. 安装 mysql yum
    ```shell
    #centos6
    yum localinstall mysql80-community-release-el6-{version-number}.noarch.rpm
    #centos7
    yum localinstall mysql80-community-release-el7-{version-number}.noarch.rpm
    ```
2. 禁用 MySQL5.7 启用 MySQL8.0
    ```shell
    yum-config-manager --disable mysql57-community
    yum-config-manager --enable mysql80-community
    ```
3.  安装MySQL服务
    ```shell
    yum install mysql-community-server
    ```
4. 启动 MySQL 服务
    ```shell
    service mysqld start
    ```
5. 获取初始化密码
    ```shell
    grep 'temporary password' /var/log/mysqld.log
    ```
6. 登陆之后修改密码
    ```shell
    mysql -uroot -p
    ```
    ```sql
    ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass4!';
    ```
## Hive 安装
1. 配置 `/etc/profile`
    ```shell
    添加如下配置：
    #HIVE
    export HIVE_HOME=/opt/bigdata/hive
    export HIVE_CONF_DIR=${HIVE_HOME}/conf
    export PATH=$PATH:$HIVE_HOME/bin
    ```
2. 复制 `hive-default.xml.template` 为 `hive-site.xml`,并配置`hive-site.xml`
    ```xml
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive/warehouse</value>
        <description>location of default database for the warehouse</description>
    </property>
    <property>
        <name>hive.exec.scratchdir</name>
        <value>/user/hive/tmp</value>
        <description>HDFS root scratch dir for Hive jobs which gets created with write all (733) permission. For each connecting user, an HDFS scratch dir: ${hive.exec.scratchdir}/&lt;username&gt; is created, with ${hive.scratch.dir.permission}.</description>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:mysql://hadoop01:3306/hive?characterEncoding=UTF-8&amp;useSSL=false</value>
        <description>
            JDBC connect string for a JDBC metastore.
            To use SSL to encrypt/authenticate the connection, provide database-specific SSL flag in the connection URL.
            For example, jdbc:postgresql://myhost/db?ssl=true for postgres database.
        </description>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>com.mysql.cj.jdbc.Driver</value>
        <description>Driver class name for a JDBC metastore</description>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>admin</value>
        <description>Username to use against metastore database</description>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>Ewell!@#456</value>
        <description>password to use against metastore database</description>
    </property>
    ```
    再替换两个地方
    >${system:java.io.tmpdir} 替换成 /opt/bigdata/hive