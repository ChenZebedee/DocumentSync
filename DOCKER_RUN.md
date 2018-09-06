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