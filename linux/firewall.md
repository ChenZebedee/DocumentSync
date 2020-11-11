#  FIREWALL NOTE

## servers -- show actice
```sh
firewall-cmd --list-services
```

## servers -- show Inactive
```sh
firewall-cmd --get-services
```

## servers -- start inactive server
```sh
firewall-cmd --add-service=http
firewall-cmd --permanent --add-service=http

```

## servers -- add server
```sh
cp /usr/lib/firewalld/services/${someone}.xml /usr/lib/firewalld/services/${youserver}.xml
```

```xml
<?xml version="1.0" encoding="utf-8"?>

<service>
<short>${serverName}</short>
<description>Transmission is a lightweight GTK+ BitTorrent client.</description>
<port protocol="tcp" port="51413"/>
</service>
```
```
firewall-cmd --permanent --add-service=serverName
systemctl restart firewalld.service
```

## port -- add
```sh
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload
```
## port -- show
```sh
firewall-cmd --zone=public --query-port=80/tcp
```

## port -- delete

```sh
firewall-cmd --zone=public --remove-port=80/tcp --permanent
```

## 批量添加目前已存在端口

```sh
#tcp端口添加
for host in {192.168.60.11,192.168.60.13,192.168.60.129,192.168.60.150,192.168.60.151,192.168.60.152,192.168.60.153,192.168.60.154,192.168.60.155,192.168.60.156,192.168.60.157,192.168.60.158,192.168.60.159,192.168.60.166};do for port in $(netstat -anlt  | awk  '{n=split($0, a,":");if (n==7) print a[4] ;else print a[2] }' | awk '{print $1}' | sort|uniq);do firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="${host}" port protocol="tcp" port="${port}" accept";done;done

#udp端口添加
for host in {192.168.60.11,192.168.60.13,192.168.60.129,192.168.60.150,192.168.60.151,192.168.60.152,192.168.60.153,192.168.60.154,192.168.60.155,192.168.60.156,192.168.60.157,192.168.60.158,192.168.60.159,192.168.60.166};do for port in $(netstat -anlu  | awk  '{n=split($0, a,":");if (n==7) print a[4] ;else print a[2] }' | awk '{print $1}' | sort|uniq);do firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="${host}" port protocol="udp" port="${port}" accept";done;done
```