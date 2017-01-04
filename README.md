#Fast Data Cluster

## Content

In case you need a local cluster providing Kafka, Cassandra and Spark you're at the right place.

* [Apache Kafka 0.10.1.0](http://kafka.apache.org/0101/documentation.html)
* [Apache Spark 2.1.0](http://spark.apache.org/releases/spark-release-2-1-0.html)
* [Apache Cassandra 3.9 provided by DataStax](https://academy.datastax.com/planet-cassandra/cassandra)

## Setup

### Prerequisites

* [Vagrant](https://www.vagrantup.com) (tested with 1.9.1)
* [VirtualBox](http://virtualbox.org) (tested with 5.1.12)
* The Nodes take 12 GB of RAM, so you should have much more than that.


### Init

```
git clone https://github.com/markush81/fastdata-cluster.git
vagrant up
```

## Cluster

The result if everything wents fine should be

![FastData Cluster](doc/fastdata-cluster.png)


### Coordinates

#### Servers

| IP | Hostname | Description | Settings |
|:--- |:-- |:-- |:-- |
|192.168.10.2|zookeeper-1|running a zookeeper instance| 1 GB RAM |
|192.168.10.3|zookeeper-2|running a zookeeper instance| 1 GB RAM |
|192.168.10.4|zookeeper-3|running a zookeeper instance| 1 GB RAM |
|192.168.10.5|kafka-1|running a kafka broker| 1 GB RAM |
|192.168.10.6|kafka-2|running a kafka broker| 1 GB RAM |
|192.168.10.7|kafka-3|running a kafka broker| 1 GB RAM |
|192.168.10.8|analytics-1|running a cassandra seed node, spark master and a spark slave| 2 GB RAM |
|192.168.10.9|analytics-2|running a cassandra node and a spark slave| 2 GB RAM |
|192.168.10.10|analytics-3|running a cassandra seed node and a spark slave| 2 GB RAM |

#### Connections

| Name |  |
|:-- |:-- |
|Zookeeper|zookeeper.connect=192.168.10.2:2181,192.168.10.3:2181,192.168.10.4:2181|
|Kafka Brokers|192.168.10.5:9092,192.168.10.6:9092,192.168.10.7:9092|
|Cassandra Hosts|192.168.10.8,192.168.10.9,192.168.10.10|
|Spark UI|[http://192.168.10.8:8080](http://192.168.10.8:8080)|
|Spark REST Submit|spark://192.168.10.8:6066|
|Spark Master|spark://192.168.10.8:7077|

(**Note:** most things are not bound to hostname, but IP for the simple reason that you do not need to setup `/etc/hosts` for your host machine)


## Usage

You either can ssh into one of the boxes or if you have all utilities in required version on your host machine as well, just use it from there (Examples are from host machine).

### Connect to Cassandra

```
lucky:~ markus$ cqlsh 192.168.10.8
Connected to analytics at 192.168.10.8:9042.
[cqlsh 5.0.1 | Cassandra 3.9.0 | CQL spec 3.4.2 | Native protocol v4]
Use HELP for help.
cqlsh> 
```

### Zookeeper

```
lucky:~ markus$ zookeeper-shell 192.168.10.2:2181,192.168.10.3:2181
Connecting to 192.168.10.2:2181,192.168.10.3:2181
Welcome to ZooKeeper!
JLine support is disabled

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
^Clucky:~ markus$ zookeeper-shell 192.168.10.2:2181,192.168.10.3:2181,192.168.10.4:2181
Connecting to 192.168.10.2:2181,192.168.10.3:2181,192.168.10.4:2181
Welcome to ZooKeeper!
JLine support is disabled

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
ls /
[cluster, controller, controller_epoch, brokers, zookeeper, admin, isr_change_notification, consumers, config]
ls /brokers/ids
[1, 2, 3]
```

### Kafka

#### Topic Creation

```
lucky:~ markus$ kafka-topics --create --zookeeper 192.168.10.2:2181 --replication-factor 2 --partitions 6 --topic sample
Created topic "sample".
lucky:~ markus$ kafka-topics --zookeeper 192.168.10.2 --topic sample --describe
Topic:sample	PartitionCount:6	ReplicationFactor:2	Configs:
	Topic: sample	Partition: 0	Leader: 2	Replicas: 2,3	Isr: 2,3
	Topic: sample	Partition: 1	Leader: 3	Replicas: 3,1	Isr: 3,1
	Topic: sample	Partition: 2	Leader: 1	Replicas: 1,2	Isr: 1,2
	Topic: sample	Partition: 3	Leader: 2	Replicas: 2,1	Isr: 2,1
	Topic: sample	Partition: 4	Leader: 3	Replicas: 3,2	Isr: 3,2
	Topic: sample	Partition: 5	Leader: 1	Replicas: 1,3	Isr: 1,3
lucky:~ markus$ 
```
#### Producer

```
lucky:~ markus$ kafka-console-producer --broker-list 192.168.10.5:9092,192.168.10.6:9092,192.168.10.7:9092 --topic sample
Hey, is Kafka up and running?
```

#### Consumer

```
lucky:~ markus$ kafka-console-consumer --bootstrap-server 192.168.10.5:9092,192.168.10.6:9092,192.168.10.7:9092 --topic sample --from-beginning
Hey, is Kafka up and running?
```

### Spark

Copy a spark application to `./spark` shared folder.

```
lucky:~ markus$ spark-submit --master spark://192.168.10.8:6066 --class org.mh.playground.spark.StreamingSample --deploy-mode cluster /vagrant/spark/spark-playground-all.jar
Running Spark using the REST application submission protocol.
Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
17/01/04 13:51:48 INFO RestSubmissionClient: Submitting a request to launch an application in spark://192.168.10.8:6066.
17/01/04 13:51:49 INFO RestSubmissionClient: Submission successfully created as driver-20170104135149-0000. Polling submission state...
17/01/04 13:51:49 INFO RestSubmissionClient: Submitting a request for the status of submission driver-20170104135149-0000 in spark://192.168.10.8:6066.
17/01/04 13:51:49 INFO RestSubmissionClient: State of driver driver-20170104135149-0000 is now RUNNING.
17/01/04 13:51:49 INFO RestSubmissionClient: Driver is running on worker worker-20170104132845-192.168.10.8-43781 at 192.168.10.8:43781.
17/01/04 13:51:49 INFO RestSubmissionClient: Server responded with CreateSubmissionResponse:
{
  "action" : "CreateSubmissionResponse",
  "message" : "Driver successfully submitted as driver-20170104135149-0000",
  "serverSparkVersion" : "2.1.0",
  "submissionId" : "driver-20170104135149-0000",
  "success" : true
}
```

The UI can be accessed by [http://192.168.10.8:8080](http://192.168.10.8:8080), from there you can navigate to your application and it can look like

![Spark running streaming](doc/spark-streaming.png)