FROM confluentinc/cp-kafka-connect-base:7.0.1

RUN confluent-hub install --no-prompt debezium/debezium-connector-mysql:1.7.1 && \
    confluent-hub install --no-prompt debezium/debezium-connector-mongodb:1.7.1 && \
    confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.3.1 && \
    confluent-hub install --no-prompt confluentinc/kafka-connect-elasticsearch:11.1.8 && \
    confluent-hub install --no-prompt confluentinc/kafka-connect-s3:10.0.5 && \
    confluent-hub install --no-prompt confluentinc/kafka-connect-gcs:5.5.11 && \
    confluent-hub install --no-prompt wepay/kafka-connect-bigquery:2.2.2 && \
    confluent-hub install --no-prompt confluentinc/connect-transforms:latest

# custom sink
COPY kafka-connect-rest-plugin-1.0.3-shaded.jar /usr/share/java/
