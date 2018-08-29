# linux操作

## 添加新用户

```shell
#此命令创建了一个用户sam，其中-d和-m选项用来为登录名sam产生一个主目录/usr/sam（/usr为默认的用户主目录所在的父目录）。
useradd –d /home/username -m username



useradd -m -g users -G wheel -s /bin/bash userName
passwd userName
```

## 防火墙设置

对外开放3306端口，供外部的计算机访问

```shell
firewall-cmd --zone=public --add-port=3306/tcp --permanent
该命令方式添加的端口，可在/etc/firewalld/zones中的对应配置文件中得到体现
#重启防火墙
systemctl restart firewalld
说明：
1. firewall-cmd：Linux中提供的操作firewall的工具。
2. –zone：指定作用域。
3. –add-port=80/tcp：添加的端口，格式为：端口/通讯协议。
4. –permanent：表示永久生效，没有此参数重启后会失效。
```

## 软连接

```shell
#开启软链接
ln -s fromPath aimsPath
#关闭软链接
rm -rf aimsPath
```

## openVPN

```shell
在*.ovpn文件最后加上
auth-user-pass pass文件路径
pass文件配置为:
username
password
```