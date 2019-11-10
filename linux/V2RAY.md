# 0. 之前准备
## 0.1 获取域名
通过 [freenom](freenom.com) 获取免费域名
## 0.2 DNS解析
1. 通过腾讯云的 [DNSPOD](dnspod.cn) 进行解析
2. 或者通过阿里云的 `云解析dns` 进行解析

大概配置如下
![域名配置](https://s2.ax1x.com/2019/11/10/Mn6QgK.png)

## 0.3 安装一些小工具
```sh
yum install -y vim git zip unzip
```

## 0.4 关闭 selinux
### 0.4.1 临时关闭
```
setenforce 0
```
### 0.4.2 永久关闭

修改 /etc/selinux/config

```sh
vim /etc/selinux/config
```

```properties
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
```


# 1. Nginx配置
## 1.1 建立web根目录
### 1.1.1 新建根目录
```
mkdir -p /www/root
```
### 1.1.2 添加 `index.html`
```
touch /www/root/index.html
```
### 1.1.3 添加腾讯公益404页面
```
cat << EOF > /www/root/index.html
<!DOCTYPE html>
<html>
<head>
    <title>404</title>
    <meta http-equiv="Content-Type" content="text/html" charset="UTF-8">
    <script type="text/javascript" src="//qzonestyle.gtimg.cn/qzone/hybrid/app/404/search_children.js" charset="utf-8" homePageUrl="https://www.example.ga/" homePageName="回到我的主页"></script>
</head>
</html>
EOF
```
>`https://www.example.ga` 改成自己的域名
## 1.2 安装配置 Nginx
### 1.2.1 安装
```
yum install -y nginx
```
### 1.2.2 配置 `/etc/nginx/nginx.conf
    
编辑文件
```sh
vim /etc/nginx/nginx.conf 
```
配置改成如下
```properties
user nginx;
worker_processes auto;
error_log /dev/null;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  off;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  example.ga www.example.ga;
        root         /www/root;
        index        index.html index.htm;

        location / {
        }
    }
}
```
> `example.ga` 和 `www.example.ga` 改成自己的域名   
> 重启 Nginx 如果能看到404腾讯公益页面就可以了
### 1.2.3 启动服务器
```sh
systemctl enable nginx
systemctl start nginx
```

# 2. v2ray安装
```sh
bash <(curl -L -s https://install.direct/go.sh)
```
安装完后先关闭v2ray
```sh
systemctl stop v2ray
```
# 3. 安装运行 acme (自动获取ssl证书)
## 3.1 安装
```sh
curl  https://get.acme.sh | sh
```
## 3.2 导入源
```sh
source /root/.bashrc
```
## 3.3 申请证书
```sh
acme.sh --issue -d example.ga -d www.example.ga --webroot /www/root/ -k ec-256
```
## 3.4 安装证书
```sh
acme.sh --installcert -d example.ga -d www.example.ga --key-file /etc/v2ray/v2ray.key --fullchain-file /etc/v2ray/v2ray.crt --ecc --reloadcmd  "service nginx force-reload && systemctl restart v2ray"
```
> `example.ga` 和 `www.example.ga` 改成自己的域名
# 4. WebSocket + TLS + Nginx配置
## 4.1 修改 Nginx 支持 TLS

修改 `/etc/nginx/nginx.conf`
```json
user nginx;
worker_processes auto;
error_log /dev/null;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  off;

    server_tokens       off;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

    # Http Server，强制跳转Https
    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  example.ga www.example.ga;
        rewrite      ^(.*)$ https://www.example.ga$1 permanent;
    }

    # Https Server
    server {
        listen       443 ssl http2 default_server;
        listen       [::]:443 ssl http2 default_server;
        # www.example.ga 改成自己的域名
        server_name  www.example.ga;
        root         /www/root;
        index        index.html index.htm;

        ssl_certificate "/etc/v2ray/v2ray.crt";
        ssl_certificate_key "/etc/v2ray/v2ray.key";
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout  10m;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        include /etc/nginx/default.d/*.conf;

        location / {
        }

        # 反向代理V2Ray
        # wss可以随便写个乱码，v2ray要配对
        # 10443 也可以根据自己的改
        location /wss {
            proxy_redirect off;
            proxy_pass http://127.0.0.1:10443;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $http_host;
        }

        error_page 404 /404.html;
        location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
}
```
> 重启 Nginx 看是否能看到腾讯公益页面,并且网址是 https 开头的
## 4.2 配置 v2ray
    
### 4.2.1 使用V2Ray自带的v2ctl工具生成一个新的uuid。
```
/usr/bin/v2ray/v2ctl uuid
93bd47f7-88f5-3a24-22c9-0f22bc64988d
```
### 4.2.2 为mtproto生成一个密钥
```
head -c 16 /dev/urandom | xxd -ps
cc078b440453400852e7b3cfe46162d2
```
### 4.2.3 修改v2ray配置文件
    
```sh
vim /etc/v2ray/config.json
```

添加如下配置
    
```json
{
    "log": {
        "loglevel": "none",
        "access": "/var/log/v2ray/access.log",
        "error": "/var/log/v2ray/error.log"
    },
    "inbounds": [
        {
            "port": 10443,
            "listen": "127.0.0.1",
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "93bd47f7-88f5-3a24-22c9-0f22bc64988d",
                        "alterId": 64
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                    "path": "/wss"
                }
            }
        },
        {
            "tag": "tg-in",
            "port": 8080,
            "protocol": "mtproto",
            "settings": {
                "users": [
                    {
                        "secret": "cc078b440453400852e7b3cfe46162d2"
                    }
                ]
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {}
        },
        {
            "protocol": "blackhole",
            "settings": {
                "response": {
                    "type": "none"
                }
            },
            "tag": "blocked"
        },
        {
            "tag": "tg-out",
            "protocol": "mtproto",
            "settings": {}
        }
    ],
    "routing": {
        "domainStrategy": "IPOnDemand",
        "settings": {
            "rules": [
                {
                    "type": "field",
                    "ip": [
                        "geoip:private"
                    ],
                    "outboundTag": "blocked"
                },
                {
                    "type": "field",
                    "inboundTag": [
                        "tg-in"
                    ],
                    "outboundTag": "tg-out"
                }
            ]
        }
    }
}
```
### 4.2.4 启动v2ray
```sh
systemctl enable v2ray
systemctl start v2ray
```

# 5. shadowrocket 客户端配置
1. 类型选Vmess
2. 内容按照之前配置的填

配置图片如下
![shadowrocket配置](https://s2.ax1x.com/2019/11/10/Mualss.jpg)

# 6. mac V2RayX 配置
## 6.1 安装 V2Ray
```sh
brew install v2ray
```

## 6.2 去github上下载最新的 V2RayX
[V2RayX下载页面](https://github.com/Cenmrev/V2RayX/releases)

然后解压复制到application里面就行了

## 6.3 新增一个，在主目录配置
![主配置](https://s2.ax1x.com/2019/11/10/MudCkV.png)
## 6.4 点击 `transport settings`，配置 ` WebSocket`选项
![ws配置](https://s2.ax1x.com/2019/11/10/MudVX9.png)
## 6.5 配置 `TLS`
![ssl配置](https://s2.ax1x.com/2019/11/10/MudnTx.png)

# 7. Windows V2RayN 配置
## 7.1 去github上下载最新的V2RayN
[下载V2RayN](https://github.com/2dust/v2rayN/releases) 要带源码的 `v2rayN-Core.zip` 压缩包
## 7.2 添加新服务器
如下图
![V2RayN配置](https://s2.ax1x.com/2019/11/10/MuyGP1.png)

# 结语
太累了，后期会找更安全的方法