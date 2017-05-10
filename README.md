#Fast Data Cluster

## Content

In case you need a local cluster providing Kafka, Cassandra and Spark you're at the right place.

* [Apache Kafka 0.10.2.0](http://kafka.apache.org/0102/documentation.html)
* [Apache Spark 2.1.1](http://spark.apache.org/releases/spark-release-2-1-1.html)
* [Apache Cassandra 3.10](http://cassandra.apache.org)
* [Apache Hadoop 2.8.0](https://hadoop.apache.org/docs/r2.8.0/)
* [Apache Flink 1.2.0](https://ci.apache.org/projects/flink/flink-docs-release-1.2)

## Prerequisites

* [Vagrant](https://www.vagrantup.com) (tested with 1.9.1)
* [VirtualBox](http://virtualbox.org) (tested with 5.1.22)
* [Ansible](http://docs.ansible.com/ansible/index.html) (tested with 2.3.0.0)
* The vms take approx 18 GB of RAM, so you should have more than that.


:warning: Vagrant might ask you for your admin password. The reason behind is, that `vagrant-hostsupdater` is used to have the vms available with their names in your network.


## Init

```bash
git clone https://github.com/markush81/fastdata-cluster.git
vagrant up
```

## Cluster

The result if everything wents fine should be

![FastData Cluster](doc/fastdata-cluster.png)


## Coordinates

#### Servers

| IP | Hostname | Description | Settings |
|:--- |:-- |:-- |:-- |
|192.168.10.2|kafka-1|running a kafka broker| 1024 MB RAM |
|192.168.10.3|kafka-2|running a kafka broker| 1024 MB RAM |
|192.168.10.4|kafka-3|running a kafka broker| 1024 MB RAM |
|192.168.10.5|cassandra-1|running a cassandra node| 1024 MB RAM |
|192.168.10.6|cassandra-2|running a cassandra nodee| 1024 MB RAM |
|192.168.10.7|cassandra-3|running a cassandra node| 1024 MB RAM |
|192.168.10.8|hadoop-1|running a yarn resourcemanager and nodemanager, hdfs namenode, spark distribution, flink distribution| 4096 MB RAM |
|192.168.10.9|hadoop-2|running a yarn nodemanager, hdfs datanode | 4096 MB RAM |
|192.168.10.10|hadoop-3|running a yarn nodemanager, hdfs datanode | 4096 MB RAM |

### Connections

| Name |  |
|:-- |:-- |
|Zookeeper|kafka-1:2181,kafka-2:2181,kafka-3:2181|
|Kafka Brokers|kafka-1:9092,kafka-2:9092,kafka-3:9092|
|Cassandra Hosts|cassandra-1,cassandra-2,cassandra-3|
|YARN Resource Manager|[http://hadoop-1:8088](http://hadoop-1:8088)|
|HDFS Namenode UI|[http://hadoop-1:50070](http://hadoop-1:50070)|


# Usage


### Connect to Cassandra

```bash
lucky:~ markus$ vagrant ssh cassandra-1
[vagrant@cassandra-1 ~]$ cqlsh
Connected to analytics at 127.0.0.1:9042.
[cqlsh 5.0.1 | Cassandra 3.10 | CQL spec 3.4.4 | Native protocol v4]
Use HELP for help.
cqlsh>
```

Check Cluster Status:

```bash
[vagrant@cassandra-1 ~]$ nodetool status
Datacenter: dc1
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address        Load       Tokens       Owns (effective)  Host ID                               Rack
UN  192.168.10.8   92.34 KiB  256          69.1%             31f056d4-ffa4-4017-bbec-f07c8be4da3f  rack1
UN  192.168.10.9   89.38 KiB  256          68.9%             f54829f4-3f91-4913-98be-e46129852188  rack1
UN  192.168.10.10  82.36 KiB  256          62.0%             69ba4402-c1d5-450c-9b06-8e96ce3fe92f  rack1
```

## Zookeeper

```bash
lucky:~ markus$ vagrant ssh kafka-1
[vagrant@kafka-1 ~]$ zkCli.sh -server kafka-1:2181/
Connecting to kafka-1:2181/
...

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[zk: zookeeper-1:2181,zookeeper-3:2181(CONNECTED) 0] ls /
[cluster, controller, controller_epoch, brokers, zookeeper, admin, isr_change_notification, consumers, config]
[zk: zookeeper-1:2181,zookeeper-3:2181(CONNECTED) 1]

```

## Kafka

### Topic Creation

```bash
lucky:~ markus$ vagrant ssh kafka-1
[vagrant@kafka-1 ~]$ kafka-topics.sh --create --zookeeper kafka-1:2181 --replication-factor 2 --partitions 6 --topic sample
Created topic "sample".
[vagrant@kafka-1 ~]$ kafka-topics.sh --zookeeper kafka-1 --topic sample --describe
Topic:sample	PartitionCount:6	ReplicationFactor:2	Configs:
	Topic: sample	Partition: 0	Leader: 1	Replicas: 1,2	Isr: 1,2
	Topic: sample	Partition: 1	Leader: 2	Replicas: 2,3	Isr: 2,3
	Topic: sample	Partition: 2	Leader: 3	Replicas: 3,1	Isr: 3,1
	Topic: sample	Partition: 3	Leader: 1	Replicas: 1,3	Isr: 1,3
	Topic: sample	Partition: 4	Leader: 2	Replicas: 2,1	Isr: 2,1
	Topic: sample	Partition: 5	Leader: 3	Replicas: 3,2	Isr: 3,2
[vagrant@kafka-1 ~]$
```
### Producer

```bash
[vagrant@kafka-1 ~]$ kafka-console-producer.sh --broker-list kafka-1:9092,kafka-3:9092 --topic sample
[2017-04-22 15:27:41,035] WARN Removing server kafka-1::9092 from bootstrap.servers as DNS resolution failed for kafka-1: (org.apache.kafka.clients.ClientUtils)
Hey, is Kafka up and running?
```

### Consumer

```bash
[vagrant@kafka-1 ~]$ kafka-console-consumer.sh --bootstrap-server kafka-1:9092,kafka-3:9092 --topic sample --from-beginning
Hey, is Kafka up and running?
```

## YARN

The YARN ResourceManager UI can be accessed by [http://hadoop-1:8088](http://hadoop-1:8088), from there you can navigate to your application .

![YARN](doc/yarn.png)

## Spark

### Spark Examples

```bash
lucky:~ markus$ vagrant ssh hadoop-1
[vagrant@hadoop-1 ~]$ spark-submit --master yarn --class org.apache.spark.examples.SparkPi --deploy-mode cluster --driver-memory 512M --executor-memory 512M --num-executors 2 /usr/local/spark-2.1.1-bin-without-hadoop/examples/jars/spark-examples_2.11-2.1.1.jar 1000
```

### Own Spark Streaming Job

For running your own packages (e.g. from [Spark Playground](https://github.com/markush81/spark-playground/blob/master/doc/StreamingSample.md)), copy them to `./exchange` which is mapped inside to `/vagrant/exchange`:

In order to run this example, prepare Cassandra first

```bash
lucky:fastdata-cluster markus$ vagrant ssh cassandra-1
[vagrant@cassandra-1 ~]$ cqlsh
Connected to analytics at 127.0.0.1:9042.
[cqlsh 5.0.1 | Cassandra 3.10 | CQL spec 3.4.4 | Native protocol v4]
Use HELP for help.
cqlsh> CREATE KEYSPACE sample WITH REPLICATION = { 'class' : 'NetworkTopologyStrategy', 'dc1' : 2  };
cqlsh> CREATE TABLE sample.wordcount (
   ...     time timestamp,
   ...     count bigint,
   ...     PRIMARY KEY (time));
```

Next submit the application to YARN:

```bash
spark-submit --master yarn --class org.mh.playground.spark.StreamingSample --conf spark.yarn.submit.waitAppCompletion=false --deploy-mode cluster --executor-memory 1G --num-executors 3 /vagrant/exchange/spark-playground-all.jar
```

Produce records into Kafka:

```bash
lucky:fastdata-cluster markus$ vagrant ssh kafka-1
[vagrant@kafka-1 ~]$ kafka-producer-perf-test.sh --producer-props bootstrap.servers="kafka-1:9092,kafka-2:9092,kafka-3:9092" --topic sample --num-records 2000 --throughput 100 --record-size 256

```

Finally it should look similar to this:

![Spark Streaming Applicaton Master](doc/spark-streaming.png)

## Flink

### Flink Examples

You can find Flink Web UI via YARN UI, e.g. [http://hadoop-1:8088/proxy/application_1492940607011_0001/#/overview](http://hadoop-1:8088/proxy/application_1492940607011_0001/#/overview)

Submit a job:

```bash
[vagrant@hadoop-1 ~]$ flink run /usr/local/flink-1.2.0/examples/streaming/WordCount.jar
```

![Flink](doc/flink.png)

## Further Links

- [yarn-default.xml](https://hadoop.apache.org/docs/r2.8.0/hadoop-yarn/hadoop-yarn-common/yarn-default.xml)
- [core-default.xml](https://hadoop.apache.org/docs/r2.8.0/hadoop-project-dist/hadoop-common/core-default.xml)
- [hdfs-default.xml](https://hadoop.apache.org/docs/r2.8.0/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml)
- [Spark Documentation](https://spark.apache.org/docs/2.1.0/)
- [Apache Cassandra Documentation 3.9](http://cassandra.apache.org/doc/3.9/)
