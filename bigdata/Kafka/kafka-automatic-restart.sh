#!/bin/sh
source /etc/profile

ARGS=`getopt -o "h:p::l::" --long "kafka-home:,proc-name::,log-name::" -- "$@"`
echo ${ARGS}

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$ARGS"
while true
do
    case "$1" in
        -h|--kafka-home)
            kafka_home=$2
            shift 2;;
        -p|--proc-name)
            proc_name=$2
            shift 2;;
        -l|--log-name)
            log_path=$2
            shift 2
            ;;
        --) shift ; break ;;
        *)
            echo "??"
            exit 1
    esac
done

if [ ! $proc_name ]
then
proc_name="kafka.Kafka"
fi
if [ ! $log_path ]
then
log_path="${kafka_home}/logs/restart.log"
fi

pid=0

proc_num()
{
        num=`ps -ef | grep $proc_name | grep -v grep | wc -l`
        return $num
}

proc_id()
{
        pid=`ps -ef | grep $proc_name | grep -v grep | awk '{print $2}'`
}

proc_num
number=$?
echo $number
if [ $number -eq 0 ]
then
    $kafka_home/bin/kafka-server-start.sh -daemon $kafka_home/config/server.properties
    proc_id
    echo "server down restart..." >> $log_path
    echo ${pid}, `date` >> $log_path
fi