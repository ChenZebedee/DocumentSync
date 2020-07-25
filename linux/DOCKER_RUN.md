# DOCKER RUNING

## 安装

[官网安装](https://docs.docker.com/install/linux/docker-ce/centos/#install-from-a-package)

## 镜像获取

```shell
docker pull ubuntu:18.04
```

这个镜像会很小，但是基本功能都没有，但是相比较而言centos大很多

## 镜像运行(配置时)

```shell
docker run --name hadoop -t -i 'ubuntu:18.04'
```

## mysql运行

```shell
docker run -p 13306:3306 --name mymysql -v $PWD/conf:/etc/mysql/conf.d -v $PWD/logs:/logs -v $PWD/data:/va/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 -d mysql:8.0
```

## 查看ip地址

```shell
docker inspect -f '{{.Name}} - {{.NetworkSettings.IPAddress }}' $(docker ps -aq)
docker inspect --format='{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq)
```


## docker运行设置内存
```shell
docker run --name docker_postgre --memory-swap -1 -m 6G -p 5432:5432 -e POSTGRES_PASSWORD=123456 -d postgres
```

## docker更新设置
```shell
docker update -${} ${} ${container_name}
```

## docker 添加新网络
```shell
docker network create -d bridge --subnet=192.168.5.0/24 --gateway=192.168.5.1 -o com.docker.network.bridge.name=br-hadoop hadoop-br0
```

## 启动伪分布式
```shell
docker run -d --net hadoop-br0 --ip 192.168.5.33 -p10023:22 -p 50010:50010 -p 50075:50075 -p 50475:50475 -p 50020:50020 -p 50070:50070 -p 50470:50470 -p 8020:8020 -p 8485:8485 -p 8480:8480 -p 8019:8019 -p 8032:8032 -p 8030:8030 -p 8031:8031 -p 8033:8033 -p 8088:8088 -p 8040:8040 -p 8042:8042 -p 8041:8041 -p 10020:10020 -p 19888:19888 -p 60000:60000 -p 60010:60010 -p 60020:60020 -p 60030:60030 -p 2181:2181 -p 2888:2888 -p 3888:3888 -p 9083:9083 -p 10000:10000 -h pd-csd --name pd-csd ssh:zf
```

## 网络带宽限制
```shell
#本地安装 iproute
#限制到10M/s
sudo tc qdisc add dev docker_game root tbf rate 90Mbit latency 50ms burst 10000
#删除
sudo tc qdisc del dev docker_game root tbf rate 90Mbit latency 50ms burst 10000
```

## agett 占用 100%
解决方法:在宿主机和容器内使用
```shell
systemctl stop getty@tty1.service
systemctl mask getty@tty1.service
```