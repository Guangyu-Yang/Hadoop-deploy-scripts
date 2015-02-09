#!/bin/bash

 function print_usage {
     echo "Usage: -c CORES: The number of cores required on each host."
     echo "       -m MEMORY: The amount of memory required on each host in GB. "
     echo "       -s SLAVE_NODES: number of slave nodes"
     echo "       -k HBASE: "True" if HBase is installed, "False" if not."
     echo "       -h: Print help"
 }

# initialize arguments
CORES=""
MEMORY=""
SLAVE_NODES=""
HBASE="False"


# parse arguments
args=`getopt c:m:s:k:h $*`
if test $? != 0
then
    print_usage
    exit 1
fi
set -- $args
for i
do
    case "$i" in
        -c) shift;
            CORES=$1
            shift;;
        -m) shift;
            MEMORY=$1
            shift;;
        -s) shift;
            SLAVE_NODES=$1
            shift;;
        -k) shift;
            HBASE=$1
            ;;
        -h) shift;
            print_usage
            exit 0
    esac
done

NODES=`uniq $PBS_NODEFILE | awk 'END { print NR }'`
MASTER_NODE=`awk 'NR==1{print;exit}' $PBS_NODEFILE`

# clean and re-create hadoop configure directory
rm -rf ${HADOOP_CONF_DIR}
mkdir -p ${HADOOP_CONF_DIR}

# copy the hadoop configure templets from etc/hadoop to hadoop configuration directory
cp ${HADOOP_PBS_ECOSYSTEM_HOME}/etc/hadoop/* ${HADOOP_CONF_DIR}

# set JAVA_HOME
echo "export JAVA_HOME=${JAVA_HOME}" >> ${HADOOP_CONF_DIR}/hadoop-env.sh

# fix the 32 bit compiling bugs
echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\"${HADOOP_HOME}/lib/native\"" >> ${HADOOP_CONF_DIR}/hadoop-env.sh
echo "export HADOOP_OPTS=\"-Djava.library.path=${HADOOP_HOME}/lib\"" >> ${HADOOP_CONF_DIR}/hadoop-env.sh

# write the pbs nodes info to hadoop configure files
echo $MASTER_NODE > ${HADOOP_CONF_DIR}/masters
tail -n +2 $PBS_NODEFILE | uniq > ${HADOOP_CONF_DIR}/slaves

declare -A config_dirs
config_dirs[MASTER_NODE]="$MASTER_NODE"
config_dirs[HADOOP_TMP_DIR]="$HADOOP_TMP_DIR"
config_dirs[YARN_STAGING_DIR]="$YARN_STAGING_DIR"
config_dirs[YARN_LOCAL_DIR]="$YARN_LOCAL_DIR"
config_dirs[YARN_LOG_DIR]="$YARN_LOG_DIR"
config_dirs[YARN_APP_LOG_DIR]="$YARN_APP_LOG_DIR"
config_dirs[HDFS_NAME_DIR]="$HDFS_NAME_DIR"
config_dirs[HDFS_DATA_DIR]="$HDFS_DATA_DIR"

for key in "${!config_dirs[@]}"; do
    for xml in mapred-site.xml core-site.xml hdfs-site.xml yarn-site.xml
    do
        if [ -f $HADOOP_CONF_DIR/$xml ]; then
            sed -i 's#'$key'#'${config_dirs[$key]}'#g' $HADOOP_CONF_DIR/$xml
        fi
    done
done

# optimize hadoop parameters based on running environment
config_paras[]="$"
strings=`python $HADOOP_PBS_ECOSYSTEM_HOME/bin/yarn-utils.py -c $CORES -m $MEMORY -d $SLAVE_NODES -k $HBASE | tail -10`

declare -A config_paras
config_paras[yarn.nodemanager.resource.memory-mb]="YARN_NODEMANAGER_RESOURCE_MEMORY_MB"
config_paras[yarn.scheduler.maximum-allocation-mb]="YARN_SCHEDULER_MAXIMUM_ALLOCATION_MB"
config_paras[yarn.scheduler.minimum-allocation-mb]="YARN_SCHEDULER_MINIMUM_ALLOCATION_MB"
config_paras[yarn.app.mapreduce.am.resource.mb]="YARN_APP_MAPREDUCE_AM_RESOURCE_MB"
config_paras[yarn.app.mapreduce.am.command-opts]="YARN_APP_MAPREDUCE_AM_COMMAND_OPTS"
config_paras[mapreduce.reduce.memory.mb]="MAPREDUCE_REDUCE_MEMORY_MB"
eonfig_paras[mapreduce.map.memory.mb]="MAPREDUCE_MAP_MEMORY_MB"
config_paras[mapreduce.map.java.opts]="MAPREDUCE_MAP_JAVA_OPTS"
config_paras[mapreduce.reduce.java.opts]="MAPREDUCE_REDUCE_JAVA_OPTS"
config_paras[mapreduce.task.io.sort.mb]="MAPREDUCE_TASKIO_SORT_MB"

for string in $strings
do
    str1=`echo $string | cut -d'=' -f1`
    str2=`echo $string | cut -d'=' -f2`
    
    for key in "${!config_paras[@]}"; do
        for xml in mapred-site.xml core-site.xml hdfs-site.xml yarn-site.xml
        do
            if [ -f $HADOOP_CONF_DIR/$xml ]; then
                if [ "$str1" == "${config_paras[$key]}" ]; then
                    sed -i 's#'$key'#'"$str2"'#g' $HADOOP_CONF_DIR/$xml
                fi
            fi
        done
    done
done

# build neccessary folders
for ((i=1; i<=$NODES; i++))
do
    node=`awk 'NR=='"$i"'{print;exit}' $PBS_NODEFILE`
    echo "Configuring node: $node"

    cmd="killall -9 java"
    echo $cmd
    ssh $node $cmd

    cmd="rm -rf $YARN_LOCAL_DIR; mkdir -p $YARN_LOCAL_DIR"
    echo $cmd
    ssh $node $cmd 
    
    cmd="rm -rf $YARN_LOG_DIR; mkdir -p $YARN_LOG_DIR"
    echo $cmd
    ssh $node $cmd 
    
    cmd="rm -rf $YARN_APP_LOG_DIR; mkdir -p $YARN_APP_LOG_DIR"
    echo $cmd
    ssh $node $cmd 
    
    cmd="rm -rf $YARN_STAGING_DIR; mkdir -p $YARN_STAGING_DIR/history/done $YARN_STAGING_DIR/history/done_intermediate"
    echo $cmd
    ssh $node $cmd 
    
    cmd="rm -rf $HDFS_NAME_DIR; mkdir -p $HDFS_NAME_DIR"
    echo $cmd
    ssh $node $cmd 
    
    cmd="rm -rf $HDFS_DATA_DIR; mkdir -p $HDFS_DATA_DIR"
    echo $cmd
    ssh $node $cmd 
done
