#!/bin/bash

# Default Hadoop version
HADOOP_VERSION=3.2.2


echo -e "\nBuilding Hadoop $HADOOP_VERSION cluster docker image...\n"
# sudo docker build --no-cache -t dp/hadoop:$HADOOP_VERSION .
sudo docker build -t dp/hadoop:$HADOOP_VERSION .