# LVM-Logical Volume Manager-逻辑卷管理

## 新增磁盘


## 添加逻辑卷
1. lvcreate -l 100%FREE -n data centos
2. mkfs.xfs -f /dev/mapper/centos-data 
3. mkdir /data
4. mount /dev/mapper/centos-data /data


## 缩减逻辑卷
1. 备份
    ```sh
    tar zcf /tmp/home.tar.gz /home/
    ```
2. 卸盘
    ```
    umount /home
    ```
3. 重新设置大小
    ```
    lvreduce -L 50G /dev/mapper/centos-home
    ```
4. 格式化
    ```
    mkfs.xfs -f /dev/mapper/centos-home
    ```
5. 挂载
    ```
    mount /dev/mapper/centos-home /home
    ```
6. 恢复
    ```
    tar zxf /tmp/home.tar.gz -C /
    ```