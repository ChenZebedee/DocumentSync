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