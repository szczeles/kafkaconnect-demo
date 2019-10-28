# FLOW

### Start and examine MySQL

    docker-compose up -d mysql
    docker exec -ti mysql mysql -ptorunjug

### Start Kafka

docker-compose up -d kafka

### Start Kafka Compose

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
    docker exec mongo /usr/local/bin/init.sh

Then fill with data:

    docker exec -ti mongo mongo -u debezium -p dbz --authenticationDatabase admin localhost:27017/demo

    PRIMARY> show collections;
    PRIMARY> db.user_actions.insert({"userId": 1, "ts": new Date(), "ip": "1.2.3.4"})

Finally, setup source and sink:

    http POST localhost:8083/connectors @connect/mongo-source.json 
    http POST localhost:8083/connectors @connect/postgres-mongo-sink.json

### Elasticsearch

Run container:

    docker-compose up -d elasticsearch

Setup connector:

    http POST localhost:8083/connectors @connect/elastic-sink.json

Check results:

    http localhost:9200/mysql.demo.users/_search?q=placki
