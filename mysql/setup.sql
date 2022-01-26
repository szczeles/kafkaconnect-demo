CREATE USER 'debezium'@'%' IDENTIFIED BY 'dbz';
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT  ON *.* TO 'debezium'@'%';

CREATE DATABASE demo;
USE demo;

CREATE TABLE users (
  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  description LONGTEXT
);

INSERT INTO users
VALUES (DEFAULT, "Alice", "alice@example.com", null),
       (DEFAULT, "Bob", "bob@example.com", null);
