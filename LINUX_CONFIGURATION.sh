#添加新用户
useradd -m -g users -G wheel -s /bin/bash userName
passwd userName

#防火墙设置
# 对外开放3306端口，供外部的计算机访问
firewall-cmd --zone=public --add-port=3306/tcp --permanent
# 该命令方式添加的端口，可在/etc/firewalld/zones中的对应配置文件中得到体现

# 重启防火墙
systemctl restart firewalld

说明：
#firewall-cmd：Linux中提供的操作firewall的工具。
#–zone：指定作用域。
#–add-port=80/tcp：添加的端口，格式为：端口/通讯协议。
#–permanent：表示永久生效，没有此参数重启后会失效。