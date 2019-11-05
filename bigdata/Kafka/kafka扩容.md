# kafka扩容手册
## 添加机器，修改每台机器的配置
1. 修改原来配置

    原配置：
    ```properties
    broker.id=0
    host.name=192.168.140.151
    port=9092
    num.network.threads=3
    num.io.threads=8
    socket.send.buffer.bytes=102400
    socket.receive.buffer.bytes=102400
    socket.request.max.bytes=104857600
    log.dirs=/opt/bigdata/kafka/data
    num.partitions=1
    num.recovery.threads.per.data.dir=1
    offsets.topic.replication.factor=1
    transaction.state.log.replication.factor=1
    transaction.state.log.min.isr=1
    log.retention.hours=168
    log.segment.bytes=1073741824
    log.retention.check.interval.ms=300000
    zookeeper.connect=hadoop01:2181,hadoop02:2181,hadoop03:2181
    zookeeper.connection.timeout.ms=6000
    group.initial.rebalance.delay.ms=0

    group.min.session.timeout.ms=6000
    group.max.session.timeout.ms=1000000
    ```
    修改后：
    ```properties
    broker.id=0 #根据机器修改
    host.name=hadoop01 #根据机器修改
    port=9092
    num.network.threads=3
    num.io.threads=8
    socket.send.buffer.bytes=102400
    socket.receive.buffer.bytes=102400
    socket.request.max.bytes=104857600
    log.dirs=/opt/bigdata/kafka/data
    num.partitions=1
    num.recovery.threads.per.data.dir=1
    offsets.topic.replication.factor=3
    transaction.state.log.replication.factor=3
    transaction.state.log.min.isr=3
    log.retention.hours=168
    message.max.byte=5242880
    default.replication.factor=3
    replica.fetch.max.bytes=5242880
    log.segment.bytes=1073741824
    log.retention.check.interval.ms=300000
    zookeeper.connect=hadoop01:2181,hadoop02:2181,hadoop03:2181
    zookeeper.connection.timeout.ms=6000
    group.initial.rebalance.delay.ms=0
    group.min.session.timeout.ms=6000
    group.max.session.timeout.ms=1000000
    delete.topic.enable=true
    ```
    >offsets.topic.replication.factor=1 ====> offsets.topic.replication.factor=3    
    >transaction.state.log.replication.factor=1  ====>    transaction.state.log.replication.factor=3    
    >transaction.state.log.min.isr=1 ====>   transaction.state.log.min.isr=3

    添加 `default.replication.factor=3` , `delete.topic.enable=true`
2. 将修改好的kafka scp到新的机器上
    ```shell
    scp -r ${kafka_home} xxx@node:/xxx/xxx
    ```
3. 各机器按照kafka配置配置完成

4. 启动集群
    ```shell
    kafka-server-stop.sh
    kafka-server-start.sh -daemon /xxxxxx/xxx/x/xx/server.properties
    ```

5. 选择要同步的topic，自己编辑json文件如:
    ```json
    {
        "topics":[
            {
                "topic":"ee"
            },
            {
                "topic":"ee_init"
            },
            {
                "topic":"myoggtest"
            },
            {
                "topic":"qq"
            },
            {
                "topic":"qq_init"
            },
            {
                "topic":"rr"
            },
            {
                "topic":"rr_init"
            },
            {
                "topic":"tt"
            },
            {
                "topic":"tt_init"
            },
            {
                "topic":"ww"
            },
            {
                "topic":"ww_init"
            },
            {
                "topic":"yy"
            },
            {
                "topic":"yy_init"
            }
        ],
        "version":1
    }
    ```
