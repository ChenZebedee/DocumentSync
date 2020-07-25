#!/bin/sh

<<<<<<< HEAD

list=`seq $1`
parNum=$2
numRecords=$3
recordSize=$4
runWhat=$5
=======
allTopicNum=$1
list=`seq ${allTopicNum}`
parNum=$2
numRecords=$3
recordSize=$4
morePartitionTopic=$5
runWhat=$6
onePartitionTopic=$[${allTopicNum}-${morePartitionTopic}]
>>>>>>> 28385cb26b0f52ca03a1ea8e8a59a7c3a486c4f1


create(){
for i in ${list}
do
<<<<<<< HEAD
kafka-topics.sh --create --zookeeper data1:2181,data2:2181,data3:2181 --replication-factor 2 --partitions ${parNum} --topic "test-${i}" 2>&1 > log/create/test-${i}
=======
mkdir -p log/create/${parNum}/${allTopicNum};
kafka-topics.sh --create --zookeeper data1:2181,data2:2181,data3:2181 --replication-factor 1 --partitions ${parNum} --topic "test-${parNum}-${i}" 2>&1 > log/create/${parNum}/${allTopicNum}/test-${parNum}-${i}
>>>>>>> 28385cb26b0f52ca03a1ea8e8a59a7c3a486c4f1
done
}

producer(){
for i in ${list}
do
<<<<<<< HEAD
mkdir -p log/producer/${parNum}/${numRecoure}/${recordSize};
kafka-producer-perf-test.sh --topic "test-${i}" --num-records ${numRecords} --record-size ${recordSize} --throughput -1 --producer-props bootstrap.servers=data1:9092,data2:9092,data3:9092 acks=-1 2>&1 > log/producer/${parNum}/${numRecoure}/${recordSize}/test-${i} &
=======
mkdir -p log/producer/${parNum}/${allTopicNum};
kafka-producer-perf-test.sh --topic "test-${parNum}-${i}" --numRecords ${numRecords} --recordSize ${recordSize} --throughput -1 --producer-props bootstrap.servers=data1:9092 acks=-1 2>&1 > log/producer/${parNum}/${allTopicNum}/test-${parNum}-${i}
>>>>>>> 28385cb26b0f52ca03a1ea8e8a59a7c3a486c4f1
done
}

consumer(){
for i in ${list}
do
<<<<<<< HEAD
mkdir -p log/consumer/${numRecords}
kafka-consumer-perf-test.sh --broker-list data1:9092,data2:9092,data3:9092  --topic test-${i} --messages ${numRecords} 2>&1 > log/consumer/${numRecords}/test-${i} &
done
}

delete(){
for i in ${list}
do
kafka-topics.sh -delete -zookeeper data1:2181,data2:2181,data3:2181 -topic test-${i}
=======
mkdir -p log/consumer/${parNum}/${allTopicNum}
kafka-consumer-perf-test.sh --broker-list data1:9092  --topic test-${parNum}-${i} --messages ${numRecords}  --num-fetch-threads ${parNum} --threads ${parNum} 2>&1 > log/consumer/${parNum}/${allTopicNum}/test-${parNum}-${i} &
done
wait;
}

business_consumer(){
for i in ${onePartitionTopic}
do
mkdir -p log/consumer/${parNum}/${onePartitionTopic}
kafka-consumer-perf-test.sh --broker-list data1:9092  --topic test-1-${i} --messages ${numRecords}  --num-fetch-threads 1 --threads 1 2>&1 > log/consumer/1/${onePartitionTopic}/test-1-${i} & 
done
for j in ${morePartitionTopic}
do
mkdir -p log/consumer/${parNum}/${morePartitionTopic}
kafka-consumer-perf-test.sh --broker-list data1:9092  --topic test-${parNum}-${i} --messages ${numRecords}  --num-fetch-threads ${parNum} --threads ${parNum} 2>&1 > log/consumer/${parNum}/${morePartitionTopic}/test-${parNum}-${i} & 
done
wait
}





delete(){
for i in ${list}
do
kafka-topics.sh --delete --zookeeper data1:2181,data2:2181,data3:2181 --topic test-${parNum}-${i}
>>>>>>> 28385cb26b0f52ca03a1ea8e8a59a7c3a486c4f1
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
<<<<<<< HEAD
elif [ ${runWhat} == "4" ]
=======
elif [  ${runWhat} == "4" ]
>>>>>>> 28385cb26b0f52ca03a1ea8e8a59a7c3a486c4f1
then
delete
elif [  ${runWhat} == "5" ]
then
<<<<<<< HEAD
create
producer
consumer
fi
=======
delete
create
producer
consumer
elif [ ${runWhat} == "6" ]
then
business_consumer
fi

>>>>>>> 28385cb26b0f52ca03a1ea8e8a59a7c3a486c4f1
