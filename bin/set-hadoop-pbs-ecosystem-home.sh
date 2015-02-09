#!/bin/bash

echo "export HADOOP_PBS_ECOSYSTEM_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"" >> ~/.bash_profile
source ~/.bash_profile
