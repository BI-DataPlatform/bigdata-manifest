#!/bin/sh

export HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-${HADOOP_VERSION}.jar
export HIVE_OPTS="${HIVE_OPTS} --hiveconf metastore.root.logger=${HIVE_LOGLEVEL},console "
export PATH=${HIVE_HOME}/bin:${HADOOP_HOME}/bin:$PATH


# guava 교체
rm -rf $HIVE_HOME/lib/guava-19.0.jar
cp $HADOOP_HOME/share/hadoop/common/lib/guava-27.0-jre.jar $HIVE_HOME/lib/


set +e
if ${HIVE_HOME}/bin/schematool -dbType mysql -info -verbose; then
    echo "Hive metastore schema verified."
else
    if ${HIVE_HOME}/bin/schematool -dbType mysql -initSchema -verbose; then
        echo "Hive metastore schema created."
    else
        echo "Error creating hive metastore: $?"
    fi
fi
set -e

${HIVE_HOME}/bin/hive --service metastore