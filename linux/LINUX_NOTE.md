# LINUX_NOTE
## Linux 免密失效
### 错误现象：ssh连接需要密码，已经配置免密却还是需要密码
通过查看目标机器的 `/var/log/secure` 文件，可以看到最后有一个报错
1. 用户目录问题
```
Oct 12 13:30:27 hadoop02 sshd[30100]: Authentication refused: bad ownership or modes for directory /home/hadoop
```
很明确，是用户目录的权限问题

    1) 用 `ll -a` 可以看到权限被更改了，组权限或者其他用户权限拥有了读权限即 `w` 权限

    2) 通过 `chmod -w ${user_home}`，再通过 `chmod u+w ${user_home}` 来给目录添加用户读取权限
2. authorized_keys 权限问题
```
Oct 12 13:22:40 hadoop02 sshd[29770]: Authentication refused: bad ownership or modes for file /home/hadoop/.ssh/authorized_keys
```
同理，修改文件权限

    chmod 600 /home/${user_home}/.ssh/authorized_keys

## Linux 登录编码问题
> 报错：-bash: warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory
解决方法：

在 `/etc/environment` 中添加
```
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
```

### 快捷命令
```
cat << EOF >> /etc/environment
LANG=en_US.utf-8
LC_ALL=en_US.utf-8
EOF
```

## 根据hosts传输文件到同主题机器

```shell
for i in $(host_name=`hostname`;le=${#host_name};prex_name=${host_name:0:((${le}-1))};cat /etc/hosts| grep ${prex_name}|awk '{print $2}');do scp jdk-8u181-linux-x64.tar.gz root@$i:;done
```

## 生成定长递增

```shell
for mod_id in `seq -f 'A%011g' 0 9999`;do echo "fuck $mod_id";done
```
其中 `seq`  是生成递增数的工具, `-f` 是格式化结果 `'A%011g'` 表示A开头11位数字，不够0补齐， `0 9999` 表示 0到9999 步长默认为1