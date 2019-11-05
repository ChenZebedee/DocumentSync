# shell 工具执行时端口冲突的解决方法
将 `kafka-run-class.sh` 文件中的内容修改
```
# JMX port to use 
if [ $JMX_PORT ]; then 
KAFKA_JMX_OPTS="$KAFKA_JMX_OPTS -Dcom.sun.management.jmxremote.port=$JMX_PORT" 
fi 

====>

# JMX port to use 
if [[ $ISKAFKASERVER = "true" ]]; then 
JMX_REMOTE_PORT=$JMX_PORT 
else 
JMX_REMOTE_PORT=$CLIENT_JMX_PORT 
fi 
if [ $JMX_REMOTE_PORT ]; then 
KAFKA_JMX_OPTS="$KAFKA_JMX_OPTS -Dcom.sun.management.jmxremote.port=$JMX_REMOTE_PORT" 
fi
```