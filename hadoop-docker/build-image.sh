#!/bin/bash

# Default Hadoop version
HADOOP_VERSION=3.2.2


echo -e "\nBuilding Hadoop $HADOOP_VERSION cluster docker image...\n"
# sudo docker build --no-cache -t dp/hadoop:$HADOOP_VERSION .
sudo docker build -f dockerfile_hadoop_master -t dp/hadoop_master:$HADOOP_VERSION .
sudo docker build -f dockerfile_hadoop_slave -t dp/hadoop_slave:$HADOOP_VERSION .