#!/bin/bash

psql -h 172.19.1.97 -U postgres -c 'CREATE USER dvir;'
psql -h 172.19.1.97 -U postgres -c 'CREATE DATABASE dvir;'
pg_restore --exit-on-error --verbose --dbname=dvir -h 172.19.1.97 -U postgres dvir-dump.tar
