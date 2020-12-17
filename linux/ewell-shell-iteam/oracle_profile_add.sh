#!/bin/bash


 cat << EOF >> ~/.bash_profile
export ZOOKEEPER_HOME=${work_dir}/zookeeper
export KAFKA_HOME=${work_dir}/kafka
export JAVA_HOME=/usr/local/java
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$ZOOKEEPER_HOME/lib:\$KAFKA_HOME/libs:\$CLASSPATH
export PATH=\$JAVA_HOME/bin:\$KAFKA_HOME/bin:\$ZOOKEEPER_HOME/bin:\$PATH
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:\$JAVA_HOME/jre/lib/amd64/libjsig.so:\${JAVA_HOME}/jre/lib/amd64/server/libjvm.so:\${JAVA_HOME}/jre/lib/amd64/server:\${JAVA_HOME}/jre/lib/amd64
EOF