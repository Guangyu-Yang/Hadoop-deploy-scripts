#!/bin/bash


$HADOOP_HOME/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop namenode
$HADOOP_HOME/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop datanode

$HADOOP_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop resourcemanager
$HADOOP_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop nodemanager

$HADOOP_HOME/sbin/yarn-daemon.sh stop proxyserver --config $HADOOP_CONF_DIR

$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh stop historyserver --config $HADOOP_CONF_DIR
