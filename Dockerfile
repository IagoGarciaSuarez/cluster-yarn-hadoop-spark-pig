FROM ubuntu:latest


USER root

RUN apt-get update && apt-get -y dist-upgrade && apt-get install -y openssh-server openjdk-11-jdk openjdk-11-jre wget scala
RUN  apt-get -y update
RUN  apt-get -y install zip 
RUN  apt-get -y install vim
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

RUN ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -P "" \
    && cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys

RUN wget -O /hadoop.tar.gz -q https://archive.apache.org/dist/hadoop/core/hadoop-3.3.5/hadoop-3.3.5.tar.gz \
        && tar xfz hadoop.tar.gz \
        && mv /hadoop-3.3.5 /usr/local/hadoop \
        && rm /hadoop.tar.gz

RUN wget -O /spark.tar.gz -q https://archive.apache.org/dist/spark/spark-3.3.0/spark-3.3.0-bin-hadoop3.tgz
RUN tar xfz spark.tar.gz
RUN mv /spark-3.3.0-bin-hadoop3 /usr/local/spark
RUN rm /spark.tar.gz

# Descarga Pig y lo instala
RUN wget http://apache.rediris.es/pig/latest/pig-0.17.0.tar.gz -P /tools/PIIIG && \
    tar -xzvf /tools/PIIIG/pig-0.17.0.tar.gz -C /tools/PIIIG && \
    mv /tools/PIIIG/pig-0.17.0 /tools/PIIIG/pig && \
    rm /tools/PIIIG/pig-0.17.0.tar.gz

# Declara las variables de entorno dentro de .bashrc para Hadoop y Pig
RUN echo '# Variables de entorno Hadoop y Pig' >> ~/.bashrc && \
    echo 'export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop/' >> ~/.bashrc && \
    echo 'export PIG_CLASSPATH=$HADOOP_CONF_DIR' >> ~/.bashrc && \
    echo 'export PIG_HOME=/tools/PIIIG/pig' >> ~/.bashrc && \
    echo 'export PATH=$PATH:$PIG_HOME/bin:$JAVA_HOME/bin' >> ~/.bashrc && \
    echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.bashrc

# Ejecuta el archivo .bashrc para aplicar los cambios inmediatamente
RUN /bin/bash -c "source ~/.bashrc" 

ENV HADOOP_HOME=/usr/local/hadoop
ENV SPARK_HOME=/usr/local/spark
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$SPARK_HOME:sbin

RUN mkdir -p $HADOOP_HOME/hdfs/namenode \
        && mkdir -p $HADOOP_HOME/hdfs/datanode


COPY config/ /tmp/
RUN mv /tmp/ssh_config $HOME/.ssh/config \
    && mv /tmp/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh \
    && mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml \
    && mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml \
    && mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml.template \
    && cp $HADOOP_HOME/etc/hadoop/mapred-site.xml.template $HADOOP_HOME/etc/hadoop/mapred-site.xml \
    && mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml \
    && cp /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves \
    && mv /tmp/slaves $SPARK_HOME/conf/slaves \
    && mv /tmp/spark/spark-env.sh $SPARK_HOME/conf/spark-env.sh \
    && mv /tmp/spark/log4j.properties $SPARK_HOME/conf/log4j.properties \
    && mv /tmp/spark/spark.defaults.conf $SPARK_HOME/conf/spark.defaults.conf

ADD scripts/spark-services.sh $HADOOP_HOME/spark-services.sh

RUN chmod 744 -R $HADOOP_HOME


RUN $HADOOP_HOME/bin/hdfs namenode -format

EXPOSE 50010 50020 50070 50075 50090 8020 9000
EXPOSE 10020 19888
EXPOSE 8030 8031 8032 8033 8040 8042 8088
EXPOSE 49707 2122 7001 7002 7003 7004 7005 7006 7007 8888 9000

ENTRYPOINT service ssh start; cd $SPARK_HOME; bash


