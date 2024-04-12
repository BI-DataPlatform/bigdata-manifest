# Download ubuntu base image 20.04
FROM ubuntu:20.04
LABEL Dongpil Yu <dongpilYu95@gmail.com>

WORKDIR /root

# bash를 사용하도록 설정
SHELL ["/bin/bash", "-c"]

ARG HADOOP_VERSION=3.2.2
ARG HADOOP_UID=1001
ARG HADOOP_GID=1001

# hadoop 사용자와 그룹 생성
RUN groupadd -r hadoop -g ${HADOOP_GID} && \
    useradd -r -s /bin/bash -g hadoop -m hadoop -u ${HADOOP_UID} && \
    mkdir -p /home/hadoop && \
    mkdir -p /home/hadoop/.ssh

# 필수 패키지 설치
RUN apt-get update && apt-get install -y openssh-server openjdk-8-jdk wget nano iputils-ping net-tools telnet

# hadoop 사용자 ssh key 생성 및 권한 부여

RUN ssh-keygen -t rsa -f /home/hadoop/.ssh/id_rsa -P '' && \
    cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys && \
    chown -R hadoop:hadoop /home/hadoop && \
    chmod 700 /home/hadoop/.ssh && \
    chmod 600 /home/hadoop/.ssh/authorized_keys

# ssh without key
RUN ssh-keygen -t rsa -f /root/.ssh/id_rsa -P '' && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

# Install HADOOP ${HADOOP_VERSION}
# RUN wget https://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
#     tar -xzvf hadoop-3.2.2.tar.gz && \
#     mv hadoop-3.2.2 /usr/local/hadoop && \
#     rm hadoop-3.2.2.tar.gz

# 로컬에 받아 둔 hadoop 압축 파일 해제
ADD hadoop-${HADOOP_VERSION}.tar.gz /usr/local/hadoop

# 환경변수 설정
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop/hadoop-${HADOOP_VERSION} 
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin 
ENV HADOOP_VERSION=3.2.2

# 하둡 클러스터 내 하둡 슬레이브 정의
ENV HADOOP_SLAVE_NUMBER 2

# Create the default directories
RUN mkdir -p /home/hadoop/hdfs/namenode && \ 
    mkdir -p /home/hadoop/hdfs/datanode && \
    mkdir -p /home/hadoop/hdfs/hadooptmp && \
    mkdir -p $HADOOP_HOME/logs

# Copy resources from the host to the docker container
ADD config/ssh_config /root/.ssh/config
ADD config/ssh_config /home/hadoop/.ssh/config
ADD config/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh
ADD config/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
ADD config/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
ADD config/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
ADD config/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
ADD config/capacity-scheduler.xml ${HADOOP_HOME}/etc/hadoop/capacity-scheduler.xml
ADD config/slaves $HADOOP_HOME/etc/hadoop/slaves
ADD config/include_list $HADOOP_HOME/etc/hadoop/include_list
ADD config/start_hadoop.sh /home/hadoop/start_hadoop.sh
ADD config/run_wordcount.sh /home/hadoop/run_wordcount.sh
ADD config/start-dfs.sh ${HADOOP_HOME}/sbin/start-dfs.sh
ADD config/hadoop-functions.sh ${HADOOP_HOME}/libexec/hadoop-functions.sh


RUN chmod +x /home/hadoop/start_hadoop.sh && \
    chmod +x /home/hadoop/run_wordcount.sh && \
    chmod +x $HADOOP_HOME/etc/hadoop/slaves && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

RUN chown -R hadoop:hadoop $HADOOP_HOME
# RUN chown -R hadoop:hadoop $HADOOP_HOME/etc/hadoop
# RUN chown hadoop:hadoop $HADOOP_HOME/logs
RUN chown -R hadoop:hadoop /home/hadoop

# Format namenode
RUN $HADOOP_HOME/bin/hdfs namenode -format

RUN chown -R hadoop:hadoop /home/hadoop/hdfs/namenode

# Start services. NOTE: the /bin/bash has to run finally to keep the container running
CMD [ "bash", "-c", "service ssh start; /home/hadoop/start_hadoop.sh; exec /bin/bash"]
# CMD ["/root/start_hadoop.sh", "-d"]

# HDFS ports
# EXPOSE 50010 50020 50070 50075 50090 8020 9000
# # Mapred ports
# EXPOSE 10020 19888
# # Yarn ports
# EXPOSE 8030 8031 8032 8033 8040 8042 8088