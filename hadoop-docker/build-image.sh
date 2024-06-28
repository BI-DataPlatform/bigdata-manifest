#!/bin/bash
set -ex


# Default Hadoop version
HADOOP_VERSION=3.2.2


echo -e "\nBuilding Hadoop $HADOOP_VERSION cluster docker image...\n"
# sudo docker build --no-cache -t dp/hadoop:$HADOOP_VERSION .
sudo docker build -f dockerfile_hadoop_master -t biqa.tmax.com/de/hadoop_master:20240627_v1 .
sudo docker build -f dockerfile_hadoop_slave -t biqa.tmax.com/de/hadoop_slave:20240627_v1 .
