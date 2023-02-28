# pvm

pvm 配置等使用

## 添加新磁盘(新增磁盘为sdb为例)

独立存储

> note: 如果磁盘未格式化需要先格式化
> `fdisk /dev/sdb` 输入 `d` 清空

### 1. 命令行新增磁盘分区

1. 创建新分区
2. 格式化分区
3. 创建挂载目录
4. 开机自动挂载写入
5. 挂载目录（也可以直接重启）

```shell
root@pve:~# fdisk /dev/sdb

Welcome to fdisk (util-linux 2.36.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x301adfb3.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (1-4, default 1): q
Value out of range.
Partition number (1-4, default 1):
First sector (2048-1953525167, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-1953525167, default 1953525167):

Created a new partition 1 of type 'Linux' and of size 931.5 GiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

root@pve:~# mkfs -t ext4 /dev/sdb1
root@pve:~# mkdir -p /mnt/sdb1
root@pve:~# echo /dev/sdb1 /mnt/sdb1 ext4 defaults 1 2 >> /etc/fstab
root@pve:~# mount /dev/sdb1 /mnt/sdb1
```

### 2. 界面新增存储

页面中 `Datacenter -> Storage -> Add -> Directory`

1. id填自己喜欢的
2. Directory填之前挂载的目标目录
3. Content全选
