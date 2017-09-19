#!/bin/bash

psql -h 172.19.1.97 -U postgres -c 'CREATE USER dvir;'
psql -h 172.19.1.97 -U postgres -c 'CREATE DATABASE dvir;'
psql -h 172.19.1.97 -U postgres -c 'GRANT ALL PRIVILEGES ON DATABASE "dvir" to dvir;'
psql -h 172.19.1.97 -U dvir -d dvir -1 -f dvir.dump
