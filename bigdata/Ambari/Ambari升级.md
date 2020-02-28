# Ambari 升级手册
## 数据备份
1. 页面停止所有服务
2. 服务器停止 `Ambari-server` 和 `Ambari-agent` 服务
3. 备份数据库数据
4. 备份ambari.properties配置文件
    ```sh
    cp /etc/ambari-server/conf/ambari.properties somePath
    ```
## 配置新版本 Ambari
