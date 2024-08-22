#!/bin/bash

MYSQL_USER='root'
MYSQL_PASSWORD='debezium'

sudo docker exec -i  b779bf46ebf9  mysql -u$MYSQL_USER -p$MYSQL_PASSWORD isanteplus < /home/ubuntu/code/sedish-haiti.org/etl_2.8.1/isanteplusreportsdmlscript.sql
sleep 1
sudo docker exec -i  b779bf46ebf9  mysql -u$MYSQL_USER -p$MYSQL_PASSWORD isanteplus < /home/ubuntu/code/sedish-haiti.org/etl_2.8.1/insertion_obs_by_day.sql
sleep 1
sudo docker exec -i  b779bf46ebf9  mysql -u$MYSQL_USER -p$MYSQL_PASSWORD isanteplus < /home/ubuntu/code/sedish-haiti.org/etl_2.8.1/patient_status_arv_dml.sql






