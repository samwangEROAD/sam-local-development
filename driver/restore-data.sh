#!/bin/bash

psql -h 172.19.1.97 -U postgres -c 'CREATE USER driver;'
psql -h 172.19.1.97 -U postgres -c 'CREATE DATABASE driver;'
pg_restore --exit-on-error --verbose --dbname=driver -h 172.19.1.97 -U postgres driver-dump.tar
