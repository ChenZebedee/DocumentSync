# LVM-Logical Volume Manager-逻辑卷管理

## 同一个磁盘扩容(一般虚拟机使用)

fdisk /dev/sda
```
(base) ┌─[root@debian] - [~] - [Thu Jun 06, 10:48]
└─[$] <> fdisk /dev/sda

Welcome to fdisk (util-linux 2.38.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

This disk is currently in use - repartitioning is probably a bad idea.
It's recommended to umount all file systems, and swapoff all swap
partitions on this disk.


Command (m for help): n
Partition type
   p   primary (1 primary, 1 extended, 2 free)
   l   logical (numbered from 5)
Select (default p):

Using default response p.
Partition number (3,4, default 3):
First sector (104855552-629145599, default 104855552):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (104855552-629145599, default 629145599):

Created a new partition 3 of type 'Linux' and of size 250 GiB.

Command (m for help): w
The partition table has been altered.
Syncing disks.
```

### 创建pv 物理卷
pvcreate /dev/sda3

>return:

```
  Physical volume "/dev/sda3" successfully created.
```
### 查找对应的vgName
vgdisplay

>return:

```
  --- Volume group ---
  VG Name               debian-vg
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <49.52 GiB
  PE Size               4.00 MiB
  Total PE              12677
  Alloc PE / Size       12677 / <49.52 GiB
  Free  PE / Size       0 / 0
  VG UUID               quhOR8-KiyT-B31z-3g5f-4el4-qR4V-IJXFW7

```
### 添加物理卷到物理卷组中中
vgextend debian-vg /dev/sda3

>return:
```
  Volume group "debian-vg" successfully extended
```

### 查看逻辑卷
lvdisplay

>return:
```
  --- Logical volume ---
  LV Path                /dev/debian-vg/root
  LV Name                root
  VG Name                debian-vg
  LV UUID                be20gG-bSv1-MuBE-Xdy0-pfLX-SnhR-TOqctX
  LV Write Access        read/write
  LV Creation host, time debian, 2024-06-02 22:09:20 +0800
  LV Status              available
  # open                 1
  LV Size                48.56 GiB
  Current LE             12432
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           254:0

  --- Logical volume ---
  LV Path                /dev/debian-vg/swap_1
  LV Name                swap_1
  VG Name                debian-vg
  LV UUID                SNQ5rP-idLw-32m1-hvUe-6MP3-ydM1-L8nXeq
  LV Write Access        read/write
  LV Creation host, time debian, 2024-06-02 22:09:20 +0800
  LV Status              available
  # open                 2
  LV Size                980.00 MiB
  Current LE             245
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           254:1
```

### 扩容逻辑卷
lvextend -l +100%FREE /dev/debian-vg/root

```
  Size of logical volume debian-vg/root changed from 48.56 GiB (12432 extents) to 298.56 GiB (76432 extents).
  Logical volume debian-vg/root successfully resized.
```
### 系统重置
resize2fs /dev/debian-vg/root

>return:

```
resize2fs 1.47.0 (5-Feb-2023)
Filesystem at /dev/debian-vg/root is mounted on /; on-line resizing required
old_desc_blocks = 7, new_desc_blocks = 38
The filesystem on /dev/debian-vg/root is now 78266368 (4k) blocks long.
```


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
