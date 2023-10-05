
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kafka Broker Failure Causing Partition Unavailability
---

This incident type refers to a situation where the Kafka broker, which is responsible for managing and storing messages in a Kafka cluster, has failed. This failure results in the unavailability of one or more partitions, which are used to distribute messages across the cluster. As a result, messages cannot be sent or received, leading to disruptions in the system's operations. This type of incident requires immediate attention to restore the Kafka broker and ensure that messages can be processed as expected.

### Parameters
```shell
export KAFKA_BROKER="PLACEHOLDER"

export PORT="PLACEHOLDER"

export ZOOKEEPER_HOST="PLACEHOLDER"

export PATH_TO_BROKER_LOGS_DIRECTORY="PLACEHOLDER"

export NUMBER_OF_ADDITIONAL_BROKERS_TO_ADD="PLACEHOLDER"

export PATH_TO_KAFKA_INSTALLATION="PLACEHOLDER"
```

## Debug

### Check if Kafka broker is running
```shell
systemctl status kafka
```

### Check if all Kafka partitions are available
```shell
kafka-topics --bootstrap-server ${KAFKA_BROKER}:${PORT} --describe
```

### Check if there are any disk space issues
```shell
df -h
```

### Check if there are any issues with Zookeeper
```shell
zkCli.sh -server ${ZOOKEEPER_HOST}:${PORT} ls /brokers/ids
```

### Check if there are any errors in Kafka logs
```shell
journalctl -u kafka.service
```

### Check if there are any network issues between Kafka brokers
```shell
ping ${KAFKA_BROKER}
```

### Resource exhaustion due to high traffic or large message sizes
```shell


#!/bin/bash



# Define variables

KAFKA_HOME=${PATH_TO_KAFKA_INSTALLATION}

BROKER_LOG_DIR=${PATH_TO_BROKER_LOGS_DIRECTORY}



# Check CPU and memory usage

top -b -n1 | head -n 5



# Check disk usage

df -h



# Check Kafka broker logs for errors

tail -n 100 $BROKER_LOG_DIR/server.log | grep ERROR



# Check Kafka broker metrics for resource usage

$KAFKA_HOME/bin/kafka-run-class.sh kafka.tools.JmxTool --jmx-url service:jmx:rmi:///jndi/rmi://localhost:9999/jmxrmi --object-name kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec --attributes Count,MeanRate,OneMinuteRate,FiveMinuteRate,FifteenMinuteRate


```

## Repair

### Increase the number of Kafka brokers in the cluster to ensure that there are enough replicas and that the cluster can handle the required load.
```shell


#!/bin/bash



# Set variables

KAFKA_HOME=${PATH_TO_KAFKA_INSTALLATION}

NUM_BROKERS=${NUMBER_OF_ADDITIONAL_BROKERS_TO_ADD}



# Stop Kafka server

${KAFKA_HOME}/bin/kafka-server-stop.sh



# Update server properties file to add new brokers

echo "num.network.threads=3" >> ${KAFKA_HOME}/config/server.properties

echo "num.io.threads=8" >> ${KAFKA_HOME}/config/server.properties

echo "socket.send.buffer.bytes=102400" >> ${KAFKA_HOME}/config/server.properties

echo "socket.receive.buffer.bytes=102400" >> ${KAFKA_HOME}/config/server.properties

echo "socket.request.max.bytes=104857600" >> ${KAFKA_HOME}/config/server.properties



# Add new brokers to the cluster

for i in $(seq 1 ${NUM_BROKERS}); do

    ${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_HOME}/config/server-${i}.properties

done



# Restart Kafka server

${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_HOME}/config/server.properties


```