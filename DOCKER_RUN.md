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