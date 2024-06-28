## Hadoop, Hive 환경 구축

### 도커 컨테이너 환경에서 hadoop-hive 클러스터 띄우기

build-image.sh 실행 후 생성된 이미지 명으로 start_containers 파일 수정
start_containers.sh 실행

### k8s 환경에서 hadoop-hive 클러스터 띄우기

쿠버네티스 환경에서 helm install hadoop-hive hadoop-hive -n [namespace]


### 쿠버네티스 환경에서 테스트할 때 변경 사항

#### 1. master/start_hadoop.sh, slave/start_hadoop.sh 변경
도커 컨테이너에서 쿠버네티스 환경으로 이동할 때, worker node를 바라보는 headless service명으로 변경해야 합니다.

- **파일**: `master/start_hadoop.sh`, `slave/start_hadoop.sh`
- **변경 내용**:
  - 기존 도커 환경에서의 설정(`hadoop-slave$i`)을 주석 처리하고,
  - 쿠버네티스 환경에서의 설정(`hadoop-worker-$new_idx.hadoop-worker-headless.de.svc.cluster.local`)을 활성화합니다.

```bash

# master/start_hadoop.sh, slave/start_hadoop.sh 일부분

rm $HADOOP_HOME/etc/hadoop/workers
# Change workers file for Kubernetes
i=1
while [ $i -lt $((HADOOP_SLAVE_NUMBER+1)) ]
do
    new_idx=$((i-1))
    echo "hadoop-slave$i" >> $HADOOP_HOME/etc/hadoop/workers
    # echo "hadoop-worker-$new_idx.hadoop-worker-headless.de.svc.cluster.local" >> $HADOOP_HOME/etc/hadoop/workers
    ((i++))
done

```

#### 2. master/start-dfs.sh 변경
도커 컨테이너에서 쿠버네티스 환경으로 이동할 때, hostname을 master node를 바라보는 headless service명으로 변경해야 합니다.

- **파일**: `master/start-dfs.sh`
- **변경 내용**:
  - helm chart를 띄울 때 환경 변수 형태로 제공되는 MASTER_HEADLESS_SERVICE가 NAMENODES가 되도록 변경해야 합니다.


```bash

# master/start-dfs.sh

NAMENODES=$("${HADOOP_HDFS_HOME}/bin/hdfs" getconf -namenodes 2>/dev/null)

if [[ -z "${NAMENODES}" ]]; then
  NAMENODES=$(hostname)
fi

# NAMENODES=${MASTER_HEADLESS_SERVICE}
echo "Starting namenodes on [${NAMENODES}]"
```


