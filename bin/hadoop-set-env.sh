#!/bin/bash

#set necessary hadoop environment variables
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_HOME}/lib/native
export HADOOP_OPTS="-Djava.library.path=${HADOOP_HOME}/lib"

#set hadoop configuration directory
export HADOOP_CONF_DIR=${HADOOP_PBS_ECOSYSTEM_HOME}/config_dir/hadoop



#set user sepcify direcotries 
export DISTRIBUTED_DIR="/local_scratch/$USER"

#for yarn
export YARN_LOCAL_DIR=${DISTRIBUTED_DIR}/local
export YARN_LOG_DIR=${DISTRIBUTED_DIR}/logs
export YARN_APP_LOG_DIR=${DISTRIBUTED_DIR}/apps
export YARN_STAGING_DIR=${DISTRIBUTED_DIR}/staging

#for hdfs
export HDFS_NAME_DIR=${DISTRIBUTED_DIR}/hdfs/name
export HDFS_DATA_DIR=${DISTRIBUTED_DIR}/hdfs/data

#for hadoop
export HADOOP_TMP_DIR=${DISTRIBUTED_DIR}/tmp

#for zookeeper
export ZOOKEEPER_DATA_DIR=${DISTRIBUTED_DIR}/zookeeper/data
export ZOOKEEPER_LOG_DIR=${DISTRIBUTED_DIR}/zookeeper/logs

