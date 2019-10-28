#FROM debezium/connect:0.10
FROM confluentinc/cp-kafka-connect-base:5.3.1

RUN confluent-hub install --no-prompt debezium/debezium-connector-mysql:0.10.0 && \
    confluent-hub install --no-prompt debezium/debezium-connector-mongodb:0.10.0 && \
    confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:$CONFLUENT_VERSION && \
    confluent-hub install --no-prompt confluentinc/kafka-connect-elasticsearch:$CONFLUENT_VERSION && \
    confluent-hub install --no-prompt confluentinc/kafka-connect-s3:$CONFLUENT_VERSION 

#ARG POSTGRES_VERSION=42.2.8
#ARG JDBC_SINK_VERSION=5.3.1
#ARG ES_SINK_VERSION=5.3.1
#ARG S3_SINK_VERSIOn=5.3.1

# Install PostgreSQL JDBC Driver
#RUN cd /kafka/libs && curl -sO https://jdbc.postgresql.org/download/postgresql-$POSTGRES_VERSION.jar

# Install Confluent connectors from the Hub
#RUN curl http://client.hub.confluent.io/confluent-hub-client-latest.tar.gz | tar xz && \
#    ./bin/confluent-hub install --component-dir $KAFKA_CONNECT_PLUGINS_DIR --no-prompt confluentinc/kafka-connect-jdbc:$JDBC_SINK_VERSION && \
#    ./bin/confluent-hub install --component-dir $KAFKA_CONNECT_PLUGINS_DIR --no-prompt confluentinc/kafka-connect-elasticsearch:$ES_SINK_VERSION && \
#    ./bin/confluent-hub install --component-dir $KAFKA_CONNECT_PLUGINS_DIR --no-prompt confluentinc/kafka-connect-s3:$S3_SINK_VERSION