6. 生成重新分配topic的方案
    ```  
    kafka-reassign-partitions.sh --zookeeper hadoop01:2181 --topics-to-move-json-file topic-movie.json --broker-list "0,1,2" --generate
    ```
    这个命令会返回一个json串，即自动分配好的,自己创建文件将结果放入文件中如：
    
    创建 reassignment.json 文件里面添加之前命令返回的结果并将replicas改成三个节点，如下：
    ```json
    {"version":1,"partitions":[{"topic":"rr_init","partition":0,"replicas":[0],"log_dirs":["any"]},{"topic":"ww_init","partition":1,"replicas":[0],"log_dirs":["any"]},{"topic":"qq_init","partition":4,"replicas":[0],"log_dirs":["any"]},{"topic":"qq_init","partition":9,"replicas":[1],"log_dirs":["any"]},{"topic":"qq_init","partition":6,"replicas":[0],"log_dirs":["any"]},{"topic":"yy_init","partition":6,"replicas":[1],"log_dirs":["any"]},{"topic":"ee_init","partition":1,"replicas":[1],"log_dirs":["any"]},{"topic":"rr_init","partition":5,"replicas":[1],"log_dirs":["any"]},{"topic":"ee_init","partition":6,"replicas":[0],"log_dirs":["any"]},{"topic":"ee_init","partition":9,"replicas":[1],"log_dirs":["any"]},{"topic":"yy_init","partition":5,"replicas":[0],"log_dirs":["any"]},{"topic":"tt_init","partition":4,"replicas":[0],"log_dirs":["any"]},{"topic":"rr_init","partition":7,"replicas":[1],"log_dirs":["any"]},{"topic":"ww_init","partition":5,"replicas":[0],"log_dirs":["any"]},{"topic":"ee_init","partition":2,"replicas":[0],"log_dirs":["any"]},{"topic":"yy_init","partition":2,"replicas":[1],"log_dirs":["any"]},{"topic":"tt","partition":0,"replicas":[1],"log_dirs":["any"]},{"topic":"tt_init","partition":1,"replicas":[1],"log_dirs":["any"]},{"topic":"ww_init","partition":0,"replicas":[1],"log_dirs":["any"]},{"topic":"ee_init","partition":0,"replicas":[0],"log_dirs":["any"]},{"topic":"rr_init","partition":2,"replicas":[0],"log_dirs":["any"]},{"topic":"rr_init","partition":4,"replicas":[0],"log_dirs":["any"]},{"topic":"ww_init","partition":8,"replicas":[1],"log_dirs":["any"]},{"topic":"tt_init","partition":8,"replicas":[0],"log_dirs":["any"]},{"topic":"yy_init","partition":9,"replicas":[0],"log_dirs":["any"]},{"topic":"ww_init","partition":3,"replicas":[0],"log_dirs":["any"]},{"topic":"rr_init","partition":9,"replicas":[1],"log_dirs":["any"]},{"topic":"yy_init","partition":7,"replicas":[0],"log_dirs":["any"]},{"topic":"tt_init","partition":2,"replicas":[0],"log_dirs":["any"]},{"topic":"ee","partition":0,"replicas":[0],"log_dirs":["any"]},{"topic":"rr_init","partition":8,"replicas":[0],"log_dirs":["any"]},{"topic":"myoggtest","partition":0,"replicas":[1],"log_dirs":["any"]},{"topic":"tt_init","partition":6,"replicas":[0],"log_dirs":["any"]},{"topic":"yy_init","partition":0,"replicas":[1],"log_dirs":["any"]},{"topic":"tt_init","partition":3,"replicas":[1],"log_dirs":["any"]},{"topic":"tt_init","partition":9,"replicas":[1],"log_dirs":["any"]},{"topic":"qq_init","partition":2,"replicas":[0],"log_dirs":["any"]},{"topic":"ee_init","partition":8,"replicas":[0],"log_dirs":["any"]},{"topic":"tt_init","partition":5,"replicas":[1],"log_dirs":["any"]},{"topic":"qq_init","partition":5,"replicas":[1],"log_dirs":["any"]},{"topic":"ee_init","partition":5,"replicas":[1],"log_dirs":["any"]},{"topic":"ww_init","partition":6,"replicas":[1],"log_dirs":["any"]},{"topic":"yy_init","partition":4,"replicas":[1],"log_dirs":["any"]},{"topic":"ee_init","partition":7,"replicas":[1],"log_dirs":["any"]},{"topic":"yy","partition":0,"replicas":[1],"log_dirs":["any"]},{"topic":"qq_init","partition":1,"replicas":[1],"log_dirs":["any"]},{"topic":"tt_init","partition":0,"replicas":[0],"log_dirs":["any"]},{"topic":"yy_init","partition":8,"replicas":[1],"log_dirs":["any"]},{"topic":"ww_init","partition":2,"replicas":[1],"log_dirs":["any"]},{"topic":"ww","partition":0,"replicas":[0],"log_dirs":["any"]},{"topic":"qq","partition":0,"replicas":[0],"log_dirs":["any"]},{"topic":"tt_init","partition":7,"replicas":[1],"log_dirs":["any"]},{"topic":"yy_init","partition":3,"replicas":[0],"log_dirs":["any"]},{"topic":"qq_init","partition":3,"replicas":[1],"log_dirs":["any"]},{"topic":"qq_init","partition":8,"replicas":[0],"log_dirs":["any"]},{"topic":"ww_init","partition":9,"replicas":[0],"log_dirs":["any"]},{"topic":"ee_init","partition":3,"replicas":[1],"log_dirs":["any"]},{"topic":"rr_init","partition":6,"replicas":[0],"log_dirs":["any"]},{"topic":"ww_init","partition":4,"replicas":[1],"log_dirs":["any"]},{"topic":"ww_init","partition":7,"replicas":[0],"log_dirs":["any"]},{"topic":"rr_init","partition":1,"replicas":[1],"log_dirs":["any"]},{"topic":"qq_init","partition":0,"replicas":[0],"log_dirs":["any"]},{"topic":"qq_init","partition":7,"replicas":[1],"log_dirs":["any"]},{"topic":"yy_init","partition":1,"replicas":[0],"log_dirs":["any"]},{"topic":"rr_init","partition":3,"replicas":[1],"log_dirs":["any"]},{"topic":"ee_init","partition":4,"replicas":[0],"log_dirs":["any"]},{"topic":"rr","partition":0,"replicas":[0],"log_dirs":["any"]}]}
    ```
    通过正则修改
    
     `"replicas":\[\d\]` ====> `"replicas":[0,1,2]`

   `"log_dirs":\["any"\]` =====> `"log_dirs":["any","any","any"]`
    ```json
    {"version":1,"partitions":[{"topic":"rr_init","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ww_init","partition":1,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"qq_init","partition":4,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"qq_init","partition":9,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"qq_init","partition":6,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"yy_init","partition":6,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ee_init","partition":1,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"rr_init","partition":5,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ee_init","partition":6,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ee_init","partition":9,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"yy_init","partition":5,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"tt_init","partition":4,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"rr_init","partition":7,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ww_init","partition":5,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ee_init","partition":2,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"yy_init","partition":2,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"tt","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"tt_init","partition":1,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ww_init","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ee_init","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"rr_init","partition":2,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"rr_init","partition":4,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ww_init","partition":8,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"tt_init","partition":8,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"yy_init","partition":9,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ww_init","partition":3,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"rr_init","partition":9,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"yy_init","partition":7,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"tt_init","partition":2,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ee","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"rr_init","partition":8,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"myoggtest","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"tt_init","partition":6,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"yy_init","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"tt_init","partition":3,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"tt_init","partition":9,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"qq_init","partition":2,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ee_init","partition":8,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"tt_init","partition":5,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"qq_init","partition":5,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ee_init","partition":5,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ww_init","partition":6,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"yy_init","partition":4,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ee_init","partition":7,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"yy","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"qq_init","partition":1,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"tt_init","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"yy_init","partition":8,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ww_init","partition":2,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ww","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"qq","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"tt_init","partition":7,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"yy_init","partition":3,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"qq_init","partition":3,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"qq_init","partition":8,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ww_init","partition":9,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ee_init","partition":3,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"rr_init","partition":6,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ww_init","partition":4,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ww_init","partition":7,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"rr_init","partition":1,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"qq_init","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"qq_init","partition":7,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"yy_init","partition":1,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"rr_init","partition":3,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"ee_init","partition":4,"replicas":[0,1,2],"log_dirs":["any","any","any"]},{"topic":"rr","partition":0,"replicas":[0,1,2],"log_dirs":["any","any","any"]}]}
    ```
7. 执行分配方案
    ```shell
    kafka-reassign-partitions.sh --zookeeper hadoop01:2181 --reassignment-json-file reassignment.json --execute
    ```
    >Successfully started reassignment of partitions.
    
    当看到最后返回这个时，说明已经执行成功了
    >如果要查看执行效率，可以通过：
    >```shell
    >kafka-reassign-partitions.sh --zookeeper hadoop01:2181 --reassignment-json-file reassignment.json --verify
    >```   
    >进行查看         
    >当都反回`successfully`怎么说明扩容成功了    
    >is still in progress 是正在处理      
    >successfully 是处理完成