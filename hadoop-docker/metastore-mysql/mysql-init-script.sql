CREATE DATABASE hive_metastore;
CREATE USER 'hiveuser'@'%' IDENTIFIED BY '1234';
GRANT ALL PRIVILEGES ON hive_metastore.* TO 'hiveuser'@'%';
FLUSH PRIVILEGES;