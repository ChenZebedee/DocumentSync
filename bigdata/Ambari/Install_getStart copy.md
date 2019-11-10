# 系统安装
## 新建虚拟机
注意选择自己合适的内存大小之类就可以了,网卡选择e1000



## 网络配置
编辑 `/etc/sysconfig/network-scripts/ifcfg-ens32`

1. 修改 `BOOTPROTO` 为 `static`
2. 修改 `ONBOOT=yes`
3. 添加 `IPADDR=192.168.aaa.xxx`
4. 添加 `GATEWAY=192.168.aaa.yyy`
5. 添加 `NETMASK=255.255.255.0`
6. 添加 `DNS1=114.114.114.114`

修改完成后 `systemctl resatrt network` 重启网络
## 修改主机名称
```shell
hostnamectl set-hostname xxx --static
```

## 配置hosts
给各个 `/etc/hosts` 文件加上配置
## 部分软件安装
### 安装配置 vim
1. `yum install vim -y` 安装 vim
2. 修改 `/etc/vimrc` 文件，添加如下内容
    ```shell
    syntax on
    set autoindent
    set tabstop=4
    set expandtab
    set softtabstop=4
    ```
### 安装 dstat
`yum install dstat -y`
### yum工具包安装
`yum install yum-utils createrepo yum-plugin-priorities -y`


## 创建 /opt/bigdata 和 /opt/run 目录
```shell
mkdir /opt/bigdata
chow hadoop:hadoop /opt/bigdata
```

## 配置hadoop免密登陆
1. 到 `~/.ssh/` 目录下先用 `ssh-keygen` 命令创建密钥公钥
2. 用 `ssh-copy-id` 进行配置
    ```shell
    ssh-copy-id hadoop@data1
    ```
3. 测试是否通过

## 关闭防火墙
```shell
systemctl disable firewalld
systemctl stop firewalld
```


## 关闭 selinux
```shell
sed 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config -i`
```

## 修改网络的配置
```shell
cat << EOF > /etc/sysconfig/network
# Created by anaconda
NETWORKING=yes
HOSTNAME=data1
EOF
```



