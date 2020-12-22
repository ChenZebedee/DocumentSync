#!/bin/bash
# 防火墙要先启动
# 括号内替换成需要访问的ip,用空格分隔，保留括号
# ip范围 1. 大数据集群各ip 2. datatools ip 3. ods、cdr等数据库ip 4. 全息服务器ip
# 直接在需要运行的服务器上运行即可(sh firewall_add_whitelist.sh)
# 如果出现有新ip替换ip_list再次执行即可
# 大数据环境的每台主机都要运行一下



check_firewall(){
    FIREWALLD=`systemctl status firewalld | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1`
    if [ "$FIREWALLD" == "running" ]
    then
        echo "防火墙已启动"
    else 
        systemctl start firewalld
        echo "启动成功"
    fi
}

check_firewall

ip_list=(192.168.201.150 192.168.201.190 192.168.201.191 192.168.201.192 192.168.201.193)

#tcp端口添加
for index in "${!ip_list[@]}";do for port in $(netstat -anlt  | awk  '{n=split($0, a,":");if (n==7) print a[4] ;else print a[2] }' | awk '{print $1}' | sort|uniq);do firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="${ip_list[index]}" port protocol="tcp" port="${port}" accept";done;done

#udp端口添加
for index in ${!ip_list[@]};do for port in $(netstat -anlu  | awk  '{n=split($0, a,":");if (n==7) print a[4] ;else print a[2] }' | awk '{print $1}' | sort|uniq);do firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="${ip_list[index]}" port protocol="udp" port="${port}" accept";done;done

for port in $(echo "8082 8096 8095 8098 9096 8369 7809");do firewall-cmd --zone=public --add-port=${port}/tcp --permanent;done