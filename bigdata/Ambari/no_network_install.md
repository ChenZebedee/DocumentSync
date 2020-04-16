# 系统准备
## 磁盘准备
将数据盘挂载到 `/data` 下
```
mount /xxx/xxx/xxx /data
```
## 包准备
## 系统参数设置
## 离线yum包安装
## JAVA安装
1. 查看是否有自带 `open JDK`
    ```sh
    rpm -qa | grep java
    ```
2. 通过命令删除
    ```sh
    yum remove "*openjdk*"
    ```
    >最好把前面列出来的，一个一个删除
    综合shell
    ```sh
    for i in $(rpm -qa | grep java);do yum remove -y $i;done
    ```
3. 下载 `oracle JDK`
   
    [jdk8下载页面](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

4. tar包安装方式(.tar.gz)
   
    将tar包解压到一个目录下，各人比较喜欢解压到 `/opt/run` 目录下，然后再通过软连接到 `/usr/local/java` 这样便于版本更新，再在 `/etc/profile`添加环境变量。 命令如下：
    ```sh
    mkdir /opt/binary
    tar zxf jdk-8u181-linux-x64.tar.gz -C /opt/binary
    ln -s /opt/binary/jdk1.8.0_181 /usr/local/java
    cat << EOF >> /etc/profile
    #JAVA_HOME
    export JAVA_HOME=/usr/local/java
    export JRE_HOME=\$JAVA_HOME/jre
    export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib
    export PATH=\${PATH}:\${JAVA_HOME}/bin
    EOF
    ```
## 安装MySQL
1. 先删除自带 mariadb-libs-5.5.60-1.el7_5.x86_64
    ```shell
    rpm -e --nodeps mariadb-libs-5.5.60-1.el7_5.x86_64
    ```

2. 按顺序安装包
    ```
    rpm -ivh mysql-community-common-5.7.29-1.el7.x86_64.rpm
    rpm -ivh mysql-community-libs-5.7.29-1.el7.x86_64.rpm
    rpm -ivh mysql-community-client-5.7.29-1.el7.x86_64.rpm
    rpm -ivh mysql-community-server-5.7.29-1.el7.x86_64.rpm
    rpm -ivh mysql-community-devel-5.7.29-1.el7.x86_64.rpm
    ```
3. 启动
    ```
    systemctl start mysqld
    ```
4. 查看初始化密码
    ```
    grep 'temporary password' /var/log/mysqld.log
    ```
5. 设置简单密码模式
    ```
    cat "validate_password = off" >> /etc/my.cnf
    ```
6. 修改密码
    ```sql
    ALTER USER 'root'@'localhost' IDENTIFIED BY 'ewell@123'；
    ```
7. 创建超级用户
    ```sql
    CREATE USER 'ewell'@'%' IDENTIFIED BY 'ewell@123';
    GRANT ALL ON *.* TO 'ewell'@'%';
    GRANT all ON *.* TO 'ewell'@'%' WITH GRANT OPTION;
    flush  privileges;
    ```
