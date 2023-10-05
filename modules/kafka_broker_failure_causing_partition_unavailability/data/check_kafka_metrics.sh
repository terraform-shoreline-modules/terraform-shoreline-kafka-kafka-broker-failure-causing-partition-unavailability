

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