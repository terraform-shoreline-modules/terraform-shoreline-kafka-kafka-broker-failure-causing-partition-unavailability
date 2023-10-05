

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