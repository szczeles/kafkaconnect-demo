FROM confluentinc/cp-kafka-connect-base:5.3.1

RUN confluent-hub install --no-prompt debezium/debezium-connector-mysql:0.10.0 && \
    confluent-hub install --no-prompt debezium/debezium-connector-mongodb:0.10.0 && \
    confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:$CONFLUENT_VERSION && \
    confluent-hub install --no-prompt confluentinc/kafka-connect-elasticsearch:$CONFLUENT_VERSION && \
    confluent-hub install --no-prompt confluentinc/kafka-connect-s3:$CONFLUENT_VERSION && \
    confluent-hub install --no-prompt confluentinc/connect-transforms:latest

# custom sink
COPY kafka-connect-rest-plugin-1.0.3-shaded.jar /usr/share/java/
