#!/bin/sh

SPARK_JAR=$SPARK_HOME/assembly/target/scala-2.10/spark-assembly_2.10-0.9.1-hadoop2.2.0.jar \
$SPARK_HOME/bin/spark-class org.apache.spark.deploy.yarn.Client \
--jar $SPARK_HOME/examples/target/scala-2.10/spark-examples_2.10-assembly-0.9.1.jar \
--class org.apache.spark.examples.JavaSparkPi \
--args yarn-standalone \
--num-workers 3 \
--master-memory 2g \
--worker-memory 2g \
--worker-cores 1
