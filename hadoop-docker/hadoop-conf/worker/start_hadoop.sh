#!/bin/bash

# The default HADOOP_SLAVE_NUMBER is 2
HADOOP_SLAVE_NUMBER=${HADOOP_SLAVE_NUMBER:-2}
echo "HADOOP_SLAVE_NUMBER =" $HADOOP_SLAVE_NUMBER

# Delete the old slaves file
# rm $HADOOP_HOME/etc/hadoop/slaves
# hadoop 2.x는 slaves, 3.x는 workers 사용

rm $HADOOP_HOME/etc/hadoop/workers

# Change slaves file
i=1
while [ $i -lt $((HADOOP_SLAVE_NUMBER+1)) ]
do
	echo "hadoop-slave$i" >> $HADOOP_HOME/etc/hadoop/workers
	((i++))
done 

echo "start_hadoop.sh execution success"

# sleep 1000

# Start hadoop service
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

# if [[ $1 == "-d" ]]; then
# 	while true
# 	do 
# 		sleep 10
# 	done
# elif [[ $1 == "-bash" ]]; then
# 	/bin/bash
# fi