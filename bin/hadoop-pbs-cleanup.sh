#!/bin/bash

# remove log files
rm -rf ${HADOOP_HOME}/hadoop/logs/*

# remove hadoop configure directory
rm -rf $HADOOP_CONF_DIR

# get the number of nodes from PBS
if [ -e ${PBS_NODEFILE} ]; then
    pbsNodes=`uniq ${PBS_NODEFILE} | awk 'END { print NR }' `
fi

# clean up working directories for N-node Hadoop cluster
for ((i=1; i<=$pbsNodes; i++))
do
    node=`uniq ${PBS_NODEFILE} | awk 'NR=='"$i"'{print;exit}' `
    echo "Clean up node: $node"
    cmd="rm -rf ${YARN_LOCAL_DIR} ${YARN_LOG_DIR}  ${YARN_APP_LOG_DIR} ${YARN_STAGING_DIR} ${HDFS_DATA_DIR} ${HDFS_NAME_DIR} ${HADOOP_TMP_DIR}"
    echo $cmd
    ssh $node $cmd 
done
