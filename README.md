# Fast Data Cluster

## Content

In case you need a local cluster providing Kafka, Cassandra and Spark you're at the right place.

* [Apache Kafka 2.7.0](http://kafka.apache.org/27/documentation.html)
* [Apache Spark 3.0.2](http://spark.apache.org/releases/spark-release-3-0-2.html)
* [Apache Cassandra 4.0-beta4](http://cassandra.apache.org)
* [Apache Hadoop 3.3.0](https://hadoop.apache.org/docs/r3.3.0/)
* [Apache Flink 1.12.1](https://ci.apache.org/projects/flink/flink-docs-release-1.12)

## Prerequisites

* [Vagrant](https://www.vagrantup.com) (tested with 2.2.14)
* [VirtualBox](http://virtualbox.org) (tested with 6.1.18)
* [Ansible](http://docs.ansible.com/ansible/index.html) (tested with 2.10.5)
* The VMs take approx 18 GB of RAM, so you should have more than that.


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

| Name | |
|:-- |:-- |
|Zookeeper|kafka-1:2181,kafka-2:2181,kafka-3:2181|
|Kafka Brokers|kafka-1:9092,kafka-2:9092,kafka-3:9092|
|Cassandra Hosts|cassandra-1,cassandra-2,cassandra-3|
|YARN Resource Manager|[http://hadoop-1:8088](http://hadoop-1:8088)|
|HDFS Namenode UI|[http://hadoop-1:9870](http://hadoop-1:9870)|

# Usage


## Cassandra

```bash
lucky:~ markus$ vagrant ssh cassandra-1
[vagrant@cassandra-1 ~]$ cqlsh
Connected to analytics at 127.0.0.1:9042.
[cqlsh 5.0.1 | Cassandra 4.0-beta4 | CQL spec 3.4.5 | Native protocol v4]
Use HELP for help.
cqlsh>
```

```
cqlsh> CREATE KEYSPACE example WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 2 };
cqlsh> USE example;
cqlsh:example> CREATE TABLE users (id UUID PRIMARY KEY, lastname text, firstname text );
cqlsh:example> INSERT INTO users (id, lastname, firstname) VALUES (6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47, 'Mustermann','Max') USING TTL 86400 AND TIMESTAMP 123456789;
cqlsh:example> SELECT * FROM users;

 id                                   | firstname | lastname
--------------------------------------+-----------+------------
 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47 |       Max | Mustermann

(1 rows)
```

Check Cluster Status:

```bash
[vagrant@cassandra-1 ~]$ nodetool status
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address       Load        Tokens  Owns  Host ID                               Rack
UN  192.168.10.5  105.69 KiB  16      ?     74e6aff4-3561-4f48-bdbb-d030a9da0c01  rack1
UN  192.168.10.7  100.65 KiB  16      ?     3b428824-a9f2-4a49-ae1d-3639fc584e92  rack1
UN  192.168.10.6  100.66 KiB  16      ?     4418963f-5e94-4046-9cc1-f9614c6eae6e  rack1

Note: Non-system keyspaces don't have the same replication settings, effective ownership information is meaningless
```

## Zookeeper

```bash
[vagrant@kafka-1 ~]$ zookeeper-shell.sh kafka-1:2181/
Connecting to kafka-1:2181/
Welcome to ZooKeeper!
JLine support is disabled

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
ls /
[admin, brokers, cluster, config, consumers, controller, controller_epoch, isr_change_notification, latest_producer_id_block, log_dir_event_notification, zookeeper]
ls /brokers/ids
[0, 1, 2]

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
[vagrant@hadoop-1 ~]$ spark-submit --master yarn --class org.apache.spark.examples.SparkPi --deploy-mode cluster --driver-memory 512M --executor-memory 512M --num-executors 2 /usr/local/spark-3.0.2-bin-without-hadoop/examples/jars/spark-examples_2.12-3.0.2.jar 1000
```

## Flink

### Flink Example Run

#### Access Flink UI:

http://hadoop-1:8088/cluster -> Click ID Link of "Flink session cluster" and then "Tracking URL: ApplicationMaster"

#### Submit a job:

```bash
[vagrant@hadoop-1 ~]$ HADOOP_CLASSPATH=$(hadoop classpath) flink run /usr/local/flink-1.12.1/examples/streaming/WordCount.jar
```


![Flink](doc/flink.png)

## Further Links

- [yarn-default.xml](https://hadoop.apache.org/docs/r3.3.0/hadoop-yarn/hadoop-yarn-common/yarn-default.xml)
- [core-default.xml](https://hadoop.apache.org/docs/r3.2.0/hadoop-project-dist/hadoop-common/core-default.xml)
- [hdfs-default.xml](https://hadoop.apache.org/docs/r3.3.0/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml)
- [Spark Documentation](https://spark.apache.org/docs/latest/)
- [Apache Cassandra Documentation](http://cassandra.apache.org/doc/latest/)
