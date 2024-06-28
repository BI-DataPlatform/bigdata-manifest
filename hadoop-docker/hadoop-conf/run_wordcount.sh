#!/bin/bash

# Test the Hadoop cluster by running wordcount

# Ensure the input directory exists on local filesystem
mkdir -p ./input

# Create input files
echo "Hello Docker" > ./input/file1.txt
echo "Hello Hadoop" > ./input/file2.txt

# Create input directory on HDFS if it doesn't already exist
hadoop fs -mkdir -p /user/root/input

# Clean existing data in HDFS input directory to avoid errors in case files already exist
hdfs dfs -rm -r /user/root/input/*

# Put input files to HDFS
hdfs dfs -put /home/hadoop/input/* /user/root/input

# Ensure the output directory does not exist on HDFS to avoid the error "Output directory already exists"
hdfs dfs -rm -r /user/root/output

# Run wordcount
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/sources/hadoop-mapreduce-examples-3.2.2-sources.jar org.apache.hadoop.examples.WordCount -Dmapreduce.job.queuename=queueA /user/root/input /user/root/output

# Print the input files from HDFS
echo -e "\nInput file1.txt:"
hdfs dfs -cat /user/root/input/file1.txt

echo -e "\nInput file2.txt:"
hdfs dfs -cat /user/root/input/file2.txt

# Print the output of wordcount
echo -e "\nWordcount output:"
hdfs dfs -cat /user/root/output/part-r-00000