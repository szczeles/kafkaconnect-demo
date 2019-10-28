GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT  ON *.* TO 'debezium' IDENTIFIED BY 'dbz';

CREATE DATABASE demo;
USE demo;

CREATE TABLE users (
  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  description LONGTEXT
);

INSERT INTO users
VALUES (DEFAULT, "Adam", "adam@niepodam.pl", null),
       (DEFAULT, "Basia", "basia@niepodam.pl", null);
