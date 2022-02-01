# Kafka Connect Demo

![Architecture](https://github.com/szczeles/szczeles.github.io/blob/master/images/Summary.svg)

[Slides](https://gitpitch.com/szczeles/public-speaking/kafkaconnect)


### Start and examine MySQL

    docker-compose up -d mysql
    docker exec -ti mysql mysql -pkafkademo demo

### Start Kafka

    docker-compose up -d kafka

### Start Kafka Connect

    docker-compose up -d connect
    http localhost:8083

Then run MySQL Source:

    http POST localhost:8083/connectors @connect/mysql-source.json
    ./bin/kafka-avro-console-consumer --topic mysql.demo.users --from-beginning

### Start PostgreSQL

    docker-compose up -d postgres
    docker exec -ti postgres psql -U postgres demo

Then run Postgres Sink:

    http POST localhost:8083/connectors @connect/postgres-sink.json

### Mongo

    docker-compose up -d mongo

Then fill with data:

    docker exec -ti mongo mongo -u debezium -p dbz --authenticationDatabase admin localhost:27017/demo

    PRIMARY> show collections;
    PRIMARY> db.user_actions.insert({"userId": 1, "ts": new Date(), "ip": "1.2.3.4"})

Finally, setup source and sink:

    http POST localhost:8083/connectors @connect/mongo-source.json 
    http POST localhost:8083/connectors @connect/postgres-mongo-sink.json

### Events + PII masking

    http POST localhost:8083/connectors @connect/postgres-mongo-sink-no-pii.json

### Elasticsearch

Run container:

    docker-compose up -d elasticsearch

Setup connector:

    http POST localhost:8083/connectors @connect/elastic-sink.json

Check results:

    http localhost:9200/mysql.demo.users/_search?q=gid

### S3 sink

First, copy AWS credentials to be available for Connect:

    docker exec connect mkdir /home/appuser/.aws
    docker cp ~/.aws/credentials.mine connect:/home/appuser/.aws/credentials

Then, run the S3 sink:

    http POST :8083/connectors @connect/s3-sink.json

Later, add a table definition in Athena:

```
CREATE EXTERNAL TABLE mysql_demo_users (
  before STRUCT<id: INT, name: STRING, email: STRING, description: STRING, city: STRING>,
  after STRUCT<id: INT, name: STRING, email: STRING, description: STRING, city: STRING>,
  source STRUCT<version: STRING, connector: STRING, name: STRING, ts_ms: BIGINT, snapshot: STRING, db: STRING, table: STRING, server_id: BIGINT, gtid: STRING, file: STRING, pos: BIGINT, row: INT, thread: BIGINT, query: STRING>,
  op STRING,
  ts_ms BIGINT
)
PARTITIONED BY (date STRING)
ROW FORMAT
SERDE 'org.apache.hadoop.hive.serde2.avro.AvroSerDe'
WITH SERDEPROPERTIES ('avro.schema.literal'='
{
  "type": "record",
  "name": "Envelope",
  "namespace": "mysql.demo.users",
  "fields": [
    {
      "name": "before",
      "type": [
        "null",
        {
          "type": "record",
          "name": "Value",
          "fields": [
            {
              "name": "id",
              "type": "int"
            },
            {
              "name": "name",
              "type": "string"
            },
            {
              "name": "email",
              "type": "string"
            },
            {
              "name": "description",
              "type": [
                "null",
                "string"
              ],
              "default": null
            },
            {
              "name": "city2",
              "type": [
                "null",
                "string"
              ],
              "default": null
            }
          ],
          "connect.name": "mysql.demo.users.Value"
        }
      ],
      "default": null
    },
    {
      "name": "after",
      "type": [
        "null",
        "Value"
      ],
      "default": null
    },
    {
      "name": "source",
      "type": {
        "type": "record",
        "name": "Source",
        "namespace": "io.debezium.connector.mysql",
        "fields": [
          {
            "name": "version",
            "type": "string"
          },
          {
            "name": "connector",
            "type": "string"
          },
          {
            "name": "name",
            "type": "string"
          },
          {
            "name": "ts_ms",
            "type": "long"
          },
          {
            "name": "snapshot",
            "type": [
              {
                "type": "string",
                "connect.version": 1,
                "connect.parameters": {
                  "allowed": "true,last,false"
                },
                "connect.default": "false",
                "connect.name": "io.debezium.data.Enum"
              },
              "null"
            ],
            "default": "false"
          },
          {
            "name": "db",
            "type": "string"
          },
          {
            "name": "table",
            "type": [
              "null",
              "string"
            ],
            "default": null
          },
          {
            "name": "server_id",
            "type": "long"
          },
          {
            "name": "gtid",
            "type": [
              "null",
              "string"
            ],
            "default": null
          },
          {
            "name": "file",
            "type": "string"
          },
          {
            "name": "pos",
            "type": "long"
          },
          {
            "name": "row",
            "type": "int"
          },
          {
            "name": "thread",
            "type": [
              "null",
              "long"
            ],
            "default": null
          },
          {
            "name": "query",
            "type": [
              "null",
              "string"
            ],
            "default": null
          }
        ],
        "connect.name": "io.debezium.connector.mysql.Source"
      }
    },
    {
      "name": "op",
      "type": "string"
    },
    {
      "name": "ts_ms",
      "type": [
        "null",
        "long"
      ],
      "default": null
    }
  ],
  "connect.name": "mysql.demo.users.Envelope"
}
')
STORED AS AVRO
LOCATION 's3://kafkaconnect-demo/topics/mysql.demo.users';
```

Sample query:

    SELECT after.id, after.name, before.description before, after.description after, from_unixtime(ts_ms / 1000) FROM mysql_demo_users order by ts_ms

### GCS sink

First, download ADC and copy these into the container:

    gcloud auth login --update-adc
    docker cp ~/.config/gcloud/application_default_credentials.json connect:/tmp/gcp.creds

Create prerequisites: GCS bucket and BQ dataset:

    gsutil mb -l europe-west4 -p analytics-playground-232209 gs://kafka-connect-demo
    bq --location=europe-west4 mk --dataset analytics-playground-232209:kafka_connect_workshops

Then, run the connector and check the created files:

    http POST :8083/connectors @connect/gcs-sink.json
    gsutil ls -r gs://kafka-connect-demo/mariusz

Browse the files in BQ using external table:

    bq mkdef --hive_partitioning_mode=AUTO --source_format=AVRO \
        --hive_partitioning_source_uri_prefix gs://kafka-connect-demo/mariusz/mysql.demo.users \
        "gs://kafka-connect-demo/mariusz/mysql.demo.users/*.avro" > table.def
    bq mk --project_id analytics-playground-232209 --external_table_definition=table.def \
        kafka_connect_workshops.ext_mysql_users

### BigQuery sink

Connector setup:

    http POST :8083/connectors @connect/bq-sink.json

Sample query:

    SELECT after.id, after.name, before.description before, after.description after, TIMESTAMP_MILLIS(ts_ms)
    FROM kafka_connect_workshops.mysql_demo_users

### KSQL processing

Start KSQL with

    docker-compose up -d ksql

Connect to console:

    docker exec -ti ksql ksql

Add sample query

    set 'auto.offset.reset'='earliest';
    create stream users with(kafka_topic='mysql.demo.users', value_format='AVRO');
    create stream address_changed_notification with (value_format='JSON') as 
        select before->email rcpt, concat('Your e-mail address was changed to ', after->email) message
	from users where before->email <> after->email;

Check the data:

    ./bin/kafka-console-consumer --topic ADDRESS_CHANGED_NOTIFICATION --from-beginning

Add REST connector

    http POST :8083/connectors @connect/rest-sink.json

Visit https://beeceptor.com/console/kafkademo and verify requests flow
