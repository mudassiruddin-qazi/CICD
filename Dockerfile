FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HADOOP_VERSION=1.2.1
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_PREFIX=/usr/local/hadoop
ENV PATH=$PATH:$HADOOP_PREFIX/bin:$JAVA_HOME/bin

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk wget ssh rsync nano && \
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzvf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} ${HADOOP_PREFIX} && \
    mkdir -p ${HADOOP_PREFIX}/HDFS ${HADOOP_PREFIX}/tmp && \
    chmod -R 755 ${HADOOP_PREFIX}

COPY core-site.xml $HADOOP_PREFIX/conf/
COPY hdfs-site.xml $HADOOP_PREFIX/conf/
COPY mapred-site.xml $HADOOP_PREFIX/conf/
COPY hadoop-env.sh $HADOOP_PREFIX/conf/
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 50070 9000 9001

ENTRYPOINT ["/entrypoint.sh"]

