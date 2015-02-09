#!/bin/bash

declare -A config_subs

config_subs[TICK_TIME]=2000
config_subs[INIT_LIMIT]=10
config_subs[SYNC_LIMIT]=5

### And actually apply those substitutions:
for key in "${!config_subs[@]}"; 
do
    if [ -f $HADOOP_CONF_DIR/$xml ]; then
        sed -i 's#'$key'#'${config_subs[$key]}'#g' $HADOOP_CONF_DIR/$xml
    fi
done

