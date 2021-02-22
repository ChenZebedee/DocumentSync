# 出错现象1:代码链路启动时，消费线程已开启，却没有进行消费，而命令行也开启之后可以进行消费

# 出错现象2:消费时offset会跳过消费，目前基本是跳过3个

# 出错现象3:kafka too maney file open，打开文件数过多
大部分是由于init的topic导致的，每个分区都会打开一个文件，而当文件大小达到1G后又会打开新的文件，而文件一直再开着

解决方案：
1. 调大 ulimit open file 的参数
2. 程序里不必要的文件不再打开，并删除topic

# 出错现象4:消费端一直在rebalance
出现rebalance主要就是消费失败，或者服务端认为消费失败了，当消费超时时，会被认为消费失败

解决方案：
1. 调大 `max.poll.interval.ms` 默认为 300S 可以先调到 500S 试试
2. 设置分区拉取阈值，调小 `poll` 拉取的大小

# 出错现象5:kafka消费的offset超过了记录的offset导致LAG为负数

# the request included a message larger than the max message to Kafka 报错

1. 修改produce配置:

    ```properties
    #扩大
    max.request.size=5024000
    send.buffer.bytes=5024000
    ```

2. 修改server.properties
    ```properties
    message.max.bytes=5024000
    ```