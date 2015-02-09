#!/bin/bash

# clean and re-create hadoop configure directory
rm -rf ${HBASE_CONF_DIR}
mkdir -p ${HBASE_CONF_DIR}

# copy the hadoop configure templets from etc/hadoop to hadoop configuration directory
cp ${HADOOP_PBS_ECOSYSTEM_HOME}/etc/hbase/* ${HBASE_CONF_DIR}

# set JAVA_HOME & HBASE_CLASSPATH
echo "export JAVA_HOME=${JAVA_HOME}" >> ${HBASE_CONF_DIR}/hbase-env.sh
echo "export HBASE_CLASSPATH=${HBASE_HOME}/conf" >> ${HBASE_CONF_DIR}/hbase-env.sh

# Tell HBase whether it should manage it's own instance of Zookeeper or not. 
echo "export HBASE_MANAGES_ZK=true" >> ${HBASE_CONF_DIR}/hbase-env.sh

# write the pbs nodes info to hbase configure files 
tail -n +2 $PBS_NODEFILE | uniq > ${HBASE_CONF_DIR}/regionservers
