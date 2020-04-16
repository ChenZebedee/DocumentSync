#!/bin/sh


list=`seq $1`
parNum=$2
numRecords=$3
recordSize=$4
runWhat=$5


create(){
for i in ${list}
do
kafka-topics.sh --create --zookeeper data1:2181,data2:2181,data3:2181 --replication-factor 2 --partitions ${parNum} --topic "test-${i}" 2>&1 > log/create/test-${i}
done
}

producer(){
for i in ${list}
do
mkdir -p log/producer/${parNum}/${numRecoure}/${recordSize};
kafka-producer-perf-test.sh --topic "test-${i}" --num-records ${numRecords} --record-size ${recordSize} --throughput -1 --producer-props bootstrap.servers=data1:9092,data2:9092,data3:9092 acks=-1 2>&1 > log/producer/${parNum}/${numRecoure}/${recordSize}/test-${i} &
done
}

consumer(){
for i in ${list}
do
mkdir -p log/consumer/${numRecords}
kafka-consumer-perf-test.sh --broker-list data1:9092,data2:9092,data3:9092  --topic test-${i} --messages ${numRecords} 2>&1 > log/consumer/${numRecords}/test-${i} &
done
}

delete(){
for i in ${list}
do
kafka-topics.sh -delete -zookeeper data1:2181,data2:2181,data3:2181 -topic test-${i}
done
}


if [  ${runWhat} == "1" ]
then
create
elif [  ${runWhat} == "2" ]
then
producer
elif [  ${runWhat} == "3" ]
then
consumer
elif [ ${runWhat} == "4" ]
then
delete
elif [  ${runWhat} == "5" ]
then
create
producer
consumer
fi